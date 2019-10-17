@isTest
private class bg_ASP_Case_Interaction_Tests {
	static testMethod void testASPCreationFromCase() {
		bg_Record_Builder.insertMinimumEmployee('654321');
		
		Id employeeId = [Select Id From employee__c Where Employee_Number__c = '654321'].Id;
		bg_Record_Builder.insertCaseAndQuoteRelatedOpportunity('Engineer', employeeId, 'Commercial', 'Test opportunity', 'new', Date.today());
		
		Id OpportunityId = [Select Id From Opportunity Where StageName = 'new' limit 1].Id;
		bg_Record_Builder.insertMinimumBigMachinesQuote('Test quote', true, OpportunityId);
		bg_Record_Builder.insertCaseForCreatingASP('Approved', 'Test function', 'Test definition', 'Test return info', 'Test reason', 0.0, OpportunityId);
		System.assertNotEquals(0, [Select Id From ASP__c].Size());
		ASP__c asp = [Select Id, Status__c, Function__c, Definition__c, Material_Return_Info__c, Picklist__c, Charge_to_Customer__c, Approved_By__c, Quote__c From ASP__c limit 1];
		System.assertEquals('Entered', asp.Status__c);
		System.assertEquals('Test function', asp.Function__c);
		System.assertEquals('Test definition', asp.Definition__c);
		System.assertEquals('Test return info', asp.Material_Return_Info__c);
		System.assertEquals('Test reason', asp.Picklist__c);
		System.assertEquals(0.0, asp.Charge_to_Customer__c);
		Id QuoteId = [Select Id From BigMachines_Quote__c limit 1].Id;
		System.assertEquals(QuoteId, asp.Quote__c);
	}
	
	static testMethod void testCaseUpdateFromASP() {
		bg_Record_Builder.insertMinimumEmployee('654321');
		
		Employee__c employee2 = [Select Id From employee__c Where Employee_Number__c = '654321'];
		
		bg_Record_Builder.insertCaseForCreatingASP('Approved', 'Test function', 'Test definition', 'Test return info', 'Test reason', 0.0, null);
		
		ASP__c asp = [Select Id, Status__c, Function__c, Definition__c, Material_Return_Info__c, Picklist__c, Charge_to_Customer__c, Approved_By__c From ASP__c limit 1];
		asp.Status__c = 'Submitted';
		asp.Approved_By__c = employee2.Id;
		
		upsert asp;
		
		List<Case> caseRecord = [Select Id, Approved_By__c From Case];
		system.assertEquals(1, caseRecord.size());
	}
}