public class BigMachinesChooseQuoteToCloneExtension {

    private ApexPages.StandardSetController bmStdSetCtrl;    

    private ID bmOpportunityId;
    private String bmOpportunityName;
    private ID bmSelectedQuoteId;

    public BigMachinesChooseQuoteToCloneExtension(ApexPages.StandardSetController stdSetCtrl) {
        bmOpportunityId = ApexPages.currentPage().getParameters().get('oppId');
        bmOpportunityName = [select Name from Opportunity where Id = :bmOpportunityId].Name;
        bmStdSetCtrl = stdSetCtrl;
    }

    public void setSelectedQuoteId(ID quoteId) {
        bmSelectedQuoteId = quoteId;
    }    

    public String getSelectedQuoteId() {
        return bmSelectedQuoteId;
    }

    public String getOppName() {
        return bmOpportunityName;
    }
    
    public ID getOppId() {
        return bmOpportunityId;
    }

    public Integer getStartOfRange() {
        return (bmStdSetCtrl.getPageNumber()-1) * bmStdSetCtrl.getPageSize() + 1;
    }
    
    public Integer getEndOfRange() {
        Integer rangeEnd = bmStdSetCtrl.getPageNumber() * bmStdSetCtrl.getPageSize();
        if (rangeEnd > bmStdSetCtrl.getResultSize()) {
            rangeEnd = bmStdSetCtrl.getResultSize();
        }
        return rangeEnd;
    }

    public PageReference cloneQuote() {
        if (bmSelectedQuoteId != null) {
            return new PageReference('/apex/BM_NewQuote?cloneId=' + bmSelectedQuoteId + '&oppId=' + bmOpportunityId);
        } else {
            return new PageReference('/apex/BM_CloneSelection?oppId=' + bmOpportunityId);
        }
    }

    public PageReference cancel() {
        return new PageReference('/' + bmOpportunityId);
    }

   /*Moved to seprate class BigMachinesChooseQuoteToCloneExten_Test
    static testMethod void testGetQuoteListFromOpty() {
        //BigMachinesController controller = new BigMachinesController();
        Opportunity opty = new Opportunity();
        opty.Name = 'BigMachines test Opportunity for testGetQuoteList';
        opty.StageName = 'Prospecting';
        opty.CloseDate = Date.today();
        //Start - Added by CF so SFDC test pass objetc validation rules
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
        BigMachines_Quote__c quote = new BigMachines_Quote__c();
        quote.Name = 'BigMachines test quote for testGetQuoteListFromOpty';
        quote.Opportunity__c = opty.id;
        insert quote;
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController([select id from BigMachines_Quote__c limit 1]);
        ApexPages.currentPage().getParameters().put('oppId', opty.id);
        BigMachinesChooseQuoteToCloneExtension controller = new BigMachinesChooseQuoteToCloneExtension(stdSetCtrl);
        pagereference p ;
        controller.getOppName();
        controller.getOppId();
        system.assertequals(controller.bmOpportunityId,opty.id);
        controller.getStartOfRange();
        controller.getEndOfRange();
        controller.cloneQuote();
        controller.setSelectedQuoteId(quote.id);
        controller.getSelectedQuoteId();
        controller.cloneQuote();
        p=controller.cancel();
        system.assertnotequals(p,new PageReference('/'+opty.id));
    }*/

}