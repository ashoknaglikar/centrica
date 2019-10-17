public with sharing class BMQuoteMapper
{
	/**
	 *	getQuotesByIds - Get Quotes for the supplied Id's
	 *
	 *	Arguments: Set<Id> ids - id's of quotes to search for
	 *	Returns: Map<Id, BigMachines_Quote__c> - map of quotes keyed by Id
	 */
	public static Map<Id, BigMachines_Quote__c> getQuotesByIds(Set<Id> ids)
	{
		return new Map<Id, BigMachines_Quote__c>([Select FaultPDF__c,POC_Payment_Method__c, Opportunity__c,b.Name, b.Id, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c From BigMachines_Quote__c b where b.id in :ids]);
	}
}