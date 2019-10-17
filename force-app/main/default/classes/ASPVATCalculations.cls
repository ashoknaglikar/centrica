public with sharing class ASPVATCalculations {
	
	public void calculateVatForNonUDP(list<Quote_Product__c> triggerQuoteProductsRelatingToASPs)
	{
		Map<string, double> vatBands = new Map<string, double>();
	    Map<string, double> oldvatBands = new Map<string, double>();
	    Map<string, double> newvatBands = new Map<string, double>();
	    Vat_Codes__c vat;
	    Decimal NewVat1;
	    Decimal NewVat4;
	    Decimal OldVat1;
	    Decimal OldVat4;
	    String overwritestring = System.Label.VAT_Change_Date;
	    Date overwrite = date.valueOf(overwritestring);
	    Date Closedate;
	   
        
    //--------------------------Start:-----VAT Change from 2011--------------------------------
    	List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,VAT_Code_4_Rate__c,VAT_Code_3__c,Status__c,start_date__c,
                                    VAT_Code_3_Rate__c,end_date__c,VAT_Code_2_Rate__c,VAT_Code_2__c,VAT_Code_1_Rate__c from VAT_Codes__c];
       for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        newvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_2__c !=null)
                        newvatBands.put(objvat.VAT_Code_2__c, objvat.VAT_Code_2_Rate__c);
                if(objvat.VAT_Code_3__c !=null)
                        newvatBands.put(objvat.VAT_Code_3__c, objvat.VAT_Code_3_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        newvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
                
            }else if (objvat.start_date__c <overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        oldvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_2__c !=null)
                        oldvatBands.put(objvat.VAT_Code_2__c, objvat.VAT_Code_2_Rate__c);
                if(objvat.VAT_Code_3__c !=null)
                        newvatBands.put(objvat.VAT_Code_3__c, objvat.VAT_Code_3_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        oldvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
            }
       }
		
        //declare current VAT Rate. This is used later to calculate the sales price of line items added
        
        double VATRate;
       //To populate the sales price field we need the 'unit list price' from the priceBookEntries record that relates to the same pricebook ID as the quote and has the same product name as the line item added                               
        //Populate lists of all the line item names and related quotes. Used in SOQL queries later.
        List<ID> triggerQuoteIDs = new List<ID>();  
		list<Id> productIdList = new list<Id>();
        List<String> triggerProductNames = new List<String>();
        List<String> nonCStriggerProductNames = new List<String>();
        map<id, Quote_Product__c> nonCSQuoteProductMap = new map<id, Quote_Product__c>();
        
        
        for(Quote_Product__c triggerQuoteProductsRelatingToASP : triggerQuoteProductsRelatingToASPs){
            triggerProductNames.add(triggerQuoteProductsRelatingToASP.Name);
            triggerQuoteIDs.add(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c);
			productIdList.add(triggerQuoteProductsRelatingToASP.Product__c);
        }
        // Retrive all the CS Part to get if they are upliftable
		map<Id, CS_Part__c> productIdCSPartMap = new map<Id, CS_Part__c>();
		for( CS_Part__c csPart : [Select id,Product__c, Upliftable__c from CS_Part__c where Product__c in:productIdList])
		{
			productIdCSPartMap.put(csPart.Product__c, csPart);
		}
		
		
		
        //Retrieve all quote PriceBook IDs and Geographic uplift factors associated with the line items inserted. There should usually only be one associated quote per trigger as line items 
        //are inserted via the BM to SFDC interface on a per quote basis, but as best practice this trigger is designed to work even when this is not the case 
        Map<Id,BigMachines_Quote__c> relatedQuotes = new Map<Id,BigMachines_Quote__c>([select Pricebook_Id__c, geographicUpliftFactor__c,closeDate__c, Job_Type__c, Opportunity__r.Account.Sales_Subpatch__r.District__c from BigMachines_Quote__c where Id in:triggerQuoteIDs]);
        
        //Put the pricebook IDs into a set to assist the query for pricebookentries later
        set<String> relatedQuotesPriceBookNames = new set<string>();   
        set<string> districts = new set<string>();
        for(BigMachines_Quote__c relatedQuote : relatedQuotes.values()){      
                if(relatedQuote.Job_Type__c != null )
                {
                    districts.add(relatedQuote.Opportunity__r.Account.Sales_Subpatch__r.District__c);
                    Pricebook__c sp = Pricebook__c.getInstance(relatedQuote.Job_Type__c);
                    if(sp!=null && sp.Pricebook_Name__c!=null)
                    relatedQuotesPriceBookNames.add(sp.Pricebook_Name__c); 
                    else
                    relatedQuotesPriceBookNames.add('Standard'); 
                }
                if(relatedQuote.Pricebook_Id__c!=null)
                {
                    relatedQuotesPriceBookNames.add(relatedQuote.Pricebook_Id__c); 
                }
                Closedate = relatedQuote.closeDate__c;      
        }
        system.debug('Closedate-->'+Closedate);
        
        
        
        //Now we have our data cycle through the line items and set the sales price.
        /*----Added for the VAT Change ----------
        ------------------------------------------
        -------------------------------------------
        ------------------------------------------*/    
        
        map<string, CS_Part_Price__c> partPriceMap = new map<string, CS_Part_Price__c>();
        Date todayDate = System.today();
    
        list<CS_Part_Price__c> partPrices = [Select id, VAT__c, Price__c, Part__r.Product__r.Second_VAT_Proportion__c,Part_code__c, District__c, Part__r.Product__r.Third_VAT_Proportion__c, Part__r.Product__r.Third_VAT_Code__c, Part__r.Product__r.Second_VAT_Code__c, Part__r.Product__r.First_VAT_Proportion__c, Part__r.Product__r.First_VAT_Code__c from CS_Part_Price__c where (District__c = null OR District__c in : districts) and Part_code__c in :triggerProductNames and  CS_Pricebook_Type__c in :relatedQuotesPriceBookNames 
                                            AND Start_Date__c  <= :todayDate And (End_Date__c>= :todayDate OR End_Date__c = null) AND Part__r.Product__c !=null];
        if(system.label.ASP_Geography_Pricing == 'on')
        for(CS_Part_Price__c c: partPrices)
        {
            if(c.District__c != null || !partPriceMap.containskey(c.Part_Code__c))
            {
                partPriceMap.put(c.Part_Code__c, c);
            }
        }
        
        for(Quote_Product__c i: triggerQuoteProductsRelatingToASPs)
		{
		    if(!partPriceMap.ContainsKey(i.Name))
		    {
		        nonCStriggerProductNames.add(i.Name);
		        nonCSQuoteProductMap.put(i.Product__c, i);
		    }
		}
		
		//query to obtain the pricebook IDs. We only currently have their names.
        list<Pricebook2> priceBooksUsed = [Select Name, Id From Pricebook2 where name in:relatedQuotesPriceBookNames];
        //put them into a map and a list for later use
        list<ID> priceBooksUsedIDs = new list<Id>();                
        Map<String, ID> priceBooksUsedMap = new Map<String, ID>();
        for(Pricebook2 priceBook : priceBooksUsed){                                         
                priceBooksUsedIDs.add(priceBook.Id);
                priceBooksUsedMap.put(priceBook.Name,priceBook.Id);                                     
        }               
                     
        //Select all pricebook entries that relate to the pricebook IDs and line item names contain in the triggering Line Items                                
        List<PricebookEntry> PricebookEntries_OLD = [Select Name, UnitPrice, Product2Id, Pricebook2Id,   
                                                    Product2.Second_VAT_Proportion__c, Product2.Third_VAT_Proportion__c, Product2.Third_VAT_Code__c, Product2.Second_VAT_Code__c, Product2.First_VAT_Proportion__c, Product2.First_VAT_Code__c
                                                    From PricebookEntry where IsActive=true AND Name in:nonCStriggerProductNames AND Pricebook2Id in:priceBooksUsedIDs];
        //Put these values into a Map to assist retrieveing values later. Make the key unique by using Name+PricebookId. There should only ever be one named product per pricebook
        Map<String, PricebookEntry> PricebookEntriesMap = new Map<String, PricebookEntry>();
        for(PricebookEntry PricebookEntriesSingle : PricebookEntries_OLD){      
            PricebookEntriesMap.put((PricebookEntriesSingle.Name+PricebookEntriesSingle.Pricebook2Id).toUpperCase() ,PricebookEntriesSingle);                                           
        }
        system.debug('PricebookEntriesMap contains: '+PricebookEntriesMap);
        
        if(Closedate >=overwrite){
            system.debug('Entered IF-->');  
            for(Quote_Product__c triggerQuoteProductsRelatingToASP : triggerQuoteProductsRelatingToASPs){
            
                //TODO: update this default value to 1.175 from 1st January
                VATRate=1.20;                                                   
                boolean unitPriceCannotBeDetermined=true;
                double VATABeforeDiscount = 0;
                double vatGeoUplift =0;
                double geoUpLiftFactor = relatedQuotes.get(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c).geographicUpliftFactor__c;
                if(geoUpLiftFactor == null)
                    geoUpLiftFactor = 0.0;
				system.debug('productIdCSPartMap---'+productIdCSPartMap);	
                boolean uplift = false;
                
                double geoUpliftExcludingVat = 0.0;
                double price = 0.0; 
                if(triggerQuoteProductsRelatingToASP.ASP_Reason__c=='Added' && triggerQuoteProductsRelatingToASP.ASP_Action__c!='Discount'){                                                
                //getpricebook name
                system.debug('added:!Disount');
                product2 productInScope = new product2();
                
                system.debug('pricebook found');
                //get pricebookID
                if(partPriceMap.containsKey(triggerQuoteProductsRelatingToASP.Name)){   
                        system.debug('pricebook in map');                           
                        CS_Part_Price__c relatedPricebookEntry = partPriceMap.get(triggerQuoteProductsRelatingToASP.Name);
                        system.debug('pricebookEntry found: '+relatedPricebookEntry);
                        //system.debug('pricebookEntry.product2: '+relatedPricebookEntry.Product2);
                        //set values for price 
                        price = relatedPricebookEntry.Price__c;
                        productInScope = relatedPricebookEntry.Part__r.Product__r;
                        unitPriceCannotBeDetermined=false;
                }
                else if(nonCSQuoteProductMap.containsKey(triggerQuoteProductsRelatingToASP.Product__c))
                {
                    string pricebookName = relatedQuotes.get(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c).Pricebook_Id__c;
                    system.debug('pricebookName: '+pricebookName);
                    if(pricebookName!=null)
                    {
                        ID pricebookID = priceBooksUsedMap.get(pricebookName);
                    //get pricebookEntry
                        String key = (triggerQuoteProductsRelatingToASP.Name+pricebookID).toUpperCase();
                        system.debug('pricebookEntry: '+ key);  
                        system.debug('PricebookEntriesMap.containsKey(key): '+ PricebookEntriesMap.containsKey(key));
                        if(PricebookEntriesMap.containsKey(key))  
                        {
                            PricebookEntry relatedPricebookEntry = PricebookEntriesMap.get(key);
                            price = relatedPricebookEntry.UnitPrice;
                            productInScope = relatedPricebookEntry.Product2;
                            unitPriceCannotBeDetermined=false;
                        }
                    }
                    
                    
                }   
                
                system.debug('productInScope--- >'+productInScope);
                    triggerQuoteProductsRelatingToASP.price_list_price_each__c= price;                                    
                    
                    //setting the VAT info for the first band 
                    triggerQuoteProductsRelatingToASP.FirstVATProportion__c = productInScope.First_VAT_Proportion__c;
                    triggerQuoteProductsRelatingToASP.FirstVATCode__c = (productInScope.First_VAT_Code__c == null ? 0.0 : double.valueof(productInScope.First_VAT_Code__c));
                   
                    triggerQuoteProductsRelatingToASP.geographicUplift__c = 0.0;
					if(productIdCSPartMap.containskey(triggerQuoteProductsRelatingToASP.Product__c) && productIdCSPartMap.get(triggerQuoteProductsRelatingToASP.Product__c).Upliftable__c == true)	
					{
                        uplift= true;
						triggerQuoteProductsRelatingToASP.geographicUplift__c = geoUpLiftFactor/100 * triggerQuoteProductsRelatingToASP.price_list_price_each__c;
					}
                   
                    if(!(lstVAT.size()> 0))
                        VATABeforeDiscount = price * VATRate;
                    else{
                        
                        double myVatRate = 0;
                        VATABeforeDiscount = 0;
						
						geoUpliftExcludingVat = triggerQuoteProductsRelatingToASP.geographicUplift__c ;
						
                        if(newvatBands.containsKey(productInScope.First_VAT_Code__c)){
                            myVatRate = newvatBands.get(productInScope.First_VAT_Code__c);
                        }
                        if(productInScope.First_VAT_Proportion__c != null && productInScope.First_VAT_Proportion__c > 0){
                            VATABeforeDiscount += price * productInScope.First_VAT_Proportion__c * myVatRate / 10000;
                            if(uplift)
							vatGeoUplift += geoUpliftExcludingVat * productInScope.First_VAT_Proportion__c * myVatRate / 10000;
                            //system.debug('1st: '+ price+'*'+relatedPricebookEntry.Product2.First_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                        }
                        if(newvatBands.containsKey(productInScope.Second_VAT_Code__c)){
                            myVatRate = newvatBands.get(productInScope.Second_VAT_Code__c);
                        }else
                            myVatRate = 0.0;
                        if(productInScope.Second_VAT_Proportion__c != null && productInScope.Second_VAT_Proportion__c > 0){
                            VATABeforeDiscount += price * productInScope.Second_VAT_Proportion__c * myVatRate / 10000;
							 if(uplift)
                            vatGeoUplift += geoUpliftExcludingVat * productInScope.Second_VAT_Proportion__c * myVatRate / 10000;
                            system.debug('1st: '+ price+'*'+productInScope.Second_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                        }
                        if(newvatBands.containsKey(productInScope.Third_VAT_Code__c)){
                            myVatRate = newvatBands.get(productInScope.Third_VAT_Code__c);
                        }else
                            myVatRate = 0.0;
                        if(productInScope.Third_VAT_Proportion__c != null && productInScope.Third_VAT_Proportion__c > 0){
                            VATABeforeDiscount += price * productInScope.Third_VAT_Proportion__c * myVatRate / 10000;
							 if(uplift)
                            vatGeoUplift += geoUpliftExcludingVat * productInScope.Third_VAT_Proportion__c * myVatRate / 10000;
                            system.debug('1st: '+ price+'*'+productInScope.Third_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                        }
                        
                    }
                           
                        //}
                    
                    triggerQuoteProductsRelatingToASP.VATABeforeDiscount__c = VATABeforeDiscount;
                    system.debug('geoUpLiftFactor:' + geoUpLiftFactor);
                    system.debug('VATABeforeDiscount:' + VATABeforeDiscount);
                    //Calculate the sales price of the line item    
                    triggerQuoteProductsRelatingToASP.Sales_Price__c = VATABeforeDiscount + triggerQuoteProductsRelatingToASP.geographicUplift__c + vatGeoUplift+triggerQuoteProductsRelatingToASP.price_list_price_each__c;
                    system.debug('triggerQuoteProductsRelatingToASP.Sales_Price__c:' + triggerQuoteProductsRelatingToASP.Sales_Price__c);
                    
                                   
                if(unitPriceCannotBeDetermined){                                                                        
                    triggerQuoteProductsRelatingToASP.price_list_price_each__c=0;                       
                }
                
            
            //rjd - 15/12/2009 - moving to inside if statement
                //Calculate the sales price of the line item                                    
                //triggerQuoteProductsRelatingToASP.Sales_Price__c = relatedQuotes.get(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c).geographicUpliftFactor__c*triggerQuoteProductsRelatingToASP.price_list_price_each__c*VATRate;
            }                               
        }
    }
    /*
    else if(Closedate < overwrite){
            system.debug('Entered Else IF-->'); 
            for(Quote_Product__c triggerQuoteProductsRelatingToASP : triggerQuoteProductsRelatingToASPs){
            
                //TODO: update this default value to 1.175 from 1st January
                VATRate=1.175;                                                  
                boolean unitPriceCannotBeDetermined=true;
                double VATABeforeDiscount = 0;
                if(triggerQuoteProductsRelatingToASP.ASP_Reason__c=='Added' && triggerQuoteProductsRelatingToASP.ASP_Action__c!='Discount')
                {                                                
                //getpricebook name
                system.debug('added:!Disount');
                //string pricebookName = relatedQuotes.get(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c).Pricebook_Id__c;
                //system.debug('pricebookName: '+pricebookName);
                //if(pricebookName!=null){
                    system.debug('pricebook found');
                    //get pricebookID
                    //if(priceBooksUsedMap.containsKey(pricebookName)){   
                        //system.debug('pricebook in map');                           
                        //ID pricebookID = priceBooksUsedMap.get(pricebookName);
                        //get pricebookEntry
                        //String key = (triggerQuoteProductsRelatingToASP.Name+pricebookID).toUpperCase();
                        //system.debug('pricebookEntry: '+ key);  
                        //system.debug('PricebookEntriesMap.containsKey(key): '+ PricebookEntriesMap.containsKey(key));
                        
                        if(partPriceMap.containsKey(triggerQuoteProductsRelatingToASP.Name)){
                            
                            CS_Part_Price__c relatedPricebookEntry = partPriceMap.get(triggerQuoteProductsRelatingToASP.Name);
                            //PricebookEntry relatedPricebookEntry = PricebookEntriesMap.get(key);
                            system.debug('pricebookEntry found: '+relatedPricebookEntry);
                            //system.debug('pricebookEntry.product2: '+relatedPricebookEntry.Product2);
                            //set values for price                                                                      
                            triggerQuoteProductsRelatingToASP.price_list_price_each__c= relatedPricebookEntry.Price__c;                                    
                            unitPriceCannotBeDetermined=false;
                            //setting the VAT info for the first band 
                            triggerQuoteProductsRelatingToASP.FirstVATProportion__c = relatedPricebookEntry.Part__r.Product__r.First_VAT_Proportion__c;
                            triggerQuoteProductsRelatingToASP.FirstVATCode__c = (relatedPricebookEntry.Part__r.Product__r.First_VAT_Code__c == null ? 0.0 : double.valueof(relatedPricebookEntry.Part__r.Product__r.First_VAT_Code__c));
                            double geoUpLiftFactor = relatedQuotes.get(triggerQuoteProductsRelatingToASP.BigMachines_Quote__c).geographicUpliftFactor__c;
                            if(geoUpLiftFactor == null)
                                geoUpLiftFactor = 0.0;
                            triggerQuoteProductsRelatingToASP.geographicUplift__c = geoUpLiftFactor/100 * triggerQuoteProductsRelatingToASP.price_list_price_each__c;
                            
                            if(!(lstVAT.size()> 0))
                                VATABeforeDiscount = relatedPricebookEntry.Price__c * VATRate;
                            else{
                                double price = relatedPricebookEntry.Price__c;
                                system.debug('price-->'+price);
                                double myVatRate = 0;
                                VATABeforeDiscount = 0;
                                if(oldvatBands.containsKey(relatedPricebookEntry.Part__r.Product__r.First_VAT_Code__c)){
                                    myVatRate = oldvatBands.get(relatedPricebookEntry.Part__r.Product__r.First_VAT_Code__c);
                                }
                                if(relatedPricebookEntry.Part__r.Product__r.First_VAT_Proportion__c != null && relatedPricebookEntry.Part__r.Product__r.First_VAT_Proportion__c > 0){
                                    VATABeforeDiscount += price * relatedPricebookEntry.Part__r.Product__r.First_VAT_Proportion__c * myVatRate / 10000;
                                    system.debug('1st: '+ price+'*'+relatedPricebookEntry.Part__r.Product__r.First_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                                }
                                if(oldvatBands.containsKey(relatedPricebookEntry.Part__r.Product__r.Second_VAT_Code__c)){
                                    myVatRate = oldvatBands.get(relatedPricebookEntry.Part__r.Product__r.Second_VAT_Code__c);
                                }else
                                    myVatRate = 0.0;
                                if(relatedPricebookEntry.Part__r.Product__r.Second_VAT_Proportion__c != null && relatedPricebookEntry.Part__r.Product__r.Second_VAT_Proportion__c > 0){
                                    VATABeforeDiscount += price * relatedPricebookEntry.Part__r.Product__r.Second_VAT_Proportion__c * myVatRate / 10000;
                                    system.debug('1st: '+ price+'*'+relatedPricebookEntry.Part__r.Product__r.Second_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                                }
                                if(oldvatBands.containsKey(relatedPricebookEntry.Part__r.Product__r.Third_VAT_Code__c)){
                                    myVatRate = oldvatBands.get(relatedPricebookEntry.Part__r.Product__r.Third_VAT_Code__c);
                                }else
                                    myVatRate = 0.0;
                                if(relatedPricebookEntry.Part__r.Product__r.Third_VAT_Proportion__c != null && relatedPricebookEntry.Part__r.Product__r.Third_VAT_Proportion__c > 0){
                                    VATABeforeDiscount += price * relatedPricebookEntry.Part__r.Product__r.Third_VAT_Proportion__c * myVatRate / 10000;
                                    system.debug('1st: '+ price+'*'+relatedPricebookEntry.Part__r.Product__r.Third_VAT_Proportion__c+'*'+myVatRate +':'+VATABeforeDiscount);
                                }
                                
                            }
                            triggerQuoteProductsRelatingToASP.VATABeforeDiscount__c = VATABeforeDiscount;
                            system.debug('geoUpLiftFactor:' + geoUpLiftFactor);
                            system.debug('VATABeforeDiscount:' + VATABeforeDiscount);
                            //Calculate the sales price of the line item    
                            triggerQuoteProductsRelatingToASP.Sales_Price__c = VATABeforeDiscount + triggerQuoteProductsRelatingToASP.geographicUplift__c + triggerQuoteProductsRelatingToASP.price_list_price_each__c;
                            system.debug('triggerQuoteProductsRelatingToASP.Sales_Price__c:' + triggerQuoteProductsRelatingToASP.Sales_Price__c);
                        }
                   // }
                //}
                //If unit price cannot be obtained it is a requirement to set the price list price to zero                              
                if(unitPriceCannotBeDetermined){                                                                        
                    triggerQuoteProductsRelatingToASP.price_list_price_each__c=0;                       
                    }
                }                               
            }
        }*/
            
	}
	
	
	public void calculateVatForUDP(list<Quote_Product__c> UDPQuoteProductsRelatingToASPs,  Map<Id,Product2> ProductIdUDPMap)
	{
		Map<string, double> vatBands = new Map<string, double>();
	    Map<string, double> oldvatBands = new Map<string, double>();
	    Map<string, double> newvatBands = new Map<string, double>();
	    Vat_Codes__c vat;
	    Decimal NewVat1;
	    Decimal NewVat4;
	    Decimal OldVat1;
	    Decimal OldVat4;
	    String overwritestring = System.Label.VAT_Change_Date;
	    Date overwrite = date.valueOf(overwritestring);
		Date Closedate;
		List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,VAT_Code_4_Rate__c,VAT_Code_3__c,Status__c,start_date__c,
                                    VAT_Code_3_Rate__c,end_date__c,VAT_Code_2_Rate__c,VAT_Code_2__c,VAT_Code_1_Rate__c from VAT_Codes__c];
       for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        newvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_2__c !=null)
                        newvatBands.put(objvat.VAT_Code_2__c, objvat.VAT_Code_2_Rate__c);
                if(objvat.VAT_Code_3__c !=null)
                        newvatBands.put(objvat.VAT_Code_3__c, objvat.VAT_Code_3_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        newvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
                
            }else if (objvat.start_date__c <overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        oldvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_2__c !=null)
                        oldvatBands.put(objvat.VAT_Code_2__c, objvat.VAT_Code_2_Rate__c);
                if(objvat.VAT_Code_3__c !=null)
                        newvatBands.put(objvat.VAT_Code_3__c, objvat.VAT_Code_3_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        oldvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
            }
       }
		
        List<Quote_Product__c> ValidUDP = new List<Quote_Product__c>();
        Map<String,String> VATCodeMap = new Map<String,String>{'General VAT'=> '1','VAT Code 4 --> 5%'=> '4'};
        double VATRate;
        for(Quote_Product__c UDP : UDPQuoteProductsRelatingToASPs)
        {
            System.debug('UDP.Product__c-->'+UDP.Product__c);
            Id pid = UDP.Product__c;
            
            //Added the BM quote query for the VAT Changes------
            List<ID> triggerQuoteIDs = new List<ID>();  
            List<String> triggerProductNames = new List<String>();
            for(Quote_Product__c UDPQuoteProductsRelatingToASP : UDPQuoteProductsRelatingToASPs){
                triggerQuoteIDs.add(UDPQuoteProductsRelatingToASP.BigMachines_Quote__c);
                triggerProductNames.add(UDPQuoteProductsRelatingToASP.Name);
            }
            Map<Id,BigMachines_Quote__c> relatedQuotes = new Map<Id,BigMachines_Quote__c>([select closeDate__c from BigMachines_Quote__c where Id in:triggerQuoteIDs]);
            for(BigMachines_Quote__c relatedQuote : relatedQuotes.values()){                    
                Closedate = relatedQuote.closeDate__c;      
            }
        //VAT change query ending here.....
            Boolean test  = ProductIdUDPMap.get(pid).User_Defined_Product__c;
            //System.debug('ProductIdUDPMap.get(UDP.Product__c-->'+ProductIdUDPMap.get(UDP.Product__c);
            Product2 prod = ProductIdUDPMap.get(UDP.Product__c);
            if(UDP.User_Defined_Product__c == true && prod.User_Defined_Product__c == false)
            {
                UDP.addError('Please Uncheck the User defined product Check Box as you have selected Standard Product');
            }
            else if(UDP.User_Defined_Product__c == true && prod.User_Defined_Product__c == true && UDP.ASP_Reason__c == 'Added' && (UDP.User_Defined_VAT_Rate__c != null )&& (UDP.Unit_Price_Inc_VAT__c != null) && (UDP.Unit_Merchant_Price_Exc_VAT__c != null ) && (UDP.User_Defined_Description__c != null || UDP.User_Defined_Description__c != '') )
            {
                ValidUDP.add(UDP);
            }
        }
        for(Quote_Product__c UDP : ValidUDP)
        {   
            double UnitPriceIncVAT = UDP.Unit_Price_Inc_VAT__c;
            // Added for the VAT changes---START-----
            if(Closedate >=overwrite){
             VATRate = newvatBands.get(VATCodeMap.get(UDP.User_Defined_VAT_Rate__c));
            }else if(Closedate < overwrite){
             VATRate = oldvatBands.get(VATCodeMap.get(UDP.User_Defined_VAT_Rate__c));   
            }
            system.debug('VATRate--->'+VATRate);
            system.debug('VATRate--->'+Closedate);
            system.debug('VATRate--->'+overwrite);
            system.debug('VATCodeMap-->'+VATCodeMap);
            system.debug('newvatBands-->'+newvatBands);
            system.debug('User_Defined_VAT_Rate__c-->'+UDP.User_Defined_VAT_Rate__c);
            
            // Added for the VAT changes---end-----
            double UnitPriceExcVAT = (100*UnitPriceIncVAT)/(100+VATRate);
            double VATABeforeDiscount = UnitPriceExcVAT*VATRate/100;
            UDP.Sales_Price__c=UDP.Unit_Price_Inc_VAT__c;
            UDP.price_list_price_each__c = UnitPriceExcVAT;
            UDP.VATABeforeDiscount__c = VATABeforeDiscount;
            UDP.FirstVATProportion__c = 100;
            UDP.FirstVATCode__c = decimal.valueOf(VATCodeMap.get(UDP.User_Defined_VAT_Rate__c)).doubleValue(); 
            
        }
            
	}

}