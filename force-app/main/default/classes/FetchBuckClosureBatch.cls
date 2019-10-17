global class FetchBuckClosureBatch implements database.batchable<sobject>,Database.AllowsCallouts,Database.Stateful{
    
     global Date startDate;
     global Date endDate;
     public static final string recTName='Quota Close time';
    global FetchBuckClosureBatch(Date sDate,Date eDate){
    startDate=sDate;
    endDate=eDate;
    
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string priRole='OFS Bucket';
        return Database.getQueryLocator('Select id, Employee_ID18__c  from Employee__c where Primary_role__c =:priRole and Inactive__c = false');
    }
    
    
    global void execute(Database.BatchableContext BC,  List<sObject> lstRecords)
    {
        for(sObject s: lstRecords)
        {
            Employee__c e = (Employee__c)s;
            list<Id> employeeId = new list<Id> {e.Id};
            FetchBuckClosureBatch.ProcessReq(employeeId,startDate,endDate);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
      AsyncApexJob a = [Select Id, Status, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
       
       list<string> toaddress = new list<string>{userinfo.getUserEmail()};
        system.debug('@@a'+a); 
       if(a.Status=='Completed')
       {
           CreateEmail.CretaeSendTextEmail(toaddress, 'Bucket Closure data has been retrieved from salesforce. Thanks',  'Bucket Closure data Successfully Retrieved');
       }
    }
    
    public static void ProcessReq(List<Id> empList,date startDate,date endDate){
    
    
      List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
       Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTName].Id;    
      List<Employee__c> empIdNList=[Select id,name from Employee__c where id in:empList];
      map<id,string> mapEmpIdName=new map<id,string>();
      for(Employee__c emp : empIdNList){
         mapEmpIdName.put(emp.id,emp.name);
         system.debug('*emp.id'+emp.id);
      }
      toaCapacity.get_quota_data_bucket_element[] quotaResp=getCapacityRes.getBuckClosure(empList,startDate,endDate);
      system.debug('*quotaResp'+quotaResp);
     
    if(quotaResp!=null)
    {     
          OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
        for(toaCapacity.get_quota_data_bucket_element BuckResp: quotaResp)
        {
             newRec.recordtypeid=recordTypeId;
             if(BuckResp.name!=null){
             newRec.Bucket_Name__c=BuckResp.name;
             }
            for(toaCapacity.get_quota_data_day_element DayElements : BuckResp.day)
            { 
                 if(DayElements !=null){
                 newRec.Date__c=DayElements.date_x;
                  system.debug('@@DayElements'+DayElements );
                  }
                for(toaCapacity.get_quota_data_time_slot_element TimeElements : DayElements.time_slot)
                {
                    if(TimeElements.label!=null){
                    newRec.Time_Slot_label__c=TimeElements.label;
                    }
                    for(toaCapacity.get_quota_data_category_element catele : TimeElements.category )
                    {
                      
                        if(catele!=null)
                        {
                         if(catele.closed_at!=null)
                         {
                          system.debug('@@Time Cateogy-closed at'+catele.closed_at); 
                         newRec.Closed_At_Category__c=DateTime.valueOf(catele.closed_at);
                         newRec.Slot_Type__c=catele.label;
                         }
                         if(catele.close_time!=null)
                         {
                         system.debug('@@Time Cateogy-close time'+catele.close_time);
                         newRec.Close_Time_Category__c=DateTime.valueOf(catele.close_time);
                         newRec.Slot_Type__c=catele.label;
                         system.debug('@@catele.label'+catele.label);
                         
                         }
                         if(catele.quota_percent!=null)
                         {
                         newRec.Quota_Percent__c=Integer.valueOf(catele.quota_percent);
                         system.debug('@@Time Cateogy-quota per'+catele.quota_percent);
                         }
                         if(catele.status!=null)
                         {
                         newRec.Category_status__c=Integer.valueOf(catele.status);
                         system.debug('@@Time Cateogy-status'+catele.status);
                         }
                        if(catele.work_zone!=null)
                         {
                            for(toaCapacity.get_quota_data_work_zone_element zone : catele.work_zone)
                               {
                                   if(zone .closed_at!=null){
                                   system.debug('@@work Zone.closed_At'+zone.closed_at);
                                     newRec.Work_Zone_Closed_At__c=DateTime.valueOf(zone.closed_at);
                                     newRec.Work_Zone__c=zone.label;
                                   }
                                   if(zone.close_time!=null)
                                   {
                                     system.debug('@@work zone.closed_time'+zone.close_time);
                                     newRec.Close_Time_Category__c=DateTime.valueOf(catele.close_time);
                                     newRec.Work_Zone__c=zone.label;
                                      system.debug('@@zone.label'+zone.label);
                                     
                                   }
                                
                               }
                         }
                        }
                   }
                }
            }
            newRec.External_ID__c=Utilities.popluateExternalId(newRec);
            if(newRec.Close_Time_Category__c!=null || newRec.Closed_At_Category__c!=null){
                       listQuotaData.add(newRec);
                      }
               system.debug('@@listQuotaData'+listQuotaData);
         } 
          
    
      }
       if(listQuotaData.size()>0){
        system.debug('@*listQuotaData.size()'+listQuotaData.size());
        Database.UpsertResult[] upsertResult = Database.upsert(listQuotaData,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),False);
        system.debug('listQuotaData='+listQuotaData);
        
        integer i = 0;
        list<string> duplicateStrings = new list<string>();
        list<OFS_Quota_Data__c> finalList  = new list<OFS_Quota_Data__c>();
        
        for(Database.UpsertResult e : upsertResult)
        {
            system.debug('Result -->'+e);
            if(!e.isSuccess())
            {
                duplicateStrings.add(listQuotaData[i].External_ID__c);
                finalList.add(listQuotaData[i]);
               

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
        
      }
    
    
    }
    
    }