@isTest 
private class cronKitBatchTrigger_Test {
// on cron__Batch_Run__c
	public static testmethod void testNotificationCleanup(){

		cron__Batch_Job__c testjob1 = new cron__Batch_job__c();
		testjob1.Name='Big Machines Quote Creation';
		testjob1.cron__Batch_Job_Type__c='Big Machines Quote Creation';
		testjob1.cron__Run_Every__c=1.0;
		testjob1.cron__Run_Every_Units__c='Hours';
		try{
			insert testjob1;
		}catch(DMLException e){
			//system.assert(false,'Error creating job');
		}


		cron__Batch_Run__c c1= new cron__Batch_Run__c();
		c1.cron__Trigger_Batch_Run__c = true;
		c1.cron__Batch_Job_Name__c = testjob1.Name;
		c1.cron__Run_Every__c = testjob1.cron__Run_Every__c;
		c1.cron__Run_Every_Units__c = testjob1.cron__Run_Every_Units__c;
		c1.cron__Batch_Job__c = testjob1.id;
		c1.cron__Batch_Job_Type__c = testjob1.cron__Batch_Job_Type__c;
		c1.cron__Trigger_Batch_Run__c = true;
		
		try{
			insert c1;
		}catch(DMLException e){
			//system.assert(false,'Error creating job');
		}


		cron__Batch_Job__c testjob = new cron__Batch_job__c();
		testjob.Name='Job-Notification';
		testjob.cron__Batch_Job_Type__c='Job-Notification';
		testjob.cron__Run_Every__c=1.0;
		testjob.cron__Run_Every_Units__c='Hours';
		try{
			insert testjob;
		}catch(DMLException e){
			//system.assert(false,'Error creating job');
		}



		cron__Batch_Run__c c= new cron__Batch_Run__c();
		c.cron__Trigger_Batch_Run__c = true;
		c.cron__Batch_Job_Name__c = testjob.Name;
		c.cron__Run_Every__c = testjob.cron__Run_Every__c;
		c.cron__Run_Every_Units__c = testjob.cron__Run_Every_Units__c;
		c.cron__Batch_Job__c = testjob.id;
		c.cron__Batch_Job_Type__c = testjob.cron__Batch_Job_Type__c;
		c.cron__Trigger_Batch_Run__c = true;
		
		try{
			insert c;
		}catch(DMLException e){
			//system.assert(false,'Error creating job');
		} 
	}
}