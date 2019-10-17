/* EventUpdate Trigger

    Trigger that happens after an Event Update. Most of the work is done
    in the EventToAppointmentSynchronisation class.

*/

trigger EventUpdate on Event (after update) {

    // Check if Lock.lock is set - if so, Appointment Update is running
    // and we don't want the code here to fire. 
    if(Lock.lock) {
        System.debug('Lock.lock is true');
        return;
    } 
    
    // Added as part of CR - Display Employee Type on multi user calender view
    
      if(cls_IsRun.dontFireTriggers){
      
          return;
          
      }      
    
    // If we're still running, set the lock
    Lock.lock = true;
    System.debug('Lock.lock set');
    
    // Create an instance of the EventToAppointmentSynchronisation class
    // and run the updateEvent method   
    EventToAppointmentSynchronisation sync =
                    new EventToAppointmentSynchronisation();    
    sync.updateEvent();
    
    // Clear the lock
    Lock.lock = false;
    System.debug('Lock.lock unset');
}