trigger cronKitBatchTrigger on cron__Batch_Run__c (before insert, before update) {

//  This Apex trigger is designed to fire when the batch workflow scheduler 
//  checks the Trigger Batch Run checkbox or when changes are made to the Batch Run
//  record manually.


    Boolean error = false;  // Var used by each batch job to flag and return an error to the Batch Run object.
    String results = '';    // Batch job results, also returned to the Batch Run object.

    for (cron__Batch_Run__c batchRun : Trigger.new) {
    System.debug(batchRun);

        // Skip batch jobs not handled by this trigger
        if (batchRun.cron__Batch_Job_Type__c == null) continue;
        if (batchRun.cron__Batch_Job_Type__c != 'Job-Notification') continue;

       if ( batchRun.cron__Completed__c != null) {
           System.debug('Job is already completed');
        continue;    // Job has alread run, skip all this
        
       } 
       

        if ( batchRun.cron__Trigger_Batch_Run__c == true ) {
            
            System.debug('Trigger Batch Run set. Running batch job.');
                            
            // --------------- Batch Job Housekeeping --------------------
                  //Datetime lastrun = Datetime.now();
                  Datetime lastrun = (batchRun.cron__Scheduled_To_Run__c==null?Datetime.now():batchRun.cron__Scheduled_To_Run__c);
                  Datetime nextrun;
                  System.debug('Last run '+lastrun);
                  if(batchRun.cron__Run_Every_Units__c == 'Days') {
                      nextrun = lastrun.addDays(batchRun.cron__Run_Every__c.intValue());
                  } else if(batchRun.cron__Run_Every_Units__c == 'Hours') {
                      nextrun = lastrun.addHours(batchRun.cron__Run_Every__c.intValue());
                  } else {
                     nextrun = lastrun.addMinutes(batchRun.cron__Run_Every__c.intValue());
                  }
                  if (nextrun < Datetime.now()) {
                      nextrun = Datetime.now();
                  } 
              
            // Create the next Batch Run and configure it so that the scheduler workflow 
            // adds a Trigger_Batch_Run field update in the time-based workflow queue.
            cron__Batch_Run__c newRun = new cron__Batch_Run__c(
                    cron__Scheduled_To_Run__c = nextrun,
                    cron__Trigger_Batch_Run__c = false,
                cron__Batch_Job_Name__c = batchRun.cron__Batch_Job_Name__c,
                    cron__Batch_Job__c = batchRun.cron__Batch_Job__c,
                    cron__Batch_Job_Type__c = batchRun.cron__Batch_Job_Type__c,
                    cron__Run_Every__c = batchRun.cron__Run_Every__c,
                    cron__Run_Every_Units__c = batchRun.cron__Run_Every_Units__c,
            cron__Trigger_Scheduler_1__c = true);
            insert newRun;

            // Update the current Batch Run dates and uncheck batch job trigger
                    batchRun.cron__Completed__c = Datetime.now();
                    if (batchRun.cron__Scheduled_To_Run__c == null) {
                        batchRun.cron__Scheduled_To_Run__c = lastrun;
                    }
                    batchRun.cron__Trigger_Batch_Run__c = false; 
            
            // ------------ End Batch Job Housekeeping -------------------


            // ----------- Begin batch jobs -----------------

            
            if (batchRun.cron__Batch_Job_Type__c == 'Job-Notification') {
                error = false;
                results = '';
                Sendmail.Createmail();
                // Insert your Apex code here... be sure to set vars 'error' and 'results' to 
                // pass batch results back to the Batch Run object.
                    
            } 

            // ----------- End batch jobs -----------------
            

            // Report Governor Limit Stats and set return values
            String limitText = 'Aggregate Queries: '+
                    Limits.getAggregateQueries() +'/' + 
                    Limits.getLimitAggregateQueries();
            limitText += '\nSOQL Queries: '+ 
                    Limits.getQueries() +'/' + 
                    Limits.getLimitQueries();
            limitText += '\nQuery Rows: '+ 
                    Limits.getQueryRows() +'/' +
                    Limits.getLimitQueryRows();
            limitText += '\nDML Statements: '+ 
                    Limits.getDMLStatements() +'/' +
                    Limits.getLimitDMLStatements();
            System.debug(limitText);                
                
            batchRun.cron__Results__c = results;
            batchRun.cron__Results__c += '\n\n'+limitText;
            if (error) {
                // write error to batch run notes field and set error flag
                batchRun.cron__Result__c = 'Error';
            } else {
                batchRun.cron__Result__c = 'Success';
            }

        } else { // end if trigger batch job flag set
            System.debug('Refreshing time-based workflow queue');
            // Alternate Trigger Scheduler flags to keep workflow queued and current
            if (batchRun.cron__Trigger_Scheduler_1__c == false) {
                        batchRun.cron__Trigger_Scheduler_1__c = true;
                        batchRun.cron__Trigger_Scheduler_2__c = false;
            } else {
                          batchRun.cron__Trigger_Scheduler_1__c = false;
                      batchRun.cron__Trigger_Scheduler_2__c = true;                        
            }    
        
        }

    }

}