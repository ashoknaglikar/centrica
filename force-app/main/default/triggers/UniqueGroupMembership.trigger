trigger UniqueGroupMembership on Employee_Group__c (before insert, before update) {
	List<Id> groupIds = new List<Id>();
    for(Employee_Group__c eg : trigger.new){
    	groupIds.add(eg.Group__c);
    }
    
    List<Employee_Group__c> egs = [select group__c, employee__c from Employee_Group__c where Group__c in :groupIds];
    
    for(Employee_Group__c eg : trigger.new){
    	for(Employee_Group__c member : egs){
    		if(member.employee__c == eg.employee__c && eg.Group__c == member.Group__c){
    			if(trigger.isInsert || trigger.isUpdate && member.Id != eg.Id){
    				eg.addError('This employee is already a member of this group.');
    				break;
    			}
    		}
    	}
    }

}