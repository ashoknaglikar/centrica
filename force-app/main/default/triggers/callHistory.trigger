trigger callHistory on Call_History__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    if(Lock.callHistory)
    return;
    
    if(system.label.CallHistory == 'on' && trigger.isBefore)
    {
        if(trigger.isInsert || trigger.isUpdate) 
        {
            Lock.employeeTrigger = true;
            Lock.callHistory =true;
            callHistoryTriggerHelper.processBeforeInsert(trigger.new, trigger.oldmap);
        }
        
    }

}