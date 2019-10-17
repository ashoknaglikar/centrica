/* PreviousAppointmentHistory()

    A class to help populate fields on Appointment objects used in
    TA Notes.

*/

public class PreviousAppointmentHistory {

    /* buildString(String, Appointment__c)
    
        Builds the String used in the Previous Appointment History group of
        TA Notes.
    */
    private String buildString(String buildMe, Appointment__c app) {
        // Start with Appointment Date, Employee Name and Phone Number. None
        // of these should be null...
        buildMe += 'Appointment Date: ' + app.Start__c.format() + ', ' + 
                    'Employee Init Name: ' + app.Assigned_To__r.Name + ', ' + 
                    'Employee Mobile: ' + app.Assigned_To__r.Phone_No__c + ', ';

        // We need to check for null values to avoid NullPointerExceptions
        // Add previous Appointment's Call Notes
        if(app.Call_Notes__c != null)
            buildMe += 'Prev Visit Detail: ' + app.Call_Notes__c; 
        else
            buildMe += 'Prev Visit Detail: ';
        buildMe += ', ';
        
        // Add previous Appointment's Status Reason
        if(app.Status_Reason__c != null)
            buildMe += 'Status Reason: ' + app.Status_Reason__c;
        else
            buildMe += 'Status Reason: ';
        buildMe += ',';
        
        return buildMe;
    }
    
    /* populateTimes(Appointment__c[])
    
        Populates the Start_Time__c and End_Time__c fields with String
        representations of the Start and End time of an Appointment.
        This allows Workflow to populate the TA Notes fields rather than
        Apex code (at the time of writing, Workflow had trouble working
        with Datetime objects). 
            
    */
    public void populateTimes(Appointment__c[] apps) {
        for(Appointment__c app : apps) {
            //if(!app.OFS_Appointment__c && ! app.PushToOFS__c)
            {
            // If the hour or minutes are less than 10, we need to pad with an extra
            // zero at the start
            
            // CR For Diary Start & End Time Changes Starts
            if(app!=null && app.Start__c !=null )
            {
            if(app.Start__c.hour() < 10 )//&& app.Start__c.minute() < 30)
                app.Start_Time__c = '0' + app.Start__c.hour().format() + ':'+(app.Start__c.minute()>9?app.Start__c.minute().format():'0'+app.Start__c.minute().format());
            else if(app.Start__c.hour() < 10)// && app.Start__c.minute() == 30)
                app.Start_Time__c = '0' + app.Start__c.hour().format() + ':'+(app.Start__c.minute()>9?app.Start__c.minute().format():'0'+app.Start__c.minute().format());
           
            if(app.Start__c.hour() >= 10 )//&& app.Start__c.minute() < 30)
                app.Start_Time__c = app.Start__c.hour().format() + ':'+(app.Start__c.minute()>9?app.Start__c.minute().format():'0'+app.Start__c.minute().format());
            else if(app.Start__c.hour() >= 10)// && app.Start__c.minute() == 30)
                app.Start_Time__c = app.Start__c.hour().format() + ':'+(app.Start__c.minute()>9?app.Start__c.minute().format():'0'+app.Start__c.minute().format());
            
                
            // And the same for the End time
            // added for phase 5
            }
            if(app.End__c==null)
            app.End__c = app.Start__c;
            if(app!=null && app.End__c !=null )
            {
                
                if(app.End__c.hour() < 10)// && app.End__c.minute() < 30)
                    app.End_Time__c = '0' + app.End__c.hour().format() + ':'+(app.End__c.minute()>9?app.End__c.minute().format():'0'+app.End__c.minute().format());
                else if(app.End__c.hour() < 10)// && app.End__c.minute() == 30)
                    app.End_Time__c = '0' + app.End__c.hour().format() + ':'+(app.End__c.minute()>9?app.End__c.minute().format():'0'+app.End__c.minute().format());
               
                if(app.End__c.hour() >= 10)// && app.End__c.minute() < 30)
                    app.End_Time__c = app.End__c.hour().format() + ':'+(app.End__c.minute()>9?app.End__c.minute().format():'0'+app.End__c.minute().format());
                else if(app.End__c.hour() >= 10)// && app.End__c.minute() == 30)
                    app.End_Time__c = app.End__c.hour().format() + ':'+(app.End__c.minute()>9?app.End__c.minute().format():'0'+app.End__c.minute().format());
                
            // CR For Diary Start & End Time Changes Ends
            }
            }
        }
    }
    
    /* updatePreviousAppointmentHistory(Appointment__c[])
        
        If Appointments are being updated, this method checks if any are becoming
        booked Appointments - if there are any, they are passed on to the 
        populatePreviousAppointmentHistory method to have their 
        PreviousAppointmentHistory methods populated.
        
    */
    public void updatePreviousAppointmentHistory(Appointment__c[] triggerAppointments) {

        if(Lock.populatedPAH)
            return;
                    
        // A list for Appointments that are being changed from non-Appointment to Appointment
        List<Appointment__c> newlyBookedApps = new List<Appointment__c>{}; 
        String appRTID = Utilities.getRecordTypeId('Appointment', 'Appointment__c');
            
        // Loop over the Appointments and see if any of them are now of Appointment Record
        // Type (and previously weren't) - if they are, add them to the list we created above
        for(Appointment__c newApp : triggerAppointments) {
            Appointment__c oldApp = (Appointment__c) Trigger.oldMap.get(newApp.Id);
            // Are any of these Appointments being booked?
            if(newApp.RecordTypeId == appRTID && oldApp.RecordTypeId != appRTID) {
                System.debug('Newly booked appointment');
                newlyBookedApps.add(newApp);
            }
            
        }
                
        // If there are newly booked Appointments, call populatePreviousAppointmentHistory
        // to populate the relevant field for TA Notes.
        if(!newlyBookedApps.isEmpty()) {
            populatePreviousAppointmentHistory(newlyBookedApps);
            Lock.populatedPAH = true;
        }
        
    }
    
    /* populatePreviousAppointmentHistory(Appointment__c[])
        
        Populates the Previous Appointment History field on an Appointment. This
        looks up an Opportunity, retrieves Appointments attached to that Opportunity
        and gets the details of the last Happened appointment on the Opportunity
        for the Previous Appointment History field used in TA notes.
        
    */
    public void populatePreviousAppointmentHistory(Appointment__c[] triggerAppointments) {
        
        // We store Appointments in a Map of lists, indexed by their Opportunity ID. We use
        // a list because we may be inserting/updating more than one Appointment on an
        // Opportunity.
        Map<ID, List<Appointment__c>> newAppointmentsByOppId = new Map<ID, List<Appointment__c>>();
        
        // Collect the new Appointments into a Map so they are organised by Opportunity ID
        for(Appointment__c newApp : triggerAppointments) {
            
            // If there is no Opportunity populated, do not add to the Map: as there's no
            // Opportunity, there won't be any related Appointments, therefore no Previous
            // Appointment History can be built.
            if(newApp.Opportunity__c != null) {
                
                System.debug('Opportunity ID found');
            
                // If we're adding an Appointment to the Map, we need to check if there have
                // already been other Appointments linked to the same Opportunity in the same
                // insert/update. If one has already been encountered, we need to add it to
                // the list associated with the Opportunity ID.
                if(newAppointmentsByOppId.containsKey(newApp.Opportunity__c)) {
                    System.debug('Entry found in newAppointmentsByOppId, will update list');
                    List<Appointment__c> tempList = newAppointmentsByOppId.get(newApp.Opportunity__c);
                    
                    // Because more than one Appointment may be added in one insert/update, we store 
                    // the Appointments in the list in ascending start date order

                    // First of all, find where the newApp needs to placed as an Integer. We loop over
                    // all Appointments currently in the list and increment a counter whenever the 
                    // Appointment we are currently on has a start date greater than the current 
                    // Appointment in the list we are comparing it to.
                    Integer place = 0;
                    for(Integer i = 0; i < tempList.size() ; i++) {
                        Appointment__c currentApp = tempList[i];
                        if(newApp.Start__c > currentApp.Start__c)
                            place++;
                    }
                    
                    // The "place" variable now has the position in the list where the new Appointment 
                    // needs to be placed. 
                    
                    // Now we create a new List
                    List<Appointment__c> newList = new List<Appointment__c>{};
                    
                    // Now add the Appointments before the newApp to the new list  
                    for(Integer i = 0; i < place; i++) {
                        newList.add(tempList[i]);
                    }
                    // Add the new newApp
                    newList.add(newApp);
                    // Now add the remaining apps to the list
                    for(Integer i = place; i < tempList.size(); i++) {
                        newList.add(tempList[i]);
                    } 
                    // Now add the list back to the map
                    newAppointmentsByOppId.put(newApp.Opportunity__c, newList);
                } else {
                    // Opportunity not previously found, add to the map and create new list
                    System.debug('Entry not found in newAppointmentsByOppId, will create list');
                    newAppointmentsByOppId.put(newApp.Opportunity__c, new List<Appointment__c>{newApp});
                }
            }
            System.debug('SHOULD CHNAGE THE RECODCTYPE : '+newApp);
        }
        
        // If there aren't any Appointments, we can return now as we don't need to do anything
        if(newAppointmentsByOppId.keySet().isEmpty())
            return;
        
        
        // CR MC011
        // We need to check if this Appointment is being booked via Call Centre Booking (CCB) as
        // when Appointments are booked this way, if an Appointment is being rebooked, the new
        // Appointment is booked before the old Appointment is cancelled. Therefore, Call Centre
        // Booking can not book a new Appointment as there is already an existing active 
        // Appointment.
        //
        // Instead, we use a static variable - in the CCB screens, the user is only able to book
        // an Appointment if there are no more than 1 active appointments, as that Appointment 
        // will be cancelled. Before booking the new Appointment, a static variable is set to
        // instruct the logic here that the check does not need to happen and that the Appointment
        // should not be prevented from being booked as the currently booked Appointment will
        // be cancelled after this Appointment is booked. 
        System.debug('Will not call CCB thus time '+Lock.callCentreBooking); 
        if(!Lock.callCentreBooking) {
            
            Appointment__c[] rApps = [SELECT a.Id, a.Type__c, a.Status__c, a.Opportunity__c 
                                            FROM Appointment__c a 
                                            WHERE a.Opportunity__c IN :newAppointmentsByOppId.keySet()
                                            AND a.Start__c >= :Datetime.now()
                                            AND (a.Type__c = 'Sales' OR a.Type__c = 'Green Deal')
                                            AND a.Status__c = 'Appointed'];
                                            
            for(Appointment__c rApp : rApps) {
                // If there are Appointments in rApps, there are active Sales appointments
                // for some inserted/updated Appointments. Therefore we need to get those
                // Appointments and report an error.
                
                List<Appointment__c> appList = newAppointmentsByOppId.get(rApp.Opportunity__c);
                if(appList != null)
                {
                	for(Appointment__c app : appList) {
                    if((app.Type__c == 'Sales' || app.Type__c == 'Green Deal') && (app.Type__c == rApp.Type__c)) {
                        System.debug('addError: Previous sales appointment found');
                        app.addError('The CHI Lead for this Appointment already has 1 or more active ' + app.Type__c + 
                                     ' Appointments booked. Please cancel those Appointments before booking ' +
                                     'a new one');
                    	}
                	}
                
                }
                newAppointmentsByOppId.remove(rApp.Opportunity__c);
            }
        }
        // End CR MC011
        
        
        // Pull all of the Appointments related to the Opportunities that "own" the Appointments we are
        // inserting/updating. We are only interested in appointments with Status of Happened. We order
        // by start date so that we can get the last Appointment against an Opportunity 
        Appointment__c[] relatedApps = [SELECT a.Id, a.Start__c,  a.Assigned_To__r.Phone_No__c, 
                                                a.Assigned_To__r.Name, a.Opportunity__c, 
                                                a.Call_Notes__c, a.Status_Reason__c
                                        FROM Appointment__c a 
                                        WHERE a.Opportunity__c IN :newAppointmentsByOppId.keySet() 
                                        AND a.Status__c = 'Happened' 
                                        ORDER BY a.Start__c];
                                        
        System.debug('relatedApps.size(): ' + relatedApps.size());
        
        // If we have results returned, we process the Appointments, adding them to a Map of 
        // List of Appointments, indexed by their Opportunity IDs - for the same reasons as above!
        if(!relatedApps.isEmpty()) {
            Map<ID, List<Appointment__c>> relatedAppointmentsByOppId = new Map<ID, List<Appointment__c>>();
            
            for(Appointment__c app : relatedApps) {
                // Check if we have already encountered an Appointment with the same Opportunity
                
                if(relatedAppointmentsByOppId.containsKey(app.Opportunity__c)) {
                    System.debug('Entry found in relatedAppointmentsByOppId, will update list');
                    
                    // Because these Appointments were retrieved from the Database with a Sort By
                    // in the query, we don't need to work out where they go - each Appointment
                    // we add will be later than the last one
                    List<Appointment__c> tempList = relatedAppointmentsByOppId.get(app.Opportunity__c);
                    tempList.add(app);
                    relatedAppointmentsByOppId.put(app.Opportunity__c, tempList);
                } else {
                    System.debug('Entry not found in relatedAppointmentsByOppId, will create list');            
                    relatedAppointmentsByOppId.put(app.Opportunity__c, new List<Appointment__c>{app});
                }
            }
        
            for(Appointment__c newApp : triggerAppointments) {
                // Loop over each new Appointment and work out what Appointment to use for its
                // Previous Appointment History. We need to consider Appointments that are already
                // in the database (prevApps) as well as other Appointmets that are being inserted
                // at the same time (otherNewApps)
                List<Appointment__c> prevApps = relatedAppointmentsByOppId.get(newApp.Opportunity__c);
                List<Appointment__c> otherNewApps = newAppointmentsByOppId.get(newApp.Opportunity__c);
                System.debug('Current PAA :  '+otherNewApps);
                System.debug('Previous PAA :  '+prevApps);
                
                if(prevApps != null) {
                    // If there were results returned from the database, get the latest Appointment
                    Appointment__c lastPrevApp = prevApps.get(prevApps.size()-1);
                    
                    if(otherNewApps != null) {
                        // If there are other Appointments being inserted against this opportunity,
                        // loop over them; if they are of status Happened and occur after the latest
                        // previous happened Appointment that we've found, we should use the current 
                        // one instead 
                        for(Appointment__c app : otherNewApps) {
                            if(app.Status__c == 'Happened' && app.Start__c > lastPrevApp.Start__c) {
                                System.debug('Inserting/Updating an Appointment with Status of Happened that' + 
                                            ' is more recent than the last Happened Appointment from the Database');
                                lastPrevApp = app;
                            }
                        }
                    }
                    
                    // Now we know which Appointment to use for the Previous Appointment History, call the 
                    // build string method to build the string for the Previous Appointment History field
                    String pah = buildString('', lastPrevApp);
                    
                    // Now set the field.
                    System.debug('Previous Appointment History being set to: ' + pah);
                    newApp.Previous_Appointment_History__c = pah;
                }   
            }
        }
        System.debug('===populateTANotesGroup4===='+newAppointmentsByOppId);
        populateTANotesGroup4(newAppointmentsByOppId);
        Lock.populatedPAH = true;
    }
    
    /* populateTANotesGroup4(Map<ID, List<Appointment__c>>)
        
        Populates the TA_Notes_Group_4 field on an Appointment linked with an Opportunity. We 
        are passed in the Appointments being inserted/updated in a Map indexed by
        Opportunity Id.
    */
    private void populateTANotesGroup4(Map<ID, List<Appointment__c>> newAppointmentsByOppId) {
        
        // Select the Opportunities from the database
        Opportunity[] relatedOpps = [SELECT o.Referral_Employee__r.Phone_No__c, o.Referral_Employee__r.Group__c, 
                                            o.Referral_Employee__r.Last_Name__c, o.Referral_Employee__r.First_Name__c, 
                                            o.Referral_Employee__c, o.Current_Boiler__r.Model__c, 
                                            o.Referral_Employee__r.Source__c, 
                                            o.Current_Boiler__r.Manufacturer__c, o.Campaign.Type, 
                                            o.CampaignId, o.Campaign.Name, o.LeadSource  
                                            FROM Opportunity o
                                            WHERE o.Id IN :newAppointmentsByOppId.keySet()];
                                            
        System.debug('relatedOpps.size(): ' + relatedOpps.size());
        
        // If there are no related Opportunites, return.
        if(relatedOpps.isEmpty())
            return;
        
        // If related Opportunities were returned, store them in a Map, indexed by their ID
        Map<Id, Opportunity> relatedOppsById = new Map<Id, Opportunity>(); 
        
        for(Opportunity opp : relatedOpps) {
            relatedOppsById.put(opp.Id, opp);
        }
        
        // Loop over the Appointments
        for(List<Appointment__c> appList : newAppointmentsByOppId.values()) {
            for(Appointment__c app : appList) {
                // For each Appointment, build a String, representing the Opportunity
                // information needed in TA Notes Group 4. There is logic related to 
                // what information is put in
                Opportunity opp = relatedOppsById.get(app.Opportunity__c);
                
                // Boiler information needed always
                app.Boiler_Manufacturer__c = opp.Current_Boiler__r.Manufacturer__c;
                app.Boiler_Model__c = opp.Current_Boiler__r.Model__c;
                
                String group4 = '<';
                
                // If Lead source != MARCOMMS, put Employee Group code in
                if(opp.LeadSource != 'MARCOMMS' && opp.Referral_Employee__r.Source__c != 'PL' && opp.Referral_Employee__r.Group__c!=null) {
                    System.debug('LeadSource != MARCOMMS and Referral_Employee__r.Source__c != PL');
                    group4 += opp.Referral_Employee__r.Group__c + ' ';
                }
                
                // If LeadSource was Engineer and his Group == ENGI, put employees name and phone number in
                if((opp.LeadSource == 'Engineer' && opp.Referral_Employee__r.Group__c=='ENGI') || opp.LeadSource == 'Other Employee') {
                    System.debug('LeadSource == Engineer && Employee == ENGI');
                    group4 += opp.Referral_Employee__r.First_Name__c + ' ' + 
                            + opp.Referral_Employee__r.Last_Name__c + ' ' ;
                if(opp.Referral_Employee__r.Phone_No__c != null)     
                           group4= group4+ opp.Referral_Employee__r.Phone_No__c + ' ';
                }
                
                // If the employee group is TFIE, put employees name and phone number in
               // This is the newly added condition as per the request from buisness
               
                if(opp.Referral_Employee__r.Group__c == 'TFIE') {
                    
                    System.debug('TA Notes Group4 for Employee Group == TFIE');
                    
                    if(opp.Referral_Employee__r.Phone_No__c != null){
                        
                    group4 += 'BG Energy Doorsales Name: ' + opp.Referral_Employee__r.First_Name__c + ' ' + 
                            + opp.Referral_Employee__r.Last_Name__c + ' ' +
                            + opp.Referral_Employee__r.Phone_No__c + ' ';
                            
                    }else{
                        
                        group4 += 'BG Energy Doorsales Name: ' + opp.Referral_Employee__r.First_Name__c + ' ' + 
                            + opp.Referral_Employee__r.Last_Name__c + ' ';
                        
                    }
                    
                }
                
                // If LeadSource != MARCOMMS and Referral Employee's Source code == PL, put
                // the Employee's group code in.
                // NOTE: In the original requirement, the information was supposed to be "Location",
                // however, no such field exists. Group was used as per client's request.
                if(opp.LeadSource != 'MARCOMMS' && opp.Referral_Employee__r.Source__c == 'PL') {
                    System.debug('LeadSource != MARCOMMS and Referral_Employee__r.Source__c == PL');
                    group4 += opp.Referral_Employee__r.Group__c + ' ';
                }
                
                // If LeadSource == MARCOMMS, put in the Campaign Type.
                if(opp.LeadSource == 'MARCOMMS') {
                    group4 += opp.Campaign.Type + ' ';
                }
                // Finally, close off the group with a chevron
                app.TA_Notes_Group_4__c = group4 + '>';
            }
        }       
    }
}