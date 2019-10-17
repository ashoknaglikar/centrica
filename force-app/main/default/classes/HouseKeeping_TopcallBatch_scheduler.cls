/** 
Type	- CLASS : HouseKeeping_TopcallBatch_scheduler
Date	- 21/07/2010 
Author	- COGNIZANT
Purpose - This is the scheduler class for the 'TopcallFaxBatch__c Batch' object
Change History  - 
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label


*/    
global class HouseKeeping_TopcallBatch_scheduler implements Schedulable    
{                  
	    
 		global string query = ''; 
        
        global Boolean StartBatchDelete {get; set;}
        
        public HouseKeeping_TopcallBatch_scheduler()
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
	        	//query = 'Select t.TopcallFaxBatch__c, t.LastModifiedById, t.Id From TopcallFaxHeader__c t  where t.TopcallFaxBatch__c.LastModifiedDate = Last_N_Days:14';
	        	query = 'Select t.TopcallFaxBatch__c, t.LastModifiedById, t.Id From TopcallFaxHeader__c t  where t.TopcallFaxBatch__c.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_TopCall_Fax;
	        	//---------------------------------------------------------------
        		batchName = HouseKeepingJobName.TopcallFaxBatch;
        	}
        	else
        	{
        		//---------------------------------------------------------------
				// Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
	        	//query = 'Select t.LastModifiedById, t.Id From TopcallFaxBatch__c t where t.LastModifiedDate =  Last_N_Days:14';
	        	query = 'Select t.LastModifiedById, t.Id From TopcallFaxBatch__c t where t.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_TopCall_Fax;
	        	//---------------------------------------------------------------
        		batchName = null;
        	}        	 
        	System.debug('----------------------------- batchName = ' + batchName);
	    	Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
	        ID batchprocessid = Database.executeBatch(objBatch);        
	        System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
           
	}