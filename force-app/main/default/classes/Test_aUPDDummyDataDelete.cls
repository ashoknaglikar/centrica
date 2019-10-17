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
private class Test_aUPDDummyDataDelete {

    static testMethod void myUnitTest() {
    	
    	Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
    	User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                             emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                             localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
    	insert UInstal1;
    	
    	Account acc = new Account(name = 'Dummy Test', BillingStreet='Test', 
                                  BillingPostalCode='SW19 6DZ', BillingCity='Test', 
                                  BillingCountry='Test', BillingState='Test', Dummy_Data__c = true, Dummy_Delete__c = false);
                                  
        insert acc;
        Supplier__c supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'x12345',Type__c = 'Product');
        
    	insert(supplier);
    	
        Employee__c testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
	                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
	                                Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c = supplier.Id);
	    insert(testEmp1);
	                                
        Opportunity opp = new Opportunity(Name = 'Dummy Opp', StageName ='Deposit Taken', Referral_Employee__c = testEmp1.Id,                                                
		                                  AccountId=acc.Id, LeadSource='Engineer',Product_Interest__c ='Solar',
		                                  CloseDate=System.today());
		insert(opp);
				                                  
        District__c district = [Select id from District__c limit 1];
        
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                                
        insert job;
                                
        acc.Dummy_Delete__c = true;      
        update acc;                   
        // TO DO: implement unit test
    }
}