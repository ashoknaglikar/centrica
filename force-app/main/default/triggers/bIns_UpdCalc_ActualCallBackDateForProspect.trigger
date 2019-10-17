trigger bIns_UpdCalc_ActualCallBackDateForProspect on Lead (before insert, before update) {
   
   boolean flag;
   for(Lead l:trigger.new)
   {
    if(l.Lead_Type__c == 'Prospect')
    {
        l.Prospect__c = true;
    }else
    {
        l.Prospect__c = false;
    }
      flag = false; 
      if(trigger.isInsert)
      {
        flag = true;
      }else if(trigger.isUpdate)
      {
        if(trigger.oldMap.get(l.Id).Call_Back_Date__c != trigger.newMap.get(l.Id).Call_Back_Date__c  || 
           trigger.oldMap.get(l.Id).Overridden_Call_Back_Date__c != trigger.newMap.get(l.Id).Overridden_Call_Back_Date__c ||
           trigger.oldMap.get(l.Id).Actual_Call_Back_Date__c != trigger.newMap.get(l.Id).Actual_Call_Back_Date__c)
           {
            flag = true;
           }
      }     
    
        if((flag == true && (l.Call_Back_Date__c != '' || l.Call_Back_Date__c != null)) || l.Actual_Call_Back_Date__c == null)
        {
            if(l.Call_Back_Date__c == 'Over Ride Call Back Date') 
            {
                l.Actual_Call_Back_Date__c = l.Overridden_Call_Back_Date__c;
            }
            else if(l.Call_Back_Date__c == 'After 1 Week') 
            {
                l.Actual_Call_Back_Date__c = system.today().addDays(7);
            }
            else if(l.Call_Back_Date__c == 'After 2 Week') 
            {
                l.Actual_Call_Back_Date__c = system.today().addDays(14);
            }
            else if(l.Call_Back_Date__c == 'After 1 Month') 
            {
                l.Actual_Call_Back_Date__c = system.today().addMonths(1);
            }
            else if(l.Call_Back_Date__c == 'After 2 Months') 
            {
                l.Actual_Call_Back_Date__c = system.today().addMonths(2);
            }
            else if(l.Call_Back_Date__c == 'After 3 Months') 
            {
                l.Actual_Call_Back_Date__c = system.today().addMonths(3);
            }
        }
   }
}