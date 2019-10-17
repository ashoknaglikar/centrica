trigger incrementQuoteIdentifier on BigMachines_Quote__c (after insert) {		
	
	 // Fix - Cognizant support - To reduce number of SOQL's in quote triggers to avoid governor limits.
	 // This trigger is no longer needed because this functionality is now added in trg_updateOpportunityPaymentDetails.trigger
	
	   return;
	
	//Updates the quote incrementer field on the associated opportunity to keep a count
	//of the number of Big Machines quotes associated with the opportunity. This is so that
	//each quote in big machines can be assigned a unique id which is a combination of Opportunity ID / Incrementor ID
	
 /* 
 
   private Integer inc;
	
	for(BigMachines_Quote__c newQuote : Trigger.new){
		if(newQuote.Opportunity__c!=null){
			Opportunity opp = [Select o.Id, o.quoteIncrementer__c From Opportunity o where o.Id = :newQuote.Opportunity__c];
			if(opp.quoteIncrementer__c == null)			
				opp.quoteIncrementer__c = '1';			
			else{
				inc = Integer.valueOf(opp.quoteIncrementer__c);
				inc++;			
				opp.quoteIncrementer__c = String.valueOf(inc);
			}		
			update opp;		
		}
	}	
	
	*/
	
}