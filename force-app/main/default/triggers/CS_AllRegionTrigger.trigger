trigger CS_AllRegionTrigger on Region__c (after update, after insert, after delete) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isAfter && (Trigger.isUpdate || trigger.isinsert)) {
            map<id, Region__c> newRegionMap = new map<id, Region__c>();
            for(Region__c r: trigger.new)
            {
                if(r.Type__c != 'Sales') {
                    continue;
                }

                Boolean convertedToSalesType = Trigger.isUpdate && trigger.oldMap.get(r.Id).Type__c != 'Sales' && trigger.newMap.get(r.Id).Type__c == 'Sales';
                Boolean toBeInserted         = Trigger.isInsert;

                if(convertedToSalesType || toBeInserted)
                {
                    newRegionMap.put(r.Id, r);
                }
            }
            if(newRegionMap.size()>0) {
                CS_AllRegionTriggerHelper.updatePartIncludedInRegions(newRegionMap);
            }
        }
        
        if(Trigger.isAfter && (Trigger.isdelete || Trigger.isUpdate))
        {
            map<id, Region__c> newRegionMap = new map<id, Region__c>();
            if(Trigger.isUpdate)
            {
            for(Region__c r: trigger.new)
            {
                if((Trigger.isUpdate && trigger.oldMap.get(r.Id).Type__c == 'Sales' && trigger.newMap.get(r.Id).Type__c != 'Sales'))
                {
                    newRegionMap.put(r.Id, r);
                }
            }
            }else
            {
                for(Region__c r: trigger.old)
                {
                    if( r.Type__c == 'Sales') 
                        newRegionMap.put(r.Id, r);
                }
                
            }
            
            if(newRegionMap.size()>0)
            CS_AllRegionTriggerHelper.updatePartAfterRegionDelete(newRegionMap);
        }
    } 

}