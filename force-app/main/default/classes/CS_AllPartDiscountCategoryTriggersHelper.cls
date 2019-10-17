// **************************************************************************************************
// ************************************************************************************************** 
// *****																						***** 
// *****	Developer:		Ana Pejakovic														***** 
// *****	Created: 		03 April 2014														***** 
// *****	Last Update: 	03 April 2014														***** 
// *****																		    			***** 
// *****	Description:	Updating Discount Categories on CS Part	with a comma separated 		*****
// *****					list of Names of Discount Categories related to part				***** 
// *****					Used to flatten the Part structure for querying in offline			*****
// *****																						***** 
// ************************************************************************************************** 
// **************************************************************************************************

public class CS_AllPartDiscountCategoryTriggersHelper 
{
	
	// Method to update Discount Categories due to changes on Part Discount Categories junction records
	public static void updatePartDiscountCategories(Map<Id,CS_Part_Discount_Category__c> triggerMap)
	{               
	    system.debug('**** updatePartDiscountCategories called');
	    
        Set<Id> affectedPartIds 			= new Set<Id>();
        for(CS_Part_Discount_Category__c pdc : triggerMap.values())
        {
            affectedPartIds.add(pdc.CS_Part__c); 
        }
        
        List<CS_Part__c> partsToUpdate 		= [Select Id, Discount_Categories__c, 
                        					    (Select Id, CS_Part__c, CS_Discount_Category__c, CS_Discount_Category__r.Name 
                        					    From CS_Part_Discount_Categories__r) From CS_Part__c 
                        					where Id in: affectedPartIds];                                       
        for(CS_Part__c part : partsToUpdate)
        {
            Set<String> discountCategories 	= new Set<String>();
            for(CS_Part_Discount_Category__c pdc : part.CS_Part_Discount_Categories__r)
            {
                discountCategories.add(pdc.CS_Discount_Category__r.Name);
            }
            part.Discount_Categories__c 	= String.Join(new List<String>(discountCategories), ',');  
            
            system.debug('***** Discount_Categories__c are: ' + part.Discount_Categories__c);
        }       
        update partsToUpdate;           
    }
    
    // Method to update Discount Categories due to changes on Discount Categories records
    public static void updatePartDiscountCategoriesChanges(Map<Id,CS_Discount_Category__c> triggerMap)
    {
    	List<CS_Discount_Category__c> dcLst	= [Select Name, Id, (Select CS_Part__c From CS_Part_Discount_Categories__r) 
    										From CS_Discount_Category__c 
    										where Id in :triggerMap.keySet()];
    										
    	Set<Id> affectedPartIds 			= new Set<Id>();
        for(CS_Discount_Category__c dc : dcLst)
        {
        	if (dc.CS_Part_Discount_Categories__r.size() > 0)
        	{
        		for (CS_Part_Discount_Category__c pdc : dc.CS_Part_Discount_Categories__r)
	        	{
	        		affectedPartIds.add(pdc.CS_Part__c);
	        	} 
        	}
        }
        
        if (affectedPartIds.size() > 0)
        {
        	List<CS_Part__c> partsToUpdate 	= [Select Id, Discount_Categories__c, 
            								(Select Id, CS_Part__c, CS_Discount_Category__c, CS_Discount_Category__r.Name
            								From CS_Part_Discount_Categories__r) From CS_Part__c 
            								where Id in: affectedPartIds];
	        for(CS_Part__c part : partsToUpdate)
	        {
	            Set<String> discountCategories 	= new Set<String>();
	            for(CS_Part_Discount_Category__c pdc : part.CS_Part_Discount_Categories__r)
	            {
	                discountCategories.add(pdc.CS_Discount_Category__r.Name);
	            }
	            part.Discount_Categories__c 	= String.Join(new List<String>(discountCategories), ',');  
	        }       
	        update partsToUpdate;
		}
    }
    
    // Method to update Discount Categories due to deleting Discount Categories records
    public static void updatePartDiscountCategoriesDelChanges(Map<Id,CS_Discount_Category__c> triggerMap)
    {
    	List<CS_Discount_Category__c> dcLst	= [Select Name, Id, (Select CS_Part__c From CS_Part_Discount_Categories__r) 
    										From CS_Discount_Category__c 
    										where Id in :triggerMap.keySet()];
    										
    	Set<String> delDcSet				= new Set<String>();									
    	Set<Id> affectedPartIds 			= new Set<Id>();
    	
        for(CS_Discount_Category__c dc : dcLst)
        {
        	delDcSet.add(dc.Name);
        	if (dc.CS_Part_Discount_Categories__r.size() > 0)
        	{
        		for (CS_Part_Discount_Category__c pdc : dc.CS_Part_Discount_Categories__r)
	        	{
	        		affectedPartIds.add(pdc.CS_Part__c);
	        	} 
        	}
        }
        
        if (affectedPartIds.size() > 0)
        {
        	List<CS_Part__c> partsToUpdate 	= [Select Id, Discount_Categories__c, 
            								(Select Id, CS_Part__c, CS_Discount_Category__c, CS_Discount_Category__r.Name
            								From CS_Part_Discount_Categories__r) From CS_Part__c 
            								where Id in: affectedPartIds];
	        for(CS_Part__c part : partsToUpdate)
	        {
	            Set<String> discountCategories 	= new Set<String>();
	            for(CS_Part_Discount_Category__c pdc : part.CS_Part_Discount_Categories__r)
	            {
	                if (!delDcSet.contains(pdc.CS_Discount_Category__r.Name))
	                {
	                	discountCategories.add(pdc.CS_Discount_Category__r.Name);
	                }
	            }
	            part.Discount_Categories__c 	= String.Join(new List<String>(discountCategories), ',');  
	        }       
	        update partsToUpdate;
		}
    }
    
}