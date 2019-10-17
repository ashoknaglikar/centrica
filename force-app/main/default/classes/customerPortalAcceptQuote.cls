@RestResource(urlMapping='/acceptQuote/*')
global class customerPortalAcceptQuote {

	@HttpPost    
    global static customerPortalResponse acceptQuote(string Sf_id,
                                                  string quoteId, 
                                                  string quoteAcceptDateTime, 
                                                  string callbackRequestDate, 
                                                  String callBackTime,  
                                                  String paymentType, 
                                                  boolean customerAgreed)
    {

        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
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
        system.debug(paymentType);
    	customerPortalResponse objResponse = new customerPortalResponse();

    	Bigmachines_Quote__c updateQuote = new  Bigmachines_Quote__c(id = quoteId);
        if(paymentType == 'Cancelled')
        {
            updateQuote.Portal_Status__c = 'Cancelled';
        }else
        {
            if(quoteAcceptDateTime!=null)
        	updateQuote.Portal_Accepted_Date__c = datetime.parse(quoteAcceptDateTime);
            if(callbackRequestDate!=null)
        	updateQuote.Portal_Call_Back_Date__c = datetime.parse(callbackRequestDate).date();
            if(callBackTime!=null)
        	updateQuote.Portal_Call_Back_Time__c=callBackTime;
            if(paymentType!=null)
         	updateQuote.Portal_Status__c = 'Accepted';//paymentType!= 'Finance' ? 'Accepted':'Interested';
            if(paymentType!=null)
         	updateQuote.Portal_Substatus__c = paymentType;
            if(customerAgreed!=null)
            updateQuote.Customer_Accepted_T_C__c = customerAgreed;
        } 

    	try{
    		update updateQuote;
            // update opportunity with details:
            
            Opportunity Opp =  new Opportunity(id = oppId);
            if(quoteAcceptDateTime!=null)
            Opp.Portal_Accepted_Date_Time__c=  datetime.parse(quoteAcceptDateTime);
            if(paymentType!=null)
            Opp.Portal_Quote_Status__c = updateQuote.Portal_Status__c;
            if(paymentType!=null)
            Opp.Portal_SubStatus__c = updateQuote.Portal_Substatus__c;
            Opp.Portal_Quote__c = [Select Name From Bigmachines_Quote__c  where id = :quoteId].Name;
            if(callbackRequestDate!=null)
            Opp.Portal_Call_Back_Date__c = updateQuote.Portal_Call_Back_Date__c;
            if(callBackTime!=null)
            Opp.Portal_Call_Back_Time__c = updateQuote.Portal_Call_Back_Time__c=callBackTime;
            update Opp;
              

    		objResponse.message = 'Sucessfully Quote Updated.';
    		objResponse.success = true;
    	}catch (Exception e)
    	{
    		objResponse.message = 'Error while Quoting Quote.';
    		objResponse.success = false;
    		system.debug('Error--->'+e.getMessage());

    	}

        return objResponse;
    }

}