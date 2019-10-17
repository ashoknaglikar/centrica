public class CS_AllMaterialTriggerHelper{

    public static void updatePartTotalMCost(Map<Id,Sobject> triggerMap, string materialOrPartMaterial){
        
        List<CS_Part_Material__c> affectedPMs = new List<CS_Part_Material__c>();
        
        if(materialOrPartMaterial.equals('material')){
            affectedPMs =
                [Select c.Quantity__c, c.Part__c, c.Material__c From CS_Part_Material__c c where c.Material__c in :triggerMap.keySet()];
        }
        else if(materialOrPartMaterial.equals('partMaterial')){     
            affectedPMs = 
                [Select c.Id, c.Quantity__c, c.Part__c, c.Material__c From CS_Part_Material__c c where c.Id in :triggerMap.keySet()];
        }   
            
        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Material__c pm : affectedPMs){
            affectedPartIds.add(pm.Part__c);   
        }
    
        List<CS_Part__c> partsToUpdate = [select Id, Total_M_Cost__c, 
              (select Material__r.Cost_Per_Unit__c, Quantity__c from CS_Part_Materials__r)
              from CS_Part__c
              where Id in: affectedPartIds];
    
        for(CS_Part__c part : partsToUpdate){
            part.Total_M_Cost__c = 0;
            decimal tempTotalM = 0;
            for(CS_Part_Material__c pm : part.CS_Part_Materials__r){
                tempTotalM += (pm.Material__r.Cost_Per_Unit__c * pm.Quantity__c);    
            }
            part.Total_M_Cost__c = tempTotalM;
        }
        
        update partsToUpdate;        
    }
    
     public static void updatePartTotalMCostAfterPMDeletion(Map<Id,CS_Part_Material__c> triggerMap){
        
        List<CS_Part_Material__c> affectedPMs = 
                [Select c.Id, c.Quantity__c, c.Part__c, c.Material__c From CS_Part_Material__c c where c.Id in :triggerMap.keySet()];  
            
        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Material__c pm : affectedPMs){
            affectedPartIds.add(pm.Part__c);   
        }
    
        List<CS_Part__c> partsToUpdate = [select Id, Total_M_Cost__c, 
              (select Id, Material__r.Cost_Per_Unit__c, Quantity__c from CS_Part_Materials__r where Id not in: affectedPMs)
              from CS_Part__c
              where Id in: affectedPartIds];
    
        for(CS_Part__c part : partsToUpdate){
            part.Total_M_Cost__c = 0;
            decimal tempTotalM = 0;
            for(CS_Part_Material__c pm : part.CS_Part_Materials__r){
                tempTotalM += (pm.Material__r.Cost_Per_Unit__c * pm.Quantity__c);    
            }
            part.Total_M_Cost__c = tempTotalM;
        }
        
        update partsToUpdate;    
    
    }

}