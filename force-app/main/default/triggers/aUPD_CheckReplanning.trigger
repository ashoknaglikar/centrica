/*
* The purpose of this trigger is to update the delivery date hnaged flag on order due to
* change in delivery date on a job.As formula updates doesn't fire WF rules this trigger will update 
* the neccessary flag in order
*/

/* And also to maintain Job Skill history object whenever the skill of the job and corresponding hours are changed */


trigger aUPD_CheckReplanning on Job__c (after update) {
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.aUPDCheckReplanning)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch); 
        System.debug('aUPDCheckReplanning : ' +Lock.aUPDCheckReplanning);
        return;
    }
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    //PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg) 
    {
        return;
    }

    List<String> jobIds = new List<String>();
    List<Order__c> orderList = new List<Order__c>();
    Integer i=0;
    Job__c[] oldJOb = Trigger.old;
    Date priordeliverydate;
    String priordeliveryslot;
    for(Job__c job : Trigger.new){
        System.debug('@ oldJob[i].Delivery_date__c @'+oldJob[i].Delivery_date__c);
        System.debug('@ job.Delivery_date__c @'+job.Delivery_date__c);
        if((oldJob[i].Delivery_date__c != null && job.Delivery_date__c != null && oldJob[i].Delivery_date__c != job.Delivery_date__c) ||
           (oldJob[i].Delivery_Slot__c != null && job.Delivery_Slot__c != null && oldJob[i].Delivery_Slot__c != job.Delivery_Slot__c)){
            jobIds.add(job.id);
            priordeliverydate= oldJob[i].Delivery_Date__c;
            priordeliveryslot= oldJob[i].Delivery_Slot__c;
        }
        i++;
    }
    if(jobIds.size() >0){
        orderList = [select Delivery_date_Changed__c,Prior_Delivery_date__c,Prior_Delivery_Slot__c,id from order__c where job__c in :jobIds and Type__c = 'Material'];
        if(orderList.size() > 0){
            for(Order__c order : orderList){
                order.Delivery_date_Changed__c = true;
                order.Prior_Delivery_date__c = priordeliverydate;
                order.Prior_Delivery_Slot__c = priordeliveryslot;
            }
            try{
                System.debug('-- enterd -- '+orderList);
                update orderList;
            }catch(Exception e){
                System.debug('Exception : '+e.getMessage());
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        if(!Lock.hasAlreadyDone()){
            AddNewSkill obj = new AddNewSkill();
            List<Job_Skill_History__c> jsh = obj.setJobSkillHistory(trigger.oldMap,trigger.newMap);
            try{
                insert jsh;
            }
            catch(Exception e){
                System.debug('Exception : '+e.getMessage());
            }
            Lock.setAlreadyDone();            
        }        
    }
}