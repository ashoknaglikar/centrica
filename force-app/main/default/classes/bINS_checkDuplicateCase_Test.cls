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
private class bINS_checkDuplicateCase_Test {

    static testMethod void testDuplicateCases() {
        try
        {
        //DECLARING COLLECTIONS.    
        List<Case> caseList = new List<Case>();
        
        //CREATING ACCOUNT
        Account account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,
                            BillingStreet='Test Street',BillingState='Test State',
                            BillingPostalCode='441111',BillingCountry='Test Country',
                            BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        //CREATING CONTACT RECORD.
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343',
                            MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country',
                            MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        
        //UPDATING ACCOUNT WITH PRIMARY CONTACT.
        account.Primary_Contact__c = contact.Id;
        update account;
        
        //CREATING EMPLOYEE.
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1',
                            Last_Name__c = 'Test1',Employee_Number__c = '0002991');
        insert emp;
        
        //CREATING OPPORTUNITY.
        Opportunity opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',
                           CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer',
                           Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        
        //CREATING NPS.
        NPS__c npsRec = new NPS__c(Account__c=Account.Id,CHI_Lead_Name__c=opportunity.Name,
                            opportunity__c=opportunity.Id,Step1_Score__c=1,Step1_Comments__c='uilg',
                            Contact_Email__c='testuser@gmail.com');
        insert npsRec ;
        
        //FETCHING EXIXTING DETRACTOR CASE RECORD TYPE ID.
        ID DetractorRecordTypeId = [select Id from RecordType where Name = 'Detractor' 
                                    and SobjectType = 'Case'].Id; 
        
        Case newCase=new Case();
            newCase.AccountId = account.Id;
            newCase.Opportunity__c = opportunity.Id;
            newCase.Origin = 'Web';
            newCase.Reason = 'New problem';
            newCase.Type = 'Customer Satisfaction Survey';
            newCase.Status = 'New';
            newCase.Priority = 'Medium';
            newCase.Case_Source__c = 'Customer';
            newCase.Preferred_Contact__c = 'Primary';
            newCase.OwnerId = UserInfo.getUserId();         
            newCase.ContactId = npsRec.Account__r.Primary_Contact__c;
            newCase.NPS_Score__c = npsRec.Step1_Score__c;
            newCase.NPS_Response__c = npsRec.Step1_Comments__c;         
            newCase.NPS__c = npsRec.Id;         
            newCase.RecordTypeId = DetractorRecordTypeId;
            newCase.NPS_Contact_Email__c = npsRec.Contact_Email__c;
            newCase.ContactId = contact.Id;
            
        caseList.add(newCase);
        
        Case newCase1=new Case();
            newCase1.AccountId = account.Id;
            newCase1.Opportunity__c = opportunity.Id;
            newCase1.Origin = 'Web';
            newCase1.Reason = 'New problem';
            newCase1.Type = 'Customer Satisfaction Survey';
            newCase1.Status = 'New';
            newCase1.Priority = 'Medium';
            newCase1.Case_Source__c = 'Customer';
            newCase1.Preferred_Contact__c = 'Primary';
            newCase1.OwnerId = UserInfo.getUserId();            
            newCase1.ContactId = npsRec.Account__r.Primary_Contact__c;
            newCase1.NPS_Score__c = npsRec.Step1_Score__c;
            newCase1.NPS_Response__c = npsRec.Step1_Comments__c;            
            newCase1.NPS__c = npsRec.Id;            
            newCase1.RecordTypeId = DetractorRecordTypeId;
            newCase1.NPS_Contact_Email__c = npsRec.Contact_Email__c; 
            newCase1.ContactId = contact.Id;  
            caseList.add(newCase1);   
         
        insert caseList;    
        }catch(Exception e){
            System.debug('Exception caught:'+e);
        }
               
    }
}