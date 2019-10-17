trigger SurveyQuestionResponse on Survey_Question_Response__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{

	if(Trigger.isAfter && Trigger.isUpdate)
	{
		new SurveyQuestionResponseService().updateSurveyStatus(Trigger.oldMap, Trigger.newMap);
	}
}