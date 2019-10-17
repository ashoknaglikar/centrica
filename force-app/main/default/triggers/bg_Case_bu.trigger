trigger bg_Case_bu on Case bulk (before update) {
	bg_Case_Fields_Update.UpdateFields(trigger.new, trigger.old);
}