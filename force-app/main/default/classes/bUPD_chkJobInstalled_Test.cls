/**
 
 */
@isTest
private class bUPD_chkJobInstalled_Test {

    static testMethod void chkJobInstalled() {
        
    
        
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
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
       

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),isSystem__c=false,                                                
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),isSystem__c=false,
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity opportunity3 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'After 1 Week',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity opportunity4 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'After 2 Week',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity opportunity5 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'After 1 Month',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity opportunity6 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'After 2 Months',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity opportunity7 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'After 3 Months',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true); 
        Opportunity opportunity8 = new Opportunity(Name = 'Test2 Opp', StageName ='Prospect',CloseDate=System.today(),isSystem__c=false,Call_Back_Date__c = 'Over Ride Call Back Date',Override_Call_Back_Date__c = system.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);                                                                                                                                              
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1, opportunity3, opportunity4, opportunity5, opportunity6, opportunity8, opportunity7};                                                 
        insert opp;
        
        opportunity7.Call_Back_Date__c = 'After 1 Week';
        update opportunity7;          
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[1].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;                
                
        //District__c district = [Select id from District__c limit 1];
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        
        Job__c job1 = new Job__c();

        job1 = new Job__c(CHI_Lead__c = opp[1].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job1;
        try{
        opportunity1.Stagename = 'Closed Lost';
        // ashok CR 14 
        opportunity1.Stage_Reason_CHICR__c = 'test value';
        //end Ashok
        system.debug('&&&&'+ [select isSystem__c, isClosed, Stagename from Opportunity where id =: opportunity1.Id]);
        cls_IsRun.isOppoJobRun = false;
        update opportunity1; 
        } catch(system.DmlException de){}
        system.debug('&&&&2222222222'+ [select isSystem__c, isClosed, Stagename from Opportunity where id =: opportunity1.Id]);
        
         
      

        
        
        
       }
}