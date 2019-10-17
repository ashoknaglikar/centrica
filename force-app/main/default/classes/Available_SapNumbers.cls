global class Available_SapNumbers implements Database.Batchable<sObject>{

 public static void createSAPNoBatch()
    {
        Available_SapNumbers r = new Available_SapNumbers ();
        ID batchprocessid = Database.executeBatch(r);
    }
global Database.querylocator start(Database.BatchableContext BC){
    return Database.getQueryLocator('Select Id From SAP_Number__c Where Active__c= True limit 1');
    
}
            

global void execute(Database.BatchableContext BC, List<sObject> saps){
        //System.debug('Number of records taken for this batch:' + saps.size());
        Integer count = [Select count() From SAP_Number__c where Active__c= True limit 50000];
        if(count < 40000)
        {           
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
            String[] toAddresses1 = new String[] {'CHI-Salesforce.support@centrica.com','BGSAMS.Support@Centrica.com','Ashok.Nagaleekar@Centrica.com','phil.dennison@britishgas.co.uk'};                                 
            mail1.setToAddresses(toAddresses1);
            mail1.setSubject('SAP numbers are below 40000');
            mail1.setPlainTextBody('Number of Available SAPs :' + count);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });  
            System.debug('Number of Available SAPs below 40000:' + count);         
         } 
         else
         {
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
            String[] toAddresses1 = new String[] {'CHI-Salesforce.support@centrica.com','BGSAMS.Support@Centrica.com','Ashok.Nagaleekar@Centrica.com','phil.dennison@britishgas.co.uk'};                                
            mail1.setToAddresses(toAddresses1);
            mail1.setSubject('SAP numbers are above 40000');
            mail1.setPlainTextBody('Number of Available SAPs :' + count);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
            System.debug('Number of Available SAPs above 40000 :' + count);
          }  
    
}
global void finish(Database.BatchableContext BC){
}
}