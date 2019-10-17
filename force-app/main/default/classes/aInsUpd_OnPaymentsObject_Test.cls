@isTest
private class aInsUpd_OnPaymentsObject_Test{

 private static testmethod Payment_Collection__c testDatasetUp(){
     
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
    
    Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
    User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
    insert UInstal1;                                     
    
    Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),isSystem__c=false,                                                
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                                 
    insert opportunity;                 

    Payment_Collection__c p = new Payment_Collection__c();
    p.Name = 'Payment';
    p.Was_Job_completed_to_specification__c = 'Yes';
    p.Were_there_any_changes_to_the_Job__c = 'Yes (see notes)';
    p.Have_you_demod_the_system_controls__c = 'Yes';
    p.Payment_Collection_Status__c ='Pending'; 
    p.Has_NPS_been_explained_to_Customer__c = 'Yes';
    p.Have_you_arranged_a_call_back_time__c = 'Yes';
    p.Reason_for_Discrepancy__c='Dispute';
    p.Opportunity__c = opportunity.Id; 
    p.Payment_Notes__c = 'test notes';
    Insert P;
    
    return p;
   }
   
   private static testmethod void CardTestScenario(){
   
       Payment_Collection__c p = testDatasetUp();
       
       Payments__c payment = new Payments__c(Payment_Collection_Notice__c = P.id,RecordtypeId = RecordTypeIdHelper.getRecordTypeId('Payments__c','Card'), Payment_Date__c = system.today(),Payment_Type__c = 'Balance Payment',Amount_Collected__c = 200,Status__c= 'Card Declined' );
        
       insert payment ; 
   }
   
   private static testmethod void chequeTestScenario(){
   
       Payment_Collection__c p = testDatasetUp();
       
       Payments__c payment = new Payments__c(Payment_Collection_Notice__c = P.id,RecordtypeId = RecordTypeIdHelper.getRecordTypeId('Payments__c','Cheque'), Payment_Date__c = system.today(),Payment_Type__c = 'Balance Payment',Amount_Collected__c = 200,Status__c= 'Card Declined' );
        
       insert payment ; 
   }
   
   
   
  
  




}