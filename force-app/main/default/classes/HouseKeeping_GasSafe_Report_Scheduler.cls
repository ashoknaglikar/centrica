/*
* CLASS - HouseKeeping_GasSafe_Report_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'Gas Safe Report' object*/

global class HouseKeeping_GasSafe_Report_Scheduler implements Schedulable
{ 
	  global void execute(SchedulableContext sc)
    {        
        String query = 'Select LastModifiedDate, Id From GasSafe_Report__c where LastModifiedDate < Last_N_Days:'+ System.Label.HouseKeeping_GasSafe_Report;
        Housekeeping_Batch objBatch = new Housekeeping_Batch(query, null);        
        ID batchprocessid = Database.executeBatch(objBatch);        
        System.debug('----------------------------- batchID = ' + batchprocessid);    
    }  
}