trigger CS_AllMaterialTrigger on CS_Material__c (after update) {
    
    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        CS_AllMaterialTriggerHelper.updatePartTotalMCost(Trigger.newMap, 'material');
    }    
}