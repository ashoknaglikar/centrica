global class customerChoiceHubscheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      customerChoiceHubBatchClass b = new customerChoiceHubBatchClass(); 
      database.executebatch(b);
   }
}