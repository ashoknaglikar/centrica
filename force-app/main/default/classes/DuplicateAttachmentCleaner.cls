global class DuplicateAttachmentCleaner implements Database.Batchable<sObject>
{

	public static void createDuplicateAttachementCleaner()
	{
        DuplicateAttachmentCleaner objCleaner = new DuplicateAttachmentCleaner();
        ID batchprocessid = Database.executeBatch(objCleaner,50);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	list<string> roleList = system.label.HSARoleList.split(':');
      
        return Database.getQueryLocator('Select Id, Employee_Number__c, Salesforce_user__c from Employee__c where Primary_Role__c in : roleList');
         
    }

    global void execute(Database.BatchableContext BC, List<Sobject> employeelIst)
    {

    	date enddate = system.today().adddays(1);
		date startdate = enddate.adddays(-30);

    	for(sObject s: employeelIst)
    	{
    		Employee__c emp = (Employee__c)s;

    		// hold list of chi leads from last 30 days
			list<id> oppIdList = new list<id>();
			for(Appointment__c ap : [Select id, Opportunity__c from Appointment__c Where Assigned_To__c = :emp.Id and 
			                        Type__c = 'Sales' and
			                        Start__c >= :startdate and 
			                        End__c<= :enddate])
			{

				oppIdList.add(ap.Opportunity__c);
			}

			// Query list of attachements from the opportunity captured
			list<attachment> attachments = [Select id, Name, ParentId, ownerId from attachment Where ParentId = :oppIdList order by CreatedDate Desc];
			system.debug(attachments.size());

			set<string> nameSet = new set<string>();

			list<attachment> deleteList  = new list<attachment>();

			for(attachment a: attachments)
			{
			    //check if attachement is from depot
			    //check if owener of the the attachement
			    // check is its not already added. 
			    system.debug(emp.Salesforce_user__c == a.ownerId);
			    system.debug(a.name);
			    system.debug(a.ParentId);
			    system.debug(a.name.contains(a.ParentId));
			    if(!nameSet.contains(a.Name) && (emp.Salesforce_user__c== a.ownerId || a.name.contains('Installation')))
			    {
			        nameSet.add(a.name);
			        continue;
			    }else if(a.name.contains(a.ParentId) || a.name.contains(string.valueof(a.ParentId).substring(0,15)) || a.name.contains('Installation'))
			    {
			    	deleteList.add(a);
			    }	
				
			}
			system.debug('before deleteing-->'+attachments.size());
			system.debug('Total Deleted-- >'+deleteList.size());

			if(deleteList.size()>0)
			{
				delete deleteList;
			}

		}
    }
    
    global void finish(Database.BatchableContext bc)
    {

	}

}