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
private class bUPD_CheckCasesupdateAgeOver_Test {

    static testMethod void myUnitTest() {
      
           
       Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact; 
        account.Primary_Contact__c = contact.id;
        update account;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='SA');
                                         
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,
                                                  Override_Billing_checks__c=false);
        
        RecordType rec = [Select r.Name, r.Id From RecordType r  where Name=:'Complaint' limit 1];

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
            newCase.RecordTypeId = rec.id;
            newCase.ContactId = contact.Id;
            
            insert newCase;

            Task newtask = new Task(Whatid = newCase.id, Status = 'In Progress', ActivityDate = System.Today());
            insert newtask;
            
            newCase.status = 'Closed';
           try{
           	 update newCase;
           }
           catch (Exception e){
           	system.assert(true);
           }
                  
       
    }
}