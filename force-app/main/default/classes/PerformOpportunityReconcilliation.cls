/*
* CLASS - PerformOpportunityReconcilliation
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process reconcilliation data and update 
*           relevant opprtunity(CHI Lead) accordingly
*/
global class PerformOpportunityReconcilliation implements Database.Batchable<sObject>{
    /*
    *   Input - None
    *   Output - None
    *   Purpose - submits batch to the queue 
    */ 
    public static void reconcile(){
        PerformOpportunityReconcilliation objReconcileOppty = new PerformOpportunityReconcilliation();
        ID batchprocessid = Database.executeBatch(objReconcileOppty);
    }
    /*
    *   Input - Current Btch Context
    *   Output - Query Set
    *   Purpose - retrieves the query set to be processed by the current & future batches 
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Processed__c, Payment_Type__c,Deposit_Date__c, Transcash_Invoice_Number__c, Amount__c From Outstanding_Deposit__c where Processed__c=false');
    } 
    /*
    *   Input - current batch context and list of records to process
    *   Output - None
    *   Purpose - retrives the related opportunities whose reconcilliation data is fecthed form the 'Outstanding Deposits' object
    *               matches the Amount in the deposits object and that on the opportunity and updates the CHI Lead Amount Settled Field 
    */ 
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        Map<String,Outstanding_Deposit__c> bgsRefMap = new Map<String,Outstanding_Deposit__c>();
        for(sobject sObj : lstRecords){
            Outstanding_Deposit__c objDepositData = (Outstanding_Deposit__c)sObj;
            String strConcat = '8'+objDepositData.Transcash_Invoice_Number__c;
            bgsRefMap.put(strConcat,objDepositData);
        }
        if(bgsRefMap.size() > 0){
            List<Opportunity> oppList = [select id,isSystem__c,Settled_Date_NBU1__c,Amount_Settled__c,Payment_Reference_Number__c from opportunity where Payment_Reference_Number__c in :bgsRefMap.keySet()];
            if(oppList.size() > 0){
                for(Opportunity opp : oppList){
                    opp.Amount_Settled__c = (bgsRefMap.get(opp.Payment_Reference_Number__c)).Amount__c;
                    opp.Settled_Date_NBU1__c = (bgsRefMap.get(opp.Payment_Reference_Number__c)).Deposit_Date__c;
                    opp.isSystem__c=true;
                }
                try{
                    Database.update (oppList,false);
                }catch(DMLException e){
                    System.debug('@ EXCEPTION @ '+e.getMessage());
                } 
                for(Outstanding_Deposit__c depData : bgsRefMap.values())
                    depData.Processed__c = true;
                try{
                    update bgsRefMap.values();
                }catch(DMLException e){
                    System.debug('@ EXCEPTION @ '+e.getMessage());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job 
       // from Database.BatchableContext. 
       // Query the AsyncApexJob object to retrieve the current job's information.  
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Apex Sharing Recalculation ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}