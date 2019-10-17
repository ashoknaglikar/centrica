trigger bg_ASP_au on ASP__c bulk (after update) {
	System.debug('Cameron entered bg_ASP_au');
	bg_ASP_Case_Update_Helper.updateNeededCaseRecords(trigger.new, trigger.old);
}