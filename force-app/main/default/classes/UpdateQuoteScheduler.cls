global class UpdateQuoteScheduler implements Schedulable{
  global void execute(SchedulableContext sc) {
        updateQuoteAvgHours UQ= new updateQuoteAvgHours();
        database.executebatch(UQ);

    }

}