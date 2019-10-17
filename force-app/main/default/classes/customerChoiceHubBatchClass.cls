Global class customerChoiceHubBatchClass implements Database.Batchable <sObject> {
    
    public static void createsapBatch()
    {
        FinanceApplicationEnqBatch objAutoPrd = new FinanceApplicationEnqBatch();
        ID batchprocessid = Database.executeBatch(objAutoPrd,1);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<string> status = new list<string> {'error', 'In Queue'};
        return Database.getQueryLocator([select id,Bill_FirstName__c,CHI_Lead_Id__c,	Bill_LastName__c,Comms_Email_Field__c,Mobile_Phone__c,Home_Phone__c,
                 Bill_Country__c,Bill_City__c,Install_Postcode__c,Bill_Street__c,Post_Code_Sector__c,Marketing_Preferences__c from Opportunity where SAP_Cloud_Integration_Status__c in :status]);
    }
    global void execute(Database.BatchableContext BC, List<opportunity> scope){
        list<id> oppId = new list<Id>();
        for(opportunity o : scope)
        {
            oppId.add(o.id);
        }
        customerChoiceHubHTTPRequest.createCustomerOrUpdateMarketingPreferences(oppId);
    }
    global void finish(Database.BatchableContext BC){
    }
}