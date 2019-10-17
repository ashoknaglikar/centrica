trigger SurveyResponse on Survey_Response__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{

    if(Trigger.isAfter && Trigger.isUpdate)
    {
        new SurveyResponseService().respondToSurveyStatusChanges(Trigger.oldMap, Trigger.newMap);
    }
    

}