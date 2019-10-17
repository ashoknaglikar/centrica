@RestResource(urlMapping='/getQuotes/*')

global with sharing class customerPortalQuoteHelper {


	@HttpPost    
    global static customerPortalQuoteJson getQuote(string Sf_id)
    {
    	
    	customerPortalQuoteJson reply = new customerPortalQuoteJson();
    	reply.errorDetail = new customerPortalQuoteJson.errorClass();

    	reply.quoteList = new list<customerPortalQuoteJson.quoteClass>();
    	//reply.leadOfferList = new list<customerPortalQuoteJson.leadoffer>();
    	/*
    	Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        */
        String oppId = CustomerPortalHelper.getOpportunityId(Sf_id);
        /*
        if(!Sf_id.startswith(keyPrefix))
        {
            System.debug('SF_ID-->'+Sf_id);
            IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal');
            Blob key = Blob.valueOf(keyRecord.Key__c) ;//Blob.valueOf('380db410e8b11fa9');
            blob encrypted2 = EncodingUtil.convertFromHex(Sf_id);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted2);
            oppId = decrypted.toString();
            system.debug('--->'+oppId);
            
        }
		*/
    	/*if(Sf_id == '1' || Sf_id== null ||Sf_id == '2' )
    	{

	    	if(Sf_id == '1' || Sf_id== null)
	    	{
	    		reply.quoteList.add(buildQuoteJSON('a0dw000000CFKWX'));

			}else if(Sf_id == '2')
			{
				reply.quoteList.add(buildQuoteJSON('a0dw000000DOsHD'));
			}
			
			return reply;
		}else{*/	


	    	list<Id> validQuotes  = returnValidQuotes(oppId);
	    	reply.acceptNotAllowed = false;
	    	reply.showVoucherCode = [select count() from Lead_Offer__c where Opportunity__c =:oppId]> 0;
	    	
	    	
	    	
	    	if(validQuotes!=null && validQuotes.size()>0)
	    	{
	    		for(id quoteId  : validQuotes)
	    		{
	    			customerPortalQuoteJson.quoteClass quoteRecord = buildQuoteJSON(quoteId);
	    			if(quoteRecord!=null)
	    			{
	    				if(!quoteRecord.validQuote && !reply.acceptNotAllowed)
	    				reply.acceptNotAllowed = true;

	    				reply.quoteList.add(quoteRecord);
	    			}
	    		}

	    	}
	    	else
	    	{

	    		reply.errorDetail.errorCode = '1';
	    		reply.errorDetail.errorMessage = 'No Eligible Quotes to Display';

	    	}

	    	system.debug('JSON After Serializing-- >'+  JSON.serialize(reply));
	    	return reply;
    	//}

    	
    }

    public static list<id> returnValidQuotes(string oppID){

    	list<Id> eligibleQuotes = new List<Id>();

        datetime createdCutOff;
        //String productInterestNames = String.valueof(IV_Vectors__c.getInstance('Product Interest').Key__c);
        //List<string> prodInterest=productInterestNames.split(';');
        list<Bigmachines_Quote__c> bmQuotes = [select id, Name,Opportunity__c,Status__c,	 SubmittedDate_quote__c, Is_Primary__c, Stage__c, bmStatusReason__c,
													  FinalPriceVisibleToCustomer__c, 	DiscountsTotalOnPricing__c, FinalNetQuoteTotal__c, createdDate,Portal_Cut_Off_Time__c
													  from Bigmachines_Quote__c where Opportunity__c = :oppID];

		system.debug('bmQuotes-->'+bmQuotes);
		for(Bigmachines_Quote__c bq : bmQuotes)
		{
			// if Primary Quotes exists retrun null.
			if(bq.Is_Primary__c || bq.Status__c == 'Quote Finalised - Accepted')
			return null;
			
			//if status reson containds anything with Asbestos . Return null
			/*
			if(bq.bmStatusReason__c!=null && bq.bmStatusReason__c.contains('Asbestos'))
			return null;
			*/
			// check for quote expiry rule


			integer quoteExpiryDays = Integer.valueof(IV_Vectors__c.getInstance('Quote_Expiry_Days').Key__c);
			system.debug('Age of Qupote -->'+bq.SubmittedDate_quote__c.daysBetween(system.today()));
			system.debug('Expiry -->'+quoteExpiryDays);
            if(bq.Portal_Cut_Off_Time__c!=null)
            {
                createdCutOff = bq.Portal_Cut_Off_Time__c;
                
            }
            else
            {
                createdCutOff = bq.CreatedDate.addMinutes(Integer.valueof(IV_Vectors__c.getInstance('Quote_Created_Time').Key__c));
            } 
           
			
            system.debug('createdCutOff=='+createdCutOff);
			// this will stop expired quotes. 
			// also adds dealy to quotes 
			if(bq.SubmittedDate_quote__c!=null && bq.SubmittedDate_quote__c.daysBetween(system.today())<= quoteExpiryDays && createdCutOff < system.now())
			{
				eligibleQuotes.add(bq.Id);
			}
			
			
		

		}
		system.debug('Eligible Qupotes-->'+eligibleQuotes.size());
		return eligibleQuotes;

    }



	public static customerPortalQuoteJson.quoteClass buildQuoteJSON( string bmQuoteId)
	{
		customerPortalQuoteJson.quoteClass returnVar = new customerPortalQuoteJson.quoteClass();
		try{
				integer quoteExpiryDays = Integer.valueof(IV_Vectors__c.getInstance('Quote_Expiry_Days').Key__c)+1;

				list<Bigmachines_Quote__c> bmQuote = [select id, Name, Opportunity__c, SubmittedDate_quote__c, Is_Primary__c, Stage__c,
													  FinalPriceVisibleToCustomer__c, 	DiscountsTotalOnPricing__c, FinalNetQuoteTotal__c,bmStatusReason__c,
													  Warranty_Portal__c,Portal_Blocker__c,
													  (Select id, Name from Attachments),
													  (select id, Name, Product__c, Product_Description__c, Quantity__c,Quote_Description__c,
													  Gross_Total__c from Quote_Products__r)
													  from Bigmachines_Quote__c where Id = : bmQuoteId];

				if(bmQuote.size()>0)
				{
				    
					Bigmachines_Quote__c bmQuoteVar = bmQuote[0];
					returnVar.leadOfferList = buildLeadOfferJSON(bmQuoteVar.Opportunity__c);
                    
					returnVar.validQuote = true;

					// check Asbestos
					if(bmQuoteVar.Portal_Blocker__c == 'Lead')
					{
						returnVar.validQuote = false;
					}else if(bmQuoteVar.Portal_Blocker__c == 'Quote')	
					{
					    returnVar.validQuote = false;
					}

					returnVar.sfQuoteId 			= bmQuoteVar.Id;
					returnVar.quoteName 			= bmQuoteVar.Name;
					returnVar.totalAmountIncVAT 	= bmQuoteVar.FinalPriceVisibleToCustomer__c;
					returnVar.totalAllownacesIncVAT	= bmQuoteVar.DiscountsTotalOnPricing__c;
					returnVar.totalNetAmountIncVAT 	= bmQuoteVar.FinalNetQuoteTotal__c;
					returnVar.warranty 				= bmQuoteVar.Warranty_Portal__c;
					returnVar.quoteValidTill		= bmQuoteVar.SubmittedDate_quote__c.adddays(quoteExpiryDays);
					//get pdf from Attachements
					if(bmQuoteVar.Attachments.size()>0){
						for(Attachment attVar : bmQuoteVar.Attachments)
						{
							if(attVar.Name.contains('quote.pdf'))
							{
								returnVar.quotePDFId 	= attVar.Id;
								break;
							}
						}

					}else
					{
						return null;
						//returnVar.quotePDFId= '00P6E000003XcUM';
					}

					if(bmQuoteVar.Quote_Products__r.size()>0)
					{
						list<customerPortalQuoteJson.quoteProductClass> quoteProductList = new list<customerPortalQuoteJson.quoteProductClass>();
						for(Quote_Product__c qp: bmQuoteVar.Quote_Products__r)
						{
							if(qp.Name.touppercase().StartsWith('CBLR'))
							{
								customerPortalQuoteJson.quoteProductClass quoteProduct = new customerPortalQuoteJson.quoteProductClass();						quoteProduct.sfQuotePoductId = qp.Id;
								quoteProduct.sfProductCode = qp.Name;
								quoteProduct.description = qp.Product_Description__c;
								quoteProduct.quantity = qp.Quantity__c;
								quoteProduct.totalAmountIncVAT = qp.Gross_Total__c;

								quoteProduct.identifier = 'Boiler';
								quoteProductList.add(quoteProduct);

							}
						}

						if(quoteProductList.size()>0)
						returnVar.quoteProductList = quoteProductList;
						else
						return null;

					}
					else
					return null;



				}

				return returnVar;

			} catch (Exception e)
			{
				/*returnVar.errorDetail = new customerPortalQuoteJson.errorDetail();
				returnVar.errorDetail.errorCode = '1';
				returnVar.errorDetail.errorMessage = e.getMessage()+' . happened at line'+e.getLineNumber();*/

				system.debug(e.getMessage()+ '. happened at line'+e.getLineNumber());
				return null;
			}
	}
	
	public static List<customerPortalQuoteJson.offer> buildLeadOfferJSON( string oppid)
	{
	       List<customerPortalQuoteJson.offer> listOfLeadOffers = new List<customerPortalQuoteJson.offer>();
	       List<Lead_offer__c> lfList = [select id,Offer_Code__c,Offer_Description__c,Offer_Value__c from Lead_offer__c where Opportunity__c=:oppid and status__c='In progress'];
	       if(lfList.size()>0)
	       {
	           for(Lead_offer__c lf: lfList)
	           {
	               customerPortalQuoteJson.offer leadoff = new customerPortalQuoteJson.offer();
	               leadoff.voucherCode = lf.Offer_Code__c;
	               leadoff.voucherName = lf.Offer_Description__c;
	               leadoff.voucherAmount = lf.Offer_Value__c;
	               listOfLeadOffers.add(leadOff);
	           }
	       }
	       return listOfLeadOffers;
	}
	
}