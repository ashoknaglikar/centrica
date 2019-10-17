@isTest
private class SurveyTakingControllerTest {
	
	@isTest static void test_method_one() {
		// Implement test code
/*
		PageReference pageReference = new PageReference('http://www.britishgas.co.uk');

		Survey_Response__c surveyResponse = null; // TODO create with Test Helper
		Test.setCurrentPageReference(pageReference);
		Test.startTest();
		ApexPages.StandardController surveyResponseController = new ApexPages.StandardController(surveyResponse);	
    	SurveyTakingController controller = new SurveyTakingController(surveyResponseController);
    
    	Test.stopTest();
*/
	}
	
	@isTest static void testInitialisation()
	{

		SurveyResponse survey = new MockSurveyResponse();
		List<SurveyQuestionResponse> questions = new List<SurveyQuestionResponse>();
		questions.add(new MockSurveyQuestionResponse('a question', 1, true, null, null));
		questions.add(new MockSurveyQuestionResponse('a question', 1, false, null, null));
		questions.add(new MockSurveyQuestionResponse('b question', 2, true, 'Sometimes', ''));
		questions.add(new MockSurveyQuestionResponse('b question', 2, false, null, 'a comment'));

		SurveyResponseDao mockDao = new MockDao(survey, questions);

		Test.startTest();

		SurveyTakingController controller = new SurveyTakingController('a4Lg0000000JXXW', survey.getId(), mockDao);

		Test.stopTest();

	}


	@isTest static void testGetters()
	{

		SurveyResponse survey = new MockSurveyResponse();
		List<SurveyQuestionResponse> questions = new List<SurveyQuestionResponse>();
		questions.add(new MockSurveyQuestionResponse('a question', 1, true, null, null));
		questions.add(new MockSurveyQuestionResponse('a question', 1, false, null, null));
		questions.add(new MockSurveyQuestionResponse('b question', 2, true, 'Sometimes', ''));
		questions.add(new MockSurveyQuestionResponse('b question', 2, false, null, 'a comment'));

		SurveyResponseDao mockDao = new MockDao(survey, questions);

		Test.startTest();

		SurveyTakingController controller = new SurveyTakingController('a4Lg0000000JXXW', survey.getId(), mockDao);



		System.assert(null != controller.surveyName);
		System.assert(null != controller.isAllocator);
		System.assert(null != controller.isRecipient);
		System.assert(null != controller.userStatus);
		System.assert(null != controller.userStatus);
		System.assert(null != controller.userName);
		System.assert(null != controller.userPersona);
		System.assert(null != controller.userInProgress);
		System.assert(null != controller.otherStatus);
		System.assert(null != controller.otherName);
		System.assert(null != controller.otherPersona);
		System.assert(null != controller.overallStatus);
		System.assert(null != controller.createdDate);
		System.assert(null != controller.lastModifiedDate);
		System.assert(null != controller.followUpRendered);
		System.assert(null != controller.followUpInputEnabled);
		System.assert(null != controller.surveyActionInlineEditEnabled);
		System.assert(null != controller.progressMadeInlineEditEnabled);
		System.assert(null != controller.saveForLaterVisible);
		System.assert(null != controller.markReadyForReviewVisible);
		System.assert(null != controller.markReviewedVisible);
		System.assert(null != controller.saveProgressVisible);
		System.assert(null != controller.surveyLoaded);
		System.assert(null != controller.recipientAdditionalComments);
		String reviewDate = controller.reviewDate;
		String desiredOutcome = controller.desiredOutcome;
		String developmentAction = controller.developmentAction;
		String actionTimescales = controller.actionTimescales;
		String actioOwner = controller.actionOwner;
		String actionProgress = controller.actionProgress;

		List<SurveyTakingController.DualQuestionItem> questionResponses = controller.questionResponses;
		String questionText = questionResponses[0].questionText;
		String answerText = questionResponses[0].answerText;
		String answerComment = questionResponses[0].answerComment;
		String otherAnswerText = questionResponses[0].otherPersonsAnswerText;
		String otherAnswerComment = questionResponses[0].otherPersonsAnswerComment;
		String order = questionResponses[0].order;
		Boolean needsSaving = questionResponses[0].needsSaving;
		List<SelectOption> answerOptions = questionResponses[0].possibleAnswers;


		Test.stopTest();

	}


	@isTest static void testSetters()
	{

		SurveyResponse survey = new MockSurveyResponse();
		List<SurveyQuestionResponse> questions = new List<SurveyQuestionResponse>();
		questions.add(new MockSurveyQuestionResponse('a question', 1, true, null, null));
		questions.add(new MockSurveyQuestionResponse('a question', 1, false, null, null));
		questions.add(new MockSurveyQuestionResponse('b question', 2, true, 'Sometimes', ''));
		questions.add(new MockSurveyQuestionResponse('b question', 2, false, null, 'a comment'));

		SurveyResponseDao mockDao = new MockDao(survey, questions);

		Test.startTest();

		SurveyTakingController controller = new SurveyTakingController('a4Lg0000000JXXW', survey.getId(), mockDao);

		
		controller.reviewDate = '27/06/2016';
		controller.desiredOutcome = 'done';
		controller.developmentAction = 'some action';
		controller.actionTimescales = 'sooner or later';
		controller.actionOwner = 'Fred';
		controller.actionProgress = 'ongoing';
		controller.recipientAdditionalComments = 'lorem';

		controller.questionResponses[0].answerText = 'Mostly';
		controller.questionResponses[0].answerComment = 'I think this is Ok';

		controller.saveForLater();
		controller.markReadyForReview();
		controller.markReviewed();
		controller.saveProgress();


		Test.stopTest();

		System.assertEquals('2016-06-27', controller.reviewDate);
		System.assertEquals('done', controller.desiredOutcome);
		System.assertEquals('some action', controller.developmentAction);
		System.assertEquals('sooner or later', controller.actionTimescales);
		System.assertEquals('Fred', controller.actionOwner);
		System.assertEquals('ongoing', controller.actionProgress);
		System.assert(controller.isParticipant);


	}


	@isTest static void testActions()
	{

		SurveyResponse survey = new MockSurveyResponse();
		List<SurveyQuestionResponse> questions = new List<SurveyQuestionResponse>();
		questions.add(new MockSurveyQuestionResponse('a question', 1, true, null, null));
		questions.add(new MockSurveyQuestionResponse('a question', 1, false, null, null));
		questions.add(new MockSurveyQuestionResponse('b question', 2, true, 'Sometimes', ''));
		questions.add(new MockSurveyQuestionResponse('b question', 2, false, null, 'a comment'));
		questions.add(new MockSurveyQuestionResponse('b question', 3, true, 'Sometimes', null));
		questions.add(new MockSurveyQuestionResponse('b question', 3, false, null, 'a comment'));

		SurveyResponseDao mockDao = new MockDao(survey, questions);

		Test.startTest();

		SurveyTakingController controller = new SurveyTakingController('a4Lg0000000JXXW', survey.getId(), mockDao);
		controller.saveForLater();
		controller.markReadyForReview();
		controller.markReviewed();
		controller.saveProgress();
		SurveyTakingController rcontroller = new SurveyTakingController('b4Lg0000000JXXW', survey.getId(), mockDao);
		rcontroller.saveForLater();
		rcontroller.markReadyForReview();
		rcontroller.markReviewed();
		rcontroller.saveProgress();


		Test.stopTest();

	}

	public class MockDao implements SurveyResponseDao
	{

		public MockDao(SurveyResponse survey, List<SurveyQuestionResponse> questions)
		{
			this.survey = survey;
			this.questions = questions;
		}

		public MockDao(SurveyResponse survey, List<SurveyQuestionResponse> questions, List<Survey_Action__c> actions)
		{
			this.survey = survey;
			this.questions = questions;
			this.actions = actions;
		}

		public SurveyResponse loadSurvey(Id idToLookup)
		{
			return survey;
		}

		public void updateSurvey(SurveyResponse survey)
		{
			this.survey = survey;
		}

		public List<SurveyQuestionResponse> questionsForSurvey(Id surveyId)
		{
			return questions;
		}

		public void saveQuestions(List<SurveyQuestionResponse> questions)
		{
			this.questions = questions;
		}

		public List<Survey_Action__c> actionsForSurvey(Id surveyId)
		{
			return actions;
		}

		public void saveActions(List<Survey_Action__c> actions)
		{
			this.actions = actions;
		}

		public SurveyResponse spyOnSurvey()
		{
			return survey;
		}

		public List<SurveyQuestionResponse> spyOnQuestions()
		{
			return questions;
		}

		private SurveyResponse survey;
		private List<SurveyQuestionResponse> questions;
		private List<Survey_Action__c> actions;

	}

	public class MockSurveyResponse implements SurveyResponse
	{

		public MockSurveyResponse()
		{
			this.recipientAdditionalComments = 'None made yet';
		}


		public Id getId(){ return 'c4Lg0000000JXXW';}

		public String getName(){ return 'Survey 004'; }
		public String getSurveyName(){ return 'H&S Survey all CHI Devon'; }
		public String getOverallStatus(){ return 'Not Started'; }
		public Id getAllocatorId(){ return 'a4Lg0000000JXXW'; }
		public String getAllocatorName(){ return 'John Smith'; }
		public Id getRecipientId(){ return 'b4Lg0000000JXXW'; }
		public String getRecipientName(){ return 'A N Other'; }
		public Datetime getCreatedDate(){ return Datetime.newInstance(2014, 5, 6); }
		public Datetime getLastModifiedDate(){ return Datetime.newInstance(2014, 5, 6);  }


		public String getAllocatorStatus(){ return this.allocatorStatus; }
		public void setAllocatorStatus(String status){ this.allocatorStatus = status; }
		public String getRecipientStatus(){ return this.recipientStatus; }
		public void setRecipientStatus(String status){ this.recipientStatus = status; }

		public String getRecipientAdditionalComments()
		{
			return this.recipientAdditionalComments;
		}
		public void setRecipientAdditionalComments(String comments)
		{
			this.recipientAdditionalComments = comments;
		}


		public Date getReviewDate(){ return reviewDate; }
		public void setReviewDate(Date reviewDate){ this.reviewDate = reviewDate; }
		public String getDesiredOutcome(){ return desiredOutcome; }
		public void setDesiredOutcome(String outcome){ this.desiredOutcome = outcome; }
		public String getAction(){ return action; }
		public void setAction(String action){ this.action = action; }
		public String getActionOwner(){ return actionOwner; }
		public void setActionOwner(String owner){ this.actionOwner = owner; }
		public String getTimescales(){ return this.timescales; }
		public void setTimescales(String timescales){ this.timescales = timescales; }
		public String getActionProgress(){ return actionProgress; }
		public void setActionProgress(String progress){ this.actionProgress = progress; }


		private String allocatorStatus = 'Not Started';
		private String recipientStatus = 'Not Started';

		private Date reviewDate;
		private String desiredOutcome;
		private String action;
		private String actionOwner;
		private String timescales;
		private String actionProgress;
		private String recipientAdditionalComments;
	}

	public class MockSurveyQuestionResponse
		implements SurveyQuestionResponse
	{
		public MockSurveyQuestionResponse(String questionText, Decimal order, Boolean isForRecipient,String answerText, String answerComment)
		{
			this.questionText = questionText;
			this.order = order;
			this.isForRecipient = isForRecipient;
			this.answerText = answerText;
			this.answerComment = answerComment;
		}


		public Id getId()
		{
			return 'a4Lg0000000JXXW'; 
		}

		public Id getSurveyResponseId()
		{
			return 'a4Lg0000000JXXW'; 
		}

		public String getQuestionText()
		{
			return this.questionText;
		}

		public Decimal getQuestionOrder()
		{
			return this.order;
		}

		public String getAnswerText()
		{
			return this.answerText;
		}

		public void setAnswerText(String answerText)
		{
			this.answerText = answerText;
		}

		public String getAnswerComment()
		{
			return this.answerComment;
		}

		public void setAnswerComment(String answerComment)
		{
			this.answerComment = answerComment;
		}

		public Boolean isForRecipient()
		{
			return isForRecipient;
		}

		public Id getQuestionTemplateId()
		{
			return 'a4Lg0000000JXXW';
		}

		private String questionText;
		private Decimal order;
		private Boolean isForRecipient;
		private String answerText;
		private String answerComment;
		
	}
	
}