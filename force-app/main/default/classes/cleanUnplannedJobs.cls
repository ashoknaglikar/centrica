global class cleanUnplannedJobs implements database.batchable<sobject>,Database.Stateful{
    
    public static void createUnPlannedJobBatch()
    {
        cleanUnplannedJobs objDeleteJob = new cleanUnplannedJobs();
        ID batchprocessid = Database.executeBatch(objDeleteJob,50);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //stopUnplannedJobs => label is configurable. i
        //If we set the label to 90,it fetches all the records from 90 days(today().adddays(-90))
        Date cDate = Date.Today().addDays(-Integer.valueof(system.label.stopUnplannedJobs.split('-')[0]));
        date endDate = Date.Today().addDays(-Integer.valueof(system.label.stopUnplannedJobs.split('-')[1]));
        string query = 'select id,name,quote__c,status__c,createdDate from Job__c where quote__c=null and createddate>=:cDate and createdDate < : endDate and status__c=\'Pending\'';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC,  List<sObject> lstRecords)
    {
        Delete lstRecords;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
   
 }