@istest
public with sharing class cocController_test {
	
	public static testmethod void testMethod1()
	{
		Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	District__c dist = TestClassHelper.createDistrict();
    	insert dist;
    	
    	Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    	job.Mechanical_Installer__c='test1,Test2';
    	insert job;
    	
    	ID gasDocuementID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
    	
    	Commissioning_Report__c jcd = TestClassHelper.createJobCompletionDoc(gasDocuementID, job.Id); 
    	
    	insert jcd;
    	
    	test.setCurrentPage(new pagereference('/apex/COCForm1?p=1&jcdId='+jcd.Id));
		cocController cocCon = new cocController();
		cocCon.saverecord();
		cocCon.cancel();
	
    	
    	
	}
	
	
	public static testmethod void testMethod2()
	{
		Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	District__c dist = TestClassHelper.createDistrict();
    	dist.COC_Ready__c =true;
    	insert dist;
    	
    	BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opp);
    	bmQuote.POC_Payment_Method__c ='Finance';
    	bmQuote.POC_Payment_Option__c = 'Green Deal Finance';
    	insert bmQuote;
    	
    	Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    	job.Mechanical_Installer__c='test1,Test2';
    	job.Quote__c = bmQuote.Id;
    	insert job;
    	
    	ID gasDocuementID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
    	
    	Commissioning_Report__c jcd = TestClassHelper.createJobCompletionDoc(gasDocuementID, job.Id); 
    	
    	insert jcd;
    	
    	Attachment att = new Attachment();
    	 att.Body = Blob.valueOf('FFFFFF');
	     att.ContentType = 'application/pdf';
		 att.Name = '1234554321.pdf';
		 att.ParentId = jcd.Id;
		 insert att;
    	
    	string s = att.Body.tostring();
    	update (new Job__c(id = Job.Id, District__c = dist.Id));
    	/*system.debug('Job District -->'+dist.Id+dist.COC_Ready__c);
    	system.debug('Job District -->'+Job.District__c);
    	system.debug('Job District -->'+[select District__r.COC_Ready__c from Job__c where id =:job.Id ].District__r.COC_Ready__c);
    	system.debug('District -->'+[select Job_Number__r.District__c, Job_Number__r.District__r.COC_Ready__c
                                From Commissioning_Report__c c where id =:jcd.Id].Job_Number__r.District__c);
        system.debug('District -->'+[select Job_Number__r.District__c, Job_Number__r.District__r.COC_Ready__c
                                From Commissioning_Report__c c where id =:jcd.Id].Job_Number__r.District__r.COC_Ready__c);*/
    	
    	PageReference pageRef = Page.COCForm1;
		pageRef.getParameters().put('jcdId', jcd.Id);
    	
    	test.setCurrentPage(pageRef);
    	cocController cocCon = new cocController();
		cocCon.jcd.GD_Claims_of_conformity__c = 'Completed- Electronically';
		cocCon.saverecord();
		pageRef.getParameters().put('date1', '2001/01/01');
		cocCon.saverecord();
		pageRef.getParameters().put('date1', '01-01-2001');
		cocCon.saverecord();
    	pageRef.getParameters().put('date2', '2001/01/01');
    	cocCon.saverecord();
    	pageRef.getParameters().put('date2', '01-01-2001');
    	cocCon.saverecord();
		pageRef.getParameters().put('encInst', 'test');
		cocCon.saverecord();
		pageRef.getParameters().put('encInst', 'test+');
		cocCon.saverecord();
    	pageRef.getParameters().put('encCust', 'test');
    	cocCon.saverecord();
    	pageRef.getParameters().put('date1', '2001-01-01');
    	pageRef.getParameters().put('date2', '2001-01-01');
    	pageRef.getParameters().put('encInst', 'test+');
    	pageRef.getParameters().put('encCust', 'test+');
    	cocCon.saverecord();
    	pageRef.getParameters().put('date1', '2001-01-01');
    	pageRef.getParameters().put('date2', '2001-01-01');
    	pageRef.getParameters().put('encInst', 'test+,'+s);
    	pageRef.getParameters().put('encCust', 'test+,'+s);
    	cocCon.saverecord();
		cocCon.jcd.GD_Claims_of_conformity__c = 'Test';
		cocCon.saverecord();
		cocCon.pdf =true;
		cocCon.methodtest();
		cocCon.cancel();
	
        
    	
	}

}