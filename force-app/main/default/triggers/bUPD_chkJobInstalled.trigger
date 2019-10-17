trigger bUPD_chkJobInstalled on Opportunity (before insert,before update) {
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    Opportunity[] oldOpp = Trigger.old;
    map<id, id > oppReferralEng = new map<Id, Id> ();
    list<Opportunity> smOpportunities = new list <Opportunity>();
    for(Opportunity opp : Trigger.new)
    {
        if(trigger.isUpdate)
        {
        
            if(opp.SM_discount_given__c != trigger.oldMap.get(opp.Id).SM_discount_given__c && opp.SM_discount_given__c &&  opp.Referral_Employee__c!= null )
            {
                // code to add the SM Discount text to TA Notes 
                oppReferralEng.put(opp.Id, opp.Referral_Employee__c);
                smOpportunities.add(opp);
                
            }else if(opp.SM_discount_given__c != trigger.oldMap.get(opp.Id).SM_discount_given__c && !opp.SM_discount_given__c)
            {
                // code to remove the SM Discount text from ta Notes.
                Opportunity new_opp = opp;
                if(new_opp.ta_notes__c!=null && new_opp.ta_notes__c.contains(system.label.SM_Discount_2))
                {
                    string s = new_opp.ta_notes__c;

                    integer start = s.indexOf(system.label.SM_Discount_2);
                    integer end_int = s.indexOf(system.label.SM_Disocunt_3);
                    
                    if(start!= -1 && end_int != -1)
                    {
                    string first = s.substring(0,start);
                    
                    string second = s.substring(s.indexOf(system.label.SM_Disocunt_3)+system.label.SM_Disocunt_3.length(), s.length());
                    
                    new_opp.ta_notes__c = first + ' '+second;
                    }
                }
                
            }
        }    
        
        if(opp.Id!=null && 	opp.CHI_Lead_Id__c!=null && opp.Install_Postcode__c !=null)
        {
            
            
            IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal');
            if(keyRecord!=null)
            {
            Blob key = Blob.valueOf(keyRecord.Key__c) ;
            Blob data = Blob.valueOf(opp.Id);
            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
    
            opp.Opp_Id_Encrypted__c =EncodingUtil.convertToHex(encrypted);
            }
            if(opp.Customer_Portal_Key__c==null && IV_Vectors__c.getinstance('Portal Key Length') != null )
            {
            Integer len = integer.valueof(IV_Vectors__c.getinstance('Portal Key Length').key__c);
            
            String chars = label.CPKKeyCharacters;//'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789abcdefghijkmnopqrstuvwxyz';
            String[] result = new String[len];
            Integer idx = 0;
            while(idx < len) {
                Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length()-1);
                result[idx++] = chars.substring(chr, chr+1);
            }
            String key = String.join(result,'');
            
            /*

            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            */

            opp.Customer_Portal_Key__c = key.substring(0,len);
            Blob bPrehash = Blob.valueOf(opp.Customer_Portal_Key__c); 
            Blob bsig = Crypto.generateDigest('SHA1', bPrehash); 
            
            opp.Customer_Portal_Key_Salted__c =  EncodingUtil.convertToHex(bsig);
            }
           
            /*
            Blob oppIDblob = blob.valueof(opp.Install_Postcode__c+'-'+opp.CHI_Lead_Id__c+'-'+opp.Id);
            opp.Opp_Id_Encrypted__c = EncodingUtil.base64Encode(oppIDblob);*/
            
        }
    }
    
    if(oppReferralEng.size()>0)
    {
        map<id,Employee__c> empMap = new  map<id,Employee__c>([select id, Service_Manager_Name__c from Employee__c where id in : oppReferralEng.values()]);
        
        for(Opportunity opp : smOpportunities)
        {
            string serviceManager= '';
            if(empMap.containsKey(oppReferralEng.get(opp.Id)))
            {
                serviceManager = empMap.get(oppReferralEng.get(opp.Id)).Service_Manager_Name__c ;
            }
            string notes  = system.label.SM_Discount_1.replace('{createddate}', string.valueof(opp.createdDate.date())).replace('{smmanager}', 	serviceManager);
            if(opp.ta_notes__c==null)
            opp.ta_notes__c = notes;
            else
            opp.ta_notes__c =notes+opp.ta_notes__c;
        }
    }
    
    Integer count=0;
    boolean flag;      
    if (cls_IsRun.isOppoJobRun==false) {            
        cls_IsRun.setIsOppoJobRun();
        Map<String,opportunity> oppMap = new Map<String,Opportunity>();
        
        for(Opportunity opp : Trigger.new){
            
            
            
            /*Modified : Cognizant
              Date : 07:16:2010
              Reason: User cannot cancel Opportunity from the Picklist value, they should use the Cancel button.
            */
            // Defect fix - CHI Small conversion - Close CHI Lead through inbound call scripts
            if(!opp.isSystem__c && opp.Stagename == 'Closed Lost' && opp.Can_Close_Lead__c =='False' && opp.By_Pass_User_Validation__c == false) 
            {
                opp.addError('Cannot make an Opportunity Closed Lost from this field, please use the Cancel button.');
            }
            
          /*  if(!opp.isSystem__c && oldOpp[count].isClosed && !(Trigger.new).isEmpty()&& opp.Can_Close_Lead__c =='False'){
                opp.addError('Cannot update Opportunity as it is Closed');
            }else{
                opp.isSystem__c = false;
            }
           */
            
            if(opp.Stagename == 'Closed Lost' ||opp.Stagename == 'Suspended'  )
                oppMap.put(opp.id,opp);
            count++;
             /*Modified : Cognizant
              Date : 01:07:2011
              Reason: To update the Actual call back Date in Case If its Prospect.
            */
        
      if(opp.Stagename == 'Prospect')  
      {
          flag = false; 
          if(trigger.isInsert)
          {
            flag = true;
          }
          if(trigger.isUpdate)
          {
            if(trigger.oldMap.get(opp.Id).Call_Back_Date__c != trigger.newMap.get(opp.Id).Call_Back_Date__c  || 
               trigger.oldMap.get(opp.Id).Override_Call_Back_Date__c != trigger.newMap.get(opp.Id).Override_Call_Back_Date__c ||
               trigger.oldMap.get(opp.Id).Actual_Call_Back_Date__c != trigger.newMap.get(opp.Id).Actual_Call_Back_Date__c)
               {
                flag = true;
               }
          }     
        
            if((flag == true && (opp.Call_Back_Date__c != '' || opp.Call_Back_Date__c != null))|| opp.Actual_Call_Back_Date__c == null )
            {
                if(opp.Call_Back_Date__c == 'Over Ride Call Back Date') 
                {
                    opp.Actual_Call_Back_Date__c = opp.Override_Call_Back_Date__c;
                }
                else if(opp.Call_Back_Date__c == 'After 1 Week') 
                {
                    opp.Actual_Call_Back_Date__c = system.today().addDays(7);
                }
                else if(opp.Call_Back_Date__c == 'After 2 Week') 
                {
                    opp.Actual_Call_Back_Date__c = system.today().addDays(14);
                }
                else if(opp.Call_Back_Date__c == 'After 1 Month') 
                {
                    opp.Actual_Call_Back_Date__c = system.today().addMonths(1);
                }
                else if(opp.Call_Back_Date__c == 'After 2 Months') 
                {
                    opp.Actual_Call_Back_Date__c = system.today().addMonths(1);
                }
                else if(opp.Call_Back_Date__c == 'After 3 Months') 
                {
                    opp.Actual_Call_Back_Date__c = system.today().addMonths(1);
                }
            }
        }
        }
        if(oppMap.size() > 0){
            if(Trigger.isBefore){
            //Code fix by BGSAMS Support - PRB00016438 starts
                List<JOb__c> jobList = [select CHI_Lead__c,CHI_Lead__r.Stagename,Status__c,sub_status__c,Cancel_Job__c,Is_Downtime_Job__c from job__c where CHI_Lead__c in : oppMap.keySet()];
                
                if(jobList.size() > 0){
                    List<JOb__c> updateJobsList = new List<JOb__c>();                
                    for(Job__c job : jobList){
                        Opportunity oppty = oppMap.get(job.CHI_LEAD__c); 
                        if(Trigger.isBefore && job.status__c == 'Installed' && job.Is_Downtime_Job__c != true){
                        //Code fix by BGSAMS Support - PRB00016438 ends
                         Opportunity objOppty  = oppMap.get(job.CHI_Lead__c);
                         objOppty.addError('Cannot Close Lost/Suspend the CHI Lead as there are one or more Installed jobs against it');   
                        }
                    }
                 }
             }
        }
    }
}