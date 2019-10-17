public class getCapacityRes{
    public static string LastRequestTime{get;set;}
    public static boolean FirstTime;
    public static string  auth_string1;
    public static DateTime StartTime;
    public static final string recTName='Internal Activity';
    
    public static toaCapacity.capacity_response_element getCapacity(string[] Locaton,Date[] dates,string PostCodeSector,string czip,string ProductInterest){
        
        
        List<toaCapacity.activity_field_element> activity_field = new List<toaCapacity.activity_field_element>();
        List<List<string>> CapacRes = new List<List<string>>(); 
        List<toaCapacity.capacity_element> CapEle = new List<toaCapacity.capacity_element>();
        toaCapacity.user_element a = new toaCapacity.user_element();
        startTime = system.now();
        string now= string.valueof(startTime);
        string CDate= now.substring(0,10);
        string CTime= now.substring(11,19);
        string CDT= CDate+'T'+CTime+'Z';
        a.now = CDT;
        a.login= string.valueof(system.Label.toa_user);
        a.company= string.valueof(system.Label.toa_company);
        
        /*String pswd = string.valueof(system.Label.toa_password);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(pswd));
        String uniqueString = EncodingUtil.convertToHex(hash);
        string authstringbeforeMD5 = a.now+uniqueString;
        Blob authBlobafterMD5 = Crypto.generateDigest('MD5', Blob.valueOf(authstringbeforeMD5));
        auth_string1 = EncodingUtil.convertToHex(authBlobafterMD5);
        a.auth_string = auth_string1;*/
        
        a.auth_string = formAuth_string(a.now);
        
        system.debug(a.auth_string);
        Date[] date_x = dates;
        String[] location = locaton; // Bucket external Id GreenWitch & Sutton
        Boolean calculate_duration=false; // this not used as we are setting this from salesforce
        Boolean calculate_travel_time=true; // Not needed
        Boolean calculate_work_skill=false; // this is
        Boolean return_time_slot_info=true; // AM PM EV
        Boolean determine_location_by_work_zone=false;
        Boolean dont_aggregate_results=true;
        Integer min_time_to_end_of_time_slot=125; // more info needed
        //Integer default_duration=60; // not needed
        //String[] time_slot=new string[]{'13-17'}; // used when you need specific time slots
        /*
String[] work_skill=new string[]{'standard_cc','Commercial'}; // used in case of multiple skills

if(TOA_Product_Interest__c.getInstance(ProductInterest).Capacity_Category__c != null)
{
work_skill.clear();  
work_skill.addall(TOA_Product_Interest__c.getInstance(ProductInterest).Capacity_Category__c.split(';'));
}*/
        
        
        if(PostCodeSector != '' || PostCodeSector != 'NULL'){
            toaCapacity.activity_field_element activity_field2 = new toaCapacity.activity_field_element();  
            activity_field2.name = 'XA_Post_Code_Sector';
            activity_field2.value = PostCodeSector;
            activity_field.add(activity_field2);
        }
        /*
if(ProductInterest != '' || ProductInterest != 'NULL'){
toaCapacity.activity_field_element activity_field3 = new toaCapacity.activity_field_element();  
activity_field3.name = 'XA_Product_Interest';
activity_field3.value = ProductInterest;
activity_field.add(activity_field3);
}
*/
        if(czip != '' || czip != 'NULL'){
            toaCapacity.activity_field_element activity_field4 = new toaCapacity.activity_field_element();  
            activity_field4.name = 'czip';
            activity_field4.value = czip;
            activity_field.add(activity_field4);
        }
        
        
        
        toaCapacity.toa_capacity_interface b = new toaCapacity.toa_capacity_interface();
        toaCapacity.capacity_response_element capRes=b.get_capacity(a,date_x,location,calculate_duration,calculate_travel_time,calculate_work_skill,
                                                                    return_time_slot_info,determine_location_by_work_zone,dont_aggregate_results,min_time_to_end_of_time_slot,
                                                                    null,null,null,activity_field);
        
        system.debug('Response Recieved -- >'+capRes);
        return capRes;
    }
    
    //GetQuotaData
    public static toaCapacity.get_quota_data_bucket_element[] getQuotaData(Date[] dates,string[] resourceId){
        
        
        toaCapacity.user_element a = new toaCapacity.user_element();
        startTime = system.now();
        string now= string.valueof(startTime);
        string CDate= now.substring(0,10);
        string CTime= now.substring(11,19);
        string CDT= CDate+'T'+CTime+'Z';
        a.now = CDT;
        a.login= string.valueof(system.Label.toa_user);
        a.company= string.valueof(system.Label.toa_company); 
        
        /*String pswd = string.valueof(system.Label.toa_password);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(pswd));
        String uniqueString = EncodingUtil.convertToHex(hash);
        string authstringbeforeMD5 = a.now+uniqueString;
        Blob authBlobafterMD5 = Crypto.generateDigest('MD5', Blob.valueOf(authstringbeforeMD5));
        auth_string1 = EncodingUtil.convertToHex(authBlobafterMD5);
        a.auth_string = auth_string1;*/
        
        a.auth_string = formAuth_string(a.now);
        system.debug(a.auth_string);
        
        Date[] date_x = dates;
        String[] resource_id = resourceId;
        Boolean aggregate_results = false;//Aggregate Results when this is mark as True
        Boolean calculate_totals = True;
        //String[] time_slot;
        //String[] category;
        //String[] day_quota_field;
        String[] time_slot_quota_field = new string[]{'other_activities'};
            String[] category_quota_field = new string[]{'max_available','quota','count','used'};
                //String[] work_zone_quota_field;
                
                toaCapacity.toa_capacity_interface b = new toaCapacity.toa_capacity_interface();
        toaCapacity.get_quota_data_bucket_element[] Resp=b.get_quota_data(a,date_x,resource_id ,aggregate_results ,calculate_totals ,
                                                                          null,null,null,time_slot_quota_field ,category_quota_field ,null);
        
        return  resp;
    }
    
    
    
    public static toatechResourcemanagement10.GetResourcesCalendarsResponseElement getCalendersResp(List<Id> empList,Date startDate,Date endDate)
    {
        system.debug('**tt'+startDate+endDate);
        List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
        startTime = system.now();
        Integer numberDaysDue ;
        string now= string.valueof(startTime);
        string CDate= now.substring(0,10);
        string CTime= now.substring(11,19);
        string CDT= CDate+'T'+CTime+'Z';
        /*String pswd = string.valueof(system.Label.toa_password);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(pswd));
        String uniqueString = EncodingUtil.convertToHex(hash);
        string authstringbeforeMD5 = CDT+uniqueString;
        Blob authBlobafterMD5 = Crypto.generateDigest('MD5', Blob.valueOf(authstringbeforeMD5));
        auth_string1 = EncodingUtil.convertToHex(authBlobafterMD5);*/
        
        toatechResourcemanagement10.ResourceManagementPort resManPort=new toatechResourcemanagement10.ResourceManagementPort();
        toatechResourcemanagement10.AuthNodeElement user_x=new toatechResourcemanagement10.AuthNodeElement();
        user_x.now= CDT;
        user_x.login=string.valueof(system.Label.toa_user);
        user_x.company=string.valueof(system.Label.toa_company);
        //user_x.auth_string=auth_string1;
        user_x.auth_string = formAuth_string(CDT);
        toatechResourcemanagement10.GetResourcesParamsElement[] resElementList=new List<toatechResourcemanagement10.GetResourcesParamsElement>();
        toatechResourcemanagement10.GetResourcesParamsElement resElement;
        toatechResourcemanagement10.GetResourcesParamsList resources=new toatechResourcemanagement10.GetResourcesParamsList();
        for(Id resourceId : empList){
            resElement=new  toatechResourcemanagement10.GetResourcesParamsElement();
            resElement.resource_id=resourceId;
            resElement.date_x=string.valueOf(startDate);
            resElement.include_inactive=string.valueOf(false);
            numberDaysDue = startDate.daysBetween(endDate);
            resElement.duration=numberDaysDue;
            resElementList.add(resElement);
        }
        
        toatechResourcemanagement10.GetResourcesParamsElement[] resElements=resElementList;
        resources.resource=resElements;
        toatechResourcemanagement10.GetResourcesCalendarsResponseElement calResp=resManPort.get_resources_calendars(user_x,resources);
        return calResp;
    }
    
    public static toaCapacity.get_quota_data_bucket_element[] getBuckClosure(List<Id> empList,Date startDate,Date endDate)
    {
        startTime = system.now();
        Integer numberDaysDue;
        string now= string.valueof(startTime);
        string CDate= now.substring(0,10);
        string CTime= now.substring(11,19);
        string CDT= CDate+'T'+CTime+'Z';
        /*String pswd = string.valueof(system.Label.toa_password);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(pswd));
        String uniqueString = EncodingUtil.convertToHex(hash);
        string authstringbeforeMD5 = CDT+uniqueString;
        Blob authBlobafterMD5 = Crypto.generateDigest('MD5', Blob.valueOf(authstringbeforeMD5));
        auth_string1 = EncodingUtil.convertToHex(authBlobafterMD5);*/
        
        toaCapacity.user_element  user_x =new toaCapacity.user_element();
        user_x.now=CDT;
        user_x.login=string.valueof(system.Label.toa_user);
        user_x.company=string.valueof(system.Label.toa_company);
        //user_x.auth_string=auth_string1;
        user_x.auth_string = formAuth_string(CDT);
        Integer numberDaysDiff = startDate.daysBetween(endDate);
        
        list<Date> DateList = new list<Date>();
        while(startDate <= endDate)
        {
            DateList.add(startDate);
            StartDate = startDate.adddays(1);
        }  
        DateList.add(startDate);
        system.debug('**DateList'+DateList);
        
        Date[] date_x = DateList;    
        String[] resource_id;
        if(empList.size()>0){
            for(ID empId : empList ){
                resource_id=new string[]{string.valueOf(empId)};
                    }
        }
        
        String[] time_slot=new String[]{'AM'};
            String[] category_quota_field = new string[]{'quota_percent','status','close_time','closed_at'};
                String[]  day_quota_field=new string[]{'date_x'};
                    String[]  work_zone_quota_field=new string[]{'status','close_time','closed_at'};
                        String[]  time_slot_quota_field=new string[]{'quota_percent'};
                            //Integer numberDaysDiff = startDate.daysBetween(endDate);
                            toaCapacity.toa_capacity_interface b = new toaCapacity.toa_capacity_interface();
        toaCapacity.get_quota_data_bucket_element[] listQuotaResp=b.get_quota_data(user_x,date_x,resource_id,null ,null,
                                                                                   null,null,null,time_slot_quota_field,category_quota_field,work_zone_quota_field);
        
        system.debug('@@listQuotaResp'+listQuotaResp);
        
        
        
        return listQuotaResp;
        
        
    }
    
    public static void getInternalActivity(Date startDate,Date endDate)
    {
        startTime = system.now();
        string now= string.valueof(startTime);
        string CDate= now.substring(0,10);
        string CTime= now.substring(11,19);
        string CDT= CDate+'T'+CTime+'Z';
        
       /* String pswd = string.valueof(system.Label.toa_password);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(pswd));
        String uniqueString = EncodingUtil.convertToHex(hash);
        string authstringbeforeMD5 = CDT+uniqueString;
        Blob authBlobafterMD5 = Crypto.generateDigest('MD5', Blob.valueOf(authstringbeforeMD5));
        auth_string1 = EncodingUtil.convertToHex(authBlobafterMD5);*/
        
        toaActivity.user_x user_x =new toaActivity.user_x();
        user_x.now=CDT;
        user_x.login=string.valueof(system.Label.toa_user);
        user_x.company=string.valueof(system.Label.toa_company);
        //user_x.auth_string=auth_string1;
        user_x.auth_string = formAuth_string(CDT);
        toaActivity.activity toaAct=new  toaActivity.activity();
        Date date_from=startDate;
        Date date_to= endDate;
        String[] property_filter=new String[]{'id','resource_id', 'date','name', 'type', 'status', 'activitytype', 'duration','XA_duration', 'start_time','end_time','time_zone','time_of_assignment','time_of_booking','worktype'};
            toaActivity.activity_response actRespList=toaAct.search_activities(user_x,'XA_internal','Internal',string.valueOf(date_from),string.valueOf(date_to),string.valueOf(1),string.valueOf(9000),'desc',property_filter);
        system.debug('**actRespList'+actRespList);
        
        //return actRespList;
        List<Employee__c> empIdNList=[Select id,name,Primary_role__c ,Inactive__c  from Employee__c where Primary_role__c = 'HSA' and Inactive__c = false Limit 50000];
        map<string,string> mapEmpIdName=new map<string,string>();
        for(Employee__c emp : empIdNList){
            mapEmpIdName.put(string.valueOf(emp.id),emp.name);
            system.debug('*emp.id'+emp.id);
        }
        Set<Id> empIdList=new  Set<Id>();
        List<OFS_Quota_Data__c> listSearchAct=new List<OFS_Quota_Data__c>();
        Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTName].Id;      
        toaActivity.activities activityList;
        toaActivity.activity_list actList;
        if(actRespList!=null){
            toaActivity.activity_response actResp =actRespList;
            actList=actResp.activity_list;
            if(actList!=null){
                activityList=actList.activities;
            }
        }
        system.debug('**activityList'+activityList);
        if(activityList!=null)
        {
            if(activityList.activity!=null){
                for(toaActivity.activity_new newActList : activityList.activity )
                {
                    system.debug('**newActList'+newActList);
                    OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
                    for(toaActivity.property property : newActList.properties)
                    {
                      
                        newRec.recordtypeid=recordTypeId;
                        system.debug('**Name'+property.name);
                        system.debug('**Value'+property.value);
                        if(property.name=='type' && property.value!=NULL){
                            newRec.Activity_Type__c=property.value;
                            newRec.Record_Type__c=property.value;
                        }
                        if(property.name=='status' && property.value!=NULL && property.value != 'cancelled'){
                            newRec.Activity_Status__c=property.value;
                        } if(property.name=='status' && property.value!=NULL && property.value == 'cancelled')
                            break;
                        if(property.name=='id' && property.value!=NULL){
                            newRec.Activity_Id__c=string.valueOf(property.value);
                        }
                        if(property.name=='date' && property.value!=NULL){
                            newRec.Date__c=date.valueOf(property.value);
                        }
                        if(property.name=='duration' && property.value!=NULL){
                            newRec.AM_Internal_activities_hrs__c=Integer.valueOf(property.value);
                        }
                        if(property.name=='XA_duration' && property.value!=NULL){
                            newRec.Duration_Final__c=Integer.valueOf(property.value);
                        }
                        if(property.name=='start_time' && property.value!=NULL){
                            newRec.Activity_Start_Time__c=Datetime.valueOf(property.value);
                        }
                        if(property.name=='end_time' && property.value!=NULL){
                            newRec.Activity_End_Time__c =Datetime.valueOf(property.value);
                        }
                        if(property.name=='time_of_assignment' && property.value!=NULL){
                            newRec.time_of_assignment__c=Datetime.valueOf(property.value);
                        }
                        if(property.name=='time_of_booking' && property.value!=NULL){
                            newRec.time_of_booking__c=Datetime.valueOf(property.value);
                        }
                        if(property.name=='worktype' && property.value!=NULL){
                            newRec.Activity_Work_Type__c=OFSUnavailabilityReasons__c.getInstance(string.valueOf(property.value))!=null ? OFSUnavailabilityReasons__c.getInstance(string.valueOf(property.value)).Value__c:string.valueOf(property.value);
                            
                        }
                        
                        if(property.name=='resource_id' && property.value!=NULL){
                            if(mapEmpIdName.containskey(property.value.deleteWhitespace())){
                                newRec.Bucket_Name__c=mapEmpIdName.get(property.value.deleteWhitespace());
                                system.debug('@@Bucket_Name__c'+newRec.Bucket_Name__c);
                            }
                        }
                     }
                    newRec.External_ID__c=Utilities.popluateExternalId(newRec);
                    if(newRec.Activity_Status__c!='Cancelled' || newRec.Activity_Status__c!='cancelled'){
                        listSearchAct.add(newRec);
                    }
                }
            }
        }
        
        
        if(listSearchAct.size()>0){
            system.debug('**listSearchAct'+listSearchAct);
            system.debug('**listSearchAct.size'+listSearchAct.size());
            
            Database.UpsertResult[] upsertResult = Database.upsert(listSearchAct,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),False);
            integer i = 0;
            list<string> duplicateStrings = new list<string>();
            list<OFS_Quota_Data__c> finalList  = new list<OFS_Quota_Data__c>();
            
            for(Database.UpsertResult e : upsertResult)
            {
                system.debug('Result -->'+e);
                if(!e.isSuccess())
                {
                    duplicateStrings.add(listSearchAct[i].External_ID__c);
                    finalList.add(listSearchAct[i]);
                   

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
            system.debug('**End');
        }
    }
    
    public static Map<String,String> getEmployeeIDandNameMap(){
        string priRole='OFS Bucket';
        List<Employee__c> empIdNList=[Select id,name,Primary_role__c ,Inactive__c,Employee_ID18__c  from Employee__c where Primary_role__c = 'HSA' and Inactive__c = false Limit 50000];
        map<string,string> mapX18EmpIdName=new map<string,string>();
        for(sObject emp : empIdNList){
            mapX18EmpIdName.put((string)emp.get('Employee_ID18__c'),(String)emp.get('name'));
            
        } 
        return mapX18EmpIdName;
    } 
    
    //suguna
    //auth_string = SHA256(now + SHA256(CLIENT_SECRET+SHA256(CLIENT_ID)));
    public static String formAuth_string(String now)
    {
        string clientId = string.valueof(system.Label.toa_user);
        string clientSecret = string.valueof(system.Label.toa_password);
        
        Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(clientId));
        String uniqueString = EncodingUtil.convertToHex(hash);
        
        string authwithsecret = clientSecret+uniqueString;
        Blob authBlobwithsecret = Crypto.generateDigest('SHA-256', Blob.valueOf(authwithsecret));
        String uniqueString2 = EncodingUtil.convertToHex(authBlobwithsecret);
        
        String authstring = now+uniqueString2;
        Blob authBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(authstring));
        String uniqueString3 = EncodingUtil.convertToHex(authBlob);
        
        return uniqueString3;
    }
    
    
}