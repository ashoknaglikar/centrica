/*
Type Name: bINS_bUPD_NPS_Populate_Account_CHILead
Author: Cognizant
Created Date: 23/04/2010
Reason: To populate Account and CHI lead on NPS object.
Change History:
*/

trigger bINS_bUPD_NPS_Populate_Account_CHILead on NPS__c (before insert,before update)
{
    //Variable declarations section.
    set<Id> lstCHILeadOfNPS = new set<Id>();
    Map<Id,Id> mapCHILeadIdAccount = new Map<Id,Id>();
    List<NPS__c> lstNPS = new List<NPS__c>();
    set<String> lstCHILeadName = new set<String>();
    set<Id> lstAllOpportunities = new set<Id>();
    Map<string,NPS__c> mapCHILeadNps = new Map<string,NPS__c>();
    Map<Id,Opportunity> mapOpportunityIdOpportunity = new Map<Id,Opportunity>();
    Map<String,Id> mapChiLeadExternalId_Id = new Map<String,Id>();
    
    //Following flow will execute if new NPS record is inserted.
    if(Trigger.isInsert)
    {
        System.debug('%%%%% inside isInsert ');
        
        set<string> jobIds= new set<string>();
        //Retrieving all the NPS records entered into this trigger.
        for( integer i = 0; i < Trigger.new.size(); i++ )
        {
            System.debug('%%%%% 1 Trigger.new[i].Created_by_InstallationForce__c: '+Trigger.new[i].Created_by_InstallationForce__c);
            System.debug('%%%%% 2 Trigger.new[i].Opportunity__c: '+Trigger.new[i].Opportunity__c);
            System.debug('%%%%% 3 Trigger.new[i].CHI_Lead_Name__c: '+Trigger.new[i].CHI_Lead_Name__c);
            
            if(trigger.new[i].job__c!=null)
            {
                jobIds.add(trigger.new[i].job__c);
            }
            //Trigger will process for NPS records created manually.
            if(!( Trigger.new[i].Created_by_InstallationForce__c ))
            {
                /**
                If Opportunity exists for NPS, prepare list of all opportunities
                to fetch respective accounts.
                */
                if(Trigger.new[i].Opportunity__c != null)
                {
                    lstCHILeadOfNPS.add( Trigger.new[i].Opportunity__c );
                }
                //If CHI Lead name is given, fetch the corresponding CHI Lead.
                if((Trigger.new[i].CHI_Lead_Name__c != null) &&
                ((Trigger.new[i].CHI_Lead_Name__c).trim() != null) )
                {
                    lstCHILeadName.add(Trigger.new[i].CHI_Lead_Name__c.split('-')[0]);                    
                }  
                System.debug('%%%%% 4 lstCHILeadName: '+lstCHILeadName);  
            }       
        }    
        
        System.debug('%%%%% 4.1 lstCHILeadOfNPS: '+lstCHILeadOfNPS);
        System.debug('%%%%% 4.2 lstCHILeadName: '+lstCHILeadName);
        System.debug('%%%%% 4.3 lstCHILeadOfNPS: '+((lstCHILeadOfNPS != null && lstCHILeadOfNPS.size() > 0) || 
        (lstCHILeadName != null && lstCHILeadName.size() > 0)));
        
        
        //Fetching account record of CHI lead of NPS. 
        if((lstCHILeadOfNPS != null && lstCHILeadOfNPS.size() > 0) || 
        (lstCHILeadName != null && lstCHILeadName.size() > 0))
        {
            System.debug('%%%%% 5 inside true of OR condition');
            
            //Last OR condition is modified:name field is replased with CHI_Lead_Id__c. 
            for(Opportunity opportunityRecord : [Select Id, name, AccountId,
            CHI_Lead_Id__c, CHI_Lead_Id1__c, CHI_Lead_Id2__c from Opportunity where
            Id in : lstCHILeadOfNPS OR CHI_Lead_Id__c in : lstCHILeadName])
            {
                System.debug('%%%%% 5.1 opportunityRecord.CHI_Lead_Id__c: '+opportunityRecord.CHI_Lead_Id__c);                
                if(opportunityRecord.CHI_Lead_Id__c !=null){
                    mapChiLeadExternalId_Id.put(opportunityRecord.CHI_Lead_Id__c,opportunityRecord.Id);
                }
                System.debug('%%%%% 5.2 mapChiLeadExternalId_Id: '+mapChiLeadExternalId_Id); 
                lstAllOpportunities.add(opportunityRecord.Id);
                mapOpportunityIdOpportunity.put(opportunityRecord.Id, opportunityRecord);
                mapCHILeadIdAccount.put( opportunityRecord.Id, opportunityRecord.AccountId );
            }
        }
        
        
        
        /**
        Retrieving all the NPS records to check if NPS already exists
        for the CHI Lead.
        */
           
        for(NPS__c nps : [select Id, Name, Account__c, Opportunity__c,source__c,appointment__c,job__c from NPS__c
                           where Opportunity__c in : lstAllOpportunities])
        {
             if(nps.appointment__c!=null)
             mapCHILeadNps.put(nps.Opportunity__c+string.valueof(nps.appointment__c),nps);
             if(nps.job__c!=null)
             mapCHILeadNps.put(nps.Opportunity__c+string.valueof(nps.job__c),nps);
             if(nps.appointment__c==null && nps.job__c==null)
                 mapCHILeadNps.put(nps.Opportunity__c,nps);
        }
        
        /**
        Validating the condition:Whether NPS already exists for CHI Lead
        or not and displaying error if NPS already exists.
        */  
        for(integer i = 0; i < Trigger.new.size(); i++)
        {
            NPS__c existingNPS = null;
            if(trigger.new[i].appointment__c!=null)
            existingNPS = mapCHILeadNps.get(Trigger.new[i].Opportunity__c+string.valueof(trigger.new[i].appointment__c));
            else if(trigger.new[i].job__c!=null)
            existingNPS = mapCHILeadNps.get(Trigger.new[i].Opportunity__c+string.valueof(trigger.new[i].job__c));
            else if(trigger.new[i].appointment__c==null&& trigger.new[i].job__c==null)
            existingNPS = mapCHILeadNps.get(Trigger.new[i].Opportunity__c);
            System.debug('%%%%% 6 before trigger.adderror: ');  
            if(system.label.npsDuplicateSwitch == 'on' && existingNPS != null )
            {
                System.debug('%%%%% 7 Inside trigger.adderror: ');  
                Trigger.new[i].addError('Cannot create new NPS as one already exists for this CHI Lead.');
            }
        }
        
        /*map<id,String> installerIdsMap= new map<id,String>();
        for(Job__c jb:[select id,InstallerAliasName__c from job__c where id IN:jobIds])
        {
            installerIdsMap.put(jb.id,jb.InstallerAliasName__c);
        }
         Map<id, Employee__c> empMap = new map<id,Employee__c>([select id ,Employee_Number__c from employee__c where id IN: installerIdsMap.values()]);*/
        
        
       
       
         Map<id,List<Diary_Entry__c>> jobDiaryEntryMap = new Map<id,List<Diary_Entry__c>>();
         for(Diary_Entry__c de: [select id,Week__r.Employee__c,Week__r.Employee__r.Employee_Number__c,job__c from Diary_Entry__c where job__c=:jobIds and Sub_Type__c='Mechanical' order by Hours__c desc])
         {
                if(jobDiaryEntryMap.containsKey(de.job__c))
                {
                    List<Diary_Entry__c> delist = jobDiaryEntryMap.get(de.job__c);
                    delist.add(de);
                    jobDiaryEntryMap.put(de.job__c,delist);
                }
                else
                {
                    jobDiaryEntryMap.put(de.job__c,new list<Diary_Entry__c>{de});
                }
        }
        
        //Associating NPS record with corresponding Account record.
        for(integer i = 0; i < Trigger.new.size(); i++)
        {
            if((Trigger.new[i].Opportunity__c != null || 
            Trigger.new[i].CHI_Lead_Name__c != null) && 
            (!( Trigger.new[i].Created_by_InstallationForce__c )))
            {
                if(Trigger.new[i].Opportunity__c != null ){
                    System.debug('%%%%% 7.1 inside if(opportunity not null: '+trigger.new[i]);
                    Trigger.new[i].CHI_Lead_Name__c = (mapOpportunityIdOpportunity.get(Trigger.new[i].Opportunity__c)).CHI_Lead_Id__c;
                    if(Trigger.new[i].Source__c=='Job Installation')
                    {
                       Trigger.new[i].CHI_Lead_Name__c+='-1'; 
                    }
                    
                }
                else if(Trigger.new[i].CHI_Lead_Name__c != null){
                    System.debug('%%%%% 7.2 inside if(CHI_Lead_Name__c not null): ');
                    System.debug('%%%%% 7.3 mapChiLeadExternalId_Id.get(Trigger.new[i].CHI_Lead_Name__c: ' + mapChiLeadExternalId_Id.get(Trigger.new[i].CHI_Lead_Name__c));
                    Trigger.new[i].Opportunity__c = mapChiLeadExternalId_Id.get(Trigger.new[i].CHI_Lead_Name__c.split('-')[0]);
                }           
                System.debug('%%%%% 8 after assigning opportunity to NPS from CHI Leadname: Trigger.new[i].Opportunity__c: '+Trigger.new[i].Opportunity__c);  
                //Set Account for NPS.
                Trigger.new[i].Account__c = mapCHILeadIdAccount.get(Trigger.new[i].Opportunity__c);            
                Trigger.new[i].Status__c = 'Step 2';  
                if(trigger.new[i].job__c!=null)
                {
                  if(jobDiaryEntryMap.containskey(trigger.new[i].job__c))
                  {
                      if(jobDiaryEntryMap.get(trigger.new[i].job__c).size()>=2)
                      {
                          trigger.new[i].Mechanical_Engineer_1_Pay_Number__c = jobDiaryEntryMap.get(trigger.new[i].job__c)[0].Week__r.Employee__r.Employee_Number__c;
                          trigger.new[i].Mechanical_Engineer_2_Pay_Number__c = jobDiaryEntryMap.get(trigger.new[i].job__c)[1].Week__r.Employee__r.Employee_Number__c;
                      }
                      else if(jobDiaryEntryMap.get(trigger.new[i].job__c).size()>0)
                          trigger.new[i].Mechanical_Engineer_1_Pay_Number__c = jobDiaryEntryMap.get(trigger.new[i].job__c)[0].Week__r.Employee__r.Employee_Number__c;
                  }
                }
                
            }  
            
            
            
        }
    }
    //Ending the execution of insert NPS event.
    
    /**
    This portion is added from the ValidateManualProcess Trigger after
    deactivating this trigger : 05/03/2010.
    */    
    /**
    Checking if the existing NPS record is being updated and
    Update the status field accordingly.
    */
    if(Trigger.isUpdate)
    {
        //Executing the flow for bulk records. 
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            /**
            Check : All the validations are applied if Preferred Contact method
            is not Email and Previous NPS status is 'Step 2'.
            */
            if(Trigger.new[i].Preferred_Contact_Method__c != 'Email' &&
            Trigger.old[i].Status__c == 'Step 2')
            {
                 /**
                 If all validation rules evaluate to false,
                 set the NPS step = 3 and update the NPS.
                 */
                 if((Trigger.new[i].Step1_Score__c != null) &&
                 (Trigger.new[i].Step2_Score__c != null))
                 {
                     Trigger.new[i].Status__c = 'Step 3';                        
                 }               
            }
            
            /*if(Trigger.new[i].Step1_Score_Dup__c!=null&&
                Trigger.new[i].Step2_Score__c !=null && 
                (Trigger.new[i].Integration_Id__c==null||Trigger.new[i].Integration_Id__c==''))
            Trigger.new[i].Integration_Status__c ='Ready to be Sent';*/
        }
    }
    //Ending the execution of update NPS event.
    
}