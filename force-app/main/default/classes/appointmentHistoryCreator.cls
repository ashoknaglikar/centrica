global class appointmentHistoryCreator implements Database.Batchable<sObject>{

    
    public static void invokeBatch(){
        appointmentHistoryCreator appObj = new appointmentHistoryCreator();
        ID batchprocessid = Database.executeBatch(appObj);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        dateTime startDate = system.now().addDays(-30);
        datetime endDate = system.now();
        
        string query = 'Select id,Assigned_To__c, Old_Assigned_To__c,Assigned_To__r.Is_Active_Salesforce_User__c, Assigned_To__r.Salesforce_User__c, EventID__c,Any_Time__c,End__c,Mode__c,Notes__c,Overbooked__c,Resource_Type__c,'+
                       'Sale_Flag__c,Show_Time_As__c,Start__c,Subject__c,Time_Band__c,Type__c,Visit_Type__c,Opportunity__c,Who__c,Status__c  from Appointment__c Where Create_History__c = true and LastModifiedDate >= : startDate and LastModifiedDate <= :endDate';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        
        Map<Id, Appointment__c> eventIdAppointmentMap = new  Map<Id, Appointment__c>(); 
        
        list<Appointment_History__c> newHistoryList = new list<Appointment_History__c>();
        
        list<Appointment__c> upddateList = new List<Appointment__c>();
        
        for(sobject s: lstRecords)
        {
            Appointment__c app  = (Appointment__C)s;
            
            eventIdAppointmentMap.put(app.EventID__c, app);
            
            app.Create_History__c = false;
            upddateList.add(app);
            
            
            Appointment_History__c newHistory = new Appointment_History__c();
            newHistory.Any_Time__c = app.Any_Time__c;
            newHistory.Assigned_To__c = app.Assigned_To__c;
            newHistory.End__c = app.End__c;
            newHistory.Mode__c = app.Mode__c;
            newHistory.Notes__c = app.Notes__c;
            newHistory.Overbooked__c = app.Overbooked__c;
            newHistory.Resource_Type__c = app.Resource_Type__c;
            newHistory.Sale_Flag__c = app.Sale_Flag__c;
            newHistory.Show_Time_As__c = app.Show_Time_As__c;
            newHistory.Start__c = app.Start__c;
            newHistory.Status_Reason__c = app.Status_Reason__c;
            newHistory.Status__c = app.Status__c;
            newHistory.Subject__c = app.Subject__c;
            newHistory.Time_Band__c = app.Time_Band__c;
            newHistory.Type__c = app.Type__c;
            newHistory.Visit_Type__c = app.Visit_Type__c;
            newHistory.WhatID__c = app.Opportunity__c;
            newHistory.WhoId__c = app.Who__c;
            if(app.Status__c == 'Cancelled')
            {
                newHistory.History_Type__c = 'Appointment Status Changed';
            }else
            {
                newHistory.History_Type__c = 'Appointment Reassignment';
            }
            newHistory.Appointment__c = app.Id;
            newHistoryList.add(newHistory);
            
        }
        
        cls_IsRun.appointmentSwitch = true;
        Lock.lock = true;
        if(upddateList.size()>0)
        update upddateList;
        
        if(newHistoryList.size()>0)
        insert newHistoryList;
        
        
        list<Event> eventUpdateList = new list<Event>();
         
        for(Event e: [select id,OwnerId  from Event Where Id in: eventIdAppointmentMap.keyset()])
        {
            if(eventIdAppointmentMap.get(e.Id).Assigned_To__r.Is_Active_Salesforce_User__c != 'false')
            {
                id assig = eventIdAppointmentMap.get(e.Id).Assigned_To__r.Salesforce_User__c;
                if(assig!=null && e.OwnerId!=assig)
                e.OwnerId = assig;
                e.StartDateTime = eventIdAppointmentMap.get(e.Id).Start__c;
                e.EndDateTime = eventIdAppointmentMap.get(e.Id).End__c;
                eventUpdateList.add(e);
            }
        }
        
        if(eventUpdateList.size()>0)
        update eventUpdateList;
        
        
    }
     
    global void finish(Database.BatchableContext BC){}
   

}