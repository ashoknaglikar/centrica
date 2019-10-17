/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public with sharing class SurveyQuestionResponseSobjectAdapter
	implements SurveyQuestionResponse, SObjectAdapter
{
	public SurveyQuestionResponseSobjectAdapter(Survey_Question_Response__c question)
	{
		this.question = question;
	}


	public Id getId()
	{
		return question.Id;
	}

	public Id getSurveyResponseId()
	{
		return question.SurveyResponse__c;
	}

	public String getQuestionText()
	{
		return question.Question_Text__c;
	}

	public Decimal getQuestionOrder()
	{
		return question.Question_order__c;
	}

	public String getAnswerText()
	{
		return question.Answer_Text__c;
	}

	public void setAnswerText(String answerText)
	{
		question.Answer_Text__c = answerText;
	}

	public String getAnswerComment()
	{
		return question.Answer_Comment__c;
	}

	public void setAnswerComment(String answerComment)
	{
		question.Answer_Comment__c = answerComment;
	}

	public Boolean isForRecipient()
	{
		return this.question.Is_for_Recipient__c;
	}

	public Id getQuestionTemplateId()
	{
		return question.Development_Survey_Question__c;
	}

	public SObject getAdaptedRecord()
	{
		return question;
	}


	private Survey_Question_Response__c question;
}