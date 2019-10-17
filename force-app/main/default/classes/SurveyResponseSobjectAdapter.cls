/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public with sharing class SurveyResponseSobjectAdapter
	implements SurveyResponse, SObjectAdapter
{
	public SurveyResponseSobjectAdapter(Survey_Response__c surveyResponse)
	{
		this.surveyResponse = surveyResponse;
	}

	public Id getId()
	{
		return surveyResponse.Id;
	}

	public String getName()
	{
		return surveyResponse.Name;
	}

	public String getSurveyName()
	{
		return surveyResponse.SurveyName__c;
	}

	public String getOverallStatus()
	{
		return surveyResponse.Overall_Status__c;
	}

	public Id getAllocatorId()
	{
		return surveyResponse.Allocator__c;
	}

	public String getAllocatorName()
	{
		return surveyResponse.Allocator__r.Name;
	}
	public Id getRecipientId()
	{
		return surveyResponse.Recipient__c;
	}

	public String getRecipientName()
	{
		return surveyResponse.Recipient__r.Name;
	}

	public Datetime getCreatedDate()
	{
		return surveyResponse.CreatedDate;
	}

	public Datetime getLastModifiedDate()
	{
		return surveyResponse.LastModifiedDate;
	}


	public String getAllocatorStatus()
	{
		return surveyResponse.Allocator_Status__c;
	}
	public void setAllocatorStatus(String status)
	{
		surveyResponse.Allocator_Status__c = status;
	}


	public String getRecipientStatus()
	{
		return surveyResponse.Recipient_Status__c;
	}
	public void setRecipientStatus(String status)
	{
		surveyResponse.Recipient_Status__c = status;
	}

	public String getRecipientAdditionalComments()
	{
		return surveyResponse.Recipient_Additional_Comments__c;
	}
	public void setRecipientAdditionalComments(String comments)
	{
		surveyResponse.Recipient_Additional_Comments__c = comments;
	}

	public Date getReviewDate()
	{
		return surveyResponse.Review_Date__c;
	}
	public void setReviewDate(Date reviewDate)
	{
		surveyResponse.Review_Date__c = reviewDate;
	}

	public String getDesiredOutcome()
	{
		return surveyResponse.Desired_Outcome__c;
	}
	public void setDesiredOutcome(String outcome)
	{
		surveyResponse.Desired_Outcome__c = outcome;
	}

	public String getAction()
	{
		return surveyResponse.Development_Action__c;
	}
	public void setAction(String action)
	{
		surveyResponse.Development_Action__c = action;
	}

	public String getActionOwner()
	{
		return surveyResponse.Action_owner__c;
	}
	public void setActionOwner(String owner)
	{
		surveyResponse.Action_owner__c = owner;
	}


	public String getTimescales()
	{
		return surveyResponse.Action_timescales__c;
	}
	public void setTimescales(String timescales)
	{
		surveyResponse.Action_timescales__c = timescales;
	}


	public String getActionProgress()
	{
		return surveyResponse.Development_Action_Progress__c;
	}
	public void setActionProgress(String progress)
	{
		surveyResponse.Development_Action_Progress__c = progress;
	}


	public SObject getAdaptedRecord()
	{
		return surveyResponse;
	}

	
	private Survey_Response__c surveyResponse;

}