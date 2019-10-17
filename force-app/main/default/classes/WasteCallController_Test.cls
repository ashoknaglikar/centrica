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
private class WasteCallController_Test {

    static testMethod void myUnitTest() 
    {
        WasteCallController wcc = new WasteCallController();
        Lead l = new Lead();
        l.LastName= 'LastName';
        l.FirstName = 'FirstName';
        l.Company = 'Comp';
        insert l;
        
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
        insert account;
        
        Campaign campaign=[select Id from campaign limit 1];
        
        Opportunity opportunity = new Opportunity();
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms'; 
        opportunity.Product_Interest__c='Solar';
        
        insert opportunity;
        
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        callObj.Billing_Street__c='test'; 
        callObj.Billing_City__c='test'; 
        callObj.Billing_State__c='test'; 
        callObj.Billilng_Country__c='test'; 
        callObj.Billing_Zip__c='345'; 

        insert callObj;
        
        Inbound_Call__c inCall = new Inbound_Call__c();
        inCall.Related_To__c = 'CHI LEAD';
        inCall.Billing_Street__c = 'Street';
        inCall.Billing_City__c = 'City';
        inCall.Billing_State__c = 'State';
        inCall.Billilng_Country__c = 'Country';
        
        insert inCall;   
        system.debug('------incall----'+inCall);
        wcc.callId = inCall.Id;
        
        /*PageReference wp = Page.WorkflowPage;
        wp.getParameters().put('c',inCall.Id);
        Test.setCurrentPage(wp);*/   
        
        system.debug('------after pageref----');
        wcc = new WasteCallController();
        
        inCall.CHI_Lead__c = opportunity.Id;
        update inCall;
        
        wcc = new WasteCallController();
        wcc.callId = inCall.Id; 
        wcc.getAccount();
        wcc.setLead(l);
        wcc.getLead();
        wcc.createLead();
        wcc.closeCall();  
        
        l.Categories__c = 'Referred to other Gas Office';
        l.Sub_Categories_of_Gas_Office_Referral__c = null;
        update l;
        
        wcc.closeCall();
        
        delete account;
        
        wcc = new WasteCallController();
        wcc.getAccount();
        wcc.createLead();
        wcc.closeCall();
        wcc.getLead();
        wcc.getLeadTypeOptions();
        wcc.getLeadType();
        wcc.setLeadType('test');
      
       wcc.methodForTest();
          
    }
}