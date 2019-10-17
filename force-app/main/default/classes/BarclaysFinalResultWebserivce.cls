global class BarclaysFinalResultWebserivce {
    
    global class CallbackCls{
        
        webservice string ProposalID;
        webservice ProposalStatusCls ProposalStatus;
        webservice CustomerAddressCls CustomerAddress;
        webservice SnagsCls Snags;
        webservice ChecklistConditionsCls ChecklistConditions;
        webservice string ClientReference;
        
    }
    
    global class ProposalStatusCls{
        webservice string Status; 
    }
    
    global class CustomerAddressCls{
        
        webservice string HouseNumber;
        webservice string HouseName;
        webservice string Flat;
        webservice string Street;
        webservice string District;
        webservice string Town;
        webservice string County;
        webservice string PostCode;
        
    }
    
    global class SnagsCls{
        
    }
    
    global class ChecklistConditionsCls{
        webservice list<ChecklistConditionCls> ChecklistConditionCls;
        
    }
    
    global class ChecklistConditionCls{
        webservice string Status;
        webservice string Satisfied;
        webservice string SatisfiedOn;
    }
    
    global class SalesforceReponseResult{
        
        webservice string callBackStatus;
        webservice boolean error;
        webservice integer errorCode;
        webservice string erroDetails;
        
    }
    
    webservice static SalesforceReponseResult updateFinaceCallBackDetails(CallbackCls Callback)
    {
        SalesforceReponseResult objRes = new SalesforceReponseResult();
        
        if(Callback.ClientReference!= null && Callback.ClientReference!='' && Callback.ProposalID!= null && Callback.ProposalID!= '')
        {
            list<Opportunity> opp = [Select id from Opportunity where Finance_Proposal_Id__c = : Callback.ProposalID and CHI_Lead_Id1__c = :Callback.ClientReference];
            if(opp.size()>0)
            {
                Opportunity oppRecord = opp[0];
                oppRecord.FinanceApplicationStatus__c = Callback.ProposalStatus.Status;
                //try {
                    update oppRecord;
                    objRes.callBackStatus = 'Sucess';
                    objRes.error = false;
                    objRes.errorCode = 0;
                /*}catch (Exception e)
                {
                    objRes.callBackStatus = 'Fail';
                    objRes.error = true;
                    objRes.errorCode = 1;
                    objRes.erroDetails= 'Opportunity Update failed. For Lead: '+Callback.ClientReference +' Due to following error: '+e.getmessage();
                }*/
                
            }else{
                objRes.callBackStatus = 'Fail';
                objRes.error = true;
                objRes.errorCode = 1;
                objRes.erroDetails= 'No Opportunity with that Ref or Propsal Number';
            }
            
            
        }else{
            objRes.callBackStatus = 'Fail';
            objRes.error = true;
            objRes.errorCode = 2;
            objRes.erroDetails= 'Client Reference Can not be blank';
        }
        return objRes;
    }
    

}