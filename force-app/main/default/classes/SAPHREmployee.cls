global class SAPHREmployee implements Database.Batchable<sObject> {

    global final String sGlobalBatchId;
    public static void ActDeact(String sBatchRecordId){
        SAPHREmployee objupdateEmployee = new SAPHREmployee (sBatchRecordId);
        ID batchprocessid = Database.executeBatch(objupdateEmployee);
    }
    global SAPHREmployee(String sBatchId) {
        sGlobalBatchId= sBatchId;  
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String sQuery='Select Pay_Number__c, First_Name__c, Last_Name__c,  Middle_Name__c,Error_Text__c From SAHRSF_Employee__c Where Processed__c=false And SAHRSF_Batch__c=\'' + sGlobalBatchId + '\'';
        return Database.getQueryLocator(sQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        List<Employee__c> employeeLst=new List<Employee__c>{};
        List<SAHRSF_Employee__c> SAPEmployeeLst=new List<SAHRSF_Employee__c>{};
        Employee__c objEmployee;
        for (sObject objSObject: lstRecords)
        {
            objEmployee=new Employee__c();
            SAHRSF_Employee__c objSAPEmployee=(SAHRSF_Employee__c)objSObject;
            objEmployee.First_Name__c=objSAPEmployee.First_Name__c;    
            objEmployee.Last_Name__c=objSAPEmployee.Last_Name__c;
            objEmployee.Middle_Name__c=objSAPEmployee.Middle_Name__c;
            objEmployee.Processed__c=true;
            objEmployee.Employee_Number__c=objSAPEmployee.Pay_Number__c;
            objEmployee.Pay_Number__c=objSAPEmployee.Pay_Number__c;
            
            objSAPEmployee.Processed__c=true;
            SAPEmployeeLst.add(objSAPEmployee);
            employeeLst.add(objEmployee);
        }
        Map<String,String> errorTextMap=new Map<String,String>{};
        if (employeeLst.size()>0)
        {
            Schema.SObjectField externalId = Employee__c.Fields.Employee_Number__c;
            List<Database.upsertResult> uResults=Database.upsert(employeeLst,externalId,false);
            Integer iCount=0;
            for(Database.upsertResult result:uResults) {
                if (!result.isSuccess()){
                    Database.Error err = result.getErrors()[0];
                    String sErrorText=err.getMessage();
                    errorTextMap.put(employeeLst[iCount].Pay_Number__c,sErrorText);
                }
                iCount++;
            }
        }
        for (SAHRSF_Employee__c objSAPEmployee1: SAPEmployeeLst) {
            if (errorTextMap.containsKey(objSAPEmployee1.Pay_Number__c)){
                objSAPEmployee1.Error_Text__c=errorTextMap.get(objSAPEmployee1.Pay_Number__c);
            }
        }
        if (SAPEmployeeLst.size()>0)
        {
            Database.upsert(SAPEmployeeLst,false);
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
        String[] toAddresses = new String[] {'avishek.kundu@centrica.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        String sPlainText;
        if (a.NumberOfErrors>0)
        {
            //Database.rollback(savePoint1);
            sPlainText='The batch Apex failed. The whole process has been reverted back.';
        } else {
            sPlainText='The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. ';
        }
        mail.setPlainTextBody(sPlainText);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        DateTime dtNow=System.now();
        dtNow=dtNow.addMinutes(05);
        String sDtNow=dtNow.format();
        String sDay=String.ValueOf(dtNow.day());
        String sMonth=String.ValueOf(dtNow.month());
        String sYear=String.ValueOf(dtNow.year());
        String sHour=String.ValueOf(dtNow.hour());
        String sMinute=String.ValueOf(dtNow.minute());
        String sSecond=String.ValueOf(dtNow.second());
        
        String sTriggerClass='0 ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        System.schedule('EmployeeUpdate'+sDtNow,sTriggerClass , new EmployeeUpdateSchedular ());
    }


}