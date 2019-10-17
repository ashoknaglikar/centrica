//This is a batch class to create/update work zones in OFS whenever sub patch records are created/updated
global without sharing class workzoneKeyBatch implements database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful{
    public map<string, WorkZoneUpdateBatch.SubPatchWrapper> supPatchWrapperMap = new  map<string, WorkZoneUpdateBatch.SubPatchWrapper>();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        return Database.getQueryLocator('select id, Old_SubPatch__c from postcode_sector__c where Old_SubPatch__c!=null');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords)
    {
        List<WorkZoneUpdateBatch.SubPatchWrapper> subPWrapList = new  List<WorkZoneUpdateBatch.SubPatchWrapper>();
        subPWrapList = WorkZoneUpdateBatch.getWorkZones();
        // create map between workzonelabel & workzone record.
        for(WorkZoneUpdateBatch.SubPatchWrapper wrapper: subPWrapList)
        {
            supPatchWrapperMap.put(wrapper.workZoneLabel, wrapper);
        }
        list<Sub_Patch__c> oldSubPathcList = new  list<Sub_Patch__c>();
        list<Id> SubPatchId = new  List<Id>();
        list<postcode_sector__c> updateList = new list<postcode_sector__c> ();
        
        Map<string, List<string>> subPatchPostCodeMap = new  Map<string, List<string>>();
        
        for(sObject s: lstRecords)
        {
            postcode_sector__c p = (postcode_sector__c)s;
            SubPatchId.add(p.Old_SubPatch__c);
            
            p.Old_SubPatch__c = null;
            updateList.add(p);
        }
        Map<string, Sub_Patch__c> subpatchMap = new  Map<string, Sub_Patch__c>();
        for(Sub_Patch__c s: [Select id, Name, Code__c, district__r.region__r.name from Sub_Patch__c where id in :SubPatchId])
        {
            subpatchMap.put(s.Code__c, s);
            subPatchPostCodeMap.put(s.Code__c, new list<string>());
        }
        system.debug('List of Sub Patches -->'+SubPatchId+subpatchMap);
        
        for(Postcode_Sector__c p: [SELECT id, 
            Name, 
            Sub_Patch__r.Code__c,
            Sub_Patch__c,
            Sub_Patch__r.Name
        FROM
            postcode_sector__c
        WHERE
            Sub_Patch__c in: SubPatchId AND Type__c = 'Sales' and Old_SubPatch__c = null])
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
                //subpatchMap.put(p.Sub_Patch__r.Code__c, new Sub_Patch__c(id = p.Sub_Patch__c, Name = p.Sub_Patch__r.Name, Code__c = p.Sub_Patch__r.Code__c));
            }
            
        
        }
        
        for(string s : subPatchPostCodeMap.keyset())
        {
            if(!supPatchWrapperMap.containskey(s))
            {
                WorkZoneUpdateBatch.createWorkZones(subpatchMap.get(s), supPatchWrapperMap, subPatchPostCodeMap.get(s));
            }
            if(supPatchWrapperMap.containskey(s))
            {
                WorkZoneUpdateBatch.updateWorkZones(subpatchMap.get(s), supPatchWrapperMap, subPatchPostCodeMap.get(s));
            }
                
        }
        
        update updateList;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        WorkZoneUpdateBatch workzoneObj = new WorkZoneUpdateBatch();
        ID batchprocessid = Database.executeBatch(workzoneObj,99);
    }
}