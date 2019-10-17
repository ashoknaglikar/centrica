/* AppointmentInsert Trigger

    Trigger that happens after an Appointment Insert. Most of the work 
    happens in the AppointmentToEventSynchronisation class.

*/

trigger AppointmentInsert on Appointment__c (after insert) {
    
    // CR - Create App History For Survey + Unavailable Appts Created As Part Of Phase IV
    // Create an instance of the AppointmentToEventSynchronisation class
    // and run the insertAppointmentHistorySurveyUnv method 
    AppointmentToEventSynchronisation sync_survey_unv =
                    new AppointmentToEventSynchronisation();            
    //sync_survey_unv.insertAppointmentHistorySurveyUnv();
    
    // Check if Lock.lock is set - if so, Event Insert is running
    // and we don't want the code here to fire.
    if(Lock.lock) {
        System.debug('Lock.lock is true');
        return;
    }
    // Phase 5 : ADDED
    Map<String,Appointment__c> elementMap = new Map<String,Appointment__c>();
    Set<String> appIds = new Set<String>();
    Map<String,String> appJEMap = new Map<String,String>();
    Map<String,String> JEcodeIdMap = new Map<String,String>();
    String Assignedsupplier;
    String Assingedsupplierbranch;
    Datetime StartDate;
    Datetime CompletionDate;
    Set<Id> elementId = new Set<Id>();
    
    // ++ Created for Priority Installations change
    Map<ID,Appointment__c> oppIdApptMap = new Map<ID,Appointment__c>();
    List<Opportunity> opportunities = new List<Opportunity>();
    // -- Created for Priority Installations change
    
    for(Appointment__c app : Trigger.new){
        if(app.Job_Element__c != null){
            elementMap.put(app.Job_Element__c,app);
            appIds.add(app.Id);
            appJEMap.put(app.Job_Element__c,app.Id);
            elementId.add(app.Job_Element__c);
            StartDate = app.Start__c;
            CompletionDate = app.End__c;
        }
        
        // ++ Added for Prioirty Installations CR start 
    	oppIdApptMap.put(app.Opportunity__c, app);
    	// -- Added for Prioirty Installations CR end
        
    }
    if(elementMap.size() > 0){
    	BookItineraryApp.updateelementsAppFuture(elementId, appIds, appJEMap,Assignedsupplier,Assingedsupplierbranch, StartDate, CompletionDate);
    	       
    }
    // ++ Added for Prioirty Installations CR start
    for(Opportunity opp : [select id,CreatedDate from Opportunity where id in: oppIdApptMap.keySet()])
    {
    	if(cls_IsRun.istrg_CustApptAfterInsert)
    	{
    		return;
    	}
    	Appointment__c relatedAppt = oppIdApptMap.get(opp.id);
    	if((opp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date))
       	{
       		system.debug('------InsideAppt-----');
       		if(relatedAppt.Big_Machines_Quote_Number__c == null)
       		{
       			opp.Timeline_Options__c = relatedAppt.Timeline_Options__c;
	        	opp.Timeline_Reason__c = relatedAppt.Timeline_Reason__c;
	        	opp.Pending_update_to_customer_category__c = true;
	        	opp.Last_customer_cat_info_update_source__c = 'SGC';
	        	opp.Customer_Category_Modified_Datetime__c = Datetime.now();
		    	opp.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
		    	opp.Stage_object_type__c = 'Appointment';
		    	opp.Stage_object_id__c = relatedAppt.Id;
		    	opp.Sales_visit_date_time__c = relatedAppt.Start__c;
		    	opp.Date_time_appointment_booked__c = Datetime.now();
		    	opportunities.add(opp);
       		}
       		   		
       	}
    }
    if(opportunities.size() > 0)
    {
    	try{
    		cls_IsRun.setistrg_CustApptAfterInsert();
    		update opportunities;
    	}
    	catch(Exception ex)
    	{
    		system.debug('-----exception-----'+ex);
    	}
    }
    // -- Added for Prioirty Installations CR end
    
    // END : PHASE 5 ADDED
      
    // If we're still running, set the lock
    Lock.lock = true;
    System.debug('Lock.lock set');

    // Set a static variable to show if user is dataloader - this value
    // is used when creating Appointment Histories  
    if(UserInfo.getUserId() == '00520000000mTzkAAE') {
        System.debug('User is DataLoader');
        Lock.userIsNotDataloader = false;
    }

    // Create an instance of the AppointmentToEventSynchronisation class
    // and run the insertAppointment method 
    AppointmentToEventSynchronisation sync =
                    new AppointmentToEventSynchronisation();            
    sync.insertAppointment();
     
    // Clear the lock
    Lock.lock = false;
    System.debug('Lock.lock unset');
    
    // At the end of an Appointment Insert, Workflow will make changes to
    // the newly inserted Appointment, effectively updating the Appointment and
    // causing the Appointment Update trigger to fire. We use Lock.isReallyInsert 
    // in the Update trigger to see if we're actually inserting objects, because
    // if we are, we need the Update logic to behave differently. 
    
    Lock.isReallyInsert = true;
}