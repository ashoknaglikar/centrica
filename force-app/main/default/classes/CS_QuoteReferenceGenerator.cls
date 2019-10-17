public class CS_QuoteReferenceGenerator {

    /*
     * Used by a UISupport Remote Action to get the total count of existing Quotes on the Opportunity
     */
    public static Integer getQuoteCountOnOpportunity(Id oppId)   {
        
        AggregateResult[] aggr = [select count(Id) quoteCount
                                from cscfga__Product_Basket__c
                                where Appointment__r.Opportunity__c = :oppId];
                            
        Integer counter = Integer.valueOf(aggr[0].get('quoteCount'));
        
        system.debug('***** Quotes retrieved: ' + counter);
        system.debug('***** for oppId: ' + oppId);
        
        return counter;
    } 
    
    public static String getNextQuoteReference(Id oppId) {
    
        List<Opportunity> opps = [select Id, CHI_Lead_Id__c from Opportunity where Id = :oppId];
        
        String quoteRef = '';
        
        if (opps.size() > 0) {
            Integer quoteCount = getQuoteCountOnOpportunity(oppId);
            
            String finalChar = calcFinalChar(quoteCount);
            
            quoteRef = 'C' + opps[0].CHI_Lead_Id__c + finalChar; 
            
            system.debug('***** quoteRef produced is: ' + quoteRef);
        }
        
        return quoteRef;
    
    }
    
    
    public static String calcFinalChar(Integer quoteCount){
        List<String> lastCharArray = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        lastCharArray.remove(0);
        
        if (quoteCount < lastCharArray.size()) {
            return lastCharArray[quoteCount];
        }
        
        return calcFinalChar(Integer.valueOf(Math.floor(quoteCount / lastCharArray.size()) -1)) + calcFinalChar(Math.mod(quoteCount, lastCharArray.size()));
    }
    
    
}