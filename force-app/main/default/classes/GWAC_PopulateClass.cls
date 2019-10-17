global class GWAC_PopulateClass {
    
    Webservice static String GWACCal(String s_productId)
    {
        
       /* List<Rate_Card__c> rateCards = [Select r.Product_Order__r.GWAC__c, r.Product_Order__r.Name, r.Product_Order__c, 
            r.P5_Supplier__r.Market_Allocation__c, r.P5_Supplier__r.Type__c, r.P5_Supplier__c, 
            (Select Cost__c, Status__c From Rate_Card_Items__r where Status__c = 'Active') 
            From Rate_Card__c r 
            where r.Product_Order__c =:s_productId and r.P5_Supplier__r.Type__c = 'Product'];*/
         
       List<Rate_Card_Items__c> rateCardsItems = [Select r.Material__r.GWAC__c, r.Material__c,r.Cost__c,
        r.Rate_Card__r.P5_Supplier__r.Type__c, r.Rate_Card__r.P5_Supplier__c,r.Status__c,
        r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c, r.Rate_Card__r.Id, r.Rate_Card__c 
        From Rate_Card_Items__c r where r.Status__c = 'Active' and r.Material__c =:s_productId and 
        r.Rate_Card__r.P5_Supplier__r.Type__c = 'Product'];
        
        String sresult=''; 
        GWACHelperClass oBjHelperClass= new GWACHelperClass();
        
        sresult=oBjHelperClass.methodForGWAC_PopulateClass(rateCardsItems);
        return sresult;
        
        /*if(rateCardsItems != null && rateCardsItems.size() > 0)
        {
            
            Map<String, Supplier__c> supplierIdMap = new Map<String, Supplier__c>();
            Map<String, Double> supplierCostMap = new Map<String, Double>();
            
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
                gWavValue += (Double) supplierCostMap.get(supplierID) / currentSupplier.Market_Allocation__c; 
            }
            
            Product_Order__c productOrder = rateCardsItems[0].Material__r;
            productOrder.GWAC__c = gWavValue; 
            update productOrder;
         
            sresult= 'success';
            system.debug('Sresult------------>'+sresult);
        }
        else
        {
            sresult= 'Unable to Populate GWAC Value';
            
            //return error
        }
        return sresult;*/
    }
    
}