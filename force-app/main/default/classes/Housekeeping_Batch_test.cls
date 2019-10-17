/*
        Author          : Cognizant
        Functionality   : This is a Test class for the Housekeeping_Batch Class
        Create Date     : 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_Batch_test {
    
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
    static Installation_Billing__c instal_bill;
    static SFNB7521_Batch__c sfnb7521;
    static list<Installation_Billing__c> lstBilling;
    static SAHRSF_Employee__c SaHrsf_emp;
    static  List<SAHRSF_Employee__c> lstSaHrsfemplst;
    static SAHRSF_Batch__c SaHrsf_batch;
    static SASF7525_Supplier__c SasfSupp;
    static SASF7525_Batch__c Sasf_batch;
    static List<SASF7525_Supplier__c> SasfSupplst;
    static SFPO7523_Batch__c Sfpo_batch;
    static SFPO7523_Order_Header__c SfPo_order;
    static List<SFPO7523_Order_Header__c> SfPo_orderlst;
    static SFPO7524_Batch__c SfPo7524_batch;
    static SFPO7524_ORDER_detail__c SfPo7524_order;
    static List<SFPO7524_ORDER_detail__c> SfPo7524_orderlst;
    static TopcallFaxHeader__c Topcalfax_header;
    static List<TopcallFaxHeader__c> Topcalfax_headerlst;
    static TopcallFaxBatch__c Topcallfax_batch;
    static void prepareTestData()
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
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Emp_Type__c='I',
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
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
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
                
       
       
        //job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id,Status__c='Planned', PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        insert JE;
        update job;
        
        
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        insert ord;
        
                
        Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        ordline.P5_Product__c=product.Id;
        OrdLine.P5_Status_c__c='Active';
        insert OrdLine;
       
        Ordline.P5_Unit_Price_c__c=100;
        Ordline.Supplier__c=supplier.Id;
        Ordline.Quantity_Returned__c=2;
        update Ordline;
        
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        
        sfnb7521 = new SFNB7521_Batch__c();
        instal_bill = new Installation_Billing__c(SFNB7521_Batch__c=sfnb7521.Id,Job_Completion_Date__c=system.today() );
        insert instal_bill;
        lstBilling = new list<Installation_Billing__c>();
        lstBilling.add(instal_bill);
        
        SaHrsf_batch = new SAHRSF_Batch__c();
        insert SaHrsf_batch;
        SaHrsf_emp= new SAHRSF_Employee__c(Pay_Number__c='123');
        SaHrsf_emp.SAHRSF_Batch__c=SaHrsf_batch.Id;
        insert SaHrsf_emp;
        lstSaHrsfemplst = new List<SAHRSF_Employee__c>();
        lstSaHrsfemplst.add(SaHrsf_emp);
        
        Sasf_batch = new SASF7525_Batch__c();
        insert Sasf_batch;
        SasfSupp = new SASF7525_Supplier__c();
        insert SasfSupp;
        SasfSupp.SASF7525_Batch__c = Sasf_batch.Id;
        SasfSupplst= new List<SASF7525_Supplier__c>();
        SasfSupplst.add(SasfSupp); 
    
        Sfpo_batch =new SFPO7523_Batch__c();
        insert Sfpo_batch; 
        SfPo_order = new SFPO7523_Order_Header__c();
        SfPo_order.P5_SFPO7523_Batch__c=Sfpo_batch.Id;
        SfPo_order.Emp_Type__c='I';
        insert SfPo_order;
        SfPo_orderlst = new List<SFPO7523_Order_Header__c>();
        SfPo_orderlst.add(SfPo_order);
        
        SfPo7524_batch= new SFPO7524_Batch__c();
        insert SfPo7524_batch;
        SfPo7524_order = new SFPO7524_ORDER_detail__c();
        SfPo7524_order.SFPO7524_Batch__c=SfPo7524_batch.Id;
        insert SfPo7524_order;
        SfPo7524_orderlst = new List<SFPO7524_ORDER_detail__c>();
        SfPo7524_orderlst.add(SfPo7524_order);
        
        Topcallfax_batch =new TopcallFaxBatch__c();
        insert Topcallfax_batch;
        Topcalfax_header =new TopcallFaxHeader__c() ;
        Topcalfax_header.TopcallFaxBatch__c= Topcallfax_batch.Id;
        insert Topcalfax_header;
        Topcalfax_headerlst = new List<TopcallFaxHeader__c>();
        Topcalfax_headerlst.add(Topcalfax_header);
         
    }

    static testMethod void Housekeeping_Batch_for_SAHRSF() 
    {
        prepareTestData();
        list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.SAHRSF;
        Database.BatchableContext BC;
        Test.startTest();
        HK_Batch.execute(BC,lstSaHrsfemplst);
        HK_Batch.finish(BC);
        Test.stopTest();
    }
    
    static testMethod void Housekeeping_Batch_for_SFNB() 
    {
        prepareTestData();
        //list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.SFNB7521;
        Database.BatchableContext BC;
        //HK_Batch.start(BC);
        //HK_Batch.execute(BC,lstBilling);            
        //HK_Batch.finish(BC);
        Test.startTest();
        HK_Batch.execute(BC,lstBilling);
        HK_Batch.finish(BC);
        Test.stopTest();
        
    }
        static testMethod void Housekeeping_Batch_for_SASF7525() 
        {
        prepareTestData();
        //list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.SASF7525;
        Database.BatchableContext BC;
        //HK_Batch.start(BC);
        //HK_Batch.execute(BC,lstBilling);            
        //HK_Batch.finish(BC);
        Test.startTest();
        HK_Batch.execute(BC,SasfSupplst);
        HK_Batch.finish(BC);
        Test.stopTest();
        
        }
        static testMethod void Housekeeping_Batch_for_SAPO7523() 
        {
        prepareTestData();
        //list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.SFPO7523;
        Database.BatchableContext BC;
        //HK_Batch.start(BC);
        //HK_Batch.execute(BC,lstBilling);            
        //HK_Batch.finish(BC);
        Test.startTest();
        HK_Batch.execute(BC,SfPo_orderlst);
        HK_Batch.finish(BC);
        Test.stopTest();
        
        }
        static testMethod void Housekeeping_Batch_for_SAPO7524() 
        {
        prepareTestData();
        //list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.SFPO7524;
        Database.BatchableContext BC;
        //HK_Batch.start(BC);
        //HK_Batch.execute(BC,lstBilling);            
        //HK_Batch.finish(BC);
        Test.startTest();
        HK_Batch.execute(BC,SfPo7524_orderlst);
        HK_Batch.finish(BC);
        Test.stopTest();
        
        }   
       /* static testMethod void Housekeeping_Batch_for_TopcallFaxBatch() 
        {
        prepareTestData();
        //list<ID> toDelete = new list<ID>();
        HouseKeepingJobName jobname;
        
        string s1= '';
        Housekeeping_Batch HK_Batch = new Housekeeping_Batch(s1,jobname);
        HK_Batch.JobName = HouseKeepingJobName.TopcallFaxBatch;
        Database.BatchableContext BC;
        //HK_Batch.start(BC);
        //HK_Batch.execute(BC,lstBilling);            
        //HK_Batch.finish(BC);
        Test.startTest();
        HK_Batch.execute(BC,Topcalfax_headerlst);
        HK_Batch.finish(BC);
        Test.stopTest();        
        }*/
    
}