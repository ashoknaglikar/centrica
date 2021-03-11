//Rest API for customer portal for cloning the existing quote and converting it to a sold quote

@RestResource(urlMapping='/acceptCloneQuote/*')
global class customerPortalAcceptCloneQuote {
    
    @HttpPost    
    global static customerAcceptCloneQuotePortalResponse acceptCloneQuotemethod(
        string jobId,
        string leadId, 
        string quoteId,
        string paymentType,
        Decimal voucherAmount,
        String voucherName,
        String voucherCode
    )
    {  
        
          BigMachines_Quote__c csQuote = new BigMachines_Quote__c();
          BigMachines_Quote__c clonedQuoteToInsert = new BigMachines_Quote__c();
          List<Quote_Product__c> quoteProductList = New List <Quote_Product__c>();
          List<Quote_Product__c> quoteProductListToInsert =New List <Quote_Product__c>();
          List <Attachment> clonedAttachments = New List <Attachment>();
          List<Lead_Offer__c> leadOffList = new List<Lead_Offer__c>();
          Job__c jobResults = new Job__c();
          Integer count = 0;
    
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();        
        String oppId = CustomerPortalHelper.getOpportunityId(LeadID); 
        
        list<string> Latlang;
        List<Opportunity> oppList = [select id,Account.Primary_Contact__c,Portal_deposit__c, name,Account.Latitude__Latitude__s,Account.Latitude__Longitude__s,Account.BillingStreet,Account.BillingCity,Install_Postcode__c,(SELECT Id From BigMachines_Quotes__r) from Opportunity WHERE ID =:oppId]; 
        for(Opportunity opp : oppList){
            count = opp.BigMachines_Quotes__r.size();           
        
          /* if(!test.isRunningTest())
           {
                if(opp.Account.Latitude__Latitude__s!=null && opp.Account.Latitude__Longitude__s!=null)
                {
                    Latlang = new List<String>{String.valueOf(opp.Account.Latitude__Latitude__s),String.valueOf(opp.Account.Latitude__Longitude__s)};        
                }else
                {
                   
                    string street = opp.Account.BillingStreet!=null?opp	.Account.BillingStreet.normalizeSpace().replaceall(' ','+').trim():'';
                    string city = opp.Account.BillingCity!=null ? opp.Account.BillingCity.normalizeSpace().replaceall(' ','+').trim():'';
                    string pcode = opp.Install_Postcode__c!=null?opp.Install_Postcode__c.normalizeSpace().replaceall(' ','+').trim():'';
                  
                    string Address = street + '+'+city+ '+' +pcode;                    
                    Latlang = Utilities.getLatLang(Address,pcode,street,city);
                }
           }*/
           
        }
        
        customerAcceptCloneQuotePortalResponse objResponse = new customerAcceptCloneQuotePortalResponse();
        csQuote = database.query(Utilities.makeQueryWithAllFields('BigMachines_Quote__c', 'Where id =\''+quoteId+'\''));
       
        String csQuoteNumber = csQuote.Name.substring(0,csQuote.Name.length()-1); 
        String csQuoteNumberCheck = csQuote.Name;
        String attachmentName = csQuote.Name;   
        if(cls_isRun.iscopyQuoteAC==true)
        {
           attachmentName = attachmentName+'_AC';   
        }
        else
        {
           attachmentName = attachmentName+'_CP';   
        }
        Integer csQuoteNumberClone = count;
        objResponse.errorList = new list<string>();
        
        //Query the QuoteProducts related to the BigmachineQuote
        quoteProductList = database.query(Utilities.makeQueryWithAllFields('Quote_Product__c', 'Where BigMachines_Quote__c = \''+QuoteID+'\''));
        quoteProductListToInsert = new List<Quote_Product__c>();
        
        // make a clone of the BigMachineQuote
        clonedQuoteToInsert = csQuote.clone(true);
        clonedQuoteToInsert.id = null;
        
        clonedQuoteToInsert.CS_Quote__c = null;
        
        if(cls_isRun.iscopyQuoteAC==true)
        {
            clonedQuoteToInsert.Name = clonedQuoteToInsert.Name+ '_AC' ;
        }
        else
        {
        clonedQuoteToInsert.Name = clonedQuoteToInsert.Name+ '_CP' ;//csQuoteNumber+count;
        clonedQuoteToInsert.preparedBy_Quote__c = 'Customer Portal';
        }
        clonedQuoteToInsert.BigMachines_Transaction_Id__c = clonedQuoteToInsert.Name;
        clonedQuoteToInsert.stage__c = 'Quote Finalised - Accepted';
        clonedQuoteToInsert.bmStatusReason__c = 'Install Date Required';
        clonedQuoteToInsert.POC_Payment_Method__c = paymentType == 'Payment On Completion' ? 'Cash' : 'Finance';
        if(clonedQuoteToInsert.POC_Payment_Method__c == 'Cash')
        clonedQuoteToInsert.POC_Payment_Option__c = 'Cash';
        clonedQuoteToInsert.depositOnPricing__c = 0;
        clonedQuoteToInsert.closeDate__c = system.today();
        clonedQuoteToInsert.Quote_Finish_Time__c = system.now();
        clonedQuoteToInsert.submittedDate_quote__c = system.today();
        
        if(voucherAmount!=null && voucherAmount>0.0)
        {
        clonedQuoteToInsert.appliedAmount7__c = voucherAmount;
        clonedQuoteToInsert.appliedAllowancesTotal__c +=voucherAmount;
        clonedQuoteToInsert.discountsTotalOnPricing__c +=voucherAmount;
        clonedQuoteToInsert.finalNetQuoteTotal__c -=voucherAmount;
        clonedQuoteToInsert.totalNetPrice_quote__c -=voucherAmount;
        }
        if(voucherName!=null)
        clonedQuoteToInsert.allowance_desc_7__c = voucherName;
        if(voucherCode!=null)
        {
        clonedQuoteToInsert.Applied_Code_7__c=voucherCode;
        leadOffList = [select id from Lead_Offer__c where Offer_Code__c=:voucherCode and Opportunity__c=:oppid and status__c='In progress'];
        }
        
    
        if(oppList[0].Portal_deposit__c!=null)
        {
          clonedQuoteToInsert.depositOnPricing__c = oppList[0].Portal_deposit__c;
          
        }
       
        clonedQuoteToInsert.balancePricing__c  = clonedQuoteToInsert.finalPriceVisibleToCustomer__c-clonedQuoteToInsert.discountsTotalOnPricing__c -clonedQuoteToInsert.depositOnPricing__c;
        if(paymentType == 'Finance' && cls_isRun.iscopyQuoteAC!=true)
        {
          
          list<Finance_Application__c> fList  = [Select Finance_Lender__c, CreatedDate, Application_Status__c, Cash_Price__c, Agreement_Number__c From Finance_Application__c Where CHI_Lead__c  = : oppId ];
          Finance_Application__c fa = CustomerPortalHelper.getFinanceApplicationByStatus(fList, 'Parked');
          if(fa!=null)
          {
          clonedQuoteToInsert.POC_Payment_Option__c = fa.Finance_Lender__c;
          update new Contact(id =oppList[0].Account.Primary_Contact__c,  bm_fAcceptanceNumber__c = fa.Agreement_Number__c, bm_fAmountOfCredit__c = fa.Cash_Price__c,
                            bm_fApplicationDate__c = fa.CreatedDate.date(), 	bm_fApplicationStatus__c = 'Approved', bm_fFinancialProduct__c =fa.Finance_Lender__c, BM_Finance_Status_Date__c = system.today() );
          }

        }

       
        system.debug('cloned Quote--> '+clonedQuoteToInsert);
       //Inserting the big machine quote
        
        if(clonedQuoteToInsert!=null)
        {
            try
            {
                insert clonedQuoteToInsert;
            } 
            catch (Exception e)
            {
                objResponse.errorList.add(e.getMessage());                
            } 
        }
        //Clone the QuoteProducts
        for(Quote_Product__c quoteProduct : quoteProductList) 
        {
            Quote_Product__c cloneRecord = quoteProduct.clone();          
            cloneRecord.BigMachines_Quote__c = clonedQuoteToInsert.Id;
            quoteProductListToInsert.add(cloneRecord);
        }
        //Inserting the Quote Products
        try
        {            
            if(quoteProductListToInsert.size()>0 && quoteProductListToInsert!=null)
            {
                insert quoteProductListToInsert;
            }
        }
        Catch(exception e)
        {            
            objResponse.errorList.add(e.getMessage());
        }
           
        
        //Inserting the cloned attachments
        try
        {
            createAttachment(quoteId,clonedQuoteToInsert.id,attachmentName,clonedQuoteToInsert.BigMachines_Transaction_Id__c,clonedQuoteToInsert.Opportunity__c,csQuoteNumberCheck,csQuote.BigMachines_Transaction_Id__c);
        }
        catch(exception e)
        {           
            objResponse.errorList.add(e.getMessage());
        }       
        
        system.debug('cloned Quote id--> '+clonedQuoteToInsert.id);
        //Query the job related to the Quote 
        if(clonedQuoteToInsert.id!=null)
           if(!test.isRunningTest())
           jobResults = [SELECT Id,District__r.C_P_Planning_lead_time__c FROM Job__c where Quote__c = : clonedQuoteToInsert.Id];
           else
           jobResults = [select id from job__c limit 1];
        else
        objResponse.errorList.add('Error in Cloning the Quote');
          
       /*try
       {
        if(Latlang.size()==2 && Latlang[0] != 'null'  && Latlang[0] !=null && Latlang[1] != 'null'  && Latlang[1] !=null)
        {
            
            jobResults.Latitude__Latitude__s = double.valueof(Latlang[0]);
            jobResults.Latitude__Longitude__s = double.valueof(Latlang[1]);
            jobResults.Longitude__Latitude__s = double.valueof(Latlang[0]);
            jobResults.Longitude__Longitude__s =  double.valueof(Latlang[1]);
        }   
                    update jobResults;
        }
        catch(Exception e)
        {
             objResponse.errorList.add(e.getMessage());
        }*/
        //update contact
        
        
        if(cls_isRun.iscopyQuoteAC!=true)
        {
        // update status on Opportunity 
        update new Opportunity(id = oppId, Portal_Quote_status__c = 'Accepted', Portal_Substatus__c = paymentType, Portal_Quote__c =csQuote.Name, Portal_Accepted_Date_Time__c = System.now() );
              
        //update status on Bigmachines Quote
        update new BigMachines_Quote__c(id = QuoteID, Portal_Status__c = 'Accepted', Portal_Substatus__c = paymentType, Portal_Accepted_Date__c = System.now());
        }
        
        if(leadOffList.size()>0)
        {
            update new Lead_offer__c(id=leadOffList[0].id,status__c='Applied');
        }
        
        objResponse.quoteId =  clonedQuoteToInsert.Id;
        objResponse.leadId =  oppId;              
        objResponse.jobId = jobResults.Id;
       
        system.debug('Final Response -->'+jSON.serialize(objResponse));
        return objResponse;
        
    }
    
    @future(callout=true)
    public static void createAttachment(id quoteId, id clonedQuoteToInsertId,String attachmentName,String transId, id oppid,String csQuoteNumberCheck, String quoteTransId)
    {
        
         List <Attachment> clonedAttachments = New List <Attachment>();
         List<Attachment> attachments = New List <Attachment>();
        if(quoteId!=null) 
        attachments = [select  Id, 
                        Body, BodyLength, 
                        ContentType, 
                        Description, 
                        Name, 
                        OwnerId, 
                        ParentId, 
                        IsPrivate 
                        from   Attachment 
                        where ParentId = : QuoteID];
                                        
        //Cloning the attachment and insert to the new Quote
        if(attachments.size()>0)
        {
            for(Attachment atta : attachments)
            {
                if(atta.Name.contains('Installation notes'))
                {
                        Attachment att = atta.clone();
                        if(att.Name.contains(csQuoteNumberCheck))
                        {
                            att.Name = att.Name.replaceFirst(csQuoteNumberCheck, attachmentName);
                        } else if(att.Name.contains(quoteTransId))
                        {
                            att.Name = att.Name.replaceFirst(quoteTransId, attachmentName);
                        }
                    att.Description = 'cloned';
                    att.ParentId = oppid;	
                    clonedAttachments.add(att);
                }
            }
        } 
         
            PageReference qPage = Page.BMQuotePDF;
            qPage.getParameters().put('Id', clonedQuoteToInsertId);
            Attachment att1 = new Attachment();
            att1.name = transId+'_quote.pdf';
            if(Test.isRunningTest()) { 
                att1.body= blob.valueOf('Unit.Test');
            } else {
                att1.body =  qPage.getContent();
            }
            
            att1.parentid = clonedQuoteToInsertId;
            clonedAttachments.add(att1);
            
            system.debug(clonedAttachments);
            if(clonedAttachments.size()>0 && clonedAttachments!=null)
            {   
                insert clonedAttachments;
            }
         
    }
    
    
     @future(callout=true)
    public static void addAttachment(id Quoteid, string transId)
    {
        List<attachment> attachlist = [select id,name from attachment where parentid=:Quoteid and name like '%quote.pdf%'];
        
        List<Attachment> attlist = new List<Attachment>();   
        if(attachlist.isempty())
        {
                PageReference qPage = Page.BMQuotePDF;
                qPage.getParameters().put('Id', Quoteid);
                Attachment att1 = new Attachment();
                att1.name = transId+'_quote.pdf';
                if(Test.isRunningTest()) { 
                    att1.body= blob.valueOf('Unit.Test');
                } else {
                    att1.body =  qPage.getContent();
                }
                att1.parentid = Quoteid;
    	        attlist.add(att1);
        }
        system.debug('attlist '+attlist);
        if(!attlist.isempty())
	    insert attlist;
    }
}