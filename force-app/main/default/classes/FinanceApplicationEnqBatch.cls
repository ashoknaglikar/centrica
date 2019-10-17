global class FinanceApplicationEnqBatch implements database.batchable<sobject>,Database.AllowsCallouts{
    
    public static void createEnqBatch()
    {
        FinanceApplicationEnqBatch objAutoPrd = new FinanceApplicationEnqBatch();
        integer i = integer.valueof(system.label.FinanceApplicationBatchSize);
        integer hour = system.now().hour();
        if(hour  == integer.valueOf(system.label.FinanceFullUpdateHour) )
        i = 1;
        
        ID batchprocessid = Database.executeBatch(objAutoPrd,i);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        list<string> status = system.label.Inter_End_Statuses.split(',');
        string statusCriteria = 'Application_Status__c  in:status';
        integer hour = system.now().hour();
        integer minute = system.now().minute();
        date x90Days = system.today().adddays(integer.valueOf(system.label.FinanceWindow));
        
        if(hour  == integer.valueOf(system.label.FinanceFullUpdateHour) )
        {
            status = system.label.End_Statuses.split(',');
            statusCriteria = 'Application_Status__c  NOT in:status';
            x90Days = system.today().adddays(integer.valueOf(system.label.FinanceBigWindow));
        }
        
        
        string applicationQuery  = Utilities.makeQueryWithAllFields('Finance_Application__c', '');
		applicationQuery = applicationQuery.replace('from Finance_Application__c' , ',Finance_Product__r.X2nd_Lender_Product__c,Finance_Product__r.Product_Code__c,Finance_Product__r.Asset_Type__c ,CHI_Lead__r.Product_Interest__c,CHI_Lead__r.ExternalRef__c,'+ 
		'Finance_Product__r.Not_Available_For__c, CHI_Lead__r.CHI_Lead_Id__c, Finance_Product__r.Parent_Product__r.Name, Finance_Product__r.Name, Finance_Product__r.Code__c,Finance_Product__r.Asset_Type_Description__c,'+
		'Finance_Product__r.New_Product__c, Finance_Product__r.Selling_Type__c from Finance_Application__c where ( '+statusCriteria +' OR   X2nd_Lended_Soft_Search__c = \'Referred\') and CreatedDate>=:x90Days');
        
        return Database.getQueryLocator(applicationQuery);
    }
    
    
    global void execute(Database.BatchableContext BC,  List<sObject> lstRecords)
    {
        string Subject = '';
        list<Finance_Application__c> updateList  = new list<Finance_Application__c>();
        for(sObject s: lstRecords)
        {
            Finance_Application__c fApplication = (Finance_Application__c)s;
            try{
                if(!fApplication.Valid_New_Application__c)
                {
                if(fApplication.Finance_Product__r.Name == system.label.X2ndLender || fApplication.Finance_Product__r.Parent_Product__r.Name  == system.label.X2ndLender)
                {
                    freedomFinanceHelper.returnClass returnObj= freedomFinanceHelper.statusUpdateFreedomFinance(fApplication);
                    if(returnObj!=null)
                    {
                        if(returnObj.isError!=null && returnObj.isError)
                        {
                            //fApplication.Application_Status__c = 'Errored';
                            fApplication.Referral_Reason__c =  returnObj.StatusReason;
                        }else
                        {
                            if(fApplication.Document_Link__c == null)
                            {
                                fApplication.X2nd_Lended_Soft_Search__c = returnObj.Status;
                            }else
                            {
                                fApplication.Application_Status__c = returnObj.Status;
                            }
                            if(returnObj.StatusReason!=null)
                            {
                                fApplication.Referral_Reason__c = returnObj.StatusReason;
                            }
                            if(returnObj.applicationId!=null)
                            {
                                fApplication.Application_Id__c = returnObj.applicationId;
                            }
                        }
                    }
                }else
                {
                    wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element AppEnq = FinanceApplicationDetail.enquiryHelper(fApplication);
                   if(!Test.IsRunningTest() && AppEnq!=null )
                   if(AppEnq!=null )
                    {
                        
                        if(AppEnq.Errors!=null && AppEnq.Errors.ErrorsWO!=null && AppEnq.Errors.ErrorsWO.size()>0){
                            string ErrDesc = '';
                            for(wwwBarclaysPartnerfinanceCom.ErrorsWO err:AppEnq.Errors.ErrorsWO){
                             ErrDesc +=err.ErrorDescription+'. ';
                            }
                            
                            fApplication.Application_Status__c = 'Errored';
                            fApplication.Referral_Reason__c =  ErrDesc;
                            
                         }else
                         {
                            fApplication.Application_Status__c = AppEnq.Application.ApplicationStatus;
                            fApplication.status__c = AppEnq.Status;
                            fApplication.Agreement_Number__c = AppEnq.Application.AgreementNumber;
                         }
                    }
                }
                }
                else
                {
                    fApplication = barclaysPhase3Helper.updateFinanceStatus(fApplication);
                }
                updateList.add(fApplication);
               }/*Catch(System.CalloutException e){
                   system.debug(LoggingLevel.INFO,''+e.getMessage());
                   //continue;
               }*/Catch(Exception e){
                   system.debug(LoggingLevel.INFO,''+e.getMessage());
                   //continue;
                   //integer count = 1; 
                   //while (count<10)
                   {
                   Subject += 'Error Finance : '+fApplication.Name+' '+e.getMessage()+' Line Number:'+e.getLineNumber()+' Application Id:  '+fApplication.Id+'     \n';
                   //count++;
                   }
               }
        }
        
        if(updateList.size()>0)
        Database.update(updateList,false);
        if(Subject!='')
        CreateEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'}, Subject, 'Error on Finance Batch');
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
   
 }