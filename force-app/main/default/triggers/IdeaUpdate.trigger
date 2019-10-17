trigger IdeaUpdate on Idea (after update) {
    set<id> Pids = new set<id>();
    set<id> Sids = new set<id>();
    map<id,string> statusMap = new Map<id,string>();
    set<id> PSids = new set<id>();
    string parentIdea;
    string ParentIdea1;
    
  for(idea i:trigger.new){
      
            if(i.parent_idea__c!=null && trigger.oldmap.get(i.id).parent_idea__c<>i.parent_idea__c){
              
              pids.add(i.parent_idea__c);
              pids.add(i.id);
              
              parentIdea = i.parent_Idea__c;
                            
            }
            
            if(trigger.oldmap.get(i.id).Sub_Status__c<>i.Sub_Status__c ){
                 if(i.parent_idea__c==null){
                    system.debug('I am in Parent_Idea Empty');
                     sids.add(i.id);
                     statusMap.put(i.id,i.sub_status__c);
                 }else{
                   system.debug('I am in Parent Idea Not Empty');
                     PSids.add(i.parent_Idea__c);
                     parentIdea1 = i.parent_Idea__c;                  
                 }
            }
  
  }
  
  if(trigger.isAfter && trigger.isupdate){
      if(pids.size()>0){
       IdeaTriggerUtility.UpdateRelatedList(pids,parentIdea);
      }
      
      if(sids.size()>0){
      
       IdeaTriggerUtility.updateStatus(sids,statusMap);
      }
      
      if(PSids.size()>0){
       system.debug('------>PARENT IDEA'+PSIDS+' '+ParentIDea1);
       IdeaTriggerUtility.UpdateRelatedList(PSids,parentIdea1);
      }
    }
  
}