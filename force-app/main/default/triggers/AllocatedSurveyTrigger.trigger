trigger AllocatedSurveyTrigger on Allocated_Survey__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		new SurveyAllocationService().createSurveyResponses(Trigger.newMap);
	}

}