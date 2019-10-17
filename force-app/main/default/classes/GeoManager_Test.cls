@istest
public with sharing class GeoManager_Test {
	
	static testmethod void testScenario1()
	{
		cls_isRun.generalTriggerSwitch =true;
	
		Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	Installer__c inst = new Installer__c();
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,null);
    	job.GM_Status__c = 'In Progress';
    	
		insert(job);
		
		inst = new Installer__c(Start_Date__c = System.today().adddays(1), End_Date__c = System.today().adddays(2), Job__c = job.id,
																	Installer_Status__c = 'Active' );
	    insert inst;
		
			
		// Scenario to cover GM_Status__c = In Prgoress
		
		Test.setMock(HttpCalloutMock.class, new HttpMockup());
		//GeoManager.sendSendSingleJob(new list<string> {job.Id});
		GeoManager.fetchJobsbyQuery();
		
		
		
		
	}
	
	static testmethod void testScenario2()
	{
		cls_isRun.generalTriggerSwitch =true;
	
		Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	Installer__c inst = new Installer__c();
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,null);
    	
		insert(job);
		Test.setMock(HttpCalloutMock.class, new HttpMockup());
		
		string result = GeoManager.sendSendSingleJob(new list<string> {job.Id});
		system.assertequals(result,'Job is not ready to be itegrated.');
		
		
		try{
			
			job.Latitude__Latitude__s= 1.234567;
			job.Longitude__Longitude__s= 1.234567;
			job.GM_Status__c = 'In Progress';
			job.Status__c ='Cancelled';
			job.GM_Status_Reason__c = 'Sucessfull';
			job.GMLoaded_Date__c = system.now();
			update job;
			GeoManager.sendSendSingleJob(new list<string> {job.Id});
		}catch (exception e)
		{
			
		}
		
		
		
		try{
			job.GM_Status__c = 'In Progress';
			job.Status__c = 'Planned';
			job.GM_Status_Reason__c = 'Sucessfull';
			job.GMLoaded_Date__c = system.now();
			update job;
			GeoManager.sendSendSingleJob(new list<string> {job.Id});
		}catch (exception e)
		{
			
		}
		
		try{
			job.GM_Status__c = 'Loaded';
			update job;
			GeoManager.sendSendSingleJob(new list<string> {job.Id});
			
		}catch (exception e)
		{
			
		}
		
		
		
		
		
	}

}