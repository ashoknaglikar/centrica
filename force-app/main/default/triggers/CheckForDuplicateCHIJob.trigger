/*
    brm - 11-01-2010
    
    * Prevents more than one active (Status not set to Cancelled) Central Heating Installation 
        job on a CHI Lead
*/

trigger CheckForDuplicateCHIJob on Job__c (before insert) {
    Set<Id> chiLeadIds = new Set<Id>();
    // Get all chi lead ids from new jobs
    for (Job__c newJob : Trigger.new)
    {
        if (newJob.Type__c == 'Central Heating Installation') chiLeadIds.add(newJob.CHI_Lead__c);
    }
    
    // Query database for any CHI jobs on the CHI Leads found above
    Set<Id> leadAlreadyHasJob = new Set<Id>();
    for (Job__c job : [Select Id, Status__c, CHI_Lead__c From Job__c Where Type__c = 'Central Heating Installation' and CHI_Lead__c in :chiLeadIds])
    {
        if (job.Status__c != 'Cancelled' && !leadAlreadyHasJob.contains(job.CHI_Lead__c)) leadAlreadyHasJob.add(job.CHI_Lead__c);
    }
    
    // Loop through all new jobs
    for (Job__c newJob : Trigger.new)
    {
        // If the new job's CHI Lead already has a job
        if (newJob.Type__c == 'Central Heating Installation' && leadAlreadyHasJob.contains(newJob.CHI_Lead__c))
        {
            // Add error
            newjob.addError('There is already an active Central Heating Installation job for the selected CHI Lead');
        }
    }
}