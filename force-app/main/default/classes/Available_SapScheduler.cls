global class Available_SapScheduler implements Schedulable{

       global void execute(SchedulableContext SC) 
       {
        
           Available_SapNumbers.createSAPNoBatch();
        
       }

}