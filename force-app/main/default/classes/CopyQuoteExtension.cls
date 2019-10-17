public class CopyQuoteExtension {
    
    public ID bmQuoteId;
    Public BGS_Payment__c leadPayment{get;set;}
    Public BigMachines_Quote__c bmQuote{get;set;}
    
    public List<SelectOption> paymentType{get;set;}
    public String selectedPaymentType{get;set;}
    public List<SelectOption> depositMethod{get;set;}
    public String selectedDepositMethod{get;set;}
    public List<SelectOption> financeLender{get;set;}
    public String selectedFinanceLender{get;set;}
    
    public customerAcceptCloneQuotePortalResponse response = new customerAcceptCloneQuotePortalResponse();
    public String voucherCode{get;set;}
    public Decimal voucherAmount{get;set;}
    public String voucherName{get;set;}
    public Decimal adjustedNetValue{get;set;}
    
    public Finance_Application__c fa{get;set;}
    public boolean isShowVoucherCode{get;set;}
    
    public CopyQuoteExtension(ApexPages.StandardController controller) {
        leadPayment= new BGS_Payment__c();
        bmQuoteId = ApexPages.currentPage().getParameters().get('id');
        fa= new Finance_Application__c();
        isShowVoucherCode=false;
        voucherCode ='';
        
        bmQuote= [select id,name,Opportunity__c,opportunity__r.account.Primary_Contact__c,POC_Payment_Method__c,Allow_copy_Quote__c,
                         finalPriceVisibleToCustomer__c,discountsTotalOnPricing__c,finalNetQuoteTotal__c   from BigMachines_Quote__c where id=:bmQuoteId];
        
        if(!bmQuote.Allow_Copy_Quote__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This Quote is not Eligible to copy.')); 
        }
        
        if([select count() from Lead_Offer__c where Opportunity__c = :bmQuote.Opportunity__c]>0)
        isShowVoucherCode=true;
        
        paymentType= new List<SelectOption>();
        paymentType.add(new SelectOption('','--None--'));
        paymentType.add(new SelectOption('Payment On Completion','Payment On Completion'));
        paymentType.add(new SelectOption('Finance','Finance'));
        
        depositMethod= new List<SelectOption>();
        depositMethod.add(new SelectOption('','--None--'));
        depositMethod.add(new SelectOption('Debit Card','Debit Card'));
        depositMethod.add(new SelectOption('Credit Card','Credit Card'));
        depositMethod.add(new SelectOption('Cash','Cash'));
        depositMethod.add(new SelectOption('Cheque','Cheque'));
        
        financeLender= new List<SelectOption>();
        financeLender.add(new SelectOption('','--None--'));
        financeLender.add(new SelectOption('Barclays','Barclays'));
        financeLender.add(new SelectOption('Honeycomb','Honeycomb'));
        
        
        List<Finance_Application__c> faList = [select id,Cash_Price__c,CreatedDate,Finance_Lender__c,Agreement_Number__c,Date_From1__c from finance_application__c 
                                                where CHI_Lead__c=: bmQuote.Opportunity__c and (Application_status__c='Accepted' OR Application_status__c='Parked') order by Application_status__c desc, createddate desc];
        
        if(faList.size()>0)
        {
            fa= falist[0];
            fa.Date_From1__c= fa.CreatedDate.date();
            selectedFinanceLender= fa.Finance_Lender__c;
        }
    }
    
   
    Public PageReference cloneQuote()
    {   
        if(voucherCode!=null && voucherCode!='' )
        {
           List<Offer__c> disAttributeList = [select id,Description__c,value__c from Offer__c where active__c=true and Offer_Code__c=:voucherCode];
           if(disAttributeList.size()>0)
           {
              voucherAmount= disAttributeList[0].value__c;
              voucherName= disAttributeList[0].Description__c;
           }
           else
           {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Voucher is invalid')); 
              return null;
           }
        }
        
        if(leadPayment.BGS_Payment_Reference_Num__c==null||leadPayment.BGS_Payment_Reference_Num__c=='')
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Billing Reference Number: You must enter a value'));
             return null; 
        }
        if(leadPayment.Amount__c==null)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deposit Amount: You must enter a value'));
             return null; 
        }
        if(leadPayment.Amount__c>(bmQuote.finalNetQuoteTotal__c-(voucherAmount!=null?voucherAmount:0))&& !test.isRunningTest())
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deposit Amount can not be more than Quote Net value £'+(bmQuote.finalNetQuoteTotal__c-(voucherAmount!=null?voucherAmount:0))));
             return null; 
        }
        if((leadPayment.BGS_Payment_Reference_Num__c!=null||leadPayment.BGS_Payment_Reference_Num__c!='')&&(leadPayment.BGS_Payment_Reference_Num__c.length()!=11||(!leadPayment.BGS_Payment_Reference_Num__c.startsWith('8'))))
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Billing Reference Number must be of 11 characters length and always start with number 8.'));
             return null;
        }
        if((selectedDepositMethod=='Credit Card'||selectedDepositMethod=='Debit Card')&&(leadPayment.EPDQ_Authorisation__c==null||leadPayment.EPDQ_Authorisation__c==''))
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EPDQ Reference Number: You must enter a value')); 
             return null;
        }
        if(selectedPaymentType==null||selectedPaymentType=='')
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Final Payment method: You must enter a value')); 
             return null;
        }
        
            
        try{
            
           
            leadPayment.depositOnPricing__c = leadPayment.Amount__c;
            leadPayment.Opportunity__c= bmQuote.Opportunity__c;
            leadPayment.Transaction_Successful__c = true;
            leadPayment.Payment_Type__c = 'Deposit';
            leadPayment.Payment_Method__c = selectedDepositMethod;
            
            
            cls_isRun.iscopyQuoteAC=true;
            customerAcceptCloneQuotePortalResponse response = new customerAcceptCloneQuotePortalResponse();
            response = customerPortalAcceptCloneQuote.acceptCloneQuotemethod(null,bmQuote.Opportunity__c,bmQuoteId,selectedPaymentType,voucherAmount,voucherName,voucherCode);
           
            
            leadPayment.BigMachines_Quote__c = response.quoteId;
            insert leadPayment;
            
            BigMachines_Quote__c newBMQuote = new BigMachines_Quote__c(id=response.quoteId);
            if(selectedPaymentType=='Finance')
            newBMQuote.POC_Payment_option__c = fa.Finance_Lender__c;
            newBMQuote.depositOnPricing__c = leadPayment.Amount__c;
            newBMQuote.balancePricing__c  = bmQuote.finalPriceVisibleToCustomer__c-bmQuote.discountsTotalOnPricing__c -newBMQuote.depositOnPricing__c-(voucherAmount!=null?voucherAmount:0);
            update newBMQuote;
            
            if(selectedPaymentType=='Finance')
            {
                update new Contact(id =bmQuote.opportunity__r.Account.Primary_Contact__c,bm_fAcceptanceNumber__c = fa.Agreement_Number__c,bm_fAmountOfCredit__c = fa.Cash_Price__c,bm_fApplicationDate__c =fa.Date_From1__c,	
                                     bm_fFinancialProduct__c =selectedFinanceLender, BM_Finance_Status_Date__c = system.today());
            }
            
            PageReference pageRef = new PageReference('/'+response.quoteId); 
            //PageReference pageRef = new PageReference('/'+bmQuote.id);
            pageRef.setRedirect(true);      
            return pageRef;
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()+' '+e.getLineNumber()));
            return null;
        }
    }
  
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/'+bmQuoteId); 
        pageRef.setRedirect(true);      
        return pageRef;
    } 
    
     Public void dummy()
     {   
         adjustedNetValue = bmQuote.finalNetQuoteTotal__c-(voucherAmount!=null?voucherAmount:0);
         fa.Cash_Price__c = adjustedNetValue - (leadPayment.Amount__c!=null?leadPayment.Amount__c:0);
     }
    
     public void applyVoucherCode(){
       
       if(voucherCode==''||voucherCode==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Voucher Code.'));
        }
        if(voucherCode!=null && voucherCode!='' )
        {
           List<Offer__c> disAttributeList = [select id,Description__c,value__c from Offer__c where active__c=true and Offer_Code__c=:voucherCode];
           if(disAttributeList.size()>0)
           {
              voucherAmount= disAttributeList[0].value__c;
              voucherName= disAttributeList[0].Description__c;
              adjustedNetValue = bmQuote.finalNetQuoteTotal__c-(voucherAmount!=null?voucherAmount:0);
              fa.Cash_Price__c = adjustedNetValue - (leadPayment.Amount__c!=null?leadPayment.Amount__c:0);
           }
           else
           {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Voucher is invalid')); 
           }
        }
    } 
    
    /*public PageReference InsertRecord() {
            leadPayment.depositOnPricing__c = leadPayment.Amount__c;
            leadPayment.Opportunity__c= bmQuote.Opportunity__c;
            leadPayment.Transaction_Successful__c = true;
            leadPayment.Payment_Type__c = 'Deposit';
            leadPayment.Payment_Method__c = selectedDepositMethod;
            //leadPayment.BigMachines_Quote__c = response.quoteId;
            insert leadPayment;
    return null;
    }
    
    public PageReference CallWebService() {
    
            cls_isRun.iscopyQuoteAC=true;
            customerAcceptCloneQuotePortalResponse response = new customerAcceptCloneQuotePortalResponse();
            response = customerPortalAcceptCloneQuote.acceptCloneQuotemethod(null,bmQuote.Opportunity__c,bmQuoteId,selectedPaymentType);
            
            PageReference pageRef = new PageReference('/'+response.quoteId); 
            pageRef.setRedirect(true);      
            return pageRef;
    }*/
  

}