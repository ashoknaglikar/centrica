//The apex class to create/update work zones in OFS whenever sub patches are created or updated in salesforce
global class WorkZoneUpdateBatch implements database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful
{
    public string status = 'Ready To Be Picked Up';
    public string statDeact = 'Deactivated';
    public map<string, SubPatchWrapper> supPatchWrapperMap = new  map<string, SubPatchWrapper>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('select id,Code__c, Name,Type__c,OFS_WZ_Status__c,district__r.region__r.name,OFS_WZ_Sub_Status__c,Old_Subpatch_OFS__c from Sub_Patch__c where OFS_WZ_Status__c=:status');// /*OR Number_of_PCS_Modified__c>0'); //  where OFS_Keys_Status__c =:status   
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords)
    {
        List<SubPatchWrapper> subPWrapList = new  List<SubPatchWrapper>();
        subPWrapList = WorkZoneUpdateBatch.getWorkZones();
        // create map between workzonelabel & workzone record.
        for(SubPatchWrapper wrapper: subPWrapList)
        {
            supPatchWrapperMap.put(wrapper.workZoneLabel, wrapper);
        }
        
        
        list<Sub_Patch__c> updateList = new  list<Sub_Patch__c>();
        list<Id> SubPatchId = new  List<Id>();
        for(sObject s: lstRecords)
        {
            SubPatchId.add(s.Id);
        }
        Map<string, List<string>> subPatchPostCodeMap = new  Map<string, List<string>>();
        for(Postcode_Sector__c p: [SELECT id, 
            Name, 
            Sub_Patch__r.Code__c
        FROM
            postcode_sector__c
        WHERE
            Sub_Patch__c in: SubPatchId AND Type__c = 'Sales'])
        {
            if(subPatchPostCodeMap.containsKey(p.Sub_patch__r.Code__c))
            {
                list<string> temp = subPatchPostCodeMap.get(p.Sub_Patch__r.Code__c);
                temp.add(p.Name);
                subPatchPostCodeMap.put(p.Sub_Patch__r.Code__c, temp);
            }
            else
            {
                subPatchPostCodeMap.put(p.Sub_Patch__r.Code__c, new list<string>{p.Name});
            }
        }
        if(lstRecords != null)
        {
            for(sObject s: lstRecords)
            {
                Sub_Patch__c e = (Sub_Patch__c)s;
                subPWrapList.clear();
                Sub_Patch__c tempRecord;
                if(!supPatchWrapperMap.containskey(e.Code__c))
                {
                    tempRecord = WorkZoneUpdateBatch.createWorkZones(e, supPatchWrapperMap, subPatchPostCodeMap.get(e.Code__c));
                }
                if(supPatchWrapperMap.containskey(e.Code__c))
                {
                    tempRecord = WorkZoneUpdateBatch.updateWorkZones(e, supPatchWrapperMap, subPatchPostCodeMap.get(e.Code__c));
                    system.debug('***tempRecord'+tempRecord);
                }
                if(e.OFS_WZ_Sub_Status__c == statDeact && e.OFS_WZ_Status__c == status)
                {
                    tempRecord = WorkZoneUpdateBatch.deactivateWorkZones(e, subPWrapList);
                }
                system.debug('tempRecord -->' + tempRecord);
                if(tempRecord != null)
                {
                    updateList.add(tempRecord);
                }
            }
            if(updateList.size() > 0)
            {
                Update updateList;
            }
        }
    }
    
    
    
    global void finish(Database.BatchableContext bc)
    {
        
        integer countConflict = [SELECT
            count()
        FROM
            Sub_Patch__c
        WHERE
            OFS_WZ_Status__c = 'Conflict' AND LastModifiedById = : userinfo.getUserid()];
        CreateEmail.CretaeSendTextEmail(new list<string>{userinfo.getUserEmail()}, 'Work Zones have been Updated. Please visit this report for Conflicts. ' + system.label.WorkZoneConflictReport, 'Workzone Update Finished. Conflict Count :' + countConflict);
        
    }
    
    
    //Method to get all active work zones from OFS
    public static List<SubPatchWrapper> getWorkZones()
    {
        SubPatchUpadateInOFS_Rest sPatchRest = new  SubPatchUpadateInOFS_Rest();
        List<SubPatchWrapper> subWrapList = new  List<SubPatchWrapper>();
        string jSonList = sPatchRest.getWorkZonesOFS();
        SubPatchWrapResp subPWrapList = (SubPatchWrapResp)JSON.deserialize(jSonList, SubPatchWrapResp.Class);
        if(subPWrapList != null)
        {
            for(SubPatchWrapper subWrap: subPWrapList.items)
            {
                if(subWrap.status == 'active')
                {
                    subWrapList.add(subWrap);
                }
            }
            return subWrapList;
        }
        return null;
    }
    
    
    //Method to create work zones in OFS
    public static Sub_Patch__c createWorkZones(Sub_Patch__c patch, map<string, SubPatchWrapper> supPatchWrapperMap, list<string> keys)
    {
        string travelAreas = patch.district__r.region__r.name;
        string wzLabel = patch.Code__c.replace(' ', '_');
        if(!supPatchWrapperMap.containskey(wzLabel) && travelAreas != null)
        {
            SubPatchUpadateInOFS_Rest sPatchRest = new  SubPatchUpadateInOFS_Rest();
            SubPatchWrapper patchWrap = new  SubPatchWrapper(wzLabel, patch.name, 'active', travelAreas, keys);
            string jSonList = sPatchRest.createUpdateWorkZonesOFS(patchWrap, null);
            workzoneRestresponseObj response = (workzoneRestresponseObj)JSON.deserialize(jSonList, workzoneRestresponseObj.Class);
            try
            {
                if(response != null)
                {
                    if(response.status == '200')
                    {
                        patch.OFS_WZ_Status__c = 'Completed';
                        patch.OFS_WZ_Sub_Status__c = 'Completed';
                    }
                    else if(response.status == '409' && response.title == 'Conflict' )
                    {
                      //string errorMsg='Work Zone'+' '+'with label'+' '+'\''+wzLabel+'\''+' '+ 'already exists';
                     string errorMsg=System.label.Duplicate_Work_Zone1+' '+'\''+wzLabel+'\''+' '+ System.label.Duplicate_Work_Zone2;
                     
                      if(response.detail.contains(errorMsg)){
                       Sub_Patch__c  updateRecord = WorkZoneUpdateBatch.updateWorkZones(patch, supPatchWrapperMap, keys);
                       system.debug('***updateRecord'+updateRecord);
                      }
                    }
                    else
                    {
                        patch.OFS_WZ_Status__c = response.title;
                        patch.OFS_WZ_Sub_Status__c = response.detail.length() >= 100 ? response.detail.substring(0, 100) : response.detail;
                    }
                    return patch;
                }
            }
            catch(Exception e)
            {
            }
        }
        return null;
    }
    
    
    //Method to update work zones in OFS
    public static Sub_Patch__c updateWorkZones(Sub_Patch__c patch, map<string, SubPatchWrapper> supPatchWrapperMap, list<string> keys)
    {
        SubPatchUpadateInOFS_Rest sPatchRest = new  SubPatchUpadateInOFS_Rest();
        string wzLabel = patch.Code__c.replace(' ', '_');
        SubPatchWrapper wrapperPatch = new  SubPatchWrapper(wzLabel, patch.name, 'active', patch.District__r.Region__r.Name, keys);
        string jSonList = sPatchRest.createUpdateWorkZonesOFS(wrapperPatch, wzLabel);
        workzoneRestresponseObj response = (workzoneRestresponseObj)JSON.deserialize(jSonList, workzoneRestresponseObj.Class);
        try
        {
            if(response != null)
            {
                if(response.status == 'active')
                {
                    patch.OFS_WZ_Status__c = 'Completed';
                    patch.OFS_WZ_Sub_Status__c = 'Completed';
                }
                else
                {
                    patch.OFS_WZ_Status__c = response.title;
                    patch.OFS_WZ_Sub_Status__c = response.detail.length() >= 100 ? response.detail.substring(0, 100) : response.detail;
                }
                return patch;
            }
        }
        catch(Exception ex)
        {
        }
        return null;
    }
    
    //Method to deactivate work zones in OFS
    public static Sub_Patch__c deactivateWorkZones(Sub_Patch__c e, List<SubPatchWrapper> subPWrapList)
    {
        SubPatchUpadateInOFS_Rest sPatchRest = new  SubPatchUpadateInOFS_Rest();
        for(SubPatchWrapper sPatchw: subPWrapList)
        {
            if(sPatchw.workZoneName == e.name && e.Type__c != 'Sales')
            {
                SubPatchWrapper patch = new  SubPatchWrapper(sPatchw.workZoneName, sPatchw.workZoneLabel, 'inactive', sPatchw.travelArea, sPatchw.keys);
                string jSonList = sPatchRest.createUpdateWorkZonesOFS(patch, sPatchw.workZoneLabel);
                workzoneRestresponseObj response = (workzoneRestresponseObj)JSON.deserialize(jSonList, workzoneRestresponseObj.Class);
                try
                {
                    if(response != null)
                    {
                        if(response.status == 'inactive')
                        {
                            e.OFS_WZ_Status__c = 'Deactivated';
                            e.OFS_WZ_Sub_Status__c = 'Deactivated';
                        }
                        else
                        {
                            e.OFS_WZ_Status__c = response.title;
                            e.OFS_WZ_Sub_Status__c = response.detail.length() >= 100 ? response.detail.substring(0, 100) : response.detail;
                        }
                        return e;
                    }
                }
                catch(Exception ex)
                {
                }
            }
        }
        return null;
    }
    
    //This is wrapper class to serialize request in order to hit to OFS
    public class SubPatchWrapper
    {
        public string workZoneLabel
        {
            get;set;
        }
        public string workZoneName
        {
            get;set;
        }
        public string status
        {
            get;set;
        }
        public string travelArea
        {
            get;set;
        }
        public List<string> keys
        {
            get;set;
        }
        public SubPatchWrapper(string workZoneLabel, string workZoneName, string status, string travelArea, List<string> keys)
        {
            this.workZoneLabel = workZoneLabel;
            this.workZoneName = workZoneName;
            this.status = status;
            this.travelArea = travelArea;
            this.keys = keys;
        }
        public SubPatchWrapper(string workZoneLabel, string workZoneName, string status, string travelArea)
        {
            this.workZoneLabel = workZoneLabel;
            this.workZoneName = workZoneName;
            this.status = status;
            this.travelArea = travelArea;
        }
    }
    //This class holds deserialized response from OFS
    public class SubPatchWrapResp
    {
        public boolean hasMore
        {
            get;set;
        }
        public Integer totalResults
        {
            get;set;
        }
        public Integer offset
        {
            get;set;
        }
        public List<SubPatchWrapper> items;
        public SubPatchWrapResp()
        {
        }
    }
    
    
    public class Links
    {
        public string rel
        {
            get;set;
        }
        public string href
        {
            get;set;
        }
    }
    
    //This is class to hold the status and type of each response from OFS for POST/PUT/GET call
    public class workzoneRestresponseObj
    {
        public string type
        {
            get;set;
        }
        public string status
        {
            get;set;
        }
        public string title
        {
            get;set;
        }
        public string detail
        {
            get;set;
        }
    }
}