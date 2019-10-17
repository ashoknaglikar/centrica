trigger aUPDDummyDataDelete on Account (after update) {
	
	if(cls_IsRun.generalTriggerSwitch)
	{
		return;
	}
	
	List<Id> DummyAccIdlst = new List<Id>(); 
	
	for(Account a : trigger.new){
		if((a.Dummy_Data__c == true || a.Name == 'Dummy Test') && a.Dummy_Delete__c == true){
			DummyAccIdlst.add(a.Id);
		}
	}
	
	if(DummyAccIdlst.size()==0){
		return;
	}
	
	List<Opportunity> DummyOpps = [select Id from Opportunity where AccountId in :DummyAccIdlst];
	
	List<Job__c> DummyJobs = [Select Id from Job__c where CHI_Lead__c in :DummyOpps];
	
	if(DummyOpps!=null){
	   if(DummyOpps.size()>0){
		   delete DummyOpps;	
 	   }
	}
	
	if(DummyJobs!=null){
		if(DummyJobs.size()>0){
		  delete DummyJobs;	
	   }
	}
}