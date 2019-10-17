trigger DiaryEntryDelete on Diary_Entry__c (before delete,before insert,after delete) {
	//some constants
	String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
	String ENTRY_RECTYPE_JOBBOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
	if(trigger.isdelete && trigger.isbefore)
	{
	
		List<Diary_Entry__c> unavs = new List<Diary_Entry__c>();
		//only do this for Unavailability, ignores other types
		//collect a list of all of the unavailability records
		for(Diary_Entry__c entToDel : trigger.old )
		{
			if(entToDel.RecordTypeId == ENTRY_RECTYPE_UNAVAIL)
			{
				unavs.add(entToDel);
			}
			
		}	
		//now use the unavailability manager to manage the diary entry records
		if(unavs.size() > 0)
		{
			UnavailabilityManager.removeUnavailability(unavs);
		}
		
	}	
	
	if(trigger.isdelete && trigger.isafter)
	{
		List<Diary_Entry__c> consolidatedLst = new List<Diary_Entry__c>();
		
		for(Diary_Entry__c entToDel : trigger.old )
		{
			if(entToDel.RecordTypeId == ENTRY_RECTYPE_UNAVAIL  ||entToDel.RecordTypeId == ENTRY_RECTYPE_JOBBOOKING)
			{
				consolidatedLst.add(entToDel);
			}
		}	
		
		if(consolidatedLst.size() > 0)
		{
			UnavailabilityManager.stackUnavailability(consolidatedLst);
		}
		
	}
	
	if(trigger.isinsert)
	{
		List<Diary_Entry__c> unavs = new List<Diary_Entry__c>();
		//only do this for Unavailability, ignores other types
		//collect a list of all of the unavailability records
		for(Diary_Entry__c entToIns : trigger.new )
		{
			if(entToIns.RecordTypeId == ENTRY_RECTYPE_UNAVAIL && entToIns.Stackable__c == 'Yes')
			{
				unavs.add(entToIns);
			} 
		}	
		if(unavs.size() > 0)
		{
			UnavailabilityManager.markStackableUnavailability(unavs);
		}
	}
}