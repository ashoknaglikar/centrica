@RestResource(urlMapping='/CustomerPortalFinanceSubmitApplication/*')
Global class CustomerPortalFinanceSubmitApplication {
    @HttpPost
    global static CustomerPortalFinanceRestHelper.responseWrapper loadFinanceApplication(String financeApplicationId, string oppId) {
        
        list<Portal_Errors__c> possibleErrors = Portal_Errors__c.getAll().values();
        
        CustomerPortalFinanceRestHelper.responseWrapper resObj = new CustomerPortalFinanceRestHelper.responseWrapper();
        resObj.errorClassList = new list<CustomerPortalFinanceRestHelper.errorClass>();
        List<Finance_Application__c> fApplications;
        try{
        system.debug('Finance Application id : --->'+financeApplicationId);
        
        system.debug('Finance Application id : --->'+oppId);
        
        string chiLeadId = CustomerPortalHelper.getOpportunityId(oppId);
        Portal_Errors__c genericError = Portal_Errors__c.getInstance('Generic Error');
        barclaysIntegrationHelper  barcalyshelper = new barclaysIntegrationHelper();
        fApplications = barcalyshelper.getFinanceApplication(new list<string>{financeApplicationId});
        string PaymentFreq = financeApplicationController.paymentsFrequency; 
        string po = fApplications[0].Payment_Options__c;
        string[] Popt = po.split('-'); 
        resObj.status = 'Success';
        if(financeApplicationId!=null )
        {
                if(!fApplications[0].Valid_New_Application__c)
                {
                   wwwBarclaysPartnerfinanceCom.ResultWO barcalysResponse = barcalyshelper.callBarclaysLoadApplication(financeApplicationId, chiLeadId, fApplications[0].Finance_Product__c, fApplications[0].Lead_Ext_Ref_No__c,fApplications[0].Deposit__c,fApplications[0].Cash_Price__c,Popt[0],PaymentFreq );
                   system.debug('barcalysResponse='+barcalysResponse);
                   if(label.testsite == '1' && barcalysResponse!=null && barcalysResponse.Errors!=null &&  barcalysResponse.Errors.ErrorsWO.size()>0)
                   {
                        resObj.status = 'Error';
                        fApplications[0].Error_Details__c= string.valueof(System.Now()); 
                        
                        for(wwwBarclaysPartnerfinanceCom.ErrorsWO err:barcalysResponse.Errors.ErrorsWO)
                        {
                            resObj.errorMessage.add(err.ErrorDescription);
                            CustomerPortalFinanceRestHelper.errorClass erroObj = new CustomerPortalFinanceRestHelper.errorClass();
                            erroObj.errorCode = genericError.Portal_Error_Code__c;
                            erroObj.errorMessage = genericError.Description__c;
                            resObj.status = 'Error';
                            /*
                            CustomerPortalFinanceRestHelper.errorClass erroObj;
                            erroObj = new CustomerPortalFinanceRestHelper.errorClass();
                            erroObj.errorCode = genericError.Portal_Error_Code__c;
                            erroObj.errorMessage = genericError.Description__c;
                            resObj.errorClassList.add(erroObj);
                            */
                            system.debug(err);
                            for(Portal_Errors__c p: possibleErrors)
                            {
                                
                                system.debug(p);
                                if( err!=null && err.ErrorCode != null && p.Barclays_Error_Code__c.contains(','+string.valueof(err.ErrorCode)+','))/*err.ErrorCode == 100 && p.Description__c.contains('/:'+p.Name)) || */
                                {
                                    erroObj = new CustomerPortalFinanceRestHelper.errorClass();
                                    
                                    erroObj.errorCode = p.Portal_Error_Code__c;
                                    erroObj.errorMessage = p.Description__c;
                                    resObj.errorClassList.add(erroObj);
                                    //break;
                                }
                               
                                
                            }
                            if(resObj.errorClassList.size()==0)
                            resObj.errorClassList.add(erroObj);
                            
                            fApplications[0].Error_Details__c +='  Next One: '+err.ErrorDescription;
                        }
                        
                    }
                    else
                    {
                    
                        resObj.status = 'Success';
                        
                    }
                    fApplications[0].Application_Status__c = label.TestFinanceStatus; //barcalysResponse.ApplicationStatus;
                    fApplications[0].status__c = label.TestFinanceStatus; //barcalysResponse.Status;
                    fApplications[0].Application_Id__c = '1234';//string.valueof(barcalysResponse.ApplicationId);
                    
                    
                    
                    
            }
            else 
            {
                fApplications[0] = barclaysPhase3Helper.submitFinanceApplication(fApplications[0]);
                
                resObj = CustomerPortalFinanceRestHelper.extractBarcalysError(fApplications[0],resObj);
                
            }
        }
        
        update fApplications[0];
        resObj.applicationID = fApplications[0].Id;
        resObj.applicationStatus = fApplications[0].Application_Status__c; 
        }
        catch(Exception e)
        {
            system.debug('Exception -- >'+e.getMessage() + e.getLineNumber());
            
            resObj.status = 'Error';
            if(fApplications.size()>0)
            resObj.applicationID =  fApplications[0].Id;
            resObj.errorMessage.add(e.getMessage() +' At line number'+ e.getLineNumber());
        }
        system.debug('Retrun -->'+resObj);
        return resObj;
    } 
}