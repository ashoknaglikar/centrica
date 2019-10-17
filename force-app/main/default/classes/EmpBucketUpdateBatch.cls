//The batch apex class is used to get employee's bucket from OFS
global class EmpBucketUpdateBatch implements database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful
{
    public static final string recTName='Employee Bucket Info';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string priRole='OFS Bucket';
        
        return Database.getQueryLocator('Select id,name, Employee_ID18__c  from Employee__c where Primary_role__c =:priRole and Inactive__c = false ');  
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords)
    {
        map<string,string> mapX18EmpIdName=new map<string,string>();
        mapX18EmpIdName=getCapacityRes.getEmployeeIDandNameMap();
        List<OFS_Quota_Data__c> listQuotaData=new  List<OFS_Quota_Data__c>();
        if(lstRecords != null)
        {
            for(sObject s: lstRecords)
            {
                Employee__c e = (Employee__c )s;
                List<OFS_Quota_Data__c> listQuota;
                system.debug('**e.id'+e.Employee_ID18__c + e.name);
                listQuota=EmpBucketUpdateBatch.ProcessRestReq(e.Employee_ID18__c,e.name,mapX18EmpIdName);
                if(listQuota!=null){
                    listQuotaData.addAll(listQuota);
                }
            }
            if(listQuotaData!=null){
                if(listQuotaData.size()>0){
                    
                    Database.UpsertResult[] upsertResult= Database.upsert(listQuotaData ,OFS_Quota_Data__c.External_ID__c.getDescribe().getSObjectField(),False );
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

                    system.debug('**listQuotaData'+ listQuotaData.size() +listQuotaData);
                }
            }
        }
    }
    
    
    
    global void finish(Database.BatchableContext bc)
    {
        CreateEmail.CretaeSendTextEmail(new list<string>{userinfo.getUserEmail()}, 'Employee bucket information is retrieved successfully','Employee bucket information');
    }
    public static List<OFS_Quota_Data__c> ProcessRestReq(string empId, string empName, map<string,string> mapX18EmpIdName){
        
        List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
        BucketWrapResp buckWrapList=new BucketWrapResp();
        Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTName].Id;  
        GetBucketUpdates_Rest getResource=new GetBucketUpdates_Rest(); 
        
        if(empId!=null){
            string respJson= getResource.getResourcesOFS(empId);
            
           
            if(respJson!=null){
                buckWrapList = (BucketWrapResp)JSON.deserialize(respJson, BucketWrapResp.Class);
            }
        }
        if(buckWrapList!=null && buckWrapList.items!=null){
            for(EmpBucketWrapper buckWrap: buckWrapList.items)
            {    
                OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
                newRec.recordtypeid=recordTypeId;
                newRec.Bucket_Name__c=mapX18EmpIdName.get(buckWrap.resourceId);
                newRec.Employee_s_bucket__c=empName;
                newRec.External_ID__c=Utilities.popluateExternalId(newRec);
                //if(newRec.Employee_s_bucket__c!=null){
                listQuotaData.add(newRec);
                // }                   
            }
        }
        if(listQuotaData.size()>0){
            return listQuotaData;
        }
        //system.debug('**listQuotaData'+ listQuotaData.size() +listQuotaData);
        return null;
    }    
    //This class holds deserialized response from OFS
    public class BucketWrapResp
    {
        
        public Integer totalResults
        {
            get;set;
        }
        public Integer offset
        {
            get;set;
        }
        public List<EmpBucketWrapper> items;
        public BucketWrapResp()
        {
        }
    }
    public class EmpBucketWrapper
    {
        public string name
        {
            get;set;
        }
        public string parentResourceId
        {
            get;set;
        }
        public string resourceId
        {
            get;set;
        }
        public EmpBucketWrapper(string name, string parentResourceId,String resourceId)
        {
            this.name= name;
            this.parentResourceId= parentResourceId;
            This.resourceId= resourceId;
        }
    }
    
}