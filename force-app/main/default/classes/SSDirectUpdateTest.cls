@isTest
private class SSDirectUpdateTest{

  static testmethod void testMethod1(){
    Account acc = TestClassHelper.createAccout();
    insert acc;
    
    contact con = TestClassHelper.createContact(acc);
    con.Contact_Type__c='Tenant';
    insert con;
       
    Opportunity opp = TestClassHelper.createCHILead(acc);
    insert opp;
      
    PageReference pageRef = Page.SSDirectBookAppointment;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('oppId',opp.id);
    pageRef.getParameters().put('new','true');
    Test.StartTest();
    ssDirectUpdate rp = new ssDirectUpdate();
    rp.confirm();
    rp.cancel();
    Test.StopTest();
  }
  
  static testmethod void testMethod2(){
    Account acc = TestClassHelper.createAccout();
    insert acc;
    
    contact con = TestClassHelper.createContact(acc);
    con.Contact_Type__c='Landlord';
    insert con;
       
    Opportunity opp = TestClassHelper.createCHILead(acc);
    insert opp;
      
    PageReference pageRef = Page.SSDirectBookAppointment;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('oppId',opp.id);
    pageRef.getParameters().put('new','true');
    Test.StartTest();
    ssDirectUpdate rp = new ssDirectUpdate();
    rp.confirm();
    rp.cancel();
    Test.StopTest();
  }
}