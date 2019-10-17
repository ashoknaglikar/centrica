@istest
public class engineerCallAppREST_TEST {
static testmethod void TestMethod1(){
 
 
 
  Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
    Opportunity opp  = TestClassHelper.createCHILead(acc);
    opp.Bill_Post_Code__c='RM11 2NS';
    opp.Product_Interest__c='Straight Swap';
    insert opp;

    DateTime StartTime=system.today();
    DateTime EndTime=system.today()+5;
    engineerCallAppREST.post(opp.Bill_Post_Code__c,StartTime,EndTime,opp.Product_Interest__c, 'Yes', 'Yes', null,  'No', null, null);

 
 }

 static testmethod void TestMethod2(){
 
 
 
  Account acc = TestClassHelper.createAccout();
    insert acc;
    
  Contact con = TestClassHelper.createContact(acc);
    insert con;
    
    Opportunity opp  = TestClassHelper.createCHILead(acc);
    opp.Bill_Post_Code__c='RM11 2NS';
    opp.Product_Interest__c='Central Heating Boiler';
    insert opp;

    DateTime StartTime=system.today();
    DateTime EndTime=system.today()+5;
    engineerCallAppREST.post(opp.Bill_Post_Code__c,StartTime,EndTime,opp.Product_Interest__c, 'Yes', 'Yes', null,  'No', null, null);

 
 }


 }