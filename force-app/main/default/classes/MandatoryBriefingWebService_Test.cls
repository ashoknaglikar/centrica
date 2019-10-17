@isTest
private class MandatoryBriefingWebService_Test {

    static Employee__c emp;
	static Mandatory_Briefing_Creator__c mbc;
	static Groups__c groupObj;
	static Employee_Group__c empGroup;
	static User UInstal1;
	static void createData()
	{
		//prepare employee data
		emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
		insert emp;
		
		//prepare group data
		groupObj = new Groups__c (Name = 'testEmpGropu');
		insert groupObj;
		
		//prepare employee group data
		empGroup = new Employee_Group__c(Employee__c = emp.Id , Group__c = groupObj.Id);
		insert empGroup;
		
		//prepare mandatory briefing creator data
		mbc = new Mandatory_Briefing_Creator__c(Name__c = 'test mbc'+system.now(),Employee__c = emp.Id, Issued_Date_Time__c = system.now()+1 , Actual_End_Date_Time__c = system.now()+10 , Employee_Group__c = groupObj.Id);
		insert mbc;
	
	}
	
	static testmethod void testMandatoryBriefingWebService()
	{
		createData();
		MandatoryBriefingWebService.generateMandatoryBriefs(mbc.id);
	}
	
	static testmethod void testInactiveEmployee()
	{
		createData();
		Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
	    UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
	                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
	                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser1@testorg1.com1',Migration_ID__c ='A763BH12e32345' , IsActive = false);
	    insert UInstal1;  
	       
		emp.Salesforce_User__c = UInstal1.Id;
		update emp;
		
		MandatoryBriefingWebService.generateMandatoryBriefs(mbc.id);
	}
	
	static testmethod void checkForDocuments()
	{
		createData();
		MandatoryBriefingWebService.checkForDocuments(mbc.id);
	}
}