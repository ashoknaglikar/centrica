//Apex Trigger on novo activity object
trigger NovoActivityTrigger on NOVO_Activities__c (after insert,after update) {

//Code to share novo activity records with activity owners
 if(trigger.isAfter && trigger.isinsert){
    
    
    List<Employee_NOVO_Log__Share> goalShares  = new List<Employee_NOVO_Log__Share>();
    Map<Id, NOVO_Activities__c > novoActions= new Map<Id, NOVO_Activities__c>([select id,Owner__r.Salesforce_User__c, Employee_NOVO_Log__c from NOVO_Activities__c where id in : Trigger.newMap.keySet()]);
    system.debug('*novoActions'+novoActions);
 
    system.debug('*novoActions'+novoActions);
    for(NOVO_Activities__c action: trigger.new){
        if(action.owner__c!=null){
            Employee_NOVO_Log__Share userShare = new Employee_NOVO_Log__Share();
            userShare.ParentId = action.Employee_NOVO_Log__c;
            userShare.UserOrGroupId = novoActions.get(action.id).Owner__r.Salesforce_User__c ;
            userShare.AccessLevel = 'read';
            userShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Emp_Novo_Goal_Access_To_action_owners__c;
            goalShares.add(userShare);
        }
    }
    Database.SaveResult[] goalShareInsertResult = Database.insert(goalShares,false);
  }
  if(trigger.isAfter && trigger.isupdate){
    
    
    List<Employee_NOVO_Log__Share> goalShares  = new List<Employee_NOVO_Log__Share>();
    Map<Id, NOVO_Activities__c > novoActions= new Map<Id, NOVO_Activities__c>([select id,Owner__r.Salesforce_User__c, Employee_NOVO_Log__c from NOVO_Activities__c where id in : Trigger.newMap.keySet()]);
    system.debug('*novoActions'+novoActions);
 
    system.debug('*novoActions'+novoActions);
    for(NOVO_Activities__c action: trigger.new){
        if(action.owner__c!=null && action.Recalculate_Sharing_rules__c==true){
            Employee_NOVO_Log__Share userShare = new Employee_NOVO_Log__Share();
            userShare.ParentId = action.Employee_NOVO_Log__c;
            userShare.UserOrGroupId = novoActions.get(action.id).Owner__r.Salesforce_User__c ;
            userShare.AccessLevel = 'read';
            userShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Emp_Novo_Goal_Access_To_action_owners__c;
            goalShares.add(userShare);
        }
    }
    Database.SaveResult[] goalShareInsertResult = Database.insert(goalShares,false);
  }

}