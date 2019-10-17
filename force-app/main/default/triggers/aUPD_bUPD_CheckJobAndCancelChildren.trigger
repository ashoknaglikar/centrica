trigger aUPD_bUPD_CheckJobAndCancelChildren on Opportunity (after update, after insert, before insert, before update) {
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    if(trigger.isbefore)
    {
        if(trigger.isInsert)
        {
            /*
        list<Id> accountIdList = new list<Id>();
        for(Opportunity opp: trigger.new)
        {
            accountIdList.add(opp.AccountId);
        }
        
        map<id, string> accountSectorMap = new map<id, string>();
        for(Account a : [select id, Post_Code_Sector__c from Account Where Id in: accountIdList] )
        {
            accountSectorMap.put(a.id, a.Post_Code_Sector__c);
        }
    
        map<string, id> postCodeManagerMap = new map<string, Id>();
        for(PostCode_Sector__c pc : [select Name, L6_Sales_Manager__c from PostCode_Sector__c where Name in :accountSectorMap.values() and Type__c = 'Sales' ])
        {
            postCodeManagerMap.put(pc.name, pc.L6_Sales_Manager__c);
        }
        
        for(Opportunity opp: trigger.new)
        {
            if(accountSectorMap.containsKey(opp.AccountId))
            if(postCodeManagerMap.containsKey(accountSectorMap.get(opp.AccountId)))
            opp.L6_Sales_Manager__c = postCodeManagerMap.get(accountSectorMap.get(opp.AccountId));
        }
        */
        }
        
        if(!lock.cchRecursiveStopper && (trigger.isInsert || trigger.isupdate))
        //if(!lock.cchRecursiveStopper)
        {
            lock.cchRecursiveStopper = true;
            list<Opportunity> oppToBeSentToCCH = new list<Opportunity>();
            for(Opportunity opp: trigger.new)
            {
                Opportunity oldOpp = new Opportunity();
                if(trigger.isupdate)
                oldOpp = trigger.oldmap.get(opp.Id);
                if(opp.StageName!= 'Closed Lost'  && opp.StageName!= 'Expired'  && opp.StageName!= 'Closed Won'  &&
                (trigger.IsInsert && (opp.Customer_Marketing_Consent__c!=null || opp.Marketing_Preferences__c != null))
                ||(trigger.isupdate &&
                (opp.Customer_Marketing_Consent__c != oldOpp.Customer_Marketing_Consent__c || 
                opp.Marketing_Preferences__c!=oldOpp.Marketing_Preferences__c)))
                {
                    opp.MPU_time__c = system.now();
                    oppToBeSentToCCH.add(opp);
                }
            }
            
            if(oppToBeSentToCCH.size()>9 || system.label.CCHIntegrationSwitch == 'off')
            {
                for(Opportunity opp : oppToBeSentToCCH)
                {
                    opp.SAP_Cloud_Integration_Status__c ='In Queue';
                }
            }
        }
    }
    else if(trigger.isAfter && (trigger.isInsert || trigger.isupdate))
    {
        if(!lock.iscchUser() && !lock.cchApiRecursiveStopper )
        {
            lock.cchApiRecursiveStopper= true;
            list<Opportunity> oppToBeSentToCCH = new list<Opportunity>();
            for(Opportunity opp: trigger.new)
            {
                Opportunity oldOpp = new Opportunity();
                if(trigger.isupdate)
                oldOpp = trigger.oldmap.get(opp.Id);
                if(opp.StageName!= 'Closed Lost'  && opp.StageName!= 'Expired'  && opp.StageName!= 'Closed Won'  &&
                opp.Customer_Marketing_Consent__c != oldOpp.Customer_Marketing_Consent__c || 
                opp.Marketing_Preferences__c!=oldOpp.Marketing_Preferences__c)
                {
                    oppToBeSentToCCH.add(opp);
                }
                
            }
            if(oppToBeSentToCCH.size()<8 && system.label.CCHIntegrationSwitch == 'on')
            {
                for(Opportunity opp : oppToBeSentToCCH)
                {
                    customerChoiceHubHTTPRequest.callCreateCustomerOrUpdateMarketingPreferences(new list<Id>{opp.Id});
                }
                
            }
        }
    }
    
  System.debug('entered ==== '+cls_IsRun.isOppoCanRun);
    if (cls_IsRun.isOppoCanRun==false && trigger.isUpdate && trigger.isAfter) {            
        cls_IsRun.setIsOppoCanRun();
        Map<String,opportunity> oppMap = new Map<String,Opportunity>();
        Map<String,opportunity> GDF_Changed = new Map<String,Opportunity>();
        
        Integer cnt =0;
        Opportunity[] oldOpp = Trigger.old;
        for(Opportunity opp : Trigger.new){
            System.debug('1 '+oldOpp[cnt].StageName+':'+opp.Stagename+':'+oldOpp[cnt].auto_cancel__c+':'+opp.auto_cancel__c);
            if(oldOpp[cnt].StageName == 'Suspended' && opp.Stagename == 'Closed Lost' && oldOpp[cnt].auto_cancel__c == false && opp.auto_cancel__c == true)
                oppMap.put(opp.id,opp);
                
            else if(opp.GDF_Offer__c != oldOpp[cnt].GDF_Offer__c)
            {
                GDF_Changed.put(opp.id,opp);
                
            }    
        }
        if(oppMap.size() > 0){           
            try{
              //System.debug('#########Calling cancel batch ########');
              SuspendCancelJob suscan = new SuspendCancelJob(); 
              suscan.cancelJobAndChildren(Trigger.new[0].id); 
            }catch(Exception e){
              System.debug('Exception : '+e.getMessage());  
            }
        }
        
        if(GDF_Changed.size()>0)
        {
            list<Job__c> updateJobs = new list<Job__c>();
            for(Job__c job: [Select Id, GDF_Offer__c, CHI_Lead__c from Job__c where CHI_Lead__c in:GDF_Changed.keyset() and Is_Downtime_Job__c = false and Is_Remedial_Job__c = false and Is_Remedial_Job__c = false and Split_Job__c = false])
            {
                job.GDF_Offer__c = GDF_Changed.get(job.CHI_Lead__c).GDF_Offer__c;
                updateJobs.add(job);
            }
            
            if(updateJobs.size()>0)
            {
                lock.jobTriggerSwitch = true;
                update updateJobs;
            }
        }
    }
}