trigger trg_updateOpportunityPaymentDetails on BigMachines_Quote__c (after insert,after update) {

 // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
 	system.debug('Error--->cls_IsRun.dontFireTriggers'+cls_IsRun.dontFireTriggers);
    system.debug('Error--->cls_IsRun.istrg_updateOpportunityPaymentDetails'+cls_IsRun.istrg_updateOpportunityPaymentDetails);
    system.debug('Error--->cls_IsRun.bigMachineSwitch '+cls_IsRun.bigMachineSwitch );
    system.debug('Error--->cls_IsRun.bigMachineSwitch '+cls_IsRun.isBGRun );
    system.debug('Error--->cls_IsRun.bigMachineSwitch '+trigger.isInsert +' '+trigger.isUpdate);
    
    if(cls_IsRun.dontFireTriggers || cls_IsRun.bigMachineSwitch || cls_IsRun.istrg_updateOpportunityPaymentDetails){
        return;
    }

 // Fix - Cognizant support - To reduce number of SOQL's in quote triggers to avoid governor limits.
  private ID oppId = Trigger.new[0].Opportunity__c;
  private BigMachines_Quote__c quote = Trigger.new[0];
  private Integer inc;
 
  
  // ++ Added for Priority Installations CR start
    List<Customer_category__c> custCatList = new List<Customer_category__c>();
  // -- Added for Priority Installations CR end
   
  // ++ Added for Smart Meter CR start
  Set<Id> quoteIds = new Set<Id>();
  if(Trigger.isAfter)
  {
    for(Integer i =0; i < Trigger.new.size(); i++)
      {
        if(Trigger.isUpdate)
        {
            if(((Trigger.new[i].Smart_Meter_Creator__c == True && (Trigger.new[i].Smart_Meter_Creator__c != Trigger.old[i].Smart_Meter_Creator__c)) || (Trigger.new[i].Smart_Meter_Required_Flag__c == 'Yes' && (Trigger.new[i].Smart_Meter_Required_Flag__c != Trigger.old[i].Smart_Meter_Required_Flag__c))) &&  Trigger.new[i].Is_Primary__c && Trigger.new[i].Consider_for_Installation_Planning__c == 'Y' && system.label.SmartMeterRecord == 'on')
            {
                quoteIds.add(Trigger.new[i].id);
            }
        }
        else if(Trigger.isInsert)
        {
            if((Trigger.new[i].Smart_Meter_Creator__c == True || Trigger.new[i].Smart_Meter_Required_Flag__c == 'Yes') && Trigger.new[i].Is_Primary__c && Trigger.new[i].Consider_for_Installation_Planning__c == 'Y' && system.label.SmartMeterRecord == 'on')
            {
                quoteIds.add(Trigger.new[i].id);
            }
        }
        
      }
      if(quoteIds.size() > 0)
      {
        SmartMeterHelper.createSmartMeterRecord(quoteIds);
      }
  }
   
  // -- Added for Smart Meter CR end
    if(trigger.isUpdate)
    {
        BigMachines_Quote__c Oldquote = Trigger.old[0];
        if(Oldquote.POC_Payment_Option__c == 'Green Deal Finance' && quote.POC_Payment_Option__c != 'Green Deal Finance' && quote.POC_Payment_Method__c != 'Finance')
        {
            cls_IsRun.dontFireTriggers = true;
            cls_IsRun.generalTriggerSwitch=true;
            update(new Opportunity(id =quote.Opportunity__c,  Finance_Amount__c= 0.0));
            update(new Contact(id =quote.Contact_Id__c, bm_fFinancialProduct__c = '', bm_fAmountOfCredit__c = 0.0 ));
        }
    }
  
    if (Trigger.size == 1 && oppId != null && cls_IsRun.isBGRun==false && quote.App_Assigned_Payroll__c !=null) {
        
        cls_IsRun.setIsBGRun();
        
        // ++ Added for Priority Installations CR start
            Employee__c emp = new Employee__c();
            List<Employee__c> empList = [Select e.Salesforce_User__r.Id, e.Salesforce_User__c, e.Employee_Number__c 
                               from Employee__c e where e.Employee_Number__c =: quote.App_Assigned_Payroll__c];
            if(empList.size() > 0)
            {
                emp = empList[0];
            }
        // -- Added for Priority Installations CR end
             
        // ++ Modified query for Priority Installations CR start               
        Opportunity opp = [select Id,Deposit_Amount__c,isSystem__c,CreatedById,
                           QuoteIncrementer__c,closeDate__c,Manual_Bill__c,
                           Amount,ASP_Addition__c,ASP_Discount__c,ASP_Removal__c,
                           Original_Quote_Value__c,discountsTotalOnPricing__c,VAT2_Amount__c,
                           Billed_Status__c,Sales_Paperwork_Count__c,VAT1_Amount__c,Sold_Quote_Received_Date__c,
                           Quote_Payment_Method__c,New_Net_Contract_Value__c,Price_Mismatch__c,InDifference_Value__c,New_Net_Contract_Price__c,
                           Latest_customer_category__c , Customer_have_any_other_form_of_HEAT__c , Does_the_customer_have_hot_water__c ,
                           Is_the_customers_boiler_working__c , Is_the_customer_vulnerable__c , Vulnerable_reason__c ,
                           Last_customer_cat_info_update_source__c , Pending_update_to_customer_category__c , Customer_Category_Modified_Datetime__c ,
                           CreatedDate ,Customer_Category_Record_Modified_By__c ,
                           (Select Id , Type__c , isLocked__c From Customer_categories__r where Type__c =: 'Sales'),
                           (Select Id from BigMachines_Quotes__r where Name != :(Trigger.new[0].Name) and Consider_For_Installation_Planning__c = 'Y') 
                           from Opportunity where ID=:oppId];
        
        
        // SO Change End 
        // ++ Added for Priority Installations CR start
        Boolean updateExistingSalesCustCatRecord = false;
        //if((opp.BigMachines_Quotes__r.size() == 0) && ((opp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)))
        if(((opp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)) && (cls_IsRun.isRestrictCustCategory == false))
        {
                      //if(Trigger.isInsert)
                      //opp.BM_Quote_Download_into_SFDC_datetime__c = DateTime.now();
                      
                      if(opp.Customer_categories__r.size() == 0)
                      {
                            opp.BM_Quote_Download_into_SFDC_datetime__c = DateTime.now();  
                            system.debug('-------opp.BM_Quote_Download_into_SFDC_datetime__c---'+opp.BM_Quote_Download_into_SFDC_datetime__c);   
                            opp.Latest_customer_category__c = quote.Latest_customer_category__c;
                            opp.Customer_have_any_other_form_of_HEAT__c = quote.Customer_have_any_other_form_of_HEAT__c;
                            opp.Does_the_customer_have_hot_water__c = quote.Does_the_customer_have_hot_water__c;
                            opp.Is_the_customers_boiler_working__c = quote.Is_the_customer_s_boiler_working__c;
                            opp.Is_the_customer_vulnerable__c = quote.Is_the_customer_vulnerable__c;
                            opp.Vulnerable_reason__c = quote.Vulnerable_reason__c;
                            opp.Last_customer_cat_info_update_source__c = 'Sales';
                            opp.Pending_update_to_customer_category__c = true;
                            opp.Customer_Category_Modified_Datetime__c = DateTime.now();
                            opp.Customer_Category_Record_Modified_By__c = emp.Salesforce_User__c;
                            opp.Stage_Object_Type__c = 'Bigmachines quote';
                            opp.Stage_object_id__c = quote.Id;
                    
                      }else {
                        
                            if(quote.Is_Primary__c && quote.stage__c == 'Quote Finalised - Accepted')
                            {
                                opp.BM_Quote_Download_into_SFDC_datetime__c = DateTime.now();
                                updateExistingSalesCustCatRecord = true;
                            }
                            else if(quote.stage__c != 'Quote Finalised - Accepted')
                            {
                                opp.isLocked__c = true;
                            }
                            else if(opp.Latest_customer_category__c != quote.Latest_customer_category__c){
                                  opp.Latest_customer_category__c = quote.Latest_Customer_category__c;
                                  updateExistingSalesCustCatRecord = true;
                            }
                            else if(opp.Customer_have_any_other_form_of_HEAT__c != quote.Customer_have_any_other_form_of_HEAT__c){
                                  opp.Customer_have_any_other_form_of_HEAT__c = quote.Customer_have_any_other_form_of_HEAT__c;
                                  updateExistingSalesCustCatRecord = true;
                            }
                            else if(opp.Does_the_customer_have_hot_water__c != quote.Does_the_customer_have_hot_water__c){
                                 opp.Does_the_customer_have_hot_water__c = quote.Does_the_customer_have_hot_water__c;
                                 updateExistingSalesCustCatRecord = true;
                            }
                            else if(opp.Is_the_customers_boiler_working__c != quote.Is_the_customer_s_boiler_working__c){
                                 opp.Is_the_customers_boiler_working__c = quote.Is_the_customer_s_boiler_working__c;
                                 updateExistingSalesCustCatRecord = true;
                            }
                            else if(opp.Is_the_customer_vulnerable__c != quote.Is_the_customer_vulnerable__c){
                                 opp.Is_the_customer_vulnerable__c = quote.Is_the_customer_vulnerable__c;
                                 updateExistingSalesCustCatRecord = true;
                            }
                            else if(opp.Vulnerable_reason__c != quote.Vulnerable_reason__c){
                                 opp.Vulnerable_reason__c = quote.Vulnerable_reason__c;
                                 updateExistingSalesCustCatRecord = true;
                            }

                            if(updateExistingSalesCustCatRecord){
                                opp.Last_customer_cat_info_update_source__c = 'Sales';
                                opp.Pending_update_to_customer_category__c = true;
                                opp.Customer_Category_Modified_Datetime__c = DateTime.now();
                                opp.Customer_Category_Record_Modified_By__c = emp.Salesforce_User__c;
                                opp.Stage_Object_Type__c = 'Bigmachines quote';
                                opp.Stage_object_id__c = quote.Id;
                            }
                             
                      }

        }
        // -- Added for Priority Installations CR end
       
       system.debug('-----obj_opportunity before ----' +opp);
                                               
        if(quote.Is_Primary__c == True){
        		 
                    
            if(quote.Quote_Net_Value__c!=null)
                opp.Amount = quote.Quote_Net_Value__c;
            else
                opp.Amount = quote.totalNetPrice_quote__c;
            if( quote.Frozen_BM_Gross__c!=null)
                opp.Original_Quote_Value__c = quote.Frozen_BM_Gross__c;
            else
                opp.Original_Quote_Value__c = quote.finalPriceVisibleToCustomer__c; 
            
            opp.ASP_Addition__c = quote.ASP_Additions__c;
            opp.ASP_Discount__c = quote.ASP_Discounts__c;
            opp.ASP_Removal__c  = quote.ASP_Removals__c ;
            
            opp.discountsTotalOnPricing__c = quote.discountsTotalOnPricing__c;
            opp.Sales_Paperwork_Count__c = quote.Num_Of_Validated_SA_Paperworks__c;
            opp.Quote_Payment_Method__c =  quote.POC_Payment_Method__c;
            //VAT Change Project
            //30-10-2010
            //Start:-----------
            opp.Price_Mismatch__c = quote.newPriceMatchDifference__c;
            opp.InDifference_Value__c = quote.ISpec_Difference__c;
            opp.VAT1_Amount__c = quote.VAT_17_5_Total_Amount__c;
            opp.VAT2_Amount__c = quote.VAT_5_Total_Amount__c;
            opp.closeDate__c = quote.closeDate__c;
            opp.New_Net_Contract_Price__c = quote.newGrossPricingTotal__c;
            opp.New_Net_Contract_Value__c = quote.newTotalNetPrice_quote__c;
            system.debug('-----fIELDS WHICH WERE PROBLEM AS THEY WERE FORMULA----' +quote.Quote_Net_Value__c +''+quote.ASP_Discounts__c+''+quote.Frozen_BM_Gross__c);
            system.debug('-----DIRECT CURRENCY FIELDS POPULATED ----' +quote.totalNetPrice_quote__c +''+quote.ASP_Discounts__c+''+quote.finalPriceVisibleToCustomer__c);
                    
      //End:---------------
       
        }
         opp.isSystem__c = true;
     /* commented : phase 5
      if(quote.Opportunity__c==opp.Id && quote.stage__c == 'Awaiting Billing'){
                    opp.Billed_Status__c = true;
                }
       */ 
      if(trigger.isInsert){
       
         if(opp.quoteIncrementer__c == null){       
                  opp.quoteIncrementer__c = '1';        
            }else{
                  inc = Integer.valueOf(opp.quoteIncrementer__c);
                  inc++;            
                  opp.quoteIncrementer__c = String.valueOf(inc);
              }
          opp.isSystem__c = true;  
      }
      
      
      if(quote.stage__c == 'Quote Finalised - Accepted' && quote.Is_Primary__c && quote.closeDate__c!= null)
      {
        opp.Sold_Quote_Received_Date__c = quote.closeDate__c;
        /* Affordable Warmth Change to Set the Manually Billed Flag to Yes.
             change: 15 Jan 2013: Cognizant
             
             Change: 23 April 2013: Cognizant
             Green Deal Finace Changes : to Set the Manually Billed Flag to Yes 
             
             Change:18 Nov 2013 : Cognizant
             Requestor: Charlotte Gallaghar
             Green Deal will no more Manually Billed.
             Green Deal Finance will be set to Bill to Office.
             
          */
          
          if(quote.Job_Type__c == '13' || quote.Job_Type__c == '14')// || (quote.POC_Payment_Method__c == 'Finance' && quote.POC_Payment_Option__c == 'Green Deal Finance' ))
          {
            opp.Manual_Bill__c='Yes';
            opp.BMQuoteJobType__c = quote.Job_Type__c == '13'?'A W Combi' : 'A W Conv';
          } 
          if(quote.POC_Payment_Method__c == 'Finance' && quote.POC_Payment_Option__c == 'Green Deal Finance' )
          {
            opp.Bill_to_Office__c = true;
          }
          //added by BGSAMS Support PRB00016918 - starts
          
            
            if(quote.POC_Payment_Method__c == 'Finance' && quote.POC_Payment_Option__c != 'Green Deal Finance' )
          {
            opp.Bill_to_Office__c = false;
          }
          
          
          //added by BGSAMS Support PRB00016918 - ends        
         
       }             
                  
        
      
      system.debug('-----obj_opportunity after ----' +opp);
        
      update opp;
   
    }
    
 }