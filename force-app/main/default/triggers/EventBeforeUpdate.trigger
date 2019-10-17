/* EventBeforeUpdate Trigger

    Trigger that happens before an Event is updated. 
    Added as part of CR - Display Employee Type on multi user calender view.

*/

trigger EventBeforeUpdate on Event (before update) {
  
   if(Lock.lock) {
   
        System.debug('Lock.lock is true');
        return;
        
    }

   Map<String,Event> appIdEventMap = new Map<String,Event>();

   for(Event e : Trigger.New){
   
        if(e.Employee_Type__c == null && e.AppointmentID__c != null){
         
             appIdEventMap.put(e.AppointmentID__c,e);
        
        }
   
   }
   
   if(appIdEventMap.keySet().size()<=0){
   
      return;
   
   }
   
   for(Appointment__c app : [Select Id, Employee_Type__c from Appointment__c where Id in : appIdEventMap.keySet()]){
   
      appIdEventMap.get(app.Id).Employee_Type__c = app.Employee_Type__c;
   
   }
   
}