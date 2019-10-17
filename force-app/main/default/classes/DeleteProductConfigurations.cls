/**
* Batch class which deletes product configurations and associated attributes to get more data storage space.
* Product Configurations will be deleted according to following criteria:
*     - createdDate of Product Configuration is within the time frame defined in Delete_Product_Configurations_Setting__c
*       custom setting with format: 'yyyy-MM-dd' and quote status IS 'Quote Finalised - Not Accepted';
*     - product basket is null.
*/
public with sharing class DeleteProductConfigurations implements Database.Batchable<sObject>{
    
    private DateTime startDate;
    private DateTime endDate;
    String query;
    string soldcrteria = ' AND cscfga__Product_Basket__r.CS_Quote_Status__c = \'Quote Finalised - Not Accepted\' ';
    string limitString = ' LIMIT 50000000';
    
    public DeleteProductConfigurations(){
        
        
        query = 'SELECT Id FROM cscfga__Product_Configuration__c WHERE CreatedDate <= :endDate AND CreatedDate >= :startDate ';
        
       
    }
    
    public DeleteProductConfigurations(String q){
        query = q;
    }
    
    public static void deleteStart(){
        DeleteProductConfigurations deleteProductConfigurations = new DeleteProductConfigurations();
        ID batchProcessId = Database.executeBatch(deleteProductConfigurations);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        endDate = DateTime.now().addDays(-180);
        startDate = endDate.addDays(-360);
        
        Delete_Product_Configurations_Setting__c sd = Delete_Product_Configurations_Setting__c.getInstance('Start Date');
        Delete_Product_Configurations_Setting__c ed = Delete_Product_Configurations_Setting__c.getInstance('End Date');
        Delete_Product_Configurations_Setting__c data = Delete_Product_Configurations_Setting__c.getInstance('Data');
        
        
        if(null != sd && null != ed){
            startDate = Datetime.valueOf(sd.Value__c + ' 00:00:00');
            endDate = Date.valueOf(ed.Value__c + ' 00:00:00');
        }
        
        if(!query.contains('LIMIT'))
        {
        if(data.Value__c != null && data.Value__c != 'All')
        {
            query += soldcrteria+limitString;
        }else
        {
            query += limitString;
        }
        }
        
        System.debug('***LOG*** start date: ' + startDate);
        System.debug('***LOG*** end date: ' + endDate);
        
        return Database.getQueryLocator(query);
        
    }
        
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        /*
        List<cscfga__Product_Configuration__c> pcs = (List<cscfga__Product_Configuration__c>) scope;
        List<Id> configurationsToDelete = new List<Id>();
        List<Id> basketToProcessIds = new List<Id>();
        Map<Id, List<Id>> prodBasketToProdConfigsMap = new Map<Id, List<Id>>();
        
        for(cscfga__Product_Configuration__c pc : pcs){
            // no product basket --> immediately add for deletion
            if(null == pc.cscfga__Product_Basket__c || pc.cscfga__Product_Basket__c == ''){
                configurationsToDelete.add(pc.Id);
            }else{
                basketToProcessIds.add(pc.Id);
                if(prodBasketToProdConfigsMap.contains(pc.cscfga__Product_Basket__c)){
                    prodBasketToProdConfigsMap.get(pc.cscfga__Product_Basket__c).add(pc.Id);
                }else{
                    prodBasketToProdConfigsMap.put(pc.cscfga__Product_Basket__c, new List<Id>{pc.Id});
                }
            }
        }
        
        List<cscfga__Product_Basket__c> pbs = [SELECT Id, Name, (SELECT Id, Name, Is_Primary__c, CreatedDate FROM BigMachines_Quotes__r) FROM cscfga__Product_Basket__c WHERE Id IN :basketToProcessIds];
        
        for(cscfga__Product_Basket__c pb : pbs){
            if(pb.BigMachines_Quotes__r.size() > 0){
                for(BigMachines_Quotes__c bmq : pb.BigMachines_Quotes__r){
                     if(bmq.Is_Primary__c && bmq.CreatedDate > startDate && bmq.CreatedDate < endDate){
                        configurationsToDelete.addAll(prodBasketToProdConfigsMap.get(pb.Id));
                        break;
                     }
                }
            }
        }
        
        delete configurationsToDelete;
        */
        
        System.debug('***LOG*** Delete scope start: ' + System.now());
        database.delete( scope, false);
        System.debug('***LOG*** Delete scope end: ' + System.now());
    }
    
    public void finish(Database.BatchableContext BC){
    
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    
        System.debug('***LOG*** The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
    
      /* AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String mailTo = a.CreatedBy.Email;
       Delete_Product_Configurations_Setting__c mailAddress = Delete_Product_Configurations_Setting__c.getInstance('Email Recipient');
       if(null != mailAddress ){
           mailTo = mailAddress.Value__c;
       }
       String[] toAddresses = new String[] {mailTo};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Deleting Product Configurations: ' + a.Status);
       mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
    

}