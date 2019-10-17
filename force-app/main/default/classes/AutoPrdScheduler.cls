global class AutoPrdScheduler implements Schedulable{
	  global void execute(SchedulableContext SC) {
     	AutoPrdBatchClass.createAutoPrdBatch();
     }
}