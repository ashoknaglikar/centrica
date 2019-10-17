@RestResource(urlMapping='/customerCallBackUpdate/*')
global class customerPortalCallBackAPI {

	@HttpPost    
    global static callBackResponse callback(string leadId,String jobId,string quoteId,date callbackRequestDate,string callBackTime)
    {
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();        
        String oppId = CustomerPortalHelper.getOpportunityId(leadId);
        
        //List<Opportunity> oppList = [SELECT id,Opp_Id_Encrypted__c From Opportunity WHERE ID =:oppId];  
        
        callBackResponse returnResponse = new callBackResponse();
        
        Bigmachines_Quote__c updateQuote = new  Bigmachines_Quote__c(id = quoteId);
        if(callbackRequestDate!=null)
        updateQuote.Portal_Call_Back_Date__c = callbackRequestDate;
        if(callBackTime!=null)
        updateQuote.Portal_Call_Back_Time__c=callBackTime;
        update updateQuote;
        try{
    		
            
            Opportunity Opp =  new Opportunity(id = oppId);
            if(callbackRequestDate!=null)
            Opp.Portal_Call_Back_Date__c = updateQuote.Portal_Call_Back_Date__c;
            if(callBackTime!=null)
            Opp.Portal_Call_Back_Time__c = updateQuote.Portal_Call_Back_Time__c;
            opp.Portal_SubStatus__c = 'Call Back Requested';
            update Opp;
            
            returnResponse.callbackRequestDate = updateQuote.Portal_Call_Back_Date__c;        
            returnResponse.callBackTime = updateQuote.Portal_Call_Back_Time__c;
        }
        catch (Exception e)
    	{    		
    		returnResponse.errorList.add(e.getMessage());
        }
            
        returnResponse.jobId = jobID;
        returnResponse.leadId = oppId;
       // returnResponse.leadId = oppList[0].Opp_Id_Encrypted__c;
        returnResponse.quoteId = quoteId;
        system.debug('@@JSONrespone  '+JSON.serialize(returnresponse));
        system.debug('@@call back response '+returnresponse);
        return returnResponse;
    }
}