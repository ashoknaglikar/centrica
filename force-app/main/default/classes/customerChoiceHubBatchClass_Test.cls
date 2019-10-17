@isTest
public class customerChoiceHubBatchClass_Test {
    
    public static TestMethod void setup() {
        account acc= TestClassHelper.createAccout();
        insert acc;
        
        
        
        List<opportunity> oppList= TestClassHelper.createMultipleCHILead(acc, 2) ;
        For(integer i=0; i< oppList.size(); i++)
        {
            oppList[i].Bill_Street__c=i+'1 street';
            oppList[i].Customer_Marketing_Consent__c = 'Yes';
            oppList[i].Marketing_Preferences__c='mobile';
            oppList[i].SAP_Cloud_Integration_Status__c='error';
        }
        insert oppList; 
        system.debug('SAP_Cloud_Integration_Status__c=='+oppList[0].SAP_Cloud_Integration_Status__c);
        
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new customerChoiceHubHTTPRequest_Mock());
        customerChoiceHubBatchClass cch=new customerChoiceHubBatchClass();
        Database.QueryLocator ql = cch.start(null);
        cch.execute(null,oppList);
        cch.Finish(null);
        customerChoiceHubBatchClass.createsapBatch();
    //    Database.executeBatch(cch);
        
        test.stopTest();
    }
    
}