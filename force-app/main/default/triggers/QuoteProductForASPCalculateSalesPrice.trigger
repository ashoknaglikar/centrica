trigger QuoteProductForASPCalculateSalesPrice on Quote_Product__c (before insert,before update) {
    
    List<Quote_Product__c> triggerQuoteProductsRelatingToASPs = new List<Quote_Product__c>();
           
    List<Quote_Product__c> UDPQuoteProductsRelatingToASPs = new List<Quote_Product__c>();
    
    Map<Id,Product2> ProductIdUDPMap = new Map<Id,Product2>();
    
    List<Id> ProductIdLst = new List<Id>(); 
   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
      if(cls_IsRun.dontFireTriggers){
          return;
      }
    
     // ASP History CR Starts
    
    if(Trigger.isUpdate){
    
       for(Quote_Product__c triggerQuoteProduct : trigger.new){ 
       	
          if(triggerQuoteProduct.ASP__c !=null && triggerQuoteProduct.ASP_Status__c == 'Entered' && 
                 trigger.oldMap.get(triggerQuoteProduct.Id).ASP_Reason__c == 'Added' &&
                   trigger.oldMap.get(triggerQuoteProduct.Id).ASP__c == triggerQuoteProduct.ASP__c &&
                     triggerQuoteProduct.ASP_Reason__c == 'Removed'){
                   	
               triggerQuoteProduct.GrossSingle__c = 0.0;
               triggerQuoteProduct.ASP_Impact__c = 0.0;
               triggerQuoteProduct.Mark_For_Deletion__c = true;
               
          }else
          { 
          	if(triggerQuoteProduct.quotingReason__c != 'First Quote' && triggerQuoteProduct.ASP__c !=null && triggerQuoteProduct.Quantity__c >0  && triggerQuoteProduct.ASP_Status__c == 'Entered' && 
                 trigger.oldMap.get(triggerQuoteProduct.Id).ASP_Reason__c == 'Added' &&
               	 trigger.oldMap.get(triggerQuoteProduct.Id).ASP__c == triggerQuoteProduct.ASP__c &&
                 triggerQuoteProduct.ASP_Reason__c == 'Added' && 
                 trigger.oldMap.get(triggerQuoteProduct.Id).Quantity__c != triggerQuoteProduct.Quantity__c)
          	{
	      	if(triggerQuoteProduct.User_Defined_Product__c)
	      	{
	      		UDPQuoteProductsRelatingToASPs.add(triggerQuoteProduct);
	      		 ProductIdLst.add(triggerQuoteProduct.Product__c);
	      	}else
	      	{
	      		triggerQuoteProductsRelatingToASPs.add(triggerQuoteProduct);
	      
	      	}
          }
       	} 
       }
       if(ProductIdLst.size()>0)
       ProductIdUDPMap = new Map<Id,Product2>([Select Name, User_Defined_Product__c from Product2 where Id in: ProductIdLst]);
       
       if(triggerQuoteProductsRelatingToASPs.size()>0)
       {
   			ASPVATCalculations aspCal = new ASPVATCalculations();
        	aspCal.calculateVatForNonUDP(triggerQuoteProductsRelatingToASPs);
       }
       
       if(UDPQuoteProductsRelatingToASPs.size()>0)
       {
       		ASPVATCalculations aspCal = new ASPVATCalculations();
        	aspCal.calculateVatForUDP(UDPQuoteProductsRelatingToASPs,ProductIdUDPMap);
       }
       
   }else { // If it is before insert operation execute this
    
    //--------------------------End:------------------------------------------------------------------------------
    ///
    //If a quote product is added that relates to an ASP this trigger calculates the Sales Price for the line item and populates the field accordingly
    ///
    try{
        if(trigger.isInsert && trigger.isBefore){
            //the vat code entry 
            //Vat_Codes__c vat;
            //Sort through line items to seperate those related to ASPs and those which are not. Reference later.                                       
            //If no line items relate to ASPs then thr trigger does nothing.
            for(Quote_Product__c p: trigger.new)
			{
				//if(p.Name == null && p.product__c !=null)
				{
					ProductIdLst.add(p.Product__c);
				}
			}
            
            if(ProductIdLst.size()>0)
			{
				ProductIdUDPMap = new map<Id, Product2>([select id, name,User_Defined_Product__c from Product2 where id in:ProductIdLst]);
			}
			
			for(Quote_Product__c p: trigger.new)
			{
				if(p.Name == null && p.product__c !=null && ProductIdUDPMap.containskey(p.product__c))
				{
					p.Name = ProductIdUDPMap.get(p.product__c).Name;
				}
			}
            
            for(Quote_Product__c triggerQuoteProduct : trigger.new){
                
                 
                if(triggerQuoteProduct.ASP__c!=null && triggerQuoteProduct.User_Defined_Product__c == false)
                //if(triggerQuoteProduct.ASP__c!=null)
                            
                    triggerQuoteProductsRelatingToASPs.add(triggerQuoteProduct);
                
                if(triggerQuoteProduct.ASP__c!=null && triggerQuoteProduct.User_Defined_Product__c == true )
                {   
                    system.debug('User_Defined_Product__c-->'+triggerQuoteProduct.Product__r.User_Defined_Product__c);
                    //if(triggerQuoteProduct.Product__r.User_Defined_Product__c == true)
                    
                
                        UDPQuoteProductsRelatingToASPs.add(triggerQuoteProduct);
                       
                        
            // Cognizant - CHI Phase III CR-005 implementation... END
                }
            }   
            //ProductIdUDPMap = new Map<Id,Product2>([Select Name, User_Defined_Product__c from Product2 where Id in: ProductIdLst]);
            System.debug('Product map-->'+ProductIdUDPMap);                 
            
            //If line items with ASPs were found then populate the line items sales price field         
            if(!triggerQuoteProductsRelatingToASPs.isEmpty()){
            	
            	ASPVATCalculations aspCal = new ASPVATCalculations();
            	aspCal.calculateVatForNonUDP(triggerQuoteProductsRelatingToASPs);
            }
            
            // PH -3 CR-005 Implementation strats.
            if(!UDPQuoteProductsRelatingToASPs.isEmpty())
            {
            	ASPVATCalculations aspCal = new ASPVATCalculations();
            	aspCal.calculateVatForUDP(UDPQuoteProductsRelatingToASPs,ProductIdUDPMap);
            	
            }
            // PH -3 CR-005 Implementation Ends.
        }
        
    
    }
    catch(exception e){
        system.debug('Exception occurred in the QuoteProductForASPCalculateSalesPrice.class. Error was: '+e);
        for(Quote_Product__c triggerQuoteProduct : trigger.new){
            triggerQuoteProduct.addError('An exception occurred: '+e);  
        }   
    }
  
 }  // else block ends

}