@isTest
private class EDIStatusUpdate_test  {
//creates test data required by test class
	static EDSF7541_ACKMNT__c EDS_Ack;
	static EDSF7541_ACKMNT__c EDS_Ack1;
	static EDSF7541_Header__c EDSF7541_header;
	static Order__c orders;
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
	static List<Order__c> orderlist;
	static List<EDSF7541_Header__c> headerlist = new List<EDSF7541_Header__c>();
	static List<EDSF7541_ACKMNT__c> acklist =new List<EDSF7541_ACKMNT__c>();
	static testMethod void prepareTestData(){ 
     
     	
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
       
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = TestClassHelper.createDistrict();
        insert district;
                
       
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        /*Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        insert JE;
        update job;*/
        
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.Status__c='Active';
        ord.Sync__c=false; 
 		ord.EDI_Status__c = 'Integrated'; 
 		ord.SAP_Number__c='121121';
 		ord.Amendment_Number__c = null; 
 		ord.SupplierBranchNum__c='121121';
 		insert ord;
 		
 		//orderlist = new List<order__c>{ord};
 		
 		Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.Order__c=ord.Id;
 		insert JE;
 		//update JE;
 	          
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
        
        EDSF7541_header = new EDSF7541_Header__c();
        EDSF7541_header.Transaction_Code__c=3145;
        EDSF7541_header.Processed__c=false;
        insert EDSF7541_header;
        //headerlist.add(EDSF7541_header);
    
       
        EDS_Ack = new EDSF7541_ACKMNT__c();     
      	EDS_Ack.Customer_Order_No__c ='121121';    
      	EDS_Ack.Amendment_Number__c='121';       		     	
      	EDS_Ack.EDSF7541_Header__c= EDSF7541_header.id;
      	insert EDS_Ack;
      	
      	EDS_Ack1 = new EDSF7541_ACKMNT__c();     
      	EDS_Ack1.Customer_Order_No__c ='1211211';    
      	EDS_Ack1.Amendment_Number__c=null;       		     	
      	EDS_Ack1.EDSF7541_Header__c= EDSF7541_header.id;
      	insert EDS_Ack1;
      	acklist.add(EDS_Ack);
      	acklist.add(EDS_Ack1);
      	
      	
        
        //ord.P5_SAP_Status__c = 'Confirmed Processing';
      
    }
    /*
    static testMethod void testWithoutData() 
     {
       	EDIStatusUpdate EDIS = new EDIStatusUpdate();
       	Test.startTest();
       	EDIS.updateOrders();
       	Database.BatchableContext BC;
	    EDIS.start(BC);
	    EDIS.execute(BC,new List<EDSF7541_ACKMNT__c>());
	    EDIS.finish(BC);
	    Test.stopTest();
      
     } */
     /*static testMethod void testWithRejectedData() 
     {
		prepareTestData();	
		EDIStatusUpdate EDIS = new EDIStatusUpdate();
		Database.BatchableContext BC;
		
		Test.startTest();
        database.executeBatch(EDIS); 
     	EDIS.finish(BC);
     	
     	Test.stopTest();
        
	 }
    static testMethod void testWithRecievedData() 
     {
		prepareTestData();	
		EDIStatusUpdate EDIS = new EDIStatusUpdate();
		Database.BatchableContext BC;
		EDSF7541_header.Transaction_Code__c=3100;
		update EDSF7541_header;
		Test.startTest();
        database.executeBatch(EDIS); 
     	EDIS.finish(BC);
     	
     	Test.stopTest();
        
	 }
	 static testMethod void testWithCancelledData() 
     {
		prepareTestData();	
		EDIStatusUpdate EDIS = new EDIStatusUpdate();
		Database.BatchableContext BC;
		EDSF7541_header.Transaction_Code__c=3170;
		update EDSF7541_header;
		Test.startTest();
        database.executeBatch(EDIS); 
     	EDIS.finish(BC);
     	
     	Test.stopTest();
        
	 }
	 static testMethod void testWithAcceptedData() 
     {
		prepareTestData();	
		EDIStatusUpdate EDIS = new EDIStatusUpdate();
		Database.BatchableContext BC;
		EDSF7541_header.Transaction_Code__c=3120;
		update EDSF7541_header;
		Test.startTest();
        database.executeBatch(EDIS); 
     	EDIS.finish(BC);
     	
     	Test.stopTest();
        
	 }*/
	 static testmethod void testWithDataNew()
	 {
	 	prepareTestData();
	 	EDIStatusUpdate EDIS = new EDIStatusUpdate();
		Database.BatchableContext BC;
		Test.startTest();
		EDIS.updateOrders();
		EDIS.start(BC);
		EDIS.execute(BC, acklist);
        //database.executeBatch(EDIS); 
     	EDIS.finish(BC);
     	Test.stopTest();
     	
	 }
 }