trigger bUPD_UpdateOpportunityStageJobInstalled on Job__c (before update) {

    /*
        Author             : Cognizant
        Functionality     : This is trigger which sets the stage of the Opportunity with Closed-Won 
                                when the 1st Job related with CHI Lead reaches the status of "Installed".
        Create Date      : 12 May 2010
        Change History  :
        Modified Date    :
    */
    //PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }
    
    map<Id,Job__c> CHILead_JobMap = new map<Id,Job__c>();
    Set<Id> opportunityIdSet=new Set<Id>{};
    Integer iCount=0;
    for (Job__c objJob:Trigger.new){
        if(objJob.Delivery_Date__c != null && objJob.Installation_Date__c != null && objJob.Delivery_Date__c <= objJob.Installation_Date__c)
            //objJob.addError('Delivery Date cannot exceed the Installation Date on Job');
        if (!objJob.is_remedial_Job__c && /*&& !objJob.Split_Job__c && */!objJob.Is_DownTime_Job__c && objJob.Status__c=='Installed' && Trigger.old[iCount].Status__c!='Installed') {
            opportunityIdSet.add(objJob.CHI_Lead__c);
            
            //if(!objJob.is_remedial_Job__c && !objJob.Split_Job__c && !objJob.Is_DownTime_Job__c)
            {
                CHILead_JobMap.put(objJob.CHI_Lead__c, objJob);
            } 
            
        }
        iCount++;
        Job__c j = trigger.oldmap.get(objJob.Id);
        system.debug('@@@@-->'+j.UCR_Number__c+objJob.UCR_Number__c);
        
        if(objJob.RHCAlertMeStatus__c != 'Complete' && objJob.RHCAlertMeStatus__c == 'Sent' && 
          (objJob.RHC_Status__c == 'TRUE' ||objJob.RHC_Status__c == 'Added') && 
          (j.UCR_Number__c == null && objJob.UCR_Number__c != null))
        {
            objJob.RHCAlertMeStatus__c = 'Complete';
        }
    }
    if(opportunityIdSet.size() > 0){
        List<Opportunity> opportunityList =[Select StageName,Id, isLocked__c, CreatedDate, (Select ID, isLocked__c, Record_Status__c , Opportunity__c from Customer_categories__r) from Opportunity where Id In: opportunityIdSet and isClosed=false];
        
        // ++ Added for Prority Installations CR start
        Map<Id,List<Customer_category__c>> custMap = new Map<Id,List<Customer_category__c>>();   
        List<Customer_category__c> tmpCustList = new List<Customer_category__c>(); 
        // --  Added for Prority Installations CR end
        
        for (Opportunity objOpportunity:opportunityList ){
            objOpportunity.StageName='Closed Won';
            objOpportunity.isSystem__c=true;
            if(CHILead_JobMap.containskey(objOpportunity.Id))
            {
            objOpportunity.Primary_Job_Status__c = CHILead_JobMap.get(objOpportunity.Id).Status__c;
            objOpportunity.Job_Sub_Status__c =CHILead_JobMap.get(objOpportunity.Id).Sub_Status__c;
            }
            // ++ Added for Prority Installations CR start
            if(objOpportunity.CreatedDate.date() < Date.valueOf(System.Label.Priority_Install_Release_Date))
            continue;
            objOpportunity.isLocked__c = true;
            for(Customer_category__c cust : objOpportunity.Customer_categories__r)
            {
                if(!custMap.containsKey(cust.Opportunity__c)){
                    tmpCustList = new List<Customer_category__c>();  
                }
                else{
                    tmpCustList = custMap.get(cust.Opportunity__c);
                }
                cust.isLocked__c = true;
                cust.Record_Status__c = 'Complete';
                tmpCustList.add(cust);
                custMap.put(cust.Opportunity__c , tmpCustList);
                System.debug('I am here');
            }
            // --  Added for Prority Installations CR end
            
        }
        Database.SaveResult[] saveResultArr;
        if (opportunityList !=null) 
            saveResultArr=Database.Update(opportunityList,false );
        tmpCustList = new List<Customer_category__c>();      
        for (Job__c objJob:Trigger.new){
            for (Database.SaveResult saveResult:saveResultArr) {
                if (saveResult.getId()==objJob.CHI_Lead__c) {
                    if (!saveResult.isSuccess()){
                        Database.Error errorMsg = saveResult.getErrors()[0];
                        String strMsg='Failed to Update Opportunity'+errorMsg ;
                        objJob.addError(strMsg);
                        
                    // ++ Added for Prority Installations CR start
                    }else if(custMap.containsKey(objJob.CHI_Lead__c) && saveResult.isSuccess()){
                        tmpCustList.addAll(custMap.get(objJob.CHI_Lead__c));
                    }
                    // --  Added for Prority Installations CR end
                }
            }
        }
        // ++ Added for Prority Installations CR start
        if(tmpCustList.size() > 0)
        Database.Update(tmpCustList,false);
        // --  Added for Prority Installations CR end
        
    }
}