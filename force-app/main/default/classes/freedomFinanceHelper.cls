public class freedomFinanceHelper {
    
    
    public static freedomFinanceHelper.returnClass  doSoftSearch(Finance_Application__c fp)
    {
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
        map<string, string> statusMap = new map<string, string>{'ACCEPT' => 'Accepted', 'REFER' => 'Referred', 'DECLINEALL' => 'Declined','Declined' => 'Declined','Accepted' => 'Accepted','Referred' => 'Referred'};
        map<string, map<string, string>> ffFieldMapping = new map<string, map<string, string>>();
        
        for(Finance_Data_Mappings__c f: Finance_Data_Mappings__c.getAll().values())
        {
            
            if(ffFieldMapping.containskey(f.Field__c))
            {
                ffFieldMapping.get(f.Field__c).put(f.PicklistOption__c,f.X2ndLenderCode__c);
            }else
            {
                map<string, string> mapList = new map<string, string>{f.PicklistOption__c => f.X2ndLenderCode__c};
                
                ffFieldMapping.put(f.Field__c, mapList );
            }
        }
        
        string po = fp.Payment_Options__c;
        string[] Popt = po.split('-'); 
        
        freedomFinanceJSONQuote newQuote = new freedomFinanceJSONQuote();
        newQuote.proposalNo = fp.Lead_Ext_Ref_No__c;
        newQuote.amount= fp.Cash_Price__c;
        newQuote.term = Popt[0];
        newQuote.purpose = 'BTL';
        newQuote.joint = false;
        newQuote.receiveMarketing = false;
        newQuote.sourceCode = 'BG';
        newQuote.instance= 'britishgas';   
        newQuote.loanType = 'U';
        newQuote.appStatus = 'New';
        newQuote.appSubStatus = 'None';
        newQuote.initialCode = '001';
        newQuote.InitialStatus = 'OPEN';
        newQuote.cashDeposit = fp.Deposit__c;
        
        
       freedomFinanceJSONQuote.cls_applicants applicantObj = new freedomFinanceJSONQuote.cls_applicants();
       applicantObj.joint = 'P';
       applicantObj.title = fp.Title__c;
       applicantObj.firstname = fp.First_Name__c;
       applicantObj.surname = fp.Last_Name__c;
       applicantObj.middlename = fp.Middle_Name__c;
       applicantObj.dateOfBirth = fp.Date_Of_Birth__c.format();
       applicantObj.gender = ffFieldMapping.get('Gender').get(fp.Gender__c);
       applicantObj.maritalStatus = ffFieldMapping.get('MaritalStatus').get(fp.Marital_Status__c);
       applicantObj.dependents = integer.valueof(fp.Number_Of_Dependents__c);
       applicantObj.email = fp.Email__c;
       applicantObj.homePhone = fp.Home_Phone__c;
       applicantObj.workPhone = fp.Work_Phone__c;
       applicantObj.mobilePhone = fp.Mobile__c;
       applicantObj.residentialStatus = ffFieldMapping.get('ResidentialStatus').get(fp.Occupancy_Status1__c);
       applicantObj.nationality = fp.Nationality__c;
       
       freedomFinanceJSONQuote.cls_applicant_addresses customerAddress1 = new  freedomFinanceJSONQuote.cls_applicant_addresses();
       customerAddress1.type = 'C'; // Current Address - C
       customerAddress1.rank = 1;
       customerAddress1.address = createFFCustomerAddress(fp.Building_Number1__c, fp.Building_Name1__c, fp.Street1__c, fp.City1__c, fp.State1__c, fp.Post_Code1__c, fp.Add1_Date__c );
       
       applicantObj.applicant_addresses = new list<freedomFinanceJSONQuote.cls_applicant_addresses>();
       applicantObj.applicant_addresses.add(customerAddress1);
       
       freedomFinanceJSONQuote.cls_applicant_addresses customerAddress2;
       if(fp.Post_Code2__c!=null)
       {
           customerAddress2 = new  freedomFinanceJSONQuote.cls_applicant_addresses();
           customerAddress2.type = 'P'; // Previous Address P
           customerAddress2.rank = 2;
           customerAddress2.address = createFFCustomerAddress(fp.Building_Number2__c, fp.Building_Name2__c, fp.Street2__c, fp.City2__c, fp.State2__c, fp.Post_Code2__c, fp.Add2_Date__c );
           applicantObj.applicant_addresses.add(customerAddress2);
       }
       
       freedomFinanceJSONQuote.cls_applicant_addresses customerAddress3;
       if(fp.Post_Code3__c!=null)
       {
           customerAddress3 = new  freedomFinanceJSONQuote.cls_applicant_addresses();
           customerAddress3.type = 'P';// Previous Address P
           customerAddress3.rank = 3;
           customerAddress3.address = createFFCustomerAddress(fp.Building_Number3__c, fp.Building_Name3__c, fp.Street3__c, fp.City3__c, fp.State3__c, fp.Post_Code3__c, fp.Add3_Date__c );
           applicantObj.applicant_addresses.add(customerAddress3);
       }
       
       
       freedomFinanceJSONQuote.cls_employments employClass = new freedomFinanceJSONQuote.cls_employments();
       integer years = fp.Employee_From__c!=null ? math.abs(system.today().daysbetween(fp.Employee_From__c)/365) : 0;
       integer months = fp.Employee_From__c!=null ? math.mod(math.ABS(system.today().daysbetween(fp.Employee_From__c)),365)/30 : 0;
       //*****
       employClass.type = ffFieldMapping.get('EmploymentStatus').get(fp.Employment_Status__c);
       employClass.years = years;
       employClass.months = months;
       /*employClass.grossPayMonthly
       employClass.netPay*/
       employClass.rank = 1;
       employClass.netPayMonthly = integer.valueof(fp.Applicant_Net_Monthly_income__c);
       employClass.grossPay  = integer.valueof(fp.Gross_Income__c);
       if(fp.Post_Code_E__c!=null)
       {
            employClass.address = createFFCustomerAddress(null, fp.Building_Name_E__c, fp.Street_E__c, fp.City_E__c, fp.State_E__c, fp.Post_Code_E__c, fp.Employee_From__c);
            //employClass.address.houseNo +=' '+fp.Employer_Name__c;
       }
       applicantObj.employments = new list<freedomFinanceJSONQuote.cls_employments>();
       applicantObj.employments.add(employClass);
       freedomFinanceJSONQuote.cls_onsData partnerObj = new freedomFinanceJSONQuote.cls_onsData();
       if(fp.Partner_Income__c!=null && fp.Partner_Income__c>0)
       {
           
            partnerObj.appjIncome = string.valueof(fp.Partner_Income__c);
            partnerObj.appjEmployment = ffFieldMapping.get('EmploymentStatus').get(fp.Partner_Employment_Status__c);
            
            
       
       }else
       {
            partnerObj.appjIncome = '0';
            partnerObj.appjEmployment = null;
       }
       
       newQuote.onsData = new list<freedomFinanceJSONQuote.cls_onsData>{partnerObj};
       integer byears = math.abs(system.today().daysbetween(fp.Date_Opened__c)/365);
       integer bmonths = math.mod(math.ABS(system.today().daysbetween(fp.Date_Opened__c)),365)/30;
       
       freedomFinanceJSONQuote.cls_bankDetails bankDetails = new freedomFinanceJSONQuote.cls_bankDetails();
       bankDetails.accountName = fp.Bank_Account_Name__c;
       bankDetails.accountNumber = fp.Bank_Account_Number__c;
       bankDetails.sortcode = fp.Sort_Code__c;
       bankDetails.years = byears;
       bankDetails.months = bmonths;
    /*
        ****** proof of Id Change********
        Adding new code for sending the  Proof of Id change ;
    */
       freedomFinanceJSONQuote.cls_Proof proofOfId =  new freedomFinanceJSONQuote.cls_Proof();
       proofOfId.type = ffFieldMapping.get('TypeOfProof (Signature)').get(fp.Signature_Proof_of_Id__c);
       proofOfId.reference = fp.Sign_Proof_Details__c;
       
       // Code change for proofofID
       
       applicantObj.proof = new list<freedomFinanceJSONQuote.cls_Proof>{proofOfId};
       
       if(fp.Applicant_Other_Income__c != null && fp.Applicant_Other_Income__c >0 )
       {
            freedomFinanceJSONQuote.cls_otherIncomes otherIncome = new freedomFinanceJSONQuote.cls_otherIncomes();
            otherIncome.description = 'TOT';
            otherIncome.rank = 1;
            otherIncome.income = integer.valueof(fp.Applicant_Other_Income__c);
            applicantObj.otherIncomes = new list<freedomFinanceJSONQuote.cls_otherIncomes> {otherIncome};
       }
       applicantObj.bankDetails = new list<freedomFinanceJSONQuote.cls_bankDetails>{bankDetails};
       
       newQuote.applicants = new list<freedomFinanceJSONQuote.cls_applicants>{applicantObj};
       
      
      
       
       
       
       String jsonQuote = JSON.serialize(newQuote);

       
       string QuoteUrl = system.label.FF_Endpoint+system.label.FF_Quote;
        
       string body = postRequest(QuoteUrl, jsonQuote);
      
       if(body.contains('Error'))
       {
           freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
           fp.Status__c = 'Error';
           update fp;
           return new freedomFinanceHelper.returnClass(null,true, errors.Error.message, null );
           
           
       }else
       {
       		freedomFinanceJSONQuoteResponse obj = freedomFinanceJSONQuoteResponse.parse(body);
            
            // string for product name
            
            string productName = '';
            
            fp.X2nd_Lended_Soft_Search__c = statusMap.get(obj.submissions.submissionStatus);
            if(fp.X2nd_Lended_Soft_Search__c == 'Declined')
            fp.Application_Status__c = fp.X2nd_Lended_Soft_Search__c;
            if(obj.submissions.lenderName!=null)
            fp.X2nd_Lender_Name__c = obj.submissions.lenderName;
            if(obj.submissions.lenderCode!=null)
            {
	            fp.Lender_Code__c = obj.submissions.lenderCode;
	            productName +=fp.Lender_Code__c.touppercase();
            }
            
            if(obj.submissions.pricingBand!=null)
            {
	            fp.Customer_Band__c= obj.submissions.pricingBand;
	            productName +=fp.Customer_Band__c;
            }
            if(obj.submissions.loanTerm!=null)
            {
            	fp.payment_Options__c= obj.submissions.loanTerm +' - '+obj.submissions.loanTerm/12+' Years';
            	productName +=(obj.submissions.loanTerm<=99 ? '0'+string.valueof(obj.submissions.loanTerm ): string.valueof(obj.submissions.loanTerm ));
            }
            productName +='IBC';
            
            if(obj.submissions.actualApr!=null)
            {
            	//system.debug(obj.submissions.actualApr);
            	//system.debug(obj.submissions.actualApr.format());
            	//system.debug(obj.submissions.actualApr.format().replaceall('.',''));
            	
            	productName += obj.submissions.actualApr.format().replace('.','');
            	//system.debug(productName);
            }
            
            if(obj.submissions.lenderReference!=null)
            fp.Application_Id__c = obj.submissions.lenderReference;
            if(obj.submissions.notes!=null)
            fp.Referral_Reason__c = obj.submissions.notes;
            
            if(obj.submissions.monthlyRepayment!=null)
            fp.Monthly_Repayments__c= obj.submissions.monthlyRepayment;
            
            if(obj.submissions.totalRepayable!=null)
            fp.Total_Amount_Repayable__c= obj.submissions.totalRepayable;
           
            
            //system.debug('fp--->'+ fp.X2nd_Lended_Soft_Search__c+' '+fp.Application_Status__c +submissions);
            system.debug('submissions-->'+productName+obj.submissions);
            fp.Status__c = 'Success';
            if(productName.length()>=13)
            {
	            productName = productName.substring(0,13);
	            fp.FF_Product_Code__c = productName;
            }
            try{
            if( productName!='')
            fp.Finance_Product__c= [select id from Finance_Product__c where Code__c = :productName].id;
            }catch (Exception e)
            {
            	update fp;
            }
            
            update fp;
            
            
            
            Opportunity opp = new Opportunity(id =fp.CHI_Lead__c, ExternalRef__c = fp.Lead_Ext_Ref_No__c );
            update opp;
            return new freedomFinanceHelper.returnClass(fp.X2nd_Lended_Soft_Search__c,false, fp.Referral_Reason__c , fp.Application_Id__c );
       }
        
    }
    
    public static freedomFinanceJSONQuote.cls_address  createFFCustomerAddress(string houseNo, string houseName, string street, string posttown , string county,  string postcode, date datefrom )
    {
        integer years = math.abs(system.today().daysbetween(datefrom)/365);
        integer months = math.mod(math.ABS(system.today().daysbetween(datefrom)),365)/30;
        freedomFinanceJSONQuote.cls_address addressObj = new freedomFinanceJSONQuote.cls_address();
        string hnumber = houseNo != null ? houseNo:'';// : (houseName!=null? houseName : '');
        addressObj.houseNo = hnumber;
        addressObj.houseName = houseName!=null? houseName : '';
        addressObj.street = street;
        addressObj.posttown = posttown;
        addressObj.county = county;
        addressObj.postcode = postcode;
        addressObj.country = 'United Kingdom';
        addressObj.years = years;
        addressObj.months = months;
        
        return addressObj;
    }
    
    // hard Search
    public static returnClass applyForFreedomFinance( Finance_Application__c fp)
    {
        freedomFinanceJSONApply hardSearch = new freedomFinanceJSONApply();
        hardSearch.submissions = new freedomFinanceJSONApply.cls_submissions();
        hardSearch.submissions.proposalNo= fp.Lead_Ext_Ref_No__c;
        hardSearch.submissions.lenderCode = fp.Lender_Code__c;
        
        string endPoint = system.label.FF_Endpoint+system.label.FF_Apply;
        String jsonQuote = JSON.serialize(hardSearch);
        
        string body = postRequest(endPoint, jsonQuote);
       
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
            system.debug('Errors-->'+errors);
            return (new returnClass(null, true, errors.Error.message, null));
        }else
        {
            freedomFinanceJSONApplyResponse responses = freedomFinanceJSONApplyResponse.parse(body);
            if(responses.ApplyResponse.URL1!='null')
            return (new returnClass('Accepted', false, responses.ApplyResponse.URL1 ,fp.Application_Id__c ));
            else
            {
                return (new returnClass(null, true, 'Finance Document Links are blank', null));
            }
        }
        
    }
    
    
    public static returnClass statusUpdateFreedomFinance(Finance_Application__c fp)
    {
        freedomFinanceDecisionUpdate decUpdate = new freedomFinanceDecisionUpdate();
        decUpdate.DecisionUpdate = new freedomFinanceDecisionUpdate.cls_DecisionUpdate();
        decUpdate.DecisionUpdate.proposalNo = fp.Lead_Ext_Ref_No__c;
        
        string endPoint = system.label.FF_Endpoint+system.label.FF_Decision_Update;
        String jsonQuote = JSON.serialize(decUpdate);
         
        string body = postRequest(endPoint, jsonQuote);
       
        if(body.contains('Error'))
        {
            freedomFinanceErrorCode errors = freedomFinanceErrorCode.parse(body);
            return (new returnClass(null, true, errors.Error.message, null));
        }else
        {
            freedomFinanceDecisionUpdateResponse responses = freedomFinanceDecisionUpdateResponse.parse(body);
            return (new returnClass(responses.DecisionUpdateResponse.appStatus, false, responses.DecisionUpdateResponse.notes,responses.DecisionUpdateResponse.proposalNo ));
        }
    }
    
    
    public static string postRequest(string endPoint, string jsonRequest)
    {
        system.debug('Request-->'+jsonRequest);
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/json');        
        req.setMethod('POST');
        req.setBody(jsonRequest);
        req.setTimeout(120000);
        httpResponse response = m_http.send(req);
       
        String body = response.getBody();
        
        system.debug('Response-->'+body);
        return body;
    }
    
    
    
	
	public class returnClass
	{
	    public string Status;
	    public boolean isError;
	    public string StatusReason;
	    public string applicationId;
	    public returnClass(string Status,boolean isError, string StatusReason, string applicationId)
	    {
	        this.Status= Status;
    	    this.isError = isError;
    	    this.StatusReason = StatusReason;
    	    applicationId = applicationId;
	    }
	}
	

}