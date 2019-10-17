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
private class RHCFileGeneratorTest {

    static testMethod void RHCFileGeneratorTestMethod() {
        Account acc = TestClassHelper.createAccout();
        insert acc;
        Opportunity  opp = TestClassHelper.createCHILead(acc);
        insert opp;
        
        District__c dist = TestClassHelper.createDistrict();
        insert dist;
        
        BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opp);
        bmQuote.RHCStatus__c = 'TRUE';
        bmQuote.RHCMobile__c = '07979797979';
        bmQuote.RHCUsername__c= 'test@test.com';
        insert bmQuote;
        
        Job__c job = TestClassHelper.createJob('Planned', 'Planned', opp.Id, dist.Id);
        job.RHCUsername__c = 'test@test.com';
        job.RHCAlertMeStatus__c=null;
        job.SentToAlertMe__c=null;
        job.Quote__c = bmQuote.Id;
        insert job;
       
        RHCFileGenerator r = new RHCFileGenerator();
        Test.startTest();
        RHCFileGenerator.createRHCBatch();
       
        Test.stopTest();
    }
    
    static testmethod void SchedulerTest(){
        
        RHCScheduler d = new RHCScheduler();
        SchedulableContext SC;
        d.execute(SC);            
    }
}