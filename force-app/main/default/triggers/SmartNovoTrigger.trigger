//Apex Trigger on smart novo object
trigger SmartNovoTrigger on Employee_NOVO_Log__c (after insert,after update) {

    //This code is to share novo goal records created by managers for respective employee with user
    if(trigger.isAfter && trigger.isInsert){
    
    List<Employee_NOVO_Log__Share> goalShares  = new List<Employee_NOVO_Log__Share>();
    Map<Id, Employee_NOVO_Log__c> novoGoals= new Map<Id, Employee_NOVO_Log__c>([select id,Employee__r.Salesforce_User__c, Employee__r.Salesforce_User__r.ManagerId from Employee_NOVO_Log__c where id in : Trigger.newMap.keySet()]);
    for(Employee_NOVO_Log__c goal : trigger.new){

        if(novoGoals.get(goal.id).Employee__r.Salesforce_User__c!=null)
        {
          Employee_NOVO_Log__Share userShare = new Employee_NOVO_Log__Share();
          userShare.ParentId = goal.Id;
          userShare.UserOrGroupId = novoGoals.get(goal.id).Employee__r.Salesforce_User__c;
          userShare.AccessLevel = 'read';
          userShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Employee_Novo_Goal_Access__c;
          goalShares.add(userShare);
        }
        if(novoGoals.get(goal.id).Employee__r.Salesforce_User__c!=null && novoGoals.get(goal.id).Employee__r.Salesforce_User__r.ManagerId!=null)
        {
          Employee_NOVO_Log__Share managerShare = new Employee_NOVO_Log__Share();
          managerShare.ParentId = goal.Id;
          managerShare.UserOrGroupId = novoGoals.get(goal.id).Employee__r.Salesforce_User__r.ManagerId;
          managerShare.AccessLevel = 'edit';
          managerShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Employee_Novo_Goal_Access__c;
          goalShares.add(managerShare);
        }
        
    }
    if(goalShares.size()>0)
    Database.SaveResult[] goalShareInsertResult = Database.insert(goalShares,false);
    }
    
      if(trigger.isAfter && trigger.isUpdate){
            List<Employee_NOVO_Log__Share> goalShares  = new List<Employee_NOVO_Log__Share>();
            Map<Id, Employee_NOVO_Log__c> novoGoals= new Map<Id, Employee_NOVO_Log__c>([select id,Employee__r.Salesforce_User__c, Employee__r.Salesforce_User__r.ManagerId from Employee_NOVO_Log__c where id in : Trigger.newMap.keySet()]);

            Map<Id, list<Employee_NOVO_Log__Share>> exisitingSharesMap  = new Map<Id, list<Employee_NOVO_Log__Share>>();

            for(Employee_NOVO_Log__Share  oldShare: [Select id, ParentId from Employee_NOVO_Log__Share where ParentId in: trigger.newMap.keySet() and RowCause!= 'Owner'])
            {
              if(exisitingSharesMap.containsKey(oldShare.ParentId))
              {
                exisitingSharesMap.get(oldShare.ParentId).add(oldShare);

              }else {

                  exisitingSharesMap.put(oldShare.ParentId, new list<Employee_NOVO_Log__Share>{oldShare});
                }

            }  

          list<Employee_NOVO_Log__Share> oldShareList = new list<Employee_NOVO_Log__Share>();

          for(Employee_NOVO_Log__c goal : trigger.new){
              if(goal.Recalculate_Sharing_rules__c==true||cls_IsRun.isSmartNovoManagerChange ==true){


                 if(novoGoals.get(goal.id).Employee__r.Salesforce_User__c!=null)
                  {
                    Employee_NOVO_Log__Share userShare = new Employee_NOVO_Log__Share();
                    userShare.ParentId = goal.Id;
                    userShare.UserOrGroupId = novoGoals.get(goal.id).Employee__r.Salesforce_User__c;
                    userShare.AccessLevel = 'read';
                    userShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Employee_Novo_Goal_Access__c;
                    goalShares.add(userShare);
                  }
                  if(novoGoals.get(goal.id).Employee__r.Salesforce_User__c!=null && novoGoals.get(goal.id).Employee__r.Salesforce_User__r.ManagerId!=null)
                  {
                    Employee_NOVO_Log__Share managerShare = new Employee_NOVO_Log__Share();
                    managerShare.ParentId = goal.Id;
                    managerShare.UserOrGroupId = novoGoals.get(goal.id).Employee__r.Salesforce_User__r.ManagerId;
                    managerShare.AccessLevel = 'edit';
                    managerShare.RowCause = Schema.Employee_NOVO_Log__Share.RowCause.Employee_Novo_Goal_Access__c;
                    goalShares.add(managerShare);
                  }

                  if(exisitingSharesMap.containskey(goal.id) && exisitingSharesMap.get(goal.id).size()>0)
                  oldShareList.addall(exisitingSharesMap.get(goal.id));

              }    
          }
          if(oldShareList.size()>0)
          delete oldShareList;

          if(goalShares.size()>0)
           Database.SaveResult[] goalShareInsertResult = Database.insert(goalShares,false);
      }
}