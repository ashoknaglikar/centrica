global class GenerateSAPOrderNumber implements Database.Batchable<sObject> {
  /*
  * CLASS - GenerateSAPOrderNumber
  * AUTHOR - COGNIZANT
  * PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process the generate the newly assigned SAP Order Number 
               
  */
    //the static method of the class. The method is called from the scheduled apex class. 
    public static void reconcile(Long iStartNumber,Long iEndNumber,Integer iIncrementNumber){
        GenerateSAPOrderNumber objCreateSAPNumber = new GenerateSAPOrderNumber();
        objCreateSAPNumber.iStartNumber=iStartNumber;
        System.debug(objCreateSAPNumber.iStartNumber);
        objCreateSAPNumber.iEndNumber=iEndNumber;
         System.debug(objCreateSAPNumber.iEndNumber);
        objCreateSAPNumber.iIncrementNumber=iIncrementNumber;
         System.debug(objCreateSAPNumber.iIncrementNumber);
        ID batchprocessid = Database.executeBatch(objCreateSAPNumber);
    }
    
    global Long iStartNumber;
    global Long iEndNumber;
    global Integer iIncrementNumber;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String sQuery='Select Id From User Limit 1000';
        return Database.getQueryLocator(sQuery);
    } 
  
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
    System.debug(iStartNumber);
    System.debug(iEndNumber);
    System.debug(iIncrementNumber);
    List<SAP_Number__c> sapNumberLst=new List<SAP_Number__c>{};
    SAP_Number__c objSAPNumber;
    for (Long iCount=iStartNumber;iCount<=iEndNumber;iCount=iCount+iIncrementNumber){
        objSAPNumber=new SAP_Number__c();
        objSAPNumber.Active__c=true;
        objSAPNumber.SAP_Number__c=String.valueOf(iCount);
        objSAPNumber.SAP_Num_Ord__c=iCount;
        sapNumberLst.add(objSAPNumber); 
    }
    Database.insert(sapNumberLst,false);
    }
    

    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job 
       // from Database.BatchableContext. 
       // Query the AsyncApexJob object to retrieve the current job's information.  
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'avishek.kundu@centrica.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Apex Sharing Recalculation ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}