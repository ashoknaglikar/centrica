trigger checkApptOnContact on Contact (before delete) {
	
	List<Contact> contactList = new List<Contact>();
	
	Appointment__c[] appts = [Select a.Who__c from Appointment__c a where Who__c in :Trigger.old 
	                                               and RecordTypeId = '012200000004iOK' and Status__c = 'Appointed'];

	for(Contact c:Trigger.old){
		contactList.add(c);
	}
	
	if(appts.size()>0){
		
		for(Appointment__c appt:appts){
			
			for(Contact c:contactList){
				
				 if(appt.Who__c == c.Id){
				 	
				 	c.addError('Please cancel the corresponding appointment before deleting this contact.');
				 	
				 }
				
			}
			
		}
		
	}

}