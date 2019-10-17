/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
 @isTest
private class SurveyQuestionResponseSobjectAdapterTest
{
	
	@isTest static void testGetters()
	{
		Survey_Question_Response__c record = createQuestion();

		Test.startTest();

		SurveyQuestionResponse question = new SurveyQuestionResponseSobjectAdapter(record);

		Test.stopTest();

		System.assertEquals(record.Id, question.getId());
		System.assertEquals(record.SurveyResponse__c, question.getSurveyResponseId());
		System.assertEquals(record.Question_Text__c, question.getQuestionText());
		System.assertEquals(record.Question_order__c, question.getQuestionOrder());
		System.assertEquals(record.Answer_Text__c, question.getAnswerText());
		System.assertEquals(record.Answer_Comment__c, question.getAnswerComment());
		System.assertEquals(record.Is_for_Recipient__c, question.isForRecipient());
		System.assertEquals(record.Development_Survey_Question__c, question.getQuestionTemplateId());

		SObjectAdapter adapter = (SObjectAdapter)question;
		SObject sobj = adapter.getAdaptedRecord();
		System.assert(record === sobj);
	}
	

	@isTest static void testSetters()
	{
		Survey_Question_Response__c record = createQuestion();

		String answerTextFixture = 'Sometimes';
		String answerCommentFixture = 'Lorem Ipsum';

		SurveyQuestionResponse question = new SurveyQuestionResponseSobjectAdapter(record);

		Test.startTest();

		question.setAnswerText(answerTextFixture);
		question.setAnswerComment(answerCommentFixture);

		Test.stopTest();

		System.assertEquals(record.Answer_Text__c, answerTextFixture);
		System.assertEquals(record.Answer_Comment__c, answerCommentFixture);

		System.assertEquals(record.Id, question.getId());
		System.assertEquals(record.SurveyResponse__c, question.getSurveyResponseId());
		System.assertEquals(record.Question_Text__c, question.getQuestionText());
		System.assertEquals(record.Question_order__c, question.getQuestionOrder());
		System.assertEquals(record.Answer_Text__c, question.getAnswerText());
		System.assertEquals(record.Answer_Comment__c, question.getAnswerComment());
		System.assertEquals(record.Is_for_Recipient__c, question.isForRecipient());
		System.assertEquals(record.Development_Survey_Question__c, question.getQuestionTemplateId());

	}


	private static Survey_Question_Response__c createQuestion()
	{
		Survey_Response__c survey = DevelopmentSurveyTestHelper.createSurveyResponse();
		List<Survey_Question_Response__c> records = DevelopmentSurveyTestHelper.questionsForSurvey(survey.Id);
		return records[0];
	}
	
}