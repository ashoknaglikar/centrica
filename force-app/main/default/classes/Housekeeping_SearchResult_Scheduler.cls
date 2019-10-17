/*
* CLASS - Housekeeping_SearchResult
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SearchResult' object
*/
    global class Housekeeping_SearchResult_Scheduler implements Schedulable
    {    
        global string query = ''; 
        
        global Boolean StartBatchDelete {get; set;}
        
        public Housekeeping_SearchResult_Scheduler()
        {
            StartBatchDelete = false;
        }
          
        global void execute(SchedulableContext sc) 
        {   
            HouseKeepingJobName batchName = null;
            System.debug('----------------------------- StartBatchDelete = ' + StartBatchDelete);
            if(StartBatchDelete == false)
            {
               query = 'Select createdDate,Id From Search_Result__c where LastModifiedDate < Last_N_Days:'+ System.Label.Housekeeping_SearchResult;
               batchName = null;
            }
            Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
            ID batchprocessid = Database.executeBatch(objBatch,5000);        
            System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
             
    }