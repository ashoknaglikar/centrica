public class barclaysIntegrationHelper {
    
    string username = system.label.barclaysUsername1;
    string password = system.label.barcalysPassword1;
    string telesalesOutlet = system.label.telesalesBarclaysOutlet;
    string digitalBarclaysOutlet = system.label.digitalBarclaysOutlet;
    map<string, map<string, string>> barcalysFieldMapping = new map<string, map<string, string>>();
        
    public wwwBarclaysPartnerfinanceCom.FinanceQuoteResultWO callBarclaysQuote(id oppId, id financeId, decimal deposit, decimal financeAmount,  string NumberOfPayments, string paymentFrequency)
    {
        
        List<Opportunity> oppObj = [SELECT Id, Install_Postcode__c,ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Accountid, Account.Primary_Contact__c,Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : oppId];
        //system.debug(LoggingLevel.INFO,'------>opp'+oppObj+' '+oppId+' '+oppObj[0].Account.Primary_Contact__r.Salutation);         
        list<Finance_Product__c> financeProduct = [SELECT Name, Id, Selling_Type_Code__c, Asset_Type__c, Asset_Type_Description__c , Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c, Product_Code__c,Outlet_Code__c,Manual_Finance_Outlet_Code__c, eFinance_outlet_Code__c FROM Finance_Product__c where Id = : financeId];         
        system.debug('financeProduct-->'+financeProduct);
        string ExternalReferenceNumber ;        
        if(oppObj.size()>0 && financeProduct.size()>0)
        {
            if(oppObj[0].ExternalRef__c!=null){
              string[] Ext = oppObj[0].ExternalRef__c.split('-');
              ExternalReferenceNumber = Ext[0]+'-'+string.valueof(Integer.valueof(Ext[1])+1);
            }else
            ExternalReferenceNumber = oppObj[0].CHI_Lead_Id__c+'-'+'1';
            
            wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap integrationObj = new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap();
            
            //Main Applicant 
            wwwBarclaysPartnerfinanceCom.QuotePersonWO MainApplicant = new wwwBarclaysPartnerfinanceCom.QuotePersonWO();
            MainApplicant.Title = oppObj[0].Bill_Title__c!=null?oppObj[0].Bill_Title__c : oppObj[0].Account.Primary_Contact__r.Salutation;
            MainApplicant.Forename = oppObj[0].Bill_FirstName__c!=null?oppObj[0].Bill_FirstName__c : oppObj[0].Account.Primary_Contact__r.FirstName;
            MainApplicant.Surname = oppObj[0].Bill_LastName__c!=null?oppObj[0].Bill_LastName__c : oppObj[0].Account.Primary_Contact__r.LastName;
            
            //asset 
            wwwBarclaysPartnerfinanceCom.AssetWO Asset = new wwwBarclaysPartnerfinanceCom.AssetWO();
            wwwBarclaysPartnerfinanceCom.ArrayOfRetailWO Retail = new wwwBarclaysPartnerfinanceCom.ArrayOfRetailWO();
            
            wwwBarclaysPartnerfinanceCom.RetailWO retailObj = new  wwwBarclaysPartnerfinanceCom.RetailWO(); 
            retailObj.AssetType = financeProduct[0].Asset_Type__c;
            retailObj.Cost = string.valueof(double.valueof(deposit+financeAmount));
            retailObj.Description = financeProduct[0].Asset_Type_Description__c;
            
            Retail.RetailWO = new list<wwwBarclaysPartnerfinanceCom.RetailWO>{retailObj};
            
            Asset.Retail = Retail;
            //Retail.AssetType= '';
            
            
            //finance Element
            wwwBarclaysPartnerfinanceCom.FinanceWO Finance = new wwwBarclaysPartnerfinanceCom.FinanceWO();
            Finance.ProductCode = financeProduct[0].Product_Code__c;
            Finance.SellingType = financeProduct[0].Selling_Type_Code__c;
            Finance.CashDeposit = string.valueof(deposit);
            Finance.Advance = string.valueof(financeAmount);
            Finance.StartDate = system.today();
            Finance.PaymentFrequency = paymentFrequency;
            Finance.NumberOfPayments = NumberOfPayments.trim();
            Finance.InterestRate = financeProduct[0].Interest_Rate__c;
            Finance.InterestRateType = '1';
            Finance.DocumentFeeFinanced = false;
            Finance.NumberOfDeferralPayments = string.valueof(0);
            
            wwwBarclaysPartnerfinanceCom.QuoteWO Application= new wwwBarclaysPartnerfinanceCom.QuoteWO();
            Application.ExternalReferenceNumber = ExternalReferenceNumber;
            Application.MainApplicant = MainApplicant;
            Application.Finance = Finance;
            Application.Asset = Asset;
            Application.AdditionalProducts = null;
            
            string outletCode = decideOutletCode(financeProduct[0], 'e-Finance');
            
            
            system.debug(LoggingLevel.INFO,'Finance Request'+outletCode + ' ' +username +' '+password +' '+Application);
            //system.debug(LoggingLevel.INFO,'Opp Details'+oppObj[0].Bill_Title__c+' '+oppObj[0].Account.Primary_Contact__r.Salutation+' '+oppObj[0].Bill_FirstName__c+' '+oppObj[0].Account.Primary_Contact__r.FirstName);
            wwwBarclaysPartnerfinanceCom.FinanceQuoteResultWO result = integrationObj.FinanceQuote(outletCode, username, password, Application);
            oppObj[0].ExternalRef__c = ExternalReferenceNumber;
            update oppObj;
            system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=->'+result);
            return result;
            
        }
        return null;
        
    }
    
    public string decideOutletCode(Finance_Product__c fp , string financeType)
    {
    	string outletCode;
    	
    	if(financeType == 'HSA')
    	{
    		outletCode=fp.Outlet_Code__c;
    		
    	}else if(financeType == 'e-Finance')
    	{
    		outletCode = fp.eFinance_outlet_Code__c;
    		
    	}else if(financeType == 'Manual Finance')
    	{
    		outletCode = fp.Manual_Finance_Outlet_Code__c;
    		
    	}
    	
    	return 	outletCode;
    }
    
    public map<string, map<string, string>> datahelper()
    {
        for(Finance_Data_Mappings__c f: Finance_Data_Mappings__c.getAll().values())
        {
            if(barcalysFieldMapping.containskey(f.Field__c))
            {
                barcalysFieldMapping.get(f.Field__c).put(f.PicklistOption__c,f.Code__c);
            }else
            {
                map<string, string> mapList = new map<string, string>{f.PicklistOption__c => f.Code__c};
                
                barcalysFieldMapping.put(f.Field__c, mapList );
            }
        }
        return barcalysFieldMapping;
    }
    
    public wwwBarclaysPartnerfinanceCom.ResultWO callBarclaysLoadApplication(string FinanceApplicaitionId, string oppId, string financeProdId,string ExtRef,decimal deposit, decimal financeAmount,  string NumberOfPayments, string paymentFrequency)
    {
        system.debug('oppId='+oppId);
        
        barcalysFieldMapping = datahelper();
        
        List<Opportunity> oppObj = [SELECT Id, Install_Postcode__c, ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : oppId];
                 system.debug('oppObj='+oppObj);
        list<Finance_Product__c> financeProduct = [SELECT Name,Outlet_Code__c, Id, Selling_Type_Code__c, Asset_Type__c, Asset_Type_Description__c , Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c, Product_Code__c,Manual_Finance_Outlet_Code__c, eFinance_outlet_Code__c FROM Finance_Product__c where Id = : financeProdId];         
                  system.debug('financeProduct='+financeProduct);     
        list<Finance_Application__c> fApplication = getFinanceApplication(new List<String> {FinanceApplicaitionId});
                 
        string ExternalReferenceNumber ;          
        if(oppObj.size()>0 && financeProduct.size()>0)
        {
            ExternalReferenceNumber = ExtRef;
            
            wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap integrationObj = new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap();
            
            //Main Applicant 
            wwwBarclaysPartnerfinanceCom.PersonWO MainApplicant = new wwwBarclaysPartnerfinanceCom.PersonWO();
            MainApplicant.Title = fApplication[0].Title__c;
            MainApplicant.Forename =  fApplication[0].First_Name__c;
            MainApplicant.Surname = fApplication[0].Last_Name__c;
            MainApplicant.MiddleNames = fApplication[0].Middle_Name__c;
            MainApplicant.Gender = barcalysFieldMapping.get('Gender').get(fApplication[0].Gender__c);
            MainApplicant.DateOfBirth = fApplication[0].Date_Of_Birth__c;
            MainApplicant.HomePhoneNumber= homephoneMethod(fApplication[0].Home_Phone__c);
            MainApplicant.MobilePhoneNumber= phoneMethod(fApplication[0].Mobile__c);
            MainApplicant.WorkPhoneNumber= homephoneMethod(fApplication[0].Work_Phone__c);
            if(fApplication[0].Email__c!=null)
            MainApplicant.EmailAddress = fApplication[0].Email__c;
            MainApplicant.SecurityQuestion = barcalysFieldMapping.get('SecurityQuestion').get(fApplication[0].Security_Question__c);
            MainApplicant.SecurityAnswer = fApplication[0].Security_Answer__c;
            MainApplicant.MaritalStatus = barcalysFieldMapping.get('MaritalStatus').get(fApplication[0].Marital_Status__c);
            MainApplicant.EmploymentStatus = barcalysFieldMapping.get('EmploymentStatus').get(fApplication[0].Employment_Status__c);
            MainApplicant.NumberOfDependants =  string.valueof(fApplication[0].Number_Of_Dependents__c);
            MainApplicant.ChequeCardHeld = fApplication[0].Number_Of_Credit_Cards__c>1?true:false;
            MainApplicant.NumberOfCardsHeld = string.valueof(fApplication[0].Number_Of_Credit_Cards__c);
            MainApplicant.Nationality = barcalysFieldMapping.get('Country').get(fApplication[0].Nationality__c);
            //MainApplicant.
            
            // ****************** Adreesss
            wwwBarclaysPartnerfinanceCom.AddressWO[] AddressWO = new list<wwwBarclaysPartnerfinanceCom.AddressWO>();
            if(fApplication[0].Post_Code1__c!=null)
            {
                
                AddressWO.add(addressMethod(fApplication[0].Building_Number1__c, fApplication[0].Building_Name1__c, fApplication[0].Street1__c, fApplication[0].City1__c, fApplication[0].State1__c, fApplication[0].Post_Code1__c, fApplication[0].Country1__c, fApplication[0].Add1_date__c, fApplication[0].Occupancy_Status1__c));
            }
            
            if(fApplication[0].Post_Code2__c!=null)
            {
                
                AddressWO.add(addressMethod(fApplication[0].Building_Number2__c, fApplication[0].Building_Name2__c, fApplication[0].Street2__c, fApplication[0].City2__c, fApplication[0].State2__c, fApplication[0].Post_Code2__c, fApplication[0].Country2__c, fApplication[0].Add2_date__c , fApplication[0].Occupancy_Status2__c));
            }
            
            if(fApplication[0].Post_Code3__c!=null)
            {
                
                AddressWO.add(addressMethod(fApplication[0].Building_Number3__c, fApplication[0].Building_Name3__c, fApplication[0].Street3__c, fApplication[0].City3__c, fApplication[0].State3__c, fApplication[0].Post_Code3__c, fApplication[0].Country3__c, fApplication[0].Add3_date__c , fApplication[0].Occupancy_Status3__c));
            }
            
            wwwBarclaysPartnerfinanceCom.ArrayOfAddressWO arrayAddressobj = new wwwBarclaysPartnerfinanceCom.ArrayOfAddressWO ();
            arrayAddressobj.AddressWO = AddressWO;
            MainApplicant.AddressHistory = arrayAddressobj;
            
            
            
            // *************** Alias****************
            wwwBarclaysPartnerfinanceCom.AliasAssociationWO[] AliasAssociationWO = new list<wwwBarclaysPartnerfinanceCom.AliasAssociationWO>();
            if(fApplication[0].Alias__c == 'Yes')
            {
                
                AliasAssociationWO.add(addAlias(MainApplicant.Gender, fApplication[0].Alias_Title__c, fApplication[0].Alias_First_Name__c, fApplication[0].Alias_Last_Name__c,fApplication[0].Alias_Middle_Name__c ));
                
            }
            wwwBarclaysPartnerfinanceCom.ArrayOfAliasAssociationWO AliasAssociation = new wwwBarclaysPartnerfinanceCom.ArrayOfAliasAssociationWO();
            AliasAssociation.AliasAssociationWO = AliasAssociationWO;
            MainApplicant.AliasAssociation = AliasAssociation;
            
            
            
            //asset 
            wwwBarclaysPartnerfinanceCom.AssetWO Asset = new wwwBarclaysPartnerfinanceCom.AssetWO();
            wwwBarclaysPartnerfinanceCom.ArrayOfRetailWO Retail = new wwwBarclaysPartnerfinanceCom.ArrayOfRetailWO();
            
            wwwBarclaysPartnerfinanceCom.RetailWO retailObj = new  wwwBarclaysPartnerfinanceCom.RetailWO(); 
            retailObj.AssetType = financeProduct[0].Asset_Type__c;
            retailObj.Cost = string.valueof(double.valueof(deposit+financeAmount));
            retailObj.Description = financeProduct[0].Asset_Type_Description__c;
            
            Retail.RetailWO = new list<wwwBarclaysPartnerfinanceCom.RetailWO>{retailObj};
            
            Asset.Retail = Retail;
           
           
           // **************  Employment*****************   
            if(fApplication[0].Employment_Status__c != 'Retired' && fApplication[0].Employment_Status__c != 'Benefits')
            {
            wwwBarclaysPartnerfinanceCom.EmploymentWO Employment = new wwwBarclaysPartnerfinanceCom.EmploymentWO();
            Employment.EmploymentCategory = barcalysFieldMapping.get('EmploymentCategory').get(fApplication[0].Employment_Category__c);
            
            Employment.EmployerName = fApplication[0].Employer_Name__c;
            Employment.EmployerPhoneNumber = homephoneMethod(fApplication[0].Employer_Phone__c);
            Employment.Address = employeeAddressMethod(fApplication[0].Building_Number1__c, fApplication[0].Building_Name_E__c, fApplication[0].Street_E__c, fApplication[0].City_E__c, fApplication[0].State_E__c, fApplication[0].Post_Code_E__c, fApplication[0].Country_E__c);
            Employment.EmploymentStartDate =fApplication[0].Employee_From__c ;
            Employment.JobTitle = fApplication[0].Job_Description__c;
            Employment.Salary = string.valueof(integer.valueof(fApplication[0].Gross_Income__c));
            MainApplicant.Employment = Employment;
            }
            
            //*******Applicant Bank Account**************
            wwwBarclaysPartnerfinanceCom.BankAccountWO ApplicantBankAccount = new wwwBarclaysPartnerfinanceCom.BankAccountWO();
            ApplicantBankAccount.AccountName =fApplication[0].Bank_Account_Name__c;
            ApplicantBankAccount.SortCode = fApplication[0].Sort_Code__c;
            ApplicantBankAccount.AccountNumber = fApplication[0].Bank_Account_Number__c;
            ApplicantBankAccount.DateOpened  = fApplication[0].Date_Opened__c;//fApplication[0].
            
            /*
            //*******Alt. Bank Account**************
            wwwBarclaysPartnerfinanceCom.BankAccountWO AlternativeBankAccount = new wwwBarclaysPartnerfinanceCom.BankAccountWO();
            AlternativeBankAccount.AccountName = fApplication[0].Bank_Account_Name__c;
            AlternativeBankAccount.SortCode = fApplication[0].Sort_Code__c;
            AlternativeBankAccount.AccountNumber = fApplication[0].Bank_Account_Number__c;
            AlternativeBankAccount.DateOpened  =  Datetime.newInstance(2006,05,04,00,00,00);//fApplication[0].*/
            
            
            //***** Applicant Income*******
            wwwBarclaysPartnerfinanceCom.IncomeWO Income = new wwwBarclaysPartnerfinanceCom.IncomeWO();
            Income.GrossAnnualIncome = fApplication[0].Gross_Income__c;
            
            MainApplicant.ApplicantBankAccount = ApplicantBankAccount;
            MainApplicant.Income = Income;
            //MainApplicant.AlternativeBankAccount = AlternativeBankAccount;
            
            
            //finance Element
            wwwBarclaysPartnerfinanceCom.FinanceWO Finance = new wwwBarclaysPartnerfinanceCom.FinanceWO();
            Finance.ProductCode = financeProduct[0].Product_Code__c;
            Finance.SellingType = financeProduct[0].Selling_Type_Code__c;
            Finance.CashDeposit = string.valueof(deposit);
            Finance.Advance = string.valueof(financeAmount);
            Finance.StartDate = system.today();
            Finance.PaymentFrequency = paymentFrequency;
            Finance.NumberOfPayments = NumberOfPayments.trim();
            Finance.InterestRate = financeProduct[0].Interest_Rate__c;
            Finance.InterestRateType = '1';
            Finance.NumberOfDeferralPayments = string.valueof(0);
            Finance.DocumentFeeFinanced = false;
            Finance.BalloonPayment = string.valueof(0);
            /*wwwBarclaysPartnerfinanceCom.QuoteWO Application= new wwwBarclaysPartnerfinanceCom.QuoteWO();
            */
            
            /***Customer PRoofs Dummy Data ****/
            wwwBarclaysPartnerfinanceCom.CustomerProofsWO[] CustProofs= new list<wwwBarclaysPartnerfinanceCom.CustomerProofsWO>();
            //system.debug(LoggingLevel.INFO,'---customerprofs:'+barcalysFieldMapping.get('TypeOfProof (Signature)').get(fApplication[0].Signature_Proof_of_Id__c));
            //system.debug(LoggingLevel.INFO,'---customerprofs:'+fApplication[0].Signature_Proof_of_Id__c);
            if(fApplication[0].Type_of_Finance__c == 'HSA' ||fApplication[0].Type_of_Finance__c == 'Manual Finance')
            {
            custProofs.add(ProofMethod(barcalysFieldMapping.get('TypeOfProof (Signature)').get(fApplication[0].Signature_Proof_of_Id__c),fApplication[0].Sign_Proof_Details__c));
            custProofs.add(ProofMethod(barcalysFieldMapping.get('TypeOfProof (Address)').get(fApplication[0].Adress_Proof_ID__c),fApplication[0].Address_Proof_Details__c));
            }else
            {
                custProofs.add(ProofMethod('7',null));
                custProofs.add(ProofMethod('60',null));
            }
            wwwBarclaysPartnerfinanceCom.ArrayOfCustomerProofsWO ACustProofs= new wwwBarclaysPartnerfinanceCom.ArrayOfCustomerProofsWO();
            ACustProofs.CustomerProofsWO = custProofs;
            
            //system.debug(LoggingLevel.INFO,'---customerprofs:'+barcalysFieldMapping.get('TypeOfProof (Signature)').get(fApplication[0].Signature_Proof_of_Id__c));
            
            
           
            
            wwwBarclaysPartnerfinanceCom.ApplicationWO Application = new wwwBarclaysPartnerfinanceCom.ApplicationWO();
            Application.ExternalReferenceNumber = ExternalReferenceNumber;
            Application.RepaymentMethod = '6';
            Application.MainApplicant = MainApplicant;
            Application.Finance = Finance;
            Application.Asset = Asset;
            Application.CustomerProofs = ACustProofs;
            //if(fApplication[0].Application_Id__c!=null)
            //Application.ApplicationId = Integer.valueof(fApplication[0].Application_Id__c);
            
            //**************COntact****
            wwwBarclaysPartnerfinanceCom.ContactNameWO ConName = new wwwBarclaysPartnerfinanceCom.ContactNameWO();
            ConName.Title = fApplication[0].Title__c;
            ConName.Forename =fApplication[0].First_Name__c;
            ConName.Surname = fApplication[0].Last_Name__c;
            
            /*wwwBarclaysPartnerfinanceCom.PhoneNumberWO ConFax = new wwwBarclaysPartnerfinanceCom.PhoneNumberWO();
            conFax = */
            
            
            wwwBarclaysPartnerfinanceCom.ContactWO Contact = new wwwBarclaysPartnerfinanceCom.ContactWO();
            contact.ContactName = conName;
            if(fApplication[0].Home_Phone__c!=null && fApplication[0].Home_Phone__c!=''){
            contact.ContactTelephone = homephoneMethod(fApplication[0].Home_Phone__c);
            }else if(fApplication[0].Work_Phone__c!=null && fApplication[0].Work_Phone__c!=''){
             contact.ContactTelephone = homephoneMethod(fApplication[0].Work_Phone__c);
            }else if(fApplication[0].Mobile__c!=null && fApplication[0].Mobile__c!=''){
             contact.ContactTelephone = phoneMethod(fApplication[0].Mobile__c);
            }
            //contact.ContactFax = ;
            if(fApplication[0].Email__c!=null)
            {
            wwwBarclaysPartnerfinanceCom.ContactEmailWO ConEmail = new wwwBarclaysPartnerfinanceCom.ContactEmailWO();
            conEmail.EmailAddress = fApplication[0].Email__c;
            contact.ContactEmail = conEmail; 
            }
            
            
            
            
            
            system.debug('Finance Request'+telesalesOutlet + ' ' +username +' '+password +' '+Application);
            system.debug('=============================con-->'+contact);
            integer inputSource;
            string ipAddress;
            string  outletcode = telesalesOutlet;
            string username_var = username;
            string password_var = password;
            
            if((fApplication[0].Type_of_Finance__c == 'HSA' || fApplication[0].Type_of_Finance__c == 'Manual Finance'))
            {
                //outletcode  = fApplication[0].HSA__r.Barclays_Outlet__c;
                Finance.SellingType = system.label.barcalysHSASellingType;
                //Application.ApplicationId =  null;
                //username_var = fApplication[0].HSA__r.Barclays_Outlet__c;
                //password_var = fApplication[0].HSA__r.Barclays_Password__c;
            }
            
            outletcode = decideOutletCode(financeProduct[0],fApplication[0].Type_of_Finance__c);
            /*
            if(financeProduct[0].Outlet_Code__c != null)
            {
            	outletcode = financeProduct[0].Outlet_Code__c ;
            }*/
            wwwBarclaysPartnerfinanceCom.ResultWO result = integrationObj.LoadApplication(outletcode , username_var,password_var, ipAddress, inputSource, Application, Contact);
            system.debug('result='+result);
            return result;
            
            
            
        }
        return null;
        
    }
    
    public wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element ApplicationEnquiry(string ExtRef,Integer ApplicationId,Boolean SuppressCCADocument, string outletcode) {
    
     
     string ExternalReferenceNumber= ExtRef;
     wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap integrationObj = new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap();

    
     
     string username_var = username;
     string password_var = password;
     
   
     
     wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element result = integrationObj.ApplicationEnquiry(outletcode ,username_var,password_var,ExternalReferenceNumber,ApplicationId,SuppressCCADocument);
     system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=->App.Res:'+result);
     return result;
     
     
     //return null;
    
    }
    
     public wwwBarclaysPartnerfinanceCom.ValidateAddressResultWO validateAddress(Id oppId,string BuildingNumber,string BuildingName,  String StreetName,String Locality, string Town, String county, String Postcode)
    {
        List<Opportunity> oppObj = [SELECT Id, Install_Postcode__c, ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : oppId];
        
        wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap integrationObj = new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap();

        if(oppObj.size()>0){
          wwwBarclaysPartnerfinanceCom.ValidateApplicantWO Applicant = new wwwBarclaysPartnerfinanceCom.ValidateApplicantWO();
          Applicant.Title = oppObj[0].Bill_Title__c!=null?oppObj[0].Bill_Title__c : oppObj[0].Account.Primary_Contact__r.Salutation;
          Applicant.Forename = oppObj[0].Bill_FirstName__c!=null?oppObj[0].Bill_FirstName__c : oppObj[0].Account.Primary_Contact__r.FirstName;
          Applicant.Surname = oppObj[0].Bill_LastName__c!=null?oppObj[0].Bill_LastName__c : oppObj[0].Account.Primary_Contact__r.LastName;
          
         wwwBarclaysPartnerfinanceCom.ValidateAddressWO returnAddress = new wwwBarclaysPartnerfinanceCom.ValidateAddressWO();
        
            returnAddress.BuildingNumber= BuildingNumber;
            returnAddress.BuildingName= BuildingName;
            returnAddress.StreetName = StreetName;
            returnAddress.Town = Town;
            returnAddress.County= county;
            returnAddress.Postcode= Postcode;
            returnAddress.Locality=Locality;
         
         
         string  outletcode = telesalesOutlet;
         string username_var = username;
         string password_var = password;   
         wwwBarclaysPartnerfinanceCom.ValidateAddressResultWO result = integrationObj.ValidateAddress(outletcode ,username_var ,password_var ,Applicant,returnAddress); 
         return result;  
          
        }
       return null; 
        
    }
    
    public wwwBarclaysPartnerfinanceCom.PhoneNumberWO phoneMethod(string phoneNumber)
    {
        if(phoneNumber!=null && phoneNumber.trim().length()>=10)
        {
            wwwBarclaysPartnerfinanceCom.PhoneNumberWO homePhone = new wwwBarclaysPartnerfinanceCom.PhoneNumberWO();
            homePhone.STDCode = phoneNumber.substring(0,4);
            homePhone.LocalNumber= phoneNumber.substring(4,phoneNumber.trim().length());
            return homePhone;
        }
        return null;
    }
    
    public wwwBarclaysPartnerfinanceCom.PhoneNumberWO homephoneMethod(string phoneNumber)
    {
        if(phoneNumber!=null && phoneNumber.trim().length()>=10)
        {
            wwwBarclaysPartnerfinanceCom.PhoneNumberWO homePhone = new wwwBarclaysPartnerfinanceCom.PhoneNumberWO();
            homePhone.STDCode = phoneNumber.substring(0,5);
            homePhone.LocalNumber= phoneNumber.substring(5,phoneNumber.trim().length());
            return homePhone;
        }
        return null;
    }
    
    
    public wwwBarclaysPartnerfinanceCom.AddressWO addressMethod(string BuildingNumber,string BuildingName,  String StreetName, string Town, String county, String Postcode, String Country,  date MovingInDate, string ResidentialStatus)
    {
        wwwBarclaysPartnerfinanceCom.AddressWO returnAddress = new wwwBarclaysPartnerfinanceCom.AddressWO();
        returnAddress.AddressType   = Country == 'UNITED KINGDOM' ? 'U':'O';
        returnAddress.BuildingNumber= BuildingNumber;
        returnAddress.BuildingName= BuildingName;
        returnAddress.StreetName = StreetName;
        returnAddress.Town = Town;
        returnAddress.County= county;
        returnAddress.Postcode= Postcode;
        //returnAddress.CountryCode= barcalysFieldMapping.get('Country').get(Country);
        returnAddress.MovingInDate= MovingInDate;
        returnAddress.ResidentialStatus= barcalysFieldMapping.get('ResidentialStatus').get(ResidentialStatus);
        return returnAddress;
    }
    
    public Date format(string movinDate){
      system.debug(LoggingLevel.INFO,'------------>'+movinDate);
      Date fDate = (Date)date.valueof(movinDate.substring(0,4) + '-' + movinDate.substring(5,7) + '-' +movinDate.substring(8,10));
      return fDate;
    }
    
    public wwwBarclaysPartnerfinanceCom.CustomerProofsWO ProofMethod(string TypeOfProof,string Ref){
       wwwBarclaysPartnerfinanceCom.CustomerProofsWO returnProof = new wwwBarclaysPartnerfinanceCom.CustomerProofsWO();
       returnProof.TypeOfProof = TypeOfProof;
       returnproof.Reference = Ref;
       return returnProof;
    }
    
    public wwwBarclaysPartnerfinanceCom.AliasAssociationWO addAlias(string Gender, string Title, string Forename, string Surname, string MiddleNames)
    { 
        
        wwwBarclaysPartnerfinanceCom.AliasAssociationWO returnObj =  new wwwBarclaysPartnerfinanceCom.AliasAssociationWO();
        returnObj.AliasAssociationType = '1';
        returnObj.Gender = Gender;
        returnObj.Title = Title;
        returnObj.Forename = Forename;
        returnObj.Surname = Surname;
        returnObj.MiddleNames = MiddleNames;
        
        return returnObj;
        
    }
    
    public wwwBarclaysPartnerfinanceCom.EmploymentAddressWO employeeAddressMethod(string BuildingNumber,string BuildingName,  String StreetName, string Town, String county, String Postcode, String Country)
    {
        wwwBarclaysPartnerfinanceCom.EmploymentAddressWO returnAddress = new wwwBarclaysPartnerfinanceCom.EmploymentAddressWO();
        returnAddress.AddressType   = Country == 'UNITED KINGDOM' ? 'U':'O';
        returnAddress.BuildingNumber= BuildingNumber;
        returnAddress.BuildingName= BuildingName;
        returnAddress.StreetName = StreetName;
        returnAddress.Town = Town;
        returnAddress.County= county;
        returnAddress.Postcode= Postcode;
        //returnAddress.CountryCode= Country == 'UNITED KINGDOM'?'GB':'O';
        return returnAddress;
    }
    
    public string removedecZeros(Decimal Amt){
        string GInc = string.valueof(Amt);
        string GInc1 = GInc.substring(0,GInc.indexOf('.'));
        return GInc1;
    }
    
    
    public void deleteCustomerData(list<Finance_Application__c> fApplication)
    {
        //list<Finance_Application__c> fApplication = getFinanceApplication(FinanceApplicaitionId);
        
        for(Finance_Application__c f: fApplication)
        {
            
            
            
            f.Gross_Annual_additional_benefit__c = null;
            f.Gross_Annual_Disability_Allowance__c = null;
            f.Gross_Annual_Income__c = null;
            f.Gross_Annual_Other_Pension__c = null;
            f.Gross_Annual_Private_Pension__c = null;
            f.Gross_Annual_State_Pension__c = null;
            f.Date_Of_Birth__c = null;
           
            f.Signature_Proof_of_Id__c = null;
            f.Sign_Proof_Details__c = null;
            f.Address_Proof_Details__c = null;
            f.Adress_Proof_ID__c = null;
            f.Bank_Account_Name__c = null;
            f.Bank_Account_Number__c = null;
            f.Number_Of_Credit_Cards__c = null;
            f.Sort_Code__c = null;
            
            f.Date_from1__c = null;
            f.Month1__c = null;
            f.Year1__c = null;
            f.Time_at_Address1__c = null;
            f.Occupancy_Status1__c = null;
            
            f.Building_Number2__c= null;
            f.Building_Name2__c= null;
            f.Street2__c = null;
            f.City2__c= null;
            f.State2__c = null;
            f.Post_code2__c= null;
            f.Country2__c = null;
            f.Date_from2__c = null;
            f.Year2__c = null;
            f.Month2__c = null;
            f.Time_at_Address2__c = null;
            f.Occupancy_Status2__c = null;
            
            f.Building_Number3__c= null;
            f.Building_Name3__c= null;
            f.Street3__c = null;
            f.City3__c= null;
            f.State3__c = null;
            f.Post_code3__c= null;
            f.Country3__c = null;
            f.Date_from3__c = null;
            f.Year3__c = null;
            f.Month3__c = null;
            f.Time_at_Address3__c = null;
            f.Occupancy_Status3__c = null;
            
            f.Building_Name_E__c= null;
            f.Street_E__c = null;
            f.City_E__c= null;
            f.State_E__c = null;
            f.Post_code_E__c= null;
            f.Country_E__c = null;
            
            f.Employer_Phone__c = null;
            f.Employment_Category__c = null;
            f.Employment_Status__c = null;
            f.Security_Question__c = null;
            f.Security_Answer__c = null;
           
            //Added by Ashok G 
            f.Employer_Name__c = null;
            f.Job_Description__c = null;
            f.Time_At_Bank__c = null;
            f.Marital_Status__c = null;
            f.Gender__c = null;
            f.Number_Of_Dependents__c = null;
            f.Nationality__c = null;
            f.Time_at_Employer__c = null;
            f.YearE__c = null;
            f.MonthE__c = null;
            f.Partner_Employment_Status__c = null;
            f.YearB__c = null;
            f.Income_Band__c = null;
        }
        /*if(fApplication.size()>0)
        update fApplication;*/
    }
    
    public List<Finance_Application__c> getFinanceApplication(list<string> FinanceApplicaitionId)
    {
			string applicationQuery  = Utilities.makeQueryWithAllFields('Finance_Application__c', 'Where id in :FinanceApplicaitionId');
			applicationQuery = applicationQuery.replace('from Finance_Application__c' , ',Finance_Product__r.X2nd_Lender_Product__c,Finance_Product__r.Product_Code__c,Finance_Product__r.Asset_Type__c ,CHI_Lead__r.Product_Interest__c,CHI_Lead__r.ExternalRef__c,'+ 
			'Finance_Product__r.Not_Available_For__c, CHI_Lead__r.CHI_Lead_Id__c, Finance_Product__r.Parent_Product__r.Name, Finance_Product__r.Name, Finance_Product__r.Code__c,Finance_Product__r.Asset_Type_Description__c,'+
			'Finance_Product__r.New_Product__c, Finance_Product__r.Selling_Type__c, Finance_Product__r.Deferral_Period__c from Finance_Application__c');
			system.debug(applicationQuery);
			list<Finance_Application__c> fApplication = database.query(applicationQuery);
			/*
			list<Finance_Application__c> fApplication = [SELECT f.payment_Options__c, f.YearE__c, f.YearB__c, f.Year3__c, f.Year2__c, f.Year1__c, f.X2nd_Lender_Name__c, 
														   f.X2nd_Lended_Soft_Search__c, f.Work_Phone__c, f.Type_of_Finance__c, f.Type_Employee__c, f.Trigger_Document_Email__c, f.Title__c, 
														   f.Time_at_Employer__c, f.Time_at_Address3__c, f.Time_at_Address2__c, f.Time_at_Address1__c, f.Time_At_Bank__c, f.SystemModstamp, 
														   f.Street_E__c, f.Street3__c, f.Street2__c, f.Street1__c, f.Status__c, f.State_E__c, f.State3__c, f.State2__c, f.State1__c, f.Sort_Code__c, 
														   f.Signature_Proof_of_Id__c, f.Sign_Proof_Details__c, f.Selling_Type__c, f.Security_Question__c, f.Security_Answer__c, f.Repayment_Method__c, 
														   f.Referral_Reason__c, f.Reference_Number__c, f.Post_Code_E__c, f.Post_Code3__c, f.Post_Code2__c, f.Post_Code1__c, f.Partner_Income__c, 
														   f.Partner_Employment_Status__c, f.Occupancy_Status3__c, f.Occupancy_Status2__c, f.Occupancy_Status1__c, f.Number_Of_Dependents__c, 
														   f.Number_Of_Credit_Cards__c, f.Nationality__c, f.Name, f.Monthly_Repayments__c, f.MonthE__c, f.MonthB__c, f.Month3__c, f.Month2__c, f.Month1__c, 
														   f.Mobile__c, f.Middle_Name__c, f.Marital_Status__c, f.Lender_Code__c, f.Lead_Ext_Ref_No__c, f.Last_Name__c, f.LastModifiedDate, f.LastModifiedById, 
														   f.LastActivityDate, f.Job_Total__c, f.Job_Description__c, f.IsDeleted, f.Input_Spurce__c, f.Id, f.Home_Phone__c, f.HSA__c, f.HSA_Email__c, 
														   f.Gross_Income__c, f.Gross_Annual_additional_benefit__c, f.Gross_Annual_State_Pension__c, f.Gross_Annual_Private_Pension__c, 
														   f.Gross_Annual_Other_Pension__c, f.Gross_Annual_Income__c, f.Gross_Annual_Disability_Allowance__c, f.Gender__c, f.First_Name__c, f.Finance_Product__c, 
														   f.Finance_Lender__c, f.Employment_Status__c, f.Employment_Category__c, f.Employer_Phone__c, f.Employer_Name__c, f.Employee_From__c, f.Email__c, 
														   f.Document_Link__c, f.Document_Link_Fr__c, f.Deposit__c, f.Delete_Date_Time__c, f.Delete_Data__c, f.Date_Opened__c, f.Date_Of_Birth__c, 
														   f.Date_From3__c, f.Date_From2__c, f.Date_From1__c, f.CreatedDate, f.CreatedById, f.Country_E__c, f.Country3__c, f.Country2__c, f.Country1__c, 
														   f.Confirm_Email__c, f.City_E__c, f.City3__c, f.City2__c, f.City1__c, f.Cash_Price__c, f.CPhone_Number__c, f.CHI_Lead__c, f.Building_Number3__c, 
														   f.Building_Number2__c, f.Building_Number1__c, f.Building_Name_E__c, f.Building_Name3__c, f.Building_Name2__c, f.Building_Name1__c, 
														   f.Barcalys_Link_Application_Expiry__c, f.Bank_Account_Number__c, f.Bank_Account_Name__c, f.Application_Status__c, f.Application_ID__c, 
														   f.Applicant_Other_Income__c, f.Applicant_Net_Monthly_income__c, f.Alias__c, f.Alias_Title__c, f.Alias_Middle_Name__c, f.Alias_Last_Name__c, 
														   f.Alias_First_Name__c, f.Agreement_Number__c, f.Adress_Proof_ID__c, f.Address_Proof_Details__c, f.Add3_Date__c, f.Add2_Date__c, f.Add1_Date__c,
														   HSA__r.Barclays_Outlet__c,Finance_Product__r.Name,CHI_Lead__r.ExternalRef__c, CHI_Lead__r.CHI_Lead_Id__c, CHI_Lead__r.Product_Interest__c, 
														   Finance_Product__r.Not_Available_For__c, Finance_Product__r.Parent_Product__r.Name , Interest_Rate__c, Total_Amount_Repayable__c,
														   Error_Details__c, Finance_Product__r.Code__c FROM Finance_Application__c f Where id in :FinanceApplicaitionId];
					 */
				return  fApplication;
                
    }
    
    public List<Finance_Application__c> getFinanceApplicationByLead(id chiLeadId)
    {
        string applicationQuery  = Utilities.makeQueryWithAllFields('Finance_Application__c', 'Where CHI_Lead__c =:chiLeadId');
		applicationQuery = applicationQuery.replace('from Finance_Application__c' , ',Finance_Product__r.Product_Code__c,Finance_Product__r.Asset_Type__c ,CHI_Lead__r.Product_Interest__c,CHI_Lead__r.ExternalRef__c,'+ 
		'Finance_Product__r.Not_Available_For__c, CHI_Lead__r.CHI_Lead_Id__c, Finance_Product__r.Parent_Product__r.Name, Finance_Product__r.Name, Finance_Product__r.Code__c,Finance_Product__r.Asset_Type_Description__c,'+
		'Finance_Product__r.New_Product__c, Finance_Product__r.Selling_Type__c, Finance_Product__r.deferral_Period__c from Finance_Application__c');
		system.debug(applicationQuery);
		list<Finance_Application__c> fApplication = database.query(applicationQuery);
		return  fApplication;
    }
        
    
    
}