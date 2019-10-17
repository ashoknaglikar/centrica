public class CS_AllPartAvailabilityTriggerHelper {
    // Logic to add region has been changed. 
    // Initally code looked at PartAvailability table to exclude from the geography. 
    // But after this change records in PartAvailability will include the part only in those geography.
    public static void updatePartIncludedInRegions(Map<Id, CS_Part_Availability__c> triggerMap){

        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Availability__c pa : triggerMap.values()){
            affectedPartIds.add(pa.CS_Part__c); 
        }
        
        List<CS_Part__c> partsToUpdate = [Select c.Id, c.Included_In_Regions__c, 
                        (Select Id, Region__c, Region__r.Name, Region__r.Code__c From CS_Part_Availabilities__r) From CS_Part__c c
                        where Id in: affectedPartIds];
                        
        for(CS_Part__c part : partsToUpdate){
            part.Included_In_Regions__c = '';
            Set<String> includedRegions = new Set<String>();
            
            for(CS_Part_Availability__c pa : part.CS_Part_Availabilities__r){
                includedRegions.add(pa.Region__r.Name);
            }
        
            part.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
        }
        
        update partsToUpdate;
            
    }
    
    public static void updatePartIncludedInRegionsOnPADelete(Map<Id, CS_Part_Availability__c> triggerMap){
    
        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Availability__c pa : triggerMap.values()){
            affectedPartIds.add(pa.CS_Part__c); 
        }
        
        List<CS_Part__c> partsToUpdate = [Select c.Id, c.Included_In_Regions__c, 
                        (Select Id, Region__c, Region__r.Name, Region__r.Code__c From CS_Part_Availabilities__r) From CS_Part__c c
                        where Id in: affectedPartIds];
                        
        List<Region__c> availableRegions = [select Id, Name, Code__c from Region__c where Type__c= 'Sales'];        
        List<String> regionNames = new List<String>();      
        for(Region__c region : availableRegions){
            regionNames.add(region.Name);
        }
                        
        for(CS_Part__c part : partsToUpdate){
            part.Included_In_Regions__c = '';
            Set<String> includedRegions = new Set<String>();

            for(CS_Part_Availability__c pa : part.CS_Part_Availabilities__r){
                if(triggerMap.keyset().contains(pa.Id)){
                    //do nothing
                } else {
                    includedRegions.add(pa.Region__r.Name);
                }             
            }
            
            if(includedRegions.size()==0)
            {
                includedRegions.addall(regionNames);
            }
        
            part.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
        }
        
        update partsToUpdate;
    }
}