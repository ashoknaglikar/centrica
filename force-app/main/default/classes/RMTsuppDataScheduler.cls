global class RMTsuppDataScheduler implements Schedulable{
  global void execute(SchedulableContext sc) {
        RMTSuppInActiveBatch  Rmt = new RMTSuppInActiveBatch();
        database.executebatch(Rmt);

    }

}