@isTest
public with sharing class DevelopmentSurveyTestHelper
{
	public static User createUserWithProfile(String profileName, String alias)
	{
		Profile profile = [SELECT Id FROM Profile WHERE Name=:profileName LIMIT 1]; 

        User user = new User(Alias = alias
                                , Email='dharfleet@salesforce.com'
                                , EmailEncodingKey='UTF-8'
                                , LastName=alias+'-UnitTest'
                                , FirstName='Test'
                                , LanguageLocaleKey='en_US'
                                , LocaleSidKey='en_US'
                                , ProfileId = profile.Id
                                , TimeZoneSidKey='America/Los_Angeles'
                                , UserName=alias + Math.random() + '@bg.dev');
        
        insert user;

        return user;
	}


	public static void giveUserPermissionSet(User user, String permissionSetName)
	{
		PermissionSet permissionSet = permissionSets.get(permissionSetName);
		if(permissionSet == null)
		{
			permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
		}

        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = user.Id;
        permissionSetAssignment.PermissionSetId = permissionSet.Id;
        
        insert permissionSetAssignment;
	}


	public static Employee__c createEmployee(String firstName, String lastName, String employeeId, User user)
	{
		Employee__c employee = new Employee__c();
		employee.First_Name__c = firstName;
		employee.Last_Name__c = lastName;
		employee.Employee_Number__c = employeeId;
		employee.Salesforce_User__c = user.Id;
		insert employee;
		return employee;
	}


	public static Groups__c createGroup(List<Employee__c> employees)
	{
		Groups__c grupe = new Groups__c();
		grupe.Name = 'unit test group' + Math.random();
		insert grupe;

		List<Employee_Group__c> junctions = new List<Employee_Group__c>();

		for(Employee__c employee : employees)
		{
			Employee_Group__c junction = new Employee_Group__c();
			junction.Employee__c = employee.Id;
			junction.Group__c = grupe.Id;
			junctions.add(junction);
		}
		insert junctions;

		return grupe;
	}


	public static Development_Survey__c createSurvey()
	{
		Development_Survey_Question__c question1 = new Development_Survey_Question__c();
		question1.Publication_Status__c = 'Published';
		question1.Question__c = 'Do you like working for the company';
		insert question1;

		Development_Survey_Question__c question2 = new Development_Survey_Question__c();
		question2.Publication_Status__c = 'Published';
		question2.Question__c = 'Do you like working for the company';
		insert question2;

		Development_Survey__c survey = new Development_Survey__c();
		survey.Publication_Status__c = 'Draft';
		survey.Description__c = 'Survey Description Text';
		insert survey;

		Development_Survey_Question_Assignment__c junction1 = new Development_Survey_Question_Assignment__c();
		junction1.Development_Survey__c = survey.Id;
		junction1.Survey_Question__c = question1.Id;
		junction1.Order__c = 1;
		insert junction1;

		Development_Survey_Question_Assignment__c junction2 = new Development_Survey_Question_Assignment__c();
		junction2.Development_Survey__c = survey.Id;
		junction2.Survey_Question__c = question2.Id;
		junction2.Order__c = 2;
		insert junction2;

		survey.Publication_Status__c = 'Published';
		update survey;

		return survey;
	}

	public static Survey_Response__c createSurveyResponse()
	{
		Development_Survey__c survey = DevelopmentSurveyTestHelper.createSurvey();

        User userA = DevelopmentSurveyTestHelper.createUserWithProfile('Standard User', 'userA');
        Employee__c employeeA = DevelopmentSurveyTestHelper.createEmployee('Andy', 'Another', 'CO5192AB', userA);

        Allocated_Survey__c allocatedSurvey = new Allocated_Survey__c();
        allocatedSurvey.Name = 'test allocated survey';
        allocatedSurvey.Development_Survey__c = survey.Id;
        allocatedSurvey.Employee__c = employeeA.Id;

        insert allocatedSurvey;

        List<Survey_Response__c> surveyResponses = [SELECT
                  Id
                , Name
                , SurveyName__c
                , Overall_Status__c
                , Allocator_Status__c
                , Allocator__c
                , Allocator__r.Name
                , Recipient_Status__c
                , Recipient__c
                , Recipient__r.Name
                , Recipient_Additional_Comments__c
                , Review_Date__c
                , Desired_Outcome__c
                , Development_Action__c
                , Action_timescales__c
                , Action_owner__c
                , Development_Action_Progress__c
                , CreatedDate
                , LastModifiedDate
            FROM 
                Survey_Response__c
            WHERE
                Allocated_Survey__c= :allocatedSurvey.Id
            LIMIT 1];
            return surveyResponses[0];
	}

	public static Survey_Response__c createSurveyResponseWithSurveyActions() {
		Survey_Response__c surveyresponse = DevelopmentSurveyTestHelper.createSurveyResponse();

		Survey_Action__c action1 = new Survey_Action__c();
		action1.Action__c = 'test action 1';
		action1.Action_Owner__c = 'test action owner 1';
		action1.Action_Timescale__c = 'test action timescale 1';
		action1.Desired_Outcome__c = 'test desired outcome 1';
		action1.Progress_Made__c = 'test progress made 1';
		action1.Survey_Response__c = surveyresponse.Id;
		insert action1;

		Survey_Action__c action2 = new Survey_Action__c();
		action2.Action__c = 'test action 2';
		action2.Action_Owner__c = 'test action owner 2';
		action2.Action_Timescale__c = 'test action timescale 2';
		action2.Desired_Outcome__c = 'test desired outcome 2';
		action2.Progress_Made__c = 'test progress made 2';
		action2.Survey_Response__c = surveyresponse.Id;
		insert action2;

        return surveyresponse;
	}

	public static List<Survey_Question_Response__c> questionsForSurvey(Id surveyId)
	{
		return [  SELECT
                      Id
                    , SurveyResponse__c
                    , Question_Text__c
                    , Question_order__c
                    , Answer_Text__c
                    , Answer_Comment__c
                    , Is_for_Recipient__c
                    , Development_Survey_Question__c
                FROM
                    Survey_Question_Response__c
                WHERE
                    SurveyResponse__c = :surveyId
                ];
	}

	public static List<Survey_Action__c> actionsForSurvey(Id surveyId)
	{
		return [  SELECT
	                  Id
	                , Name
	                , Action__c
	                , Action_Owner__c
	                , Action_Timescale__c
	                , Desired_Outcome__c
	                , Progress_Made__c
	                , Survey_Response__c
                FROM
                    Survey_Action__c
                WHERE
                    Survey_Response__c = :surveyId
                ];
	}

	private static Map<String, PermissionSet> permissionSets = new Map<String, PermissionSet>();
}