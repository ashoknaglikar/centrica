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
private class BigMachinesQuoteProductExtension_Test {

    static testMethod void testQuoteProdExt() {
        BigMachines_Quote__c quote = new BigMachines_Quote__c();        
        quote.Name = 'BigMachines test quote for testQuoteProdExt';
        Opportunity opty = new Opportunity();        
        opty.Name = 'BigMachines test Opportunity for testGetQuoteList';
        opty.StageName = 'Prospecting';
        opty.CloseDate = Date.today(); 
        //Start - Added by CF so SFDC test pass object validation rules       
        opty.LeadSource = 'Marcomms'; 
        Campaign newCampaign = new Campaign();
        newCampaign.Name = 'Test Temp Campaign';
        newCampaign.Group_Code__c='MEDA';
        newCampaign.Source__c='XP';
        newCampaign.Media_Cost_Code__c='atestvalue';
        insert newCampaign; 
        opty.CampaignId=newCampaign.ID; 
        opty.Product_Interest__c='Solar';
        //End 
        insert opty;
        quote.Opportunity__c=opty.Id;
        //End       
        insert quote;
        Quote_Product__c qProd = new Quote_Product__c();
        qProd.Name = 'BigMachines test quote product for testQuoteProdExt';
        qProd.BigMachines_Quote__c = quote.id;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(qProd);
        BigMachinesQuoteProductExtension controller = new BigMachinesQuoteProductExtension(stdCtrl);
        String bmRedirectURL = controller.getRedirectURL();
        system.assertequals(bmRedirectURL,'/apex/BM_EditQuote?id='+quote.id);
    }
}