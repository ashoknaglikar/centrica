global class MetricScheduler implements Schedulable {
  
   global void execute(SchedulableContext sc) {
      Database.executeBatch(
        new MetricBatch(MetricBatch.WORK_PRODUCT, 
        ' WHERE Iteration__r.Current_Iteration__c = true AND RecordType.DeveloperName = \'Defect\''));
   }
   
}