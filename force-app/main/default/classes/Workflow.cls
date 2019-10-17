public abstract class Workflow
{
    //To intiate workflow from Inbound call screen
    //Decides which screen to go to
    //public abstract PageReference IntiateWorkflow(WorkflowInfo info);
    MessageConstants msgConst = new MessageConstants();
    DisplayMode objDisplayMode = new DisplayMode();
    private MessageConstants errorMsg;
    String errMsg='';
    //Sets the various properties of WorkflowInfo object for displaying lead page
    public abstract WorkflowInfo SetWorkflow(WorkflowInfo info);
    
    //Handles click event of Continue button
    public abstract WorkflowInfo Continue_Click(WorkflowInfo info);
    
    //Handles click event of Create Lead button
    public abstract WorkflowInfo CreateLead_Click(WorkflowInfo info);
    
    //Handles click event of Sales Appointment button
    public virtual PageReference SalesAppointment_Click(WorkflowInfo info)
    {
        PageReference pageRef = null;
        List<Opportunity> lstOpps = info.Opportunities;
        List<ContactInfo> lstContacts = info.ContactInfos;
        if(lstOpps != null && lstContacts != null && lstOpps.size() > 0 && lstContacts.size() > 0)
        {
            //Search for primaryContact
            
            Contact primaryContact;
            for(ContactInfo c :lstContacts)
            {
                if(c.Contact != null && c.Contact.Primary_Contact__c == true)
                {
                    primaryContact = c.Contact;
                    break;
                }
            }
            if(primaryContact == null) primaryContact = lstContacts[0].Contact;
            string gdeal = lstOpps[0].Product_Interest__c=='Straight Swap'||lstOpps[0].Product_Interest__c=='Telesales Conv'?'3':'0';
            pageRef = new PageReference 
                ('/apex/availability?var_OpptyId='+  
                 lstOpps[0].ID+'&var_Source=IC&view=null&var_date=null&var_contactId='
                 +primaryContact.ID+'&var_cancelledapp=null' + 
                 '&var_CallId=' + info.Call.ID+'&gDeal='+gdeal+'&existingLead='+info.existingLead+'&new='+info.newInbound);
            pageRef.setRedirect(true);            
        }
        return pageRef;
    }
    
    //Handles click event of Create New Lead button
    public abstract WorkflowInfo CreateNewLead_Click(WorkflowInfo info);
    
    //Handles click event of Create Payment button
    public virtual WorkflowInfo CreatePayment_Click(WorkflowInfo info){
        return info;
    }
    
    //Handles click event of New Sales Appointment button
    public virtual PageReference NewSalesAppointment_Click(WorkflowInfo info)
    {
        return SalesAppointment_Click(info);
    }
    
    //Handles click event of Cancel Appointment button
    // modified the return type of this metohd as bsiness requetsd to directly land on wrap up page instead of having to click the button
    public virtual Pagereference CancelAppointment_Click(WorkflowInfo info){
        List<SelectedAppointment> tempAppnt = info.SelectedAppointments;
        List<Appointment__c> appointments = new List<Appointment__c>();
        info.DisplayPaymentMessage = false; //To avoid display of 'Payment created successfully' alert message.
        Integer appointSelected = 0;
        System.debug('### info.SelectedAppointments size: '+info.SelectedAppointments.size());
        
        if(info.SelectedAppointments==null || info.SelectedAppointments.size()==0){
            //info = WorkflowHelper.SetError(info, msgConst.ERR_CANCELAPPOINTMENT);
            errMsg = msgConst.ERR_CANCELAPPOINTMENT;
            setErrorMsg();
            return null;
        }
        //Count select opportunities
        for(SelectedAppointment selectListItem :info.SelectedAppointments)
        {
            if(selectListItem.appoinSelected)
            { 
                appointSelected++;
            }
        }
        if(appointSelected == 0)
        {
            System.debug('### inside zero list'); 
            //info = WorkflowHelper.SetError(info, msgConst.ERR_CANCELAPPOINTMENT);
            errMsg = msgConst.ERR_CANCELAPPOINTMENT;
            setErrorMsg();
            return null;
        }   
        
        //STATUS REASON CHANGE : START
        //Count select opportunities
        for(SelectedAppointment selectListItem :info.SelectedAppointments)
        {
            if(selectListItem.appoinSelected)
            { 
                // Ashok :CR :002 CP
                // if(selectListItem.appointment.Status_Reason__c == null ){
                if((selectListItem.appointment.Primary_Cancellation_Reason__c == null) || ((selectListItem.appointment.Primary_Cancellation_Reason__c =='Customer Request via HA' || selectListItem.appointment.Primary_Cancellation_Reason__c =='Customer Request Direct'||selectListItem.appointment.Primary_Cancellation_Reason__c =='Visited: can\'t proceed'
                                                                                            || selectListItem.appointment.Primary_Cancellation_Reason__c =='Re-scheduled Appointment')  && selectListItem.appointment.Secondary_Cancellation_Reason__c == null)){ 
                                                                                                // Ashok End    
                                                                                                errMsg = msgConst.ERR_CANCAPPOINTMENT;
                                                                                                setErrorMsg();
                                                                                                selectListItem.displayRedTextForCanReasons = true;
                                                                                                return null;
                                                                                            }
            }
        }  
        //STATUS REASON CHANGE :END
        
        if(appointSelected == 0)
        {
            System.debug('### inside zero list'); 
            //info = WorkflowHelper.SetError(info, msgConst.ERR_CANCELAPPOINTMENT);
            errMsg = msgConst.ERR_CANCELAPPOINTMENT;
            setErrorMsg();
            //return null;
        }   
        
        if(tempAppnt.size()>0)
        {
            System.debug('### inside > 0');
            for(SelectedAppointment selectedApp :tempAppnt)
            { 
                if(selectedApp.appoinSelected)
                {       
                    selectedApp.appointment.Status__c = 'Cancelled';
                    appointments.Add(selectedApp.appointment);
                    selectedApp.appoinSelected = false;
                }
            }
            update appointments;
            
            info.SelectedAppointments = tempAppnt;
            
            // MGM  changes start
            List<Opportunity> lstOpps = [Select o.Name, o.CHI_Lead_Id__c,  o.Campaign_Name__c, o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,
                                         o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,
                                         o.Preferred_appointment_time__c,o.Lead_Comments__c,o.ta_notes__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,o.HomeImprovementCheckbox__c,
                                         o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.isMGM__c,
                                         o.Is_the_customers_boiler_working__c,o.Does_the_customer_have_hot_water__c,o.Customer_have_any_other_form_of_HEAT__c,
                                         o.Is_the_customer_vulnerable__c,o.Vulnerable_reason__c,o.Latest_customer_category_indicator__c,
                                         o.Latest_customer_category__c,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Boiler_type__c,o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Current_annual_gas_spend_over_1500__c,o.Missing_product_holdings_reason__c,o.Home_Care__c,o.Marketing_Preferences__c,o.Customer_Marketing_Consent__c
                                         From Opportunity o where o.ID=:info.Opportunities[0].Id];
            info.Opportunities = lstOpps;
            // MGM  changes ends 
            
            
        }
        //return info;
        Pagereference pageRef = null;
        if(info.Call != null)
        {   
            pageRef = new Pagereference('/apex/wrapupscreenpage?c=' + info.Call.id+'&existingLead='+info.existingLead);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    //Handles click event of Re-arrange Appointment button
    public virtual PageReference ReArrangeAppointment_Click(WorkflowInfo info){
        PageReference pageRef = null;
        Id tempAppntId;
        List<Opportunity> lstOpps = info.Opportunities;
        List<Contact> lstContacts = info.Contacts;
        List<SelectedAppointment> tempAppnt = info.SelectedAppointments;
        SelectedAppointment sAappointment =  new SelectedAppointment ();
        Integer count = 0;
        info.DisplayPaymentMessage = false; //To avoid display of 'Payment created successfully' alert message.
        
        if(tempAppnt.size()>0)
        {
            boolean isGreenDeal =false;   
            for(SelectedAppointment selectedApp :tempAppnt)
            { 
                if(selectedApp.appoinSelected)
                { 
                    sAappointment = selectedApp;
                    tempAppntId = selectedApp.appointment.Id;
                    isGreenDeal=selectedApp.GreenDeal;
                    count++;
                }
            }
            if(count == 1)
            {
                // ch: 08/11/2011 : To make Primary and seconday cancellation reason mandatory for present appointment while rearranging the appointment.
                if((sAappointment.appointment.Primary_Cancellation_Reason__c == null) || ((sAappointment.appointment.Primary_Cancellation_Reason__c =='Customer Request via HA' || sAappointment.appointment.Primary_Cancellation_Reason__c =='Customer Request Direct'||sAappointment.appointment.Primary_Cancellation_Reason__c =='Visited: can\'t proceed'
                                                                                           || sAappointment.appointment.Primary_Cancellation_Reason__c =='Re-scheduled Appointment')  && sAappointment.appointment.Secondary_Cancellation_Reason__c == null)){ 
                                                                                               
                                                                                               errMsg = msgConst.ERR_CANCAPPOINTMENT;
                                                                                               setErrorMsg();
                                                                                               sAappointment.displayRedTextForCanReasons = true;
                                                                                               return null;
                                                                                           }
                // Ashok End   
                if(lstOpps != null && lstContacts != null && lstOpps.size() > 0 && lstContacts.size() > 0)
                {
                    //Search for primaryContact
                    Contact primaryContact;
                    for(Contact c :lstContacts)
                    {
                        if(c.Primary_Contact__c)
                        {
                            primaryContact = c;
                            break;
                        }
                    }
                    if(primaryContact == null) primaryContact = lstContacts[0];
                    string gDPageRef= isGreenDeal?'&gDeal=1':'&gDeal=0';
                    pageRef = new PageReference 
                        ('/apex/availability?var_OpptyId='+  
                         lstOpps[0].ID+'&var_Source=IC&view=null&var_date=null&var_contactId='
                         +primaryContact.ID+'&var_cancelledapp='+tempAppntId + 
                         '&var_CallId=' + info.Call.ID+'&var_Pcr='+sAappointment.appointment.Primary_Cancellation_Reason__c+'&var_Sec='+sAappointment.appointment.Secondary_Cancellation_Reason__c+gDPageRef+'&existingLead='+info.existingLead);
                    pageRef.setRedirect(true);                      
                }
            }
            else if(count < 1){
                //info = WorkflowHelper.seterror(info,msgConst.ERR_NOAPPOINTMENTSELECTED);
                errMsg = msgConst.ERR_NOAPPOINTMENTSELECTED;
                setErrorMsg();
                return null;
            }
            else{
                //info = WorkflowHelper.seterror(info,msgConst.ERR_MULTIPLEAPPOINTMENTSELECTED);
                errMsg = msgConst.ERR_MULTIPLEAPPOINTMENTSELECTED;
                setErrorMsg();
                return null;
            }
        }
        else{
            //info = WorkflowHelper.seterror(info,msgConst.ERR_NOAPPOINTMENTSAVAILABLE);
            errMsg = msgConst.ERR_NOAPPOINTMENTSAVAILABLE;
            setErrorMsg();
            return null;
        }
        
        return pageRef;
        
    }
    
    //Handles click event of Book Survey Appointment button
    public virtual PageReference BookSurveyAppointment_Click(WorkflowInfo info)
    {
        List<Opportunity> oppList=info.Opportunities;
        info.DisplayPaymentMessage = false;
        for(integer i=0;i<oppList.size();i++)
        {
            oppList[i].Visit_Type__c = 'Survey';
            oppList[i].Enquiry_Type__c = 'Sales Appointment';
        }
        try
        {
            upsert oppList;
            info.Opportunities=oppList;
            return SalesAppointment_Click(info);
        }
        catch(Exception e)
        {
            //info = WorkflowHelper.SetError(info, e.getMessage());
            errMsg = e.getMessage();
            setErrorMsg();
            return null;
        }
        return null;
    }
    
    //Handles click event of Wrap call button
    public virtual PageReference WrapCall_Click(WorkflowInfo info)
    {
        Pagereference pageRef = null;
        //Changes for Wrapupscreen seperation :START
        /* WrapUpScreenController wrapupController = new WrapUpScreenController();
wrapupController.info = info;
wrapupController.CallModeStringValue = info.callModeString;   */
        //Changes for Wrapupscreen seperation :END 
        if(info.Call != null)
        {   
            if(info.newInbound)
                pageRef = new Pagereference('/apex/new_wrapupscreenpage?c='+info.Call.id+'&existingLead='+info.existingLead+'&new='+info.newInbound);
            else           
                pageRef = new Pagereference('/apex/wrapupscreenpage?c=' + info.Call.id+'&existingLead='+info.existingLead);
            
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    //Handles click event of Waste Call button
    public virtual PageReference WasteCall_Click(WorkflowInfo info)
    {
        Pagereference pageRef = null;
        if(info.Call != null)
        {
            pageRef = new Pagereference('/apex/wastecallpage?c=' + info.Call.id);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    public virtual WorkflowInfo Initialize(WorkflowInfo info)
    {
        info.IsError = false;
        info.Messages = new List<String>();
        return info;
    }
    
    public WorkflowInfo SetInitialValues(WorkflowInfo info)
    {
        info.ShowBtnContinue = false;
        info.ShowBtnCreateLead = false;
        info.ShowBtnCreateNewLead = false; 
        info.ShowBtnSalesAppointment = false;
        info.ShowBtnNewSalesAppointment = false;
        info.ShowBtnCancelAppointment = false;
        info.ShowBtnRearrangeAppointment = false;
        info.ShowBtnBookSurveyAppointment = false;
        info.ShowBtnWrapUpCall = false;
        info.ShowBtnWasteCall = false;
        info.ShowBtnCreatePayment = false;
        info.ShowMektPref=false;
        //Boolean properties to display/hide components
        info.ShowAccountView = false;
        info.ShowAddNewContact = false;
        info.ShowViewContacts = false;
        info.ShowSelectContacts = false;
        info.ShowSelectOpportunities = false;
        info.ShowEditOpportunities = false;
        info.ShowAppointments = false;
        info.ShowEvents = false;
        info.ShowPayment = false;
        info.ShowEngineerQues = false;
        //info.ShowProductHoldingInfo = false; //added on May 14, 2012 for Product Holding section
        
        info.ShowCustQuestions = false; // added on Jul 03,2015 for holding Customer section-- Change By Ashok G
        info.ShowEmployeeQuestions = false; // added on Jul 03,2015 for holding Employee section-- Change By Ashok G
        
        return info;
    }
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }
    
    public class WorkflowInfo
    {
        public string customerCateogryType='0';
        public Integer WorkflowType{get; set;}
        public Boolean DisplayAccount{get; set;}
        public Account CurrentAccount{get; set;}
        public List<Appointment__c> Appointments{get; set;}
        public List<SelectedAppointment> SelectedAppointments{get; set;}
        public List<Contact> Contacts{get; set;}
        public BGS_Payment__c Payment{get; set;}
        public boolean showApp{get;set;} 
        public boolean warning {get;set;}
        // Ashok CR : wanning
        public Lead prospect = new lead();
        // End
        public List<ContactInfo> ContactInfos{get; set;}
        public List<ContactInfo> NewContactInfos{get; set;}
        public List<OppSelectClass> SelectedOpportunities{get; set;}
        public List<Opportunity> Opportunities{get; set;}
        public List<Inbound_Call__c> Calls{get; set;}
        public Inbound_Call__c Call {get; set;}     
        public List<Opportunity> NonClosedOpportunityList{get; set;}
        
        // ++ Added for Gas Council CR start
        public string gasCouncil1 {get; set;}
        public string gasCouncil2 {get; set;}
        public string gasCouncil3 {get; set;}
        // -- Added for Gas Council CR end
        
        public string district {get;set;}
        public string region {get;set;}
        public boolean messageBool1{get; set;}
        public boolean messageBool2{get; set;}
        public String messageStr1{get;set;}
        public string messageStr2{get;set;}
        
        //Boolean properties to display/hide buttons 
        public Boolean ShowBtnContinue{get; set;}
        public Boolean ShowBtnCreateLead{get; set;}
        public Boolean ShowBtnCreateNewLead{get; set;}
        public Boolean ShowBtnSalesAppointment{get; set;}
        public Boolean ShowBtnNewSalesAppointment{get; set;}
        public Boolean ShowBtnCancelAppointment{get; set;}
        public Boolean ShowBtnRearrangeAppointment{get; set;}
        public Boolean ShowBtnBookSurveyAppointment{get; set;}
        public Boolean ShowBtnWrapUpCall{get; set;}
        public Boolean ShowBtnWasteCall{get; set;}
        public Boolean ShowBtnCreatePayment{get; set;}
        public boolean showCombiswap{get;set;}
        //Boolean properties to display/hide components
        public Boolean ShowAccountView{get; set;}
        public Boolean ShowAddNewContact{get; set;}
        public Boolean ShowViewContacts{get; set;}
        public Boolean ShowSelectContacts{get; set;}
        public Boolean ShowSelectOpportunities{get; set;}
        public Boolean ShowEditOpportunities{get; set;}
        public Boolean ShowAppointments{get; set;}
        public Boolean ShowEvents{get; set;}
        public Boolean ShowPayment{get; set;}
        public Boolean ShowEngineerQues{get; set;}
        public Boolean ShowMektPref{get; set;}
        //Change By Ashok G
        public Boolean ShowCustQuestions{get;set;}
        public Boolean ShowEmployeeQuestions{get;set;}
        public string existingLead{get;set;}
        
        //End
        public Boolean include_priority_install {get; set;}   
        
        
        //Integer properties for dislpay mode of components
        public Integer ViewModeAccountView{get; set;}
        public Integer ViewModeAddNewContact{get; set;}
        public Integer ViewModeViewContacts{get; set;}
        public Integer ViewModeSelectContacts{get; set;}
        public Integer ViewModeSelectOpportunities{get; set;}
        public Integer ViewModeEditOpportunities{get; set;}
        public Integer ViewModeAppointments{get; set;}
        public Integer ViewModeEvents{get; set;}
        public Integer ViewModeEngineerQues{get; set;}// added by Ashok G
        public Integer ViewModeCustomer{get; set;}// added by Ashok G
        public Integer ViewModeEmployee{get; set;}// added by Ashok G
        
        
        public Boolean IsError {get; set;}
        public Boolean DisplayPaymentMessage {get; set;}
        public List<String> Messages;
        public String callModeString{get; set;}
        public String exitAppointment{get; set;}  // for exit functionality of Appointment page
        public Boolean IsNewLead{get; set;} // to find the create new lead flow in ExistingCust
        public Boolean ShowFWAMessage{get; set;} 
        public CombiSwapQuestion__c combiSwap{get;set;}
        
        //CODE ADDED ------------------------------------------------------------
        //DATE:- May 9, 2012
        //DESCRIPTION:- Property to store selected customer UCRN 
        public String CustomerUCRN {get; set;} //to store customer UCRN details
        public String CustomerUCRNAgencyCode {get; set;} //to store customer UCRN agency details
        public ProductHolding__c ProductHoldingInfo {get; set;} //to store Product Holding details
        public List<ProductHoldingAccount__c> ProductHoldingAccounts {get; set;} //to store Product Holding details
        public Boolean ShowProductHoldingInfo{get; set;} //added on May 14, 2012 for Product Holding section
        public String HouseNumber {get; set;}
        public String HouseName {get; set;}
        public String PoBoxNumber {get; set;}
        public Boolean ProductHoldingEnabled {get; set;}
        //-----------------------------------------------------------------------
        public boolean isGDAEnabled {get;set;}
        public boolean showGDBtn {get;set;}
        public boolean newInbound  {get;set;}
        
        public List<PicklistWrapper> picklistValues{get;set;}
        
        public string getcustomerCateogryType(){
            return customerCateogryType;
        }
        
        public WorkflowInfo()
        {
            this.DisplayAccount = false;
            this.IsError = false;
            this.Appointments = new List<Appointment__c>();
            this.SelectedAppointments = new List<SelectedAppointment>();
            this.NonClosedOpportunityList = new List<Opportunity>(); 
            this.CurrentAccount = new Account();
            this.Payment = new BGS_Payment__c(); 
            this.DisplayPaymentMessage = false;  
            this.ShowFWAMessage = false;  
            this.combiSwap =  new CombiSwapQuestion__c(); 
            this.ShowProductHoldingInfo = true;
            this.ProductHoldingEnabled = false;
            this.isGDAEnabled = false;
            this.showGDBtn = false;
            this.messageBool1 = false;
            this.messageBool2 = false;
            this.showApp = false;
            this.warning = false;
            this.newInbound = false;
            this.picklistValues = new List<PicklistWrapper>();
        }
        
        
    }
    
   
    
}