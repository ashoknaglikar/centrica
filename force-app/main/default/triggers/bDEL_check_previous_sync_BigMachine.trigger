/*
  Purpose: THis trigger is written to prevent the BMSFDCIntegration users not to sync the BIg Machine
  Quote Product second time to salesforce. This was a fix for one of the production issue.
  Issue is Quote product from big macine sync twice and delete the previous packs and create new one.
  
  Date:- 05/08/2010
  
*/
trigger bDEL_check_previous_sync_BigMachine on Quote_Product__c (before delete){
    
   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
	  if(cls_IsRun.dontFireTriggers){
	      return;
	  }
	      
    for(Quote_Product__c objQuoteProd: Trigger.old) {
        if (objQuoteProd.Big_Machine_Sync__c == 'TRUE' && 
                 ( UserInfo.getName() == 'BMSFDCIntegration' || UserInfo.getName() == 'BMSFDCIntegrationParts' ))
            objQuoteProd.addError('Synched quote products cannot be removed.');    
        }
    }