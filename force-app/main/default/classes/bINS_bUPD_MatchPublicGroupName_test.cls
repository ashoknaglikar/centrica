/**
Class:   bINS_bUPD_MatchPublicGroupName_test
Purpose: This class serves the code coverage og the trigger : bINS_bUPD_MatchPublicGroupName.
         The trigger is defined for the Agency change purpose.
Author:  COGNIZANT
Created date: 11-Aug-2010.
*/

@isTest
private class bINS_bUPD_MatchPublicGroupName_test {
    static testMethod void myUnitTest() {
       try{        
           Agency__c agency = new Agency__c();
           agency.name='ABCD';
           insert agency;
       }catch(Exception ex){
           System.debug('Exception occured: '+ex);
       }
    }
}