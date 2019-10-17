public class createBundleLeadHelper {
    public list<Attachment> attachmentList  = new list<Attachment>();
    public createBundleLeadResponse.cls_errorList error = new createBundleLeadResponse.cls_errorList();
    
    public createBundleLeadResponse createBundleLeadFunc(createBundleLeadRequest request)
    {
        Savepoint sp = Database.setSavepoint();
        createBundleLeadResponse reply = new createBundleLeadResponse();
        string postcode;
        string NameNumber;
        string RHCEmail;
        String RHCMobile;
        LeadCreateHelper helper = new LeadCreateHelper();
        
        if(request.CustomerData.Address.PostCode!=null && request.CustomerData.Address.PostCode!= '')
        {
            postcode = request.CustomerData.Address.PostCode;
        }else
        {
            error.errorCode = '20';
            error.errorName = ' Create account failed. Postcode is Blank.';
            error.description = ' Create account failed. Postcode is Blank.';
            reply.errorList.add(error);
            return reply;
        }
        
        if(request.CustomerData.Address.NameNumber!=null && request.CustomerData.Address.NameNumber != '')
        {
            NameNumber = request.CustomerData.Address.NameNumber;
        }else
        {
            error.errorCode = '20';
            error.errorName = ' Create account failed. NameNumber in Address is null.';
            error.description = ' Create account failed. NameNumber in Address is null.';
            reply.errorList.add(error);
            return reply;
        }
        
        if(request.bundle.allowancesApplied.size()>=7)
        {
          error.errorCode = '20';
          error.errorName = 'ERROR: Only max of 7 Allowances are allowed ';
          error.description ='ERROR: Only max of 7 Allowances are allowed.';
          reply.errorList.add(error);
          return reply;
        }
        
        Web_Enquiry__c enquiry = new Web_Enquiry__c();
        Contact new_contact = new Contact();
        Account chi_account = new Account();
        Opportunity chi_lead = new Opportunity();
        
        boolean existAccount = false, existLead = false;
       
        string trimmed_code;
        string first_part;
        string second_part;
        string reformatted_code;
        string post_code_sector;
        
        trimmed_code    = request.CustomerData.Address.Postcode.replace(' ', '');
        second_part     = trimmed_code.substring(trimmed_code.length()-3, trimmed_code.length());
        first_part      = trimmed_code.substring(0, trimmed_code.length()-second_part.length());
        reformatted_code = first_part + ' ' + second_part;
        
        try {
            
            
            string billingStreet = request.CustomerData.Address.NameNumber + ' ' +request.CustomerData.Address.Street;
            
            string test_acc_name = reformatted_code.trim() + ' ' + (billingStreet.length()>29 ? billingStreet.substring(0,29): billingStreet);
            
            List<Account> existing_accs = [SELECT  Id,BillingStreet,BillingCity,BillingPostalCode,BillingState  FROM Account WHERE Account_Id__c = :test_acc_name ]; // use this field as it is indexed
            
            system.debug('Sugu '+test_acc_name);
            if(existing_accs.size()>0)
            {   
                
                system.debug('I am inside existing Lead');
                existAccount =true;
                chi_account = existing_accs[0];
                List<Opportunity> existing_leads = [SELECT Id, CloseDate, StageName, CHI_Lead_Id1__c,Product_Interest__c, AccountId ,LeadSource,Customer_Portal__c,Customer_Portal_Key__c,Customer_have_any_other_form_of_HEAT__c,Does_the_customer_have_hot_water__c,
                                                           Is_the_customers_boiler_working__c,Is_the_customer_vulnerable__c,Latest_customer_category__c,Vulnerable_reason__c,
                                                           (select id from Bigmachines_Quotes__r),(Select id, Status__c,Visit_Date__c from Appointments__r where Status__c = 'Appointed')
                                                   FROM Opportunity
                                                   WHERE AccountId = :existing_accs[0].id
                                                   AND CloseDate >= :Date.Today() order by StageName limit 1];
       
              
                
                if (existing_leads.size() > 0 ) { 
                    for(Opportunity o : existing_leads)
                    {
                        system.debug('Lead id '+o.id);
                        if( o.Bigmachines_Quotes__r.size()>0)
                        {
                             error.errorCode = '10';
                             error.errorName = 'ERROR: Account still has active lead, new lead not allowed';
                             error.description = 'ERROR: Account still has active lead, new lead not allowed';
                             reply.errorList.add(error);
                             return reply;
                        }
                        if(o.StageName =='Appointed' || o.StageName =='Active')
                        {
                            for(Appointment__c a: o.Appointments__r)
                            {
                                if(a.Visit_Date__c>=system.today())
                                {
                                    error.errorCode = '10';
                                    error.errorName = 'ERROR: Account still has active lead, new lead not allowed';
                                    error.description = 'ERROR: Account still has active lead, new lead not allowed';
                                    reply.errorList.add(error);
                                    return reply;
                                }
                            }
                            if((request.CustomerData.ProductInterest == null && o.Product_Interest__c != 'Online Boiler') || (request.CustomerData.ProductInterest != null && o.Product_Interest__c != request.CustomerData.ProductInterest))
                            {
                                o.Product_Interest__c = 'Online Boiler';
                                if(request.CustomerData.ProductInterest != null )
                                o.Product_Interest__c = request.CustomerData.ProductInterest;
                                helper = createUpdateLead(request.CustomerData, chi_account.Id,existAccount,true, o);
                            } 
                            chi_lead = o;
                            //reply.leadReference = o.CHI_Lead_Id1__c;
                            existLead = true;
                        }
                        
                    }
                    
                     if(chi_lead.CHI_Lead_Id1__c==null )
                     {
                         helper = createUpdateLead(request.CustomerData, chi_account.Id,existAccount,false,null);
                         if(helper.Code!='0')
                         {
                                    error.errorCode = helper.Code;
                                    error.errorName = helper.Message ;
                                    error.description = helper.Message;
                                    reply.errorList.add(error);
                                    Database.rollback( sp );
                                    return reply;
                         }else
                         {
                                    chi_lead = helper.Opp;
                                    //reply.leadReference = chi_lead.CHI_Lead_Id1__c;
                         }
                    }
                }
                else
                {
                    
                    helper = createUpdateLead(request.CustomerData, chi_account.Id,existAccount,false, null);
                    if(helper.Code!='0')
                    {
                              error.errorCode = helper.Code;
                              error.errorName = helper.Message ;
                              error.description = helper.Message;
                              reply.errorList.add(error);
                              Database.rollback( sp );
                              return reply;
                    }else
                    {
                             chi_lead = helper.Opp;
                             //reply.leadReference = chi_lead.CHI_Lead_Id1__c;
                    }
                }
            }
            else
            {
                chi_account.Primary_Contact__c          = new_contact.Id;
                chi_account.BillingPostalCode           = request.CustomerData.Address.PostCode;
                chi_account.BillingStreet               = request.CustomerData.Address.NameNumber+' '+request.CustomerData.Address.Street;
                chi_account.BillingCity                 = request.CustomerData.Address.TownCity;
                chi_account.BillingState                = request.CustomerData.Address.CountyProvince;
                chi_account.Name                        = 'unused name';
                chi_account.Asbestos_found__c           = request.CustomerData.asbestosIdentified;
                
                try{
                  string street = chi_account.BillingStreet!=null?chi_account.BillingStreet.normalizeSpace().replaceall(' ','+').trim():'';
                  string city = chi_account.BillingCity!=null ? chi_account.BillingCity.normalizeSpace().replaceall(' ','+').trim():'';
                  string pcode = chi_account.BillingPostalCode!=null?chi_account.BillingPostalCode.normalizeSpace().replaceall(' ','+').trim():'';
                  string Address = street + '+'+city+ '+' +pcode;
                  System.debug('address string send to utility-->'+Address);
                   try{
                       list<string> Latlang = Utilities.getLatLang(Address,pcode);
                       if(Latlang.size()==2)
                       {
                           chi_account.Latitude__Latitude__s = double.valueof(Latlang[0]);
                           chi_account.Latitude__Longitude__s = double.valueof(Latlang[1]);
                       }   
                      }catch (Exception e)
                         {
                         }
                  insert chi_account;
                }catch (exception e)
                  {
                      error.errorCode = '30';
                      error.errorName = 'ERROR: Create account failed with name.';
                      error.description ='ERROR: Create account failed with name.';
                      reply.errorList.add(error);
                      Database.rollback( sp );
                      return reply;
                  }
                  // CHI Lead creaion.
                  helper = createUpdateLead(request.CustomerData, chi_account.Id, false,false, null);
                
                  if(helper.Code!='0')
                  {
                         error.errorCode = helper.Code;
                         error.errorName = helper.Message ;
                         error.description = helper.Message;
                         reply.errorList.add(error);
                         Database.rollback( sp );
                         return reply;
                 }else
                 {
                       chi_lead = helper.Opp;
                       //reply.leadReference = chi_lead.CHI_Lead_Id1__c;
                 } 
            }
            
            string onlineBoilerjson = JSON.serialize(request);
            blob JSONBody = blob.valueof(onlineBoilerjson);
            Attachment att = new Attachment(Name = chi_lead.CHI_Lead_Id1__c+' JSON.text', Body = JSONBody, ParentId = chi_Lead.Id);
            attachmentList.add(att);
            
            if(attachmentList.size()>0)
            insert attachmentList;
            
            new_contact.Salutation          = request.CustomerData.customerDetails.Salutation;
            new_contact.FirstName           = request.CustomerData.customerDetails.FirstName;
            new_contact.LastName            = request.CustomerData.customerDetails.LastName;
            string mobile;
            string homephone;
            
            if(request.CustomerData.contactDetails.MobilePhone!=null && request.CustomerData.contactDetails.MobilePhone.startsWith('07'))
            mobile = request.CustomerData.contactDetails.MobilePhone;
            else
            homephone = request.CustomerData.contactDetails.MobilePhone;
            
            RHCMobile = new_contact.MobilePhone         = mobile;
            new_contact.HomePhone           = homephone;
            RHCEmail = new_contact.Email__c            = request.CustomerData.contactDetails.Email;
            new_contact.Contact_Type__c     = request.CustomerData.ResStatus;
            new_contact.MailingCity         = request.CustomerData.Address.TownCity;
            new_contact.MailingPostalCode   = reformatted_code;
            new_contact.MailingState        = request.CustomerData.Address.CountyProvince;
            
            new_contact.MailingStreet       = request.CustomerData.Address.NameNumber + ' ' + request.CustomerData.Address.Street;
            new_contact.IsActive__c         = True;
            
            new_contact.Primary_Contact__c  = True;
            
            new_contact.AccountId           = chi_account.Id;
            
            enquiry.Name                    = new_contact.LastName + ' ' + chi_account.BillingPostalCode + ' ' + datetime.now();
            //enquiry.Boiler_Age__c           = objManageCustomerBooking.CreateCustomerData.BoilerAge ;
            //enquiry.Boiler_Operational__c   = objManageCustomerBooking.CreateCustomerData.BoilerOp == 'Yes'?true:false;
            enquiry.County_Province__c      = new_contact.MailingState;
            enquiry.Fuel_Type__c            = request.CustomerData.FuelType;
            enquiry.Email__c                = new_contact.Email__c;
            enquiry.First_Name__c           = new_contact.FirstName;
            enquiry.Home_Phone__c           = new_contact.HomePhone;
            //enquiry.Work_Phone__c           = new_contact.OtherPhone;
            enquiry.Mobile_Phone__c         = new_contact.MobilePhone;
            //enquiry.Alt_Phone__c            = new_contact.Phone;
            enquiry.Last_Name__c            = new_contact.LastName;
            enquiry.Postcode__c             = chi_account.BillingPostalCode;
            enquiry.Residential_Status__c   = request.CustomerData.ResStatus;
            enquiry.Salutation__c           = new_contact.Salutation;
            enquiry.CHI_Lead__c             = chi_lead.id;
            string temp_str = '';
            temp_str = request.CustomerData.Address.NameNumber + ' ' + request.CustomerData.Address.Street;
            
            if (temp_str.length() > 45) {
                enquiry.Street__c = temp_str.substring(0, 45);
            }
            else {
                enquiry.Street__c = temp_str;  
            }
        
            temp_str = '';
            temp_str = request.CustomerData.Address.TownCity;
            
            if (temp_str.length() > 30) {
                enquiry.Town_City__c = temp_str.substring(0, 30);
            }
            else {
                enquiry.Town_City__c = temp_str;   
            }
            
            try{
                insert new_contact;
                insert enquiry;
                
                
                // CHG00009065: fix to create relationship record to relate Contat and CHI Lead
                // as is done in the call centre booking system
                // So, now add opportunity contact role....
                OpportunityContactRole opp_contact_role = new OpportunityContactRole();
                opp_contact_role.ContactId      = new_contact.Id;
                opp_contact_role.OpportunityId  = chi_lead.Id;
                opp_contact_role.Role           = 'Decision Maker';
                try {
                    insert opp_contact_role;
                }             
                catch (exception e) {
                      error.errorCode = '30';
                      error.errorName = 'WARNING: Opportunity contact role insert failed';
                      error.description ='WARNING: Opportunity contact role insert failed';
                      reply.errorList.add(error);
                      Database.rollback( sp );
                }  
                
                //update Account with CHI Lead
                chi_account.Primary_Contact__c = new_contact.Id;
                update chi_account;
            }catch (exception e)
            {
                error.errorCode = '30';
                error.errorName = 'ERROR: Create contact failed with name. '+e.getmessage();
                error.description ='ERROR: Create contact failed with name.';
                reply.errorList.add(error);
                Database.rollback( sp );
                if (null != chi_account.Id && !existAccount) // only need to delete account as this triggers a delete of everything else
                    delete chi_account;
                else if(!existLead)
                    delete chi_lead;
                return reply;
            }
            
            
            
            
            //create Bigmachine Quote and Quote Products
            if(chi_lead!=null && request.bundle!=null/* &&request.bundle.size()>0*/)
            {
                //for(createBundleLeadRequest.cls_bundle bundle: request.bundle)
                {   
                    createBundleLeadRequest.cls_bundle bundle = request.bundle;
                    if(bundle.id!=null&& bundle.id!='')
                    {
                        string bundleId = bundle.id;
                        // check if hive is present
                        if(!request.CustomerData.hiveReq)
                        {
                            Bundle__c bundleChek = [Select id ,Hive__c, Non_Hive_Equ_Bundle__c from Bundle__c where Reference_Code__c=:bundle.id ] ;
                            if(bundleChek.Hive__c == 'Yes')
                            bundleId = bundleChek.Non_Hive_Equ_Bundle__c;
                        }
                        
                        
                        List<Bundle__c> chi_bundleList = [select id,name,Reference_Code__c,Gross_Price__c,Total_Allowances__c,(select id,Price__c,CS_Part__r.Product__c,CS_Part__r.Product__r.name,Quantity__c,CS_Part__r.type__c,CS_Part__r.BGC_Number__c,CS_Part__r.Upliftable__c,
                                                                CS_Part__r.EAN__c,CS_Part__r.Model__c,CS_Part__r.VAT_Percentage__c, CS_Part__r.Quote_Section__c,CS_Part__r.Manufacturer__c, CS_Part__r.Part_Code__c,
                                                                CS_Part__r.Quote_Description__c from Bundle_Parts__r),
                                                                (select id,name,Amount__c,code__c,CS_Allowance__r.Description__c from Bundle_Allowances__r) from Bundle__c where Reference_Code__c=:bundleId];
                        if(chi_bundleList.size()>0)
                        {
                             try{
                             BigMachines_Quote__c bigMachineQuote = new BigMachines_Quote__c();
                             bigMachineQuote.name = 'C'+chi_lead.CHI_Lead_Id__c+'0';
                             bigMachineQuote.Pricebook_Id__c ='CHB';
                             bigMachineQuote.Product_Type_ID__c ='CHB';
                             bigMachineQuote.createdDate_quote__c =system.today();
                             bigMachineQuote.App_Assigned_To__c ='Online Boilers - 002a';
                             bigMachineQuote.preparedBy_Quote__c ='Online Boilers - 002a';
                             bigMachineQuote.Opportunity__c = chi_lead.id;
                             bigMachineQuote.stage__c = 'Quote Finalised - Not Accepted';
                             bigMachineQuote.bmStatusReason__c = 'Online Boilers';
                             bigMachineQuote.submittedDate_quote__c =system.today();
                             bigMachineQuote.Quote_Finish_Time__c = system.now();
                             
                             //bigMachineQuote.finalPriceVisibleToCustomer__c= chi_bundleList[0].Gross_Price__c;
                             //bigMachineQuote.appliedAllowancesTotal__c= chi_bundleList[0].Total_Allowances__c;
                             bigMachineQuote.finalPriceVisibleToCustomer__c= decimal.valueOf(bundle.totalBundlePrice);
                             bigMachineQuote.appliedAllowancesTotal__c=decimal.valueOf(bundle.totalAllowance);
                             bigMachineQuote.finalNetQuoteTotal__c = bigMachineQuote.finalPriceVisibleToCustomer__c - bigMachineQuote.appliedAllowancesTotal__c;
                             bigMachineQuote.discountsTotalOnPricing__c= bigMachineQuote.appliedAllowancesTotal__c;
                             bigMachineQuote.totalNetPrice_quote__c= bigMachineQuote.finalNetQuoteTotal__c;
                             bigMachineQuote.depositOnPricing__c =0.0;
                             bigMachineQuote.balancePricing__c =  bigMachineQuote.finalNetQuoteTotal__c-bigMachineQuote.depositOnPricing__c;
                             
                             bigMachineQuote.sFDCApptStatus__c = 'Happened';
                             bigMachineQuote.sFDCApptStatusReason__c = 'Online Boilers';
                             bigMachineQuote.BigMachines_Transaction_Id__c ='C'+chi_lead.CHI_Lead_Id__c+'0';
                             
                             bigMachineQuote.RHCStatus__c ='FALSE';
                             //bigMachineQuote.Boiler_Plus_Reasons__c = 'Not Applicable' ;
                             bigMachineQuote.Job_Type__c ='15';
                             bigMachineQuote.Job_Type_Description__c ='Online Boilers';
                             bigMachineQuote.Core_Bundle__c ='Online Boilers';   
                             //bigMachineQuote.Customer_Homecare_Contact__c ='No';
                             bigMachineQuote.Active_QP_Lines__c = chi_bundleList[0].Bundle_Parts__r.size();
                             
                             bigMachineQuote.Customer_have_any_other_form_of_heat__c = chi_lead.Customer_have_any_other_form_of_HEAT__c;
                             bigMachineQuote.Does_the_customer_have_hot_water__c = chi_lead.Does_the_customer_have_hot_water__c;
                             bigMachineQuote.Is_the_customer_s_boiler_working__c = chi_lead.Is_the_customers_boiler_working__c;
                             bigMachineQuote.Is_the_customer_vulnerable__c = chi_lead.Is_the_customer_vulnerable__c;
                             bigMachineQuote.Latest_customer_category__c = chi_lead.Latest_customer_category__c;
                             bigMachineQuote.Vulnerable_reason__c = chi_lead.Vulnerable_reason__c;
                             bigMachineQuote.geographicUpliftFactor__c = 0;
                             bigMachineQuote.Frozen_BM_Gross__c = bigMachineQuote.finalNetQuoteTotal__c;
                             bigMachineQuote.systemType__c ='1';
                             
                             
                             /*
                             Ashok Set of fields
                             */
                            
                             bigMachineQuote.Energy_Account_Ref__c = request.CustomerData.homeCareAccountNumber;
                            
                             
                                  if(bundle.allowancesApplied.size()>0)
                                  {
                                      //List<Bundle_Allowance__c> bundle.allowancesApplied = chi_bundleList[0].Bundle_Allowances__r;
                                      //for()
                                      if(bundle.allowancesApplied.size()>=6)
                                      {
                                          bigMachineQuote.appliedAmount6__c =bundle.allowancesApplied[5].amount;
                                          bigMachineQuote.appliedAllowance6__c =bundle.allowancesApplied[5].code;
                                          bigMachineQuote.allowance_desc_6__c =bundle.allowancesApplied[5].name;
                                          bigMachineQuote.CS_Allowance_6__c      = bundle.allowancesApplied[5].sfId;
                                      }if(bundle.allowancesApplied.size()>=5)
                                      {
                                          bigMachineQuote.appliedAmount5__c =bundle.allowancesApplied[4].amount;
                                          bigMachineQuote.appliedAllowance5__c =bundle.allowancesApplied[4].code;
                                          bigMachineQuote.allowance_desc_5__c =bundle.allowancesApplied[4].name;
                                          bigMachineQuote.CS_Allowance_5__c      = bundle.allowancesApplied[4].sfId;
                                      }if(bundle.allowancesApplied.size()>=4)
                                      {
                                          bigMachineQuote.appliedAmount4__c =bundle.allowancesApplied[3].amount;
                                          bigMachineQuote.appliedAllowance4__c =bundle.allowancesApplied[3].code;
                                          bigMachineQuote.allowance_desc_4__c =bundle.allowancesApplied[3].name;
                                          bigMachineQuote.CS_Allowance_4__c      = bundle.allowancesApplied[3].sfId;
                                      }if(bundle.allowancesApplied.size()>=3)
                                      {
                                          bigMachineQuote.appliedAmount3__c =bundle.allowancesApplied[2].amount;
                                          bigMachineQuote.appliedAllowance3__c =bundle.allowancesApplied[2].code;
                                          bigMachineQuote.allowance_desc_3__c =bundle.allowancesApplied[2].name;
                                          bigMachineQuote.CS_Allowance_3__c      = bundle.allowancesApplied[2].sfId;
                                      }if(bundle.allowancesApplied.size()>=2)
                                      {
                                          bigMachineQuote.appliedAmount2__c =bundle.allowancesApplied[1].amount;
                                          bigMachineQuote.appliedAllowance2__c =bundle.allowancesApplied[1].code;
                                          bigMachineQuote.allowance_desc_2__c =bundle.allowancesApplied[1].name;
                                          bigMachineQuote.CS_Allowance_2__c      = bundle.allowancesApplied[1].sfId;
                                      }if(bundle.allowancesApplied.size()>=1)
                                      {
                                          bigMachineQuote.appliedAmount1__c =bundle.allowancesApplied[0].amount;
                                          bigMachineQuote.appliedAllowance1__c =bundle.allowancesApplied[0].code;
                                          bigMachineQuote.allowance_desc_1__c =bundle.allowancesApplied[0].name;
                                          bigMachineQuote.CS_Allowance_1__c      = bundle.allowancesApplied[0].sfId;
                                      }
                                      
                                  }
                                  
                                  List<Quote_Product__c> quoteProductList = new List<Quote_Product__c>();
                                  set<Id> productIds = new set<id>();
                                  boolean hivePresent = false;
                                  if(chi_bundleList[0].Bundle_Parts__r.size()>0)
                                  {
                                      for(Bundle_Part__c bundlepart :chi_bundleList[0].Bundle_Parts__r)
                                      {
                                           productIds.add(bundlepart.CS_Part__r.Product__c);  
                                           
                                           Quote_Product__c quoteProduct = new Quote_Product__c();
                                           quoteProduct.name =bundlepart.CS_Part__r.Product__r.name;
                                           if(!hivePresent && bundlepart.CS_Part__r.Product__r.name!=null && bundlepart.CS_Part__r.Product__r.name.contains('HIVE'))
                                           hivePresent = true;
                                           quoteProduct.Product__c=bundlepart.CS_Part__r.Product__c;
                                           quoteProduct.Quantity__c=bundlepart.Quantity__c;
                                           quoteProduct.quotingReason__c = 'First Quote';
                                           quoteProduct.BigMachines_Quote__r = new BigMachines_Quote__c(BigMachines_Transaction_Id__c =  bigMachineQuote.BigMachines_Transaction_Id__c); 
                                           quoteProduct.Component_Group_Type__c = bundlepart.CS_Part__r.type__c;
                                           quoteProduct.Component_Type__c = bundlepart.CS_Part__r.type__c;
                                           quoteProduct.BGC_Number__c = bundlepart.CS_Part__r.BGC_Number__c;
                                           quoteProduct.upliftable__c = bundlepart.CS_Part__r.Upliftable__c ? 'Y' : 'N';
                                           quoteProduct.EAN__c= bundlepart.CS_Part__r.EAN__c;
                                           quoteProduct.Model_Description__c= bundlepart.CS_Part__r.Model__c;
                                           decimal vat = Integer.valueOf(bundlepart.CS_Part__r.VAT_Percentage__c);
                                                if(vat != null){
                                                    if(vat == 20){
                                                        quoteProduct.FirstVATCode__c = 1;
                                                    } else if(vat == 5){
                                                        quoteProduct.FirstVATCode__c = 4;
                                                    }
                                                }
                                          system.debug('*******'+vat);
                                          quoteProduct.Level_1_Print_Description__c = bundlepart.CS_Part__r.Quote_Section__c;
                                          quoteProduct.Manufacturer__c = bundlepart.CS_Part__r.Manufacturer__c;
                                          quoteProduct.price_list_price_each__c = bundlepart.Price__c/(1+(vat/100));
                                          system.debug(quoteProduct.price_list_price_each__c + ''+bundlepart.Price__c +' ' +bundlepart.Price__c/(1+(vat/100))+ ' '+(1+(vat/100))+ ' '+vat);
                                          quoteProduct.geographicUplift__c = 0.0;
                                          decimal grossSingle = bundlepart.Price__c;
                                          quoteProduct.GrossSingle__c = grossSingle;
                                          quoteProduct.Sales_Price__c = quoteProduct.GrossSingle__c*quoteProduct.Quantity__c;
                                          quoteProduct.vATAAfterDiscount__c = quoteProduct.Sales_Price__c-(quoteProduct.price_list_price_each__c*quoteProduct.Quantity__c);
                                          quoteProduct.Part_Number__c =bundlepart.CS_Part__r.Part_Code__c;
                                          quoteProduct.Product_Code__c  = bundlepart.CS_Part__r.Part_Code__c; //
                                          quoteProduct.Quote_Description__c     = bundlepart.CS_Part__r.Quote_Description__c;
                                          quoteProductList.add(quoteProduct);  
                                      }
                                  }
                                  Map<String,Decimal> skillHourMap = new Map<String,Decimal>{  'Mechanical' => 0.0, 'Powerflush' => 0.0, 'Building Work' => 0.0, 'Electrical' => 0.0, 
                                                                                               'Scaffolder' => 0.0, 'Roof Work' => 0.0, 'Specialist Building' => 0.0, 'LPG Installation' => 0.0,
                                                                                               'Asbestos Removal'=>0.0,'Asbestos Removal Fixed Rate' => 0.0,'Solar' => 0.0, 'Connect Solar Panels' => 0.0, 'Contractor Installation' => 0.0,
                                                                                               'Unvented Hot Water' => 0.0, 'Payment Collection' => 0.0, 'Water Heater Fixing' => 0.0, 'Electrical Work ASP' => 0.0,
                                                                                               'FIRE/WALL HEATER FIXING' => 0.0, 'Ecogen Mechanical' => 0.0, 'Ecogen Electrical' => 0.0, 'Remote Heating' => 0.0,
                                                                                               'ECO' => 0.0, 'Landlord Check' => 0.0 };
                                                                            
                                  if(productIds.size()>0)
                                  {
                                      List<Product_Work_Code__c> productWorkCodeList = [select id,Skill_Type__c,Hours__c from Product_Work_Code__c where Product__c=:productIds and isActive__c=true ];
                                      
                                      if(productWorkCodeList.size()>0)
                                      {
                                          for(Product_Work_Code__c pwc:productWorkCodeList)
                                          {
                                              if(skillHourMap.containsKey(pwc.Skill_Type__c) && pwc.Hours__c!=null)
                                              {
                                                  Decimal hours = skillHourMap.get(pwc.Skill_Type__c)+pwc.Hours__c;
                                                  skillHourMap.put(pwc.Skill_Type__c,hours);
                                              }
                                          }
                                      }
                                  }
                                  
                                 bigMachineQuote.skillTotalMechanical__c = skillHourMap.get('Mechanical');
                                 bigMachineQuote.skillTotalPowerFlush__c = skillHourMap.get('Powerflush');
                                 bigMachineQuote.skillTotalBuildingWork__c = skillHourMap.get('Building Work');
                                 bigMachineQuote.skillTotalElectrical__c = skillHourMap.get('Electrical');
                                 bigMachineQuote.skillTotalScaffolder__c = skillHourMap.get('Scaffolder');
                                 bigMachineQuote.skillTotalRoofWork__c = skillHourMap.get('Roof Work');
                                 bigMachineQuote.skillTotalSpecialistBuilding__c = skillHourMap.get('Specialist Building');
                                 bigMachineQuote.skillTotalLPGInstallation__c = skillHourMap.get('LPG Installation');
                                 bigMachineQuote.skillTotalAsbestosRemoval__c = skillHourMap.get('Asbestos Removal');
                                 bigMachineQuote.skillTotalAsbestosRemovalFixedRate__c = skillHourMap.get('Asbestos Removal Fixed Rate');
                                 bigMachineQuote.skillTotalSolar__c = skillHourMap.get('Solar');
                                 bigMachineQuote.skillTotalConnectSolarPanels__c = skillHourMap.get('Connect Solar Panels');
                                 bigMachineQuote.skillTotalContractorInstallation__c = skillHourMap.get('Contractor Installation');
                                 bigMachineQuote.skillTotalUnventedHotWater__c = skillHourMap.get('Unvented Hot Water');
                                 bigMachineQuote.skillTotalPaymentCollection__c = skillHourMap.get('Payment Collection');
                                 bigMachineQuote.skillTotalWaterHeatingFixing__c = skillHourMap.get('Water Heater Fixing');
                                 bigMachineQuote.SkillTotalElectricalWorkASP__c = skillHourMap.get('Electrical Work ASP');
                                 bigMachineQuote.skillTotalFireWallHeaterFixing__c = skillHourMap.get('FIRE/WALL HEATER FIXING');
                                 bigMachineQuote.skillTotal_ecogenMechanical__c = skillHourMap.get('Ecogen Mechanical');
                                 bigMachineQuote.skillTotal_ecogenElectrical__c = skillHourMap.get('Ecogen Electrical');
                                 bigMachineQuote.Remote_Heating__c = skillHourMap.get('Remote Heating');
                                 bigMachineQuote.skillTotalECO__c = skillHourMap.get('ECO');
                                 bigMachineQuote.Landlord_Check__c = skillHourMap.get('Landlord Check');
                                 bigMachineQuote.Boiler_Plus_Reasons__c = 'Existing Product';
                                 if(hivePresent)
                                 {
                                     bigMachineQuote.RHCStatus__c ='TRUE';
                                     bigMachineQuote.RHCUsername__c = RHCEmail;
                                     bigMachineQuote.RHCMobile__c = RHCMobile;
                                     bigMachineQuote.Boiler_Plus_Reasons__c = 'Included';
                                 }
                                 bigMachineQuote.Boiler_Plus_Reasons__c = hivePresent ? 'Included' :'Existing product';
                                  
                             //try{
                                  insert bigMachineQuote;
                                  //bigMachineQuote = [select id,BigMachines_Transaction_Id__c from BigMachines_Quote__c where id = :bigMachineQuote.Id];
                                  if(quoteProductList.size()>0)
                                  {
                                      try{ 
                                            insert quoteProductList;
                                         } 
                                         catch(Exception e)
                                         {
                                            error.errorCode = '30';
                                            error.errorName = 'ERROR: create Quote Product failed';
                                            error.description ='ERROR: create Quote Product failed';
                                            reply.errorList.add(error);
                                            Database.rollback( sp );
                                                if(bigMachineQuote.id !=null)
                                                delete bigMachineQuote;
                                            return reply; 
                                         }
                                 }
                                 /*
                                 PageReference qPage = Page.BMQuotePDF;
                                 qPage.getParameters().put('Id', bigMachineQuote.id);
                                 Attachment attach = new Attachment();
                                 attach.name = bigMachineQuote.BigMachines_Transaction_Id__c+'_quote.pdf';
                                 attach.body =  qPage.getContent();
                                 attach.parentid = bigMachineQuote.id;
                                 insert attach;
                                 */
                                 customerPortalAcceptCloneQuote.createAttachment(null, bigMachineQuote.id, null, bigMachineQuote.BigMachines_Transaction_Id__c, null, null, null);
                                  
                            }catch(Exception e)
                            {
                                    error.errorCode = '30';
                                    error.errorName = 'ERROR: create BigMachine Quote failed'+e.getmessage()+' '+e.getlinenumber();
                                    error.description ='ERROR: create BigMachine Quote failed';
                                    reply.errorList.add(error);
                                    Database.rollback( sp );
                                    return reply; 
                            }
                               
                        }
                    }
                }
                
                reply.status ='Success';
                reply.redirectLink =chi_lead.Customer_Portal__c;
                reply.token = chi_lead.Customer_Portal_Key__c;
                reply.leadReference = chi_lead.CHI_Lead_Id1__c;
            }
        }
        catch(Exception e)
        {
            error.errorCode = '30';
            error.errorName = 'ERROR: Something went wrong. '+e.getmessage()+e.getlinenumber();
            error.description ='ERROR: Something went wrong. '+e.getmessage();
            reply.errorList.add(error);
            Database.rollback( sp );
            return reply; 
        }
        
        return reply;
    }
    
    
    
     private class LeadCreateHelper {
        String Code = '0';
        string Message = null;
        Opportunity  opp = new Opportunity();
    }
    
    private LeadCreateHelper createUpdateLead (createBundleLeadRequest.cls_CustomerData CustomerData, Id chi_accountId, boolean existAccount,boolean updateFlag,Opportunity opp)
    {
        Opportunity chi_lead = new Opportunity();
        LeadCreateHelper reply = new LeadCreateHelper();
        
        if(updateFlag)
            chi_lead = opp;
        else
        {
            string temp_str = CustomerData.Address.NameNumber;
            if (temp_str.length() > 10) {
                chi_lead.Address_Number__c = temp_str.substring(0, 10);
            }
            else {
                chi_lead.Address_Number__c = temp_str;  
            }
            
            //chi_lead.Alternative_Number__c  = CreateCustomerData.Contact_x.AltPhone;
            //chi_lead.Boiler_Age__c          = CreateCustomerData.BoilerAge;
            //chi_lead.Contact_Number__c = CreateCustomerData.Contact_x.AltPhone;
             
             if (null != CustomerData.contactDetails.MobilePhone) 
                chi_lead.Contact_Number__c =  CustomerData.contactDetails.MobilePhone;     
          
            
            chi_lead.Name                   = 'unused name';
            chi_lead.StageName              = 'Active';
            chi_lead.CloseDate              = Date.today().addmonths(3);
            chi_lead.AccountId              = chi_accountId;
            chi_lead.Urgency__c             = 'Standard';
            chi_lead.Home_improvement__c    = 'No';
            chi_lead.Visit_Type__c          = 'Sales';
            chi_lead.SC_Type__c             =  CustomerData.ResStatus;
            chi_lead.Enquiry_Type__c        = 'Sales Appointment';
            chi_lead.Product_Interest__c    = 'Online Boilers';
            chi_lead.LeadSource             =  CustomerData.chiLeadChannel;
            
        } 
        chi_lead.ES_Product_Interest__c = CustomerData.ProductInterest!=null ?true:false ;
        
        chi_lead.Bill_Title__c =        CustomerData.customerDetails.Salutation;
        chi_lead.Bill_FirstName__c =    CustomerData.customerDetails.FirstName;
        chi_lead.Bill_LastName__c =     CustomerData.customerDetails.LastName;
        chi_lead.Bill_Street__c =       CustomerData.Address.NameNumber+' '+CustomerData.Address.Street;
        chi_lead.Bill_Post_Code__c =    CustomerData.Address.PostCode;
        chi_lead.Bill_City__c =         CustomerData.Address.TownCity;
        chi_lead.Bill_State__c =        CustomerData.Address.CountyProvince;
        chi_lead.Customer_Marketing_Consent__c = CustomerData.isMarketingConsent;
        
        chi_lead.Home_care__c = CustomerData.isHomecare?'Yes':'No';
        chi_lead.Fuel_Type__c = CustomerData.fuelType;
        
        
        if(CustomerData.marketingPreference!=null)
        chi_lead.Marketing_Preferences__c =   CustomerData.marketingPreference;
        chi_lead.Bill_Country__c =      'United Kingdom';
        string campignName = 'ENG1';
        
        List<Campaign> campaign_sources = [SELECT Id 
                                           FROM Campaign 
                                           WHERE Name = :campignName];
        
        if (campaign_sources.size() == 1) {
            chi_lead.CampaignId             = campaign_sources[0].id;
        }
        else {
                 reply.Code = '9';
                 reply.Message = 'ERROR: Cannot assign Campaign to CHI Lead';
                
                if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                    delete new Account(Id =chi_accountId);
                return reply;  
            }
            
        try{
                    if(!updateFlag)
                    insert chi_lead;
                    
                    update chi_lead;
                    chi_lead = [SELECT AccountId, Id, Account.BillingPostalCode, CHI_Lead_Id1__c , LeadSource, CHI_Lead_Id__c, Visit_Type__c, Product_Interest__c, ES_Product_Interest__c,Customer_Portal__c,Customer_Portal_Key__c, Customer_have_any_other_form_of_HEAT__c,
                                       Does_the_customer_have_hot_water__c,Is_the_customers_boiler_working__c,Is_the_customer_vulnerable__c,Latest_customer_category__c,Vulnerable_reason__c
                                FROM Opportunity where id =:chi_lead.Id];
                    
                    reply.Opp =chi_lead;
                    
                    
        }catch(Exception e)
            {
                    reply.Code = '3';
                    reply.Message = 'ERROR: Create CHI Lead failed.';
                    if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                        delete new Account(Id =chi_accountId);
                   return reply;    
           } 
           
       system.debug('online Boiler '+chi_lead.id + ' '+reply);
       return reply;                
    }
}