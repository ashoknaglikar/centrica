/*
* CLASS - Housekeeping_Job_Booking_History
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for deleting/housekeeping Job Booking history records 
*/
global class Housekeeping_Job_Booking_History implements Schedulable
{
	global void execute(SchedulableContext sc)
    {        
        string query = 'Select Id From Job_Booking_History__c where Interface_Status__c != \'Awaiting Integration\' and LastModifiedDate =  Last_N_Days:' + System.Label.Housekeeping_Job_Booking_History;
        Housekeeping_Batch objBatch = new Housekeeping_Batch(query, null);        
        ID batchprocessid = Database.executeBatch(objBatch);        
        System.debug('----------------------------- batchID = ' + batchprocessid);    
    }    
}