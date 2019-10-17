@isTest
public class CaseNPSCardController_Test{
    
static account a;  
static contact contact1;
static case c;
static caseNPS__c NPS;

    static testMethod void createTestData(){        
        a = TestClassHelper.createAccout();
        insert a;

        contact1 = new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                    MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                    FirstName='First name',Email='test@gmail.com',AccountId=a.Id,Salutation='Mr'); 
        insert contact1;
        c = new case(recordtypeID='012200000009mdm',subject = 'test',description = 'test',accountID=a.id,
                    issued_to_group__c = 'Sales', contactID=contact1.id);
        insert c;
        System.debug('Test Case ID :' +c.ID);
        
        // Test1 - Scenario - Valid case & all questions answered
        PageReference pageRef1 = new PageReference('/apex/CaseNPSCardPage?caseID='+ C.ID);      
        Test.setCurrentPage(pageRef1); 
        CaseNPSCardController controller1 = new CaseNPSCardController();
        Controller1.caseDetails = c;
        controller1.question1 = 1;
        controller1.question2 = 1;
        controller1.question3 = 1;
        controller1.question4 = 1;
        controller1.question5 = true;
        controller1.caseID = c.id;
        ApexPages.currentPage().getParameters().put('question1','1');
        controller1.assignfirst();
        ApexPages.currentPage().getParameters().put('question2','2');
        controller1.assignsec();
        ApexPages.currentPage().getParameters().put('question3','3');
        controller1.assignthird();
        ApexPages.currentPage().getParameters().put('question4','4');
        controller1.assignforth();
        
        List<SelectOption> setOpts1 = controller1.getQuestionItem();
        system.assertnotequals(controller1.showQuestionSection,false);
        system.assertequals(controller1.missingAnswers,false);
        controller1.save();
        
        // Test2 - Scenario - missing answers
        PageReference pageRef2 = new PageReference('/apex/CaseNPSCardPage?caseID='+ C.ID);      
        Test.setCurrentPage(pageRef2);
        CaseNPSCardController controller2 = new CaseNPSCardController();        
        Controller2.caseDetails = c;        
        controller2.question1 = NULL;
        controller2.question2 = NULL;
        controller2.question3 = NULL;
        controller2.question4 = NULL;
        controller2.question5 = false;
        List<SelectOption> setOpts2 = controller1.getQuestionItem();    
        controller2.save();  
        
        // Test 3 - Invalid ID
        PageReference pageRef3 = new PageReference('/apex/CaseNPSCardPage');      
        Test.setCurrentPage(pageRef3);
        CaseNPSCardController controller3 = new CaseNPSCardController();
    }
    
}