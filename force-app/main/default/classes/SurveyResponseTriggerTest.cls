@isTest
private class SurveyResponseTriggerTest
{
	
	@isTest static void testAfterUpdate()
	{
		Development_Survey__c survey = DevelopmentSurveyTestHelper.createSurvey();

        User userA = DevelopmentSurveyTestHelper.createUserWithProfile('Standard User', 'userA');
        Employee__c employeeA = DevelopmentSurveyTestHelper.createEmployee('Andy', 'Another', 'CO5192AB', userA);

        Allocated_Survey__c allocatedSurvey = new Allocated_Survey__c();
        allocatedSurvey.Name = 'test allocated survey';
        allocatedSurvey.Development_Survey__c = survey.Id;
        allocatedSurvey.Employee__c = employeeA.Id;

        insert allocatedSurvey;

        List<Survey_Response__c> surveyResponses = [Select Id, Name, Recipient__c, SurveyName__c from Survey_Response__c where Recipient__c = :userA.Id and SurveyName__c = :allocatedSurvey.Name];
        System.assertEquals(1, surveyResponses.size());

        Test.startTest();

        Survey_Response__c response = surveyResponses[0];

        System.runAs(userA)
        {
        	response.Recipient_Status__c = 'Ready for Review';
        	update response;
        }
    
    	response.Allocator_Status__c = 'Ready for Review';
    	update response;

        Test.stopTest();



	}

	
}