@istest
public class CustomerPortalAppointmentHelperTest {
    
    public static testmethod void  secnario1()
    {
    CustomerPortalAppointmentHelper eClass=new CustomerPortalAppointmentHelper();
   /* eClass.eventDate=system.today();
    eClass.eventEndDate=system.today()+5;
    customerPortalEventClass.cutomerPortalEventChildClass childClass=new customerPortalEventClass.cutomerPortalEventChildClass();
    
    */
      Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
   Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  User u = new User(Alias = 'standt1', Email='standard11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standrd11@testorg.com');
            insert u;
  Employee__c emp = TestClassHelper.createEmployee();
  emp.Salesforce_User__c=u.id;
  insert emp;
  id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
  DateTime startTime=system.today();
  DateTime EndTime=system.today()+5;
  Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
  insert app;
   CustomerPortalAppointmentHelper.cancelAppointment(null,'Reason1','Reason2');
    CustomerPortalAppointmentHelper.getAppointmentsByPostcodeFunc(string.valueof(opp.id),startTime,EndTime);
    
    getAppointmentsJSON.ManageAppointment reservedAppt=new getAppointmentsJSON.ManageAppointment();
    CustomerPortalAppointmentHelper.ManageReservation('test1',reservedAppt);
   
    
    }
    
      public static testmethod void  secnario2()
    {
    CustomerPortalAppointmentHelper eClass=new CustomerPortalAppointmentHelper();
   /* eClass.eventDate=system.today();
    eClass.eventEndDate=system.today()+5;
    customerPortalEventClass.cutomerPortalEventChildClass childClass=new customerPortalEventClass.cutomerPortalEventChildClass();
    
    */
      Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  User u = new User(Alias = 'standt1', Email='standard11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standrd11@testorg.com');
            insert u;
  Employee__c emp = TestClassHelper.createEmployee();
  emp.Salesforce_User__c=u.id;
  insert emp;
  id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
  DateTime startTime=system.today();
  DateTime EndTime=system.today()+5;
  Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
  insert app;
    CustomerPortalAppointmentHelper.getAppointmentsByPostcodeFunc(string.valueof(opp.id),startTime,EndTime);
    
    getAppointmentsJSON.ManageAppointment reservedAppt=new getAppointmentsJSON.ManageAppointment();
    CustomerPortalAppointmentHelper.ManageReservation('test1',reservedAppt);
    List<opportunity> oppList=eClass.getOpportunity(string.valueof(opp.id));
    CustomerPortalAppointmentHelper.cancelAppointment(string.valueof(opp.id),'Reason1','I’m moving house');
  
    
    }
      public static testmethod void  secnario3()
    {
    CustomerPortalAppointmentHelper eClass=new CustomerPortalAppointmentHelper();
   /* eClass.eventDate=system.today();
    eClass.eventEndDate=system.today()+5;
    customerPortalEventClass.cutomerPortalEventChildClass childClass=new customerPortalEventClass.cutomerPortalEventChildClass();
    
    */
      Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  User u = new User(Alias = 'standt1', Email='standard11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standrd11@testorg.com');
            insert u;
  Employee__c emp = TestClassHelper.createEmployee();
  emp.Salesforce_User__c=u.id;
  insert emp;
  id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
  DateTime startTime=system.today();
  DateTime EndTime=system.today()+5;
  Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
  app.Status__c = 'Appointed';
  app.Type__c = 'Sales';
  insert app;
   CustomerPortalAppointmentHelper.cancelAppointment(string.valueof(opp.id),'Reason1',null);
  getAppointmentsJSON.ManageAppointment reservedAppt;
  CustomerPortalAppointmentHelper.ManageReservation('',reservedAppt);
  CustomerPortalAppointmentHelper.getAppointmentsByPostcodeFunc('',startTime,EndTime);
    
   CustomerPortalAppointmentHelper.manageAppointmentBooking(string.valueof(opp.id),string.valueof(app.id));
  
  
    }
     public static testmethod void  secnario4()
    {
    CustomerPortalAppointmentHelper eClass=new CustomerPortalAppointmentHelper();
   /* eClass.eventDate=system.today();
    eClass.eventEndDate=system.today()+5;
    customerPortalEventClass.cutomerPortalEventChildClass childClass=new customerPortalEventClass.cutomerPortalEventChildClass();
    
    */
      Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  User u = new User(Alias = 'standt1', Email='standard11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standrd11@testorg.com');
            insert u;
  Employee__c emp = TestClassHelper.createEmployee();
  emp.Salesforce_User__c=u.id;
  insert emp;
  id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
  DateTime startTime=system.today();
  DateTime EndTime=system.today()+5;
  Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
  insert app;
   
  //  CustomerPortalAppointmentHelper.manageAppointmentBooking(string.valueof(opp.id),'111111111111111111');
    CustomerPortalAppointmentHelper.cancelAppointment(string.valueof(opp.id),'Reason1','Reason2');
  
    
    }
    
    
    public static testmethod void  secnario5()
    
    {
    DateTime startTime=system.today();
    DateTime EndTime=system.today()+5;
    Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
    insert  newCampaign;    
    Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar');        
    insert opty;
    CustomerPortalAppointmentHelper.getAppointmentsByPostcodeFunc(string.valueof(opty.id),startTime,EndTime);
    }
 }