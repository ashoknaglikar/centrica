global class RHCScheduler implements Schedulable{

	   global void execute(SchedulableContext SC) 
	   {
        
      	   RHCFileGenerator.createRHCBatch();
        
       }

}