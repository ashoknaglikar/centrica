public class GetCalendersController{

public OFS_Quota_Data__c quotaData{get;set;} 
public boolean exeCheck;
public List<Employee__c> emplList;

    public GetCalendersController()
    {
    
        quotaData=new OFS_Quota_Data__c();
        emplList=[select id,Salesforce_User__c from Employee__c where id=:id.valueOf('a0Aw000002UVP1aEAH')];
        //emplList=[select id,Salesforce_User__c from Employee__c where Salesforce_User__c=:UserInfo.getUserId()];
        // Salesforce_User__c=:UserInfo.getUserId()
        system.debug('**emplList'+emplList);
    
    }

   public void validateDates(){
        if(quotaData.Work_Time_Start__c==null || quotaData.Work_Time_End__c==null ){
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Date values are mandatory'));
            exeCheck=false;
       }
       if(quotaData.Work_Time_Start__c!=null && quotaData.Work_Time_End__c!=null ){
       Integer monthsBetween = quotaData.Work_Time_Start__c.monthsBetween(quotaData.Work_Time_End__c);
           if(monthsBetween>6){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Date difference between two dates should not be more than 6 months'));
                exeCheck=false;
           
          }
      }
   }
   public void getShiftPattern()
   {
           validateDates();
            if(exeCheck!=false){
            system.debug('**Work_Time_Start__c'+quotaData.Work_Time_Start__c);
            if(quotaData.Work_Time_Start__c!=null && quotaData.Work_Time_End__c!=null){
            system.debug('**1');
            FetchCalendersBatch calBatch=new FetchCalendersBatch(quotaData.Work_Time_Start__c,quotaData.Work_Time_End__c);
            system.debug('**dd'+quotaData.Work_Time_Start__c+quotaData.Work_Time_End__c);
            ID batchprocessid = Database.executeBatch(calBatch,1);
            //system.debug('**batchprocessid '+batchprocessid);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'System is retrieveing the Shifts from OFS. An email will be sent once this process is complete.'));
      
            }
              
           }
   
   }
  public void getbucketClosure()
   {
    validateDates();
     if(exeCheck!=false){
      if(quotaData.Work_Time_Start__c!=null ){
            system.debug('**1');
            FetchBuckClosureBatch closBatch=new FetchBuckClosureBatch(quotaData.Work_Time_Start__c,quotaData.Work_Time_End__c);
           
            ID batchprocessid = Database.executeBatch(closBatch,1);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'System is retrieveing the bucket closure time from OFS. An email will be sent once this process is complete.'));
      }
    }
  }
  public void getInternalAct()
   {
    validateDates();
    if(exeCheck!=false){
      if(quotaData.Work_Time_Start__c!=null  ){
           if (quotaData.Work_Time_Start__c.daysbetween(quotaData.Work_Time_End__c) >=3) 
           {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Date difference between two dates should not be more than 2 days.'));
           }else
           {
            system.debug('**1');
             getCapacityRes.getInternalActivity(quotaData.Work_Time_Start__c,quotaData.Work_Time_End__c);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'HSA unavailabilites are being fetched. This might take a while. System will email you once the process has been complete.'));
           }
       }
      }
   }
   //This method is used to execute the batch class workzoneKeyBatch in order to automate work zones in OFS
   public void automateWorkZones()
   {
        workzoneKeyBatch workzoneObj = new workzoneKeyBatch();
        ID batchprocessid = Database.executeBatch(workzoneObj,99);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Salesforce Batch has been scheduled to update the Workzones in OFS. Please wait for an email.'));

   }
   //This method is used to get employee's bucket information from OFS
   public void getbucketMapping()
   {
          EmpBucketUpdateBatch empBucket = new EmpBucketUpdateBatch();
          ID batchprocessid = Database.executeBatch(empBucket,99); 
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Salesforce Batch has been scheduled to retrieve employee bucket information from OFS. Please wait for an email.'));
   }

   
}