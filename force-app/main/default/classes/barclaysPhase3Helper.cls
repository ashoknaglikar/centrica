public class barclaysPhase3Helper {
    
    public static map<string, string> statusMap = new map<string, string>{  'AWAITING_DECISION' => 'Awaiting Decision', 
                                                                            'AwaitingDecision' => 'Awaiting Decision',
                                                                            'ACCEPTED' => 'Accepted', 
                                                                            'REFERRED' => 'Referred', 
                                                                            'DECLINEALL' => 'Declined',
                                                                            'DECLINED' => 'Declined',
                                                                            'Accepted' => 'Accepted',
                                                                            'Referred' => 'Referred',
                                                                            'Declined' => 'Declined',
                                                                            'CONDITIONALLY_ACCEPTED' => 'Conditionally Accepted', 
                                                                            'CONDITIONAL_ACCEPT' => 'Conditionally Accepted',
                                                                            'ConditionallyAccepted' => 'Conditionally Accepted', 
                                                                            'NOT_TAKEN_UP' => 'Not Taken Up' ,
                                                                            'NotTakenUp' => 'Not Taken Up', 
                                                                            'CCA_CANCELLED' => 'CCA Cancelled',
                                                                            'CcaCancelled' => 'CCA Cancelled',
                                                                            'INTRODUCER_PENDING' =>'Introducer Pending', 
                                                                            'IntroducerPending' =>'Introducer Pending', 
                                                                            'PENDING'=> 'Pending', 
                                                                            'Pending'=> 'Pending', 
                                                                            'DOCUMENT_RECEIVED' => 'Document Received',
                                                                            'DOCUMENTS_RECEIVED' => 'Document Received',
                                                                            'DocumentReceived' => 'Document Received',
                                                                            'SNAGGED' => 'Snagged' , 
                                                                            'Snagged' => 'Snagged', 
                                                                            'PARKED'=>'Parked',
                                                                            'Parked'=>'Parked', 
                                                                            'CUSTOMER_CANCELLED' => 'Customer Cancelled' , 
                                                                            'CustomerCancelled' => 'Customer Cancelled' , 
                                                                            'THIRD_PARTY_CANCELLED'=> 'Third Party Cancelled',
                                                                            'ThirdPartyCancelled'=> 'Third Party Cancelled',
                                                                            'UNWOUND' => 'Unwound' , 
                                                                            'Unwound' => 'Unwound' ,
                                                                            'ACTIVE' => 'Active', 
                                                                            'Active' => 'Active', 
                                                                            'LIVE'=> 'Live',
                                                                            'Live'=> 'Live',
                                                                            'NewlyCreated' => 'Newley Created',
                                                                            'NEWLY_CREATED'=>'Newley Created',
                                                                            'EXPIRED' => 'Expired'
                                                                            
    };
    
    public static Finance_Application__c submitBarclaysApplication(Finance_Application__c fa)
    {
        string endPoint = label.barclays3baseURl +label.BarcalysSubmit3;
        
        system.debug('endpoint url '+endPoint);
        
        submitBarclaysv3  subObj = new submitBarclaysv3(fa);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        
        string body = JSON.Serialize(subObj);
        system.debug('req body'+body);
         
        req.setBody(body);
        
        Httpresponse response = sendRequest(req, true);
        
       
        
        if(response.getStatusCode() == 201)
        {
            barc3SubmitReponse jsonObj = barc3SubmitReponse.parse(response.getBody());
            fa.Application_Id__c = jsonObj.applicationId;
            fa.Application_status__c = statusMap.containskey(jsonObj.applicationStatus)? statusMap.get(jsonObj.applicationStatus):jsonObj.applicationStatus;
            fa.Lead_Ext_Ref_No__c = jsonObj.externalApplicationReference;
            fa.Status__c = 'Success';
            fa.Error_Details__c = null;
            
        }else
        {
            system.debug(response.getBody());
            errorListClass errlist = errorListClass.parse(response.getBody());
            system.debug(errlist);
            if(errlist!=null)
            for(errorListClass.ErrorClass  er: errlist.Errors)
            {
                er.ExceptionDetails = '';
            }
            fa.Error_Details__c = JSON.Serialize(errlist); 
            fa.Status__c = 'Error';
        }
        
        if(fa.Add_Logging__c)
        {
            fa.Request_JSON__c += 'Submit Barclays APP on:'+system.now()+' :'+body+'\n';
            fa.Request_JSON__c += 'Submit Response: '+response.getBody()+'\n';
        }
            
        return fa;
        
    }
    
    public static Finance_Application__c getBarclaysApplicationStatus(Finance_Application__c fa)
    {
        string applicationId = fa.Application_Id__c;
        
        string endPoint = label.barclays3baseURl + label.BarcalysSubmit3+applicationId;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        Httpresponse response = sendRequest(req, true);
        
        if(response.getStatusCode() == 200)
        {
            getStatusUpdate jsonObj = getStatusUpdate.parse(response.getBody());
            
            fa.Application_status__c = statusMap.containskey(jsonObj.applicationStatus)? statusMap.get(jsonObj.applicationStatus):jsonObj.applicationStatus;
            fa.Agreement_Number__c = jsonObj.agreementNumber;
            if(fa.Type_of_Finance__c == 'e-Finance' || userinfo.getUserName().contains('orckid'))
            fa.Finance_Link__c = label.CustomerSigningLink + jsonObj.clientCustomerAccessToken;
            else
            fa.Finance_Link__c = label.barclays3SignBaseURL + jsonObj.clientCustomerAccessToken;
            fa.Status__c = 'Success';
            fa.Error_Details__c = null;
            
        }else
        {
            system.debug(response.getBody());
            errorListClass errlist = errorListClass.parse(response.getBody());
            system.debug(errlist);
            if(errlist!=null)
            for(errorListClass.ErrorClass  er: errlist.Errors)
            {
                er.ExceptionDetails = '';
            }
            fa.Error_Details__c = JSON.Serialize(errlist); 
            fa.Status__c = 'Error';
            
        }
        
        if(fa.Add_Logging__c)
        {
            fa.Request_JSON__c += 'Get Barclays APP on:'+system.now()+'\n';
            fa.Request_JSON__c += 'Get Response: '+response.getBody()+'\n';
        }
        
        return fa;
        
        
        
    }
    
    
    
    public static Httpresponse sendRequest(HttpRequest request, boolean needsToken)
    {
        
        if(needsToken)
        {
            string token = getBearerToken();
            request.setHeader('Authorization', 'Bearer '+token);
        }
        
        system.debug('request-->'+request);
        
        Http m_http = new Http();
        request.setHeader('Content-Type','application/json');        
        request.setTimeout(120000);
        httpResponse response = m_http.send(request);
        system.debug('Response-->'+response.getBody());
        return response;
       
    }
    
    
    public static Finance_Application__c updateFinanceStatus(Finance_Application__c fApplication) 
    {
        system.debug('I am here updateFinanceStatus-->'+fApplication);
        if(fApplication.Lender_text__c == system.label.HoneyComb)
        {
            system.debug('I am here Honeycomb-->');
            fApplication = honeyCombFinanceHelper.getApplicationStatusHC(fApplication);
           
            // if Accpeted get the signingLink too
            if(fApplication.Application_Status__c.toUpperCase() == 'ACCEPTED')
            {
                fApplication = honeyCombFinanceHelper.getSigningLinkHoneyComb(fApplication);
            }
            
        }else if(fApplication.Finance_Lender__c == system.label.Barclays)
        {
            fApplication = barclaysPhase3Helper.getBarclaysApplicationStatus(fApplication);
            
        }
        if(fApplication.Application_Status__c.toUpperCase() == 'DECLINED' &&  fApplication.Finance_Product__r.X2nd_Lender_Product__c!=null  && fApplication.Sent_To_2nd_lender__c == null)
        {
            fApplication.Sent_To_2nd_lender__c = system.now();
            fApplication = cloneAndResubmitToNextLender(fApplication);
            
            fApplication = new barclaysIntegrationHelper().getFinanceApplication(new list<string>{fApplication.id})[0];
        }
        
        
        return fApplication;
    }
    
    public static  Finance_Application__c submitFinanceApplication(Finance_Application__c fApplication)
    {
        try{
        system.debug('I am in new Submit -->'+fApplication.Lender_Text__c.toUpperCase());
        fApplication.Lead_Ext_Ref_No__c = generateNextReferenceNumber(fApplication.CHI_Lead__r.ExternalRef__c, fApplication.CHI_Lead__r.CHI_Lead_Id__c);
        
        if(fApplication.Lender_Text__c.toUpperCase() == system.label.HoneyComb.toUpperCase())
        {
            fApplication = honeyCombFinanceHelper.submitApplication(fApplication, null);
            
        }else if(fApplication.Lender_Text__c.toUpperCase() == system.label.Barclays.ToUpperCase())
        {
            fApplication = barclaysPhase3Helper.submitBarclaysApplication(fApplication);
            
        }
        
        updateOpp(fApplication.CHI_Lead__c, fApplication.Lead_Ext_Ref_No__c);
        } catch (exception e)
        {
            updateOpp(fApplication.CHI_Lead__c, fApplication.Lead_Ext_Ref_No__c);
        }
        return fApplication;
    }
    
    public static Finance_Application__c cloneAndResubmitToNextLender(Finance_Application__c fApplication)
    {
        Finance_Application__c fClonnedApplication = fApplication.clone(false, true, false, false);
        Finance_Product__c nextLender = [Select Id, X2nd_Lender_Product__c, X2nd_Lender_Payment_Option__c, X2nd_Lender_Product__r.Product_code__c,X2nd_Lender_Product__r.Asset_Type_Description__c from Finance_Product__c where id = :fApplication.Finance_Product__c];
        fClonnedApplication.Finance_Product__c = nextLender.X2nd_Lender_Product__c;
        fClonnedApplication.Application_Status__c = '';
        fClonnedApplication.Status__c = '';
        fClonnedApplication.Agreement_Number__c = '';
        fClonnedApplication.Application_ID__c = '';
        fClonnedApplication.payment_Options__c=nextLender.X2nd_Lender_Payment_Option__c;
        fClonnedApplication.Lead_Ext_Ref_No__c = generateNextReferenceNumber(fApplication.Lead_Ext_Ref_No__c, fApplication.CHI_Lead__r.CHI_Lead_Id__c);
        fClonnedApplication.Do_Not_Derive_Product__c = true;
        fClonnedApplication.Finance_Link__c = null;
        // Call Honeycomb to submit
        fClonnedApplication = honeyCombFinanceHelper.submitApplication(fClonnedApplication, new Finance_Product__c(Product_Code__c = nextLender.X2nd_Lender_Product__r.Product_code__c , Asset_Type_Description__c = nextLender.X2nd_Lender_Product__r.Asset_Type_Description__c));
        
        // update old application 
        update fApplication;
        
        updateOpp(fClonnedApplication.CHI_Lead__c, fClonnedApplication.Lead_Ext_Ref_No__c);
        
        //insert fClonnedApplication;
        insert fClonnedApplication;
        
        return fClonnedApplication;
    }
    
    public static void updateOpp( id  chiLeadId, string externalRef)
    {
         update (new Opportunity(id =chiLeadId , ExternalRef__c = externalRef   ) );
    }
    
    public static string generateNextReferenceNumber(string referenceNumber, string LeadId)
    {
        system.debug(LeadId +' ' +referenceNumber);
        string ExternalReferenceNumber = LeadId+'-'+'1';
        if(referenceNumber!=null && referenceNumber.contains('-') )
        {
          string[] Ext = referenceNumber.split('-');
          ExternalReferenceNumber = Ext[0]+'-'+string.valueof(Integer.valueof(Ext[1])+1);
        }
        
        return ExternalReferenceNumber;
    }
    
    public static string getBearerToken()
    {
        string endPoint = label.barcalaysSecurity + label.Identity;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        string body = '{"clientId": "'+label.BarcalysUN3+'","password": "'+label.BarcalysPW3+'"}';
        
        system.debug('request token -->'+body);
        req.setBody(body);
        
        Httpresponse response = sendRequest(req, false);
        
        
        if(response.getStatusCode() == 200)
        {
            tokenClass jsonObj = tokenClass.parse(response.getBody());
            if(jsonObj.succeeded)
            return jsonObj.result;
            
            
        }else
        {
            system.debug(response.getBody());
        }
        
        
        return null;
    }
    
    
    
    
    

}