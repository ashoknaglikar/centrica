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
private class GasSafeReportBGC_number_test {
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Supplier__c supplier1;
    static Employee__c emp;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    
    static testMethod void GasSafeReportBGC_number_method() {
    	
    	Id material = null;
    	account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
       
        insert supplier;
        
        supplier1 = new supplier__c(Name='Test supplier1',ANA_Number__c='122',Type__c='Resource',Supplier_Num__c='B1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
        insert supplier1;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',salesforce_user__c = UInstal1.Id);
        
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
        Job__c job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                        Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());
		insert job;
		
	  	Order__c  ord = new Order__c();
        ord.Job__c= job.Id;
        ord.Status__c='Active';
        ord.Sync__c=true;
        //sord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Material';
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        insert ord;
        Order_Line_Item__c OrdLine2 = new Order_Line_Item__c();
        OrdLine2.Code__c= 'CBLR1073';
        OrdLine2.P5_Purchase_Order__c=ord.Id;
        OrdLine2.P5_Status_c__c='Active';
        OrdLine2.Units__c=10;
        OrdLine2.P5_Type__c='Material';
        OrdLine2.Description__c='testdescription';
        OrdLine2.Line_Item_Value__c = 89.90;
        Ordline2.P5_Unit_Price_c__c=100;
        insert Ordline2; 
        
    	List<String> TempLinenummap = new List<String>();
    	TempLinenummap.add(Ordline2.Code__c);
    	
    	Material = [Select r.Name, r.Id From RecordType r where 
    	r.Name='Material Record Type' and SobjectType = 'Product_Order__c'].Id;
    	
    	//Product_Order__c productOrder=new Product_Order__c(BGC_NUMBER__c='123',RecordTypeId=Material,Product_Number__c='BLR1849845');
    	//insert productOrder;
    	       
        List<Product_Order__c> productOrderLst =new List<Product_Order__c>();
        if(TempLinenummap.size()>0){
        Product_Order__c lstProduct = [Select Name, Product_Number__c, Product_Code__c,BGC_NUMBER__c  From Product_Order__c where Product_code__c IN : TempLinenummap];
        //productOrderLst.add(productOrder);
        productOrderLst.add(lstProduct);
       	update Ordline2;
        }
    	
        
    }
}