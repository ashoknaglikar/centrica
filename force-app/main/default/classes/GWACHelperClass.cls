public with sharing class GWACHelperClass {
	
     
    public String methodForGWAC_PopulateClass(List<Rate_Card_Items__c> rateCardsItems){
        
        String sresult='';
        system.debug('Ratecard ----->'+rateCardsItems.size());
        system.debug('Ratecard ----->'+rateCardsItems);
        
        if(rateCardsItems != null && rateCardsItems.size() > 0)
        {
            
            Map<String, Supplier__c> supplierIdMap = new Map<String, Supplier__c>();
            Map<String, Double> supplierCostMap = new Map<String, Double>();
            Map<String,Integer> noOfActiveRateCardItems=new Map<String,Integer>();
            Boolean isDataValid = true;
            boolean obj=false;
            
            for(Rate_Card_Items__c r :rateCardsItems)
            {
            	Integer count = 0;
            	
            	if(noOfActiveRateCardItems.containsKey(r.Rate_Card__c))
            	{
            		count = noOfActiveRateCardItems.get(r.Rate_Card__c);
            	}
            	if(r.Status__c == 'Active')
            	{
            		noOfActiveRateCardItems.put(r.Rate_Card__c, count++);
            	}
            }
            
            //check in map if there are more than 1 ratecarditem in active state for a ratecard
			for(Integer activeCount :noOfActiveRateCardItems.values())
        	{
        		if(activeCount > 1)
        		{
        			isDataValid = false;
        			break;
        		}
        	}
            
         
            if(!isDataValid)
            {
            	sresult= 'There are multiple rate card items active for the Rate card';	
            }
            else
        	{
	            for(Rate_Card_Items__c r:rateCardsItems)
	            {
	            	
	            	//---------------------Create supplier map
	                supplierIdMap.Put(r.Rate_Card__r.P5_Supplier__c, r.Rate_Card__r.P5_Supplier__r);
	                
	                //---------------------Calculate total cost for each supplier
	                //If Cost is not null AND Rate Card is not null AND Supplier of Rate Card is not null
	                //Add the cost of product to Supplier map
	                if(r.Cost__c != null && r.Rate_Card__r != null && 
	                    r.Rate_Card__r.P5_Supplier__c != null)
	                {
	                    Double TotalCost = 0;
	                    //Check if some value already exists for current suplier
	                    if(supplierCostMap.containsKey(r.Rate_Card__r.P5_Supplier__c))
	                    {
	                        //Value exists; retrieve the value
	                        TotalCost = supplierCostMap.get(r.Rate_Card__r.P5_Supplier__c);
	                    }
	                    //Add the current value to map value
	                    TotalCost += r.Cost__c;
	                    
	                    //Place new value on map
	                    supplierCostMap.put(r.Rate_Card__r.P5_Supplier__c, TotalCost);
	                }
	                
	                
	            }
	            
	            Double gWavValue = 0;
	            
	            //For each supplier calculate GWAC from market allocation
	            for(String supplierID :supplierCostMap.keySet())
	            {
	                Supplier__c currentSupplier = supplierIdMap.get(supplierID); 
	                if(currentSupplier.Market_Allocation__c!=null) 
	                {
	                	
	                    gWavValue += (Double) supplierCostMap.get(supplierID) * (currentSupplier.Market_Allocation__c / 100);
	                }
	                else
	                {
	                	sresult='% Market Allocation value of any related supplier cannot be  null or zero please specify Allocation value for each supplier';
	                	obj=true;  
	                	system.debug('sresult1------'+sresult);
	                }  
	            }
	            if(obj==false)
	            {
	            Product_Order__c productOrder = rateCardsItems[0].Material__r;
	            productOrder.GWAC__c = gWavValue; 
	            update productOrder;
	         
	            sresult= 'success';
	            }
	            
        	}
            system.debug('Sresult------------>'+sresult);
         
        }
        else
        {
            sresult= 'There are no Ratecard items present or they are in "Inactive" status or product type supplier is not selected(Please select the supplier)';
            
            //return error
        }
        return sresult;
    }
    
    
    public void methodForBatchGWAC_PopulateClass(List<Rate_Card_Items__c> poRateCardItems){
        
        List<Product_Order__c> lstProductOrd = new List<Product_Order__c>();
        if(poRateCardItems != null && poRateCardItems.size() > 0) 
        {
            Map<String, Supplier__c> supplierIdMap = new Map<String, Supplier__c>();
            Map<String, Double> supplierCostMap = new Map<String, Double>();
            Map<String, Double> productOrderGWAC = new Map<String, Double>();
            Map<ID, Product_Order__c> productOrderMap = new Map<ID, Product_Order__c>();
            
            for(Rate_Card_Items__c r:poRateCardItems)
            {
                Double marketAllocation = r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c;
                system.debug('-------Market_Allocation__c------->'+r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c);
                
                //---------------------Calculate total cost for each supplier
                //If Cost is not null AND Rate Card is not null AND Supplier of Rate Card is not null
                //Add the cost of product to Supplier map
                system.debug('-------Rate Card Price------->'+r.Cost__c);
                if(r.Cost__c != null && r.Rate_Card__r != null && 
                    r.Rate_Card__r.P5_Supplier__c != null && marketAllocation!=null && marketAllocation!=0)
                {
                    Double TotalCost = 0;
                    
                    Double tempGWAC = 0;
                    //Check if some value already exists for current suplier
                    if(productOrderGWAC.containsKey(r.Material__c))
                        tempGWAC = productOrderGWAC.get(r.Material__c);
                    
                    tempGWAC += (r.Cost__c * (marketAllocation / 100));
                    system.debug('--->>tempGWAC' +tempGWAC);
                    //Putting the GWAC value in the temporary variable
                    productOrderGWAC.put(r.Material__c, tempGWAC);
                    //Putting the temp var in the GWAC Field of Product Order
                    if(!productOrderMap.containsKey(r.Material__c))
                    	 productOrderMap.put(r.Material__c, r.Material__r);
                    	 
                    system.debug('-------r.Material__c------->'+r.Material__c);
                    system.debug('-------r.Material__r------->'+r.Material__r);
                    /*Product_Order__c productOrder = r.Material__r;
                    productOrder.GWAC__c = productOrderGWAC.get(r.Material__c);
                    //updating productOrder
                    //update productOrder; 
                    
                    productOrder.GWAC__c += tempGWAC;  
                    productOrderGWAC.put(r.Material__c, productOrder);
                    
                    system.debug('----productOrder' +productOrder);
                    system.debug('-------GWAC Value------->'+productOrderGWAC.get(r.Material__c));
                    */
                }
                
                else{
                    system.debug('Condition not satisfied');
                }  
                
            }
            
            //set the product list
            for(ID poID :productOrderGWAC.keySet())
            {
            	Double tempGWAC = productOrderGWAC.get(poID);
            	system.debug('----poID' +poID);
            	system.debug('----productOrderMap' +productOrderMap.values());
            	system.debug('----tempGWAC' +tempGWAC);
            	
            	
            	Product_Order__c tempPO = productOrderMap.get(poID);            	
            	//if(tempPO.GWAC__c != null)
            	//{
            		tempPO.GWAC__c = tempGWAC;
            		
    	        	lstProductOrd.add(tempPO);
            	//}
            	
            }
           
            if (lstProductOrd.size() >0)
	        {
	        	update lstProductOrd;
	        }
            
        }
	}
}