@istest
public class customerPortalModifyAppointmentRestTest {
    
    public static testmethod void  secnario1()
    {
    customerPortalModifyAppointmentRest eClass=new customerPortalModifyAppointmentRest();
  
      Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  User u = new User(Alias = 'standt1', Email='stan1dard11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stand1rd11@testorg.com');
            insert u;
    Employee__c emp = TestClassHelper.createEmployee();
    emp.Salesforce_User__c=u.id;
    insert emp;
    id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
    Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
    insert app;
    customerPortalModifyAppointmentRest.completeBooking(string.valueof(opp.id),app.id);
    
    }
 }