public class opportunityTriggerHandler
{

	public static void handleMaketingPreference(Map<id, Opportunity> triggerNew , Map<id, Opportunity> triggerOld)
	{
		map<id, Opportunity> oppMap = new map<id, Opportunity>();
		for(Opportunity opp: triggerNew.Values())
		{
			if(trigger.isInsert ||  (trigger.Isupdate && (Opp.Marketing_Preferences__c!= triggerOld.get(opp.id).Marketing_Preferences__c ||  Opp.Customer_Marketing_Consent__c!= triggerOld.get(opp.id).Customer_Marketing_Consent__c)) )
			{
				oppMap.put(opp.AccountId, opp);
			}

		}
		if(oppMap.size()>0)
		{
			list<Contact>  contactList =  [select id,AccountId from Contact where Primary_Contact__c = true and AccountId in : oppMap.keyset()];

			for(Contact c: contactList)
			{
					if(oppMap.containsKey(c.AccountId))
					{
						Opportunity oppRecord = oppMap.get(c.AccountId);

						c.Marketing_Preference__c = oppRecord.Marketing_Preferences__c;
						c.Marketing_Consent__c = oppRecord.Customer_Marketing_Consent__c;
					}
			}

			if(contactList.size()>0)
			update contactList;
		}

	}
}