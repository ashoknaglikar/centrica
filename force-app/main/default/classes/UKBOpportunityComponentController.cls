public with sharing class UKBOpportunityComponentController {
	
	public Opportunity oppRecord {get;set;}
	
	public boolean pageMessages {get;set;}
	
	public UKBOpportunityComponentController()
	{
		pageMessages = false;
		
	}
	
	public void checkOpp()
    {
    	if(oppRecord.Boiler_Size__c > 40 || oppRecord.Number_of_boilers_in_scope_to_replace__c >1 || oppRecord.Number_Of_Radiators__c >14|| oppRecord.Number_of_Additional_Appliances__c >1 ||
    	oppRecord.Total_number_of_boilers_onsite__c>1 || oppRecord.Fuel_Type__c!= 'Natural Gas' || oppRecord.Type_of_Heater__c == 'Heater')
    	{
    		pageMessages = true;
    		ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'This Lead is not eligible for HA visit & needs to be surveyed by CIM, please use BAU process.');
        	ApexPages.addMessage(msg);
    		
    		
    	}else
    	{
    		pageMessages = false;
    	}
    	
    }
    
}