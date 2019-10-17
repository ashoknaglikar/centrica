/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public interface SurveyQuestionResponse
{

	Id getId();

	Id getSurveyResponseId();

	String getQuestionText();

	Decimal getQuestionOrder();

	String getAnswerText();
	void setAnswerText(String answerText);

	String getAnswerComment();
	void setAnswerComment(String answerComment);


	Boolean isForRecipient();

	Id getQuestionTemplateId();

}