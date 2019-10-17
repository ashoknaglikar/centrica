/*Type Name: NpsController_Test
Author: Cognizant
Created Date: 11/05/2010
Reason: Test class for NpsController.
Change History:*/

@isTest
private class NpsController_Test 
 {
    //Variable declaration section.
    static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
    static NPS__c NpsRec ;
   /* This methods inserts the required record to form an Nps record 
   and then intiates the class NpsController*/
        
    static testMethod void NpsControllerTestMethod()
        
        {
        
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        // Insert mandatory fields in the Contact        
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
         emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        // Insert mandatory fields in the Opportuinty(CHI_lead).        
        
        opportunity = [select id, CHI_Lead_Id__c,Name from Opportunity limit 1 ];
        
        PageReference pageRef = new PageReference('/apex/NpsController?s=' + opportunity.Id);
        Test.setCurrentPage(pageRef);
        
        // retrive opportunity Id and refere the NpsController through that id.
        
        NpsRec = new NPS__c(CHI_Lead_Name__c=opportunity.Name,opportunity__c=opportunity.Id,Step1_Score__c=2,Step1_Comments__c='uilg');
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(NpsRec);
        NpsController controller = new NpsController(StdCtrl);
        controller.npsCHILeadAccountMethod();
        
        //Invoke the method in NpsController class to autopopulate the Account and CHI_lead fields in NPS object

                                       
        }
             
      
  }