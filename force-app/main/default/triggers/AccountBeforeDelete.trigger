/* AccountBeforeDelete Trigger

	This trigger deletes Appointments relating to an Account when that
	Account is deleted.
	
	The reason for this is that when an Account is deleted, children of
	the Account are deleted (i.e. Tasks, Events, Contacts, CHI Leads etc).
	When Events are deleted this way, the EventDelete trigger does not
	fire - this was confirmed by Salesforce as standard behaviour. This
	leaves orphaned Appointment objects.
	
	To overcome this, when an Account is deleted, this trigger fires, 
	retrieves the related Appointments and deletes them.
	
	The other child objects of Account will be deleted as per normal.

*/

trigger AccountBeforeDelete on Account (before delete) {
	
	if(cls_IsRun.generalTriggerSwitch)
	{
		return;
	}
	
	// Retrieve Opportunities related to the Accounts being deleted from the Database
	Opportunity[] opps = [SELECT o.Id,AccountId FROM Opportunity o WHERE o.AccountID IN :Trigger.oldMap.keySet()];
	System.debug('Number of related Opportunities: ' + opps.size());
	
	// Populate a Map with the Opportunity objects
	Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();
	
	for(Opportunity opp : opps) {
		oppMap.put(opp.Id, opp);
	}
	
	// Now retrieve Appointments related to those Opportunities
	Appointment__c[] apps = [SELECT a.Id, a.Opportunity__c FROM Appointment__c a WHERE a.Opportunity__c IN :oppMap.keySet()];
	System.debug('Number of related Appointments: ' + apps.size());
	
	// Now delete those Appointments
	Database.DeleteResult[] results = Database.delete(apps, false);
	
	// Process the results
	Integer ctr = 0;
	for(Database.DeleteResult result : results) {
		if(!result.isSuccess()) {
			Appointment__c app = apps[ctr];
			Account account = Trigger.oldMap.get(oppMap.get(app.Opportunity__c).AccountId);
			account.addError('There was an error trying to delete a related Appointment when ' + 
							'trying to delete an Account: ' + result.getErrors()[0].getMessage());
			System.debug('Unable to delete an Appointment when trying to delete an Account: ' + result.getErrors()[0]);
		}
		ctr++;
	}
}