@isTest
private class NewEngineerWorkflow_Test{

    static testmethod void newEngineerWorkflowMethod(){
        NewEngineerWorkflow controller= new NewEngineerWorkflow();
		
		Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
		
        //Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c limit 1];
        
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
        info.call=callObj;
        System.debug('### info.call.Workflow_Step__c: '+info.call.Workflow_Step__c);
        info.call.Workflow_Step__c=1;
        info.call.CHI_Lead__c=opp.Id;
        info.CurrentAccount=account;
        info.WorkflowType=1;
        info.DisplayAccount=true;
        info.Contacts=contactList;
        info.Opportunities=opportunityList;
        info.Appointments=appointmentList;
        
        controller.SetWorkflow(info);
        controller.Continue_Click(info);
        controller.CreateLead_Click(info);
        controller.CreateNewLead_Click(info);
        controller.BookSurveyAppointment_Click(info);
        controller.NewSalesAppointment_Click(info);
        
        info.call.Workflow_Step__c=1;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info);

        info.call.Workflow_Step__c=2;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info);

        info.WorkflowType=0;
        info.call.Workflow_Step__c=0;
        controller.SetWorkflow(info);
        controller.CreateLead_Click(info);



    }
}