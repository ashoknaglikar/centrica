public class IdeaTriggerUtility{
   
   public IdeaTriggerUtility(){
   
   }
   
  public static void UpdateRelatedList(set<id> pids,string parentIdea){
  
        if(pids.size()>0){
           list<idea> IQuery = [SELECT Id,Idea_Number__c,status,Region__c,Parent_Idea__c , Accepted_Date__c,Sub_Status__c ,createdByID,createddate FROM Idea WHERE Parent_Idea__c = :pids];
           map<id,idea> mapIdeas= new map<id,idea>([SELECT Id,Idea_Number__c,status,Region__c,Parent_Idea__c , Accepted_Date__c,Sub_Status__c ,createdByID,createddate FROM Idea WHERE id= :pids]);
           
           list<idea> updatIdea = new List<idea>();        
           if(IQuery.size()>0){
               for(Idea URelIdeas: IQuery){
                if(mapIdeas.containskey(URelIdeas.parent_idea__c)){
                 URelIdeas.Sub_Status__c = mapIdeas.get(URelIdeas.parent_idea__c).sub_status__c;
                 URelIdeas.parent_idea__c = parentIdea;
                 updatIdea.add(URelIdeas);
                }
               }
               if(UpdatIdea.size()>0)
               update updatIdea;
          }
        }
   
  
  }
  
  public static void updateStatus(set<id> sids,map<id,string> statusMap){
    list<idea> IQuery = [SELECT Id,Idea_Number__c,status,Region__c,Parent_Idea__c , Accepted_Date__c,Sub_Status__c ,createdByID,createddate FROM Idea WHERE Parent_Idea__c = :sids];
    List<idea> updatIdea= new list<idea>();
    if(IQuery.size()>0){
    
      for(Idea UpStatus: IQuery){
       if(statusMap.containskey(UpStatus.parent_idea__c)){
        UpStatus.sub_status__c = statusMap.get(Upstatus.Parent_Idea__c);
        updatIdea.add(UpStatus);    
       }
      }
    }
    if(UpdatIdea.size()>0){
      update UpdatIdea;
    }
  }
  

 
}