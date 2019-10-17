@istest
public class customerPortalAuthenticateTest{
 static testmethod void TestMethod1(){
 
 customerPortalAuthenticate cPortal=new customerPortalAuthenticate();
 
  Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
  Opportunity opp  = TestClassHelper.createCHILead(acc);
    insert opp;
  customerPortalAuthenticate.post(string.valueof(opp.id), 'testKey');
  insert new IV_Vectors__c(Key__c = 'Customer Portal',Name='Customer Portal');

  customerPortalAuthenticate.post('1111111111111111', 'testKey'); 
  //customerPortalAuthenticate.post('', 'testKey'); 
  // 0000000000000001 0042000000151234
 
 }
 }