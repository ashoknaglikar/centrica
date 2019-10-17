global class FinanceAppEnqSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
       
        FinanceApplicationEnqBatch.createEnqBatch();

    }

}