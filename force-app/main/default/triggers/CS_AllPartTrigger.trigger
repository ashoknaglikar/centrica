trigger CS_AllPartTrigger on CS_Part__c (after insert, after update, before update) {
    
    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers != null && notriggers.Flag__c) {
        return;
    }

    if (Trigger.isBefore) {

        if(Trigger.isUpdate) {
            Map<Id,CS_Part__c> toBeDeactivated = new Map<Id,CS_Part__c>();
            Map<Id,CS_Part__c> toBeActivated = new Map<Id,CS_Part__c>();

            for (CS_Part__c part : Trigger.newMap.values()) {
                Boolean isActive  = part.Active__c;
                Boolean wasActive = Trigger.oldMap.get(part.Id).Active__c;

                Boolean isToBeDeactivated = wasActive && !isActive;
                Boolean isToBeActivated   = !wasActive && isActive;

                if (isToBeDeactivated) {
                    toBeDeactivated.put(part.Id, part);
                }
                if (isToBeActivated) {
                    toBeActivated.put(part.Id, part);
                }
            }

            if(CS_checkPartPriceRecursion.runOnce()) {
                CS_AllPartTriggerHelper.validatePartActivation(toBeActivated);
                CS_AllPartTriggerHelper.validatePartDeactivation(toBeDeactivated);
            }
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isUpdate) {

            CS_AllPartTriggerHelper.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
            CS_AllPartTriggerHelper.touchBundlePartAssociations(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isInsert) {

            CS_AllPartTriggerHelper.handleAfterInsert(Trigger.newMap);
             
        }        
    }   
}