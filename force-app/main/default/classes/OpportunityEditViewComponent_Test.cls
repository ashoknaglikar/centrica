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
private class OpportunityEditViewComponent_Test {

    static testMethod void myUnitTest() 
    {
        OpportunityEditViewComponentController obj = new OpportunityEditViewComponentController();
        
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
        
        Employee__c emp = new Employee__c();
        emp.Name = 'EMPNAME';
        emp.Employee_Number__c = '123456A';
        insert emp;
         
        Campaign campaign=[select Id from campaign limit 1];
        List<Opportunity> opportunityList=new List<Opportunity>();
        
        Opportunity opp= new Opportunity();
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        opportunity.Lead_Comments__c = 'Lead Comments';
        opportunity.Referral_Employee__c = emp.Id;
      
        insert opportunity;
        opportunityList.add(opportunity);
        
        obj.Opportunities = opportunityList;
        
        obj.setLeadCommentsEdit('TestLeadCommentsEdit');
        obj.getLeadCommentsEdit();
        obj.getLeadCommentsOpp();
        obj.getLeadCommentsOppArray();
        obj.Referral_Employee = emp.Id;
        
        ApexPages.currentPage().getParameters().put('Heat','yes');
        ApexPages.currentPage().getParameters().put('HW','yes');
        ApexPages.currentPage().getParameters().put('OH','yes');
        ApexPages.currentPage().getParameters().put('subreason','Heart condition');
        obj.indicator();
        
    }
}