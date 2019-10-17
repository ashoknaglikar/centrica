/**
Type Name: aUPD_changeBillingAddress_Test
Author: Cognizant
Change Date: 02/06/2010
Reason: To test class aUPD_changeBillingAddress
Change History:
 */ 
@isTest
private class aUPD_changeBillingAddress_Test {
    static Account account;
    static Contact contact;
    static Employee__c employee ;
    static Opportunity opportunity;
    static order__c order;
    

    static testMethod void changeBillingAddressTestMethod() {
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id); 
           
        
        insert contact;
        
       Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
         opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
                                                                
        insert opportunity;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            App_Assigned_To__c=emp.Id,Stage__c = 'Billed',POC_Payment_Method__c = 'Cash',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        //quote.ASP_after_Billed__c=true;
        quote.Billed__c=false;
        insert quote;
        quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        quote.POC_Payment_Method__c = 'Finance';
        quote.Billed__c=true;
        quote.ASP_after_Billed__c=true;
        update quote;
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id,
                                PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today()+1,Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
        job.Status__c='Pending';                
        insert job;
        Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        Diary_Entry__c DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id);
        insert DEntry;
        Week__c week1 = new Week__c(Employee__c=emp1.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week1;
        Diary_Entry__c DEntry1 = new Diary_Entry__c(Employee__c=emp1.Id,Week__c=week1.Id);
        insert DEntry1;
    
        
        
        order__c ord = new order__c();
        ord.Job__c= job.Id;
        ord.Status__c = 'Active';
        ord.Job__c=job.Id;
        ord.Supplier__c=supplier.Id;
        insert ord;
             //   quote.stage__c = 'Awaiting Billing';
        //upsert quote;

        job.Status__c='Installed';
        update job;
       
        
    }
    static testMethod void WithonlyCashTestMethod() {
        /*
        Region__c r = TestClassHelper.createRegion();
        insert r;
        District__c d = TestClassHelper.createDistrict();
        d.Region__c = r.id;
        insert d;
        
        Sub_patch__c s = TestClassHelper.createSubPatch(d.Id);
        insert s;
        
        Postcode_Sector__c p = new Postcode_sector__c (Name ='SK1 2',Type__c ='Installation', sub_patch__c = s.id );
        insert p;
        */
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='SK1 2LG',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='HITACHI/LOMBARD',MailingState='Test State',
                                     MailingPostalCode='SK1 2LG',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id); 
           
        
        insert contact;
        
       // List<Employee__c> empList = ();
         employee = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                         Employee_Number__c = '0002991');
       
        insert employee;
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp'+ System.now().format('mmddyyhh'),CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer', 
                                      Product_Interest__c = 'Solar', Referral_Employee__c =employee.id,StageName='Quote Accepted');
                                                    
        insert opportunity;
        opportunity.CHI_Lead_Id__c=opportunity.Id;
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.id,POC_Payment_Method__c = 'Finance', 
                                                            is_primary__c=true, quote_reconciled__c = True,stage__c='Awaiting Billing');
        insert quote;
        quote.POC_Payment_Method__c = 'Cash';
        upsert quote;
        
        
    }
    static testMethod void SameQuoteStageTestMethod() {
        /*
        Region__c r = TestClassHelper.createRegion();
        insert r;
        District__c d = TestClassHelper.createDistrict();
        d.Region__c = r.id;
        insert d;
        
        Sub_patch__c s = TestClassHelper.createSubPatch(d.Id);
        insert s;
        
        Postcode_Sector__c p = new Postcode_sector__c (Name ='SK1 2',Type__c ='Installation', sub_patch__c = s.id );
        insert p;
        */
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='HITACHI/LOMBARD',BillingState='Test State',
                                    BillingPostalCode='SK1 2LG',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='SK1 2LG',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id); 
           
        
        insert contact;
        
       // List<Employee__c> empList = ();
         employee = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                         Employee_Number__c = '0002991');
       
        insert employee;
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp'+ System.now().format('mmddyyhh'),CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer', 
                                      Product_Interest__c = 'Solar', Referral_Employee__c =employee.id,StageName='Quote Accepted');
                                                    
        insert opportunity;
        opportunity.CHI_Lead_Id__c=opportunity.Id;
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.id,POC_Payment_Method__c = 'Cash', 
                                                            is_primary__c=true,stage__c='Quote Finalised - Accepted',Billed__c=false);
        insert quote;
        quote.Billed__c=true;
        //quote.stage__c = 'Awaiting Billing';
        upsert quote;
        
        
    }
    
}