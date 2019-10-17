@Istest
public class opportunityTriggerHandler_Test {
    
    public static TestMethod void handleMaketingPreferenceTest() {
        account acc= TestClassHelper.createAccout();
        insert acc;
        
        contact con = TestClassHelper.createContact(acc) ;
        con.Primary_Contact__c=true;
        con.MobilePhone='01234567890';
        con.Email__c='abc@test.com';
        con.Marketing_Consent__c='yes';
        con.Marketing_Preference__c='Email; Text Message';
        insert con;
        opportunity opp= TestClassHelper.createCHILead(Acc);
        opp.Comms_Email_Field__c='abc@test.com';
        opp.Bill_Street__c='12test';
        opp.Customer_Marketing_Consent__c = 'Yes';
        opp.Marketing_Preferences__c='mobile';
        opp.CHI_Lead_Id__c='47023643';
        opp.SAP_Cloud_Integration_Status__c='error';
        insert opp; 
        
        Lock.cchContactOppRecursiveStopper= false;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new customerChoiceHubHTTPRequest_Mock());
        opp.Marketing_Preferences__c='Text Message';
        update opp;
        Test.stopTest();
    }
    
}