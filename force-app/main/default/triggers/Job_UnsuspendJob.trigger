/*
rjd - 2009-12-07

Trigger to un-suspend a job as part of suspend/cancel functionality.

Workflow will have set:-
    Job__c.Unsuspend_Job__c = false from true
    

trigger functionality:-
1. Take all Suspended Job_Element__c items (status__c='Suspended') for job and set status__c='Active' and sub_status__c='Awaiting Order'

*/
trigger Job_UnsuspendJob on Job__c (after update) {
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.unsuspendJob)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch);
        System.debug('unsuspendJob : ' +Lock.unsuspendJob);
        return;
    }
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    
    // PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }   
    Job__c oldJob;
    // if there are multiple updates then return error - only works for one record.
    if(trigger.new.size() > 1){
        for(Job__c newJob : trigger.new){
            oldJob = trigger.oldMap.get(newJob.Id);
            //if the Unsuspend_Job__c  has been unchecked (this will be from workflow)
            if(!oldJob.Unsuspend_Job__c && newJob.Unsuspend_Job__c)
                newJob.addError('Unsuspend Job functionality is not bulkified and can only be used for 1 Job update at a time.');
        }
    }else{
        
        Job__c newJob = trigger.new.get(0);
        oldJob = trigger.oldMap.get(newJob.Id);
        //if the Unsuspend_Job__c  has been unchecked (this will be from workflow)
        if(!oldJob.Unsuspend_Job__c && newJob.Unsuspend_Job__c){
            // gjb 2010-03-03 - Now using a future method to unsuspend the job elements, to avoid DML row limits
            // when cancelling a job.
            UpdateJobElements.unsuspendJobElementsFuture(newjob.ID);
            
            // Old code - essentially, this has been copy/pasted to the future method called above.
            /*List<Job_Element__c> toUpdate = new List<Job_Element__c>();
            newJob = [Select (Select Id, Type__c, Status__c, Sub_Status__c From Job_Elements1__r) From Job__c j where id=:newJob.Id];
            for(Job_Element__c je : newJob.Job_Elements1__r){
                if(je.Status__c == 'Suspended'){
                    je.Status__c = 'Active';
                    je.Sub_Status__c = 'Awaiting Planning';
                    toUpdate.add(je);
                }
            }
            
            if(toUpdate.size() > 0) update toUpdate;*/
        }
    }
}