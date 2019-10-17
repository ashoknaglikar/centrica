/*
* CLASS - Housekeeping_SAHRSF_Scheduler
* AUTHOR - COGNIZANT
* PURPOSE - This is the scheduler class for the 'SAHRSF Batch' object

Change History  - 
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label

*/

    global class Housekeeping_SAHRSF_Scheduler implements Schedulable
    {    
    	
 		global string query = ''; 
        
        global Boolean StartBatchDelete {get; set;}
        
        public Housekeeping_SAHRSF_Scheduler()
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
	        	//query = 'Select SAHRSF_Batch__r.LastModifiedDate, SAHRSF_Batch__c, Id From SAHRSF_Employee__c  where SAHRSF_Batch__r.LastModifiedDate =  Last_N_Days:14';
	        	query = 'Select SAHRSF_Batch__r.LastModifiedDate, SAHRSF_Batch__c, Id From SAHRSF_Employee__c  where SAHRSF_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SAHRSF;
	        	//---------------------------------------------------------------
        		batchName = HouseKeepingJobName.SAHRSF;
        	}
        	else
        	{
        		//---------------------------------------------------------------
				// Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
	        	//query = 'Select LastModifiedDate, Id From SAHRSF_Batch__c where LastModifiedDate =  Last_N_Days:14';
	        	query = 'Select LastModifiedDate, Id From SAHRSF_Batch__c where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SAHRSF;
	        	//---------------------------------------------------------------
        		batchName = null;
        	}        	 
        	System.debug('----------------------------- batchName = ' + batchName);
	    	Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
	        ID batchprocessid = Database.executeBatch(objBatch,5000);        
	        System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
             
    }