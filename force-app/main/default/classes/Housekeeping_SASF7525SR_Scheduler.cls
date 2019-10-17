/*
* CLASS - Housekeeping_SASF7525SR_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SASF7525 Supplier Region' object

*/


global class Housekeeping_SASF7525SR_Scheduler implements Schedulable
{ 
global string query = '';

global Boolean StartBatchDelete {get; set;}

public Housekeeping_SASF7525SR_Scheduler()
{
    StartBatchDelete = false;
}

global void execute(SchedulableContext sc) 
{ 
    HouseKeepingJobName batchName = null;
    if(StartBatchDelete == false)
    {
        query = 'Select createdDate,Id From SASF7525_Supplier_Region__c where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SASF7525;
    }
    Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
    ID batchprocessid = Database.executeBatch(objBatch,5000); 
    System.debug('----------------------------- batchID = ' + batchprocessid);
    
    List<CronTrigger> lstct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE State='DELETED' and TimesTriggered=1 and NextFireTime=null];
    system.debug(lstct);
    
    for( CronTrigger ct:lstct)
    {
        system.abortJob(ct.Id);
    } 
} 

global void finish(SchedulableContext sc)    
{

}

}