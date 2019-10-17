public with sharing class update_Employee_Skills_Helper{
     static Map<id,list<Employee_Skills__c>> empToEmpSkillsMap = new Map<id,list<Employee_Skills__c>>();
     static List<Employee__c> empToUpdateList = new List<Employee__c>();
     static Map<id,Employee__c> empIdMap = new Map<id,Employee__c>();
     static AddNewSkill obj = new AddNewSkill();
     static Map<String,String> setSkillMap = obj.setSkillMap();
     
      public static void updateEmployeeRecordsAfterInsert(List<Employee_Skills__c> newEmpSkill) { 
             Set<id> empIdSet = new Set<id>();
             for(Employee_Skills__c es : newEmpSkill){
                 if(!empIdSet.contains(es.Employee__c))
                 empIdSet.add(es.Employee__c);
             }
             
            empToUpdateList = [Select id,Name,Employee_Skills__c,(Select id,Skill_Name__C from Employee_Skills__r) from Employee__c where id IN :empIdSet];
            System.debug('====Pritiscode2===='+empToUpdateList);
            for(Employee__c e : empToUpdateList){
                empIdMap.put(e.id,e);
                for(List<Employee_Skills__c> es : e.Employee_Skills__r){  
                empToEmpSkillsMap.put(e.id,es); 
                System.debug('=====Pritiscode===='+es);}
            }
            System.debug('====Pritiscode3===='+empToEmpSkillsMap);
            
            for(Employee__c e : empToUpdateList){
               checkWhileInserting(e,empToEmpSkillsMap.get(e.id)); 
            }
            
            update empToUpdateList;
             
      }
      
      public static void updateEmployeeRecordsAfterUpdate(List<Employee_Skills__c> oldEmpSkill,List<Employee_Skills__c> newEmpSkill) { 
            if(System.label.Employee_Skills_One_Time_Bulk_Update_Switch == 'Yes'){
                System.debug('====OneTimeUpdate====');
                updateEmployeeRecordsAfterInsert(newEmpSkill);
                System.debug('====Pritiscode1===='+newEmpSkill);
            }
            
            else{
                System.debug('====UpdateAfterChecking====');
                List<Employee_Skills__c> tempAdd = new List<Employee_Skills__c>();
                List<Employee_Skills__c> tempDelete = new List<Employee_Skills__c>();
                for(Integer i=0;i<oldEmpSkill.size();i++){
                    if(oldEmpSkill[i].Skill_Name__C!=newEmpSkill[i].Skill_Name__C){
                        tempAdd.add(newEmpSkill[i]);
                        tempDelete.add(oldEmpSkill[i]);
                    }
                } 
                if(tempAdd!=null && tempDelete!=null){
                    updateEmployeeRecordsAfterDelete(tempDelete);
                    updateEmployeeRecordsAfterInsert(tempAdd);
                }
            }
      }
      
      public static void updateEmployeeRecordsAfterDelete(List<Employee_Skills__c> oldEmpSkill) { 
             Set<id> empIdSet = new Set<id>();
             for(Employee_Skills__c es : oldEmpSkill){
                 if(!empIdSet.contains(es.Employee__c))
                 empIdSet.add(es.Employee__c);
             }
             
            empToUpdateList = [Select id,Name,Employee_Skills__c,(Select id,Skill_Name__C from Employee_Skills__r) from Employee__c where id IN :empIdSet];
            for(Employee__c e : empToUpdateList){
                empIdMap.put(e.id,e);
                List<Employee_Skills__c> temp = new List<Employee_Skills__c>();
                for(Employee_Skills__c es : oldEmpSkill){
                    if(e.id == es.Employee__c)
                    temp.add(es); 
                }
                empToEmpSkillsMap.put(e.id,temp);
            }
            
            System.debug('=============='+empToEmpSkillsMap);
            
            for(Employee__c e : empToUpdateList){
               checkWhileDeleting(e,empToEmpSkillsMap.get(e.id)); 
            }
            System.debug('=======before======'+empToUpdateList);
            update empToUpdateList;
            System.debug('=======after======'+empToUpdateList); 
      }
      
      public static void checkWhileInserting(Employee__c e,list<Employee_Skills__c> empSkills){
          System.debug('====InCheck===='+empSkills);
          for(Employee_Skills__c es : empSkills){
              if(setSkillMap.containsKey(es.Skill_Name__C)){
                  if(e.Employee_Skills__c == null){
                      System.debug('====InCheckIf===='+setSkillMap.get(es.Skill_Name__C));
                      e.Employee_Skills__c = setSkillMap.get(es.Skill_Name__C);
                      e.Employee_Skills__c += '-';
                  }
                  else if(!e.Employee_Skills__c.contains(setSkillMap.get(es.Skill_Name__C)+'-')){
                      System.debug('====InCheckElseIf===='+setSkillMap.get(es.Skill_Name__C));
                      e.Employee_Skills__c += setSkillMap.get(es.Skill_Name__C);
                      e.Employee_Skills__c += '-';
                  }
                  else{
                      System.debug('====InCheckElse===='+setSkillMap.get(es.Skill_Name__C));
                  } 
              }         
          }
      }
          
          public static void checkWhileDeleting(Employee__c e,list<Employee_Skills__c> empSkills){
              for(Employee_Skills__c es : empSkills){
               if(setSkillMap.containsKey(es.Skill_Name__C)){
                  if(e.Employee_Skills__c == null){
                     
                  }
                  else if(e.Employee_Skills__c.contains(setSkillMap.get(es.Skill_Name__C)+'-')){
                      e.Employee_Skills__c = e.Employee_Skills__c.replace(setSkillMap.get(es.Skill_Name__C)+'-','');
                      System.debug('=============1'+setSkillMap.get(es.Skill_Name__C));
                      System.debug('=============2'+setSkillMap.get(es.Skill_Name__C)+'-');
                      System.debug('=============3'+e.Employee_Skills__c.replace(setSkillMap.get(es.Skill_Name__C)+'-',''));
                  }
                  else{
                  
                  } 
               }         
              }
          }
          
    
}