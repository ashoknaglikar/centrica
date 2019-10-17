/* EventDelete Trigger
    
    Trigger that happens after an Event Delete. A quick check is made
    to make sure that if record is a booked Appointment, deletion can
    only be performed by System Administrator or DataLoader users.  
*/
trigger EventDelete on Event (after delete) {

    // Check if Lock.lock is set - if so, Appointment Delete is running
    // and we don't want the code here to fire. 
    if(Lock.lock) {
        System.debug('Lock.lock is true');
        return;
    }
    
    // If we're still running, set the lock
    Lock.lock = true;
    System.debug('Lock.lock set');

    // Check to see if user is allowed to delete Appointments. If not, loop
    // over Events being deleted and check each one to see if any are
    // Appointments. If they are, add an Error to prevent deletion and warn user.
    if(!Utilities.profilesAllowedToDelete.contains(UserInfo.getProfileId())) {
        for(Event ev : Trigger.old) {
            if(ev.RecordTypeId == Utilities.getRecordTypeId('Appointment', 'Event'))
                ev.addError('Customer Appointment cannot be deleted. Please contact your administrator');
        }
    }

    // Create an instance of the EventToAppointmentSynchronisation class
    // and run the deleteEvent method   
    EventToAppointmentSynchronisation sync =
                    new EventToAppointmentSynchronisation();
    sync.deleteEvent();
    
    // Clear the lock
    Lock.lock = false;
    System.debug('Lock.lock unset');
}