/*  Class called after an Appointment_History Insert. 
	
	This is for when an appointment is reassigned. If the appointment history is of type 'Appointment Reassignment' and appointment data 
	has already been loaded into Big Machines. The following actions need to take place:
		
	- Cancel the quote in Big Machines (BM) associated with the appointment/previous appointment owner.
	- Create a new Quote in BM associated with the new appointment owner and write transaction ID to the appointment record (overwrite the previous one)
	- If the re-assignment is for an in-day appointment, or if it isnt in-day but the attempt to cancel the existing BM quote
	  fails due to it being checked out, then flag the records (check box) so workflow sends a Text mail the old employee and new employee (assigned from and to) to inform them
	  of the change of appointment.

*/


public class BigMachinesUpdateAfterApptReassign {
	
	public static void updateBM(Appointment_History__c[] triggerApps){

		System.debug('Trigger.new size is: '+triggerApps.size());	
		//check static lock to ensure only one callout is made to cancel the current quote and create a new one
		
		System.debug('Lock.appointmentReassignmentIsLocked status is: ' + Lock.appointmentReassignmentIsLocked);	
		if(Lock.appointmentReassignmentIsLocked != true){	
						
			//Get the associated appointment ID of all the appointment histories in trigger.new
			Set<Id> appointment_ids = new Set<Id>();
			for(Appointment_History__c ah : triggerApps){
				 // CR - Create App History For Survey + Unavailable Appts Created As Part Of Phase IV
			    if(ah.History_Type__c == 'Survey unv appointment created'){
			         continue;
			      }
				appointment_ids.add(ah.Appointment__c);
			}		
			
			Map<Id, Appointment__c> appointments = new Map<Id, Appointment__c>([select id, SentToBM__c, LoadedInBM__c from Appointment__c where id IN :appointment_ids]);
			
			//Due to Http Callout limits in SFDC we can only process one appointment. If trigger is a bulk trigger we cannot process the request.
			System.debug('appointments array size is: '+appointments.size());
			if(appointments.size() == 1)									
				//process each Appointment History to find ones that have been created due to reassignment of an appointed appointment
				for(Appointment_History__c app_hist : triggerApps) {				
					if(app_hist.History_Type__c == 'Appointment Reassignment' && app_hist.Status__c == 'Appointed'){
						Appointment__c app = appointments.get(app_hist.Appointment__c);	
						//if the appointment has been sent to Big Machines
						if(app.SentToBM__c || app.LoadedInBM__c){				
							//call future method to make the http callouts to BM to cancel quote and create new quote. method flags record if textmail required also.
							List<ID> appList = new List<ID>{app.Id};
							//BigMachinesQuoteInterface.updateBigMachinesWhenAppReassigned(appList, app_hist.Previous_Assigned_To_Textmail__c);				
							System.debug('Apex future method to update big machines due to a reassigned appointment has been called');
							//set lock to true so any recursive trigger action doe not send more callouts to Big Machines
							Lock.appointmentReassignmentIsLocked = true;
							System.debug('Lock.appointmentReassignmentIsLocked status is: ' + Lock.appointmentReassignmentIsLocked);																	
						}
					}				
				}			
		}
	}
}