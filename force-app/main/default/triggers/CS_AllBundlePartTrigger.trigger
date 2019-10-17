trigger CS_AllBundlePartTrigger on CS_Bundle_Part_Association__c (after insert, after update, before delete) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    {
        if (Trigger.isBefore && Trigger.isDelete) {
            CS_AllBundlePartTriggerHelper.updateBundleSupportedBoilerGroupsAfterBPAssociationDelete(Trigger.oldMap);
        } 
        else if (Trigger.isAfter && Trigger.isInsert) {
            CS_AllBundlePartTriggerHelper.handleAfterInsert(Trigger.newMap);
        }
        
        else if (Trigger.isAfter && Trigger.isUpdate) {
            CS_AllBundlePartTriggerHelper.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }    
   
}