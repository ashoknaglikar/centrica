/*
*   CLASS - NotifyTaskOverDue
*   Author - COGNIZANT
*   Purpose - The prupose of this class is to fetch all the tasks;related to cases; which are not closed by thier respective Due Date(i.e Overdue Tasks)
*             Assign tasks to the Assignee's respective manager with details of the overdue case tasks.
*/
global class NotifyTaskOverDue implements Database.Batchable<sObject> {
	
	public string soql = 'Select WhatId, Subject, Status__c,  Status,  Priority,Owner.Name,OwnerId,Description, Communication_Status__c, Call_Notes__c, ActivityDate From Task t where IsClosed = false and ActivityDate < today';
    /*
    *   This method submits a batch to the queue for processing
    */
     public static void notifyManagers(){
        NotifyTaskOverDue objNotifyDue = new NotifyTaskOverDue();
        ID batchprocessid = Database.executeBatch(objNotifyDue);
     }
     /*
    *   Input - Current Btch Context
    *   Output - Query Set
    *   Purpose - retrieves the query set to be processed by the current & future batches 
    */  
     global Database.QueryLocator start(Database.BatchableContext BC){
     	
     	return Database.getQueryLocator(soql);
    }
    /*
    *   Input - current batch context and list of records to process
    *   Output - None
    *   Purpose - retrives the open tasks related to cases and then group the tasks by Assignee's Manager
    *               creates tasks for managers with the task description field outlining the open task details 
    */
    global void execute(Database.BatchableContext BC, List<sObject> lstTasks){
        Set<String> assingedToSet = new Set<String>();
        List<String> whatIdList = new List<String>();
        Map<String,List<Task>> taskListMap = new Map<String,List<Task>>();
        
        for(sObject sObj : lstTasks){
            Task objTask = (Task) sObj;
            assingedToSet.add(objTask.OwnerId);
        }
        
        for(String assTo : assingedToSet){
            List<Task> taskList = new List<Task>();
            for(sObject sObj : lstTasks){
                Task objTask = (Task) sObj;
                if(objTask.OwnerId == assTo && (((String)(objTask.WhatId)).substring(0,3) == '500')){
                    taskList.add(objTask);
                    whatIdList.add(objTask.WhatId);
                }
            }
            if(taskList.size() > 0)
                taskListMap.put(assTo,taskList);
        }
        // Retrieve the Managers for the Assigned Employees of the overdue tasks
        // SHOULD BE UN COMMENTED WHEN USING ACTUALS
        List<User> managers = [select id,managerId,Email,Manager.Email from User where id in :assingedToSet and managerId != null and Phase_4_Ready__c = true];
        Map<String,User> managerMap = new Map<String,User>();
        for(User us : managers)
            managerMap.put(us.Id,us);
        Map<String,Case> caseMap = new Map<String,Case>();
        for(Case c : [select id,CaseNumber from Case where id in :whatIdList])
            caseMap.put(c.id,c);

        
        List<Task> toBeInsertedTaskList = new List<Task>();
        Map<String,String> emailIdMap = new Map<String,String>();
        Integer count =0;
        for(String mId :  managerMap.keySet()){

                List<task> tempTaskList = taskListMap.get(mId);
                String s_managerId = managerMap.get(mId).managerId;
                // Create Task for the respective manager
                Task objTask = new Task();
                objTask.Type__c = 'Customer Experience Case';
                objTask.Subject = 'Urgent : Tasks Overdue on Cases';
                objTask.Status_Reason__c = 'TASKS OVERDUE BY ASSIGNEES';
                objTask.Priority = 'High';
                String s_TempStr = '---- TASK OVERDUE DETAILS ---- '+'\n';
                String s_email = '';
                for(Task tsk : tempTaskList){
                    Case objcase = caseMap.get(tsk.WhatId);
                    s_email = s_email+(managerMap.get(mid)).Email+';';
                    s_TempStr = s_TempStr+'Assigned To - '+tsk.Owner.Name + '  |  '+'Case Number - '+objcase.CaseNumber+ '\n';
                    s_TempStr = s_TempStr+'Subject - '+tsk.Subject+'  |  '+'Due Date - '+tsk.ActivityDate+'\n';
                    s_TempStr = s_TempStr+'Priority - '+tsk.Priority+ '  |  '+'Status - '+tsk.Status__c+ '\n';
                    if(tsk.Call_Notes__c == null)
                        s_TempStr = s_TempStr+'Call Notes - None'+'\n';
                    else
                        s_TempStr = s_TempStr+'Call Notes - '+tsk.Call_Notes__c+'\n';
                    s_TempStr = s_TempStr+'******************************'+'\n';                    
                }
                objTask.Description = s_TempStr;
                objTask.ActivityDate = System.Today() + 9;
                //SHOULD BE UNCOMMENTED IF RUNNING ACTUALS
                objTask.OwnerId = s_managerId;
                //objTask.OwnerId = mId;
                
                emailIdMap.put((managerMap.get(mId)).manager.Email,s_email);
                toBeInsertedTaskList.add(objTask);
        }
        if(toBeInsertedTaskList.size() > 0){
            try{
                insert toBeInsertedTaskList;
            }catch(DMLException e){
                System.debug('----TASK CANNOT BE CREATED For - '+e.getMessage());
            }
        }           
    }
    global void finish(Database.BatchableContext BC){
        System.debug('--Finish Job -- ');
    }
}