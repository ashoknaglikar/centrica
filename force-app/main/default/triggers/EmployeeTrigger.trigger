trigger EmployeeTrigger on Employee__c (after insert, after undelete, after update, 
before insert, before update) {
    
    if(Lock.employeeTrigger)
    return;
    
    if(trigger.isAfter && system.label.callHistory == 'on')
    {
        Lock.callHistory = true;
        if(trigger.isInsert)
        {
            EmployeeTriggerHelper.processBeforeInsert(trigger.new, trigger.newmap); 
        }
        else if(trigger.isUpdate)
        {
            EmployeeTriggerHelper.processBeforeUpdate(trigger.new, trigger.newmap, trigger.old, trigger.oldmap); 
        }
        
    }

}