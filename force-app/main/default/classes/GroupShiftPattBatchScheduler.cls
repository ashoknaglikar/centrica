global class GroupShiftPattBatchScheduler implements Schedulable {
	/*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to GroupShiftPattBatchScheduler method in the related Batch Apex 
    test Class for this Class is in GroupShiftPatternBatch_Test.
    */
    global void execute(SchedulableContext sc) {
        GroupShiftPatternBatch.createWrkCycleBatch();
    }
}