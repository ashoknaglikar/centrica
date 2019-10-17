@isTest (SeeAllData=true)
private class BatchUpdateSFPO7524Records_test{  
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
    static List<order__c> orderlist;
    static List<Order_Line_Item__c> Olnlist;
    static SFPO7524_ORDER_detail__c SFPO7524OrdDetail;
    static List<SFPO7524_ORDER_detail__c> listOfORDERdetail;
    static SFPO7524_Batch__c SFPO7524BtachObj;
    
    
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
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Salesforce_user__c =UInstal1.id);
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
        
         opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().adddays(100),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
                        
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       //creating job and inserting
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
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
                
        //creating order and inserting
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        ord.P5_Good_Receipting_Status__c='Confirmed Processing';
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        insert ord;
                
        
        //creating SFPO7524 Btach Object and inserting
        SFPO7524BtachObj=new SFPO7524_Batch__c();
        SFPO7524BtachObj.Batch_Status__c='A';
        SFPO7524BtachObj.Processed__c=true;
        //SFPO7524BtachObj.Salesforce_Processed__c=false;
        insert SFPO7524BtachObj;
                
        System.debug('------->>>>ValuesorderID<<<<<------->'+ord.Id);       
        
        
         //creating SFPO7524 order Detail object and inserting
       SFPO7524OrdDetail=new SFPO7524_ORDER_detail__c();
       SFPO7524OrdDetail.P5_Purchase_Order__c=ord.Id;
       SFPO7524OrdDetail.SFPO7524_Batch__c=SFPO7524BtachObj.Id;
       SFPO7524OrdDetail.Error_Description__c = '';
       SFPO7524OrdDetail.status__c = 'Integrated';

       listOfORDERdetail=new List<SFPO7524_ORDER_detail__c>();
       listOfORDERdetail.add(SFPO7524OrdDetail);   
       insert listOfORDERdetail;
    }
       
    static testMethod void testWithPositiveData() 
    {
        BatchUpdateSFPO7524Records SFPO =new BatchUpdateSFPO7524Records();
        Database.BatchableContext BC;
        prepareTestData();
        Test.startTest();
                
        database.executeBatch(SFPO);
            
        SFPO.finish(BC);
        Test.stopTest();
        
    }  
           
           
}