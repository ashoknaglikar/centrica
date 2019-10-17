@RestResource(urlMapping='/depositPayment/*')
Global class customerPortalDepositPayment {
    @HttpPost    
    global static customerPortalResponse depositPayment(string Sf_id,
                                                     string quoteId,   
                                                     decimal depositAmount,
                                                     String  depositReferenceNumber,
                                                     string mac,
                                                     string jlbz,
                                                     string transactionStatus,
                                                     String cardType,
                                                     datetime depositTime
                                                    )
    {       
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String oppId = CustomerPortalHelper.getOpportunityId(Sf_id);
        customerPortalResponse objResponse = new customerPortalResponse();
        
        //Bigmachines_Quote__c updateQuote = new  Bigmachines_Quote__c(id = quoteId);
        
        try{
            Opportunity Opp =  new Opportunity(id = oppId);
            system.debug(depositAmount);
            system.debug(depositReferenceNumber);
            system.debug(transactionStatus);
            system.debug(cardType);
            if(depositAmount!=null)
                opp.Portal_Deposit__c=depositAmount;
            if(!string.isBlank(depositReferenceNumber))
                opp.Payment_Reference_Number__c=depositReferenceNumber;
                opp.Portal_Quote_Status__c  = 'Deposit Collected';	
                opp.Portal_Substatus__c = 'Deposit Collected';
                integer offset = DiaryChangeHelperMethods.getTZOffset(depositTime.date())== 0?-1:0;
                opp.Portal_Deposit_date__c = depositTime.addHours(offset);
            update Opp;
            


            system.debug(Opp);
            BigMachines_Quote__c bq = new BigMachines_Quote__c(id  =quoteId, Portal_Status__c = 'Accepted', Portal_Substatus__c = 'Deposit Collected' );
            update bq;
            

            // Add payment records! 
            if(label.planningPortalLive == 'on')
            {
                BGS_Payment__c depositPayment = new BGS_Payment__c(Status__c = 'Receieved',
                                                                   Payment_Type__c = 'Deposit',
                                                                   Payment_Method__c = 'Debit Card',
                                                                   Amount__c = opp.Portal_Deposit__c,
                                                                   depositOnPricing__c = opp.Portal_Deposit__c,
                                                                   BGS_Payment_Reference_Num__c = depositReferenceNumber,
                                                                   Transaction_Successful__c = true,
                                                                   Opportunity__c = 	oppId

                                                                  );

                insert depositPayment;

            }
            
            objResponse.message = 'Sucessfully Deposit payment Updated.';
            objResponse.success = true;
        }catch (Exception e)
        {
            objResponse.message = 'Error while updating Deposit payment.';
            objResponse.success = false;
            system.debug('Error--->'+e.getMessage());
            
        }
        
        return objResponse;
    }
}