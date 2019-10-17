/*@isTest
private class BatchPopulateSFPO7523Records_test {

    static testMethod void myUnitTest() {
      
        BatchPopulateSFPO7523Records SFPO =new BatchPopulateSFPO7523Records();
        SFPO.createSAPBatch();
        
        //List<String> orderList= new List<String>();
        List<SFPO7523_Order_Header__c> OHlist = [Select P5_Type_Purchase_Order__c, P5_SFPO7523_Batch__c From SFPO7523_Order_Header__c];
       // List<Order__c> orderslist = [select id,Sync__c,P5_SAP_Status__c from order__c];
        List<SFPO7523_Batch__c> batches = [select Processed__c,id from SFPO7523_Batch__c];
        //SFPO.updateOrderRecords('','4');
        
        
       // order__c order = new order__c(Sync__c=true,P5_SAP_Status__c='Integrated');
        //orders.;
        //orders.;
        Database.BatchableContext BC;
        SFPO.start(BC);
        SFPO.execute(BC,OHlist);            
        SFPO.finish(BC);
      }
      }*/
      
@isTest
private class BatchPopulateSFPO7523Records_test 
{
    //creates test data required by test class
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
    static order__c ord;
    static order__c ord1;
    static List<order__c> ordobj;
    static void prepareTestData()
    {
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact; 
        account.Primary_Contact__c=contact.Id;
        update  account;
        //supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        supplier = new supplier__c(Name='Test supplier',Type__c='Product',ANA_Number__c='007',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
        						Pay_Number__c = '134', Emp_type__c ='C', 
                                         Employee_Number__c = '134',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};
                                                  
        insert employees;
        
        emp= [select Name,First_Name__c,Last_Name__c,Supplier__c,Employee_Number__c,Resource_Id__c,Resource_Type__c from  Employee__c where Employee_Number__c ='134' limit 1];
        
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
                                                            Pricebook_Id__c='457',
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Name,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        
        insert quote;
        
        quote = [select Name , Opportunity__c ,discountsTotalOnPricing__c,
					Pricebook_Id__c,POC_Payment_Method__c,App_Assigned_To__c, App_Assigned_Payroll__c,
					Stage__c, bmstatusreason__c,is_primary__c, quote_reconciled__c ,
					finalPriceVisibleToCustomer__c from BigMachines_Quote__c where id =:quote.ID];
        
       // BigMachines_Quote__c qobj=
        system.debug('-------------quote.App_Assigned_Payroll__c---->>>'+quote.App_Assigned_Payroll__c);
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;*/
                
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        Region__c region = new Region__c(Code__c='25',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
        insert region;
            
            
        District__c district = new District__c();
        district.Code__c='4411';
        district.Name='sambroun';
        district.Region__c=region.Id;
        insert district;
                
       
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id,Account__c=account.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
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
        
        
        ord = new order__c();
        ord.Job__c= job.Id;
        
        //ord.Name='ORD-50798';
        ord.Status__c='Active';
        ord.could_not_process__c=false;
        ord.Original_Order_Value__c=4;
        ord.Type__c='Material';
        ord.Sync__c=true;
        ord.Supplier__c=supplier.Id;
        ord.Supplier_Acceptance_Status__c='Accepted';
        ord.SAP_Number__c='216311232';
        //ord.Quote__c=quote.Id;
        //ord.P5_Order_Release_Date__c=system.today();
        
        ord.P5_Good_Receipting_Status__c= 'Awaiting Integration';
        ord.Order_Value__c=5.05;
        ord.Order_Note__c='Test Note';
        ord.Order_Date__c=system.today()+3;
        //ord.Job_Delivery_Date__c=system.today()+8;
        ord.Approved__c=false;
        ord.P5_Order_Cancellation_Date__c=system.today()+10;
        ord.Amendment_Number__c=7;
        ord.P5_Order_Amendment_Date__c=system.today()+11;
        ord.P5_Order_Amendment_Date__c=system.today()+12;
        system.debug('---ord.Supplier__r.supplier_num__c' +ord.Supplier__r);
        //ord.P5_Number_Of_Line_Items__c=1;
        ord.P5_Account_Assignment_Category__c='Y';
        
        insert ord;
        
        
        
        
        ord1 = new order__c();
        ord1.Job__c= job.Id;
        
        //ord.Name='ORD-50798';
        ord1.Status__c='Active';
        ord1.could_not_process__c=false;
        ord1.Original_Order_Value__c=4;
        ord1.Type__c='Material';
        ord1.Sync__c=true;
        ord1.Supplier__c=supplier.Id;
        ord1.Supplier_Acceptance_Status__c='Accepted';
        ord1.SAP_Number__c='216311232';
        //ord.Quote__c=quote.Id;
        //ord.P5_Order_Release_Date__c=system.today();
        
        ord1.P5_Good_Receipting_Status__c= 'Awaiting Integration';
        ord1.Order_Value__c=5.05;
        ord1.Order_Note__c='Test Note';
        ord1.Order_Date__c=system.today()+3;
        //ord.Job_Delivery_Date__c=system.today()+8;
        ord1.Approved__c=false;
        ord1.P5_Order_Cancellation_Date__c=system.today()+10;
        ord1.Amendment_Number__c=7;
        ord1.P5_Order_Amendment_Date__c=system.today()+11;
        ord1.P5_Order_Amendment_Date__c=system.today()+12;
        system.debug('---ord.Supplier__r.supplier_num__c' +ord.Supplier__r);
        //ord.P5_Number_Of_Line_Items__c=1;
        ord1.P5_Account_Assignment_Category__c='Y';
        
        insert ord1;
        
        orderlist=new List<order__c>();
        orderlist.add(ord1);
        
        orderlist.add(ord);
        System.debug('--------------->>>>>>>>orderlist'+orderlist);
        
        BatchPopulateSFPO7523Records SFPO =new BatchPopulateSFPO7523Records();
        //SFPO.createBatchRecords(orderlist);
        
        
        
        //=new List<order__c>([Select Job__r.Primary_Contact__c, Job__r.quote__r.Pricebook_Id__c,o.Type__c, o.Sync__c,Job__r.Quote__r.App_Assigned_Payroll__c, Supplier__r.Resource_Type__c,o.Supplier__c,o.Supplier_Acceptance_Status__c, o.Status__c, o.Should_be_Dispatched__c,o.SAP_Number__c, o.Quote__c, o.P5_Order_Release_Date__c,o.P5_Good_Receipting_Status__c, o.Order_Value__c,o.Order_Note__c,o.Order_Date__c, o.Name, o.Job__c, o.Job_Delivery_Date__c, o.Id, o.Error_Description__c, o.Approved__c, o.CreatedDate,o.Job__r.region__c, o.Supplier__r.Supplier_Num__c, o.Job__r.Name,o.Supplier__r.Type__c, P5_SAP_Status__c,o.Job__r.Account__c,o.Job__r.Account__r.Primary_Contact__c,Job__r.CHI_Lead__r.CHI_Lead_Id1__c,o.Job__r.Account__r.BillingStreet,o.Job__r.Account__r.BillingCity, o.Job__r.Account__r.BillingCountry, o.Job__r.Account__r.BillingPostalCode, o.Job__r.Account__r.BillingState, o.Job__r.Delivery_Date__c, o.P5_Order_Cancellation_Date__c,o.Amendment_Number__c, o.P5_Order_Amendment_Date__c, o.P5_Number_Of_Line_Items__c, o.Job__r.District__r.Region__r.Code__c, o.P5_Account_Assignment_Category__c,o.Job__r.CHI_Lead__c From order__c o where o.Id=:ord.Id ]);
        
        
        
                
        Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        ordLine.P5_Purchase_Order__c= ord.Id;
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        ordline.P5_Product__c=product.Id;
        OrdLine.P5_Status_c__c='Active';
        ordLine.Code__c='1234';
        Ordline.P5_Unit_Price_c__c=100;
        Ordline.Supplier__c=supplier.Id;
        Ordline.Quantity_Returned__c=2;
        insert OrdLine;
        Olnlist = new List<Order_Line_Item__c>();
        
        Order_Line_Item__c OrdLine2 = new Order_Line_Item__c();
        OrdLine2.P5_Purchase_Order__c= ord.Id;
        OrdLine2.Order_Line_Item_Number__c=714;
        OrdLine2.P5_Job_Element__c=JE.Id;
        OrdLine2.P5_Purchase_Order__c=ord.Id;
        OrdLine2.P5_Product__c=product.Id;
        OrdLine2.P5_Status_c__c='Active';
        OrdLine2.P5_Unit_Price_c__c=100;
        OrdLine2.P5_Type__c = 'Work';
        ordLine2.Code__c='4325';
        OrdLine2.Supplier__c=supplier.Id;
        
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.P5_Purchase_Order__c= ord.Id;
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Active';
        ordLine3.Code__c='99';
        OrdLine3.P5_Unit_Price_c__c=0;
        OrdLine3.P5_Type__c = 'Work';
        OrdLine3.Supplier__c=supplier.Id;
        
        
        
        OrdLine3.Rate_Type__c = 'Fixed';
        //insert OrdLine3;
        
        Order_Line_Item__c OrdLine4 = new Order_Line_Item__c();
        OrdLine4.P5_Purchase_Order__c= ord1.Id;
        OrdLine4.Order_Line_Item_Number__c=714;
        OrdLine4.P5_Job_Element__c=JE.Id;
        OrdLine4.P5_Purchase_Order__c=ord.Id;
        OrdLine4.P5_Product__c=product.Id;
        OrdLine4.P5_Status_c__c='Cancelled';
        OrdLine4.P5_Unit_Price_c__c=1;
        ordLine4.Code__c='123456';
        OrdLine4.Units__c=12;
        OrdLine4.P5_Type__c = 'Work';
        OrdLine4.Supplier__c=supplier.Id;
        
        OrdLine4.Original_Units__c=12;
        OrdLine4.Original_Value__c=12;
        OrdLine4.Rate_Type__c = 'Fixed';
        
        
        Order_Line_Item__c OrdLine5 = new Order_Line_Item__c();
        OrdLine5.P5_Purchase_Order__c= ord1.Id;
        OrdLine5.Order_Line_Item_Number__c=714;
        OrdLine5.P5_Job_Element__c=JE.Id;
        OrdLine5.P5_Purchase_Order__c=ord.Id;
        OrdLine5.P5_Product__c=product.Id;
        OrdLine5.P5_Status_c__c='Cancelled';
        OrdLine5.P5_Unit_Price_c__c=1;
        OrdLine5.Units__c=12;
        ordLine5.Code__c='CBLR2345';
        OrdLine5.P5_Type__c = 'Material';
        OrdLine5.Supplier__c=supplier.Id;
        
        OrdLine5.Original_Units__c=12;
        OrdLine5.Original_Value__c=12;
        OrdLine5.Rate_Type__c = 'Fixed';
        
             Order_Line_Item__c OrdLine6 = new Order_Line_Item__c();
        OrdLine6.P5_Purchase_Order__c= ord1.Id;
        OrdLine6.Order_Line_Item_Number__c=714;
        OrdLine6.P5_Job_Element__c=JE.Id;
        OrdLine6.P5_Purchase_Order__c=ord.Id;
        OrdLine6.P5_Product__c=product.Id;
        //OrdLine6.P5_Status_c__c='Cancelled';
        OrdLine6.P5_Unit_Price_c__c=1;
        OrdLine6.Units__c=12;
        //OrdLine6.P5_Type__c = 'Material';
        OrdLine6.Supplier__c=supplier.Id;
        ordLine6.Code__c='BtR234534554433';
        
        OrdLine6.Original_Units__c=12;
        OrdLine6.Original_Value__c=12;
        OrdLine6.Rate_Type__c = 'Fixed';
        
        Olnlist.add(OrdLine2);
        Olnlist.add(OrdLine3);
        Olnlist.add(OrdLine4);
        Olnlist.add(OrdLine5);
        Olnlist.add(OrdLine6);
        insert Olnlist;
        Olnlist.add(OrdLine);
        
         ordobj= [Select Name,Status__c,could_not_process__c,Original_Order_Value__c,
         Job__r.Primary_Contact__c, Job__r.quote__r.Pricebook_Id__c,o.Type__c, 
         o.Sync__c,Job__r.Quote__r.App_Assigned_Payroll__c, Supplier__r.Resource_Type__c,
         o.Supplier__c,o.Supplier_Acceptance_Status__c,  o.SAP_Number__c, o.Quote__c, 
         o.P5_Order_Release_Date__c,o.P5_Good_Receipting_Status__c, o.Order_Value__c,o.Order_Note__c,
         o.Order_Date__c, o.Job__c, o.Job_Delivery_Date__c, o.Id, o.Approved__c, o.CreatedDate,
         o.Job__r.region__c, o.Supplier__r.Supplier_Num__c, o.Job__r.Name,o.Supplier__r.Type__c, 
         P5_SAP_Status__c,o.Job__r.Account__c,o.Job__r.Account__r.Primary_Contact__c,
         Job__r.CHI_Lead__r.CHI_Lead_Id1__c,o.Job__r.Account__r.BillingStreet,o.Job__r.Account__r.BillingCity,
         o.Job__r.Account__r.BillingCountry, o.Job__r.Account__r.BillingPostalCode, 
         o.Job__r.Account__r.BillingState, o.Job__r.Delivery_Date__c, o.P5_Order_Cancellation_Date__c,
         o.Amendment_Number__c, o.P5_Order_Amendment_Date__c, o.P5_Number_Of_Line_Items__c, 
         Job__r.District__r.Region__r.Code__c, o.P5_Account_Assignment_Category__c,o.Job__r.CHI_Lead__c 
         From order__c o where o.P5_SAP_Status__c = 'Awaiting Integration' 
         and supplier__r.supplier_num__c != :System.label.BGS_Snum_1 and o.id = :ord.id
         and supplier__r.supplier_num__c != :System.label.BGS_Snum_2 limit 10];
          
        
        
    }

    static testMethod void testWithoutData() 
    {
        
        BatchPopulateSFPO7523Records SFPO =new BatchPopulateSFPO7523Records();
        //SFPO.createBatchRecords(orderlist);
        prepareTestData();
        Database.BatchableContext BC;
        Test.startTest();
        database.executeBatch(SFPO);
        //SFPO.execute(BC,ordobj);
        SFPO.Finish(BC);            
        Test.stopTest();
        
        system.debug('--------ordobj--------->>>>'+ordobj);
        
        
    }
    
    static testMethod void test_for_MaterialOrders() 
    {
        prepareTestData();
        BatchPopulateSFPO7523Records SFPO =new BatchPopulateSFPO7523Records();
        //SFPO.createBatchRecords(orderlist);
        
        Database.BatchableContext BC;
        Test.startTest();
        //database.executeBatch(SFPO);
        SFPO.createBatchRecords(orderlist);
        SFPO.updateOrderPOStatus(orderlist);
        SFPO.createSAPBatch();
        SFPO.Finish(BC); 
           
        Test.stopTest();
        //SFPO.updateOrderRecords(Orderslist,Null);
    }
    
    static testMethod void test_for_WorkOrders() 
    {
        prepareTestData();
        
        supplier.Type__c='Resource';
        update supplier;
        
        ord.Type__c='Work';
        update ord;
        
        
        
        BatchPopulateSFPO7523Records SFPO =new BatchPopulateSFPO7523Records();
        //SFPO.createBatchRecords(orderlist);
        
        Database.BatchableContext BC;
        Test.startTest();
        //database.executeBatch(SFPO);
        SFPO.createSAPBatch();
        SFPO.Finish(BC); 
           
        Test.stopTest();
        //SFPO.updateOrderRecords(Orderslist,Null);
    } 
}