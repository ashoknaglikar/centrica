public class CS_AllSkillTriggerHelper {

    public static void updatePartTotalLowAndStandardCost(Map<Id,Sobject> triggerMap, string skillOrPartSkill){
     
        List<CS_Part_Skill__c> affectedPartSkills = new List<CS_Part_Skill__c>();
     
        if(skillOrPartSkill.equals('skill')){   
            affectedPartSkills = 
                    [select c.Id, c.Name, c.No_of_Hours__c, c.Part__c, c.Skill__c From CS_Part_Skill__c c where c.Skill__c in :triggerMap.keySet()];
        }
        else if (skillOrPartSkill.equals('partSkill')){
            affectedPartSkills = 
                [select c.Id, c.Name, c.No_of_Hours__c, c.Part__c, c.Skill__c From CS_Part_Skill__c c where c.Id in :triggerMap.keySet()];
        }   
        
        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Skill__c ps : affectedPartSkills){
            affectedPartIds.add(ps.Part__c);   
        }
    
        List<CS_Part__c> partsToUpdate = [select Id, Total_S_Cost_Low_Cost__c, Total_S_Cost_Standard__c, 
              (select Skill__r.Cost_per_Hour_Low_Cost__c, Skill__r.Cost_per_Hour_Standard__c, No_of_Hours__c from CS_Part_Skills__r) 
              from CS_Part__c
              where Id in: affectedPartIds];
    
        
        for(CS_Part__c part : partsToUpdate){
            part.Total_S_Cost_Low_Cost__c = 0;
            part.Total_S_Cost_Standard__c = 0;
            decimal tempTotalLowCost = 0;
            decimal tempTotalStandardCost = 0;
            for(CS_Part_Skill__c ps : part.CS_Part_Skills__r){
                tempTotalLowCost += (ps.Skill__r.Cost_per_Hour_Low_Cost__c * ps.No_of_Hours__c);
                tempTotalStandardCost += (ps.Skill__r.Cost_per_Hour_Standard__c * ps.No_of_Hours__c);   
            }
            part.Total_S_Cost_Low_Cost__c = tempTotalLowCost;
            part.Total_S_Cost_Standard__c = tempTotalStandardCost;
        }
        
        update partsToUpdate;              
    }
    
    public static void updatePartTotalLowAndStandardCostAfterPSDeletion(Map<Id,CS_Part_Skill__c> triggerMap){
     
        List<CS_Part_Skill__c> affectedPartSkills = 
                [select c.Id, c.Name, c.No_of_Hours__c, c.Part__c, c.Skill__c From CS_Part_Skill__c c where c.Id in :triggerMap.keySet()];  
        
        Set<Id> affectedPartIds = new Set<Id>();
        for(CS_Part_Skill__c ps : affectedPartSkills){
            affectedPartIds.add(ps.Part__c);   
        }
    
        List<CS_Part__c> partsToUpdate = [select Id, Total_S_Cost_Low_Cost__c, Total_S_Cost_Standard__c, 
              (select Id, Skill__r.Cost_per_Hour_Low_Cost__c, Skill__r.Cost_per_Hour_Standard__c, No_of_Hours__c from CS_Part_Skills__r where Id not in :affectedPartSkills) 
              from CS_Part__c
              where Id in: affectedPartIds];
    
        
        for(CS_Part__c part : partsToUpdate){
            part.Total_S_Cost_Low_Cost__c = 0;
            part.Total_S_Cost_Standard__c = 0;
            decimal tempTotalLowCost = 0;
            decimal tempTotalStandardCost = 0;
            for(CS_Part_Skill__c ps : part.CS_Part_Skills__r){
                tempTotalLowCost += (ps.Skill__r.Cost_per_Hour_Low_Cost__c * ps.No_of_Hours__c);
                tempTotalStandardCost += (ps.Skill__r.Cost_per_Hour_Standard__c * ps.No_of_Hours__c);   
            }
            part.Total_S_Cost_Low_Cost__c = tempTotalLowCost;
            part.Total_S_Cost_Standard__c = tempTotalStandardCost;
        }
        
        update partsToUpdate;      
        
    }
     
}