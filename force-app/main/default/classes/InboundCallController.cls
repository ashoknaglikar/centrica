/*
This class checks the call type and navigates to the specific page.
*/


public with sharing class InboundCallController
{
    public Account accountSearch{get; set;} 
    public Integer WorkflowType;
    public Boolean leadNumberExist = false;
    public Boolean recordExist;
    public Boolean OppNotClosed;
    private String LeadNumber='';
    private CallMode objCallMode; 
    public DisplayMode objDisplay{get;set;}
    private MessageConstants errorMsg;
    String errMsg;
    public Opportunity[] opp {get;set;}
    Inbound_Call__c call;
    //public Boolean ConfirmAccountAddress{get; set;}
     // Ashok CHI Conversion Variable Declaration start :: 26/11/10
    public list<Lead> propspects = new List<Lead>();
    // Ashok CHI Conversion Variable Declaration End 
  
    //Ashok G to find lead exists or not
    public Boolean existingLead{get;set;}
    //declaration End
    //CODE ADDED
    //DATE:- May 3, 2012
    //DESCIRPTION: Additional variables for Production holding    
    private String customerUCRN, customerUCRNCode;
    public List<CustomerUCRNSelectionData> CustomerDetails {get; set;} 
    private Boolean isUserEnabledForProductHolding = false;
    public Boolean skipProductHolding {get; set;}
    public String houseNumber {get; set;}
    public String houseName {get; set;}
    public String poBoxNumber {get; set;}
    public boolean startCall{get;set;}
    //----------------------------------------------------------------
    
    public boolean newInbound {get;set;}
    
    MessageConstants msgConstants = new MessageConstants();

    public InboundCallController()
    {
    	showContact = false;
    	startCall = true;
        addressBlock = true;
        newInbound = System.currentPageReference().getParameters().get('sfdc.tabName')== system.label.newInboundTabId ? true: false;
        
        //ConfirmAccountAddress=false;
        OppNotClosed=false;
        accountSearch = new Account();
        objCallMode = new CallMode();
        objDisplay = new DisplayMode();
        errorMsg = new MessageConstants();
        errMsg = '';
        existingLead = false;//added by Ashok G
        
        //CODE ADDED -----------------------------------------------------
        //DATE:- July 17, 2012
        //DESCIRPTION: Enable Product Holding for  
        User user = [select id, EnabledForProductHolding__c from User where id = :UserInfo.getUserId()];
        
        if(user.EnabledForProductHolding__c != null)
        {
            isUserEnabledForProductHolding = user.EnabledForProductHolding__c;
        }
        skipProductHolding = false;
        //----------------------------------------------------------------
    }
    
    public String getLeadNumber(){
        return this.LeadNumber;
    }   
    public void setLeadNumber(String leadNumber){
        this.LeadNumber=leadNumber.trim();
    }
    
    //++ Inbound call PRB00010961 changes starts
    public void CorrectBillingStreet(){
         String billingStreet = accountSearch.BillingStreet;
         if(billingStreet.contains('\r\n')){
                billingStreet = billingStreet.replace('\r\n', ' ');
         }
         //To remove extra spaces
         billingStreet = billingStreet.replaceAll('(\\s+)', ' ');
         accountSearch.BillingStreet = billingStreet;
    }
    //-- Inbound call PRB00010961 changes ends
    
     // Call Type : Customer Call   
    public PageReference InvokeCustomerCall()
    {
        // First validate the data
        if(ValidateData()) 
        {    
            // First check for the Lead Number 
            if(leadNumberExist)
            {
                // If Lead number is valid, Call Type is Existing Customer
                if(CheckLeadNumber())
                {
                    WorkflowType = objCallMode.CUSTOMERCALLEXISTCUST;
                    return InvokeWorkflow();
                }
                else
                {
                     setErrorMsg();       
                }
            }
            // Check for the existing Lead Address
            else
            {   
                //if(ConfirmAccountAddress)
                //{
                        // If Lead address is valid, Call Type is Existing Customer
                    if(CheckLeadAddress())
                    {
                         WorkflowType = objCallMode.CUSTOMERCALLEXISTCUST;   
                    }
                    // If prospect Exists then , show prospect record
                    /*else if(CheckProspectAdd())
                    {   
                        system.debug('Inside Ashoks if');
                        WorkflowType = objCallMode.CUSTOMERCALLNEWCUST; 
                        return Prospectdisplay();
                    }*/
                    // If Lead address is not valid, Call Type is New Customer
                    else
                    {
                        WorkflowType = objCallMode.CUSTOMERCALLNEWCUST;  
                    }
                    return InvokeWorkflow();
                /*}
                else
                {
                        errMsg = errorMsg.ERR_CONFIRMADDRESS;
                                setErrorMsg();
                } */      
            }
        }
        // For invalid data
        else
        {
            setErrorMsg();
        }
        return null;
    }
    
    // Call Type : Engineer Call
    public PageReference InvokeEngineerCall()
    {
    // First validate the data
        if(ValidateData()) 
        {    
            // First check for the Lead Number 
            if(leadNumberExist)
            {
                // If Lead number is valid, Call Type is Existing Engineer 
                if(CheckLeadNumber())
                {
                    WorkflowType = objCallMode.ENGINEERCALLEXISTCUST;
                    return InvokeWorkflow();
                }
                else
                {
                     setErrorMsg();       
                }
            }
            // Check for the existing Lead Address
            else
            {
                /*if(ConfirmAccountAddress)
                {*/
                        // If Lead address is valid, Call Type is Existing Engineer 
                        if(CheckLeadAddress())
                        {
                             WorkflowType = objCallMode.ENGINEERCALLEXISTCUST;   
                        }
                        // If prospect Exists then , show prospect record
                        /*else if(CheckProspectAdd())
                        {   
                            system.debug('Inside Ashoks if');
                            WorkflowType = objCallMode.ENGINEERCALLNEWCUST; 
                            return Prospectdisplay();
                        }*/
                        // If Lead address is not valid, Call Type is New Engineer 
                        else
                        {
                            WorkflowType = objCallMode.ENGINEERCALLNEWCUST;   
                            //setErrorMsg();       
                        }
                        return InvokeWorkflow();
                /*}
                else
                {
                        errMsg = errorMsg.ERR_CONFIRMADDRESS;
                                setErrorMsg();
                } */
            }
        }
        // For invalid data
        else
        {
            setErrorMsg();
        }
        return null;

    }
    
    // Call Type: Employee Call
    public PageReference InvokeEmployeeCall()
    {
        // First validate the data
        if(ValidateData()) 
        {    
            // First check for the Lead Number 
            if(leadNumberExist)
            {
                // If Lead number is valid, Call Type is Existing Employee
                if(CheckLeadNumber())
                {
                    WorkflowType = objCallMode.EMPLOYEECALLEXISTCUST;
                    return InvokeWorkflow();
                }
                else
                {
                     setErrorMsg();       
                }
            }
            // Check for the existing Lead Address
            else
            {   
                /*if(ConfirmAccountAddress)
                {*/
                        // If Lead address is valid, Call Type is Existing Employee
                        if(CheckLeadAddress())
                        {
                             WorkflowType = objCallMode.EMPLOYEECALLEXISTCUST;
                        }
                          // If prospect Exists then , show prospect record
                        /*else if(CheckProspectAdd())
                        {   
                            system.debug('Inside Ashoks if');
                            WorkflowType = objCallMode.EMPLOYEECALLNEWCUST; 
                            return Prospectdisplay();
                        }*/
                        // If Lead address is not valid, Call Type is New Employee
                        else
                        {
                            WorkflowType = objCallMode.EMPLOYEECALLNEWCUST;   
                            //setErrorMsg();       
                        }
                        return InvokeWorkflow();
                /*}
                else
                {
                        errMsg = errorMsg.ERR_CONFIRMADDRESS;
                                setErrorMsg();
                }*/
            }
        }
        // For invalid data
        else
        {
            setErrorMsg();
        }
        return null;
    }
    
    
    // Call Type: HSA Call 
    public PageReference InvokeHSACall()
    {
        try
        {
            // First validate the data
            if(ValidateData()) 
            {    
                System.debug('### inside validate data...');
                // First check for the Lead Number 
                if(leadNumberExist)
                {
                    System.debug('### inside leadnum exist...');
                    // If Lead number is valid, Call Type is Existing HSA 
                    if(CheckLeadNumber())
                    {
                        System.debug('--Opp---'+opp[0].AccountId);
                            
                        for(Opportunity allOpp:[Select o.StageName, o.CHI_Lead_Id__c From Opportunity o  where o.accountId=: opp[0].AccountId])
                        {
                            System.debug('--inside for---');
                            if(allOpp.StageName != 'Closed Lost')
                            {
                                OppNotClosed = true;
                            }                           
                        }
                        System.debug('--OppNotClosed---'+OppNotClosed);
                        if(OppNotClosed)
                        {
                            WorkflowType = objCallMode.HSACALL;
                            return InvokeWorkflow();
                        }
                        else
                        {
                            //errMsg = errorMsg.ERR_NOACTIVEOPP;
                            errMsg = 'All the leads are Closed Lost. Please enter the active lead number.';
                            System.debug('--err msg---'+errMsg);
                            setErrorMsg();
                        }
                    }
                    else
                    {
                         setErrorMsg();       
                    }
                }
                // Check for the existing Lead Address
                else
                {
                    System.debug('### else part of Lead num exist...');
                   /* if(ConfirmAccountAddress)
                    {*/
                            System.debug('### else..inside confirm acc address...');
                            // If Lead address is valid, Call Type is Existing HSA 
                            if(CheckLeadAddress())
                            {
                                 System.debug('### else..inside check lead address...');
                                 WorkflowType = objCallMode.HSACALL;
                                 return InvokeWorkflow();
                            }
                            // If Lead address is not valid, error message should be displayed. 
                            else
                            {
                                System.debug('### else..sles of check lead address...display error for HSA ');
                                errMsg = errorMsg.ERR_HSANOLEADFORADDRESS;
                                setErrorMsg(); 
                                return null;      
                            }                           
                       /* }
                    else
                    {
                        errMsg = errorMsg.ERR_CONFIRMADDRESS;
                        setErrorMsg();
                    }*/
                }
            }
            // For invalid data
            else
            {
                setErrorMsg();
            }
        }
        catch(Exception e)
        {
            System.debug('###*** Exception: '+e);
        }
        return null;
    }

    
    // Call Type : Waste Call
    public PageReference InvokeWasteCall()
    {
        String tempPostCode = accountSearch.BillingPostalCode;
        
        WorkflowType = objCallMode.WASTECALL;
        
        // Check if lead exist
        if(CheckLeadNumber())
        {       
            return InvokeWorkflow();
        }
        
        return InvokeWorkflow();
        return null;
    }
    
    
    // This methods validate the Lead Number and Address data
    public Boolean ValidateData()
    {
        CorrectBillingStreet();
        Boolean retVal = true;
        System.debug('## Lead number--> '+LeadNumber );
        if(LeadNumber == null || LeadNumber == '')
        {
            retVal = false;
            leadNumberExist = false;
        }
        else
        {
            leadNumberExist = true;
        }
        System.debug('## Lead number exist--> '+leadNumberExist);
        System.debug('## accountSearch == null ->' + (accountSearch == null));
        System.debug('## retVal--> '+retVal);
        
        String tempPostCode = accountSearch.BillingPostalCode;
        System.debug('## tempPostCode--> '+tempPostCode);
        
        if(!retVal && (tempPostCode == null || tempPostCode == ''))
        {            
            retVal = false;
            errMsg = errorMsg.ERR_NOLEADNUMBERADDRESS;            
        }
        else
        {
            String tempStreet = accountSearch.BillingStreet;
            System.debug('## ELSE PART tempStreet--> '+tempStreet);
            System.debug('## leadNumberExist--> '+leadNumberExist);
            if(!leadNumberExist && (tempStreet == null || tempStreet == '' ||tempStreet.trim().length() == 0))
            {            
                retVal = false;
                errMsg = errorMsg.ERR_NOSTREET;
               // setErrorMsg();
            }
            else
            {
                retVal = true;
            }
       } 
       
       if(accountSearch.BillingState.length()>20)
       {
            retVal = false;
            errMsg = errorMsg.ERR_STATELENGTH;
       }  
        System.debug('## return retVal--> '+retVal);
        return retVal;
    }
    
     // This method checks for the existing lead number
    public Boolean CheckLeadNumber()
    {
        //CODE MODIFIED
        //DATE:- May 3, 2012
        //DESCRIPTION:- Two new fields (o.Account.CustomerUCRN__c, o.Account.ProductHoldingLastUpdated__c, o.Account.CustomerUCRNCode__c) added to below query
        //opp = [select o.Id, o.AccountId, o.Account.BillingStreet, o.Account.BillingPostalCode, o.Account.CustomerUCRN__c, o.Account.CustomerUCRNCode__c, o.Account.ProductHoldingLastUpdated__c from Opportunity o where o.CHI_Lead_Id__c =:LeadNumber limit 1];
        //PRB00013945 - fix to not allow expired lead to be re-used
        opp = [select o.StageName, o.Id, o.AccountId, o.Account.BillingStreet, o.Account.BillingPostalCode, o.Account.CustomerUCRN__c, o.Account.CustomerUCRNCode__c, o.Account.ProductHoldingLastUpdated__c from Opportunity o where o.CHI_Lead_Id__c =:LeadNumber and o.StageName!='Expired' limit 1];
        //---------------------------------------------------  
        
        if(opp.size() > 0)
            return true;    
        else
         {  
          errMsg = errorMsg.ERR_INVALIDLEADNUMBER;
          return false;
         }
    }

    List<Account> lstAccounts;
    // This method checks for the existing lead address    
    public Boolean CheckLeadAddress()
    {
            //opp = [Select o.Id, o.AccountId from Opportunity o where o.Install_Postcode__c =:accountSearch.BillingPostalCode and o.Install_Address_Street__c =:accountSearch.BillingStreet and o.Install_Address_City__c =:accountSearch.BillingCity  and o.Install_Address_County__c =:accountSearch.BillingState limit 1];
            
            //------------------------------------------------------
            //Modification made to handle data where BillingStreet is less than 8 characters.
            CorrectBillingStreet();
            String AccountName = accountSearch.BillingPostalCode.trim() + ' ';
            String str2 = accountSearch.BillingStreet.trim(); // 2 space in between
            //Modified the length for PRB00016664
            /*if( str2.length() > 8) 
                AccountName += str2.substring(0,8).trim(); // 2 space in between*/
            if( str2.length() > 29) 
                AccountName += str2.substring(0,29).trim(); // 2 space in between
            else
                AccountName += str2;
            System.debug('-------------- AccountName = ' + AccountName);    
            
            //------------------------------------------------------
            //CHANGE REQUEST: If an Account entered with the provided address but there is no lead associated with that Account then need to delete that account
            //opp = [Select o.Id, o.AccountId,o.Account.Name from Opportunity o where o.Account.Name=:AccountName limit 1]; // 37 ms
            opp = new List<Opportunity>();
            
            //CODE MODIFIED
            //DATE:- May 3, 2012
            //DESCRIPTION:- Two new fields (CustomerUCRN__c, ProductHoldingLastUpdated__c) added to below query
            lstAccounts = [Select a.ID, CustomerUCRN__c, CustomerUCRNCode__c, ProductHoldingLastUpdated__c, BillingPostalCode, BillingStreet,BillingState,BillingCountry,BillingCity , (Select Id,StageName, Account.BillingPostalCode, Account.BillingStreet, Account.CustomerUCRN__c, Account.CustomerUCRNCode__c, Account.ProductHoldingLastUpdated__c, Name,CreatedDate, Product_Interest__c From Opportunities) From Account a where a.Name=:AccountName limit 1];
            //-------------------------------            
            System.debug('-------------- lstAccounts = ' + lstAccounts);
            if(lstAccounts != null && lstAccounts.size() > 0)
            {
                opp = lstAccounts[0].Opportunities;
            }
            
            if(lstAccounts != null && lstAccounts.size() > 0 && lstAccounts[0].Opportunities != null && lstAccounts[0].Opportunities.size() > 0){
                boolean flag = false; 
                for(Opportunity o:opp)
                {
                    if(o.StageName != 'Closed Lost' && o.StageName != 'Expired')
                    {
                        flag = true;
                    }
                    if(flag== true)
                        break;
                }
                /*if(flag == false)
                {
                    if(CheckProspectAdd())
                    {
                        return false;
                    }
                }*/
            
                return true;
            }
            else
            {
                if(lstAccounts != null && lstAccounts.size() > 0)
                {
                    //Account exists but no related lead exist
                    lstAccounts[0].Notes__c = 'Account exists with no Lead';
                    //Code fix done by BGSAMS Support as part of PRB00006452 - starts
                    //delete lstAccounts[0]; // junk data - delete it
                    //Code fix done by BGSAMS Support as part of PRB00006452 - ends
                }
                return false;
            }
    }
    // Ashok CHI Conversion proj Prospect Search Begin :: 26/11/10
    // this method will fetch prospect details from the address given.
    public boolean CheckProspectAdd()
    {
        system.debug('in Ashoks method');
        CorrectBillingStreet();
        String AccountName = accountSearch.BillingPostalCode.trim() + '  ';
        String str2 = accountSearch.BillingStreet.trim(); // 2 space in between
         
       // if( str2.length() > 8) 
        //  AccountName += str2.substring(0,8).trim(); // 2 space in between
       // else
            AccountName = AccountName+str2;
        system.debug('in Ashoks method--->AccountName+'+AccountName);
        //propspects = Database.query('Select Id,Account_Key_Calc__c From Lead where Account_Key_Calc__c ='+'\''+AccountName.trim()+'\'');          
        propspects = [Select Id,Account_Key_Calc__c From Lead where Account_Key_Calc__c =:AccountName and (Status != 'Closed' and Status != 'Qualified')  and Lead_Type__c = 'Prospect'];
        
        if(propspects.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    
    public PageReference Prospectdisplay()
    {
        system.debug('Prospectdisplay--->');
        String pageUrl= '';
        
        StartCall(0);
       
        pageUrl = '/apex/ProspectPage';
        PageReference PageRef = new PageReference(pageUrl + '?c=' + call.Id+'&first='+call.Id);
        PageRef.setRedirect(true);
        return PageRef;  
    }
    // Ashok CHI Conversion proj Prospect Search END 
    // This method creates a call   
    // 
     // This method creates a call   
    public void StartCall(Integer oppSize)
    {
        call = new Inbound_Call__c();
        call.Start_Date_Time__c = System.now();
        call.Workflow_Step__c = 0;
        call.Workflow_Type__c = WorkflowType;
        
        System.debug('-------------- call.Workflow_Type__c = ' + call.Workflow_Type__c);
        
        call.Billilng_Country__c = accountSearch.BillingCountry;
        call.Billing_City__c = accountSearch.BillingCity;
        call.Billing_State__c = accountSearch.BillingState;
        call.Billing_Street__c = accountSearch.BillingStreet;
        call.Billing_Zip__c = accountSearch.BillingPostalCode;
          
        if(oppSize > 0)
        {
            call.CHI_Lead__c = opp[0].ID;     
            call.Related_To__c = 'CHI Lead';
        }
               
        try
        {
            insert call;
        }
        catch(Exception e)
        {
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();            
        }
                      
       
    }
      
    public void setErrorMsg()
    {
    	System.debug('###Error msg-->'+errMsg);
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }
    
    boolean isUCRNPresent = false;
    
    public PageReference InvokeWorkflow()
    {
        String pageUrl= '';
        CorrectBillingStreet();
        
        //check if customer has UCRN no.
        //Boolean isUCRNPresent = checkCustomerUCRNDetails();
        //Boolean isUCRNAvailable = true;
        if(WorkflowType == objCallMode.EMPLOYEECALLEXISTCUST || WorkflowType==objCallMode.ENGINEERCALLEXISTCUST || WorkflowType == objCallMode.CUSTOMERCALLEXISTCUST){
           existingLead = True;
        }
        
        if(WorkflowType == objCallMode.WASTECALL)
        {
           
            pageUrl = '/apex/wastecallpage';
        }
        else if(!newInbound || existingLead)
        {
            pageUrl = '/apex/WorkflowPage';
            
        }else{
             pageUrl = '/apex/WorkflowPageNew';
        }
        
        if(newInbound && skipUCRNSelection && !existingLead) // Added to redirect to new Workflow page..on skip button press.
        pageUrl = '/apex/WorkflowPageNew';
        
       
        
        if(!skipUCRNSelection && !isUCRNPresent /*&& !existingLead */&& WorkflowType != objCallMode.WASTECALL  && isUserEnabledForProductHolding && System.label.PH_Switch == 'on')
        {
            string postcode = accountSearch.BillingPostalCode.replaceall(' ','').trim();
            newProductHoldingClass obj = new newProductHoldingClass();
            string loginIdKey = obj.loginDetails();
            newProductHoldingClass.postcodeReposnse objPCResp=  obj.getAllAddress(loginIdKey, postcode);
            //newProductHoldingClass.postcodeReposnse objPCResp=  obj.getAllAddress(obj.loginDetails(), 'G781AH');
            system.debug('objPCResp---');
            list<string> addressId  = new list<string>();
            integer i = 0;
            if(objPCResp!=null && objPCResp.addresses!=null && objPCResp.addresses.size()>0)
            {
                for(newProductHoldingClass.Addresses add: objPCResp.addresses)
                {
                    if(i<=5 && (houseNumber!= null && houseNumber!='' && add.firstLine.toUpperCase().contains(houseNumber.toUpperCase())) || (houseName!=null && houseName != '' && add.firstLine.contains(houseName.toUpperCase())) || (poBoxNumber!=null && poBoxNumber!='' && add.firstLine.contains(poBoxNumber.toUpperCase())))
                    {
                        addressId.add(add.Id);
                        i++;
                    }
                }
            }
            //list<productHoldingReponseClass> allResponses;
            //list<CustomerUCRNSelectionData> custdataList ;
            if(addressId.size()>0)
            {
                //allResponses = new list<productHoldingReponseClass> ();
                //custdataList = new  list<CustomerUCRNSelectionData>();
                for(string s: addressId)
                {
                    loginIdKey = obj.loginDetails();
                    if(loginIdKey!=null)
                    {
                    productHoldingReponseClass objresponse = obj.getProductHoldingByAddressId(loginIdKey,s);
                    system.debug('Response-->'+objresponse);
                    integer matchValue =0;
                    string addressstring = '';
                    if(objresponse!=null)
                    {
                       if(objresponse.address!= null)
                       {
                           matchValue = 0; 
                           for(productHoldingReponseClass.Address add : objresponse.address)
                           {
                               system.debug('Address -->'+add);
                               
                               if(add.houseNumber!= null && houseNumber!= null &&  add.houseNumber.touppercase()==houseNumber.touppercase() ||
                                add.postcode!= null && accountSearch.BillingPostalCode!= null && add.postcode.touppercase()==accountSearch.BillingPostalCode.touppercase() ||
                                add.houseName!=null && houseName!= null && add.houseName.touppercase() == houseName.touppercase() ||
                                add.flatNumber!=null && houseNumber!= null && add.flatNumber.touppercase() == houseNumber.touppercase())
                                {    
                                   matchValue++;
                                }
                                addressstring += add.flatnumber!=null? add.flatnumber:' ';
                                addressstring += add.houseNumber!=null? add.houseNumber:' ';
                                addressstring += add.street!=null ? add.street:' ';
                                addressstring += add.postcode!=null?add.postcode:'';
                              
                               system.debug(addressstring);
                               system.debug(add.flatnumber!=null? add.flatnumber:'****');
                               
                           }
                           
                           system.debug('matchValue-->'+matchValue);
                           if(matchValue<2)
                           continue;
                           else
                           {
                               CustomerDetails = new list<CustomerUCRNSelectionData>();
                               for(productHoldingReponseClass.People ple : objresponse.people)
                               {
                                system.debug('-->'+ple);   
                                CustomerUCRNSelectionData singleCust = new CustomerUCRNSelectionData();
                                singleCust.UCRN = s;
                                singleCust.FirstName = ple.name;
                                singleCust.Address = addressstring;
                                if(existingLead!=null)
                                singleCust.existingLead = string.valueof(existingLead);
                                CustomerDetails.add(singleCust);
                                
                                PageReference pageRef = Page.CustomerUCRNSelection;
                                pageRef.getParameters().put('e','1');
                                return pageRef;
                               }
                           }
                       }
                       
                      
                    }
                    
                    }
                    
                }
            }
            
            
            
            
            //system.debug('*************>'+obj.getProductHoldingByAddressId(obj.loginDetails(),objPCResp.addresses[0].Id));

        }
        
        StartCall(opp.size());
        pageURL += '?c=' + call.Id + '&existingLead=' + existingLead+'&ucrn='+customerUCRN+'&new='+newInbound;
        //CODE MODIFIED ENDS --------------------------------------------------------
        PageReference PageRef = new PageReference(pageURL);
        PageRef.setRedirect(true);
        return PageRef;   
    }
    
    
    public class CustomerUCRNSelectionData
    {
        //public britishgasCoUkEnterpriseParty.Customer CustomerInfo {get; set;}    
        public String UCRN {get; set;}
        public String FirstName {get; set;}
        public String LastName {get; set;}
        public String Address {get; set;}
        public String SchemeID {get; set;}
        public String SchemeAgencyID {get; set;}
        public string existingLead {get;set;}
    }
    
    //parse account adderss to detect houseno./ housename/ pobox number
    
    
    //invoked when agent selects a customer profile. The selected UCRN is updated with the current Account
    public PageReference selectUCRN()
    {
        String ucrn = Apexpages.currentPage().getParameters().get('cUCRN');
        //String ucrncode = Apexpages.currentPage().getParameters().get('scAID');
        
        //update account with selected ucrn
        if(opp != null && opp.size() > 0 && opp[0].Account != NULL)
        {
            Account acc = opp[0].Account;
            
            if(acc.CustomerUCRN__c != ucrn)
            {
                //new UCRN is selected; mark all existing product holding records with current account as OLD
                //WorkflowHelper.markOldProductHoldingRecords(acc.Id, null);
                //acc.CustomerUCRN__c = ucrn;
                //acc.CustomerUCRNCode__c = ucrncode;
                
                acc.BuildingNo__c = houseNumber;
                acc.HouseName__c = houseName;
                acc.POBoxNumber__c = poBoxNumber;
                
                acc.ProductHoldingLastUpdated__c = Date.today();
                update acc;
            }
               
        }
        
        this.customerUCRN = ucrn;
        //this.customerUCRNCode = ucrncode;
        
        isUCRNPresent = true;
        //navigate user to call workflow next screen
        return InvokeWorkflow();
    }
    
    private Boolean skipUCRNSelection = false;
    public PageReference skipProfileSelection()
    {
        skipUCRNSelection = true;
        return InvokeWorkflow();
    }
    
    /*
    	*****************************************************************************
    	************************ UKB Script Changes**********************************
    	*****************************************************************************
    */
    
    
    
    public boolean addressBlock{get;set;}
    
    public integer mode {get;set;}
    
    public CallMode CallMode{get; set;}
    
    public DisplayMode DisplayMode{get; set;}
    
    public list<Contact> contact {get;set;}
    
    public Opportunity oppurtunitySelect {get;set;}
    
    public list<oppClass> opportunityClassList {get;set;}
    
    public boolean showContact {get;set;}
    
    public list<Appointment__c> appList {get;set;}
    
  
    
    public void InvokeCommerialCall()
    {
		
		 // First validate the data
		startCall = false;  
        if(ValidateData()) 
        {    
             // First check for the Lead Number 
            if(leadNumberExist)
            {
                // If Lead number is valid, Call Type is Existing Customer
                if(CheckLeadNumber())
                {
                    mode = 3;
                    queryData();
                   
                }
                else
                {
                	 startCall = true;  
                     setErrorMsg();       
                }
                
            }
            // Check for the existing Lead Address
            else
            {   
               	
                if(commercialGeographyChecker() )
                {
                	initalizeVariables();
                	if(CheckLeadAddress() && opp.size()>0)
                	{
                		mode = 1;
                		opportunityClassList = new list<oppClass>();
                		if(lstAccounts.size()>0)
                		accountSearch = lstAccounts[0];
                		for(Opportunity op : opp)
                		{
                			//if(op.StageName != 'Closed Won' && op.StageName != 'Closed Lost')
                			{
                				
                				opportunityClassList.add(new oppClass(op));
                				errMsg =msgConstants.ERR_NOOPPORTUNITYSELECTED;
                			}
                		}
                		
                	}else
                	{
                		
                		for(Contact c:contact)
                		{
                		c.MailingStreet = accountSearch.BillingStreet;
                		c.MailingState=accountSearch.BillingState;
                		c.MailingPostalCode=accountSearch.BillingPostalCode;
                		c.MailingCountry= accountSearch.BillingCountry;
                		}
                		mode = 2;
                	}
                	system.debug('Mode -->'+mode);
                     
                }
               
                // If Lead address is not valid, Call Type is New Customer
                else
                {
                   startCall = true;  
                   setErrorMsg();
                }
               
              
            }
               
        }else{
        	startCall = true; 
        	setErrorMsg();
        }
        //return null;   	
    }
    
    public boolean commercialGeographyChecker()
    {
    	string postcodeSector = accountSearch.BillingPostalCode.trim().substring(0,accountSearch.BillingPostalCode.length()-2);
    	list<Postcode_Sector__c> pc = [select id, NotAvailableFor__c from Postcode_Sector__c where Name = :postcodeSector and Type__c = 'Sales'];
    	
    	if(pc.size()>0 && pc[0].NotAvailableFor__c!=null && pc[0].NotAvailableFor__c.contains('Small Commercial'))
    	{
    		system.debug('I am in if + '+pc[0].NotAvailableFor__c);
	    	errMsg = 'This is outside of Small Commercial trial.';	
	    	return false;
    	}
    	else
    	{
    		system.debug('I am in else');
    		return true;
    	}
    	
    }
    
    private void initalizeVariables()
    {
    	contact= new list<Contact>();
    	for(integer i = 0;i<=2;i++)
    	{
    		contact.add(new contact());
    	}
    	
		oppurtunitySelect = new Opportunity();
		opportunityClassList = new list<oppClass>();
		appList = new List<Appointment__c>();
    }
    
    public class oppClass
    {
    	public boolean isSelect {get;set;}
    	public Opportunity opp{get;set;}
    	
    	public oppClass(Opportunity opp)
    	{
    		this.opp=  opp;
    	}
    }
    
    public pagereference exitInbound()
    {
    	pagereference p = new pagereference ('/apex/'+system.label.CommercialScript);
    	p.setredirect(true);
    	
    	return p;
    	
    }
    
    public void contiueBtnMethod()
    {
    	integer selectedOpp =0;
    	for(oppClass oppInstance : opportunityClassList)	
    	{
    		
    		if(oppInstance.isSelect!=null && oppInstance.isSelect)
    		{
    			selectedOpp++;
    			
    			
    			oppurtunitySelect = oppInstance.opp;
    			queryData();
    		}
    		 
    	}
    	if(selectedOpp!=1)
    	{
    		errMsg ='Please select one Opportunity to continue';
    		setErrorMsg();
    	}else if(oppurtunitySelect != null)
    	{
    		mode = 3;
    	}
    	
    	
    	
    	
    	
    }
    
    public pagereference createRecords()
    {
    	
    	if(!oppValidation() || !contactValidation())
    	return null;
    	
    	try{
		accountSearch.name = 'Unknown';
    	upsert accountSearch;
    	
    	list<Contact> upsertList = new list<Contact>();
    	
    	for(Contact cobj : contact)
    	{
    		if(cobj.lastName != null)
    		{
	    		cobj.AccountId = accountSearch.Id;
	    		upsertList.add(cobj);
    		}
    		
    		
    		
    		
    	}
    	
    	upsert upsertList;
    	
    	for(Contact cobj : upsertList)
    	{
    		if(cobj.Primary_contact__c)
    		{
    			
    			accountSearch.Primary_contact__c = cobj.Id;
    			
    		}
    	}
    	
    	upsert accountSearch;
    	
    	Campaign campignRecord = [Select Id from Campaign where Name = 'Small Commercial'];
    	
    	oppurtunitySelect.Name = 'Unknown';
    	oppurtunitySelect.StageName = 'Active';
    	oppurtunitySelect.CloseDate = system.today().adddays(90);
    	oppurtunitySelect.Visit_Type__c = 'Sales';
    	oppurtunitySelect.CampaignId = campignRecord.id;
    	
    	oppurtunitySelect.Bill_Title__c = contact[0].Salutation;
        oppurtunitySelect.Bill_FirstName__c = contact[0].FirstName;
        oppurtunitySelect.Bill_LastName__c = contact[0].LastName;
        oppurtunitySelect.Bill_Street__c = contact[0].MailingStreet;
        oppurtunitySelect.Bill_City__c= contact[0].MailingCity;
        oppurtunitySelect.Bill_State__c= contact[0].MailingState;
        oppurtunitySelect.Bill_Post_Code__c= contact[0].MailingPostalCode;
        oppurtunitySelect.Bill_Country__c    = contact[0].MailingCountry;
    	
    	
    	oppurtunitySelect.accountId = accountSearch.Id;
    	if(oppurtunitySelect.Product_Interest__c == null)
    	oppurtunitySelect.Product_Interest__c = 'Small Commercial';

        oppurtunitySelect.Latest_Customer_Category__c = 4;
        if(oppurtunitySelect.Is_the_customer_vulnerable__c == 'Yes')
        oppurtunitySelect.Latest_Customer_Category__c = 1;    
        else if(oppurtunitySelect.Is_the_customer_s_boiler_working__c == 'No' && oppurtunitySelect.Does_the_customer_have_hot_water__c == 'No')
        oppurtunitySelect.Latest_Customer_Category__c = 2;
        else if(oppurtunitySelect.Is_the_customer_s_boiler_working__c == 'No' )
        oppurtunitySelect.Latest_Customer_Category__c = 3;
        



    	upsert oppurtunitySelect;
    	opp.add(oppurtunitySelect);
    	mode = 3;
    	queryData();
    	}catch (exception e)
    	{
    		
    	}
    	
    	return null;
    	
    }
    
    public pagereference salesAptBtn()
    {
    	pagereference page = new pagereference ('/apex/availability?var_OpptyId='+  
                oppurtunitySelect.ID+'&var_Source=CS&view=null&var_date=null&var_contactId='
                +accountSearch.Primary_contact__c);
                
        return page;        
    }
    
    public void queryData()
    {
    	if(opp.size()>0)
    	{
    		
    	oppurtunitySelect = [select id , Name, Job_Type__c, Type_of_Boiler__c,  Boiler_Model__c, High_Priority__c, 
    						Boiler_Size__c, Total_number_of_boilers_onsite__c,  Number_Of_Radiators__c, Number_of_boilers_in_scope_to_replace__c,
    						Type_of_Heater__c,Description_of_Work_Required__c,Number_of_Additional_Appliances__c,Fuel_Type__c, Boiler_Make__c, 
    						Does_the_customer_have_hot_water__c,Is_the_customer_s_boiler_working__c,Is_the_customer_vulnerable__c, Product_Interest__c, Commercial_Indicator__c,CHI_Lead_Id__c from Opportunity where id =:opp[0].Id];
    	accountSearch = [select id,Name, BillingState, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, Primary_Contact__c from Account where Id = :opp[0].AccountId ];
    	contact = [Select id, Salutation, FirstName, lastName, MobilePhone, Phone, Email, MailingStreet, MailingState,MailingCity ,  MailingPostalCode, MailingCountry, Email__c,
    					  Primary_contact__c from Contact where AccountId = :accountSearch.Id order by Primary_Contact__c  DESC];
    	appList = [Select a.BM_Salesperson__c,a.Opportunity__c,a.Visit_Date__c, a.Time_Band__c,Type__c, a.Status__c, a.Name, a.Id, a.Assigned_To__r.Primary_Role__c, a.Assigned_To__c,a.Call_Notes__c,a.Start_Time__c,a.End_Time__c, a.Bring_forward_visit__c  from Appointment__c a where Opportunity__c = :oppurtunitySelect.Id and  Status__c = 'Appointed' and Type__c = 'Sales' Order By Start__c Desc ];
    	
    	}
    	
    }
    
    public void validateOpp()
    {
    	If(!oppValidation())
    	{
    		system.debug('I am here + oppValidation');
    		return;
    	}
    	
    	
    	checkOpp();
    	
    	
    	
    }
    
    public void checkOpp()
    {
    	if(oppurtunitySelect.Boiler_Size__c > 40 || oppurtunitySelect.Number_of_boilers_in_scope_to_replace__c >1 || oppurtunitySelect.Number_Of_Radiators__c >14 || oppurtunitySelect.Number_of_Additional_Appliances__c >1 ||
    	oppurtunitySelect.Total_number_of_boilers_onsite__c>1 || oppurtunitySelect.Fuel_Type__c!= 'Natural Gas' || oppurtunitySelect.Type_of_Heater__c == 'Heater')
    	{
    		errMsg ='This Lead is not eligible for HA visit & needs to be surveyed by CIM, please use Commercial BAU process';
    		setErrorMsg();
    		showContact = false;
    		
    	}else
    	{
    		showContact = true;
    	}
    	
    }
    
    public void createNew()
    {
    	list<Opportunity> updatelist=  new list<Opportunity>();
    	for(oppClass oppClass : opportunityClassList)
    	{
	    	if(oppClass.opp.StageName!= 'Closed Won' && oppClass.opp.StageName!= 'Closed Lost')
	    	{
	    	oppClass.opp.StageName = 'Closed Lost';
	    	oppClass.opp.Stage_Reason_CHICR__c  = 'Auto Close Via Script';
	    	oppClass.opp.By_Pass_User_Validation__c  = true;
	    	updatelist.add(oppClass.opp);
	    	}
    	}
    	update updatelist;
    	
    	oppurtunitySelect = new Opportunity();
    	contact = new list<Contact>();
    	for(integer i = 0;i<=2;i++)
    	{
    		Contact c  = new contact();
    		c.MailingStreet = accountSearch.BillingStreet;
    		c.MailingState=accountSearch.BillingState;
    		c.MailingPostalCode=accountSearch.BillingPostalCode;
    		c.MailingCountry= accountSearch.BillingCountry;
    		contact.add(c);
    	}
    	
    	mode = 2;
    	
    	
    }
    
    private boolean  oppValidation()
    {
    	string isMandatory =' field is mandatory.';
    	errMsg = null;
    	if(oppurtunitySelect.Job_Type__c == null )
    	{
    		errMsg ='Job Type '+isMandatory;
    		setErrorMsg();
    	}
    	
    	if(oppurtunitySelect.Total_number_of_boilers_onsite__c== null)
    	{
    		errMsg ='Total number of boilers onsite'+isMandatory;
    		setErrorMsg();
    	}
    	
    	if(oppurtunitySelect.Number_of_boilers_in_scope_to_replace__c== null)
    	{
    		errMsg ='Number of boilers in scope to replace '+isMandatory;
    		setErrorMsg();
    		
    	}
    	
    	if(oppurtunitySelect.Description_of_Work_Required__c== null)
    	{
    		errMsg ='Description of work required '+isMandatory;
    		setErrorMsg();
    		
    	}
    	if(errMsg != null)
    	{
    		return false;
    		
    	}else  	
    	return true;
    	
    }
    
    private boolean contactValidation()
    {
    	string isMandatory =' field is mandatory for contact captured';
    	errMsg = null;
    	integer primaryCount =0;
    	boolean nocontactFilled = true;
    	for(Contact c: contact)
    	{
    		if(c.LastName != null)
    		{
    			nocontactFilled = false;
	    		if(c.MobilePhone == null && c.OtherPhone ==null)
	    		{
	    			errMsg ='Mobile Number or Work Phone field'+isMandatory;
	    			setErrorMsg();
	    		
	    			
	    		}
	    		if(c.Email__c == null)
	    		{
	    			errMsg ='Email field'+isMandatory;
	    			setErrorMsg();
	    			
	    		}
	    		if(c.Contact_type__c == null)
	    		{
	    			errMsg ='Contact Type field'+isMandatory;
	    			setErrorMsg();
	    			
	    		}
	    		
	    		if(c.Primary_Contact__c)
	    		primaryCount ++;
    		
    		}
    	}
    	
    	
    	if(nocontactFilled)
    	{
    		errMsg = 'Atleast one primary conact needs to be captured.';
    		setErrorMsg();
    	}
    	if(primaryCount != 1)
    	{
    		errMsg = 'One primary contact needs be captured.';
    		setErrorMsg();
    	}
    	
    	if(errMsg != null)
		return false;
		else
		return 
		true;
    	
    }
    
    
    
  
}