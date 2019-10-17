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
private class Test_updatefinanceonopportunity {

    static testMethod void TestUpdatefinance() {
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
		insert camp;
		
		Account acc1 = new Account(name = 'RA UpdateAcc', BillingStreet='8 Roundacre', 
										BillingPostalCode='SW19 6DG', BillingCity='London', 
										BillingCountry='UK', BillingState='London');
		Database.insert(acc1);
		
		Contact contact = new Contact(Primary_Contact__c = true,LastName = 'RAUpdateAccContact', AccountId = acc1.Id, bm_fApplicationStatus__c = 'Approved',bm_fAmountOfCredit__c = 10.00);								
		insert contact;
		
		Contact contact_lanlord_test = new Contact(Primary_Contact__c = false,LastName = 'RAUpdateAccContact Landlord', AccountId = acc1.Id, Contact_Type__c = 'Landlord');								
		insert contact_lanlord_test;
		
		acc1.Primary_Contact__c = contact.Id;
		update acc1;
		
		update contact_lanlord_test;
		
		Opportunity opp = new Opportunity (LeadSource = 'Marcomms', name = 'createNewAppt() opp', AccountId = acc1.Id,
												CloseDate = Date.today().addyears(1), 
												StageName = 'Active', 
												Product_Interest__c='Central Heating Boiler',
												CampaignId = camp.Id,
												Finance_Amount__c = 0.0,
												isSystem__c =true);
		
		insert opp;
		
		contact.bm_fAmountOfCredit__c = 1000.00;
		contact.bm_fApplicationStatus__c = 'Approved';
		update contact;
		
    }
}