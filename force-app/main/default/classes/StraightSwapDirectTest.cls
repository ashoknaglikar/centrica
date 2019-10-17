@isTest
private class StraightSwapDirectTest {

    static testMethod void myUnitTest() {
      
      Account acc = TestClassHelper.createAccout();
      insert acc;
      
      contact con = TestClassHelper.createContact(acc);
      con.Contact_Type__c='Tenant';
      insert con;
       
      Opportunity opp = TestClassHelper.createCHILead(acc);
      insert opp;
      
      Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(new CombiSwapQuestion__c());
      
      PageReference pageRef = new PageReference('/apex/StraightSwapDirect?oppId='+opp.Id);
        Test.setCurrentPage(pageRef);
        StraightSwapDirect obj = new  StraightSwapDirect(stdCtr);
        obj.ssObj.SSD1__c = 'No';
        obj.check();
        obj.ssObj.SSD1__c = 'Yes';
        obj.check();
        
        obj.ssObj.SSD2__c = 'No';
        obj.check();
        obj.ssObj.SSD2__c = 'Yes';
        obj.check();
        
        obj.ssObj.SSD3__c = 'No';
        obj.check();
        obj.ssObj.SSD3__c = 'Yes';
        obj.check();
        
        obj.ssObj.SSD4__c = 'Floor';
        obj.check();
        obj.ssObj.SSD4__c = 'Wall';
        obj.check();
        
        obj.ssObj.SSD5__c = 'No';
        obj.check();
        obj.ssObj.SSD5__c = 'Yes';
        obj.check();
        
        obj.ssObj.SSD6__c = 'Yes';
        obj.check();
        obj.ssObj.SSD6__c = 'No';
        obj.check();
        
        obj.ssObj.SSD7__c = 'Yes';
        obj.check();
        obj.ssObj.SSD7__c = 'Wall';
        obj.check();
        
        obj.ssObj.SSD8__c = 'Yes';
        obj.check();
        obj.ssObj.SSD8__c = 'No';
        obj.check();
        
        obj.saveExit();
        obj.exitBtn();
        
        // TO DO: implement unit test
    }
    static testMethod void myUnitTest2() {
      
      Account acc = TestClassHelper.createAccout();
      insert acc;
      
      contact con = TestClassHelper.createContact(acc);
      con.Contact_Type__c='owner';
      insert con;
       
      Opportunity opp = TestClassHelper.createCHILead(acc);
      insert opp;
      
      Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(new CombiSwapQuestion__c());
      
      PageReference pageRef = new PageReference('/apex/StraightSwapDirect?oppId='+opp.Id);
        Test.setCurrentPage(pageRef);
        StraightSwapDirect obj = new  StraightSwapDirect(stdCtr);
        obj.ssObj.SSD1__c = '';
        obj.check();
        obj.ssObj.SSD1__c = 'Yes';
        obj.check();
        
        obj.saveExit();
        obj.exitBtn();
        
        // TO DO: implement unit test
    }
    static testMethod void myUnitTest3() {
      
      Account acc = TestClassHelper.createAccout();
      insert acc;
      
      contact con = TestClassHelper.createContact(acc);
      con.Contact_Type__c='Landlord';
      insert con;
       
      Opportunity opp = TestClassHelper.createCHILead(acc);
      insert opp;
      
      Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(new CombiSwapQuestion__c());
      
      PageReference pageRef = new PageReference('/apex/StraightSwapDirect?oppId='+opp.Id);
        Test.setCurrentPage(pageRef);
        StraightSwapDirect obj = new  StraightSwapDirect(stdCtr);
        obj.ssObj.SSD1__c = 'Yes';
        obj.check();
        
        obj.saveExit();
        obj.exitBtn();
        
        // TO DO: implement unit test
    }
}