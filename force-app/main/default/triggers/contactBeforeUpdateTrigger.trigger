trigger contactBeforeUpdateTrigger on Contact (before update) {

   for(Contact c : Trigger.New){
       
       if(c.Marketing_Preference__c!=null && c.Marketing_Preference__c.contains('No Changes'))
       c.Marketing_Preference__c = c.Marketing_Preference__c.replace('No Changes', '');
   
      if(c.Dont_Update_Finance_Info__c && UserInfo.getUserName().contains('bmsfdcintegration') &&
      (c.bm_fCreditCheckDate__c != Trigger.OldMap.get(c.ID).bm_fCreditCheckDate__c ||
          c.bm_cCCreditCheckOutcome__c != Trigger.OldMap.get(c.ID).bm_cCCreditCheckOutcome__c ||
          c.bm_fAcceptanceNumber__c != Trigger.OldMap.get(c.ID).bm_fAcceptanceNumber__c ||
          c.bm_fAmountOfCredit__c != Trigger.OldMap.get(c.ID).bm_fAmountOfCredit__c ||
          c.bm_fApplicationDate__c != Trigger.OldMap.get(c.ID).bm_fApplicationDate__c ||
          c.bm_fApplicationStatus__c != Trigger.OldMap.get(c.ID).bm_fApplicationStatus__c ||
          c.bm_fFinancialProduct__c != Trigger.OldMap.get(c.ID).bm_fFinancialProduct__c ||
          c.BM_Finance_Status_Date__c != Trigger.OldMap.get(c.ID).BM_Finance_Status_Date__c)){
      
          c.bm_fCreditCheckDate__c = Trigger.OldMap.get(c.ID).bm_fCreditCheckDate__c;
          c.bm_cCCreditCheckOutcome__c = Trigger.OldMap.get(c.ID).bm_cCCreditCheckOutcome__c;
          c.bm_fAcceptanceNumber__c = Trigger.OldMap.get(c.ID).bm_fAcceptanceNumber__c;
          c.bm_fAmountOfCredit__c = Trigger.OldMap.get(c.ID).bm_fAmountOfCredit__c;
          c.bm_fApplicationDate__c = Trigger.OldMap.get(c.ID).bm_fApplicationDate__c;
          c.bm_fApplicationStatus__c = Trigger.OldMap.get(c.ID).bm_fApplicationStatus__c;
          c.bm_fFinancialProduct__c= Trigger.OldMap.get(c.ID).bm_fFinancialProduct__c;
          c.BM_Finance_Status_Date__c= Trigger.OldMap.get(c.ID).BM_Finance_Status_Date__c;
      }
       
   }

}