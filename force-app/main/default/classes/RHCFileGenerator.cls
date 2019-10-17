/*
    Autor: Cognizant (29-03-2012)
    Description: This class was developed to cretae a dialy file containing Remote Heating Jobs list and post on RHC object . 
*/
global class RHCFileGenerator implements Database.Batchable<sObject>{
    public static void createRHCBatch()
    {
        RHCFileGenerator r = new RHCFileGenerator();
        ID batchprocessid = Database.executeBatch(r);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date createDate = date.valueOf(system.label.RCHRelease);  
        integer count = [Select count() From Job__c where (RHC_Status__c = 'Added' OR RHC_Status__c = 'TRUE') and (SentToAlertMe__c = null) and (RHCAlertMeStatus__c = 'Data' OR RHCAlertMeStatus__c = null) and CreatedDate >=:createDate and Status__c != 'Pending' and Status__c != 'Suspended' and Status__c != 'Cancelled'];
        if(count>0)
        {
            Utility_Object__c newUtil  = new Utility_Object__c(Status__c = 'Ready', RecordTypeId = '012200000005yaN');
            //Utility_Object__c newUtil  = new Utility_Object__c(Status__c = 'Ready', RecordTypeId = '012W00000004J5XIAU');
            insert newUtil;
        }
        //string query = 'Select Name,Installation_County__c,Install_Street__c,Install_Postcode__c,Install_City__c,Customer_Name__c,Quote__r.App_Assigned_To__c,Mechanical_Installer__c,CHI_Lead_Number_Text__c,Installation_Date__c, RHC_Status__c, RHC_Mobile__c, RHCUsername__c, Id, SentToAlertMe__c From Job__c where (RHC_Status__c = \'Added\' OR RHC_Status__c = \'TRUE\') and (SentToAlertMe__c = null) and (RHCAlertMeStatus__c = \'Data\' OR RHCAlertMeStatus__c = null) and CreatedDate >=:createDate and Status__c != \'Pending\' and Status__c != \'Suspended\' and Status__c != \'Cancelled\' order by Installation_Date__c' ;
        //string query = 'Select Name,Installation_County__c,Install_Street__c,Install_Postcode__c,Install_City__c,Customer_Name__c,Quote__r.App_Assigned_To__c,Mechanical_Installer__c,CHI_Lead_Number_Text__c,Installation_Date__c, RHC_Status__c, RHC_Mobile__c, RHCUsername__c, Id, SentToAlertMe__c From Job__c where id= \'a0nW0000000Q5bu\'';
        string query = 'Select Name,Installation_County__c,Install_Street__c,Install_Postcode__c,Install_City__c,Customer_Name__c,Quote__r.App_Assigned_To__c,Mechanical_Installer__c,CHI_Lead_Number_Text__c,Installation_Date__c, RHC_Status__c, RHC_Mobile__c, RHCUsername__c, Id, SentToAlertMe__c From Job__c where (RHC_Status__c = \'Added\' OR RHC_Status__c = \'TRUE\') and (SentToAlertMe__c = null) and (RHCAlertMeStatus__c = \'Data\' OR RHCAlertMeStatus__c = null) and CreatedDate >=:createDate and Status__c = \'Planned\' order by Installation_Date__c' ;
        return Database.getQueryLocator(query);
    }
    string ExcelHeader= 'Record Id , Job Number , CHI Lead Number , Installation Date , App Assigned To , Mechanical Installer , Primay Contact Name , Installation Address , Installation PostCode , RHC Email , RHC Mobile , UCRN Number\n';
    global void execute(Database.BatchableContext BC, List<sObject> jobs)
    {
        string excelbody = '';
        date day = system.today();
        Utility_Object__c newUtil = [Select Id, Name from Utility_Object__c where CreatedDate >= :day and RecordTypeId = '012200000005yaN' and Status__c = 'Ready' order by CreatedDate Desc limit 1];
        //Utility_Object__c newUtil = [Select Id, Name from Utility_Object__c where CreatedDate >= :day and RecordTypeId = '012W00000004J5XIAU' and Status__c = 'Ready' order by CreatedDate Desc limit 1];
        list<Job__c> joblist = new list<Job__c>();
        for(sObject sObj : jobs)
        {
            Job__c j = (Job__c)sObj;
            joblist.add(j);
        }
        excelbody = ExcelHeader;
        for(Job__c j: joblist)
        {
            if(j.RHCUsername__c != null)
            {
                excelbody += createIndividaulExcelLine(j);
                j.RHCAlertMeStatus__c = 'Sent';
                j.SentToAlertMe__c = newUtil.Name;
            }else
            {
                j.RHCAlertMeStatus__c = 'Data';
                j.SentToAlertMe__c = null;
            }
                 
        }
        blob textBlob = Blob.valueOf(excelbody);
        string fileName = 'RHC_File';
        Document d = new Document(); 
        d.Name = fileName;
        d.FolderId = system.label.RHCFolder;
        d.Body = textBlob;
        d.ContentType = 'text/plain';
        d.Type = 'csv';
        insert d;
        
        try{
            //code fix done by BGSAMS Support  as part of PRB00009436 - starts
            Lock.jobTriggerSwitch = true;
            update joblist;
            Lock.jobTriggerSwitch = false;
            //code fix done by BGSAMS Support  as part of PRB00009436 - ends
        }catch (Exception e)
        {
            system.debug('Exception  while Updating Jobs in RHC batch');
        }
    }
    
    string createIndividaulExcelLine(Job__c job)
    {
        string excelLine ;
        list<string> streetLst = job.Install_Street__c.split('\n');
        string street = '';
        for(string s :streetLst)
        {
            street += s.trim();
        }
        string d = job.RHC_Mobile__c;
        string address = (street!=null?street:'')+' '+(job.Install_City__c!=null?job.Install_City__c.replaceall('\n','  '):'')+' '+(job.Installation_County__c!=null ? job.Installation_County__c.replaceall('\n','  '):'')+' '+(job.Install_Postcode__c!=null?job.Install_Postcode__c.replaceall('\n','  '):'');
        excelLine = job.Id + ' , ' +job.Name+','+ job.CHI_Lead_Number_Text__c + ',' + job.Installation_Date__c +','+ job.Quote__r.App_Assigned_To__c +','+(job.Mechanical_Installer__c != null ? (job.Mechanical_Installer__c).replaceall(',','; '):'')+','+job.Customer_Name__c+ ','+address+','+job.Install_Postcode__c+','+job.RHCUsername__c+','+d+', \n';
        system.debug('Excel Line---->'+excelLine);
        return excelLine;
    }
    global void finish(Database.BatchableContext bc)
    {
         AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
          if(a.TotalJobItems == 0)
          {
            //CreateEmail.CretaeSendTextEmail(system.label.Dialler_Mails.split(','), 'No Contact details present on this day.', 'No Leads for Dialler');
          }else{
            date todayDate = system.today();
            list<Document> dList = [Select Name, Id, FolderId, Body From Document d where FolderId= :system.label.RHCFolder and CreatedDate >= :todayDate and name = 'RHC_File'];
            string finalText;
            for(Document d:dList)
            {
                if(finalText !=null)
                {
                    finalText += d.Body.tostring();
                }else
                {
                    finalText = d.Body.tostring();
                }
            }
            delete dlist;
            string todayTime = system.now().format();
            string fileName = 'RHC_File'+todayTime.substring(0,2)+todayTime.substring(3,5)+todayTime.substring(8,10)+'.csv';
            date day = system.today();
            Utility_Object__c newUtil = [select Id, Name from Utility_Object__c where CreatedDate >= :day order by CreatedDate Desc limit 1];
            
            Attachment attachment = new Attachment();
            attachment.Body = blob.valueof(finalText);
            attachment.Name = newUtil.Name+'.csv';
            attachment.ParentId = newUtil.Id;
            Database.insert(attachment);
          }
            
    }

}