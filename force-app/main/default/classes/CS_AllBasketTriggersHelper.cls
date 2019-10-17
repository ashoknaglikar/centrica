public class CS_AllBasketTriggersHelper {
    
    /**
     *  Before update trigger handler.
     */
    public static void handleBeforeUpdate(map<id, cscfga__Product_Basket__c> oldBasketMap, map<id, cscfga__Product_Basket__c> newBasketMap) {
      String userIdForTriggerTest = UserInfo.getUserId();
        
        
        //Retrieve all required data
        List<cscfga__Product_Configuration__c> configs = [
        SELECT  Name,
                cscfga__Product_Basket__c,
                cscfga__Product_Basket__r.Appointment__r.Opportunity__c,
                cscfga__Product_Basket__r.Name,
                cscfga__Configuration_Status__c
        FROM    cscfga__Product_Configuration__c
        WHERE   cscfga__Product_Basket__c IN :newBasketMap.keySet()];
    
        //Create a Basket Map   
        Map<Id, cscfga__Product_Basket__c> basketsWithAppointments = new Map<Id, cscfga__Product_Basket__c>();
        
        if(!configs.isEmpty()){
            
        
            for (cscfga__Product_Configuration__c config : configs) {
                if (!basketsWithAppointments.containsKey(config.cscfga__Product_Basket__c)) {
                    basketsWithAppointments.put(config.cscfga__Product_Basket__c, config.cscfga__Product_Basket__r);
                }
            }
            
             //Iterate through all updated baskets and populate the Opportunity lookup
            for(cscfga__Product_Basket__c basket : newBasketMap.values()){
                if (basket.Id != null && basketsWithAppointments.containsKey(basket.Id) && basketsWithAppointments.get(basket.Id).Appointment__r != null) {
                    basket.cscfga__Opportunity__c = basketsWithAppointments.get(basket.Id).Appointment__r.Opportunity__c;
                }
            }
        
            //extract all config Ids
            
            Set<Id> pConfigsAllIds = (new Map<Id,cscfga__Product_Configuration__c>(configs)).keySet();
            List<Id> pConfigsIdList = new List<Id>(pConfigsAllIds);
            
            Map<String,Object> allConfigsData = cscfga.API_1.getProductConfigurations(pConfigsIdList);  
            
            system.debug('KEY SET 0 '+allConfigsData.keySet());
            
            //Populate CS_Quote_Status__c & Quote_Reference__c on Basket
            for (cscfga__Product_Configuration__c config : configs) {
                //Populate the CS_Quote_Status__c of the basket according to the Attribute value
                String status, prodConfStatus, quoteRef;
                Decimal totalPricePayable;
                cscfga__Product_Basket__c basket = newBasketMap.get(config.cscfga__Product_Basket__c);
    
                prodConfStatus = String.valueOf(config.cscfga__Configuration_Status__c);
                
                List<cscfga__Attribute__c> configAttributeObj = (List<cscfga__Attribute__c>)allConfigsData.get(config.Id +'-attributes');
    
                 
    
                
                configAttributeObj = configAttributeObj == null ? new List<cscfga__Attribute__c> () : configAttributeObj;
               for(cscfga__Attribute__c att : configAttributeObj){
               
               
                    if (att.Name == CS_Constants.QuoteStatusAttributeName) {
                        status = att.cscfga__Value__c;
                    }
                    
                    if (att.Name == CS_Constants.QuoteReferenceAttributeName) {
                        quoteRef = att.cscfga__Value__c;
                    }
                    
                    if (att.Name == CS_Constants.TotalPricePayableAttributeName) {
                        system.debug('Total Price Payable is: ' + att.cscfga__Value__c);
                        try {
                            totalPricePayable = Decimal.valueOf(att.cscfga__Value__c);
                        } catch (Exception e) {
                            // do nothing
                        }
                    }
                }
                
                system.debug('basket: ' + basket);
                system.debug('status: ' + status);
                if (basket != null && status != null) {
                    if(prodConfStatus != CS_Constants.ProductConfiguration_ClonedStatus){
                        basket.CS_Quote_Status__c = status;
                    }
                    
                    if (quoteRef != null) {
                        basket.Quote_Reference__c = quoteRef;
                        basket.Name = quoteRef;
                    }
    
                    if (totalPricePayable != null) {
                        basket.cscfga__Total_Price__c = totalPricePayable;
                    }
                    system.debug('basket.cscfga__Total_Price__c: ' + totalPricePayable);
                }
            }
        }

        replaceAttributeIdValuesWithKeyValues(newBasketMap);
        //}
        /*
        else{
    
            //Retrieve all required data
             List<cscfga__Product_Configuration__c> configs = [
                SELECT  Name,
                        cscfga__Product_Basket__c,
                        cscfga__Product_Basket__r.Appointment__r.Opportunity__c,
                        cscfga__Product_Basket__r.Name,
                        cscfga__Configuration_Status__c,
                        (SELECT Name,
                                cscfga__Value__c
                         FROM   cscfga__Attributes__r
                         WHERE  Name = :CS_Constants.QuoteStatusAttributeName 
                         OR Name = :CS_Constants.QuoteReferenceAttributeName
                         OR Name = 'Total Price Payable')
                FROM    cscfga__Product_Configuration__c
                WHERE   cscfga__Product_Basket__c IN :newBasketMap.keySet()];
            
            //Create a Basket Map   
            Map<Id, cscfga__Product_Basket__c> basketsWithAppointments = new Map<Id, cscfga__Product_Basket__c>();
            
            for (cscfga__Product_Configuration__c config : configs) {
                if (!basketsWithAppointments.containsKey(config.cscfga__Product_Basket__c)) {
                    basketsWithAppointments.put(config.cscfga__Product_Basket__c, config.cscfga__Product_Basket__r);
                }
            }
         
             //Iterate through all updated baskets and populate the Opportunity lookup
            for(cscfga__Product_Basket__c basket : newBasketMap.values()){
                if (basket.Id != null && basketsWithAppointments.containsKey(basket.Id) && basketsWithAppointments.get(basket.Id).Appointment__r != null) {
                    basket.cscfga__Opportunity__c = basketsWithAppointments.get(basket.Id).Appointment__r.Opportunity__c;
                }
            }
        
            //Populate CS_Quote_Status__c & Quote_Reference__c on Basket
            for (cscfga__Product_Configuration__c config : configs) {
                //Populate the CS_Quote_Status__c of the basket according to the Attribute value
                String status, prodConfStatus, quoteRef;
                Decimal totalPricePayable;
                cscfga__Product_Basket__c basket = newBasketMap.get(config.cscfga__Product_Basket__c);

                prodConfStatus = String.valueOf(config.cscfga__Configuration_Status__c);
                
                for (cscfga__Attribute__c att : config.cscfga__Attributes__r) {
                    if (att.Name == CS_Constants.QuoteStatusAttributeName) {
                        status = att.cscfga__Value__c;
                    }
                    if (att.Name == CS_Constants.QuoteReferenceAttributeName) {
                        quoteRef = att.cscfga__Value__c;
                    }
                    if (att.Name == CS_Constants.TotalPricePayableAttributeName) {
                        try {
                            totalPricePayable = Decimal.valueOf(att.cscfga__Value__c);
                        } catch (Exception e) {
                            // do nothing
                        }
                    }
                }
                if (basket != null && status != null) {
                    if(prodConfStatus != CS_Constants.ProductConfiguration_ClonedStatus){
                        basket.CS_Quote_Status__c = status;
                    }
                    
                    if (quoteRef != null) {
                        basket.Quote_Reference__c = quoteRef;
                        basket.Name = quoteRef;
                    }

                    if (totalPricePayable != null) {
                        basket.cscfga__Total_Price__c = totalPricePayable;
                    }
                }
            }

            replaceAttributeIdValuesWithKeyValues(newBasketMap);
        }
        */
    }
    
    /**
     * Workaround for new configurator and old DepotSQT (~3.0.69).
     * Replaces the Ids with cscfga__Key__c values in cscfga__Value__c fields of related product attributes.
     * Uses 2 SOQL queries.
     */
    private static void replaceAttributeIdValuesWithKeyValues(map<id, cscfga__Product_Basket__c> newBasketMap) {
        
        

         Map<Id, cscfga__Product_Configuration__c> allConfigsMap = new Map<Id, cscfga__Product_Configuration__c>([
            SELECT  Id,
                    cscfga__Key__c
            FROM    cscfga__Product_Configuration__c
            WHERE   cscfga__Product_Basket__c IN :newBasketMap.keySet()
            ]);

        Map<Id, String> configIdToKeyMap = new Map<Id, String>();
        for(Id configId : allConfigsMap.keySet()) {
            cscfga__Product_Configuration__c config = allConfigsMap.get(configId);
            configIdToKeyMap.put(config.Id, config.cscfga__Key__c);
        }

        List<cscfga__Attribute__c> allRelatedProductAttributes = [
            SELECT Id,
                   cscfga__Value__c
            FROM   cscfga__Attribute__c
            WHERE  cscfga__Attribute_Definition__r.cscfga__Type__c = 'Related Product'
            AND    cscfga__Product_Configuration__c IN :allConfigsMap.keySet()];

        List<cscfga__Attribute__c> attrsToUpdate = new List<cscfga__Attribute__c>(); 

       

        for(cscfga__Attribute__c attr : allRelatedProductAttributes) {
            // get the value
            String value = attr.cscfga__Value__c;
            if(value != null) {
                // split the value
                List<String> splitValues = value.split(',');
                List<String> keyValues = new List<String>();
                // try to convert split values to ids, so they can be fetched from configIdToKeyMap
                for(String splitVal : splitValues) {
                    try {
                        Id splitId = Id.valueOf(splitVal);
                        keyValues.add(configIdToKeyMap.get(splitId));
                    } catch (Exception ex) {
                        // do nothing
                    }
                }
                if(keyValues.size() > 0) {
                    attr.cscfga__Value__c = String.join(keyValues, ',');
                    attrsToUpdate.add(attr);
                }
            }
        }

        // only update attributes if there is anything to be updated
        if(attrsToUpdate.size() > 0) {
            update attrsToUpdate;
        }        
    }    
/*
    public static void updateOpportunityLookupOnProductBasket(List<cscfga__Product_Basket__c> triggerList) {
        
        Map<Id, cscfga__Product_Basket__c> basketsWithAppointments = new Map<Id, cscfga__Product_Basket__c>([
            Select 
                Id, Appointment__r.Opportunity__c 
            from
                cscfga__Product_Basket__c
            where
                Id in :triggerList
        ]);
    
        //iterate through all updated baskets
        for(cscfga__Product_Basket__c basket : triggerList){
            // update the cscfga__Opportunity__c field on the basket
            if (basket.Id != null && basketsWithAppointments.get(basket.Id).Appointment__r != null) {
                basket.cscfga__Opportunity__c = basketsWithAppointments.get(basket.Id).Appointment__r.Opportunity__c;
            }
        }
    }
    */
}