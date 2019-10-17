@istest (SeeAllData=true)
private class GeogrpahyUpdateBatch_Test {
	
	private static testmethod void testGeogrpahyUpdateBatch()
	{
		cls_IsRun.dontFireTriggers = true;
		cls_IsRun.generalTriggerSwitch = true;
		id Avav = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
		
		Account acc = TestClassHelper.createAccout();
		acc.BillingPostalCode = 'SK1 2QL';
		insert acc;
		
		Contact c = TestClassHelper.createContact(acc);
		insert c;
		
	    Opportunity opty = TestClassHelper.createCHILead(acc);
		insert opty;
		
		opty=[Select o.StageName, o.Last_Installation_Date__c, o.Id,DistrictName_Sales__c, o.CreatedDate, o.Account.Old_District_ID__c, o.Account.Old_Region_ID__c, o.Account.Sales_Subpatch__c, o.Account.Sales_Region__c, o.Account.Sales_District__c, o.Account.ShippingPostalCode, o.Account.Id, o.AccountId, Account.BillingPostalCode From Opportunity o where id = :opty.Id];
		
		Region__c regionId = [select id from Region__c where type__c = 'Installation' limit 1];
		
		District__c dist = TestClassHelper.createDistrict();
		dist.Region__c = regionId.Id;
		insert dist;
		
		BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opty);
		insert bm;
		
		Job__c job = TestClassHelper.createJob('Pending', 'Pending', opty.Id, dist.Id);
		job.Quote__c = bm.Id;
		insert job;
		job = [Select District__c, District_Name__c,Region__c,Install_Postcode__c,CHI_Lead__c, Account_Id__c From Job__c where id=:job.Id];
		
		Test.startTest();
		GeogrpahyUpdateBatch  newObj = new GeogrpahyUpdateBatch();
		newObj.qurey = 'Select o.StageName, o.Last_Installation_Date__c, o.Id, o.CreatedDate, o.Account.Old_District_ID__c, o.Account.Old_Region_ID__c, o.Account.Sales_Subpatch__c, o.Account.Sales_Region__c, o.Account.Sales_District__c, o.Account.ShippingPostalCode, o.Account.Id, o.AccountId, Account.BillingPostalCode From Opportunity o limit 5';
		GeogrpahyUpdateBatch.createGeogrpahyUpdateBatch();
		
		newObj.takeGeogrphyJobbackup(new list<Job__c>{job});
		newObj.DeriveNewGeoforJob(new list<Job__c>{job});
		newObj.takeAppointmentBackup(new list<Opportunity>{opty});
		newObj.deriveNewGeoforAcc(new list<Opportunity>{opty});
		Test.stopTest();
	}

}