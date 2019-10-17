/*
*
*  CLASS - CreateInstallationInspectionDocument
*  AUTHOR - 30 Aug 2011, Cognizant
*  PURPOSE - To create installation inspection document for DHM survey.
* 
*/
global without sharing class CreateInstallationInspectionDocument {

   webservice static String createInstallationInspecDoc(String jobId){
   	
   	  Job__c job = [Select j.Id, 
   	                       j.Telephone_Number__c, 
   	                       j.Job_Notes__c, 
   	                       j.District_Name__c, 
   	                       j.District__r.Region__r.Name, 
   	                       j.Customer_Name__c, 
   	                       j.CHI_Lead_Name__c, 
   	                       j.Address__c, 
   	                       j.Account__c, 
   	                       j.Status__c, 
   	                       j.Installation_Date__c,
   	                       j.InstallerAliasName__c, 
   	                       j.InstallerName__c, 
   	                       j.CHI_Lead__r.AccountId From Job__c j where Id = :jobId limit 1];
   	                       
   	  Installation_Inspection__c ic = new Installation_Inspection__c();
   	  
   	  if(job != null){
   	  	
   	  Commissioning_Report__c jobComplDoc = [Select Id, 
   	                                                Date__c, 
   	                                                Have_You_Worked_On_The_Gas__c,
   	                                                InstallerName__c,
   	                                                Installer_For_Job_Completion__c, 
   	                                                Gas_Council_Number__c, 
   	                                                existing_boiler_working__c from Commissioning_Report__c where Job_Number__c = :job.Id and RecordType.Name = 'Gas Installation Works' limit 1]; 	
   	  	
   	  	ic.Job_Number__c = job.Id;
   	  	ic.CHI_Lead__c = job.CHI_Lead_Name__c;
   	  	ic.Customer_Name__c = job.Customer_Name__c;
   	  	ic.Address__c = job.Address__c;
   	  	ic.District__c = job.District_Name__c;
   	  	ic.Region__c = job.District__r.Region__r.Name;
   	  	ic.Home_Phone__c = job.Telephone_Number__c;
   	  	ic.Job_Notes_c__c = job.Job_Notes__c;
   	  	ic.Property__c = job.CHI_Lead__r.AccountId;
   	  	ic.Job_Status__c = job.Status__c;
   	  	ic.Job_Installation_Date__c = job.Installation_Date__c;
   	  	
   	  	ic.Installer_Name__c = jobComplDoc.InstallerName__c;
   	  	ic.Installer_For_Job_Completion__c = jobComplDoc.Installer_For_Job_Completion__c;
   	  	ic.Date__c =jobComplDoc.Date__c;
   	  	ic.Gas_Council_Number_of_removed_boiler__c = jobComplDoc.Gas_Council_Number__c;
   	  	ic.Was_the_boiler_removed_working__c = jobComplDoc.existing_boiler_working__c;
   	  	ic.Have_You_Worked_on_the_Gas__c = jobComplDoc.Have_You_Worked_on_the_Gas__c;
   	  	
   	  	
   	  	
   	  	Database.insert(ic);
   	  	return ic.Id;
   	  	
   	  }                  
   	                       
   	  return null;                    
	
   }
   
}