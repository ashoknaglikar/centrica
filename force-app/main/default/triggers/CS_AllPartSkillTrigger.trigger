trigger CS_AllPartSkillTrigger on CS_Part_Skill__c (after insert, after update, before delete) {
    
    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isDelete && Trigger.isBefore) {
            CS_AllSkillTriggerHelper.updatePartTotalLowAndStandardCostAfterPSDeletion(Trigger.oldMap);
        } 
        else if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
            CS_AllSkillTriggerHelper.updatePartTotalLowAndStandardCost(Trigger.newMap, 'partSkill');
        }
    }
    
}