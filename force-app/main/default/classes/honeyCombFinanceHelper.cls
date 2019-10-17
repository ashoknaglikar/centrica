public class honeyCombFinanceHelper {    
    
    public static Finance_Application__c submitApplication(Finance_Application__c fp, Finance_Product__c product)
    {
        /*
        if(fp.Lead_Ext_Ref_No__c== null)
        {
            string ExternalReferenceNumber = fp.CHI_Lead__r.CHI_Lead_Id__c+'-'+'1';
            if(fp.CHI_Lead__r.ExternalRef__c!=null)
            {
              string[] Ext = fp.CHI_Lead__r.ExternalRef__c.split('-');
              ExternalReferenceNumber = Ext[0]+'-'+string.valueof(Integer.valueof(Ext[1])+1);
             
            }
            fp.Lead_Ext_Ref_No__c  = ExternalReferenceNumber;
        } 
        */
        
        //map<string, string> statusMap = new map<string, string>{'ACCEPT' => 'Accepted', 'REFER' => 'Referred', 'DECLINEALL' => 'Declined','Declined' => 'Declined','Accepted' => 'Accepted','Referred' => 'Referred'};
        map<string, map<string, string>> ffFieldMapping = new map<string, map<string, string>>();
        
        for(Finance_Data_Mappings__c f: Finance_Data_Mappings__c.getAll().values())
        {   
            if(f.Honeycomb_2019__c!= null)
            {
                if(ffFieldMapping.containskey(f.Field__c))
                {
                    ffFieldMapping.get(f.Field__c).put(f.PicklistOption__c,f.Honeycomb_2019__c);
                }else
                {
                    map<string, string> mapList = new map<string, string>{f.PicklistOption__c => f.Honeycomb_2019__c};
                    
                    ffFieldMapping.put(f.Field__c, mapList );
                }
            }
        }
        system.debug('Mappings'+ffFieldMapping);
        
        string po = fp.Payment_Options__c;
        string[] Popt = po.split('-'); 
        
        
        honeyCombFinanceJSONSubmit.cls_references referenceObj = new honeyCombFinanceJSONSubmit.cls_references();
        referenceObj.externalUniqueReference = fp.Lead_Ext_Ref_No__c;
        
        honeyCombFinanceJSONSubmit.cls_finance financeObj = new honeyCombFinanceJSONSubmit.cls_finance();
        financeObj.financeProductCode = fp.Finance_Product__r.Product_Code__c; 
        if(product!=null)
        {
             financeObj.financeProductCode = product.Product_Code__c;
        }
        financeObj.advance = fp.Cash_Price__c;
        financeObj.termMonths = Integer.valueOf(Popt[0].trim());
        financeObj.APR = fp.Interest_Rate__c;  
        financeObj.deposit = fp.Deposit__c;
        financeObj.depositTakenExternally = true; 
        
        
        honeyCombFinanceJSONSubmit.cls_retail retailObj = new honeyCombFinanceJSONSubmit.cls_retail();
        retailObj.retailerName = label.honeyCombRetailer; 
        retailObj.productLegalDescription = 'Boiler'; //check
        retailObj.retailSource = 'Online'; //check
        retailObj.goods = new List<honeyCombFinanceJSONSubmit.cls_goods>();
        
        
        honeyCombFinanceJSONSubmit.cls_goods goodsObj = new honeyCombFinanceJSONSubmit.cls_goods();
        goodsObj.description = 'Boiler'; //check
        goodsObj.typeCode = fp.Finance_Product__r.Asset_Type_Description__c; //check //
        if(product!=null)
        {
             goodsObj.typeCode = product.Asset_Type_Description__c;
        }
        goodsObj.totalPrice = fp.Cash_Price__c; //check
        goodsObj.quantity = 1; //check
        retailObj.goods.add(goodsObj);
        
         
        honeyCombFinanceJSONSubmit.cls_primaryApplicant papplicantObj = new honeyCombFinanceJSONSubmit.cls_primaryApplicant();
        papplicantObj.title = fp.Title__c;
        papplicantObj.firstName = fp.First_Name__c;
        papplicantObj.middleNames = fp.Middle_Name__c;
        papplicantObj.lastName = fp.Last_Name__c;
        papplicantObj.dateOfBirth = fp.Date_Of_Birth__c;
        papplicantObj.maritalStatus = ffFieldMapping.get('MaritalStatus').get(fp.Marital_Status__c);
        papplicantObj.nationality = fp.Nationality__c;
        papplicantObj.residentialStatus =ffFieldMapping.get('ResidentialStatus').get(fp.Occupancy_Status1__c);
        papplicantObj.dependents = integer.valueof(fp.Number_Of_Dependents__c);
        
        
        honeyCombFinanceJSONSubmit.cls_contactDetails contactDetailsObj = new honeyCombFinanceJSONSubmit.cls_contactDetails();
        contactDetailsObj.emailAddress = fp.Email__c;
        contactDetailsObj.homePhone = fp.Home_Phone__c;
        contactDetailsObj.workPhone = fp.Work_Phone__c;
        contactDetailsObj.mobilePhone = fp.Mobile__c;
        papplicantObj.contactDetails = contactDetailsObj;
        
        honeyCombFinanceJSONSubmit.cls_income incomeObj = new honeyCombFinanceJSONSubmit.cls_income();
        incomeObj.grossAnnualIncome =  integer.valueof(fp.Gross_Income__c);
        //incomeObj.netAnnualIncome = integer.valueof(fp.Applicant_Net_Monthly_income__c);
        papplicantObj.income = incomeObj;
        
        honeyCombFinanceJSONSubmit.cls_bankAccount bankaccountObj = new honeyCombFinanceJSONSubmit.cls_bankAccount();
        bankaccountObj.accountNumber = fp.Bank_Account_Number__c;
        bankaccountObj.accountHolderName = fp.Bank_Account_Name__c;
        bankaccountObj.sortCode = fp.Sort_Code__c;
        papplicantObj.bankAccount = bankaccountObj;
        
        honeyCombFinanceJSONSubmit.cls_monthlyOutgoings monthlyoutgoingObj = new honeyCombFinanceJSONSubmit.cls_monthlyOutgoings();
        monthlyoutgoingObj.Mortgage = fp.Mortgage__c; 
        monthlyoutgoingObj.Rent = fp.Rent__c;
        /*
        monthlyoutgoingObj.otherOutgoings = new List<honeyCombFinanceJSONSubmit.cls_otherOutgoings>();
        honeyCombFinanceJSONSubmit.cls_otherOutgoings otheroutgoingObj = new honeyCombFinanceJSONSubmit.cls_otherOutgoings();
        otheroutgoingObj.outgoingName = 'test'; //check
        otheroutgoingObj.outgoingValue = 1234.56; //check
        monthlyoutgoingObj.otherOutgoings.add(otheroutgoingObj);*/
        papplicantObj.monthlyOutgoings = monthlyoutgoingObj;
        
        honeyCombFinanceJSONSubmit.cls_addresses addressesObj = new honeyCombFinanceJSONSubmit.cls_addresses();
        if(fp.Post_Code1__c!=null)
        {
        addressesObj.currentAddress  = createHCCustomerAddress(fp.Building_Number1__c, fp.Building_Name1__c, fp.Street1__c,fp.City1__c, fp.State1__c, fp.Post_Code1__c, fp.Add1_Date__c);
        }
        addressesObj.previousAddresses = new list<honeyCombFinanceJSONSubmit.cls_address>();
        if(fp.Post_Code2__c!=null)
        {
            
        
            addressesObj.previousAddresses .add(createHCCustomerAddress(fp.Building_Number2__c, fp.Building_Name2__c, fp.Street2__c,fp.City2__c, fp.State2__c, fp.Post_Code2__c, fp.Add2_Date__c));
        }
        if(fp.Post_Code3__c!=null)
        {
            addressesObj.previousAddresses .add(createHCCustomerAddress(fp.Building_Number3__c, fp.Building_Name3__c, fp.Street3__c,fp.City3__c, fp.State3__c, fp.Post_Code3__c, fp.Add3_Date__c));
        }
        papplicantObj.addresses = addressesObj;
        
        honeyCombFinanceJSONSubmit.cls_employment employmentObj = new honeyCombFinanceJSONSubmit.cls_employment();
        if(fp.Employment_Status__c != 'Retired' && fp.Employment_Status__c != 'Benefits')
	    {
            honeyCombFinanceJSONSubmit.cls_employeeDetails employeeDetailsObj = new honeyCombFinanceJSONSubmit.cls_employeeDetails();
            employeeDetailsObj.employerName =fp.Employer_Name__c; 
        /* if(fp.Post_Code_E__c!=null)
         {
            employeeDetailsObj.employerAddress =  createHCCustomerAddress(null,fp.Building_Name_E__c, fp.Street_E__c,fp.City_E__c, fp.State_E__c, fp.Post_Code_E__c, fp.Employee_From__c);            
         }*/
         
         
            honeyCombFinanceJSONSubmit.cls_employers employersObj = new honeyCombFinanceJSONSubmit.cls_employers();
            employersObj.currentEmployer = employeeDetailsObj;
         //employersObj.previousEmployers = new List<honeyCombFinanceJSONSubmit.cls_employeeDetails>();
            employmentObj.employers = employersObj;
	    } 
        
        
        employmentObj.employmentStatus =ffFieldMapping.get('EmploymentStatus').get(fp.Employment_Status__c);
        //employmentObj.occupation = fp.Job_Description__c;  
       
        papplicantObj.employment = employmentObj;
        
        honeyCombFinanceJSONSubmit.cls_applicants applicantObj = new honeyCombFinanceJSONSubmit.cls_applicants();
        applicantObj.primaryApplicant = papplicantObj;
        
        honeyCombFinanceJSONSubmit newQuote = new honeyCombFinanceJSONSubmit();
        newQuote.references = referenceObj;
        newQuote.finance = financeObj;
        newQuote.applicants = applicantObj;
        newQuote.retail = retailObj;
       
       String jsonQuote = JSON.serialize(newQuote);       
       string QuoteUrl = system.label.HoneyComb_Endpoint+system.label.HoneyComb_Submit_Application;
        
       HttpResponse response = postRequest(QuoteUrl, jsonQuote);
       
       if(response.getStatusCode() == 201)
        {
            honeyCombFinanceJSONSubmitResponse jsonObj = honeyCombFinanceJSONSubmitResponse.parse(response.getBody());
            fp.Application_Id__c = jsonObj.applicationId;
            fp.Application_status__c = barclaysPhase3Helper.statusMap.containskey(jsonObj.status.toUpperCase())? barclaysPhase3Helper.statusMap.get(jsonObj.status.toUpperCase()):jsonObj.status;
            //fp.Lead_Ext_Ref_No__c = jsonObj.externalApplicationReference;
            fp.Status__c = 'Success';
            fp.Error_Details__c = null;
            
            if(jsonObj.finance!=null && jsonObj.finance.totalAmountRepayable!=null)
            fp.Total_Amount_Repayable__c = jsonObj.finance.totalAmountRepayable;
            
            if(jsonObj.applicationId!=null)
            fp.Application_Id__c = jsonObj.applicationId;
            
            // if Accpeted get the signingLink too
            if(fp.Application_Status__c.toUpperCase() == 'ACCEPTED')
            {
                fp = honeyCombFinanceHelper.getSigningLinkHoneyComb(fp);
            }
            
        }else
        {
            system.debug(response.getBody());
            honeyComberrorClass errlist = honeyComberrorClass.parse(response.getBody());
            system.debug(errlist);
            //fp.Error_Details__c = '';
            if(errlist!=null)
            {
                errorListClass error = new errorListClass();
                integer i = 1;
                error.Errors = new list<errorListClass.ErrorClass>();
                for(string s : errlist.errors)
                {
                    errorListClass.ErrorClass  objError = new errorListClass.ErrorClass( string.valueof(i),s);
                    error.Errors.add(objError);
                    i++;
                    
                }
                fp.Error_Details__c = JSON.serialize(error);
            }
            
            fp.Status__c = 'Error';
        }
        
        if(fp.Add_Logging__c)
        {
            fp.Request_JSON__c = 'Submit Barclays APP on:'+system.now()+' :'+jsonQuote+'\n';
            fp.Request_JSON__c = 'Submit Response: '+response.getBody()+'\n';
        }
        
        
       return fp;
       
      /*
       if(body.contains('Error'))
       {
           freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
           fp.Status__c = 'Error';
           //update fp;
           
       }else
       {
            system.debug('into response from HC');
            honeyCombFinanceJSONSubmitResponse obj = honeyCombFinanceJSONSubmitResponse.parse(body);
            
            if(obj.status!=null)
            {fp.Application_Status__c = obj.status;}
            if(obj.finance.totalAmountRepayable!=null)
            fp.Total_Amount_Repayable__c = obj.finance.totalAmountRepayable;
            if(obj.finance.monthlyRepayment!=null)
            fp.Monthly_Repayments__c = obj.finance.monthlyRepayment;
            
            if(obj.finance.termMonths!=null)
            {
                fp.payment_Options__c= obj.finance.termMonths +' - '+obj.finance.termMonths/12+' Years';
            }
            
            if(obj.applicationId!=null)
            fp.Application_Id__c = obj.applicationId;
            fp.Status__c='SUCCESS';
            /*
            try{
            if( obj.finance.financeProductCode!=''||obj.finance.financeProductCode!=null)
            fp.Finance_Product__c= [select id from Finance_Product__c where Product_Code__c = :obj.finance.financeProductCode].id;
            }catch (Exception e)
            {
                //update fp;
            }
            */
            //update fp;
            
            
            /*
            Opportunity opp = new Opportunity(id =fp.CHI_Lead__c, ExternalRef__c = obj.externalUniqueReference );
            update opp;
            */
            //return fp;
       //}
       
       
        
    }
    
   public static honeyCombFinanceJSONSubmit.cls_address  createHCCustomerAddress(string houseNo, string houseName, string street, string posttown , string county,  string postcode, date datefrom )
    {
        //date endD = dateend!=null? dateend:system.today();
        integer months = math.mod(math.ABS(system.today().daysbetween(datefrom)),365)/30;
        honeyCombFinanceJSONSubmit.cls_address addressObj = new honeyCombFinanceJSONSubmit.cls_address();
        //addressObj.flatNumber = flatNo!=null?flatNo:'';
        addressObj.buildingNumber =  houseNo != null ? houseNo:'';
        addressObj.buildingName = houseName!=null? houseName : '';
        addressObj.address1 = street;
        //addressObj.address2 = address2!=null? address2:'';
        //addressObj.address3 = address3!=null? address3:'';
        addressObj.town = posttown;
        addressObj.postcode = postcode;
        addressObj.countryCode = 'UK';
        addressObj.startDate = datefrom;
        //addressObj.endDate = dateend!=null?dateend.format():'';
        addressObj.monthsAtAddress = months;
        return addressObj;
    }
   
    
    //getApplicationStatus
    public static Finance_Application__c getApplicationStatusHC(Finance_Application__c fp)
    {
        string endPoint = system.label.HoneyComb_Endpoint+fp.Application_Id__c+system.label.HoneyComb_Get_Status;       
        HttpResponse response = getRequest(endPoint);
        
        if(response.getStatusCode() == 200)
        {
            honeyCombFinanceJSONSubmitResponse jsonObj = honeyCombFinanceJSONSubmitResponse.parse(response.getBody());
            
            fp.Application_status__c = barclaysPhase3Helper.statusMap.containskey(jsonObj.status.toUpperCase())? barclaysPhase3Helper.statusMap.get(jsonObj.status.toUpperCase()):jsonObj.status;
            //fp.Customer_Band__c = jsonObj.finance!=null?jsonObj.finance.tier:'';
            String[] cusBand;
            if(jsonObj.finance!=null)
            { 
               cusBand= jsonObj.finance.tier.split(' ');
            }
            if(jsonObj.finance!=null)
            {
                fp.Customer_Band__c= jsonObj.finance.tier!=null?cusBand[1]:'';
                if(fp.Customer_Band__c!= null && fp.Customer_Band__c != '' && fp.Customer_Band__c != '1' )
                {
                    string code = fp.Finance_Product__r.Code__c.substring(0,fp.Finance_Product__r.Code__c.length()-1) + fp.Customer_Band__c;
                    
                    Finance_Product__c fPrd= [Select id from Finance_Product__c where Code__c = :code];  
                    if(fPrd!=null)
                    fp.Finance_Product__c = fPrd.Id;
                }
            }
            fp.Status__c = 'Success';
            fp.Error_Details__c = null;
            
        }else
        {
            system.debug(response.getBody());
            honeyComberrorClass errlist = honeyComberrorClass.parse(response.getBody());
            if(errlist!=null && errlist.errors!=null)
            {
                errorListClass error = new errorListClass();
                integer i = 1;
                error.Errors = new list<errorListClass.ErrorClass>();
                for(string s : errlist.errors)
                {
                    errorListClass.ErrorClass  objError = new errorListClass.ErrorClass( string.valueof(i),s);
                    
                    if(s.ToUpperCase().contains('ACCOUNT NUMBER'))
                    objError.ErrorCode = '11027';
                    error.Errors.add(objError);
                    i++;
                }
                fp.Error_Details__c = JSON.serialize(error);
            }
            
            fp.Status__c = 'Error';
        }
        
        if(fp.Add_Logging__c)
        {
            fp.Request_JSON__c = 'Get Honeycomb APP on:'+system.now()+'\n';
            fp.Request_JSON__c = 'Get Response: '+response.getBody()+'\n';
        }
            
       /*
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
            
        }else
        {
            honeyCombFinanceJSONSubmitResponse responses = honeyCombFinanceJSONSubmitResponse.parse(body);
            fp.Application_Status__c =responses.status;
            
        }
        */
      
        
        
        
        return fp;
    }
    
    //getSigningLink
    public static Finance_Application__c getSigningLinkHoneyComb(Finance_Application__c fp)
    {
        honeyCombFinanceJSONSigning signingLink = new honeyCombFinanceJSONSigning();
        signingLink.returnURL = fp.Portal_Link__c;        
        
        string endPoint = system.label.HoneyComb_Endpoint+fp.Application_Id__c+system.label.HoneyComb_Signing_Link; 
        String jsonQuote = JSON.serialize(signingLink);
         
        HttpResponse response = postRequest(endPoint, jsonQuote);
        
        if(response.getStatusCode() == 200)
        {
            honeyCombFinanceJSONSigningResponse jsonObj = honeyCombFinanceJSONSigningResponse.parse(response.getBody());
            //fp.Document_Link__c =jsonObj.signingLink;
            fp.Finance_Link__c =jsonObj.signingLink;
            fp.Paper_Documents__c =label.Agents_URL_Honeycomb + jsonObj.signingLink.substring(jsonObj.signingLink.lastIndexOfIgnoreCase('/')+1, jsonObj.signingLink.length());
            fp.Barcalys_Link_Application_Expiry__c = jsonObj.expirationDate;
            fp.Status__c = 'Success';
            
            
        }else
        {
            honeyComberrorClass errlist = honeyComberrorClass.parse(response.getBody());
            if(errlist!=null && errlist.errors!=null)
            {
                errorListClass error = new errorListClass();
                error.Errors = new list<errorListClass.ErrorClass>();
                integer i = 1;
                for(string s : errlist.errors)
                {
                    errorListClass.ErrorClass  objError = new errorListClass.ErrorClass( string.valueof(i),s);
                    error.Errors.add(objError);
                    i++;
                }
                fp.Error_Details__c = JSON.serialize(error);
            }
            
            fp.Status__c = 'Error';
        }    
        
        if(fp.Add_Logging__c)
        {
            fp.Request_JSON__c += 'Get Sigininglink Honeycomb APP on:'+system.now()+' : \n';
            fp.Request_JSON__c += 'Submit Response: '+response.getBody()+'\n';
        }
            
       
        
        /*
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
        }else
        {
            honeyCombFinanceJSONSigningResponse responses = honeyCombFinanceJSONSigningResponse.parse(body);
            fp.Document_Link__c =responses.signingLink;
            fp.Barcalys_Link_Application_Expiry__c = responses.expirationDate;
        }
        */
        return fp;
    }
    
     //cancelApplication
    public static void cancelApplicationHoneyComb(Finance_Application__c fp)
    {
        honeyCombFinanceJSONCancelApplication cancelApp= new honeyCombFinanceJSONCancelApplication();
        cancelApp.cancellationReason= '';        
        
        string endPoint = system.label.HoneyComb_Endpoint+fp.Application_Id__c+system.label.HoneyComb_Cancel_Application; 
        String jsonQuote = JSON.serialize(cancelApp);
         
        HttpResponse response = postRequest(endPoint, jsonQuote);
        /*
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
        }else
        {
            honeyCombFinanceJSONCancelAppResponse responses = honeyCombFinanceJSONCancelAppResponse.parse(body); 
        }
        */
    }
    
    
    //Notify Fulfilment
    public static void notifyFulfilmentHoneyComb(Finance_Application__c fp)
    {
        string endPoint = system.label.HoneyComb_Endpoint+fp.Application_Id__c+system.label.HoneyComb_Notify_Fulfilment; 
         
        HttpResponse response = postRequest(endPoint,'');
        /*
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
        }else
        {
            honeyCombFinanceJSONFulfilmentResponse responses = honeyCombFinanceJSONFulfilmentResponse.parse(body);   
        }*/
    }
    
    
    public static httpResponse postRequest(string endPoint, string jsonRequest)
    {
        system.debug('Request-->'+jsonRequest);
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/json'); 
        req.setHeader(label.HoneycombHeader,label.HoneycombKey); 
        req.setMethod('POST');
        req.setBody(jsonRequest);
        req.setTimeout(120000);
        httpResponse response = m_http.send(req);       
        //String body = response.getBody();        
        system.debug('Response-->'+response.getBody());
        return response;
    }
    
    public static httpResponse getRequest(string endPoint)
    {        
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint); 
        req.setHeader(label.HoneycombHeader,label.HoneycombKey); 
        req.setMethod('GET');       
        req.setTimeout(120000);
        httpResponse response = m_http.send(req);       
        //String body = response.getBody();        
        system.debug('Response-->'+response.getBody());
        return response;
    }
    
    
    

}