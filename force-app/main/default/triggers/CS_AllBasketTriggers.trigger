trigger CS_AllBasketTriggers on cscfga__Product_Basket__c (before update) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isUpdate && Trigger.isBefore) {
            CS_AllBasketTriggersHelper.handleBeforeUpdate(trigger.oldMap, trigger.newMap);
        }
    }
}