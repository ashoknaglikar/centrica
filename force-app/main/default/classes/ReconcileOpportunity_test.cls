/**

 Type Name:ReconcileOpportunity_test
Author: Cognizant
Created Date: 24/06/2010
Reason: This is Test class for ReconcileOpportunity
Change History

 */
@isTest
private class ReconcileOpportunity_test {

    static testMethod void ReconcileOpportunityTest() {
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new ReconcileOpportunity());
        ReconcileOpportunity RO = new ReconcileOpportunity();
        Test.startTest();
        //Database.execute(sc);
        RO.execute(sc);
        Test.stopTest();
  
        }
}