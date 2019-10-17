/*
* CLASS - Housekeeping_SASF7525Supplier_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SASF7525 Supplier' object

* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label
*/


    global class Housekeeping_SASF7525Supplier_Scheduler implements Schedulable
    {    
    	global string query = '';
        
        global Boolean StartBatchDelete {get; set;}
        
        public Housekeeping_SASF7525Supplier_Scheduler()
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
        		//query = 'Select SASF7525_Batch__r.LastModifiedDate, SASF7525_Batch__c, Id From SASF7525_Supplier__c where SASF7525_Batch__r.LastModifiedDate =  Last_N_Days:14';
        		query = 'Select SASF7525_Batch__r.LastModifiedDate, SASF7525_Batch__c, Id From SASF7525_Supplier__c where SASF7525_Batch__r.LastModifiedDate <  Last_N_Days:' + System.Label.Housekeeping_SASF7525;
        		//---------------------------------------------------------------
        		batchName = HouseKeepingJobName.SASF7525;
        	}
        	else
        	{
        		//---------------------------------------------------------------
        		// Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
        		//query = 'Select LastModifiedDate,Id From SASF7525_Batch__c where LastModifiedDate =  Last_N_Days:14';
        		query = 'Select LastModifiedDate,Id From SASF7525_Batch__c where LastModifiedDate <  Last_N_Days:' + System.Label.Housekeeping_SASF7525;
        		//---------------------------------------------------------------
        		batchName = null;
        	}        	 
	    	Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
	        ID batchprocessid = Database.executeBatch(objBatch,5000);        
	        System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
      
                    
            }