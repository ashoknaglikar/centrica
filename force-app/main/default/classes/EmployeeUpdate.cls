global class EmployeeUpdate implements Database.Batchable<sObject> {

    public static void updateEmployee(){
        EmployeeUpdate objupdateEmployee = new EmployeeUpdate();
        ID batchprocessid = Database.executeBatch(objupdateEmployee);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String sQuery='Select Processed__c, Inactive__c,Id From Employee__c Where   Is_Contractor__c=False';
        return Database.getQueryLocator(sQuery);
    }
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        List<Employee__c> employeeLst=new List<Employee__c>{};

        for (sObject objSObject: lstRecords) {
            
            Employee__c objEmployee=(Employee__c)objSObject;
            if (objEmployee.Processed__c==true) {
                objEmployee.Inactive__c=false;
                objEmployee.Processed__c=false;
            } else if (objEmployee.Processed__c==false) {
                objEmployee.Inactive__c=true;
                objEmployee.Processed__c=false;
            }
            employeeLst.add(objEmployee);
        }
        
        if (employeeLst.size()>0) {
            Database.update(employeeLst,false);
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
        String sPlainText;
        sPlainText='The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. ';
        mail.setPlainTextBody(sPlainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}