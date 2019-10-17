global class BatchDeleteSFPO7541ErrRecords implements Database.Batchable<SObject>{
    public void deleteErrorData(){
        BatchDeleteSFPO7541ErrRecords batchRecObj = new BatchDeleteSFPO7541ErrRecords();
        ID batchprocessid = Database.executeBatch(batchRecObj);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator('Select Id From EDSF7541_ACKMNT__c where EDSF7541_Header__r.Processed__c=true and Error_Description__c != null');
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> lstOrderList){
        if(lstOrderList.size() > 0){
            try{
                delete lstOrderList;
            }catch(Exception e){
                System.debug('Exception :  '+e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}