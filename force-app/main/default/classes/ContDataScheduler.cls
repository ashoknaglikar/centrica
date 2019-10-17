global class ContDataScheduler implements Schedulable{
  global void execute(SchedulableContext sc) {
        ContSuppInActiveBatch con = new ContSuppInActiveBatch();
        database.executebatch(con);

    }

}