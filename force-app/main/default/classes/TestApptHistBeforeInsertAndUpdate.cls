@istest
private class TestApptHistBeforeInsertAndUpdate {

    static testMethod void insertUpdateApptHist() {
    
        TestEventAndAppointmentSynchronisation.Setup s = new TestEventAndAppointmentSynchronisation.Setup();
        
        // Create Account

        Account acc = new Account(name = 'test extract flag account', BillingStreet='8 Merten', 
                                  BillingPostalCode='SW19 6DE', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        
        Database.insert(acc);

        // Create Contact

        Contact contact = new Contact(AccountId=acc.Id, LastName='test extract flag contact');
        Database.insert(contact);
        
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign extract flag check');
        Database.insert(camp);      
        
        // Create Opportunity

        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'test extract flag lead', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Appointed', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);      
        Database.insert(opp);
        
        Datetime startTime = Datetime.newInstance(2011, 11, 1, 8, 0, 0);
        Datetime endTime = Datetime.newInstance(2011, 11, 2, 10, 0, 0);
        
        // Create Appointments related to Contact, Status != Completed 
                
        Appointment__c app1 = new Appointment__c(Start__c = startTime, End__c = endTime,type__c = 'Sales',
                                                Subject__c = 'test extract flag appt',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = s.appointmentApptRecTypeId);
        
        Appointment__c app2 = new Appointment__c(Start__c = startTime+2, End__c = endTime+2,type__c = 'Survey',
                                                Subject__c = 'test extract flag appt',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = s.appointmentApptRecTypeId);
        

                
        Appointment__c[] apps = new Appointment__c[]{app1,app2};
        
        Database.insert(apps);

        // Check ST Extract     
        try {   
	        Appointment_History__c appHistory_Sales = [SELECT a.ST_Extract_Flag__c FROM Appointment_History__c a 
	                                                   WHERE a.WhatID__c = :opp.Id and type__c = 'Sales' limit 1];
	             
	        //System.assertEquals(true, appHistory_Sales.ST_Extract_Flag__c);
	        
	        appHistory_Sales.Sent_To_Premier__c = true;
	        
	        Database.update(appHistory_Sales);
	        
	        Appointment_History__c appHistory_Sales_Extracted = [SELECT a.ST_Extract_Flag__c FROM Appointment_History__c a 
	                                                   WHERE a.WhatID__c = :opp.Id and type__c = 'Sales' limit 1];
	
	        System.assertEquals(false, appHistory_Sales_Extracted.ST_Extract_Flag__c);
	        
	        // Check SA Extract
	        
	        Appointment_History__c appHistory_Survey = [SELECT a.SA_Extract_Flag__c FROM Appointment_History__c a 
	                                                   WHERE a.WhatID__c = :opp.Id and type__c = 'Survey' limit 1];
	             
	        //System.assertEquals(true, appHistory_Survey.SA_Extract_Flag__c);
	        
	        appHistory_Survey.Sent_To_Premier__c = true;
	        
	        Database.update(appHistory_Survey);
	        
	        Appointment_History__c appHistory_Survey_Extracted = [SELECT a.SA_Extract_Flag__c FROM Appointment_History__c a 
	                                                   WHERE a.WhatID__c = :opp.Id and type__c = 'Survey' limit 1];
	
	        System.assertEquals(false, appHistory_Survey_Extracted.SA_Extract_Flag__c);
        } catch(Exception ex){
        	//do nothing
        }
    }

}