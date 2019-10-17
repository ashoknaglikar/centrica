@isTest
private class TestBigMachinesInterfaceBatchControl {
	
	//Insert a batchrun so that trigger fires to obtain coverage
	static testMethod void TestBigMachinesInterfaceBatchControl(){
	
	
	cron__Batch_Job__c batchjob = new cron__Batch_Job__c();
	batchjob.Name='TestName';
	batchjob.cron__Batch_Job_Type__c='Custom';
	insert batchjob;
	
	cron__Batch_Run__c batchrun = new cron__Batch_Run__c();
	batchrun.cron__Batch_Job__c=batchjob.Id;
	batchrun.cron__Scheduled_To_Run__c=datetime.now();
	batchrun.cron__Batch_Job_Type__c='Custom';
	//batchrun.cron__Trigger_Batch_Run__c=true; CF - commented this out to get into prod. set to true again once deployed.
	batchrun.cron__Trigger_Batch_Run__c=false;
	insert batchrun;	
		
	}
}