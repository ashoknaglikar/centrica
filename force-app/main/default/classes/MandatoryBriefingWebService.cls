global class MandatoryBriefingWebService {
	
	static List<Mandatory_Briefings__c> briefsToBeInserted = new List<Mandatory_Briefings__c>();
	static List<Task> tasksToBeCreated = new List<Task>();
	
	@future (callout=false)
	webservice static void generateMandatoryBriefs(String mbcId)
	{
		system.debug('-----mbcId-------'+mbcId);
		Map<String,Id> briefNameUserIdMap = new Map<String,Id>();
		Map<Id,String> briefIdNameMap = new Map<Id,String>();
		Id userId;
		Mandatory_Briefing_Creator__c mbc = new Mandatory_Briefing_Creator__c();
		mbc = [Select m.Name__c, m.Issued_Date_Time__c, m.Id, 
		       m.Employee__r.Salesforce_User__c, m.Employee__r.Id, m.Employee__c,
		       m.Employee__r.Salesforce_User__r.IsActive,
		       m.Employee_Group__r.Id, m.Employee_Group__c,m.Brief_Generation_Status__c,
		       m.Content__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c 
		       From Mandatory_Briefing_Creator__c m
		       where id=: mbcId];
		
		mbc.Brief_Generation_Status__c = 'In Process';
		if(mbc.Active_Count__c == null)
		{
			mbc.Active_Count__c = 0;
		}
		if(mbc.Inactive_Count__c == null)
		{
			mbc.Inactive_Count__c = 0;
		}
		update mbc;
		       
		if(mbc.Employee__r.Id != null && mbc.Employee__r.Salesforce_User__r.IsActive)
		{
			mbc.Active_Count__c++;
			Mandatory_Briefings__c brief = new Mandatory_Briefings__c();
			brief.Briefing_Name__c = mbc.Name__c;
			brief.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
			brief.Employee__c = mbc.Employee__r.Id;
			//brief.Completeion_Date_Time__c = system.now()+5;
			brief.Content__c = mbc.Content__c;
			brief.Mandatory_Briefing_Creator__c = mbc.Id;
			brief.Status__c = 'In Progress';
			briefsToBeInserted.add(brief);
			
		}
		else if(mbc.Employee__r.Id != null && (mbc.Employee__r.Salesforce_User__r.IsActive == false))
		{
			mbc.Inactive_Count__c++;
		}
		
		for(Groups__c  groupObj : [Select g.id,
		                          (Select Employee__c,Employee__r.Salesforce_User__c,Employee__r.Salesforce_User__r.IsActive 
		                           From Employee_Groups__r)
		                           From Groups__c g where g.id =: mbc.Employee_Group__r.Id])
		                           
		{
			for(Employee_Group__c emGroup : groupObj.Employee_Groups__r)
			{
				if(emGroup.Employee__r.Salesforce_User__r.IsActive == true)
				{
					mbc.Active_Count__c++;
					Mandatory_Briefings__c brief = new Mandatory_Briefings__c();
					brief.Briefing_Name__c = mbc.Name__c;
					brief.Completed_By__c = emGroup.Employee__r.Salesforce_User__c;
					brief.Employee__c = emGroup.Employee__r.Id;
					//brief.Completeion_Date_Time__c = system.now()+5;
					brief.Content__c = mbc.Content__c;
					brief.Mandatory_Briefing_Creator__c = mbc.Id;
					brief.Status__c = 'In Progress';
					briefsToBeInserted.add(brief);
				}
				else if(emGroup.Employee__r.Salesforce_User__r.IsActive == false)
				{
					mbc.Inactive_Count__c++;
				}
				
			}
		}
				
		Database.SaveResult[] results = Database.insert(briefsToBeInserted , false);
		
		mbc.Brief_Generation_Status__c = 'Complete';
		update mbc;
		
		
	}
	webservice static string checkForDocuments(String mbcId)
	{
		Mandatory_Briefing_Creator__c mbc = new Mandatory_Briefing_Creator__c();
		mbc = [Select id ,(Select Id From Attachments) From Mandatory_Briefing_Creator__c m where id=: mbcId];
		if(mbc.Attachments.size() > 0)
		{
			return 'TRUE';
		}
		else
		{
			return 'FALSE';
		}
	}
}