trigger CS_AllProjectAvailabilityTrigger on CS_Project_Availability__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isAfter) {
        
            if(Trigger.isUpdate || Trigger.isInsert) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectAvailabilityUpdateOrInsert(Trigger.newMap);
            } else if(Trigger.isDelete) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectAvailabilityDelete(Trigger.oldMap);
            } else if(Trigger.isUndelete) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsAfterProjectAvailabilityUnDelete(Trigger.newMap);
            }
        } 
    }        
}