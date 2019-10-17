/*
rjd - 2009-12-07

Trigger to suspend a job as part of suspend/cancel functionality.

Workflow will have set:-
    Job__c.Suspend_Job__c = false from true
    (possibly)
    Job__c.Cancel_Merchant_Orders__c = false from true
    

trigger functionality:-
1. Unplan all Diary Entries for the job
2. Set active work job elements to status = 'suspended'
    write a JBH entry  Work_Affected__c = true
3. (if Cancel_Merchant_Orders__c unset)
    Set Active material JEs to status = 'suspended'
    write a JBH entry Materials_Affected__c = true

*/
trigger Job_SuspendJob on Job__c (after update) {
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.suspendJob)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch);
        System.debug('suspendJob : ' +Lock.suspendJob);
        return;
    }
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    
    // PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }
    System.debug('='+cls_IsRun.isSuspendJob);
    if(cls_IsRun.isSuspendJob==false){
        Job__c oldJob;
        cls_IsRun.setIsSuspendJob();
        // if there are multiple updates then return error - only works for one record.
        if(trigger.new.size() > 1){
            for(Job__c newJob : trigger.new){
                oldJob = trigger.oldMap.get(newJob.Id);
                //if the Suspend_Job__c  has been unchecked (this will be from workflow)
                if(!oldJob.Suspend_Job__c && newJob.Suspend_Job__c)
                    newJob.addError('Suspend Job functionality is not bulkified and can only be used for 1 Job update at a time.');
            }
        }else if(!trigger.new.isEmpty()){ // gjb 2010-03-01 - Added this as if the trigger is called because of an update to a child
                                      // object, trigger.new.get(0) will cause a Null Pointer
       
            Job__c newJob = trigger.new.get(0);
            oldJob = trigger.oldMap.get(newJob.Id);
            System.debug('## before call   #'+oldJob.Suspend_Job__c +'-'+newJob.Suspend_Job__c);
            if((oldJob.Suspend_Job__c == false) && newJob.Suspend_Job__c){
                
                // gjb 2010-03-03 - Now using a future method to suspend the job elements, to avoid DML row limits
                // when cancelling a job.
                //Boolean updateWorkItems = (oldJob.Cancel_Merchant_Orders__c == 'No' && newJob.Cancel_Merchant_Orders__c == 'Yes');
                Boolean updateWorkItems = newJob.Cancel_Merchant_Orders__c == 'Yes';
                UpdateJobElements.suspendJobElementsFuture(newjob.ID, updateWorkItems);
                
                //if Job is suspended then Corresponding diary entries need to be flushed out.
                JobBookingManager.suspendJob(oldJob);
                JobSharingCls.createJobSharing(new List<String>{oldJob.Id});
           
            }
        
            if(newJob.Status__c == 'Suspended' && newJob.Sub_Status__c == null){
                Job__c localJob = [select previous_resources__c, Cancel_Merchant_Orders__c, Suspend_Job__c, sub_status__c, suspension_Reason__c from job__c where id = :oldJob.Id];
                localJob.previous_resources__c = JobBookingManager.generateEmployeeDetails(newJob.ID);
                localJob.Sub_Status__c = localJob.Suspension_Reason__c;
                localJob.Suspension_Reason__c = 'Awaiting Advice';
                update localJob;
            }
        }
    }  
}