@RestResource(urlMapping='/getVoucherAmount/*')
global class customerPortalVoucherAmountAPI {

	@HttpPost    
    global static customerportalDiscountAmountResponse getVoucherAmount(string leadId,
                                                  string quoteId, 
                                                  string voucherCode)
    {

        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String oppId = CustomerPortalHelper.getOpportunityId(leadId);
        
        customerportalDiscountAmountResponse response= new customerportalDiscountAmountResponse();
        List<Offer__c> offerList = [select id,Description__c,start_date__c, end_date__c,Offer_Code__c,value__c from Offer__c where active__c=true and Offer_Code__c=:voucherCode];
        List<Lead_Offer__c> leadOffers = [Select id from Lead_Offer__c where Offer__c  in :offerList and opportunity__c=:oppId ];
        if(offerList.size()>0)
        {
            response.voucherCode=voucherCode;
            response.voucherName=offerList[0].Description__c;
            response.voucherAmount= offerList[0].value__c;
            response.initialQuotePrice= [select finalNetQuoteTotal__c from BigMachines_Quote__c where id=:quoteId].finalNetQuoteTotal__c;
            response.netQuotePrice = response.initialQuotePrice-response.voucherAmount;
            
            Lead_Offer__c leadoffer = new Lead_Offer__c(opportunity__c = oppId,offer__c=offerList[0].id,status__c='In progress' );
            if(leadOffers.size()>0)
            leadoffer.id = leadOffers[0].Id;
            try{
                upsert leadoffer;
            }catch(Exception e)
            {
                response.errorList.add('Error in applying vouchercode.'); 
            }
            
        }
        else
        {
           response.errorList.add('The voucher is invalid'); 
        }
        response.LeadID=oppId;
        response.QuoteID =quoteId;
        system.debug('JSON After Serializing-- >'+  JSON.serialize(response));
        return response;
    }
}