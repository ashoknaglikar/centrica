global class FetchQuotaDataReq implements database.batchable<sobject>,Database.AllowsCallouts,Database.Stateful{
    
    public static void createOFSBatch()
    {
        FetchQuotaDataReq objAutoPrd = new FetchQuotaDataReq();
        ID batchprocessid = Database.executeBatch(objAutoPrd,1);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string buck = system.label.OFSBucketType;
        //string employeeId = 'a0Aw000002WGjE6';
        return Database.getQueryLocator('select id,name,Primary_Role__c from Employee__c where Primary_Role__c=:buck');
    }
    
    
    global void execute(Database.BatchableContext BC,  List<sObject> lstRecords)
    {
        for(sObject s: lstRecords)
        {
            Employee__c e = (Employee__c)s;
            list<string> employeeId = new list<string> {e.Id};
                FetchQuotaDataReq.ProcessReq(employeeId);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    /*
    public static void InvokeFutureMethod(){
        list<Employee__c> emp=[select id,name,Primary_Role__c from Employee__c where Primary_Role__c=:'OFS Bucket'];
        list<string> loc;
        
        if(emp!=null){
            loc = new list<string>();
            for(employee__c emp1:emp){
                loc.add(emp1.id);
            }
            FetchQuotaDataReq.ProcessReq(loc);        
        }
        
        
    }    
    */
    
    
    //@future(callout=true)
    public static void ProcessReq(List<string> location){ //Get the Districts to Process 
        
        system.debug('---------->'+location);
        List<OFS_Quota_Data__c> QuotaList = new List<OFS_Quota_Data__c>();
        //Dates to process - 90 days
        list<Date> DateList = new list<Date>();
        Date StartDate = date.Today();
        Date EndDate = Date.Today().adddays(integer.valueof(system.label.get_Quota_days)); // maintain Custom Label to control no. of days
        while(StartDate<=EndDate)
        {
            DateList.add(StartDate);
            StartDate = StartDate.adddays(1);
        }
        
        
        //string[] loc = new string[]{'a0A20000002RrXh'};
        
        toaCapacity.get_quota_data_bucket_element[] Resp = getCapacityRes.getQuotaData(DateList,location);
        system.debug('::::::::::::::::'+resp);
        If(Resp!=NULL){
            for(toaCapacity.get_quota_data_bucket_element BuckResp: Resp){
                
                //bucket_id, name are Used to set the Bucket Name of OFS QuotaData Records
                string bucket_id = BuckResp.bucket_id;
                string name = BuckResp.name;
                for(toaCapacity.get_quota_data_day_element DayElements : BuckResp.day){ 
                    //Process the Date Field to Date In OFS Quota data Object
                    
                    
                    for(toaCapacity.get_quota_data_time_slot_element TimeElements : DayElements.time_slot){
                        
                        
                        
                        system.debug('-------------->'+TimeElements.label+' ' +TimeElements.other_activities );
                        
                        if(TimeElements.label != null ){
                            
                            
                            if(TimeElements.category != null){
                                for(toaCapacity.get_quota_data_category_element category: TimeElements.category)
                                {
                                    system.debug('::::::'+category);
                                    OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
                                    newRec.Bucket_name__c = name;
                                    newRec.Date__c = DayElements.date_x; 
                                    newRec.Slot_Type__c = TimeElements.label;
                                    newRec.AM_All_day_unavailabilities_hours__c = TimeElements.other_activities == null ? 0:TimeElements.other_activities; 
                                    newRec.AM_Internal_activities_hrs__c = TimeElements.other_activities == null ? 0:TimeElements.other_activities;
                                    newRec.Capacity_Category__c  = category.label;
                                    newRec.AM_Booked_activities__c =  category.count == null ? 0 : category.count; 
                                    newRec.AM_Capacity_Available_Hrs__c = category.max_available == null ? 0 : category.max_available;
                                    newRec.AM_Quota__c = category.quota == null ?0:category.quota;
                                    newRec.AM_Category_Booked_Time_Hrs__c = category.used == null ? 0 : category.used;
                                    if(TimeElements.Total != null)
                                    {
                                        
                                        newRec.AM_Total_Available_Hrs__c = TimeElements.Total.max_available == null ? 0 : TimeElements.Total.max_available;
                                        newRec.AM_Total_Quota__c = TimeElements.Total.quota == null ?0:TimeElements.Total.quota;
                                        newRec.AM_Total_Booked_Time_hrs__c = TimeElements.Total.used == null ? 0 : TimeElements.Total.used;
                                    }
                                    newRec.External_ID__c=Utilities.popluateExternalId(newRec);
                                    system.debug('newRec -->'+newRec.Slot_Type__c+' '+newRec);
                                    QuotaList.add(newRec);
                                }
                                
                            }
                            
                            
                        }
                        
                        
                        
                    }
                    
                }
                
            }
        }
        if(QuotaList.size()>0){
            Database.UpsertResult[] upsertResult = Database.upsert(QuotaList,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),false);
            integer i = 0;
            list<string> duplicateStrings = new list<string>();
            list<OFS_Quota_Data__c> finalList  = new list<OFS_Quota_Data__c>();
            
            for(Database.UpsertResult e : upsertResult)
            {
                system.debug('Result -->'+e);
                if(!e.isSuccess())
                {
                    duplicateStrings.add(QuotaList[i].External_ID__c);
                    finalList.add(QuotaList[i]);
                   

                }
                 i++ ;
            }
            system.debug('duplicateStrings -->'+duplicateStrings);
            system.debug('finalList -->'+finalList);
            
            if(duplicateStrings.size()>0)
            {
                delete (new list<OFS_Quota_Data__c>([select id from OFS_Quota_Data__c where External_ID__c in :duplicateStrings ]));
                Database.upsert(finalList,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),false);

            }

            system.debug('QuotaList='+QuotaList);
            
        }
        
    }
    
}