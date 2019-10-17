@isTest
private class WorkflowPageController_Test{

    static testmethod void workflowTestMethod(){
        
        

        /*PageReference pageRef = Page.WorkflowPage;
        Test.setCurrentPage(pageRef);*/
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        callObj.Workflow_Type__c = 1;        
        insert callObj;
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c,Workflow_Type__c from Inbound_Call__c where id=:callObj.id limit 1];
        
        
        //Add parameters to page URL 
        System.debug('####**** inboundCall'+inboundCall);
        //ApexPages.currentPage().getParameters().put('c',inboundCall.Id);
        
        ///////////////
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
        account.customerUCRN__c = 'abcde';
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
            contact1.MailingPostalCode='M25 017';
            contact1.MailingCountry='Test country1';
            contact1.MailingCity='Test City';
            contact1.LastName='Last Name1';
            contact1.FirstName='First name1';
            contact1.Email='test@gmail.com';
            contact1.AccountId=account.Id;
        
            insert contact1;

            contactList.add(contact);
            contactList.add(contact1);
        
        Lead prospect = new Lead(Status = 'Open',LastName = 'testName',Company = 'testComapny');
        insert prospect;
        
        ProductHolding__c prodHolding = new ProductHolding__c(Account__c = account.Id , Status__c = 'Current');
        insert prodHolding;
        
        ProductHoldingAccount__c proHoldAccount = new ProductHoldingAccount__c(Name = 'testProdHoldAct' , ProductHolding__c = prodHolding.Id);
        insert proHoldAccount;
        
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
        System.debug('####**** opportunity==>'+opportunity);
        System.debug('### opportunity.CHI_Lead_Id1__c==>'+opportunity.CHI_Lead_Id1__c);
        
        PageReference pageRef = Page.WorkflowPage;
        pageRef.getParameters().put('c', inboundCall.id);
        pageRef.getParameters().put('ucrn','abcde');
        pageRef.getParameters().put('uc','1');
        pageRef.getParameters().put('e','1');
        pageRef.getParameters().put('p',prospect.Id);
        Test.setCurrentPage(pageRef);
        
        WorkflowPageController controller= new WorkflowPageController();
       
        
        controller.CurrentWorkflow= WorkflowFactory.GetWorkFlow(2);
        controller.CallMode=new CallMode(); 
        controller.CallMode.CUSTOMERCALLEXISTCUST=2;       
        controller.DisplayMode.VIEW=1;
        
        opp=[select Id,CHI_Lead_Id1__c,CHI_Lead_Id__c,name from opportunity where CHI_Lead_Id__c!=null and AccountId!=null limit 1];            
        
        //List<Appointment__c> appointmentList=[Select a.Name, a.Id From Appointment__c a limit 2];
        Workflow.WorkflowInfo info= new Workflow.WorkflowInfo();
        info.Call=inboundCall;
        System.debug('####**** final inboundCall ==>'+inboundCall);
        System.debug('####**** final info.call ==>'+info.Call);
        /////////////////////////////////
        //info.call.Workflow_Step__c=4;
        info.call.CHI_Lead__c=opportunity.Id;
        info.CurrentAccount=account;
        info.WorkflowType=3;
        info.DisplayAccount=true;
        info.Contacts=contactList;
        info.ContactInfos = contactInfoList;
        info.NewContactInfos = contactInfoList;
        info.Opportunities=opportunityList;
        info.payment= new BGS_Payment__C();
        info.ProductHoldingEnabled = true;         
        //controller.BtnNewSalesAppointment_Click();
        info.NonClosedOpportunityList = info.Opportunities;
              
        
        System.debug('####**** info.ContactInfos size---> '+info.ContactInfos.size());
        System.debug('####**** info.NewContactInfos size---> '+info.NewContactInfos.size());
        
        Employee__c employee = new Employee__c();
        employee.Name='Test emp - 87356';
        employee.First_Name__c='Test';
        employee.Last_Name__c='emp';
        employee.Employee_Number__c='Emp70608';
        
        insert employee;
        System.debug('####**** Employee object---> '+employee);
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
        System.debug('####**** appointment object---> '+appointment);
        
        List<Appointment__c> appointList = new List<Appointment__c>();
        appointList.add(appointment);
        
        info.SelectedOpportunities = new list<OppSelectClass>();
        for(Opportunity o:opportunityList)
        {
            OppSelectClass oVab = new OppSelectClass();
            oVab.opp = o;
            oVab.oppSelected = false;
            info.SelectedOpportunities.add(oVab);
        }
        info.Appointments = appointList;
        //WorkflowHelper.GetAppointments(info);
        //WorkflowHelper.closeAppointmentsOfClosedLead(info);
        
        System.debug('### info.call.Workflow_Step__c: '+info.call.Workflow_Step__c);
        
        controller.WorkflowInfo.gasCouncil1 = '12';
        controller.WorkflowInfo.gasCouncil2 = '555';
        controller.WorkflowInfo.gasCouncil3 = 'ab';
        
        controller.BtnContinue_Click();
        controller.BtnCreateLead_Click();
        controller.BtnCreateNewLead_Click();
        controller.BtnWrapUpCall_Click();
        controller.BtnWasteCall_Click();
        controller.BtnCreatePayment_Click();
        controller.getMessageFWAArray();
        controller.BtnCancelAppointment_Click();
        controller.BtnSalesAppointment_Click();
        controller.BtnRearrangeAppointment_Click();
        controller.BtnBookSurveyAppointment_Click();
        controller.BtnNewSalesAppointment_Click();
        controller.BtnGreenDeal_Click();
                
        info.IsError = false;         
        info.payment.Payment_Type__c='Deposit';
        info.payment.Payment_Method__c='Cash';
        info.payment.Payment_Date__c=System.Today();
        info.payment.EPDQ_Authorisation__c='444';
        info.payment.BGS_Payment_Reference_Num__c='454';
        info.payment.Amount__c=1000;
        info.ProductHoldingEnabled = true;
        controller.BtnCreatePayment_Click();
        
         
        info.IsError = true;
        info.SelectedOpportunities = new list<OppSelectClass>();
        for(Opportunity o:opportunityList)
        {
            OppSelectClass oVab = new OppSelectClass();
            oVab.opp = o;
            oVab.oppSelected = false;
            info.SelectedOpportunities.add(oVab);
        }
        system.debug('2nd Debug--->'+info);
        controller.BtnContinue_Click();
        //controller.BtnCreateNewLead_Click();
        controller.BtnCreatePayment_Click();        
        controller.setErrorMsg();
        controller.BtnWasteCall_Click();
        controller.BtnWrapUpCall_Click();
        //WorkflowPageController.TestData= 'test';
        
        try{
            controller.BtnRefreshPH_click();
        }catch(Exception e){        }       
        try{
            controller.BtnBookSurveyAppointment_Click();
        }catch(Exception e){ }
        
        try{    controller.BtnContinue_Click(); }catch(Exception e){ }
        try{        controller.BtnCreateLead_Click(); }catch(Exception e){ }
                //controller.BtnCreateNewLead_Click();
            //controller.BtnSalesAppointment_Click();
        try{        controller.BtnCancelAppointment_Click(); }catch(Exception e){ }
            //controller.BtnRearrangeAppointment_Click();
        try{        controller.BtnWrapUpCall_Click(); }catch(Exception e){ }
        try{        controller.BtnWasteCall_Click(); }catch(Exception e){ }
        try{        controller.BtnCreatePayment_Click(); }catch(Exception e){ }
            
        try{        controller.BtnSaveCustCategoryDetails_Click(); }catch(Exception e){ }
         //changes for IPD 3653 begin - dated 2/26/2013
        try{        ProductHoldingData productHoldingData = new ProductHoldingData();
productHoldingData.NewContactInfos= new List<contactinfo>();
contactinfo coninfotest = new contactinfo();
coninfotest.contact= new contact(lastname='test',email='x@test.com');
productHoldingData.NewContactInfos.add( coninfotest );
controller.processResponse(productHoldingData );
 CallMode objCallMode = new CallMode();             
controller.WorkflowInfo.WorkflowType  = objCallMode.CUSTOMERCALLEXISTCUST ;
controller.processResponse(productHoldingData );

controller.WorkflowInfo.ContactInfos= new List<contactinfo>();
controller.WorkflowInfo.ContactInfos.add(coninfotest );
productHoldingData.NewContactInfos= new List<contactinfo>();
contactinfo coninfotest1 = new contactinfo();
coninfotest1.contact= new contact(lastname='test', email='x@test.com', email__c='x@test.com', firstname='test', salutation='Mr',homephone='9834567894', mobilephone='9876543210', otherphone='1234456778');
productHoldingData.NewContactInfos.add( coninfotest1 );
controller.processResponse(productHoldingData );

controller.WorkflowInfo.ContactInfos= new List<contactinfo>();
contactinfo coninfotest2 = new contactinfo();
coninfotest2.contact= new contact(lastname='test',email__c='x@test.com');
controller.WorkflowInfo.ContactInfos.add(coninfotest2 );
controller.processResponse(productHoldingData );
 }catch(Exception e){ }
try{        
controller.updateContacts(); 
controller.updatecon=null;
controller.updatecon=new List<contact>();
controller.updatecon.add(new contact(firstname='test',lastname='test',email='x@test.com'));
controller.showUpdateContacts=true;
controller.updateContacts(); 
controller.updatecon=null;
controller.updatecon=new List<contact>();
controller.updatecon.add(new contact(firstname='test',lastname='',email='x@test.com'));
controller.showUpdateContacts=true;
controller.updateContacts(); 
}catch(Exception e){ }
//changes for IPD 3653 end - dated 2/26/2013
        /*try{      
            controller.showRefreshProducttHolding=true;
            controller.BtnRefreshProductHoldingPH();  }catch(Exception e){ }*/
            
controller.WorkflowInfo.ShowBtnContinue = true;
controller.showUpdateContacts = true;
controller.getSaveAndContinue();

controller.WorkflowInfo.ShowBtnContinue = true;
controller.showUpdateContacts = false;
controller.getContinue();
controller.closePopup();
    }
}