public with sharing class CS_AllBundlePartTriggerHelper {

    public static void handleAfterInsert (Map<Id, CS_Bundle_Part_Association__c> newBPs) {
    
        //updateBundleSupportedBoilerGroups
        List<CS_Bundle_Part_Association__c> affectedBPAs =  
            [Select Id, Type__c, Part__c, Bundle__c From CS_Bundle_Part_Association__c
            where Id in :newBPs.keyset()];  
                
        Set<Id> affectedBundleIds = new Set<Id>();
        for(CS_Bundle_Part_Association__c pa : affectedBPAs){
            affectedBundleIds.add(pa.Bundle__c);
        } 
        
        updateBundleSupportedBoilerGroups(affectedBundleIds);
    
    }
    
    public static void handleAfterUpdate (Map<Id, CS_Bundle_Part_Association__c> oldBPs, Map<Id, CS_Bundle_Part_Association__c> newBPs) {
    
        //updateBundleSupportedBoilerGroups
        List<CS_Bundle_Part_Association__c> affectedBPAs =  
            [Select Id, Type__c, Part__c, Bundle__c From CS_Bundle_Part_Association__c
            where Id in :newBPs.keyset()];  
                
        Set<Id> affectedBundleIds = new Set<Id>();
        for(CS_Bundle_Part_Association__c pa : affectedBPAs){
            affectedBundleIds.add(pa.Bundle__c);
        } 
        
        updateBundleSupportedBoilerGroups(affectedBundleIds);
    
    }
    
    public static void updateBundleSupportedBoilerGroups(Set<Id> affectedBundleIds){             
        
        List<CS_Bundle__c> bundlesToUpdate = [Select c.Id, c.Name, c.Supported_boiler_groups__c, 
                            (Select Id, Part__r.Flue_Boiler_Groups_Formula__c, Bundle__r.Type__c, Type__c From CS_Bundle_Part_Associations__r where Bundle__r.Type__c = 'Flue') 
                        From CS_Bundle__c c
                        where Id in: affectedBundleIds];
                        
        system.debug('****** bundles to update: ' + bundlesToUpdate.size());
                        
                      
        Set<String> includedBoilerGroups; 
        for(CS_Bundle__c bundle : bundlesToUpdate){
            includedBoilerGroups = new Set<String>(); //reset
            bundle.Supported_boiler_groups__c = '';
            
            system.debug('****** bundles: ' + bundle.Name + ' has bpas of type Flue: ' + bundle.CS_Bundle_Part_Associations__r.size());
                        
            for(CS_Bundle_Part_Association__c bpa : bundle.CS_Bundle_Part_Associations__r){
                system.debug('****** Flue_Boiler_Groups_Formula__c has value: ' + bpa.Part__r.Flue_Boiler_Groups_Formula__c);
                
                if (String.isNotBlank(bpa.Part__r.Flue_Boiler_Groups_Formula__c)){
                    List<String> groups = bpa.Part__r.Flue_Boiler_Groups_Formula__c.split(',');
                
                    includedBoilerGroups.addAll(groups);   
                }   
            }
        
            system.debug('****** includedBoilerGroups: ' + includedBoilerGroups);
            bundle.Supported_boiler_groups__c = String.Join(new List<String>(includedBoilerGroups), ',');  
        }
        
        update bundlesToUpdate;      
        
    }
    
    public static void updateBundleSupportedBoilerGroupsAfterBPAssociationDelete(Map<Id,CS_Bundle_Part_Association__c> triggerMap){
        
        List<CS_Bundle_Part_Association__c> affectedBPAs =  
            [Select Id, Type__c, Part__c, Bundle__c From CS_Bundle_Part_Association__c
            where Id in :triggerMap.keyset()];  
                
        Set<Id> affectedBundleIds = new Set<Id>();
        for(CS_Bundle_Part_Association__c pa : affectedBPAs){
            affectedBundleIds.add(pa.Bundle__c);
        }                
        
        List<CS_Bundle__c> bundlesToUpdate = [Select c.Id, c.Supported_boiler_groups__c, 
                         (Select Id, Part__r.Flue_Boiler_Groups_Formula__c, Bundle__r.Type__c, Type__c From CS_Bundle_Part_Associations__r where Bundle__r.Type__c = 'Flue') 
                        From CS_Bundle__c c
                        where Id in: affectedBundleIds];
                        
                      
        Set<String> includedBoilerGroups;  
        for(CS_Bundle__c bundle : bundlesToUpdate){
            includedBoilerGroups = new Set<String>();  
            bundle.Supported_boiler_groups__c = '';
                        
            for(CS_Bundle_Part_Association__c bpa : bundle.CS_Bundle_Part_Associations__r){
                 if(triggerMap.keyset().contains(bpa.Id)){
                    //do nothing
                } else {
                    if (String.isNotBlank(bpa.Part__r.Flue_Boiler_Groups_Formula__c)){
                        List<String> groups = bpa.Part__r.Flue_Boiler_Groups_Formula__c.split(',');
                    
                        includedBoilerGroups.addAll(groups);   
                    }   
                }
            }
        
            bundle.Supported_boiler_groups__c = String.Join(new List<String>(includedBoilerGroups), ',');  
        }
        
        update bundlesToUpdate; 
        
    }
}