public with sharing class bg_Case_Fields_Update{
	
	private static List<Case> checkChangeCriteria(List<Case> newCases, List<Case> oldCases) {
		//return (List<Case>) bg_Helper_Methods.getAllRecordsThatHaveChanged(newCases, oldCases, new String[] {'Opportunity__c'});
		return newCases;
	}
	
	public static void UpdateFields(List<Case> newCases, List<Case> oldCases) {
		UpdateFields(checkChangeCriteria(newCases, oldCases));
	}
	
	public static void UpdateFields(List<Case> cases) {
		/*
		 * Retrieve reference data
		 */
		Set<Id> opportunityIds = new Set<Id>();
		for(object id : bg_Helper_Methods.getIdSet(cases, 'Opportunity__c')) {
			opportunityIds.add((Id) id);
		}
		Map<string, sObject> GenericCHILeadMap = bg_Helper_Methods.getIdObjectMap([Select O.Id, O.Account.Id, O.Account.Primary_Contact__c, O.Account.Sales_Subpatch__r.District__r.Id, O.AccountId,(Select id from Jobs__r where IS_Remedial_Job__c = false and Split_Job__c = false and Is_Downtime_Job__c = false) from Opportunity O Where O.Id in :opportunityIds]);
		Map<string, Opportunity> CHILeadMap = new Map<string, Opportunity>();
		for(String key : GenericCHILeadMap.KeySet()) {
			CHILeadMap.put(key, (Opportunity) GenericCHILeadMap.get(key));
		}
		
		/*
		 * Update field values
		 */
		System.debug('Cameron CHILeadMap [' + CHILeadMap + ']');
		System.debug('Cameron Cases [' + Cases + ']');
		for(Case caseRecord : Cases) {
			if(CHILeadMap.containsKey(caseRecord.Opportunity__c)) {
				System.debug('Cameron AccountId [' + CHILeadMap.get(caseRecord.Opportunity__c).Account.Id + ']');
				System.debug('Cameron ContactId [' + CHILeadMap.get(caseRecord.Opportunity__c).Account.Primary_Contact__c + ']');
				System.debug('Cameron District__c [' + CHILeadMap.get(caseRecord.Opportunity__c).Account.Sales_Subpatch__r.District__r.Id + ']');
				caseRecord.AccountId = CHILeadMap.get(caseRecord.Opportunity__c).Account.Id;
				caseRecord.ContactId = CHILeadMap.get(caseRecord.Opportunity__c).Account.Primary_Contact__c;
				caseRecord.District__c = CHILeadMap.get(caseRecord.Opportunity__c).Account.Sales_Subpatch__r.District__r.Id;
                if(CHILeadMap.get(caseRecord.Opportunity__c).Jobs__r.size()>0)
                {    
                	caseRecord.Job__c = CHILeadMap.get(caseRecord.Opportunity__c).Jobs__r[0].Id;
                }   
			}
		}
	}
}