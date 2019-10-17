public with sharing class SurveyQuestionResponseService
{

	private static String NOT_STARTED = SurveyResponseService.NOT_STARTED;
	private static String ANSWERING = SurveyResponseService.ANSWERING;
	private static String READY_FOR_REVIEW = SurveyResponseService.READY_FOR_REVIEW;
	private static String COMPLETE = SurveyResponseService.COMPLETE;


	public void updateSurveyStatus(Map<Id, Survey_Question_Response__c> oldValues, Map<Id, Survey_Question_Response__c> newValues)
	{
		surveysToUpdate = new List<Survey_Response__c>();

		List<Survey_Question_Response__c> newQuestionResponses = attachRelatedSurveysTo(newValues);

   		
   		for(Survey_Question_Response__c questionResponse : newQuestionResponses)
   		{
   			Survey_Response__c survey = lookupParentOf(questionResponse);

   			String newAnswer = answerValue(questionResponse);
			String oldAnswer = oldAnswerValue(questionResponse, oldValues);

   			if( (oldAnswer != newAnswer) && surveyIsNotComplete(survey) )
   			{
   				updateToAnsweringIfNeeded(survey, questionResponse);
   			}
   		}

   		if(surveysToUpdate.size() > 0)
   		{
   			new SurveyResponseUpdater().updateSurveys(surveysToUpdate);
   		}
	}


	public void updateToRecipientAnswering(Survey_Response__c surveyResponse)
	{
	   surveyResponse.Recipient_Status__c = ANSWERING;
	}


	public void updateToAllocatorAnswering(Survey_Response__c surveyResponse)
	{
	   surveyResponse.Allocator_Status__c = ANSWERING;
	}


	public String answerValue(Survey_Question_Response__c questionResponse)
	{
		return questionResponse.Answer_Text__c;
	}


	public Boolean surveyIsNotComplete(Survey_Response__c surveyResponse)
	{
		return surveyResponse.Overall_Status__c != COMPLETE;
	}


	public Boolean isForReceipient(Survey_Question_Response__c questionResponse)
	{
		return questionResponse.Is_for_Recipient__c;
	}


	public Boolean isForAllocator(Survey_Question_Response__c questionResponse)
	{
	  return !questionResponse.Is_for_Recipient__c;
	}


	private Survey_Response__c lookupParentOf(Survey_Question_Response__c questionResponse)
	{
		return questionResponse.SurveyResponse__r;
	}


	private void updateToAnsweringIfNeeded(Survey_Response__c survey , Survey_Question_Response__c newAnswer)
	{
		if( isForReceipient(newAnswer) && recipientHasNotStartedAnswering(survey) )
		{
			updateToRecipientAnswering(survey);
			surveysToUpdate.add(survey);
			System.debug(LoggingLevel.DEBUG, 'SurveyQuestionRsponseService: Will update surveyResponse: ' + survey.Name + ' to recipient answering status');
		}
		else if( isForAllocator(newAnswer) && allocatorHasNotStartedAnswering(survey))
		{
			updateToAllocatorAnswering(survey);
			surveysToUpdate.add(survey);
			System.debug(LoggingLevel.DEBUG, 'SurveyQuestionRsponseService: Will update surveyResponse: ' + survey.Name + ' to allocator answering status');
		}
	}

	private Boolean recipientHasNotStartedAnswering(Survey_Response__c survey)
	{
		return survey.Recipient_Status__c == NOT_STARTED;
	}


	private Boolean allocatorHasNotStartedAnswering(Survey_Response__c survey)
	{
		return survey.Allocator_Status__c == NOT_STARTED;
	}


	private List<Survey_Question_Response__c> attachRelatedSurveysTo(Map<Id, Survey_Question_Response__c> thinObjects)
	{
		return [select Id, Name, Answer_Text__c, Is_for_Recipient__c, SurveyResponse__r.Id, SurveyResponse__r.Name, SurveyResponse__r.Recipient_Status__c, SurveyResponse__r.Allocator_Status__c, SurveyResponse__r.Overall_Status__c from Survey_Question_Response__c where Id in :thinObjects.keySet()];
	}


	private Survey_Question_Response__c findOldQuestionResponse(Survey_Question_Response__c newQuestionResponse, Map<Id, Survey_Question_Response__c> oldRecords)
	{
		Survey_Question_Response__c result = null;
		Id key = newQuestionResponse.Id;
		if(oldRecords.containsKey(key))
		{
			result = oldRecords.get(key);
		}
		return result;
	}


	private String oldAnswerValue(Survey_Question_Response__c newQuestionResponse, Map<Id, Survey_Question_Response__c> oldRecords)
	{
		String result = '';
		Survey_Question_Response__c oldRecord = findOldQuestionResponse(newQuestionResponse, oldRecords);

		return (oldRecord == null) ? '' : answerValue(oldRecord);
	}


	private List<Survey_Response__c> surveysToUpdate;


	private without sharing class SurveyResponseUpdater
	{
		private void updateSurveys(List<Survey_Response__c> surveys)
		{
			update surveys;
		}
	}

}