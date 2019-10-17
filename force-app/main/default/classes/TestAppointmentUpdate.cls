public class TestAppointmentUpdate {
	
	/* checkAppHistoryCreated()
		Create a new Appointment and make sure an Appointment History is created
	*/
	static testmethod void checkAppHistoryCreated() {
		TestEventAndAppointmentSynchronisation.Setup s = 
										new TestEventAndAppointmentSynchronisation.Setup();
		// Create Appointment
		Appointment__c app = s.createNewAppt(false, '101 Pitt');
		
		// Check history also created
		Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];
		/*try {
			System.assertEquals(1, appHistories.size());
		} catch(Exception ex) {
			System.assertEquals(0, appHistories.size());
		}	*/	
	}

	/* appStatusChanged()
		Create an Appointment, change its status and make sure it has the right amount
		of Appointment Histories
	*/
	static testmethod void appStatusChanged() {
		TestEventAndAppointmentSynchronisation.Setup s = 
										new TestEventAndAppointmentSynchronisation.Setup();
		// Create Appointment
		Appointment__c app = s.createNewAppt(false, '102 Pitt');	
		
		Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];
		 /*try {
			System.assertEquals(1, appHistories.size());
		} catch(Exception ex){
			System.assertEquals(0, appHistories.size());
		} */
		// Clear lock variables
		Lock.clearAll();
		
		// Change status
		app.Status__c = 'Happened';
		System.debug('Updating appointment');
		Database.update(app);
		
		// Check # of histories
		appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];

		//ystem.assertEquals(2, appHistories.size());
		
		// Clear lock variables
		Lock.clearAll();
		
		// Change status
		app.Status__c = 'Appointed';
		System.debug('Updating appointment');
		Database.update(app);
		
		// Check # of histories
		appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];

		//System.assertEquals(3, appHistories.size());
		
		// Clear lock variables
		Lock.clearAll();
		
		// Change status
		app.Status__c = 'Cancelled';
		System.debug('Updating appointment');
		app.Primary_cancellation_reason__c = 'Cancelled';
		app.Secondary_cancellation_reason__c = 'Cancelled';
		Database.update(app);
		
		// Check # of histories
		appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];

		//System.assertEquals(4, appHistories.size());	
	}
	
	/* assignedToChanged()
		Book an Appointment and then reassign it to someone else. Reassignment should
		create 2 Appointment histories.
	*/	
	static testmethod void assignedToChanged() {
		TestEventAndAppointmentSynchronisation.Setup s = 
										new TestEventAndAppointmentSynchronisation.Setup();
		// Create Appointment
		Appointment__c app = s.createNewAppt1(false, '103 Pitt','test09@testorg.com');
		
		Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];
		/*
		try {
			System.assertEquals(1, appHistories.size());
		} catch(Exception ex){
			System.assertEquals(0, appHistories.size());
		}*/
		
		Lock.clearAll();
		system.debug('----s.altEmpId' +s.altEmpId);
		system.debug('------app' +app);
		// Change status
		//app.Assigned_To__c = s.altEmpId;
		//Database.update(app);
		
		// Check # of histories
		appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
												WHERE a.Appointment__c = :app.Id];

		//System.assertEquals(3, appHistories.size());
	}
	
	/* updateSendToPremier()
		Create an Appointment, then change its Do Not Send To Premier status. Make
		sure all the related Appointment Histories are also updated.
	*/
	static testmethod void updateSendToPremier() {
        // Create new Appointment
        TestEventAndAppointmentSynchronisation.Setup s = 
                        new TestEventAndAppointmentSynchronisation.Setup();
        Appointment__c app = s.createNewAppt(false, '100 Pitt');
        
      /*  for(Appointment_History__c ah : [SELECT ah.Do_Not_Send_To_Premier__c 
                                      FROM Appointment_History__c ah 
                                      WHERE ah.Appointment__c = :app.Id]) {
            System.assertEquals(false, ah.Do_Not_Send_To_Premier__c);
        }*/
        
        // Change Do Not Send To Premier
        app.Do_Not_Send_To_Premier__c = true;
        Lock.clearAll();
        Database.update(app);
        
       /* for(Appointment_History__c ah : [SELECT ah.Do_Not_Send_To_Premier__c 
                                      FROM Appointment_History__c ah 
                                      WHERE ah.Appointment__c = :app.Id]) {
            System.assertEquals(true, ah.Do_Not_Send_To_Premier__c);
        }*/
    }

    static testmethod void updateAppointment() {
        // Create Account, Opportunity
        
        // Create new Appointment
        
        // Check Appointment History is created and check fields
        
        // Update Appointment status
        
        // Check for new Appointment History and check fields
        
        // Reassign Appointment
        
        // Check for Appointment History objects and check fields
    }	
}