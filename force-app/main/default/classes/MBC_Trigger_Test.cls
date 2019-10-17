@isTest
private class MBC_Trigger_Test {
	
	static Employee__c emp;
	static Mandatory_Briefing_Creator__c mbc;
	static void createData()
	{
		//prepare employee data
		emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
		insert emp;
		//prepare mandatory briefing creator data
		mbc = new Mandatory_Briefing_Creator__c(Name__c = 'test mbc'+system.now(),Employee__c = emp.Id, Issued_Date_Time__c = system.now()+1 , Actual_End_Date_Time__c = system.now()+10 );
		insert mbc;
	}
    static testMethod void insertMBC() {
        createData();
    }
    static testMethod void checkforEmployee() {
        createData();
        try
        {
        	mbc.Employee__c = null;
        	update mbc;
        }
        catch(exception ex)
        {
        	
        }
    }
    static testmethod void checkForPastIssuedDate()
    {
    	try
    	{
    		//prepare employee data
			Employee__c emp1 = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
			insert emp1;
			//prepare mandatory briefing creator data
			Mandatory_Briefing_Creator__c mbc1 = new Mandatory_Briefing_Creator__c(Name__c = 'test mbc'+system.now(),Employee__c = emp1.Id, Issued_Date_Time__c = system.now()-2 , Actual_End_Date_Time__c = system.now()+10 );
			insert mbc1;
    	}
    	catch(exception ex)
    	{
    		
    	}
    	
    }
}