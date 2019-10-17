trigger bUPD_populateHSAEmail on ASP__c (before update) {
    /*       
    Author           : Cognizant        
    Functionality    : This trigger will Populate the HSA email id in the ASP record for sending the mail.
    Create Date      : 30 Nov 2010        
    Change History   :        
    Modified Date    :    
    */
    Set<string> setids = new Set<string>();
    Map <Id,ASP__c> lstAsps = new Map <Id,ASP__c>();
     for (ASP__c objAsp:Trigger.new){
            if(objAsp.Status__c =='Submitted'){
                setids.add(objAsp.App_Assigned_Payroll__c);
                system.debug('Set id--->'+setids);
                objAsp.Related_CHI_Lead__c = objAsp.CHI_Lead_ID__c;
            objAsp.Submitted__c = true;
            objAsp.Submitted_Date__c = Date.Today();
            if(objAsp.Payment_Option__c =='Green Deal Finance')
            {
              lstAsps.put(objAsp.CHI_Lead_ID__c,objAsp);
            } 
            }
     }
     List<Employee__c> lst_hsa = new List<Employee__c>(); 
     /* Code change to address array of update 15/06/2011 */
     Map<string,string> emailIdMap = new Map<string,string>();
     if(setids.size()>0)
     lst_hsa  = [Select id, name, Employee_Number__c,Salesforce_User__r.Email from Employee__c where Employee_Number__c IN:setids];          
     if(lst_hsa .size()>0){
        for(Employee__c objemp:lst_hsa){
    emailIdMap.put(objemp.Employee_Number__c,objemp.Salesforce_User__r.Email);
        
       }
    }
    system.debug('emailIdMap --->'+emailIdMap );
    
   list <Quote_Product__c> qplist =new list< Quote_Product__c>();
   map<id, string> RHCMap = new map<id, string>();
   list<Id> rhcIds= system.label.RHC_Product_Id.split(',');
   qplist= [select Id, ASP__c,ASP_Reason__c from Quote_Product__c where ASP__c in :Trigger.new and Product__c in :rhcIds];
   system.debug('quote Products-->'+qplist);
   if(qplist.size()>0)
   {
     for(Quote_Product__c q :qplist)
     {
         RHCMap.put(q.ASP__c, q.ASP_Reason__c);
         cls_IsRun.setRHCBGRun();  //PRB00020964 
     }
   }
   system.debug('RHC Map--->'+RHCMap);
   list<BigMachines_Quote__c> updateingQuotes = new list<BigMachines_Quote__c>();
   for (ASP__c objAsps:Trigger.new){
            if(objAsps.Status__c =='Submitted'){
               objAsps.HSA_Email__c = emailIdMap.get(objAsps.App_Assigned_Payroll__c);
              }
              if(RHCMap.containskey(objAsps.Id))
              {
                updateingQuotes.add(new BigMachines_Quote__c(id = objAsps.Quote__c, RHCStatus__c = RHCMap.get(objAsps.Id)));
              }
          }
   system.debug('updateingQuotes--->'+updateingQuotes);
      if(updateingQuotes.size()>0)
   {
     update updateingQuotes;
     //Fix for PRB00016833 - BGSAMS SUPPORT
     cls_IsRun.isBGRun=false;

   }
   
   
   /*
       Green Deal Finance ASP should add the Charge to customer on ASP to Financed amount on CHI lead.
       Reason: CHI Eng will not collect any balance in this scenario. This will ensure Quote Amount will always be 
       equal to Financed Amount. 
   */
   if(lstAsps.size()>0)
   {
       list<Opportunity> updatelist = new list<Opportunity> ();
       for(Opportunity opp : [Select Id,Finance_Amount__c from Opportunity where id in: lstAsps.keyset()])
       {
         if(opp.Finance_Amount__c ==null)
         opp.Finance_Amount__c =0;
         double extraMoney = lstAsps.get(opp.id).Charge_to_Customer__c;
         opp.Finance_Amount__c+=extraMoney;
         updatelist.add(opp);
       }
       
       cls_IsRun.setgeneralTriggerSwitch();
       update updatelist;
   }
          
   }