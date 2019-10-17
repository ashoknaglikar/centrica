global class DuplicateAttachementScheduler implements Schedulable{

	global void execute(SchedulableContext SC) {
		DuplicateAttachmentCleaner.createDuplicateAttachementCleaner();
	}

}