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
private class JobInformation_Test {

	static Account account;
	static Contact contact;
	static Opportunity opportunity, opportunity1;
	static Opportunity[] opp;
	static BigMachines_Quote__c quote;
	static Job__c job;
	static Quote_Product__c quoteProduct;
	static List<BigMachines_Quote__c> quoteList;
	//static NIAS_Code__c Nias;
	static testMethod void setTestData()
	{
		account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
                                    
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
        
        insert contact;
          
        Supplier__c supplier = new Supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer', Emp_type__c = 'S');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',Emp_type__c='S',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        //NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];
        /*Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c='12', WRK_TYPE__c='123',
                   INCOME_CODE__c=323, INSTALLER__c='1', OTH_CODE__c=123, PYMT_CODE__c='123', RESOURCE_TYPE__c=emp.Emp_type__c, 
                   WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                   insert Nias;*/
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), Payment_Reference_Number__c = '845088998899',
                                                  AccountId=account.Id,Platform__c='SFDC', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false, Payment_Method__c = 'Cash');
                                                    
        opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), Payment_Reference_Number__c = '853088998899',
                                                AccountId=account.Id, Platform__c = 'SFDC', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true, Payment_Method__c = 'Cash');
        opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
        													POC_Payment_Method__c = 'Finance',App_Assigned_To__c='test - ' + emp.Employee_Number__c, createdDate_quote__c = System.today(),
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                                             priceMatchDifference__c = -45, ISpec_Difference__c = 45, Pricebook_Id__c='CHX');
		                                                             
        insert quote;
        quote.Pricebook_Id__c='CHX';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;
        
        quoteList = new List<BigMachines_Quote__c>();
	    quoteList.add(quote);
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =1.00, GrossSingle__c = 15.5,  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='1');
                                                            
        Quote_Product__c quoteProduct1 = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =4.00, GrossSingle__c = 20.5,
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=200,Quantity__c=10,VAT_Code__c='4');                                                
                                                            
		Quote_Product__c quoteProduct2 = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =1.00, GrossSingle__c = 15.73,
                                                            Part_Number__c='ABC124', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123', Sales_Price__c=200, Quantity__c=10,VAT_Code__c='1');
                                                                                                                        
        insert product;
        insert new List<Quote_Product__c>{quoteProduct, quoteProduct1, quoteProduct2};
        
        
        Region__c region = new Region__c(Code__c='25',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
            insert region;
            
            
            District__c district = new District__c();
            district.Code__c='4411';
            district.Name='sambroun';
            district.Region__c=region.Id;
            insert district;
            system.debug(district.Region__c+'%%%');
            
            Sub_Patch__c SubPatch = new Sub_Patch__c();
            SubPatch.Name='4411';
            SubPatch.Code__c='441111';
            SubPatch.District__c=district.Id;
            SubPatch.Type__c='Installation';
            insert SubPatch;
            system.debug('postdistrict'+SubPatch.District__c);
             
             Postcode_Sector__c PtCodeSect =  new Postcode_Sector__c();
             PtCodeSect.Name='4411';
             PtCodeSect.Code__c='441111';
             PtCodeSect.Sub_Patch__c=SubPatch.Id;
             PtCodeSect.Type__c='Installation';
             insert PtCodeSect;
            system.debug('postsector'+PtCodeSect.Sub_Patch__c);
            
            job = new Job__c(CHI_Lead__c = opportunity.ID, Quote__c=quote.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                            Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
                            Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
                            Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
                            Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                            Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
            
                
         insert job;
         
         JobInformation jobInforObj= new JobInformation(job.Id);
         //jobInforObj.JobInformation();
	}
}