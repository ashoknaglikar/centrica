@IsTest
public class customerChoiceHubREST_Test {
    
    Public static TestMethod void updateMarketingPreferenceTest(){
        account acc= TestClassHelper.createAccout();
        insert acc;
        
        contact con=testclasshelper.createContact(acc);
        con.MobilePhone='+44789900999';
        con.Email='abc@test.com';
        insert con;
        
        opportunity opp= TestClassHelper.createCHILead(Acc);
        opp.Comms_Email_Field__c='abc@test.com';
        opp.Bill_Street__c='12test';
        opp.Customer_Marketing_Consent__c = 'Yes';
        opp.Marketing_Preferences__c='mobile';
        insert opp;
         
        List<opportunity> oppList= [select CHI_Lead_Id__c from opportunity where id=:opp.Id];
        
        system.debug('oppList=='+oppList);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/updateMarketingPreference/*';
        String JsonMsg='{"Customers":[{"id": "DS_51","sourceSystemType": "EXT","sourceSystemId": "ANY","timestamp": "2018-03-16T18:11:58","contacts": {"contact": {"id":  "'+oppList[0].CHI_Lead_Id__c +'","idOrigin": "ZCHI","timestamp": "2018-03-16T18:12:58","marketingPermissions":{"contactMarketingPermissions":[{"id": "+44789900999","idOrigin":"MOBILE","optIn": "y","outboundCommunicationMedium":"PHONE","timestamp": "2018-04-16T18:14:59"},{"id": "+44789900999","idOrigin":"MOBILE","optIn": "N","outboundCommunicationMedium":"SMS","timestamp": "2018-04-16T18:14:59"}]}}}}]}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new customerChoiceHubHTTPRequest_Mock());
        customerChoiceHubREST.updateMarketingPreference();
        test.stopTest();
        
    }
    
}