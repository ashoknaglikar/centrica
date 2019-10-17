trigger bg_ASP_ai on ASP__c bulk (after insert) {
	bg_ASP_Case_Update_Helper.updateNeededCaseRecords(trigger.new);

}