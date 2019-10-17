/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class aINS_aUPD_Case_SetAccDisp_test {

    static testMethod void DispCaseTestMethod() {
    	// this nmethod is for insert
    	Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
                                                  
        insert emp;
        
        
        
        
       
        
       	RecordType RcdTypId = [Select r.Id From RecordType r where r.Name='Dispute'and sObjectType = 'Case']; 
        
        Case caseObj = new Case();
        caseObj.RecordTypeId=RcdTypId.Id;
        caseObj.AccountId=account.Id;
        caseObj.ContactId=contact.Id;
        caseObj.Subject='Test Case';
        caseObj.Description='Test Desc';
        caseObj.Disputed_Amount__c=100;
        caseObj.Communication_status__c='Awaiting Office';
        caseObj.Case_Source__c='Customer';
        caseObj.Priority='High';
        caseObj.Issued_To__c=emp.Id;
        caseObj.Classification__c='Sales';
        caseObj.Status='New';
        insert caseObj;
        
        caseObj.Conclusion__c='Justified';
        caseObj.Status='Closed';
       // caseObj.Comments='Test comment';
        update caseObj;
    }
    static testMethod void CloseCaseTestMethod() {
    	// this method is for update
    	Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
                                                  
        insert emp;
        
        
       	RecordType RcdTypId = [Select r.Id From RecordType r where r.Name='Dispute'and sObjectType = 'Case']; 
        
        Case caseObj = new Case();
        caseObj.RecordTypeId=RcdTypId.Id;
        caseObj.AccountId=account.Id;
        caseObj.ContactId=contact.Id;
        caseObj.Subject='Test Case';
        caseObj.Description='Test Desc';
        caseObj.Disputed_Amount__c=100;
        caseObj.Communication_status__c='Awaiting Office';
        caseObj.Case_Source__c='Customer';
        caseObj.Priority='High';
        caseObj.Issued_To__c=emp.Id;
        caseObj.Classification__c='Sales';
        caseObj.Status='New';
        insert caseObj;
        
        caseObj.Conclusion__c='Justified';
        caseObj.Status='Closed';
       // caseObj.Comments='Test comment';
        update caseObj;
    }
}