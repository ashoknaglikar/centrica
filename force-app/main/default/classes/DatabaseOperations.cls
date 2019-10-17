/* DatabaseOperations()

    A class that contains the methods used to make changes to the Database 
    for Appointment/Event Inserta/Updates/Deletes.
    
    The methods try to remain object agnostic - that is, they try to work for
    both Event and Appointment operations regardless of which object is
    being inserted/updated/deleted.
    
    This works with the concept of primary and secondary objects. The primary
    object is the object being operated on; the secondary object is the object
    that we operate on on behalf of the user. So for example, if a user deletes
    an Appointment, the Appointment will be the primary object and the Event
    will be the secondary object.  

*/

public class DatabaseOperations {

    // Strings that hold the primary and secondary object types. These are
    // populated later and are used mostly for debug statments
    private static String primaryObjectType = '';
    private static String secondaryObjectType = '';
    
    // A map of Strings that hold the different types of database operation.
    // These are used to genericise the debug statements 
    private static Map<Integer, String> opTypes = 
                    new Map<Integer, String> {1 => 'insert',
                                              2 => 'update',
                                              3 => 'delete'};
    
    /* databaseOps(SObjectType)
        
        Returns a string based on the SObjectType passed in.
    */
    private static String databaseOps(SObjectType objType) {
        if(objType == Event.getSObjectType())
            return 'Event';
        else if (objType == Appointment__c.getSObjectType())
            return 'Appointment';           
        else
            return '';
    }   

    /* handleResults(Database.SaveResult[], Integer, List<sObject>, Map<ID, sObject>)
    
        Method that processes results from a Database Insert or Update. Returns
        an array of Strings representing Appointment IDs that failed to insert/update.
        
        The objects in the list of sObjects are the objects that were in the 
        insert/update. The Map contains the "primary" objects - these are the objects
        that the user operated on directly (the objects in the list were operated on
        on behalf of the user i.e. if the user saves an Appointment, Appointment would
        be the primary object and in the Map, and the Event would be the secondary 
        object and in the List instead.  
    */  
    private static String[] handleResults(Database.SaveResult[] results, Integer opType,
                                    List<sObject> objectsToOperateOn, 
                                    Map<ID, sObject> primary) {
                                        
        // An array of strings to hold the IDs of any Appointments that were not
        // successfully operated on. 
        String[] failedAppointments = new String[]{};
        
        // Loop over the results
        Integer ctr = 0;
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                System.Debug('Unsuccessful ' + secondaryObjectType + ' ' + opTypes.get(opType));
                Database.Error err = result.getErrors()[0];
                
                if(primary.getSObjectType() == Event.getSObjectType()) {
                    // If the primary object was an Event, get the Appointment that caused the 
                    // problem and from that, get the Event the user inserted/modified
                    Appointment__c temp = (Appointment__c) objectsToOperateOn[ctr]; 
                    Event errorEvent = (Event) primary.get(temp.EventID__c);
                    
                    // Add an error to the Event to report the problem to the user
                    errorEvent.addError('Couldn\'t ' + opTypes.get(opType) + 
                                        ' Appointment when attempting to ' + 
                                        opTypes.get(opType) + ' Event: ' +
                                        err.getMessage());
                } else if (primary.getSObjectType() == Appointment__c.getSObjectType()) {
                    // If the primary object was an Appointment, get the Event that cause the
                    // problem and from that, get the Appointment user inserted/modified
                    Event temp = (Event) objectsToOperateOn[ctr];
                    Appointment__c errorAppt = (Appointment__c) primary.get(temp.AppointmentID__c);
                    
                    // Add an error to the Appointment to report the problem to the user
                    errorAppt.addError('Couldn\'t ' + opTypes.get(opType) + 
                                        ' Event when attempting to ' + 
                                        opTypes.get(opType) + ' Appointment: ' + 
                                        err.getMessage());
                                        
                    // Add the ID of the Appointment to the list - we need to inform the calling
                    // method that this Appointment was not operated on successfully.
                    failedAppointments.add(errorAppt.Id);
                }
            }
            ctr++;
        }
        
        // Return the list of Appointments that were unsuccessful
        return failedAppointments;
    }
    
    /* databaseInsert(Map<Id, Sobject>, Map<Id, Sobject>) 
    
        Inserts the objects in the secondary Map into the Database. The objects in the 
        Primary map are the objects that the user operated on, the objects in the 
        Secondary map are the objects that we are inserting on behalf of the user e.g.
        If the user is creating a new Appointment, Appointment is the primary object,
        Event is the secondary object.
    */
    public static void databaseInsert(Map<Id, sObject> primary, Map<Id, sObject> secondary) {
        
        // If there are no objects to insert, return
        if(secondary.isEmpty())
            return;
        
        // For debugging purposes, we populate these two strings that are used later in
        // System.debug() statements. This help genericise the method but also allows
        // debugging to show what objects we are operating on.
        primaryObjectType = databaseOps(primary.getSObjectType());
        secondaryObjectType = databaseOps(secondary.getSObjectType());

        try {
            if(!secondary.isEmpty()) {
                // Insert the objects into the database and call the handleresults() 
                // method to process the results.
                System.Debug('Inserting objects: ' + secondaryObjectType);
                List<sObject> objectsToInsert = secondary.values();
                Database.SaveResult[] results = Database.insert(objectsToInsert, false);
                System.debug('EVENTS INSERTED ....');
                handleResults(results, 1, objectsToInsert, primary);
            }
        } catch (Exception exc) {
            // Execution should never get here - if there is a problem, it should be 
            // reported in handleResults()
            for(sObject obj : primary.values()) {
                obj.addError('Couldn\'t insert ' + secondaryObjectType + 
                            ' when inserting ' + primaryObjectType);
                System.debug('Exception thrown trying to insert ' + secondaryObjectType +
                            ': ' + exc);
            }
        }       
    }
    
    /* databaseUpdate(Map<Id, Sobject>, Map<Id, Sobject>)
    
        Updates the objects in the secondary Map in the Database. The objects in the 
        Primary map are the objects that the user operated on, the objects in the 
        Secondary map are the objects that we are updating on behalf of the user e.g.
        If the user is updating an Appointment, Appointment is the primary object,
        Event is the secondary object.
        
        This method returns an array of strings - these Strings contain Apponintment 
        IDs of Appointments that were not updated successfully.
    
    */
    public static String[] databaseUpdate(Map<Id, sObject> primary, Map<Id, sObject> secondary) {
        // Check that there are actually objects to update - if not, just return
        if(secondary.isEmpty())
            return null;
        
        // For debugging purposes, we populate these two strings that are used later in
        // System.debug() statements. This help genericise the method but also allows
        // debugging to show what objects we are operating on.      
        primaryObjectType = databaseOps(primary.getSObjectType());
        secondaryObjectType = databaseOps(secondary.getSObjectType());
        String[] failedUpdates = new String[]{};
        
        try {
            if(!secondary.isEmpty()) {
                // Update the objects in the database and process the results in the
                // handleResults() method
                System.Debug('Updating objects: ' + secondaryObjectType);
                Database.SaveResult[] results = Database.update(secondary.values(), false);
                List<sObject> objectsToUpdate = secondary.values();
                failedUpdates = handleResults(results, 2, objectsToUpdate, primary);
            }
            // If some appointments did not update, failedUpdates will not be empty, so
            // return failedUpdates. If it is empty, return null - that way, the calling
            // function can see if there were any problems by checking for the null value 
            if(!failedUpdates.isEmpty())
                return failedUpdates;
            else
                return null;
        } catch (Exception exc) {
            // Execution should never get here - if there is a problem, it should be 
            // reported in handleResults()          
            for(sObject obj : primary.values()) {
                obj.addError('Couldn\'t update ' + secondaryObjectType + 
                            ' when updating ' + primaryObjectType);
                System.debug('Exception thrown trying to update ' + secondaryObjectType +
                            ': ' + exc);
            }
            return null;
        }
    }
    
    /* databasedelete(Map<Id, Sobject>, Map<Id, Sobject>)
    
        Deletes the objects in the secondary Map from the Database. The objects in the 
        Primary map are the objects that the user operated on, the objects in the 
        Secondary map are the objects that we are deleting on behalf of the user e.g.
        If the user is deleting an Appointment, Appointment is the primary object,
        Event is the secondary object.
    
    */
    public static void databaseDelete(Map<Id, sObject> primary, Map<ID, ID> secondary) {
        // Check there are objects to be deleted, if not, return.
        if(secondary.isEmpty())
            return;

        // For debugging purposes, populate these two strings that are used later in
        // System.debug() statements. This help genericise the method but also allows
        // debugging to show what objects we are operating on.
        if(primary.getSObjectType() == Event.getSObjectType()) {
            primaryObjectType = 'Event';
            secondaryObjectType = 'Appointment';
        } else if (primary.getSObjectType() == Appointment__c.getSObjectType()) {
            primaryObjectType = 'Appointment';
            secondaryObjectType = 'Event';
        }
                
        try {
            if(!secondary.isEmpty()) {
                System.debug('Deleting objects: ' + secondaryObjectType);
                
                // Create a list of IDs of objects to delete, then delete them
                List<ID> ids = new List<ID>(secondary.keySet());
                Database.DeleteResult[] results = Database.delete(ids, false);
                
                // Process the results - we can't use handleResults() as the logic
                // is slightly different
                Integer i = 0;
                for(Database.DeleteResult result : results) {
                    if(!result.isSuccess()) {
                        // Problem deletion - there are a couple of Status Codes that, if we
                        // encounter, we should ignore. These are ENTITY_IS_DELETED and 
                        // INVALID_CROSS_REFERENCE_KEY - if these occur, we've tried to delete
                        // an object related to another object, but it's already deleted.
                        Database.Error error = result.getErrors()[0];
                        if(error.getStatusCode() != System.StatusCode.ENTITY_IS_DELETED &&
                            error.getStatusCode() != System.StatusCode.INVALID_CROSS_REFERENCE_KEY) {
                            System.debug('Error whilst deleting, problem wasn\'t Entity_Is_Delete: ' + 
                                            error.getStatusCode() + ' : ' + error);
                            ID errID = secondary.get(ids[i]);
                            sObject err = primary.get(errID);
                            err.addError('Couldn\'t delete ' + secondaryObjectType + 
                                        ' when deleting ' + primaryObjectType);                                                 
                        }
                    }
                    i++;
                }
            }
        } catch (Exception exc) {
            // Execution should never get here - if there is a problem, it should be 
            // handled above            
            for(sObject obj : primary.values()) {
                obj.addError('Couldn\'t delete ' + secondaryObjectType + 
                            ' when deleting ' + primaryObjectType);
                System.debug('Exception thrown trying to delete ' + secondaryObjectType +
                            ': ' + exc);
            }
        }
    }
    
    /* insertAppointmentHistories(Map<String, List<Appointment_History__c>>, Map<Id, Appointment__c>)

        Inserts Appointment Histories into the database.
    */
    public static void insertAppointmentHistories(Map<String, List<Appointment_History__c>> appHistories, 
                                                    Map<ID, Appointment__c> appts) {
        try {
            if(!appHistories.isEmpty()) {
                // The Appointment Histories are stored in Lists in the Map, we need to loop
                // over the Lists in the Map and add all the Appointment Histories into
                // one List.
                List<Appointment_History__c> historyList = new List<Appointment_History__c>();
                for(List<Appointment_History__c> subList : appHistories.values()) {
                    historyList.addAll(subList);
                }
                
                // Insert the Appointment Histories...
                Database.SaveResult[] insertResults = Database.insert(historyList, false);
                
                // ... and Process the results
                Integer i = 0;
                for(Database.SaveResult result : insertResults) {
                    if(!result.isSuccess()) {
                        // Problem insert, get the Appointment that the Appointment
                        // History is being inserted against and report an error on it
                        Database.Error err = result.getErrors()[0];
                        System.debug('insertAppointment: Unsuccessful Appointment History insert: ' + err);
                        Appointment_History__c ah = historyList[i];
                        System.debug('Problem Appointment History: ' + historyList[i]);
                        Appointment__c app = appts.get(ah.Appointment__c);
                        app.addError('Error creating Appointment History object: ' + err);
                    }
                    i++;
                }
            }
        } catch (Exception exc) {
            // Execution should not reach here; if something goes wrong, report
            // an error on all Appointments we were passed.
            for(Appointment__c app : appts.values()) {
                app.addError('Couldn\'t insert Appointment History when updating Appointment');
                System.debug('Exception thrown trying to insert Appointment History ' + 
                            'when updating Appointment: ' + exc);               
            }
        }
    }
    
    /* updateAppointmentHistories(List<Appointment_History__c>, Map<ID, Appointment__c>)

        Updates the Appointment Histories passed into the method in the database.
    */
    public static void updateAppointmentHistories(List<Appointment_History__c> updates, Map<ID, Appointment__c> appts) {
        try {
            if(!updates.isEmpty()) {
                // Update the Appointment Histories...
                Database.SaveResult[] updateResults = Database.update(updates, false);
                
                // ... and process the results
                Integer i =0;
                for(Database.SaveResult result : updateResults) {
                    if(!result.isSuccess()) {
                        // If a result is not a success, add an error to the Appointment
                        // that the Appointment History is linked to
                        Database.Error err = result.getErrors()[0];
                        System.debug('Unsuccessful Appointment History update: ' + err);
                        Appointment_History__c ah = updates[i];
                        System.debug('Problem Appointment History: ' + updates[i]);
                        Appointment__c app = appts.get(ah.Appointment__c);
                        app.addError('Error updating Appointment History object: ' + err);
                    }
                    i++;
                }
            }
        } catch (Exception exc) {
            // Execution should not reach here; if something goes wrong, report
            // an error on all Appointments we were passed.
            for(Appointment__c app : appts.values()) {
                app.addError('Couldn\'t update Appointment History when updating Appointment');
                System.debug('Exception thrown trying to update Appointment History ' + 
                            'when updating Appointment: ' + exc);               
            }
        }
    }

    /* insertCapacity(List<Appointment__c>)
        A method that inserts new capacity (Appointments of type Available) into
        the database. This is used, for example, when a (non-Overbooked) 
        Appointment is cancelled, we need to create a replacement Appointment
        of type Available - this method deals with inserting the new capacity.
    */  
    
    public static void insertCapacity(List<Appointment__c> newApptsFromCancellations) {
        
        System.Debug('Inserting new capacity');
        System.debug(LoggingLevel.INFO, 'Number of appointments getting cancelled in this transaction: ' + newApptsFromCancellations.size());
        
        // As we're inserting new Appointments, we need to set Lock.lock to false.
        // This is so that, when the Appointments are inserted, the triggers fire
        // to insert Events.
        Lock.lock = false;
        
        /*
             We have changed the logic in this method over the period of time. 
             Now as Premier to Salesforce interface is not in place.
             We normally do not recieve any cancelled appointments from Premier. 
             We need to ensure that we create available slot for the cancelled appointment only if employee is an active salesforce user
             & if the orignal appointment is scheduled in future.
             This method also has a logic to convert the cancelled appointments from old world 
             to the equivalent available slot considering start/end timings in the new world.
        */

           List<ID> empIdList = new List<ID>(); 
           List<Employee__c> empList = new List<Employee__c>();
           
           for(Appointment__c app:newApptsFromCancellations){
              
                if(app.Assigned_To__c == null){
                    
                    continue;
                    
                 }
                 
                empIdList.add(app.Assigned_To__c);
              
           }
            
           empList = [Select ID,Is_Active_Salesforce_User__c from Employee__c where ID in :empIdList];
           
           // Added nested loops to avoid list out of bound apex exceptions when cancelling mutiple appointments in single transaction 
           // or when assigned to field is null on appointment record.
           
           for(Integer i=0;i<newApptsFromCancellations.size();i++){
                 if(newApptsFromCancellations[i].Assigned_To__c == null){
                    newApptsFromCancellations.remove(i);
                 }
           }
           
           System.debug(LoggingLevel.INFO, 'actual size of availability to be inserted: ' + newApptsFromCancellations.size());
           
           for(Integer i=0;i<newApptsFromCancellations.size();i++){
            for(Integer j=0;j<empList.size();j++){
               if(newApptsFromCancellations[i].Assigned_To__c == empList[j].ID && empList[j].Is_Active_Salesforce_User__c == 'false'){
                   newApptsFromCancellations.remove(i);
                   break;
               }
             }
           }     
           
           if(newApptsFromCancellations.isEmpty()){
            
             Lock.lock = true;
             Lock.insertedCapacity = true;
             return;
            
           } 
           
           // CR For Diary Start & End Time Changes Starts
            
            // Utilities.convertAppointmentsFromOldWorldToNewWorld(newApptsFromCancellations);
           
           // CR For Diary Start & End Time Changes Ends
        
           // Insert the Appointment objects
           Database.SaveResult[] results;
           try{
            
            results = Database.insert(newApptsFromCancellations);
           
           }catch(DMLException excp){
            
             System.debug('Problem whilst creating Available Appointment to replace cancelled Appointment.');  
                    
           }
           
           // Now process the results.
           Integer ctr = 0;
           // Added extra if condition to avoid null pointer exception
           if(results.size()>0){
           for(Database.SaveResult result : results) {
                 if(!result.isSuccess()) {
                     Database.Error err = result.getErrors()[0];
                     Appointment__c appError = newApptsFromCancellations[ctr];
                     appError.addError('Problem whilst creating Available Appointment to replace cancelled Appointment: ' + err.getMessage());
                  }
                     ctr++;
              }
           }
   
        // Now that the capacity is inserted, set Lock.lock to true again. We also
        // set Lock.insertedCapacity to true - this is used so that we know 
        // (elsewhere) that the capacity has been inserted, and that we don't insert 
        // it twice  
        
        Lock.lock = true;
        Lock.insertedCapacity = true;
        
    }

}