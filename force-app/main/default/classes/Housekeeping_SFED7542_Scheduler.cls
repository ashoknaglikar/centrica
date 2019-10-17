/*
* CLASS - Housekeeping_SFED7542_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SFED7542 Batch' object
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label
*/

global class Housekeeping_SFED7542_Scheduler implements Schedulable{
    
    global string query = '';
    
    global void execute(SchedulableContext sc) 
    {
        //---------------------------------------------------------------
        // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
        //query = 'Select LastModifiedDate, Id From SFED7542_Batch__c where LastModifiedDate =  Last_N_Days:14';
        query = 'Select LastModifiedDate, Id From SFED7542_Batch__c where Status__c =\'Integrated\' and LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFED7542;
        //---------------------------------------------------------------
        Housekeeping_Batch objBatch = new Housekeeping_Batch(query, null);
        ID batchprocessid = Database.executeBatch(objBatch,100);
        System.debug('----------------------------- batchID = ' + batchprocessid);
    }
    
}