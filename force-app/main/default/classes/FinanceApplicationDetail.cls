public class FinanceApplicationDetail{
  
  string FId,oppId,fpId;
  public Finance_Application__c fApplication{get;set;}
  public string FR{get;set;}
  public string ErrDesc{get;set;}
  public boolean Err{get;set;}
  public boolean AppStatus{get;set;}
  public boolean btn_show {get;set;}
  boolean notEligibleForFF = false;
  public boolean isFreedomFinance{get;set;}
  // 2nd lender change
  public boolean fFinanceBtn {get;set;}
  public boolean applyFFFinance{get;set;}
  //public boolean submitFinish {get;set;}
  barclaysIntegrationHelper ojbBarclays;
  
  public boolean renderHighlight {get;set;}
  
  map<string, string> statusMap = new map<string, string>{'ACCEPT' => 'Accepted', 'REFER' => 'Referred', 'DECLINEALL' => 'Declined'};
  
  public FinanceApplicationDetail(){
   renderHighlight = false;
   //submitFinish = false;
   fFinanceBtn = false;
   applyFFFinance = false;   
  
   FId = ApexPages.currentPage().getParameters().get('FId');
   fpId = ApexPages.currentPage().getParameters().get('fpId');
   oppId = ApexPages.currentPage().getparameters().get('oppId');
   FR = ApexPages.currentPage().getparameters().get('FR');
   
   Err = false;
   ojbBarclays = new barclaysIntegrationHelper();
   if(FId!=null)
   fApplication = ojbBarclays.getFinanceApplication(new list<string>{FId})[0];  
   
   
   isFreedomFinance = false;
   
   if(fApplication.CHI_Lead__r.Product_Interest__c!=null && fApplication.Finance_Product__r.Not_Available_For__c!= null &&  fApplication.Finance_Product__r.Not_Available_For__c.contains(fApplication.CHI_Lead__r.Product_Interest__c))
   notEligibleForFF = true;
   
   if(fApplication.Finance_Product__r.Name == system.label.X2ndLender || fApplication.Finance_Product__r.Parent_Product__r.Name  == system.label.X2ndLender)
   isFreedomFinance = true;
   
   if(isFreedomFinance && fApplication.Interest_Rate__c != 14.90)
   renderHighlight = true;
   
   
    btn_show = true;             
    if(fApplication.Application_Status__c == 'Accepted' || fApplication.Application_Status__c == 'Declined' || fApplication.Application_Status__c == 'Awaiting Decision' || fApplication.Application_Status__c == 'Referred')   
    {
        btn_show = false;
    
    }
    
    if(FR== 'True')
    {
         
         btn_show = false;  
    }
   
  
  //decimal financeAmount,  string NumberOfPayments, string paymentFrequency,  string ExternalReferenceNumber
  
  }
    
  
  public void LoadApplication(){
     ApexPages.Message myMsg;
     string status = '';
     
     AppStatus = true;
     
     try{
     
     if(fApplication.Application_Status__c == 'Quote Online' || fApplication.Application_Status__c == 'Newly Created'  || fApplication.Application_Status__c == '' || fApplication.Application_Status__c == null)
     {
         system.debug(fApplication.Valid_New_Application__c);
         if(fApplication.Valid_New_Application__c)
         {
             // use new apis
             
             fApplication = barclaysPhase3Helper.submitFinanceApplication(fApplication);
             addErrorMessageToPage();
             
         }else
         {  
             if(!isFreedomFinance)
             {
                 string ExtRef = fApplication.Lead_Ext_Ref_No__c;
                 string PaymentFreq = financeApplicationController.paymentsFrequency; 
                 string po = fApplication.Payment_Options__c;
                 string[] Popt = po.split('-'); 
                 barclaysIntegrationHelper barInt = new barclaysIntegrationHelper();
                 wwwBarclaysPartnerfinanceCom.ResultWO loadApp = barInt.callBarclaysLoadApplication(FId,oppId,FpId,ExtRef,fApplication.Deposit__c,fApplication.Cash_Price__c,Popt[0],PaymentFreq);
                 fApplication.Application_Status__c = loadApp.ApplicationStatus;
                 fApplication.status__c = loadApp.status;
                 fApplication.Application_Id__c = string.valueof(loadApp.ApplicationId);
                 //update fApplication;
                 if(loadApp.Errors!=null){
                    ErrDesc='';
                    if(loadApp.Errors.ErrorsWO.size()>0){
                        Err = True;
                        for(wwwBarclaysPartnerfinanceCom.ErrorsWO err:loadApp.Errors.ErrorsWO){
                         ErrDesc +=err.ErrorDescription+' <br/>';
                        }
                    }
                     myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ErrDesc);
                    
                     //AppStatus = false;
                 } 
                 system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=load App:'+loadApp); 
                 
                if(fApplication.Application_Status__c == 'Declined' && !notEligibleForFF)
                 {
                   
                     fFinanceBtn = true;
                 }
                 
                 status = fApplication.Application_Status__c;
             }else if (isFreedomFinance)
             {
                if(fApplication.X2nd_Lended_Soft_Search__c == null )
                {
                    
                    freedomFinanceHelper.returnClass returnObj= freedomFinanceHelper.doSoftSearch(fApplication);
                    if(returnObj!=null)
                    if(returnObj.isError!=null && returnObj.isError)
                    {
                        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,returnObj.StatusReason);
                        ApexPages.addMessage(myMsg);
                        //AppStatus = false;
                        
                    }else
                    {
                        fApplication = ojbBarclays.getFinanceApplication(new list<string>{fApplication.Id})[0];
                        
                         if(fApplication.Interest_Rate__c != 14.90)
       						renderHighlight = true;
                        string info = '';
                        if(fApplication.X2nd_Lended_Soft_Search__c == 'Accepted') 
                        {
                            info = 'Status of Soft Search is ' +fApplication.X2nd_Lended_Soft_Search__c+'. Please go ahead & click apply button to apply with Freedom Finance.';
                            applyFFFinance = true;
                            //AppStatus = false;
                            //submitFinish = true; 
                            
                        }else if(fApplication.X2nd_Lended_Soft_Search__c == 'Declined')
                        {
                             info = 'Status of Soft Search is ' +fApplication.X2nd_Lended_Soft_Search__c;
                             //AppStatus = false;
                             //submitFinish = true; 
                        }else
                        {
                            info = 'Status of Soft Search is ' +fApplication.X2nd_Lended_Soft_Search__c;
                            //AppStatus = true;
                            //submitFinish = false; 
                        }
                        
                        
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,info);
                        //submitFinish = true;  
                       
                        
                    }
                }else if(fApplication.X2nd_Lended_Soft_Search__c == 'Accepted'  || fApplication.X2nd_Lended_Soft_Search__c == 'Declined' )
                {
                    //Submit Application
                    applyForFFApplication();
                    //AppStatus = false;
                    //submitFinish = true; 
                }
                status = fApplication.X2nd_Lended_Soft_Search__c;
             }
         }
     }else
     {
     
        ApplicationEnquiry();
        status= fApplication.Application_Status__c != null ? fApplication.Application_Status__c : fApplication.X2nd_Lended_Soft_Search__c;
     
     }
     
     if(status == 'Awaiting Decision' || status == 'Referred' )
     {
         myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Your Application is sucessfully submitted. Please wait for Decision to be made.Screen will Auto refresh in every 30 seconds..');
         //AppStatus = true;
         //submitFinish = false; 
     }
     else if(status == 'Accepted' || status == 'Declined' /*|| status == 'Awaiting Decision' || status == 'Referred'*/)
     {
         //AppStatus = true;
          ////submitFinish= false; 
        
         myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Your Application is now ' +status);
        
         //if(fApplication.Application_Status__c == 'Accepted' || fApplication.Application_Status__c == 'Declined')
         {
            AppStatus = false;
            //submitFinish = true; 
         }
          
        
     }
     
     }Catch(Exception e){
         myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() +' '+e.getlinenumber());
         
         //AppStatus = false;
     }
     if(myMsg!=null)
     ApexPages.addMessage(myMsg);
     btn_show = false;
     
     update fApplication;
     
     addErrorMessageToPage();
  
  }
  
  public void ApplicationEnquiry(){
      
      
     fApplication = FinanceApplicationDetail.ApplicationEnquiry1(fApplication, isFreedomFinance);
     string status = fApplication.Application_Status__c;
     if(!fApplication.Valid_New_Application__c)
     {
         if((fApplication.Finance_Product__r.Name == system.label.X2ndLender || fApplication.Finance_Product__r.Parent_Product__r.Name  == system.label.X2ndLender)&&  fApplication.Document_Link__c == null)
         {
             status = fApplication.X2nd_Lended_Soft_Search__c;
         }
         if(fApplication.Application_Status__c == 'Declined'  && !notEligibleForFF)
         {
            fFinanceBtn = true; 
         }
     }   
     string message = '';
     if(status == 'Awaiting Decision' || status == 'Referred' )
     {   
         message = 'Your Application is sucessfully submitted and Application is now a status of ' +status + ' Please wait for Decision to be made.Screen will Auto refresh in every 30 seconds..';
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,message);
         ApexPages.addMessage(myMsg);
         ErrDesc = message;
         Err = true;
        
         
         
     }
     
     if(status == 'Accepted' || status == 'Declined' )
     {
         
         //AppStatus = false;
         ApexPages.Message myMsg;
         myMsg = new ApexPages.Message(ApexPages.Severity.Info,message);
        
         if(status == 'Accepted'){
         ErrDesc = 'Your Application is now ' +status+' by '+fApplication.Finance_Lender__c+'. Please wait for customer to sign the document.';
         }
         else{
         ErrDesc = 'Your Application is now ' +status + ' by '+fApplication.Finance_Lender__c;
         }
         
         if(fApplication.Sent_to_2nd_Lender__c!=null)
         {
             ErrDesc = 'Your application is declined by Barclays and is ';
             if(status == 'Declined')
             ErrDesc = 'Your Application is declined by all lenders';
             else
             ErrDesc += status+' by '+fApplication.Finance_Lender__c;
         }
         
         
         Err = true;
         AppStatus = false;
         //submitFinish = false; 
        
     }
     
     
     update fApplication;
     
     
  }
  /*
  public void ApplicationEnquiryBtn(){
     string status ;
     if(fApplication.Valid_New_Application__c)
     {
         fApplication = barclaysPhase3Helper.updateFinanceStatus(fApplication);
         status =fApplication.Application_Status__c;
     }
     else
     {
         fApplication = FinanceApplicationDetail.ApplicationEnquiry1(fApplication, isFreedomFinance);
         
         if((fApplication.Finance_Product__r.Name == system.label.X2ndLender || fApplication.Finance_Product__r.Parent_Product__r.Name  == system.label.X2ndLender) && fApplication.Document_Link__c == null)
         {
         
             status = fApplication.X2nd_Lended_Soft_Search__c;
             
             if(status == 'Accepted'  && !notEligibleForFF)
             {
                 fFinanceBtn = true;
             }
         }else
         {
             status = fApplication.Application_Status__c;
         }
     }
     
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Your Application is now ' +status);
     ApexPages.addMessage(myMsg);
     
     addErrorMessageToPage();
     update fApplication;
     
  }
  */
  public static Finance_Application__c ApplicationEnquiry1(Finance_Application__c fApplication, boolean isFreedomFinance){
    ApexPages.Message myMsg;
    try{  
        
        if(fApplication.Valid_New_Application__c)
        {
            fApplication = barclaysPhase3Helper.updateFinanceStatus(fApplication);
            
        }
        else
        {
            if(!isFreedomFinance) 
            {
           
            
                wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element AppEnq = FinanceApplicationDetail.enquiryHelper(fApplication);
                system.debug(LoggingLevel.INFO,'-0-0-0-0-0-0-0-0-0-0->'+AppEnq);
                if(AppEnq.Errors!=null){
                string ErrDesc='';
                if(AppEnq.Errors.ErrorsWO.size()>0){
                  
                    for(wwwBarclaysPartnerfinanceCom.ErrorsWO err:AppEnq.Errors.ErrorsWO){
                     ErrDesc +=err.ErrorDescription+' ';
                    }
                    if(ErrDesc.contains('not found'))
                    {
                    	 AppEnq = FinanceApplicationDetail.enquiryHelper(fApplication);
                    }
                
                     myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ErrDesc);
                     ApexPages.addMessage(myMsg);
                    
                 }
             
             }else
             {
            
                fApplication.Application_Status__c = AppEnq.Application.ApplicationStatus;
                fApplication.status__c = AppEnq.Status;
                fApplication.Agreement_Number__c = AppEnq.Application.AgreementNumber;
                if((fApplication.Type_of_Finance__c == 'HSA' || fApplication.Type_of_Finance__c == 'Manual Finance') && AppEnq.GuidDetails!= null && AppEnq.GuidDetails.GuidDetailWO!=null && AppEnq.GuidDetails.GuidDetailWO.size()>0)
                {
                    fApplication.Document_Link__c = system.label.barclaysDocumentLink +AppEnq.GuidDetails.GuidDetailWO[0].Guid;
                    fApplication.Barcalys_Link_Application_Expiry__c = AppEnq.GuidDetails.GuidDetailWO[0].GuidExpiryDateTime;
                }
               
             }
            
            
            }else
            {
                freedomFinanceHelper.returnClass returnObj= freedomFinanceHelper.statusUpdateFreedomFinance(fApplication);
                if(returnObj!=null)
                {
                    if(returnObj.isError!=null && returnObj.isError)
                    {
                        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,returnObj.StatusReason);
                        ApexPages.addMessage(myMsg);
                        
                        
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
                
            }
        }
    }Catch(Exception e){
         myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getlinenumber());
         ApexPages.addMessage(myMsg);
     }
     return fApplication;
     
  }
  
  public pagereference cancel(){
    pageReference pageref;
   
    delete fApplication;
    pageref = new pagereference('/'+oppId);
    pageref.setRedirect(true);
    return pageref; 
    
  }
  
  public pagereference edit(){
   pageReference pageref = new pagereference('/apex/newBarclaysFinance?Id='+FId+'&FromDetail=T');
   pageref.setRedirect(true);
   return pageref;
  }
  
  public pagereference exit()
  {
      return (new pagereference('/'+fApplication.Id));
  }
  
  
  public static wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element enquiryHelper(Finance_Application__c fApplication)
  {
      if(fApplication.Application_ID__c!=null)
      {
          string outletcode = system.label.telesalesBarclaysOutlet;
          barclaysIntegrationHelper barInt = new barclaysIntegrationHelper();
          
          if(fApplication.createdDate < date.valueof(system.label.FinanceHSAOutletGolive) && (fApplication.Type_of_Finance__c == 'HSA' || fApplication.Type_of_Finance__c == 'Manual Finance'))
          {
              outletcode = fApplication.HSA__r.Barclays_Outlet__c;
          }else 
          {
              Finance_Product__c financeProd = [select id ,Outlet_Code__c, eFinance_outlet_Code__c, Manual_Finance_Outlet_Code__c from Finance_Product__c where id =:fApplication.Finance_Product__c];
              outletcode =  barInt.decideOutletCode(financeProd, fApplication.Type_of_Finance__c);
          }
          
          integer AppNum = Integer.valueof(fApplication.Application_ID__c);
          string ExtRefNo = fApplication.Lead_Ext_Ref_No__c;
          
          return (barInt.ApplicationEnquiry(ExtRefNo,AppNum,false,outletcode));
      }
        return null;
        
  }
  
  public pagereference doFFSoftSearch()
  {
      // clone the existing record to send for 2nd lender;
      
      if(fApplication.Application_Status__c == 'Declined'  )
      {
          Finance_Application__c clonnedFFApplication  = fApplication.clone(false, true, false, false);
          Finance_Product__c X2ndLender = [Select Id, X2nd_Lender_Product__c, X2nd_Lender_Payment_Option__c from Finance_Product__c where id = :fApplication.Finance_Product__c];
          clonnedFFApplication.Finance_Product__c = X2ndLender.X2nd_Lender_Product__c;
          clonnedFFApplication.Application_Status__c = '';
          clonnedFFApplication.Status__c = '';
          clonnedFFApplication.Agreement_Number__c = '';
          clonnedFFApplication.Application_ID__c = '';
          clonnedFFApplication.payment_Options__c=X2ndLender.X2nd_Lender_Payment_Option__c;
          clonnedFFApplication.Income_Band__c='Other';
          clonnedFFApplication.Do_Not_Derive_Product__c = true;
          // create new external Refnum;
          
          string ExternalReferenceNumber = fApplication.CHI_Lead__r.CHI_Lead_Id__c+'-'+'1';
          if(fApplication.CHI_Lead__r.ExternalRef__c!=null)
          {
              string[] Ext = fApplication.CHI_Lead__r.ExternalRef__c.split('-');
              ExternalReferenceNumber = Ext[0]+'-'+string.valueof(Integer.valueof(Ext[1])+1);
          }
          clonnedFFApplication.Lead_Ext_Ref_No__c  = ExternalReferenceNumber;
                
          insert clonnedFFApplication;
          system.debug('---->'+clonnedFFApplication.Lead_Ext_Ref_No__c);
          //update opp with new reference used
          Opportunity opp = new Opportunity(id =fApplication.CHI_Lead__c, ExternalRef__c = ExternalReferenceNumber );
          update opp;
          pagereference p = new pagereference('/apex/FinanceDetailPage?FR=True&FId='+clonnedFFApplication.id+'&oppId='+clonnedFFApplication.CHI_Lead__c+'&fpId='+clonnedFFApplication.Finance_Product__c );
          p.setredirect(true);
          return p;
      }else
      {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Declined Barclays Applications can be applied with Freedom '));
          return null;
      }
  }
  
  public void applyForFFApplication()
  {
      ApexPages.Message myMsg;
     
      if(fApplication.X2nd_Lended_Soft_Search__c == 'Accepted')
      {
          fApplication.Hard_Search_Date__c = system.now();
          freedomFinanceHelper.returnClass returnObj = freedomFinanceHelper.applyForFreedomFinance(fApplication);
          system.debug('returnObj--- >'+returnObj);
          
          if(returnObj!=null && returnObj.isError !=null && returnObj.isError)
          {
              myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,returnObj.StatusReason);
              AppStatus = false;
                
          }else
          {
                
              if(returnObj.StatusReason!=null)
              {
                  fApplication.Document_Link__c = returnObj.StatusReason;
                  fApplication.Application_Status__c = 'Accepted';
              }
              myMsg = new ApexPages.Message(ApexPages.Severity.info,'Your Application is sucessfully sent to Freedom Finance.If you need to access the loan documents a link is in the application screen'); 
          }
      }else
      {
          myMsg = new ApexPages.Message(ApexPages.Severity.error,'Soft serach status on this Application Not accepted. Please do the soft search first.'); 
      }
      
      update fApplication;
  }
  
  public void addErrorMessageToPage()
  {
      try{
          ApexPages.Message myMsg;
          if(fApplication.Error_Details__c!= null)
          {
              for(errorListClass.ErrorClass err : errorListClass.parse(fApplication.Error_Details__c).Errors)
              {
                  myMsg = new ApexPages.Message(ApexPages.Severity.error,err.ErrorMessage);
              }
              ApexPages.addMessage(myMsg);
          }
      }catch (exception e){
          system.debug(e.getMessage());
      }
  }
  
   
  
}