@istest
public class customerPortalAppointmentRESTTest{
 static testmethod void TestMethod1(){
 
 customerPortalAppointmentREST cPortal=new customerPortalAppointmentREST();
 
  Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
    DateTime StartTime=system.today();
    DateTime EndTime=system.today()+5;
    customerPortalAppointmentREST.post(string.valueOf(opp.id),StartTime,EndTime);
 // getAppointmentsJSON.getAppointmentsResponse resp=customerPortalAppointmentREST.post(string.valueof(opp.id), system.today(),);
  // customerPortalAuthenticate.post('4A4B4CADCF', 'testKey'); 
 
 }
 }