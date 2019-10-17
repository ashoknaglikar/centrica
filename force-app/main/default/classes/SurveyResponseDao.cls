public interface SurveyResponseDao
{

	SurveyResponse loadSurvey(Id idToLookup);

	void updateSurvey(SurveyResponse survey);


	List<SurveyQuestionResponse> questionsForSurvey(Id surveyId);

	void saveQuestions(List<SurveyQuestionResponse> questions);


	List<Survey_Action__c> actionsForSurvey(Id surveyId);

	void saveActions(List<Survey_Action__c> actions);

}