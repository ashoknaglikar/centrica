/* setNetCustomerPriceOnQuote

 This trigger is used for invoking the logic which calculates net price charged to the customer on big machines quote in case of below events :
      
    --> When we submit the ASP --> Not done through this trigger but done when we decompile the quote products.
    
    --> When we plan the job or when allocated job recieves the matching quote from big machines
    
    --> We dont trigger this logic when installation date on the job is blank or when there is hours mismatch 
        between job which is already allocated and corresponding quote recieved from big machines in case of pre-allocation 
        or when we plan downtime or remedial jobs.
        Reason for this is downtime or remedial jobs are created as part of ASP submission.
        
    --> When we change the installation date on the job

    
*/

 trigger setNetCustomerPriceOnQuote on Job__c (after update) {
     //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.setNetCustomerPriceOnQuote)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch);
        System.debug('setNetCustomerPriceOnQuote : ' +Lock.setNetCustomerPriceOnQuote);
        return;
    }
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    
    // PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }
    Job__c oldJob;
    
    // Created for Priority Milestone
    List<Opportunity> oppList = new List<Opportunity>(); 
    
    CalculateQuoteNetValue c = new CalculateQuoteNetValue();
    
    List<BigMachines_Quote__c> bmQuoteList = new List<BigMachines_Quote__c>();
    
    BigMachines_Quote__c q;
    
    if(cls_IsRun.isCalculateNetCustomerPrice || Trigger.new.size()>1){
        
        return;
        
    }
    
    for(Job__c newJob : Trigger.new){
        Opportunity tempOpp = new Opportunity(Id = newJob.CHI_Lead__c);
        oldJob = Trigger.oldMap.get(newJob.Id);
        if(newJob.Is_Downtime_Job__c || newJob.isCancellation_Job__c || newJob.Is_Remedial_Job__c || newJob.Quote__c == null || newJob.Installation_Date__c == null){
            if(!newJob.Is_Downtime_Job__c && !newJob.isCancellation_Job__c && !newJob.Is_Remedial_Job__c && newJob.Status__c!=oldJob.Status__c)
            {
                tempOpp.Primary_Job_Status__c = newJob.Status__c;
                tempOpp.Job_Sub_Status__c = newJob.Sub_Status__c;
                update tempOpp;
            }

            continue;

        }

        
        
        boolean AddOpp=false;
        // ++ Added for Priority Milestone start
        if(((newJob.CRD_Code__c != oldJob.CRD_Code__c) && newJob.CRD_Code__c != null) || ((newJob.Job_Reason__c != oldJob.Job_Reason__c) && newJob.Job_Reason__c != null) && (cls_IsRun.isUpdateServiceLevelValues == false))
        {
            
            tempOpp.Installation_opt_out_reason__c = newJob.CRD_Code__c;
            tempOpp.Installation_Opt_Out_Type__c = newJob.Job_Reason__c;
            tempOpp.Last_customer_cat_info_update_source__c = 'Installation';
            tempOpp.Pending_update_to_customer_category__c = True;
            tempOpp.Customer_Category_Modified_Datetime__c = Datetime.Now();
            tempOpp.Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
            tempOpp.Stage_object_Type__c = 'Job';
            tempOpp.Stage_object_Id__c = newJob.Id;
            AddOpp=true;
            
        }
        if(newJob.GDF_Offer__c != oldJob.GDF_Offer__c)
        {
            tempOpp.GDF_Offer__c = newJob.GDF_Offer__c;
            AddOpp=true;
            cls_IsRun.setgeneralTriggerSwitch();
        }
        
        if(newJob.Status__c!=oldJob.Status__c)
        {
            tempOpp.Primary_Job_Status__c = newJob.Status__c;
            tempOpp.Job_Sub_Status__c = newJob.Sub_Status__c;
            AddOpp=true;
        }
        
        /*
            Change: Specify to Succeed.
            Description: Update Quote with TrialName
        
        if(newJob.Quote__c!= null && newJob.Trial_Names__c != oldJob.Trial_Names__c )
        {
            cls_IsRun.setgeneralTriggerSwitch();
            update( new BigMachines_Quote__c(id = newJob.Quote__c, Trial_Name__c= newJob.Trial_Names__c));
        }
        */
        
        if(AddOpp)
        oppList.add(tempOpp);
        // -- Added for Priority Milestone end
        
        if((oldJob.Installation_Date__c != newJob.Installation_Date__c && newJob.Status__c != 'Allocated' && newJob.Status__c != 'Pending')
        || (oldJob.Status__c != 'Planned' && newJob.Status__c == 'Planned' && newJob.Sub_Status__c != 'Quote Received Not Balanced')){
        
           cls_IsRun.setIsCalculateNetCustomerPrice();
            
           q = [select id, name, createdDate_quote__c,IsSystem__c, 
           Number_of_paperworks_recieved__c,
           Opportunity__r.Platform__c,
           Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
           Opportunity__r.Account.Primary_Contact__r.Salutation,
           Opportunity__r.Account.Primary_Contact__r.FirstName,
           Opportunity__r.Account.Primary_Contact__r.LastName,
           Opportunity__r.Account.BillingStreet,
           Opportunity__r.Account.BillingCity,
           Opportunity__r.Account.BillingState,
           Opportunity__r.Account.BillingPostalCode,
           Opportunity__r.Account.Primary_Contact__r.MailingCity,
           Opportunity__r.Account.Primary_Contact__r.MailingState,
           Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
           Opportunity__r.Account.Primary_Contact__r.MailingStreet,
           Opportunity__r.Payment_Reference_Number__c,
           Opportunity__r.Override_Billing_checks__c,
           Opportunity__r.discountsTotalOnPricing__c,
           Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,
           Opportunity__r.Bill_to_Office__c,
           Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
           VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
           VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
           Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
           priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
           newTotalNetPrice_quote__c,
           (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),
           (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
           (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
           (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
            from  BigMachines_Quote__c where ID = :newJob.Quote__c];
            
            bmQuoteList.add(q);
            
            c.calculateQuoteNetValueForCustomer(bmQuoteList);
            
        }
        /*
            Date: 14/05/2013
            Commented to improve the effeciency of code. This will remove the redudandnt Code.
        
        else if(oldJob.Status__c != 'Planned' && newJob.Status__c == 'Planned' && newJob.Sub_Status__c != 'Quote Received Not Balanced'){
           
           cls_IsRun.setIsCalculateNetCustomerPrice();
           
           
           q = [select id, name, createdDate_quote__c,IsSystem__c, 
           Number_of_paperworks_recieved__c,
           Opportunity__r.Platform__c,
           Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
           Opportunity__r.Account.Primary_Contact__r.Salutation,
           Opportunity__r.Account.Primary_Contact__r.FirstName,
           Opportunity__r.Account.Primary_Contact__r.LastName,
           Opportunity__r.Account.BillingStreet,
           Opportunity__r.Account.BillingCity,
           Opportunity__r.Account.BillingState,
           Opportunity__r.Account.BillingPostalCode,
           Opportunity__r.Account.Primary_Contact__r.MailingCity,
           Opportunity__r.Account.Primary_Contact__r.MailingState,
           Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
           Opportunity__r.Account.Primary_Contact__r.MailingStreet,
           Opportunity__r.Payment_Reference_Number__c,
           Opportunity__r.Override_Billing_checks__c,
           Opportunity__r.discountsTotalOnPricing__c,
           Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,
           Opportunity__r.Bill_to_Office__c,
           Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
           VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
           VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
           Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
           priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
           newTotalNetPrice_quote__c,
           (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),
           (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
           (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
           (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
            from  BigMachines_Quote__c where ID = :newJob.Quote__c];
            
            
            bmQuoteList.add(q);
            
            c.calculateQuoteNetValueForCustomer(bmQuoteList);
        
        }*/
        
    }
    
    // ++ Added for Priority Milestone start
    if(oppList.size() > 0)
    {
        try{
            update oppList;
        }
        catch(Exception ex){
            system.debug('-----Exception occurred------'+ex);
        }
    }
    // -- Added for Priority Milestone end
 }