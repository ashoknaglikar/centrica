global class cleanUnplannedJobsSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
       
        cleanUnplannedJobs.createUnPlannedJobBatch();

    }

}