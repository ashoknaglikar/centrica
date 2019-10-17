global class  workZoneScheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
     	workzoneKeyBatch workzoneObj = new workzoneKeyBatch();
        ID batchprocessid = Database.executeBatch(workzoneObj,99);
        
     }
    
}