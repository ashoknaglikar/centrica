@isTest
private class SurveyQuestionResponseTriggerTest {
	
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

        List<Survey_Response__c> surveyResponses = [Select Id, Name, Recipient__c, SurveyName__c, Allocator_Status__c, Recipient_Status__c from Survey_Response__c where Recipient__c = :userA.Id and SurveyName__c = :allocatedSurvey.Name];
        System.assertEquals(1, surveyResponses.size());
        Survey_Response__c response = surveyResponses[0];


        List<Survey_Question_Response__c> questions = [Select Id, Is_for_Recipient__c from Survey_Question_Response__c where SurveyResponse__c = :response.Id];
		System.assertEquals(4, questions.size());

		List<Survey_Question_Response__c> recipientAnswers = new List<Survey_Question_Response__c>();
		List<Survey_Question_Response__c> allocatorAnswers = new List<Survey_Question_Response__c>();
		for(Survey_Question_Response__c question : questions)
		{
			if(question.Is_for_Recipient__c)
			{
				recipientAnswers.add(question);
			}
			else
			{
				allocatorAnswers.add(question);
			}
		}
        
        Test.startTest();

       
        System.runAs(userA)
        {
        	recipientAnswers[0].Answer_Text__c = 'Never';
        	recipientAnswers[0].Answer_Comment__c = 'Well almost never';

        	update recipientAnswers[0];	
        }

        allocatorAnswers[0].Answer_Text__c = 'Sometimes';
        allocatorAnswers[0].Answer_Comment__c = 'Well usually sometimes';

        update allocatorAnswers[0];	
    
    	//response.Allocator_Status__c = 'Ready for Review';
    	//update response;

        Test.stopTest();



	}
	
}