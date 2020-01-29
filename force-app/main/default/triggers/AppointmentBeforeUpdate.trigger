/* AppointmentBeforeUpdate Trigger
    
    This trigger does a number of things before an Appointment is
    updated. Notably it does the following (in this order):
        - populates a couple of fields on the Appointment object
        with a String representation of the time that is used
        in Workflow to populate TA Notes;
        - Sets the relevant offer text on an Appointment;
        - Populates the Previous Appointment History field for
        TA Notes.
        
    Most of the work is done in methods in the PreviousAppointmentHistory
    class
*/

trigger AppointmentBeforeUpdate on Appointment__c (before update) {
    
    if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_AppointmentBeforeUpdate)
    {
    	return;
    }
    
    System.debug('Entered AppointmentBeforeUpdate');
    
    PreviousAppointmentHistory pah = new PreviousAppointmentHistory();
    // Populate the fields on the Appointment that hold String representations
    // of the time of the appointment
    pah.populateTimes(Trigger.new);
    
    set<id> apptIds = new set<Id>();
    map<id,Appointment__c> apptMap = new map<id,appointment__c>();
    for(Appointment__c newApp : Trigger.new)
    { 
        Appointment__c oldApp = Trigger.oldMap.get(newApp.Id);
        if(newApp.Status__c=='Happened'&& (newApp.Status__c != oldApp.Status__c))
        apptIds.add(newApp.id);
    }
    if(!apptIds.isEmpty())
    {
       for(Appointment__c appt: [select id,Opportunity__r.account.Sales_Subpatch__r.District__r.NPS_Virtuatell_Trial__c from appointment__c where id=:apptIds])
       {
           apptMap.put(appt.id,appt);
       }
    }
    
    for(Appointment__c newApp : Trigger.new) {
        
        Appointment__c oldApp = Trigger.oldMap.get(newApp.Id);
        
        if(newApp.NPS_Notification_Sent_Date__c==null && newApp.Status__c=='Happened'&& (newApp.Status__c != oldApp.Status__c)&&apptMap.containskey(newApp.id)
           &&apptMap.get(newApp.id).Opportunity__r.account.Sales_Subpatch__r.District__r.NPS_Virtuatell_Trial__c==true)
        {
            newApp.NPS_Notification_Status__c ='Ready to be Sent';
        }
        
        //Populate the Time to free the slot when an appointment is reserved.
        if(oldApp.Status__c != 'Reserved' && newApp.Status__c == 'Reserved' )
    	{
    		newApp.Online_Freeing_time__c = System.now().addMinutes(integer.valueof(system.label.OnlineFreeMins));
    	}
        // Fix for seven days diaries - starts
        
        if(newApp.Visit_Date__c >= System.today() && (newApp.Type__c == 'Sales' || newApp.Type__c == 'Green Deal' || newApp.Type__c == Utilities.nonOpCategory) && newApp.RecordTypeId == Utilities.appRTID && newApp.Opportunity__c != null) {
              
             newApp.Visit_Day_Of_Year__c = newApp.Visit_Date__c.dayOfYear();
            
         }   
        
        // ++ Added for HSA Profile change start
        if((system.label.HSA_Appointment_Switch == 'on') && (newApp.Type__c == 'Sales') && (newApp.RecordTypeId == Utilities.appRTID) && ((newApp.HSA_Primary_Cancellation_Reason__c != null && (newApp.HSA_Primary_Cancellation_Reason__c != oldApp.HSA_Primary_Cancellation_Reason__c)) || (newApp.HSA_Secondary_Cancellation_Reason__c != null && (newApp.HSA_Secondary_Cancellation_Reason__c != oldApp.HSA_Secondary_Cancellation_Reason__c))))
        {
        	newApp.Primary_Cancellation_Reason__c = newApp.HSA_Primary_Cancellation_Reason__c;
        	newApp.Secondary_Cancellation_Reason__c = newApp.HSA_Secondary_Cancellation_Reason__c;
        }
        
        // -- Added for HSA Profile change end
        
        // ++ Added for Non operational tye change start
        if((newApp.Type__c == Utilities.nonOpCategory) && (newApp.Status__c == 'Appointed') && (newApp.Status__c != oldApp.Status__c))
        {
        	newApp.Type__c = 'Sales';
        }
        // -- Added for Non operational tye change end
        
        // Fix for seven days diaries - ends

        // CR MC012
        // If the Appointment has been reassigned, we store the value of the Reassignment 
        // Override checkbox in a static map. We also need to check if it's already in
        // the map or not (as we don't want this running again after Workflow updates and
        // overwriting the original value       
        if(newApp.Assigned_To__c != oldApp.Assigned_To__c) {
            if(!Lock.reassigned.containsKey(newApp.Id))
                Lock.reassigned.put(newApp.Id, newApp.Reassignment_Override__c);
        }
        // Set the checkbox back to false
        newApp.Reassignment_Override__c = false;
        // End CR MC013
                
        // If this is: 
        //      a. an Appointment without Offer already set and
        //      b(i). a booked Appointment, or 
        //      b(ii). an Appointment with a value in Opportunity
        // set the offer text (used as part of TA Notes).
        //
        // Logic is: a AND (b(i) or b(ii)
        //
        // b(ii). was put in due to the fact that Workflow updates an "Availability" Appointment
        // to an "Appointment" Appointment if an Appointment is Availability but has a value
        // in the Opportunity field - if we have that situation, the workflow will update
        // the type of Appointment from Available to Appointment.
        /*        
        if(newApp.Offer__c == null && (newApp.RecordTypeId == Utilities.appRTID ||
            (newApp.RecordTypeId == Utilities.avRTID && newApp.Opportunity__c != null))) {
            System.debug('Setting Offer description');  
            newApp.Offer__c = Utilities.getOfferDescription(Datetime.now());
        } */  
    }   
    
    // Populate the previous Appointment History field.
    pah.updatePreviousAppointmentHistory(Trigger.new);
    System.debug('Exiting AppointmentBeforeUpdate');
}