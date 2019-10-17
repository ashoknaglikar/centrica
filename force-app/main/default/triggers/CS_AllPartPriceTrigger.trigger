trigger CS_AllPartPriceTrigger on CS_Part_Price__c (before insert, before update, after insert, after update) {
    
    // do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers != null && notriggers.Flag__c)
    {
        return;
    }
    
    Map<Id, CS_Part_Price__c> mapPartPricesNew;

    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate) {
            if(CS_checkPartPriceRecursion.runOnce()) {
                CS_AllPartTriggerHelper.ensureNationalPartPrice(Trigger.newMap);
            }
        }
        if(Trigger.isInsert) {
            /*if(CS_checkPartPriceRecursion.runOnce())*/ {
                CS_AllPartTriggerHelper.ensureNationalPartPrice(Trigger.newMap);
            }
        }
    }
}