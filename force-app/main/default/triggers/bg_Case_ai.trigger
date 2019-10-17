trigger bg_Case_ai on Case bulk (after insert) {
	bg_Case_ASP_Creation_Helper.createNeededASPRecords(trigger.new);
}