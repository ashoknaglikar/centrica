/*
    Type Name:      Class NBBSInterfaceController
    Author:         Cognizant
    Created Date:   04/29/2010
    Reason:         Centrica Phase 5 - NBBS Integration
    Change History: 
    Author: Cognizant
    Modified Date: 05/28/2010
    Modified Date: 06/02/2010
    Modified Date: 06/15/2010
    Reason:To display the information being sent to Nbbs in different visual force page 'NbbsInterfaceDisplayPage.page'
    Modified Date: 06/23/2010 
    Reason: Modified the query to retreive diary entries whose employee Group Code = 'INST'
    Reason: Modified to update the formula for Billing on 3rd modification.
    Modified Date: 06/26/2010 
    Reason: Modified to incorporate Client comments: user should be able to view contingency screen if the platform is 'Premier'.
    Modified Date: 07/06/2010 
    Modified Date: 07/08/2010  
    Reason: Added ServiceLineInformation() getter method and class ServiceLineData for Billing Contingency screen.
    Modified Date: 07/09/2010 
    Reason: removed the Installed Job checked, means even if Job is not Installed users can send the lead for billing. Also another method is change 
    which was fetching the highest installation date of the Job, but now it will fetch the Lowase installtion date of the Job because maybe another
    job installtion date will be in future so NBBS will reject the file.
    System.Label.Hitachi_Billing_Post_code
    Modified date: 27/09/2010
    Reason: Removing the status change of the Big Machine Quote. Initially when anybody bill the lead, status of the Big Machine is changed from 'Quote-Finalized Accepted' to 'Awaiting Billing'
    Business has discard the requirement number BRS-34 and BRS-35. INstead of changing the Status we are checking a checkbos in the Quote.*/
    
public class NBBSInterfaceController 
{
    public String QuoteId{get; set;}
    
    public Boolean IsError{get; set;}
    public String DisplayMessage{get; set;}
    public Boolean IsConfirmed{get; set;}
    public Boolean isPlatformSFDC{get; set;}
    private List<Id> quoteIdList = new List<Id>{};
    private List<String> billingStatus = new List<String>{};
    public Installation_Billing__c newInstallationBilling = new Installation_Billing__c();
    private Map<Id,List<String>> billingOutputList=new Map<Id,List<String>>{};
    private list<Job_Description_Record__c> lstJobDescriptionRecord = new list<Job_Description_Record__c>{};
    private Map<ID, NIASCodeHelper.NIASCode> quoteNIASMap = new Map<ID, NIASCodeHelper.NIASCode>{};
    private List<Installation_Billing__c> newInstallationBillingList;
    private Map<String,Decimal> vatcode = new Map<String,Decimal>();
    private Map<string, Decimal> oldvatBands = new Map<string, Decimal>();
    private Map<string, Decimal> newvatBands = new Map<string, Decimal>();
    public Boolean blMultiple{get; set;}
    public Decimal firstValue;
    public Decimal Value;
    public Decimal newvalue;
    public boolean hideservicecodeL {get;set;}
    public boolean hideservicecodeD {get;set;}
    public Decimal newVat1;
    public Decimal newVat4;
    public Decimal oldVat1;
    public Decimal oldVat4;
    public boolean newchange = false;
    public boolean nochange = false;
    public Integer Districtiden;
    public String BillType{get;set;} // Added new else condition for manual billing for Payment team.
    private Boolean isView = false;
    private Boolean isValid = false;
    public string billperiod;
    public Double newisdifference;
    public Decimal newmismatch;
    private Map<Id,String> checkBillTotalMap =new Map<Id,String>{};
    private Boolean isBillingTotal = false;
    public Double VATAMOUNT{get; set;}
    public Double  SubTotalDisp{get; set;}
    public Double  SubnewTotalDisp{get; set;}
    public Double  SumVatAmount{get; set;}
    public Double  SumnewVATAmount{get;set;}
    public Double  SumDiscount{get; set;}
    public Double  SumnewDiscount{get; set;}
    public Double  BillTotal{get; set;}
    public Double  NewBillTotalshow{get; set;}
    public string defaultPlatform = System.Label.Default_Platform;
    public List<Job__c> lst_jobs = new List<Job__c>{};
    public final String SUSPENDED = 'Suspended';
    public final String CLOSEDLOST = 'Closed Lost';
    public static boolean checksystem;//Added for Quote/Quote Product Issue.
    public String overwritestring = System.Label.VAT_Change_Date;
    public Date overwrite = date.valueOf(overwritestring);
    public boolean newVATselected;
    public boolean newVATselecteddis;
    public Decimal newVAT1Amount = 0.0;
    public Decimal oldVAT1Amount = 0.0;
    public Decimal newfirstvalue = 0.0;
    public Decimal oldfirstvalue = 0.0;
    public Decimal oldbilltotal;
    public Decimal newbilltotal;
    public Date billingoverride;
    
    //This class is used to display toal Amounts : Subtotal,Discount and VAT RAtes of Job Description records created when data is inserted
    //This information is displayed in Billing Contingency Screen : NbbsInterfaceDisplayPage.page
    public class ServiceLineData{
        public Job_Description_Record__c JobDescriptionBlock {get; set;}
        public Double  VatAmount{get; set;}
        public Double  DiscountDisp{get; set;}
        public Double  VatRate{get; set;}
        public Double  SubTotal{get; set;}      
        public Boolean ShowDiscount{get; set;}
        public Boolean ShowVatAmount{get; set;}
        public Boolean ShowVatRate{get; set;}
        public boolean hideservicecode {get;set;}
   }
    
    public list<Job_Description_Record__c> getlstJobDescriptionRecord(){
        system.debug('---->lstJobDescriptionRecord123'+lstJobDescriptionRecord);
        return lstJobDescriptionRecord;
    }
    
    public NIASCodeHelper.NIASCode getQuoteNIASCode(){
        List<NIASCodeHelper.NIASCode> niascodes = quoteNIASMap.values();
        return niascodes[0];
    }
    
    public Installation_Billing__c getnewInstallationBilling(){
        //if(!IsError)
        if(newInstallationBillingList.size() > 0)
            return newInstallationBillingList[0];
        else 
            return null;
    }

    public NBBSInterfaceController(){
      /**************************************************Added for VAT change**************************************************
      
      *************************************************************************************************************************/
     
      List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,VAT_Code_4_Rate__c,VAT_Code_3__c,Status__c,start_date__c,
                                    VAT_Code_3_Rate__c,end_date__c,VAT_Code_2_Rate__c,VAT_Code_2__c,VAT_Code_1_Rate__c from VAT_Codes__c];
                                    
      system.debug('overwrite-->'+overwrite);
      system.debug(lstVAT); 
                                   
                                    
       for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        newvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        newvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
                
            }else if (objvat.start_date__c <overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        oldvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        oldvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
            }
       }
       newVat1 = (newvatBands.get('1'))/100;
       newVat4 = (newvatBands.get('4'))/100;
       if(oldvatBands.size()>1)
       {
       oldVat1 = (oldvatBands.get('1'))/100;
       oldVat4 = (oldvatBands.get('4'))/100;
       }
       system.debug('newvatBands-->'+newvatBands);
       system.debug('oldvatBands-->'+oldvatBands);
      /**********************************************Ending Here**********************************************************************/   
        blMultiple=false;
       //Retrieve the CHI Lead id from the URL
        String leadID = System.currentPageReference().getParameters().get('s');
        
        if(System.currentPageReference().getParameters().get('t') != null)
            isView = true;
            IsError = false;
        system.debug('------------------------------ isView -->' + isView);
        IsConfirmed = false;

        //Check if CHI Lead id was provided or not 
        if(leadID != null && leadID.trim() != '')
        {
            /** Retrieve Oppportunities & Quotes based on the CHILead Id. 
            Quotes should be of status "Quote Finalised - Accepted"
            and should be the primary quote for the CHI Lead */

             // modified for read only (Check billing)
            List<Opportunity> lstOpportunities ;
            if(isView){
                lstOpportunities = [Select Platform__c, StageName ,(Select id From BigMachines_Quotes__r where Is_Primary__c = true) From Opportunity where id =:leadID];
            }
            else{
                lstOpportunities = [Select Platform__c, StageName,(Select id,Billed__c From BigMachines_Quotes__r where Stage__c = 'Quote Finalised - Accepted' 
                                and Is_Primary__c = true and Billed__c = false) From Opportunity where id =:leadID];
            }
            system.debug('testing   --->'+lstOpportunities);
            system.debug('lstOpportunities.size   --->'+lstOpportunities.size());
                    
            /** Checks if Opportunity & Quote exists for the CHI lead for which the user wants to do billing. 
            If no data exists, display error messages */
            if(lstOpportunities != null && lstOpportunities.size() > 0)
            {   
                /* As planned for Centrica Phase V Parallel Running of SFDC and Premier - if the platform value in CHI Lead is 
                   'Premier', then we should not send the Lead for Billing. So modified the code to put a check for the field value
                    and display error as "Job is being processed in Premier"
                    
                */
                system.debug('testing   --->'+lstOpportunities);
                system.debug('---paltform' +defaultPlatform);
                /***************************Changed the below condition to handle the below scenario:*****************************
                *************************If there is a TYPO error in the Label for the platform, then default should go for Premier, 
                ********************************not SFDC****************************************************************************/     
                    if(((lstOpportunities[0].Platform__c == null && defaultPlatform  != 'SFDC') || lstOpportunities[0].Platform__c != 'SFDC') && isView == true)
                    {
                        if(lstOpportunities[0].BigMachines_Quotes__r != null && lstOpportunities[0].BigMachines_Quotes__r.size() > 0)
                            quoteIdList.add(lstOpportunities[0].BigMachines_Quotes__r[0].id);
                        else
                            setMessage(true, 'No billable quote exist for selected Lead.');
                    } 
                    
                    system.debug('---paltform' +defaultPlatform );
                    //if(lstOpportunities[0].Platform__c != 'Premier' && lstOpportunities[0].Platform__c != null)
                     /*Changed the condition to handle the below scenario:
                                If there is a TYPO error in the Label for the platform, then default should go for Premier, not SFDC
                      */ 
                    //if((lstOpportunities[0].Platform__c == null && defaultPlatform  != 'Premier') || lstOpportunities[0].Platform__c != 'Premier')
                    if((lstOpportunities[0].Platform__c == null && defaultPlatform  == 'SFDC') || lstOpportunities[0].Platform__c == 'SFDC'){ 
                        if(lstOpportunities[0].BigMachines_Quotes__r != null && lstOpportunities[0].BigMachines_Quotes__r.size() > 0){
                            quoteIdList.add(lstOpportunities[0].BigMachines_Quotes__r[0].id);
                            system.debug('inside loop----');
                        }
                        else
                            setMessage(true, 'No billable quote exist for selected Lead.');          
                    }
                    else{
                        if(!isView){
                            isPlatformSFDC = True;
                            setMessage(true, 'Job is being processed in Premier');
                        }
                    }
                 }
            else{
                setMessage(true, 'No quote data found. Please try again or contact Installationforce Administrator');
            }
        }
        else{
            setMessage(true, 'Invalid data. Please try again or contact Installationforce Administrator');
        }
    }

    /*
    Code added By Avishek
    This constructor of the class takes in a list of opportunity and processes them to find the BIG Machines Quote 
    and insert data in the Billing objects
    */
    public NBBSInterfaceController(List<Opportunity> opportunityList) {
                
        blMultiple=true;
              
      /**************************************************Added for VAT change**************************************************
      
      *************************************************************************************************************************/
      
      List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,VAT_Code_4_Rate__c,Status__c,start_date__c,
                                    end_date__c,VAT_Code_1_Rate__c from VAT_Codes__c];
       for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        newvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        newvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
                
            }else if (objvat.start_date__c <overwrite){
                if(objvat.VAT_Code_1__c !=null)
                        oldvatBands.put(objvat.VAT_Code_1__c, objvat.VAT_Code_1_Rate__c);
                if(objvat.VAT_Code_4__c !=null)
                        oldvatBands.put(objvat.VAT_Code_4__c, objvat.VAT_Code_4_Rate__c);
            }
       }
       newVat1 = (newvatBands.get('1'))/100;
       newVat4 = (newvatBands.get('4'))/100;
       oldVat1 = (oldvatBands.get('1'))/100;
       oldVat4 = (oldvatBands.get('4'))/100;
       system.debug('newvatBands-->'+newvatBands);
       system.debug('oldvatBands-->'+oldvatBands);
      /**********************************************Ending Here**********************************************************************/  
      
      Set<Id> opportunityIdSet=new Set<Id>{};
      IsConfirmed = false;
      isPlatformSFDC = false;
        if (opportunityList!=null && opportunityList.size()>0) 
        {
            for (Opportunity objOpportunityId:opportunityList){
                opportunityIdSet.add(objOpportunityId.Id);
            }
            /**
            Retreives Opportunities & Quotes based on the Opportunity Ids provided in the List.
            Quotes of status "Quote Finalized - Accepted" and it is the primary quote related with the CHI Lead
            **/
            
            if(isView){
                opportunityList = [Select Id,  StageName,(Select id from  BigMachines_Quotes__r where Is_Primary__c = true) From Opportunity where id IN:opportunityIdSet];
            }
            else{
                opportunityList = [Select Id,Platform__c, StageName, (Select id,Billed__c From BigMachines_Quotes__r where Stage__c = 'Quote Finalised - Accepted' 
                                and Is_Primary__c = true and Billed__c = false) From Opportunity where id IN:opportunityIdSet];
            }
            for (Opportunity opportunityObj:opportunityList)
            {
            /* As planned for Centrica Phase V Parallel Running of SFDC and Premier - if the platform value in CHI Lead is 
                   'Premier', then we should not send the Lead for Billing. So modified the code to put a check for the field value
                    and display error as "Job is being processed in Premier"
            */
                system.debug('---paltform' +defaultPlatform );
                if((opportunityObj.Platform__c == null && defaultPlatform  == 'SFDC') || opportunityObj.Platform__c == 'SFDC'){
                        system.debug('inside loop----');
                        billingStatus=new List<String>{};
                        if(opportunityObj.BigMachines_Quotes__r != null && opportunityObj.BigMachines_Quotes__r.size() > 0){
                            quoteIdList.add(opportunityObj.BigMachines_Quotes__r[0].id);
                            system.debug('--quoteIdList' +quoteIdList);
                        }
                        else{
                            billingStatus.add('Error');
                            billingStatus.add('No billable quote exist for selected Lead.');
                            billingOutputList.put(opportunityObj.Id,billingStatus);     
                        }
                    }
                    else{
                        isPlatformSFDC = True;
                        setMessage(true, 'Job is being processed in Premier');
                    }
            }
        }
    }

    //Amended on 09-07-2010:-----
    //****************************
   //**************************
   //Retrieves  latest date of installation date for all the jobs relating to the above Quote
    private Date getLowestInstallationDate(List<Job__c> lstJobs){
        Date jobInstalationDate = lstJobs[0].Installation_Date__c;
        for(integer i=0; i < lstJobs.size(); i++){  
            //Job Completion Date in Installation Billing is the lowest Installation date for the all related Jobs for the Quote              
            if(lstJobs[i].Installation_Date__c < jobInstalationDate){
                jobInstalationDate = lstJobs[i].Installation_Date__c;
            }
        }
        return jobInstalationDate;      
    }
    
    //Get Job Input date
    private Datetime getjobinputdate(List<Job__c> lstJobs){
        Datetime jobInputDate = lstJobs[0].createddate;
        for(integer i=0; i < lstJobs.size(); i++){  
            if(lstJobs[i].createddate > jobInputDate){
                jobInputDate = lstJobs[i].createddate;
            }
        }
        return jobInputDate;      
    }
    //ending the Job Input Date Method
    
    
    /*
        Public method to be called from the En-Mass Installtion Billing Data

    */
    public Map<Id,List<String>> insertMultipleData() 
    {
        InsertData();
        return billingOutputList;
    }
    //##############################################################################################
    //private method for insertion of Installation billing and Job Description for overriden checkbox    
    //Modified input parameter from a SObject to List<SOject> by Avishek for En-Mass Billing Record Creation
   private  void InsertOverridenData(List<BigMachines_Quote__c> quoteFinalList){
        System.Savepoint srInstallation = Database.setSavePoint();
        try
        {     
            newInstallationBillingList = new List<Installation_Billing__c>{};
            List<ID> CHILeadIdList = new List<ID>();
            ID installationBillingID;           

            for (BigMachines_Quote__c Quote:quoteFinalList){
                
           // Fix for multiple billing 17.5 % and 20 % CHI Leads in a single multi billing view
           // Reset all the variables which are used in the loop at the start of every iteration.
                
                newchange = false;
                nochange = false;
                
                //create a new Installation Billing from the quote
                BillType = Quote.Opportunity__r.Manual_Bill__c;
                oldbilltotal = 0.0;
                newbillTotal = 0.0;
                newVAT1Amount = 0.0;
                oldVAT1Amount = 0.0;
                Date tempinstalldate;
                Date Actualinstallationdate;
                newInstallationBilling = new Installation_Billing__c();
                //newInstallationBilling.Job_Completion_Date__c = getLowestInstallationDate(Quote.Jobs__r);    //Changed because It will fetch lowast installation date of the Jobs.  
                Actualinstallationdate = getLowestInstallationDate(Quote.Jobs__r);
                newInstallationBilling.Job_Request_Date__c = Quote.createdDate_quote__c;    
                newInstallationBilling.Big_Machine_Quote__c = Quote.Id;
                newInstallationBilling.Job_Input_Date__c = getjobinputdate(Quote.Jobs__r).date();
                Decimal VAT17 = 0.0;
                Decimal VAT5 = Quote.VAT_5_Total_Amount__c;
                Decimal discount = 0.0;
                Decimal newdiscount = 0.0;
                newmismatch = 0.0;
                billperiod = Quote.Opportunity__r.Bill_Period__c;
                /************************** Added for VAT change**************************************************
                ************************        Start     *******************************************************/
                system.debug('Quote.VAT_17_5_Total_Amount__c'+Quote.VAT_17_5_Total_Amount__c);
                system.debug('oldvat1'+oldVat1);
                system.debug('newvat1'+newVat1);
                Double newvat17 =0.0;
                newvat17 = (Quote.VAT_17_5_Total_Amount__c/(1+oldVat1)+ ((Quote.VAT_17_5_Total_Amount__c/(1+oldVat1))*(newVat1))).setscale(2);
                newisdifference = 0.00;
                system.debug('VAT 1 net Value--->'+(Quote.VAT_17_5_Total_Amount__c/(1+oldVat1)));
                system.debug('VAT1 Amount--->'+((Quote.VAT_17_5_Total_Amount__c/(1+oldVat1))*(newVat1)));
                system.debug('newvat17--->'+newvat17);
                if(Quote.ISpec_Difference__c !=null && Quote.ISpec_Difference__c>0.00 ){
                    newisdifference = ((Quote.ISpec_Difference__c/(1+oldVat1))+((Quote.ISpec_Difference__c/(1+oldVat1))*(newVat1))).setscale(2);
                 }
                system.debug('newisdifference--->'+newisdifference);
                system.debug('billperiod--->'+billperiod);
                
                if(billperiod == 'After  04/01' ||((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) && (billperiod != 'Before 04/01'))){
                    newchange =true;
                    if(Quote.newPriceMatchDifference__c != null ||Quote.newPriceMatchDifference__c>=0.0){
                        newmismatch = Quote.newPriceMatchDifference__c;
                    }else if(Quote.priceMatchDifference__c !=null || Quote.priceMatchDifference__c>=0.0){
                        newmismatch = ((Quote.priceMatchDifference__c/(1+oldVat1))+ ((Quote.priceMatchDifference__c/(1+oldVat1))*newVat1)).setscale(2);
                    }
                }
                tempinstalldate = getLowestInstallationDate(Quote.Jobs__r);
                if((Quote.closeDate__c >= overwrite)&& (tempinstalldate >= overwrite) ){
                    nochange =true;
                }
                if(Quote.Opportunity__r.Installation_Date_Billing__c != null)
                     billingoverride = date.valueOf(Quote.Opportunity__r.Installation_Date_Billing__c); 
                if(((tempinstalldate < overwrite)&& newchange)){
                    newInstallationBilling.Job_Completion_Date__c = billingoverride;
                }else if((billperiod == 'Before 04/01')){
                    newInstallationBilling.Job_Completion_Date__c = billingoverride;
                }else {
                    newInstallationBilling.Job_Completion_Date__c = getLowestInstallationDate(Quote.Jobs__r); 
                }
                system.debug('newpricemismatch-->'+Quote.newPriceMatchDifference__c);   
                system.debug('newmismatch-->'+newmismatch); 
                 if(((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) || newchange)&& (billperiod != 'Before 04/01')){
                        if(newvat17 >0){
                            system.debug('Inside New VAT');
                            if(newmismatch >0 && newisdifference >0){
                                VAT17 = newvat17 + newisdifference + newmismatch;
                            }else if (newmismatch >=0 && newisdifference <=0){
                                VAT17 = newvat17 + newmismatch;
                            }else if (newmismatch <=0 && newisdifference >=0){
                                VAT17 = newvat17 + newisdifference;
                            }else
                                VAT17=   newvat17 ;
                        }
                     
                }
                
                 /************************** Added for VAT change**************************************************
                ************************        End     *******************************************************/
                else {
                    if(Quote.VAT_17_5_Total_Amount__c >0){
                    if(Quote.priceMatchDifference__c >0 && Quote.ISpec_Difference__c >0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.ISpec_Difference__c + Quote.priceMatchDifference__c;
                    }else if (Quote.priceMatchDifference__c >=0 && Quote.ISpec_Difference__c <=0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.priceMatchDifference__c;
                    }else if (Quote.priceMatchDifference__c <=0 && Quote.ISpec_Difference__c >=0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.ISpec_Difference__c;
                    }else
                        VAT17=   Quote.VAT_17_5_Total_Amount__c ;
                    }
                }
                system.debug('newchange'+newchange);
                 /************************** Added for VAT change**************************************************
                ************************        Start     *******************************************************/
                if(((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) || newchange)&& (billperiod != 'Before 04/01')){
                    if(Quote.discountsTotalOnPricing__c >=0){
                            if(newmismatch <= 0 && newisdifference >=0){
                                discount = (Quote.discountsTotalOnPricing__c -(newmismatch)) ;
                            }else if(newmismatch >= 0 && newisdifference<=0){
                                discount = (Quote.discountsTotalOnPricing__c -(newisdifference));
                            }else if(newmismatch <= 0 && newisdifference <=0){
                                discount = (Quote.discountsTotalOnPricing__c - newisdifference - newmismatch);
                            }else
                                discount = Quote.discountsTotalOnPricing__c ;
                        }
                    
                    }
                
                /************************** Added for VAT change**************************************************
                ************************        End     *******************************************************/
              else{
                if(Quote.discountsTotalOnPricing__c >=0){
                    if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c>=0){
                        discount = (Quote.discountsTotalOnPricing__c -(Quote.priceMatchDifference__c)) ;
                    }else if(Quote.priceMatchDifference__c >= 0 && Quote.ISpec_Difference__c<=0){
                        discount = (Quote.discountsTotalOnPricing__c -(Quote.ISpec_Difference__c));
                    }else if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c <=0){
                        discount = (Quote.discountsTotalOnPricing__c -Quote.ISpec_Difference__c-Quote.priceMatchDifference__c);
                    }else
                        discount = Quote.discountsTotalOnPricing__c ;
                }
                
              }
                System.debug('Testing---discount'+discount);
                System.debug('Testing---VAt17'+VAt17);
                //populate fields in Installation Billing                    
                String addressLine1 = '';

                //populating addressLine1
               if(Quote.Opportunity__r.Bill_Title__c!= null && Quote.Opportunity__r.Bill_Title__c.trim() != '')
               {
                    if(Quote.Opportunity__r.Bill_Title__c != 'Company')
                    {
                        addressLine1 = Quote.Opportunity__r.Bill_Title__c;
                    }
                
               }
               else if(Quote.Opportunity__r.Account.Primary_Contact__r.Salutation != null && Quote.Opportunity__r.Account.Primary_Contact__r.Salutation.trim() != ''){
                    
                    addressLine1 = Quote.Opportunity__r.Account.Primary_Contact__r.Salutation;
               }
                
                if(Quote.Opportunity__r.Bill_FirstName__c!= null && Quote.Opportunity__r.Bill_FirstName__c.trim() != '')
                {
                    if(Quote.Opportunity__r.Bill_Title__c != 'Company' )
                    {
                        if(addressLine1 != '') addressLine1 += ' ';
                        addressLine1 += Quote.Opportunity__r.Bill_FirstName__c;
                    }
                }
                else if(Quote.Opportunity__r.Account.Primary_Contact__r.FirstName != null && Quote.Opportunity__r.Account.Primary_Contact__r.FirstName.trim() != ''){
                    if(addressLine1 != '') addressLine1 += ' ';                         
                        addressLine1 += Quote.Opportunity__r.Account.Primary_Contact__r.FirstName ;
                }
                
                if(Quote.Opportunity__r.Bill_LastName__c!= null && Quote.Opportunity__r.Bill_LastName__c.trim() != '')
                {
                     if(addressLine1 != '') addressLine1 += ' ';                         
                        addressLine1 += Quote.Opportunity__r.Bill_LastName__c ;
                }
                else if(Quote.Opportunity__r.Account.Primary_Contact__r.LastName != null && Quote.Opportunity__r.Account.Primary_Contact__r.LastName.trim() != ''){
                    if(addressLine1 != '') addressLine1 += ' ';
                        addressLine1 += Quote.Opportunity__r.Account.Primary_Contact__r.LastName;
                }
                //newInstallationBilling.Account_Address_Line1__c = addressLine1 ;

                if (Quote.POC_Payment_Method__c == 'Finance'){
                    /*if (Quote.POC_Payment_Option__c.contains('Hitachi')){
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.Hitachi_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.Hitachi_Name;
                    }else*/
                    if(Quote.POC_Payment_Option__c.contains('Hitachi') || Quote.POC_Payment_Option__c == 'Barclays' || 
                             Quote.POC_Payment_Option__c == 'BNPL' ||  Quote.POC_Payment_Option__c == 'Macquarie' ||
                             Quote.POC_Payment_Option__c == 'GreenDeal' ||  Quote.POC_Payment_Option__c == System.Label.LinkFinance_Name ||
                             Quote.POC_Payment_Option__c == 'Honeycomb' ||  Quote.POC_Payment_Option__c == '1st Stop'){
                        newInstallationBilling.Account_Address_Line_2__c = Quote.POC_Payment_Option__c +' '+System.Label.Barclays_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.Barclays_Name;
                    }/*else if(Quote.POC_Payment_Option__c == 'GreenDeal'){
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.GreenDeal_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.GreenDeal_Name;
                    }else if(Quote.POC_Payment_Option__c == System.Label.LinkFinance_Name){
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.LinkFinance_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.LinkFinance_Name2;
                    }
                    else if(Quote.POC_Payment_Option__c == 'Honeycomb'){ // Added as part of PRB00032822
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.Honeycomb_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.Honeycomb_Name;
                    }
                    else if(Quote.POC_Payment_Option__c == '1st Stop'){ // Added as part of PRB00032822
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.First_Stop_Billing_Street; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.HItachi_Billing_City;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Hitachi_Billing_County;
                        newInstallationBilling.Account_Address_Line1__c = System.Label.First_Stop_Name;
                    }
                    if (Quote.Opportunity__r.Bill_to_Office__c == true){   
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.Office_Billing_Name; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.Office_Billing_Street;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Office_Billing_City;
                        newInstallationBilling.Account_Address_Line1__c =  UserInfo.getName();
                    }
                    */
                }
                
                else if(Quote.Opportunity__r.Bill_to_Office__c == true){   
                        newInstallationBilling.Account_Address_Line_2__c = System.Label.Office_Billing_Name; 
                        newInstallationBilling.Account_Address_Line_3__c = System.Label.Office_Billing_Street;
                        newInstallationBilling.Account_Address_Line_4__c = System.Label.Office_Billing_City;
                        newInstallationBilling.Account_Address_Line1__c =  UserInfo.getName();
                }
                else{
                        if(Quote.Opportunity__r.Bill_Street__c!=null)
                        {
                            newInstallationBilling.Account_Address_Line_2__c = Quote.Opportunity__r.Bill_Street__c;
                        }else
                        {
                            newInstallationBilling.Account_Address_Line_2__c = Quote.Opportunity__r.Account.Primary_Contact__r.MailingStreet;
                        }
                        
                        if(Quote.Opportunity__r.Bill_City__c !=null)
                        {
                            newInstallationBilling.Account_Address_Line_3__c = Quote.Opportunity__r.Bill_City__c.length()>20?Quote.Opportunity__r.Bill_City__c.substring(0,20):Quote.Opportunity__r.Bill_City__c;
                        }else if(Quote.Opportunity__r.Account.Primary_Contact__r.MailingCity !=null)
                       {
                        if(Quote.Opportunity__r.Account.Primary_Contact__r.MailingCity.length()>20)
                        newInstallationBilling.Account_Address_Line_3__c = Quote.Opportunity__r.Account.Primary_Contact__r.MailingCity.subString(0,20);
                        else
                        newInstallationBilling.Account_Address_Line_3__c = Quote.Opportunity__r.Account.Primary_Contact__r.MailingCity;
                       } 
                       if(Quote.Opportunity__r.Bill_State__c!=null)
                       {
                        newInstallationBilling.Account_Address_Line_4__c = Quote.Opportunity__r.Bill_State__c;
                       }else
                       {                   
                        newInstallationBilling.Account_Address_Line_4__c = Quote.Opportunity__r.Account.Primary_Contact__r.MailingState;
                       }
                        
                        newInstallationBilling.Account_Address_Line1__c = addressLine1;
                            
                }

                //adding BGS Payment Reference Number
                if(Quote.Opportunity__r.Payment_Reference_Number__c != null && Quote.Opportunity__r.Payment_Reference_Number__c.trim() != ''){
                   
                    newInstallationBilling.BGS_Payment_Reference_Number__c = Quote.Opportunity__r.Payment_Reference_Number__c;
                }

                //adding Area Identifier
                if(Quote.Opportunity__r.Payment_Reference_Number__c != null && Quote.Opportunity__r.Payment_Reference_Number__c.trim() != ''){
                   
                    newInstallationBilling.Area_Identifier__c = (Quote.Opportunity__r.Payment_Reference_Number__c).SubString(1, 4);
                }

                //adding VAT 17_5 Net Value 
                if(VAT17 != null || VAT17 >0.0 ){ 
                    if(newchange ||nochange){
                        newInstallationBilling.VAT_17_5_Net_Value__c = (((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))* 100)).round() - ((discount/(1+newVat1))*100).round());
                        system.debug('newInstallationBilling.VAT_17_5_Net_Value__c'+newInstallationBilling.VAT_17_5_Net_Value__c);
                    } else
                        newInstallationBilling.VAT_17_5_Net_Value__c = (((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))* 100)).round() - ((discount/(1+oldVat1))*100).round());
                }                
                //adding VAT_17_5_Amount__c
                if(VAT17 != null || VAT17 >0.0 ){ 
                    if(newchange ||nochange){
                        system.debug('vat not negetive or null');
                        newInstallationBilling.VAT_17_5_Amount__c = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+newVat1))*newVat1)*100).round();
                        newVAT1Amount = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+newVat1))*newVat1)*100).round();
                        oldVAT1Amount = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+newVat1))*oldVat1)*100).round();
                    } else{  
                         system.debug('vat is null');
                        newInstallationBilling.VAT_17_5_Amount__c = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+oldVat1))*oldVat1)*100).round();
                        newVAT1Amount = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+oldVat1))*newVat1)*100).round();
                        oldVAT1Amount = ((((VAT17 +Quote.ASP_Discounts__c - discount)/(1+oldVat1))*oldVat1)*100).round();
                    }
                }
                system.debug('newVAT1Amount---->'+newVAT1Amount);
                system.debug('oldVAT1Amount---->'+oldVAT1Amount);
                //adding VAT 5 Net Value
                if(VAT5 != null || VAT5 >0.0 ){   
                        newInstallationBilling.VAT_5_Net_Value__c = ((VAT5/(1+oldVat4))* 100).round();
                }
                //adding VAT 5 Amount
                if(VAT5 != null || VAT5 >0.0){   
                        newInstallationBilling.VAT_5_Amount__c = ((VAT5*100)-((VAT5/(1+oldVat4))*100)).round();
                }
                //adding VAT Exempt Value Net Value
                newInstallationBilling.VAT_Exempt_Value_Net_Value__c = 0;

                //adding VAT Zero Rated Net Value
                newInstallationBilling.VAT_Zero_Rated_Net_Value__c = 0;

                //adding Bill Total
                if(newchange ||nochange){
                System.debug('entered in if billltotal');
                        newInstallationBilling.Bill_Total__c= ((((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))* 100)).round() + (((VAT5 / (1+newVat4))*100)).round() +newInstallationBilling.VAT_17_5_Amount__c +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+newVat1))*100).round());
                        oldbilltotal = ((((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))* 100)).round() + (((VAT5 / (1+newVat4))*100)).round() +oldVAT1Amount +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+newVat1))*100).round());
                        newbilltotal = ((((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))* 100)).round() + (((VAT5 / (1+newVat4))*100)).round() +newVAT1Amount +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+newVat1))*100).round());
                } else {
                System.debug('entered in else billtotal');
                        newInstallationBilling.Bill_Total__c= ((((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))* 100)).round() + (((VAT5 / (1+oldVat4))*100)).round() +newInstallationBilling.VAT_17_5_Amount__c +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+oldVat1))*100).round());
                        newbilltotal = ((((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))* 100)).round() + (((VAT5 / (1+oldVat4))*100)).round() +newVAT1Amount +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+oldVat1))*100).round());
                        oldbilltotal = ((((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))* 100)).round() + (((VAT5 / (1+oldVat4))*100)).round() +oldVAT1Amount +  newInstallationBilling.VAT_5_Amount__c)-((discount/(1+oldVat1))*100).round());
                } 
                
                 System.debug('VAT17'+VAT17);
                 System.debug('VAT5'+VAT5);
                 System.debug('Quote.ASP_Discounts__c'+ Quote.ASP_Discounts__c);
                 System.debug('oldVat1'+oldVat1);
                 System.debug('oldVat4'+oldVat4);
                 System.debug('oldVAT1Amount'+ oldVAT1Amount);
                 System.debug('newVat1'+ newVat1);
                 System.debug('newVat4'+ newVat4);
                 System.debug('newVAT1Amount'+ newVAT1Amount);
                 System.debug('newInstallationBilling.VAT_5_Amount__c'+ newInstallationBilling.VAT_5_Amount__c);
                 System.debug('newInstallationBilling.VAT_17_5_Amount__c'+ newInstallationBilling.VAT_17_5_Amount__c);
                 System.debug('discount'+ discount);
                 
                 System.debug ('1-->'+(((VAT17/ (1+newVat1))* 100)).round()); 
                 System.debug ('1-->'+(((VAT17/ (1+oldVat1))* 100)).round()); 
                 System.debug ('2-->'+(((Quote.VAT_5_Total_Amount__c / (1+oldVat4))*100)).round()); 
                 System.debug ('3-->'+((Quote.ASP_Discounts__c*100).round())); 
                 System.debug ('4-->'+newInstallationBilling.VAT_17_5_Amount__c); 
                 System.debug ('5-->' + newInstallationBilling.VAT_5_Amount__c);  
                 System.debug ('6-->'+((discount/(1+newVat1))*100).round()); 
                if(newchange ||nochange){
                        newInstallationBilling.Bill_Value__c = (((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))* 100)).round()+ (((VAT5 / (1+newVat4))*100)).round())-((discount/(1+newVat1))*100).round();
                } else{
                        newInstallationBilling.Bill_Value__c = (((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))* 100)).round()+ (((VAT5 / (1+oldVat4))*100)).round())-((discount/(1+oldVat1))*100).round();
                }
                system.debug('oldbilltotal---->'+oldbilltotal);
                system.debug('newInstallationBilling.Bill_Value__c---->'+newInstallationBilling.Bill_Value__c);
                //adding Customer Reference
                if(Quote.Opportunity__r.Payment_Reference_Number__c != null && Quote.Opportunity__r.Payment_Reference_Number__c.trim() != ''){
                    newInstallationBilling.Customer_Reference__c = (Quote.Opportunity__r.Payment_Reference_Number__c).SubString(1, 11);
                }
                //adding Job_Address
                if (Quote.POC_Payment_Method__c == 'Finance'){
                    //NEW CODE - 
                    newInstallationBilling.Job_Address_Line_1__c = addressLine1 ;
                    newInstallationBilling.Job_Address_Line_2__c = Quote.Opportunity__r.Account.Primary_Contact__r.MailingStreet ;
                    newInstallationBilling.Job_Address_Line_3__c =  Quote.Opportunity__r.Account.Primary_Contact__r.MailingCity;
                    newInstallationBilling.Post_Code__c = System.Label.Hitachi_Billing_Post_code;
                    newInstallationBilling.Account_Post_code__c = Quote.Opportunity__r.Account.BillingPostalcode;
                }
                
               else if ( Quote.Opportunity__r.Bill_to_Office__c == true || Quote.Opportunity__r.Account.Landlord_Account__c ){
                    newInstallationBilling.Job_Address_Line_1__c = addressLine1 ;
                    newInstallationBilling.Job_Address_Line_2__c = Quote.Opportunity__r.Account.BillingStreet;
                    newInstallationBilling.Job_Address_Line_3__c =  Quote.Opportunity__r.Account.BillingCity;
                    newInstallationBilling.Account_Post_code__c = Quote.Opportunity__r.Account.BillingPostalcode;
                    if(Quote.Opportunity__r.Bill_to_Office__c == true)
                    newInstallationBilling.Post_Code__c = System.Label.Office_Billing_Post_Code;
                    else
                    newInstallationBilling.Post_Code__c =  Quote.Opportunity__r.Bill_Post_Code__c;
                }
                else{
                    newInstallationBilling.Job_Address_Line_1__c = '';
                    newInstallationBilling.Job_Address_Line_2__c = '';
                    newInstallationBilling.Job_Address_Line_3__c = '';
                    newInstallationBilling.Post_Code__c = Quote.Opportunity__r.Bill_Post_Code__c!=null? Quote.Opportunity__r.Bill_Post_Code__c: Quote.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode;
                }
                //adding CHI Lead Number
               
                newInstallationBilling.CHI_Lead_Number__c = Quote.Opportunity__r.CHI_Lead_Id__c;    
                    
                //Check if at least one job description record would be generated for current Quote           
                
                if(isJobDescRecordTobeGenerated(Quote))
                {
                    newInstallationBillingList.add(newInstallationBilling);
                }
   
                //for Quote Editable  
                checksystem=true;
                if(checksystem==true){
                    Quote.IsSystem__c=true; 
                }
                Quote.Billed__c = true;
                system.debug('--newInstallationBillingList' +newInstallationBillingList);
                //fix for defect
                if(!isJobDescRecordTobeGenerated(Quote)){
                    checkBillTotalMap.put(Quote.Id, '2');
                }
                else if(newInstallationBilling.Bill_Total__c > 0.0){
                    checkBillTotalMap.put(Quote.Id, '1');
                }
                else if(newInstallationBilling.Bill_Total__c == 0){
                    checkBillTotalMap.put(Quote.Id, '3');
                }
                else{
                    checkBillTotalMap.put(Quote.Id, '0');
                }               
                CHILeadIdList.Add(Quote.Opportunity__c);
                
            }
            
            //moved the setsavepoint before try block
            //Added a new condition that if the Bill total is less than 0.00 then don't send record for Billing.
            /* *********************                    Date:- 30-06-2010   ***********************************
             Insertion of Installation billing record is modified, if the Bill total is less than 0 then, system will remove the installation 
             billing record and quote id from MAP and do not insert or update the record
             */ 
           //if(isView == false)     //Added for Contingency Billing screen testing  
            {     
               system.debug('checkBillTotalMap-->'+checkBillTotalMap);
               Map<String,Installation_Billing__c> installationBillMap=new Map<String,Installation_Billing__c>{};
               Map<String,BigMachines_Quote__c> bmQuoteMap= new Map<String,BigMachines_Quote__c>{};
               List<Installation_Billing__c> newInstallationBillingList1=new List<Installation_Billing__c>{};
               List<BigMachines_Quote__c> quoteFinalList1=new List<BigMachines_Quote__c>{};
                 
               newInstallationBillingList1.addAll(newInstallationBillingList); 
               quoteFinalList1.addAll(quoteFinalList);
               for (Installation_Billing__c objInstBill:newInstallationBillingList1){
                installationBillMap.put(objInstBill.Big_Machine_Quote__c, objInstBill);         
               }  
               for (BigMachines_Quote__c objBMQuote:quoteFinalList1){
                bmQuoteMap.put(objBMQuote.Id, objBMQuote);          
               } 
                system.debug('installationBillMap-->'+installationBillMap);
                system.debug('bmQuoteMap-->'+bmQuoteMap);      
               if (newInstallationBillingList.size()>0 ){
                 for (BigMachines_Quote__c objQuote:quoteFinalList){
                             billingStatus=new List<String>{};
                         String s_status = checkBillTotalMap.get(objQuote.Id);
                         
                //Start: Check the CHI Lead Status
                if(objQuote.Opportunity__r.StageName == 'Suspended' || objQuote.Opportunity__r.StageName == 'Expired'||objQuote.Opportunity__r.StageName == 'Closed Lost'){
                    if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('CHI Lead is Closed Lost, Suspended or Expired.');
                        billingOutputList.put(objQuote.Opportunity__c,billingStatus);  
                    }
                    else
                        setMessage(true, 'CHI Lead is Closed Lost, Suspended or Expired.');
                        
                     installationBillMap.remove(objQuote.id);
                     bmQuoteMap.remove(objQuote.id);
                }
                //End: Check for CHI Lead status is ending here.
                         
                        if(s_status == '0'){
                            if (blMultiple){    
                                billingStatus.add('Error');
                                billingStatus.add('Bill Total is Less than 0.');
                                billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                                
                            }else{
                                setMessage(true, 'Bill Total is Less than 0.');
                                //installationBillMap.remove(objQuote.id);
                                //bmQuoteMap.remove(objQuote.id);
                            }
                            installationBillMap.remove(objQuote.id);
                            bmQuoteMap.remove(objQuote.id);
                        }
                        else if(s_status == '2'){
                            if (blMultiple){    
                                billingStatus.add('Error');
                                billingStatus.add('No valid Quote Product associated with current Quote.');
                                billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                            } 
                            else {
                                setMessage(true, 'No valid Quote Product associated with current Quote.');
                                //installationBillMap.remove(objQuote.id);
                                //bmQuoteMap.remove(objQuote.id);
                            }
                            installationBillMap.remove(objQuote.id);
                            bmQuoteMap.remove(objQuote.id);
                        }
                        else if(s_status == '3'){
                            if (blMultiple){    
                                billingStatus.add('Error');
                                billingStatus.add('The Quote value is 0, so system cant bill this Job. ');
                                billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                            } 
                            else {
                                setMessage(true, 'The Quote value is 0, so system cant bill this Job. ');
                            }
                            installationBillMap.remove(objQuote.id);
                            bmQuoteMap.remove(objQuote.id);
                        }
                     }
                 }
                         system.debug('installationBillMap-->'+installationBillMap); 
                         system.debug('bmQuoteMap-->'+bmQuoteMap); 
                        newInstallationBillingList=new List<Installation_Billing__c>{};
                        quoteFinalList = new List<BigMachines_Quote__c>{}; 
                        newInstallationBillingList=installationBillMap.values();
                        quoteFinalList = bmQuoteMap.values();
                        
                       if(!IsView){   
                            if(BillType != 'Yes' ){
                            if (newInstallationBillingList.size()>0){
                                    insert newInstallationBillingList;
                                    if (quoteFinalList.size()>0){
                                     update quoteFinalList;
                                    }
                               }
                            }
                            else{
                                if (quoteFinalList.size()>0){
                                    update quoteFinalList;
                                }
                            }
                       }   
                    }
            
          
               
            //#######################################################################################
            //Need to be modified- waiting for further information on Job Description records(Service)                    
            
            
            lstJobDescriptionRecord = new list<Job_Description_Record__c>();
            
            for (BigMachines_Quote__c Quote:quoteFinalList) {
                
           // Fix for multiple billing 17.5 % and 20 % CHI Leads in a single multi billing view
           // Reset all the variables which are used in the loop at the start of every iteration.
                
                newchange = false;
                nochange = false;
                billperiod = Quote.Opportunity__r.Bill_Period__c;
                Date tempinstalldate_new  = getLowestInstallationDate(Quote.Jobs__r);
                if((Quote.closeDate__c >= overwrite)&& (tempinstalldate_new >= overwrite) ){
                     nochange =true;
                }

                System.debug('Quote Data' + Quote);
                /*
                Added By:- Cognizant
                Reason:- To set the nias codes
                */
                 // Added new else condition for manual billing for Payment team.
                if(isView || (!isView && Quote.Opportunity__r.Manual_Bill__c != 'Yes'))
                {
                    system.debug('2----newInstallationBillingList' +newInstallationBillingList);
                    for (Installation_Billing__c objInstallationBilling :newInstallationBillingList){
                      System.debug('ObjInstallation Id' + objInstallationBilling.Id);
                      system.debug('--objInstallationBilling' +objInstallationBilling);
                      //Checking the Quote Id in Installation Billing Record and Quote Product 
                         if (objInstallationBilling.Big_Machine_Quote__c == Quote.ID){
                             System.debug('Is Matched');
                             installationBillingID = objInstallationBilling.Id;
                             system.debug('---installationBillingID' +installationBillingID);                         
                    }                    
                }
                //Added a new Block that if the Bill total is less than 0.00 then don't send record for Billing.
                if (installationBillingID != null){
                    isValid = true;
                } else {
                    isValid = false;
                }
                 // Get NIAS Code for current Quote from map    
                NIASCodeHelper.NIASCode niasCode = quoteNIASMap.get(Quote.ID);
                 System.debug('-------------- NIAS Quote ID  -> ' + Quote.ID );
                //Build default NIAS codes
                String serviceTypeFinCode ='       ';
                String discountTypeFinCode ='       ';
                String applianceType = '  ';
                
                //Retrieve target nias code values
                 if(niasCode != null && niasCode.EMPcode != null && niasCode.COSTCode != null && niasCode.INCOMECode != null){
                    serviceTypeFinCode = niasCode.CostCode + '' + niasCode.INCOMECode;
                    discountTypeFinCode = niasCode.CostCode + '' + niasCode.EMPCode;
                    applianceType = '' + niasCode.ApplianceType;
                    System.debug('-------------- serviceTypeFinCode  -> ' + serviceTypeFinCode );
                    System.debug('-------------- discountTypeFinCode -> ' + discountTypeFinCode );
                }
                 //Create Job Description record (Service Type) for newly created Installation billing record if VAT  is present
                    Job_Description_Record__c jobDescription;
                    //Create Job Description record (Discount) for newly created Installation billing record if discount is present
                       /************************** Added for VAT change**************************************************
                ************************        Start     *******************************************************/
                Double newisdifference = 0.00;
                newmismatch = 0.0;
                Decimal Tempnewmismatch = 0.0;
                if(Quote.ISpec_Difference__c !=null && Quote.ISpec_Difference__c>0.00 ){
                    newisdifference = ((Quote.ISpec_Difference__c/(1+oldVat1))+((Quote.ISpec_Difference__c/(1+oldVat1))*(newVat1))).setscale(2);
                 System.debug('newisdifference'+newisdifference);}
                system.debug('newisdifference--->'+newisdifference);
                Date Actualinstallationdate = getLowestInstallationDate(Quote.Jobs__r);
                if(billperiod == 'After  04/01' ||((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) && (billperiod != 'Before 04/01'))){
                    newchange =true;
                    if(Quote.newPriceMatchDifference__c != null ||Quote.newPriceMatchDifference__c>=0.0){
                        newmismatch = Quote.newPriceMatchDifference__c;
                    }else if(Quote.priceMatchDifference__c !=null || Quote.priceMatchDifference__c>=0.0){
                        newmismatch = ((Quote.priceMatchDifference__c/(1+oldVat1))+ ((Quote.priceMatchDifference__c/(1+oldVat1))*newVat1)).setscale(2);
                    System.debug('newmismatch'+newmismatch);}
                }
                 if(Quote.newPriceMatchDifference__c != null ||Quote.newPriceMatchDifference__c>=0.0){
                        Tempnewmismatch = Quote.newPriceMatchDifference__c;
                    }else if(Quote.priceMatchDifference__c !=null || Quote.priceMatchDifference__c>=0.0){
                        Tempnewmismatch = ((Quote.priceMatchDifference__c/(1+oldVat1))+ ((Quote.priceMatchDifference__c/(1+oldVat1))*newVat1)).setscale(2);
                   }
                if(((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) || newchange)&& (billperiod != 'Before 04/01')){
                       
                        if(Quote.discountsTotalOnPricing__c >=0){
                            if(newmismatch <= 0 && newisdifference >=0){
                                Value = (Quote.discountsTotalOnPricing__c -(newmismatch)) ;
                                System.debug('inside 1st condition');
                            }else if(newmismatch >= 0 && newisdifference<=0){
                                Value = (Quote.discountsTotalOnPricing__c -(newisdifference));
                                System.debug('inside 2nd condition');
                            }else if(newmismatch <= 0 && newisdifference <=0){
                                Value = (Quote.discountsTotalOnPricing__c - newisdifference - newmismatch);
                                System.debug('inside 3rd condition');
                            }else
                                Value = Quote.discountsTotalOnPricing__c ;
                               
                        }
                        if(Quote.discountsTotalOnPricing__c >=0){
                            if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c>=0){
                                newvalue = (Quote.discountsTotalOnPricing__c -(Quote.priceMatchDifference__c)) ;
                                System.debug('inside 1st condition new value');
                            }else if(Quote.priceMatchDifference__c >= 0 && Quote.ISpec_Difference__c<=0){
                                newvalue = (Quote.discountsTotalOnPricing__c -(Quote.ISpec_Difference__c));
                                System.debug('inside 2nd condition new value');
                            }else if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c <=0){
                                newvalue = (Quote.discountsTotalOnPricing__c -Quote.ISpec_Difference__c-Quote.priceMatchDifference__c);
                                System.debug('inside 3rd condition new value');
                            }else
                                newvalue = Quote.discountsTotalOnPricing__c ;
                         }
                        
                        System.debug('Value---->'+Value);
                        System.debug('newValue---->'+newValue);
                       firstValue = ((Value  / (1+newVat1))* 100);    
                       jobDescription = new Job_Description_Record__c();                  
                       jobDescription.First_Value__c = firstValue.round();
                       jobDescription.Vat_Code__c = ''; //Modified because VAT code doesn't go for Discounts.on 31/05/2010
                       jobDescription.Appliance_Type__c = '00';
                       jobDescription.Financial_Code__c = discountTypeFinCode;
                       jobDescription.Service_Type__c = 'LD';
                       jobDescription.Allowance_Marker__c = 'C';
                       jobDescription.Installation_Billing__c = installationBillingID;
                       if(firstValue>0.0){
                           lstJobDescriptionRecord.Add(jobDescription);
                       }
                       
                       system.debug('1--lstJobDescriptionRecord' +lstJobDescriptionRecord);
                   
                }
                /************************** Added for VAT change**************************************************
                ************************        End     *******************************************************/
              else{
                    if(Quote.discountsTotalOnPricing__c >=0){
                        if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c>=0){
                            Value = (Quote.discountsTotalOnPricing__c -(Quote.priceMatchDifference__c)) ;
                            System.debug('inside 1st condition else part');
                        }else if(Quote.priceMatchDifference__c >= 0 && Quote.ISpec_Difference__c<=0){
                            Value = (Quote.discountsTotalOnPricing__c -(Quote.ISpec_Difference__c));
                            System.debug('inside 2nd condition else part');
                        }else if(Quote.priceMatchDifference__c <= 0 && Quote.ISpec_Difference__c <=0){
                            Value = (Quote.discountsTotalOnPricing__c -Quote.ISpec_Difference__c-Quote.priceMatchDifference__c);
                            System.debug('inside 3rd condition else part');
                        }else
                            Value = Quote.discountsTotalOnPricing__c ;
                    }
                    System.debug('Value---->'+Value);
                   if(Quote.discountsTotalOnPricing__c >=0){
                            if(Tempnewmismatch <= 0 && newisdifference >=0){
                                newValue = (Quote.discountsTotalOnPricing__c -(Tempnewmismatch)) ;
                               System.debug('inside 1st condition else part newvalue');  
                            }else if(Tempnewmismatch >= 0 && newisdifference<=0){
                                newValue = (Quote.discountsTotalOnPricing__c -(newisdifference));
                                 System.debug('inside 2nd condition else part newvalue'); 
                            }else if(Tempnewmismatch <= 0 && newisdifference <=0){
                                newValue = (Quote.discountsTotalOnPricing__c - newisdifference - Tempnewmismatch);
                                 System.debug('inside 3rd condition else part newvalue'); 
                            }else
                                newValue = Quote.discountsTotalOnPricing__c ;
                        }
                        System.debug('newValue---->'+newValue);
                   if(nochange){ 
                        firstValue = ((Value  / (1+newVat1))* 100);    
                   }else{
                        firstValue = ((Value  / (1+oldVat1))* 100);    
                   }
                   jobDescription = new Job_Description_Record__c();                  
                   jobDescription.First_Value__c = firstValue.round();
                   jobDescription.Vat_Code__c = ''; //Modified because VAT code doesn't go for Discounts.on 31/05/2010
                   jobDescription.Appliance_Type__c = '00';
                   jobDescription.Financial_Code__c = discountTypeFinCode;
                   jobDescription.Service_Type__c = 'LD';
                   jobDescription.Allowance_Marker__c = 'C';
                   jobDescription.Installation_Billing__c = installationBillingID;
                   if(firstValue>0.0){
                   lstJobDescriptionRecord.Add(jobDescription);
                   }
                   system.debug('1--lstJobDescriptionRecord' +lstJobDescriptionRecord);
              }
              
              /************************** Added for VAT change**************************************************
                ************************        Start     *******************************************************/
                Double newvat17 = (Quote.VAT_17_5_Total_Amount__c/(1+oldVat1)+ ((Quote.VAT_17_5_Total_Amount__c/(1+oldVat1))*(newVat1))).setscale(2);
                Decimal VAT17 = 0.0;
                system.debug('newvat17--->'+newvat17);
                if(((Actualinstallationdate >= overwrite && Quote.closeDate__c < overwrite) || newchange)&& (billperiod != 'Before 04/01')){
                     if(newvat17 >0){
                            if(newmismatch >0 && newisdifference >0){
                                VAT17 = newvat17 + newisdifference + newmismatch;
                            }else if (newmismatch >=0 && newisdifference <=0){
                                VAT17 = newvat17 + newmismatch;
                            }else if (newmismatch <=0 && newisdifference >=0){
                                VAT17 = newvat17 + newisdifference;
                            }else
                                VAT17=   newvat17 ;
                        }
                      system.debug('VAt17--->'+VAt17);  
                      // no job desc record of same vat; create new
                            jobDescription = new Job_Description_Record__c();
                            jobDescription.First_Value__c = ((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))*100).round());
                            newfirstvalue = jobDescription.First_Value__c;
                            oldfirstvalue = newfirstvalue;
                            jobDescription.Vat_Code__c = 'L';
                            jobDescription.Appliance_Type__c = applianceType;
                            jobDescription.Financial_Code__c = serviceTypeFinCode;
                            jobDescription.Service_Type__c = 'I';
                            jobDescription.Allowance_Marker__c = ' ';
                            jobDescription.Installation_Billing__c = installationBillingID;                        
                            lstJobDescriptionRecord.add(jobDescription);
                            system.debug('2--lstJobDescriptionRecord' +lstJobDescriptionRecord);  
                    }
                
                 /************************** Added for VAT change**************************************************
                ************************        End     *******************************************************/
                else {
                    if(Quote.VAT_17_5_Total_Amount__c >0){
                    if(Quote.priceMatchDifference__c >0 && Quote.ISpec_Difference__c >0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.ISpec_Difference__c + Quote.priceMatchDifference__c;
                    }else if (Quote.priceMatchDifference__c >=0 && Quote.ISpec_Difference__c <=0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.priceMatchDifference__c;
                    }else if (Quote.priceMatchDifference__c <=0 && Quote.ISpec_Difference__c >=0){
                        VAT17 = Quote.VAT_17_5_Total_Amount__c + Quote.ISpec_Difference__c;
                    }else
                        VAT17=   Quote.VAT_17_5_Total_Amount__c ;
                    }
                    // no job desc record of same vat; create new
                        jobDescription = new Job_Description_Record__c();
                        if(nochange){ 
                            firstValue = ((((VAT17+Quote.ASP_Discounts__c)/ (1+newVat1))*100).round());   
                         }else{
                            firstValue = ((((VAT17+Quote.ASP_Discounts__c)/ (1+oldVat1))*100).round());    
                        }
                        jobDescription.First_Value__c = firstValue;
                        newfirstvalue = jobDescription.First_Value__c;
                        oldfirstvalue = newfirstvalue;
                        if(nochange){ 
                            jobDescription.Vat_Code__c = 'L';  
                         }else{
                            jobDescription.Vat_Code__c = 'D';    
                        }
                        
                        jobDescription.Appliance_Type__c = applianceType;
                        jobDescription.Financial_Code__c = serviceTypeFinCode;
                        jobDescription.Service_Type__c = 'I';
                        jobDescription.Allowance_Marker__c = ' ';
                        jobDescription.Installation_Billing__c = installationBillingID;                        
                        lstJobDescriptionRecord.add(jobDescription);
                        system.debug('2--lstJobDescriptionRecord' +lstJobDescriptionRecord);
                }
                system.debug('oldfirstvalue---->'+oldfirstvalue);
                system.debug('newfirstvalue---->'+newfirstvalue);
                    //If a record for same VAT already exists, add the value to the same record
                    if (Quote.VAT_5_Total_Amount__c !=0.00 && Quote.VAT_5_Total_Amount__c >0.00){
                        jobDescription = new Job_Description_Record__c();
                        jobDescription.First_Value__c = ((Quote.VAT_5_Total_Amount__c / (1+newVat4))*100).round();
                        jobDescription.Vat_Code__c = 'F'; 
                        jobDescription.Appliance_Type__c = applianceType;
                        jobDescription.Financial_Code__c = serviceTypeFinCode;
                        jobDescription.Service_Type__c = 'I';
                        jobDescription.Allowance_Marker__c = ' ';
                        jobDescription.Installation_Billing__c = installationBillingID;
                        lstJobDescriptionRecord.add(jobDescription);
                        system.debug('3--lstJobDescriptionRecord' +lstJobDescriptionRecord);
                    }
                 } // Added new else condition for manual billing for Payment team.
            }
                system.debug('---------------lstJobDescriptionRecord' +lstJobDescriptionRecord);
                               
            
            
            List<Job_Description_Record__c> jobDescList = new List<Job_Description_Record__c>();
            //If Job description records are populated save the information to SFDC database
            //added the Isview check outside the loop as isValid heck wont allow to view the data.
            if(isView == false){
                
                if(lstJobDescriptionRecord.size() > 0){
                    System.debug('jobDescList----->'+jobDescList);
                    //Added for Contingency Billing screen testing
                        
                    insert lstJobDescriptionRecord;
                                
                    if (blMultiple){
                        for (BigMachines_Quote__c objQuote:quoteFinalList){
                            billingStatus=new List<String>{};
                            billingStatus.add('Success');
                            billingStatus.add('Data sent for billing successfully.');
                            billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                        }
                    } 
                    else{
                        setMessage(false, 'Data sent for billing successfully.');
                    }
                }
                // Added new else condition for manual billing for Payment team.
                else if (BillType  == 'Yes'){
                    if (blMultiple){
                        for (BigMachines_Quote__c objQuote:quoteFinalList){
                            billingStatus = billingOutputList.get(objQuote.Opportunity__c);
                            billingStatus.add('Error');
                            billingStatus.add('CHI Lead needs to be Billed Manually');
                            billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                        }
                    } else if(!IsError){
                        setMessage(true, 'CHI Lead needs to be Billed Manually');
                    }

                } 
                 //ending here manual billing.
                else {
                    if (blMultiple){
                        for (BigMachines_Quote__c objQuote:quoteFinalList){
                            billingStatus = billingOutputList.get(objQuote.Opportunity__c);
                            billingStatus.add('Error');
                            billingStatus.add('Error occurred while processing information. Please try again or contact Installationforce Administrator');
                            billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                        }
                    } else if(!IsError) {
                        setMessage(true, 'Error occurred while processing information. Please try again or contact Installationforce Administrator');
                    }
                }
          }
        }//try
        catch(Exception ex)
        {
            Database.rollback(srInstallation);
            if (blMultiple)
            {
                for (BigMachines_Quote__c objQuote:quoteFinalList)
                {
                    billingStatus.add('Error');
                    billingStatus.add('Error occurred while processing information. Please try again or contact Installationforce Administrator');
                    billingOutputList.put(objQuote.Opportunity__c,billingStatus);
                }
            } else {
                setMessage(true, 'Error occurred while processing information. Please try again or contact Installationforce Administrator:' + ex);
            }
        } 
    system.debug('@@@@@-->'+newInstallationBilling);                
    }


    //Method which calculates and inserts values for the fields in 'Installation Billing' and 'Job Description' objects
    public void InsertData()
    {
        List<BigMachines_Quote__c> quoteListFinal=new List<BigMachines_Quote__c>{};
        IsConfirmed = true;
        List<Paperwork_Recieved_Details__c> lstPaperWorkDetails = new List<Paperwork_Recieved_Details__c>();
        Integer numberOfValidatedSAPaperWorks = 0;
        System.debug('--- QuoteIdList :' + QuoteIdList);
        /*
        Code added By Anshul
        The Query needs to retrieve extra fields for NIAS code generation purpose
        */
        //Retrieves the related Opportunity & Quote product and existing Job details for the CHI Lead and Quote  
        List<BigMachines_Quote__c> lstQuote = [select id, name, createdDate_quote__c,IsSystem__c, 
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
        Opportunity__r.Manual_Bill__c,
        Opportunity__r.Bill_to_Office__c,
        Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
        VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
        VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
        Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
        priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
        newTotalNetPrice_quote__c,
        (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null and Sales_Paperwork_Validated_Date__c <= :System.today()),
        (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
        (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
        (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false),
        Opportunity__r.Bill_Title__c,
        Opportunity__r.Bill_FirstName__c,
        Opportunity__r.Bill_LastName__c,
        Opportunity__r.Bill_Street__c,
        Opportunity__r.Bill_City__c,
        Opportunity__r.Bill_Post_Code__c,
        Opportunity__r.Bill_State__c,   
        Opportunity__r.Bill_Country__c,
        Opportunity__r.Account.Landlord_Account__c     
        from  BigMachines_Quote__c where 
        id In: quoteIdList and quote_reconciled__c =: True]; 


        //START: checks if the related Quote details exists, then create Installation Billing                
        if(lstQuote != null && lstQuote.size() > 0){
            
          //Retrieve NIAS codes for Quotes
           quoteNIASMap.clear();
           quoteNIASMap = NIASCodeHelper.GetNIASCodeMapByOpportunity(lstQuote);
           boolean isInvalidNIASCode = false;
           
           for (BigMachines_Quote__c Quote: lstQuote){
            
                isInvalidNIASCode = false;
                lstPaperWorkDetails = Quote.Paperwork_Recieved_Details__r;
                
                if(lstPaperWorkDetails!=null){
                    
                    numberOfValidatedSAPaperWorks = lstPaperWorkDetails.size();
                    
                } else {
                    
                    numberOfValidatedSAPaperWorks = 0;
                    
                }
               
               // Fix for adding validation for valid NIAS Code - Starts 
               // Modified on 11/04/2011 - To display the reason for invalid Nias code.
                
               if (quoteNIASMap.get(Quote.ID).isInvalidNIASCode){

                    isInvalidNIASCode = true;
                    String message='Job can not be sent for billing as invalid NIAS code is being generated. ';

                   if (quoteNIASMap.get(Quote.ID).ResourceType == null)
                        message = message + 'Please check the \'App Assigned To\' field on quote and \'Employee type\' for that employee. They should not be empty.';
                   else if (quoteNIASMap.get(Quote.ID).WorkType == null)
                        message = message + 'Please check the \'Pricebook Id\' field on quote, it should not be empty.';
                   else if (quoteNIASMap.get(Quote.ID).RegionCode == null)
                        message = message + 'Please check the \'Region\' field on the Job, it should not be empty.';
                   else if (quoteNIASMap.get(Quote.ID).PaymentCode == null)
                        message = message + 'Please check the Payment method on Quote if the payment is of Finance, otherwise check Payment method on CHI lead. They should not be empty.';
                   else
                        message = message + 'Please contact your support team for help.';
        
                   if (blMultiple) {
                        billingStatus.add('Error');
                        billingStatus.add(message);
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                    
                   }else {
                        setMessage(true, message);
    
                   }
                   
               }
               
               // Fix for adding validation for valid NIAS Code - Ends
               
                Boolean isJobNotInstalled = false;
                Boolean isJobNoInstallDate = false;
                system.debug('---Quote.Opportunity__r.Payment_Reference_Number__c---' +Quote.Opportunity__r.Payment_Reference_Number__c);
                if(Quote.Opportunity__r.Payment_Reference_Number__c != null){
                   Districtiden = Integer.valueof(Quote.Opportunity__r.Payment_Reference_Number__c.Substring(1,4));
                }
                else{
                if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('Payment Reference Number in  CHI Lead is not present.');
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                }else
                    setMessage(true, 'Payment Reference Number in  CHI Lead is not present.');
                }
                system.debug('--Districtiden--' +Districtiden);
                billingStatus=new List<String>{};
                //Start: Check the CHI Lead Status
                if(Quote.Opportunity__r.StageName == 'Suspended' || Quote.Opportunity__r.StageName == 'Expired'||Quote.Opportunity__r.StageName == 'Closed Lost'){
                    if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('CHI Lead is Closed Lost, Suspended or Expired.');
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                    }else
                    setMessage(true, 'CHI Lead is Closed Lost, Suspended or Expired.');
                }
                //End: Check for CHI Lead status is ending here.
                // Start: Checks the Quote Installation date.
                string[] distRange = system.label.NBBS_Geo_Range.split(',');
                
                if(Quote.createdDate_quote__c == null ){
                    if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('Quote Created Date(date on which quote was created within BigMachines) in Big machine quote is not present.');
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                    }else
                    setMessage(true, 'Quote Created Date(date on which quote was created within BigMachines) in Big machine quote is not present.');
                }
                
                else if(!(( Integer.valueOf(distRange[0])< Districtiden && Districtiden <Integer.valueOf(distRange[1])) ||(Integer.valueOf(distRange[2]) < Districtiden && Districtiden <Integer.valueOf(distRange[3]))|| (Integer.valueOf(distRange[4]) < Districtiden && Districtiden < Integer.valueOf(distRange[5])) )){
                if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('Payment Reference Number is not a Valid Number.');
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                    }
                    else
                    setMessage(true, 'Payment Reference Number is not a Valid Number.');
                }   
                else{
                    if(quote.Jobs__r.size() >0){
                        if(Quote.Opportunity__r.Installation_Date_Billing__c != null)
                        billingoverride = date.valueOf(Quote.Opportunity__r.Installation_Date_Billing__c); 
                        //Checks if Installation date exists for the Job
                        Date Installdate = getLowestInstallationDate(quote.Jobs__r);
                        if((Quote.Opportunity__r.Bill_Period__c == 'Before 04/01')){
                           Installdate = billingoverride;
                        }
                        if(Installdate == null || Installdate > System.today()){
                            isJobNoInstallDate = true;
                           
                           //isJobNoInstallDate = false;
                        }
                       System.debug('isJobNoInstallDate --->'+isJobNoInstallDate );
                  
                    //START: Job Completion date is a mandatory field
                    //-------------------------------------------------------
                    //UAT DEFECT FIX
                    //DEFECT ID:- 282
                    //DESC:- For contingency billing screen, job can be in future date
                    //if(isJobNoInstallDate == false)
                    system.debug('----isView->>>'+isView);
                    system.debug('----isJobNoInstallDate->>>'+isJobNoInstallDate);                    
                    if(isJobNoInstallDate == false || isView == true)
                    {
                        /** Check for "Override Billing checks" value in CHILead. If checked, will override all the conditions except 
                        the following:
                        a.  CHI Lead should have at least one Quote which should be Primary and Approved
                        b.  The Approved Quote should have at least one Job   */
                        //START: Check for "Override Billing checks" value in CHILead        
                        if(Quote.Opportunity__r.Override_Billing_checks__c == false || isView ==true){
                            if((numberOfValidatedSAPaperWorks > 0 || isView ==true) && (!isInvalidNIASCode || isView ==true)){
                               System.debug('blMultiple --->'+blMultiple);
                                    if (blMultiple )
                                        quoteListFinal.add(Quote);
                                        
                                    else{ 
                                            quoteListFinal.add(Quote);
                                            InsertOverridenData(quoteListFinal);
                                            System.debug('quoteListFinal--->'+quoteListFinal);
                                   }
                               }
                               
                            
                            //END: At least 1 Sales Paper Work record is mandatory
                            else if(!isInvalidNIASCode){
                                if (blMultiple ){
                                    billingStatus.add('Error');
                                    billingStatus.add('Quote does not have any validated sales paperwork or the date is in future.');
                                    billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                                }
                                else
                                    setMessage(true, 'Quote does not have any validated sales paperwork or the date is in future.');
                            }   
                        }
                        //END: Check for "Override Billing checks" value in CHILead
                        else
                        {
                            if (blMultiple)
                                quoteListFinal.add(Quote);
                            else
                            {   
                                    quoteListFinal.add(Quote);
                                    InsertOverridenData(quoteListFinal);
                            }
                        }
                    } 
                    //END: Job Completion date is a mandatory field
                    else if(!isInvalidNIASCode){   
                        if (blMultiple){
                            billingStatus.add('Error');
                            billingStatus.add('Job is having Installation date is in Future or it is blank.');
                            billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                        }
                        else
                            setMessage(true, 'Job is having Installation date is in Future or it is blank.');
                    }
                        
                }//END: Checks if all the jobs related to the Quote are of status "Installed"                  
                else{
                    if (blMultiple){
                        billingStatus.add('Error');
                        billingStatus.add('There is no job found associated with Quote.');
                        billingOutputList.put(Quote.Opportunity__c,billingStatus);  
                    }
                    else
                        setMessage(true, 'There is no job found associated with Quote.');
                }
                }
                
                numberOfValidatedSAPaperWorks = 0;
                
            }   
            //END: checks if the related Quote details exists, then create Installation Billing
            if (blMultiple){
                InsertOverridenData(quoteListFinal);
            }
        }
        else{
            setMessage(true, 'No quote found. Please try again or contact Installationforce Administrator');
        }
    }


    //Display all custom errors
    private void setMessage(Boolean isErr, String errorMsg){
        IsError = isErr;
        DisplayMessage = errorMsg;
        System.debug('Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£Â£ : ' + errorMsg);
    }
     
    public List<ServiceLineData> getServiceLineInformation(){
        List<ServiceLineData> servliceLineList = new List<ServiceLineData>();
        Double tempF = 0;
        Double tempD = 0;
        Double tempL = 0;
        Double tempNoVat = 0;
        Double tempnoVATnew  =0;
        
        ServiceLineData serviceDataObjD, serviceDataObjF,serviceDataObjL;
        
        for(Job_Description_Record__c jobDesc :lstJobDescriptionRecord){
            ServiceLineData serviceDataObj = new ServiceLineData();
            ServiceLineData serviceDataObj1 = new ServiceLineData();
            serviceDataObj.ShowVatAmount = false;
            serviceDataObj.ShowVatRate = false;
            serviceDataObj.ShowDiscount = false;
            serviceDataObj.hideservicecode = false;
            serviceDataObj1.hideservicecode = false;
            serviceDataObj.JobDescriptionBlock = jobDesc;
            //system.debug(serviceDataObj.SumVatAmount+'--serviceDataObj.SumVatAmount--');      
                                
            if(jobDesc.Vat_Code__c=='F'){
                serviceDataObj.VatAmount = newInstallationBilling.VAT_5_Amount__c /100;
                serviceDataObj.VatRate=5;
                serviceDataObj.ShowVatAmount = true;
                serviceDataObj.ShowDiscount = false ;
                serviceDataObj.ShowVatRate = true ;
                serviceDataObj.hideservicecode =true;
                tempF += jobDesc.First_Value__c / 100;
                serviceDataObj.SubTotal = tempF;
                serviceDataObjF = serviceDataObj;
            }
            else if(jobDesc.Service_Type__c == 'LD'){
                   // tempNoVat = (((Value  / (1+oldVat1))* 100))/100;
                   // tempnoVATnew = (((Value  / (1+newVat1))* 100))/100; 
                    system.debug('Tempnovat-->'+tempNoVat);
                    system.debug('tempnoVATnew-->'+tempnoVATnew);
            }
            
   
            /****************************************   Added for VAT Change    ***************************************
            **********************************************   Start               **************************************/
            else if(jobDesc.Vat_Code__c=='D' ||jobDesc.Vat_Code__c=='L'){
                system.debug('inside L& D');
                if(jobDesc.Vat_Code__c=='D'){
                    serviceDataObj.hideservicecode = true;
                    system.debug('Inside D');
                    serviceDataObj.VatAmount = oldVAT1Amount / 100;
                    serviceDataObj.VatRate=17.5;
                    serviceDataObj.ShowVatAmount = true;
                    serviceDataObj.ShowDiscount = true;
                    serviceDataObj.ShowVatRate = true ;
                    serviceDataObj.DiscountDisp = (((Value  / (1+oldVat1))* 100))/100;
                    SumDiscount = (((Value  / (1+oldVat1))* 100))/100;
                    tempD += newfirstvalue / 100;
                    serviceDataObj.SubTotal = tempD;
                    serviceDataObjD = serviceDataObj; 
                     
                    serviceDataObj1.VatAmount = newVAT1Amount / 100;
                    serviceDataObj1.hideservicecode = false;
                    serviceDataObj1.VatRate=20.0;
                    serviceDataObj1.ShowVatAmount = true;
                    serviceDataObj1.ShowDiscount = true;
                    serviceDataObj1.ShowVatRate = true ;
                    serviceDataObj1.DiscountDisp = (((newValue  / (1+newVat1))* 100))/100; 
                    SumnewDiscount = (((newValue  / (1+newVat1))* 100))/100; 
                    tempL += oldfirstvalue / 100;
                    serviceDataObj1.SubTotal = tempL;
                    serviceDataObjL = serviceDataObj1;  
                    system.debug('serviceDataObjL----->'+serviceDataObjL);
                    system.debug('serviceDataObjD----->'+serviceDataObjD);
                }
                
                else if(jobDesc.Vat_Code__c=='L'){
                    
                    system.debug('Inside L');
                    serviceDataObj.hideservicecode = true;
                    serviceDataObj.VatAmount = newVAT1Amount / 100;
                    serviceDataObj.VatRate=20.0;
                    serviceDataObj.ShowVatAmount = true;
                    serviceDataObj.ShowDiscount = true;
                    serviceDataObj.ShowVatRate = true ;
                    serviceDataObj.DiscountDisp = (((Value  / (1+newVat1))* 100))/100; 
                    SumnewDiscount = (((Value  / (1+newVat1))* 100))/100; 
                    tempL += newfirstvalue / 100;
                    serviceDataObj.SubTotal = tempL;
                    serviceDataObjL = serviceDataObj; 
                     
                    serviceDataObj1.VatAmount = oldVAT1Amount / 100;
                    serviceDataObj1.VatRate=17.5;
                    serviceDataObj1.hideservicecode = false;
                    serviceDataObj1.ShowVatAmount = true;
                    serviceDataObj1.ShowDiscount = true;
                    serviceDataObj1.ShowVatRate = true ;
                    serviceDataObj1.DiscountDisp = (((newValue  / (1+oldVat1))* 100))/100;
                    SumDiscount = (((newValue  / (1+oldVat1))* 100))/100;
                    tempD += oldfirstvalue / 100;
                    serviceDataObj1.SubTotal = tempD;
                    serviceDataObjD = serviceDataObj1;  
                }
                
            }
            /***********************************************   End Here  ************************************************/
                       
        } 
        
        // ----------------------------------------------------
        //Setting Discount for "D" type of Service line
        // 
        if(serviceDataObjD != null) servliceLineList.Add(serviceDataObjD);
        if(serviceDataObjF != null) servliceLineList.Add(serviceDataObjF);
        if(serviceDataObjL != null) servliceLineList.Add(serviceDataObjL);
        
        // ----------------------------------------------------
        
        //This is the VAT total amount which includes 17.5 and 5.0 VAT rate Amounts
            SumVatAmount = (oldVAT1Amount + newInstallationBilling.VAT_5_Amount__c) / 100;
            SumnewVATAmount = (newVAT1Amount + newInstallationBilling.VAT_5_Amount__c) / 100;
        //Discount Obtained on job description
      //  SumDiscount = tempNoVat;
      //  SumnewDiscount = tempnoVATnew;
        system.debug('SumDiscount-->'+SumDiscount); 
        system.debug('SumnewDiscount-->'+SumnewDiscount);
        // sum of subtotal of VAT Code Type F, D and Null - Discount
        SubTotalDisp= tempD + tempF;
        SubnewTotalDisp = tempL +tempF;
        system.debug('SubTotalDisp-->'+SubTotalDisp); 
        system.debug('SubnewTotalDisp-->'+SubnewTotalDisp); 
        BillTotal = oldbilltotal / 100;
        NewBillTotalshow = newbilltotal/100;
        system.debug('BillTotal-->'+BillTotal); 
        system.debug('NewBillTotalshow-->'+NewBillTotalshow); 
        return servliceLineList;
    }
    
    //Returns true if job description record would be generated for passed Quote
    private Boolean isJobDescRecordTobeGenerated(BigMachines_Quote__c quote)
    {
        Boolean retVal = false;
        if(isView || (!isView && Quote.Opportunity__r.Manual_Bill__c != 'Yes'))
        {
            if(Quote.discountsTotalOnPricing__c >0.00 ||Quote.priceMatchDifference__c < 0 || Quote.ISpec_Difference__c <0)
            {
                //LD record would be created
                retVal = true;
            }
            if(Quote.VAT_17_5_Total_Amount__c !=0.00 && Quote.VAT_17_5_Total_Amount__c >0.00)
            {
                retVal = true;
            }
             if (Quote.VAT_5_Total_Amount__c !=0.00 && Quote.VAT_5_Total_Amount__c >0.00)
            {
                retVal = true;
            }
        }
        system.debug('--retVal' + retVal);
        return retVal;
    }
      
}