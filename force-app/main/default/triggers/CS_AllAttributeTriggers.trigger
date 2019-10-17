trigger CS_AllAttributeTriggers on cscfga__Attribute__c (before insert, after insert, before update, after update) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isAfter && Trigger.isInsert) {
            CS_AllAttributeTriggerHelper.handleAfterInsert(trigger.newMap);
        
        }
    }
}