global class DeleteBriefWebService {
	
	static List<Mandatory_Briefings__c> briefsToBeDeleted = new List<Mandatory_Briefings__c>();
	
	webservice static void deleteMandatoryBriefs(String mbcId)
	{
		Mandatory_Briefing_Creator__c MBC = [Select (Select Id From Mandatory_Briefings__r) From Mandatory_Briefing_Creator__c m where Id =: mbcId];
		for(Mandatory_Briefings__c brief : MBC.Mandatory_Briefings__r)
		{
			briefsToBeDeleted.add(brief);
		}
		if(briefsToBeDeleted.size() > 0 )
		{
			try
			{
				delete briefsToBeDeleted;
				MBC.Active_Count__c = 0;
				MBC.Inactive_Count__c = 0;
				MBC.Brief_Generation_Status__c = null;
				update MBC;
			}
			catch(Exception ex)
			{
				system.debug('----------Error-----'+ex);
			}
		}
	}

}