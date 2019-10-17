public class ExistingCustomerWorkflow extends Workflow 
{
    private DisplayMode objDisplayMode; //displaymode object for displaymode constants
    private CallMode objCallMode;
    private Integer WorkflowMode; //workflowmode: 0-Initial
    private MessageConstants msgConstants;
    
    //public String callModeString = ''; //change for wrap up
    private final Integer STEP1 = 0; //intial view
    private final Integer STEP2 = 1; //after user has created a new lead
    private final Integer STEP3 = 2; //user opts to create a new lead
    private final Integer STEP4 = 3; //user has selected an existing lead
    private final Integer STEP5 = 4; //Going for boking appointment
    //Default Constructor 
    public ExistingCustomerWorkflow()
    {
        objDisplayMode = new DisplayMode();
        objCallMode = new CallMode();
        
        //callModeString = 'CUSTOMERCALLEXISTCUST'; //change for wrap up
        msgConstants = new MessageConstants(); 
        WorkflowMode = STEP1;        
    }
    
    //Sets the various properties of WorkflowInfo object for displaying lead page
    public override WorkflowInfo SetWorkflow(WorkflowInfo info)
    {
        //info.callModeString = this.callModeString; //change for wrap up 
        system.debug('----info.exitAppointment----'+info.exitAppointment);
        system.debug('----info.Call.Workflow_Step__c----'+info.Call.Workflow_Step__c);
        
        Integer mode = info.Call.Workflow_Step__c.intValue();
        
        
        // check whether it comes from rearrange appointment exit button. if yes then set mode to step 4
        System.debug('----------info.IsNewLead------------'+info.IsNewLead);
        if(info.exitAppointment != null)
        {
            mode = STEP4;
            
        }       
        system.debug('----mode----'+mode);
        WorkflowMode = mode;
        info = WorkflowHelper.fetchCallData(info);
        //info = WorkflowHelper.GetAppointments(info);
        
        if(mode == STEP3)
        {
            info = resetContacts(info);
            info = ResetOpportunities(info);
            
        }
        else if(mode == STEP4)
        {
            system.debug('----inside mode == STEP4----');           
            //display events in this case
            Inbound_Call__c call = info.Call;
            system.debug('----call.CHI_Lead__c----'+call.CHI_Lead__c); 
            if(call.CHI_Lead__c != null)
                info.Calls = WorkflowHelper.getAllCallsByOpportunityID(call.CHI_Lead__c);
        }
        
        info = SetWorkflowComponents(info);
        
        return info;
    }
    
    //Shows/hides various workflow components on basis of workflow stage 
    private WorkflowInfo SetWorkflowComponents(WorkflowInfo info)
    {
        Integer mode = WorkflowMode;
        System.debug(' ------------------- mode = ' + mode);
        info = SetInitialValues(info);
        if(mode == STEP1)
        {
            info.ViewModeAccountView = objDisplayMode.STATUS;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            
            info.ShowBtnContinue = true;
            info.ShowBtnCreateNewLead = true; 
            info.ShowBtnWasteCall = true;
            
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowSelectOpportunities = true;
        }
        else if(mode == STEP2)
        {
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.VIEW;
            
            if(info.ShowFWAMessage == true)
            {
                info.ShowBtnSalesAppointment = false;
            }
            else
            {               
            info.ShowBtnSalesAppointment = true;
            
            }
            
            info.ShowBtnWrapUpCall = true;
            
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
        }
        else if(mode == STEP3)
        {
            //Create new lead mode
            info.ViewModeAccountView = objDisplayMode.EDIT;
            info.ViewModeAddNewContact = objDisplayMode.EDIT;
            info.ViewModeSelectContacts = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.EDIT;
            info.ViewModeCustomer = objDisplayMode.EDIT;// added by Ashok G
            
            info.ShowBtnCreateLead = true;
            info.ShowBtnWasteCall = true;
            
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowAddNewContact = true;
            info.ShowSelectContacts = true;
            info.ShowEditOpportunities = true;
            info.ShowCustQuestions = true; //added by Ashok G
        }
        else if(mode == STEP4)
        {
            system.debug('--------inside step4---------');
            system.debug('--------info.Call---------'+info.Call);
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            //info.ViewModeEditOpportunities = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.APPOINTSUCCESS;
            info.ViewModeCustomer = objDisplayMode.VIEW;// added by Ashok G
            
            if(info.exitAppointment != null)
            {
                info = WorkflowHelper.RemoveNonCallOpportunities(info);                             
            }
            
            info.ShowBtnCancelAppointment = true;
            info.ShowBtnNewSalesAppointment = true;
            if(info.isGDAEnabled)
            info.showGDBtn = true;
            info.ShowBtnRearrangeAppointment = true;
            info.ShowBtnWrapUpCall = true;
            info.ShowCustQuestions = true; //added by Ashok G
            
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
            info.ShowEvents = true;
            
            //display appointments if available
            info = WorkflowHelper.GetAppointments(info);
            List<Appointment__c> tempAppnt = info.Appointments;
            if(tempAppnt.size()>0){
                info.ShowAppointments = true;
                //show existing appointments to select for cancel or re-arange
                //info.ViewModeAppointments = objDisplayMode.EXISTING; 
                info.ViewModeAppointments = objDisplayMode.APPOINTSUCCESSEXIST;
            }
        }
        else if(mode == STEP5)
        {
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
            
            //Boolean properties to display/hide buttons
            info.ShowBtnWrapUpCall = true;

            
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            ///info.ViewModeEditOpportunities = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.APPOINTSUCCESS;
            info = WorkflowHelper.RemoveNonCallOpportunities(info);
            
            //display appointments if available
            info = WorkflowHelper.GetAppointments(info);
            List<Appointment__c> tempAppnt = info.Appointments;
            if(tempAppnt.size()>0){
                info.ShowAppointments = true;
                //info.ViewModeAppointments = objDisplayMode.VIEW;
                info.ViewModeAppointments = objDisplayMode.APPOINTSUCCESS;
            }
        }
        return info;
    }
    
    //Handles click event of Continue button
    public override WorkflowInfo Continue_Click(WorkflowInfo info)
    {
        Integer oppSelected = 0;
        info = Initialize(info);
        
        //find if any of the opportunities are selected
        List<Opportunity> unselectedOpps = new List<Opportunity>();
        List<Opportunity> selectedOpps = new List<Opportunity>();
        
        //Count select opportunities
        //system.debug('1st-->'+info.SelectedOpportunities);
        if(info.SelectedOpportunities!=null && info.SelectedOpportunities[0].oppSelected!=null)
        {
            for(OppSelectClass selectListItem :info.SelectedOpportunities)
            {
                if(selectListItem.oppSelected!=null && selectListItem.oppSelected)
                { 
                    oppSelected++;
                }
            }
        }
        
        if(oppSelected == 1) // if one opportunity is selected
        {
            //One opportunity is selected
            for(OppSelectClass selectListItem :info.SelectedOpportunities)
            {
                if(selectListItem.oppSelected)
                {
                    selectedOpps.add(selectListItem.opp);
                }
                else if(selectListItem.opp.StageName == 'Active')
                {
                    selectListItem.opp.StageName = 'Closed Lost';
                    //ashok cr :12 
                    selectListItem.opp.Stage_Reason_CHICR__c  = 'Auto Close Via Script';
                    // ashok end
                    unselectedOpps.add(selectListItem.opp);
                }
            }
            System.debug('marking opps as closed lost');
            info.Opportunities = selectedOpps;
            update unselectedOpps;
            
            WorkflowMode = STEP4;
            Inbound_Call__c call = info.Call;
            call.Workflow_Step__c = WorkflowMode;
            call.CHI_Lead__c = selectedOpps[0].id;
            update call;
            info.Call = call;
        }
        else if(oppSelected < 1)
        {
            //No opportunity is selected, display error message
            info = WorkflowHelper.SetError(info, msgConstants.ERR_NOOPPORTUNITYSELECTED);
        }
        else
        {
            //More than one opprtunities are selected
            info = WorkflowHelper.SetError(info, msgConstants.ERR_MULTIPLEOPPORTUNITYSELECTED);
        }
        
        //if an opportunity is selected pull all the previous call details
        if(!info.IsError)
        {
            info.Calls = WorkflowHelper.getAllCallsByOpportunityID(selectedOpps[0].ID);
        }
        
        //set components according to the workflow step
        info = SetWorkflowComponents(info);
        
        return info;
    }
    
    //Handles click event of Create Lead button
    public override WorkflowInfo CreateLead_Click(WorkflowInfo info)
    {
        System.debug('----------before set info.IsNewLead------------'+info.IsNewLead);
        info.IsNewLead = true;
        System.debug('----------after set info.IsNewLead------------'+info.IsNewLead);
        try
        {
            info = WorkflowHelper.CreateLeadAccountOpp(info);
            System.debug('---------info == ' +info);
            if(!info.IsError)
            {
                WorkflowMode = STEP2;
                Inbound_Call__c call = info.Call;
                call.Workflow_Step__c = WorkflowMode;
                update call;
                info.Call = call;
                info = SetWorkflowComponents(info);
            }
        }
        catch(Exception ex)
        {
            info = WorkflowHelper.SetError(info, ex.getMessage());
        }
        return info;
    }
    
    //Handles click event of Create New Lead button
    public override WorkflowInfo CreateNewLead_Click(WorkflowInfo info)
    {
        //Resest Contact collection
        /*info.Contacts = new List<Contact>();
        //info.ContactInfos = new List<ContactInfo>();
        
        Contact newContact1 = new Contact();
        Contact newContact2 = new Contact();
        newContact1.Description = 'newContact1';
        newContact2.Description = 'newContact2';
        
        info.Contacts.Add(newContact1);
        info.Contacts.Add(newContact2);
        System.debug('--------------------- CreateNewLead_Click ----- 1');
        ContactInfo newContactInfo = new ContactInfo();
        newContactInfo.contact = newContact1;
        info.ContactInfos.Add(newContactInfo);
        System.debug('--------------------- CreateNewLead_Click ----- 2');
        newContactInfo = new ContactInfo();
        newContactInfo.contact = newContact2;
        info.ContactInfos.Add(newContactInfo);*/
        info = resetContacts(info);
        info.combiSwap = new CombiSwapQuestion__c();
        System.debug('--------------------- CreateNewLead_Click ----- 3' + info.Contacts);
        //mark opportunities as "closed lost"
        List<OppSelectClass> currentOpps = info.SelectedOpportunities;
        //Ashok : Code start CR 12
        List<Opportunity> lstOppty = new List<Opportunity>();
            for(Integer i=0; i < currentOpps.size(); i++)
            {
                lstOppty.add(currentOpps[i].opp);
            }
        list<Job__c> joblst = new list<Job__c>([Select Id, CHI_Lead__c From Job__c where CHI_Lead__c in: lstOppty]);
        map<Id, Boolean> OppflagMap = new map<Id, Boolean>();
        for(Job__c j :joblst)
        {
            if(!OppflagMap.containskey(j.CHI_Lead__c))
            {
                OppflagMap.put(j.CHI_Lead__c, true);
            }
        }
        // end
        if(currentOpps != null) 
        {
            List<Opportunity> lstOpp = new List<Opportunity>();
            for(Integer i=0; i < currentOpps.size(); i++)
            {
                if(!OppflagMap.containskey(currentOpps[i].opp.Id))
                {
                //Changes for CR:SR no :20 :START
                    if(currentOpps[i].opp.StageName != 'Closed Lost'){
                        info.NonClosedOpportunityList.add(currentOpps[i].opp);
                    }
                    //Changes for CR:SR no :20 :END
                    
                    if(currentOpps[i].opp.StageName != 'Closed Won' && currentOpps[i].opp.StageName != 'Closed Lost')
                    {
                        currentOpps[i].opp.StageName = 'Closed Lost';
                        currentOpps[i].opp.Stage_Reason_CHICR__c  = 'Auto Close Via Script';
                        currentOpps[i].opp.Firefly_Script_Complete__c = true;
                        currentOpps[i].opp.By_Pass_User_Validation__c  = true;
                        lstOpp.Add(currentOpps[i].opp);
                    }
                    // below 2 line commented because it updates chi leads with stage closed won/closed lost
                    //currentOpps[i].opp.Firefly_Script_Complete__c = true;
                    //lstOpp.Add(currentOpps[i].opp);
                    
                } 
            }
            // first cancel the appointments then update the opportunity
            //info= WorkflowHelper.closeAppointmentsOfClosedLead(info);
            
            if(lstOpp.size() > 0)
                update lstOpp;
            
            //Changes for CR:SR no :20 :START
            //info= WorkflowHelper.closeAppointmentsOfClosedLead(info);
            //Changes for CR:SR no :20 :END
        }
        else
            System.debug('--------------------- opportunity colelction is null');
        
        info = ResetOpportunities(info);
        
        System.debug('--------------------- CreateNewLead_Click ----- 5');
        if(!info.IsError)
        {
            WorkflowMode = STEP3;
            Inbound_Call__c call = info.Call;
            call.Workflow_Step__c = WorkflowMode;
            update call;
            info.Call = call;
            info = SetWorkflowComponents(info);
        }
        
        return info;
    }
    
    //Handles click event of New Sales Appointment button
    public override PageReference NewSalesAppointment_Click(WorkflowInfo info)
    {
        //Increment workflow step
        PageReference pageRef = super.NewSalesAppointment_Click(info);
        info.Call.Workflow_Step__c = STEP5;
        System.debug('---------------- pageRef = ' + pageRef);
        update info.Call;
        
        //perform base class operation
        return pageRef;
    }
    
    //Handles click event of New Sales Appointment button
    public override PageReference SalesAppointment_Click(WorkflowInfo info)
    {
        //Increment workflow step
        PageReference pageRef = super.SalesAppointment_Click(info);
        info.Call.Workflow_Step__c = STEP5;
        System.debug('---------------- pageRef = ' + pageRef);
        update info.Call;
        
        //perform base class operation
        return pageRef;
    }
    
    //Handles click event of Re-arrange Appointment button
    public override PageReference ReArrangeAppointment_Click(WorkflowInfo info)
    {
        //Increment workflow step
        PageReference pageRef = super.ReArrangeAppointment_Click(info);     
        system.debug('----inside ReArrangeAppointment_Click pageRef----'+pageRef);
        
        info.Call.Workflow_Step__c = STEP5;
        
        System.debug('---------------- pageRef = ' + pageRef);
        update info.Call;
        
        //perform base class operation
        return pageRef;
    }   
        
    private WorkflowInfo resetContacts(WorkflowInfo info)
    {
        info.NewContactInfos = new List<ContactInfo>();
        
        Contact newContact1 = new Contact();
        Contact newContact2 = new Contact();
        ContactInfo newcontactInfo = new ContactInfo(); 
        newContact1.Description = 'newContact1';
        newContact2.Description = 'newContact2';
        
        newcontactInfo.contact = newContact1;
        newcontactInfo.ConSlct = false;
        info.NewContactInfos.Add(newcontactInfo);
        
        newcontactInfo = new ContactInfo();
        newcontactInfo.contact = newContact2;
        newcontactInfo.ConSlct = false;
        info.NewContactInfos.Add(newcontactInfo);
        
        return info;
    }
    
    private WorkflowInfo ResetOpportunities(WorkflowInfo info)
    {
        //Reset Opportunity collection
        info.Opportunities = new List<Opportunity>();
        info.SelectedOpportunities = new List<OppSelectClass>();
        
        Opportunity newOpp = new Opportunity();
        OppSelectClass newOppInfo = new OppSelectClass();
        newOppInfo.opp = newOpp;
        
        info.Opportunities.Add(newOpp);
        info.SelectedOpportunities.Add(newOppInfo);
        return info;
    }  
}