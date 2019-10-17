trigger Delete_event_Installer on Diary_Entry__c (before delete) 
{
    String InsId = RecordTypeIdHelper.getRecordTypeId('Event', 'Installation');
    Set<String> diaryId=new Set<String>{};
    Set<Id> jobIds = new set<Id>();
    for (Diary_Entry__c d: Trigger.old) {
        if (d.Check_Installer_type__c=='true')
        { 
            diaryId.add(d.Id);
            jobIds.add(d.Job__c);
        }    
    }   
    try {
    	if(jobIds.size()>0)
    	{
	    	list <Job__c> jobsToUpdate=[Select Id,Start_Data_Time__c,Previous_End_Time__c,Previous_Start_Time__c,Maximum_End_Date__c from Job__c where Id in:jobIds];
			
			if(jobsToUpdate.size()>0)
			{
				for(Job__c j:jobsToUpdate)
				{
					j.Previous_Start_Time__c = j.Start_Data_Time__c;
					j.Previous_End_Time__c = j.Maximum_End_Date__c;
					
				}
				update jobsToUpdate;
			}
    	}
		
        List<Installer__c> lst_old_Installer = [Select Id, Job__c, Installer_Status__c, Diary_Entry__c from Installer__c where Diary_Entry__c in: diaryId];
        if(lst_old_Installer!= null)
        {
            for (Installer__c objInstaller: lst_old_Installer) {
                objInstaller.Installer_Status__c='Inactive';
            }
            update lst_old_Installer;
        }
        
        //START: TO AVOID 100K RECORDS EXCEPTION.: 06/JAN/2011.
        List<Event> lst_old_Event = [Select Id,Whatid,OwnerId,Job_Number__c,StartDateTime,EndDateTime, RecordtypeId,Diary_Entry_ID__c from Event where Diary_Entry_ID__c in :diaryId];
        List<Event> del_old_Event = new List<Event>();
        
        for(Event e : lst_old_Event){
            if(e.recordtypeId == InsId){
                del_old_Event.add(e);
            }
        }
        
        if(del_old_Event.size() > 0)
            delete del_old_Event;     
        //END: TO AVOID 100K RECORDS EXCEPTION.: 06/JAN/2011.  
    } catch(Exception ex) {
        System.debug('Exception'+ ex);
    }
    
    
}