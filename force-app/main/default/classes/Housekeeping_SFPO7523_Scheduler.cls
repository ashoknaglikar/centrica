/** 
Type    - CLASS : Housekeeping_SFPO7523_Scheduler
Date    - 21/07/2010 
Author  - COGNIZANT
Purpose - This is the scheduler class for the 'SFPO7523 Batch' object
Change History  - 
* Modified date:- August 6, 2010
* Modification description:- Removed the hardcoding of number of days and taking the value from Custom Label
*/      
global class Housekeeping_SFPO7523_Scheduler implements Schedulable    
{  
    global string query = '';
        
        global Boolean StartBatchDelete {get; set;}
        
        public Housekeeping_SFPO7523_Scheduler()
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
                //query = 'Select P5_SFPO7523_Batch__r.LastModifiedDate, P5_SFPO7523_Batch__c, Id From SFPO7523_Order_Header__c where P5_SFPO7523_Batch__r.LastModifiedDate = Last_N_Days:14';
                query = 'Select P5_SFPO7523_Batch__r.LastModifiedDate, P5_SFPO7523_Batch__c, Id From SFPO7523_Order_Header__c where Status__c =\'Integrated\' and P5_SFPO7523_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7523;
                //---------------------------------------------------------------
                batchName = HouseKeepingJobName.SFPO7523;
            }
            else
            {
                //---------------------------------------------------------------
                // Modification:- Removed the hardcoding of number of days and taking the value from Custom Label
                //query = 'Select s.LastModifiedDate, s.Id From SFPO7523_Batch__c s where s.LastModifiedDate =  Last_N_Days:14';
                query = 'Select s.LastModifiedDate, s.Id From SFPO7523_Batch__c s where  s.P5_Batch_Status__c=\'S\' and s.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7523;
                //---------------------------------------------------------------
                batchName = null;
            }            
            System.debug('----------------------------- batchName = ' + batchName);
            Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
            ID batchprocessid = Database.executeBatch(objBatch,1000);        
            System.debug('----------------------------- batchID = ' + batchprocessid);            
        }    
                              
                            
             
}