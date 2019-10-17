@isTest
private class SuspendJobController_test {
    static Job_Element__c Job_Element;
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
    static SFPO7523_Batch__c objBatch;
    static SFPO7523_Order_Header__c objHeader;
    static Order__c ord;
    static List<order__c> ordlst;
    
    static void createTestData()
     {
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,Material_Labour_Charges__c=123);
        insert quote;
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;*/
                
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
      
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456;
        ord.Prior_Order_Value__c=213; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        ord.Approved__c=true;
        // ord.Order_Date__c.format();
        insert ord;
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
        Job_Element__c JE = new Job_Element__c(Type__c ='Work',Skill__c='Asbestos Removal');
        JE.Job__c = job.Id;
        insert JE;
        List<Job_Element__c> JEList =new List<Job_Element__c>();
        JEList.add(JE);
    }
    
    static testmethod void testPositiveCase()
    {
        createTestData();
        Pagereference pageRef = Page.Suspend_Job;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('jobId',job.Id);
        
        SuspendJobController sus_job = new SuspendJobController();
        sus_job.suspendJob();
        sus_job.getJobId();
        sus_job.errorMsg = 'Test error msg'; 
        sus_job.setErrorMsg();
        
    }   
    static testmethod void testPositiveCase1()
    {
        createTestData();
        Pagereference pageRef = Page.Suspend_Job;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('jobId',job.Id);
        
        SuspendJobController sus_job = new SuspendJobController();
        system.debug('@@@@failedInstall'+sus_job.failedInstall);
        
        sus_job.failedInstall.Cause__c='Customer Cancelled';
        sus_job.failedInstall.Reason__c='Cost Related';
        sus_job.thisJob.Is_Remedial_Job__c=true;
        sus_job.thisJob.Secondary_Job_Type_New__c='Non Productive'; 
        sus_job.suspendJob();
        sus_job.getJobId();
        sus_job.errorMsg = 'Test error msg'; 
        sus_job.setErrorMsg();
        
    }
    static testmethod void testNegativeCase_Nojobid()
    {   
        createTestData();
        //error scenario 1
        Pagereference pageRef = Page.Suspend_Job;
        Test.setCurrentPage(pageRef);
        try
        {
            ApexPages.currentPage().getParameters().put('jobId','asd');
            
            SuspendJobController sus_job = new SuspendJobController();
            sus_job.suspendJob();
            sus_job.getJobId();
            sus_job.errorMsg = 'Test error msg'; 
            sus_job.setErrorMsg();
        }
        catch(Exception ex)
        {
            System.debug('exception thrown on a negative case: testNegativeCase_Nojobid');
        }
        
    }
    
    
    
    static testmethod void testPTSChange()
    {
        createTestData();
        
        try
        {
            Pagereference pageRef = Page.Suspend_Job;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('jobId',job.id);
            SuspendJobController sus_job = new SuspendJobController();
            job.DeliveryID__c = 'testDelId';
            job.Status__c = 'Suspended';
            //job.Cancel_Merchant_Orders__c = 'No';
            update job;
            sus_job.thisJob.Cancel_Merchant_Orders__c = 'Yes';
            sus_job.redirectToPTS();
            sus_job.isPTSEnabled = true;
            sus_job.suspendJob();
            
        }
        catch(Exception ex)
        {
            System.debug('exception thrown on a negative case: testNegativeCase2');
        }
        
    }
    
    
    static testmethod void testNegativeCase2()
    {   
        createTestData();
        //error scenario 1
        
        try
        {
            Pagereference pageRef = Page.Suspend_Job;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('jobId',job.id);
            
            SuspendJobController sus_job = new SuspendJobController();
            
             system.debug('@@@@failedInstall'+sus_job.failedInstall);
             sus_job.failedInstall.Cause__c='Customer Cancelled';
             sus_job.failedInstall.Reason__c='Cost Related';
            //delete job;
            sus_job.suspendJob();
            sus_job.getJobId();
            sus_job.errorMsg = 'Test error msg'; 
            sus_job.setErrorMsg();
        }
        catch(Exception ex)
        {
            System.debug('exception thrown on a negative case: testNegativeCase2');
        }
    }
    //change to 
    static testmethod void AllConditionscheck()
    {
        createTestData();
        Pagereference pageRef = Page.Suspend_Job;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('jobId',job.Id);
        
        SuspendJobController sus_job = new SuspendJobController();
        sus_job.thisJob.Status__c = 'Completed';
        sus_job.suspendJob();
        
        sus_job.getJobId();
        sus_job.errorMsg = 'Test error msg'; 
        sus_job.setErrorMsg();
    }
    
}