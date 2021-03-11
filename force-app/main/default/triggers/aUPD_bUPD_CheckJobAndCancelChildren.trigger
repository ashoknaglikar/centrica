trigger aUPD_bUPD_CheckJobAndCancelChildren on Opportunity (after update, after insert, before insert, before update) {
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    list<Deposit_number__c> usedNumbers = new list<Deposit_number__c>();
    if(trigger.isbefore)
    {
          
          if(trigger.isInsert || trigger.isUpdate)
          {
           for(Opportunity opp: trigger.new)
           {
              Opportunity oldOpp = new Opportunity();
              if(trigger.isupdate)
              oldOpp = trigger.oldmap.get(opp.Id);
              
              /*if((opp.Derived_Payment_Reference_Number__c|| system.label.Deposit_Reference_Number=='on')
                  &&((trigger.isInsert && opp.Payment_Reference_Number__c == null)
                  ||(trigger.isUpdate && opp.Payment_Reference_Number__c==null && opp.Sales_visit_date_time__c!=null && opp.Sales_visit_date_time__c!=oldopp.Sales_visit_date_time__c)))*/
        if(system.label.Deposit_Reference_Number=='on'&&opp.Payment_Reference_Number__c == null&&(trigger.isInsert||(trigger.isUpdate&& opp.Sales_visit_date_time__c!=null && opp.Sales_visit_date_time__c!=oldopp.Sales_visit_date_time__c))
           ||(opp.Derived_Payment_Reference_Number__c&&opp.Payment_Reference_Number__c == null)&&(trigger.isInsert||(trigger.isupdate&&opp.Derived_Payment_Reference_Number__c==true&&oldopp.Derived_Payment_Reference_Number__c==false)))
              {
                  Deposit_number__c refNum =utilities.getAvailableRefNumber();
                  if(refNum!=null)
                  {
                      refNum.Status__c = 'Used';
                      opp.Payment_Reference_Number__c = refNum.name;
                     
                      usedNumbers.add(refNum);
                  }
                  
              }
          }
        }
                  
                  
// mark the used numbes as used 
        if(usedNumbers.size()>0)
        {
            update usedNumbers;
        }
        
        if(!lock.cchRecursiveStopper && (trigger.isInsert || trigger.isupdate))
       
        {
            lock.cchRecursiveStopper = true;
            list<Opportunity> oppToBeSentToCCH = new list<Opportunity>();
            for(Opportunity opp: trigger.new)
            {
                Opportunity oldOpp = new Opportunity();
                if(trigger.isupdate)
                oldOpp = trigger.oldmap.get(opp.Id);
                if(opp.StageName!= 'Closed Lost'  && opp.StageName!= 'Expired'  && opp.StageName!= 'Closed Won'  &&
                (trigger.IsInsert && (opp.Customer_Marketing_Consent__c!=null || opp.Marketing_Preferences__c != null))
                ||(trigger.isupdate &&
                (opp.Customer_Marketing_Consent__c != oldOpp.Customer_Marketing_Consent__c || 
                opp.Marketing_Preferences__c!=oldOpp.Marketing_Preferences__c)))
                {
                    opp.MPU_time__c = system.now();
                    oppToBeSentToCCH.add(opp);
                }
            }
            
            if(oppToBeSentToCCH.size()>9 || system.label.CCHIntegrationSwitch == 'off')
            {
                for(Opportunity opp : oppToBeSentToCCH)
                {
                    opp.SAP_Cloud_Integration_Status__c ='In Queue';
                }
            }
        }
    }
    else if(trigger.isAfter && (trigger.isInsert || trigger.isupdate))
    {
        
        /*//Suguna
        if(system.label.Deposit_Reference_Number=='on')
        {
        if(trigger.isInsert)
        {
            system.debug('Sugu inside after insert');
           List<Deposit_number__c> depositNumList = new List<Deposit_Number__c>();
           map<string,id> refNum= new map<string,id>();
           for(opportunity opp: trigger.new)
           {
               system.debug('Sugu new id '+opp.id+' - '+opp);
              refNum.put(opp.Payment_Reference_Number__c,opp.id);
           }
           system.debug('Sugu map '+refNum);
           for(Deposit_Number__c dn:[select id,status__c,opportunity__c,name from Deposit_Number__c where name=:refNum.keyset() and status__c='Available'])
           {
               dn.status__c='Used';
               dn.opportunity__c=refNum.get(dn.name);
               depositnumList.add(dn);
           }
           
           if(!depositnumList.isempty())
           update depositnumList;
        }
        }
        //ends
        */
        if(!lock.iscchUser() && !lock.cchApiRecursiveStopper )
        {
            lock.cchApiRecursiveStopper= true;
            list<Opportunity> oppToBeSentToCCH = new list<Opportunity>();
            for(Opportunity opp: trigger.new)
            {
                Opportunity oldOpp = new Opportunity();
                if(trigger.isupdate)
                oldOpp = trigger.oldmap.get(opp.Id);
                if(opp.StageName!= 'Closed Lost'  && opp.StageName!= 'Expired'  && opp.StageName!= 'Closed Won'  &&
                opp.Customer_Marketing_Consent__c != oldOpp.Customer_Marketing_Consent__c || 
                opp.Marketing_Preferences__c!=oldOpp.Marketing_Preferences__c)
                {
                    oppToBeSentToCCH.add(opp);
                }
                
            }
            if(oppToBeSentToCCH.size()<8 && system.label.CCHIntegrationSwitch == 'on')
            {
                for(Opportunity opp : oppToBeSentToCCH)
                {
                    customerChoiceHubHTTPRequest.callCreateCustomerOrUpdateMarketingPreferences(new list<Id>{opp.Id});
                }
                
            }
        }
    }
    
  System.debug('entered ==== '+cls_IsRun.isOppoCanRun);
    if (cls_IsRun.isOppoCanRun==false && trigger.isUpdate && trigger.isAfter) {            
        cls_IsRun.setIsOppoCanRun();
        Map<String,opportunity> oppMap = new Map<String,Opportunity>();
        Map<String,opportunity> GDF_Changed = new Map<String,Opportunity>();
        
        Integer cnt =0;
        Opportunity[] oldOpp = Trigger.old;
        for(Opportunity opp : Trigger.new){
            System.debug('1 '+oldOpp[cnt].StageName+':'+opp.Stagename+':'+oldOpp[cnt].auto_cancel__c+':'+opp.auto_cancel__c);
            if(oldOpp[cnt].StageName == 'Suspended' && opp.Stagename == 'Closed Lost' && oldOpp[cnt].auto_cancel__c == false && opp.auto_cancel__c == true)
                oppMap.put(opp.id,opp);
                
            else if(opp.GDF_Offer__c != oldOpp[cnt].GDF_Offer__c)
            {
                GDF_Changed.put(opp.id,opp);
                
            }    
        }
        if(oppMap.size() > 0){           
            try{
              //System.debug('#########Calling cancel batch ########');
              SuspendCancelJob suscan = new SuspendCancelJob(); 
              suscan.cancelJobAndChildren(Trigger.new[0].id); 
            }catch(Exception e){
              System.debug('Exception : '+e.getMessage());  
            }
        }
        
        if(GDF_Changed.size()>0)
        {
            list<Job__c> updateJobs = new list<Job__c>();
            for(Job__c job: [Select Id, GDF_Offer__c, CHI_Lead__c from Job__c where CHI_Lead__c in:GDF_Changed.keyset() and Is_Downtime_Job__c = false and Is_Remedial_Job__c = false and Is_Remedial_Job__c = false and Split_Job__c = false])
            {
                job.GDF_Offer__c = GDF_Changed.get(job.CHI_Lead__c).GDF_Offer__c;
                updateJobs.add(job);
            }
            
            if(updateJobs.size()>0)
            {
                lock.jobTriggerSwitch = true;
                update updateJobs;
            }
        }
    }
}