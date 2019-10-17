@isTest
public class DevelopmentSurveyNewControllerTest{

    public static testMethod void testSave()
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1]; 

        User authorUser = new User(Alias = 'AuthorT'
                                , Email='dharfleet@salesforce.com'
                                , EmailEncodingKey='UTF-8'
                                , LastName='Author T'
                                , FirstName='Test'
                                , LanguageLocaleKey='en_US'
                                , LocaleSidKey='en_US'
                                , ProfileId = profile.Id
                                , TimeZoneSidKey='America/Los_Angeles'
                                , UserName='authorT' + Math.random() + '@bg.dev');
        
        insert authorUser;
                
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'DevelopmentSurveyAuthorsPermissionSet' LIMIT 1];
        
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = authorUser.Id;
        permissionSetAssignment.PermissionSetId = permissionSet.Id;
        
        insert permissionSetAssignment;
       
        
        Test.startTest();
    	PageReference page = new PageReference('/apex/DevelopmentSurveyNew');
    	Test.setCurrentPage(page);
    	
    	String nextPage; 
      	System.runAs(authorUser)
        {
        	DevelopmentSurveyNewController controller = new DevelopmentSurveyNewController(new ApexPages.StandardController(new Development_Survey__c()));
        	DevelopmentSurveyNewController alreadyCachedRecordTypeId = new DevelopmentSurveyNewController(new ApexPages.StandardController(new Development_Survey__c()));
        	controller.survey.Name = 'TestSurvey';
         	nextPage = controller.save().getUrl();
        }
        Test.stopTest();
        
        List<Development_Survey__c> surveys = [SELECT Id, Name, Publication_Status__c FROM Development_Survey__c where Name = 'TestSurvey'];
        System.assertEquals(1, surveys.size(), 'should be 1 survey created');
        System.assertEquals('Draft', surveys[0].Publication_Status__c, 'Publication Status of Survey should be Draft');
        System.assertEquals('/' + surveys[0].Id, nextPage);
        
    }
}