/* AppointmentHistoryInsert Trigger

	Trigger that fires when an Appointment History is inserted. Two actions need to happen
	
	1/ When	Appointment Histories are inserted, we need to check other Appointment
	Histories related to the same Appointment, to ensure that the Do Not
	Send To Premier field is the same across all Appointment Histories 
	on an Appointment.
	
	2/ If the appointment history is of type 'Appointment Reassignment' and appointment data 
	has already been loaded into Big Machines. The following actions need to take place:
		
	- Cancel the quote in Big Machines (BM) associated with the appointment/previous appointment owner.
	- Create a new Quote in BM associated with the new appointment owner and write transaction ID to the appointment record (overwrite the previous one)
	- If the re-assignment is for an in-day appointment, or if it isnt in-day but the attempt to cancel the existing BM quote
	  fails due to it being checked out, then flag the records (check box) so workflow sends a Text mail the old employee and new employee (assigned from and to) to inform them
	  of the change of appointment.

*/

trigger AppointmentHistoryInsert on Appointment_History__c (after insert) {
	
	///
	//ACTION 1 - check other Appointment Histories related to the same Appointment, to ensure that the Do Not
	//Send To Premier field is the same across all Appointment Histories on an Appointment.
	///
	///
	CheckRelatedAppointmentHistories.checkRelatedHistories();
	
	///
	//ACTION 2 - If is a re-assigned appointment and data has been sent to Big Machines make 
	//SOAP calls to update Big Machines Quotes.
	///
	BigMachinesUpdateAfterApptReassign.updateBM(trigger.new);
}