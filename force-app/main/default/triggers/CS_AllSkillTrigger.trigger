trigger CS_AllSkillTrigger on CS_Skill__c (after update) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        CS_AllSkillTriggerHelper.updatePartTotalLowAndStandardCost(Trigger.newMap, 'skill');
    }
}