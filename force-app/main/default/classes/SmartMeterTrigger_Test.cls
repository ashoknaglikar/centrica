@isTest
private class SmartMeterTrigger_Test {
    
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Opportunity opportunity;
    static BigMachines_Quote__c quote;
    static Job__c job;
    static void createData()
    {
        //insert Account
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        
        //insert contact
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;
        
        //insert Supplier
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //insert Employee
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
        insert emp;
        
        //insert CHI Lead
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
        insert opportunity;
        
        //insert Quote
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
        //insert Job
        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),Installer__c=Userinfo.getUserId());
       
        job.Status__c='Pending';
        insert job; 
    }
    
    static testmethod void deleteSmartMeter()
    {  
        createData();
        Smart_Meter__c smartMeter = new Smart_Meter__c(Name='test',Quote__c=quote.Id,CHI_Lead__c=opportunity.Id,Job__c=job.Id);
        insert smartMeter;
        system.debug('@@smartMeter' + smartMeter);
        //smartMeter.S_M_Status__c = 'Eligible';
        delete smartMeter;
        system.debug('@@smartMeter after delete' + smartMeter);
    }
    static testMethod void createSmartMeter() 
    {
        createData();
        quote.Smart_Meter_Creator__c = True;
        update quote;
    }
    
    static testmethod void updateSmartMeter()
    {
        createData();
        Smart_Meter__c smartMeter = new Smart_Meter__c(Name='test',Quote__c=quote.Id,CHI_Lead__c=opportunity.Id,Job__c=job.Id);
        insert smartMeter;
        smartMeter.S_M_Status__c = 'Eligible';
        update smartMeter;
    }
    
    static testmethod void updateSMStatus()
    {
        createData();
        Smart_Meter__c smartMeter = new Smart_Meter__c(Name='test',Quote__c=quote.Id,CHI_Lead__c=opportunity.Id,Job__c=job.Id);        
        insert smartMeter;
        opportunity.SMStatus__c = 'Eligible';
        update opportunity;
        
    }    
}