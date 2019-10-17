trigger QuoteProductDecompile on Quote_Product__c (after insert, after update) {   
    
   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
    if(cls_IsRun.dontFireTriggers){
        return;
    }
    
    ///
    //Trigger to control decompiling quote line items on to a Job record as related Job Elements.
    //If line items do not relate to an ASP they will be decompiled into job elements if they satisfy
    //conditions in the class QuoteProductDecompile. Line items related to ASPs will be decompiled once
    //the ASP is submitted (submit button on ASP record pressed) also based on logic in the QuoteProductDecompile class.
    
    //bjm:2010/01/06 - adding filter to stop any decompiling of products if quotingReasonOn2ndVisit__c = removed
    ///
        System.debug('----------------------- trigger records: ' + trigger.new);
    //Sort through line items to seperate those related to ASPs and those which are not.
    List<Quote_Product__c> triggerQuoteProductsNotRelatingToASPs = new List<Quote_Product__c>();
    List<ID> TriggerQuoteProductsNotRelatingToASPsIDs = new List<ID>(); 
    for(Quote_Product__c triggerQuoteProduct : trigger.new){
        if(triggerQuoteProduct.ASP__c==null && triggerQuoteProduct.quotingReasonOn2ndVisit__c != 'Removed'){
            // brm - 13-01-2010 - Added to stop decompiling quote products twice in a row
//            if (triggerQuoteProduct.Name != triggerQuoteProduct.Part_Number__c || (Trigger.isUpdate && triggerQuoteProduct.Quantity__c != trigger.oldMap.get(triggerQuoteProduct.Id).Quantity__c))
//            {
                triggerQuoteProductsNotRelatingToASPs.add(triggerQuoteProduct);
                TriggerQuoteProductsNotRelatingToASPsIDs.add(triggerQuoteProduct.Id);
//            }
        }
    }
    
    //If line items are inserted and they do not relate to an ASP they should be considered for decompiling into Job Elements.              
    //Any that DO relate to an ASP should not be decompiled on insert as the ASP will not be submitted yet. Decomposition will happen when the ASP 'Submit' button is pressed.              
    if(!triggerQuoteProductsNotRelatingToASPs.isEmpty() && cls_IsRun.isDecompiledQuoteProducts == false){   
      cls_IsRun.setIsDecompiledQuoteProducts();         
        QuoteProductDecompile.decompileQuoteProducts(triggerQuoteProductsNotRelatingToASPs, TriggerQuoteProductsNotRelatingToASPsIDs);  
    }                        
        
}