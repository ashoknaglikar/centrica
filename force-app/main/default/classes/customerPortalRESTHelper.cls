@RestResource(urlMapping='/getCustomerPortalData/*')
global with sharing class customerPortalRESTHelper {
    
    @HttpPost    
    global static dynamicCustomerPortalJSONClass post(string Sf_id, String Sf_user_agent, string Sf_resolution, string  Sf_ip)
    {
        try
        {
        dynamicCustomerPortalJSONClass returnResponse = new dynamicCustomerPortalJSONClass();

        list<Finance_Application__c> faApplication = new list<Finance_Application__c>();
        
        list<Opportunity> vaildOpportunity = new list<Opportunity>();
        
        list<Appointment__c> appointmentList = new list<Appointment__c>();
        Appointment__c bestAppointment = new Appointment__c();
        customerPortalEventClass appointmentEvent;// 
        customerPortalEventClass bmQuoteEvent;// 
        customerPortalEventClass jobEvent;// 
        
        list<Bigmachines_Quote__c> quoteList = new list<Bigmachines_Quote__c>();
        Bigmachines_Quote__c bestQuote = new Bigmachines_Quote__c();
        list<job_element__c> jobelementList = new List<job_element__c>();
        List<attachment> attachmentlist = new list<attachment>();
        
        list<Job__c> jobList = new list <Job__c>();
        Job__c bestJob = new Job__c();
        
        
        list<customerPortalEventClass> eventList = new list<customerPortalEventClass>();
        
        returnResponse.StageId= '0.0';
        returnResponse.StageDecription= 'No stage assigend yet.';
        
        customerPortalRESTHelper cobj = new customerPortalRESTHelper();
        
        CustomerPortalHelper helperObj = new CustomerPortalHelper();

        
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String oppId = CustomerPortalHelper.getOpportunityId(Sf_id);
        list<id> parentIds = new list<id> {oppId};
        
        boolean callBackScenario = false;
       
        dynamicCustomerPortalJSONClass.cls_outstandingFinance outBalance = new dynamicCustomerPortalJSONClass.cls_outstandingFinance();
        string notEligiblePI = system.label.PINotEligibleForPortal;
        dateTime leadCreatedDate ;
        list<Opportunity> result = [SELECT Id, Name, StageName, CHI_Lead_Id__c,Customer_Name__c, Install_Address_Street__c, Install_Address_County__c, Install_Address_City__c, Install_Postcode__c, Product_Interest__c, CreatedDate, Customer_Email__c , Account.Primary_Contact__r.FirstName,  
                                    Account.Primary_Contact__r.LastName, Account.Primary_Contact__r.Salutation,Portal_Deposit__c, Payment_Reference_Number__c,Derived_Payment_Reference_Number__c,
                                    Balance_Outstanding__c,Original_Quote_Value__c,AllowFinalPayment__c,AllowPortalPayment__c,discountsTotalOnPricing__c,Net_Contract_Price__c,Sum_of_Payments__c,ASP_Outcome__c  ,Sum_of_Deposits__c,
                                    Landlord__c, Latest_customer_category__c
                                    FROM Opportunity WHERE id = :oppId   ];
        
        if(result.size()>0)
        {
            
            for(Opportunity o : result)
            {
                if(notEligiblePI.contains(','+o.Product_Interest__c+','))
                return null;
                returnResponse.journey = 0;
               
                if(o.CreatedDate>= date.valueof(IV_Vectors__c.getInstance('Portal Second Phase').Key__c))
                returnResponse.journey = 1;
                
                if(o.StageName!= 'Closed Lost' && o.StageName!= 'Expired')
                {
                    returnResponse.CHILeadId                =  o.Id;
                    returnResponse.CHILeadNumber            =  o.CHI_Lead_Id__c;
                    returnResponse.CustomerName             =  o.Customer_Name__c;
                    returnResponse.Address                  =  (o.Install_Address_Street__c!=null? o.Install_Address_Street__c:'') +(o.Install_Address_City__c!=null ? ', '+o.Install_Address_City__c:'')+(o.Install_Address_County__c!=null? ', '+o.Install_Address_County__c: '')+(o.Install_Postcode__c!=null ? ', '+o.Install_Postcode__c: '');
                    returnResponse.productInterest          =  (o.Product_Interest__c=='Staright Swap' ||o.Product_Interest__c=='Telesales Conv'? 'Staright Swap': o.Product_Interest__c);
                    returnResponse.StageId= '10.0';
                    returnResponse.email                    =  o.Customer_Email__c;
                    returnResponse.title                    =  o.Account.Primary_Contact__r.Salutation;
                    returnResponse.firstName                =  o.Account.Primary_Contact__r.FirstName;
                    returnResponse.lastName                 =  o.Account.Primary_Contact__r.LastName;
                    returnResponse.street                   =  o.Install_Address_Street__c;
                    returnResponse.city                     =  o.Install_Address_City__c;
                    returnResponse.postcode                 =  o.Install_Postcode__c;
                    returnResponse.county                   =  o.Install_Address_County__c;
                    returnResponse.StageDecription          = 'CHI Lead with '+o.StageName+' Status';
                    leadCreatedDate                         =  o.CreatedDate;
                    vaildOpportunity.add(o);
                    
                    outBalance.allowFinalPaymentCollection = false;
                    //returnResponse.paymentReferenceNumber = outBalance.paymentReferenceNumber      = o.Payment_Reference_Number__c;
                    outBalance.paymentReferenceNumber      = o.Payment_Reference_Number__c;
                    outBalance.originalQuoteValue          = o.Original_Quote_Value__c;
                    outBalance.totalAllowance              = o.discountsTotalOnPricing__c;
                    outBalance.netContractPrice            = o.Net_Contract_Price__c;
                    outBalance.totalPayments               = o.Sum_of_Deposits__c;
                    outBalance.finalBalanceOutstanding     = o.Balance_Outstanding__c;
                    outBalance.changesToQuote              = o.ASP_Outcome__c;
                    outBalance.totalPriceYouWillPay        = o.Net_Contract_Price__c+o.ASP_Outcome__c;
                    
                    break;
                }
            }
            
            
            returnResponse.keyInformationList = new list<dynamicCustomerPortalJSONClass.keyValue>();
            
            
            
           if(vaildOpportunity[0].Payment_Reference_Number__c==null&&(system.label.Deposit_Reference_Number=='on'||vaildOpportunity[0].Derived_Payment_Reference_Number__c))
            {
                Deposit_Number__c depNum= utilities.assignReferenceNumberToLead(vaildOpportunity[0].id);
                vaildOpportunity[0].Payment_Reference_Number__c= depNum!=null?depNum.name:null;
            }
            if(vaildOpportunity[0].Payment_Reference_Number__c!=null)
            returnResponse.paymentReferenceNumber=vaildOpportunity[0].Payment_Reference_Number__c;
            
            
            if(vaildOpportunity.size()>0)
            {
               outBalance.balancePaid = 0;
               try{   
               AggregateResult[] groupedResults   = [Select SUM(Amount__c)Amount   From BGS_Payment__c where Opportunity__c = :vaildOpportunity[0].id and Payment_Type__c = 'Balance Payment' ];
               system.debug(groupedResults);
               outBalance.balancePaid =  groupedResults[0].get('Amount')!=null ? (decimal)groupedResults[0].get('Amount'):0 ;
               }catch (exception e)
               {
                   outBalance.balancePaid =0;
               }

                //returnResponse.customerDocs.addAll();

                appointmentList = [Select id, Assigned_To__c, Status__c, Visit_Date__c,SFDC_Customer_Commited_Window__c, Start_Time__c, End_Time__c, EmployeeName__c, Assigned_To__r.Phone_No__c from Appointment__c where Opportunity__c in :vaildOpportunity and Status__c!= 'Cancelled' order by Start__c ASC];
                
                quoteList = [Select id, Stage__c, Is_Primary__c, quote_Finish_Time__c, CreatedDate, App_Assigned_To__c,Portal_Status__c,bmStatusReason__c,Portal_Call_Back_Time__c,Portal_Substatus__c,   Portal_Call_Back_Date__c , FinalNetQuoteTotal__c from Bigmachines_Quote__c where Opportunity__c in :vaildOpportunity and stage__c !=null   order by Is_Primary__c , CreatedDate asc];
                
                jobList = [Select id,Quote__c, Install_Postcode__c, Status__c, Installation_Date__c,  Count_Own_labour_orders__c, Delivery_Date__c, Delivery_Slot__c, Start_Data_Time__c, Maximum_End_Date__c,Mechanical_Installer__c,Quote__r.Max_Lead_Time__c,simple_complex_job__c,District__r.C_P_Planning_lead_time__c,Portal_Installation_Time__c,Portal_Call_Back_Date__c,Portal_Call_Back_Time__c from Job__c where CHI_Lead__c in :vaildOpportunity and Is_Remedial_Job__c = false and Is_Downtime_Job__c = false ];
                
                faApplication = cobj.returnValidFinanceApplication(vaildOpportunity[0].Id);
                
                jobelementList=[SELECT ID,Description__c FROM JOB_ELEMENT__C WHERE Product_ID__c LIKE 'cblr%' AND job__r.chi_lead__c=:vaildOpportunity];
                
                attachmentlist = [select id from attachment where parentid =:vaildOpportunity and name like '%Installation notes%'];
                
               
                system.debug('appointmentList---->'+appointmentList);
                system.debug('quoteList---->'+quoteList);
                system.debug('jobList---->'+jobList);
                system.debug('faApplication---->'+faApplication);
              
              
              returnResponse.leadOffers.addAll(customerPortalQuoteHelper.buildLeadOfferJSON(vaildOpportunity[0].id));
              returnResponse.showVoucherCode = returnResponse.leadOffers.size()>0;
              
              //Suguna
              
              
              IF(!attachmentlist.isempty())
              returnResponse.installnotesId= attachmentlist[0].id;
              set<String> quoteIds= new set<string>();
              map<string,string> BMQuotePDFMap = new map<string,string>();
              if(!quoteList.isempty())
              {
                  for(Bigmachines_Quote__c b:quoteList)
                  {
                      quoteIds.add(b.id);
                      parentIds.add(b.id);
                  }
                  
                  for(Attachment att: [select id,parentId from Attachment where parentId IN:quoteIds])
                  {
                      BMQuotePDFMap.put(att.parentId,att.id);
                  }
                  
              }
              
              if(jobelementList.size()>0)
                  outBalance.boilerName = jobelementList[0].Description__c;
                  
              /*    
              if(!faApplication.isempty())
              {
                  outBalance.allowFinalPaymentCollection=false;
              }*/
              
              returnResponse.outstandingFinance = outBalance;
              
              //ends
              
              if(JobList.size()>0)
              {
                  List<Job__c> tempJobList = new List<job__c>();
                  for(Job__c j: jobList)
                  {
                     if(j.Status__c == 'Pending' && j.Quote__c == null && j.Installation_date__c == null && System.label.Portal_DummyJob_Delete=='Yes')
                        {
                            // delete the dummy Job
                            delete j;
                            // go to bigmachines Quote
                            jobEvent = null;
                        }
                        else
                        {
                            tempJobList.add(j);
                        }
                        
                        if(label.allowedJobsForFinalPaymentOnPOrtal.contains(','+j.status__c+',') )
                        {
                            outBalance.allowFinalPaymentCollection = true;
                            
                            if(j.Installation_Date__c <=system.today() && j.Count_Own_labour_orders__c> decimal.valueof(label.ownlabourCount) )
                            outBalance.allowFinalPaymentCollection = false;
                        }

                        if(vaildOpportunity[0].AllowPortalPayment__c == 'No') {
                            outBalance.allowFinalPaymentCollection = false; 
                        }
                        
                        
                  }
                  JobList.clear();
                  JobList.addAll(tempJobList);
              }
             /* ********************************************************************************************************************
                Appointment Event Starts */
                if(jobEvent == null && appointmentList.size()>0)
                {
                    appointmentEvent= new customerPortalEventClass();
                    for(Appointment__c a : appointmentList)
                    {
                        system.debug('ap---->'+a);
                        bestAppointment = new Appointment__c();
                        bestAppointment = a;
                        if(a.Status__c == 'Appointed' && a.Visit_Date__c>= system.today())
                        {
                            // Future Appointed leads.
                            returnResponse.StageId= '20.0';
                            returnResponse.StageDecription= 'Appointment Planned';
                            break;
                            
                        }else 
                        {
                            returnResponse.StageId= '20.1';
                            returnResponse.StageDecription= 'Appointment / Quote complete';
                            system.debug('stage 20.1---->'+returnResponse.StageDecription);
                        }
                        
                        
                    }
                    
                    if(bestAppointment!=null)
                    {
                        
                        
                        if(bestAppointment.Visit_Date__c>= system.today())
                        {
                            // future Appointment Scenario
                            appointmentEvent = cobj.createEvent(true, bestAppointment.Visit_Date__c, bestAppointment.Visit_Date__c, bestAppointment.Start_Time__c, bestAppointment.End_Time__c, 
                                                           'Sales Appointment' , '20.0' , 'Appointment Planned', bestAppointment.EmployeeName__c, bestAppointment.Assigned_To__r.Phone_No__c);
                        }else
                        {
                            // past or happened appointment scenario.
                            appointmentEvent = cobj.createEvent(true, bestAppointment.Visit_Date__c, bestAppointment.Visit_Date__c, bestAppointment.Start_Time__c, bestAppointment.End_Time__c, 
                                                           'Sales Appointment' , '20.1' , 'Appointment / Quote complete', bestAppointment.EmployeeName__c, bestAppointment.Assigned_To__r.Phone_No__c);
                        }
                        
                       
                        List<Attachment> hsaPic = [Select id from Attachment where ParentId = : bestAppointment.Assigned_To__c and Name LIKE '%HSA_PIC%'];
                        
                        if(hsaPic.size()>0)
                        appointmentEvent.employeePictureId = hsaPic[0].Id;
                    }else
                    {
                        // no Appoinment Scenario
                        appointmentEvent = cobj.createEvent(false, null, null, null, null, 'No Sales Appointment' , '10.1' , 'CHI Lead with No future or past Appointment.', null, null);
                    }
                    
                    //returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('paymentRefNumber', string.valueof(vaildOpportunity[0].Payment_Reference_Number__c)));
                     
                }
                /* Appointment Event ends*/
            /* ************************************************************************************************************************
                
                Bigmachine event Starts:
                
            */
                if((jobEvent == null && quoteList.size()>0) )
                {
                    system.debug('into BMQuote---->');
                    bmQuoteEvent = new customerPortalEventClass();
                    for(Bigmachines_Quote__c b: quoteList)
                    {
                        system.debug('BM---->'+b);
                        bestQuote = new Bigmachines_Quote__c();
                        bestQuote = b;
                        
                        returnResponse.StageId= '30.2';
                        returnResponse.aprChange = false;
                        returnResponse.StageDecription= 'Appointment / Quote complete';
                        DateTime quoteDate = b.quote_Finish_Time__c!=null? b.quote_Finish_Time__c: b.CreatedDate;
                        returnResponse.financeProductList = new list<CustomerPortalHelper.financeProduct>();
                        for(Finance_Product__c fp: CustomerPortalHelper.getEligibleFinanceProducts (date.valueof(quoteDate),date.valueof(leadCreatedDate)))
                        {
                            returnResponse.financeProductList.add(new CustomerPortalHelper.financeProduct(fp));
                        }
                        
                        if( !b.Is_Primary__c && b.Portal_Substatus__c == 'Deposit Collected' && b.Portal_Status__c =='Accepted')
                        {
                            returnResponse.StageId= '30.4';
                            returnResponse.StageDecription= 'Portal Deosit Collected';
                            bmQuoteEvent = cobj.createEvent(true, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Time__c, b.Portal_Call_Back_Time__c, 
                                                           'Portal Deosit Collected' , '30.4' , 'CHI Lead with Portal Deposit Collected', null, null);
                            bmQuoteEvent.recordId = b.Id;
                            
                            callBackScenario = true;
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('quoteId', string.valueof(b.Id)));
                            break;
                            
                        } 
                        else if( !b.Is_Primary__c && b.Portal_Substatus__c == 'Payment On Completion' && b.Portal_Status__c =='Accepted')
                        {
                           /* if(label.planningPortalLive != 'on')
                            {
                                returnResponse.StageId= '30.3';
                                returnResponse.StageDecription= 'Portal Accepted Cash';
                                bmQuoteEvent = cobj.createEvent(true, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Time__c, b.Portal_Call_Back_Time__c, 
                                                               'Quote Accepted ' , '30.3' , 'CHI Lead with Portal Accepted Cash', null, null);
                                bmQuoteEvent.recordId = b.Id;
                                callBackScenario = true;
                                break;
                            
                            }else*/
                            {
                                returnResponse.StageId= '30.4';
                                returnResponse.StageDecription= 'Portal Deosit Collected';
                                bmQuoteEvent = cobj.createEvent(true, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Time__c, b.Portal_Call_Back_Time__c, 
                                                               'Portal Deosit Collected' , '30.4' , 'CHI Lead with Portal Deposit Collected', null, null);
                                bmQuoteEvent.recordId = b.Id;
                                
                                callBackScenario = true;
                                returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('quoteId', string.valueof(b.Id)));
                                break;
                            }
                            
                        }/* else if( label.planningPortalLive != 'on' && !b.Is_Primary__c && (b.Portal_Status__c =='Interested' ||  b.Portal_Status__c =='Accepted') && b.Portal_Substatus__c == 'Finance' )
                        {
                            
                            returnResponse.StageId= '30.3';
                            returnResponse.StageDecription= 'Portal Accepted Finance';
                            bmQuoteEvent = cobj.createEvent(true,  b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Date__c, b.Portal_Call_Back_Time__c, b.Portal_Call_Back_Time__c, 
                                                           'Quote Accepted ' , '30.3' , 'CHI Lead with Portal Accepted Finance quote', null, null);
                            bmQuoteEvent.recordId = b.Id;
                            callBackScenario = true;
                            break;
                            
                        } */else if(!b.Is_Primary__c &&( faApplication == null || faApplication.size() == 0 ))
                        {
                            returnResponse.StageId= '30.1';
                            returnResponse.StageDecription= 'UnSold Quote';
                            bestQuote = b;
                            
                            /*
                            
                            CS_Promotion_Dates__c dp = CS_Promotion_Dates__c.getInstance('IFC');
                            Date dp_date_start = dp.Start_Date__c;
                            Date dp_date_end = dp.End_Date__c;
                            Date dp_date_final = dp.Final_Date__c;
                            returnResponse.aprChange = false;
                            if(quoteDate >= dp_date_start && 
                               quoteDate <= dp_date_final &&
                               leadCreatedDate <= dp_date_end)
                            {
                              returnResponse.aprChange = true;   
                            }
                            
                            dp = CS_Promotion_Dates__c.getInstance('IFC 3 Months Deferred');
                            dp_date_start = dp.Start_Date__c;
                            dp_date_end = dp.End_Date__c;
                            dp_date_final = dp.Final_Date__c;
                            returnResponse.showDeferredFinanceOption = false;
                            if(quoteDate >= dp_date_start && 
                               quoteDate <= dp_date_final &&
                               leadCreatedDate <= dp_date_end)
                            {
                              returnResponse.showDeferredFinanceOption = true;   
                            }
                            */
                            
                            bmQuoteEvent = cobj.createEvent(true, bestQuote.CreatedDate.Date(), bestQuote.CreatedDate.Date(), null, null, 
                                                           'Unsold Quote' , '30.1' , 'UnSold Quote', bestQuote.App_Assigned_To__c, null);
                                                           
                           system.debug('I am in Unsold Quote without Finance');                                
                        }else if(!b.Is_Primary__c && faApplication != null && faApplication.size()>0)
                        {
                            system.debug('I am in Unsold Quote with Finance');
                            
                            returnResponse.StageId= '30.5';
                            string status = '';
                            string allAcceptedValues = IV_Vectors__c.getInstance('Finance_Accepted_Statuses').Key__c;
                            string allRefferredValues = IV_Vectors__c.getInstance('Finance_Reffered_Statuses').Key__c;
                            string allDeclinedValues   = IV_Vectors__c.getInstance('Finance_Declined_Statuses').Key__c;
                            string allParkedValues = IV_Vectors__c.getInstance('Finance_Parked_Statuses').Key__c;
                            if(allAcceptedValues.contains(faApplication[0].Application_Status__c))
                            status = 'Accepted'; 
                            else if(allDeclinedValues.contains(faApplication[0].Application_Status__c))
                            status = 'Declined';
                            else if(allRefferredValues.contains(faApplication[0].Application_Status__c))
                            status = 'Referred';
                            else if(allParkedValues.contains(faApplication[0].Application_Status__c))
                            status = 'Parked';
                            
                            
                            returnResponse.StageDecription= 'Unsold quote with Finance Application with :'+ status+' Status';
                            bestQuote = b;
                            bmQuoteEvent = cobj.createEvent(true, bestQuote.CreatedDate.Date(), bestQuote.CreatedDate.Date(), null, null, 
                                                           status , '30.5' , 'UnSold Quote with Finance Application', bestQuote.App_Assigned_To__c, null);
                            returnResponse.recordId = faApplication[0].Id;
                            
                            if(faApplication[0].Portal_Quote__c == null && faApplication[0].Quote_number__c != null)
                            {
                                BigMachines_Quote__c bm = [Select id from BigMachines_Quote__c where name = :faApplication[0].Quote_number__c];
                                faApplication[0].Portal_Quote__c = bm.Id;
                                update faApplication[0];
                            }
                            
                            //returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('depositAmount', string.valueof(faApplication[0].Deposit__c)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('quoteId', string.valueof(faApplication[0].Portal_Quote__c)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('financeAmount', string.valueof(faApplication[0].Cash_Price__c)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('financeDuration', string.valueof(faApplication[0].Payment_Options__c)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('financeId', string.valueof(faApplication[0].Id)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('financeProdId', string.valueof(faApplication[0].Finance_Product__r.Code__c)));
                            returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('financeOption', faApplication[0].Finance_Options__c));
                            
                            
                            
                        }
                        
                        
                    }
                    if(faApplication.size() > 0 )
                    {
                        returnResponse.financeRecords = new list<dynamicCustomerPortalJSONClass.financeClass>();
                        returnResponse.financeRecords.add(new dynamicCustomerPortalJSONClass.financeClass(faApplication[0], vaildOpportunity[0]));
                    }
                    
                    returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('depositAmount', string.valueof(vaildOpportunity[0].Portal_Deposit__c)));
                    returnResponse.keyInformationList.add(new dynamicCustomerPortalJSONClass.keyValue('paymentRefNumber', string.valueof(vaildOpportunity[0].Payment_Reference_Number__c)));
                           
                }
                
                /* Bigmachine event Ends
                ********************************************************************************************************************************************
                
                Job event Starts:
                
                */
                
                if(jobList.size()>0)
                {
                    for(Job__c j: jobList)
                    {
                        jobEvent = new customerPortalEventClass();
                        returnResponse.StageDecription= 'CHI Lead with '+j.Status__c+' job';
                        date childEventEndDate;
                        String childEventEndTime;
                        String childEventStartTime;
                         
                        if(j.Maximum_End_Date__c!=null)
                        {
                            childEventEndDate = j.Maximum_End_Date__c.date();
                            childEventEndTime =  string.valueof(j.Maximum_End_Date__c.time());}
                        else{
                            childEventEndDate = j.Installation_Date__c;
                            childEventEndTime  = null;
                            
                        }
                        
                        if(j.Start_Data_Time__c!=null)
                            childEventStartTime = string.valueof(j.Start_Data_Time__c.time());
                        else
                            childEventStartTime =String.valueOf(j.Portal_Installation_Time__c);
                        
                        returnResponse.maximumDay = Integer.valueOf(System.Label.maximumDayCustomerPortal);
                        returnResponse.quoteId = j.Quote__c;
                        returnResponse.bigMachineQuotePDFId=BMQuotePDFMap.containsKey(j.Quote__c)?BMQuotePDFMap.get(j.Quote__c):null;
                        if(j.Simple_Complex_Job__c=='Complex')
                        {
                        returnResponse.complexJob= true;
                        }else
                        {
                         returnResponse.complexJob= false;
                        }
                        
                        Integer minDay = Integer.valueOf(System.Label.minimumDayCustomerPortal);
                        Integer minDayCheck1 = 0;
                        Integer minDayCheck2 = 0;
                        if(Integer.valueOf(j.Quote__r.Max_Lead_Time__c) != null){
                             minDayCheck1 = Integer.valueOf(j.Quote__r.Max_Lead_Time__c);           
                        }
        
                        if(Integer.valueOf(j.District__r.C_P_Planning_lead_time__c) != null){
                             minDayCheck2 = Integer.valueOf(j.District__r.C_P_Planning_lead_time__c);            
                        }  
        
                        //Comparing the values of C_P_Planning_lead_time__c , Max_Lead_Time__c and the value 
                        //from the custome label to get the Minday value 
                        if(minDay < minDayCheck1 )
                        {
                            minday = minDayCheck1;
                        }
                        if(minday<minDayCheck2)
                        {
                            minday = minDayCheck2;
                        } 
                       
                        system.debug('childEventEndDate---->'+minday +' '+vaildOpportunity[0].Latest_customer_category__c ); 
                        String postCodeSector = j.Install_Postcode__c.substring(0, j.Install_Postcode__c.length()-2);
                        list<Postcode_Sector__c> postcode = [select id, Operational_Date__c, Non_Operational_Date__c  from Postcode_Sector__c where Type__c = 'Installation' and Name = :postCodeSector];
                        if(postcode.size()>0)
                        {
                            if(vaildOpportunity[0].Latest_customer_category__c<=3 && postcode[0].Non_Operational_Date__c!=null && postcode[0].Non_Operational_Date__c>system.today() && minday < system.today().daysBetween(postcode[0].Non_Operational_Date__c))
                            {
                                minday = system.today().daysBetween(postcode[0].Non_Operational_Date__c);
                            }
                            else if(vaildOpportunity[0].Latest_customer_category__c>3 && postcode[0].Operational_Date__c!=null && postcode[0].Operational_Date__c>system.today() && minday < system.today().daysBetween(postcode[0].Operational_Date__c) )
                            {
                                minday = system.today().daysBetween(postcode[0].Operational_Date__c);
                            }
                        }
                        
                         returnResponse.minimumDay = minday; 
                         system.debug('childEventEndDate---->'+childEventEndDate+ '' +minday +' '+vaildOpportunity[0].Latest_customer_category__c ); 
                         system.debug('childEventEndTime---->'+childEventEndTime); 
                         system.debug('childEventStartTime---->'+childEventStartTime); 
                        if(label.planningPortalLive == 'on' && j.Status__c == 'Pending' && j.Portal_Call_Back_Date__c!= null && j.Portal_Call_Back_Time__c!=null)
                        {
                             //CompleJob, max and Min day calculation
                            //if()
                            {
                                returnResponse.StageId= '40.3';
                                jobEvent = cobj.createEvent(true, j.Portal_Call_Back_Date__c, j.Portal_Call_Back_Date__c, j.Portal_Call_Back_Time__c, j.Portal_Call_Back_Time__c, 
                                                               'Quote Accepted' , '40.3' , 'CHI Lead with call back date and time', null, null);
                            }
                        }
                        else
                        if(j.Status__c == 'Pending' )
                        {
                            returnResponse.StageId= '40.1';
                            jobEvent = cobj.createEvent(true, null, null, null, null, 
                                                           'Quote Accepted' , '40.1' , 'CHI Lead with pending job', null, null);
                            jobEvent.recordId =j.id;
                        }
                        
                        else if(j.Status__c == 'Planned' || j.Status__c == 'Allocated')
                        {
                            returnResponse.StageId= '40.2';
                             
                                /*jobEvent = cobj.createEvent(true, j.Installation_Date__c, j.Maximum_End_Date__c.Date(), string.valueof(j.Start_Data_Time__c.time()), string.valueof(j.Maximum_End_Date__c.time()), 
                                                        'Delivery and Installation Planned' , '40.2' , 'CHI Lead with Planned job', j.Mechanical_Installer__c, null);
                                customerPortalEventClass.cutomerPortalEventChildClass deliveryChildEvent = cobj.createChildEvent(true, j.Delivery_Date__c, null, j.Delivery_Slot__c,j.Delivery_Slot__c,  
                                                        'Delivery Details' , '40.2.1' , 'Delivery Details of the Job', 'PTS', null); 
                                                       
                                customerPortalEventClass.cutomerPortalEventChildClass installEvent = cobj.createChildEvent(true, j.Installation_Date__c, j.Maximum_End_Date__c.Date(), string.valueof(j.Start_Data_Time__c.time()), string.valueof(j.Maximum_End_Date__c.time()), 
                                                        'Installation Details' , '40.2.2' , 'Installation Details of the Job', j.Mechanical_Installer__c, null);  
                                jobEvent.childEvents = new list<customerPortalEventClass.cutomerPortalEventChildClass> {deliveryChildEvent, installEvent};   */
                          
                           jobEvent = cobj.createEvent(true, j.Installation_Date__c, childEventEndDate, childEventStartTime, childEventEndTime, 
                                                        'Delivery and Installation Planned' , '40.2' , 'CHI Lead with Planned job', j.Mechanical_Installer__c, null);
                           customerPortalEventClass.cutomerPortalEventChildClass deliveryChildEvent = cobj.createChildEvent(true, j.Delivery_Date__c, null, j.Delivery_Slot__c,j.Delivery_Slot__c,  
                                                        'Delivery Details' , '40.2.1' , 'Delivery Details of the Job', 'PTS', null); 
                                                       
                           customerPortalEventClass.cutomerPortalEventChildClass installEvent = cobj.createChildEvent(true, j.Installation_Date__c, childEventEndDate, childEventStartTime, childEventEndTime, 
                                                        'Installation Details' , '40.2.2' , 'Installation Details of the Job', j.Mechanical_Installer__c, null);  
                           jobEvent.childEvents = new list<customerPortalEventClass.cutomerPortalEventChildClass> {deliveryChildEvent, installEvent}; 
                        }
                        else if(j.Status__c == 'Installed')
                        {
                            returnResponse.StageId= '50.0';
                            jobEvent = cobj.createEvent(true, j.Installation_Date__c,childEventEndDate, childEventStartTime, childEventEndTime,
                                                        'Installation complete' , '50.0' , 'CHI Lead with Planned job', j.Mechanical_Installer__c, null);
                            
                            customerPortalEventClass.cutomerPortalEventChildClass deliveryChildEvent = cobj.createChildEvent(true, j.Delivery_Date__c, null,  j.Delivery_Slot__c,  j.Delivery_Slot__c,  
                                                        'Delivery Details' , '50.0.1' , 'Delivery Details of the Job', 'PTS', null); 
                                                        
                            customerPortalEventClass.cutomerPortalEventChildClass installEvent = cobj.createChildEvent(true, j.Installation_Date__c, childEventEndDate, childEventStartTime, childEventEndTime,
                                                        'Installation Details' , '50.0.2' , 'Installation Details of the Job', j.Mechanical_Installer__c, null);        
                            jobEvent.childEvents = new list<customerPortalEventClass.cutomerPortalEventChildClass> {deliveryChildEvent, installEvent};    
                            
                        }else if(j.Status__c == 'Suspended')
                        {
                            returnResponse.StageId= '40.5';
                            
                            jobEvent = cobj.createEvent(true, null, null, null, null, 'Suspended Job', '40.5' , ' Job is Suspended', null, null);
                        }else if(j.Status__c == 'Pending' && callBackScenario ==true)
                        {
                            returnResponse.StageId= '30.3';
                            jobEvent = cobj.createEvent(true, bestQuote.Portal_Call_Back_Date__c, bestQuote.Portal_Call_Back_Date__c, bestQuote.Portal_Call_Back_Time__c, bestQuote.Portal_Call_Back_Time__c, 
                                                           'Portal Quote Accepted' , '30.3' , 'CHI Lead with Portal Accepted Quote', null, null);
                        }
                        
                    }
                }
                
                eventList = new list<customerPortalEventClass>();
                if(jobEvent!=null && (returnResponse.StageId.Contains('40') || returnResponse.StageId.Contains('40')))
                {
                    eventList.add(jobEvent);
                }else if(bmQuoteEvent!=null && (returnResponse.StageId.Contains('30') || returnResponse.StageId.Contains('30')))
                {
                     eventList.add(bmQuoteEvent);
                }else if(appointmentEvent!=null && (returnResponse.StageId.Contains('20') || returnResponse.StageId.Contains('20')))
                {
                     eventList.add(appointmentEvent);
                }
                //eventList = new list<customerPortalEventClass>{appointmentEvent, bmQuoteEvent, jobEvent};
                returnResponse.evenList = eventList;
                //returnResponse.customerDocs = getCustomerDocs(parentIds);
                
            }else
            {
                returnResponse.errorCode = 2;
                returnResponse.errorDiscription = 'CHI Lead is not Active.';
            }
            
            Call_History__c portalHistory = new Call_History__c(CHI_Lead__c = oppId, Type__c = 'Portal', Browser__c = Sf_user_agent, Ip_Address__c =Sf_ip, Device__c =  Sf_resolution, Portal_Stage__c =returnResponse.StageId );
            
            insert portalHistory;
            
        }else
        {
            returnResponse.errorCode = 1;
            returnResponse.errorDiscription = 'CHI Lead Id is blank or CHI Lead exists.';
        }
        system.debug('Final Response -->'+jSON.serialize(returnResponse));
        return returnResponse;
        }
        catch (exception e)
        {
            System.debug('Exception in get api '+e.getMessage()+' At line number :'+e.getLineNumber());
        }
       
        return null;
        
    }
    
    
    public list<Finance_Application__c> returnValidFinanceApplication (Id chileadId)
    {
        barclaysIntegrationHelper  barcalysHelper = new barclaysIntegrationHelper();
        list<Finance_Application__c> faList = barcalysHelper.getFinanceApplicationByLead(chileadId);
        string allAcceptedValues = IV_Vectors__c.getInstance('Finance_Accepted_Statuses').Key__c;
        string allRefferredValues = IV_Vectors__c.getInstance('Finance_Reffered_Statuses').Key__c;
        string allOtherValues = IV_Vectors__c.getInstance('Finance_Other_Statuses').Key__c;
        string allParkedValues = IV_Vectors__c.getInstance('Finance_Parked_Status').Key__c;
        string allDeclinedCalues = IV_Vectors__c.getInstance('Finance_Declined_Statuses').Key__c;
        list<Finance_Application__c> localApp; 
        list<Finance_Application__c> decApp = new list<Finance_Application__c>(); 
        integer offset = integer.valueof(IV_Vectors__c.getInstance('Quote_Expiry_Days').Key__c);
        for(Finance_Application__c f: faList)
        {
            if(f.CreatedDate >= system.today().addDays(-(offset)))
            {
                localApp = new list<Finance_Application__c>();
                
                
                if(f.Application_Status__c!=null && !allOtherValues.contains(','+f.Application_Status__c+','))
                {
                    localApp.add(f);
                    
                    if(allParkedValues.contains(','+f.Application_Status__c +','))
                        return localApp;
                    else if(allAcceptedValues.contains(','+f.Application_Status__c+','))
                    {
                        return localApp;
                    }else if(allRefferredValues.contains(','+f.Application_Status__c+','))
                    {
                        // run the update status 
                        localApp.clear();
                        f = CustomerPortalHelper.applicationStatusUpdate(f);
                        localApp.add(f);
                        return localApp;
                    }else if(allDeclinedCalues.contains(','+f.Application_Status__c+','))
                    {
                        
                        decApp.add(f);
                        //return localApp;
                    }else
                    {
                        return localApp;
                    }
                    
                }
            }
            
            
           
            
        }
        return decApp;
        
    }
    
    public customerPortalEventClass createEvent(Boolean show, date   eventDate, date   eventEndDate, string eventStartTime, string eventEndTime,
                                               string eventName, string eventId, string eventDescription, string employeeName, 
                                               string employeeContactNumber)
    {
        customerPortalEventClass returnEvent = new customerPortalEventClass();
        returnEvent.show = show;
        returnEvent.eventDate = eventDate;
        returnEvent.eventEndDate = eventEndDate;
        returnEvent.eventStartTime = eventStartTime;
        returnEvent.eventEndTime = eventEndTime;
        returnEvent.eventName = eventName;
        returnEvent.eventId = eventId;
        returnEvent.eventDescription = eventDescription;
        returnEvent.employeeName = employeeName;
        returnEvent.employeeContactNumber = employeeContactNumber;
        
        return returnEvent;
        
    }
    
    public customerPortalEventClass.cutomerPortalEventChildClass createChildEvent(boolean show, date   childEventDate, date childEventEndDate,  string   childEventStartTime, string childEventEndTime,
                                                                                 string childEventName, string childEventId, string childEventDescription, string childEmployeeName, 
                                                                                 string childEmployeeContactNumber)
    {
        customerPortalEventClass.cutomerPortalEventChildClass returnEvent = new customerPortalEventClass.cutomerPortalEventChildClass();
        returnEvent.show = show;
        returnEvent.childEventDate = childEventDate;
        returnEvent.childEventEndDate = childEventEndDate;
        returnEvent.childEventEndTime = childEventEndTime;
        returnEvent.childEventStartTime = childEventStartTime;
        returnEvent.childEventName = childEventName;
        returnEvent.childEventId = childEventId;
        returnEvent.childEventDescription = childEventDescription;
        returnEvent.childEmployeeName = childEmployeeName;
        returnEvent.childEmployeeContactNumber = childEmployeeContactNumber;
        return returnEvent;
        
    }

    public static list<dynamicCustomerPortalJSONClass.ContentVersionJSON> getCustomerDocs(list<id> parentIds)
    {
        system.debug('I am inside Customer docs');
        list<string> docIdList = new list<string>();
        for(Portal_Document__c p : [select id,Document__c from Portal_Document__c where  CHI_Lead__c in : parentIds])
        {
            docIdList.add(p.Document__c);
        }
        
        list<dynamicCustomerPortalJSONClass.ContentVersionJSON> docs= new list<dynamicCustomerPortalJSONClass.ContentVersionJSON>();
        for(ContentVersion con  : [select   Title, ContentSize, FileExtension, FileType, Id, ContentDocumentId  from ContentVersion  where (Id  in :docIdList or ContentDocumentId in :docIdList) /*and IsLatest = true*/ limit 50])
        {
            docs.add(new dynamicCustomerPortalJSONClass.ContentVersionJSON('ContentVersion/'+string.valueof(con.Id), 'content' ,con.Title,con.ContentSize,con.FileExtension,con.FileType,con.Id, con.ContentDocumentId));
        }
        
        
        try{
                list<Attachment> attachments = [select id,BodyLength,name  from Attachment where ParentId in :parentIds and (Name like '%Installation Notes%' OR Name like '%Energy Saving Illustrator%')order by createdDate];
                boolean installNotes = false;
                for(Attachment a : attachments)
                {
                    if(!installNotes || a.name.contains('Energy Saving Illustrator'))
                    docs.add(new dynamicCustomerPortalJSONClass.ContentVersionJSON('Attachment/'+string.valueof(a.Id)+'/body', 'attachment',a.name, a.BodyLength,'pdf','PDF',a.Id, a.id));
                    
                    if(a.name.contains('Installation Notes'))
                    installNotes= true;
                    
                }
                
        }catch(Exception e)
        {
            
        }
        system.debug('contentlist -->'+docs);
        return docs;
        
    }

    
}