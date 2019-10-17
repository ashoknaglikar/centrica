trigger BigMachinesInterfaceBatchControl on cron__Batch_Run__c (before insert, before update) {

//Trigger for CronKit. Fires at each batch run to perform batch run logic. 
//Used to send appointment data to BigMachines as a batch process 
//This Apex trigger is designed to fire when the batch workflow scheduler 
//checks the 'Trigger Batch Run' checkbox or when changes are made to the Batch Run
//record manually.
//Created from the Linivo CronKit trigger template.
integer count = 0;
	try{
	 Boolean error = false; // Var used by each batch job to flag and return an error to the Batch Run object.
	 String results = ''; // Batch job results, also returned to the Batch Run object.
	 Boolean myRun = false;
		count = 1;
	    for (cron__Batch_Run__c batchRun : Trigger.new) {
	    System.debug(batchRun);
			count++;
		    // Skip batch jobs not handled by this trigger
		    if (batchRun.cron__Batch_Job_Type__c == null || batchRun.cron__Batch_Job_Type__c != 'custom' || batchRun.cron__Completed__c != null) 
		    	continue;
	    
	   		if (batchRun.cron__Trigger_Batch_Run__c == true) {    
	    		System.debug('Trigger Batch Run set. Running batch job.');
	    
			    // --------------- Batch Job Housekeeping --------------------
			    Datetime lastrun = (batchRun.cron__Scheduled_To_Run__c==null?Datetime.now():batchRun.cron__Scheduled_To_Run__c);
			    Datetime nextrun;
			    System.debug('Last run '+lastrun);
			
			    
		     if(batchRun.cron__Batch_Job_Name__c == 'Big Machines Quote Creation')
		    	nextrun = lastrun.addMinutes(15);
		     else if(batchRun.cron__Run_Every_Units__c == 'Days')
                nextrun = lastrun.addDays(batchRun.cron__Run_Every__c.intValue());
             else
              	nextrun = lastrun.addHours(batchRun.cron__Run_Every__c.intValue());

			    if (nextrun < Datetime.now()) {
			    	nextrun = Datetime.now();
			    } 
			 
			    // Create the next Batch Run and configure it so that the scheduler workflow 
			    // adds a Trigger_Batch_Run field update in the time-based workflow queue.
			   	    
			    cron__Batch_Run__c newRun = new cron__Batch_Run__c(cron__Scheduled_To_Run__c = nextrun,
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
		
		
				 // ----------- Begin batch job logic -----------------
				 // Insert your Batch run Apex code here. Set variables 'error' and 'results' to 
				 // pass batch results back to the Batch Run object.
				
				//for BigMachines interface - send appointment data to Big Machines	
				/*
				if (batchRun.cron__Batch_Job_Name__c == 'Big Machines Quote Creation') {		                   					    			    
				    //Apex Code to run Big Machines Quote creation interface
				    //String[] JobResult = BigMachinesQuoteInterface.batchUpdateBigMachines();
				    if(JobResult[0]=='true')
				    	error = true;
				    else if(JobResult[0]=='false')	
				    	error = false;	
				    results = JobResult[1];	    
				 } 				 			
			    */
			 	// ----------- End batch job logic -----------------
	    
			    /* Not used currently, use for debugging if required - Report Governor Limit Stats in results parameter and set return values
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
			    batchRun.cron__Results__c = '\n\n'+limitText;*/
			    //Instead use results passed back from Apex method called
			    batchRun.cron__Results__c = results;
			    
			    // write error to batch run notes field and set error flag
			    if(error) 	    	
			    	batchRun.cron__Result__c = 'Error';
			    else
			    	batchRun.cron__Result__c = 'Success';	
			    			    	
	   		} 
		    else { // end if trigger batch job flag set
			    System.debug('Refreshing time-based workflow queue');
			    // Alternate Trigger Scheduler flags to keep workflow queued and current
			    if (batchRun.cron__Trigger_Scheduler_1__c == false) {
			         batchRun.cron__Trigger_Scheduler_1__c = true;
			         batchRun.cron__Trigger_Scheduler_2__c = false;
			    } 
			    else {
			         batchRun.cron__Trigger_Scheduler_1__c = false;
			         batchRun.cron__Trigger_Scheduler_2__c = true;  
			    }   
		    }    
	    }
	}
	catch(exception e){
		system.debug('trigger size is: '+trigger.new.size());
		system.debug('trigger contains: '+trigger.new);
		system.debug('count is: '+count);
		system.debug('error is: '+e);
		
		for (cron__Batch_Run__c batchRun : Trigger.new) {
			batchRun.cron__Results__c = 'Error:Exception Occurred: '+e;
			batchRun.cron__Result__c = 'Error';
		}
		
		// Send an email to the SFDC admin to notify of failure.	
		Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();		
		String[] toAddresses1 = new String[] {'CHI-Salesforce.support@centrica.com','BGSAMS.Support@Centrica.com'};				    				
		mail1.setToAddresses(toAddresses1);
		mail1.setSubject('BM: Caught Exception: Apex Exception occurred in the SFDC to Big Machines Batch Interface');
		mail1.setPlainTextBody('BM: A CronKit batch job sending quote information to Big Machines has failed to execute successfully. Please check that the CronKit batch job Big Machines Quote Creation is running. Error received: ' + e.getMessage());
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });			
	}
	
}