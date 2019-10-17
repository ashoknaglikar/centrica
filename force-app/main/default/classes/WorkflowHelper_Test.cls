@isTest
private class WorkflowHelper_Test{
    static testmethod void workflowTestmethod(){
        cls_IsRun.generalTriggerSwitch= true;
        List<Opportunity> opportunityList=new List<Opportunity>();
        List<Contact> contactList = new List<Contact>();
        List<Appointment__c> appointmentList=new List<Appointment__c>();
        //NewCustomerWorkflow controller= new NewCustomerWorkflow();
        
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
        
        Contact contact=new Contact();
            contact.Primary_Contact__c=true;
            contact.Phone='9022332343';                    
            contact.MailingStreet='test Street';
            contact.MailingState='Test State';
            contact.MailingPostalCode='4411189';
            contact.MailingCountry='Test country';
            contact.MailingCity='Test City';
            contact.Salutation='Mr';
            contact.LastName='Last Name';
            contact.FirstName='First name';
            contact.Contact_Type__c='Owner';
            contact.Email='test@gmail.com';
            contact.AccountId=account.Id;
            contact.Contact_Type__c = 'Owner';
        insert contact;
        System.debug('###*** contact object---> '+contact);
        
        Contact contact1=new Contact();
            contact1.Primary_Contact__c=false;
            contact1.Phone='9022332343';                    
            contact1.MailingStreet='test Street';
            contact1.MailingState='Test State1';
            contact1.MailingPostalCode='M25 3UJ';
            contact1.MailingCountry='Test country1';
            contact1.MailingCity='Test City';
            contact1.Salutation='Mr';
            contact1.LastName='Last Name1';
            contact1.FirstName='First name1';
            contact1.Contact_Type__c='Owner';
            contact1.Email='test@gmail.com';
            contact1.AccountId=account.Id;
            
        insert contact1;
        System.debug('###*** contact1 object---> '+contact1);
        
        contactList.add(contact);
        contactList.add(contact1);
        
        ContactInfo conInfo = new ContactInfo();
        conInfo.contact= contact;
        conInfo.AddSlct = true;
        conInfo.ConSlct = true;
        conInfo.AddStrt='Street';
        conInfo.AddCty='city';
        conInfo.AddStat='state';
        conInfo.AddCntr='country';
        conInfo.AddZip='442222';
        conInfo.ConAdd='conAddress';
        
        ContactInfo conInfo1 = new ContactInfo();
        
        conInfo1.contact= contact1;
        conInfo1.AddSlct = true;
        conInfo1.ConSlct = true;
        conInfo1.AddStrt='Street';
        conInfo1.AddCty='city';
        conInfo1.AddStat='state';
        conInfo1.AddCntr='country';
        conInfo1.AddZip='442222';
        conInfo1.ConAdd='conAddress';

        List<ContactInfo> contactInfoList= new List<ContactInfo>();        
        contactInfoList.add(conInfo);
        contactInfoList.add(conInfo1);  
        
        
        Campaign campaign=[select Id from campaign limit 1];
        
        Opportunity opp= new Opportunity();
        Opportunity opportunity = new Opportunity();
        
                
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        opportunity.Latest_customer_category__c = 5;
        opportunity.Unsafe_Appliance_Reason__c = 'Immediately dangerous';
        opportunity.Customer_agreed_to_appointment__c = 'Yes';
        insert opportunity;
        opportunityList.add(opportunity);

        System.debug('### opportunity.CHI_Lead_Id1__c==>'+opportunity.CHI_Lead_Id1__c);
        opp=[select Id,CHI_Lead_Id1__c,CHI_Lead_Id__c,name from opportunity where CHI_Lead_Id__c!=null and AccountId!=null limit 1];            
        //appointmentList=[Select a.Name, a.Id From Appointment__c a limit 2];
        Workflow.WorkflowInfo info= new Workflow.WorkflowInfo();
        info.call=inboundCall;
        
        /////////////////////////////////
        info.NonClosedOpportunityList = info.Opportunities;
        
        Employee__c employee = new Employee__c();
        employee.Name='Test emp - 87356';
        employee.First_Name__c='Test';
        employee.Last_Name__c='emp';
        employee.Employee_Number__c='Emp70609';
        
        insert employee;
        System.debug('###*** Employee object---> '+employee);
        System.debug('###*** employee.Id---> '+employee.Id);
        
        
        RecordType appointRecordType=[Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType='Appointment__c' and  r.Name='Available'];
        Appointment__c appointment = new Appointment__c();
        //appointment.Assigned_To__c = employee.Id;
        appointment.RecordTypeId = appointRecordType.Id;
        appointment.Visit_Type__c = 'First Visit';
        appointment.Type__c = 'Sales';
        appointment.Status__c = 'New';
        
        appointment.Mode__c = 'SA';
        
        appointment.Opportunity__c=opportunity.Id;
        appointment.Who__c=contact.Id;
        
        Date todaysDate= System.today().addDays(1);
        String year =(''+todaysDate.year()).trim();
        String month = (todaysDate.month()+'').trim();
        String day = (todaysDate.day()+'').trim();
        
        Date tommorrowsDate= System.today().addDays(2);
        String endYear =(''+tommorrowsDate.year()).trim();
        String endMonth = (tommorrowsDate.month()+'').trim();
        String endDay = (tommorrowsDate.day()+'').trim();
        
        String startHour='14';
        String endHour='16';
        String minute='00';
        String second='00';
        
        String startDate = year + '-' + month+ '-' + day + ' ' + startHour + ':' +minute + ':' + second;
        String endDate = endYear + '-' + endMonth+ '-' + endDay + ' ' + endHour + ':' +minute + ':' + second;
        
        appointment.Start__c=datetime.valueOf(startDate);
        appointment.End__c=datetime.valueOf(endDate);
        
        insert appointment;
        System.debug('###*** appointment object---> '+appointment);
        
        List<Appointment__c> appointList = new List<Appointment__c>();
        appointList.add(appointment);
        
        info.call.CHI_Lead__c=opportunity.Id;
        info.Appointments = appointList;
        WorkflowHelper.GetAppointments(info);
        
        /////////////////////////////////
              
        System.debug('### info.call.Workflow_Step__c: '+info.call.Workflow_Step__c);
        info.call.Workflow_Step__c=1;
        info.call.CHI_Lead__c=opp.Id;
        info.CurrentAccount=account;
        info.WorkflowType=1;
        info.DisplayAccount=true;
        info.Contacts=contactList;
        info.Opportunities=opportunityList;
        info.Appointments=appointList;
        
        System.debug('###*** info.opportunities size()--'+info.opportunities.size());
        
        
        info.ContactInfos = contactInfoList;
        info.NewContactInfos = contactInfoList;
        
        System.debug('###*** info.ContactInfos size()--'+info.ContactInfos.size());
        System.debug('###*** info.NewContactInfos size()--'+info.NewContactInfos.size());
        WorkflowHelper.ValidateContact(info);
        
        info.call.Workflow_Step__c=1;
        
        //controller.SetWorkflow(info);
        //controller.CreateLead_Click(info);
        
        info.call.Workflow_Step__c=2;
        //controller.SetWorkflow(info);
        //controller.CreateLead_Click(info);

        info.call.Workflow_Step__c=3;
        //controller.SetWorkflow(info);
        //controller.CreateLead_Click(info);
        
        info.Call.Billing_Zip__c = 'M19 2QB';
        WorkflowHelper.fetchCallData(info);
        WorkflowHelper.GetAppointments(info);
        WorkflowHelper.newCallData(info);
        WorkflowHelper.ValidateContact(info);
        
        info.Opportunities=opportunityList;
        
        info.include_priority_install = false;
        
        WorkflowHelper.CreateLeadAccountOpp(info);
        WorkflowHelper.getCallByCallID(inboundCall.Id);
        callObj.CHI_Lead__c = opportunity.Id;
        update callObj;
        WorkflowHelper.getAllCallsByOpportunityID(opportunity.Id);
        
        WorkflowHelper.RemoveNonCallOpportunities(info);
       
        //To cover errors of validate contact:
        Contact contact3=new Contact();
        contact3.Primary_Contact__c=true;
        contact3.Phone='9022332343';                    
        contact3.MailingStreet='test Street';
        contact3.MailingState='Test State';
        contact3.MailingPostalCode='4411189';
        contact3.MailingCountry='Test country';
        contact3.MailingCity='Test City';
        contact3.LastName='Last Name';
        contact3.FirstName='First name';
        contact3.Contact_Type__c='Owner';
        contact3.Email='test@gmail.com';
        contact3.AccountId=account.Id;
        contact3.Salutation='Mr';
        
        insert contact3;
        
        ContactInfo conInfo2 = new ContactInfo();
        conInfo2.contact= contact3;
        conInfo2.AddSlct = true;
        conInfo2.ConSlct = true;
        conInfo2.AddStrt='Street';
        conInfo2.AddCty='city';
        conInfo2.AddStat='state';
        conInfo2.AddCntr='country';
        conInfo2.AddZip='442222';
        conInfo2.ConAdd='conAddress';
        
        ContactInfo conInfo3 = new ContactInfo();
        conInfo3.contact= contact3;
        conInfo3.AddSlct = true;
        conInfo1.ConSlct = true;
        conInfo3.AddStrt='Street';
        conInfo3.AddCty='city';
        conInfo3.AddStat='state';
        conInfo3.AddCntr='country';
        conInfo3.AddZip='442222';
        conInfo3.ConAdd='conAddress';

        List<ContactInfo> contactInfoList1= new List<ContactInfo>();        
        contactInfoList1.add(conInfo2);
        contactInfoList1.add(conInfo3);     
         
        info.NewContactInfos=contactInfoList1; 
        info.ContactInfos=contactInfoList1; 
        WorkflowHelper.ValidateContact(info);
        
        info.WorkflowType= 1;
        info.Opportunities = opportunityList;
        WorkflowHelper.ValidateOpportunity(info);
        test.starttest();
        //To cover createLeadAccountOpp menthod: 
        Contact contact5=new Contact();
            contact5.Primary_Contact__c=true;
            contact5.Phone='9022332343';                    
            contact5.MailingStreet='test Street';
            contact5.MailingState='Test State';
            contact5.MailingPostalCode='4411189';
            contact5.MailingCountry='Test country';
            contact5.MailingCity='Test City';
            contact5.Salutation='Mr';
            contact5.LastName='Last Name';
            contact5.FirstName='First name';
            contact5.Contact_Type__c='Owner';
            contact5.Email='test@gmail.com';
            contact5.AccountId=account.Id;
            contact5.Salutation='Mr';
        insert contact5;
        System.debug('###*** contact object---> '+contact5);
        
        Contact contact6=new Contact();
            contact6.Primary_Contact__c=true;
            contact6.Phone='9022332343';                    
            contact6.MailingStreet='test Street';
            contact6.MailingState='Test State1';
            contact6.MailingPostalCode='M25 O17';
            contact6.MailingCountry='Test country1';
            contact6.MailingCity='Test City';
            contact6.Salutation='Mr';
            contact6.LastName='Last Name1';
            contact6.FirstName='First name1';
            contact6.Contact_Type__c='Owner';
            contact6.Email='test@gmail.com';
            contact6.AccountId=account.Id;
            contact6.Salutation='Mr';
        insert contact6;
        System.debug('###*** contact1 object---> '+contact6);
        
        contactList.add(contact5);
        contactList.add(contact6);
        
        ContactInfo conInfo5 = new ContactInfo();
        conInfo5.contact= contact5;
        conInfo5.AddSlct = true;
        conInfo5.ConSlct = true;
        conInfo5.AddStrt='Street';
        conInfo5.AddCty='city';
        conInfo5.AddStat='state';
        conInfo5.AddCntr='country';
        conInfo5.AddZip='442222';
        conInfo5.ConAdd='conAddress';
        
        ContactInfo conInfo6 = new ContactInfo();
        conInfo6.contact= contact6;
        conInfo6.AddSlct = true;
        conInfo6.ConSlct = false;
        conInfo6.AddStrt='Street';
        conInfo6.AddCty='city';
        conInfo6.AddStat='state';
        conInfo6.AddCntr='country';
        conInfo6.AddZip='442222';
        conInfo6.ConAdd='conAddress';

        List<ContactInfo> contactInfoList3= new List<ContactInfo>();  
        List<ContactInfo> contactInfoList4= new List<ContactInfo>();      
        contactInfoList3.add(conInfo5);
        contactInfoList4.add(conInfo6);   
        
        Opportunity opportunity1 = new Opportunity();
        
        opportunity1.name='Test Opp';
        opportunity1.StageName='Active';
        opportunity1.CloseDate=System.today();
        opportunity1.CampaignId=campaign.Id;
        opportunity1.AccountId=account.Id;
        opportunity1.LeadSource='Marcomms';
        opportunity1.Product_Interest__c='Solar';
        opportunity1.Referral_Employee__c=employee.Id;
        opportunity1.Latest_customer_category__c = 5;
        opportunity1.Unsafe_Appliance_Reason__c = 'Immediately dangerous';
        opportunity1.Customer_agreed_to_appointment__c = 'Yes';
        insert opportunity1;
        
        List<Opportunity> opportunityListNew= new List<Opportunity>();
        opportunityListNew.add(opportunity1);
        
        info.IsError=false;
        
        
        info.WorkflowType= 3;
        info.CurrentAccount=account;
        info.NewContactInfos=contactInfoList3; 
        info.ContactInfos=contactInfoList4; 
        WorkflowHelper.ValidateContact(info);
        test.stoptest();
        /*      
        info.Opportunities=opportunityListNew;
        WorkflowHelper.ValidateOpportunity(info);        
        WorkflowHelper.CreateLeadAccountOpp(info);
        
        info.NonClosedOpportunityList = info.Opportunities;
        WorkflowHelper.closeAppointmentsOfClosedLead(info);
        */
    }
    
    static testmethod void test2()
    {
        List<Opportunity> opportunityList=new List<Opportunity>();
        List<Contact> contactList = new List<Contact>();
        List<Appointment__c> appointmentList=new List<Appointment__c>();
        //NewCustomerWorkflow controller= new NewCustomerWorkflow();
        
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c where id=:callObj.id limit 1];
        Campaign campaign=[select Id from campaign limit 1];
        
        Employee__c employee = new Employee__c();
        employee.Name='Test emp - 87356';
        employee.First_Name__c='Test';
        employee.Last_Name__c='emp';
        employee.Employee_Number__c='Emp70609';
        
        insert employee;
        
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
        
        //To cover createLeadAccountOpp menthod: 
        Contact contact5=new Contact();
            contact5.Primary_Contact__c=true;
            contact5.Phone='9022332343';                    
            contact5.MailingStreet='test Street';
            contact5.MailingState='Test State';
            contact5.MailingPostalCode='4411189';
            contact5.MailingCountry='Test country';
            contact5.MailingCity='Test City';
            contact5.Salutation='Mr';
            contact5.LastName='Last Name';
            contact5.FirstName='First name';
            contact5.Contact_Type__c='Owner';
            contact5.Email='test@gmail.com';
            contact5.AccountId=account.Id;
            contact5.Salutation='Mr';
        insert contact5;
        System.debug('###*** contact object---> '+contact5);
        
        Contact contact6=new Contact();
            contact6.Primary_Contact__c=true;
            contact6.Phone='9022332343';                    
            contact6.MailingStreet='test Street';
            contact6.MailingState='Test State1';
            contact6.MailingPostalCode='M25 O17';
            contact6.MailingCountry='Test country1';
            contact6.MailingCity='Test City';
            contact6.Salutation='Mr';
            contact6.LastName='Last Name1';
            contact6.FirstName='First name1';
            contact6.Contact_Type__c='Owner';
            contact6.Email='test@gmail.com';
            contact6.AccountId=account.Id;
            contact6.Salutation='Mr';
        insert contact6;
        System.debug('###*** contact1 object---> '+contact6);
        
        contactList.add(contact5);
        contactList.add(contact6);
        
        ContactInfo conInfo5 = new ContactInfo();
        conInfo5.contact= contact5;
        conInfo5.AddSlct = true;
        conInfo5.ConSlct = true;
        conInfo5.AddStrt='Street';
        conInfo5.AddCty='city';
        conInfo5.AddStat='state';
        conInfo5.AddCntr='country';
        conInfo5.AddZip='442222';
        conInfo5.ConAdd='conAddress';
        
        ContactInfo conInfo6 = new ContactInfo();
        conInfo6.contact= contact6;
        conInfo6.AddSlct = true;
        conInfo6.ConSlct = false;
        conInfo6.AddStrt='Street';
        conInfo6.AddCty='city';
        conInfo6.AddStat='state';
        conInfo6.AddCntr='country';
        conInfo6.AddZip='442222';
        conInfo6.ConAdd='conAddress';

        List<ContactInfo> contactInfoList3= new List<ContactInfo>();  
        List<ContactInfo> contactInfoList4= new List<ContactInfo>();      
        contactInfoList3.add(conInfo5);
        contactInfoList4.add(conInfo6);   
        
        Opportunity opportunity1 = new Opportunity();
        
        opportunity1.name='Test Opp';
        opportunity1.StageName='Active';
        opportunity1.CloseDate=System.today();
        opportunity1.CampaignId=campaign.Id;
        opportunity1.AccountId=account.Id;
        opportunity1.LeadSource='Marcomms';
        opportunity1.Product_Interest__c='Combi Replacement';
        opportunity1.Referral_Employee__c=employee.Id;
        opportunity1.Latest_customer_category__c = 5;
        opportunity1.Unsafe_Appliance_Reason__c = 'Immediately dangerous';
        opportunity1.Customer_agreed_to_appointment__c = 'Yes';
        
        insert opportunity1;
        
        CombiSwapQuestion__c combiQuestion = new CombiSwapQuestion__c(Opportunity__c = opportunity1.id );
        insert combiQuestion;
        
        Lead prospect = new Lead(Status = 'Open',LastName = 'testName',Company = 'testComapny');
        insert prospect;
        
        ProductHolding__c prodHolding = new ProductHolding__c(Account__c = account.Id , Status__c = 'Current');
        insert prodHolding;
        
        ProductHoldingAccount__c proHoldAccount = new ProductHoldingAccount__c(Name = 'testProdHoldAct' , ProductHolding__c = prodHolding.Id);
        insert proHoldAccount;
        
        RecordType appointRecordType=[Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType='Appointment__c' and  r.Name='Available'];
        Appointment__c appointment = new Appointment__c();
        //appointment.Assigned_To__c = employee.Id;
        appointment.RecordTypeId = appointRecordType.Id;
        appointment.Visit_Type__c = 'First Visit';
        appointment.Type__c = 'Green Deal';
        appointment.Status__c = 'New';
        
        appointment.Mode__c = 'SA';
        
        appointment.Opportunity__c=opportunity1.Id;
        appointment.Who__c=contact6.Id;
        
        Date todaysDate= System.today().addDays(1);
        String year =(''+todaysDate.year()).trim();
        String month = (todaysDate.month()+'').trim();
        String day = (todaysDate.day()+'').trim();
        
        Date tommorrowsDate= System.today().addDays(2);
        String endYear =(''+tommorrowsDate.year()).trim();
        String endMonth = (tommorrowsDate.month()+'').trim();
        String endDay = (tommorrowsDate.day()+'').trim();
        
        String startHour='14';
        String endHour='16';
        String minute='00';
        String second='00';
        
        String startDate = year + '-' + month+ '-' + day + ' ' + startHour + ':' +minute + ':' + second;
        String endDate = endYear + '-' + endMonth+ '-' + endDay + ' ' + endHour + ':' +minute + ':' + second;
        
        appointment.Start__c=datetime.valueOf(startDate);
        appointment.End__c=datetime.valueOf(endDate);
        
        insert appointment;
        System.debug('###*** appointment object---> '+appointment);
        
        List<Appointment__c> appointList = new List<Appointment__c>();
        appointList.add(appointment);
        
        List<Opportunity> opportunityListNew= new List<Opportunity>();
        opportunityListNew.add(opportunity1);
        test.starttest();
        Workflow.WorkflowInfo info= new Workflow.WorkflowInfo();
        info.call=inboundCall;
        info.IsError=false;
        
        
        info.WorkflowType= 3;
        info.CurrentAccount=account;
        info.NewContactInfos=contactInfoList3; 
        info.ContactInfos=contactInfoList4; 
        
        
        info.include_priority_install = false;
        
        info.gasCouncil1 = '11';
        info.gasCouncil2 = '444';
        info.gasCouncil3 = '22';
        info.prospect = prospect;
        info.ProductHoldingInfo = prodHolding;
        
        info.Opportunities=opportunityListNew;
        WorkflowHelper.ValidateOpportunity(info);        
        WorkflowHelper.CreateLeadAccountOpp(info);
        
        info.NonClosedOpportunityList = info.Opportunities;
        WorkflowHelper.closeAppointmentsOfClosedLead(info);
        ProductHolding__c p = TestClassHelper.createProductHodling(account.Id);
        insert p;
        WorkflowHelper.markOldProductHoldingRecords(account.Id, 'abcd');
        test.stoptest();
    } 
}