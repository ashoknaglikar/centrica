@isTest
private class bg_Helper_Method_Tests {
	static testMethod void TestConvertToQueryString() {
		Set<object> Ids = new Set<object>(new object[] {'0012000000FbiKuAAJ'});
		String actualResult = bg_Helper_Methods.convertToQueryString(Ids);
		String expectedResult = '(\'0012000000FbiKuAAJ\')';
		
		System.assertEquals(expectedResult, actualResult);
	}
	
	static testMethod void TestGetIdSet() {
        insert new Account(Name='Test Account', Number_of_Bedrooms__c=1, Gas_Supply_At_Address__c=true, Current_Heating_System__c=true,
									BillingStreet='Test Street', BillingState='Test State', BillingPostalCode='441111', BillingCountry='Test Country',
									BillingCity='Test City', Water_Hardness__c=0);

		Set<Id> returnedIdSet = bg_Helper_Methods.getIdSet([Select Id From Account]);
		
		System.assertEquals(1, returnedIdSet.size());
	}
	
	static testmethod void TestGetAllRecordsThatHaveChanged() {
		List<SObject> preList = new List<SObject>(new SObject[] {
			new Account(Name='Test Account', Number_of_Bedrooms__c=1, Gas_Supply_At_Address__c=true, Current_Heating_System__c=true,
									BillingStreet='Test Street', BillingState='Test State', BillingPostalCode='441111', BillingCountry='Test Country',
									BillingCity='Test City', Water_Hardness__c=0),
			new Account(Name='Test Account2', Number_of_Bedrooms__c=1, Gas_Supply_At_Address__c=true, Current_Heating_System__c=true,
									BillingStreet='Test Street', BillingState='Test State', BillingPostalCode='441111', BillingCountry='Test Country',
									BillingCity='Test City', Water_Hardness__c=0)
		});
		
		List<SObject> postList = new List<SObject>(new SObject[] {
			new Account(Name='Test Account', Number_of_Bedrooms__c=1, Gas_Supply_At_Address__c=true, Current_Heating_System__c=true,
									BillingStreet='Test Street', BillingState='Test State', BillingPostalCode='441111', BillingCountry='Test Country',
									BillingCity='Test City', Water_Hardness__c=0),
			new Account(Name='Test Account3', Number_of_Bedrooms__c=1, Gas_Supply_At_Address__c=true, Current_Heating_System__c=true,
									BillingStreet='Test Street', BillingState='Test State', BillingPostalCode='441111', BillingCountry='Test Country',
									BillingCity='Test City', Water_Hardness__c=0)
		});
		List<sObject> returnedValues = bg_Helper_Methods.getAllRecordsThatHaveNotChanged(preList, postList, new String[] {'Name'});
		
		System.assertEquals(1, returnedValues.size());
	}
	
	static testmethod void TestDeduplicateList() {
		List<sobject> deDuplicatedList = bg_Helper_Methods.deduplicateList(new List<sobject>(new sobject[] {
							new Account(Name = 'test1'),
							new Account(Name = 'test2'),
							new Account(Name = 'test1')
		}));
		System.assertEquals(2, deDuplicatedList.size());
	}
	
	static testmethod void TestJoinList() {
		String joinedList = bg_Helper_Methods.joinList(new List<String>(new String[] {'1','2','3','4'}), '|');
		String expectedResult = '1|2|3|4';
		System.assertEquals(expectedResult, joinedList);
	}
}