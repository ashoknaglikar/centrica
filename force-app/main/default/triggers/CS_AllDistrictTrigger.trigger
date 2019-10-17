trigger CS_AllDistrictTrigger on District__c (before insert, after insert, before update, after update, before delete, after delete) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isBefore) {
        
            if(Trigger.isUpdate) {
                CS_AllDistrictTriggerHelper.updateIncludedProjectsBeforeDistrictUpdate(Trigger.newMap);
            }
        } 

        if(Trigger.isAfter) {

            if(Trigger.isUpdate) {
                CS_AllDistrictTriggerHelper.updateRelatedPostcodeSector(Trigger.newMap);
            }
        }
    }        
       
}