@isTest(seeAllData=true)

public class ExcessTravelTimeExtension_Test{
     static Excess_Travel_Claim__c etc;
     static Employee__c emp;
     static Job__c j;
     static User user;
     static ApexPages.StandardController sc;
     static ExcessTravelTimeExtension ext;
     
     static void createData(){
         Account acc = TestClassHelper.createAccout();
         insert acc;
         Opportunity opp = TestClassHelper.createCHILead(acc);
         insert opp;
         District__c dist = [Select id From District__c where Name='Greenwich' Limit 1];
         j = TestClassHelper.createJob('Planned', 'Planned', opp.id, dist.id);
         insert j;
         user=[Select id, Name From User where Name='Ashok Kumar Nagaleekar'];
         emp=[Select id,Name From Employee__c where Salesforce_User__c = :user.id];
         etc = new Excess_Travel_Claim__c(Job__c=j.id,Employee__c = emp.id);
         insert etc; 
     }
     
     static testmethod void method1(){
         createData();
         sc = new ApexPages.StandardController(etc);
         ext = new ExcessTravelTimeExtension(sc);
         ext.onClickSave();
         ext.onClickCancel();
     }
     
}