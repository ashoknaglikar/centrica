/* CheckRelatedAppointmentHistories class

	A class that holds methods that handle operations on Appointment Histories. 
	Mostly, this is used when Contact or Opportunities are updated and 
	Appointment Histories are created for Appointments relating to the 
	Contact/Opportunity.

*/

public class CheckRelatedAppointmentHistories {

	/* handleResults(Database.SaveResult[], Appointment_History__c[])
		
		Method that processes results from Database operations in this class.
		
		We need to check the object that was operated on to determine which
		object to report the error on. This is because, the methods in this 
		class may be called from triggers on different objects (Contacts,
		Opportunities, Appointment Histories).   
		  		
	*/
	private static void handleResults(Database.SaveResult[] results, Appointment_History__c[] appHistories) {
		Integer ctr = 0;
		
		// Loop over the results
		for(Database.SaveResult result : results) {
			if(!result.isSuccess()) {
				// If the result was not successful, get the error
				Database.Error err = result.getErrors()[0];
				System.debug('Error: ' + err);
				System.debug('Problem Appointment History: ' + appHistories[ctr]);
								
				// We now need to report the error to the user by adding the error to the object the user
				// was trying to act upon. However, this method is called when operating on a number
				// of different types of object, so we need to work out what the type of object is, get 
				// the specific object and then add the error to that object.
				
				// The objects being operated on are in Trigger.newMap - we can use different fields on 
				// the Appointment History that was unsuccessfully operated on to determine what type of
				// object the Appointment History belongs to.
				
				if(Trigger.newMap.containsKey(appHistories[ctr].Appointment__c)) { // Appointment
					// If Trigger.newMap contains a key with the value of the Appointment History's Appointment
					// field, the object we need to report on is an Appointment 
					Appointment__c appErr = (Appointment__c) Trigger.newMap.get(appHistories[ctr].Appointment__c);
					System.debug('Error with Appointment update: ' + err);
					appErr.addError('Error with Appointment update: ' + err.getMessage());					
				} else if(Trigger.newMap.containsKey(appHistories[ctr].WhoID__c)) { // Contact
					// If Trigger.newMap contains a key with the value of the Appointment History's WhoID
					// field, the object we need to report on is a Contact
					Contact contactErr = (Contact) Trigger.newMap.get(appHistories[ctr].WhoID__c);
					System.debug('Error with Contact update: ' + err);
					contactErr.addError('Error with Contact update: ' + err.getMessage());					
				} else if(Trigger.newMap.containsKey(appHistories[ctr].WhatID__c)) { // Opportunity
					// If Trigger.newMap contains a key with the value of the Appointment History's WhatID
					// field, the object we need to report on is an Opportunity
					Opportunity oppErr = (Opportunity) Trigger.newMap.get(appHistories[ctr].WhatID__c);
					System.debug('Error with Opportunity update: ' + err);
					oppErr.addError('Error with Opportunity update: ' + err.getMessage());					
				} else if(Trigger.newMap.containsKey(appHistories[ctr].Id)) { // Appointment History
					// If Trigger.newMap contains a key with the value of the Appointment History ID, then
					// the object we need to report on is an Appointment History  
					Appointment_History__c appHistoryErr = (Appointment_History__c) Trigger.newMap.get(appHistories[ctr].Id);
					System.debug('Error with Appointment History update: ' + err);
					appHistoryErr.addError('Error with Appointment History update: ' + err.getMessage());
				} else {
					// If none of the above are true, try and report a problem on the Appointment History.
					// This may not work but the error will be thrown back and should be caught in a try/catch block.
					System.debug('Couldn\'t determine what object was being inserted or updated:' + err);
					appHistories[ctr].addError('There was a problem with an Appointment History object: ' + err.getMessage());
				}
			}
			ctr++;
		}
	}

	/* createAppointmentHistroy(Appointment__c)
	
		Method that takes an Appointment object and creates an Appointment History object for it.
	
	*/	
	private static Appointment_History__c createAppointmentHistory(Appointment__c app) {
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
							WhoId__c = app.Who__c);
		return newHistory;
	}

	/* copyAppointmentHistory(Appointment_History__c, Appointment_History__c)
	
		Copies one Appointment History object to another. Both Appointment Histories
		are passed into the method - the values of the first are copied to the second 
		and then the second is returned.
	
	*/
	private static Appointment_History__c copyAppointmentHistory(Appointment_History__c oFrom, Appointment_History__c oTo) {
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
	
	/* updateRelatedHistories(Map<ID, Appointment__c>)
	
		A method that changes the value in the Do Not Send To Premier field on Appointment
		History objects related to the Appointments passed into the method. This is
		because, when creating an Appointment History, the value in the Do Not Send To
		Premier field should be the same across all Appointment Histories (and of course,
		they should reflect the value in the Appointment object).
		
		This method is used when updating Appointments.
		
	*/
	public static void updateRelatedHistories(Map<ID, Appointment__c> appsToUpdate) {
		System.debug('Entered updateRelatedHistories()');
		
		// Extract the Appointment Histories related to the Appointments in the Map
		// passed into the method
		Appointment_History__c[] hists = [SELECT a.Appointment__c, a.Do_Not_Send_To_Premier__c
										FROM Appointment_History__c a 
										WHERE a.Appointment__c IN :appsToUpdate.keySet()];
		
		// We now loop over the Appointment Histories extracted above, change the
		// value as appropriate
		for(Appointment_History__c hist : hists) {
			// We get the value from the "old" version of the object (i.e. from 
			// Trigger.oldMap rather than Trigger.newMap). 
			Appointment__c oldApp = (Appointment__c) Trigger.oldMap.get(hist.Appointment__c);
			
			if(oldApp.Do_Not_Send_To_Premier__c)
				hist.Do_Not_Send_To_Premier__c = false;
			else
				hist.Do_Not_Send_To_Premier__c = true;
		}
		
		// Now update the histories in the database
		try {
			if(!hists.isEmpty()) {
				System.debug('Updating histories');
				Database.SaveResult[] results = Database.update(hists, false);
				handleResults(results, hists);
			}
		} catch (Exception exc) {
			// If there is a problem, report to the user
			for(sObject s : Trigger.new) {
				Appointment__c app = (Appointment__c) s;
				app.addError('Couldn\'t update Appointment History when updating Appointment');
				System.debug('Exception thrown trying to update Appointment History ' + 
							'when updating Appointment: ' + exc);
			}
		}
	}

	/* checkRelatedHistories()
	
		A method that checks that all Appointment Histories related to an Appointment
		have the same value for the Do Not Send To Premier field. If the value on the
		Appointment has changed, we update all the related Appointment Histories.
		
		This method is called when Appointment Histories are created (from the
		Appointment History Insert trigger)
	
	*/
	public static void checkRelatedHistories() {
		
		Map<ID, Appointment_History__c> insertedHistories = new Map<ID, Appointment_History__c>();
		Map<ID, Appointment_History__c> updatedHistories  = new Map<ID, Appointment_History__c>();		

		// Loop over the newly inserted Appointment Histories and store them in a map		
		for(sObject temp : Trigger.new) {
			Appointment_History__c ah = (Appointment_History__c) temp;  
			insertedHistories.put(ah.Appointment__c, ah);
		}
		
		// Get the related Appointment Histories from the database
		// This will be all related histories for all Appointment Histories being inserted
		Appointment_History__c[] relatedHistories = [SELECT a.id, a.Appointment__c, 
													a.Do_Not_Send_To_Premier__c 
													FROM Appointment_History__c a
													WHERE a.Appointment__c IN :insertedHistories.keySet()];
													
		if(!relatedHistories.isEmpty()) {
			System.debug('Found related Appointment History object(s): ' + relatedHistories.size());
			// Loop over the related histories we've just retrieved 
			for(Appointment_History__c relatedHistory : relatedHistories) {
				// For each related history, get the history that is being inserted.
				Appointment_History__c inserted = insertedHistories.get(relatedHistory.Appointment__c);
				if(relatedHistory.Id != inserted.Id) {
					// Compare the Download To Premier flag of the inserted history with
					// the related history's flag
					if(relatedHistory.Do_Not_Send_To_Premier__c != inserted.Do_Not_Send_To_Premier__c) {
						System.debug('Do_Not_Send_To_Premier is different has changed');
						// Download To Premier flag has changed, update this Appointment History item
						// to match the inserted history
						relatedHistory.Do_Not_Send_To_Premier__c = inserted.Do_Not_Send_To_Premier__c;
						// Add to a list for update
						updatedHistories.put(inserted.Id, relatedHistory);
					}
				}
			}
		}
		
		try {
			if(!updatedHistories.isEmpty()) {
				System.debug('There are Appointment Histories to update');
				Appointment_History__c[] historiesList = updatedHistories.values();
				Database.SaveResult[] results = Database.update(historiesList, false);
				handleResults(results, historiesList);				
			}
		} catch (Exception exc) {
			// Shouldn't reach this point...
			for(Appointment_History__c ah : insertedHistories.values()) {
				ah.addError('Couldn\'t insert Appointment History when updating Appointment: ' + exc);
				System.debug('Exception thrown trying to insert Appointment History ' + 
							'when updating Appointment: ' + exc);
			}		
		}		
	}


	/* createAppointmentHistoriesOnUpdate(Appointment__c, String)

		A method for creating Appointment Histories when Contacts or Opportunities are updated.
		The String passed in is displayed on the Appointment History as the reason for the 
		Appointment History being created.
		
		The Appointments passed into the method are the Appointments that meet the criteria
		for Appointment History creation.
		
		For example, when an Opportunity is updated, any Appointments against that Opportunity 
		that have a Status of New or Appointed and have a Start Date in the future should have
		an Appointment History created.
		
		This method assumes that the Appointments passed in meet the criteria for Appointment
		History creation i.e. it is up to the calling method to make sure that the Appointments
		passed in need Appointment Histories created. 
			
	*/
	public static void createAppointmentHistoriesOnUpdate(Appointment__c[] apps, String historyType) {
		
		Map<ID, List<Appointment_History__c>> apptHistories = new Map<ID, List<Appointment_History__c>>();
		List<Appointment_History__c> apptHistoriesToUpdate = new List<Appointment_History__c> ();
		
		for(Appointment__c app : apps) {
					
			System.debug('New or Appointed App, Start is future');
			
			// Create the Appointment History and populate the History_Type__c field
			Appointment_History__c appHistory = createAppointmentHistory(app);
			appHistory.History_Type__c = historyType;

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
							apptHistoriesToUpdate.add(ah);
							tempAppHistoryList.add(ah);
						}
						else {
							System.debug('Appointment History didn\'t have Id, will insert: ' + ah);
							
							// Check if there are already Appointment Histories related to this
							// Appointment that we are inserting - if so, we need to add it to
							// the list associated with the Appointment. If not, create a new one.
							if(apptHistories.containsKey(app.Id)) {
								System.debug('appHistories.containsKey() is true');
								List<Appointment_History__c> ahList = apptHistories.get(app.Id);
								ahList.add(appHistory);	
								apptHistories.put(app.Id, ahList);
								//Lock.appHistories.put(app.Id, ahList); // No longer needed
							} else {
								System.debug('appHistories.containsKey() is false');
								apptHistories.put(app.Id, new Appointment_History__c[]{appHistory});
								//Lock.appHistories.put(app.Id, new Appointment_History__c[]{appHistory}); // No longer needed
							}
							System.debug('Adding appHistory to tempAppHistoryList, this is also the Appointment ' +
										 'History to be inserted: ' + appHistory);							
							// Add Appointment History back into the list
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
					if(apptHistories.containsKey(app.Id)) {
						System.debug('apptHistories.containsKey is true');
						apptHistories.put(app.Id, tempAppHistoryList);
						//Lock.appHistories.put(app.Id, tempAppHistoryList);	
					} else {
						System.debug('apptHistories.containsKey is false');
						apptHistories.put(app.Id, new Appointment_History__c[]{appHistory});
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
				apptHistories.put(app.Id, new Appointment_History__c[]{appHistory});
				Lock.appHistories.put(app.Id, new Appointment_History__c[]{appHistory});							
			}
		}

		// Now insert any Appointment Histories in apptHistories
		try {
			if(!apptHistories.isEmpty()) {
				System.debug('Inserting apptHistories: apptHistories is not empty');
				
				// Create a list with all the Appointment Histories to be inserted
				Appointment_History__c[] appHistoriesList = new Appointment_History__c[]{};
				for(List<Appointment_History__c> ahl : apptHistories.values()) {
					appHistoriesList.addall(ahl);
				}
				
				// Insert Appointment Histories and process results
				Database.SaveResult[] results = Database.insert(appHistoriesList, false);
				handleResults(results, appHistoriesList);
			}
		}
		catch (Exception exc) {
			// Error handling in case handleResults is unable to process results
			for(Appointment__c s : apps) {				
				System.debug('Exception thrown trying to insert Appointment History ' + 
							'when updating ' + s.getSObjectType() + ': ' + exc);
				s.addError('Couldn\'t insert Appointment History when inserting ');
			}
		}
		
		// And now update any Appointment Histories in apptHistoriesToUpdate
		try {
			if(!apptHistoriesToUpdate.isEmpty()) {
				// Update Appointment Histories and process results
				Database.SaveResult[] results = Database.update(apptHistoriesToUpdate, false);
				handleResults(results, apptHistoriesToUpdate);
			}
		}
		catch (Exception exc) {
			// Error handling in case handleResults is unable to process results
			for(Appointment__c s : apps) {
				System.debug('Exception thrown trying to update Appointment History ' + 
							'when updating ' + s.getSObjectType() + ': ' + exc);				
				s.addError('Couldn\'t update Appointment History when updating ');// + s.getSObjectType());
			}
		}		
	}
}