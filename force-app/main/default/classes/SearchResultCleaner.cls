global with sharing class SearchResultCleaner implements Database.Batchable<sObject> {
	
	global final String query;
	
	global SearchResultCleaner() {
		Date d = Date.today().addDays(-1);
		DateTime dt = DateTime.newInstanceGmt(d, Time.newInstance(23,0,0,0));
		query = 'Select ID from Search_Result__c where CreatedDate <= ' + Datetime.now().format();
	}
	
	global SearchResultCleaner(String q) {
		query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<ID> toDelete = new List<ID>();
		for(sObject s : scope) {
			toDelete.add(s.ID);
		}
		Database.delete(toDelete, false);
	}

	global void finish(Database.BatchableContext BC) {
		// No clean up required.
	}
	

}