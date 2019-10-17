/*
rjd - 2009-12-07

Trigger to cancel a job as part of suspend/cancel functionality.


*/
trigger Job_CancelJob on Job__c (after update) {
    
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.cancelJob)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch);
        System.debug('cancelJob : ' +Lock.cancelJob);
        return;
    }
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    
    // PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }
    
    Job__c[] oldJob = trigger.old;
    // if there are multiple updates then return error - only works for one record.
    if(!trigger.new.isEmpty()){ // gjb 2010-03-01 - Added this as if the trigger is called because of an update to a child
                                      // object, trigger.new.get(0) will cause a Null Pointer
        Map<String,Job__c> updateJobsMap = new Map<String,Job__c>();
        
        Integer cnt =0;
        for(Job__c job : trigger.new){
            if((!oldJob[cnt].Cancel_Job__c && job.Cancel_Job__c)){// removed the status check of cancelled
                updateJobsMap.put(job.id,job);
               
            }
        }
        if(updateJobsMap.size() > 0){
            UpdateJobElements.cancelJobElementsFuture(updateJobsMap.keySet());
            List<String> ordIds = new List<String>();
            List<Order__c> jobOrdrList = [select Job__c, id,Status__c, Quote__c From order__c where job__c in :updateJobsMap.keySet() and Status__c != 'Cancelled'];
            if(jobOrdrList.size() > 0){
                for(Order__c ord : jobOrdrList){
                    ord.Status__c = 'Cancelled';
                    ordIds.add(ord.Id);
                }
            }
            try{
                update jobOrdrList;
                UpdateJobElements.cancelOrderLinesFuture(ordIds);
            }catch(DMLException e){
                 System.debug('@ Exception cancelling Orders @ '+e);
            }

        }   
    }
}