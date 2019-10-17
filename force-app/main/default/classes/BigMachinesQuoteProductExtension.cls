public class BigMachinesQuoteProductExtension {

    // URLs for Visualforce pages
    private String bmRedirectURL = '';
    
    private Quote_Product__c bmQuoteProd;

    public BigMachinesQuoteProductExtension(ApexPages.StandardController stdCtrl) {
        bmQuoteProd = (Quote_Product__c)stdCtrl.getRecord();
        bmRedirectURL = '/apex/BM_EditQuote?id=' + bmQuoteProd.BigMachines_Quote__c;
    }

    public String getRedirectURL() {
        return bmRedirectURL;
    }

    /*Moved to new seprate class BigMachinesQuoteProductExtension_Test
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
        controller.getRedirectURL();
        system.assertequals(controller.bmRedirectURL,'/apex/BM_EditQuote?id='+quote.id);
    }*/

    
}