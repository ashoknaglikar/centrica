/*
* CLASS - DisplayReplanJobsController 
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to act as controller class for DisplayReplanJobs page.  
*           This page is used for displaying all the jobs which needs replanning as part of creation of 
*           unavailability, which overlaps one or more job bookings.
*           These jobs are displayed per district. 
*           Once we replan these jobs, these are autometically taken off this visualforce report.
*/  
public with sharing class DisplayReplanJobsController {
        
  public List<Job__c> jobList{get;set;}
  public boolean renderJobList{get;set;}
  public boolean renderDisplayMessage{get;set;}
  public String areaId;
  public String regionID;
  public String thisValue{get;set;}
         
  public DisplayReplanJobsController(){
                jobList = new List<Job__c>();
                areaId = '';
                regionId = '';
        renderJobList = false;
                renderDisplayMessage = false;
         }
        
  public String getAreaId(){
         return(areaId);
     } 
     
  public String getRegionId(){
         return(regionId);
     } 
     
  public void setAreaId(String areaIdValue) {
        areaId = areaIdValue;
     }
     
  public void setRegionId(String regionIdValue) {
        regionId = regionIdValue;
     }     
     
        
  public List<District__c> Districts {get;set;}
  public List<Region__c> Regions {get;set;}
         
  public List<SelectOption> getAreaItems() {
            List<SelectOption> options = new List<SelectOption>();
            if(Districts == null)loadDistricts();
              for (Integer i = 0; i < Districts.size(); i++)
                {                             
                   options.add(new SelectOption(Districts[i].Id,Districts[i].Name));
                }   
            return options;
      }
      
  public List<SelectOption> getRegionItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','Select region'));
            if(Regions == null)loadRegions();
              for (Integer i = 0; i < Regions.size(); i++)          
                {                             
                   options.add(new SelectOption(Regions[i].Id,Regions[i].Name));
                }   
           
            return options;
      }      
      
        
  public void loadDistricts() {
        Districts = [Select d.Name, d.Id From District__c d where d.Type__c = 'Installation' order by d.Name];
     }
     
  public void loadRegions() {
        Regions = [Select reg.Name, reg.Id From Region__c reg where reg.Type__c = 'Installation' order by reg.Name];
     }
     
  public void fetchJobList(){
            jobList = new List<Job__c>();
            if(RegionId!=null){
                system.debug('IN REGION ID-->'+RegionId);
                jobList = [Select Id, Name, District__c, CHI_Lead__c, CHI_Lead__r.AccountId, Needs_Re_Planing__c,Previous_End_Time__c,Previous_Start_Time__c from Job__c where  District__r.Region__r.Id = :regionId and Needs_Re_Planing__c = true];
            }else if(AreaId != null)
            {     
                jobList = [Select Id, Name, District__c, CHI_Lead__c, CHI_Lead__r.AccountId, Needs_Re_Planing__c,Previous_End_Time__c,Previous_Start_Time__c from Job__c where District__r.Id = :areaId and Needs_Re_Planing__c = true];
                 system.debug('IN DISTRCT ID-->'+AreaId );
            }else
            return;
                
                if(jobList.size()>0){
                        renderJobList = true;
                        renderDisplayMessage = false;
                }else{
                        renderDisplayMessage = true;
                        renderJobList = false;
                }
        }
 }