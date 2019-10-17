/*
Author : Cognizant
Purpose : Purpose of this trigger is to complete the brief record when
		  task related to brief is completed
*/
trigger CompleteBriefs on Task (before update) {
	
	Schema.Describesobjectresult result = Schema.Sobjecttype.Mandatory_Briefings__c;
	Set<Id> briefId = new Set<Id>();
	Map<Id,Mandatory_Briefings__c> briefMap = new Map<Id,Mandatory_Briefings__c>();
	// check for static variable to avoid recursive trigger functionality
	if(cls_IsRun.istrg_CompleteBriefs == false)
	{
		cls_IsRun.setistrg_CompleteBriefs();
		for(Task briefTask : Trigger.new)
		{
			if(briefTask.WhatId != null)
			{
				if(string.valueOf(briefTask.WhatId).startsWith(result.getKeyPrefix()))
				{
					briefId.add(briefTask.WhatId);
				}
			}
		}
		
		for(Mandatory_Briefings__c brief : [Select m.Sub_Status__c, m.Status__c, m.Id From Mandatory_Briefings__c m where m.Id in: briefId])
		{
			briefMap.put(brief.id , brief);
		}
		
		for(Task briefTask : Trigger.new)
		{
			if(briefMap.containsKey(briefTask.WhatId) && briefMap.size()>0)
			{
				if(briefTask.Status == 'Completed' && ((briefMap.get(briefTask.WhatId).Sub_Status__c == 'Not Understood' && briefMap.get(briefTask.WhatId).Status__c == 'Complete') || (briefMap.get(briefTask.WhatId).Status__c == 'In Progress')))
				{
					briefTask.addError('Please complete & understood the brief before completing the task');
				}
				
			}
		}
		
	}
}