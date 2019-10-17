trigger contactTrigger on Contact (after update,after insert) {

If(Trigger.isAfter)
{
	if(trigger.isUpdate ){

		if(!Lock.cchContactOppRecursiveStopper)
		{
			Lock.cchContactOppRecursiveStopper = true;
			ContactTriggerHandler.updateMarketingPreferenceFieldOnopportunity(trigger.oldmap,Trigger.new);
		}
	}
}
}