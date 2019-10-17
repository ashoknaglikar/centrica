@istest

private class TestUpdateExtractFlag {
	
	static testMethod void testUpdateExtractFlag (){
			
		TestEventAndAppointmentSynchronisation.Setup s = new TestEventAndAppointmentSynchronisation.Setup();
			
		// Create Account
		Account acc = new Account(name = 'updateOpportunityStatus() acc uef', BillingStreet='1000 Roundacre uef', 
								  BillingPostalCode='SW19 6DF', BillingCity='London', 
								  BillingCountry='UK', BillingState='London');
		
		Database.insert(acc);
		
		// Create campaign
		Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
		Database.insert(camp);		
		
		// Create Opportunity
		Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'updateOpportunityStatus() opp uef', 
											AccountId = acc.Id, 
											CloseDate = Date.today().addyears(1), 
											StageName = 'Active',
											Product_Interest__c='Central Heating Boiler',
											CampaignId = camp.Id);
		
		Database.insert(opp);
		String oppId = opp.Id;
		
		// Create contact
		Contact contact = new Contact(LastName = 'contact uef', AccountId = acc.Id);
		Database.insert(contact);
		
		// Create Two Appointments
		Datetime startTime = Datetime.newInstance(2010, 11, 1);
		Datetime endTime = Datetime.newInstance(2010, 11, 10);
		Appointment__c app1 = new Appointment__c(Start__c = startTime, End__c = endTime,
												Subject__c = 'updateOpportunityStatus() subject 1 uef',
												Opportunity__c = opp.Id, Status__c = 'Appointed',
												Who__c = contact.Id,Visit_Type__c = 'Sales' ,RecordTypeId = s.appointmentApptRecTypeId);
														
		Database.insert(app1);
													
		// Check Appointment Histories exist
		try {
			Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
													WHERE a.WhatID__c = :opp.Id and a.Appointment__c = :app1.Id];	
			
		
				
			appHistories[0].Sent_To_Premier__c = true;
			Database.update(appHistories[0]);
	        System.assertEquals(false, appHistories[0].SA_Extract_Flag__c);
	        System.assertEquals(false, appHistories[0].ST_Extract_Flag__c);
		} catch(Exception ex) {
			//do nothing
		}						
			
		}
		

}