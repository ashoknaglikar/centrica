/*
* CLASS - Housekeeping_NBBS_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'NBBS Batch' object

Change History  - 
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label
*/

    global class Housekeeping_NBBS_Scheduler implements Schedulable
    {    
        
        global string query = '';
        
        global Boolean StartBatchDelete {get; set;}
        
        public Housekeeping_NBBS_Scheduler()
        {
            StartBatchDelete = false;
        }
          
        global void execute(SchedulableContext sc) 
        {   
            HouseKeepingJobName batchName = null;
            if(StartBatchDelete == false)
            {
                //---------------------------------------------------------------
                // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
                //query = 'Select SFNB7521_Batch__r.LastModifiedDate, SFNB7521_Batch__c, Id From Installation_Billing__c where SFNB7521_Batch__r.LastModifiedDate =  Last_N_Days:14';
                query = 'Select SFNB7521_Batch__r.LastModifiedDate, SFNB7521_Batch__c, Id From Installation_Billing__c where SFNB7521_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFNB7521;
                //---------------------------------------------------------------
                batchName = HouseKeepingJobName.SFNB7521;
            }
            else
            {
                //---------------------------------------------------------------
                // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
                //query = 'Select LastModifiedDate, Id From SFNB7521_Batch__c  where LastModifiedDate =  Last_N_Days:14';
                query = 'Select LastModifiedDate, Id From SFNB7521_Batch__c  where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFNB7521;
                //---------------------------------------------------------------
                batchName = null;
            }            
            Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
            ID batchprocessid = Database.executeBatch(objBatch,1000);        
            System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
        
    }