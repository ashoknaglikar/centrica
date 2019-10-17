@isTest
private class Workflow_Test{
    static testmethod void workflowTestMethod(){
        
        //ExistingCustomerWorkflow controller= new ExistingCustomerWorkflow();
        Workflow workflowObject;
        
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c where id=:callObj.id limit 1];
        
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
            contact1.MailingPostalCode='M25 0UJ';
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
        
        opp=[select Id,CHI_Lead_Id1__c,CHI_Lead_Id__c,name from opportunity where Id = :opportunity.Id];            
        
        //List<Appointment__c> appointmentList=[Select a.Name, a.Id From Appointment__c a limit 2];
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
        info.ContactInfos = new list<ContactInfo>();
        for(Contact c: contactList)
        {
            ContactInfo co = new ContactInfo();
            co.ConSlct = false;
            co.contact = c;
            info.ContactInfos.add(co);
        }
        //info.Appointments=appointmentList;
        
      
        
        workflowObject=WorkflowFactory.GetWorkFlow(1);
        workflowObject.SetInitialValues(info);
        
        workflowObject.Initialize(info);
        
        workflowObject.SalesAppointment_Click(info);
        workflowObject.CreatePayment_Click(info);
        
        workflowObject.NewSalesAppointment_Click(info);
        workflowObject.CancelAppointment_Click(info);
        
        info.SelectedAppointments = new list<SelectedAppointment>();
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c=userinfo.getuserid();
        insert emp;
        
        Id App = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app1 = TestClassHelper.createAppointment(opportunity,emp.Id,userinfo.getuserid(),App,contact.Id);
        insert app1;
        SelectedAppointment appSel = new SelectedAppointment(); 
        appSel.appointment = app1;
        appSel.appoinSelected = true;
        info.SelectedAppointments.add(appSel);
        
        workflowObject.CancelAppointment_Click(info);
        workflowObject.ReArrangeAppointment_Click(info);
        workflowObject.BookSurveyAppointment_Click(info);
        
        workflowObject.WrapCall_Click(info);
        
        workflowObject.WasteCall_Click(info);
        

    }
}