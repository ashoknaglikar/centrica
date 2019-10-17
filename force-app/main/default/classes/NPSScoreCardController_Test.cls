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
private class NPSScoreCardController_Test {

    static testMethod void testMethodforValidScenario() {
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
       
        Employee__c[] employees = new Employee__c[]{emp};                                          
        insert employees;
        
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        insert opportunity;
        
        list<NPS__c> nps = [select id from NPS__c where Opportunity__c = :opportunity.Id];
        if(nps.size()>0)
        delete nps;
                
        // 2nd scenarion : Sucessfull insert of nps
        PageReference pageRef = new PageReference('apex/NPS_Score_Card?var_OpptyId='+ opportunity.Id);
        Test.setCurrentPage(pageRef);
        NPSScoreCardController nps_Obj = new NPSScoreCardController();
        
        nps_Obj.npsInfo.scoreQ1 = '1';
        nps_Obj.npsInfo.nps.Step1_Comments__c = 'test';
        nps_Obj.npsInfo.scoreQ2='1';
        nps_Obj.npsInfo.scoreQ3='yes';
        nps_Obj.npsInfo.scoreQ4='1';
        nps_Obj.npsInfo.scoreQ5='1';
        nps_Obj.npsInfo.scoreQ6='Yes';
        nps_Obj.npsInfo.scoreQ7='1';
        nps_Obj.npsInfo.nps.Q8_Score__c= 'Test';
        PageReference thankyou = nps_Obj.submitNPSForm();
        system.assertnotequals(new PageReference('/apex/NPSThankYouPage'),thankyou);
        
        nps = [select id from NPS__c where Opportunity__c = :opportunity.Id];
        //system.assertequals(1,nps.size());
        
    
        
    }
   
    
}