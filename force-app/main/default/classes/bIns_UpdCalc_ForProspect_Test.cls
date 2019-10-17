@isTest
private class bIns_UpdCalc_ForProspect_Test{
 static testMethod void leadcreationTestMethod(){
      Lead L= new Lead();
      L.LastName='test1';
      L.Company='company1';
      L.Status='Open';
      L.Lead_Type__c = 'Prospect';
      L.Prospect__c = true;
      L.Call_Back_Date__c = 'Over Ride Call Back Date';
      L.Actual_Call_Back_Date__c = L.Overridden_Call_Back_Date__c;
      Lead L1= new Lead();      
      L1.LastName='test2';
      L1.Company='company2';
      L1.Status='Open';
      L1.Lead_Type__c = 'Prospect';
      L1.Prospect__c = true;
      L1.Call_Back_Date__c = 'After 1 Week';
      L1.Actual_Call_Back_Date__c = system.today().addDays(7);
      Lead L2= new Lead();
      L2.LastName='test3';
      L2.Company='company3';
      L2.Status='Open';
      L2.Lead_Type__c = 'Prospect';
      L2.Prospect__c = true;
      L2.Call_Back_Date__c = 'After 2 Week';
      L2.Actual_Call_Back_Date__c = system.today().addDays(14);
      Lead L3= new Lead();
      L3.LastName='test4';
      L3.Company='company4';
      L3.Status='Open';
      L3.Lead_Type__c = 'Prospect';
      L3.Prospect__c = true;
      L3.Call_Back_Date__c = 'After 1 Month';
      L3.Actual_Call_Back_Date__c = system.today().addMonths(1);
      Lead L4= new Lead();
      L4.LastName='test5';
      L4.Company='company5';
      L4.Status='Open';
      L4.Lead_Type__c = 'Prospect';
      L4.Prospect__c = true;
      L4.Call_Back_Date__c ='After 2 Months';
      L4.Actual_Call_Back_Date__c = system.today().addMonths(2);
      Lead L5= new Lead();
      L5.LastName='test6';
      L5.Company='company6';
      L5.Status='Open';
      L5.Lead_Type__c = 'Prospect';
      L5.Prospect__c = true;
      L5.Call_Back_Date__c = 'After 3 Months';
      L5.Actual_Call_Back_Date__c = system.today().addMonths(3);
      
      L5.LastName='test7';
      L5.Company='company7';
      L5.Status='Open';
      L5.Lead_Type__c = 'Prospect1';
      L5.Prospect__c = False;
List<Lead> Leads = new List<Lead>{L,L1,L2,L3,L4,L5};
      insert Leads;
      }
   }