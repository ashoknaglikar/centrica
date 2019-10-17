@isTest (SeeAllData=true)
private class BatchPopulateSFPO7524Records_test{
    
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
        update job;
        
        
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        ord.P5_Good_Receipting_Status__c= 'Awaiting Integration';
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        ord.Status__c='Goods Receipted';
        
        
        insert ord;
        
        //orderlist=new List<order__c>();
        //orderlist.add(ord);
        
        //orderlist=new List<order__c>([Select Job__r.Primary_Contact__c, Job__r.quote__r.Pricebook_Id__c,o.Type__c, o.Sync__c,Job__r.Quote__r.App_Assigned_Payroll__c, Supplier__r.Resource_Type__c,o.Supplier__c,o.Supplier_Acceptance_Status__c, o.Status__c, o.Should_be_Dispatched__c,o.SAP_Number__c, o.Quote__c, o.P5_Order_Release_Date__c,o.P5_Good_Receipting_Status__c, o.Order_Value__c,o.Order_Note__c,o.Order_Date__c, o.Name, o.Job__c, o.Job_Delivery_Date__c, o.Id, o.Error_Description__c, o.Approved__c, o.CreatedDate,o.Job__r.region__c, o.Supplier__r.Supplier_Num__c, o.Job__r.Name,o.Supplier__r.Type__c, P5_SAP_Status__c,o.Job__r.Account__c,o.Job__r.Account__r.Primary_Contact__c,Job__r.CHI_Lead__r.CHI_Lead_Id1__c,o.Job__r.Account__r.BillingStreet,o.Job__r.Account__r.BillingCity, o.Job__r.Account__r.BillingCountry, o.Job__r.Account__r.BillingPostalCode, o.Job__r.Account__r.BillingState, o.Job__r.Delivery_Date__c, o.P5_Order_Cancellation_Date__c,o.Amendment_Number__c, o.P5_Order_Amendment_Date__c, o.P5_Number_Of_Line_Items__c, o.Job__r.District__r.Region__r.Code__c, o.P5_Account_Assignment_Category__c,o.Job__r.CHI_Lead__c From order__c o where o.Id=:ord.Id ]);
        
        
        
                
        Order_Line_Item__c OrdLine = new Order_Line_Item__c();
         ordLine.P5_Purchase_Order__c= ord.Id;
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        ordline.P5_Product__c=product.Id;
        OrdLine.P5_Status_c__c='Active';
        OrdLine.Units__c=10;
        OrdLine.Quantity_Returned__c=20;
        insert OrdLine;
        //Olnlist = new List<Order_Line_Item__c>([Select o.Order_complete__c,o.Units__c, Quantity_Returned__c,o.Supplier__c, o.Skill__c, o.P5_Unit_Price_c__c, o.P5_Type__c,o.P5_Sub_Status_c__c, o.P5_Status_c__c, o.P5_Purchase_Order__c, o.P5_Job_Element__c, o.Description__c,P5_Purchase_Order__r.Job__r.CHI_Lead__r.CHI_Lead_Id1__c,P5_Purchase_Order__r.Goods_Receipted_On__c From Order_Line_Item__c o where o.Id=:OrdLine.Id]);
        //Olnlist.add(OrdLine);
       //Olnlist=[Select P5_Purchase_Order__r.Order_complete__c,P5_Purchase_Order__r.Active_Line_Item_Value__c,P5_Purchase_Order__r.Cancelled_Line_Item__c,o.Units__c, Quantity_Returned__c,o.Supplier__c, o.Skill__c, o.P5_Unit_Price_c__c, o.P5_Type__c,o.P5_Sub_Status_c__c, o.P5_Status_c__c, o.P5_Purchase_Order__c, o.P5_Job_Element__c, o.Description__c,P5_Purchase_Order__r.Job__r.CHI_Lead__r.CHI_Lead_Id1__c,P5_Purchase_Order__r.Goods_Receipted_On__c From Order_Line_Item__c o Where P5_Purchase_Order__r.P5_Good_Receipting_Status__c = 'Awaiting Integration' and P5_Purchase_Order__r.Status__c='Goods Receipted' and P5_Purchase_Order__r.Goods_Receipted_On__c != null  and supplier__r.supplier_num__c != '2017' and supplier__r.supplier_num__c != '3163'];
        /*Ordline.P5_Unit_Price_c__c=100;
        Ordline.Supplier__c=supplier.Id;
        Ordline.Quantity_Returned__c=2;
        update Ordline;*/
        SFPO7524BtachObj=new SFPO7524_Batch__c();
        SFPO7524BtachObj.Batch_Status__c='A';
        SFPO7524BtachObj.Processed__c=false;
        SFPO7524BtachObj.Record_Count__c=4;
        insert SFPO7524BtachObj;
        SFPO7524BtachObj.Processed__c=false;
        update SFPO7524BtachObj; 
        
        System.debug('------->>>>ValuesorderID<<<<<------->'+ord.Id);       
        
        
         //creating SFPO7524 order Detail object and inserting
       SFPO7524OrdDetail=new SFPO7524_ORDER_detail__c();
       SFPO7524OrdDetail.P5_Purchase_Order__c=ord.Id;
       SFPO7524OrdDetail.SFPO7524_Batch__c=SFPO7524BtachObj.Id;
       SFPO7524OrdDetail.Error_Description__c = 'testDesciption';
       insert SFPO7524OrdDetail;
        
       
        
        
    }

    static testMethod void testWithoutData() 
    {
        try
        {  
            BatchPopulateSFPO7524Records SFPO =new BatchPopulateSFPO7524Records();
            Database.BatchableContext BC;
            Test.startTest();
            database.executeBatch(SFPO);
            SFPO.finish(BC);
            Test.stopTest();
        }
        catch(System.exception e)
        {
            
        }
    }
    
    
    
    static testMethod void testWithPositiveData() 
    {
        prepareTestData();
        BatchPopulateSFPO7524Records SFPO =new BatchPopulateSFPO7524Records();
        
        Database.BatchableContext BC;
        Test.startTest();
        
        database.executeBatch(SFPO);
                 
        SFPO.finish(BC);
        Test.stopTest();
        
    }
    
    
                          
                          
                          
                                   
                

}