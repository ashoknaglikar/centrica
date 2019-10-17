@isTest
private class Sendmail_Test {    
	static testMethod void Createmail() 
	{ 
		//Create job
    	String testDistrict = '';
    	Postcode_Sector__c testPostCode = [Select Sub_Patch__r.District__c, name From Postcode_Sector__c where type__c = 'Installation' limit 1];
    	
    	Account testAccount = new Account();
    	testAccount.name = 'test1';
    	testAccount.BillingPostalCode = testPostCode.name + '02';
    	testAccount.BillingStreet = 'test address';
    	insert testAccount;
    	
    	Opportunity testOpp = new Opportunity(); 
    	testOpp.Name = 'test2';
    	testOpp.AccountID = testAccount.ID;
    	testOpp.LeadSource = 'Engineer';
    	testOpp.Referral_Employee__c = [select id from Employee__c limit 1].ID;
    	testOpp.Product_Interest__c = 'Solar';
    	testOpp.StageName = 'Active';
    	testOpp.CloseDate = System.today().AddDays(1);     	
    	insert testOpp; 
    	
    	Job__c testJob = new Job__c();
    	testJob.CHI_Lead__c = testOpp.ID;
    	testJob.Installation_Date__c = System.today();
    	insert testJob;
    	
    	Installer__c testInstaller = new Installer__c();
		testInstaller.Job__c = testJob.id;
		testInstaller.User__c = UserInfo.getUserId();
		testInstaller.Name = 'Test';
		
		Insert testInstaller;
		
		testInstaller = [select id, Is_Ready__c from Installer__c where id =:testInstaller.ID limit 1];
		System.debug('--------- testInstaller  = '+ testInstaller.Is_Ready__c);
		
		Test.startTest();
		//Sendmail.createMail();
		Test.stopTest();
	}
}