@IsTest
public class customerChoiceHubHTTPRequest_Test {
    public static  testmethod void callCreateCustomerOrUpdateMarketingPreferencesPositiveTest(){
        account acc= TestClassHelper.createAccout();
        insert acc;
        
        contact con=TestClassHelper.createContact(acc) ;
        con.MobilePhone='01234567890';
        con.HomePhone='01132779570';
        insert con;
        
        List<id> oppIds=new List<id>();
        opportunity opp= TestClassHelper.createCHILead(Acc);
        opp.Comms_Email_Field__c='abc@test.com';
        opp.Bill_Street__c='12test';
        opp.Customer_Marketing_Consent__c = 'Yes';
        opp.Marketing_Preferences__c='mobile';
        
        insert opp;
        oppIds.add(opp.Id);
        
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new customerChoiceHubHTTPRequest_Mock());
        customerChoiceHubHTTPRequest.callCreateCustomerOrUpdateMarketingPreferences(oppIds);
        test.stopTest();
    }


 public static  testmethod   void callCreateCustomerOrUpdateMarketingPreferencesNegativeTest(){
    account acc= TestClassHelper.createAccout();
    insert acc;
    
    contact con=TestClassHelper.createContact(acc) ;
    con.MobilePhone='01234567890';
    con.HomePhone='01132779570';
    insert con;
    
    List<id> oppIds=new List<id>();
    opportunity opp= TestClassHelper.createCHILead(Acc);
    opp.Comms_Email_Field__c='abc@test.com';
    opp.Bill_Street__c='12test';
    opp.Customer_Marketing_Consent__c = 'no';
    opp.Marketing_Preferences__c='';
    
    insert opp;
    oppIds.add(opp.Id);
    
    
    test.startTest();
      Test.setMock(HttpCalloutMock.class, new customerChoiceHubHTTPRequest_Mock());
    customerChoiceHubHTTPRequest.callCreateCustomerOrUpdateMarketingPreferences(oppIds);
    test.stopTest();
}
}