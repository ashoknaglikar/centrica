@istest
private class DuplicateAttachmentCleanerTest {

	

	private static testmethod void testScenrio_1()
	{

		createtestData();

		DuplicateAttachmentCleaner.createDuplicateAttachementCleaner();

	}

	
	private static void createtestData()
	{
		Id ProfileId = [select id from Profile where Name  = 'CHI HSA'].Id;

		User hsaUser = TestClassHelper.createUser();
		hsaUser.ProfileId = ProfileId;
		insert hsaUser;

		Employee__c hsa = TestClassHelper.createEmployee();
		hsa.Primary_Role__c = 'HSA';
		hsa.Salesforce_user__c = hsaUser.Id;
		insert hsa;

		Account acc = TestClassHelper.createAccout();
		insert acc;

		Contact con = TestClassHelper.createContact(acc);
		insert con;

		acc.Primary_Contact__c = con.Id;
		update acc;

		Opportunity opp = TestClassHelper.createCHILead(acc);
		insert opp;

		system.runas(hsaUser)
		{
			list<Attachment> attachmentList = new list<Attachment>();
			for(integer i =0;i<2;i++)
			{
				for(integer j= 0; j<5 ;j++)
				{
					Attachment att = TestClassHelper.createAttachemnt(opp.Id);
					att.name= 'Test_'+i;
					attachmentList.add(att);
				}
			}
			insert attachmentList;
		}

		id AppointemenId = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');

		Appointment__c app = TestClassHelper.createAppointment(opp,hsa.Id,hsaUser.Id,AppointemenId, con.Id);
		app.Start__c = System.now().adddays(-1);
		app.End__c = System.now().adddays(-1).addhours(2);
		insert app;

		




	}

}