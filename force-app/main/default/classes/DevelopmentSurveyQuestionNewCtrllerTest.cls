@isTest
public class DevelopmentSurveyQuestionNewCtrllerTest
{
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
    	PageReference page = new PageReference('/apex/DevelopmentSurveyQuestionNew');
    	Test.setCurrentPage(page);
    	
    	String nextPage; 
      	System.runAs(authorUser)
        {
        	DevelopmentSurveyQuestionNewController controller = new DevelopmentSurveyQuestionNewController(new ApexPages.StandardController(new Development_Survey_Question__c()));
        	DevelopmentSurveyQuestionNewController alreadyCachedRecordTypeId = new DevelopmentSurveyQuestionNewController(new ApexPages.StandardController(new Development_Survey_Question__c()));
        	controller.question.Question__c = 'TestQuestion';
         	nextPage = controller.save().getUrl();
        }
        Test.stopTest();
        
        List<Development_Survey_Question__c> questions = [SELECT Id, Question__c, Publication_Status__c FROM Development_Survey_Question__c where Question__c = 'TestQuestion'];
        System.assertEquals(1, questions.size(), 'should be 1 question created');
        System.assertEquals('Draft', questions[0].Publication_Status__c, 'Publication Status of Question should be Draft');
        System.assertEquals('/' + questions[0].Id, nextPage);
        
    }
}