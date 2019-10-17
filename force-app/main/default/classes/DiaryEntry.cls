public with sharing class DiaryEntry {
	
	public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
	private Diary_Entry__c entry;
	
	//constructor
	public DiaryEntry(Diary_Entry__c dEntry)
	{
		entry = dEntry;
	}	
	//return the modified diary entry
	/* dont need this as entry is passed in by reference so you get back
	the changes anyway
	public Diary_Entry__c getDiaryEntry()
	{
		return entry;	
	}
	*/
	//create a new gap as this one has been split by inserting something in the middle
	//start and end must be provided
	public Diary_Entry__c newGap(Datetime startTime, DateTime endTime)
	{
		//if the start and end time are the same, we don't actually need a new gap
		if(DatetimeHelper.dateEquals(startTime, endTime))
		{
			return null;
		}
		else
		{
			/*
			//clone the existing entry to get the useful data that will be the same
			Diary_Entry__c newGap = entry.clone(false, true);
			
			system.debug(LoggingLevel.INFO, 'The week on the new gap is : ' + newGap.week__c);		
			
			//set some values that do not need to be copied
			newGap.Start__c = startTime;
			newGap.End__c = endTime;
			newGap.RecordTypeId = ENTRY_RECTYPE_AVAIL;
			newGap.Sub_Type__C = 'Availability';
			newGap.Job__c = null;
			newGap.Extra_Hours__c = null;
			return newGap;
			*/
			//makes more sense just to create a new object with the fields we want
			Diary_Entry__c newGap = new Diary_Entry__c(Week__c = entry.week__c, 
				RecordTypeId = ENTRY_RECTYPE_AVAIL, Sub_Type__c = 'Availability',
				Start__c = startTime, End__c = endTime);
			system.debug(LoggingLevel.INFO, 'CREATING NEW GAP: '+newGap);
			return newGap;
		}
	}
	
	//reduce the size of a diary entry by making the end time earlier
	public void shrinkLeft(Datetime endTime)
	{
		entry.End__c = endTime;
	}
	//reduce the size of a diary entry by making the start time later
	public void shrinkRight(Datetime startTime)
	{
		entry.Start__c = startTime;
	}
	//increase the size of a diary entry by making the start time earlier
	public void growLeft(Datetime startTime)
	{
		entry.Start__c = startTime;
	}
	//increase the size of a diary entry by making the end time later
	public void growRight(Datetime endTime)
	{
		entry.End__c = endTime;
	}
	/*  //This is old - do not delete entries in this way
	public void remove()
	{
		delete entry;
		entry = null;
	}
	*/
	
}