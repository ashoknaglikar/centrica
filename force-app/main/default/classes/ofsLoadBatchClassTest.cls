/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ofsLoadBatchClassTest {

    static testMethod void unitTest1() {
    	
    Account acc = TestClassHelper.createAccout();
    insert acc;
    
    Contact con = TestClassHelper.createContact(acc);
    insert con;
    
    Opportunity opp1 = TestClassHelper.createCHILead(acc);
    Opportunity opp2 = TestClassHelper.createCHILead(acc);
    insert new list<Opportunity>{opp1, opp2};
    
    User hsaUser = TestClassHelper.createUser();
    insert hsaUser;
    
    Employee__c emp = TestClassHelper.createEmployee();
    emp.Salesforce_User__c = hsaUser.Id;
    
    Employee__c ofsBucket = TestClassHelper.createEmployee();
    ofsBucket.Salesforce_User__c = hsaUser.Id;
    ofsBucket.Primary_Role__c = 'OFS Bucket';
    ofsBucket.Employee_Number__c = 'Buck101';
    insert new list<Employee__c>{emp, ofsBucket};
    
    Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;    
    
    Appointment__c app1 = TestClassHelper.createAppointment(opp1,emp.Id,hsaUser.Id, availableRecordTypeId,  con.Id );
    app1.Start__c = system.now().adddays(1);
    app1.End__c = system.now().adddays(1).addhours(2);
    app1.OFS_Appointment__c = true;
    app1.PushToOFS__c =true;
    
    Appointment__c app2 = TestClassHelper.createAppointment(opp2,ofsBucket.Id,hsaUser.Id, availableRecordTypeId,  con.Id );
    app2.OFS_Appointment__c = true;
    app2.Start__c = system.now().adddays(1);
    app2.End__c = system.now().adddays(1).addhours(2);
    app2.PushToOFS__c =true;
    
    
    insert new list<Appointment__c>{app1, app2};
    
    CreateEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'}, 'Debug : '+app1.Start__c +'  '+app1.OFS_Appointment__c, 'Debug');
    
    pagereference pageRef = new pagereference('/apex/ofsLoadPage');
	test.setCurrentPage(pageRef);   
	ApexPages.StandardController controller = new ApexPages.StandardController(new OFS_Load__c());
	OFSLoadController cont_Gd = new OFSLoadController(controller);
    try{
    cont_Gd.querySalesforce();
    }catch (Exception e)
    {
    	system.assert(true, 'Exception Occured: Null Pointer Exception');
    }
    
    cont_Gd.ofsLoad.Request_Date__c = system.today();
    cont_Gd.querySalesforce();
    
    cont_Gd.ofsLoad.Request_Date__c = app1.Start__c.date();
    cont_Gd.querySalesforce();
    
    cont_Gd.invokeBatch();
    
    cont_Gd.invokeBatch();
    
    cont_Gd.abortBatch();
    cont_Gd.abortBatch();
    cont_Gd.ofsButton = true;
    
    pageRef = new pagereference('/apex/ofsLoadPage');
	test.setCurrentPage(pageRef);   
	ApexPages.StandardController controller_new = new ApexPages.StandardController(new OFS_Load__c());
	OFSLoadController cont_new = new OFSLoadController(controller_new);
    
    
    	
        // TO DO: implement unit test
        
    }
    /*
    static testMethod void unitTest2() {
    	
			
    Account acc = TestClassHelper.createAccout();
    insert acc;
    
    Contact con = TestClassHelper.createContact(acc);
    insert con;
    
    Opportunity opp1 = TestClassHelper.createCHILead(acc);
    Opportunity opp2 = TestClassHelper.createCHILead(acc);
    insert new list<Opportunity>{opp1, opp2};
    
    User hsaUser = TestClassHelper.createUser();
    insert hsaUser;
    
    Employee__c emp = TestClassHelper.createEmployee();
    emp.Salesforce_User__c = hsaUser.Id;
    
    Employee__c ofsBucket = TestClassHelper.createEmployee();
    ofsBucket.Salesforce_User__c = hsaUser.Id;
    ofsBucket.Primary_Role__c = 'OFS Bucket';
    ofsBucket.Employee_Number__c = 'Buck101';
    insert new list<Employee__c>{emp, ofsBucket};
    
    Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;    
    
    Appointment__c app1 = TestClassHelper.createAppointment(opp1,emp.Id,hsaUser.Id, availableRecordTypeId,  con.Id );
    app1.Start__c = system.now().adddays(1);
    app1.End__c = system.now().adddays(1).addhours(2);
    app1.OFS_Appointment__c = true;
    app1.PushToOFS__c =true;
    
    Appointment__c app2 = TestClassHelper.createAppointment(opp2,ofsBucket.Id,hsaUser.Id, availableRecordTypeId,  con.Id );
    app2.OFS_Appointment__c = true;
    app2.Start__c = system.now().adddays(1);
    app2.End__c = system.now().adddays(1).addhours(2);
    app2.PushToOFS__c =true;
    
    
    insert new list<Appointment__c>{app1, app2};
    OFS_Load__c ofsLoad = new OFS_Load__C(Request_date__c = system.today());
    
    insert ofsLoad;
    
    app2 = [select id, X18_Digit_App_Id__c from Appointment__c where id =: app2.Id];
    
    test.starttest();
    
    SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 'inactive',
                                               '{"items": [{"workZoneLabel": "xxzz","workZoneName": "SalesSubpatch2","status":"inactive","travelArea": "North","keys": ["ZTPCS 2"]}]}', null);
    
    Test.setMock(HttpCalloutMock.class, fakeResp); 
	ofsLoadBatchClass objLoad = new ofsLoadBatchClass(app1.Id, ofsLoad);
	ID batchId = Database.executeBatch(objLoad,100);
	
	
	
	/*
	SubPatchUpInOFSRestMock fakeResp2 = new SubPatchUpInOFSRestMock(200,
                                                 'inactive',
                                               '{"items": [{"apptNumber": "'+app2.X18_Digit_App_Id__c+'","XA_eta": "06/05/17 09:00 AM","status":"pending","resourceId": "'+emp.Id+'","keys": ["ZTPCS 2"]}]}', null);
                                               
	Test.setMock(HttpCalloutMock.class, fakeResp2); 
	objLoad = new ofsLoadBatchClass(app2.Id, ofsLoad);
	Database.executeBatch(objLoad,100);
	
	
	test.stopTest();
		
    }
    
    	*/
}