/*
* CLASS - HouseKeeping_SFPO7524_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SFPO7524' Object

Change History  - 
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label
*/

    global class HouseKeeping_SFPO7524_Scheduler implements Schedulable
    {    
 
            
        global string query = ''; 
        
        global Boolean StartBatchDelete {get; set;}
        
        public HouseKeeping_SFPO7524_Scheduler()
        {
            StartBatchDelete = false;
        }
          
        global void execute(SchedulableContext sc) 
        {   
            HouseKeepingJobName batchName = null;
            System.debug('----------------------------- StartBatchDelete = ' + StartBatchDelete);
            if(StartBatchDelete == false)
            {
                //---------------------------------------------------------------
                // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
                //query = 'Select SFPO7524_Batch__r.LastModifiedDate, SFPO7524_Batch__c, Id From SFPO7524_ORDER_detail__c where SFPO7524_Batch__r.LastModifiedDate =  Last_N_Days:14';
                query = 'Select SFPO7524_Batch__r.LastModifiedDate, SFPO7524_Batch__c, Id From SFPO7524_ORDER_detail__c where Status__c =\'Integrated\' and SFPO7524_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7524;
                //---------------------------------------------------------------
                batchName = HouseKeepingJobName.SFPO7524;
            }
            else
            {
                //---------------------------------------------------------------
                // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
                //query = 'Select LastModifiedDate,Id From SFPO7524_Batch__c  where LastModifiedDate =  Last_N_Days:14';
                query = 'Select LastModifiedDate,Id From SFPO7524_Batch__c  where Batch_Status__c=\'S\' and LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7524;
                //---------------------------------------------------------------
                batchName = null;
            }
            System.debug('----------------------------- batchName = ' + batchName);
            Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
            ID batchprocessid = Database.executeBatch(objBatch,1000);        
            System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
                     
                    
       }