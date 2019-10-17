@isTest
private with sharing class TestOppContactDeleteTrigger {
	
	 static testMethod void testOppContactDeleteTrigger() {
    
        // Create Account
        Account acc = new Account(name = 'Test', BillingStreet='8 Opp Contact Delete Test', 
                                  BillingPostalCode='SW19 6DF', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        
        // Create campaign
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='OppConDelete');
        Database.insert(camp);      
        
        // Create Opportunity
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'Test', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        Database.insert(opp);
  
        // Create contact
        Contact contact = new Contact(LastName = 'OppContact Delete', AccountId = acc.Id);
        Database.insert(contact);
        
        // Set up recordTypes
        
        String apptRecType;
		RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];
		for(RecordType rt : recordTypes) {
				if(rt.sObjectType == 'Appointment__c'){
					if(rt.Name == 'Appointment')
						apptRecType = rt.Id;
				}
			}
			
		// Set up employee and user
			
			Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
			User dummyUser = new User(LastName = 'User', Alias = 'duser', 
								Email = 'dummy@user.com', Username='test' + System.now().format('yyddmmssSS') + '@testdata.com',
								ProfileId = p.Id, EmailEncodingKey='UTF-8',
								Migration_ID__c = 'dummy@user.com',
								TimeZoneSidKey = 'Europe/London', 
								LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
			insert(dummyUser);
     		Employee__c emp = new Employee__c(First_Name__c = 'emp', Last_Name__c='surname', Employee_Number__c = System.now().format('ddmmssSS').substring(0,8),
                                                                                     Salesforce_User__c = dummyUser.Id);
     		Database.insert(emp);

	  // Determine what values we are going to use for the Appointment
	    
			Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
			Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
			Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 8, 0, 0);
			String subject = 'createNewAppt() Test';
			Boolean anyTime = false; // Also: True
			Boolean convertedVisitType = true; // Or False
			String description = 'createNewAppt() description';
			Boolean doNotSendToPremier = false; // Also: true
			Boolean allDayEvent = false; // Also: True
			Datetime lastSentToPremier = Datetime.now();
			
			String mode = 'SA'; // Other options available
		
			String recordTypeId = apptRecType; // Other options available
			String resourceType = 'A';
			Boolean sale = false; // Also: True
			String showTimeAs = 'Busy'; // Also: Out of Office, Free
			String statusReason = 'INFORMATION PROVIDED'; // Other options available
			String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
			String timeBand = 'AM'; // Also: PM, EV, AT
			
			String typeC = 'Sales'; // Other options available
		

			String visitType = 'First Visit'; // Also: Recall Visit, Pickup
			String opportunity = opp.Id;
			String who = contact.Id;
			String postcodeSector = 'SE3 9';

			// Now create the appointment and insert it
			
			Appointment__c app = new Appointment__c(Start__c = startTime, 
								 End__c = endTime, Subject__c = subject, 
								 Assigned_To__c = emp.Id,Any_Time__c = anyTime, Description__c = description,
								 Converted_Visit_Type__c = convertedVisitType,
								 Do_Not_Send_To_Premier__c = doNotSendToPremier,
								 Mode__c = mode, RecordTypeId = recordTypeId,
								 Resource_Type__c = resourceType, 
								 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
								 Status_Reason__c = statusReason, Status__c = status,
								 Time_Band__c = timeBand, Type__c = typeC,
								 Visit_Type__c = visitType, Opportunity__c = opportunity,
								 Who__c = who);
								 
			Database.insert(app);
			
			String err;
			
			try{
				 
				 Database.delete(opp);
				 
			   } catch (Exception excp) {
			   	
                      err = 'Test successfull';
                      System.debug('Insert did not happen succesfully due to an error.');
                      
 		       }
 		       
		  System.assertEquals( 'Test successfull', err );	
		  
		  err = '';
		  
			try{
				 
				 Database.delete(contact);
				 
			   } catch (Exception excp) {
			   	
                      err = 'Test successfull';
                      System.debug('Insert did not happen succesfully due to an error.');
                      
 		       }
 		       
		  System.assertEquals( 'Test successfull', err );	
		  
  }

}