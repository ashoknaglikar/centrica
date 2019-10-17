// Created by Prashant Kulkarni - 21 July 2010.
// This replaces the job suspend functionality with a button rather than a trigger.

public without sharing class SuspendJobController {
 
   public Job__c thisJob{get; set;}
   public ID jobId = null;
   public String errorMsg {get;set;}
   public boolean errorRender {get;set;}
   public static Savepoint  sp;
   // ++ variables created for PTS CR start
   public Boolean isPTSEnabled {get; set;} // variable decides whether redirect to PTS or not
   String newDeliveryId; // stores DeliveryId after cancelling slot in PTS
   public Boolean isMandatoryField {get; set;} // variable to show srror if mandatory fields are missing
   public Boolean showPTSPanel {get; set;} // variable decides to show PTS section on screen
   MessageConstants messageConst = new MessageConstants();
   // -- variables created for PTS CR end
   
   //code added for failed install on day
    public boolean showFailedInstallDetails{get;set;}    
    public Failed_Install__c failedInstall{get;set;}
   
   public SuspendJobController() {

    try {
             jobID = ApexPages.currentPage().getParameters().get('jobId');
        } catch(Exception ex) {
             errorRender = true;
             errorMsg = 'Invalid job ID.';
             setErrorMsg();
        }
        
    if(thisJob==null){
        // Updated SOQL for PTS CR
        thisJob = [select Job_Locked__c,Status__c,previous_resources__c, Cancel_Merchant_Orders__c, Suspend_Job__c, sub_status__c,
                  Delivery_Date__c , DeliveryID__c,Formatted_Delivery_Date__c, Installation_Date__c,
                          suspension_Reason__c,Suspension_Reason_List__c,Secondary_Job_Type_New__c,Is_Remedial_Job__c,(Select id from NWD_Detail__r) from job__c where id = :jobID];
        // ++ Added for PTS CR                
        if(thisJob.DeliveryID__c != null)
        {
            showPTSPanel = true;
        }
        // -- Added for PTS CR
    }
    
     //code added for failed install on day
    System.debug('###FieldSet###'+thisJob.Installation_Date__c);                  
    if(thisJob.Installation_Date__c!= NULL && thisJob.Installation_Date__c <= system.today()){
     System.debug('###FieldSet###');
     showFailedInstallDetails = true;   
    failedInstall = new Failed_Install__c(Job__c=thisJob.id,date_failed__c = System.today());
    }                  
    
  }
  
   //code added for failed install on day
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Failed_Install__c.FieldSets.FailedInstallDetails.getFields();
    }
 
    public PageReference suspendJob() {
    
    try{
     // ++ Added for PTS CR start
     Job__c job = new Job__c();
     job = [select id,DeliveryID__c, Delivery_Date__c from Job__c where id =: jobID]; // Query job record to fetch updated DeliverId by PTS
     newDeliveryId = job.DeliveryID__c;
     thisJob.DeliveryID__c = job.DeliveryID__c;
     if(thisJob.Suspension_Reason_List__c == null || thisJob.Suspension_Reason__c == null)
     {
        isMandatoryField = true;
     }
     if((job.Delivery_Date__c>= system.today() && newDeliveryId != null) && (thisJob.Cancel_Merchant_Orders__c == 'Yes') && (System.Label.PTS_Switch == 'On'))
     {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR,messageConst.ERR_PTS_SLOT_NOT_CANCELLED_IN_PTS);
        ApexPages.addMessage(msg);
        return null;
     }
     // -- Added for PTS CR end
     
     // Set the database savepoint so that 
     // in case of any exceptions entire transaction 
     // will be rolled back and exception will be shown on the VF page.
       sp = Database.setSavepoint();
    // suspending job / cancel job should clear the NWD_Entries from NWD Table
     
      if(thisJob.NWD_Detail__r.size()>0){
         delete thisJob.NWD_Detail__r;
        
      }
     
     // If job lock is in place then produce the error message.
      if(thisJob.Job_Locked__c=='Y'){
           throw new SuspendJobController.SuspendJobException('This job is currently locked.');
      }
      
     // If job is not planned yet then throw the error message.
    
      if(thisJob.Status__c == 'Suspended' || thisJob.Status__c == 'Cancelled'){
           throw new SuspendJobController.SuspendJobException('This job is either suspended or cancelled at the moment so you can not suspend it again.');
      }
      
    // If the job is already installed then we can not suspend.
    
      if(thisJob.Status__c == 'Completed' || thisJob.Status__c == 'Installed' || 
         thisJob.Status__c == 'Billed' || thisJob.Status__c == 'Installed - Awaiting Payment'){
           throw new SuspendJobController.SuspendJobException('This job is already installed so you can not suspend it now.');
      }
       // Suspend material orders if planner chooses to do so.
      Boolean updateWorkItems = (thisJob.Cancel_Merchant_Orders__c == 'Yes');
      // Generate previous resource details before we delete the diary entries.
      system.debug(thisJob.Is_Remedial_Job__c +thisJob.Secondary_Job_Type_New__c);
      
      //code added for failed install on day 
            if(showFailedInstallDetails == true && (failedInstall.Job__c==NULL || failedInstall.Date_Failed__c == NULL || failedInstall.Cause__c == NULL
               || failedInstall.Reason__c == NULL)){
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please enter all the details in failed install section');
                  ApexPages.addMessage(msg);
                  return null;

            }               
            try{
                if(showFailedInstallDetails==true && failedInstall!=NULL)
                  insert failedInstall;
            }catch(Exception e){
                  System.debug('####error In Failed Install###');
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
                  ApexPages.addMessage(msg);
                  return null;
            }   
      
      if(thisJob.Is_Remedial_Job__c  && thisJob.Secondary_Job_Type_New__c!= null && thisJob.Secondary_Job_Type_New__c.contains('Non Productive'))
      {
            
            thisJob.previous_resources__c = JobBookingManager.generateEmployeeDetails(thisJob.ID);
            JobSharingCls.createJobSharing(new List<String>{thisJob.Id});
            thisJob.Status__c = 'Suspended';
            thisJob.Sub_Status__c = thisJob.Suspension_Reason__c;
            thisJob.Suspension_Reason__c = null;
            thisJob.Suspend_Job__c=false;
            thisJob.Cancel_Merchant_Orders__c = '';
            update thisJob;
            List<Diary_Entry__c> delDe = [Select Id from Diary_Entry__c where Job__c = : thisJob.ID];
            delete delDe;
            UpdateJobElements.suspendJobElementsFuture(thisJob.ID, updateWorkItems);
      }else{

            // Set suspend job check box to true.
            thisJob.Suspend_Job__c=true;
           
            thisJob.previous_resources__c = JobBookingManager.generateEmployeeDetails(thisJob.ID);
            JobBookingManager.suspendJob(thisJob);
            // Now call the job sharing again to remove the resources from sharing table.
            System.debug(LoggingLevel.Info,'Create new sharing for job and job documents.');
            JobSharingCls.createJobSharing(new List<String>{thisJob.Id});
            update thisJob;
            thisJob = [select Status__c,previous_resources__c, Cancel_Merchant_Orders__c, Suspend_Job__c, sub_status__c, 
                              suspension_Reason__c,Suspension_Reason_List__c from job__c where id = :jobID];
            thisJob.Status__c = 'Suspended';
            thisJob.Sub_Status__c = thisJob.Suspension_Reason__c;
            thisJob.Suspension_Reason__c = null;
            thisJob.Suspend_Job__c=false;
            thisJob.Cancel_Merchant_Orders__c = '';
            System.debug(LoggingLevel.Info,'Updating the job after doing entire process of suspension.');
            update thisJob;
            // Calling the future method which exceutes in after some delay.
            UpdateJobElements.suspendJobElementsFuture(thisJob.ID, updateWorkItems);
            }
           }catch(Exception exc){
            
               Database.rollback(sp);
               errorRender = true;
               errorMsg = exc.getMessage();
               setErrorMsg();
               System.debug(LoggingLevel.Info,'Error occured : '+errorMsg);
               return null;
               
           }
        return new PageReference('/'+jobId);
    }

 public Id getJobId()
    {
        return jobId;
    } 

 public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }
 
 // Method sets variable whcih decides wheteher user is redirected to PTS screen or not
 public void redirectToPTS()
 {
    if(thisJob.Cancel_Merchant_Orders__c == 'Yes')
    {
        isPTSEnabled = true;
    }
    else
    {
        isPTSEnabled = false;
    }
    
 }
 
 // Throw customized exception instead of standard one.
 // This allows generic code to throw different error messages.
 public class SuspendJobException extends Exception {}
 
}