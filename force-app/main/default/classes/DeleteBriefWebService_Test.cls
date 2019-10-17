@isTest
private class DeleteBriefWebService_Test {
	
	static Employee__c emp;
	static Mandatory_Briefing_Creator__c mbc;
	static Mandatory_Briefings__c mb;
	
    static void createData()
    {
    	//prepare employee data
		emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
		insert emp;
		//prepare mandatory briefing creator data
		mbc = new Mandatory_Briefing_Creator__c(Name__c = 'test mbc'+system.now(),Employee__c = emp.Id, Issued_Date_Time__c = system.now()+1 , Actual_End_Date_Time__c = system.now()+10 );
		insert mbc;
		//insert brief data
		mb  = new Mandatory_Briefings__c();
		mb.Briefing_Name__c = mbc.Name__c;
		mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
		mb.Employee__c = mbc.Employee__r.Id;
		mb.Content__c = mbc.Content__c;
		mb.Mandatory_Briefing_Creator__c = mbc.Id;
		mb.Status__c = 'In Progress';
		insert mb;
    }
    
    static testmethod void testDeleteBriefWebService()
    {
    	createData();
    	DeleteBriefWebService.deleteMandatoryBriefs(mbc.id);
    }
}