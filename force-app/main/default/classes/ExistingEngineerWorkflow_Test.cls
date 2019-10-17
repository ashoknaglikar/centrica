/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ExistingEngineerWorkflow_Test {

    static testmethod void existingEngineerWorkflowMethod(){
        ExistingEngineerWorkflow controller= new ExistingEngineerWorkflow();
        test.startTest();
		Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        
        Inbound_Call__c inboundCall = new Inbound_Call__c();
        inboundCall.Workflow_Step__c = 1;
        insert inboundCall;
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

        Campaign campaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert campaign;    
        //Campaign campaign=[select Id from campaign limit 1];
        List<Opportunity> opportunityList=new List<Opportunity>();
        
        Opportunity opp= new Opportunity();
        opp.name='Test Opp';
        opp.StageName='Active';
        opp.CloseDate=System.today();
        opp.CampaignId=campaign.Id;
        opp.AccountId=account.Id;
        opp.LeadSource='Marcomms';
        opp.Product_Interest__c='Solar';
        insert opp;
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
        
        //opp=[select Id,CHI_Lead_Id1__c,CHI_Lead_Id__c,name from opportunity where id =:opp.Id ];            
        Supplier__c supplier = new Supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '2991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
	    insert emp;
	    Datetime startTime;
		Datetime endTime;
	    Datetime now;
	    // String who = contact.id;
	     now = system.today();  
	     startTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 13, 0, 0);
       	 endTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 21, 0, 0);			                                 
		 Appointment__c app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = 'Test', 
                                 Assigned_To__c = emp.id, OwnerId = user.id,
                                 Description__c = 'Test desc',
                                 Do_Not_Send_To_Premier__c = false,Mode__c='Installation',
                                 Resource_Type__c ='A',Sale_Flag__c = false,Show_Time_As__c= 'Out of Office',
                                 Time_Band__c = 'AM',Status_Reason__c = 'Purchase Elsewhere', Status__c ='New',
                                 Type__c = 'Sales', Opportunity__c = opportunity.Id, Who__c =contact1.Id );	
        
        insert app;
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        appointmentList.add(app);//=[Select a.Name, a.Id From Appointment__c a limit 2];
        
        test.stopTest();
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
        
        controller.SetWorkflow(info);
        controller.Continue_Click(info);
        controller.CreateLead_Click(info);
        controller.CreateNewLead_Click(info);
        controller.NewSalesAppointment_Click(info);
        controller.BookSurveyAppointment_Click(info);
        controller.ReArrangeAppointment_Click(info);
        
        //***************************************
        OppSelectClass oppClassObject= new OppSelectClass();
        oppClassObject.oppSelected=true;
        oppClassObject.opp=opportunity;
        
        List<OppSelectClass> oppList= new List<OppSelectClass>();
        oppList.add(oppClassObject);        
        info.SelectedOpportunities=oppList;
        controller.Continue_Click(info);        
        //******************************************
        
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
        
        info.call.Workflow_Step__c=4;
        controller.SetWorkflow(info);
        //controller.CreateLead_Click(info);  
        
        info.exitAppointment = '1';
        controller.SetWorkflow(info);  
        
        info.ShowFWAMessage = true;
        controller.SetWorkflow(info);  
       
        //*******************************************
        info.ShowFWAMessage=false;
        info.call.Workflow_Step__c=1;
        controller.SetWorkflow(info); 
        
        opportunity.StageName = 'Active';
        update opportunity;
        OppSelectClass oppClassObject1= new OppSelectClass();
        oppClassObject1.oppSelected=true;
        oppClassObject1.opp=opportunity;
        
        List<OppSelectClass> oppList1= new List<OppSelectClass>();
        oppList1.add(oppClassObject);
        info.SelectedOpportunities=null;
        info.SelectedOpportunities=oppList1;
        controller.Continue_Click(info);
        controller.CreateNewLead_Click(info);
        //********************************************  
            
    }
}