global class BatchCalculateCustomerNetPrice implements Database.Batchable<sObject>{
    
   public void calculateNetPrice(){
    
      BatchCalculateCustomerNetPrice objCalcNetPrice = new BatchCalculateCustomerNetPrice();
      
      ID batchprocessid = Database.executeBatch(objCalcNetPrice,50);
      
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
    
        return Database.getQueryLocator('Select id, name, createdDate_quote__c,IsSystem__c,'+ 
                          'Number_of_paperworks_recieved__c,'+ 
                          'Opportunity__r.Platform__c,'+ 
                          'Opportunity__r.CHI_Lead_Id__c,Opportunity__c,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.Salutation,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.FirstName,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.LastName,'+ 
                          'Opportunity__r.Account.BillingStreet,'+ 
                          'Opportunity__r.Account.BillingCity,'+ 
                          'Opportunity__r.Account.BillingState,'+ 
                          'Opportunity__r.Account.BillingPostalCode,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.MailingCity,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.MailingState,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,'+ 
                          'Opportunity__r.Account.Primary_Contact__r.MailingStreet,'+ 
                          'Opportunity__r.Payment_Reference_Number__c,'+ 
                          'Opportunity__r.Override_Billing_checks__c,'+ 
                          'Opportunity__r.discountsTotalOnPricing__c,'+ 
                          'Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,'+ 
                          'Opportunity__r.Bill_to_Office__c,'+ 
                          'Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,'+ 
                          'VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,'+ 
                          'VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,'+ 
                          'Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c,'+  
                          'priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,'+ 
                          'newTotalNetPrice_quote__c,'+ 
           '(Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),'+ 
           '(Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = \'INST\'),'+                                                                       
           '(Select Id From Quote_Products__r where Product__r.Do_Not_Consider_For_Net_Price_Calc__c = TRUE),'+ 
           '(Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)'+ 
           'from  BigMachines_Quote__c where Opportunity__r.Platform__c = \'SFDC\' and Consider_for_Installation_Planning__c = \'Y\' and Line_Items_Decompiled__c = TRUE and Net_Price_Charged_To_Customer__c=null' );
        
   } 
 
   global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
     	
      cls_IsRun.setDontFireTriggers();
      
      List<BigMachines_Quote__c> tempQuotesList = new List<BigMachines_Quote__c>();
      
      BigMachines_Quote__c tmpQuote;
      
      List<Quote_Product__c> qpListToDummyUpdate = new List<Quote_Product__c>();
      
      for(sObject sObj : lstRecords){
        
         tempQuotesList.add((BigMachines_Quote__c)sObj);
         
         tmpQuote = (BigMachines_Quote__c)sObj;
         
         if(tmpQuote.Quote_Products__r.size()>0){
          
          System.debug('####################################################'+tmpQuote.Name);
          
             for(Quote_Product__c qp : tmpQuote.Quote_Products__r){
            
                qpListToDummyUpdate.add(qp);

             }
          
         }
         
      }
      
      if(qpListToDummyUpdate.size()>0){
        
        update qpListToDummyUpdate;
        
      }
      
      if(tempQuotesList.size()>0){
        
         CalculateQuoteNetValue c = new CalculateQuoteNetValue();
         
         c.calculateQuoteNetValueForCustomer(tempQuotesList);
        
      }
   
   }
    
   global void finish(Database.BatchableContext BC){}

}