trigger DeleteDummyRecords on Opportunity (after delete) {
	if(cls_IsRun.generalTriggerSwitch)
	{
		return;
	}
	List<Id> AccIdLst = new List<Id>();
	
	for(Opportunity o : trigger.old){
			AccIdLst.add(o.AccountId);
	}
	
	if(AccIdLst.size()==0){
		return;
	}

	List<Account> DummyAccs = [Select Id from Account where Dummy_Data__c = true and Id in:AccIdLst and Name = 'Dummy Test'];
    
    if(DummyAccs!=null){
	     if(DummyAccs.size()>0){
		     delete DummyAccs;	
	      }
    }

}