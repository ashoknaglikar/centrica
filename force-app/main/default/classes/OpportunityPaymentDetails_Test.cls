@isTest

private class OpportunityPaymentDetails_Test 

{ 
static Employee__c emp;  
static Supplier__c supplier; 
static Opportunity opportunity;
static BigMachines_Quote__c quote;
static Customer_category__c custcat;


static testMethod void OpportunityPaymentDetails_Test() 
{

        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                         BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
      
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
          supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,                                         
                                        Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');         
       
        insert emp;
        
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                                                                   
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);       
        
         insert opportunity;
         
         custcat = new Customer_category__c(name='Test',Opportunity__c=opportunity.id,RecordTypeid='012200000005zsz');
         insert custcat;
         quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,                                                            
                                                   POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',                                                             
                                                   is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,Job_Type__c = '13',closeDate__c = date.today());   
                                                   
        insert quote;
       
        
        System.debug('**************'+opportunity.Customer_categories__r.size());
        }
        
        static testMethod void OpportunityPaymentDetails_Test1() 
{

        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                         BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
      
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
          supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,                                         
                                        Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');         
       
        insert emp;
        
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                                                                   
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);       
        
         insert opportunity;
         
        
         quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,                                                            
                                                   POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id, Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',                                                             
                                                   is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);        
                                                   
        insert quote;
        
        
        System.debug('**************'+opportunity.Customer_categories__r.size());
        }
        static testMethod void OpportunityPaymentDetails_Test2() 
{

        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                         BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
      
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
          supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,                                         
                                        Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');         
       
        insert emp;
        
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                                                                   
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);       
        
         insert opportunity;
         
         custcat = new Customer_category__c(name='Test',Opportunity__c=opportunity.id,RecordTypeid='012200000005zsz');
         insert custcat;
         quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,                                                            
                                                   POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised -Not Accepted', bmstatusreason__c='Quote Finalised - Accepted',                                                             
                                                   is_primary__c=true,quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);        
                                                   
        insert quote;
     
        
        System.debug('**************'+opportunity.Customer_categories__r.size());
        }
        
       static testMethod void OpportunityPaymentDetails_Test3() 
{

        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                         BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
      
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
          supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,                                         
                                        Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');         
       
        insert emp;
        
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                                                                   
                                                AccountId=account.Id,Latest_customer_category__c=1, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);       
        
         insert opportunity;
         
         custcat = new Customer_category__c(name='Test',Opportunity__c=opportunity.id,RecordTypeid='012200000005zsz');
         insert custcat;
         quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,                                                            
                                                   POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised -Accepted', bmstatusreason__c='Quote Finalised - Accepted',                                                             
                                                   is_primary__c=false,Latest_customer_category__c=4,quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);        
                                                   
        insert quote;
     
        
        System.debug('**************'+opportunity.Customer_categories__r.size());
        }
        
        }