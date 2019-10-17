@isTest 
private class HsaWorkflow_Test{
    static testmethod void hsaWorkflowMethod(){
        HsaWorkflow controller= new HsaWorkflow();
		Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c limit 1];
        
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
        
        insert account;
        
        List<Contact> contactList = new List<Contact>();
        Contact contact=new Contact();
            contact.Primary_Contact__c=true;
            contact.Phone='9022332343';                    
            contact.MailingStreet='test Street';
            contact.MailingState='Test State';
            contact.MailingPostalCode='4411189';
            contact.MailingCountry='Test country';
            contact.MailingCity='Test City';
            contact.LastName='Last Name';
            contact.FirstName='First name';
            contact.Email='test@gmail.com';
            contact.AccountId=account.Id;
        
            insert contact;
            
            Contact contact1=new Contact();
            contact1.Primary_Contact__c=false;
            contact1.Phone='9022332343';                    
            contact1.MailingStreet='test Street';
            contact1.MailingState='Test State1';
            contact1.MailingPostalCode='M25 0ET';
            contact1.MailingCountry='Test country1';
            contact1.MailingCity='Test City';
            contact1.LastName='Last Name1';
            contact1.FirstName='First name1';
            contact1.Email='test@gmail.com';
            contact1.AccountId=account.Id;
        
            insert contact1;

            contactList.add(contact);
            contactList.add(contact1);

            
        Campaign campaign=[select Id from campaign limit 1];
        List<Opportunity> opportunityList=new List<Opportunity>();
        
        Opportunity opp= new Opportunity();
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
      
        insert opportunity;
        opportunityList.add(opportunity);
        
        System.debug('### opportunity.CHI_Lead_Id1__c==>'+opportunity.CHI_Lead_Id1__c);
        
        opp=[select Id,CHI_Lead_Id1__c,CHI_Lead_Id__c,name from opportunity where CHI_Lead_Id__c!=null and AccountId!=null limit 1];            
        
        List<Appointment__c> appointmentList=[Select a.Name, a.Id From Appointment__c a limit 2];
        Workflow.WorkflowInfo info= new Workflow.WorkflowInfo();
        info.call=inboundCall;
        System.debug('### info.call.Workflow_Step__c: '+info.call.Workflow_Step__c);
        info.call.Workflow_Step__c=1;
        info.call.CHI_Lead__c=opp.Id;
        info.CurrentAccount=account;
        info.WorkflowType=1;
        info.DisplayAccount=true;
        info.Contacts=contactList;
        info.Opportunities=opportunityList;
        info.Appointments=appointmentList;
        info.payment= new BGS_Payment__C(); 
        
        controller.SetWorkflow(info);
        controller.Continue_Click(info);
        controller.CreateLead_Click(info);
        controller.CreateNewLead_Click(info);
        controller.NewSalesAppointment_Click(info);
        controller.BookSurveyAppointment_Click(info);
        controller.CreatePayment_Click(info);
        
        info.call.Workflow_Step__c=0;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info);  
        
        info.call.Workflow_Step__c=1;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info);  
        
        info.call.Workflow_Step__c=2;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info); 
        
        info.call.Workflow_Step__c=3;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info); 
        
        info.IsError = false;         
        info.payment.Payment_Type__c='Deposit';
        info.payment.Payment_Method__c='Cash';
        info.payment.Payment_Date__c=System.Today();
        info.payment.EPDQ_Authorisation__c='444';
        info.payment.BGS_Payment_Reference_Num__c='454';
        info.payment.Amount__c=1000;
        controller.CreatePayment_Click(info);
		controller.ReArrangeAppointment_Click(info);
		
		info.exitAppointment = '1';
		controller.SetWorkflow(info);
		
		//Test Code coverage gor Appointment : START
		//Profile profile= [Select p.Name, p.Id From Profile p where p.Name='Standard Platform Light User'];
		//User user = [Select u.ProfileId, u.LastName, u.IsActive, u.Id, u.FirstName From User u where u.ProfileId=:profile.Id limit 1];
		//Select e.Name, e.Last_Name__c, e.First_Name__c, e.Employee_Number__c From Employee__c e
		/*Employee__c employee = new Employee__c();
		employee.Name='Test emp - 87356';
		employee.First_Name__c='Test';
		employee.Last_Name__c='emp';
		employee.Employee_Number__c='87356';
		
		insert employee;
		
		RecordType appointRecordType=[Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType='Appointment__c' and  r.Name='Available'];
		Appointment__c appointment = new Appointment__c();
		appointment.Assigned_To__c = employee.Id;
		appointment.RecordTypeId = appointRecordType.Id;
		appointment.Visit_Type__c = 'First Visit';
		appointment.Type__c = 'Sales';
		appointment.Status__c = 'New';
		
		appointment.Mode__c = 'SA';
		
		appointment.Opportunity__c=opportunity.Id;
		
		Date todaysDate= System.today();
		String year =(''+todaysDate.year()).trim();
		String month = (todaysDate.month()+'').trim();
		String day = (todaysDate.day()+'').trim();
		String startHour='10';
		String endHour='14';
		String minute='00';
		String second='00';
		String startDate = year + '-' + month+ '-' + day + ' ' + startHour + ':' +minute + ':' + second;
		String endDate = year + '-' + month+ '-' + day + ' ' + endHour + ':' +minute + ':' + second;
		appointment.Start__c=datetime.valueOf(startDate);
		appointment.End__c=datetime.valueOf(startDate);
		
		insert appointment;
		
		List<Appointment__c> appointList = new List<Appointment__c>();
		appointList.add(appointment);
		
		info.Appointments = appointList;
		info = WorkflowHelper.GetAppointments(info);
	
		info.call.Workflow_Step__c=2;
        controller.SetWorkflow(info);
        
        info.call.Workflow_Step__c=3;
        controller.SetWorkflow(info);
		
		*/
		//Select a.Visit_Type__c, a.Type__c, a.Status__c, a.Start_Time__c, a.Name, a.Mode__c, a.End_Time__c, a.Assigned_To__c From Appointment__c a where a.name='A-03956299'
		//Test Code coverage gor Appointment : END
		
        
    }
}