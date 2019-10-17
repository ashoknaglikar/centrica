/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
@isTest
private class SurveyResponseSobjectAdapterTest
{
	
	@isTest static void testGetters()
	{
		
		Survey_Response__c response = DevelopmentSurveyTestHelper.createSurveyResponse();

        Test.startTest();

        SurveyResponse surveyResponse = new SurveyResponseSobjectAdapter(response);

        Test.stopTest();

        System.assertEquals(response.Id, surveyResponse.getId());
        System.assertEquals(response.Name, surveyResponse.getName());


		System.assertEquals(response.SurveyName__c, surveyResponse.getSurveyName());
		System.assertEquals(response.Overall_Status__c, surveyResponse.getOverallStatus());
		System.assertEquals(response.Allocator_Status__c, surveyResponse.getAllocatorStatus());
		System.assertEquals(response.Allocator__c, surveyResponse.getAllocatorId());
		System.assertEquals(response.Allocator__r.Name, surveyResponse.getAllocatorName());
		System.assertEquals(response.Recipient_Status__c, surveyResponse.getRecipientStatus());
		System.assertEquals(response.Recipient__c, surveyResponse.getRecipientId());
		System.assertEquals(response.Recipient__r.Name, surveyResponse.getRecipientName());
		System.assertEquals(response.Review_Date__c, surveyResponse.getReviewDate());
		System.assertEquals(response.Desired_Outcome__c, surveyResponse.getDesiredOutcome());
		System.assertEquals(response.Development_Action__c, surveyResponse.getAction());
		System.assertEquals(response.Action_timescales__c, surveyResponse.getTimescales());
		System.assertEquals(response.Action_owner__c, surveyResponse.getActionOwner());
		System.assertEquals(response.Development_Action_Progress__c, surveyResponse.getActionProgress());
		System.assertEquals(response.CreatedDate, surveyResponse.getCreatedDate());
		System.assertEquals(response.LastModifiedDate, surveyResponse.getLastModifiedDate());
		System.assertEquals(response.Recipient_Additional_Comments__c, surveyResponse.getRecipientAdditionalComments());

		SObjectAdapter adapter = (SObjectAdapter)surveyResponse;
		SObject record = adapter.getAdaptedRecord();
		System.assert(response === record);

	}


	@isTest static void testSetters()
	{
		
		String allocatorStatusFixture = 'allocatorStatusFixture';
		String recipientStatusFixture = 'recipientStatusFixture';
		Date reviewDateFixture = Date.newInstance(1944, 6, 6);
		String desiredOutcomeFixture = 'desiredOutcomeFixture';
		String actionFixture = 'actionFixture';
		String timescalesFixture = 'timescalesFixture';
		String actionOwnerFixture = 'actionOwnerFixture';
		String actionProgressFixture = 'actionProgressFixture';

		String recipientAdditionalCommentsFixture = 'recipientAdditionalCommentsFixture'; 

		Survey_Response__c response = DevelopmentSurveyTestHelper.createSurveyResponse();

		SurveyResponse surveyResponse = new SurveyResponseSobjectAdapter(response);

        Test.startTest();

        surveyResponse.setAllocatorStatus(allocatorStatusFixture);
        surveyResponse.setRecipientStatus(recipientStatusFixture);
        surveyResponse.setReviewDate(reviewDateFixture);
        surveyResponse.setDesiredOutcome(desiredOutcomeFixture);
        surveyResponse.setAction(actionFixture);
        surveyResponse.setTimescales(timescalesFixture);
        surveyResponse.setActionOwner(actionOwnerFixture);
        surveyResponse.setActionProgress(actionProgressFixture);
        surveyResponse.setRecipientAdditionalComments(recipientAdditionalCommentsFixture);

        Test.stopTest();


		System.assertEquals(response.Allocator_Status__c, surveyResponse.getAllocatorStatus());
		System.assertEquals(response.Recipient_Status__c, surveyResponse.getRecipientStatus());
		System.assertEquals(response.Review_Date__c, surveyResponse.getReviewDate());
		System.assertEquals(response.Desired_Outcome__c, surveyResponse.getDesiredOutcome());
		System.assertEquals(response.Development_Action__c, surveyResponse.getAction());
		System.assertEquals(response.Action_timescales__c, surveyResponse.getTimescales());
		System.assertEquals(response.Action_owner__c, surveyResponse.getActionOwner());
		System.assertEquals(response.Development_Action_Progress__c, surveyResponse.getActionProgress());
		System.assertEquals(response.Recipient_Additional_Comments__c, surveyResponse.getRecipientAdditionalComments());

		System.assertEquals(allocatorStatusFixture,response.Allocator_Status__c);
		System.assertEquals(recipientStatusFixture,response.Recipient_Status__c);
		System.assertEquals(reviewDateFixture,response.Review_Date__c);
		System.assertEquals(desiredOutcomeFixture,response.Desired_Outcome__c);
		System.assertEquals(actionFixture,response.Development_Action__c);
		System.assertEquals(timescalesFixture,response.Action_timescales__c);
		System.assertEquals(actionOwnerFixture,response.Action_owner__c);
		System.assertEquals(actionProgressFixture,response.Development_Action_Progress__c);
		System.assertEquals(recipientAdditionalCommentsFixture, response.Recipient_Additional_Comments__c);

	}
	
}