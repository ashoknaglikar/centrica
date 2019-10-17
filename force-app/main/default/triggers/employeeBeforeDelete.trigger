trigger employeeBeforeDelete on Employee__c (before delete) {
	
	Profile p = [Select ID from Profile where Name = 'System Administrator'];
	
	if(System.Userinfo.getProfileId() == p.ID){
		
		System.debug('Profile is system administrator so take no action.');
		
	}else {
		
    	for(Employee__c emp:Trigger.old){
    		
			emp.addError('You do not have sufficient privileges to delete this record.');
			
	     	}
	     	
	}
	
}