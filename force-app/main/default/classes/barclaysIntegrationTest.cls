@isTest
public class barclaysIntegrationTest {


    static testmethod void testNegtiveScenario()
    {
        Account Acc = Testclasshelper.createAccout();
        insert Acc;
        
        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        insert opp;
        
        PageReference pageRef = new pagereference('/apex/BarclaysFinanceApplicationnew?oppId='+opp.id);
        Test.setCurrentPage(pageRef);
        
        barclaysIntegration bObj = new barclaysIntegration();
        bObj.createApplication();
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new barclaysHTTPReqFailure());
        bObj.createApplication();
        
        test.stopTest();
    }
    
    static testmethod void testPositiveScenario()
    {
        Account Acc = Testclasshelper.createAccout();
        insert Acc;
        
        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        insert opp;
        
        PageReference pageRef = new pagereference('/apex/BarclaysFinanceApplicationnew?oppId='+opp.id);
        Test.setCurrentPage(pageRef);
        
        barclaysIntegration bObj = new barclaysIntegration();
        // Set mock callout class 
       
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        
        test.starttest();
        
        Test.setMock(HttpCalloutMock.class, new barclaysHTTPReqHelper());
        bObj.createApplication();
        
        test.stopTest();
    }

}