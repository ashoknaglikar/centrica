global class sendAspExceptionScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
        SendASPAcknowledgments.sendAckListLink();
    }

}