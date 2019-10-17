trigger CS_AllPartAvailabilityTrigger on CS_Part_Availability__c (after insert, after update, before delete) {
    
    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isDelete && Trigger.isBefore) {
            CS_AllPartAvailabilityTriggerHelper.updatePartIncludedInRegionsOnPADelete(Trigger.oldMap);
        }
        else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {        
            CS_AllPartAvailabilityTriggerHelper.updatePartIncludedInRegions(Trigger.newMap);
        }
    }   
}