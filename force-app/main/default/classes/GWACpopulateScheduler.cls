global class GWACpopulateScheduler implements Schedulable {  
    
    global void execute(SchedulableContext sc) 
    {        
        BatchGWAC_PopulateClass GWACPopu = new BatchGWAC_PopulateClass();
        GWACPopu.createGWACBatch();
    }

}