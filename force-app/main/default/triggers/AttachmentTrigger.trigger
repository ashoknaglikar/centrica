trigger AttachmentTrigger on Attachment (after delete, after insert, after update, before delete, before insert, before update)
{
    // Disable Trigger if required
    if (Label.DisableAttachmentTrigger.toUpperCase() == 'TRUE' )
    {
        return;
    }
    
    // Instantiate a hander appropriate to the target object
    TriggerHandler.ITrigger handler = new AttachmentHandler(Trigger.oldMap, Trigger.newMap, Trigger.old, Trigger.new);
    
    // If we are in the Before trigger
    if (Trigger.isBefore)
    {
        // call the bulk load method for the Before trigger
        handler.bulkBefore();
        
        // process the the items for deletion
        if (Trigger.isDelete)
        {
            if(label.SystemAdminId.contains(userinfo.getProfileId()))   
            return;
            for (SObject so : Trigger.old)
            {
                handler.beforeDelete(so);
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
            if(label.SystemAdminId.contains(userinfo.getProfileId()))   
            return;
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

            //call CS trigger helper method for populating BM quotes
            CS_AllAttachmentTriggerHelper.createBMQuoteAndQuoteProducts(Trigger.newMap);
        }
        else if (Trigger.isUpdate) // process the the items for Update
        {
            for (SObject so : Trigger.old)
            {
                handler.afterUpdate(so, Trigger.newMap.get(so.Id));
            }

            //call CS trigger helper method for populating BM quotes
            CS_AllAttachmentTriggerHelper.createBMQuoteAndQuoteProducts(Trigger.newMap);
        }
        
        // call the method for any post processing operations such as updating other objects.
        handler.postProcessing();
    }
}