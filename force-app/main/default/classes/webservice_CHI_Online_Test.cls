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
 //
@isTest
private class webservice_CHI_Online_Test {
    
    static webservice_CHI_Online.cCreateCustomerReply       cus_reply   = new webservice_CHI_Online.cCreateCustomerReply();
    static webservice_CHI_Online.cCreateCustomerRequest     cus_request = new webservice_CHI_Online.cCreateCustomerRequest();
    
    static webservice_CHI_Online.cGetAppointmentsReply      app_reply   = new webservice_CHI_Online.cGetAppointmentsReply();    
    static webservice_CHI_Online.cGetAppointmentsRequest    app_request = new webservice_CHI_Online.cGetAppointmentsRequest();
    
    static webservice_CHI_Online.cMakeBookingReply      book_reply  = new webservice_CHI_Online.cMakeBookingReply();    
    static webservice_CHI_Online.cMakeBookingRequest    book_request = new webservice_CHI_Online.cMakeBookingRequest();
    
    static id book_app_id       = null;
    static id book_chi_lead_id  = null;
    
    static Web_Enquiry__c   enquiry         = new Web_Enquiry__c();
    static Opportunity      chi_lead        = new Opportunity();
    static Contact          new_contact     = new Contact();
    static Account          chi_account     = new Account();
    static Campaign         campaign_source = new Campaign();
    static Employee__c      employee        = new Employee__c();
        
        
    private static webservice_CHI_Online.cCreateCustomerRequest fSetCusRequest(webservice_CHI_Online.cCreateCustomerRequest request) {
        
        request.Address.NameNumber      = 'House';
        request.Address.Street          = 'Wandsworth Bridge Road';
        request.Address.TownCity        = 'London';
        request.Address.CountyProvince  = 'London';
        request.Address.PostCode        = 'SW6 2TT';
        request.BoilerAge               = '0-5';
        request.BoilerOp                = True;
        //request.CHIMarketing          = True;
        request.Contact_x.MobilePhone   = '07123456789';
        request.Contact_x.WorkPhone     = '';
        request.Contact_x.HomePhone     = '';
        request.Contact_x.AltPhone      = '02081234567';
        request.Contact_x.Email         = 'FirstName.LastName@centrica.com';
        //request.ExistingHomeCare      = True;
        request.FuelType                = 'Mains Gas';
        request.Name_x.Salutation       = 'Salutation';
        request.Name_x.FirstName        = 'FirstName';
        request.Name_x.LastName         = 'LastName';
        //request.ProductInterest           = True;
        request.ResStatus               = 'Owner';
        
        return request; 
    }
    
    private static webservice_CHI_Online.cGetAppointmentsRequest fSetAppRequest(webservice_CHI_Online.cGetAppointmentsRequest   request) {
        
        request.ChiLeadId = chi_lead.Id;
        
        datetime temp_datetime = null;
        
        temp_datetime = datetime.now();
        temp_datetime = temp_datetime.addDays(1);
        
        request.BracketStart    = datetime.newInstance(temp_datetime.date(), time.newInstance(8, 0, 0, 0) );
        request.BracketEnd      = datetime.newInstance(temp_datetime.addDays(7).date(), time.newInstance(22, 0, 0, 0) );
        
        return request; 
    }
    
    private static webservice_CHI_Online.cMakeBookingRequest fSetBookRequest(webservice_CHI_Online.cMakeBookingRequest  request) {
        
        request.AppointmentId       = book_app_id;
        request.ChiLeadId           = book_chi_lead_id; 
        
        return request; 
    }
    
    private static void fInsertContact() {
        
        if (null != new_contact.Id)
            delete new_contact;
            
        // now put original data in
        new_contact.Salutation          = cus_request.Name_x.Salutation;
        new_contact.FirstName           = cus_request.Name_x.FirstName;
        new_contact.LastName            = cus_request.Name_x.LastName;
        new_contact.MobilePhone         = cus_request.Contact_x.MobilePhone;
        new_contact.HomePhone           = cus_request.Contact_x.HomePhone;
        new_contact.OtherPhone          = cus_request.Contact_x.WorkPhone;
        new_contact.Phone               = cus_request.Contact_x.AltPhone;
        new_contact.Email               = cus_request.Contact_x.Email;
        new_contact.Contact_Type__c     = cus_request.ResStatus;
        new_contact.MailingCity         = cus_request.Address.TownCity;
        new_contact.MailingPostalCode   = cus_request.Address.PostCode;
        new_contact.MailingState        = cus_request.Address.CountyProvince;
        new_contact.MailingStreet       = cus_request.Address.NameNumber + ' ' + cus_request.Address.Street;
        new_contact.IsActive__c         = True;  
        
        insert new_contact; 
    }
    
    private static void fInsertAccount() {
        
        if (null != chi_account.Id)
            delete chi_account;
            
        chi_account.Primary_Contact__c          = new_contact.Id;
        chi_account.BillingPostalCode           = new_contact.MailingPostalCode;
        chi_account.BillingStreet               = new_contact.MailingStreet;
        chi_account.BillingCity                 = new_contact.MailingCity;
        chi_account.BillingState                = new_contact.MailingState;
        chi_account.Name                        = 'unused name';
        
        insert chi_account; 
    }
    
    private static void fInsertEnquiryOpportunity() {
        
        if (null != chi_lead.Id)
            delete chi_lead;
        
        if (null != enquiry.Id)
            delete enquiry;
            
        if (null != campaign_source.Id)
            delete campaign_source;
        
        enquiry.Name                    = new_contact.LastName + ' ' + chi_account.BillingPostalCode + ' ' + datetime.now();
        enquiry.Boiler_Age__c           = cus_request.BoilerAge;
        enquiry.Boiler_Operational__c   = cus_request.BoilerOp;
        //enquiry.CHI_Marketing__c        = cus_request.CHIMarketing;
        enquiry.County_Province__c      = new_contact.MailingState;
        enquiry.Fuel_Type__c            = cus_request.FuelType;
        enquiry.Email__c                = new_contact.Email;
        enquiry.First_Name__c           = new_contact.FirstName;
        enquiry.Home_Phone__c           = new_contact.HomePhone;
        enquiry.Work_Phone__c           = new_contact.OtherPhone;
        enquiry.Mobile_Phone__c         = new_contact.MobilePhone;
        enquiry.Alt_Phone__c            = new_contact.Phone;
        enquiry.Last_Name__c            = new_contact.LastName;
        enquiry.Postcode__c             = chi_account.BillingPostalCode;
        enquiry.Residential_Status__c   = cus_request.ResStatus;
        enquiry.Salutation__c           = new_contact.Salutation;
        enquiry.Street__c               = chi_account.BillingStreet;
        enquiry.Town_City__c            = chi_account.BillingCity;
        
        chi_lead.Address_Line1__c       = enquiry.Street__c;
        chi_lead.Address_Number__c      = cus_request.Address.NameNumber;
        chi_lead.Alternative_Number__c  = enquiry.Alt_Phone__c;
        chi_lead.Boiler_Age__c          = enquiry.Boiler_Age__c;
        
        if (enquiry.Boiler_Operational__c) 
            chi_lead.Boiler_Working__c = 'Yes';
        else 
            chi_lead.Boiler_Working__c = 'No';
        
        if (null != enquiry.Mobile_Phone__c) 
            chi_lead.Contact_Number__c = enquiry.Mobile_Phone__c;   
        else if (null != enquiry.Home_phone__c)
            chi_lead.Contact_Number__c = enquiry.Home_phone__c;
        else if (null != enquiry.Work_phone__c)
            chi_lead.Contact_Number__c = enquiry.Work_phone__c;
        else
            chi_lead.Contact_Number__c = enquiry.Alt_phone__c;
            
        chi_lead.LeadSource             = 'Internet';
        chi_lead.Product_Interest__c    = 'Unknown';
        //chi_lead.ES_Product_Interest__c   = cus_request.ProductInterest;
        //chi_lead.Homecare__c          = cus_request.ExistingHomeCare;
        
        chi_lead.Name                   = 'unused name';
        chi_lead.StageName              = 'Active';
        datetime temp_date              = datetime.now();
        temp_date.addMonths(3);
        chi_lead.CloseDate              = temp_date.date();
        chi_lead.AccountId              = chi_account.Id;
        chi_lead.Urgency__c             = 'Standard';
        chi_lead.Home_improvement__c    = 'No';
        chi_lead.Visit_Type__c          = 'Sales';
        chi_lead.SC_Type__c             = new_contact.Contact_Type__c;
        chi_lead.Product_Interest__c    = 'Central Heating Boiler';
        
        campaign_source.Name                = 'Campaign Name';
        campaign_source.Type                = 'Cross Sell';
        campaign_source.Media_Cost_Code__c  = 'MediaCode';
        campaign_source.Status              = 'Planned';
        campaign_source.Source__c           = 'XP';
        campaign_source.Group_Code__c       = 'ENGI';
        
        insert campaign_source;
        
       /* Campaign campaign_source2 = [SELECT Id 
                                     FROM Campaign 
                                     WHERE Name = 'Campaign Name'];*/
        
        chi_lead.CampaignId = campaign_source.Id;
        
        insert chi_lead;
        
        book_chi_lead_id    = chi_lead.Id;
        enquiry.CHI_Lead__c = chi_lead.Id;
        
        insert enquiry; 
    }
    
    private static void fInsertEmployee() {
        
        if (null != employee.Id)
            delete employee;
            
        employee.Name               = 'unused name';
        employee.First_Name__c      = 'John';
        employee.Last_Name__c       = 'Smith';
        employee.Employee_Number__c = '9999999';
        
        insert employee;
    }
    
    
    
    private static void fResetData() {
        
        cus_request = fSetCusRequest(cus_request);
        
        fInsertContact();
        fInsertAccount();
        fInsertEnquiryOpportunity();
        fInsertEmployee();
            
        app_request = fSetAppRequest(app_request);
    }
  
   static testMethod void fCreateCustomerSuccess1() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fCreateCustomerSuccess2() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        cus_request.BoilerOp = False;
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fCreateCustomerSuccess3() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        cus_request.Contact_x.MobilePhone = null;
        cus_request.Contact_x.HomePhone   = '02071234567';
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fCreateCustomerSuccess4() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        cus_request.Contact_x.MobilePhone = null;
        cus_request.Contact_x.WorkPhone   = '02071234567';
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fCreateCustomerSuccess5() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        cus_request.Contact_x.MobilePhone = null;
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    // test contact insert fail
    static testMethod void fCreateCustomerFail1() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        // null field to force insert failure
        cus_request.Name_x.LastName = '';
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fCreateCustomerFail8() {
        
          fResetData();
          chi_lead.accountId=chi_account.id;
          chi_lead.stageName = 'Active';
          chi_lead.CloseDate = date.today();
          update Chi_lead;
          WebCustomer WC = new WebCustomer();
          WC.fCreateCustomer(cus_request);
          
          test.startTest();
            chi_lead.stageName = 'Inactive';
            update chi_lead;
             wc.fCreateCustomer(cus_request);
          Test.stopTest();
            
    }
    
    static testMethod void fCreateCustomerFail9() {
        
          fResetData();
           delete chi_account;
           WebCustomer WC = new WebCustomer();
           WC.fCreateCustomer(cus_request);
           
           campaign_source.name= 'web';
           update campaign_source;
           Test.startTest();
             wc.fCreateCustomer(cus_request);
           Test.stopTest();
         
            
    }
        
    // opportunity insert fail
    static testMethod void fCreateCustomerFail3() {
        
        fResetData();
        
        // remove data for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete chi_account;
        delete campaign_source; 
        
        // null field to force insert failure
        cus_request.Address.NameNumber = '';
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    // account insert fail due to duplicate
    static testMethod void fCreateCustomerFail4() {
        
        fResetData();
        
        // remove all data apart from account for this test
        delete enquiry;
        delete chi_lead;
        delete new_contact;
        delete campaign_source; 
        
        
        
        Test.startTest();
        cus_reply = webservice_CHI_Online.fCreateCustomer(cus_request);
        Test.stopTest();    
            
    }
    
    
 
   static testMethod void fGetAvailabilitySuccess1() {
        
        //fResetData();
        
        Test.startTest();
        
        webservice_CHI_Online_Test.setUpData1();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        
        opp.Visit_Type__c = 'sales';
        update opp;
        
        webservice_CHI_Online.cGetAppointmentsRequest request = new webservice_CHI_Online.cGetAppointmentsRequest();
        request.ChiLeadId = opp.Id;
        request.BracketStart    = app1.Start__c;
        request.BracketEnd      = app1.End__c;
        
        
        app_reply = webservice_CHI_Online.fGetAppointments(request);
        Test.stopTest();
    }
    
    static testMethod void fGetAvailabilitySuccess4() {
        
        //fResetData();
        
        Test.startTest();
        
        webservice_CHI_Online_Test.setUpData();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        
        opp.Visit_Type__c = 'sales';
        update opp;
        
        webservice_CHI_Online.cGetAppointmentsRequest request = new webservice_CHI_Online.cGetAppointmentsRequest();
        request.ChiLeadId = opp.Id;
        request.BracketStart    = app1.Start__c;
        request.BracketEnd      = app1.End__c;
        
        
        app_reply = webservice_CHI_Online.fGetAppointments(request);
        Test.stopTest();
    }
    
    static testMethod void fGetAvailabilitySuccess2() {
        
        //fResetData();
        
        Test.startTest();
        webservice_CHI_Online_Test.setUpData();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        
        opp.Visit_Type__c = 'sales';
        update opp;
        
        webservice_CHI_Online.cGetAppointmentsRequest request = new webservice_CHI_Online.cGetAppointmentsRequest();
        request.ChiLeadId = opp.Id;
        request.BracketStart    = app1.Start__c;
        request.BracketEnd      = app1.End__c;
        
        
        app_reply = webservice_CHI_Online.fGetAppointments(request);
        Test.stopTest();
    }
    
    static testMethod void fGetAvailabilityFailure1() {
        
        fResetData();
        
        // delete opportunity to force opportunity selection failure
        delete chi_lead;
        
        Test.startTest();
        app_reply = webservice_CHI_Online.fGetAppointments(app_request);
        Test.stopTest();    
            
    }
    
     static testMethod void fGetAvailabilityFailure4() {
        
        fResetData();
        
        
        Test.startTest();
        app_reply = webservice_CHI_Online.fGetAppointments(app_request);
        Test.stopTest();    
            
    }
    
    static testMethod void fGetAvailabilityfail1() {
        
        fResetData();
        
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
        
         now = system.today();  
         startTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 13, 0, 0);
         endTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 21, 0, 0);                                            
         Appointment__c app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = 'Test', 
                                 Assigned_To__c = emp.id, OwnerId = user.id,
                                 Description__c = 'Test desc',
                                 Opportunity__c = book_chi_lead_id,
                                 Who__c = chi_account.Primary_Contact__c,
                                 Do_Not_Send_To_Premier__c = false,Mode__c='Installation',
                                 Resource_Type__c ='A',Sale_Flag__c = false,Show_Time_As__c= 'Out of Office',
                                 Time_Band__c = 'AM',Status_Reason__c = 'Purchase Elsewhere', Status__c ='New',
                                 Type__c = 'Sales');    
        
        insert app;
        
        Test.startTest();
        app_reply = webservice_CHI_Online.fGetAppointments(app_request);
        Test.stopTest();
    }
    
    
    /*static testMethod void fGetAvailabilitySuccess3() {
        
        //fResetData();
        
        webservice_CHI_Online_Test.setUpCHILead();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpData1();
        opp.Visit_Type__c = 'sales';
        opp.AccountID = acc.id;
        opp.Product_Interest__c = 'Central Heating Boiler';
        update opp;
        datetime EarliestDateTime = datetime.newinstance(date.today().year(), date.today().month(), date.today().day()-2, 09,00,00);
        datetime LatestDateTime = datetime.newinstance(date.today().year(), date.today().month(), date.today().day()+2, 11,00,00);
        
        Test.startTest();                   
            WebAvailability WA = new WebAvailability(opp.id,EarliestDateTime,LatestDateTime);
            WA.fGetAvailability();
        Test.stopTest();                   
        
        
            
    }
    */
 
    static testMethod void fMakeBookingSuccess1() {
        
        fResetData();
        
        book_request.ChiLeadId  = book_chi_lead_id;
        
        system.debug('-------------->Test'+book_chi_lead_id+' '+chi_account.Primary_Contact__c);
        
        // okay, there are error issues with trying to insert an appointment for testing, 
        // so will simply rely on finding ANY sales appointment for the thest method. This 
        // is not ideal but will have to suffice for the moment
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
        
        Test.startTest();
        webservice_CHI_Online_Test.setUpData();
        book_request.AppointmentId  = app3.Id;
        book_reply = webservice_CHI_Online.fMakeBooking(book_request);
        
        Test.stopTest();
        
    }
   
    static testMethod void fMakeBookingSuccess(){
      webservice_CHI_Online.cMakeBookingRequest bookReq= new webservice_CHI_Online.cMakeBookingRequest();
      webservice_CHI_Online.cMakeBookingReply objManageResp = new webservice_CHI_Online.cMakeBookingReply();    

       // null values
        //objManageResp = webservice_CHI_Online.fMakeBooking(bookReq);
        
       webservice_CHI_Online_Test.setUpData1();
       webservice_CHI_Online_Test.setUpCHILead();
       webservice_CHI_Online_Test.setUpAccount();
       
       opp.Visit_Type__c = 'sales';
       opp.AccountID = acc.id;
       opp.Product_Interest__c = 'Central Heating Boiler';
       update opp;
        //invalid Appointment Id
        insert new SalesAppointment__c(Name='AM',End_Time__c='13:00',SLA_End__c='13:30',SLA_Start__c='09:00',Start_Time__c='09:00',Order__c=1);
              
        bookReq= new webservice_CHI_Online.cMakeBookingRequest();
        bookReq.AppointmentId = 'a0cw0000AM11072025';
        bookReq.ChiLeadId = opp.id;
        objManageResp = webservice_CHI_Online.fMakeBooking(bookReq);
        
       
    }
    static testMethod void fMakeBookingFailure1() {
        
        fResetData();
        
        // no CHI Lead ID to force CHI Lead selection failure
        
        Test.startTest();
        book_reply = webservice_CHI_Online.fMakeBooking(book_request);
        Test.stopTest();
    }
    
    static testMethod void fMakeBookingFailure2() {
        
        fResetData();
        
        book_request.ChiLeadId  = book_chi_lead_id;
        
        // no Account ID to force accout selection failure
        chi_lead.AccountId = null;
        update chi_lead;
        
        Test.startTest();
        book_reply = webservice_CHI_Online.fMakeBooking(book_request);
        Test.stopTest();
    }
    
    static testMethod void fMakeBookingFailure3() {
        
        fResetData();
        
        book_request.ChiLeadId  = book_chi_lead_id;
        
        // null appointment ID to force appointment selection failure
        //book_request.AppointmentId  = null;
        
        book_request.IsAnytimeApp   = True;
        
        
        Employee__c hsa1 = TestClassHelper.createEmployee();
        hsa1.Employee_Number__c = 't1234t';
        hsa1.Salesforce_User__c = userinfo.getuserId();
        insert hsa1;
        
        id recordTypeId = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        
        app1 = TestClassHelper.createAppointment(new Opportunity(),hsa1.id, userinfo.getuserId(), recordTypeId, null);
        app1.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app1.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
      
         insert app1;
          webBooking webBooking = new WebBooking(); 
          webBooking.fMakeBooking(app1.id,book_chi_lead_id,true,true,true);
       
    }
    
    
    
    /*static testMethod void fMakeBookingFailure5() {
        
        fResetData();
        
        book_request.ChiLeadId  = book_chi_lead_id;
        
        // okay, there are error issues with trying to insert an appointment for testing, 
        // so will simply rely on finding ANY sales appointment for the thest method. This 
        // is not ideal but will have to suffice for the moment
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
                                 Opportunity__c = book_chi_lead_id,
                                 Who__c = chi_account.Primary_Contact__c,
                                 Do_Not_Send_To_Premier__c = false,Mode__c='Installation',
                                 Resource_Type__c ='A',Sale_Flag__c = false,Show_Time_As__c= 'Out of Office',
                                 Time_Band__c = 'AM',Status_Reason__c = 'Purchase Elsewhere', Status__c ='New',
                                 Type__c = 'Sales');    
        
        insert app;
       
        
        book_request.AppointmentId  = app.Id;
        
        // delete the app so it cannot be found and force failure
        app.Status__c = 'Appointed';
        update app;
        
        
        Test.startTest();
        book_reply = webservice_CHI_Online.fMakeBooking(book_request);
        Test.stopTest();
    }
    */
    
    private static webservice_CHI_Online.GetAppointmentsByPostcode setGetAppointmentsByPostcode(string boilerOP , string PostCode)
    {
        webservice_CHI_Online.GetAppointmentsByPostcode objApptByPostCode = new webservice_CHI_Online.GetAppointmentsByPostcode();
        objApptByPostCode.Address.PostCode = PostCode;
        
        objApptByPostCode.BoilerOp = boilerOP;
        
        return objApptByPostCode;
        
    }
    
    private static webservice_CHI_Online.ManageCustomerBooking setManageCustomerBooking(string boilerOP , string PostCode, id Appid)
    {
        webservice_CHI_Online.ManageCustomerBooking objReq = new webservice_CHI_Online.ManageCustomerBooking();
        
        objReq.CreateCustomerData.BoilerOp = boilerOP;
        objReq.CHILeadChannel = 'Online';
        objReq.CreateCustomerData.BoilerAge ='10';
        objReq.CreateCustomerData.ResStatus= 'Owner';
        objReq.CreateCustomerData.FuelType= 'LPG';
        //objReq.CreateCustomerData.ProductInterest= true;
        objReq.CreateCustomerData.Name_x.Salutation='Mr';
        objReq.CreateCustomerData.Name_x.FirstName ='Test';
        objReq.CreateCustomerData.Name_x.LastName = 'REC - 1';
        objReq.CreateCustomerData.Address.NameNumber = '2';
        objReq.CreateCustomerData.Address.Street = 'Test Street';
        objReq.CreateCustomerData.Address.CountyProvince = 'Test Province';
        objReq.CreateCustomerData.Address.PostCode = PostCode;
        objReq.CreateCustomerData.Address.TownCity = 'Stockport';
        objReq.CreateCustomerData.Contact_x.MobilePhone = '01245678945';
        objReq.CreateCustomerData.Contact_x.HomePhone = '02456487945';
        objReq.CreateCustomerData.Contact_x.WorkPhone = '07933333333';
        objReq.CreateCustomerData.Contact_x.AltPhone = '07933333331';
        objReq.CreateCustomerData.Contact_x.Email = 'test@test.com';
        objReq.CreateAppointmentData.Appointment.AppId= Appid;
        datetime start = datetime.newinstance(2014,08,20,08,00, 00);
        datetime endTime  = datetime.newinstance(2014,08,20,10,00, 00);
        objReq.CreateAppointmentData.Appointment.AppStart= start;
        objReq.CreateAppointmentData.Appointment.AppEnd = endTime;
                
        return objReq;
        
    }
    
    
    private static Appointment__c app1 = new Appointment__c();
    private static Appointment__c app2 = new Appointment__c();
    private static Appointment__c app3 = new Appointment__c();
    private static District__c dist = new District__c();
    private static Account acc = new Account();
    private static Opportunity opp = new Opportunity();
    private static Appointment__c salesApp = new Appointment__c(); 
    
    
    private static void setUpAccount()
    {
        acc = TestClassHelper.createAccout();
        acc.BillingPostalCode = 'AB1 2DE';
        acc.BillingStreet = '2 Test Street';
        acc.BillingCity = 'Stockport';
        insert acc;
        
        
        
    }
    
    private static void setUpCHILead()
    {
        opp = TestClassHelper.createCHILead(acc);
        opp.StageName = 'Deposit Taken';
        insert opp;
    }
    
    private static void setUpData()
    {
        dist = TestClassHelper.createDistrict();
        dist.Type__c = 'Sales';
        insert dist;
        
        Sub_patch__c subPatch = TestClassHelper.createSubpatch(dist.Id);
        insert subPatch;
        
        Sub_patch__c UnavailApptsubPatch = TestClassHelper.createSubpatch(dist.Id);
        UnavailApptsubPatch.Name = 'UnavailableAppt';
        UnavailApptsubPatch.Code__c = 'UN01';
        insert UnavailApptsubPatch;
        
        Sub_patch__c UnavailRolesubPatch = TestClassHelper.createSubpatch(dist.Id);
        UnavailRolesubPatch.Name = 'UnavailableRole';
        UnavailRolesubPatch.Code__c = 'UN02';
        insert UnavailRolesubPatch;
        
        PostCode_Sector__c postCode = TestClassHelper.createPostCode(subPatch.Id);
        insert postCode;
        
        PostCode_Sector__c UnavilablePostCode = TestClassHelper.createPostCode(UnavailRolesubPatch.Id);
        UnavilablePostCode.Name = 'AB1 2';
        insert UnavilablePostCode;
        
        PostCode_Sector__c UnavilableAPPPostCode = TestClassHelper.createPostCode(UnavailApptsubPatch.Id);
        UnavilableAPPPostCode.Name = 'AB1 3';
        insert UnavilableAPPPostCode;
        
        
        Employee__c hsa = TestClassHelper.createEmployee();
        hsa.Salesforce_User__c = userinfo.getuserId();
        insert hsa;
        
        Role__c hsaRole  = TestClassHelper.createHSARole(hsa.Id );
        insert hsaRole;
        
        Employee__c hsa1 = TestClassHelper.createEmployee();
        hsa1.Employee_Number__c = 't1234t';
        hsa1.Salesforce_User__c = userinfo.getuserId();
        insert hsa1;
        
        Role__c hsaRole1 = TestClassHelper.createHSARole(hsa1.Id );
        insert hsaRole1;
        
        Role_Sub_Patch__c roleSubPatch = TestClassHelper.createRoleSubPatch(hsaRole.Id,subPatch.Id);
        insert roleSubPatch;
        
        
        Role_Sub_Patch__c NoApptroleSubPatch = TestClassHelper.createRoleSubPatch(hsaRole1.Id,UnavailApptsubPatch.Id);
        insert NoApptroleSubPatch;
        
        Role_Sub_Patch__c ApptroleSubPatch = TestClassHelper.createRoleSubPatch(hsaRole.Id,UnavailRolesubPatch.Id);
        insert ApptroleSubPatch;
        
        
        id recordTypeId = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        
        app1 = TestClassHelper.createAppointment(new Opportunity(), hsa.Id, userinfo.getuserId(), recordTypeId, null);
        app1.Status__c = 'New';
        app1.Show_Time_As__c = 'Out of Office';
        app1.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app1.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        
        app2 = TestClassHelper.createAppointment(new Opportunity(), hsa.Id, userinfo.getuserId(), recordTypeId, null);
        app2.Status__c = 'New';
        app2.Show_Time_As__c = 'Out of Office';
        app2.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        app2.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 13,00,00);
        
        app3 = TestClassHelper.createAppointment(new Opportunity(), hsa.Id, userinfo.getuserId(), recordTypeId, null);
        app3.Status__c = 'New';
        app3.Show_Time_As__c = 'Out of Office';
        app3.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app3.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        
        
        insert new list<Appointment__c>{app1, app2, app3};
        
        campaign web = TestClassHelper.createCampaign();
        web.Name = 'Web';
        web.Group_Code__c = 'WEB';
       
        
        campaign eng = TestClassHelper.createCampaign();
        eng.Name = 'Engineer';
        eng.Group_Code__c = 'Engineer';
        insert new list<campaign>{web,eng} ;
        
        category_Indicator__c cat = new category_Indicator__c(Heating__c = 'Yes', Hot_Water__c = 'Yes' , Customer_Category_Logic__c = '1');
        insert cat;
        
        SalesAppointment__c s = new SalesAppointment__c(Name='AA', Start_Time__c= '08:00', End_time__c= '13:00', SLA_Start__c= '08:00', SLA_End__c ='13:00',  Online_Code__c= 'AA');
        insert s;
        
        TOA_Product_Interest__c t= new TOA_Product_Interest__c(Name ='Central Heating Boiler', Duration__c = '90', Active__c =true );
        insert t;
         
    }
    
    private static void setUpData1(){
        dist = TestClassHelper.createDistrict();
        dist.Type__c = 'Sales';
        insert dist;
        
        Sub_patch__c UnavailRolesubPatch = TestClassHelper.createSubpatch(dist.Id);
        UnavailRolesubPatch.Name = 'UnavailableRole';
        UnavailRolesubPatch.Code__c = 'UN02';
        unavailRolesubPatch.Appointment_Source__c='OFS';
        unavailRolesubPatch.OFS_Start_Date__c = date.newinstance(date.today().year(), date.today().month(), date.today().day());
        insert UnavailRolesubPatch;
        
        
        PostCode_Sector__c UnavilablePostCode = TestClassHelper.createPostCode(UnavailRolesubPatch.Id);
        UnavilablePostCode.Name = 'AB1 2';
        insert UnavilablePostCode;
        
        Employee__c hsa1 = TestClassHelper.createEmployee();
        hsa1.Employee_Number__c = 't1234t';
        hsa1.Salesforce_User__c = userinfo.getuserId();
        insert hsa1;
        
        UnavailRolesubPatch.OFS_Bucket_Name__c = hsa1.id;
        update UnavailRolesubPatch;
        
        Role__c hsaRole1 = TestClassHelper.createHSARole(hsa1.Id );
        insert hsaRole1;
               
        Role_Sub_Patch__c ApptroleSubPatch = TestClassHelper.createRoleSubPatch(hsaRole1.Id,UnavailRolesubPatch.Id);
        insert ApptroleSubPatch;
        
        
        id recordTypeId = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        
        app1 = TestClassHelper.createAppointment(new Opportunity(), hsa1.Id, userinfo.getuserId(), recordTypeId, null);
        app1.Status__c = 'New';
        app1.Show_Time_As__c = 'Out of Office';
        app1.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app1.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        
        app2 = TestClassHelper.createAppointment(new Opportunity(), hsa1.Id, userinfo.getuserId(), recordTypeId, null);
        app2.Status__c = 'New';
        app2.Show_Time_As__c = 'Out of Office';
        app2.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        app2.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 13,00,00);
        
        app3 = TestClassHelper.createAppointment(new Opportunity(), hsa1.Id, userinfo.getuserId(), recordTypeId, null);
        app3.Status__c = 'New';
        app3.Show_Time_As__c = 'Out of Office';
        app3.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app3.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        
        
        insert new list<Appointment__c>{app1, app2, app3};
        
        campaign web = TestClassHelper.createCampaign();
        web.Name = 'Web';
        web.Group_Code__c = 'WEB';
        insert web;
    }
    
    static testmethod void  testGetAppointmentsByPostcode()
    {
        webservice_CHI_Online.GetAppointmentsByPostcodeResponse objApptByPostCodeRes =  new webservice_CHI_Online.GetAppointmentsByPostcodeResponse();
        webservice_CHI_Online.GetAppointmentsByPostcode objReq = new webservice_CHI_Online.GetAppointmentsByPostcode();
        
        // test the null values;
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode(null, null));
        
        //Invalid Postcode Sector
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','XY1 1YX'));
        
        
        test.startTest();
        
        webservice_CHI_Online_Test.setUpData();
        
        // No Role Subpatch
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 2CD'));
        // No apppointment 
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 3CD'));
        system.debug('AB1 3'+objApptByPostCodeRes);
        
        
        // test with Boiler Working = Yes Value;
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 2CD');
        objReq.GetAppointmentDate.BracketStart = system.today().adddays(-1);
        objReq.GetAppointmentDate.BracketEnd = system.today().adddays(56);
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
        
        // test with  Boiler working = No value;
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('No','AB1 2CD');
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
    
    // test the district switch 
        dist.NA_Online__c = true;
        update dist;
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('No','AB1 1CD');
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
        
        Test.stoptest();
        
        
    }
    
   
    static testmethod void testGetAppointmentsByPostcode3()
    {
        webservice_CHI_Online.GetAppointmentsByPostcodeResponse objApptByPostCodeRes =  new webservice_CHI_Online.GetAppointmentsByPostcodeResponse();
        webservice_CHI_Online.GetAppointmentsByPostcode objReq = new webservice_CHI_Online.GetAppointmentsByPostcode();
        
       
        test.startTest();
        
        dist = TestClassHelper.createDistrict();
        dist.Type__c = 'Sales';
        insert dist;
        
        Sub_patch__c subPatch = TestClassHelper.createSubpatch(dist.Id);
        insert subPatch;
        
        Sub_patch__c UnavailRolesubPatch = TestClassHelper.createSubpatch(dist.Id);
        UnavailRolesubPatch.Name = 'UnavailableRole';
        UnavailRolesubPatch.Code__c = 'UN02';
        
        insert UnavailRolesubPatch;
        
        
        PostCode_Sector__c UnavilablePostCode = TestClassHelper.createPostCode(UnavailRolesubPatch.Id);
        UnavilablePostCode.Name = 'AB1 2';
        insert UnavilablePostCode;
        
        Employee__c hsa1 = TestClassHelper.createEmployee();
        hsa1.Employee_Number__c = 't1234t';
        hsa1.Salesforce_User__c = userinfo.getuserId();
        insert hsa1;
        
        UnavailRolesubPatch.OFS_Bucket_Name__c = hsa1.id;
        update UnavailRolesubPatch;
        
        Role__c hsaRole1 = TestClassHelper.createHSARole(hsa1.Id );
        insert hsaRole1;
               
        Role_Sub_Patch__c ApptroleSubPatch = TestClassHelper.createRoleSubPatch(hsaRole1.Id,subpatch.Id);
        insert ApptroleSubPatch;
        
        
        id recordTypeId = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        
        app1 = TestClassHelper.createAppointment(new Opportunity(), hsa1.Id, userinfo.getuserId(), recordTypeId, null);
        app1.Status__c = 'New';
        app1.Show_Time_As__c = 'Out of Office';
        app1.Start__c = datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 09,00,00);
        app1.End__c =  datetime.newinstance(system.now().year(), system.now().month(), system.now().day()+1, 11,00,00);
        
        insert app1;
        
        campaign web = TestClassHelper.createCampaign();
        web.Name = 'Web';
        web.Group_Code__c = 'WEB';
        insert web;
        
        insert new Toa_Product_Interest__c(Name='Central Heating Boiler',Active__c=true,duration__c='90');
        insert new SalesAppointment__c(Name='AM',End_Time__c='13:00',SLA_End__c='13:30',SLA_Start__c='09:00',Start_Time__c='09:00',Order__c=1);
        // No Role Subpatch
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 2CD'));
        // No apppointment 
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 3CD'));
        system.debug('AB1 3'+objApptByPostCodeRes);
        
        
        // test with Boiler Working = Yes Value;
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 1CD');
        objReq.GetAppointmentDate.BracketStart = system.today();
        objReq.GetAppointmentDate.BracketEnd = system.today().adddays(56);
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
        
        // test with  Boiler working = No value;
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('No','AB1 1CD');
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
    
    
        Test.stoptest();
        
        unavailRolesubPatch.Appointment_Source__c='OFS';
        unavailRolesubPatch.OFS_Start_Date__c = date.newinstance(date.today().year(), date.today().month(), date.today().day());
        
        update unavailRolesubpatch;
        Role_Sub_Patch__c ApptroleSubPatch1 = TestClassHelper.createRoleSubPatch(hsaRole1.Id,unavailRolesubpatch.Id);
        insert ApptroleSubPatch1;
        
        objReq = webservice_CHI_Online_Test.setGetAppointmentsByPostcode('Yes','AB1 2CD');
        objApptByPostCodeRes = webservice_CHI_Online.fGetAppointmentsByPostcode(objReq);
        
    }

    
    static testmethod void testManageCustomerBooking()
    {
        webservice_CHI_Online.ManageCustomerBookingResponse objManageResp = new webservice_CHI_Online.ManageCustomerBookingResponse();
        
        webservice_CHI_Online.ManageCustomerBooking ManageCustomerBooking = webservice_CHI_Online_Test.setManageCustomerBooking(null, null, null);
        
        objManageResp = webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        ManageCustomerBooking = webservice_CHI_Online_Test.setManageCustomerBooking('Yes', 'AB1 2CD', null);
 
        objManageResp = webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        webservice_CHI_Online_Test.setUpData();
        // Normal Scenario "// ******* Invalid Postcode ******
        
        test.starttest();
        
        ManageCustomerBooking.CreateCustomerData.BoilerOp ='NO';
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppId= app1.Id;
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppStart= app1.start__c;
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd = app1.End__c;
        objManageResp = webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        System.debug('Respnse -->'+objManageResp);
        
        objManageResp = webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        System.debug('Respnse -->'+objManageResp);
        
        app1 =[select id , Status__c , Opportunity__c, Start__c, End__c from Appointment__c where id =: app1.Id];
        
        
        app1.Start__c = app1.Start__c.adddays(-2);
        app1.End__c = app1.End__c.adddays(-2);
        update app1;
        //try another request for same Details.
        
        
        test.stoptest();
        objManageResp = webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        System.debug('Respnse -->'+objManageResp);
        
        
    }
    
    static testmethod void testManageCustomerBooking2()
    {
        webservice_CHI_Online_Test.setUpData();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        webservice_CHI_Online.ManageCustomerBookingResponse objManageResp = new webservice_CHI_Online.ManageCustomerBookingResponse();
        test.starttest();
        webservice_CHI_Online.ManageCustomerBooking ManageCustomerBooking = webservice_CHI_Online_Test.setManageCustomerBooking('No', 'AB1 2DE', 'a0CZ020151010ATOFS');
        
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppStart= app2.start__c;
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd = app2.End__c;
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        ManageCustomerBooking.CreateCustomerData.Address.NameNumber = null;
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        webManageCustomerBooking wcb = new webManageCustomerBooking();
        wcb.reSearchAppointment(app2.start__c , app2.End__c, 'AB1 2DE' , 'No', 'Straight Swap');

        test.stoptest();
    }
  
    
     static testmethod void testManageCustomerBooking3X()
    {
        webservice_CHI_Online_Test.setUpData();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        
        webservice_CHI_Online.ManageCustomerBookingResponse objManageResp = new webservice_CHI_Online.ManageCustomerBookingResponse();
        test.starttest();
        webservice_CHI_Online.ManageCustomerBooking ManageCustomerBooking = webservice_CHI_Online_Test.setManageCustomerBooking('No', 'AB1 2DE', 'a0cw0000AA11072025');
        
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppStart= app2.start__c;
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd = app2.End__c;
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        ManageCustomerBooking.CreateCustomerData.Address.NameNumber = null;
        ManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber = 'ABCD';
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
    }    
    
    static testmethod void testManageCustomerBooking3()
    {
        webservice_CHI_Online_Test.setUpData();
        webservice_CHI_Online_Test.setUpAccount();
        webservice_CHI_Online_Test.setUpCHILead();
        
        webservice_CHI_Online.ManageCustomerBookingResponse objManageResp = new webservice_CHI_Online.ManageCustomerBookingResponse();
        test.starttest();
        webservice_CHI_Online.ManageCustomerBooking ManageCustomerBooking = webservice_CHI_Online_Test.setManageCustomerBooking('No', 'AB1 2DE', 'a0cw0000AM11072025');
        
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppStart= app2.start__c;
        ManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd = app2.End__c;
        
        
        ManageCustomerBooking.CreateCustomerData.Address.NameNumber = '2';
        ManageCustomerBooking.CreateCustomerData.heating = 'Yes';
        ManageCustomerBooking.CreateCustomerData.HotWaterOp = 'Yes';
        ManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber = 'ABCD';
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        ManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber = 't1234t';
        ManageCustomerBooking.CreateCustomerData.extraInfo.homecare = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.existingBoiler = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.gasAtProperty = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.asbestosIdentified = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.boilerGCNumber = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.boilerBelow18kw = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.discountType = true;
        ManageCustomerBooking.CreateCustomerData.extraInfo.reasonForQuote = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.unsafeAppReason = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.ProductInterest = 'Central Heating Boiler';
        ManageCustomerBooking.CreateCustomerData.extraInfo.fuelType = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.fuseSpurReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.PEBInstalled = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.systemFilterFitted = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.powerflushReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.scaleReducerFitted = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.flueType = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.flueSubType = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.plumeKitReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.hnztlFlueExtReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.hnztlFlueBendReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.terminalGuardReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.balFlueBrickReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.heatingControlsReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.frostProtectionReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.condensateRun = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.termostateReq = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.signature = 'Yes';
        ManageCustomerBooking.CreateCustomerData.extraInfo.haNotes = 'Yes';
        webservice_CHI_Online.attachementObj attt = new webservice_CHI_Online.attachementObj();
        attt.title = '1';
        attt.description = 'test';
        attt.base64JPEG = '1234567';
        ManageCustomerBooking.CreateCustomerData.extraInfo.attachmentList = new list<webservice_CHI_Online.attachementObj>{attt};
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking);
        
        webManageCustomerBooking wcb = new webManageCustomerBooking();
        wcb.reSearchAppointment(app2.start__c , app2.End__c, 'AB1 2DE' , 'No', 'Central Heating Boiler');
        
        insert new SalesAppointment__c(Name='AM',End_Time__c='13:00',SLA_End__c='13:30',SLA_Start__c='09:00',Start_Time__c='09:00',Order__c=1);

        webservice_CHI_Online.ManageCustomerBooking ManageCustomerBooking1 = webservice_CHI_Online_Test.setManageCustomerBooking('No', 'AB1 2DE', 'a0cw0000AM11072025');
        ManageCustomerBooking1.CreateAppointmentData.Appointment.AppStart= app2.start__c;
        ManageCustomerBooking1.CreateAppointmentData.Appointment.AppEnd = app2.End__c;
        objManageResp =  webservice_CHI_Online.fManageCustomerBooking(ManageCustomerBooking1);
        
        test.stoptest();
        
        
    }
    
    static testmethod void testManageReservation()
    {
        test.starttest();
        
        webservice_CHI_Online.ManageReservation objManageReq = new webservice_CHI_Online.ManageReservation();
        webservice_CHI_Online.ManageReservationResponse objManageResp = new webservice_CHI_Online.ManageReservationResponse();
        
        // null values
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        
        webservice_CHI_Online_Test.setUpData();
        
        //invalid Appointment Id
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = dist.Id;
        objManageReq.ReserveAppointment.ReservationId = 'TestReserve';
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        
        // Reservation Id is blank
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = app1.Id;
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        
         // Reservation Id not blank
        system.debug('Appointment Id -->'+app1.Id);
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = app1.Id;
        objManageReq.ReserveAppointment.ReservationId = 'TestReserve';
        objManageReq.PostCode = 'SK1 2LG';
        objManageReq.BoilerOp = 'No';
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        system.debug('1st Scenrio--->'+objManageResp);
        
        //Try reserving Same appointment
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = app1.Id;
        objManageReq.ReserveAppointment.ReservationId = 'TestReserve';
        objManageReq.PostCode = 'SK1 2LG';
        objManageReq.BoilerOp = 'No';
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        system.debug('1st Scenrio--->'+objManageResp);
        
        // try unreserve Appointment
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = app1.Id;
        objManageReq.ReserveAppointment.ReservationId = 'TestReserve';
        objManageReq.UnReserveAppointment.Appointment.AppId = app1.Id;
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        
        
        objManageReq = new webservice_CHI_Online.ManageReservation();
        objManageReq.ReserveAppointment.Appointment.AppId = app2.Id;
        objManageReq.ReserveAppointment.ReservationId = 'TestReserve';
        objManageReq.UnReserveAppointment.Appointment.AppId = app1.Id;
        objManageResp = webservice_CHI_Online.fManageReservation(objManageReq);
        system.debug('2nd Scenrio--->'+objManageResp);
        test.stoptest();
    }
    
    
    
}