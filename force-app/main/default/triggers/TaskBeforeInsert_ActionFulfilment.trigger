trigger TaskBeforeInsert_ActionFulfilment on Task (before insert) {
	
	Map<String,Task> leadTaskMap = new Map<String,Task>{};
	Map<String,Id> oppsMap = new Map<String,Id>{};
	Map<Id, Task> TaskMap = new Map<Id, Task>();
	for (Task t : Trigger.new)
	{
		if(t.Opportunity_Id__c!=null)
			leadTaskMap.put(t.Opportunity_Id__c,t);
		string taskId = 	t.WhatId;
        
		if(t.WhatId!= null && taskId.startsWith(case.sObjectType.getDescribe().getKeyPrefix()))	
		{
			TaskMap.put(t.WhatId,t);
		}
        system.debug('TaskMap-->'+TaskMap);
	}
	
	if(TaskMap.size()>0)
	{
		for(Case c: [Select Id, RecordType.Name, Contact.Name, Contact.Best_Phone__c,Contact.MobilePhone,Contact.HomePhone, Contact.OtherPhone, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode from Case Where id in : TaskMap.keyset()])
		{
            if(c.RecordType.Name == 'Dissatisfaction' || system.label.CaseDisssatifaction== 'on')
            {    
                Task t = TaskMap.get(c.Id);
                t.Description = t.Description + '\n\n Customers Name: ' +c.Contact.Name +
                    			'\n\n Address :'+c.Account.BillingStreet +' ' + c.Account.BillingCity + ' ' + c.Account.BillingPostalCode+
                                +'\n\n Best Phone :'+c.Contact.Best_Phone__c +
                    			+'\n Mobile :'+c.Contact.MobilePhone +
                                +'\n Home Phone :'+c.Contact.HomePhone +
                                +'\n Work Phone :'+c.Contact.OtherPhone ;
                                
                 
            }   
		}
        
       
	}
	
	Opportunity[] oppsList=
			[Select o.CHI_Lead_Id__c,o.id from Opportunity o where o.CHI_Lead_Id__c in :leadTaskMap.keySet()];
	
	System.debug('oppsList: ' + oppsList);
	
	for (Opportunity opp : oppsList)
	{
		oppsMap.put(opp.CHI_Lead_Id__c,opp.Id);
	}
	
	//for(String leadNum : leadTaskMap.keySet())
	//{
		//System.debug('Setting WhatId to: ' + oppsMap.get(leadNum));
		//leadTaskMap.get(leadNum).WhatId=oppsMap.get(leadNum);
		//System.debug('Set WhatId to: ' + leadTaskMap.get(leadNum).WhatId);
	//}
	
	if (oppsMap.isEmpty())
		return;
	for (Task t : Trigger.new)
	{
		t.WhatId = oppsMap.get(t.Opportunity_Id__c);
	}
	
}