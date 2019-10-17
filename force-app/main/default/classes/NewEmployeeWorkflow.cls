public class NewEmployeeWorkflow extends Workflow{

private DisplayMode objDisplayMode; //displaymode object for displaymode constants
    private Integer WorkflowMode; //workflowmode: 0-Initial
    private MessageConstants msgConstants;
    //public String callModeString = ''; //change for wrap up
    
    private final Integer STEP1 = 0; //intial view
    private final Integer STEP2 = 1; //after user has created a new lead
    private final Integer STEP3 = 2; //user opts to create a new lead
    
    public NewEmployeeWorkflow(){
        //callModeString = 'CUSTOMERCALLEXISTCUST'; //change for wrap up
        objDisplayMode = new DisplayMode();
        msgConstants = new MessageConstants();
        WorkflowMode = STEP1;
    }
    
    //Sets the various properties of WorkflowInfo object for displaying new lead page
    public override WorkflowInfo SetWorkflow(WorkflowInfo info)
    {
        //info.callModeString = this.callModeString; //change for wrap up 
        Integer mode = info.call.Workflow_Step__c.intValue();
        
        if(info.exitAppointment != null)
        {
            mode = STEP2;                   
        }   
        
        WorkflowMode = mode;
         
        if(mode == STEP1)
        {
            info = WorkflowHelper.newCallData(info);
            info = WorkflowHelper.SetContacts(info);
            
        }
        else
            info = WorkflowHelper.fetchCallData(info);
        
        info = SetWorkflowComponents(info);
        return info;
    }
    
    //Shows/hides various workflow components.
    private WorkflowInfo SetWorkflowComponents(WorkflowInfo info)
    {   
        Integer mode = WorkflowMode;
        info = SetInitialValues(info);
        
        if(mode == STEP1)
        {
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowAddNewContact = true;
            info.ShowEditOpportunities = true;
            info.ShowEmployeeQuestions = true;//added by Ashok G on JUL 03,2015
            info.ShowCustQuestions = true;//added by Ashok G on JUL 03,2015
            
            //Boolean properties to display/hide buttons
            info.ShowBtnWasteCall = true;
            info.ShowBtnCreateLead = true;
                       
            info.ViewModeAccountView = objDisplayMode.EDIT;
            info.ViewModeAddNewContact = objDisplayMode.EDIT;
            info.ViewModeEditOpportunities = objDisplayMode.EDIT;
            info.ViewModeCustomer = objDisplayMode.EDIT;//added by Ashok G
            info.ViewModeEmployee = objDisplayMode.EDIT;//added by Ashok G
        }
        else if(mode == STEP2)
        {
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
            info.ShowEmployeeQuestions = true;//added by Ashok G on JUL 03,2015
            info.ShowCustQuestions = true;//added by Ashok G on JUL 03,2015
            
            //Boolean properties to display/hide buttons

            //info.ShowBtnNewSalesAppointment = true;
            if(info.ShowFWAMessage == true)
            {
                info.ShowBtnNewSalesAppointment = false;
            }
            else
            {               
                info.ShowBtnNewSalesAppointment = true;
                if(info.isGDAEnabled)
                info.showGDBtn = true;
            }
            info.ShowBtnWrapUpCall = true;

            
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.VIEW;
            info.ViewModeCustomer = objDisplayMode.VIEW;//added by Ashok G
            info.ViewModeEmployee = objDisplayMode.VIEW;//added by Ashok G
        }
        else if(mode == STEP3)
        {
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
            info.ShowEmployeeQuestions = true;//added by Ashok G on JUL 03,2015
            info.ShowCustQuestions = true;//added by Ashok G on JUL 03,2015
            
            //Boolean properties to display/hide buttons
            info.ShowBtnWrapUpCall = true;
            info = WorkflowHelper.GetAppointments(info);
            
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            //info.ViewModeEditOpportunities = objDisplayMode.VIEW;
            info.ViewModeEditOpportunities = objDisplayMode.APPOINTSUCCESS;
            
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
        return info;    
    }
    
    //Handles click event of Create Lead button
    public override WorkflowInfo CreateLead_Click(WorkflowInfo info)
    {
        
        try
        {
            System.debug('------------------------ saving lead data');
            info = WorkflowHelper.CreateLeadAccountOpp(info);
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
        return info;
    }
    
    //Handles click event of New Sales Appointment button
    public override PageReference NewSalesAppointment_Click(WorkflowInfo info)
    {
        //Increment workflow step
        PageReference pageRef = super.NewSalesAppointment_Click(info);
        info.Call.Workflow_Step__c = STEP3;
        System.debug('---------------- pageRef = ' + pageRef);
        update info.Call;
        
        //perform base class operation
        return pageRef;
    }
    
    
}