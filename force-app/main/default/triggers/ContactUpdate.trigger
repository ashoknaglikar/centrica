/* ContactUpdate Trigger

    Trigger that happens after a Contact is updated. If any of a Contact's name or
    contact details have changed, we need to create an Appointment History for any
    Appointments related to the Contact that are in the future and of Status 
    New or Appointed.
    
    Most of the work is done in the CheckRelatedAppointmentHistories class. 

*/

trigger ContactUpdate on Contact (after update) {

    // If user is Dataloader, set the variable accordingly
    if(UserInfo.getUserId() == '00520000000mTzkAAE') {
        System.debug('User is DataLoader');
        Lock.userIsNotDataloader = false;
    }
    
    // A map to hold the contacts   
    Map<ID, Contact> contacts = new Map<ID, Contact>();
    Map<ID, Contact> newcontacts = new Map<ID, Contact>();
    
    for(Contact newContact : Trigger.new) {
        Contact oldContact = Trigger.oldMap.get(newContact.Id);
        
        if(oldContact.Salutation   != newContact.Salutation  ||
            oldContact.FirstName   != newContact.FirstName   ||
            oldContact.LastName    != newContact.LastName    ||
            oldContact.HomePhone   != newContact.HomePhone   ||
            oldContact.OtherPhone  != newContact.OtherPhone  ||
            oldContact.MobilePhone != newContact.MobilePhone ||
            oldContact.Phone       != newContact.Phone) {
            
            // We will need to get this Contact's Appointments
            contacts.put(newContact.Id, oldContact);
            newcontacts.put(newContact.Id, newContact); //PRB00032662
        }
    }
    System.debug(LoggingLevel.INFO, 'new and old contacts'+contacts+' '+newcontacts);
    // If there are no Opportunities with Stage updates, nothing for us to do, so return
    if(contacts.isEmpty()) {
        System.debug('No Contacts with necessary details updated, returning');
        return;
    }
    
    //PRB00032662 fix starts
    if(system.label.contact_update_on_opp == 'on'){
    Opportunity[] opp_record = [Select o.id,o.Bill_Title__c, o.Bill_LastName__c, o.Bill_FirstName__c,o.Account.Primary_Contact__c from Opportunity o where o.Account.Primary_Contact__c in :contacts.keyset() ];
    
    List<Opportunity> opptoupd = new List<Opportunity>();
    System.debug(LoggingLevel.INFO, 'Opp before update '+opp_record);
    
    Contact oldcompare = new Contact();
    Contact newcompare = new Contact();
    Boolean toupdatechecker = false;
    
    for(Opportunity opp : opp_record){
    
    oldcompare = contacts.get(opp.Account.Primary_Contact__c);
    newcompare = newcontacts.get(opp.Account.Primary_Contact__c);
    System.debug(LoggingLevel.INFO, 'opp.Bill_LastName__c '+opp.Bill_LastName__c+' oldcompare.LastName'+' '+oldcompare.LastName+' newcompare.LastName '+newcompare.LastName+' toupdatechecker '+toupdatechecker);
    
    if(opp.Bill_Title__c == oldcompare.Salutation && opp.Bill_Title__c != newcompare.Salutation){
    opp.Bill_Title__c = newcompare.Salutation;
    toupdatechecker = true;
    }
    if(opp.Bill_FirstName__c == oldcompare.FirstName && opp.Bill_FirstName__c != newcompare.FirstName){
    opp.Bill_FirstName__c = newcompare.FirstName;
    toupdatechecker = true;
    }
    if(opp.Bill_LastName__c == oldcompare.LastName && opp.Bill_LastName__c != newcompare.LastName){
    opp.Bill_LastName__c = newcompare.LastName;
    toupdatechecker = true;
    }
    if(toupdatechecker){
    opptoupd.add(opp);
    toupdatechecker = false;
    }
    }
    
    System.debug(LoggingLevel.INFO, 'Opp to update '+opptoupd);
 
    update opptoupd;
    }
    //PRB00032662 fix ends
    // Get the related Appointments out of the database 
    Appointment__c[] apps = [SELECT a.id, a.Status__c, 
                            a.Any_Time__c, a.Assigned_To__c, a.Do_Not_Send_To_Premier__c,
                            a.Converted_Visit_Type__c, a.End__c, a.Mode__c,
                            a.Notes__c, a.Overbooked__c, a.Resource_Type__c, 
                            a.Sale_Flag__c, a.Show_Time_As__c, a.Siebel_Created_Date__c,
                            a.Specific_Date_Requested__c, a.Start__c,
                            a.Status_Reason__c, a.Subject__c, a.Time_Band__c,
                            a.Visit_Type__c, a.Opportunity__c, a.Who__c, a.Type__c
                            FROM Appointment__c a
                            WHERE a.Who__c IN :contacts.keySet()
                            AND a.Start__c > :Datetime.now()
                            AND (a.Status__c='New' OR a.Status__c='Appointed')];

    System.debug('Number of returned Appointments: ' + apps.size());

    // If there are no Appointments returned, no Appointment Histories need to be created
    // so we can exit here                      
    if(apps.isEmpty()) {
        System.debug('No Appointments returned, none to update, returning');
        return;
    }

    // Call the createAppointmentHistoriesOnUpdate method - this will create Appointment
    // Histories on relevant Appointment objects
    System.debug('Number of returned Appointments: ' + apps.size());                            
    CheckRelatedAppointmentHistories.createAppointmentHistoriesOnUpdate(apps, 'Contact Update');

}