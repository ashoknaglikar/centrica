/*
Author : Cognizant
Purpose : Purpose of this trigger is to create/update the tasks
          related to mandatory briefing.
*/
trigger CreateBriefTask on Mandatory_Briefings__c (after insert, after update , before update) {
    
    List<Task> briefTasks = new List<Task>(); // List of taks to be created
    Set<Id> briefIdSet = new Set<Id>(); // set of brief id's
    List<Task> briefTaskToBeCompleted = new List<Task>(); // List of taks to be completed
    for(Mandatory_Briefings__c brief : Trigger.new)
    {
        if(trigger.isInsert && trigger.isAfter)
        {
            // create task as soon as brief record is created
            Task brieftask = new Task();
            brieftask.OwnerId = brief.Completed_By__c;
            brieftask.Subject = brief.Briefing_Name__c;
            brieftask.Status = 'In Progress';
            brieftask.Priority = 'Normal';
            brieftask.WhatId = brief.Id;
            brieftask.ReminderDateTime = brief.Issued_Date_Time__c;
            brieftask.IsReminderSet = true;
            brieftask.ActivityDate = Date.valueOf(brief.Actual_End_Date_Time__c);
            brieftask.RecordTypeId = Utilities.getRecordTypeId('Brief Task', 'Task');
            briefTasks.add(brieftask);
        }
        if(trigger.isUpdate && trigger.isAfter)
        {
            // If brief is complete & understood then add brief id to set 
            if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Understood')
            {
                briefIdSet.add(brief.id);
            }
        }
        if(trigger.isBefore && trigger.isUpdate)
        {
            if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Understood')
            {
                brief.Completeion_Date_Time__c = system.now();
            }
        }
        
    }
    
    if(briefTasks.size() > 0)
    {
        try{
            insert briefTasks;
        }
        catch(Exception ex)
        {
        //added by BGSAMS Support - To capture exception in Brief Tasks - starts
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
        String[] toAddresses1 = new String[] {'APPS-SALESFORCE-COGSupport@centrica.com'};                                   
        mail1.setToAddresses(toAddresses1);
        mail1.setSubject('Exception in creating brief Tasks');
        mail1.setPlainTextBody('Brief Task was not created for the following reason: ' + ex.getMessage());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });  
        //added by BGSAMS Support - To capture exception in Brief Tasks - ends
        }
    }
    
    if(briefIdSet != null && briefIdSet.size() > 0)
    {
        // fetch the task related to brief & set status of task as "Complete"
        for(Task brieftask : [Select t.WhatId, t.Status, t.Id, t.Description,t.Owner.Name, t.OwnerId 
                              From Task t
                             where t.whatId in: briefIdSet])
        {
            brieftask.Description = 'Mandatory brief is completed & understood by '+brieftask.Owner.Name;
            brieftask.Status = 'Completed';
            briefTaskToBeCompleted.add(brieftask);
        }
    }
    
    if(briefTaskToBeCompleted.size() > 0)
    {
        update briefTaskToBeCompleted;
    }

}