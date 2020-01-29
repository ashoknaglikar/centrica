public class WorkflowPageController 
{
    public Workflow.WorkflowInfo WorkflowInfo {get; set;}
    public Workflow CurrentWorkflow {get; set;}
    public CallMode CallMode{get; set;}
    public DisplayMode DisplayMode{get; set;}
    public boolean checkProfile{get;set;}
    //changes for IPD 3653 end   - dated 2/18/2013
    public List<contactInfo> newcontactsInfo{get;set;}
    public boolean shownewContacts{get;set;}
    public boolean showUpdateContacts{get;set;}
    public List<contact> updatecon{get;set;}
    //changes for IPD 3653 end   - dated 2/18/2013
    public Boolean autoPopulate{get;set;}
    //public Static String TestData {get; set;}
    public boolean var{get;set;}
    //public boolean uexist{get;set;}
    public Boolean showRefreshProducttHolding {get; set;} // added on May 30, 2012 Boolean to indicate whether to show the Refresh product holding data button on page
    String callID;
    
    private Boolean refreshProductHoldingData; //added on May 14, 2012 for indicating whether to refresh Product holding information
    private MessageConstants errorMsg;
    String errMsg;
    String MessageFWA='';
    
    
    //Changes for Wrap up Screen  starts bY Ashok G
    public String existingLead{get;set;}
    //Declaration End
    String ucrn = '';
    
    productHoldingReponseClass objresponse;
    public string acceptBttnClr{get;set;}
    public string optOutBttnClr{get;set;}
    public void closePopup() {
        var = false;
        
    }
    
    
    public List<PicklistWrapper> getPicklistValues() {
        List<PicklistWrapper> picklistValues=new List<PicklistWrapper>();
        
        picklistValues = new List<PicklistWrapper>();    
        Schema.DescribeFieldResult fieldResult = Opportunity.Marketing_Preferences__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            picklistValues.add(new PicklistWrapper(f.getLabel(),f.getValue(), false));
        }       
        
        return picklistValues;
    }
    
    public WorkflowPageController()
    {  
        WorkflowInfo = new Workflow.WorkflowInfo();
        List<PicklistWrapper> picVal = getPicklistValues();
        WorkflowInfo.picklistValues = picVal;
        //uexist=false;
        acceptBttnClr=optOutBttnClr='#b3e000';
        
        /*
        Group g = [select id,name,(Select Id, UserOrGroupId From GroupMembers) from group where name='Straightswap Direct'];
        for(GroupMember gm:g.GroupMembers){
            if(gm.UserOrGroupId == UserInfo.getUserID())
                uexist = TRUE;
        }
        */
        errorMsg = new MessageConstants();
        autopopulate = false;
        //changes for IPD 3653 end   - dated 2/18/2013
        shownewContacts=false;
        showUpdateContacts=false;
        newcontactsinfo= new List<contactInfo> ();
        updatecon = new List<contact>();
        //changes for IPD 3653 end   - dated 2/18/2013
        User usr = [select id, EnabledForProductHolding__c, isGDAEnabled__c,Profile.Name from User where id = :USerInfo.getUserID() limit 1];
        String userProfileName = usr.Profile.Name;
        if(userProfileName == 'System Administrator')
            checkProfile = True;
        else
            checkProfile = false; 
        //WorkflowInfo.ShowProductHoldingInfo = True;
        showRefreshProducttHolding = false; 
        refreshProductHoldingData = false; //added on May 14, 2012 for indicating whether to refresh Product holding information
        errMsg = '';
        MessageFWA = 'From the information you have given me I can pass your details onto our chosen specialist in the field who can then contact you and arrange an appointment.\nMay I do this for you?Which is the best number to contact you on?\n\nNote: Please capture in the Query Sheet if the boiler is operational and if the customer has Homecare.\n\n';
        callID = System.currentPageReference().getParameters().get('c');
        // CR Ashok Fetching Prospects record
        string LeadId = System.currentPageReference().getParameters().get('p');
        //CR END
        String exitAppointment = System.currentPageReference().getParameters().get('e'); // to exit from appointment  
        
        existingLead = System.currentPageReference().getParameters().get('existingLead'); //to know lead exists or not
        system.debug('######existingLead'+existingLead);
        
        WorkflowInfo.newInbound = System.currentPageReference().getParameters().get('new')== 'true'?true:false;
        
        
        // ++ Added for Priority Installations CR start
        WorkflowInfo.include_priority_install = true;
        // -- Added for Priority Installations CR end
        //++ Added to find exisiting or new lead By Ashok G
        WorkflowInfo.existingLead= existingLead;
        //-- End
        CallMode = new CallMode();
        DisplayMode = new DisplayMode();
        
        System.debug('-----------exitAppointment----------'+exitAppointment);
        
        // to exit from appointment
        if(exitAppointment != null && exitAppointment != '')
        {
            WorkflowInfo.exitAppointment = exitAppointment; // to exit from appointment
            System.debug('-----------WorkflowInfo.exitAppointment----------'+WorkflowInfo.exitAppointment);
            
        }
        
        if(callID != null && callID != '')
        {
            WorkflowInfo.Call = new Inbound_Call__c();
            WorkflowInfo.Call = WorkflowHelper.getCallByCallID(callID);
        }
        
        //added on August 7, 2012
        //description: detect if user is not activated for product holding
        
        if(usr.EnabledForProductHolding__c == true)
        {
            WorkflowInfo.ProductHoldingEnabled = true;
        }
        if(usr.isGDAEnabled__c)
            WorkflowInfo.isGDAEnabled = true;
        
        //
        if(WorkflowInfo.Call!= null)
        {
            Integer mode =  WorkflowInfo.Call.Workflow_Type__c.intValue();
            System.debug('---------- mode = ' + mode);
            CurrentWorkflow = WorkflowFactory.GetWorkFlow(mode);
            System.debug('---------- set workflow data' + (CurrentWorkflow == null));
            WorkflowInfo.WorkflowType = mode;
            
            
            WorkflowInfo = CurrentWorkflow.SetWorkflow(WorkflowInfo);
            
            //CODE ADDED ------------------------------------------------------------
            //DATE:- May 10, 2012
            //DESCRIPTION:- Code to handle SAP PI calls and data processing 
            //String ucrnMode = Apexpages.currentPage().getParameters().get('uc');
            ucrn = Apexpages.currentPage().getParameters().get('ucrn');
            
            //WorkflowInfo.HouseName = Apexpages.currentPage().getParameters().get('h');
            //WorkflowInfo.HouseNumber = Apexpages.currentPage().getParameters().get('hn');
            //WorkflowInfo.PoBoxNumber = Apexpages.currentPage().getParameters().get('po');
            
            if(ucrn!=null && ucrn != 'null' && ucrn.trim() != '')
            {
                WorkflowInfo.CustomerUCRN = ucrn;
                //WorkflowInfo.CustomerUCRNAgencyCode = Apexpages.currentPage().getParameters().get('scAID');
                //check if UCRN is available on Account
                this.refreshProductHoldingData = true;  
                //showRefreshProducttHolding = true;
                
                newProductHoldingClass obj = new newProductHoldingClass();
                string loginIdKey = obj.loginDetails();
                objresponse = obj.getProductHoldingByAddressId(loginIdKey,ucrn);
                system.debug('Response--->'+objresponse);
                if(objresponse!= null && (existingLead != 'true' || WorkflowInfo.newInbound ))
                    
                {
                    handleNewProductHolding(objresponse);
                }
                
            }
            System.debug('------------- workflowpagecontroller = ' + WorkflowInfo);
            //CODE ADDITION ENDS ----------------------------------------------------
            
            // MGM Change starts
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  WorkflowInfo.Opportunities'+WorkflowInfo.Opportunities);
            List<Opportunity> lstOpp = WorkflowInfo.Opportunities;
            /*
if(lstOpp!=null){
if(lstOpp.size()==1 && lstOpp[0].ID!=null){
List<Opportunity> tempOppList=[Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c
From Opportunity o where o.ID=:lstOpp[0].ID]; //,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
WorkflowInfo.Opportunities = tempOppList;


// ++ Added for Priority Installations CR start
if((WorkflowInfo.Opportunities[0].CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)){
WorkflowInfo.include_priority_install = true;
}else{
WorkflowInfo.include_priority_install = false;
}
// -- Added for Priority Installations CR end

}
}*/
            
            //CODE ADDED ------------------------------------------------------------
            //DATE:- May 14, 2012
            //DESCRIPTION:- Code to retrieve Product Holding data
            
            /*
System.debug('---------- 1showRefreshProducttHolding = ' + showRefreshProducttHolding);
Account currentAccount = WorkflowInfo.CurrentAccount;

if(WorkflowInfo.ProductHoldingEnabled &&
currentAccount != null && currentAccount.id != null && 
currentAccount.customerUCRN__c != null && currentAccount.customerUCRN__c.equalsIgnoreCase(ucrn) == true)
{
System.debug('-------------- bsd = ' + ucrn);
List<ProductHolding__c> lstProductInfo = [select Account__c,BestTimeToCall__c,
BoilerBreakdownHistory__c, CreditRating__c, Status__c,
LengthOfTimeProductHeld__c, NumberOfExistingProperties__c, 
CustomerTypeOrMarketingCode__c,DateOfInstallation__c,DateOfLastCertification__c,
DateOfPreviousQuotes__c,ElectricityAnnualSpend__c,ElectricityIsCurrentCustomer__c,
ElectricityMonthlySpend__c,ExistingFinanceProducts__c,GasAnnualSpend__c,
GasIsCurrentCustomer__c,GasMonthlySpend__c,Id,IsCurrentCustomerOfAnyProduct__c,
IsCustomerHasCavityWallInsulation__c,IsCustomerHasLoftInsulation__c,IsDeleted,
IsExistingPropertiesHaveCentralHeating__c,IsParent__c,IsPartTimeOrNightWorker__c,
IsVulnerableCustomer__c,LastModifiedById,LastModifiedDate,MakeOfBoiler__c,
ModelOfBoiler__c, Name,NumberOfPreviousQuotes__c,ServiceCover__c,QuoteDetails__c,
GasPaymentMethod__c, ElectricityPaymentMethod__c, IsPetOwner__c,
GasAccount__c, ElectricityAccount__c, ServiceProducts__c,
(select id, Type__c, Name, MonthlySpend__c, ProductHolding__c, PaymentMethod__c from ProductHoldingAccounts__r)  
FROM ProductHolding__c where Account__c =:currentAccount.id and Status__c = 'Current'];

system.debug('------lstProductInfo------' +lstProductInfo);

if(lstProductInfo != null && lstProductInfo.size() > 0)
{
WorkflowInfo.ProductHoldingInfo = lstProductInfo[0];

WorkflowInfo.ProductHoldingAccounts = WorkflowInfo.ProductHoldingInfo.ProductHoldingAccounts__r;

WorkflowInfo.ShowProductHoldingInfo = true;

refreshProductHoldingData = false;

//Added 30 May 2012 condition to check the boolean showRefreshProducttHolding 
if(WorkflowInfo.CurrentAccount.ProductHoldingRefresh__c == 'true')
{
showRefreshProducttHolding = true;
}
}
}
System.debug('---------- 2showRefreshProducttHolding = ' + showRefreshProducttHolding);
// MGM Change ends
System.debug('  --------------WorkflowInfo.CurrentAccount------------'+WorkflowInfo.CurrentAccount);
System.debug('---------- workflow data et done');

*/
            
        }
        
    }
    
    //------------------------------EVENT HANDLERS
    public void BtnContinue_Click()
    {
        
        try{
            
            clearMessages(); //clear error messages
            if(showUpdateContacts){
                updateContacts();}
            //do action
            system.debug('Green Deal-->2'+WorkflowInfo.isGDAEnabled);
            WorkflowInfo = CurrentWorkflow.Continue_Click(WorkflowInfo); 
            
            //IF error occurred display error message
            if(WorkflowInfo.IsError) setPageErrors();
        }catch(Exception e){
            throw ( e);
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
        }       
        
    }
    
    public Pagereference  BtnCreateLead_Click() 
        
    {
        try{
            clearMessages(); //clear error messages
            //do action
            
            if(WorkflowInfo.include_priority_install)
                populateCustCategoryDetails();
            
            // ++ Added for CR#869 start
            /*if(WorkflowInfo.Opportunities[0].Preferred_appointment_day__c == null || WorkflowInfo.Opportunities[0].Preferred_appointment_time__c == null)
{
errMsg = errorMsg.ERR_PREFERRED_OPTIONS;
setErrorMsg();
return null ;
}*/
            
            // ++ Aded for Gas Council change start
            if((WorkflowInfo.gasCouncil1 != null &&  WorkflowInfo.gasCouncil1 != '') && (WorkflowInfo.gasCouncil2 != null && WorkflowInfo.gasCouncil2 != '') && (WorkflowInfo.gasCouncil3 != null && WorkflowInfo.gasCouncil3 != '' ) && system.label.GasCouncilNumber == 'on')
            {
                String gasSafeNumber = WorkflowInfo.gasCouncil1 + WorkflowInfo.gasCouncil2 + WorkflowInfo.gasCouncil3;
                if(!(gasSafeNumber.isNumeric()))
                {
                    errMsg = errorMsg.ERR_GAS_COUNCIL;
                    setErrorMsg();
                    return null ;
                    
                }
                
            }
            
            
            // ++ Aded for Gas Council change start
            
            WorkflowInfo = CurrentWorkflow.CreateLead_Click(WorkflowInfo);
            
            if(WorkflowInfo.Opportunities[0].Referral_Employee__c != null && WorkflowInfo.Opportunities[0].Referral_Employee__r.Group__c == 'SMRT')
            {
                system.debug('WorkflowInfo.Opportunities[0].Referral_Employee__r.Group__c'+WorkflowInfo.Opportunities[0].Referral_Employee__r.Group__c);
                var = true;
                
            }
            
            //WorkflowInfo = CurrentWorkflow.CreateLead_Click(WorkflowInfo);
            
            
            //IF error occurred display error message
            if(WorkflowInfo.IsError) 
            {
                setPageErrors();
                return null;
            }/*else if(WorkflowInfo.Opportunities[0].Product_Interest__c == 'Telesales Combi' || WorkflowInfo.Opportunities[0].Product_Interest__c == 'Telesales Conventional' || WorkflowInfo.Opportunities[0].Product_Interest__c == 'Straight Swap')
{
return new pagereference ('/apex/StraightSwapQuestions?oppId='+WorkflowInfo.Opportunities[0].Id+'&PID='+WorkflowInfo.Opportunities[0].Product_Interest__c+'&Ecall='+workflowInfo.ShowEngineerQues);
}*/
            else if(WorkflowInfo.CurrentAccount.Gas_Supply_At_Address1__c == 'Yes' && WorkflowInfo.Opportunities[0].Boiler_type__c == 'Combi boiler' && WorkflowInfo.CurrentAccount.Number_of_Bathrooms__c <= 2 /*&& WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' */&& WorkflowInfo.newInbound  /*&& uexist*/ &&
                    WorkflowInfo.Opportunities[0].Location_of_Current_Boiler__c!='Bathroom' && WorkflowInfo.Opportunities[0].Location_of_Current_Boiler__c!='Loft' && WorkflowInfo.Opportunities[0].Location_of_Current_Boiler__c!='Cellar' && WorkflowInfo.Opportunities[0].Location_of_Current_Boiler__c!='Boiler room'){
                        system.debug(LoggingLevel.INFO,'I am Inside Straigh swap direct');
                        return new pagereference ('/apex/StraightSwapDirect?oppId='+WorkflowInfo.Opportunities[0].Id+'&PID='+WorkflowInfo.Opportunities[0].Product_Interest__c+'&new='+workflowInfo.newInbound);
                    }
            else if(WorkflowInfo.showApp)
            {
                return new pagereference ('/apex/captureLandlordDetails?edit=1&source=IC&chiLeadId='+WorkflowInfo.Opportunities[0].Id+'&accId='+WorkflowInfo.CurrentAccount.Id+'&existingLead='+existingLead+'&new='+workflowInfo.newInbound);
            }else    
            {
                return CurrentWorkflow.SalesAppointment_Click(WorkflowInfo);
            } 
            
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            
            
        }
        return null;
        
    }
    
    
    public pagereference BtnCreateNewLead_Click()
    {
        try{
            clearMessages(); //clear error messages
            //do action
            Workflow.WorkflowInfo info = WorkflowInfo;
            System.debug('---------- calling create new lead');
            info = CurrentWorkflow.CreateNewLead_Click(info);
            
            System.debug('---------- calling create new lead');
            handleNewProductHolding(objresponse);
            
            //IF error occurred display error message
            System.debug('--------------- info.IsError = ' + info.IsError);
            if(info.IsError) setPageErrors();
            WorkflowInfo = info;
            if(WorkflowInfo.newInbound)
            {
                pagereference p = new pagereference ('/apex/WorkflowPageNew?c=' + callID + '&existingLead=' + WorkflowInfo.existingLead+'&ucrn='+ucrn+'&new='+WorkflowInfo.newInbound);
                p.setredirect(true);
                return p;
            }
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
        return null;
    }
    
    public Pagereference BtnSaveCustCategoryDetails_Click(){
        
        try{
            
            clearMessages(); //clear error messages
            
            //do action
            
            
            // ++ Added for Priority Installations CR start
            populateCustCategoryDetails();
            // -- Added for Priority Installations CR end
            
            
            WorkflowHelper.ValidateOpportunity(WorkflowInfo);
            if(WorkflowInfo.IsError) 
                setPageErrors();  
            else
            {
                Database.update(WorkflowInfo.Opportunities);
                
                if(WorkflowInfo.ProductHoldingInfo != null && WorkflowInfo.ProductHoldingInfo.id != null)
                    Database.update(WorkflowInfo.ProductHoldingInfo);
            }
            
        }catch(Exception excp){
            
            Apexpages.addMessages(excp);
            
        }
        
        return null;
        
    }
    
    public Pagereference BtnSalesAppointment_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // MGM Change Starts
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
                                         o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
                                         o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];//,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
            WorkflowInfo.Opportunities = lstOpps;
            
            //do action
            return CurrentWorkflow.SalesAppointment_Click(WorkflowInfo);
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
    }
    
    public Pagereference BtnNewSalesAppointment_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // ++ Added for updating Priority Questions on CHI Lead start
            if(WorkflowInfo.include_priority_install)
                populateCustCategoryDetails();
            // -- Added for updating Priority Questions on CHI Lead end
            
            // MGM Change Starts
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
                                         o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
                                         o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];//,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
            WorkflowInfo.Opportunities = lstOpps;
            
            return CurrentWorkflow.NewSalesAppointment_Click(WorkflowInfo);
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
    }
    
    public Pagereference BtnCancelAppointment_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // MGM Change Starts
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
                                         o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
                                         o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];//,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
            WorkflowInfo.Opportunities = lstOpps;
            
            return CurrentWorkflow.CancelAppointment_Click(WorkflowInfo);
            
            //IF error occurred display error message
            //if(WorkflowInfo.IsError) setPageErrors();
        }catch(Exception e){
            System.debug('###*** Exception in cancel appointment: '+e.getCause());
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
    }
    
    public Pagereference BtnRearrangeAppointment_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // ++ Added for updating Priority Questions on CHI Lead start
            if(WorkflowInfo.include_priority_install)
                populateCustCategoryDetails();
            // -- Added for updating Priority Questions on CHI Lead end
            
            // MGM Change Starts
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
                                         o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
                                         o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Customer_agreed_to_appointment__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];
            WorkflowInfo.Opportunities = lstOpps;
            
            //do action
            return CurrentWorkflow.ReArrangeAppointment_Click(WorkflowInfo);
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
    }
    
    public PageReference BtnBookSurveyAppointment_Click()
    {/*

try{
clearMessages(); //clear error messages

// MGM Change Starts
update WorkflowInfo.Opportunities[0];
List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Customer_agreed_to_appointment__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c
From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];//,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
WorkflowInfo.Opportunities = lstOpps;

//do action
return CurrentWorkflow.BookSurveyAppointment_Click(WorkflowInfo);

}catch(Exception e){
errMsg = errorMsg.ERR_PROCESSINGRECORDS;
setErrorMsg();
return null;
}*/
        return null;
        
    }
    
    public Pagereference BtnWrapUpCall_Click()
    {
        try{
            clearMessages(); //clear error messages
            //do action
            // MGM Change Starts
            
            // ++ Added for validation on Vulnerable reason start
            populateCustCategoryDetails();
            if(WorkflowInfo.include_priority_install && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes' && (WorkflowInfo.Opportunities[0].Vulnerable_reason__c == null || WorkflowInfo.Opportunities[0].Vulnerable_reason__c == '' || WorkflowInfo.Opportunities[0].Vulnerable_reason__c == 'Not applicable'))
            {
                errMsg = errorMsg.ERR_ENTER_VULNERABLE_REASON;
                setErrorMsg();
                return null;
            }
            
            // -- Added for validation on Vulnerable reason end
            
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,GDCashBack__c,
                                         o.Latest_customer_category__c, o.Account.CustomerUCRN__c,o.WithCustomer__c ,o.Nectar_Number__c,o.WithCustReasons__c,o.Gas_Council_Number__c, 
                                         o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];//,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c
            WorkflowInfo.Opportunities = lstOpps;
            
            return CurrentWorkflow.WrapCall_Click(WorkflowInfo);
            
        }catch(Exception e){
            System.debug('Exception thrown 1');
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        } 
    }
    
    public Pagereference BtnWasteCall_Click()
    {
        try{
            clearMessages(); //clear error messages
            return CurrentWorkflow.WasteCall_Click(WorkflowInfo);
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        } 
    }
    
    public void BtnCreatePayment_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // MGM Change Starts
            update WorkflowInfo.Opportunities[0];
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Ecogen_Propostioned__c,o.Customer_Interested_In_Ecogen__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,
                                         o.Latest_customer_category__c,o.WithCustomer__c,o.Nectar_Number__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Keeping_current_boiler_in_same_place__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:WorkflowInfo.Opportunities[0].Id];
            WorkflowInfo.Opportunities = lstOpps;
            
            WorkflowInfo = CurrentWorkflow.CreatePayment_Click(WorkflowInfo);           
            if(WorkflowInfo.IsError) setPageErrors();           
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            
        } 
    }
    
    //Returns a message is Product interest type is "FWA".
    public List<String> getMessageFWAArray(){
        List<String> messageList = new List<String>();
        
        if(MessageFWA.trim().length()!=0){
            messageList=MessageFWA.split('\\n');
        }
        return messageList;
    }
    
    //Sets errors in page
    private void setPageErrors()
    {
        System.debug('WorkflowInfo == null ----> ' + WorkflowInfo);
        for(String msg :WorkflowInfo.Messages)
        {
            Apexpages.addMessage(new Apexpages.Message( Apexpages.Severity.ERROR, msg ));
        }
        
    }
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }
    
    private void clearMessages()
    {
        WorkflowInfo = CurrentWorkflow.Initialize(WorkflowInfo);
        WorkflowInfo.DisplayPaymentMessage = false; // To avoid display of Payment creation alert message.
    }
    
    /*
Method populates respective customer category details based on 
response of questions submitted by user
*/
    
    private void populateCustCategoryDetails(){
        
        WorkflowInfo.Opportunities[0].Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
        WorkflowInfo.Opportunities[0].Customer_Category_Modified_Datetime__c = DateTime.now();
        WorkflowInfo.Opportunities[0].Last_customer_cat_info_update_source__c = 'SGC';
        WorkflowInfo.Opportunities[0].Stage_object_type__c = 'CHI Lead';
        WorkflowInfo.Opportunities[0].Stage_object_id__c = WorkflowInfo.Opportunities[0].id;
        if(WorkflowInfo.Opportunities[0].Id != null)
            WorkflowInfo.Opportunities[0].pending_update_to_customer_category__c = true;
        if(WorkflowInfo.customerCateogryType == '0')
        {
            if (WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes'){
                WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c = 'Not applicable';
                WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c = 'Not applicable';
            }
            if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No'){
                WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c = 'Not applicable';
            }
            if(WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c != 'Yes'){
                WorkflowInfo.Opportunities[0].Vulnerable_reason__c = '';
            }
            
            
            
            if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes'){
                WorkflowInfo.Opportunities[0].Latest_customer_category__c = 4;
            }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes'){
                WorkflowInfo.Opportunities[0].Latest_customer_category__c = 2;
            }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'Yes' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'No'){
                WorkflowInfo.Opportunities[0].Latest_customer_category__c = 3;
            }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes' && 
                     WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'Yes' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes'){
                         WorkflowInfo.Opportunities[0].Latest_customer_category__c = 2;
                     }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes' && 
                              WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'Yes' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'No'){
                                  WorkflowInfo.Opportunities[0].Latest_customer_category__c = 3;
                              }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes' && 
                                       WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes'){
                                           WorkflowInfo.Opportunities[0].Latest_customer_category__c = 1;
                                       }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'Yes' && 
                                                WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'No'){
                                                    WorkflowInfo.Opportunities[0].Latest_customer_category__c = 2;
                                                }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && 
                                                         WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'Yes' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes'){
                                                             WorkflowInfo.Opportunities[0].Latest_customer_category__c = 2;
                                                         }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && 
                                                                  WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'Yes' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'No'){
                                                                      WorkflowInfo.Opportunities[0].Latest_customer_category__c = 3;
                                                                  }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && 
                                                                           WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'Yes'){
                                                                               WorkflowInfo.Opportunities[0].Latest_customer_category__c = 1;
                                                                           }else if(WorkflowInfo.Opportunities[0].Is_the_customers_boiler_working__c == 'No' && WorkflowInfo.Opportunities[0].Does_the_customer_have_hot_water__c == 'No' && 
                                                                                    WorkflowInfo.Opportunities[0].Customer_have_any_other_form_of_HEAT__c == 'No' && WorkflowInfo.Opportunities[0].Is_the_customer_vulnerable__c == 'No'){
                                                                                        WorkflowInfo.Opportunities[0].Latest_customer_category__c = 2;
                                                                                    }else{
                                                                                        WorkflowInfo.Opportunities[0].Latest_customer_category__c = 99;
                                                                                    }
        }
        
    }
    
    
    //Added 30 May 2012 Method to refresh the product holding data
    //Argumrnt : pagereference
    //Result : refreshes the product holding with the latest Data from SAP PI and returns to same page   
    public void BtnRefreshPH_click()
    {
        /*
System.debug('-------------BtnRefreshPH_click1 dml exhausted : '  + Limits.getDmlStatements());
//invoke SAP PI web service to retrieve Product Holding details


//if product holding do not exist currently create new
if(WorkflowInfo.ProductHoldingInfo == null) 
{
WorkflowInfo.ProductHoldingInfo = new ProductHolding__c(Status__c = 'Current');
}

// invoke SAP PI web service to refresh data

System.debug('-------------BtnRefreshPH_click 2 dml exhausted : '  + Limits.getDmlStatements());

ProductHoldingData productHoldingData = RefreshProductHoldingDataService.refreshProductHoldingData(WorkflowInfo, WorkflowInfo.CurrentAccount);
//changes for IPD 3653 begin - dated 2/11/2013
processResponse(productHoldingData);
//changes for IPD 3653 end - dated 2/11/2013
if(refreshProductHoldingData == true && WorkflowInfo.ProductHoldingEnabled)
{
WorkflowInfo.ProductHoldingInfo = productHoldingData.ProductHolding;
WorkflowInfo.ProductHoldingAccounts = productHoldingData.ProductHoldingAccounts;

if(WorkflowInfo.ProductHoldingAccounts.size() <= 0)
{
WorkflowInfo.ProductHoldingAccounts = null;
}

WorkflowInfo.ShowProductHoldingInfo = true;

//upsert product holding record
if(WorkflowInfo.ProductHoldingInfo != null)
{
WorkflowInfo.ShowProductHoldingInfo = true;

//WorkflowInfo.ProductHoldingInfo.Account__c = WorkflowInfo.CurrentAccount.Id; 
//upsert WorkflowInfo.ProductHoldingInfo;

system.debug('----------- WorkflowInfo.ShowProductHoldingInfo = ' + WorkflowInfo.ShowProductHoldingInfo);
}

refreshProductHoldingData = false;
}
*/
        
    }
    
    public pagereference BtnGreenDeal_Click()
    {
        try{
            clearMessages(); //clear error messages
            
            // ++ Added for updating Priority Questions on CHI Lead start
            if(WorkflowInfo.include_priority_install)
                populateCustCategoryDetails();
            update WorkflowInfo.Opportunities[0];
            // -- Added for updating Priority Questions on CHI Lead end
            
            //do action
            return(new pagereference('/apex/availability?gDeal=1&&var_Source=IC&view=null&var_date=null&var_contactId='+WorkflowInfo.Contacts[0].Id+'&var_OpptyId='+WorkflowInfo.Opportunities[0].Id+'&var_CallId='+WorkflowInfo.Call.Id+'&var_cancelledapp=null')); 
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            return null;
        }
        
    }
    /*public pagereference BtnRefreshProductHoldingPH()
{
if(showRefreshProducttHolding == true)
{

//if product holding do not exist currently create new
/*system.debug('-----WorkflowInfo.CurrentAccount.Id---' +WorkflowInfo.CurrentAccount.Id);

//Web service method called to fetch the latest product holding data fromSAP PI
//WorkflowInfo.ProductHoldingInfo  = RefreshProductHoldingDataService.refreshProductHoldingData(WorkflowInfo.CustomerUCRN, WorkflowInfo.CustomerUCRNAgencyCode, WorkflowInfo.CurrentAccount);
WorkflowInfo.ProductHoldingInfo  = RefreshProductHoldingDataService.refreshProductHoldingData(WorkflowInfo, WorkflowInfo.CurrentAccount);
showRefreshProducttHolding = false;

//Pagereference to return to the same page with the latest call id
PageReference pref = new PageReference('/apex/WorkflowPage?c=' +callID);
pref.setRedirect(true);
return pref;


}

return null;
}*/
    
    //changes for IPD 3653 begin - dated 2/11/2013
    
    public void handleNewProductHolding(productHoldingReponseClass objresponse)
    {
        
        WorkflowInfo.ProductHoldingInfo  = new ProductHolding__c();
        contactInfo con;
        string productHoldings='' ;
        string noOfCon='0';
        string noOfEng = '0';
        string engVisitSt = '';
        date engVisitDate;
        string engVisitDes = '';
        
        string noOfComp='0';
        string compStus = '';
        date compDate ;
        string compDes = '';
        integer j = 0;
        string numberOfExistingProperties ='';
        string currentHeatingSystem = '';
        string lengthOfTimeProductHeld = '';
        string boilerGCNumber = '';
        decimal electricityAnnualSpend ;
        decimal electricityMonthlySpend ;
        string electricityPaymentMethod ='' ;
        decimal gasAnnualSpend ;
        decimal gasMonthlySpend ;
        string gasPaymentMethod = '';
        string boilerAge = '';
        date dateOfLastCertification ;
        string contactType = '';
        string propertyType = '';
        map<string, string> contactTypeMap = new Map<string, string>{'ZOWNER' =>'Landlord', 'ZLETAGET' => 'Agent', 'ZONDMD'=> 'Owner' };
            if(objresponse!=null)
        {
            if(objresponse.address!=null)
            {
                for(productHoldingReponseClass.Address add: objresponse.address){
                    if(add.propertyType!=null)
                    {
                        propertyType = add.propertyType;
                        break;
                    }
                }
            }
            
            if(objresponse.people!=null)
            {
                for(productHoldingReponseClass.People peo: objresponse.people)
                {
                    if(peo.info!=null)
                    {
                        con=  new contactInfo(); 
                        con.contact = new Contact();
                        for(productHoldingReponseClass.Info infoObJ: peo.info)
                        {
                            if(propertyType!= null)
                                //con.contact.Contact_Type__c = propertyType;
                                
                                //2nd phase change start
                                if(infoObJ.numberOfExistingProperties!=null)
                                numberOfExistingProperties = infoObJ.numberOfExistingProperties;
                            // 2nd phase changes end
                            if(infoObJ.title!=null)
                                con.contact.Salutation = infoObJ.title;
                            
                            if(infoObJ.firstName!=null)
                                con.contact.FirstName = infoObJ.firstName;
                            
                            if(infoObJ.lastName!=null)
                                con.contact.LastName = infoObJ.lastName;
                            
                            if(infoObJ.phoneNumber!=null && infoObJ.phoneNumber!= ''){
                                
                                if(infoObj.phoneNumber.startswith('07'))
                                {
                                    con.contact.MobilePhone =infoObJ.phoneNumber;
                                    con.contact.Preferred_Contact_Method__c ='Text (SMS)';
                                }else
                                {
                                    con.contact.HomePhone= infoObJ.phoneNumber;
                                    con.contact.Preferred_Contact_Method__c ='Phone';
                                }
                                
                            } 
                            if(infoObJ.alternateContactNumber!=null && infoObJ.alternateContactNumber!= ''){
                                
                                con.contact.OtherPhone =infoObJ.alternateContactNumber;
                            }
                            if(infoObJ.email!=null)
                                con.contact.Email__c = infoObJ.email;
                            
                            con.AddSlct= true;
                            con.Contact.Description =string.valueof(j);
                            //WorkflowInfo.NewContactInfos.add(con);
                        }
                        
                        if(j<1)
                        {
                            //WorkflowInfo.ContactInfos[j]=con;
                            WorkflowInfo.NewContactInfos[j]=con;
                        }
                        j++;
                    }
                    
                    
                    if(peo.contactHistory!=null)
                    {
                        
                        if(peo.contactHistory.calls!=null)
                        {
                            noOfCon = string.valueof(peo.contactHistory.calls.size());
                        }
                        if(peo.contactHistory.engineers!=null)
                        {
                            
                            
                            if(peo.contactHistory.engineers.size()>0)
                            {
                                integer jl = 0;
                                for(productHoldingReponseClass.Summary eng: peo.contactHistory.engineers)
                                {
                                    if(eng.visitDate>=system.today().adddays(-365))
                                    {
                                        jl++;
                                    }
                                }
                                noOfEng = string.valueof(jl);
                                engVisitSt = peo.contactHistory.engineers[0].visitStatus;
                                engVisitDate = peo.contactHistory.engineers[0].visitDate;
                                engVisitDes = peo.contactHistory.engineers[0].jobDescription;
                            }
                            
                        }
                        
                        
                    }
                    
                    if(peo.complaints!=null)
                    {
                        
                        integer totalcom =0;
                        
                        if(peo.complaints.closed!=null)
                        {
                            totalcom += peo.complaints.closed.size();
                            if(peo.complaints.closed.size()>0)
                            {
                                compStus = peo.complaints.closed[0].visitStatus;
                                compDate = peo.complaints.closed[0].visitDate;
                                compDes = peo.complaints.closed[0].jobDescription;
                            }
                        }
                        
                        if(peo.complaints.open!=null)
                        {
                            totalcom += peo.complaints.open.size();
                            if(peo.complaints.open.size()>0)
                            {
                                compStus = peo.complaints.open[0].visitStatus;
                                compDate = peo.complaints.open[0].visitDate;
                                compDes = peo.complaints.open[0].jobDescription;
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                }    
                
            }
            
            if(objresponse.combinedProductHoldings!=null)
            {
                for(productHoldingReponseClass.ProductHoldings ph : objresponse.combinedProductHoldings)
                {
                    if(ph.Items!=null)
                    {
                        for(productHoldingReponseClass.Items it : ph.items)
                        {
                            if(it.active == true)
                            {
                                productHoldings += it.subcategory+', ';
                            }
                            
                            for(productHoldingReponseClass.AtAddress prod : it.products)
                            {
                                system.debug('--->'+prod);
                                if(prod.productName.contains('CENTRAL HEATING')  || prod.type_Z == 'Energy' )
                                {
                                    if(prod.productBundleName == 'HOMECARE400_COVER')
                                        productHoldings+='HOMECARE 400';
                                    if(prod.boilerGCNumber!= null && prod.boilerGCNumber!= 'No')
                                        boilerGCNumber = prod.boilerGCNumber;
                                    if(prod.currentHeatingSystem!=null )
                                        currentHeatingSystem = prod.currentHeatingSystem;
                                    if(prod.lengthOfTimeProductHeld!=null )
                                        lengthOfTimeProductHeld = prod.lengthOfTimeProductHeld;
                                    if(prod.electricityAnnualSpend!=null )
                                        electricityAnnualSpend = decimal.valueof(prod.electricityAnnualSpend);
                                    if(prod.electricityMonthlySpend!=null)
                                        electricityMonthlySpend = decimal.valueof(prod.electricityMonthlySpend);
                                    if(prod.electricityPaymentMethod!=null)
                                        electricityPaymentMethod = prod.electricityPaymentMethod;
                                    if(prod.gasAnnualSpend!=null)
                                        gasAnnualSpend = decimal.valueof(prod.gasAnnualSpend);
                                    if(prod.gasMonthlySpend!=null)
                                        gasMonthlySpend = decimal.valueof(prod.gasMonthlySpend);
                                    if(prod.gasPaymentMethod!=null)
                                        gasPaymentMethod = prod.gasPaymentMethod;
                                    if(prod.boilerAge!=null)
                                        boilerAge = prod.boilerAge;
                                    if(prod.dateOfLastCertification!=null)
                                        dateOfLastCertification = prod.dateOfLastCertification;
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        // 2nd phase changes
        WorkflowInfo.currentAccount.Current_Heating_System1__c = currentHeatingSystem;
        if(productHoldings!=null && productHoldings.toUpperCase().Contains('GAS'))
        {
            WorkflowInfo.currentAccount.Gas_Supply_At_Address1__c = 'Yes';
            WorkflowInfo.ProductHoldingInfo.GasIsCurrentCustomer__c  = true;
        }
        if(productHoldings!=null && productHoldings.toUpperCase().Contains('ELEC'))
        {
            WorkflowInfo.ProductHoldingInfo.ElectricityIsCurrentCustomer__c  = true;
        }
        
        WorkflowInfo.Opportunities[0].Length_of_time_product_held__c = lengthOfTimeProductHeld;
        WorkflowInfo.Opportunities[0].Number_of_existing_properties__c = numberOfExistingProperties;
        if(boilerGCNumber.length()>=7)
        {
            WorkflowInfo.gasCouncil1 = boilerGCNumber.substring(0,2);
            WorkflowInfo.gasCouncil2 = boilerGCNumber.substring(2,5);
            WorkflowInfo.gasCouncil3 = boilerGCNumber.substring(5,7);
        }
        /*
WorkflowInfo.Opportunities[0].Gas_Annual_Spend__c = gasAnnualSpend;
WorkflowInfo.Opportunities[0].Gas_Monthly_Spend__c = gasMonthlySpend;
WorkflowInfo.Opportunities[0].Electricity_Annual_Spend__c = electricityAnnualSpend;
WorkflowInfo.Opportunities[0].Electricity_Monthly_Spend__c = electricityMonthlySpend;
*/
        WorkflowInfo.Opportunities[0].Gas_Payment_Method__c = gasPaymentMethod;
        
        
        
        WorkflowInfo.Opportunities[0].Electricity_Payment_Method__c = electricityPaymentMethod;
        
        string bagePicklist = '';
        
        if(boilerAge!=null && boilerAge!='')
        {
            bagePicklist = 'Unknown';
            decimal bAge = decimal.valueof(boilerAge)/365;
            if(bAge>15)
                bagePicklist = '15 or more years';
            else if(bAge>10)
                bagePicklist = '10 - 14 years';
            else if(bAge>5)
                bagePicklist = '5 - 9 years';
            else if(bAge>=2)
                bagePicklist = '2 - 4 years';
            
            WorkflowInfo.Opportunities[0].Boiler_Age__c = bagePicklist;
        }
        
        WorkflowInfo.Opportunities[0].Date_of_last_certification__c = dateOfLastCertification;
        // 2nd phase change end
        
        
        WorkflowInfo.Opportunities[0].Product_Holdings__c =productHoldings!=null && productHoldings.length()>255 ? productHoldings.substring(0,255):productHoldings ;
        WorkflowInfo.Opportunities[0].Count_Of_Contacts__c =noOfCon;
        WorkflowInfo.Opportunities[0].Count_of_Complaints__c =noOfComp;
        WorkflowInfo.Opportunities[0].Count_of_Engineer_Visit__c =noOfEng;
        WorkflowInfo.Opportunities[0].Last_Complaint_Status__c =compStus;
        WorkflowInfo.Opportunities[0].Last_Complaint_Date__c =compDate;
        WorkflowInfo.Opportunities[0].Last_Eng_Visit_Date__c =engVisitDate;
        WorkflowInfo.Opportunities[0].Last_Eng_Visit_Description__c =engVisitDes!= null && engVisitDes.length()>255 ? engVisitDes.substring(0,255):engVisitDes;
        WorkflowInfo.Opportunities[0].Last_Eng_Visit_Status__c =engVisitSt;
        WorkflowInfo.Opportunities[0].Last_Complaint_Details__c= compDes!= null && compDes.length()>255 ? compDes.substring(0,255):compDes;
        WorkflowInfo.ProductHoldingInfo.Current_product_Holdings__c = productHoldings!=null && productHoldings.length()>255 ? productHoldings.substring(0,255):productHoldings ;
        WorkflowInfo.ProductHoldingInfo.Count_Of_Contacts__c =noOfCon;
        WorkflowInfo.ProductHoldingInfo.Count_of_Complaints__c =noOfComp;
        WorkflowInfo.ProductHoldingInfo.Count_of_Engineer_Visit__c =noOfEng;
        WorkflowInfo.ProductHoldingInfo.Last_Complaint_Status__c =compStus;
        WorkflowInfo.ProductHoldingInfo.Last_Complaint_Details__c =compDes!=null && compDes.length()>255 ? compDes.substring(0,255):compDes;
        WorkflowInfo.ProductHoldingInfo.Last_Complaint_Date__c =compDate;
        WorkflowInfo.ProductHoldingInfo.Last_Eng_Visit_Date__c =engVisitDate;
        WorkflowInfo.ProductHoldingInfo.Last_Eng_Visit_Description__c =engVisitDes!= null && engVisitDes.length()>255 ? engVisitDes.substring(0,255):engVisitDes;
        WorkflowInfo.ProductHoldingInfo.Last_Eng_Visit_Status__c =engVisitSt;
        
        
        // 2nd Phase Product Holding
        /*
WorkflowInfo.ProductHoldingInfo.GasAnnualSpend__c = gasAnnualSpend;
WorkflowInfo.ProductHoldingInfo.GasMonthlySpend__c = gasMonthlySpend;
WorkflowInfo.ProductHoldingInfo.ElectricityAnnualSpend__c = electricityAnnualSpend;
WorkflowInfo.ProductHoldingInfo.ElectricityMonthlySpend__c = electricityMonthlySpend;
*/
        WorkflowInfo.ProductHoldingInfo.GasPaymentMethod__c = gasPaymentMethod;
        
        
        WorkflowInfo.ProductHoldingInfo.ElectricityPaymentMethod__c = electricityPaymentMethod;
        
        WorkflowInfo.ProductHoldingInfo.DateOfLastCertification__c = dateOfLastCertification;
        WorkflowInfo.ProductHoldingInfo.LengthOfTimeProductHeld__c = lengthOfTimeProductHeld;
        if(numberOfExistingProperties!='')
            WorkflowInfo.ProductHoldingInfo.NumberOfExistingProperties__c = integer.valueof(numberOfExistingProperties);
        
        
        system.debug('Workflow infor Response--->'+WorkflowInfo);    
        
    }
    
    
    
    public void processResponse(ProductHoldingData productHoldingData){
        /*
CallMode objCallMode = new CallMode();             
if(WorkflowInfo.WorkflowType  == objCallMode.CUSTOMERCALLNEWCUST ||WorkflowInfo.WorkflowType  ==  objCallMode.EMPLOYEECALLNEWCUST||              WorkflowInfo.WorkflowType  == objCallMode.ENGINEERCALLNEWCUST){
integer i=0;
integer des=WorkflowInfo.NewContactInfos.size();
for( contactInfo conInfo:productHoldingData.NewContactInfos){

WorkflowInfo.NewContactInfos[i].contact.description=''+des;
WorkflowInfo.Contacts.add(WorkflowInfo.NewContactInfos[i].contact);
WorkflowInfo.NewContactInfos.add(WorkflowInfo.NewContactInfos[i]);
conInfo.contact.description=''+i;
WorkflowInfo.NewContactInfos[i]=conInfo;
WorkflowInfo.Contacts[i]=conInfo.contact;

des++;
i++;
}
}

if(WorkflowInfo.WorkflowType  == objCallMode.CUSTOMERCALLEXISTCUST || WorkflowInfo.WorkflowType  ==objCallMode.EMPLOYEECALLEXISTCUST||         WorkflowInfo.WorkflowType  ==objCallMode.ENGINEERCALLEXISTCUST|| WorkflowInfo.WorkflowType  ==objCallMode.HSACALL){

integer i=0;

for( contactInfo WflowConInfo:WorkflowInfo.ContactInfos){system.debug('WflowConInfo='+WflowConInfo);
for( contactInfo conInfo:productHoldingData.NewContactInfos){system.debug('conInfo='+conInfo);
//matching logic and that set blank fields with SAP data
boolean isUpdate=false;
system.debug('lastname'+(WflowConInfo.contact.lastname!=null && conInfo.contact.lastname==WflowConInfo.contact.lastname ));
system.debug('home'+(WflowConInfo.contact.homephone!=null && conInfo.contact.homephone==WflowConInfo.contact.homephone));
system.debug('firstname'+(WflowConInfo.contact.firstname!=null && conInfo.contact.firstname==WflowConInfo.contact.firstname));
system.debug('email__c'+(WflowConInfo.contact.email__c!=null && conInfo.contact.email==WflowConInfo.contact.email__c));
//system.debug('email'+(WflowConInfo.contact.email!=null && conInfo.contact.email==WflowConInfo.contact.email));
system.debug('otherphone'+(WflowConInfo.contact.otherphone!=null && conInfo.contact.otherphone==WflowConInfo.contact.otherphone));
system.debug('mobile'+(WflowConInfo.contact.mobilephone!=null && conInfo.contact.mobilephone==WflowConInfo.contact.mobilephone));
if((WflowConInfo.contact.lastname!=null && conInfo.contact.lastname==WflowConInfo.contact.lastname )
&& ((WflowConInfo.contact.firstname!=null && conInfo.contact.firstname==WflowConInfo.contact.firstname) || 
(WflowConInfo.contact.email__c!=null && conInfo.contact.email==WflowConInfo.contact.email__c)
|| (WflowConInfo.contact.otherphone!=null && conInfo.contact.otherphone==WflowConInfo.contact.otherphone) || 
(WflowConInfo.contact.mobilephone!=null && conInfo.contact.mobilephone==WflowConInfo.contact.mobilephone)
|| (WflowConInfo.contact.homephone!=null && conInfo.contact.homephone==WflowConInfo.contact.homephone))){
//|| (WflowConInfo.contact.email!=null && conInfo.contact.email==WflowConInfo.contact.email))){
i++;

if(WflowConInfo.contact.firstname ==null && conInfo.contact.firstname!=null )
{system.debug('firstname');
WflowConInfo.contact.firstname =conInfo.contact.firstname;
WflowConInfo.isEditFirstName=true;
isUpdate=true;
}
system.debug('sWflowConInfo.contact.email__c='+WflowConInfo.contact.email__c);
if( WflowConInfo.contact.email__c==null && conInfo.contact.email__c!= null ){
system.debug('setting email');
WflowConInfo.contact.email__c= conInfo.contact.email__c;
system.debug('setting email WflowConInfo.contact.email__c=='+WflowConInfo.contact.email__c);
WflowConInfo.isEditEmail=true;
isUpdate=true;
}
/*system.debug('sWflowConInfo.contact.email='+WflowConInfo.contact.email);
if( WflowConInfo.contact.email==null && conInfo.contact.email!= null ){
system.debug('setting email');
WflowConInfo.contact.email= conInfo.contact.email;
WflowConInfo.isEditEmail=true;
system.debug('setting email WflowConInfo.contact.email=='+WflowConInfo.contact.email);
isUpdate=true;
}*/
        /*
if(WflowConInfo.contact.salutation ==null && conInfo.contact.salutation !=null)
{system.debug('salutation');
WflowConInfo.contact.salutation =conInfo.contact.salutation ;
WflowConInfo.isEditTitle=true;
isUpdate=true;
}
if(WflowConInfo.contact.mobilephone ==null && conInfo.contact.mobilephone!=null){
WflowConInfo.contact.mobilephone =conInfo.contact.mobilephone;
WflowConInfo.isEditMobile=true;
isUpdate=true;system.debug('mobile');
}
if(WflowConInfo.contact.otherphone ==null && conInfo.contact.otherphone!=null)
{
WflowConInfo.contact.otherphone = conInfo.contact.otherphone;
WflowConInfo.isEditWork=true;
isUpdate=true;system.debug('otherphone');
}
if(WflowConInfo.contact.homephone ==null && conInfo.contact.homephone!=null){
WflowConInfo.contact.homephone = conInfo.contact.homephone;
WflowConInfo.isEditHome=true;
isUpdate=true;system.debug('home');
}
}
if(isUpdate){
updatecon.add(WflowConInfo.contact);
showUpdateContacts=true;
}
}
}
if(i==0 && productHoldingData.NewContactInfos.size()>0){

WorkflowInfo.ViewModeAddNewContact=DisplayMode.EDIT;
shownewContacts=true;
showUpdateContacts=true;
productHoldingData.NewContactInfos[0].contact.description=''+0;
productHoldingData.NewContactInfos[0].contact.isactive__c=true;
productHoldingData.NewContactInfos[0].contact.accountid=WorkflowInfo.currentaccount.id;
newcontactsinfo.add(productHoldingData.NewContactInfos[0]);
updatecon.add(productHoldingData.NewContactInfos[0].contact);
}
system.debug('new contacts='+newcontactsinfo);
system.debug('updatecon='+updatecon);

for( contact con:WorkflowInfo.Contacts){
for( contactInfo WflowConInfo:WorkflowInfo.ContactInfos){
if(con.id==WflowConInfo.contact.id)
con=WflowConInfo.contact;
}
}
}
*/
        
    }
    
    public void updateContacts()
    {
        system.debug('before upsert'+updatecon);
        try{
            List<contact> tempCon= new List<contact>();
            for(Contact c:updatecon){
                if(c.lastname!=null || c.lastname!='')
                    tempCon.add(c);
                else{
                    errMsg = 'SurName is required to add new contacts';
                    setErrorMsg();
                }
            }
            updatecon=tempCon;
            if(updatecon.size()>0){
                upsert updatecon;
                if(showUpdateContacts){
                    for(ContactInfo conInfo:WorkflowInfo.contactinfos){
                        conInfo.isEditTitle=false;
                        conInfo.isEditFirstName=false;
                        conInfo.isEditEmail=false;
                        conInfo.isEditHome=false;
                        conInfo.isEditWork=false;
                        conInfo.isEditMobile=false;
                    }
                    WorkflowInfo.contacts.addAll(updatecon);
                    WorkflowInfo.contactinfos.addAll(newcontactsinfo);
                    newcontactsinfo=null;
                    updatecon=null;
                }
                shownewContacts=false;
                showUpdateContacts=false;
            }
        }
        catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
        }
        system.debug('after upsert'+updatecon);
    }
    
    public boolean getSaveAndContinue(){
        Boolean isVisible=false;
        if(WorkflowInfo.ShowBtnContinue==true && showUpdateContacts==true)
            isVisible=true;
        return isVisible;
    }
    
    public boolean getContinue(){
        Boolean isVisible=false;
        if(WorkflowInfo.ShowBtnContinue==true && showUpdateContacts==false)
            isVisible=true;
        return isVisible;
    }
    public  void AgreeAndAccept(){
        system.debug('Inside');
        WorkflowInfo.Opportunities[0].Customer_Marketing_Consent__c='Yes';
        acceptBttnClr='red';
        optOutBttnClr='#b3e000';
        String str='';
        For(PicklistWrapper wrapper:WorkflowInfo.picklistValues){
            if(wrapper.isSelected==True){
                str += wrapper.value + ';';
            }
        }
        
        WorkflowInfo.Opportunities[0].Marketing_Preferences__c=str;
        update  WorkflowInfo.Opportunities[0] ;
        
        
        
    }
    public  void  OptOut(){
        WorkflowInfo.Opportunities[0].Customer_Marketing_Consent__c='No';
        optOutBttnClr='red';
        acceptBttnClr='#b3e000';
        WorkflowInfo.Opportunities[0].Marketing_Preferences__c='';
        update  WorkflowInfo.Opportunities[0] ;
    } 
    
    public pagereference BtnLandlordDetails()
    {
        return new pagereference ('/apex/captureLandlordDetails?edit=1&source=IC&chiLeadId='+WorkflowInfo.Opportunities[0].Id+'&accId='+WorkflowInfo.CurrentAccount.Id+'&existingLead='+existingLead);
    }
    //changes for IPD 3653 end - dated 2/11/2013        
    
    public pagereference updateMarketingPreference() {
        
        return new pagereference ('/apex/cchMarketing?id='+WorkflowInfo.Opportunities[0].Id); 
        
    }
    
}