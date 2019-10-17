/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public interface SurveyResponse
{

	Id getId();

	String getName();
	String getSurveyName();
	String getOverallStatus();
	Id getAllocatorId();
	String getAllocatorName();
	Id getRecipientId();
	String getRecipientName();
	Datetime getCreatedDate();
	Datetime getLastModifiedDate();


	String getAllocatorStatus();
	void setAllocatorStatus(String status);
	String getRecipientStatus();
	void setRecipientStatus(String status);

	String getRecipientAdditionalComments();
	void setRecipientAdditionalComments(String comments);


	Date getReviewDate();
	void setReviewDate(Date setReviewDate);
	String getDesiredOutcome();
	void setDesiredOutcome(String outcome);
	String getAction();
	void setAction(String action);
	String getActionOwner();
	void setActionOwner(String owner);
	String getTimescales();
	void setTimescales(String timescales);
	String getActionProgress();
	void setActionProgress(String progress);

}