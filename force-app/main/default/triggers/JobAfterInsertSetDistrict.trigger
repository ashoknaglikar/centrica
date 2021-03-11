/*
* Purpose: Set the district value on a job when it is created
*
*
*
*/
trigger JobAfterInsertSetDistrict on Job__c (before insert,after insert, before update) {

//PRB00032289 - transferhrstrg


 if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg || Lock.jobAfterInsertSetDistrict)
    {
        return;
    }   
  list<Opportunity>  lst_Opp = new list<Opportunity>();
 if(Trigger.isBefore){
    
    //check that prerequisites are there
    List<Job__c> allJobs = Trigger.new;
    //create a map of opportunity id's to potcode sector
    Map<Id, String> opportunityIdtoPostcodeSector = new Map<Id, String>();
    //get a set of opportunity id's
    Set<Id> oppIds = new Set<Id>();
    for(Job__c theJob : allJobs)
    {   
        // Added as part of customer history card change request.  
        if(theJob.District__c == null)// || (System.Label.Customer_Journey_Flag == 'TRUE' && theJob.Customer_manager_email_address__c == null)){ // Added by Cognizant
        {
            oppIds.add(theJob.CHI_Lead__c);
        }
        // End of customer history card change request.
        if(theJob.Is_Downtime_Job__c || theJob.Is_Remedial_Job__c || theJob.isCancellation_Job__c){
            // Do nothing
        }else{
            theJob.Customer_journey_status_index__c = 1;
        }
    }
    if(oppIds.size() > 0){ // Added by Cognizant
        //create a map of the opportunities that we need the postcode info from
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>(
            [Select Account.BillingPostalCode from Opportunity where ID in :oppIds]);
           
        //now put together the opportunityIdtoPostcodeSector map from the oppIds set and the postcodes 
        if(idToOpportunityMap.size()>0)
        {
        for(Id oppId : oppIds)
        {
            String postCode = idToOpportunityMap.get(oppId).Account.BillingPostalCode;
            String postCodeSector = postCode.substring(0,postCode.length()-2);
            opportunityIdtoPostcodeSector.put(oppId, postCodeSector);
        }
        }
        //now have the set of postcode sectors get the district from the postcode sector
        //create a map of postcode sector names to district ids     
        /*
        Map<String, Id> postcodeSectorNameToDistrictIdMap = new Map<String, Id>();
        Map<String, String> postcodeSectorNameToSubpatchNameMap = new Map<String, String>();
        Map<String, String> postcodeSectorNameToDHMEmailMap = new Map<String, String>();
        Map<String, String> postcodeSectorNameToPlannerEmailMap = new Map<String, String>();
        Map<String, String> postcodeSectorNameToCMEmailMap = new Map<String, String>();
        Map<String, String> pcSectorToTextMail = new Map<String, String>();
        */
         Map<String, Postcode_Sector__c> postcodeSectorMap = new Map<String, Postcode_Sector__c>();
        //all of the postcode sector objects we are interested in...
        List<Postcode_Sector__c> postSectors = new List<Postcode_Sector__c>(
            [Select Sub_Patch__r.District__r.Premier_Ready__c, Sub_Patch__r.Name, Sub_Patch__r.District__c, name, Sub_Patch__r.District__r.DHMName__r.DHM_Email_Address__c, 
            Sub_Patch__r.District__r.Customer_account_manager__r.email, Sub_Patch__r.District__r.Customer_Manager_Email_Address__c,Sub_Patch__r.District__r.DHMName__r.EmployeeTextMailAddress__c,
            Area_Group__c From Postcode_Sector__c where name in :opportunityIdtoPostcodeSector.values() and type__c = 'Installation']);
            
        //now populate the postcodeSectorNameToDistrictIdMap from the list of postcode sector objects
        map<string, string> areaGroupEmpMap  = new map<string, string>();
        for(Postcode_Sector__c postSector : postSectors)
        {
            postcodeSectorMap.put(postSector.name, postSector);
            if(postSector.Area_Group__c!=null)
            areaGroupEmpMap.put(postSector.Area_Group__c, null);
            /*
            postcodeSectorNameToDistrictIdMap.put(postSector.name, postSector.Sub_Patch__r.District__c);
            postcodeSectorNameToSubpatchNameMap.put(postSector.name, postSector.Sub_Patch__r.Name);
            postcodeSectorNameToDHMEmailMap.put(postSector.name, postSector.Sub_Patch__r.District__r.DHMName__r.DHM_Email_Address__c);
            postcodeSectorNameToPlannerEmailMap.put(postSector.name, postSector.Sub_Patch__r.District__r.Customer_account_manager__r.email);
            postcodeSectorNameToCMEmailMap.put(postSector.name, postSector.Sub_Patch__r.District__r.Customer_Manager_Email_Address__c);
            pcSectorToTextMail.put(postSector.name, postSector.Sub_Patch__r.District__r.DHMName__r.EmployeeTextMailAddress__c);
            */
        }
        
        if(areaGroupEmpMap.keyset().size()>0)
        for(Employee__c emp : [Select id, Area_Group__c from Employee__c where Area_Group__c in:areaGroupEmpMap.keySet() and Area_Group__c!=null])
        {
            areaGroupEmpMap.put(emp.Area_Group__c, emp.Id);
        }
        
        //we now have 2 maps that can be combined to determin the district given the opportunity id
        
        //loop through all of the jobs and assign the district
        List<Job__c> premierJobs = new List<Job__c>();
        for(Job__c theJob : allJobs)
        {       
            String postcodeSector = opportunityIdtoPostcodeSector.get(theJob.CHI_Lead__c);
            if(postcodeSectorMap.ContainsKey(postcodeSector))
            {
                Postcode_Sector__c localSector = postcodeSectorMap.get(postcodeSector);
                theJob.District__c = localSector.Sub_Patch__r.District__c;
                theJob.Sub_Patch__c = localSector.Sub_Patch__r.Name;
                theJob.DHM_Email_Address__c = localSector.Sub_Patch__r.District__r.DHMName__r.DHM_Email_Address__c;
                theJob.CAM_Email_Address__c = localSector.Sub_Patch__r.District__r.Customer_account_manager__r.email;
                theJob.Customer_manager_email_address__c = localSector.Sub_Patch__r.District__r.Customer_Manager_Email_Address__c;
                theJob.Customer_Journey_Status_Change_Date__c = Date.today();
                theJob.DHMTextMail__c = localSector.Sub_Patch__r.District__r.DHMName__r.EmployeeTextMailAddress__c;
                if(areaGroupEmpMap.containsKey(localSector.Area_Group__c))
                theJob.L6_PC_Manager__c = areaGroupEmpMap.get(localSector.Area_Group__c);
                if(/*postcodeSectorMap.get(postcodeSector).Sub_Patch__r.District__r.Premier_Ready__c &&*/ theJob.Installation_Type__c!=null && theJob.Boiler_Location__c !=null)
                {
                    premierJobs.add(theJob);
                }
            }
            
        }
        if(premierJobs.size()>0 && trigger.isInsert)
        {
            jobTriggerHelper.calculateBalancingMechanicalHours(premierJobs,true);
        }
    }
    
 }// Added as part of customer history card change request. 
   else 
   {
        /*
            Populate Primary Job's Status & Sub-Status on CHI Lead, when Job is created.
            //fix : Green Deal 
            // Associate GD Prequal if they were created before Job.
        */
        
        map<Id, Id> ChiLeads = new map<Id, Id>();
        for(Job__c j:trigger.new)
        {
            if(!j.Is_Downtime_Job__c && !j.Is_Remedial_Job__c  && !j.Split_Job__c)
            {
                lst_Opp.add(new Opportunity(id=j.CHI_Lead__c, Primary_Job_Status__c = j.Status__c,Job_Sub_Status__c = j.Sub_Status__c));
                ChiLeads.put(j.CHI_Lead__c,j.Id);
            }   
                
        }
        /*
        if(ChiLeads.keyset().size()>0)
        {
            list<Green_Deal_Questions__c> needsUpdating = new list<Green_Deal_Questions__c>();
            for(Green_Deal_Questions__c gdp : [select id,CHI_Lead__c from Green_Deal_Questions__c where CHI_Lead__c in :ChiLeads.keyset() and Job__c = null ])
            {
                gdp.Job__c = ChiLeads.get(gdp.CHI_Lead__c);
                needsUpdating.add(gdp);
            }
            
            if(needsUpdating.size()>0)
            update needsUpdating;
            
            list<Green_Deal_Reconsilliation__c> needsGDUpdating = new list<Green_Deal_Reconsilliation__c>();
            for(Green_Deal_Reconsilliation__c gdp : [select id,Opportunity__c from Green_Deal_Reconsilliation__c where Opportunity__c in :ChiLeads.keyset() and Job__c = null ])
            {
                gdp.Job__c = ChiLeads.get(gdp.Opportunity__c);
                needsGDUpdating.add(gdp);
            }
            
            if(needsGDUpdating.size()>0)
            update needsGDUpdating;
            
        }
        */
   if(System.Label.Customer_Journey_Flag == 'TRUE'){
      
      try{
        
        /*
        List<Customer_history_card__c> lstCustHistCard = new List<Customer_history_card__c>();
        Customer_history_card__c custHistCard;
        Map<Id,Job__c> jobIdAndJobMap = new Map<Id,Job__c>();
        Map<Id,Job__c> custHistCardIdAndJobMap = new Map<Id,Job__c>();
        
        for(Job__c job : Trigger.New){
            if(job.Is_Downtime_Job__c || job.Is_Remedial_Job__c || job.isCancellation_Job__c){
                continue;
            }
            custHistCard = new Customer_history_card__c();
            custHistCard.Sub_Patch__c = job.Sub_Patch__c;
            custHistCard.Job__c = job.Id;
            custHistCard.DHM_Email__c = job.DHM_Email_Address__c;
            custHistCard.CAM_Email_Address__c = job.CAM_Email_Address__c;
            custHistCard.Customer_Manager_Email_Address__c = job.Customer_manager_email_address__c;
            custHistCard.Customer_journey_status_index__c = 1;
            lstCustHistCard.add(custHistCard);
            jobIdAndJobMap.put(job.id,job);
            
           
            
        }
        
        Database.Insert(lstCustHistCard,false);
        
        for(Customer_history_card__c custHistI : lstCustHistCard){
            
            custHistCardIdAndJobMap.put(custHistI.Id,jobIdAndJobMap.get(custHistI.Job__c));
            
        }
        
        List<Customer_journey_event_history__c> custJourneyEventHistList = new List<Customer_journey_event_history__c>();
        Customer_journey_event_history__c custJourneyEventHist;
        
        for(Customer_history_card__c custHist : lstCustHistCard){
            custJourneyEventHist = new Customer_journey_event_history__c();
            custJourneyEventHist.Customer_history_card__c = custHist.Id;
            custJourneyEventHist.Customer_journey_status__c = custHistCardIdAndJobMap.get(custHist.Id).Customer_Journey__c;
            custJourneyEventHist.Customer_Journey_Status_Change_Date__c = Date.today();
            custJourneyEventHistList.add(custJourneyEventHist);
        }
        
        Database.Insert(custJourneyEventHistList,false);
        */
        //Populate Primary Job's Status & Sub-Status on CHI Lead, when Job is created.
        if(lst_Opp.size()>0)
        update lst_Opp;
       }catch(Exception excp){
         
         System.debug('#####Exception in customer history card creation#####'+excp.getMessage());
        
       }
        
    }
    
    
    
   }
 // End of customer history card change request.
 Lock.setJobAfterInsertSetDistrict();
}