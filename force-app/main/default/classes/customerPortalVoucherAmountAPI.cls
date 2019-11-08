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
        //List<Offer__c> offerList = [select id,Description__c,start_date__c, end_date__c,Offer_Code__c,value__c from Offer__c where Offer_Code__c=:voucherCode];
        List<Lead_Offer__c> leadOffers = [Select id , Offer__r.Description__c, Offer__r.start_date__c,
                                          Offer__r.end_date__c, Offer__r.Offer_Code__c, Offer__r.value__c from Lead_Offer__c
                                          where Offer__r.Offer_Code__c=:voucherCode  and Offer__r.Active__c  = true 
                                          and opportunity__c=:oppId and Expiry_Date__c >= :system.today()];
        if(leadOffers.size()>0)
        {
            response.voucherCode=voucherCode;
            response.voucherName=leadOffers[0].Offer__r.Description__c;
            response.voucherAmount= leadOffers[0].Offer__r.value__c;
            response.initialQuotePrice= [select finalNetQuoteTotal__c from BigMachines_Quote__c where id=:quoteId].finalNetQuoteTotal__c;
            response.netQuotePrice = response.initialQuotePrice-response.voucherAmount;
            
            Lead_Offer__c leadoffer = new Lead_Offer__c(id = leadOffers[0].Id, status__c='In progress' );
            update leadoffer;
            
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