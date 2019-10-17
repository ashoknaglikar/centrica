public class JobCompletionTriggerHelper {
    
    public static Commissioning_Report__c JobCompletionDataPopulate(Job__c j, string recordTypeName, string Subscript)
    {
        string homePhone = (j.Telephone_Number__c!=null && j.Telephone_Number__c.length()>20)? j.Telephone_Number__c.substring(0,20): j.Telephone_Number__c;
        string workPhone = (j.Telephone_Number_Work__c!=null && j.Telephone_Number_Work__c.length()>20)? j.Telephone_Number_Work__c.substring(0,20): j.Telephone_Number_Work__c;
        string telePhone = (j.Telephone_Number__c!=null && j.Telephone_Number__c.length()>15)? j.Telephone_Number__c.substring(0,15): j.Telephone_Number__c;
        String recordTypeId = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', recordTypeName);
        
        Commissioning_Report__c commissionreport = new Commissioning_Report__c();
        commissionreport.RecordtypeId=recordTypeId;
        commissionreport.Report_Name__c= recordTypeName;
        commissionreport.Client_Name__c = j.Customer_Name__c;
        commissionreport.Customer_Name__c = j.Customer_Name__c;
        commissionreport.Job_Number__c = j.Id;
        commissionreport.Phone_Number_Home__c  = homePhone;
        commissionreport.Phone_Number_Work__c  = workPhone;
        commissionreport.Address__c = j.Address__c;
        commissionreport.Property__c = j.Account_Id__c;
        commissionreport.Installation_Notes__c = j.Job_Notes__c;
        commissionreport.Job_Special_ID__c = j.Id +Subscript;
        commissionreport.District__c = j.District_Name__c;
        commissionreport.Job_Installation_Date__c = j.Installation_Date__c;
        commissionreport.InstallerName__c=j.InstallerAliasName__c;
        System.debug('Completion report: '+commissionreport );    
        return commissionreport;
        
    }
    
}