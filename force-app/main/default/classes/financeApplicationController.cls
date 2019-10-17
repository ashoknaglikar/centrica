public class financeApplicationController {

    
    public Finance_Application__c fa {get;set;}
    public static final String paymentsFrequency = '12';
    public string fpSelected {get;set;}
    
    public List<SelectOption> financeProducts {get;set;} 
    public List<SelectOption> secondaryFinanceProducts {get;set;} 
    public List<SelectOption> country1 {get;set;}
    public List<SelectOption> country2 {get;set;}
    public List<SelectOption> country3 {get;set;}
    public List<SelectOption> countrye {get;set;}
    public boolean address2{get;set;}
    public boolean address3{get;set;}
    public boolean removeAdd{get;set;}
    public boolean setPensionFields{get;set;}
    
    Public String selPensionDetails{set;get;}
    Public String selPensionF{set;get;}
    public boolean savebtn{get;set;}
    public boolean validatebtn{get;set;}
    public Finance_Product__c fp {get;set;}
    public string fpProdValue { get;set; }
    public List<SelectOption> fpProdOptions { get;set; }
    opportunity opp;
    public boolean productPanel {get;set;}
    
    
    Map<string, list< Finance_Data_Mappings__c>> picklistFieldMaps;
    
    public integer stage {get;set;}
    
    public string ErrMsg{get;set;}
    public boolean err{get;set;}
    
    public boolean showAlias {get;set;}
    
    public string year1 {get;set;}
    public string year2 {get;set;}
    public string year3 {get;set;}
    public string year4 {get;set;}
    public string month1 {get;set;}
    public string month2 {get;set;}
    public string month3 {get;set;}
    public string month4 {get;set;}
    public boolean CheckAddressBtn {get;set;} 
    public Boolean disableInput {get; set;}
    public boolean domestic{get;set;}
    integer ApplicationId;
    string AgreementNumber;
    string ExtRef;
    string oppId = '';
   
    
    public list<Appointment__c> AppointmentList;
    
    public financeApplicationController( ApexPages.StandardController controller)
    {
        domestic = true; 

        ErrMsg='';err=false;
        savebtn = false;
        validatebtn= false;
        removeAdd = address2 = address3= false;
        CheckAddressBtn = true;
        setPensionFields=false;
        disableInput = false;
        string retURL =  ApexPages.currentPage().getParameters().get('retURL');
        system.debug(LoggingLevel.INFO,'RETURL-->'+retURL);
        if(retURL != null){
            if(retURL.startswith('%2F')){
             string[] rUrl = retURL.split('%3F');
             retURL = rURL[0].substring(3,rURL[0].length());
            }
            if(retURL.startswith('/')){
             string[] rtURL = retURL.split('\\?');
             retURL = rtURL[0].substring(1,rtURL[0].length());
            }
            system.debug('final Return URL:'+retURL);
            if(retURL.startswith('006'))
            oppId = retURL;
        }
        system.debug(oppId);
        
        showAlias = true;
        stage = 1;
        list<Finance_Application__c> faList = new list<Finance_Application__c>();
        
        fa = new Finance_Application__c();
        fa = (Finance_Application__c)controller.getRecord();
        opp= new Opportunity();
        fp = new Finance_Product__c();
        

        fpSelected = '';
         
        string FromDetail= ApexPages.currentPage().getParameters().get('FromDetail');
        
        faList = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, CHI_Lead__c, Signature_Proof_of_Id__c, 
                 Title__c, First_Name__c, Last_Name__c, Middle_Name__c, Alias__c, Home_Phone__c, Work_Phone__c, Mobile__c, Alias_Title__c, Alias_First_Name__c, Alias_Last_Name__c, 
                 Alias_Middle_Name__c, Date_Of_Birth__c, Nationality__c, Marital_Status__c, Number_Of_Dependents__c, Gender__c, Street1__c, City1__c, Post_Code1__c, State1__c, Country1__c, 
                 Time_at_Address1__c, Date_From1__c, Occupancy_Status1__c, Occupancy_Status2__c, Occupancy_Status3__c, Street2__c, City2__c, Post_Code2__c, State2__c, Country2__c, Time_at_Address2__c, Date_From2__c, Street3__c, 
                 City3__c, Post_Code3__c, State3__c, Country3__c, Time_at_Address3__c, Date_From3__c, Employment_Status__c, Employer_Name__c, Employment_Category__c, CPhone_Number__c, 
                 Job_Description__c, Time_at_Employer__c, Type_Employee__c, Post_Code_E__c, Street_E__c, City_E__c, State_E__c, Country_E__c, Building_Name_E__c, Gross_Annual_Income__c, 
                 Gross_Annual_State_Pension__c, Gross_Annual_Private_Pension__c, Gross_Annual_Disability_Allowance__c, Gross_Annual_Other_Pension__c, Gross_Annual_additional_benefit__c, 
                 Adress_Proof_ID__c, Sign_Proof_Details__c, Address_Proof_Details__c, Number_Of_Credit_Cards__c, Bank_Account_Name__c, Bank_Account_Number__c, Sort_Code__c, Repayment_Method__c, 
                 Time_At_Bank__c, Status__c, Reference_Number__c, Selling_Type__c, Cash_Price__c, Deposit__c, Monthly_Repayments__c,Building_Number1__c, Building_Number2__c, Building_Number3__c,
                 Building_Name1__c, Building_Name2__c, Building_Name3__c, Employer_Phone__c,Year1__c, Year2__c,Year3__c,YearB__c, Month1__c ,  Month2__c ,  Month3__c ,  Add1_date__c ,  Add2_date__c,
                 Type_of_Finance__c,HSA__c,Email__c,Confirm_Email__c,Add3_date__c,YearE__c,MonthE__c,Finance_Product__c,payment_Options__c,Job_total__c,
                 Security_Question__c,Security_Answer__c,Agreement_Number__c ,X2nd_Lended_Soft_Search__c,Quote_Number__c,
                 Lender_Code__c, X2nd_Lender_Name__c, Applicant_Net_Monthly_income__c, Applicant_Other_Income__c, Partner_Income__c, Partner_Employment_Status__c,  Referral_Reason__c,Income_Band__c, Portal_Quote__c FROM Finance_Application__c Where Id = :fa.Id];
                
       if(faList.size()>0 & FromDetail=='T')
       {
           system.debug(Logginglevel.INFO,'-----INSIDE DETAIL------>');
           //for(Finance_Application__c f: faList)
           //{
              fa = faList[0]; 
              stage = 3;
              CheckAddressBtn = false;
              oppId = fa.CHI_Lead__c;
              fp = [SELECT Name, Id, Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c FROM Finance_Product__c where id=:fa.Finance_Product__c LIMIT 1];
              fpSelected = fa.Finance_Product__c;
              fp.Payment_Options__c = fa.Payment_Options__c;
              if(fa.Year1__c!=null && fa.Month1__c!=null){
                Year1 = String.valueof(fa.Year1__c);
                Month1 = String.valueof(fa.Month1__c);
              }
              if(fa.Year2__c!=null && fa.Month2__c!=null){
                Year2 = String.valueof(fa.Year2__c);
                Month2 = String.valueof(fa.Month2__c);
              }
              if(fa.Year3__c!=null && fa.Month3__c!=null){
                Year3 = String.valueof(fa.Year3__c);
                Month3 = String.valueof(fa.Month3__c);
              }
              if(fa.YearE__c!=null && fa.MonthE__c!=null){
                Year4 = String.valueof(fa.YearE__c);
                Month4 = String.valueof(fa.MonthE__c);
              }
              
           //}
       }else if(oppId!=null)
       {
           opp = [SELECT Id, Install_Postcode__c, Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Account.Primary_Contact__r.HomePhone, Account.Primary_Contact__r.MobilePhone, Account.Primary_Contact__r.otherPhone, Account.Primary_Contact__r.Email__c,
                 Account.Primary_Contact__r.MailingState, Account.Primary_Contact__r.MailingPostalCode, Account.Primary_Contact__r.MailingCity , Account.Primary_Contact__r.MailingStreet, Account.Primary_Contact__r.salutation
                 ,Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.lastName, Product_Interest__c , CHI_Lead_Id__c , (Select id, Name from Bigmachines_Quotes__r order by CreatedDate  )from  Opportunity where Id = : oppId];
            
            AppointmentList = new list<Appointment__c>();     
            AppointmentList = [Select id, Who__c, Assigned_To__c from Appointment__c where Status__c != 'Cancelled' and Opportunity__c = :oppId order by Start__c DESC ];
            
            
            fa.Title__c = opp.Bill_Title__c!=null?opp.Bill_Title__c : opp.Account.Primary_Contact__r.Salutation;
            fa.First_Name__c = opp.Bill_FirstName__c!=null?opp.Bill_FirstName__c : opp.Account.Primary_Contact__r.FirstName;
            fa.Last_Name__c = opp.Bill_LastName__c!=null?opp.Bill_LastName__c : opp.Account.Primary_Contact__r.LastName;
            fa.Street1__c =opp.Bill_Street__c!=null?opp.Bill_Street__c : opp.Account.Primary_Contact__r.MailingStreet;
            fa.City1__c =opp.Bill_City__c!=null?opp.Bill_City__c : opp.Account.Primary_Contact__r.MailingCity;
            fa.Post_Code1__c =opp.Bill_Post_Code__c!=null?opp.Bill_Post_Code__c : opp.Account.Primary_Contact__r.MailingPostalCode;
            fa.State1__c = opp.Bill_State__c!=null?opp.Bill_State__c : opp.Account.Primary_Contact__r.MailingState;
            fa.Home_Phone__c = opp.Account.Primary_Contact__r.HomePhone;
            fa.Mobile__c = opp.Account.Primary_Contact__r.MobilePhone;
            fa.Work_Phone__c = opp.Account.Primary_Contact__r.OtherPhone;
            fa.Email__c = opp.Account.Primary_Contact__r.Email__c;
            fa.Confirm_Email__c = opp.Account.Primary_Contact__r.Email__c;
            //if(opp.Bigmachines_Quotes__r.size()>0)
            //fa.Portal_Quote__c  = opp.Bigmachines_Quotes__r[0].Id;
            //fa.Country1__c = 'UNITED KINGDOM';
            fa.Repayment_Method__c = 'Direct Debit';
            domestic = !(opp.Product_Interest__c == 'Small Commercial');
            
            if(!domestic)
            fa.RecordTypeId = RecordTypeIdHelper.getrecordTypeid('Finance_Application__c', 'Commercial');
            if(opp.Bigmachines_Quotes__r.size()>0)
            {
                //opp.Bigmachines_Quotes__r[0].Name = opp.Bigmachines_Quotes__r[0].Name.substring(0,opp.Bigmachines_Quotes__r[0].Name.length()-1)+'*';
                //Bigmachines_Quote__c bQuote = new Bigmachines_Quote__c(name = 'C'+opp.CHI_Lead_Id__c+'*');
                fa.Portal_Quote__c = opp.Bigmachines_Quotes__r[0].Id;
            }
            else
            fa.Quote_Number__c =  'C'+opp.CHI_Lead_Id__c+'0';
           
       }

       /*
        fa.Country1__c = 'UNITED KINGDOM';
        fa.Country2__c = 'UNITED KINGDOM';
        fa.Country3__c = 'UNITED KINGDOM';
        fa.Country_E__c = 'UNITED KINGDOM';*/
       picklistFieldMaps = new Map<string, list<Finance_Data_Mappings__c>>();
        
       loadPicklist();
    }
    map<id, Finance_Product__c> fpMap;
    
    map<string, list<selectoption>> secondaryProductMapping = new map<string, list<selectoption>>();
    
    public void loadPicklist()
    { 
        financeProducts  = new list<SelectOption>();
        country1 =   new list<SelectOption>();
        country2 =   new list<SelectOption>();
        country3 =   new list<SelectOption>();
        countrye =   new list<SelectOption>();
        fpMap = new map <Id, Finance_Product__c> ([SELECT Name, Id, Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c, Not_Available_For__c FROM Finance_Product__c where Active__c = true]);
        financeProducts.add(new SelectOption('','-- None --'));
        
        // get active parent Products. 
        for(Finance_Product__c f: [SELECT Name, Id, Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c, Not_Available_For__c FROM Finance_Product__c where Active__c = true and Selectable__c = true])
        {
            if(opp!=null && f.Not_Available_For__c!= null &&  f.Not_Available_For__c.contains(opp.Product_Interest__c))
            {
                continue;
            }
            
            financeProducts.add(new SelectOption(f.Id,f.Name));
            
        }
        
        fp = fpMap.get(system.label.barclaysProduct);
        
        
        
        //secondaryFinanceProducts
        
        //List< Map<String, Finance_Data_Mappings__c>> templist = new List< Map<String, Finance_Data_Mappings__c>>();
        //country1.add(new SelectOption('','-- None --'));
        country1.add(new SelectOption('UNITED KINGDOM','UNITED KINGDOM'));
        for(Finance_Data_Mappings__c f: Finance_Data_Mappings__c.getAll().values())
        {
            
            if(f.Field__c == 'Country' && f.PicklistOption__c!= 'UNITED KINGDOM')
            {
                country1.add(new SelectOption(f.PicklistOption__c,f.PicklistOption__c));
            }
            if(picklistFieldMaps.containskey(f.Field__c))
            {
                picklistFieldMaps.get(f.Field__c).add(f);
            }else
            {
                
                picklistFieldMaps.put(f.Field__c,  new list<Finance_Data_Mappings__c>{f});
            }
        }
        country2 = country1;
        country3 = country1;
        countrye = country1;
        
        
    }
    
    public void calculateFinance()
    {
        if(fa.Portal_Quote__c==null && fa.Quote_number__c == null)
        {
            util.setErrorMsg(true, 'Please enter either the Quote Nmber or pick an exisitng Quote' );
           
            return;
        }
        if(fa.Portal_Quote__c!=null)
        {
        BigMachines_Quote__c b = [Select id, 	finalNetQuoteTotal__c, depositOnPricing__c from BigMachines_Quote__c where id = :fa.Portal_Quote__c];
        fa.Job_Total__c = b.finalNetQuoteTotal__c;
        fa.Deposit__c = b.depositOnPricing__c;
        fa.Cash_Price__c = fa.Job_Total__c - fa.Deposit__c;
        }
        productPanel = true;
    }
    
    public void financeProductSel()
    {
        if(fpSelected!=null && fpMap.containsKey(fpSelected))
        {
            fp = fpMap.get(fpSelected);
            
            if(fp.Name == 'BarclaysIBCTerm')
            {
                // loading secondary finance products
                if(secondaryProductMapping.size()==0)
                {
                    for(Finance_Product__c fp : [SELECT Name, Id, Interest_Rate__c, Payment_Options__c, Selling_Type__c, Promotional_period__c, Not_Available_For__c, Parent_Product__c FROM Finance_Product__c where Parent_Product__c != null and  Active__c = true and   Min_Loan__c <= :fa.Cash_Price__c and Max_Loan__c >= :fa.Cash_Price__c ])
                    {
                        if(secondaryProductMapping.containsKey(fp.Parent_Product__c))
                        {
                            secondaryProductMapping.get(fp.Parent_Product__c).add(new SelectOption(fp.Id,fp.Name));
                        }else
                        {
                            secondaryProductMapping.put(fp.Parent_Product__c, new list<SelectOption>{new SelectOption('','-- None --')});
                            secondaryProductMapping.get(fp.Parent_Product__c).add(new SelectOption(fp.Id,fp.Name));
                        }
                    }
                }
                fpProdOptions = secondaryProductMapping.get(fpSelected);
            }
        }
        productPanel= true;
    }
    
    public void secondarySelection()
    {
        if(fpProdValue!=null)
        {
            fp = fpMap.get(fpProdValue);
            fa.Payment_Options__c = fp.Payment_Options__c;
        }
        
        
    }
    
    public void getQuote()
    {
        stage = 2;
        fa.Cash_Price__c = fa.Job_Total__c - fa.Deposit__c;
        system.debug(fa.Finance_Options__c);
        string financeOption = fa.Finance_Options__c;
        IV_Vectors__c fo = IV_Vectors__c.getInstance(financeOption);
        decimal apr = decimal.valueof(fo.Key__c)*0.01;
        integer tenure = integer.valueof(fo.Key2__c);
        fa.Monthly_Repayments__c = returnPaymentMonthly(fa.Cash_Price__c,tenure,apr );
        fa.Total_Amount_Repayable__c = apr == 0.00 ? fa.Cash_Price__c: fa.Monthly_Repayments__c *tenure*12;
        /*
        try{
        stage = 2;
        system.debug('fp.Payment_Options__c'+fp.Payment_Options__c+fa.Payment_Options__c);
        string po = fp.Payment_Options__c!=null?fp.Payment_Options__c:fa.Payment_Options__c;
        string[] Popt = po.split('-'); 
        List<string> fpProdList=new List<string>();
        List<Finance_Product__c> fProdList=new List<Finance_Product__c>();
        system.debug(LoggingLevel.INFO,'------Inside Quote-->'+opp.id);
        fa.Cash_Price__c = fa.Job_Total__c - fa.Deposit__c;
        Decimal price=fa.Cash_Price__c;
        /*
        if(string.valueOf(financeProducts)=='BarclaysIBCTerm'){
        fProdList=[select id,name,Product_Code__c,Min_Loan__c,Max_Loan__c from  Finance_Product__c where Product_Code__c like : 'BPF%'];
          for(Finance_Product__c fPro : fProdList ){
             if(price >= fPro.Min_Loan__c && price <= fPro.Max_Loan__c){
             fpProdList.add(fPro.name);
             }
        
          }
        }
        else if(string.valueOf(financeProducts)=='Freedom Finance'){
         fProdList=[select id,name,Product_Code__c,Min_Loan__c,Max_Loan__c   from  Finance_Product__c where (Product_Code__c like : 'HCF%' OR  Product_Code__c like : '1ST%')];
          for(Finance_Product__c fPro : fProdList ){
             if(price >= fPro.Min_Loan__c && price <= fPro.Max_Loan__c){
             fpProdList.add(fPro.name);
             }
        
          }
        
        }*/
        
        //fpProdOptions = new list<SelectOption>();
        /*
        barclaysIntegrationHelper barInt = new barclaysIntegrationHelper();
        wwwBarclaysPartnerfinanceCom.FinanceQuoteResultWO quote= barInt.callBarclaysQuote(oppId,fp.Id,fa.Deposit__c,fa.Cash_Price__c,popt[0],paymentsFrequency);
       
        if(quote!=null && quote.Application!=null)
        {
        system.debug(LoggingLevel.INFO,'Agreement Number:'+quote);
        if(quote.Application.MonthlyRepayment!=null)
        fa.Monthly_Repayments__c = quote.Application.MonthlyRepayment;
        
        if(quote.Application.ApplicationId!=null)
        ApplicationId = quote.Application.ApplicationId;
        
        if(quote.Application.AgreementNumber!=null)
        AgreementNumber = quote.Application.AgreementNumber;
        }
        
        system.debug(LoggingLevel.INFO,'ApplicationId-->'+ApplicationId+' '+AgreementNumber);
        opportunity opp1 = [select id,name,ExternalRef__c from opportunity where id=:oppId];
        ExtRef = opp1.ExternalRef__c;
        }catch( exception e)
        {
            ErrMsg = 'Something went wrong with Barclays. Please refresh and try again. If the issue persists. Please raise "I Need Help"';
            ErrMsg += system.label.SystemAdminId.contains(userinfo.getProfileId()) ? e.getMessage() : '';
            util.setErrorMsg(true,  ErrMsg);
            err = true;
            return;
        }
        
        */
    }
    
    public pagereference goToOpp()
    {
        
        return new pagereference ('/'+oppId);
    }
    
    public void startApplication()
    {
        stage = 3;
        
        fa.Country1__c = 'United Kindom';
        
    }
    
    public void hideAlias()
    {
        showAlias = fa.Alias__c == 'Yes' ? true: false;
      
    }
    
    Utilities util = new Utilities();
    
    public void checkAddress()
    {
        decimal minumumYear = 3.0;
        decimal totalYears = 0.0;
        decimal toal1 = 0.0;
        decimal toal2 = 0.0;
        decimal toal3 = 0.0;
        
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+year1);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+month1);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+fa.Date_From1__c);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+year2);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+month2);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+fa.Date_From2__c);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+year3);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+month3);
        system.debug(LoggingLevel.INFO,'------------Test debug----------------'+fa.Date_From3__c);
       // try{
            if((year1 == ''||year1 == null) && (month1 == ''||month1 == null) && fa.Date_From1__c == null)
            {
                util.setErrorMsg(true, 'Please enter the number of years before proceeding' );
                ErrMsg = 'Please enter the number of Years before proceeding';
                err = true;
                return;
            }
            
            if(address2 && year2 == '' && month2 == '' && fa.Date_From2__c == null)
            {
                util.setErrorMsg(true, 'Please enter the number of years before proceeding' );
                ErrMsg = 'Please enter the number of Years before proceeding';
                err = true;
                return;
            }
            
            if(address3 && year3 == '' && month3 == '' && fa.Date_From3__c == null)
            {
                util.setErrorMsg(true, 'Please enter the number of years before proceeding' );
                ErrMsg = 'Please enter the number of Years before proceeding';
                err = true;
                return;
            }
            
            if(year1!=null && year1!='' )
            {
                decimal decY1 = decimal.valueof(year1);
                toal1 = decY1;
            }
            if(month1!=null && month1!= '')
            {
                toal1+= ( (decimal.valueof(month1)>9) ? (decimal.valueof(month1)*.01):(decimal.valueof(month1)*.1));
            }
            
            if(fa.Date_From1__c!=null)
            {
                toal1 = fa.Date_From1__c.daysbetween(system.today())/365;
                
            }
            
                
            if(year2!=null && year2!= '')
            {
                decimal decY1 = decimal.valueof(year2);
                toal2+= decY1;
            }
            if(month2!=null && month2!= '')
            {
                toal2+=  ( (decimal.valueof(month2)>9) ? (decimal.valueof(month2)*.01):(decimal.valueof(month2)*.1));
            }
            
            if(fa.Date_From2__c!=null)
            toal2 += (fa.Date_From2__c.daysbetween(system.today())/365)-toal1;
            
            if(year3!=null && year3!= '')
            {
                decimal decY1 = decimal.valueof(year3);
                toal3+= decY1;
            }
            if(month3!=null && month3 != '')
            {
                toal3+=  ( (decimal.valueof(month3)>9) ? (decimal.valueof(month3)*.01):(decimal.valueof(month3)*.1));
            }
            
            if(fa.Date_From3__c!=null)
            toal3 += (fa.Date_From3__c.daysbetween(system.today())/365)-toal1-toal2;
            
            totalYears = toal1+toal2+toal3;
            
            system.debug(loggingLevel.INFO,'-->'+year1+' '+totalYears);
            if(totalYears<minumumYear && !address3)
            {
                removeAdd = true;
                if(!address2)
                {
                address2 = true;
                
                }else if(!address3)
                address3 = true;
                
            }else
            {
                
                CheckAddressBtn = false;
                util.setErrorMsg(false, 'Please Proceed. Addresses have been added' );
                ErrMsg = 'Please Proceed. Addresses have been added';
                savebtn = true;
                validatebtn= true;
                err = true;
                return;
            }
        
        //}catch( Exception e)
        {
            
        }
        
    }
    
    public pageReference saveApp(){
        system.debug(LoggingLevel.INFO,'I am Inside SaveAPp');
        pagereference pageref;
        try{
            if(fa.Email__c!=fa.Confirm_Email__c){
              util.setErrorMsg(true, 'Please check the Email entered..' );
              return null;                
            }
            
            if(fa.Date_Of_Birth__c.daysbetween(System.today())/365<18)
            {
                util.setErrorMsg(true, 'Customer should be more then 18 years Old' );
                return null;
            }
            
            if(year1!='' && year1!=null)fa.Year1__c = decimal.valueof(year1);
            if(year2!='' && year2!=null)fa.Year2__c = decimal.valueof(year2);
            if(year3!='' && year3!=null)fa.Year3__c = decimal.valueof(year3);
            if(year4!='' && year4!=null)fa.YearE__c = decimal.valueof(year4);
            if(month1!='' && month1!=null)fa.Month1__c = decimal.valueof(month1);
            if(month2!='' && month2!=null)fa.Month2__c = decimal.valueof(month2);
            if(month3!='' && month3!=null)fa.Month3__c = decimal.valueof(month3);
            if(month4!='' && month4!=null)fa.MonthE__c = decimal.valueof(month4);
            //fa.ApplicationId__c = ApplicationId;
            fa.Application_Id__c = string.valueof(ApplicationId);
            fa.Agreement_Number__c = AgreementNumber;
            fa.Payment_Options__c = fp.Payment_Options__c;
            fa.Lead_Ext_Ref_No__c = ExtRef;
            fa.Finance_Product__c = fp.Id;
            fa.Time_at_Address1__c = fa.Year1__c +' Years '+ fa.Month1__c +' Months';
            fa.Time_at_Address2__c = fa.Year2__c +' Years '+ fa.Month2__c +' Months'; 
            fa.Time_at_Address3__c = fa.Year3__c +' Years '+ fa.Month3__c +' Months';
            if(fa.Time_At_Bank__c!=null)
            fa.YearB__c = integer.valueof(fa.Time_At_Bank__c);
            upsert fa;
            pageref = new pagereference('/apex/FinanceDetailPage?FId='+fa.id+'&oppId='+oppId+'&fpId='+fa.Finance_Product__c);
            pageref.setRedirect(true);
            return pageref; 
        }Catch(Exception e){
            
            if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
               if(e.getmessage().Contains('Invalid net monthly income')){
                      return null;
                }
                else{
                list<string> error = e.getmessage().split(',');
                util.setErrorMsg(true, error[1]);
                }
            }else
            {
                util.setErrorMsg(true, e.getmessage());
            }
            system.debug(LoggingLevel.INFO,'------->'+e.getMessage());
            return null;
        }
        return null;
    }
    
    public void financeTypeSel()
    {
        if(fa.Type_of_Finance__c == 'HSA' && AppointmentList.size()>0)
        fa.HSA__c= AppointmentList[0].Assigned_To__c;
    }
    
    public void removeAddress()
    {
        if(address3)
            address3 = false; 
        else
        {
            address2 = false;
            removeAdd = false;
        }
    }
   
     Public pageReference validatePayment()
    {
    
        if(fa.Gross_Annual_Income__c!=null && fa.Applicant_Net_Monthly_income__c!=null){
            Decimal netIncome= fa.Gross_Annual_Income__c/12;
            if(fa.Applicant_Net_Monthly_income__c  > netIncome){
                  util.setErrorMsg(true, 'Invalid net monthly income' );
                  return null;  
              }
        }
        return null;
    }
    
    private decimal returnPaymentMonthly(Decimal amount, Integer term, decimal aprDecimal) {  
        system.debug('aprDecimal-->'+aprDecimal);
    	Decimal monthlyPayment = (amount / 24.0).setScale(2);
    	// return payment is equally divided by 24 (months) if the term is 2 years

    	if (term > 2) {
	        Integer numOfMonths = 12;
	        //Decimal annualInterestRate = 0.149;
            Decimal annualInterestRate = aprDecimal;
	        Decimal oneMonth = 1.00;
	        oneMonth = oneMonth.divide(12.00, 7);
	        Decimal monthlyInterestRate = (Math.exp(oneMonth*Math.log(1 + annualInterestRate)) - 1).setScale(7);
	        
	        Decimal value1 = amount * monthlyInterestRate;
	        
	        Decimal value2 = Math.exp(-1*numOfMonths*term*Math.log(1 + monthlyInterestRate));
	        
	        Decimal value3 = 1 - value2;

	        monthlyPayment = 0.00;
	        if(value3!=0){
	           monthlyPayment =  (value1 / value3).setScale(2);        
	        }
	    } 

        return monthlyPayment;
    }
    
}