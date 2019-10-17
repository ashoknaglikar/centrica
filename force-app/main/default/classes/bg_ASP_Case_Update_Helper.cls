public with sharing class bg_ASP_Case_Update_Helper{
	private static List<ASP__c> checkChangeCriteria(List<ASP__c> newASP, List<ASP__c> oldASP) {
		return (List<ASP__c>) bg_Helper_Methods.getAllRecordsThatHaveChanged(newASP, oldASP, new String[] {'Status__c'});
	}
	
	public static void updateNeededCaseRecords(List<ASP__c> newASP) {
		/*
		 * Genreate a list of cases that need to have asp records created for them
		 */
		Map<String, object[]> recordMatchingMap = new Map<String, object[]>();
		recordMatchingMap.put('Status__c', new object[] {'Submitted'});
		List<ASP__c> ASPs = bg_Helper_Methods.getAllRecordsThatHaveValues(newASP, recordMatchingMap);
		
		/*
		 * Remove all ASPs without a reference to a case
		 */
		recordMatchingMap = new Map<String, object[]>();
		recordMatchingMap.put('Request_For_ASP__c', new object[] {null});
		ASPs = bg_Helper_Methods.getAllRecordsThatDontHaveValues(ASPs, recordMatchingMap);
		
		/*
		 * Get related ASP__c Ids
		 */
		if(ASPs.size() > 0) {
			Map<string, sObject> genericCaseMap = bg_Helper_Methods.getFieldObjectMap(ASPs, 'Request_For_ASP__c', new String[] {'Id' ,'Approved_By__c'});
			Map<string, Case> CaseMap = new Map<string, Case>();
			for(String key : genericCaseMap.keySet()) {
				CaseMap.put(key, (Case) genericCaseMap.get(key));
			}
			/*
			 * Create asp records for those cases
			 */
			for(ASP__c ASP : ASPs) {
				if(CaseMap.containsKey(ASP.Request_For_ASP__c)) {
					/*
					 * Look in to closing a case
					 */
					CaseMap.get(ASP.Request_For_ASP__c).Status = 'Closed';
				}
			}
			
			upsert CaseMap.values();
		}
	}
	
	public static void updateNeededCaseRecords(List<ASP__c> newASP, List<ASP__c> oldASP) {
		updateNeededCaseRecords(checkChangeCriteria(newASP, oldASP));
	}
}