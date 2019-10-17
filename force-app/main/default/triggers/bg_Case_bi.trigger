trigger bg_Case_bi on Case bulk (before insert) {
	bg_Case_Fields_Update.UpdateFields(trigger.new);
}