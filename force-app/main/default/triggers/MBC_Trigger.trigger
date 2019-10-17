/*
Author : Cognizant
Purpose : Purpose of this trigger is to do all the validations
          before inserting MBC record.
*/
trigger MBC_Trigger on Mandatory_Briefing_Creator__c (before insert,before update) {
	
	for(Mandatory_Briefing_Creator__c mbc : Trigger.new)
	{
		// If employee or employee group is absent then show error message.
		if(mbc.Employee__c == null && mbc.Employee_Group__c == null)
		{
			mbc.addError('Please select either employee group or employee.');
		}
		if(Trigger.isBefore && Trigger.isInsert)
		{
			
			if(mbc.Issued_Date_Time__c < system.now())
			{
				mbc.addError('Issued date time will never be past date value.');
			}
		}
		
	}
}