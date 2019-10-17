/**
 Type Name:RecallBilling_test
Author: Cognizant
Created Date: 24/06/2010
Reason: This is Teast class for RecallBilling 
Change History
 */
@isTest
private class RecallBilling_Test {
    
    
    
    static testMethod void RecallTestWithValidData() {
        
        
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
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
       
        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp',CHI_Lead_Id__c = '456713', StageName ='Awaiting Billing',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
        
        System.debug('------------ 1opportunity.CHI_Lead_Id__c = ' + opportunity.CHI_Lead_Id__c);                                                 
        insert opportunity;
        
        
        
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,Billed__c=true);
        insert quote;
        
        //SFNB7521_Batch__c SFNB7521obj = new SFNB7521_Batch__c(Name ='SFNB001');
        //insert SFNB7521obj;
        
        Installation_Billing__c InstBill = new Installation_Billing__c();
        InstBill.Big_Machine_Quote__c = quote.Id;
        InstBill.CHI_Lead_Number__c = '456713';
        InstBill.Job_Completion_Date__c = system.today();
        InstBill.SFNB7521_Batch__c = null;
        insert InstBill;
        
  
        Opportunity oppTest = [Select Platform__c,Id,Billed_Status__c,CHI_Lead_Id__c, (Select id,Stage__c,Billed__c From BigMachines_Quotes__r where Billed__c = true 
               and Is_Primary__c = true) From Opportunity where id =:opportunity.ID];
        
        System.debug('------------------------- oppTest = ' + oppTest);
        System.debug('------------------------- opportunity = ' + opportunity);
        
        
        BigMachines_Quote__c quotechngstatus = oppTest.BigMachines_Quotes__r;
        
        System.debug('------------------------- quotechngstatus = ' + quotechngstatus);
               
        //Retrive installation billing with quote status "Awainting Billing" and batch field is not populated
        Installation_Billing__c testInstBill = [Select i.CHI_Lead_Number__c, i.Big_Machine_Quote__c, i.SFNB7521_Batch__c, i.Id From Installation_Billing__c i where i.ID =:InstBill.ID];
        
        System.debug('------------------------- testInstBill = ' + testInstBill);
        testInstBill.CHI_Lead_Number__c = oppTest.CHI_Lead_Id__c;
        update testInstBill;
        
        //Installation_Billing__c instbilldelete = [Select i.SFNB7521_Batch__c, i.Id From Installation_Billing__c i where i.Big_Machine_Quote__c=:quotechngstatus.Id 
                      //   and i.CHI_Lead_Number__c =: oppTest.CHI_Lead_Id__c];
                         
        //System.debug('------------------------- instbilldelete = ' + instbilldelete);
        
        RecallBilling.delinstbill(opportunity.ID);  
        
        
    }
    
    static testMethod void RecallTestWithNoData() 
    {
            
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
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
       
        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Awaiting Billing',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
        opportunity.CHI_Lead_Id__c='456713';
        System.debug('------------ 1opportunity.CHI_Lead_Id__c = ' + opportunity.CHI_Lead_Id__c);
        //Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        //Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opportunity;
        
        
        
       // opportunity = [select Name, CHI_Lead_Id__c, StageName,CloseDate, AccountId, LeadSource ,Product_Interest__c, Referral_Employee__c, Override_Billing_checks__c from Opportunity where id =: opportunity.id ];
       // System.debug('------------ 2opportunity.CHI_Lead_Id__c = ' + opportunity.CHI_Lead_Id__c);
        
        
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,Billed__c = true);
        insert quote;
        
        Installation_Billing__c InstBill = new Installation_Billing__c();
        InstBill.Big_Machine_Quote__c = quote.Id;
        InstBill.CHI_Lead_Number__c = opportunity.CHI_Lead_Id__c;
        InstBill.Job_Completion_Date__c = system.today();
        insert InstBill;
        
        
        Opportunity oppTest = [Select Platform__c,Id,Billed_Status__c,CHI_Lead_Id__c, (Select id,Stage__c,Billed__c From BigMachines_Quotes__r where  Billed__c = true  
               and Is_Primary__c = true) From Opportunity where id =:opportunity.ID];
     
        RecallBilling.delinstbill(opportunity.ID);  
    } 
}