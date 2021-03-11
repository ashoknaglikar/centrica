trigger Create_task_to_call_Quality on Payment_Collection__c (after update,after insert){

/*
   Code written within this first block creates the task for mechanical
   installers for completing post installation call.
*/  
 //PRB00032289
 if(cls_IsRun.transferhrstrg)
 {
     return;
 }
 
if(trigger.isUpdate && Trigger.New[0].Payment_Collection_Status__c == 'Complete' && Trigger.Old[0].Payment_Collection_Status__c != 'Complete'){

     integer iCount=0;
     Set<ID> jobIds = new Set<ID>();
     Set<ID> mechEmpUserIds = new Set<ID>();
     Set<String> agencyNames = new Set<String>();
     Set<ID> paymentCollectionIds = new Set<ID>();
     boolean shouldWeAddAgency;
     
     for(Payment_Collection__c  p: Trigger.new){
        
        jobIds.add(p.Job__c);
        paymentCollectionIds.add(p.Id);
        
     }
    
    // Fetch all the diary entries of all the skills which are related to jobs being considered in this batch 
    List<Diary_Entry__c> mechDiaryEntries = [Select id, Job__r.Id, Sub_Type__c, Employee_Salesforce1_ID__c, Employee_Agency_Name__c from Diary_Entry__c where Job__r.Id in :jobIds];
    
    // Map contains job id as key and Salesforce user Id of mechanical employee as value..
    // We keep only one value in set for one job....because we need only one task...
    Map<Id,Set<Id>> jobIdMechUserIds = new Map<Id,Set<Id>>();
    
    // Map contains agency name as key and Salesforce user Id of mechanical employee as value..
    // We keep only one value in set for one job....because we need only one task to be created...
    Map<String,List<Diary_Entry__c>> agencyNamesDiaryEntriesMap = new Map<String,List<Diary_Entry__c>>();
    
    for(Diary_Entry__c d : mechDiaryEntries){
        
        if(d.Sub_Type__c != 'Mechanical'){
            
            continue;
            
        }
        
        // If job is not yet added in this map and if employee has some salesforce user associated then add it & continue...
        if(!jobIdMechUserIds.containsKey(d.Job__r.Id) && d.Employee_Salesforce1_ID__c != '0'){
        
            // If for this job any other diary entry for office user is added in bucket then continue
            if(d.Employee_Agency_Name__c != '0' && agencyNamesDiaryEntriesMap.containsKey(d.Employee_Agency_Name__c)){
                
                for(Diary_Entry__c agencyDiaryEntry : agencyNamesDiaryEntriesMap.get(d.Employee_Agency_Name__c)){
                    
                    if(agencyDiaryEntry.Job__r.Id == d.Job__r.Id && d.Id != agencyDiaryEntry.Id){
                        
                        continue;
                        
                    }
                    
                }
                
            }
            
            jobIdMechUserIds.put(d.Job__r.Id,new Set<Id>());
            mechEmpUserIds.add(d.Employee_Salesforce1_ID__c);
            jobIdMechUserIds.get(d.Job__r.Id).add(d.Employee_Salesforce1_ID__c);
            continue;
        
        }
        
        // If job is not yet added in jobIDMechSalesforceUser map and if employee has some agency associated then enter the block..
        if(d.Employee_Agency_Name__c != '0' && !jobIdMechUserIds.containsKey(d.Job__r.Id)){
            
            agencyNames.add(d.Employee_Agency_Name__c);
            
            if(!agencyNamesDiaryEntriesMap.containsKey(d.Employee_Agency_Name__c)){
        
                agencyNamesDiaryEntriesMap.put(d.Employee_Agency_Name__c,new List<Diary_Entry__c>());
                agencyNamesDiaryEntriesMap.get(d.Employee_Agency_Name__c).add(d);
        
            }else if(agencyNamesDiaryEntriesMap.containsKey(d.Employee_Agency_Name__c)){
                
                shouldWeAddAgency = true;
                
                for(Diary_Entry__c agencyDiaryEntry : agencyNamesDiaryEntriesMap.get(d.Employee_Agency_Name__c)){
                    
                    if(agencyDiaryEntry.Job__r.Id == d.Job__r.Id && d.Id != agencyDiaryEntry.Id){
                        
                        shouldWeAddAgency = false;
                        
                    }
                    
                }
                
                if(shouldWeAddAgency){
                    
                    agencyNamesDiaryEntriesMap.get(d.Employee_Agency_Name__c).add(d);
                    
                }
                
            }
            
        }
        
     }
    
    if(agencyNames.size()>0){
        
            List<Group> groupList = [Select Id, Name from Group where Name in :agencyNames];
            
            Map<Id,String> groupIdNameMap = new Map<Id,String>();
            
            for(Group g : groupList){
                
                groupIdNameMap.put(g.Id, g.Name);
                
            }
            
            List<GroupMember> agencyOfficeGroupMembersList = [Select UserOrGroupId, GroupId from GroupMember where GroupId in :groupIdNameMap.keySet()];
             
            Map<String,Set<Id>> groupNameUserIdsMap = new Map<String,Set<Id>>();
            
            Set<Id> groupMemberIds = new Set<Id>();
            
            for(GroupMember gm : agencyOfficeGroupMembersList){
                
                if(!groupNameUserIdsMap.containsKey(groupIdNameMap.get(gm.GroupId))){
                    
                    groupNameUserIdsMap.put(groupIdNameMap.get(gm.GroupId),new Set<Id>());
                    groupNameUserIdsMap.get(groupIdNameMap.get(gm.GroupId)).add(gm.UserOrGroupId);
                    
                }else{
                    
                    groupNameUserIdsMap.get(groupIdNameMap.get(gm.GroupId)).add(gm.UserOrGroupId);
                    
                }
                
                groupMemberIds.add(gm.UserOrGroupId);
                
            }
    
    
        
            List<User> agencyOfficeUsers = [Select Id from User where Id in :groupMemberIds];
              
            for(String agencyName : agencyNamesDiaryEntriesMap.keySet()){
                  
              for(Diary_Entry__c d : agencyNamesDiaryEntriesMap.get(agencyName)){
                
                    if(d.Sub_Type__c != 'Mechanical'){
                        
                        continue;
                        
                    }
                    
                    for(User u : agencyOfficeUsers){
                        
                        if(groupNameUserIdsMap.get(agencyName) != null && groupNameUserIdsMap.get(agencyName).contains(u.Id) && !jobIdMechUserIds.containsKey(d.Job__r.Id)){
                        
                            jobIdMechUserIds.put(d.Job__r.Id,new Set<Id>());
                            jobIdMechUserIds.get(d.Job__r.Id).add(u.Id);
                        
                        }
                    
                    }
                                
               }
             
            }
            
    }
      /*
    Map<Id,List<Task>> old_Task_map = new Map<Id,List<Task>>(); 
    
    List<Task> oldTaskList = [Select Id,Whatid,OwnerId,ActivityDate from Task where Whatid in :paymentCollectionIds];
    
    for(Task t : oldTaskList){
        
       if(!old_Task_map.containsKey(t.Whatid)){
            
          old_Task_map.put(t.Whatid,new List<Task>());
            
        }
        
        old_Task_map.get(t.Whatid).add(t);
        
    }
    
    datetime t;
    date d;
    String sDate;
    List<Task> lst_task = new List<Task>();
    Task obj_task;
    Integer h;
    Integer m;
    Integer s;
    String shour;
    String smin;
    String ssec;
    String Sub;
    
    // For loop starts
   
    for(Payment_Collection__c  p: Trigger.new )

        {

          if(p.Payment_Collection_Status__c =='Complete' && (Trigger.old[iCount].Payment_Collection_Status__c =='Pending'||Trigger.old[iCount].Payment_Collection_Status__c == 'In Process')  && p.If_Yes_When__c <> null)
          
           {

                t = p.If_Yes_When__c;
                h = t.hour();
                m = t.minute();
                s = t.second();
                shour = String.valueOf(h);
                smin = String.valueOf(m);
                ssec = String.valueOf(s);
                d = Date.newInstance(t.year(),t.month(),t.day());
                sDate = String.valueOf(d);
                

            if(sDate !='')
                
            {

                if(old_Task_map != null && old_Task_map.get(p.Id) == null && jobIdMechUserIds.containsKey(p.Job__c))
                
                {
                  for(Id id : jobIdMechUserIds.get(p.Job__c)){
                        
                            obj_task = new Task();
        
                            Sub =  'Call'+' '+ p.ContactName__c+' '+'at'+' '+ shour +':'+ smin+' '+'on'+' '+p.Customer_Contact_Number__c;
        
                            obj_task.Subject = Sub ;
                            
                            obj_task.Whatid = p.Id;
                            
                            obj_task.OwnerId= id;
        
                            obj_task.Status= 'In Progress';
        
                            obj_task.Status__c= 'In Progress';
                                           
                            obj_task.ActivityDate = d;
                                                
                            obj_task.Is_post_installation_call_task__c = true;
                            
                            obj_task.whoid = p.Contact__c;
        
                            lst_task.add(obj_task);
                    
                    }

                  }
           
                } 
           
             }
           
                   try{
                    
                        if(lst_task!= null)
                        insert lst_task;
                        System.debug('lst_task: '+lst_task);
                          
                    }catch(Exception exp){
                        
                        System.debug('Exception'+ exp);
                        
                      } 
           
           }*/
      
       // For loop Ends
      
  }

/*
   First main IF block ends here.
*/

           if(!cls_IsRun.isaInsUpd_OnPaymentsObjectRun)
           {
               if(trigger.isinsert || trigger.isupdate)
               {
                    list<Id> CHILeadLst = new list<Id>();
                    // Added as part of customer history card change request. 
                    Set<Id> set_JobId=new Set<Id>{};
                    Map<Id,Id> map_PaymentCompDocId=new Map<Id,Id>{}; 
                    //List<Customer_history_card__c> custHistCardList = new List<Customer_history_card__c>();
                    for(Payment_Collection__c p:trigger.new)
                    {
                        if(p.Payment_Method__c == 'Finance')
                        CHILeadLst.add(p.Opportunity__c);
                        set_JobId.add(p.Job__c);
                        map_PaymentCompDocId.put(p.Job__c,p.Id);
                    }
                    /*
                    try{
                     if(trigger.isinsert){  
                      for(Customer_history_card__c c : [Select Job__r.Id,Job_Completion_Document__r.Id from Customer_history_card__c where Job__c in :set_JobId]){
                          c.Payment_Collection__c = map_PaymentCompDocId.get(c.Job__r.Id);
                          custHistCardList.add(c);
                         }
                       if(custHistCardList.size()>0){
                          Database.Update(custHistCardList);
                       }
                     }
                    }catch(Exception ex){
                          System.debug('Exception  : '+ex.getMessage());
                    }*/
                    
                                        
                    if(CHILeadLst.size()>0)
                    {
                        LIST<Opportunity> updatingCHILeads = new LIST<Opportunity>();

                        updatingCHILeads=[Select Unbilled_Reason__c from Opportunity where Id in:CHILeadLst];
                        
                        if(updatingCHILeads.size()>0)
                        {
                            for(Opportunity o : updatingCHILeads)
                            {
                                o.Unbilled_Reason__c = 'Job Complete – Finance';
                            }
                            try{
                                update updatingCHILeads;
                            }catch(Exception e)
                            {
                                system.debug('Exception occured while upadting unbilled reason in CHI lead'+e);
                            }
                        }
                    }
               }
           }
}