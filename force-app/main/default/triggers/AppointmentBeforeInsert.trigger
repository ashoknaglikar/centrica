/* AppointmentBeforeInsert Trigger
    
    This trigger does a number of things before an Appointment is
    inserted. Notably it does the following (in this order):
        - populates a couple of fields on the Appointment object
        with a String representation of the time that is used
        in Workflow to populate TA Notes;
        - populates the Time Band field;
        - Sets the relevant offer text on an Appointment;
        - Populates the Previous Appointment History field for
        TA Notes.
        
    Most of the work is done in methods in the PreviousAppointmentHistory
    class
*/
trigger AppointmentBeforeInsert on Appointment__c (before insert,before update) {
    
    if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_AppointmentBeforeInsert)
    {
    	return;
    }
    System.debug('Entered AppointmentBeforeInsert');
    list<Id> chiLeadIdlst = new list<Id>();
    list<Appointment__c> old_Apps = new list<Appointment__c>();
    PreviousAppointmentHistory pah = new PreviousAppointmentHistory();
    list<Id> appidlst = new list<Id>();
    if(trigger.isinsert)
    { 
	    // Populate the fields on the Appointment that hold String representations
	    // of the time of the appointment
	    pah.populateTimes(Trigger.new);
    }
    
    
    for(Appointment__c newApp : Trigger.new) {
        
        if(trigger.isinsert)
        {
	        // Set the Time Band, initially to AM, then see if the start time
	        // meets criteria for each subsequent time band. At the end, we
	        // check to see for an all day appointment.
	        if(newApp.Time_Band__c==null && newApp.Type__c == 'Sales')
	        {
    	        newApp.Time_Band__c = 'AM';
    	
    	        // CR For Diary Start & End Time Changes
    	        if(newApp.Start__c.hour() >= 13)
    	            newApp.Time_Band__c = 'PM';     
    	        if(newApp.Start__c.hour() >= 17)
    	            newApp.Time_Band__c = 'EV';
    	        
    	        if(newApp.Start__c.hour() >= 7 && newApp.End__c.hour() == 21)
    	            newApp.Time_Band__c = 'AT';
	        }     
	        
	        // If the record type indicated this is a booked Appointment being inserted, 
	        // or if it is availability with an Opportunity value (i.e. Workflow will 
	        // change the record type to Appointment), set the offer text on the Appointment 
	        /*if(newApp.RecordTypeId == Utilities.appRTID ||
	            (newApp.RecordTypeId == Utilities.avRTID && newApp.Opportunity__c != null)) {
	            System.debug('Setting Offer description');
	            newApp.Offer__c = Utilities.getOfferDescription(Datetime.now());
	        }*/
        }
        if(((trigger.isinsert && newApp.Opportunity__c != null) ||(trigger.isupdate && trigger.oldmap.get(newApp.Id).Opportunity__c == null && newApp.Opportunity__c != null))&& !Lock.abitrg)
        {
        	chiLeadIdlst.add(newApp.Opportunity__c);
        	if(trigger.isupdate)
        	{
        		appidlst.add(newApp.Id);
        	}
        }
        
    }
	
	if(trigger.isinsert)
	{
	    // Populate the previous Appointment History field.
	    pah.populatePreviousAppointmentHistory(Trigger.new);
	    System.debug('Exiting AppointmentBeforeInsert...........');
	}
	
	if(chiLeadIdlst.size()>0 && !Lock.abitrg)
	{
		old_Apps = [Select Id, OldAppt__c from Appointment__c where Opportunity__c in:chiLeadIdlst and OldAppt__c = false and id not in :appidlst];
		
		if(old_Apps.size()>0)
		{
			for(Appointment__c a: old_Apps)
			{
				a.OldAppt__c = true; 
			}
			update old_Apps;
			Lock.setabitrg();
			
		}
	}
}