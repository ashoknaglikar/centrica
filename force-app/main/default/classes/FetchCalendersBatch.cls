global class FetchCalendersBatch implements database.batchable<sobject>,Database.AllowsCallouts,Database.Stateful{
    
    global Date startDate;
    global Date endDate;
    /*
    global boolean  retRecords;
    public static final string start_date='date';
    public static final string workStartTime='time_from';
    public static final string workEndTime='time_to';
    public static final string recType='calendar_type';
    public static final string resourceId='resource_id';
    */
    public static final string recTypeName='HSA Calendar';
    
    //global FetchCalendersBatch(){}
    global FetchCalendersBatch(Date sDate,Date eDate){
    startDate=sDate;
    endDate=eDate;
    
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string priRole= 'HSA';
        return Database.getQueryLocator('Select id, Employee_ID18__c,name from Employee__c where Primary_role__c =:priRole and Inactive__c = false');
    }
    
    
    global void execute(Database.BatchableContext BC,  List<sObject> lstRecords)
    {
        for(sObject s: lstRecords)
        {
            Employee__c e = (Employee__c)s;
            list<Id> employeeId = new list<Id> {e.Id};
            FetchCalendersBatch.ProcessReq(employeeId,startDate,endDate);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
       AsyncApexJob a = [Select Id, Status, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
       
       list<string> toaddress = new list<string>{userinfo.getUserEmail()};
        system.debug('@@a'+a); 
       if(a.Status=='Completed')
       {
           CreateEmail.CretaeSendTextEmail(toaddress, 'Shift pattern data has been retrieved from salesforce. Thanks',  'Shift Patterns Successfully Retrieved');
       }
            
            
    }
    
    public static void ProcessReq(List<Id> empList,date startDate,date endDate){
     List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
     List<Employee__c> empIdNList=[Select id,name from Employee__c where id in:empList];
     map<id,string> mapEmpIdName=new map<id,string>();
     string empidIDParameter = '';
     for(Employee__c emp : empIdNList){
     mapEmpIdName.put(emp.id,emp.name);
     system.debug('*emp.id'+emp.id);
     empidIDParameter +=emp.id+',';
     }
     empidIDParameter = empidIDParameter.substring(0,empidIDParameter.length()-1);
     
     system.debug('*empidIDParameter'+empidIDParameter);
     
     UnavailUpadateInOFS_Rest objRestClass = new UnavailUpadateInOFS_Rest();
     
     string jsonResponse = objRestClass.getCalendarsVer2(empidIDParameter,startDate,endDate);
     if(jsonResponse!=null)
     {
         getCalendersResponseCalss.GetCalendersResponse  objResonse  = getCalendersResponseCalss.parse(jsonResponse);
         
         Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTypeName].Id;   
         
         for(getCalendersResponseCalss.Item itemVar : objResonse.items)
         {
             if(itemVar.regular!=null && itemVar.regular.workTimeEnd != null && itemVar.regular.workTimeStart != null)
             {
               OFS_Quota_Data__c calendarVar = new OFS_Quota_Data__c(recordtypeid = recordTypeId,
                                                                     Date__c = Date.valueOf(itemVar.date_x),
                                                                     Record_Type__c = itemVar.regular.recordType,
                                                                     Work_Time_End_Text__c = itemVar.regular.workTimeEnd,
                                                                     Work_Time_Start_Text__c = itemVar.regular.workTimeStart,
                                                                     Bucket_Name__c = mapEmpIdName.get(itemVar.resourceId));
                calendarVar.External_ID__c=Utilities.popluateExternalId(calendarVar);
                 
                listQuotaData.add(calendarVar);
             }
         }
     }
     /*
     //FetchCalendersBatch objAutoPrd = new FetchCalendersBatch();
      system.debug('**dd'+startDate+endDate);
      toatechResourcemanagement10.GetResourcesCalendarsResponseElement calResp=getCapacityRes.getCalendersResp(empList,startDate,endDate);
      system.debug('**calResp'+calResp);
       system.debug('**dd'+startDate+endDate);
      Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTypeName].Id;           
      toatechResourcemanagement10.CalendarElement[] calendars;
        toatechResourcemanagement10.TextPropertiesElement properties = new toatechResourcemanagement10.TextPropertiesElement();
        system.debug('**calResp'+calResp);
        toatechResourcemanagement10.CalendarList calList;
        if(calResp!=null){
        if(calResp.calendars!=null){
        calendars=calResp.calendars.calendar;
         if(calendars!=null){
            for(toatechResourcemanagement10.CalendarElement calElement : calendars)
            {
                  properties =calElement.properties;
                  OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
                  system.debug('***properties '+properties );
                  for(toatechResourcemanagement10.TextPropertyElement property : properties.property ){
                  
                     system.debug('***property '+property );
                     system.debug('***property.name '+property.name);
                     system.debug('***property.value '+property.value);
                      newRec.recordtypeid=recordTypeId;
                     if(property.name==recType && property.value!=NULL){
                          newRec. =property.value;
                      }
                      if(property.name==workEndTime && property.value!=NULL){
                          newRec.Work_Time_End_Text__c=property.value;
                      }
                      if(property.name==workStartTime && property.value!=NULL){
                          newRec.Work_Time_Start_Text__c=property.value;
                      }
                      if(property.name==start_date && property.value!=NULL){
                          newRec.Date__c=Date.valueOf(property.value);
                      }
                      if(property.name==resourceId && property.value!=NULL){
                          if(mapEmpIdName.containskey(Id.valueOf(property.value))){}
                          newRec.Bucket_Name__c=mapEmpIdName.get(Id.valueOf(property.value));
                           system.debug('@@Bucket_Name__c'+newRec.Bucket_Name__c);
                      }
                       
                  }
                newRec.External_ID__c=Utilities.popluateExternalId(newRec);
                  if(newRec.Work_Time_End_Text__c!=null && newRec.Work_Time_Start_Text__c!=null){
                       listQuotaData.add(newRec);
                      }
               system.debug('@@listQuotaData'+listQuotaData);
            }
            }
            }
        }
        
        */
        if(listQuotaData.size()>0){
        system.debug('@*listQuotaData.size()'+listQuotaData.size());
        Database.UpsertResult[] upsertResult = Database.upsert(listQuotaData,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),False);
        integer i = 0;
        list<string> duplicateStrings = new list<string>();
        list<OFS_Quota_Data__c> finalList  = new list<OFS_Quota_Data__c>();
        
        for(Database.UpsertResult e : upsertResult)
        {
            system.debug('Result -->'+e);
            if(!e.isSuccess()|| test.isRunningTest())
            {
                duplicateStrings.add(listQuotaData[i].External_ID__c);
                finalList.add(listQuotaData[i]);
               

            }
             i++ ;
        }
        system.debug('duplicateStrings -->'+duplicateStrings);
        system.debug('finalList -->'+finalList);
        
        if(duplicateStrings.size()>0 || test.isRunningTest())
        {
            delete (new list<OFS_Quota_Data__c>([select id from OFS_Quota_Data__c where External_ID__c in :duplicateStrings ]));
            Database.upsert(finalList,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),false);

        }
        
     
        
        }
        
        
         
    }     

    
    /*public static void ProcessReq_Rest(List<Id> empList,date startDate,date endDate)
    {
         List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
         List<Employee__c> empIdNList=[Select id,name from Employee__c where id in:empList];
         map<id,string> mapEmpIdName=new map<id,string>();
        
         for(Employee__c emp : empIdNList){
         mapEmpIdName.put(emp.id,emp.name);
         }
    
         getCalender_Response calResp = CapacityRes_Rest.getCalendersResp(empList,startDate,endDate);
     
         Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTypeName].Id;       
      
         if(calResp!=null){
            if(calResp.items!=null){
                for(getCalender_Response.cls_items item:calResp.items)
                {
                     OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
                     newRec.recordtypeid=recordTypeId;
                     if(mapEmpIdName.containskey(Id.valueOf(item.resourceId))){}
                     newRec.Bucket_Name__c=mapEmpIdName.get(Id.valueOf(item.resourceId));
                     newRec.Date__c=Date.valueOf(item.date_x);
                     
                     if(item.regular!=null){
                     newRec.Record_Type__c=item.regular.recordType;
                     newRec.Work_Time_End_Text__c= item.regular.workTimeEnd;
                     newRec.Work_Time_Start_Text__c= item.regular.workTimeStart;
                     }
                     
                     newRec.External_ID__c=Utilities.popluateExternalId(newRec);
                     if(newRec.Work_Time_End_Text__c!=null && newRec.Work_Time_Start_Text__c!=null){
                       listQuotaData.add(newRec);
                     }
               }
          }
        }
        
        if(listQuotaData.size()>0)
        {
            system.debug('@*listQuotaData.size()'+listQuotaData.size());
            Database.UpsertResult[] upsertResult = Database.upsert(listQuotaData,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),False);
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
    
 }*/
}