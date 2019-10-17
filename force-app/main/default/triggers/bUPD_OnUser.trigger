/* This triggers updates the employee corresponding to the user record 
as inactive if the user record is updated as an inactive one*/
/* The code which makes the employee active if the user is updated as active is commented as per user's request*/

trigger bUPD_OnUser on User (before update,after update) {    
     List<Id> updates_inactiveuserlist=new List<Id>();
    // List<Id> updates_activeuserlist=new List<Id>();
     for(User user : Trigger.New){
        if(user.IsActive==false)
        {
         updates_inactiveuserlist.add(user.id);
        }
        /* if(user.IsActive==true)
        {
         updates_activeuserlist.add(user.id);
        }*/
    }
    if(updates_inactiveuserlist.size()>0){  
                                system.debug('Users updated as inactive '+updates_inactiveuserlist );    
                                Employee__c[] emp = [Select Inactive__c,Name from Employee__c where Salesforce_User__c IN :updates_inactiveuserlist and Inactive__c=false]; 
                                system.debug('Employee to be updated as inactive '+emp);   
                                if(emp.size()>0)
                                {
                                for(Employee__c e : emp) {                                      
                                    e.Inactive__c=true;     
                                }
                                try{
                                    Database.update(emp);
                                    System.debug('Employees updated successfully  as inactive '+emp);
                                }
                                catch(Exception e){
                                {
                                      System.debug('@Exception in updating the employee record :  '+e.getMessage()+' Error in line number : '+e.getLineNumber());
                                }
                                }
                             }
}
/* if(updates_activeuserlist.size()>0){  
                                system.debug('Users updated as active '+updates_activeuserlist );    
                                Employee__c[] emp = [Select Inactive__c,Name from Employee__c where Salesforce_User__c IN :updates_activeuserlist and Inactive__c=true]; 
                                system.debug('Employee to be updated as inactive '+emp);   
                                if(emp.size()>0)
                                {
                                for(Employee__c e : emp) {  
                                    e.Inactive__c=false;     
                                }
                                try{
                                    Database.update(emp);
                                    System.debug('Employees updated successfully as active '+emp);
                                }
                                catch(Exception e){
                                {
                                      System.debug('@Exception in updating the employee record :  '+e.getMessage()+' Error in line number : '+e.getLineNumber());
                                }
                                }
                             }
}*/

//Code added to update field on Employee if User's profile is changed

if(trigger.isAfter && trigger.isUpdate){
    Map<id,User> changedUser = new Map<id,User>();
    List<Employee__c> employeeToUpdate = new List<Employee__c>();

    for(Id u : trigger.newMap.KeySet()){
        if(trigger.newMap.get(u).ProfileId != trigger.oldMap.get(u).ProfileId){       
         changedUser.put(u,trigger.newMap.get(u));
        }         
    }
    
    List<User> users = [Select id,Profile.Name,(Select id From Employees__r) From User where id IN :changedUser.keySet()];
    
    For(User u : users){
         For(Employee__c e : u.Employees__r){
             e.Role_Type__c = u.Profile.Name;
             employeeToUpdate.add(e);
         }        
    }
    System.debug('==========debug====='+employeeToUpdate);
    update employeeToUpdate; 
    
    //Suguna - Smart Novo Maanger sharing change
     set<id> smartNovoEmpIds = new set<id>();
     for(Id u : trigger.newMap.KeySet()){
        if(trigger.newMap.get(u).managerId != trigger.oldMap.get(u).managerId){       
         smartNovoEmpIds.add(u);
        }         
    }
    
    List<Employee_NOVO_Log__c> smartNovos = [select id from Employee_NOVO_Log__c where Employee__r.Salesforce_User__c=:smartNovoEmpIds];
    if(smartNovos.size()>0)
    {
        cls_IsRun.isSmartNovoManagerChange =true;
        update smartNovos;
    }
}
}