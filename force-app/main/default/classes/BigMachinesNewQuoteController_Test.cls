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
private class BigMachinesNewQuoteController_Test {

    static testMethod void testGetCreateURL() {
        Account acct = new Account();
        acct.Name = 'BigMachines test Account for testGetCreateURL';
        acct.BillingPostalCode='XXX XXX';
        acct.BillingStreet='1 Forge'; 
		acct.BillingCity='London'; 
		acct.BillingCountry='UK';
		acct.BillingState='London';
        insert acct;
        Opportunity opty = new Opportunity();
        opty.Name = 'BigMachines test Opportunity for testGetCreateURL';
        opty.StageName = 'Prospecting';
        opty.CloseDate = Date.today();
        opty.LeadSource = 'Marcomms';
        Campaign newCampaign = new Campaign();
        newCampaign.Name = 'Test Temp Campaign';
        newCampaign.Group_Code__c='MEDA';
        newCampaign.Source__c='XP';
        newCampaign.Media_Cost_Code__c='atestvalue';
        insert newCampaign; 
        opty.CampaignId=newCampaign.ID; 
        opty.Product_Interest__c='Solar';
        insert opty;
        BigMachines_Quote__c quote = new BigMachines_Quote__c();
        quote.Name = 'BigMachines test Quote for testGetCreateURL';
        quote.Opportunity__c = opty.id;
        quote.BigMachines_Transaction_Id__c = 'transactionId';
        insert quote;
        BigMachinesNewQuoteController controller = null;

        // error case - no account specified
        ApexPages.currentPage().getParameters().put('oppId', opty.id);
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}
        
        // success case - create new quote
        opty.AccountId = acct.id;
        update opty;
        try {
            controller = new BigMachinesNewQuoteController();
        } catch (Exception e) {
            System.assert(false);
        }
        //controller.bmUsesSSL = true;
        //controller.buildURL();
        
        // success case - create clone of quote
        ApexPages.currentPage().getParameters().put('actId', acct.id);
        ApexPages.currentPage().getParameters().put('cloneId', quote.id);
        try {
            controller = new BigMachinesNewQuoteController();
        } catch (Exception e) {
            System.assert(false);
        }
        //controller.bmUsesSSL = false;
        //controller.buildURL();
        controller.getCreateURL();
        controller.getSubtitle();

        // error case - invalid clone object type
        ApexPages.currentPage().getParameters().put('cloneId', opty.id);
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}

        // error case - invalid clone id
        ApexPages.currentPage().getParameters().put('cloneId', 'garbage');
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}

        // error case - invalid account object type
        ApexPages.currentPage().getParameters().put('actId', opty.Id);
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}
        
        // error case - invalid account id
        ApexPages.currentPage().getParameters().put('actId', 'garbage');
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}

        // error case - invalid opportunity id
        ApexPages.currentPage().getParameters().put('oppId', 'garbage');
        try {
            controller = new BigMachinesNewQuoteController();
            System.assert(false);
        } catch (Exception e) {}
        
    }
}