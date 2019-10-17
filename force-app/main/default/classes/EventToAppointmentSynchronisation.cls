public class EventToAppointmentSynchronisation {

    // Map holding any Appointments that are being modified
    private Map<ID, Appointment__c> appts = new Map<ID, Appointment__c>();

    // Map holding any Events that are being modified
    private Map<ID, Event> evts = new Map<ID, Event>();
    
    // One of the field mappings is Appointment.Assigned_to__c = Event.OwnerID
    // Assigned_To should be an employee ID, OwnerID should be a user ID. These
    // maps are used to help us work out the values and save on SOQL queries if possible
    private Map<ID, ID> eventOwnerIDsToCheck = new Map<ID, ID>();  // EventID, OwnerID
    
    // Another Map, this stores any new Events created if an Appointment changes
    // from type Installation (i.e. there is no associated Event) to another type
    // (which should have an Event).
    private Map<Id, Event> newEvents = new Map<Id, Event>();
    
    // We need the ID prefixes of Lead and Opportunity objects, so get describe info...     
    private Schema.DescribeSObjectResult dsrLead = Lead.SObjectType.getDescribe();
    private Schema.DescribeSObjectResult dsrOpp = Opportunity.SObjectType.getDescribe();
    private Schema.DescribeSObjectResult dsrJob = Job__c.SObjectType.getDescribe();    //Added by Cognizant for phase 4
     private Schema.DescribeSObjectResult dsrCase = Case.SObjectType.getDescribe();    //Added by Cognizant for Phase 5
 private Schema.DescribeSObjectResult dsrJobEle = Job_Element__c.SObjectType.getDescribe();    //Added by Cognizant for Phase 5

    // ... and store the prefixes as Strings
    String leadPrefix = dsrLead.getKeyPrefix();
    String opportunityPrefix = dsrOpp.getKeyPrefix();
    String jobPrefix = dsrJob.getKeyPrefix();                            //Added by Cognizant for phase 4
    String casePrefix = dsrCase.getKeyPrefix();                //Added by Cognizant for phase 5
    String jobElePrefix = dsrJobEle.getKeyPrefix();
            /* checkEventOwners()
            
    */
    private void checkEventOwners() {
        System.debug('Entered checkEventOwners');
        // Create a Map for the Employee instances we're interested in 
        Map<ID, Employee__c> employees = new Map<ID, Employee__c>();
        
        // Select all Employees related to the Events where we need to look up
        // information for the associated Appointment object. 
        for(Employee__c employee : 
            [SELECT e.Salesforce_User__c FROM Employee__c e WHERE e.Salesforce_User__c in :eventOwnerIDsToCheck.values()]) {
            employees.put(employee.Salesforce_User__c, employee);
        }

        // Now for each Event we need to assign the relevant Employee Id to the 
        // Appointment associated with the Event
        for(ID eventID : eventOwnerIDsToCheck.keySet()) {
            // We need to get the relevant appointment...
            Appointment__c apptToUpdate = appts.get(eventID);
            // and event...
            Event event = null;
            if(evts.containsKey(eventID)) {
                System.debug('checkEventOwners: found in evts');
                event = evts.get(eventID);
            } else if(newEvents.containsKey(eventID)) {
                System.debug('checkEventOwners: found in newEvents');
                event = newEvents.get(eventID);
            }

            if(event != null && employees.containsKey(event.OwnerID)) {
                System.debug('checkEventOwners: event not null and employee found');
                apptToUpdate.Assigned_To__c = employees.get(event.OwnerID).Id;
            } else {
                event.addError('Couldn\'t reassign Event to user, please contact your administrator');
                appts.remove(eventID);
            }   
        }   
        System.debug('Exiting checkEventOwners...');
    }
        
    /* insertEvent()
        
        Called when a new Event is inserted by the user.
        
        A new Appointment object is created and populated with the details from the
        inserted Event. If the Event has a WhoId that corresponds to a lead or a
        WhatID that does not correspond to an Opportunity, no Appointment is 
        created.
        
        Because Appointments and Events have fields that map to the relevant 
        Event/Appointment object, we need to create the Appointments so that they
        are assigned an object ID and then store these object IDs on the relevant
        Event.
    */
    
    public void insertEvent() {
        System.debug('Entered insertEvent');
        
        // Loop over new Event objects and store in a map
        for(sObject e : Trigger.new) {
            // Need to create an Event (rather than sObject) - this is because
            // we want some fields from the object and we can't cast when
            // accessing the fields 
            Event temp = (Event) e;
                        
            // If the new Event has a WhoID that corresponds to a Lead, 
            // do not create an Appointment
            String whoId = temp.WhoId;
                
            if(whoId != null && whoId.startsWith(leadPrefix)) {
                System.debug('insertEvent: Event WhoID is a lead, skipping appointment creation');
                continue;
            }

            // If the new Event has a WhatID that is not equal to an Opportunity,Job or Quote
            // do not create an Appointment
            // Job  is added by cognizant for Phase 4.
            String whatId = temp.WhatId;
            if(whatId != null && !(whatId.startsWith(jobElePrefix) || whatId.startsWith(opportunityPrefix) || whatId.startsWith(jobPrefix)|| whatId.startsWith(casePrefix) ) ) {
                System.debug('insertEvent: Event WhatID is not an Opportunity,Case or Job, skipping appointment creation: ' + whatId);  
                continue;
            }

            
            evts.put(e.Id, (Event) e);
            
            // Create Appointment object and add to appts for insertion
            Appointment__c a = copyDetails((Event) e, new Appointment__c(EventID__c = e.Id));
            appts.put(a.EventID__c, a);
        }
    
        // Are there any Event OwnerIDs that we need to check? 
        // (as we're inserting, there should be)
        if(!eventOwnerIDsToCheck.isEmpty())
            checkEventOwners();
        
        // Insert Appointment objects
        DatabaseOperations.databaseInsert(evts, appts);
        
        if(evts.size() > 0) {
            Event[] evtsUpdate = new Event[]{};
    
            for(Event e : [SELECT e.id, e.AppointmentId__c FROM Event e 
                                WHERE e.Id IN :evts.KeySet()]) {
                if(appts.containsKey(e.Id)) {   
                    e.AppointmentId__c = appts.get(e.Id).Id;
                    evtsUpdate.add(e);
                }
            }
            
            try {
                if(evtsUpdate.size() > 0) { 
                    System.debug('insertEvent: updating Events');
                    Database.SaveResult[] updateResults = Database.update(evtsUpdate);
                    for(Database.SaveResult result : updateResults) {
                        if(!result.isSuccess()) {
                            System.debug('insertEvent: Unsuccessful Event update');
                            // Get the problem Event and add error
                            Event ev = evts.get(result.getId());
                            ev.addError('Error setting AppointmentID of Event');
                        }
                    }
                }
            } catch (Exception exc) {
                for(Event ev: evts.values()) {
                    ev.addError('Error setting AppointmentID of Event, '
                    + 'an exception was thrown');
                    System.debug('insertEvent: Exception thrown trying to update Events: ' + exc);
                }
            }
        }
        
        System.debug('Exiting insertEvent...');     
    }
    
    /* deleteEvent()
    
        Called when an Event is deleted by the user. Creates a list of
        Appointment IDs to be deleted and deletes them from the Database
    
    */
    public void deleteEvent() {
        System.debug('Entered deleteEvent');
        
        // Loop over the deleted Events and put them in a Map (using
        // their corresponding Appointment ID as the key) and also
        // put the corresponding Appointment ID in a list, which we'll 
        // use to delete the Appointments from the Database
        Map<ID, ID> apptsToDelete = new Map<ID, ID>();
        for(sObject ev : Trigger.old) {
            // Need to explicitly convert from sObject...
            Event oldEvent = (Event) ev;
            //evts.put(oldEvent.AppointmentId__c, (Event) ev);
            evts.put(oldEvent.Id, (Event) ev);
            if(oldEvent.AppointmentId__c != null)
                apptsToDelete.put(oldEvent.AppointmentId__c, oldEvent.Id);
        }
        
        // Delete Appointments
        DatabaseOperations.databaseDelete(evts, apptsToDelete);

        System.debug('Exiting deleteEvent');
    }

    /* updateEvent()
        
        Called when a user updates Events.
    
    */
    public void updateEvent() {
        System.debug('Entered updateEvent');

        // Put all the Events in a Map
        for(sObject ev : Trigger.new) {
            evts.put(ev.Id, (Event) ev);
        }
        
        // Retrieve the Appointments corresponding to the updated Events
        for(Appointment__c app : [SELECT a.EventID__c FROM Appointment__c a WHERE 
                        a.EventID__c IN :evts.KeySet()]) {
            // For each Appointment, call the copy details method
            appts.put(app.EventId__c, copyDetails(evts.get(app.EventID__c), app));      
        }
        
        // Are there any Event OwnerIDs that we need to check? 
        if(!eventOwnerIDsToCheck.isEmpty())
            checkEventOwners();
        
        // Update Appointments associated with the updated Events - first
        // check that there are Appointments to update!
        
        DatabaseOperations.databaseUpdate(evts, appts);
        
        System.debug('updateEvent: Exiting...');    
    }
    
    public Appointment__c copyDetails(Event oFrom, Appointment__c oTo) {
        oTo.Converted_Visit_Type__c =   oFrom.Converted_Visit_Type__c;
        oTo.Description__c          =   oFrom.Description;
        oTo.Do_Not_Send_To_Premier__c   =   oFrom.Do_Not_Send_To_Premier__c;
        //oTo.End__c                    =   oFrom.EndDateTime;
        oTo.Mode__c                 =   oFrom.Mode__c;
        oTo.Overbooked__c           =   oFrom.Overbooked__c;
        oTo.Duration__c              =   ofrom.DurationInMinutes;//Added by Cognizant to populate the subject in the Appointment

        if(!Trigger.isInsert) {         
            Event oldEvent = (Event) Trigger.oldMap.get(oFrom.Id);
    
            // CHECK FOR NULLS?
            if(oldEvent.OwnerId != oFrom.OwnerId) {
                System.debug('copyDetails: Event OwnerId has changed');
                // Add to the list/map
                eventOwnerIDsToCheck.put(oFrom.Id, oFrom.OwnerId);
            }
            
            if(oldEvent.RecordTypeId != oFrom.RecordTypeId) {
                System.debug('copyDetails: Event RecordTypeId has changed');
                Utilities.setup();
                String newRecordTypeId = null;
                String newRecordTypeName = Utilities.recordTypes.get(oFrom.RecordTypeId).Name;
                for(RecordType rt : Utilities.recordTypes.values()) {
                    if(rt.sObjectType=='Appointment__c' && rt.Name==newRecordTypeName){
                        // We want the id of this object
                        System.Debug('copyDetails: Found RecordTypeID for Appointment__c: ' + rt.Id);
                        newRecordTypeId = rt.Id;
                        break;
                    }
                }
                if(newRecordTypeId == null)
                    System.debug('copyDetails: Didn\'t find RecordTypeId for Appointment');             
                oTo.RecordTypeId        =   newRecordTypeId;
            }
        } else {
            if(oFrom.OwnerID!=null) {
                System.debug('copyDetails: new Event, will check user is employee, ' +
                            'Event.OwnerID is: ' + oFrom.OwnerID);
                eventOwnerIDsToCheck.put(oFrom.Id, oFrom.OwnerID);
            }
            oTo.End__c                  =   oFrom.EndDateTime;
            oTo.Start__c                =   oFrom.StartDateTime;
            oTo.Any_Time__c             =   oFrom.Any_Time__c;
            oTo.Time_Band__c            =   oFrom.Time_Band__c;
                        
            System.debug('copyDetails: Looking up Event RecordTypeId');
            Utilities.setup();
            String newRecordTypeId = null;
            String newRecordTypeName = Utilities.recordTypes.get(oFrom.RecordTypeId).Name;
            for(RecordType rt : Utilities.recordTypes.values()) {
                if(rt.sObjectType=='Appointment__c' && rt.Name==newRecordTypeName){
                    // We want the id of this object
                    System.Debug('copyDetails: Found RecordTypeID for Appointment__c: ' + rt.Id);
                    newRecordTypeId = rt.Id;
                }
            }
            if(newRecordTypeId == null)
                System.debug('copyDetails: Didn\'t find RecordTypeId for Appointment');
            oTo.RecordTypeId        =   newRecordTypeId;
        }   
        
        
        oTo.Resource_Type__c        =   oFrom.Resource_Type__c;
        oTo.Sale_Flag__c            =   oFrom.Sale_Flag__c;
        if(oFrom.ShowAs=='OutOfOffice')
            oTo.Show_Time_As__c     =   'Out Of Office';
        else
            oTo.Show_Time_As__c     =   oFrom.ShowAs;
        oTo.Specific_Date_Requested__c = oFrom.Specific_Date_Requested__c;
        //oTo.Start__c              =   oFrom.StartDateTime;
        oTo.Status_Reason__c        =   oFrom.Status_Reason__c;
        oTo.Status__c               =   oFrom.Status__c;
        oTo.Type__c                 =   oFrom.Type__c;
        oTo.Visit_Type__c           =   oFrom.Visit_Type__c;
        //Added by Cognizant to populate the What id in the Appointment
        String prefixId=oFrom.WhatId;
        if (prefixId.startsWith(opportunityPrefix)) {
            oTo.Opportunity__c      =   oFrom.WhatId;
        } else if (prefixId.startsWith(jobPrefix)) {
            oTo.Job__c=oFrom.WhatId;
        }  else if (prefixId.startsWith(casePrefix)) {
            oTo.Case__c=oFrom.WhatId;
        }else if(prefixId.startsWith(jobElePrefix)) {
            oTo.Job_Element__c=oFrom.WhatId;
        }
                  oTo.Call_Notes__c=oFrom.Call_Notes__c;
        
       oTo.Communication_Status__c = oFrom.Communication_Status__c;    // Added by Cognizant for Phase 5
        oTo.Unavailability_Reason__c = oFrom.Unavailability_Reason__c; //Added by Cognizant for Phase 4 CR.
        oTo.Who__c                  =   oFrom.WhoId;
        oTo.Subject__c              =   oFrom.Subject;//Added by Cognizant to populate the subject in the Appointment
       oTo.Skill__c              =   oFrom.Skill__c;//Added by Cognizant to populate the subject in the Appointment

        // Do not use
        //oTo.Postcode_Sector__c        =   oFrom.Postcode_Sector__c;
        
        return oTo;
    }   
}