/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class bUPD_ProcessOrderBefUpd_Test {

    
    	
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
	static List<order__c> orderlist;
	static List<Order_Line_Item__c> Olnlist;
	static Order_Line_Item__c ActivelineItem;
	static Order_Line_Item__c InActivelineItem;
	
	static testMethod void bUPD_ProcessOrderBefUpdTestData()
	{
		
		account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        List<supplier__c> suppliers  = [select name, Type__c, Supplier_Num__c, Resource_Type__c from supplier__c where 
        									Type__c='Resource'and Supplier_Num__c='0001' and Resource_Type__c='S'];
		if(suppliers != null && suppliers.size() > 0)
		{
			supplier = suppliers[0];
		}        					
		else
		{			
        	supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='00011',Resource_Type__c='S');
        	insert supplier;
		}
        	
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
        update job;
        
        //creating order and inserting
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        ord.Supplier__c = supplier.id;
        ord.P5_Good_Receipting_Status__c='Confirmed Processing';
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        insert ord;
        ord.P5_Good_Receipting_Status__c='Confirmed Processing';
        update ord;
        
        
        //creating ActiveLineItems and inserting
        ActivelineItem = new Order_Line_Item__c();
        ActivelineItem.Order_Line_Item_Number__c=714;
        ActivelineItem.P5_Job_Element__c=JE.Id;
        ActivelineItem.P5_Purchase_Order__c=ord.Id;
        ActivelineItem.P5_Product__c=product.Id;
        
        
        ActivelineItem.Quantity_Returned__c=100;
        ActivelineItem.P5_Status_c__c='Active';
        ActivelineItem.Skill__c='Roof Work';
        
        ActivelineItem.Units__c=5;
        ActivelineItem.P5_Unit_Price_c__c=100;
        ActivelineItem.Quantity_Returned__c=2;
        
        ActivelineItem.P5_Type__c='Work';
        ActivelineItem.Description__c='testdescription';
        ActivelineItem.Code__c='123'; 
        //OrdLine.Name; 
        
       
        
        ActivelineItem.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert ActivelineItem;
        
        //creating InActiveLineItems and inserting
        InActivelineItem = new Order_Line_Item__c();
        InActivelineItem.Order_Line_Item_Number__c=714;
        InActivelineItem.P5_Job_Element__c=JE.Id;
        InActivelineItem.P5_Purchase_Order__c=ord.Id;
        InActivelineItem.P5_Product__c=product.Id;
        InActivelineItem.Units__c=10;
        InActivelineItem.Quantity_Returned__c=100;
        InActivelineItem.Skill__c='Roof Work';
        
        InActivelineItem.P5_Status_c__c='Inactive';
        InActivelineItem.Units__c=5;
        InActivelineItem.P5_Unit_Price_c__c=100;
        InActivelineItem.Quantity_Returned__c=2;
        
        InActivelineItem.P5_Type__c='Work';
        InActivelineItem.Description__c='testdescription';
        InActivelineItem.Code__c='123'; 
        //OrdLine.Name; 
        InActivelineItem.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert InActivelineItem;
        
        ActivelineItem.Units__c=100;
        ActivelineItem.P5_Unit_Price_c__c=100;
        ActivelineItem.Quantity_Returned__c=2;
        update ActivelineItem;
        
        InActivelineItem.Units__c=20;
        InActivelineItem.P5_Unit_Price_c__c=100;
        InActivelineItem.Quantity_Returned__c=18;
        update InActivelineItem;
        
        ActivelineItem.P5_Unit_Price_c__c=5000;
        InActivelineItem.P5_Unit_Price_c__c=100;
        
        update ActivelineItem;
        update InActivelineItem;
        
        update ord;
        
        ord.EDI_Status__c = 'Awaiting Integration';
        
        ord.P5_SAP_Status__c = 'Awaiting Integration';
        
        ord.P5_Good_Receipting_Status__c = 'Awaiting Integration';
        update ord;
        
    }
}