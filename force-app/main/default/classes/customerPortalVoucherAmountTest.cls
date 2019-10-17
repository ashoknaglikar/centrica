@isTest
public class customerPortalVoucherAmountTest {
    public static BigMachines_Quote__c quote;
    private static testmethod void  secnario1()
    {
    
    customerAcceptCloneQuotePortalResponse objResponse = new customerAcceptCloneQuotePortalResponse();
     
      Account acc = TestClassHelper.createAccout();
      insert acc;
    
      Contact con = TestClassHelper.createContact(acc);
      insert con;
    
      Opportunity opp  = TestClassHelper.createCHILead(acc);
      insert opp;
        
      quote = TestClassHelper.createBMQuote(opp);
      insert quote;
     
      Offer__c off= new Offer__c(Offer_Code__c='QWERT12345',value__c=100,start_date__c=system.today()-1,end_date__c=system.today()+1,Description__c='test',offer_type__c='Monetary');
      insert off;
      
      Lead_Offer__c leadOff = new Lead_Offer__c(Offer__c=off.id,opportunity__c=opp.id);
      insert Leadoff;
      
    
    String voucherCode = 'QWERT12345';
    Test.setMock(HttpCalloutMock.class, new HttpMockup());
    try{    
    customerPortalVoucherAmountAPI.getVoucherAmount(string.valueof(opp.id),string.valueof(quote.id),voucherCode);
    }
    catch(Exception e)
    {}
    
    String voucherCode1 = 'QWERT65345';
    try{    
    customerPortalVoucherAmountAPI.getVoucherAmount(string.valueof(opp.id),string.valueof(quote.id),voucherCode1);
    }
    catch(Exception e)
    {} 
    
    }

}