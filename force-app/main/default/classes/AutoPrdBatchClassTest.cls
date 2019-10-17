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
private class AutoPrdBatchClassTest {

    static testMethod void myUnitTest() {
        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Opportunity opp = TestClassHelper.createCHILead(acc);
        insert opp;
        
        BGS_Payment__c bPayment = TestClassHelper.createBGSPayment(opp.Id, 'Credit Card', null);
        bPayment.Payment_Type__c = 'Deposit';
        bPayment.Payment_Method__c = 'Debit Card';
        insert bPayment;
        
        system.debug('opp1---->'+bPayment.Opportunity__c);
        BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opp);
        bmQuote.BigMachines_Transaction_Id__c = '1234554321';
        bmQuote.POC_Payment_Method__c = 'Cash';
        bmQuote.Is_Electronically_Signed__c = true;
        bmQuote.Is_Primary__c = true;
        insert bmQuote; 
        
        Attachment att = TestClassHelper.createAttachemnt(bmQuote.Id);
        insert att;
        
        
        Test.startTest();
        AutoPrdBatchClass.createAutoPrdBatch();
        Test.stopTest();
    }
}