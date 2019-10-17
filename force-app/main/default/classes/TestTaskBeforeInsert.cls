@isTest
private class TestTaskBeforeInsert {

	static testMethod void insertTask()
	{
				
		Account acc1 = new Account(name = 'RA UpdateAcc', BillingStreet='19 Roundacre', 
										BillingPostalCode='SW19 6DB', BillingCity='London', 
										BillingCountry='UK', BillingState='London');
		Database.insert(acc1);
		
		Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
		Database.insert(camp);		
				
		Opportunity opp = new Opportunity (name = 'Task() opp', AccountId = acc1.Id,
												CloseDate = Date.today().addyears(1), 
												StageName = 'Active', CHI_Lead_Id2__c='56789087',
												Product_Interest__c='Central Heating Boiler',
												LeadSource='MARCOMMS',
												CampaignId=camp.Id);
		Database.insert(opp);
	
		Task task = new Task(Ext_Task__c='ABC123POPJ',Opportunity_Id__c='56789087',
								ActivityDate=Date.today(),
								Subject='Letter: Appointment Confirmation',Type__c='Letter');
								
		Database.insert(task);
		
		task = [SELECT t.Id, t.WhatId FROM Task t WHERE t.Id=:task.Id];
		System.assertEquals(opp.Id,task.WhatId);
		
	}
}