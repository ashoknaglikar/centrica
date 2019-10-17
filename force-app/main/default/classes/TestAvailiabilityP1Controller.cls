@isTest (SeeAllData=true)
private class TestAvailiabilityP1Controller {

    // ++ Priority Installations CR start
    static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static date todayDate;
    static void createData()
    {
        todayDate = date.today();
        //Prepare account data
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='XXX XXX',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='XXX XXX',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        
        //prepare supplier data
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        insert emp;
        
        //Prepare opportunity data
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                LeadSource='Engineer', Referral_Employee__c =emp.id,
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId());
        
        insert opp;
    }
    
    static testmethod void testCustomerCategory1()
    {
        createData();
        opp.Latest_customer_category__c = 1;
        update opp;
        date pageDate = date.today().addYears(100);
        String pageView = 'null';
        String pageSource = 'SF';
        String URLdate = String.valueOf(pageDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
                    
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
    }
    
    static testmethod void testCustomerCategor2()
    {
        createData();
        opp.Latest_customer_category__c = 2;
        update opp;
        date pageDate = date.today().addYears(100);
        String pageView = 'null';
        String pageSource = 'SF';
        String URLdate = String.valueOf(pageDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
                    
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
    }
    
    static testmethod void testCustomerCategory3()
    {
        createData();
        opp.Latest_customer_category__c = 3;
        update opp;
        date pageDate = date.today().addYears(100);
        String pageView = 'null';
        String pageSource = 'SF';
        String URLdate = String.valueOf(pageDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
                    
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
    }
    
    static testmethod void testCustomerCategory4()
    {
        createData();
        opp.Latest_customer_category__c = 4;
        update opp;
        date pageDate = date.today().addYears(100);
        String pageView = 'null';
        String pageSource = 'SF';
        String URLdate = String.valueOf(pageDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
                    
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
    }
    // -- Priority Installations CR end
    
    public static testMethod void testAvailiabilityP1Controller()
    {
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        //Test Class for AvailiabilityP1Controller:                                                        //
        //Setup the environment for the test class to operate on. This requires a Contact, and Account to  //
        //associate with a CHI Lead. Create available appointments to test against. This requires a User,  //
        //employees, postcode sector, subpatch, district, role sub patch, role district, and roles to be   //
        //created.                                                                                         //
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        cls_IsRun.generalTriggerSwitch = true;
        cls_IsRun.dontFireTriggers = true;
        String standardUrgency = 'Standard';
        String urgentUrgency = 'Urgent';
        String salesType = 'Green Deal';
        String apptType = 'Sales';
        String surveyType = 'Survey';
        date pageDate = date.today().addYears(100);
        integer calc = math.mod((date.today().daysBetween(pageDate)),7);
        date OppCloseDate = pageDate.addYears(1); 
        datetime AppointmentTime0700am;
        datetime AppointmentTime0900am;
        datetime AppointmentTime1100am;
        datetime AppointmentTime1300pm;
        datetime AppointmentTime1530pm;
        datetime AppointmentTime1730pm;
        
        if(pageDate.addDays(1).Day()==1){
        AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);     
        AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
        AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 11,0,0);
        AppointmentTime1300pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 13,0,0);        
        AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 15,30,0);
        AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 17,30,0);   
        }
        else{
        AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 7,0,0);      
        AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 9,0,0);
        AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 11,0,0);
        AppointmentTime1300pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 13,0,0);     
        AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 15,30,0);
        AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 17,30,0);    
        }           
        Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        
        ID userProfileID = [select Id from Profile where Name='Standard User'].Id;
        
        Employee__c poolEmployee = new Employee__c(Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller',Sales_Technical_Ability__c =1);
        Employee__c stmEmployee = new Employee__c(Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller',Sales_Technical_Ability__c =2);
        Employee__c hsaEmployee = new Employee__c(Name = 'Test Emp 3', Employee_Number__c = '0999007', Primary_Role__c = 'HSA', Last_Name__c='Emp3', First_Name__c='TestP1Controller',Sales_Technical_Ability__c =3);
        Employee__c [] TestEmployees = new Employee__c[]{poolEmployee, stmEmployee, hsaEmployee};
        insert TestEmployees; 
        /*
        Added By Cognizant Sales Skill Added
         */
        Employee_Sales_Skill__c Skill1 = new Employee_Sales_Skill__c(Employee__c = poolEmployee.Id, Sales_Skill_Name__c = 'Central Heating Boiler', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1);
        Employee_Sales_Skill__c Skill2 = new Employee_Sales_Skill__c(Employee__c = stmEmployee.Id, Sales_Skill_Name__c = 'solar PV', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
        Employee_Sales_Skill__c Skill3 = new Employee_Sales_Skill__c(Employee__c = hsaEmployee.Id, Sales_Skill_Name__c = 'Central Heating Boiler', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
        Employee_Sales_Skill__c [] testskills = new Employee_Sales_Skill__c[]{Skill1,Skill2,Skill3};
        insert testskills;
         
        User TestUser1 = new User(Username='test@testtesttest.co.uk', ProfileId=userProfileID, FirstName = 'testP1Controller', LastName = 'testP1Controller', Email='test@testtesttest.co.uk', Alias='testP1Co',
                                    EmailEncodingKey='UTF-8', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US', Migration_ID__c='test@testtesttest.co.uk');
        insert TestUser1;
        
        TestEmployees[0].Salesforce_User__c=TestUser1.Id;
        TestEmployees[1].Salesforce_User__c=TestUser1.Id;
        TestEmployees[2].Salesforce_User__c=TestUser1.Id;
        update TestEmployees;
        
        Role__c TestRole1 = new Role__c(Type__c='Pool', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=poolEmployee.Id);
        Role__c TestRole2 = new Role__c(Type__c='STM', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=stmEmployee.Id);
        Role__c TestRole3 = new Role__c(Type__c='HSA', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=hsaEmployee.Id);
        Role__c [] TestRoles = new Role__c[]{TestRole1, TestRole2, TestRole3};
        insert TestRoles;
        
        District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
        District__c TestSurveyDistrict = new District__c(Type__c='Survey', Name='P1Controller_SurveyDistrict', Code__c='yyyyyyyy');     
        District__c [] TestDistricts = new District__c[]{TestSalesDistrict,TestSurveyDistrict};
        insert TestDistricts;
        
        Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx');
        Sub_Patch__c TestSurveySubPatch = new Sub_Patch__c(Type__c='Survey',Name='P1Controller_SurveySubpatch', District__c=TestSurveyDistrict.Id, Code__c='yyyyyyyy');     
        Sub_Patch__c [] TestSubPatches = new Sub_Patch__c[]{TestSalesSubPatch, TestSurveySubPatch};
        insert TestSubPatches;      
        
        Postcode_Sector__c TestSalesSector = new Postcode_Sector__c(Type__c='Sales',Name='XXX X', Sub_Patch__c=TestSalesSubPatch.Id);
        Postcode_Sector__c TestSurveySector = new Postcode_Sector__c(Type__c='Survey',Name='XXX X', Sub_Patch__c=TestSurveySubPatch.Id);
        Postcode_Sector__c [] TestSectors = new Postcode_Sector__c[]{TestSalesSector, TestSurveySector};
        insert TestSectors;
        
        Role_Sub_Patch__c TestRoleSubPatch1 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1), Status__c='Preferred'); 
        Role_Sub_Patch__c TestRoleSubPatch2 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1)); 
        Role_Sub_Patch__c TestRoleSubPatch3 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole2.Id, End_Date__c=pageDate.addYears(1), Status__c='Preferred'); 
        Role_Sub_Patch__c TestRoleSubPatch4 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole2.Id, End_Date__c=pageDate.addYears(1));     
        Role_Sub_Patch__c TestRoleSubPatch5 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSurveySubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1), Status__c='Backup'); 
        Role_Sub_Patch__c TestRoleSubPatch6 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSurveySubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1)); 
        Role_Sub_Patch__c TestRoleSubPatch7 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSurveySubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole2.Id, End_Date__c=pageDate.addYears(1), Status__c='Backup'); 
        Role_Sub_Patch__c TestRoleSubPatch8 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSurveySubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole2.Id, End_Date__c=pageDate.addYears(1));        
        Role_Sub_Patch__c [] TestRoleSubPatches = new Role_Sub_Patch__c[]{TestRoleSubPatch1, TestRoleSubPatch2, TestRoleSubPatch3, TestRoleSubPatch4, TestRoleSubPatch5, TestRoleSubPatch6, TestRoleSubPatch7, TestRoleSubPatch8};
        insert TestRoleSubPatches;              
        
        Role_District__c TestRoleDistrict1 = new Role_District__c(Type__c='Ongoing', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
        Role_District__c TestRoleDistrict2 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
        Role_District__c TestRoleDistrict3 = new Role_District__c(Type__c='Ongoing', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
        Role_District__c TestRoleDistrict4 = new Role_District__c(Type__c='Availability', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
        Role_District__c TestRoleDistrict5 = new Role_District__c(Type__c='Ongoing', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1)); 
        Role_District__c TestRoleDistrict6 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1));
        Role_District__c [] TestRoleDistricts = new Role_District__c[]{TestRoleDistrict1, TestRoleDistrict2, TestRoleDistrict3, TestRoleDistrict4,TestRoleDistrict5,TestRoleDistrict6};
        insert TestRoleDistricts;
         
        Appointment__c TestAppointment1 = new Appointment__c(Type__c=apptType, Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime0900am, Assigned_To__c=poolEmployee.Id , Status__c = 'Appointed');
        Appointment__c TestAppointment2 = new Appointment__c(Type__c=apptType, Mode__c = 'SA', Start__c =AppointmentTime0900am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1100am, Assigned_To__c=stmEmployee.Id, Status__c = 'New');
        Appointment__c TestAppointment3 = new Appointment__c(Type__c=apptType, Mode__c = 'SU', Start__c =AppointmentTime1100am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300pm, Assigned_To__c=hsaEmployee.Id, Status__c = 'New');
        Appointment__c TestAppointment4 = new Appointment__c(Type__c=surveyType, Mode__c = 'SU', Start__c =AppointmentTime1300pm, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1530pm, Assigned_To__c=stmEmployee.Id);
        Appointment__c TestAppointment5 = new Appointment__c(Type__c=surveyType, Mode__c = 'SU', Start__c =AppointmentTime1530pm, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1730pm, Assigned_To__c=poolEmployee.Id);     
        Appointment__c [] TestAppointments = new Appointment__c[]{TestAppointment1, TestAppointment2, TestAppointment3, TestAppointment4, TestAppointment5};
        insert TestAppointments;
        System.debug('TestAppointment1 Id is '+TestAppointment1.Id+' TestAppointment2 Id is '+TestAppointment2.Id+' TestAppointment3 Id is '+TestAppointment3.Id);
        System.debug('pageDate is: '+pageDate);
        System.debug('AppointmentTime0700am is: '+AppointmentTime0700am);   
        System.debug('TestAppointments contains: '+TestAppointments);
        
        Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
        insert TestAccount1;
                        
        Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
        insert TestContact1;        
                                    
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
            
        Opportunity TestOpp1 = new Opportunity(LeadSource = 'MARCOMMS',AccountId = TestAccount1.Id, Name = 'P1Controller Opp 1', CloseDate = OppCloseDate, StageName='Active', Visit_Type__c = apptType, Urgency__c = standardUrgency, Product_Interest__c='Solar PV', CampaignId = camp.Id , Latest_customer_category__c = 1);
        insert TestOpp1;        
        System.debug('TestOpp1 contains: '+TestOpp1);  
        
        /*Remote_quote_product__c rq= new Remote_Quote_Product__c(name='Guided Sale',Active__c=true);
        Database.insert(rq);*/
    
        //////////////////////////////////////////////////////////////////////////////////////////////////
        //Test 1: Check for the availability created above by using a start date 100 years ahead.       //
        //Source is 'SF', View is 'null', primary contact is the one created above, urgency is Standard.//
        //Check survey and pool appointments are NOT returned, but that sales appointments are returned.//
        //////////////////////////////////////////////////////////////////////////////////////////////////  
            
        String pageView = 'null';
        String pageSource = 'SF';
        String URLdate = String.valueOf(pageDate);
        String cancelAppId = TestAppointment2.id;
        
        Opportunity opp1 = [select id,CHI_Lead_Type__c from Opportunity where id=: TestOpp1.Id];
        
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp1.Id+'&var_view='+pageView+'&var_contactId='+TestContact1.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=' +cancelAppId);
        Test.setCurrentPage(pageRef);
        
            
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        AvailabilityP1Controller.availDataSet controller2 = new AvailabilityP1Controller.availDataSet();
        //controller1.testclasscoverageString(); 
        controller1.onClickExit();
        controller1.onClickBack7();
        controller1.onClickCancel();
        controller1.onClickForward7();
        //controller1.onClickNoSuitable();
        controller1.getactiveDate0();
        controller1.getactiveDate1();
        controller1.getactiveDate2();
        controller1.getactiveDate3();
        controller1.getactiveDate4();
        controller1.getactiveDate5();
        controller1.getactiveDate6();
        controller1.getday0Title();
        controller1.getday1Title();
        controller1.getday2Title();
        controller1.getday3Title();
        controller1.getday4Title();
        controller1.getday5Title();
        controller1.getday6Title();
         controller1.onClickNoSuitable();
          controller1.getNoSuitableLabel();
        
        
        controller2.gettimeInfo();
        controller2.gettimeTitle();
        controller2.getday0Available();
        controller2.getday1Available();
        controller2.getday2Available();
        controller2.getday3Available();
        controller2.getday4Available();
        controller2.getday5Available();
        controller2.getday6Available();
        controller2.getAvailability0Color();
        controller2.getAvailability1Color();
        controller2.getAvailability2Color();
        controller2.getAvailability3Color();
        controller2.getAvailability4Color();
        controller2.getAvailability5Color();
        controller2.getAvailability6Color();
        controller2.getday0availableminutes();
        controller2.getday1availableminutes();
        controller2.getday2availableminutes();
        controller2.getday3availableminutes();
        controller2.getday4availableminutes();
        controller2.getday5availableminutes();
        controller2.getday6availableminutes();
        
        controller2.getcommercialMinutes();
        controller2.getavailableminutes();
        controller2.getdayAvailableMinutes(1);
        
        controller1.getAvailability();
        
        //Code By Ashok - G
        TestSalesSubPatch.OFS_Start_Date__c = Date.today();
        TestSalesSubPatch.OFS_Bucket_Name__c = stmEmployee.id;
        TestSalesSubPatch.Appointment_Source__c = 'OFS';
        update TestSalesSubPatch;
        
        controller1.getAvailability();
        
        controller1.getshowCancelButton();
        controller1.getHighestSalesOrTechnicalAbility();
        controller1.getshowButton();
        //controller1.getNoSuitableLabel();
        controller1.getparameterString();
        controller1.getOpportunity();
        controller1.getStartofWeek();
        controller1.getdisplayMessage();
        //controller1.fetchHighestSalesOrTechnicalAbility(TestAppointments);
        controller1.nextpage();
        controller1.onClickGo();
        controller1.onClickLLPage();
        
        controller1.gDeal='3';
        controller1.getAvailability();
        
        controller1.thisopp.Product_interest__c ='Guided Sale'; 
        controller1.getAvailability();
        
              
    }
    
   static testmethod void testExitMethod1()
    {
        createData();
        String pageSource = 'FF';
        String pageView = 'null';
        String URLdate = String.valueOf(todayDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.onClickExit();
    }
    
    static testmethod void testExitMethod2()
    {
        createData();
        String pageSource = 'PF';
        String pageView = 'null';
        String URLdate = String.valueOf(todayDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.onClickExit();
    }
    
    static testmethod void testExitMethod3()
    {
        createData();
        String pageSource = 'IC';
        String pageView = 'null';
        String URLdate = String.valueOf(todayDate.addDays(-20));
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.onClickExit();
    }
    
    static testmethod void testExitMethod4()
    {
        createData();
        String pageSource = null;
        String pageView = 'true';
        String URLdate = String.valueOf(todayDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.onClickExit();
    }
    
    static testmethod void testActivedateNull()
    {
        cls_IsRun.generalTriggerSwitch = true;
        cls_IsRun.dontFireTriggers = true;
        createData();
        Opportunity opp1 = [select id ,CHI_Lead_Type__c  from Opportunity where id=: opp.id];
        opp1.Urgency__c = 'Urgent';
        update opp1;
        String pageSource = null;
        String pageView = null;
        String URLdate = 'null';
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp1.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.getAvailability();
    }
    
    static testmethod void testExitMethod5()
    {
        createData();
        account.Landlord_Account__c = true;
        update account;
                
        opp.Landlords_permission__c = 'Yes';
        update opp;
        
        date pageDate = date.today().addYears(100);
        datetime AppointmentstartTime = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 15,30,0);     
        datetime AppointmentEndTime = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 17,30,0);     
        Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        

        Appointment__c TestAppointment1 = new Appointment__c(Type__c='sales', Mode__c = 'SA', Start__c =AppointmentstartTime, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentEndTime, Assigned_To__c=emp.Id , Status__c = 'Appointed', Opportunity__c=opp.id);
        
        String pageSource = 'FF';
        String pageView = 'null';
        String URLdate = String.valueOf(todayDate);
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null');
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        
    }
    
    
    
    /*static testmethod void testNoSuitable()
    {
        createData();
        String pageSource = null;
        String pageView = 'true';
        String URLdate = String.valueOf(todayDate);
        String NoSuitable = 'true';        
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null&var_NoSuitable='+NoSuitable);
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.onClickNoSuitable();
    }
    

    static testmethod void testNoSuitable1()
    {
        createData();
        String pageSource = 'SF';
        String pageView = null;
        String URLdate = String.valueOf(todayDate);
        String NoSuitable = 'true';        
        PageReference pageRef = new PageReference('/apex/availability?var_OpptyId='+opp.Id+'&var_view='+pageView+'&var_contactId='+contact.Id+'&var_Source='+pageSource+'&var_date='+URLdate+'&var_cancelledapp=null&var_NoSuitable='+NoSuitable);
        Test.setCurrentPage(pageRef);
        AvailabilityP1Controller controller1 = new AvailabilityP1Controller();
        controller1.getNoSuitableLabel();
        //controller1.onClickNoSuitable();
        controller1.getAvailability();        
    }
*/
}