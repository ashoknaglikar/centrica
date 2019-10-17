global class Quoteproductarchivingbatchclass implements Database.Batchable<sObject>{

 public static void createQParchivalBatch()
    {
        Quoteproductarchivingbatchclass objQParchival = new Quoteproductarchivingbatchclass();
        ID batchprocessid = Database.executeBatch(objQParchival,50);
    }


        global Database.QueryLocator start(Database.BatchableContext BC){
        
        Date startDate = date.valueOf(system.label.quote_product_archival_start_date);
        Date endDate = date.valueOf(system.label.quote_product_archival_end_date);
        Integer lim = Integer.valueOf(system.label.qp_archival_limit);
        
        return Database.getQueryLocator('SELECT Id FROM Quote_Product__c WHERE BigMachines_Quote__r.stage__c != \'Quote Finalised - Accepted\' AND BigMachines_Quote__r.Is_Primary__c = False AND BigMachines_Quote__r.CreatedDate >= :startDate AND BigMachines_Quote__r.CreatedDate < :endDate limit :lim');
        
        }
      
      
       global void execute(Database.BatchableContext BC, List<sObject>lstRecords){
           cls_IsRun.dontFireTriggers = True;
           database.delete(lstRecords);
       }
     
       global void finish(Database.BatchableContext BC){
       
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'APPS-SALESFORCE-COGSupport@centrica.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Quote product deletion update');
       mail.setPlainTextBody
       ('Quote product deletion process has been completed for today. '+' Status : '+a.Status);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
       }
    }