public class CS_AllRegionTriggerHelper{

    public static void updatePartIncludedInRegions(Map<Id, Region__c> triggerMap){
    
        List<CS_Part__c> partList = 
            [Select c.Id, c.Included_In_Regions__c, 
            (Select Region__c, Region__r.Name, Region__r.Code__c From CS_Part_Availabilities__r) 
            From CS_Part__c c];
        
        List<Region__c> availableRegions = [select Id, Name, Code__c from Region__c where Type__c = 'Sales'];        
        List<String> regionNames = new List<String>();      
        for(Region__c region : availableRegions){
            regionNames.add(region.Name);
        }        
        
        for(CS_Part__c part : partList){
            if(part.CS_Part_Availabilities__r.size()==0)
            {
                part.Included_In_Regions__c = '';
                Set<String> includedRegions = new Set<String>(regionNames);
            
                part.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
            }
        }
        
        update partList;
        
    }
    
    public static void updatePartAfterRegionDelete(Map<Id, Region__c> triggerMap)
    {
        List<CS_Part__c> partList = 
            [Select c.Id, c.Included_In_Regions__c, 
            (Select Region__c, Region__r.Name, Region__r.Code__c,Id From CS_Part_Availabilities__r) 
            From CS_Part__c c];
            
        list<CS_Part_Availability__c> deleteList = new list<CS_Part_Availability__c>();
        List<Region__c> availableRegions = [select Id, Name, Code__c from Region__c where Type__c = 'Sales' ];        
        List<String> regionNames = new List<String>();      
        
        for(Region__c region : availableRegions){
            if(!triggerMap.containsKey(region.Id))
            regionNames.add(region.Name);
        }        
        
        for(CS_Part__c part : partList){
            if(part.CS_Part_Availabilities__r.size()==0)
            {
                part.Included_In_Regions__c = '';
                Set<String> includedRegions = new Set<String>(regionNames);
                
                for(CS_Part_Availability__c pa : part.CS_Part_Availabilities__r){
                    includedRegions.remove(pa.Region__r.Name);
                }
            
                part.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
            }else
            {
                deleteList.addall(part.CS_Part_Availabilities__r);
            }
        }
        
        update partList;
        
        if(deleteList.size()>0)
        delete deleteList;
    }
    
}