/* AppointmentUpdate Trigger

    Trigger that happens after an Appointment Update.
    
    As per the other triggers on Appointment and Event, most of the
    work is done in the AppointmentToEventSynchronisation class.
    However there is a lore more logic in this trigger than the other
    triggers because of different possible flows of events. 

*/

trigger AppointmentUpdate on Appointment__c (after update) {

    // If Lock.immediateReturn
    if(Lock.immediateReturn) {
        System.debug('AppointmentUpdate: immediateReturn is true');
        Lock.immediateReturn = false;
        return;
    }
    
    if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_AppointmentUpdate)
    {
        return;
    }
    
    // Set a static variable to show if user is dataloader - this value
    // is used when creating Appointment Histories  
    if(UserInfo.getUserId() == '00520000000mTzkAAE') {
        System.debug(' User is DataLoader ');
        Lock.userIsNotDataloader = false;
    }
    
    if(Lock.apptReassignedLock) {
        System.debug('AppointmentUpdate: apptReassignedLock is true');
        Map<ID, Appointment__c> updates = new Map<ID, Appointment__c>();
        
        for(Appointment__c app : Trigger.new) {
            updates.put(app.EventID__c, app);
        }
        
        Event[] events = [SELECT e.Id, e.Overbooked__c FROM Event e
                            WHERE e.Id IN :updates.keySet()];
        
        for(Event e : events) {
            Appointment__c app = updates.get(e.Id);
            System.debug('AppointmentUpdate: app.Assigned_To__c is ' + app.Assigned_To__c);

            Employee__c emp = AppointmentToEventSynchronisation.employees.get(app.Assigned_To__c);

            if(emp == null)
                System.debug('AppointmentUpdate: emp is null');
                        
            e.OwnerId = emp.Salesforce_User__c;
        }
        
        Lock.lock = true;
        Database.update(events);
        Lock.lock = false;
        Lock.immediateReturn = true;
        return;
    }
    
    if(Lock.updatingOverbooked) {
        System.debug('AppointmentUpdate: updatingOverbooked is true');
        Map<ID, Appointment__c> eventIDs = new Map<ID, Appointment__c>();
        for(Appointment__c app : Trigger.new) {
            eventIDs.put(app.EventID__c, app);
        }
        
        Event[] events = [SELECT e.Id, e.Overbooked__c FROM Event e
                            WHERE e.Id IN :eventIDs.keySet()];
                            
        for(Event e : events) {
            Appointment__c app = eventIDs.get(e.Id);
            System.debug('AppointmentUpdate: app.Overbooked__c is: ' + app.Overbooked__c);
            System.debug('AppointmentUpdate: e.Overbooked__c was: ' + e.Overbooked__c);
            e.Overbooked__c = app.Overbooked__c;
            System.debug('AppointmentUpdate: e.Overbooked__c now: ' + e.Overbooked__c);
        }
        Lock.lock = true;
        Database.update(events);
        Lock.lock = false;
        Lock.updatingOverbooked = false;
        Lock.immediateReturn = true;
        return;
    }

    Map<ID, Appointment__c> appsChanged = new Map<ID, Appointment__c>();
  //  Opportunity[] oppsToBeUpd = new list<Opportunity>();
  //  Appointment__c[] apptInAppted = new list<Appointment__c>();
    
    for(Appointment__c newApp : Trigger.new) {
        System.debug('+++++++++++++++++++++++chitra - newApp.Id - '+newApp.Id);
        Appointment__c oldApp = Trigger.oldMap.get(newApp.Id);
        
        if(oldApp.Converted_Visit_Type__c != newApp.Converted_Visit_Type__c || 
           oldApp.Description__c != newApp.Description__c ||
           oldApp.Do_Not_Send_To_Premier__c != newApp.Do_Not_Send_To_Premier__c ||
           oldApp.Mode__c != newApp.Mode__c ||
           oldApp.Overbooked__c != newApp.Overbooked__c ||
           oldApp.RecordTypeId != newApp.RecordTypeId ||
           oldApp.Any_Time__c != newApp.Any_Time__c ||
           oldApp.Time_Band__c != newApp.Time_Band__c ||
           oldApp.Resource_Type__c != newApp.Resource_Type__c ||
           oldApp.Sale_Flag__c != newApp.Sale_Flag__c ||
           oldApp.Show_Time_As__c != newApp.Show_Time_As__c ||
           oldApp.Specific_Date_Requested__c != newApp.Specific_Date_Requested__c ||
           oldApp.Status_Reason__c != newApp.Status_Reason__c ||
           oldApp.Status__c != newApp.Status__c ||
           oldApp.Subject__c != newApp.Subject__c ||
           oldApp.Type__c != newApp.Type__c ||
           oldApp.Visit_Type__c != newApp.Visit_Type__c ||
           oldApp.Opportunity__c != newApp.Opportunity__c ||
           oldApp.Who__c != newApp.Who__c ||
           oldApp.Postcode_Sector__c != newApp.Postcode_Sector__c ||
           oldApp.Assigned_To__c != newApp.Assigned_To__c ||
           //PRB00022215 Fix Starts
           oldApp.Start__c != newApp.Start__c ||
           oldApp.End__c != newApp.End__c ||
           //PRB00022215 Fix Ends
           oldApp.EventID__c != newApp.EventID__c) {
            System.debug('AppointmentUpdate: Appointment changed');
            appsChanged.put(newApp.Id, newApp);
            //PR fix chitra

 /* oppsToBeUpd = [Select o.id,o.StageName,o.Number_of_Survey_Appointments__c, 
                                    o.Number_of_Sales_Appointments__c, o.First_Appointment_Date__c,
                                    o.Number_of_Appointed_Sales_Appointments__c,
                                    o.Number_of_Appointed_Survey_Appointments__c, 
                                    o.Number_of_Cancelled_Sales_Appointments__c,HistorySOHSA__c                                 
                                    from Opportunity o
                                    WHERE o.id =: newApp.Opportunity__c];
            System.debug('++++++++++++++++++++++chitra - oppsToBeUpd'+oppsToBeUpd); 
            apptInAppted = [Select a.id, a.Status__c, a.Opportunity__c, a.Type__c from Appointment__c a WHERE a.Opportunity__c IN :oppsToBeUpd];    
            System.debug('++++++++++++++++++++++chitra - apptInAppted'+apptInAppted);
            if (!apptInAppted.isEmpty() && !oppsToBeUpd.isEmpty())
            {
            for(Opportunity opp : oppsToBeUpd)
            {
            opp.Number_of_Sales_Appointments__c = 0;
            opp.Number_of_Survey_Appointments__c = 0;
            for(Appointment__c app : apptInAppted)
             {
             if(app.Status__c=='Appointed')
               { 
               System.debug('++++++++++++++++++++++chitra - inside loop');
                if (app.Type__c=='Sales')
                opp.Number_of_Sales_Appointments__c++ ;
                if (app.Type__c=='Survey')
                opp.Number_of_Survey_Appointments__c++ ;
               }
              }
             if (opp.Number_of_Appointed_Survey_Appointments__c > 0 || opp.Number_of_Appointed_Sales_Appointments__c > 0)
                 opp.StageName='Appointed';
                 System.debug('++++++++++++++++++++++chitra - opp.StageName '+opp.StageName);
            
             }
             }        
//PR fix chitra 
*/
        }
    }
    
    if(appsChanged.isEmpty()) {
        System.debug('AppointmentUpdate: No changed Appointments, exiting...');
        return;
    }

    //
    // End Section  - Cancellation
    //
    // Start Section    - synchronisation and creates history
    //
    if(Lock.lock) {
        System.debug('Lock.Lock is set');
        //Lock.lock = false;
        return;
    }
        
    Lock.lock = true;
    System.debug('AppointmentUpdate: lock set');

    AppointmentToEventSynchronisation sync =
                    new AppointmentToEventSynchronisation();            
    sync.updateAppointment();
    
    Lock.lock = false;
    System.debug('AppointmentUpdate: lock unset');
    //
    // End Section  -   - synchronisation and creates history
    
    ///
    //Cancel Quote in Big Machines - Check if appointment has been cancelled and has already been loaded into Big Machines.
    //If so, send a webservice callout to Big Machines to cancel the quote also.
    //Due to callout governor limits this acts on single appointment updates only. Cannot work in with bulk updates.
    /// 
    /*
    system.debug('lock.httpCancellationCallOutToBigMachinesMade is '+lock.httpCancellationCallOutToBigMachinesMade);
    if(!lock.httpCancellationCallOutToBigMachinesMade){             
        if(trigger.new.size()==1){          
            for(Appointment__c newApp : Trigger.new) {                      
                Appointment__c oldApp = Trigger.oldMap.get(newApp.Id);
                List<ID> app = new List<ID>{newApp.Id};
                system.debug('newApp.LoadedInBM__c == '+newApp.LoadedInBM__c+' newApp.SentToBM__c== '+newApp.SentToBM__c+ 'newApp.Status__c == '+newApp.Status__c+' oldApp.Status__c == '+oldApp.Status__c);
                //If has become cancelled and has been loaded in Big Machines call web method to cancel BigMachines quote
                if((newApp.LoadedInBM__c ==true || newApp.SentToBM__c==true) && newApp.Status__c == 'Cancelled' && oldApp.Status__c != 'Cancelled' && newApp.LastModifiedById != system.label.BM_UserId){        
                    // Commented after business have stopped using BM.
                    //BigMachinesQuoteInterface.updateBigMachinesWhenCancelled(app);
                    System.debug('Apex future method to cancel quote in big machines has been called');
                    //Set lock tp ensure only one callout is made per transaction. 
                    lock.httpCancellationCallOutToBigMachinesMade=true; 
                    system.debug('lock.httpCancellationCallOutToBigMachinesMade is '+lock.httpCancellationCallOutToBigMachinesMade);                                
                }
            }
        }       
    }*/
    
}