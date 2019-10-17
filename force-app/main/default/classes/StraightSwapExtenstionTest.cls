/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class StraightSwapExtenstionTest {

    static testMethod void myUnitTest() {
    	
    	Account acc = TestClassHelper.createAccout();
    	insert acc;
    	 
    	Opportunity opp = TestClassHelper.createCHILead(acc);
    	insert opp;
    	
    	Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(new CombiSwapQuestion__c());
    	
    	PageReference pageRef = new PageReference('/apex/StraightSwapQuestions?oppId='+opp.Id);
        Test.setCurrentPage(pageRef);
        StraightSwapExtenstion obj = new  StraightSwapExtenstion(stdCtr);
        
        obj.saveExit();
        
        obj.lpgAction();
        
        obj.ssObj.S_S_Q1__c = 'Yes';
        obj.saveExit();
        
        obj.lpgAction();
        
        obj.exitBtn();
        
        obj.ssObj.S_S_Q1__c = 'test';
        obj.ssObj.S_S_Q2__c = 'test';
        obj.ssObj.S_S_Q3__c = 'test';
        obj.ssObj.S_S_Q4__c = 'test';
        obj.ssObj.S_S_Q5__c = 'test';
        obj.ssObj.S_S_Q6__c = 'test';
        obj.ssObj.S_S_Q7__c = 'test';
        obj.ssObj.S_S_Q8__c = 'test';
        obj.ssObj.S_S_Q9__c = 'test';
        obj.ssObj.S_S_Q10__c = 'test';
        obj.ssObj.S_S_Q11__c = 'test';
        obj.ssObj.S_S_Q12__c = 'test';
        obj.ssObj.S_S_Q13__c = 'test';
        
        obj.saveExit();
        
        
        
    	
    	
        // TO DO: implement unit test
    }
}