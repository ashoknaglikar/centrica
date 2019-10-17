/*
Type Name: BatchUpdateSFPO7523Records
Author: Cognizant
Change Date: 26/05/2010
Reason: To populate SFPO7523(SFDC to SAP Purchasing and Finance interface) object through batch jobs.
*/

global class BatchUpdateSFPO7523Records implements Database.Batchable<sObject>{

    List<String> batchList = new List<String>();
    List<String> orderList= new List<String>();
    
     public void updateSAPBatch(){
        BatchUpdateSFPO7523Records objSAPOrder = new BatchUpdateSFPO7523Records();
        ID batchprocessid = Database.executeBatch(objSAPOrder);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator('Select s.Purchase_Order__c, P5_SFPO7523_Batch__c,Purchase_Order__r.P5_SAP_Status__c,s.P5_SFPO7523_Batch__r.Processed__c,P5_SFPO7523_Batch__r.Salesforce_Processed__c,s.status__c From SFPO7523_Order_Header__c s where error_description__c = null and P5_SFPO7523_Batch__r.Salesforce_Processed__c = false and status__c = \'Integrated\' and Purchase_Order__r.P5_SAP_Status__c = \'Confirmed Processing\' ');
    }
  
    global void execute(Database.BatchableContext BC, List<Sobject> sampleOrderList){
        if(sampleOrderList.size() > 0){
            for(Sobject sObj : sampleOrderList){
                SFPO7523_Order_Header__c IntOrderObj = (SFPO7523_Order_Header__c)sObj;
                orderList.add(IntOrderObj.Purchase_Order__c);
                batchList.add(IntOrderObj.P5_SFPO7523_Batch__c);
            }
            updateOrderRecords(orderList,batchList);  
        }
    }


    public void updateOrderRecords(List<String> ordrList,List<String> batchList){
     
       List<Order__c> orders = [select id,Sync__c,Synched_to_SAP__c,P5_SAP_Status__c from order__c where id in: ordrList]; 
       
       
       for(Order__c ord : orders){
           ord.Synched_to_SAP__c = true;
           ord.P5_SAP_Status__c = 'Integrated';
           if(!ord.Sync__c)
               ord.Sync__c = true;
       }
       try{
           database.update(orders,false);
       }catch(Exception e){
                   Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
                   String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                   mail1.setToAddresses(toAddresses);
                   mail1.setSubject('Exception ocurred in updating order SAP status to integrated');
                   mail1.setPlainTextBody('Exception ocurred in updating order SAP status to integrated: ' + e.getMessage());
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
       
            System.debug('#Exception  #'+e);
                }
       List<SFPO7523_Batch__c> batches = [select Processed__c,Salesforce_Processed__c,id from SFPO7523_Batch__c where id in :batchList];
        for(SFPO7523_Batch__c btch : batches)
            btch.Salesforce_Processed__c = true;
        try{
            database.update(batches,false);
       }catch(Exception e){
            System.debug('#Exception  #'+e);
       }
    }

global void finish(Database.BatchableContext bc){
    /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'amit.kumar12@centrica.com'});
        mail.setReplyTo('donotreply@centrica.com');
        mail.setSenderDisplayName('Batch Processing : San-SFPO7523Order');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR SFPO');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
}


}