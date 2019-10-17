trigger CS_AllPartDiscountCategoryTriggers on CS_Part_Discount_Category__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	// Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
    	if (Trigger.isAfter)
    	{
    		if (Trigger.isDelete) 
	        {
	            CS_AllPartDiscountCategoryTriggersHelper.updatePartDiscountCategories(Trigger.oldMap); 
	        }
	        else
	        {        
	            CS_AllPartDiscountCategoryTriggersHelper.updatePartDiscountCategories(Trigger.newMap);
	        }
    	}
    }
}