/*
* CLASS - SmartMeterInstallReport 
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to act as controller for SmartMeterDiary page,
* to display jobs where smart meter installation is required.
*/
@istest
public with sharing class SmartMeterInstallReport {
/*  +++++++++++++ Commented to Improve the test class performance ++++++++++++++++++++++++
     
     
//////////////////////////////               Declaring class level variables - Starts           /////////////////////////////////////////////////////////////////////////////////////////
     public Job__c inputJob1 {get;set;}
     public Job__c inputJob2 {get;set;}
     public Date startDate{get;set;}
     public Date endDate{get;set;}
     public List<SmartMeterListViews> smartMeterTabsList{get;set;} 
     public Map<Integer, SmartMeterListViews> smartMeterTabsIndexValueMap{get;set;} 
     public Map<Integer, String> smartMeterIndexTabNameMap{get;set;}
     public Map<String, SmartMeterListViews> smartMeterTabNameValueMap{get;set;}
     public Integer totalNumberOfTabs{get;set;} 
     public Id district{get;set;} 
     public SmartMeterListViews ReportData{get;set;}
     public String smartMeterJobNotes1{get;set;}  
     public boolean displayTabs{get;set;}  
//////////////////////////////               Declaring class level variables  - Ends          /////////////////////////////////////////////////////////////////////////////////////////
     







//////////////////////////////       Getter Setter Methods for DIfferent Tabs Data  - Starts          /////////////////////////////////////////////////////////////////////////////////////////
     public SmartMeterListViews getLive_jobs(){return smartMeterTabsList[0];}
     public void setLive_jobs(SmartMeterListViews s){smartMeterTabsList[0]=s;}
     
     public SmartMeterListViews getSuspended_jobs(){return smartMeterTabsList[1];}
     public void setSuspended_jobs(SmartMeterListViews s){smartMeterTabsList[1]=s;}
     
     public SmartMeterListViews getCancelled_jobs(){return smartMeterTabsList[2];}
     public void setCancelled_jobs(SmartMeterListViews s){smartMeterTabsList[2]=s;}
     
     public SmartMeterListViews getInstall_date_changed(){return smartMeterTabsList[3];}
     public void setInstall_date_changed(SmartMeterListViews s){smartMeterTabsList[3]=s;}
        // codefix done as a part of problem recored-PRB00009676 starts
     //public SmartMeterListViews getCancelled_work_without_install_date(){return smartMeterTabsList[4];}
    // public void setCancelled_work_without_install_date(SmartMeterListViews s){smartMeterTabsList[4]=s;}
     
  
      //public SmartMeterListViews getPending_jobs_without_delivery_date(){return smartMeterTabsList[5];}
    // public void setPending_jobs_without_delivery_date(SmartMeterListViews s){smartMeterTabsList[5]=s;}
     // codefix done as a part of problem recored-PRB00009676 ends
     public SmartMeterListViews getAcknowledged_jobs_with_install_date(){return smartMeterTabsList[6];}
     public void setAcknowledged_jobs_with_install_date(SmartMeterListViews s){smartMeterTabsList[6]=s;}
//////////////////////////////        Getter Setter Methods for DIfferent Tabs Data  - Ends          /////////////////////////////////////////////////////////////////////////////////////////







     
////////////////////////////////// Declaring class empty constructor - Starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     public SmartMeterInstallReport(){
        
        inputJob1 = new Job__c();
        inputJob2 = new Job__c();
        startdate = null;
        enddate = null;
        district =null;
        this.setSmartMeterListViewAndMap();
        
     }
////////////////////////////////// Declaring class empty constructor - Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








//////////////////////////////// Declaring wrapper class - Starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     public class SmartMeterInstallDiaryDetails{
        
        public boolean isSelected{get;set;}
        public Job__c thisJob{get;set;}
        public String chiJobDeliveryDate{get;set;}
        public String priorsmartMeterInstallDate{get;set;}
        public String smartMeterInstallDate{get;set;}
        public String smartMeterJobNotes{get;set;}
        public String style{get;set;}
        
     }
//////////////////////////////// Declaring wrapper class - Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








//////////////////////////////// Method to set few class level variables - Starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      public void setSmartMeterListViewAndMap(){

        displayTabs = false;
        ReportData = new SmartMeterListViews();
        smartMeterTabsList = new List<SmartMeterListViews>();
        smartMeterTabsIndexValueMap = new Map<Integer,SmartMeterListViews>();
        smartMeterIndexTabNameMap = new Map<Integer,String>();
        smartMeterTabNameValueMap = new Map<String, SmartMeterListViews>();
        totalNumberOfTabs = 7;
        
        for(Integer i=1; i<=totalNumberOfTabs; i++){
            
            if(i == 1)
            smartMeterIndexTabNameMap.put(i,'Live Jobs');
            if(i == 2)
            smartMeterIndexTabNameMap.put(i,'Suspended Jobs');
            if(i == 3)
            smartMeterIndexTabNameMap.put(i,'Cancelled Jobs');
            if(i == 4)
            smartMeterIndexTabNameMap.put(i,'Install date changed');
             // codefix done as a part of problem recored-PRB00009676 starts
           // if(i == 5)
           // smartMeterIndexTabNameMap.put(i,'Suspended or Cancelled work without install date');
       
           // if(i == 6)
            //smartMeterIndexTabNameMap.put(i,'Pending jobs without delivery date');
            // codefix done as a part of problem recored-PRB00009676 ends
            if(i == 7)
            smartMeterIndexTabNameMap.put(i,'Acknowledged jobs with install date');
            
            smartMeterTabsList.add(new SmartMeterListViews(i,smartMeterIndexTabNameMap.get(i))); 
            smartMeterTabsIndexValueMap.put(i,smartMeterTabsList[i-1]);    
            smartMeterTabNameValueMap.put(smartMeterIndexTabNameMap.get(i),smartMeterTabsList[i-1]);    
                
        }
        
     }
//////////////////////////////// Method to set few class level variables - Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
     
     
     
     
     

     
//////////////////////////////// Method to fetch smart meter installation jobs..starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     public PageReference fetchSmartMeterJobList() {
        
         this.setSmartMeterListViewAndMap();
         
         List<Job__c> listAllSmartMeterJobs = null;
         startDate = inputJob1.Smart_Meter_Installation_Date__c;
         endDate = inputJob2.Smart_Meter_Installation_Date__c;
         district = inputJob1.District__c;
                  
         if(startDate != null && endDate != null){
            if(startDate > endDate){
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date should be before end date.'));
                return null;
            }else if(startDate.daysBetween(endDate) >= 30){
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can run diary for maximum duration of 30 days.'));
                return null;
            }
         }
         
         if(startDate != null && endDate != null && district == null){
           listAllSmartMeterJobs = [Select id, Name, Status__c, Sub_Status__c, Smart_meter_reference_number__c, Home_Phone__c, Region__c, District__r.Name, CHI_Lead__r.Smart_meter_reference_number__c, CHI_Lead__r.Id, Smart_meter_installation_notes__c, Smart_Meter_Installation_Date__c, Smart_meter_install_date_changed__c,
                                                                Smart_meter_installation_status__c, Smart_meter_installation_sub_status__c, CHI_Lead_Number_Text__c, Customer_Name__c, Reason_for_acknowledgement__c,
                                                                Delivery_Date__c, Install_Postcode__c, Best_Phone_Number__c, Decouple_Smart_Meter_Install_Date__c, S_M_Prior_Date__c, Is_Remedial_Job__c, Is_Downtime_Job__c, Split_Job__c,  isCancellation_Job__c from Job__c 
                                                                       where Smart_Meter_Installation_Date__c >= :startDate and 
                                                                                                Smart_Meter_Installation_Date__c <= :endDate and 
                                                                                         (Smart_Meter_Required_Flag__c = 'Yes') order by Smart_Meter_Installation_Date__c];
         }else if(startDate != null && endDate != null && district != null){
            listAllSmartMeterJobs = [Select id, Name, Status__c, Sub_Status__c, Smart_meter_reference_number__c, Home_Phone__c, Region__c, District__r.Name, CHI_Lead__r.Smart_meter_reference_number__c, CHI_Lead__r.Id, Smart_meter_installation_notes__c, Smart_Meter_Installation_Date__c, Smart_meter_install_date_changed__c,
                                                                Smart_meter_installation_status__c, Smart_meter_installation_sub_status__c, CHI_Lead_Number_Text__c, Customer_Name__c, Reason_for_acknowledgement__c,
                                                                Delivery_Date__c, Install_Postcode__c, Best_Phone_Number__c, Decouple_Smart_Meter_Install_Date__c, S_M_Prior_Date__c, Is_Remedial_Job__c, Is_Downtime_Job__c, Split_Job__c,  isCancellation_Job__c from Job__c 
                                                                       where Smart_Meter_Installation_Date__c >= :startDate and 
                                                                                                Smart_Meter_Installation_Date__c <= :endDate and 
                                                                                                District__r.id = :district and
                                                                                         (Smart_Meter_Required_Flag__c = 'Yes') order by Smart_Meter_Installation_Date__c];
         }else{
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please input valid data.'));
            return null;
         }
         
         populateSmartMeterJobList(listAllSmartMeterJobs);
         return null;
         
     }
//////////////////////////////// Method to fetch smart meter installation jobs..Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






//////////////////////////////// Method to populate smart meter installation diary..Starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public void populateSmartMeterJobList(List<Job__c> listAllSmartMeterJobs) {
                           
                  SmartMeterInstallDiaryDetails smInstallDiaryDetailsIndividual = null;
                  boolean noJobsWithinDates = false;
                  
                  for(Job__c job : listAllSmartMeterJobs){
                            if(job.Smart_meter_installation_status__c == null || job.Is_Remedial_Job__c || 
                               job.Is_Downtime_Job__c || job.Split_Job__c || job.isCancellation_Job__c)
                                continue;
                            smInstallDiaryDetailsIndividual = new SmartMeterInstallDiaryDetails();
                            smInstallDiaryDetailsIndividual.thisJob = job;
                            if(job.Smart_meter_installation_date__c != null)
                            smInstallDiaryDetailsIndividual.smartMeterInstallDate = job.Smart_meter_installation_date__c.format();
                            if(job.S_M_Prior_Date__c != null)
                            smInstallDiaryDetailsIndividual.priorsmartMeterInstallDate = job.S_M_Prior_Date__c.format();
                            smInstallDiaryDetailsIndividual.isSelected = false;
                            if(smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Acknowledged'))
                            smInstallDiaryDetailsIndividual.style = 'font=calibri;size=5;color: black;';
                            else if(smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged'))
                            smInstallDiaryDetailsIndividual.style = 'font=calibri;size=8;font-weight:bold;color: blue;';
                            smInstallDiaryDetailsIndividual.smartMeterJobNotes = job.Smart_meter_installation_notes__c;
                          
                            if(job.Smart_meter_installation_status__c.equalsIgnoreCase('Cancelled') &&
                              smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged')){
                              
                              smartMeterTabNameValueMap.get('Cancelled Jobs').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                              smartMeterTabNameValueMap.get('Cancelled Jobs').renderTab = true;
                              smartMeterTabNameValueMap.get('Cancelled Jobs').renderListViewItems = true;
                              continue;
                              
                            }
                            
                            if(job.Smart_meter_install_date_changed__c &&
                              smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged')){
                              
                              smartMeterTabNameValueMap.get('Install date changed').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                              smartMeterTabNameValueMap.get('Install date changed').renderTab = true;
                              smartMeterTabNameValueMap.get('Install date changed').renderListViewItems = true;
                              continue;
                              
                          }
                          
                          if(job.Smart_meter_installation_status__c.equalsIgnoreCase('Suspended') &&
                              smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged')){
                                
                              smartMeterTabNameValueMap.get('Suspended Jobs').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                              smartMeterTabNameValueMap.get('Suspended Jobs').renderTab = true;
                              smartMeterTabNameValueMap.get('Suspended Jobs').renderListViewItems = true;
                              continue;
                              
                            }
                            
                          if(smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Acknowledged')){
                                
                              smartMeterTabNameValueMap.get('Acknowledged jobs with install date').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                              smartMeterTabNameValueMap.get('Acknowledged jobs with install date').renderTab = true;
                              smartMeterTabNameValueMap.get('Acknowledged jobs with install date').renderListViewItems = true;
                              continue;
                              
                           }
                                          
                            smartMeterTabNameValueMap.get('Live Jobs').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                            smartMeterTabNameValueMap.get('Live Jobs').renderTab = true;
                            smartMeterTabNameValueMap.get('Live Jobs').renderListViewItems = true;
                            
                         }
                         
                         if(listAllSmartMeterJobs == null || listAllSmartMeterJobs.size() == 0){
                                
                                noJobsWithinDates = true;
                                
                         }
                         // codefix done as a part of problem recored-PRB00009676 starts
                         
                         listAllSmartMeterJobs = [Select id, Name, Status__c, Sub_Status__c, Smart_meter_reference_number__c, Home_Phone__c, Region__c, District__r.Name, CHI_Lead__r.Smart_meter_reference_number__c, CHI_Lead__r.Id, Smart_meter_installation_notes__c, Smart_Meter_Installation_Date__c, Smart_meter_install_date_changed__c,
                                                                                Smart_meter_installation_status__c, Smart_meter_installation_sub_status__c, CHI_Lead_Number_Text__c, Customer_Name__c, Reason_for_acknowledgement__c,
                                                                                Delivery_Date__c, Install_Postcode__c, Best_Phone_Number__c, Decouple_Smart_Meter_Install_Date__c,S_M_Prior_Date__c, Is_Remedial_Job__c, Is_Downtime_Job__c, Split_Job__c,  isCancellation_Job__c from Job__c 
                                                                                       where //(Smart_Meter_Required_Flag__c = 'Yes' and  Smart_Meter_Installation_Date__c = null and Smart_meter_installation_status__c = 'Pending') 
                                                                                              //or
                                                                                              (Smart_Meter_Required_Flag__c = 'Yes' and  Smart_Meter_Installation_Date__c = null and (Smart_meter_installation_status__c = 'Suspended' or Smart_meter_installation_status__c = 'Cancelled') and Smart_meter_installation_sub_status__c = 'Unacknowledged')
                                                                              order by Name];
                   
                        
                        //if((listAllSmartMeterJobs == null || listAllSmartMeterJobs.size() == 0) && noJobsWithinDates)
                        //{
                         //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no data to display.'));
                         //   return;
                       // }
                         
                       
                        // else{
                            displayTabs = true;
                         //}
                         
                         for(Job__c job : listAllSmartMeterJobs){
                            if(job.Smart_meter_installation_status__c == null || job.Is_Remedial_Job__c || 
                              job.Is_Downtime_Job__c || job.Split_Job__c || job.isCancellation_Job__c)
                              continue;
                            smInstallDiaryDetailsIndividual = new SmartMeterInstallDiaryDetails();
                            smInstallDiaryDetailsIndividual.thisJob = job;
                            smInstallDiaryDetailsIndividual.isSelected = false;
                            if(smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Acknowledged'))
                            smInstallDiaryDetailsIndividual.style = 'font=calibri;size=5;color: black;';
                            else if(smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged'))
                            smInstallDiaryDetailsIndividual.style = 'font=calibri;size=8;font-weight:bold;color: blue;';
                               // codefix done as a part of problem recored-PRB00009676 starts        
                            //if((job.Smart_meter_installation_status__c.equalsIgnoreCase('Suspended') ||
                             //  job.Smart_meter_installation_status__c.equalsIgnoreCase('Cancelled')) &&
                             // smInstallDiaryDetailsIndividual.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged')){
                             // smartMeterTabNameValueMap.get('Suspended or Cancelled work without install date').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                             // smartMeterTabNameValueMap.get('Suspended or Cancelled work without install date').renderTab = true;
                            //  smartMeterTabNameValueMap.get('Suspended or Cancelled work without install date').renderListViewItems = true;
                          //    continue;
                        //    }
                            
                         //   if(job.Smart_meter_installation_status__c.equalsIgnoreCase('Pending')){
                             // smartMeterTabNameValueMap.get('Pending jobs without delivery date').smartMeterJobs.add(smInstallDiaryDetailsIndividual);
                             // smartMeterTabNameValueMap.get('Pending jobs without delivery date').renderTab = true;
                             // smartMeterTabNameValueMap.get('Pending jobs without delivery date').renderListViewItems = true;
                            //  continue;
                           // }
                          // codefix done as a part of problem recored-PRB00009676 ends
                         } 
                
      }        
//////////////////////////////// Method to populate smart meter installation diary..Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

         




   
//////////////////////////////// Methods to redirect to update smart meter installation jobs screen..starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      public PageReference selectSmartMeterJobsForUpdateLive_jobs(){
           selectSmartMeterJobsForUpdate(getLive_jobs());
           return null;
      }
      public PageReference selectSmartMeterJobsForUpdateSuspended_jobs(){
           selectSmartMeterJobsForUpdate(getSuspended_jobs());
           return null;
      }
      public PageReference selectSmartMeterJobsForUpdateInstall_date_changed(){
           selectSmartMeterJobsForUpdate(getInstall_date_changed());
           return null;
      }
      public PageReference selectSmartMeterJobsForUpdateCancelled_jobs(){
           selectSmartMeterJobsForUpdate(getCancelled_jobs());
           return null;
      }
      // codefix done as a part of problem recored-PRB00009676 starts
     // public PageReference selectSmartMeterJobsForUpdateCancelled_work_without_install_date(){
          // selectSmartMeterJobsForUpdate(getCancelled_work_without_install_date());
          // return null;
     // }
      
     // public PageReference selectSmartMeterJobsForUpdatePending_jobs_without_delivery_date(){
         //  selectSmartMeterJobsForUpdate(getPending_jobs_without_delivery_date());
          // return null;
     // }
     // codefix done as a part of problem recored-PRB00009676 ends
      public PageReference selectSmartMeterJobsForUpdateAcknowledged_jobs_with_install_date(){
           selectSmartMeterJobsForUpdate(getAcknowledged_jobs_with_install_date());
           return null;
      }
      public void selectSmartMeterJobsForUpdate(SmartMeterListViews s){
          s.jobsToUpdate = new List<SmartMeterInstallDiaryDetails>();
          s.renderUpdateSection = false;
              for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobs){
              if(sm.isSelected){
                 s.jobsToUpdate.add(sm);
                 s.renderUpdateSection = true;
              }
              }
      }
//////////////////////////////// Methods to redirect to update smart meter installation jobs screen..Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  
  
  
  
  
  
//////////////////////////////// Methods to save updates in smart meter installation jobs & return to report..starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      public PageReference saveChangesGoBackLive_jobs(){
           saveChangesGoBack(getLive_jobs());
           return null;
      }
      public PageReference saveChangesGoBackSuspended_jobs(){
           saveChangesGoBack(getSuspended_jobs());
           return null;
      }
      public PageReference saveChangesGoBackInstall_date_changed(){
           saveChangesGoBack(getInstall_date_changed());
           return null;
      }
      public PageReference saveChangesGoBackCancelled_jobs(){
           saveChangesGoBack(getCancelled_jobs());
           return null;
      }
      // codefix done as a part of problem recored-PRB00009676 starts
      //public PageReference saveChangesGoBackCancelled_work_without_install_date(){
      //     saveChangesGoBack(getCancelled_work_without_install_date());
     //     return null;
     // }
      
     // public PageReference saveChangesGoBackPending_jobs_without_delivery_date(){
        //   saveChangesGoBack(getPending_jobs_without_delivery_date());
        //   return null;
    //  }
    // codefix done as a part of problem recored-PRB00009676 ends
      public PageReference saveChangesGoBackAcknowledged_jobs_with_install_date(){
           saveChangesGoBack(getAcknowledged_jobs_with_install_date());
           return null;
      }
      public void saveChangesGoBack(SmartMeterListViews s){
        List<Job__c> tempJobList = new List<Job__c>();
        for(SmartMeterInstallDiaryDetails sm : s.jobsToUpdate){
                sm.thisJob.Smart_meter_installation_notes__c = sm.smartMeterJobNotes;
                tempJobList.add(sm.thisJob);
        }
        try{
                        Database.update(tempJobList);
                }catch(Exception excp){
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
            ApexPages.addMessage(msg);
            return;
         }
        s.renderUpdateSection = false;
        s.jobsToUpdate = new List<SmartMeterInstallDiaryDetails>();
      }
//////////////////////////////// Methods to save updates in smart meter installation jobs & return to report..Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








//////////////////////////////// Methods to save updates in smart meter installation jobs..starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      public PageReference saveChangesLive_jobs(){
           saveChanges(getLive_jobs());
           return null;
      }
      public PageReference saveChangesSuspended_jobs(){
           saveChanges(getSuspended_jobs());
           return null;
      }
      public PageReference saveChangesInstall_date_changed(){
           saveChanges(getInstall_date_changed());
           return null;
      }
      public PageReference saveChangesCancelled_jobs(){
           saveChanges(getCancelled_jobs());
           return null;
      }
       // codefix done as a part of problem recored-PRB00009676 starts
     // public PageReference saveChangesCancelled_work_without_install_date(){
       //    saveChanges(getCancelled_work_without_install_date());
       //    return null;
     // }
      // codefix done as a part of problem recored-PRB00009676 starts
    //  public PageReference saveChangesPending_jobs_without_delivery_date(){
        //   saveChanges(getPending_jobs_without_delivery_date());
        //   return null;
    //  }
    // codefix done as a part of problem recored-PRB00009676 ends
      public PageReference saveChangesAcknowledged_jobs_with_install_date(){
           saveChanges(getAcknowledged_jobs_with_install_date());
           return null;
      }
      public void saveChanges(SmartMeterListViews s){
        List<Job__c> tempJobList = new List<Job__c>();
        for(SmartMeterInstallDiaryDetails sm : s.jobsToUpdate){
                sm.thisJob.Smart_meter_installation_notes__c = sm.smartMeterJobNotes;
                tempJobList.add(sm.thisJob);
        }
            try{
                        Database.update(tempJobList);
                }catch(Exception excp){
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
            ApexPages.addMessage(msg);
            return;
         }
      }
//////////////////////////////// Methods to save updates in smart meter installation jobs..Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   
   
   
   
   
   
   
//////////////////////////////// Methods to clear smart meter installation jobs selection & return.....starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       public PageReference extractSelectedLive_jobs(){
           extractSelected(getLive_jobs());
           return Page.SmartMeterJobsExtract;
        }
        public PageReference extractSelectedSuspended_jobs(){
            extractSelected(getSuspended_jobs());
            return Page.SmartMeterJobsExtract;
        }
        public PageReference extractSelectedInstall_date_changed(){
            extractSelected(getInstall_date_changed());
            return Page.SmartMeterJobsExtract;
        }
        public PageReference extractSelectedCancelled_jobs(){
            extractSelected(getCancelled_jobs());
            return Page.SmartMeterJobsExtract;
        }
           // codefix done as a part of problem recored-PRB00009676 starts
      //  public PageReference extractSelectedCancelled_work_without_install_date(){
        //    extractSelected(getCancelled_work_without_install_date());
       //     return Page.SmartMeterJobsExtract;
      //  }
     
        //public PageReference extractSelectedPending_jobs_without_delivery_date(){
        //    extractSelected(getPending_jobs_without_delivery_date());
        //    return Page.SmartMeterJobsExtract;
       // }
       // codefix done as a part of problem recored-PRB00009676 ends
        public PageReference extractSelectedAcknowledged_jobs_with_install_date(){
            extractSelected(getAcknowledged_jobs_with_install_date());
            return Page.SmartMeterJobsExtract;
        }
        public void extractSelected(SmartMeterListViews s){
            List<Job__c> jobsToUpdate = new List<Job__c>();
            for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobs){
                if(sm.isSelected){
                     sm.isSelected = false;
                     jobsToUpdate.add(sm.thisJob);
                }
             }
            ReportData.ReportData = SmartMeterHelper.extratctXLS(jobsToUpdate);
        }
//////////////////////////////// Methods to clear smart meter installation jobs selection & return.....Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    
    
    
    
    
    
//////////////////////////////// Methods to clear smart meter installation jobs selection & return.....starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public PageReference acknowledgeSelectedLive_jobs(){
            acknowledgeSelected(getLive_jobs());
            return null;
        }
        public PageReference acknowledgeSelectedSuspended_jobs(){
            acknowledgeSelected(getSuspended_jobs());
            return null;
        }
        public PageReference acknowledgeSelectedInstall_date_changed(){
            acknowledgeSelected(getInstall_date_changed());
            return null;
        }
        public PageReference acknowledgeSelectedCancelled_jobs(){
            acknowledgeSelected(getCancelled_jobs());
            return null;
        }
        // codefix done as a part of problem recored-PRB00009676 starts
      //  public PageReference acknowledgeSelectedCancelled_work_without_install_date(){
          //  acknowledgeSelected(getCancelled_work_without_install_date());
        //    return null;
      //  }
        
        //public PageReference acknowledgeSelectedPending_jobs_without_delivery_date(){
         //   acknowledgeSelected(getPending_jobs_without_delivery_date());
         //   return null;
        //}
        // codefix done as a part of problem recored-PRB00009676 ends
        private void acknowledgeSelected(SmartMeterListViews s){
        
            List<Job__c> jobsToUpdate = new List<Job__c>();
            for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobs){
                if(sm.isSelected){
                     sm.isSelected = false;
                     sm.thisJob.Smart_meter_install_date_changed__c = false;
                     sm.thisJob.Smart_meter_installation_sub_status__c = 'Acknowledged';
                     sm.thisJob.Reason_for_acknowledgement__c = '';
                     jobsToUpdate.add(sm.thisJob);
                     sm.style = 'font=calibri;size=5;';
                }
             }
             if(jobsToUpdate.size()>0){
                if(s.smartMeterJobsBackUp.size() == 0)
                s.smartMeterJobsBackUp = s.smartMeterJobs;
                s.selectAll = false;
                s.selectAllUnackAndSort = false;
                for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobsBackUp)
                    sm.isSelected = false;
                    s.smartMeterJobs = s.smartMeterJobsBackUp;
                    s.smartMeterJobsBackUp = new List<SmartMeterInstallDiaryDetails>();
                Database.update(jobsToUpdate);
             }
        
        }
//////////////////////////////// Methods to clear smart meter installation jobs selection & return.....starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////









//////////////////////////////// Methods to select all smart meter installation jobs.....starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public PageReference selectAllLive_jobs(){
            selectAll(getLive_jobs());
            return null;
        }
        public PageReference selectAllSuspended_jobs(){
            selectAll(getSuspended_jobs());
            return null;
        }
        public PageReference selectAllInstall_date_changed(){
            selectAll(getInstall_date_changed());
            return null;
        }
        public PageReference selectAllCancelled_jobs(){
            selectAll(getCancelled_jobs());
            return null;
        }
          // codefix done as a part of problem recored-PRB00009676 starts
        //public PageReference selectAllCancelled_work_without_install_date(){
        //    selectAll(getCancelled_work_without_install_date());
       //     return null;
       // }
      
      //  public PageReference selectAllPending_jobs_without_delivery_date(){
        //    selectAll(getPending_jobs_without_delivery_date());
        //    return null;
       // }
       // codefix done as a part of problem recored-PRB00009676 ends
        public PageReference selectAllAcknowledged_jobs_with_install_date(){
            selectAll(getAcknowledged_jobs_with_install_date());
            return null;
        }
        public void selectAll(SmartMeterListViews s){ 
            for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobs)
               sm.isSelected = s.selectAll;
        }
//////////////////////////////// Methods to select all smart meter installation jobs.....Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








//////////////////////////////// Methods to select all unacknowledged smart meter installation jobs & sort.....starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public PageReference selectAllUnackAndSortLive_jobs(){
            selectAllUnackAndSort(getLive_jobs());
            return null;
        }
        public PageReference selectAllUnackAndSortSuspended_jobs(){
            selectAllUnackAndSort(getSuspended_jobs());
            return null;
        }
        public PageReference selectAllUnackAndSortInstall_date_changed(){
            selectAllUnackAndSort(getInstall_date_changed());
            return null;
        }
        public PageReference selectAllUnackAndSortCancelled_jobs(){
            selectAllUnackAndSort(getCancelled_jobs());
            return null;
        }
        // codefix done as a part of problem recored-PRB00009676 starts
       // public PageReference selectAllUnackAndSortCancelled_work_without_install_date(){
       //     selectAllUnackAndSort(getCancelled_work_without_install_date());
      //      return null;
      //  }
        
       // public PageReference selectAllUnackAndSortPending_jobs_without_delivery_date(){
          //  selectAllUnackAndSort(getPending_jobs_without_delivery_date());
          //  return null;
       // }
       // codefix done as a part of problem recored-PRB00009676 ends
        public void selectAllUnackAndSort(SmartMeterListViews s){
          List<SmartMeterInstallDiaryDetails> smListToSortUnack = new List<SmartMeterInstallDiaryDetails>();
          List<SmartMeterInstallDiaryDetails> smListToSortAck = new List<SmartMeterInstallDiaryDetails>();
          if(s.selectAllUnackAndSort){
             s.smartMeterJobsBackUp = s.smartMeterJobs;
             for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobs){
                if(sm.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Unacknowledged')){
                    sm.isSelected = s.selectAllUnackAndSort;
                    smListToSortUnack.add(sm);
                }else if(sm.thisJob.Smart_meter_installation_sub_status__c.equalsIgnoreCase('Acknowledged')){
                    smListToSortAck.add(sm);
                }
             }
             s.smartMeterJobs = new List<SmartMeterInstallDiaryDetails>();
             s.smartMeterJobs.addAll(smListToSortUnack);
             s.smartMeterJobs.addAll(smListToSortAck);
          }else{
             for(SmartMeterInstallDiaryDetails sm : s.smartMeterJobsBackUp)
             sm.isSelected = false;
             s.smartMeterJobs = s.smartMeterJobsBackUp;
             s.smartMeterJobsBackUp = new List<SmartMeterInstallDiaryDetails>();
          }
        }
//////////////////////////////// Methods to select all unacknowledged smart meter installation jobs & sort.....Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 +++++++++++++ Commented to Improve the test class performance ++++++++++++++++++++++++
 */

}