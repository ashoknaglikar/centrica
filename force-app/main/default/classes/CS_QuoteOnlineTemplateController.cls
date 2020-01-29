public class CS_QuoteOnlineTemplateController {

 
    public string basketId {get; set;}
    public boolean showYourPayOptions {get;set;}
    public string productInterest {get;set;}
     
    private static final String RADIATOR = 'Radiator_';
    private static final String ACTUAL = 'Actual_Radiator_';
    private static final String PLACEHOLDER = 'Placeholder_';
    private static final String FITTINGBUNDLE = 'Fitting_Bundle_';
    private static final Map<String, String> fittingBundleNameMap = new Map<String, String> 
                                                    {'New location in same room' => 'new fix',
                                                     'Same place, different size' => 'replacement',
                                                     'Same place, same size' => 'replacement' };

    public Boolean is_ifc_active {get;set;}
    public Boolean isShowTermsConditions {get;set;}
    //public Boolean showEnergyTC {get;set;} // Added 26/11/18
    public string tandcs{get;set;}
    //public Boolean showGiftCardAllowanceTC {get;set;} // Added 26/11/18
    public String voucherEmail {get;set;} // Added 26/11/18

    public String pageContent {get;set;}
    public Id appId {get; set;}
    public Id attId {get;set;}
    public Id oppId {get;set;}
    public String logoType {get;set;}

    public string boilerPlusReason{get;set;}

	public static final String TEMP_ONLINE_QUOTE_ATT_NAME = 'TEMP_ONL_Q.HTML';
    
    public List<Attachment> attList {get; set;}

    // apr change 

    public string aprUsed{get;set;} 
    decimal aprDecimal = 0.149;
    
    // These four classes represent data structure that is coming from CS_quotePdf javascript
    // They are similar but not exactly the same as existing Section/LineItem classes
    // This needs refactoring, but for now, we will use QBT* classes and QuoteBreakDownTable class
    // when dealing with data from JS (i.e. before the basket exists) and Section/LineItem 
    // when dealing with data from DB (i.e. when we have a basket)
    // After parsing JSON data, QBT* classes will be transformed to Section/LineItem classes and then passed
    // to the final detailed quote data composer that will create data appropriate for Visualforce page
        
    public class QBTLineItem {
        public String Description {get; set;}
        public String Price {get; set;}
        public String Quantity {get; set;}
        public String Total {get; set;}
        public Id id {get; set;}
    }
    
    public class QBTProduct {
        public String Description {get; set;}
        public Id Id {get; set;}
        //public String Sequence__c;
        public String SubTotal {get; set;}
        public List<QBTLineItem> LineItems {get; set;}
    }
    
    public class QBTSection {
        public String Header {get; set;}
        public Id id {get; set;}
        public Integer Sequence {get; set;}
        //public String Sequence__c;
        public String SubTotal {get; set;}
        public String Text {get; set;}
        public List<QBTProduct> Products {get; set;}
    }
    
    public class QuoteBreakDownTable {
        public String Description {get; set;}
        public List<QBTSection> Sections {get; set;}
        
    }
    
    public class allowanceClass
    {
        public string Description {get;set;}
        public decimal Amount {get;set;}
        
        public allowanceClass(string Description, decimal Amount)
        {
            this.Description = Description;
            this.Amount = Amount;
        }
    }
    
        /**
     * A class representing a section on the pdf quote.
     */
    public class Section {
        public String id {get; set;}
        public String Name {get; set;}
        public Decimal Sequence {get; set;}
        public Decimal Totals {get; set;}
        public List<LineItem> lineItems {get; set;}
        public List<Section> sections {get; set;}
        
        public Section(String id, String name, Decimal sequence) {
            this.Id = id;
            this.Name = name;
            this.Sequence = sequence;
            this.lineItems = new List<LineItem>();
            this.sections = new List<Section>();
        }
        
        public Section(String name, Decimal totals) {
            this.Name = name;
            this.Totals = totals;
            this.lineItems = new List<LineItem>();
            this.sections = new List<Section>();
        }
        
        public void addLineItem(LineItem l) {
            this.lineItems.add(l);
        }
        
        public void addSection(Section s) {
            this.sections.add(s);
        }
    }
    
    /**
     * A class representing line items under particular sections on the pdf quote.
     */
    public class LineItem {
        public String Description {get; set;}
        public Decimal Quantity {get; set;}
        public Decimal Price {get; set;}
        public Decimal Total {get; set;}
        public Id lineItemId {get; set;}
        
        public LineItem(String d, Decimal q, Decimal price, Decimal t, Id lineItemId) {
            this.Description = removeSpecialCharacters(d);
            this.Quantity = q;
            this.Price = price.setScale(2, RoundingMode.HALF_UP);
            this.Total = t.setScale(2, RoundingMode.HALF_UP);
            this.lineItemId = lineItemId;
        }
        
        public Boolean equals(Object obj) {
            if (obj instanceof LineItem) {
                LineItem other = (LineItem) obj;
                return other.lineItemId == lineItemId;
            }
            
            return false;
        }   
    }

    /**
     * A class representing quote summary shown on the first page of the pdf quote.
     */
    public class SummaryTableType {
        public String name {get;set;}
        public String amount {get;set;}
        public String nameClass {get;set;}
        public String amountClass {get;set;}
        public String trClass {get;set;}

        private void setProperties(String trClass, String name, String namCls, String price, String amoCls) {
            this.trClass = trClass;
            this.name = name; //getTrimmedAfterYour(replaceHtmlEscapes(name));  // Updated : 03/10/2019 No need remove "Your " at the beginning of name
            this.amount = price == '0' ? '' : price;
            this.nameClass = namCls;
            this.amountClass = amoCls;
        }

        public SummaryTableType(String trClass, String name, String namCls, String price, String amoCls) {
            setProperties(trClass, name, namCls,formatPriceWithComma(price), amoCls);
        }
        
        public SummaryTableType(String trClass, String name, String namCls, Decimal price, String amoCls) {
            setProperties(trClass, name, namCls, formatPriceWithCommaDecimal(price), amoCls);   
        }

        public void replaceEscapes() {
            name = replaceHtmlEscapes(name);
            amount = replaceHtmlEscapes(amount);
        }
    }
    
    public string businessType {get;set;}
    
    public string getBusinessType(string business)
    {
        businessType = 'Default';
        if(label.regulatedBusinessType.contains(','+business+','))
        businessType =  'Regulated';
        /*else if(label.largeResidentialType.contains(','+business+','))
        businessType = 'Residential';*/
        
        return businessType;
    }
    
    public class AllQuoteData {
        public String logoPng {get;set;}
        public String logoPng2 {get;set;}
        public String logoPng3 {get;set;}
        public String transactionId {get;set;}
        public String quoteNumber {get;set;}
        public String quoteDate {get;set;}
        public String depositReceiptNumber {get;set;}
        public String allowancesApplied {get;set;}
        public String billingPostcode {get;set;}
        public String billingCounty {get;set;}
        public String billingStreet {get;set;}
        public String installationAddress {get;set;}
        public String customerName {get;set;}
        public String hsaName {get;set;}
        public String hsaContactNumber {get;set;}
        public List<SummaryTableType> sectionPrices {get;set;}
        public String ballonTotalPrice {get;set;}
        public QuoteBreakDownTable breakdownQuoteTable {get;set;}
        public String deposit {get;set;}
        public String totalNetPrice {get;set;}
        public String balanceToBePaidBy {get;set;}
        public String balanceOutstanding {get;set;}
        public String depositPaidBy {get;set;}
        public String quoteRef {get;set;}
        public String quoteRef2 {get;set;}
        public String mmp_2 {get;set;}
        public String mmp_3 {get;set;}
        public String mmp_5 {get;set;}
        public String mmp_8 {get;set;}
        public String mmp_10 {get;set;}
        public String tar_2 {get;set;}
        public String tar_3 {get;set;}
        public String tar_5 {get;set;}
        public String tar_8 {get;set;}
        public String tar_10 {get;set;}
        public String waysToPayTotalAmount {get;set;}
        public String waysToPayDeposit {get;set;}
        public String waysToPayBalance {get;set;}
        public String minMonthlyTotal {get;set;}
        public String illustrationDeposit {get;set;}
        public String illustrationTotal {get;set;}
        public String illustrationLoanAmount {get;set;}
        public String paymentDetails {get;set;}
        public String footerContactsDetails {get;set;}
        public String company1 {get;set;}
        public String company2 {get;set;}     
        public String partsModel {get;set;}                
        public String balance {get;set;}  
        public String tradeName {get;set;}     
        public Datetime chi_lead_created_date {get;set;}   
        public String totalPriceExcVat {get;set;}
        public string jobRole {get;set;}

        public list<SummaryTableType> innerTopSummaryTable;
        public list<list<PDFQuoteDetailSection>> innerPdfQuoteDetail {get;set;}
        public list<allowanceClass> allowances {get;set;}
        public string boilerPlusReason{get;set;}
        public boolean wwabQuote {get;set;}
        public boolean wwabGas1YearCareExists {get;set;}
        public string tAndCs {get;set;}
    }

    
    
    
    public AllQuoteData inputQuoteData {get;set;} 

    /**** Structure for keeping top summary table data *****/
    public List<SummaryTableType> topSummaryTable {get;set;}
    
    public String hsaNumber {get;set;}
    public Boolean logoBG {get;set;}
    public String summaryTableHeading{get;set;}    
    
    
    /***** FIELDS THAT ARE NOT DIRECTLY MAPPED FROM JS *****/    
    public String installationPostcode {get;set;}    // billingPostcode
    public String totalPricePayable {get;set;}       // waysToPayTotalAmount
    public String greenBallonPrice {get;set;}        // minMonthlyTotal 
    public String blueBallonPrice {get;set;}         // ballonTotalPrice    
    public String depositB {get;set;}                // illustrationDeposit
    public String loanAmountAB {get;set;}            // illustrationLoanAmount
    public String billingAddress {get;set;}          // billingStreet
    public String depositNumber {get;set;}           // depositReceiptNumber
    public String totalPriceA {get;set;}             // illustrationTotal
    
    /******* DERIVED FIELD **********/
    public String summaryTableFooter {get;set;}
    
    

    public class RadiatorItem{
        public String IncValve {get;set;}
        public String Category {get;set;}
        public String Price {get;set;}

        public RadiatorItem(String incValve, String category,String price){
            this.IncValve = incValve;
            this.Category = category;
            this.Price = price;
        }
    }

    public class RadiatorLineItem implements Comparable {
        public String Description {get;set;}
        public String IncValve {get;set;}
        public Integer Quantity {get;set;}
        public Integer Sequence {get;set;}
        public Decimal Price {get;set;}

        public RadiatorLineItem(String description, Integer quantity,Integer sequence, Decimal price, String incValve){
            this.Description = description;
            this.Quantity = quantity;
            this.Sequence = sequence;
            this.Price = price;
            this.IncValve = incValve;
        }

        public Integer compareTo(Object compareTo) {
            RadiatorLineItem compareToEmp = (RadiatorLineItem)compareTo;
            if (Sequence == compareToEmp.Sequence) return 0;
            if (Sequence > compareToEmp.Sequence) return 1;
            return -1;    
        }   
    }
       
    public class PDFQuoteLineItem {
        public String name {get; set;}
        public String quantity {get; set;}      
        public String price {get; set;}
        public Id id {get; set;}
        
        
        public PDFQuoteLineItem(String itemName, Decimal itemQuantity, String itemPrice, Id id) {
            name = itemName;
            this.id = id;
            if (itemQuantity != 1) {
                quantity = '(x' + itemQuantity + ')';
            } else {
                quantity = ' ';
            }
            price = itemPrice;
        }       
    }
    
    public class PDFQuoteDetailSection {
        public String levelClass {get; set;}
        public String title {get; set;}
        public List<PDFQuoteLineItem> items {get; set;}
        public decimal line = 0;
        
        public PDFQuoteDetailSection(String level, String sectionTitle) {
            items = new List<PDFQuoteLineItem>();
            levelClass = level;
            title = sectionTitle;
        }
    }
    
    Datetime quoteCreatedDate = NULL; 
    public List<PDFQuoteDetailSection> pdfQuoteDetail {get; set;}

    public boolean isSmallCommercial {get;set;}
    
    public void  is_ifc_active( date chi_lead_created_date, date quoteCreatedDate)
    {
        is_ifc_active = false;
        
        list<CS_Promotion_Dates__c> ifcPromotions = new list<CS_Promotion_Dates__c>();
        list<CS_Promotion_Dates__c> defaultPromotions = new list<CS_Promotion_Dates__c>();
         if (chi_lead_created_date != null)
         {
            for(CS_Promotion_Dates__c s: CS_Promotion_Dates__c.getAll().values())
            {
                if(s.Active__c && s.APR__c  == 0.0)
                {
                    ifcPromotions.add(s);
                }else if(s.Active__c)
                {
                    defaultPromotions.add(s);

                }
            }
         }
         
         for(CS_Promotion_Dates__c ifc : ifcPromotions)
         {
            System.debug('////Raw chi_lead_created_date: ' + chi_lead_created_date);
                 // determine interest free loan start and end dates from custom settings
            Date ifc_date_start = ifc.Start_Date__c;
            Date ifc_date_end = ifc.End_Date__c;
            Date ifc_date_final = ifc.Final_Date__c;
            Date leadCreatedDate = chi_lead_created_date;
            Date quoteDate =  quoteCreatedDate;
            System.debug('////IFC Start date: ' + ifc_date_start);
            System.debug('////IFC End date  : ' + ifc_date_end);
            System.debug('////Quote date    : ' + quoteDate);
            System.debug('////CHI Lead c.dt.: ' + leadCreatedDate);

            is_ifc_active = (quoteDate >= ifc_date_start && 
                             quoteDate <= ifc_date_final &&
                             leadCreatedDate <= ifc_date_end);
            System.debug('////IFC quote will be shown? ' + is_ifc_active);
            if(is_ifc_active)
            break;


         }
    }
    
    public string convertToString (decimal amount)
    {
        if(amount == null || amount <= 0.00)
        return null;
        else
        return '£'+string.valueof(amount);
    }

    public CS_QuoteOnlineTemplateController(/*ApexPages.StandardController c*/) {
        
        isSmallCommercial= false;
        aprUsed = '14.9%';
        basketId =ApexPages.currentPage().getParameters().get('Id');// c.getRecord().Id;   
        pdfQuoteDetail = new List<PDFQuoteDetailSection>();  
        inputQuoteData = new AllQuoteData();
        inputQuoteData.wwabQuote = false;
        inputQuoteData.wwabGas1YearCareExists = false;
        topSummaryTable = new List<SummaryTableType>();
        isShowTermsConditions = false;
        showYourPayOptions = false;
        inputQuoteData.tAndCs = '';
        //showEnergyTC = false; // Added 26/11/18
        //showGiftCardAllowanceTC = false; // Added 26/11/18
        
        // this is the date when the quote was created or current date if the quote is not yet written to db
        System.debug('@@@into CS_QuoteOnlineTemplateController constructor  '+basketId);
        
        list<string> aspStatus = new list<string> {'Entered', 'Committed', 'Commited - Removed'};
        
        if(basketId != null && basketId.startsWith(BigMachines_Quote__c.sObjectType.getDescribe().getKeyPrefix()))
        {
            Bigmachines_Quote__c bQuote = [Select id, Opportunity__c,Opportunity__r.Product_Interest__c, Trading_Name__c, App_Assigned_To__c, App_Assigned_Payroll__c, 
                                            Opportunity__r.Account.Primary_Contact__r.Name,
                                            Opportunity__r.Account.Primary_Contact__r.Salutation,
                                            Opportunity__r.Install_Address_Street__c,
                                            Opportunity__r.Install_Postcode__c,
                                            Opportunity__r.SC_Home_Phone__c,
                                            Opportunity__r.SC_Mobile_Phone__c,
                                            Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                                            Opportunity__r.Account.Primary_Contact__r.MailingState,
                                            Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,
                                            Opportunity__r.Account.Primary_Contact__r.MailingCity,
                                            Opportunity__r.Account.Primary_Contact__r.Best_Phone__c,
                                            Opportunity__r.Account.Primary_Contact__r.MobilePhone,
                                            Opportunity__r.CreatedDate,
                                            Opportunity__r.CHI_Lead_Id__c,
                                            opportunity__r.Business_Type__c,
                                            CS_Allowance_1__c,CS_Allowance_1__r.Quote_Description__c,
                                            CS_Allowance_2__c,CS_Allowance_2__r.Quote_Description__c,
                                            CS_Allowance_3__c,CS_Allowance_3__r.Quote_Description__c,
                                            CS_Allowance_4__c,CS_Allowance_4__r.Quote_Description__c,
                                            CS_Allowance_5__c,CS_Allowance_5__r.Quote_Description__c,
                                            CS_Allowance_6__c,CS_Allowance_6__r.Quote_Description__c,
                                            
                                            //Opportunity__r.Install_Postcode__c,
                                            CreatedDate,
                                            Opportunity__r.Payment_Reference_Number__c,depositOnPricing__c,
                                            finalNetQuoteTotal__c,appliedAllowancesTotal__c,POC_Payment_Method__c,Name,allowance_desc_1__c ,allowance_desc_2__c, allowance_desc_3__c,allowance_desc_4__c,
                                            allowance_desc_5__c,allowance_desc_6__c,allowance_desc_7__c,appliedAmount1__c,appliedAmount2__c,appliedAmount3__c,appliedAmount4__c,appliedAmount5__c,appliedAmount6__c,
                                            appliedAmount7__c,discountsTotalOnPricing__c,finalPriceVisibleToCustomer__c ,Boiler_Plus_Reasons__c,
                                            (select id, Name, Gross_Total__c,Quantity__c  from Quote_Products__r where ASP_Status__c not in :aspStatus)  from Bigmachines_Quote__c where id = :basketId];
            
            isSmallCommercial = bQuote.Opportunity__r.Product_Interest__c=='Small Commercial' ? true:false;
            productInterest = bQuote.Opportunity__r.Product_Interest__c;
            is_ifc_active(bQuote.Opportunity__r.CreatedDate.Date(), bQuote.CreatedDate.date());
            
            system.debug('IFC Active -->'+is_ifc_active);
            
            String tradingNameApp = bQuote.Trading_Name__c;     
            setTradeBrand(tradingNameApp);
            
            Employee__c hsa = [Select id, Name , First_Name__c , Last_Name__c,Phone_No__c  from Employee__c where Employee_Number__c = : bQuote.App_Assigned_Payroll__c];
            
            inputQuoteData.hsaName = hsa.First_Name__c + ' '+hsa.Last_Name__c ;
            hsaNumber = hsa.Phone_No__c;
            
            inputQuoteData = OnlineQuoteHelper.createQuotePDFData(bQuote);
            if(inputQuoteData.tAndCs != '' && inputQuoteData.tAndCs !=null )
            {
                tandcs = inputQuoteData.tAndCs;
                isShowTermsConditions = true;
            }
            
            billingAddress  = bQuote.Opportunity__r.Account.Primary_Contact__r.MailingStreet; //+ ' '+ bQuote.Opportunity__r.Account.Primary_Contact__r.MailingCity + ' '+bQuote.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode;
            
            topSummaryTable = inputQuoteData.innerTopSummaryTable;
            
            summaryTableFooter = returnSummaryTableFooter(string.valueof(bQuote.finalNetQuoteTotal__c), null);
            
            for(List<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection> cp : inputQuoteData.innerPdfQuoteDetail)
            pdfQuoteDetail.addall(cp);
            
            installationPostcode =      bQuote.Opportunity__r.Install_Postcode__c;
            
            totalPricePayable = convertToString(bQuote.finalNetQuoteTotal__c );//- bQuote.depositOnPricing__c);
            
            boilerPlusReason = bQuote.Boiler_Plus_Reasons__c;
            
            depositNumber = bQuote.Opportunity__r.Payment_Reference_Number__c;
            totalPriceA =  convertToString(bQuote.finalNetQuoteTotal__c);
            depositB = convertToString(bQuote.depositOnPricing__c);// - bQuote.depositOnPricing__c);
            loanAmountAB = convertToString(bQuote.finalNetQuoteTotal__c - bQuote.depositOnPricing__c);
            
            decimal amount = bQuote.finalNetQuoteTotal__c - bQuote.depositOnPricing__c;
            
            if(amount >=1000)
            showYourPayOptions = true;
            
            aprDecimal = 0.079;
            aprused = '7.9%';
            
            list<CS_Promotion_Dates__c> ifcPromotions = new list<CS_Promotion_Dates__c>();
            list<CS_Promotion_Dates__c> defaultPromotions = new list<CS_Promotion_Dates__c>();
             //if (inputQuoteData.chi_lead_created_date != null)
             {
                for(CS_Promotion_Dates__c s: CS_Promotion_Dates__c.getAll().values())
                {
                    if(s.Active__c && s.APR__c  == 0.0)
                    {
                        ifcPromotions.add(s);
                    }else if(s.Active__c)
                    {
                        defaultPromotions.add(s);
    
                    }
                }
             }
            
            if(!isSmallCommercial)
            for(CS_Promotion_Dates__c dp : defaultPromotions)
            {
                System.debug('////Raw chi_lead_created_date: ' + inputQuoteData.chi_lead_created_date);
                     // determine interest free loan start and end dates from custom settings
                Date dp_date_start = dp.Start_Date__c;
                Date dp_date_end = dp.End_Date__c;
                Date dp_date_final = dp.Final_Date__c;
                Date leadCreatedDate = bQuote.Opportunity__r.CreatedDate.date();
                Date quoteDate =  bQuote.CreatedDate.Date();
               
                if(quoteDate >= dp_date_start && 
                   quoteDate <= dp_date_final &&
                   leadCreatedDate <= dp_date_end)
                {
                    aprDecimal = dp.APR__c*0.01;
                    aprused = string.valueof(dp.APR__c)+'%';
                }

                system.debug('APR Decimal-->'+aprDecimal+' '+dp.APR__c);

            }
             
            inputQuoteData.mmp_2  = returnPaymentMonthly(amount, 2, 0);
            inputQuoteData.mmp_3  = returnPaymentMonthly(amount,3, aprDecimal);
            inputQuoteData.mmp_5  = returnPaymentMonthly(amount,5,aprDecimal);
            inputQuoteData.mmp_8  = returnPaymentMonthly(amount,8, aprDecimal);
            inputQuoteData.mmp_10  = returnPaymentMonthly(amount,10, aprDecimal);
    
            greenBallonPrice  = inputQuoteData.mmp_10;//formatPriceWithComma(getAttributeValue('Total Net Price', configAttributeList));

            //inputQuoteData.tar_2  = returnTotalAmount(amount + Decimal.valueOf(depositB.substring(1)), 2);
            inputQuoteData.tar_2  = returnTotalAmount(amount,2, 0);
            inputQuoteData.tar_3  = returnTotalAmount(amount,3, aprDecimal);
            inputQuoteData.tar_5  = returnTotalAmount(amount,5, aprDecimal);
            inputQuoteData.tar_8  = returnTotalAmount(amount,8, aprDecimal);
            inputQuoteData.tar_10  = returnTotalAmount(amount,10, aprDecimal);

            
        }else if (basketId != null) {    
            System.debug('**** Creating Temp ');
            cscfga__Product_Basket__c basket = [select Id, Name, CreatedDate, Appointment__c, Appointment__r.Opportunity__c, 
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.Salutation,
                                                Appointment__r.Opportunity__r.Install_Address_Street__c,
                                                Appointment__r.Opportunity__r.Install_Postcode__c,
                                                Appointment__r.Opportunity__r.SC_Home_Phone__c,
                                                Appointment__r.Opportunity__r.SC_Mobile_Phone__c,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingState,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MobilePhone,
                                                Appointment__r.Opportunity__r.CreatedDate,
                                                Appointment__r.Assigned_To_Name__c,
                                                Appointment__r.CHI_Lead_No__c,
                                                Appointment__r.Trading_Name__c,
                                                Appointment__r.Assigned_To_Phone__c,
                                                Appointment__r.Opportunity__r.Product_Interest__c,
                                                Appointment__r.Opportunity__r.Business_Type__c
                                                
                                                from cscfga__Product_Basket__c 
                                                where Id = :basketId];
                                                
            is_ifc_active(basket.Appointment__r.Opportunity__r.CreatedDate.Date(), basket.CreatedDate.date());
            getBusinessType(basket.Appointment__r.Opportunity__r.Business_Type__c);
            isSmallCommercial = basket.Appointment__r.Opportunity__r.Product_Interest__c=='Small Commercial' ? true:false;                                    
            productInterest = basket.Appointment__r.Opportunity__r.Product_Interest__c;
            Id appointmentId = basket.Appointment__c;
            Id opportunityId = basket.Appointment__r.Opportunity__c;
            quoteCreatedDate = basket.CreatedDate; // created date if we have a quote
            
            Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c> ([select Id, Name, cscfga__Product_Basket__r.cscfga__Basket_Status__c, cscfga__Product_Definition__c, cscfga__Configuration_Status__c,
                                                                                                                cscfga__Product_Definition__r.Name  
                                                                                                                from cscfga__Product_Configuration__c  
                                                                                                                where cscfga__Product_Basket__c = :basketId
                                                                                                                and cscfga__Parent_Configuration__c = null]);
            if(IV_Vectors__c.getInstance('wwabName').Key__c.contains(configs.values()[0].cscfga__Product_Definition__r.Name))
            inputQuoteData.wwabQuote = true;
            
            //get all attributes and attribute fields
            List<cscfga__Attribute__c> allAttributes = [select  cscfga__Annualised_Price__c, cscfga__Attribute_Definition__c, cscfga__Billing_Price__c, cscfga__Cascade_value__c, cscfga__Discount_Amount__c, cscfga__Discount_Type__c, 
                                                                cscfga__Display_Value__c, cscfga__Hidden__c, cscfga__Is_Line_Item__c, cscfga__Is_rate_line_item__c, cscfga__Is_Read_Only__c, cscfga__Is_Required__c, cscfga__is_active__c, 
                                                                cscfga__Key__c, cscfga__Line_Item_Description__c, cscfga__Line_Item_Sequence__c, cscfga__List_Price__c, Name, cscfga__Attribute_Definition__r.Name, cscfga__Price__c, 
                                                                cscfga__Product_Configuration__c, Id,  cscfga__Recurring__c, cscfga__Value__c,
                                                                (select     cscfga__Attribute__c, 
                                                                            Name, 
                                                                            Id, 
                                                                            cscfga__Value__c
                                                                from cscfga__Attribute_Fields__r)
                                                        from cscfga__Attribute__c 
                                                        where cscfga__Product_Configuration__r.cscfga__Product_Basket__c = : basketId];

        
            //AaJSON
            Set<Id> pConfigsAllIds = (new Map<Id,cscfga__Product_Configuration__c>(configs)).keySet();
            List<Id> pConfigsIdList = new List<Id>(pConfigsAllIds);
            Map<String,Object> configsData = cscfga.API_1.getProductConfigurations(pConfigsIdList); 
        
            //Change for JSON
            Map<Id, Map<String, cscfga__Attribute__c>> configAttributesMap = new Map<Id, Map<String, cscfga__Attribute__c>>(); //in case more than 1 configs are supported per basket in the future
            
            configAttributes(configAttributesMap, allAttributes);
             //2017 --include in screen version
            String tradingNameApp = basket.Appointment__r.Trading_Name__c;       
            setTradeBrand(tradingNameApp);
            inputQuoteData.hsaName = basket.Appointment__r.Assigned_To_Name__c;
            hsaNumber = basket.Appointment__r.Assigned_To_Phone__c;

            fillFromProductConfig(configAttributesMap, basket, configs.keySet(), configsData);

           
         
        } else {
            //getDatafromJson
            attId = ApexPages.currentPage().getParameters().get('attId');
            appId = ApexPages.currentPage().getParameters().get('appId');
            oppId = ApexPages.currentPage().getParameters().get('oppId');  
            
            attList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = 'TEMP_Online_Quote.txt'];    
            quoteCreatedDate = System.now();
            getDataFromJson();         
        }
        system.debug('I am looking for 1 year complimentay cover' +pdfQuoteDetail.size());
        if(pdfQuoteDetail!=null && pdfQuoteDetail.size()>0)
        {
            for(CS_QuoteOnlineTemplateController.PDFQuoteDetailSection p: pdfQuoteDetail)
            {
                for( PDFQuoteLineItem i:p.items)
                {
                    inputQuoteData.wwabGas1YearCareExists= IV_Vectors__c.getInstance('wwabGas1YearCareProductName').key__c.contains(i.name);
                    
                    break;
                }
                if(inputQuoteData.wwabGas1YearCareExists)
                break;
            }
        }
        /*
        if (inputQuoteData.chi_lead_created_date != null &&
        	CS_Promotion_Dates__c.getInstance('Interest Free Credit') != null) {

		        System.debug('////Raw chi_lead_created_date: ' + inputQuoteData.chi_lead_created_date);
		         // determine interest free loan start and end dates from custom settings
		        Date ifc_date_start = CS_Promotion_Dates__c.getInstance('Interest Free Credit').Start_Date__c;
		        Date ifc_date_end = CS_Promotion_Dates__c.getInstance('Interest Free Credit').End_Date__c;
		        Date ifc_date_final = CS_Promotion_Dates__c.getInstance('Interest Free Credit').Final_Date__c;
		        Date leadCreatedDate = Date.newInstance(inputQuoteData.chi_lead_created_date.year(),
		        							inputQuoteData.chi_lead_created_date.month(),
		        							inputQuoteData.chi_lead_created_date.day());
		        Date quoteDate =  Date.newInstance(quoteCreatedDate.year(), quoteCreatedDate.month(), quoteCreatedDate.day());
		        System.debug('////IFC Start date: ' + ifc_date_start);
		        System.debug('////IFC End date  : ' + ifc_date_end);
		        System.debug('////Quote date    : ' + quoteDate);
		        System.debug('////CHI Lead c.dt.: ' + leadCreatedDate);

		        is_ifc_active = (quoteDate >= ifc_date_start && 
		        				 quoteDate <= ifc_date_final &&
		        				 leadCreatedDate <= ifc_date_end);
		        System.debug('////IFC quote will be shown? ' + is_ifc_active);

        } else {
        	is_ifc_active = false;
        }*/
        
        

       
    }
        
    public String returnSummaryTableFooter(String val, String priceExcVAT) {
        String tableFooter = '<tfoot>';
        tableFooter += '<tr class="topBorder">';
        tableFooter += '<td>';
        tableFooter += 'Total net price (inc. VAT)';
        tableFooter += '</td>';
        tableFooter += '<td class="right">';
        tableFooter += formatPriceWithComma(val);
        tableFooter += '</td>';
        tableFooter += '</tr>';

        if (priceExcVAT != null) {
            tableFooter += '<tr>';
            tableFooter += '<td>';
            tableFooter += 'Total price (exc. VAT)';
            tableFooter += '</td>';
            tableFooter += '<td class="right">';
            tableFooter += formatPriceWithComma(priceExcVAT);
            tableFooter += '</td>';
            tableFooter += '</tr>';
        }
        
        tableFooter += '</tfoot>';
        
        return tableFooter;
    }
    
    
    public void deleteTempAttachment() {
        attList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = 'TEMP_Online_Quote.txt'];
        if(attList.size() > 0) {
            Attachment a = attList[0];
            delete a;
        }
    }
    
    private static String getAttributeValue(String attributeName, List<cscfga__Attribute__c> attributeList) {
        System.debug('attributeName: ' + attributeName);
        System.debug('attributeList: ' + attributeList);
        for(cscfga__Attribute__c attr : attributeList){
            if(attr.Name == attributename) return attr.cscfga__Value__c;
        }   
        return '';
    }
    
    private static cscfga__Attribute__c getAttributeItem(String attributeName, List<cscfga__Attribute__c> attributeList) {
        
        cscfga__Attribute__c attrRet = new cscfga__Attribute__c();

        for(cscfga__Attribute__c attr : attributeList){
            if(attr.Name == attributename) return attr;
        }   
        return attrRet;
    }

    private static Decimal returnDecimal(String value) {
        try {
            return Decimal.valueOf(value);
        } catch (Exception ex){
            return 0.00;
        }   
    }  
    
    private static String getCorrectDateFormat(String dateNonFormatted) {
       String formattedDate = '';
       if(dateNonFormatted.indexOf('-')!=-1){
            String[]dateParts = dateNonFormatted.split('-');
            formattedDate = dateParts[2]+' '+ getMonthName(dateParts[1])+' '+ dateParts[0];
        } else {
            formattedDate = dateNonFormatted;
        }
        return formattedDate;
    }
    
    public static String getMonthName(String dateNumeric) {
        String dateName = '';

        if(dateNumeric == '01'){
            dateName = 'January';
        } else if(dateNumeric == '02') {
            dateName = 'February';
        } else if(dateNumeric == '03') {
            dateName = 'March';
        } else if(dateNumeric == '04') {
            dateName = 'April';
        } else if(dateNumeric == '05') {
            dateName = 'May';
        } else if(dateNumeric == '06') {
            dateName = 'June';
        } else if(dateNumeric == '07') {
            dateName = 'July';
        } else if(dateNumeric == '08') {
            dateName = 'August';
        } else if(dateNumeric == '09') {
            dateName = 'September';
        } else if(dateNumeric == '10') {
            dateName = 'October';
        } else if(dateNumeric == '11') {
            dateName = 'November';
        } else if(dateNumeric == '12') {
            dateName = 'December';
        }
        return dateName;
    }
    
    public static String returnFormattedPrice(String value) {
        String formatted = '£'+'0.00';
        if(value!=''){
            if(value.length()>0){
                if(value.indexOf('&pound;')!=-1){
                    formatted = value.split('&pound;')[1];
                } else {
                    formatted = value;
                }
                
                formatted = '£'+ value;
            }
        }
            
         return formatted; 
    } 
    
    private static List<LineItem> condenseLineItems(List<LineItem> lis) {
        Map<Id, LineItem> ret = new Map<Id, LineItem>();        
        for (LineItem li : lis) {
            LineItem item = ret.get(li.lineItemId);         
            if (item != null) {
                item.Quantity += li.Quantity;
                item.Price    += li.Price;
                item.Total    += li.Total;
            } else {
                item = new LineItem(li.Description, li.Quantity, li.Price, li.Total, li.lineItemId);
            }           
            ret.put(item.lineItemId, item);
        }       
        return ret.values();
    }
    
    private void constructPdfLineItemsData(List<LineItem> lis, PDFQuoteDetailSection section) {
        String output = '';     
        List<LineItem> condensedLineItems = condenseLineItems(lis);         
        for (LineItem li : condensedLineItems) {        
            PDFQuoteLineItem item = new PDFQuoteLineItem(adaptStringForOutput(li.Description), li.Quantity, formatPriceWithCommaDecimal(li.Total), li.lineItemId);
            section.items.add(item);
        }
            
    }
    
    private PDFQuoteDetailSection constructSectionHeader(String levelCssClass, String sectionName) {
        PDFQuoteDetailSection sectionHandle = new PDFQuoteDetailSection(levelCssClass, sectionName);    
        return sectionHandle;       
    }
     
    public void createQuoteDetailData(List<Section> quoteItems, Attachment att) {   
        Map<String, CS_PartModelEntry> partsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(att.Body.toString(), Map<String, CS_PartModelEntry>.class);
        createQuoteDetailData(quoteItems, partsModel);
    }
    
    public void createQuoteDetailData(List<Section> quoteItems, Map<String, CS_PartModelEntry> partsModelMap) {
         for (Section lvl1 : quoteItems) {    
            PDFQuoteDetailSection section1Handle = constructSectionHeader('Level1', adaptStringForOutput(lvl1.Name));                          
            if (lvl1.lineItems != null) {           
                constructPdfLineItemsData(lvl1.lineItems, section1Handle);
            }            
            pdfQuoteDetail.add(section1Handle);                            
            if (lvl1.sections != null) {            
                for (Section lvl2 : lvl1.sections) {  
                    PDFQuoteDetailSection section2Handle = constructSectionHeader('Level2', adaptStringForOutput(lvl2.Name));                                                     
                    if (lvl2.lineItems != null ) {
                        if (lvl2.Name.toLowerCase().indexOf('radiators and valves') != -1) {
                            getRadiatorLineItems(partsModelMap, section2Handle);
                        } else {
                            constructPdfLineItemsData(lvl2.lineItems, section2Handle);
                        }                     
                    }            
                    pdfQuoteDetail.add(section2Handle);
                }
            }
        }
        System.debug('sasa:: pdfQuoteDetail: ' + JSON.serialize(pdfQuoteDetail));
		System.debug('sasa:: quoteItems: ' + JSON.serialize(quoteItems));
    }
    
    private static String adaptStringForOutput(String input) {
        return getTrimmedAfterYour(replaceHtmlEscapes(input));
        
    }
    
    private static String getTrimmedAfterYour(String input) {
        String ret = input;
        final String TOKEN = 'Your ';
        
        if (input.contains(TOKEN)) {
            ret = input.substringAfter(TOKEN);
        }
        
        return ret;
    }
    
    private static String replaceHtmlEscapes(String input) {
        if (input != null) {
            return input.replace('&amp;', '&').replace('&quot;','"').replace('&pound;', '£');
        } else {
            return '';
        }
        
    }
    
    private String returnPaymentMonthly(Decimal amount, Integer term, decimal aprDecimal) {  
        system.debug('aprDecimal-->'+aprDecimal);
    	Decimal monthlyPayment = (amount / 24.0).setScale(2, RoundingMode.HALF_UP);
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
	           monthlyPayment =  (value1 / value3).setScale(2, RoundingMode.HALF_UP);        
	        }
	    } 

        return '£'+monthlyPayment;
    }
    
    private String returnTotalAmount(Decimal amount, Integer term, decimal aprDecimal) {
        system.debug('aprDecimal-->'+aprDecimal);
    	Decimal totalAmountRepayable = amount.setScale(0);
    	// repayable amount is the same as the amount for 2-year interest free credit
    	if (term > 2) {
	        Integer numOfMonths = 12;
	        //Decimal annualInterestRate = 0.149;
            Decimal annualInterestRate = aprDecimal;
	        Decimal oneMonth = 1.00;
	        oneMonth = oneMonth.divide(12.00, 7);
	        Decimal monthlyInterestRate = (math.exp(oneMonth*math.log(1 + annualInterestRate)) - 1).setScale(7);
	            
	        Decimal value1 = amount * monthlyInterestRate;
	        Decimal value2 = math.exp(-1*numOfMonths*term*math.log(1 + monthlyInterestRate));
	        Decimal value3 = 1 - value2;

	        Decimal monthlyPayment = 0.00;
	        if(value3!=0){
	           monthlyPayment =  (value1 / value3).setScale(2, RoundingMode.HALF_UP);
	        }

	        totalAmountRepayable = (monthlyPayment*numOfMonths*term).setScale(0);
	    }

        return formatPriceAsWholeNumber(totalAmountRepayable);
    }
    
    //Build Sections
    public class QuoteDetails {
        public String QuoteDate {get; set;}
        public String QuoteNumber {get; set;}
        public String TransactionId {get; set;}
        
        public QuoteDetails(String qd, String qn, String tid) {
            this.QuoteDate = toFullMonth(qd);
            this.QuoteNumber = qn;
            this.TransactionId = tid;
        }
        
        private String toFullMonth(String s) {
            Map<Integer, String> monthNames = new Map<Integer, String>{
                1 => 'January',
                2 => 'February', 
                3 => 'March',
                4 => 'April',
                5 => 'May',
                6 => 'June',
                7 => 'July',
                8 => 'August',
                9 => 'September',
                10 => 'October',
                11 => 'November',
                12 => 'December'
            };
            
            try {
                Date d = returnDate(s);
                String returnedDate = monthNames.get(d.month()) + ' ' + d.day() + ', ' + d.year();
                return returnedDate;
            } catch (Exception e) {
                System.debug('In QuoteDetails.toFullMonth: ' + e);
            }
            return s;
        }
    }
    

    
    /**
     * Tries to return a date from a provided string.
     * Returns null if the parsing was unsuccessful.
     * @param {String} d   A string representation of a date.
     * @returns {Date}
     */
    public static Date returnDate(String d) {
        if (d == null) {
            return null;
        }
        try {
          Date parsedDate = Date.parse(d); 
          return parsedDate; 
        }
        catch (TypeException e) {
          try {
                Date parsedDate = Date.valueOf(d); 
                return parsedDate;
            }
            catch (TypeException ex) {
              return null;
            }        
        }
        return null;    
    }
    
    /**
     * Formatts the price to 2 decimal values.
     * @param{String} p   A string representation of a price.
     * @return{Decimal} Returns a price in a decimal format rounded to 2 decimal places.
     */
    public static String formatPrice(String p) {
        try {
            Decimal priceDecimal = Decimal.valueOf(p); 
            priceDecimal = priceDecimal.setScale(2, RoundingMode.HALF_UP);
            return String.valueOf(priceDecimal);
        } catch (Exception ex) {
            System.debug('********* Format price exception: ' + ex);
        }
        
        return p;
    }

    /**
     * Replaces any special characters present in the provided string.
     * @param{String} s
     * @return{String} Returns a string without special characters.
     */
    public static String removeSpecialCharacters(String s) {
        if(s != null && s.length() != 0) {
            return s.replaceAll('&amp;', '&');
        } else {
            return s;
        }
    }
    
    /**
     * Builds the model to be passed to the visual force page. Contains all of the items 
     * to be shown on the pdf quote.
     * @param {Attachment} att   An attachment containing the partsModel.
     * @param {Map<String, cscfga__Attribute__c>} Map of attributes, used for allowances values.
     * @returns {List<Section>} Returns a list of section objects which are displayed on the visualforce page.
     */
    private static List<Section> buildQuote(Attachment att, Map<String, cscfga__Attribute__c> attributeMap, List<cscfga__Attribute__c> attributesForConfig, Map<String,Object> configsData, Id pcId) {
        //initialize maps for radiators and bundles
        Map<String, CS_PartModelEntry> radiatorMap = new Map<String, CS_PartModelEntry>();
        Map<String, CS_PartModelEntry> fittingBundleMap = new Map<String, CS_PartModelEntry>();
        
        
        // get all sections
        // sort all sections
        String sectionQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Template_Section_Header__c') + ' From CS_Template_Section_Header__c ORDER BY Sequence__c';
        
        List<CS_Template_Section_Header__c> allSections = ((List<CS_Template_Section_Header__c>)database.query(sectionQuery));
                      
        Map<Id, CS_Template_Section_Header__c> allSectionsMap = new Map<Id, CS_Template_Section_Header__c>(allSections);
        
        // create a map of level1 to level2 sections
        Map<Id, List<Id>> level1toLevel2Map = new Map<Id, List<Id>>();
        for(CS_Template_Section_Header__c section : allSections) {
            // check if a section is a level 2 section
            if(section.Level_1_Section__c != null) {
                if (level1toLevel2Map.get(section.Level_1_Section__c) == null) {
                    level1toLevel2Map.put(section.Level_1_Section__c, new List<Id>());
                }              
                level1toLevel2Map.get(section.Level_1_Section__c).add(section.Id);
                
            } else {
                if (level1toLevel2Map.get(section.Id) == null) level1toLevel2Map.put(section.Id, new List<Id>());
            }
        }
        
        // create a map of sections with their parts
        Map<Id, List<LineItem>> sectionIdToPartsModelMap = new Map<Id, List<LineItem>>();
        if (att != null) {
            Map<String, CS_PartModelEntry> partsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(att.Body.toString(), Map<String, CS_PartModelEntry>.class); 
                       
            for(String key : partsModel.keySet()) {
                CS_PartModelEntry item = partsModel.get(key);
                
                if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
                
                    // add a check for radiators
                    if(isRadiatorAttribute(item.attRef)) {
                        addRadiatorOrFittingBundle(item, radiatorMap, fittingBundleMap);
                    } else {
                        if (item.isPart && !(item.isMultilookup)) {
                                 
                            String description = String.isNotEmpty(item.parentPart.part.Quote_Description__c) 
                                                ? item.parentPart.part.Quote_Description__c 
                                                : (String.isNotEmpty(item.parentPart.part.Description__c) 
                                                    ? item.parentPart.part.Description__c 
                                                    : (String.isNotEmpty(item.parentPart.part.Name) 
                                                        ? item.parentPart.part.Name 
                                                        : ''));
                                                        
                            Boolean showAssociatedParts = item.parentPart.part.Show_Parts__c;
                            
                            if(showAssociatedParts == true) {
                                // add the parent part                              
                                LineItem li = new LineItem(description, 
                                                        item.parentPart.quantity, 
                                                        item.parentPart.totalNetPrice, 
                                                        item.parentPart.totalPriceIncVAT,
                                                        item.parentPart.part.Id);
                            
                                if(item.parentPart.part.CS_Template_Section_Header__c != null) {
                                    if(sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c) == null) {
                                        sectionIdToPartsModelMap.put(item.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                    }
                                    
                                    sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c).add(li);   
                                }
                                // add the associated parts
                                
                                for (CS_PartModelEntry.CS_PartInformation  associatedPart : item.associatedParts) {
                                    String aPdescription = String.isNotEmpty(associatedPart.part.Quote_Description__c) 
                                        ? associatedPart.part.Quote_Description__c 
                                        : (String.isNotEmpty(associatedPart.part.Description__c) 
                                            ? associatedPart.part.Description__c 
                                            : (String.isNotEmpty(associatedPart.part.Name) 
                                                ? associatedPart.part.Name 
                                                : ''));
                                                
                                    LineItem aPli = new LineItem(aPdescription, 
                                                            associatedPart.quantity, 
                                                            associatedPart.totalNetPrice, 
                                                            associatedPart.totalPriceIncVAT,
                                                            associatedPart.part.Id);
                                                            
                            
                                    if (associatedPart.part.CS_Template_Section_Header__c != null) {
                                        if(sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c) == null) {
                                            sectionIdToPartsModelMap.put(associatedPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                        }
                                        sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c).add(aPli);     
                                    }                   
                                 }
                            } else {
                                LineItem li = new LineItem(description, item.parentPart.quantity, item.aggregatedNetPrice, item.aggregatedPriceInclVAT, item.parentPart.part.Id);
                            
                                if(item.parentPart.part.CS_Template_Section_Header__c != null) {
                                    if(sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c) == null) {
                                        sectionIdToPartsModelMap.put(item.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                    }
                                    sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c).add(li);   
                                }
                            }
                        } else if (item.isBundle) {
                            
                            Boolean showParts = item.parentBundle.Show_Parts__c;
                            if (showParts == true) {
                                // add all associated parts
                                for (CS_PartModelEntry.CS_PartInformation  associatedPart : item.associatedParts) {
                                        
                                    String description = String.isNotEmpty(associatedPart.part.Quote_Description__c) 
                                                                ? associatedPart.part.Quote_Description__c 
                                                                : (String.isNotEmpty(associatedPart.part.Description__c) 
                                                                    ? associatedPart.part.Description__c 
                                                                    : (String.isNotEmpty(associatedPart.part.Name) 
                                                                        ? associatedPart.part.Name 
                                                                        : ''));
                                                                        
                                                                        
                                    LineItem li = new LineItem(description, 
                                                            associatedPart.quantity, 
                                                            associatedPart.totalNetPrice, 
                                                            associatedPart.totalPriceIncVAT,
                                                            associatedPart.part.Id);
                              
                                    if (associatedPart.part.CS_Template_Section_Header__c != null) {
                                        
                                        if(sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c) == null) {
                                            sectionIdToPartsModelMap.put(associatedPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                        } 
                                        sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c).add(li);    
                                    }
                                }               
                                 
                            } else {
                                // add the bundle
                                String description = String.isNotEmpty(item.parentBundle.Quote_Description__c) 
                                                        ? item.parentBundle.Quote_Description__c 
                                                        : (String.isNotEmpty(item.parentBundle.Description__c) 
                                                            ? item.parentBundle.Description__c 
                                                            : (String.isNotEmpty(item.parentBundle.Name) 
                                                                ? item.parentBundle.Name 
                                                                : ''));
                                                                
                                LineItem li = new LineItem(description, 
                                                        item.attLastQuantity, 
                                                        item.aggregatedNetPrice, 
                                                        item.aggregatedPriceInclVAT,
                                                        item.parentBundle.id);
                                                        
                                
                                if (item.parentBundle.CS_Template_Section_Header__c != null) {
                                    
                                    if (sectionIdToPartsModelMap.get(item.parentBundle.CS_Template_Section_Header__c) == null) {
                                        sectionIdToPartsModelMap.put(item.parentBundle.CS_Template_Section_Header__c, new List<LineItem>());
                                    }
                                    
                                    sectionIdToPartsModelMap.get(item.parentBundle.CS_Template_Section_Header__c).add(li);  
                                }
                            }
                        }
                    }
                }
            }
            
            addRadiatorsToSectionList(radiatorMap, fittingBundleMap, sectionIdToPartsModelMap);
        }   
         
        List<Section> quoteItems = new List<Section>();
        
        // if the quote is a low cost quote an additional section needs to be added
        //get pricebook type value

        if(attributesForConfig!=null){

            String pricebookValue = getAttributeValue('Pricebook Type', attributesForConfig);

            //Boolean isLowCostSection = attributeMap.get('Pricebook Type') != null ? (attributeMap.get('Pricebook Type').cscfga__Value__c == CS_Constants.CS_PricebookType_LowCost ? true : false) : false;
            Boolean isLowCostSection = pricebookValue != null ? (pricebookValue == CS_Constants.CS_PricebookType_LowCost ? true : false) : false;
            
            if(isLowCostSection) {
                Section lowCostSection = new Section('noId', 'Quotation details', 0);
                lowCostSection.addLineItem(new LineItem('The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.', 0, 0, 0, null));
                quoteItems.add(lowCostSection);
            }
        }
  
        // iterate through all of the sorted sections
        // create a list of section objects with their partsModel
        for(CS_Template_Section_Header__c sortedSection : allSections) {
            if(sortedSection.Level_1_Section__c == null) {
                Section sectionObject = new Section(sortedSection.Id, sortedSection.Name, sortedSection.Sequence__c);
                sectionObject.lineItems = sectionIdToPartsModelMap.get(sortedSection.Id);
                // if a level1 section has level 2 sections we need to iterate through those as well
                for(CS_Template_Section_Header__c sortedLevel2Section : allSections) {
                    if(sortedLevel2Section.Level_1_Section__c == sortedSection.Id) {
                        Section sectionLevel2Object = new Section(sortedLevel2Section.Id, sortedLevel2Section.Name, sortedLevel2Section.Sequence__c);
                        sectionLevel2Object.lineItems = sectionIdToPartsModelMap.get(sortedLevel2Section.Id);
                        sectionObject.addSection(sectionLevel2Object);
                    }    
                }
                quoteItems.add(sectionObject);
            }
        }
        
        // remove all empty sections
        Integer i = 0;
        while (i < quoteItems.size()) {
            if(quoteItems.get(i).sections.size() != 0) {
                Integer j = 0;
                while (j < quoteItems.get(i).sections.size()) {
                    if(quoteItems.get(i).sections.get(j).lineItems == null && quoteItems.get(i).sections.get(j).sections.size() == 0) {
                        quoteItems.get(i).sections.remove(j);
                    } else {
                        j++;
                    }
                }
            }
            
            if(quoteItems.get(i).lineItems == null && quoteItems.get(i).sections.size() == 0) {
                quoteItems.remove(i);
            } else {
                i++;
            }
        }
        
        // add the pricing
        // Pricing:
        
        
        //add the allowances
        List<String> allowanceAttributes = new List<String> {'Allowance1' , 'Allowance2', 'Allowance3', 'Allowance4', 'Allowance5', 'Allowance6'};
        
        Section discounts = new Section('', 'Discounts:', 997);
        for(String attr : allowanceAttributes) {
            cscfga__Attribute__c allowance = getAttributeItem(attr,attributesForConfig);//attributeMap.get(attr);
            if (allowance != null && allowance.cscfga__Value__c != null && allowance.cscfga__Value__c != '') {
                String isApplied = 'FALSE';
                String allowanceName = '';
                Decimal allowanceActualValue = 0;
                Id attributeDefinitionId = allowance.cscfga__Attribute_Definition__c;
                List<cscfga__Attribute_Field__c> allowanceAttributeFields = (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+attributeDefinitionId+'-attributeFields');
               
                for (cscfga__Attribute_Field__c af : allowanceAttributeFields) {  
                    if (af.Name == 'AllowanceName') {
                        allowanceName = af.cscfga__Value__c;
                    }
                    else if (af.Name == 'ActualAmount') {
                        allowanceActualValue = Decimal.valueOf(af.cscfga__Value__c);
                    } 
                    else if (af.Name == 'Is_Applied') {
                        isApplied = af.cscfga__Value__c;
                    }
                }
                
                if(isApplied == 'TRUE') {
                    LineItem al = new LineItem(allowanceName, 0, 0, allowanceActualValue, null); //DO NOT DISPLAY NET FOR ALLOWANCES
                    discounts.addLineItem(al);
                }         
            }
        }
        
        
        
        // add the total discrounts
        
        
        return quoteItems;
    }
    
    /**
     * Checks whether an attribute reference starts with Radiator_ and contains
     * Placeholder_ or Actual_Radiator_ or Fitting_Bundle_
     * @param {String} attRef  An attribute reference which will be checked.
     * @returns {Boolean} Whether or not an attribute is a radiator attribute.
     */
    public static Boolean isRadiatorAttribute(String attRef) {
        if(attRef != null && attRef.startsWith(RADIATOR)) {
            if(attRef.contains(PLACEHOLDER) || attRef.contains(ACTUAL) || attRef.contains(FITTINGBUNDLE)) {
                return true;    
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
        
    /**
     * Adds the radiator or fitting bundle to their respective maps.
     * @param {CS_PartModelEntry} item   An partmodelentry.
     * @param {Map<String, CS_PartModelEntry>} radiatorMap  
     * @param {Map<String, CS_PartModelEntry>} fittingBundleMap
     */
    private static void addRadiatorOrFittingBundle(CS_PartModelEntry item, Map<String, CS_PartModelEntry> radiatorMap, Map<String, CS_PartModelEntry> fittingBundleMap) {
        // get reference for map
        String attRef = item.attRef;
        Integer len = RADIATOR.length() + 1;
        String index = attRef.substring(0, len);
        
        // add placeholders and actuals to radiator map
        // add fitting bundles to fitting bundle map
        if(attRef.contains(PLACEHOLDER) || attRef.contains(ACTUAL)) {
            radiatorMap.put(index, item);
        } else if(attRef.contains(FITTINGBUNDLE)) {
            fittingBundleMap.put(index, item);
        }
    }
    
    /**
     * Adds the constructed line items to the partsModel map to be displayed on the visualforce page.
     * It iterates through all of the radiators and fitting bundles and constructs line items out of them.
     * @param {Map<String, CS_PartModelEntry>} radiatorMap  A map of all radiator parts.
     * @param {Map<String, CS_PartModelEntry>} fittingBundleMap  A map of all the fitting bundles.
     * @param {Map<Id, List<LineItem>>} sectionIdToPartsModelMap  A map of sections and parts.
     */
    private static void addRadiatorsToSectionList(Map<String, CS_PartModelEntry> radiatorMap, Map<String, CS_PartModelEntry> fittingBundleMap, Map<Id, List<LineItem>> sectionIdToPartsModelMap) {
        // iterate radiator map
        for(String key : radiatorMap.keySet()) {
            CS_PartModelEntry rad = radiatorMap.get(key);
            CS_PartModelEntry fitBundle = fittingBundleMap.get(key);
    
            // construct radiator and add to section list
            if(rad != null) {
                String description = String.isNotEmpty(rad.parentPart.part.Quote_Description__c) ? rad.parentPart.part.Quote_Description__c : (String.isNotEmpty(rad.parentPart.part.Description__c) ? rad.parentPart.part.Description__c : (String.isNotEmpty(rad.parentPart.part.Name) ? rad.parentPart.part.Name : ''));
                Decimal aggregatedPriceInclVAT = rad.aggregatedPriceInclVAT;
                Decimal aggregatedNetPrice = rad.aggregatedNetPrice;
                
                if(fitBundle != null) {
                    // construct a description with fitting bundle
                    String fittingBundleName = fittingBundleNameMap.get(fitBundle.parentBundle.Fitting_Pack__c);
                    description += ' (' + fittingBundleName + ') x1';
                    // add the fitting price to the radiator price
                    Decimal fittingBundlePriceInclVAT = fitBundle.aggregatedPriceInclVAT;
                    Decimal fittingBundNetPrice = fitBundle.aggregatedNetPrice;
                    aggregatedPriceInclVAT += fittingBundlePriceInclVAT;
                    aggregatedNetPrice += fittingBundNetPrice;
                }

                // add the radiator along with the fitting bundle               
                LineItem li = new LineItem(description, rad.parentPart.quantity, aggregatedNetPrice, aggregatedPriceInclVAT, rad.parentPart.part.id);
                
                if(rad.parentPart.part.CS_Template_Section_Header__c != null) {
                    if(sectionIdToPartsModelMap.get(rad.parentPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(rad.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                    sectionIdToPartsModelMap.get(rad.parentPart.part.CS_Template_Section_Header__c).add(li);    
                }
            }
        }
    }
    
    public void getSectionPricesFirstPage(Id pcId, List<Section> quoteSections, Map<String,Object> configsData, List<cscfga__Attribute__c> attributeList){
        Boolean firstSectionOnFirstPageAdded = false;
        String cssClass = 'topBorder';

        //Section price summary
        for(Section sec : quoteSections) {
            Decimal totalPrice=0;

            if (sec.lineItems!=null) {
                for (LineItem lin : sec.lineItems){
                    totalPrice+=lin.Total;
                }
            } else if (sec.sections!=null) {
                for (Section ss : sec.sections) {
                    if (ss.lineItems!=null) {
                        for(LineItem liin : ss.lineItems) {
                            totalPrice+=liin.Total;
                        }
                    }
                }   
            }

            if (firstSectionOnFirstPageAdded == false) {        
                firstSectionOnFirstPageAdded = true;
            } else {
                cssClass = '';
            }

            topSummaryTable.add(
                new SummaryTableType(cssClass, 
                                     sec.Name, 
                                     'summary-section', 
                                     totalPrice, 
                                     'section-price right'));
        }
        
        // add Total gross price (inc. VAT)

        topSummaryTable.add(
            new SummaryTableType('', 
                                 'Total gross price (inc. VAT)', 
                                 'summary-section', 
                                 getAttributeValue('Gross Price incl VAT', attributeList), 
                                 'section-price right')); 
          
        addAllowancesToFirstPage(pcId, attributeList, configsData);      
    }
    

    private static String formatPriceWithComma(String value){
        if (value == null || value == '') return '0';
        String formattedPrice = '';
        System.debug('formatPriceWithComma input value: ' + value);
        if(value.indexOf('&pound;')!=-1){

            formattedPrice = value;
        }
        else{
            Decimal dec = Decimal.valueOf(value);
            dec = dec.setScale(2);
            formattedPrice = '£'+String.valueOf(dec.format());
            if(formattedPrice.indexOf('.')==-1){
                formattedPrice+='.00';
            }
            else{
                List<String> partPrice = formattedPrice.split('\\.');
                if(partPrice!=null && partPrice[1].length()==1){
                    formattedPrice+='0';
                }
            }
        }
        
        return formattedPrice;
    }
    
    public static String formatPriceWithCommaDecimal(Decimal value){
        String formattedPrice = '';
        Decimal dec = value.setScale(2);
        formattedPrice = '£'+String.valueOf(dec.format());
        if(formattedPrice.indexOf('.')==-1){
            formattedPrice+='.00';
        }
        else{
            List<String> partPrice = formattedPrice.split('\\.');
            if(partPrice!=null && partPrice[1].length()==1){
                formattedPrice+='0';
            }
        }
        
        return formattedPrice;
    }
    
    public static String formatPriceAsWholeNumber(Decimal value) {
        return '£'+ String.valueOf(value.format());
    }

    public void addAllowancesToFirstPage(Id pcId, List<cscfga__Attribute__c> attributeList, Map<String,Object> configsData) {
        
        List<String> allowanceAttributes = new List<String> {'Allowance1' , 
                                                             'Allowance2', 
                                                             'Allowance3', 
                                                             'Allowance4', 
                                                             'Allowance5', 
                                                             'Allowance6'};

        List<SummaryTableType> summaryTemp = new List<SummaryTableType>();
        string energryAccountRef;
        for(cscfga__Attribute__c allowance : attributeList) {
          //system.debug('@@@@@attribute----->'+allowance);      
            if(allowance.Name == 'Energy Account Ref')
            {
                energryAccountRef =  allowance.cscfga__Value__c;
                //break;
            }
            
            if(allowance.Name == 'Contact Email') // Added 26/11/18
            {
                voucherEmail =  allowance.cscfga__Value__c;
            }
         }
        map<string, decimal> allowanceCodeList = new map <string, decimal>();
        for(String attributeName : allowanceAttributes) {
          
            for(cscfga__Attribute__c allowance : attributeList) {
                if(allowance.Name == attributeName) {
                    if (allowance != null && allowance.cscfga__Value__c != null && allowance.cscfga__Value__c != '') {
                        String isApplied = 'FALSE';
                        String allowanceDesc = '';
                        Decimal allowanceActualValue = 0;
                        string code = '';
                        Id attributeDefinitionId = allowance.cscfga__Attribute_Definition__c;
                        List<cscfga__Attribute_Field__c> allowanceAttributeFields = 
                                (List<cscfga__Attribute_Field__c>) configsData.get(
                                                                pcId + '-' + attributeDefinitionId + '-attributeFields');
                        
                        if (allowanceAttributeFields != null) {
                            for (cscfga__Attribute_Field__c af : allowanceAttributeFields) {
                               
                                /*
                                if (af.Name == 'AllowanceDescription') {
                                    if (af.cscfga__Value__c != null) {
										 allowanceDesc = af.cscfga__Value__c;
										 if(allowanceDesc.contains('Energy £300 Credit'))
										 {
										    isShowTermsConditions = true;
										    showEnergyTC = true;
										    allowanceDesc = allowanceDesc + ' ref:'+energryAccountRef;
										 }
										 
										 // Add 26/11/18 for gift card changes
										 if (allowanceDesc!=null && label.Cloudsense_Gift_Card_T_Cs.contains(allowanceDesc))
										 {
										     isShowTermsConditions = true;
										     showGiftCardAllowanceTC = true;
										 }
										 
									}
                                }*/ if (af.Name == 'Code' && af.cscfga__Value__c!=null) {
                                    
                                        code= af.cscfga__Value__c;
                                    }
                                    else if (af.Name == 'ActualAmount') {
                                    allowanceActualValue = Decimal.valueOf(af.cscfga__Value__c);
                                } else if (af.Name == 'Is_Applied') {
                                    isApplied = af.cscfga__Value__c;
                                } 
                            }
                            
                            
                            if(isApplied == 'TRUE') {
                               /* summaryTemp.add(
                                        new SummaryTableType('', 
                                                            allowanceDesc, 
                                                            'allowance-label', 
                                                            allowanceActualValue, 
                                                            'allowance-value right'));*/
                                                            
                                   allowanceCodeList.put(code, allowanceActualValue) ;                        
                                
                            }
                        }
                    }      
                }
            }   
        }
        
        

        if (allowanceCodeList.size() > 0) {
            tandcs = '';
            for(CS_allowance__c aw : [Select id , Name , Allowance_Code__c, Requires_Billing_Ref__c,	Quote_Description__c , 	T_C_s__c from CS_allowance__c where Allowance_Code__c in :allowanceCodeList.keyset()])
            {
                string description  = aw.Quote_Description__c;
                
                if(aw.Requires_Billing_Ref__c)
                description += ' ref:'+energryAccountRef;
                
                summaryTemp.add(
                                new SummaryTableType('', 
                                                    description, 
                                                    'allowance-label', 
                                                    allowanceCodeList.get(aw.Allowance_Code__c), 
                                                    'allowance-value right'));
                                                    
                if(aw.T_C_s__c!=null)
                {
                    isShowTermsConditions = true;
				    //showEnergyTC = true;
				    tandcs += aw.T_C_s__c.replaceall('brandName',summaryTableHeading);
                }
                
                
            }
            
            topSummaryTable.add(
                    new SummaryTableType('', 
                                         'Our offers for you', 
                                         'boldText slate', 
                                         '', 
                                         'section-price'));
            topSummaryTable.addall(summaryTemp);
            topSummaryTable.add(
                    new SummaryTableType('', 
                                         'Total discount', 
                                         'discount-total boldText', 
                                         getAttributeValue('Total Allowance Value',attributeList), 
                                         'section-total boldText right'));
        }     
        
        

    } 


    public String addAllowancesApplied(Id pcId, List<cscfga__Attribute__c> attributeList, Map<String,Object> configsData){
        
        List<String> allowanceAttributes = new List<String> {'Allowance1' , 'Allowance2', 'Allowance3', 'Allowance4', 'Allowance5', 'Allowance6'};

        String allowancesApplied = '';
        String allowancesAdded = '';
        for(String attributeName : allowanceAttributes) {
            for(cscfga__Attribute__c allowance : attributeList){

                if(allowance.Name == attributeName){
                    if (allowance != null && allowance.cscfga__Value__c != null && allowance.cscfga__Value__c != '') {
                        String isApplied = 'FALSE';
                        String allowanceName = '';
                        Decimal allowanceActualValue = 0;
                        Id attributeDefinitionId = allowance.cscfga__Attribute_Definition__c;
                        List<cscfga__Attribute_Field__c> allowanceAttributeFields = (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+attributeDefinitionId+'-attributeFields');
                        if(allowanceAttributeFields!=null){
                            for (cscfga__Attribute_Field__c af : allowanceAttributeFields) {
                                if (af.Name == 'AllowanceName') {
                                    allowanceName = af.cscfga__Value__c;
                                }
                                else if (af.Name == 'ActualAmount') {
                                    allowanceActualValue = Decimal.valueOf(af.cscfga__Value__c);
                                } 
                                else if (af.Name == 'Is_Applied'){
                                    isApplied = af.cscfga__Value__c;
                                }
                            }
                            if(isApplied == 'TRUE'){
                                allowancesAdded +='<tr class="boldText"><td>'+ allowanceName+'</td><td class="right">' + formatPriceWithCommaDecimal(allowanceActualValue)+ '</td></tr>';
                            }
                        }
                        
                    }      
                }
            }   
        }

        if(allowancesAdded!=''){
            allowancesApplied +='<table style="width:100%;">';
            allowancesApplied +=allowancesAdded;
            allowancesApplied +='<tr class="boldText"><td>Total discount</td><td>'+ formatPriceWithComma(getAttributeValue('Total Allowance Value',attributeList))+ '</td></tr>';
            allowancesApplied +='</table>'; 
        }
        else{
            allowancesApplied +='<p>No allowances applied</p>';
        }
        
        return allowancesApplied;
    } 



    private void getRadiatorLineItems(Map<String, CS_PartModelEntry> partsModelMap, PDFQuoteDetailSection section) {
       
        List<RadiatorItem> radItems = addRadiators(partsModelMap);
        
        if (radItems != null && radItems.size() != 0) {
             List<RadiatorLineItem> radLineItems = getRadiatorSection(radItems);
             if(radLineItems != null){
                createRadSection(radLineItems, section);
             }
        }
      
    }
    
    public List<RadiatorItem> addRadiators(Map<String, CS_PartModelEntry> partsModelMap) {
        List<RadiatorItem> radValves = new List<RadiatorItem>();
        if (partsModelMap != null) {
            for (String key : partsModelMap.keySet()) {
                CS_PartModelEntry item = partsModelMap.get(key);
                if (   key.contains('Placeholder_0'      )  // Product definition: Radiator
                    ||  key.contains('Actual_Radiator_1_0') // Product definition: Radiator
                    || ( key.contains('Actual_Radiator')  && key.contains(':Radiator_0' ) ) ) {
                        
                    System.debug('****CS: is radiator or placeholder'); 
                    System.debug('****Item ' + item);            
                    String indexKey = key.split(':')[0];
                    String valveKey = indexKey+':'+'Radiator_Valve_0';         
                    String fittingBundleKey = indexKey+':'+'Fitting_Bundle_0';

                    String radPrice = String.valueOf(item.aggregatedPriceInclVAT);
                   
                    String radCategory = item.parentPart.part.Radiator_Category__c;
                   
                    System.debug('****radPrice ' + radPrice);       
                    System.debug('****radCategory ' + radCategory);

                    CS_PartModelEntry valve = partsModelMap.get(valveKey);
                    CS_PartModelEntry fittingBndl = partsModelMap.get(fittingBundleKey);

                    Decimal summaryRadPrice = 0.0; // here we'll put radiator price with fitting bundle and radiator valve price

                    
                    Decimal valvePrice         = valve       == null ? 0.0 : valve.aggregatedPriceInclVAT;
                    Decimal fittingBundlePrice = fittingBndl == null ? 0.0 : fittingBndl.aggregatedPriceInclVat;

                    summaryRadPrice = item.aggregatedPriceInclVAT + valvePrice + fittingBundlePrice;
                    String radInclValve = valve == null ? '' : 'inc. valves';
                     
                    radValves.add(new RadiatorItem(radInclValve, radCategory, String.valueOf(summaryRadPrice)));

                }
            }  
        }
        
        System.debug('****radValves ' + radValves); 
        return radValves;
    }

 
 
    public List<RadiatorLineItem> getRadiatorSection(List<RadiatorItem> radItems) {
       
        List<RadiatorLineItem> radLineItems = new List<RadiatorLineItem>();
        
        for(RadiatorItem radItem : radItems){
            if (radItem != null) {
                RadiatorLineItem radLineItem;
                Integer seq = 0;
                String description ='';
                Integer quantity = 0;
                String incValves ='';
                System.debug('**** radItem: ' + radItem);
                if(radItem.Category == 'L'){
                    description = 'Large';
                    seq = 3;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'M'){
                    description = 'Medium';
                    seq = 2;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'S'){
                    description = 'Small';
                    seq = 1;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'LST'){
                    description = 'Low Surface Temp';
                    seq = 5;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'XL'){
                    description = 'Extra Large';
                    seq = 4;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'Towel Warmer'){
                    description = 'Towel Warmer';
                    seq = 6;
                    incValves = radItem.IncValve;
                }
                else if(radItem.Category == 'Designer'){
                    seq = 7;
                    description = 'Designer';
                    incValves = radItem.IncValve;
                }
                Decimal price = Decimal.valueOf(radItem.price);
                radLineItem = new RadiatorLineItem(description, quantity, seq, price, incValves);
                radLineItems.add(radLineItem);
            } else {
                radLineItems.add(new RadiatorLineItem('Radiator missing', 0, 8, 0.0, 'N/A'));
            }
        }
        return radLineItems;

    }

    public void createRadSection (List<RadiatorLineItem> radItems, PDFQuoteDetailSection section) {

       Map<String, RadiatorLineItem> aggregatedItems = new Map<String, RadiatorLineItem>();
             
       for (RadiatorLineItem radItem : radItems) {          
            RadiatorLineItem currentItem = aggregatedItems.get(radItem.Description);
            if (aggregatedItems.get(radItem.Description) != null) {
                currentItem.Price += radItem.Price;
                currentItem.Quantity += 1;
            } else {
                radItem.Quantity = 1;
                aggregatedItems.put(radItem.Description, radItem);  
            }   
        }

        List<RadiatorLineItem> sortedRads = new List<RadiatorLineItem>();

        for (RadiatorLineItem radVal : aggregatedItems.values()) {
            sortedRads.add(radVal);
        }

        sortedRads.sort();

        for(RadiatorLineItem radVal : sortedRads) {
            PDFQuoteLineItem li = new PDFQuoteLineItem(radVal.Description + ' Radiator ' + radVal.IncValve,
                                            radVal.Quantity, 
                                            formatPriceWithCommaDecimal(radVal.Price), null);                               
            section.items.add(li);
        }

    }
    
    private void configAttributes(Map<Id, Map<String, cscfga__Attribute__c>> configAttributesMap, List<cscfga__Attribute__c> allAttributes) {
        for (cscfga__Attribute__c att : allAttributes) {
            if (!configAttributesMap.containsKey(att.cscfga__Product_Configuration__c)) {
                configAttributesMap.put(att.cscfga__Product_Configuration__c, new Map<String, cscfga__Attribute__c> {att.Name => att});
            }
            else {
                configAttributesMap.get(att.cscfga__Product_Configuration__c).put(att.Name, att);
            }
        }
        
    }
    
    private Map<Id, Attachment> getConfigAttachmentMap(Set<Id> basketIds) {
        List<Attachment> attachmentList = [SELECT Id, Name, Body, ParentId FROM Attachment where ParentId in :basketIds and Name = 'partsModel.txt'];
                        
        Map<Id, Attachment> configAttachmentMap = new Map<Id, Attachment>();
        
        for (Attachment doc : attachmentList) {
            configAttachmentMap.put(doc.ParentId, doc);
        }
        
        return configAttachmentMap;
        
    }
    
    private void fillFromProductConfig(Map<Id, Map<String, cscfga__Attribute__c>> configAttributesMap, cscfga__Product_Basket__c basket, Set<Id> basketIds, Map<String,Object> configsData) {
        
        for(Id pcId : basketIds) {
            Map<String, cscfga__Attribute__c> attributeMap = configAttributesMap.get(pcId);
            System.debug('AttributeMap: ' + attributeMap);
            List<cscfga__Attribute__c> configAttributeList = (List<cscfga__Attribute__c>)configsData.get(pcId +'-attributes');
            System.debug('AttributeList: ' + configAttributeList);
            
            //AaJSON
            //get Attribute values
            
            //2017
            inputQuoteData.customerName  = basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name;
            System.debug('inputQuoteData.customerName: ' + inputQuoteData.customerName);

            inputQuoteData.installationAddress  = basket.Appointment__r.Opportunity__r.Install_Address_Street__c;
            installationPostcode  = basket.Appointment__r.Opportunity__r.Install_Postcode__c;
            
            //2017
            inputQuoteData.billingPostcode  = basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode;
            billingAddress  = basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet;
            inputQuoteData.billingCounty  = basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingState;
            
            inputQuoteData.allowancesApplied  = addAllowancesApplied(pcId, configAttributeList, configsData);
            System.debug('inputQuoteData.allowancesApplied: ' + inputQuoteData.allowancesApplied);

            inputQuoteData.chi_lead_created_date = basket.Appointment__r.Opportunity__r.CreatedDate;

            //2018
            Decimal vatRate = decimal.valueOf(getAttributeValue('Allowance VAT', configAttributeList));
            Decimal totalNetPrice = decimal.valueOf(getAttributeValue('Total Net Price', configAttributeList));
            String totalAllowance = getAttributeValue('Total Allowance Value', configAttributeList);
            Decimal totalAllowancesNet = 0;
            if (totalAllowance != '') {
                totalAllowancesNet = decimal.valueOf(totalAllowance)/(1+vatRate/100);
            }
            totalNetPrice = totalNetPrice-totalAllowancesNet;
            
            Decimal actualDeposit = decimal.valueOf(getAttributeValue('Actual Deposit', configAttributeList));
            inputQuoteData.deposit  = formatPriceWithComma(String.valueOf(actualDeposit));
            inputQuoteData.totalNetPrice = formatPriceWithComma(String.valueOf(totalNetPrice));
            totalPricePayable  = formatPriceWithComma(getAttributeValue('Total Price Payable', configAttributeList));
            depositNumber  = formatPriceWithComma(getAttributeValue('Deposit Receipt Number', configAttributeList));
            inputQuoteData.deposit = getAttributeValue('Actual Deposit',configAttributeList);
            inputQuoteData.depositPaidBy  = getAttributeValue('Payment Type', configAttributeList);
            inputQuoteData.balance = formatPriceWithComma(String.valueOf(returnDecimal(getAttributeValue('Total Price Payable', configAttributeList)) - returnDecimal(getAttributeValue('Actual Deposit', configAttributeList))));
            inputQuoteData.balanceToBePaidBy  = getAttributeValue('Payment Option', configAttributeList);
            
            inputQuoteData.quoteDate = getCorrectDateFormat(getAttributeValue('Quote Creation Date', configAttributeList));
            inputQuoteData.quoteRef  = getAttributeValue('CHI Lead Number', configAttributeList);
            boilerPlusReason        = getAttributeValue('Boiler Plus Reason', configAttributeList);
            inputQuoteData.quoteNumber = getAttributeValue('Quote Reference', configAttributeList);
            inputQuoteData.jobRole = 'Role: ' + getAttributeValue('Identity Job Role', configAttributeList);

            //2017
            blueBallonPrice  = formatPriceWithComma(getAttributeValue('Total Price Payable', configAttributeList));//'£'+getAttributeValue('Total Net Price', configAttributeList);
            
            //2018
            String pricebookValue = getAttributeValue('Pricebook Type', configAttributeList);
            Boolean isSmallCommercialQuote = pricebookValue != null ? (pricebookValue == CS_Constants.CS_PricebookType_SmallCommercial ? true : false) : false;
            String priceExcVAT = null;
            inputQuoteData.totalPriceExcVat = null;
            
            if(isSmallCommercialQuote) {
                priceExcVAT = String.valueOf(totalNetPrice);
                inputQuoteData.totalPriceExcVat = inputQuoteData.totalNetPrice;
            }

            //2017
            summaryTableFooter = returnSummaryTableFooter(getAttributeValue('Total Price Payable', configAttributeList), priceExcVAT);
            System.debug('summaryTableFooter: ' + summaryTableFooter);

                    
            Decimal amount = getAmount(configAttributeList);
            
            Map<Id, Attachment> configAttachmentMap = getConfigAttachmentMap(basketIds);
               
            System.debug('**** Got attachment '+configAttachmentMap.size());
                    
            List<Section> quoteItems =  buildQuote(configAttachmentMap.get(pcId), attributeMap, configAttributeList,configsData, pcId);
            
            
            System.debug('***Quote Items: ' + quoteItems);
            System.debug('***Config attachment map: ' + configAttachmentMap); 

            
            //leftTableQuoteBreakdown = getLeftQuoteBreakdownTable(quoteItems,configAttachmentMap.get(pcId));
            
            // createQuoteDetailData creates hierachical representation of line items with sections
            // inside a property pdfQuoteDetail which will be used by visualforce view to display those line items       
            createQuoteDetailData(quoteItems, configAttachmentMap.get(pcId));
            
            getSectionPricesFirstPage(pcId,quoteItems, configsData, configAttributeList);
            
           
        
            list<CS_Promotion_Dates__c> ifcPromotions = new list<CS_Promotion_Dates__c>();
            list<CS_Promotion_Dates__c> defaultPromotions = new list<CS_Promotion_Dates__c>();
             if (inputQuoteData.chi_lead_created_date != null)
             {
                for(CS_Promotion_Dates__c s: CS_Promotion_Dates__c.getAll().values())
                {
                    if(s.Active__c && s.APR__c  == 0.0)
                    {
                        ifcPromotions.add(s);
                    }else if(s.Active__c)
                    {
                        defaultPromotions.add(s);

                    }
                }
             }
             /*
             is_ifc_active = false;
             for(CS_Promotion_Dates__c ifc : ifcPromotions)
             {
                System.debug('////Raw chi_lead_created_date: ' + inputQuoteData.chi_lead_created_date);
                     // determine interest free loan start and end dates from custom settings
                Date ifc_date_start = ifc.Start_Date__c;
                Date ifc_date_end = ifc.End_Date__c;
                Date ifc_date_final = ifc.Final_Date__c;
                Date leadCreatedDate = Date.newInstance(inputQuoteData.chi_lead_created_date.year(),
                                            inputQuoteData.chi_lead_created_date.month(),
                                            inputQuoteData.chi_lead_created_date.day());
                Date quoteDate =  Date.newInstance(quoteCreatedDate.year(), quoteCreatedDate.month(), quoteCreatedDate.day());
                System.debug('////IFC Start date: ' + ifc_date_start);
                System.debug('////IFC End date  : ' + ifc_date_end);
                System.debug('////Quote date    : ' + quoteDate);
                System.debug('////CHI Lead c.dt.: ' + leadCreatedDate);

                is_ifc_active = (quoteDate >= ifc_date_start && 
                                 quoteDate <= ifc_date_final &&
                                 leadCreatedDate <= ifc_date_end);
                System.debug('////IFC quote will be shown? ' + is_ifc_active);
                if(is_ifc_active)
                break;


             }
             */
             aprDecimal = 0.079;
             aprused = '7.9%';
             if(!isSmallCommercial)
             for(CS_Promotion_Dates__c dp : defaultPromotions)
             {
                System.debug('////Raw chi_lead_created_date: ' + inputQuoteData.chi_lead_created_date);
                     // determine interest free loan start and end dates from custom settings
                Date dp_date_start = dp.Start_Date__c;
                Date dp_date_end = dp.End_Date__c;
                Date dp_date_final = dp.Final_Date__c;
                Date leadCreatedDate = Date.newInstance(inputQuoteData.chi_lead_created_date.year(),
                                            inputQuoteData.chi_lead_created_date.month(),
                                            inputQuoteData.chi_lead_created_date.day());
                Date quoteDate =  Date.newInstance(quoteCreatedDate.year(), quoteCreatedDate.month(), quoteCreatedDate.day());
                System.debug('////IFC Start date: ' + dp_date_start);
                System.debug('////IFC End date  : ' + dp_date_end);
                System.debug('////Quote date    : ' + quoteDate);
                System.debug('////CHI Lead c.dt.: ' + leadCreatedDate);

                if(quoteDate >= dp_date_start && 
                   quoteDate <= dp_date_final &&
                   leadCreatedDate <= dp_date_end)
                {
                    aprDecimal = dp.APR__c*0.01;
                    aprused = string.valueof(dp.APR__c)+'%';
                }

                system.debug('APR Decimal-->'+aprDecimal+' '+dp.APR__c);

             }
            
            totalPriceA  = formatPriceWithComma(getAttributeValue('Total Price Payable', configAttributeList));//'£'+getAttributeValue('Total Price Payable', configAttributeList);
            depositB  = formatPriceWithComma(getAttributeValue('Actual Deposit', configAttributeList));//'£'+getAttributeValue('Actual Deposit', configAttributeList);
            Decimal loan = returnDecimal(getAttributeValue('Total Price Payable', configAttributeList))  - returnDecimal(getAttributeValue('Actual Deposit', configAttributeList)); 
            loanAmountAB  = formatPriceWithCommaDecimal(loan);//'£'+loan;
            
            if(loan!=null && loan >=1000)
            showYourPayOptions = true;
            
            
            
            inputQuoteData.mmp_2  = returnPaymentMonthly(amount, 2, 0);
            inputQuoteData.mmp_3  = returnPaymentMonthly(amount,3, aprDecimal);
            inputQuoteData.mmp_5  = returnPaymentMonthly(amount,5,aprDecimal);
            inputQuoteData.mmp_8  = returnPaymentMonthly(amount,8, aprDecimal);
            inputQuoteData.mmp_10  = returnPaymentMonthly(amount,10, aprDecimal);
    
            greenBallonPrice  = inputQuoteData.mmp_10;//formatPriceWithComma(getAttributeValue('Total Net Price', configAttributeList));

            //inputQuoteData.tar_2  = returnTotalAmount(amount + Decimal.valueOf(depositB.substring(1)), 2);
            inputQuoteData.tar_2  = returnTotalAmount(amount,2, 0);
            inputQuoteData.tar_3  = returnTotalAmount(amount,3, aprDecimal);
            inputQuoteData.tar_5  = returnTotalAmount(amount,5, aprDecimal);
            inputQuoteData.tar_8  = returnTotalAmount(amount,8, aprDecimal);
            inputQuoteData.tar_10  = returnTotalAmount(amount,10, aprDecimal);
    
        }
        
    }
    
    private Decimal getAmount(List<cscfga__Attribute__c> configAttributeList) {
        Decimal amount = 0;
        
        if (    returnDecimal( getAttributeValue('Total Price Payable', configAttributeList) )  > 0 
            &&  returnDecimal( getAttributeValue('Actual Deposit', configAttributeList) )       > 0) {
                
            amount = returnDecimal( getAttributeValue('Total Price Payable', configAttributeList) ) 
                        - returnDecimal( getAttributeValue('Actual Deposit', configAttributeList) );
                        
        } else if ( returnDecimal(totalPricePayable) == 0 
                    && returnDecimal( getAttributeValue('Actual Deposit', configAttributeList) ) > 0) {
                        
            amount = - returnDecimal( getAttributeValue('Actual Deposit', configAttributeList) );
            
        } else if ( returnDecimal( getAttributeValue('Total Price Payable', configAttributeList) ) > 0
                && returnDecimal( getAttributeValue('Actual Deposit', configAttributeList) )     == 0 ) {
                    
            amount = returnDecimal( getAttributeValue('Total Price Payable', configAttributeList) );
            
        } else {
            amount = 0;
        }
        
        return amount;
    }

	 public PageReference displayPDF(){
        
        Attachment att;

		// check if there already is attachment 

		// there are two cases:
		// (1) The quote is being generated after the basket is created
		// (2) The quote is being generated before the basket is created

		// case (1): we have basket ID so we'll use it as attachment parent id
		// first check if there already is some html attachment (there shouldn't be, but if there is, we'll overwrite it)
		// ultimately it doesn't matter which parent id we'll use, because we'll send the actual attachment ID to the 
		// actual PDF rendering page

		Id parentId;
		// we know that we are generating pdf before attachment by the fact we have oppId set (see line 379)
		if (oppId != null) {
			parentId = oppId;
		// otherwise we have a basket
		} else {
			parentId = basketId;
		}

		List<Attachment> attList = 	[SELECT Id, Name, Body, ParentId 
										FROM Attachment 
										WHERE ParentId = :parentId 
										AND Name = :TEMP_ONLINE_QUOTE_ATT_NAME];
		
		// If there is no attachment, create one
        if(attList.size() > 0) {
            att = attList[0];
        } else {
            att = new Attachment();
            att.ParentId = parentId;
        }

        att.Body = Blob.valueOf(pageContent);
        att.Name = TEMP_ONLINE_QUOTE_ATT_NAME;
        upsert att;

		String footerCode = summaryTableHeading == 'British Gas' ? 'BG': 'SG';
       
        PageReference pr = new PageReference('/apex/CS_QuoteOnlineActualPdf');
        pr.getParameters().put('pageAttId', att.id);
		pr.getParameters().put('quoteRef', inputQuoteData.quoteNumber);
		pr.getParameters().put('footerCode', footerCode);
        pr.setRedirect(true);
        return pr;
    }
    
    private void getDataFromJson() {    
        if(attList.size() > 0) {
            Attachment a = attList[0];
            if (a != null) {
                String content = a.body.toString();
                
                inputQuoteData = (AllQuoteData) JSON.deserialize(content, AllQuoteData.class);   
                
                // some fields are not 1-to-1 between JS code and this class. remap them
                remapInputFieldsToProperties();
                setTradeBrand(inputQuoteData.tradeName);
                
                // these two are derived fields
                summaryTableFooter = returnSummaryTableFooter(inputQuoteData.totalNetPrice, inputQuoteData.totalPriceExcVat);
                topSummaryTable = inputQuoteData.sectionPrices;


                // clean up ampersand escapes
                for (SummaryTableType stt : topSummaryTable) {
                    stt.replaceEscapes();
                }

                System.debug(topSummaryTable);

                // transform "JS Sections" to classes more suitable for html render             
                List<Section> transformedSections = transformSections(inputQuoteData.breakdownQuoteTable.Sections);
   
                Map<String, CS_PartModelEntry> partsModelMap = (Map<String, CS_PartModelEntry>)JSON.deserialize(inputQuoteData.partsModel, Map<String, CS_PartModelEntry>.class);
                
                createQuoteDetailData(transformedSections, partsModelMap);
            }
        }
    }
    
    
    private void remapInputFieldsToProperties() {
        installationPostcode = inputQuoteData.billingPostcode;
        totalPricePayable = inputQuoteData.waysToPayTotalAmount;
        greenBallonPrice = inputQuoteData.minMonthlyTotal;
        blueBallonPrice = inputQuoteData.ballonTotalPrice;
        depositB = inputQuoteData.illustrationDeposit;
        loanAmountAB = inputQuoteData.illustrationLoanAmount;
        billingAddress = inputQuoteData.billingStreet;
        depositNumber = inputQuoteData.depositReceiptNumber;
        totalPriceA = inputQuoteData.illustrationTotal;
        hsaNumber = inputQuoteData.hsaContactNumber;
        
    }
    
    
    /**
    *
    *  Transforms QBT* classes to Section/LineItems classes
    */
    private static List<Section> transformSections(List<QBTSection> qbtSections) {
        List<Section> ret = new List<Section>();
        
        for (QBTSection qbts : qbtSections) {
            Section sect = new Section(qbts.id, qbts.Header, qbts.Sequence);
            if (qbts.SubTotal.length() > 0) {  // if there is a subtotal on the root section, we add new line item with name as "Text" and 
                sect.addLineItem(new LineItem(qbts.Text, 1, convertPoundAmountToDecimal(qbts.SubTotal), convertPoundAmountToDecimal(qbts.SubTotal), qbts.Id));                          
            }
            if (qbts.Products != null) {
                for (QBTProduct qbtp : qbts.Products) {
                    
                    Section lvl2Sect = new Section(qbtp.id, qbtp.Description, qbts.Sequence);
                    
                    sect.addSection(lvl2Sect); // we don't get sequence from JS, so we'll use qbts.Sequence as a placeholder
                    
                    if (qbtp.LineItems != null) {
                        for (QBTLineItem qbtLi : qbtp.LineItems) {
                            lvl2Sect.addLineItem(new LineItem(qbtLi.Description, 
                                                                convertDirtyStringToDec(qbtLi.Quantity), 
                                                                convertPoundAmountToDecimal(qbtLi.Price), 
                                                                convertPoundAmountToDecimal(qbtLi.Total), 
                                                                qbtLi.id));
                        }
                    }
                    
                }
            }
            
            ret.add(sect);
        }
        
        return ret;
    }
    
    private void setTradeBrand(String tradeName) {
        if(tradeName =='Scottish Gas'){
            logoBG = false;
            summaryTableHeading = 'Scottish Gas';
        } else {
            logoBG = true;
            summaryTableHeading = 'British Gas';
        }
    } 
    
    private static Decimal convertPoundAmountToDecimal(String input) {
        return Decimal.valueOf(input.substringAfter('&pound;'));
    }
    
    private static Decimal convertDirtyStringToDec(String input) {
        return Decimal.valueOf(input.replaceAll('[^0-9]', ''));
    }

}