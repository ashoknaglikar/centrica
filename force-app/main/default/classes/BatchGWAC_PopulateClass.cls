global class BatchGWAC_PopulateClass implements Database.Batchable<sObject> {
         
    //Batch Class to Populate the GWAC Value 
    public void createGWACBatch()
    {
        BatchGWAC_PopulateClass objGWAC = new BatchGWAC_PopulateClass();
        ID batchprocessid = Database.executeBatch(objGWAC);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
         //Passing the List of Rate Card Items in the Query String
         return Database.getQueryLocator('select id from Product_Order__c');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> rateCardsItems)
    {
        //List of Product Order IDs
        List<Id> productOrders = new List<Id>(); 
        for(sObject sObj : rateCardsItems)
        {
            String rateCardItemObj = sObj.Id;
            productOrders.add(rateCardItemObj);
        }
        
        System.debug('----------------- productOrders  =' + productOrders);
        //List of Rate card Items corresponding to that product orders.
        List<Rate_Card_Items__c> poRateCardItems = [Select r.Material__r.GWAC__c, r.Material__c,r.Cost__c, 
            r.Rate_Card__r.P5_Supplier__r.Type__c, r.Rate_Card__r.P5_Supplier__c,r.Status__c, 
            r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c, r.Rate_Card__r.Id, r.Rate_Card__c 
            from Rate_Card_Items__c r where r.Status__c = 'Active' and 
            r.Rate_Card__r.P5_Supplier__r.Type__c = 'Product' and r.Material__c in :productOrders];
            
            System.Debug('poRateCardItems Rate Card Item List Size----->'+poRateCardItems.size());
            GWACHelperClass oBjHelperClass= new GWACHelperClass();
        
        	oBjHelperClass.methodForBatchGWAC_PopulateClass(poRateCardItems);
        //Checking the size of rateCard Items list. 
        /*if(poRateCardItems != null && poRateCardItems.size() > 0)
        {
            Map<String, Supplier__c> supplierIdMap = new Map<String, Supplier__c>();
            Map<String, Double> supplierCostMap = new Map<String, Double>();
            Map<String, Double> productOrderGWAC = new Map<String, Double>();
            
            for(Rate_Card_Items__c r:poRateCardItems)
            {
                Double marketAllocation = r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c;
                system.debug('-------Market_Allocation__c------->'+r.Rate_Card__r.P5_Supplier__r.Market_Allocation__c);
                
                //---------------------Calculate total cost for each supplier
                //If Cost is not null AND Rate Card is not null AND Supplier of Rate Card is not null
                //Add the cost of product to Supplier map
                system.debug('-------Rate Card Price------->'+r.Cost__c);
                if(r.Cost__c != null && r.Rate_Card__r != null && 
                    r.Rate_Card__r.P5_Supplier__c != null)
                {
                    Double TotalCost = 0;
                    
                    
                    Double tempGWAC = 0;
                    //Check if some value already exists for current suplier
                    if(productOrderGWAC.containsKey(r.Material__c))
                        tempGWAC = productOrderGWAC.get(r.Material__c);
                    
                    tempGWAC += r.Cost__c / marketAllocation;
                    //Putting the GWAC value in the temporary variable
                    productOrderGWAC.put(r.Material__c, tempGWAC);
                    //Putting the temp var in the GWAC Field of Product Order 
                    Product_Order__c productOrder = r.Material__r;
                    productOrder.GWAC__c=productOrderGWAC.get(r.Material__c);
                    //updating productOrder
                    update productOrder; 
                    system.debug('-------GWAC Value------->'+productOrderGWAC.get(r.Material__c));
                    
                }
                
                else{
                    system.debug('Condition not satisfied');
                }  
                
            }
            
        }*/
        
      }
    
    global void finish(Database.BatchableContext bc){
        messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'shekharchauhan85@gmail.com'});
        mail.setReplyTo('shekharchauhan85@gmail.com');
        mail.setSenderDisplayName('Batch Processing : GWAC Populate Batch');
        mail.setSubject('Batch Process Completed For GWAC value');
        mail.setPlainTextBody('&&& Batch Process has completed FOR GWAC value Populate');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}