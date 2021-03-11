trigger ensurePrimary on BigMachines_Quote__c (before insert,before update) {

    // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
      if(cls_IsRun.dontFireTriggers || cls_IsRun.bigMachineSwitch || cls_IsRun.istrg_ensurePrimary){
          return;
      }
      
    // CHI CR-000430 
    
    if(Trigger.isUpdate && trigger.new[0].Dont_Update_Payment_Options__c && UserInfo.getUserName().contains('bmsfdcintegration')
       && ( trigger.new[0].POC_Payment_Option__c != Trigger.OldMap.get(trigger.new[0].ID).POC_Payment_Option__c ||
        trigger.new[0].POC_Payment_Method__c != Trigger.OldMap.get(trigger.new[0].ID).POC_Payment_Method__c)){
     
        trigger.new[0].POC_Payment_Option__c = Trigger.OldMap.get(trigger.new[0].ID).POC_Payment_Option__c;
        trigger.new[0].POC_Payment_Method__c = Trigger.OldMap.get(trigger.new[0].ID).POC_Payment_Method__c;
    
    
    }
    
    
    
    // There is no standard scenario where multiple quotes are created in one
    // batch operation.  This trigger only operates for individual quote 
    // creation.  If multiple quotes are created at the same time (through 
    // the API, for example) this trigger will not do anything.
    
    /*
    //Capgemini - 26th Aug 09
    
    Current Functionality:
    In the current interface when the first BM Quote is created against a CHI lead 
    that quote becomes the primary quote. That quote remains the primary whenever 
    any new quotes are created.
    Required Functionality:
    For a given CHI Lead, the most recently created quote that has the stage 
    "Quote Finalised – Accepted" will be the primary quote. Otherwise there will 
    be no primary quote. If there is no primary quote then the quote data will not 
    be rolled up to the CHI lead.   
    */

    ID oppId = Trigger.new[0].Opportunity__c;
 
 // Fix - Cognizant support - To reduce number of SOQL's in quote triggers to avoid governor limits.
 // There are number of changes done in this trigger for performance tuning on 10 June 2010. 
    
    if (Trigger.size == 1 && oppId != null && cls_IsRun.isQuoteInsertUpdate == false ) {
    
       cls_IsRun.setIsQuoteInsertUpdate();
       
       // CR XXX Dont change the quote submitted date once it is populated
       if(Trigger.isUpdate && trigger.old[0].submittedDate_quote__c != null)
       if(trigger.old[0].submittedDate_quote__c.format().length()>0)
       trigger.new[0].submittedDate_quote__c = trigger.old[0].submittedDate_quote__c;
       
    // brm:2010/01/06 If the quote matches the 'Consider for Installation Planning' = y criteria and a quote already exists where the CfIP=y
    //then set the bmStatusReason__c to 'Subsequent Sold Quote'. 
    //Otherwise do the standard existing functionality.
    
    Boolean stopComposition = false;
    
    BigMachines_Quote__c[] existingItems = new List<BigMachines_Quote__c>();
    
    if(trigger.new[0].bmStatusReason__c == 'Subsequent Sold Quote' || trigger.new[0].stage__c == 'Quote Finalised - Not Accepted'){
        
        return;
        
    }
    
    if(trigger.new[0].stage__c == 'Quote Finalised - Accepted' && trigger.isInsert)
    {
    
    trigger.new[0].Is_Primary__c = true;
    
    existingItems = [select Id from BigMachines_Quote__c
                                              where Opportunity__c = :oppId
                                              //and Name != :(Trigger.new[0].Name)
                                              and Consider_For_Installation_Planning__c = 'Y'
                                              ];
                                              
    stopComposition = (existingItems.size() > 0);
    
    if(stopComposition ){
        system.debug('Duplicate -->'+trigger.new[0].Id);
        trigger.new[0].bmStatusReason__c = 'Subsequent Sold Quote';
        trigger.new[0].stage__c = 'Quote Finalised - Not Accepted';
        trigger.new[0].Is_Primary__c = false;
    }
            
        /*
        	Change: Specify To Succeed
        	Des: Update Trial Name from Job to BM Quote if a Job existis in before in job.
        
        if(trigger.isinsert)
        {
        	AddNewSkill addObj = new AddNewSkill();
        	List<Job__c> primaryJobList = addObj.fetchJobByCHILead(trigger.new[0]);
        	if(primaryJobList.size()>0 && primaryJobList[0].Trial_Names__c!=null)
        	{
        		trigger.new[0].Trial_Name__c = primaryJobList[0].Trial_Names__c;
        	}
        }
        */
    }
    
    }    
}