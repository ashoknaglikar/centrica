@isTest
private class bg_Case_Field_Update_Tests {
	static testMethod void TestFieldPopulation() {
		/*
		 * Set up reference data
		 */
		District__c district = new District__c();
		district.Name = 'Test Name';//This field is bought through to the case
		district.Code__c = '123456';
		List<Id> districtId = new List<Id>(bg_Helper_Methods.insertRecords(new District__c[] {district}));
		
		Sub_Patch__c SalesSubPath = new Sub_Patch__c();
		SalesSubPath.Name = 'Test Sub Patch';
		SalesSubPath.District__c = districtId.get(0);
		SalesSubPath.Code__c = '12345';
		List<Id> salesPatchId = new List<Id>(bg_Helper_Methods.insertRecords(new Sub_Patch__c[] {SalesSubPath}));
		
		Contact contact = new Contact();
		contact.LastName = 'Test Last Name';
		List<Id> contactId = new List<Id>(bg_Helper_Methods.insertRecords(new Contact[] {contact}));
		
		Account account = new Account();
		account.Name='Test Account';
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
		account.Primary_Contact__c = contactId.get(0);
		account.Sales_Subpatch__c = salesPatchId.get(0);
		List<Id> accountId = new List<Id>(bg_Helper_Methods.insertRecords(new Account[] {account}));
		
		/*
		 * Relate the contact to the account
		 */
		contact = [Select Id, AccountId From contact where Id = :contactId.get(0)];
		contact.AccountId = accountId.get(0);
		upsert contact;
		
		Opportunity CHILead = new Opportunity();
		CHILead.AccountId = accountId.get(0);
		CHILead.Name = 'Test CHI Lead';
		CHILead.LeadSource = 'Test';
		CHILead.Product_Interest__c = 'Test product';
		CHILead.StageName = 'new';
		Date closeDate = Date.today();
		closeDate.addDays(10);
		CHILead.CloseDate = closeDate;
		List<Id> chiLeadId = new List<Id>(bg_Helper_Methods.insertRecords(new Opportunity[] {CHILead}));
		
		Case caseRecord = new Case();
		caseRecord.Opportunity__c = chiLeadId.get(0);
		List<Id> CaseId = new List<Id>(bg_Helper_Methods.insertRecords(new Case[] {caseRecord}));
		
		/*
		 * Retrieve the inserted case
		 */
		caseRecord = [Select C.Id, C.Status, C.District__c, C.AccountId, C.ContactId from Case C Where C.Id = :CaseId.get(0)];
		
		/*
		 * Assert that tne District, Account and Contact have been populated correctly
		 */
		System.assertEquals(districtId.get(0), caseRecord.District__c);
		System.assertEquals(accountId.get(0), caseRecord.AccountId);
		System.assertEquals(contactId.get(0), caseRecord.ContactId);
	}
}