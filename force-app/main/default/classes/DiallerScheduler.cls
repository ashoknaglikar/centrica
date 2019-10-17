global class DiallerScheduler implements Schedulable{

   
    global void execute(SchedulableContext SC) {
        
      sendDiallerDetails.createDiallerBatch();
        
     }
}