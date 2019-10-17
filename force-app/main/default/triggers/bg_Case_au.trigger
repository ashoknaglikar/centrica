trigger bg_Case_au on Case bulk (after update) {
	bg_Case_ASP_Creation_Helper.createNeededASPRecords(trigger.new, trigger.old);
}