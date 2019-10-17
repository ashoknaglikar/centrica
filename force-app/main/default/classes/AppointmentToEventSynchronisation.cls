/* AppointmentToEventSynchronisation class

    A class that contains logic and controls creation, updating and
    deletion of any Events that are affected by inserts, updates
    or deletions of Appointment objects.

    Essentially this class is used to keep the details between Appointment 
    and corresponding Event objects in synch when Appointment objects
    are operated on.
    
    In most cases, users operate on Appointment objects rather than
    Event objects - hence the logic in this class (and the trigger that
    calls the methods within) are more involved than the corresponding
    EventToAppointmentSynchronisation class.
    
*/

public class AppointmentToEventSynchronisation {
    
    id loggedinUser = userinfo.getuserid();
    
    // Map holding any Appointments that are being modified
    private Map<ID, Appointment__c> appts = new Map<ID, Appointment__c>();

    // Map holding any Events that are being modified
    private Map<ID, Event> evts = new Map<ID, Event>();
    
    // One of the field mappings is Appointment.Assigned_to__c = Event.OwnerID
    // Assigned_To should be an employee ID, OwnerID should be a user ID. These
    // maps are used to help us work out the values and save on SOQL queries if possible
    private Map<ID, ID> apptsOwnerIDsToCheck = new Map<ID, ID>();  // ApptID, OwnerID
    private List<ID> extraUsers = new List<ID>();
    
    // Another Map, this stores any new Events created if an Appointment changes
    // from type Installation (i.e. there is no associated Event) to another type
    // (which should have an Event), or vice versa.
    private static Map<Id, Event> newEvents = new Map<Id, Event>();
    private static Map<ID, ID> oldEvents = new Map<ID, ID>();
    
    // Another Map which holds Appointments where the value of the Do Not Send To
    // Premier field has changed.
    private Map<ID, Appointment__c> sendToPremierChanged = new Map<ID, Appointment__c>();

    // Another Map - this stores Appointment Histories that need to be inserted...
    private Map<String, List<Appointment_History__c>> appHistories = 
            new Map<String, List<Appointment_History__c>>();

    // ... and another map to hold any Appointment Histories that need to be updated
    private List<Appointment_History__c> appHistoriesToUpdate = 
            new List<Appointment_History__c>();
/* Added by Cognizant for Phase 4 
 Start
*/
     // We need the ID prefixes of Job and Opportunity objects, so get describe info...     
    private Schema.DescribeSObjectResult dsrOpp = Opportunity.SObjectType.getDescribe();
    private Schema.DescribeSObjectResult dsrJob = Job__c.SObjectType.getDescribe();
    private Schema.DescribeSObjectResult dsrcase = Case.SObjectType.getDescribe(); //Added by cognizant for Phase 5
    private Schema.DescribeSObjectResult dsrJobEle = Job_Element__c.SObjectType.getDescribe();// Phase 5 addded
    
    // ... and store the prefixes as Strings
    String opportunityPrefix = dsrOpp.getKeyPrefix();
    String jobPrefix = dsrJob.getKeyPrefix();
    String jobElePrefix = dsrJobEle.getKeyPrefix(); // Added for Phase 5
    String casePrefix = dsrcase.getKeyPrefix(); //Added by cognizant for Phase 5
    String InstID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Installation'); // Added by cognizant for Phase 4
    String CustExpID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Customer Experience Case Event'); // Added by cognizant for Phase 4
    
/* End */
    
    // A map holding the values for the History Type field on Appointment Histories.
    // This indicates why the Appointment History was created.
    private static final Map<Integer, String> historyTypes = 
                new Map<Integer, String> {0 => '',
                                          1 => 'Appointment Reassignment',
                                          2 => 'Contact Update',
                                          3 => 'Lead Stage Updated',
                                          4 => 'Premier Appointment Cancellation',
                                          5 => 'Appointment Created',
                                          6 => 'Appointment Status Changed'};

    /* createAppointmentHistroy(Appointment__c)
    
        Method that takes an Appointment object and creates an Appointment History object for it.
    
    */

    private Appointment_History__c createAppointmentHistory(Appointment__c app) {
        Appointment_History__c newHistory = new Appointment_History__c(
                            Any_Time__c = app.Any_Time__c,
                            Appointment__c = app.Id,
                            Assigned_To__c = app.Assigned_To__c,
                            Converted_Visit_Type__c = app.Converted_Visit_Type__c,
                            Not_Created_By_Dataloader__c = Lock.userIsNotDataloader,
                            Do_Not_Send_To_Premier__c = app.Do_Not_Send_To_Premier__c, 
                            End__c = app.End__c,
                            Mode__c = app.Mode__c,
                            Notes__c = app.Notes__c,
                            Overbooked__c = app.Overbooked__c,
                            Resource_Type__c = app.Resource_Type__c,
                            Sale_Flag__c = app.Sale_Flag__c,
                            Show_Time_As__c = app.Show_Time_As__c,
                            Siebel_Created_Date__c = app.Siebel_Created_Date__c,
                            Specific_Date_Requested__c = app.Specific_Date_Requested__c,
                            Start__c = app.Start__c,
                            Status_Reason__c = app.Status_Reason__c,
                            Status__c = app.Status__c,
                            Subject__c = app.Subject__c,
                            Time_Band__c = app.Time_Band__c,
                            Type__c = app.Type__c,
                            Visit_Type__c = app.Visit_Type__c,
                            WhatID__c = app.Opportunity__c,
                            WhoId__c = app.Who__c
                            );
                    
        //need to use Trigget.oldMap to find the old Assigned To value. This is needed
        //to send a text message to the old employee when they have an appointment
        //reassigned to inform them it has been cancelled
        if(system.trigger.isUpdate){                
            system.debug('Entering Phase 2 Change');
            Appointment__c oldApp = (Appointment__c) trigger.oldMap.get(app.Id);                                         
            if(oldApp.Assigned_To__c!=null){
                newHistory.Previous_Assigned_To__c = oldApp.Assigned_To__c;
                system.debug('oldApp.Assigned_To__c is '+oldApp.Assigned_To__c);
            }
            if(oldApp.EmployeeTextMailAddress__c!=null){
                system.debug('oldApp.EmployeeTextMailAddress__c is '+oldApp.EmployeeTextMailAddress__c);        
                newHistory.Previous_Assigned_To_Textmail__c = oldApp.EmployeeTextMailAddress__c;
            }
        }        
        return newHistory;
    }
    
    /* copyAppointmentHistory(Appointment_History__c, Appointment_History__c)
    
        Copies one Appointment History object to another. Both Appointment Histories
        are passed into the method - the values of the first are copied to the second 
        and then the second is returned.
    
    */
    
    private Appointment_History__c copyAppointmentHistory(Appointment_History__c oFrom, Appointment_History__c oTo) {
        oTo.Any_Time__c = oFrom.Any_Time__c;
        oTo.Assigned_To__c = oFrom.Assigned_To__c;
        oTo.Converted_Visit_Type__c = oFrom.Converted_Visit_Type__c;
        oTo.Not_Created_By_Dataloader__c = oFrom.Not_Created_By_Dataloader__c;
        oTo.Do_Not_Send_To_Premier__c = oFrom.Do_Not_Send_To_Premier__c;
        oTo.End__c = oFrom.End__c;
        oTo.Mode__c = oFrom.Mode__c;
        oTo.Notes__c = oFrom.Notes__c;
        oTo.Overbooked__c = oFrom.Overbooked__c;
        oTo.Resource_Type__c = oFrom.Resource_Type__c;
        oTo.Sale_Flag__c = oFrom.Sale_Flag__c;
        oTo.Show_Time_As__c = oFrom.Show_Time_As__c;
        oTo.Siebel_Created_Date__c = oFrom.Siebel_Created_Date__c;
        oTo.Specific_Date_Requested__c = oFrom.Specific_Date_Requested__c;
        oTo.Start__c = oFrom.Start__c;
        oTo.Status_Reason__c = oFrom.Status_Reason__c;
        oTo.Status__c = oFrom.Status__c;
        oTo.Subject__c = oFrom.Subject__c;
        oTo.Time_Band__c = oFrom.Time_Band__c;
        oTo.Type__c = oFrom.Type__c;
        oTo.Visit_Type__c = oFrom.Visit_Type__c;
        oTo.WhatID__c = oFrom.WhatID__c;
        oTo.WhoId__c = oFrom.WhoId__c;
       
        return oTo;
    }

    // A map to hold any Employee objects we retrieve from the Database 
    public static Map<ID, Employee__c> employees = new Map<ID, Employee__c>();
    
    /* addAppointmentHistory(Appointment__c, Integer)
    
        A method that is called when an Appointment History needs to be created.
        
        Appointment Histories act as an audit trail of the changes made to an
        Appointment. They are also used to send details to the Premier system.
        A "reason" for creating the Appointment History is also part of the
        Appointment History object to indicate why the object was created 
        (see historyTypes Map above).
        
        It is slightly more complicated than just creating an Appointment
        History - for one operation on one Appointment, there can be multiple
        Appointment Histories, but there should not be more than one of the
        same "historyType".
        
        For example, when reassigning an object, an
        Appointment History with the history type of "Premier Appointment
        Cancellation" is created as well as an Appointment History of 
        "Appointment Reassignment". However, there should not be two 
        Appointment Histories with, for example, a history type of "Contact
        Update". Because of this, and because Workflow can cause triggers to
        fire more than once, there is logic to make sure we only get, at 
        most, one of an Appointment History history type. 
        
    */
    private void addAppointmentHistory(Appointment__c app, Integer reason) {
        
        // We only need to create Appointment Histories for Appointment of
        // type Appointment (i.e. booked Appointments). If this Appointment
        // passed in is NOT a booked Appointment, return.
        if(app.RecordTypeId != Utilities.appRTID || system.label.OFS_Integration_User.contains(loggedinUser)){ //app.OFS_Appointment__c) {
            System.debug('Appointment not an Appointment type, returning...');
            return;
        }
            
        // If status has changed, create new Appointment History
        Appointment_History__c appHistory = createAppointmentHistory(app);
        // We also need to set the History Type on the Appointment History. This
        // is determined by the Integer passed in to the metho
        String historyType = historyTypes.get(reason);
        if(reason > 0)
            appHistory.History_Type__c = historyTypes.get(reason);

        // Due to the interactions between Apex code and Workflow, we need to make sure we only
        // create one Appointment History per History Type. For example, if Appointment Histories
        // are created because an Opportunity is updated, we only want one Appointment History, but
        // if the Appointment is updated by Workflow, potentially we get two Appointment Histories.
            
        // To solve this, we keep a static map in the Lock class which we add Appointment Histories
        // to. When updating an Appointment in a way that creates an Appointment History, there
        // should never be two Appointment Histories with the same value in History Type.
            
        // When we are creating an Appointment History, we check if one already exists for the
        // same Appointment with the same History Type value; if one does exist, we update that 
        // one rather than create a new one. Otherwise, we create a new one and add it to the list 

        // Please note however that it can be valid to have more than one Appointment History when
        // updating an Appointment. For example, reassigning an Appointment create two Appointment
        // Histories - however, they have different History Type values, so this is allowed.
        
        if(Lock.appHistories.containsKey(app.Id)) {
            System.debug('Lock.appHistories contains Key');
            
            // The static Map contains some Appointment Histories for this Appointment. We
            // need to see if any of the existing ones have the same History Type value.            
            
            // Lock.appHistories is a Map of Lists, indexed by Appointment IDs. Therefore,
            // we need to get the List associated with the ID of the Appointment passed in 
            List<Appointment_History__c> tempAppHistoryList = Lock.appHistories.get(app.Id);
            
            Integer i = 0;
            Boolean found = false;
            
            // We now need to loop over the Appointment Histories in the List and check
            // if any of them have the same History Type
            for(Appointment_History__c ah : tempAppHistoryList) {
                if(ah.History_Type__c == historyType) {
                    // An Appointment History has already been created for the same reason,
                    // therefore we copy the new values over the old ones.
                    found = true;
                    System.debug('Found Appointment History with matching History Type');
                    
                    // Remove the matching Appointment History from the list (we'll replace
                    // it with the new Appointment History later).
                    tempAppHistoryList.remove(i);
                    
                    // We check if the Appointment History (already in the list) has an ID 
                    // - this tells us if the object is already in the database (and therefore
                    // we should update the object rather than insert it), or if we need to
                    // insert it (i.e. the Appointment History has no ID.
                    if(ah.Id != null) {
                        System.debug('Appointment History has Id, will update');
                        ah = copyAppointmentHistory(appHistory, ah);
                        System.debug('Copied Appointment History: ' + ah);
                        appHistoriesToUpdate.add(ah);
                        tempAppHistoryList.add(ah);
                    } else {
                        System.debug('Appointment History didn\'t have Id, will insert: ' + ah);
                        
                        // Check if there are already Appointment Histories related to this
                        // Appointment that we are inserting - if so, we need to add it to
                        // the list associated with the Appointment. If not, create a new one.
                        if(appHistories.containsKey(app.Id)) {
                            System.debug('appHistories.containsKey() is true');
                            List<Appointment_History__c> ahList = appHistories.get(app.Id);
                            ahList.add(appHistory); 
                            appHistories.put(app.Id, ahList);
                        } else {
                            System.debug('appHistories.containsKey() is false');
                            appHistories.put(app.Id, new Appointment_History__c[]{appHistory});
                        }
                        System.debug('Adding appHistory to tempAppHistoryList, this is also the Appointment ' +
                                     'History to be inserted: ' + appHistory);
                        tempAppHistoryList.add(appHistory);
                    }
                    // Store the List in the static Map Lock variable
                    Lock.appHistories.put(app.Id, tempAppHistoryList);
                    break;
                }
                i++;
            }
            
            if(!found) {
                // If we have been over each of the Appointment Histories in the static map for
                // this Appointment and not found an existing Appointment History object with
                // the same value in the History Type field, we'll need to create a new
                // entry for this Appointment History               
                System.debug('Matching Appointment History not found, adding appHistory: ' + appHistory);
                tempAppHistoryList.add(appHistory);

                // We also need to work out whether to insert of update this Appointment History.
                // Check if apptHistories contains Appointment Histories for this Appointment 
                // already; if it does, we need to add it to the associated list, otherwise, 
                // create a new one.
                if(appHistories.containsKey(app.Id)) {
                    System.debug('apptHistories.containsKey is true');
                    appHistories.put(app.Id, tempAppHistoryList);
                    //Lock.appHistories.put(app.Id, tempAppHistoryList);
                } else {
                    System.debug('apptHistories.containsKey is false');
                    appHistories.put(app.Id, new Appointment_History__c[]{appHistory});
                    //Lock.appHistories.put(app.Id, new Appointment_History__c[]{appHistory});
                }
                // Add tempAppHistoryList back into the static Map for future checking
                Lock.appHistories.put(app.Id, tempAppHistoryList);
            }           
        } else {
            // This Appointment has no Appointment Histories in the static Map, therefore
            // we need to create a new entry in the Map, as well as adding the Appointment
            // History to the Map of Appointment Histories to be inserted into the database
            System.debug('Lock.appHistories.containsKey is false, adding appHistory: ' + appHistory);
            appHistories.put(app.Id, new Appointment_History__c[]{appHistory});
            Lock.appHistories.put(app.Id, new Appointment_History__c[]{appHistory});                            
        }
    }
    
    /* checkApptOwners()
    
        Check that the Employee given in the Assigned To field on an Appointment has
        an associated Salesforce User ID to assigned to the OwnerID field on the
        Event object associated with the Appointment.
    
    */
    private void checkApptOwners() {
        System.debug('Entered checkApptOwners');
        
        List<ID> idsToLookFor = apptsOwnerIDsToCheck.values();
        idsToLookFor.addAll(extraUsers);
        
        System.debug('Looking for: ' + idsToLookFor);
        
        for(Employee__c employee : [SELECT e.Id, e.Salesforce_User__c, e.Salesforce_User__r.Sales_District__c,
                                    e.Salesforce_User__r.Survey_District__c, e.First_Name__c, e.Last_Name__c
                                    FROM Employee__c e WHERE e.Id in :idsToLookFor]) {
            System.debug('employee.Id: ' + employee.Id + ' employee: ' + employee);
            employees.put(employee.Id, employee);
        }
        
        // CR MC012
        // We maintain a Set that contains the IDs of any Appointments that are being reassigned,
        // and therefore we need to check that the employee the Appointment is being assigned to
        // covers the district.
        Set<Id> checkMove = new Set<Id>();
        // End CR MC012
        
        for(ID apptID : apptsOwnerIDsToCheck.keySet()) {
            // We need to get the relevant event...
            Event eventToUpdate = evts.get(apptID);
            // and appointment...
            Appointment__c appointment = appts.get(apptID);
            // and employee id for the user
            if(appointment != null && employees.containsKey(appointment.Assigned_To__c)) {
                if(eventToUpdate != null) {
                    System.debug('checkApptOwners: appointment not null and employee found');
                    System.debug('checkApptOwners: employees.get(appointment.Assigned_To__c).Id; is: ' + 
                                    employees.get(appointment.Assigned_To__c).Id);
                    if(employees.get(appointment.Assigned_To__c).Salesforce_User__c!=null)
                    eventToUpdate.OwnerID = employees.get(appointment.Assigned_To__c).Salesforce_User__c;
                }
                
                // CR MC012
                // If an Appointment has been reassigned (stored in the static variable) and the Reassignment
                // Override checkbox has not been checked, we need to check the reassignment. Therefore
                // we add the Appointment's ID to the Set.
                if(Lock.reassigned.containsKey(apptID) && !Lock.reassigned.get(apptID) && 
                    (appointment.Type__c =='Sales' || appointment.Type__c =='Survey')) {
                    System.debug('Adding ID');
                    checkMove.add(apptID);
                }
                // End CR MC012
            } else {
                System.debug('addError: Could not reassign Appointment, no valid user?');
                appointment.addError('Couldn\'t reassign Appointment to user, please contact your administrator');
                evts.remove(apptID);
                appHistories.remove(apptID);
                sendToPremierChanged.remove(apptID);
            }   
        }
        
        // CR MC012
        // If checkMove is not empty, we have Appointments that are being reassigned and we need to check
        // that the employee the Appointment is being assigned to covers the district.
        if(!checkMove.isEmpty()) {
            System.debug('checkmove is not empty');
            
            // Get the Appointments with the fields that we need - we need to use a SOQL query as there
            // is information we need from the Appointments relationships that we do not get from Trigger.new
            Appointment__c[] apps = [SELECT a.Opportunity__r.Account.Sales_Subpatch__r.District__r.Code__c, 
                                            a.Assigned_To__c, a.Type__c, a.Reassignment_Override__c,OFS_Appointment__c
                                     FROM Appointment__c a WHERE a.Id IN :checkMove];
                                     
            System.debug('checkMove apps.size(): ' + apps.size());
            
            // A Map to hold an Appointments against their ID
            Map<ID, Appointment__c> appDistricts = new Map<ID, Appointment__c>();
            
            for(Appointment__c app : apps) {
                appDistricts.put(app.Id, app);
            }
            
            // Loop over each of the Appointments passed to checkApptOwners and check that the
            // new employee covers the district
            for(ID apptID : apptsOwnerIDsToCheck.keySet()) {
                Appointment__c app = appDistricts.get(apptID);
                Employee__c emp = employees.get(app.Assigned_To__c);
                
                // Check that the Appointment's District Code is not null and the user has either Sales
                // or Survey Districts assigned to them
                if(app.Opportunity__r.Account.Sales_Subpatch__r.District__r.Code__c != null && !system.label.OFS_Integration_User.contains( loggedinUser) && //!app.OFS_Appointment__c  && 
                    (emp.Salesforce_User__r.Sales_District__c != null || 
                     emp.Salesforce_User__r.Survey_District__c != null)) {

                    // Get the Appointment's District 
                    String appDistrict = app.Opportunity__r.Account.Sales_Subpatch__r.District__r.Code__c;
                    // If Appointment is of type Survey, swap the HT for an SU
                    if(app.Type__c == 'Survey') {
                        appDistrict = 'SU' + appDistrict.subString(2, appDistrict.length());
                    }
                    
                    // Get the Employee's districts - we need to avoid putting any "nulls" into
                    // the string, we also need to cope with employees who have both sales and 
                    // survey districts
                    String empDistrict = null;
                    /*
                    if(emp.Salesforce_User__r.Sales_District__c != null)
                        empDistrict = emp.Salesforce_User__r.Sales_District__c;
                    if(empDistrict != null && emp.Salesforce_User__r.Survey_District__c != null)
                        empDistrict += ';' + emp.Salesforce_User__r.Survey_District__c;
                    else if(emp.Salesforce_User__r.Survey_District__c != null)
                        empDistrict = emp.Salesforce_User__r.Survey_District__c;

                    // We add all the Employee's districts into a Set - if the Employee has more
                    // than one district, we split them up by the semi-colons
                    Set<String> employeeDistricts = new Set<String>();
                    if(empDistrict != null && empDistrict.contains(';')) {
                        employeeDistricts.addAll(empDistrict.split(';', 0));
                    } else {
                        employeeDistricts.add(empDistrict);
                    }
                    
                    System.debug('appDistrict: ' + appDistrict);
                    System.debug('empDistrict: ' + empDistrict);
                    */
                    /*
                    // Now check if the employee covers the district
                    if(!employeeDistricts.contains(appDistrict) ) {
                        // If the employee does not cover the district, report an error
                        Appointment__c errorApp = appts.get(apptID);
                        System.debug('addError: Could not reassign Appointment, out of district error');
                        errorApp.addError('You are trying to reassign an Appointment but it appears either that ' + 
                                emp.First_Name__c + ' ' + emp.Last_Name__c + ' does not cover this Appointment\'s District, ' +
                                'or does not attend ' + app.Type__c + ' Appointments. ' +
                                'If you are sure you want to reassign the Appointment, please check the "Reassignment Override" ' +
                                'checkbox, or contact support.');

                        // We also need to remove some other objects
                        evts.remove(apptID);
                        appHistories.remove(apptID);
                        sendToPremierChanged.remove(apptID);                        
                    }*/
                }
            }
        }       
        // End CR MC012
        
        System.debug('Exiting checkApptOwners');
    }
    

    
    /* insertAppointment()
        
        Called when a new Appointment is inserted by the user.
        
        A new Event object is created and populated with the details from the
        inserted Appointment.
        
        Because Appointments and Events have fields that map to the relevant 
        Event/Appointment object, we need to create the Events so that they
        are assigned an object ID and then store these object IDs on the relevant
        Appointment.
    */
    
    public void insertAppointment() {
        System.debug('Entered insertAppointment');
        
        // Loop over new Appointment objects and store in a map
        System.debug('insertAppointment: Trigger.new.size()' + Trigger.new.size());
        
        for(sObject a : Trigger.new) {
            // Need to create an Appointment (rather than sObject) - this is
            // because we want some fields from the object and we can't cast
            // when accessing the fields
            Appointment__c app = (Appointment__c) a;
            
            // If the Appointment is of type Installation, we don't need a
            // corresponding Event, so we don't need to put it into the map
        String InstID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Installation'); // Added by cognizant for Phase 4
           if(app.Type__c=='Installation' && app.RecordtypeId !=InstID) {                   // Added by cognizant for Phase 4
                System.debug('insertAppointment: Appointment is an Installation,' +
                            ' won\'t create an Event');
                continue;
            }
            
            appts.put(a.Id, (Appointment__c) a);
            // Create Event object(s) and add to evts
            Event e = copyDetails((Appointment__c) a, new Event(AppointmentID__c = a.Id));
            evts.put(e.AppointmentID__c, e);
        }
        
        System.debug('insertAppointment: appts.size(): ' + appts.size());
        
        // Are there any Appointment Assigned_Tos that we need to check? 
        // (as we're inserting, there should be)        
        if(!apptsOwnerIDsToCheck.isEmpty())
            checkApptOwners();
        
        // Insert Event objects     
        DatabaseOperations.databaseInsert(appts, evts);
    
        // Now that the Events are inserted and have IDs, insert these IDs into
        // the relevant Appointment objects

        Map<ID, Appointment__c> apptsUpdate = new Map<ID, Appointment__c>();

        for(Appointment__c a : [SELECT a.id, a.EventId__c, a.Do_Not_Send_To_Premier__c, a.Start__c
                                FROM Appointment__c a 
                                WHERE a.Id IN :appts.KeySet()]) {
            System.debug('in loop, Do_Not_Send_To_Premier__c: ' + a.Do_Not_Send_To_Premier__c);
            if(evts.containsKey(a.Id)) {
                a.EventId__c = evts.get(a.Id).Id;
                apptsUpdate.put(a.Id, a);
            }
        }
        
        try {
            if(apptsUpdate.size() > 0) {    
                System.debug('insertAppointment: updating Appointments');
                Database.SaveResult[] updateResults = Database.update(apptsUpdate.values());
                System.debug('will come here after update ... ');
                for(Database.SaveResult result : updateResults) {
                    if(!result.isSuccess()) {
                        System.debug('addError: Unsuccessful Appointment update');
                        // Get the problem Appointment__c and add error
                        Appointment__c app = appts.get(result.getId());
                        app.addError('Error setting EventID of Appointment');
                    } else {
                        // Else: create an Appointment History
                        System.debug('insertAppointment: creating Appointment History');
                        Appointment__c app = appts.get(result.getId());
                        System.debug('----SUCESSS --------- '+app);
                        addAppointmentHistory(app, 5);
                    }
                }
                
                DatabaseOperations.insertAppointmentHistories(appHistories, apptsUpdate);
            }
        } catch (Exception exc) {
            for(Appointment__c app : appts.values()) {
                System.debug('addError: Exception thrown trying to update Appointments: ' + exc);
                app.addError('Error setting EventID of Appointment, '
                + 'an exception was thrown');
            }
        }
        
        System.debug('Exiting insertAppointment...');
    }
    
    /* deleteAppointment()
    
        Called when an Appointment is deleted by the user. Creates a list of
        Event IDs to be deleted and deletes them from the Database
    
    */
    public void deleteAppointment() {
        System.debug('Entered deleteAppointment');
        
        // Loop over the deleted Appointments and put them in a Map
        // (using their corresponding Event ID as the key) and also
        // put the corresponding Event ID in a list, which we'll 
        // use to delete the Eventts from the Database
        Map<ID, ID> eventsToDelete = new Map<ID, ID>();
        for(sObject a : Trigger.old) {
            Appointment__c oldApp = (Appointment__c) a;
            //appts.put(oldApp.EventId__c, (Appointment__c) a);
            appts.put(oldApp.Id, (Appointment__c) a);
            if(oldApp.EventId__c != null)
                eventsToDelete.put(oldApp.EventId__c, oldApp.Id);
        }
        
        // Delete Events - check first there are some to delete!
        DatabaseOperations.databaseDelete(appts, eventsToDelete);

        System.debug('Exiting deleteAppointment');      
    }
    
    /* updateAppointment()
    
        Called when a user updates Appointments.
        
        This requires specific logic to check if an Appointment is either
        changing to or from an Installation - if it's the former, we need 
        to remove the associated Event; if it's the latter, we need to
        create an associated Event. 
    */
    public void updateAppointment() {
        System.debug('Entered updateAppointment');

        // A Map to hold Events we may need to remove - note that we store the
        // Event Id, but the Appointment object alongside it 

        List<Appointment__c> newApptsFromCancellations = new List<Appointment__c>();
        List<Appointment__c> movedAppts = new Appointment__c[]{};
        Map<ID, boolean> apptsUpdateOB = new Map<ID, boolean>(); 
        
        for(sObject a : Trigger.new) {
            // Need to convert to Appointment from sObject
            Appointment__c newApp = (Appointment__c) a;
            // Also need to get the old Appointment as well for comparison
            Appointment__c oldApp = (Appointment__c) Trigger.oldMap.get(a.Id); 
            if(oldApp.Type__c=='Installation' && newApp.Type__c!='Installation' && newApp.RecordtypeId !=InstID) {
                if(!newEvents.containsKey(a.Id)) {
                    // Type of Appointment has changed from Installation to something else.
                    // We'll need to create a new Event - stick it in a list
                    System.debug('updateAppointment: Appointment type changed from Installation, '
                                + 'creating new Event');
                    Event newEventFromInstallation = copyDetails(newApp, new Event(AppointmentID__c = a.Id));
                    newEventFromInstallation.EndDateTime = newApp.End__c;
                    newEventFromInstallation.StartDateTime = newApp.Start__c;
                    newEventFromInstallation.Any_Time__c = newApp.Any_Time__c;
                    newEventFromInstallation.Time_Band__c = newApp.Time_Band__c;
                    
                    newEvents.put(newEventFromInstallation.AppointmentId__c, newEventFromInstallation);
                } else {
                    System.debug('updateAppointment: Appointment type changed from Installation, '
                                + 'new Event already present');             
                    newEvents.remove(a.Id);
                }
            } else if(oldApp.Type__c!='Installation' && newApp.Type__c=='Installation' && newApp.RecordtypeId !=InstID) {
                if(!oldEvents.containsKey(newApp.EventId__c)) {
                    // Type of appointment has changed to Installation - we'll need to
                    // delete the associated Event object
                    System.debug('updateAppointment: Appointment type changed to Installation, '
                                 + 'will remove corresponding event');
                    // Put the IDs of Events to remove into a list
                    oldEvents.put(newApp.EventId__c, newApp.Id);
                } else {
                    System.debug('updateAppointment: Appointment type changed to Installation, '
                                 + 'old Event already removed');                    
                    oldEvents.remove(newApp.EventId__c);
                }
            }
            
            if(oldApp.Status__c != newApp.Status__c) {
                // If status has changed
                // Create new Appointment History object and add it to a list/Map
                System.debug('updateAppointment: Status has changed, will create a new Appointment History. Changed to: ' + newApp.Status__c);
                addAppointmentHistory(newApp, 6);
                
                if(!newApp.OFS_Appointment__c && newApp.Status__c == 'Cancelled' && !newApp.Overbooked__c && newApp.RecordtypeId !=InstID &&  !system.label.OFS_Integration_User.contains(loggedinUser )){//!newApp.OFS_Appointment__c) {//
                    System.debug('updateAppointment: Appointment has been cancelled');
                    String AvailableRTID = Utilities.avRTID;
                    System.debug('updateAppointment: AvailableRTID: ' + AvailableRTID);
                    
                    // CR for creating availability for cancelled apps starts here.
                    // CR for diary start end time changes.
                    // We need to ensure that, we create available slot for the cancelled appointment only if 
                    // --> Employee is an active salesforce user
                    // --> Orignal appointment is scheduled in future.
                    
                    if(newApp.Start__c.date() >= DateTime.now().date()){
                        
                    // Added visit type for avoiding validation failures
                    Appointment__c newAv = new Appointment__c(Assigned_To__c = newApp.Assigned_To__c, Start__c = newApp.Start__c, 
                                            End__c = newApp.End__c, OwnerId = newApp.OwnerId,
                                            Type__c = newApp.Type__c, Show_Time_As__c = 'Out Of Office',
                                            RecordTypeId = AvailableRTID, Mode__c = newApp.Mode__c, Visit_Type__c = 'First Visit');
                                            
                    // ++ Priority appointment change start
                    /*
                    When priority type appt is booked , it is converted into "Sales". Now if we are cancelling the appt we create blank appt.
                    For priority case we will be creating blank appt of type "Priority" only.
                    */                        
                    if(newApp.Priority__c == true)
                    {
                        newAv.Type__c = Utilities.nonOpCategory;
                    }
                    if(newApp.Initial_Type__c!=null)
                    {
                        newAv.Type__c = newApp.Initial_Type__c;
                    }
                    // -- Priority appointment change end
                    
                    System.debug('updateAppointment: mode is ' + newAv.Mode__c);
                    newApptsFromCancellations.add(newAv);
                    
                    }
                }
            }
            
            if(oldApp.Assigned_To__c != newApp.Assigned_To__c) {
                System.debug('updateAppointment: Assigned_To__c has changed, will create new Appointment Histories');
                // If Assigned To has changed
                // Create new Appointment History for the 'old' Appointment...
                addAppointmentHistory(oldApp, 4);
                
                // ... and a new one for the 'new' Appointment
                addAppointmentHistory(newApp, 1);
                
                if(!Lock.apptReassignedLock  &&  !system.label.OFS_Integration_User.contains(loggedinUser)  ) {
                    System.debug('updateAppointment: Reassignment...');
                    movedAppts.add(newApp);
                }
            }
            /*
            if(oldApp.Do_Not_Send_To_Premier__c != newApp.Do_Not_Send_To_Premier__c &&
                !appHistories.containsKey(oldApp.Id)) {
                System.debug('updateAppointment(): Send To Premier flag has changed');
                // Add Appointment to a Map, we'll toggle the flag after we've finished going round
                // the updated Appointments
                sendToPremierChanged.put(newApp.Id, newApp);
            }*/
            Appointment__c app = (Appointment__c) a;
            if(!system.label.OFS_Integration_User.contains(loggedinUser)) //!app.OFS_Appointment__c)
            appts.put(a.Id, (Appointment__c) a);
        }
        
        // Check if there are any Appointment Owner IDs we need to check
        if(!apptsOwnerIDsToCheck.isEmpty())
            checkApptOwners();

        // As we'll need to call checkApptOwners again, clear the list 
        apptsOwnerIDsToCheck.clear();
                    
        // Now insert any new events created above
        DatabaseOperations.databaseInsert(appts, newEvents);
        
        // Now remove any Events as decided above
        DatabaseOperations.databaseDelete(appts, oldEvents);
        
        for(Event ev : [SELECT e.AppointmentID__c FROM Event e WHERE
                            e.AppointmentID__c IN :appts.KeySet()]) {
            // For each Event, call the copy details method
            evts.put(ev.AppointmentId__c, copyDetails(appts.get(ev.AppointmentID__c), ev));     
        }

        // Reassignement code
        if(!movedAppts.isEmpty()) {
            System.debug('updateAppointment: Reassignments...');
            List<String> owners = new List<String>{};
            List<Datetime> startTimes = new List<datetime>{};
            List<Datetime> endTimes = new List<datetime>{};
            List<String> apptType = new List<String>{};
            Appointment__c[] updatedAppts = new Appointment__c[]{};
            Appointment__c[] toDeleteAppts = new Appointment__c[]{};
            Appointment__c[] createdAppts = new Appointment__c[]{}; 
            
            for (Appointment__c apt : movedAppts) {
                owners.add(apt.Assigned_To__c);
                startTimes.add(apt.Start__c);
                endTimes.add(apt.End__c);
                apptType.add(apt.Type__c);
            }    
            
            Appointment__c[] availability = [select Id, Assigned_To__c, Start__c, End__c, Type__c from Appointment__c 
                                                where Assigned_To__c IN :owners 
                                                and Start__c in :startTimes
                                                and End__c in :endTimes
                                                and Type__c in :apptType
                                                and Show_Time_As__c = 'Out Of Office'];
                                                
            System.debug('updateAppointment: number of availability slots returned: ' + availability.size());

            for(Appointment__c movedApp : movedAppts){
                boolean found = false;
                for(Integer i = 0; i < availability.size(); i++){
                    if(movedApp.Assigned_To__c == availability[i].Assigned_To__c &&
                        movedApp.Start__c == availability[i].Start__c &&
                        movedApp.End__c == availability[i].End__c &&
                        movedApp.Type__c == availability[i].Type__c){
                            if(movedApp.OFS_Appointment__c)
                            found = true;
                            
                    else if(!movedApp.Overbooked__c && !found) {
                            // We have found a matching slot of Availabilty; if the Appointment being moved
                            // was not overbooked, let's assign the Availability from the user receiving
                            // the Appointment to the user who is moving the Appointment
                            System.debug('updateAppointment: Moved appointment not overbooked and found is false');
                            Appointment__c temp = (Appointment__c) trigger.oldMap.get(movedApp.Id);
                            System.debug('temp.Assigned_To__c: ' + temp.Assigned_To__c);
                            System.debug('availability[i].Assigned_To__c: ' + availability[i].Assigned_To__c);
                            String add = temp.Assigned_To__c;
                            System.debug('add is: ' + add);
                            extraUsers.add(add);
                            availability[i].Assigned_To__c = temp.Assigned_To__c;
                            updatedAppts.add(availability[i]);
                            System.debug('add is now: ' + add);                   
                            found = true;
                        } else if(!found) {
                            // Moved Appointment is overbooked and we haven't yet found a replacement slot, 
                            // therefore we should delete the availability 
                            System.debug('updateAppointment: Found is false');
                            toDeleteAppts.add(availability[i]); // Delete rather than reassign
                            // Need to set Overbooked on this appointment somehow...
                            //movedApp.Overbooked__c = false;
                            apptsUpdateOB.put(movedApp.Id, false);
                            found = true;
                        }
                    }       
                }
                
                String AvailableRTID = Utilities.avRTID;
                
                if(!found) {
                    // Not found any availability in the destination employee. If the appointment we are moving
                    // is not overbooked, create replacement Availability. We'll also need to mark the 
                    // Appointment being moved as Overbooked.
                    System.debug('updateAppointment: Not found availability...');
                    if(!movedApp.Overbooked__c && !movedApp.OFS_Appointment__c ) {
                        System.debug('updateAppointment: Appointment wasn\'t overbooked so creating Availability');
                        Appointment__c temp = (Appointment__c) trigger.oldMap.get(movedApp.Id);
                        Appointment__c newAppt = new Appointment__c(Assigned_To__c = temp.Assigned_To__c,
                                                                    End__c = movedApp.End__c, Start__c = movedApp.Start__c,
                                                                    OwnerId = temp.OwnerId,
                                                                    Type__c = movedApp.Type__c, Show_Time_As__c = 'Out Of Office',
                                                                    RecordTypeId = AvailableRTID, Mode__c = temp.Mode__c);
                        createdAppts.add(newAppt);                      
                    }
                    // Need to set Overbooked on this appointment somehow...
                    // Add the ID to a list, we'll grab the Appointments later and do an update that way!
                    //movedApp.Overbooked__c = true;
                    apptsUpdateOB.put(movedApp.Id, true);
                }
            }
            
            if(!apptsUpdateOB.isEmpty()) {
                System.debug('updateAppointment: need to update Overbooked on some Appointments');
                // Get the appointments
                Appointment__c[] updates = [SELECT a.Id, a.Overbooked__c FROM Appointment__c a WHERE a.Id IN :apptsUpdateOB.keySet()];
                
                for(Appointment__c ob : updates) {
                    System.debug('Overbooked was: ' + ob.Overbooked__c);
                    System.debug('Overbooked is being set to: ' + apptsUpdateOB.get(ob.Id));
                    ob.Overbooked__c = apptsUpdateOB.get(ob.Id);
                }
                
                Lock.updatingOverbooked = true;
                Database.update(updates);
            }
            
            // Now we insert/update/delete appointments created above...
            try {
                if(!updatedAppts.isEmpty()) {
                    System.debug('updateAppointment: updatedAppts is not empty: ' + updatedAppts.size());
                    checkApptOwners();
                    Lock.lock = false;
                    Lock.apptReassignedLock = true;
                    Database.SaveResult[] lsr = Database.update(updatedAppts, false);
                    Lock.apptReassignedLock = false;
                    Lock.lock = true;
                    //Lock.apptReassignedLock = false;
                    integer i = 0;
                    for(Database.SaveResult sr:lsr){
                        if(!sr.isSuccess()){
                            // Get the problem Appointment__c and add error
                            Database.Error err = sr.getErrors()[0];
                            System.debug('addError: Unsuccessful reassigned Appointment update' + err);
                            Appointment__c errApp = updatedAppts[i];
                            errApp.addError('Error updating appointment database error' + err.getMessage());                                           
                        }
                        i++;
                    }                   
                }
                
                if(!toDeleteAppts.isEmpty()) {
                    System.debug('updateAppointment: toDeleteAppts is not empty: ' + toDeleteAppts.size());
                    Lock.lock = false;
                    Database.DeleteResult[] dels = Database.delete(toDeleteAppts, false);
                    Lock.lock = true;
                    integer i = 0;
                    for(Database.DeleteResult dl:dels){
                        if(!dl.isSuccess()){
                            // Get the problem Appointment__c and add error
                            // Think this is causing an error at the moment - may need to cast to an Appointment object?
                            Database.Error err = dl.getErrors()[0];
                            System.debug('addError: Unsuccessful delete of Appointment: ' + err);
                            toDeleteAppts[i].addError('Error deleting Appointment. Message received: ' + err.getMessage());                                                            
                        } else {
                            evts.remove(dl.getId());
                            appHistories.remove(dl.getId());
                            sendToPremierChanged.remove(dl.getId());
                        }
                        i++;                             
                    }                   
                }
                
                if(!createdAppts.isEmpty()) {
                    System.debug('updateAppointment: createdAppts is not empty: ' + createdAppts.size());
                    System.debug('updateAppointment: createdAppts is not empty: ' + createdAppts);
                    Lock.lock = false;
                    Database.SaveResult[] ins = Database.insert(createdAppts, false);
                    Lock.lock = true;                     
                    integer i = 0;
                    for(Database.SaveResult sr:ins){                             
                        if(!sr.isSuccess()){
                            Database.Error err = sr.getErrors()[0];
                            System.debug('addError: Error inserting capacity.');
                            createdAppts[i].addError('Error inserting new available appointment for previous user. Message received: ' + err.getMessage());                                                            
                        }
                        i++; 
                    }                   
                }
            } catch (Exception exc) {
                System.debug('Something bad happened: ' + exc);
            }
            
            Lock.immediateReturn = true;
        }    
                                       
        // Cancellations...
        if(!newApptsFromCancellations.isEmpty() && !Lock.insertedCapacity) {
            DatabaseOperations.insertCapacity(newApptsFromCancellations);
        }
        
        if(!apptsOwnerIDsToCheck.isEmpty())
            checkApptOwners();

        String[] historiesToRemove = DatabaseOperations.databaseUpdate(appts, evts);
        if(historiesToRemove != null) {
            for(String s : historiesToRemove) {
                appHistories.remove(s);
            }
        }
        /*
        if(!sendToPremierChanged.isEmpty())
            CheckRelatedAppointmentHistories.updateRelatedHistories(sendToPremierChanged);
        
        // BUGFIX
        for(List<Appointment_History__c> ahList : Lock.appHistories.values()) {
            for(Appointment_History__c ah : ahList) {
                if(ah.History_Type__c == historyTypes.get(5)) {
                    if(appts.get(ah.Appointment__c) != null) {
                        ah.Notes__c = appts.get(ah.Appointment__c).Notes__c;
                        ah.Subject__c = appts.get(ah.Appointment__c).Subject__c;
                        ah.Show_Time_As__c = appts.get(ah.Appointment__c).Show_Time_As__c;
                        ah.Any_Time__c = appts.get(ah.Appointment__c).Any_Time__c;
                        ah.Mode__c = appts.get(ah.Appointment__c).Mode__c;
                        appHistoriesToUpdate.add(ah);
                    }
                }
            } 
        }
        */
        DatabaseOperations.insertAppointmentHistories(appHistories, appts);

        DatabaseOperations.updateAppointmentHistories(appHistoriesToUpdate, appts);

        System.debug('updateAppointment: Exiting...');
    }

    public Event copyDetails(Appointment__c oFrom, Event oTo) {
        //System.debug('In copyDetails');
        
        oTo.Converted_Visit_Type__c = oFrom.Converted_Visit_Type__c;
        oTo.Description             = oFrom.Description__c;
        System.debug('copyDetails: Do_Not_Send_To_Premier__c: ' + oFrom.Do_Not_Send_To_Premier__c);
        oTo.Do_Not_Send_To_Premier__c   = oFrom.Do_Not_Send_To_Premier__c ;
         //PRB00022215 Fix Starts
        oTo.EndDateTime           = oFrom.End__c;
        oTo.StartDateTime           = oFrom.Start__c;
        //PRB00022215 Fix Ends
        //oTo.EndDateTime           = oFrom.End__c;
        oTo.Mode__c                 = oFrom.Mode__c;
        oTo.Overbooked__c           = oFrom.Overbooked__c;

        if(!Trigger.isInsert) {
            Appointment__c oldAppt = (Appointment__c) Trigger.oldMap.get(oFrom.Id);
    
            if(oldAppt.Assigned_To__c != oFrom.Assigned_To__c) {
                System.debug('copyDetails: Appointment Assigned_To__c has changed');
                // Add to the list/map
                apptsOwnerIDsToCheck.put(oFrom.Id, oFrom.Assigned_To__c);
            }
    
            if(oldAppt.RecordTypeId != oFrom.RecordTypeId) {
                //System.debug('copyDetails: Appointment RecordTypeId has changed');
         System.debug('copyDetails: Appointment RecordTypeId has changed'+oldAppt.RecordTypeId+'  :   '+oFrom.RecordTypeId);
                String newRecordTypeId = null;
                String oldRecordTypeName = Utilities.getRecordTypeName(oFrom.RecordTypeId);

                System.debug('copyDetails: Looking up Event RecordTypeId, looking for: ' + 
                        oFrom.RecordTypeId + ' ' + oldRecordTypeName);          
                
                newRecordTypeId = Utilities.getRecordTypeId(oldRecordTypeName, 'Event');
                
                if(newRecordTypeId == null)
                    System.debug('copyDetails: Didn\'t find RecordTypeId for Event');
                oTo.RecordTypeId        =   newRecordTypeId;
            }
        } else {
            
            System.debug('----------------------------------IN THE ELSE PART --------------------------');
            if(oFrom.Assigned_To__c!= null) {
                System.debug('copyDetails: new Appointment, will check employee is user, ' +
                            'Appointment.Assigned_To__c is: ' + oFrom.Assigned_To__c);
                apptsOwnerIDsToCheck.put(oFrom.Id, oFrom.Assigned_To__c);
            }
            oTo.EndDateTime             = oFrom.End__c;
            oTo.StartDateTime           = oFrom.Start__c;
            oTo.Any_Time__c             = oFrom.Any_Time__c;
            oTo.Time_Band__c            = oFrom.Time_Band__c;
            System.debug('copyDetails: Looking up Event RecordTypeId, looking for: ' + 
                        oFrom.RecordTypeId);

            String oldRecordTypeName = Utilities.getRecordTypeName(oFrom.RecordTypeId);
            System.debug('App Rec type name  : '+oldRecordTypeName);
            String newRecordTypeId = Utilities.getRecordTypeId(oldRecordTypeName, 'Event');
            System.debug('Event Rec type iD  : '+newRecordTypeId);
            /*Utilities.setup();
            String newRecordTypeId = null;
            String oldRecordTypeName = Utilities.recordTypes.get(oFrom.RecordTypeId).Name;
            for(RecordType rt : Utilities.recordTypes.values()) {
                if(rt.sObjectType=='Event' && rt.Name==oldRecordTypeName){
                    // We want the id of this object
                    System.Debug('copyDetails: Found RecordTypeID for Event: ' + rt.Id);
                    newRecordTypeId = rt.Id;
                }
            }*/
            oTo.RecordTypeId        =   newRecordTypeId;
        }   
        
        oTo.Resource_Type__c        = oFrom.Resource_Type__c;
        oTo.Sale_Flag__c            = oFrom.Sale_Flag__c;
        
        if(oFrom.Show_Time_As__c == 'Out Of Office')
            oTo.ShowAs              =   'OutOfOffice';
        else if(oFrom.Status__c == 'Cancelled')
            oTo.ShowAs              = 'Free';
        else
            oTo.ShowAs              = oFrom.Show_Time_As__c;
        
        oTo.Specific_Date_Requested__c = oFrom.Specific_Date_Requested__c;
        //oTo.StartDateTime             = oFrom.Start__c;
        oTo.Status_Reason__c        = oFrom.Status_Reason__c;
        oTo.Status__c               = oFrom.Status__c;
        oTo.Subject                 = oFrom.Subject__c;
        oTo.Type__c                 = oFrom.Type__c;
        oTo.Visit_Type__c           = oFrom.Visit_Type__c;
        //oTo.WhatId                  = oFrom.Opportunity__c;
         //Added by Cognizant to populate the subject in the Appointment
        //String prefixId=oFrom.WhatId;
        if (oFrom.RecordtypeId ==InstID) {
            oTo.WhatId     =   oFrom.Job__c;
        }else if (oFrom.RecordtypeId ==CustExpID)  {
        oTo.WhatId                  = oFrom.Case__c;
        oTo.Communication_Status__c = oFrom.Communication_Status__c;
        }else if(oFrom.Job_Element__c != null){
            System.debug('@@@@@@APP INPUT = for itinerary@@@@@@'+oFrom);
            oTo.WhatId = oFrom.Job_Element__c;
        }else{
        oTo.WhatId                  = oFrom.Opportunity__c;
        }
        oTo.WhoId                   = oFrom.Who__c;
        oTo.Postcode_Sector__c      = oFrom.Postcode_Sector__c;
        
        //DO NOT USE
        //oFrom.Name;
        //oFrom.Id;
        //oFrom.Appoint_Id_Calc__c;
        
        // THE FOLLOWING ARE NOT WRITEABLE
        //oTo.CreatedDate = oFrom.CreatedDate;
        //oTo.CreatedById = oFrom.CreatedById;
        //oTo.LastModifiedDate = oFrom.LastModifiedDate;
        //oTo.LastModifiedById = oFrom.LastModifiedById;
        //oTo.IsDeleted = oFrom.IsDeleted;
        //oTo.SystemModstamp = oFrom.SystemModStamp;
    
        // Added as part of CR - Display Employee Type on multi user calender view.
        
        oTo.Employee_Type__c = oFrom.Employee_Type__c;
        oTo.Customer_Category__c = oFrom.Customer_Category__c;
        return oTo; 
    }

    /* insertAppointmentHistorySurveyUnv()
        
        CR - Create App History For Survey + Unavailable Appts Created As Part Of Phase IV
        
        Called when a new Appointment is inserted by the user of type survey & unavailablity.
        
        Orignally user creates an unavailability record of type survey booking.
        
        When unavailability is created, an event record is created which in turn creates the appointment.
        
        We have written this to add appointment history also for the same appointment record. 
        
        This is for MI purpose really.
        
        Commented as no more used
    */
    
   /* public void insertAppointmentHistorySurveyUnv() {
        System.debug(LoggingLevel.Info,'Entered insertAppointmentHistorySurveyUnv');
        String unvRecordID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Unavailable');
        List<Appointment_History__c> unvSurveyAppHistList = new List<Appointment_History__c>();
        Appointment_History__c unavSuveryAppHist;
        for(sObject a : Trigger.new) {
            Appointment__c app = (Appointment__c)a;
            System.debug('Will not create survey unav : '+app);
            if(app.RecordTypeID == unvRecordID && app.Unavailability_Reason__c == 'Survey Booking' && app.Type__c == 'Survey'){
               System.debug(LoggingLevel.Info,'Creating app history for survey unv : ' + app.Unavailability_Reason__c);
               unavSuveryAppHist = createAppointmentHistory(app);
               unavSuveryAppHist.History_Type__c = 'Survey unv appointment created';
               unavSuveryAppHist.Status__c = 'Appointed';
               unvSurveyAppHistList.add(unavSuveryAppHist);
            }
        }
        if(unvSurveyAppHistList.size()>0){
            Database.insert(unvSurveyAppHistList);
        }
        System.debug(LoggingLevel.Info,'insertAppointmentHistorySurveyUnv: appts.size(): ' + appts.size());
    }*/
    
}