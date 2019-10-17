/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
@isTest
private class SurveyResponseDaoSoqlTest
{
	
	@isTest static void loadSurvey()
	{
		ErrorHandler errorHandler = new ErrorHandlerSpy();
		Survey_Response__c record = DevelopmentSurveyTestHelper.createSurveyResponse();

		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		Test.startTest();

		SurveyResponse surveyResponse = dao.loadSurvey(record.Id);

		Test.stopTest();

		System.assertEquals(record.Id, surveyResponse.getId());
        System.assertEquals(record.Name, surveyResponse.getName());


		System.assertEquals(record.SurveyName__c, surveyResponse.getSurveyName());
		System.assertEquals(record.Overall_Status__c, surveyResponse.getOverallStatus());
		System.assertEquals(record.Allocator_Status__c, surveyResponse.getAllocatorStatus());
		System.assertEquals(record.Allocator__c, surveyResponse.getAllocatorId());
		System.assertEquals(record.Allocator__r.Name, surveyResponse.getAllocatorName());
		System.assertEquals(record.Recipient_Status__c, surveyResponse.getRecipientStatus());
		System.assertEquals(record.Recipient__c, surveyResponse.getRecipientId());
		System.assertEquals(record.Recipient__r.Name, surveyResponse.getRecipientName());
		System.assertEquals(record.Review_Date__c, surveyResponse.getReviewDate());
		System.assertEquals(record.Desired_Outcome__c, surveyResponse.getDesiredOutcome());
		System.assertEquals(record.Development_Action__c, surveyResponse.getAction());
		System.assertEquals(record.Action_timescales__c, surveyResponse.getTimescales());
		System.assertEquals(record.Action_owner__c, surveyResponse.getActionOwner());
		System.assertEquals(record.Development_Action_Progress__c, surveyResponse.getActionProgress());
		System.assertEquals(record.CreatedDate, surveyResponse.getCreatedDate());
		System.assertEquals(record.LastModifiedDate, surveyResponse.getLastModifiedDate());

	}
	

	@isTest static void loadSurveyNotFound()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		Test.startTest();

		SurveyResponse surveyResponse = dao.loadSurvey('01Ig0000000D862');

		System.assertEquals(null, surveyResponse);

		System.assertEquals(errorHandler.level, LEVEL_ERROR);
		System.assertEquals(errorHandler.message, 'Could not find the Survey you are trying to access');
		System.assert(errorHandler.messageDetail.startsWith('Contact system administrator. Information trying to find survey with id'));
		System.assert(errorHandler.ex.getMessage().contains('Trying to lookup Survey_Response__c with id'));
		System.assert(errorHandler.ex.getMessage().contains('but got 0 results'));


		Test.stopTest();
	}


	@isTest static void loadQuestions()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c surveyResponse = DevelopmentSurveyTestHelper.createSurveyResponse();
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		Test.startTest();

		List<SurveyQuestionResponse> questions = dao.questionsForSurvey(surveyResponse.Id);

		Test.stopTest();

		System.assertEquals(4, questions.size());
	}

		
	@isTest static void saveSurveyNoChange()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c record = DevelopmentSurveyTestHelper.createSurveyResponse();

		Id idBookmark = record.Id;
		String nameBookmark = record.Name;
		String surveyNameBookmark = record.SurveyName__c;
		String allocatorStatusBookmark = record.Allocator_Status__c;
		String recipientStatusBookmark = record.Recipient_Status__c;
		String overalStatusBookmark = record.Overall_Status__c;
		String allocatorIdBookmark = record.Allocator__c;
		String recipientIdBookmark = record.Recipient__c;
		String allocatorNameBookmark = record.Allocator__r.Name;
		String recipientNameBookmark = record.Recipient__r.Name;
		Date reviewDateBookmark = record.Review_Date__c;
		String desiredOutcomeBookmark = record.Desired_Outcome__c;
		String actionBookmark = record.Development_Action__c;
		String timescalesBookmark = record.Action_timescales__c;
		String actionOwnerBookmark = record.Action_owner__c;
		String actionProgressBookmark = record.Development_Action_Progress__c;
		Datetime createdDateBookmark = record.CreatedDate;
		Datetime lastModifiedDateBookmark = record.LastModifiedDate;
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		SurveyResponse surveyResponse = new SurveyResponseSobjectAdapter(record);

		Test.startTest();

		dao.updateSurvey(surveyResponse);

		Test.stopTest();

		System.assertEquals(record.Id, idBookmark);
		System.assertEquals(record.Name, nameBookmark);
		System.assertEquals(record.SurveyName__c, surveyNameBookmark);
		System.assertEquals(record.Overall_Status__c, overalStatusBookmark);
		System.assertEquals(record.Allocator_Status__c, allocatorStatusBookmark);
		System.assertEquals(record.Allocator__c, allocatorIdBookmark);
		System.assertEquals(record.Allocator__r.Name, allocatorNameBookmark);
		System.assertEquals(record.Recipient_Status__c, recipientStatusBookmark);
		System.assertEquals(record.Recipient__c, recipientIdBookmark);
		System.assertEquals(record.Recipient__r.Name, recipientNameBookmark);
		System.assertEquals(record.Review_Date__c, reviewDateBookmark);
		System.assertEquals(record.Desired_Outcome__c, desiredOutcomeBookmark);
		System.assertEquals(record.Development_Action__c, actionBookmark);
		System.assertEquals(record.Action_timescales__c, timescalesBookmark);
		System.assertEquals(record.Action_owner__c, actionOwnerBookmark);
		System.assertEquals(record.Development_Action_Progress__c, actionProgressBookmark);
		System.assertEquals(record.CreatedDate, createdDateBookmark);
		System.assertEquals(record.LastModifiedDate, lastModifiedDateBookmark);
	}


	@isTest static void saveSurveyStatusChange()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c record = DevelopmentSurveyTestHelper.createSurveyResponse();

		Id idBookmark = record.Id;
		String nameBookmark = record.Name;
		String surveyNameBookmark = record.SurveyName__c;
		String allocatorStatusBookmark = record.Allocator_Status__c;
		String recipientStatusBookmark = record.Recipient_Status__c;
		String overalStatusBookmark = record.Overall_Status__c;
		String allocatorIdBookmark = record.Allocator__c;
		String recipientIdBookmark = record.Recipient__c;
		String allocatorNameBookmark = record.Allocator__r.Name;
		String recipientNameBookmark = record.Recipient__r.Name;
		Date reviewDateBookmark = record.Review_Date__c;
		String desiredOutcomeBookmark = record.Desired_Outcome__c;
		String actionBookmark = record.Development_Action__c;
		String timescalesBookmark = record.Action_timescales__c;
		String actionOwnerBookmark = record.Action_owner__c;
		String actionProgressBookmark = record.Development_Action_Progress__c;
		Datetime createdDateBookmark = record.CreatedDate;
		Datetime lastModifiedDateBookmark = record.LastModifiedDate;
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		SurveyResponse surveyResponse = new SurveyResponseSobjectAdapter(record);

		Test.startTest();

		surveyResponse.setAllocatorStatus('Ready for Review');
		dao.updateSurvey(surveyResponse);

		Test.stopTest();

		System.assertNotEquals(record.Allocator_Status__c, allocatorStatusBookmark);
		System.assertEquals(record.Allocator_Status__c, 'Ready for Review');

		System.assertEquals(record.Id, idBookmark);
		System.assertEquals(record.Name, nameBookmark);
		System.assertEquals(record.SurveyName__c, surveyNameBookmark);
		System.assertEquals(record.Overall_Status__c, overalStatusBookmark);
		
		System.assertEquals(record.Allocator__c, allocatorIdBookmark);
		System.assertEquals(record.Allocator__r.Name, allocatorNameBookmark);
		System.assertEquals(record.Recipient_Status__c, recipientStatusBookmark);
		System.assertEquals(record.Recipient__c, recipientIdBookmark);
		System.assertEquals(record.Recipient__r.Name, recipientNameBookmark);
		System.assertEquals(record.Review_Date__c, reviewDateBookmark);
		System.assertEquals(record.Desired_Outcome__c, desiredOutcomeBookmark);
		System.assertEquals(record.Development_Action__c, actionBookmark);
		System.assertEquals(record.Action_timescales__c, timescalesBookmark);
		System.assertEquals(record.Action_owner__c, actionOwnerBookmark);
		System.assertEquals(record.Development_Action_Progress__c, actionProgressBookmark);
		System.assertEquals(record.CreatedDate, createdDateBookmark);
		System.assertEquals(record.LastModifiedDate, lastModifiedDateBookmark);
	}
	

	@isTest static void saveQuestionsNoChange()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c surveyResponse = DevelopmentSurveyTestHelper.createSurveyResponse();
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		List<SurveyQuestionResponse> questions = dao.questionsForSurvey(surveyResponse.Id);
		
		SurveyQuestionResponse question = questions[0];

		Survey_Question_Response__c  record = [select Id, Answer_Text__c from Survey_Question_Response__c where id = :question.getId()];
		
		Id idBookmark = record.Id;
		String answerTextBookmark = record.Answer_Text__c;

		Test.startTest();

		dao.saveQuestions(questions);

		Test.stopTest();

		System.assertEquals(idBookmark, record.Id);
		System.assertEquals(idBookmark, question.getId());
		System.assertEquals(answerTextBookmark, record.Answer_Text__c);
		System.assertEquals(answerTextBookmark, question.getAnswerText());
	}

	@isTest static void loadActions()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c surveyResponse = DevelopmentSurveyTestHelper.createSurveyResponseWithSurveyActions();
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		Test.startTest();

		List<Survey_Action__c> actions = dao.actionsForSurvey(surveyResponse.Id);

		Test.stopTest();

		System.assertEquals(2, actions.size());
	}

	@isTest static void saveActionsNoChange()
	{
		ErrorHandlerSpy errorHandler = new ErrorHandlerSpy();

		Survey_Response__c surveyResponse = DevelopmentSurveyTestHelper.createSurveyResponseWithSurveyActions();
		
		SurveyResponseDao dao = new SurveyResponseDaoSoql(errorHandler);

		List<Survey_Action__c> actions = dao.actionsForSurvey(surveyResponse.Id);
		
		Survey_Action__c action = actions[0];

		Survey_Action__c record = [select Id, Action__c, Action_Owner__c, Action_Timescale__c, Desired_Outcome__c, Progress_Made__c from Survey_Action__c where id = :action.Id];
		
		Id idBookmark = record.Id;
		String actionBookmark = record.Action__c;
		String actionOwnerBookmark = record.Action_Owner__c;
		String actionTimescaleBookmark = record.Action_Timescale__c;
		String desiredOutcomeBookmark = record.Desired_Outcome__c;
		String progressMadeBookmark = record.Progress_Made__c;

		Test.startTest();

		dao.saveActions(actions);

		Test.stopTest();

		System.assertEquals(idBookmark, record.Id);
		System.assertEquals(idBookmark, action.Id);
		System.assertEquals(actionBookmark, record.Action__c);
		System.assertEquals(actionBookmark, action.Action__c);
		System.assertEquals(actionOwnerBookmark, record.Action_Owner__c);
		System.assertEquals(actionOwnerBookmark, action.Action_Owner__c);
		System.assertEquals(actionTimescaleBookmark, record.Action_Timescale__c);
		System.assertEquals(actionTimescaleBookmark, action.Action_Timescale__c);
		System.assertEquals(desiredOutcomeBookmark, record.Desired_Outcome__c);
		System.assertEquals(desiredOutcomeBookmark, action.Desired_Outcome__c);
		System.assertEquals(progressMadeBookmark, record.Progress_Made__c);
		System.assertEquals(progressMadeBookmark, action.Progress_Made__c);
	}


	private class ErrorHandlerSpy extends ErrorHandler
	{
		override public void handleException(String level, String message, String messageDetail, Exception ex)
		{
			this.level = level;
			this.message = message;
			this.messageDetail = messageDetail;
			this.ex = ex;
		}

		public String level;
		public String message;
		public String messageDetail;
		public Exception ex;
	}
	

	private static Survey_Question_Response__c createQuestion()
	{
		Survey_Response__c survey = DevelopmentSurveyTestHelper.createSurveyResponse();
		List<Survey_Question_Response__c> records = DevelopmentSurveyTestHelper.questionsForSurvey(survey.Id);
		return records[0];
	}

	private static String LEVEL_ERROR = ErrorHandler.LEVEL_ERROR;
	
}