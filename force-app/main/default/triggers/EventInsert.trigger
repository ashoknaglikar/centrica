/* EventInsert Trigger

    Trigger that happens after an Event Insert. Most of the work 
    happens in the EventToAppointmentSynchronisation class.

*/
trigger EventInsert on Event (after insert) {

    // Check if Lock.lock is set - if so, Appointment Insert is running
    // and we don't want the code here to fire.
    if(Lock.lock) {
        System.debug('Lock.lock is true');
        return;
    }
    
    // If we're still running, set the lock
    Lock.lock = true;
    System.debug('Lock.lock set');

    // Create an instance of the EventToAppointmentSynchronisation class
    // and run the insertEvent method   
    EventToAppointmentSynchronisation sync =
                    new EventToAppointmentSynchronisation();
    sync.insertEvent();
    
    // Clear the lock
    Lock.lock = false;
    System.debug('Lock.lock unset');
}