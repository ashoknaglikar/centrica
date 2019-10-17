trigger CreateIdeaHistory on Idea (after insert,after update) {

    Public static Boolean SingleTimeOccurence;
    List<Business_Admin_History__c> IdeaHistory= new List<Business_Admin_History__c>();
    for (idea newidea: Trigger.New) {
      
      if(Trigger.isupdate){
        if(!cls_IsRun.hasAlreadyDone()){
          system.debug('##Update');
                   if(Trigger.oldMap.get(newidea.Id).sub_status__c != NULL || Trigger.oldMap.get(newidea.Id).sub_status__c != ''){
                       if(newidea.sub_status__c != Trigger.oldMap.get(newidea.Id).sub_status__c){
                       system.debug('new idea status:'+newidea.sub_status__c );
                       system.debug('new idea status:'+Trigger.oldMap.get(newidea.Id).sub_status__c);
                          Business_Admin_history__c newIdea1 = new Business_Admin_History__c();
                          newIdea1.Idea_Ref__c = newidea.Id;
                          newIdea1.From_status__c = Trigger.oldMap.get(newidea.Id).sub_status__c;
                          newIdea1.To_status__c = newidea.sub_status__c;
                          IdeaHistory.add(newIdea1);
                          
                   
                   }
               }
               cls_IsRun.setAlreadyDone();   
            }
          }
       } 
     
     
    if(IdeaHistory.size()>0)
    upsert IdeaHistory;

}