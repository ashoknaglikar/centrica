/*
    rjd - 21-12-2009 - added error message if called from a bulk function.
*/

trigger BigMachinesQuoteInsertJobReconciliation on BigMachines_Quote__c (after insert, after update) {
    
    
   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
      if(cls_IsRun.dontFireTriggers || cls_IsRun.bigMachineSwitch || cls_IsRun.istrg_BigMachinesQuoteInsertJobReconciliation){
          return;
      }
    
    
    //
    //This trigger calls a class to reconcile a job with a quote. See class 'BigMachinesQuoteInsertJobReconciliation'
    //for further information on the logic performed. Note - Big Machines Quotes are inserted from Big Machines on an 
    //individual basis so this trigger will only work if one quote is inserted. It will do nothing for bulk load of quotes.
    //
    /*  Added to bypass the En-Masse Quote Billed checkbox is set to true from False */ 
    boolean process = true;
    Integer count = 0;
    BigMachines_Quote__c[] quoteOld = Trigger.old;
    for(BigMachines_Quote__c quote : Trigger.new){
        if(quote.Billed__c == true){
            process = false;
            break;
        }
        
    }     
    if(process){
        system.debug('BigMachinesQuoteInsertJobReconciliation - Trigger.new.size() is: '+Trigger.new.size());
        if(Trigger.new.size()==1){                          
            BigMachinesQuoteInsertJobReconciliation jobrec = new BigMachinesQuoteInsertJobReconciliation();
            jobrec.jobReconciliation(trigger.new[0]);       
        }else{
            
            for(BigMachines_Quote__c bmq : trigger.new){
                bmq.addError('Job Reconciliation is not bulkified. Concequently only 1 record can be upserted at any one time.');
            }
        } 
        if(trigger.isupdate && trigger.new[0].quote_reconciled__c == true)
        {
            AddNewSkill ObjNewSkill = new AddNewSkill();
            string oldrhcUserName=trigger.old[0].RHCUsername__c;
            string newrhcUserName=trigger.new[0].RHCUsername__c;
            if(oldrhcUserName!=newrhcUserName)
            {
                Job__c job = [select id, RHCUsername__c from Job__c where CHI_Lead__c=:(trigger.new[0].Opportunity__c )AND Type__c = 'Central Heating Installation' and Is_Downtime_Job__c = false and  Is_Remedial_Job__c = false and Split_Job__c = false limit 1];
                if (job != null)
                {
                    job.RHCUsername__c = newrhcUserName;
                    update job;
                }
                
            }
        
        }
    }  
}