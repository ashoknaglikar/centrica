@isTest
public class CS_AllSkillTriggerTest {
    
    static testMethod void testPartSkillDeletion(){   
           
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;

        insert vat20;
        
        List<CS_Skill__c> skillList = new List<CS_Skill__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();
        
        for (Integer i=0; i< 100; i++){
            skillList.add(new CS_Skill__c(Name = 'Test skill 005', Cost_per_Hour_Low_Cost__c = 10, Cost_per_Hour_Standard__c = 20));
        }
        insert skillList;
        
        CS_Part__c part = new CS_Part__c(Name = 'Test part 006', Part_Code__c = '123', VAT_Code__c = vat20.Id);
        insert part;
        
        List<CS_Part_Skill__c> partSkills = new List<CS_Part_Skill__c>();
        
        for(Integer i=0; i < skillList.size(); i++){
            Id skillId = skillList[i].Id;
            partSkills.add(new CS_Part_Skill__c(Skill__c = skillId, Part__c = part.Id, No_of_Hours__c = 1));
        }
        
        insert partSkills;
        
        CS_Part__c retrievedPart = [select Total_S_Cost_Standard__c, Total_S_Cost_Low_Cost__c from CS_Part__c where Id = :part.Id];
        
        System.assertEquals(retrievedPart.Total_S_Cost_Standard__c, 100 * 20);
        System.assertEquals(retrievedPart.Total_S_Cost_Low_Cost__c, 100 * 10);
        
        Test.startTest();
        
        //Delete 40 relationships
        List<CS_Part_Skill__c> partSkillsToDelete = new List<CS_Part_Skill__c>();
        
        for (Integer i=0; i < 40; i++) {
            partSkillsToDelete.add(partSkills[i]);
        }
        
        delete partSkillsToDelete;
        
        retrievedPart = [select Total_S_Cost_Standard__c, Total_S_Cost_Low_Cost__c from CS_Part__c where Id = :part.Id];
        
        System.assertEquals(retrievedPart.Total_S_Cost_Standard__c, 60 * 20);
        System.assertEquals(retrievedPart.Total_S_Cost_Low_Cost__c, 60 * 10);
        
        Test.stopTest();
        
    }

    static testMethod void testSkillUpdateAndSkillPartInsertUpdate(){    
        
        Test.startTest();
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;

        insert vat20;
        
        List<CS_Skill__c> skillList = new List<CS_Skill__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();
        
        for (Integer i=0; i< 100; i++){
            skillList.add(new CS_Skill__c(Name = 'Test skill 005', Cost_per_Hour_Low_Cost__c = 10, Cost_per_Hour_Standard__c = 20));
            partList.add(new CS_Part__c(Name = 'Test part 006', Part_Code__c = string.valueOf(i), VAT_Code__c = vat20.Id));
        }
        
        insert skillList;
        insert partlist;
                
        List<CS_Skill__c> queriedSkillList = 
            [select Id, Name, Cost_per_Hour_Low_Cost__c, Cost_per_Hour_Standard__c  from CS_Skill__c where Id in :skillList];
        
        List<CS_Part__c> queriedPartList = [select Id, Name from CS_Part__c where Id in :partList];
        
        List<CS_Part_Skill__c> partSkills = new List<CS_Part_Skill__c>();
        
        for(Integer i=0; i<queriedSkillList.size(); i++){
            Id skillId = queriedSkillList[i].Id;
            Id partId = queriedPartList[i].Id;
            partSkills.add(new CS_Part_Skill__c(Skill__c = skillId, Part__c = partId, No_of_Hours__c = 1));
        }
        
        insert partSkills;
        
        for (Integer i=0; i< queriedSkillList.size(); i++){
            queriedSkillList[i].Cost_per_Hour_Low_Cost__c += 1; //makes it 11
            queriedSkillList[i].Cost_per_Hour_Standard__c += 2; //makes it 22
        }
        
        update queriedSkillList;
        
        List<CS_Part__c> queriedUpdatedPartList = [select Id, Name, Total_S_Cost_Low_Cost__c, Total_S_Cost_Standard__c from CS_Part__c where Name = 'Test part 006'];
        for (Integer i=0; i< queriedUpdatedPartList.size(); i++){
            System.debug('****************** ' + queriedUpdatedPartList[i].Total_S_Cost_Standard__c);
            System.debug('****************** ' + queriedUpdatedPartList[i].Total_S_Cost_Low_Cost__c);
            System.assertEquals(queriedUpdatedPartList[i].Total_S_Cost_Standard__c, 22);
            System.assertEquals(queriedUpdatedPartList[i].Total_S_Cost_Low_Cost__c, 11);
        }
        
        Test.stopTest();
    }
}