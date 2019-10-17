public class HsaWorkflow extends Workflow
{

	private DisplayMode objDisplayMode; //displaymode object for displaymode constants
    private Integer WorkflowMode; //workflowmode: 0-Initial
    private MessageConstants msgConstants;
    
    private final Integer STEP1 = 0; //intial view
    private final Integer STEP2 = 1; //after user has created a new lead
    private final Integer STEP3 = 2; //user has selected an existing lead
    private final Integer STEP4 = 3; //Going for boking appointment
    
    
    public HsaWorkflow()
    {
        objDisplayMode = new DisplayMode();
        msgConstants = new MessageConstants();
        WorkflowMode = STEP1;
    }
    
    ////////////////////////
    //Sets the various properties of WorkflowInfo object for displaying lead page
    public override WorkflowInfo SetWorkflow(WorkflowInfo info)
    {
    	Integer mode = info.Call.Workflow_Step__c.intValue();
    	
    	if(info.exitAppointment != null)
    	{
    		mode = STEP3;
    		
    	}
    	
    	WorkflowMode = mode;
        info = WorkflowHelper.fetchCallData(info);
        info = WorkflowHelper.GetAppointments(info);
        //info = WorkflowHelper.RemoveNonCallOpportunities(info);
        info = SetWorkflowComponents(info);
        
        return info;
    }
    
    //Shows/hides various workflow components on basis of workflow stage 
    private WorkflowInfo SetWorkflowComponents(WorkflowInfo info)
    {
        Integer mode = WorkflowMode;
        System.debug(' ------------------- mode = ' + mode);
        info = SetInitialValues(info);
        
        ///////////////////
       	if(mode == STEP1)
        {
        	info.ViewModeAccountView = objDisplayMode.STATUS;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            
            info.ShowBtnContinue = true;
           
            //Boolean properties to display/hide components
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowSelectOpportunities = true;
        }
        else if(mode == STEP3)
        {
	        //////////////////
	        info.ViewModeAccountView = objDisplayMode.VIEW;
	        info.ViewModeViewContacts = objDisplayMode.VIEW;
	        //info.ViewModeEditOpportunities = objDisplayMode.VIEW;
	        info.ViewModeEditOpportunities = objDisplayMode.APPOINTSUCCESS;
	        //info.ViewModeAppointments = objDisplayMode.EXISTING;
	        if(info.exitAppointment != null)
    		{
				info = WorkflowHelper.RemoveNonCallOpportunities(info);           	           		
    		}
	        
			info.ShowBtnCancelAppointment= true;
			info.ShowBtnRearrangeAppointment= true;
			info.ShowBtnBookSurveyAppointment= true;
			info.ShowBtnCreatePayment= true;
			info.ShowBtnWrapUpCall= true;
		            
	        //Boolean properties to display/hide components
	        info.ShowAccountView = true;
	        info.ShowViewContacts = true;
	        info.ShowEditOpportunities = true;
	        info.ShowAppointments = true;
	   		info.ShowPayment = true;
	   		
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
        else if(mode == STEP4)
        {
            info.ShowAccountView = true;
            info.ShowViewContacts = true;
            info.ShowEditOpportunities = true;
            
            //Boolean properties to display/hide buttons
			info.ShowBtnWrapUpCall = true;

            
            info.ViewModeAccountView = objDisplayMode.VIEW;
            info.ViewModeViewContacts = objDisplayMode.VIEW;
            //info.ViewModeEditOpportunities = objDisplayMode.VIEW;
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
        for(OppSelectClass selectListItem :info.SelectedOpportunities)
        {
            if(selectListItem.oppSelected)
            { 
                oppSelected++;
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
            
            WorkflowMode = STEP3;
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
    
    public override WorkflowInfo CreateLead_Click(WorkflowInfo info)
    {        
        return info;
    }
    
    public override WorkflowInfo CreateNewLead_Click(WorkflowInfo info)
    {        
        return info;
    }    
    
    //Handles click event of Book Survey Appointment button
    /*public override WorkflowInfo BookSurveyAppointment_Click(WorkflowInfo info)
    {
    	List<Opportunity> oppList=info.Opportunities;
    	info.DisplayPaymentMessage = false;
    	
    	for(integer i=0;i<oppList.size();i++)
    	{
    		oppList[i].Visit_Type__c = 'Survey';
    	}
    	try
    	{
    		upsert oppList;
    	}
    	catch(Exception e)
    	{
    		info = WorkflowHelper.SetError(info, e.getMessage());
    	}
        return info;
    }*/
    
    //Handles click event of Re-arrange Appointment button
    public override PageReference ReArrangeAppointment_Click(WorkflowInfo info)
    {
    	//Increment workflow step
    	PageReference pageRef = super.ReArrangeAppointment_Click(info);    	
    	system.debug('----inside ReArrangeAppointment_Click pageRef----'+pageRef);
    	
    	info.Call.Workflow_Step__c = STEP4;
    	
    	System.debug('---------------- pageRef = ' + pageRef);
    	update info.Call;
    	
    	//perform base class operation
        return pageRef;
    }	
    
   //Handles click event of Create Payment button.
    public override WorkflowInfo CreatePayment_Click(WorkflowInfo info){
    	System.debug('*******Payment object '+info.Payment);
    	System.debug('*******Payment date '+info.Payment.Payment_Date__c);
    	System.debug('*******Payment amount '+info.Payment.Amount__c);
    	System.debug('*******Payment type '+info.Payment.Payment_Type__c);
    	BGS_Payment__C payment=info.Payment;
    	info.Payment = payment;
		List<Opportunity> oppList = info.Opportunities;
    	    	 
    	if( oppList!= null && oppList.size()>0 )
    	{
    	payment.Opportunity__c = info.Opportunities[0].Id;
    	}
    	    	
    	if(info.Payment.Payment_Date__c == null)
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTDATE);
    		System.debug('### Payment date  null');
    	}
    	if(info.Payment.Amount__c == null)
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTVALUE);
    		System.debug('### Payment amount null');    		
    	}
    	if(info.Payment.Payment_Type__c == null || info.Payment.Payment_Type__c == '')
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTTYPE);
    		System.debug('### Payment date  null');
    	}
    	if(info.Payment.Payment_Method__c == null || info.Payment.Payment_Method__c == '')
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTMETHOD);
    		System.debug('### Payment method  null');
    	}
    	if(info.Payment.BGS_Payment_Reference_Num__c == null || info.Payment.BGS_Payment_Reference_Num__c == '')
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTBGREFNUMBER);
    		System.debug('### Payment ref number  null');
    	}
    	if(info.Payment.BGS_Payment_Reference_Num__c != null)
    	{
    		System.debug('### inside valid num check');
    		Double num = 0.0;
    		try
    		{
    			System.debug('### inside try');
    			num = Double.valueOf(info.Payment.BGS_Payment_Reference_Num__c);
    		}
    		catch(Exception e)
    		{
    			System.debug('### inside catch');
    			info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTVALIDBGREFNUMBER);	
    		}    		
    	}
    	
    	if(info.Payment.EPDQ_Authorisation__c == null || info.Payment.EPDQ_Authorisation__c == '')
    	{
    		info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTPAYEEREFNUMBER);
    		System.debug('### Payee ref number  null');
    	}
    	if(info.Payment.EPDQ_Authorisation__c != null)
    	{
    		System.debug('### inside valid num check');
    		Double num = 0.0;
    		try
    		{
    			System.debug('### inside try');
    			num = Double.valueOf(info.Payment.EPDQ_Authorisation__c);
    		}
    		catch(Exception e)
    		{
    			System.debug('### inside catch');
    			info = WorkflowHelper.SetError(info, msgConstants.ERR_PAYMENTVALIDPAYEEREFNUMBER);	
    		}    		
    	}
    	
    	if(!info.IsError)    	
    	{
	    	try
	    	{	
	    		System.debug('### inside try......insertion');	    		
	    		insert info.Payment;
	    		info.DisplayPaymentMessage = true;
	    		info.Payment = new BGS_Payment__c();
	    		System.debug('### Payment created successfully....');
	    	}
	    	catch(Exception e)
	    	{
	    		System.debug('### inside catch......insertion');
	    		info = WorkflowHelper.SetError(info, e.getMessage());
	    	}
    	}
    	return info;
    }
    
    
    
}