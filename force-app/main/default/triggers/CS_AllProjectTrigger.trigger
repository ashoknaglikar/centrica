trigger CS_AllProjectTrigger on CS_Project__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isAfter) {
        
            if(Trigger.isUpdate) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectUpdateOrDelete(Trigger.newMap, false);
            } else if (Trigger.isUndelete) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectUpdateOrDelete(Trigger.newMap, false);
            }
        } 

        if(Trigger.isBefore) {

            if(Trigger.isDelete) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectUpdateOrDelete(Trigger.oldMap, true);
            }
        }
    }
}