public with sharing class DisplayConsumable {
	public Consumables__c consu{get;set;}
	public string resource {get;set;}
	public string location {get;set;}
	public DisplayConsumable()
	{
		Id consuId = System.currentPageReference().getParameters().get('Id');
		consu = [select id,ImageName__c, Image_Location__c, Image_URL__c,Name, Static_Resource_Location__c from Consumables__c where Id = :consuId];
		if(consu.Image_Location__c==null)
		resource = 'Consumabels_1';
		else
		resource = consu.Image_Location__c;
		
		if(consu.Static_Resource_Location__c==null)
		location = 'Consumabels_1';
		else
		location = consu.Static_Resource_Location__c;
	}
	
}