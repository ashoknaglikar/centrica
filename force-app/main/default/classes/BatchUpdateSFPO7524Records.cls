global class BatchUpdateSFPO7524Records implements Database.Batchable<SObject>{
    
    List<String> batchList = new List<String>();
    List<String> orderList= new List<String>();

    public void UpdGoodReceiptItems(){
        BatchUpdateSFPO7524Records batchRecObj = new BatchUpdateSFPO7524Records();
        ID batchprocessid = Database.executeBatch(batchRecObj);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator('Select SFPO7524_Batch__r.Processed__c,SFPO7524_Batch__r.Salesforce_Processed__c,s.SFPO7524_Batch__c, s.P5_Purchase_Order__c,P5_Purchase_Order__r.P5_Good_Receipting_Status__c,s.Status__c From SFPO7524_ORDER_detail__c s where error_description__c = null and SFPO7524_Batch__r.Salesforce_Processed__c = false and Status__c = \'Integrated\' and P5_Purchase_Order__r.P5_Good_Receipting_Status__c = \'Confirmed Processing\' ');
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> sampleOrderList){
        if(sampleOrderList.size() > 0){
            for(Sobject sObj : sampleOrderList){
                SFPO7524_ORDER_detail__c IntOrderObj = (SFPO7524_ORDER_detail__c)sObj;
                orderList.add(IntOrderObj.P5_Purchase_Order__c);
                batchList.add(IntOrderObj.SFPO7524_Batch__c);
            }
            updateOrderRecords(orderList,batchList);  
        }
    }
    
    private void updateOrderRecords(List<String> ordrList,List<String> batchList){
        List<Order__c> orders = [select Synched_to_GR__c,id,Sync__c,P5_SAP_Status__c from order__c where id in: ordrList]; 
       
       
       for(Order__c ord : orders){
           ord.P5_Good_Receipting_Status__c = 'Integrated';
           ord.Synched_to_GR__c = true;
           if(!ord.Sync__c)
               ord.Sync__c = true; 
       }
               
       try{
           database.update(orders,false);
       }catch(Exception e){
            System.debug('#Exception  #'+e);
       }
       List<SFPO7524_Batch__c> batches = [select Salesforce_Processed__c,Processed__c,id from SFPO7524_Batch__c where id in :batchList];
        for(SFPO7524_Batch__c btch : batches)
            btch.Salesforce_Processed__c = true;
        try{
            database.update(batches,false);
       }catch(Exception e){
            System.debug('#Exception  #'+e);
       }
    }

    global void finish(Database.BatchableContext BC){
    	/*
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'amit.kumar12@centrica.com'});
        mail.setReplyTo('donotreply@centrica.com');
        mail.setSenderDisplayName('Batch Processing : San-SFPO7524Order');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR SFPO');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */
    }

}