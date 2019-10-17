trigger CS_AllDiscountCategoryTriggers on CS_Discount_Category__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
	// Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    {
    	Map<Id,CS_Discount_Category__c> dcImpactList = new Map<Id,CS_Discount_Category__c>();
    	
    	if (Trigger.isBefore && Trigger.isDelete)
    	{
    		CS_AllPartDiscountCategoryTriggersHelper.updatePartDiscountCategoriesDelChanges(Trigger.oldMap);
    	}
    	else if (Trigger.isAfter) 
	    {
	        if (Trigger.isUnDelete)
	        {        
	            CS_AllPartDiscountCategoryTriggersHelper.updatePartDiscountCategoriesChanges(Trigger.newMap);
	        }
	        // Only Name change is relevant
	        else if (Trigger.isUpdate)
	        {
	        	for (Integer i=0; i<trigger.new.size(); i++)
	        	{
	        		if (trigger.old[i].Name != trigger.new[i].Name)
	        		{
	        			dcImpactList.put(trigger.new[i].Id,trigger.new[i]);
	        		}
	        	}        
	            CS_AllPartDiscountCategoryTriggersHelper.updatePartDiscountCategoriesChanges(dcImpactList);
	        }
    	}
    }
}