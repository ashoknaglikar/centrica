trigger SmartMeterTrigger on Smart_Meter__c (after delete, after insert, after update, before delete, before insert, before update) {

    // Instantiate a hander appropriate to the target object
    TriggerHandler.ITrigger handler = new SmartMeterHandler(Trigger.oldMap, Trigger.newMap, Trigger.old, Trigger.new);
   
    if(cls_IsRun.generalTriggerSwitch )
    {  
        return;
    }
    // If we are in the Before trigger
    if (Trigger.isBefore)
    {
        // call the bulk load method for the Before trigger
        handler.bulkBefore();
        
        // process the the items for deletion
        if (Trigger.isDelete)
        {
            for (SObject so : Trigger.old)
            {
               handler.beforeDelete(so);
               //system.debug('@@@@@@@@@@@Trigger');
            }
        }
        else if (Trigger.isInsert) // process the items for insert
        {
            for (SObject so : Trigger.new)
            {
                handler.beforeInsert(so);
            }
        }
        else if (Trigger.isUpdate) // process the items for update
        {
           
            
            for (SObject so : Trigger.old)
            {
                system.debug('@@cls_IsRun.callsmartmeter' + cls_IsRun.callsmartmeter);
                cls_IsRun.callsmartmeter = true;
                handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
            }
            
        }
    }
    else // we are in the After trigger
    {
        // call the bulk load method for the After trigger
        handler.bulkAfter();
        
        // process the the items for deletion
        if (Trigger.isDelete)
        {
            for (SObject so : Trigger.old)
            {
                handler.afterDelete(so);
            }
            
        }
        else if (Trigger.isInsert) // process the the items for Insert
        {
            for (SObject so : Trigger.new)
            {
                handler.afterInsert(so);
            }
        }
        else if (Trigger.isUpdate) // process the the items for Update
        {
        	system.debug('Inside -->1');
            for (SObject so : Trigger.old)
            {
            	system.debug('Inside --2>');
                handler.afterUpdate(so, Trigger.newMap.get(so.Id));
            }
        }
        
        // call the method for any post processing operations such as updating other objects.
        handler.postProcessing();
    }
}