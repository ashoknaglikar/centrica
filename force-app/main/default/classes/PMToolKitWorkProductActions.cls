/**
* @author       Mark Baker      
* @date         06/18/2013
* @description  Class that checks the State of a work product. When all 
*               child tasks have been set to completed, it sets WP state to 
*               Complete.  When at least one task is In-Progress, sets the
*               WP to In-Progress. When no tasks are In-Progress, or there are
*               no tasks (e.g. when the only task was deleted), sets the WP to  
*               Defined.
*
*    --------------------------------------------------------------------------
*    Developer                  Date                Description
*    --------------------------------------------------------------------------
*   
*    Mark Baker                 06/11/2013          Created
*/

public with sharing class PMToolKitWorkProductActions {
  
    public static void setWorkProductState(List<Work_Product_Task__c> triggerList) {
        
        map<Id, string> WorkProductStates = new map<Id, string>();
        List<Id> WpTriggerList = new List<Id>();
        String CurrentWPState, TaskState;
        Integer I;
        
        //throw the parent user stories from the trigger into a list so we can query on it
        for(Work_Product_Task__c task : triggerList) {
           WpTriggerList.add(task.Work_Product__c);
        }

        //go through the tasks that have a Work Product in the trigger list
        for (Work_Product_Task__c T : [SELECT Id, State__c,Work_Product__c FROM Work_Product_Task__c WHERE Work_Product__c IN :WpTriggerList]) {
            CurrentWPState = WorkProductStates.get(t.Work_Product__c);
            TaskState = T.State__c;
        //if the current tasks's work product is not in the map of wpstates, add the task's state to it
        //as if there is only one task under a WP we know we can set WP state = Task state
            if (!(WorkProductStates.containsKey(T.Work_Product__c))) {
                WorkProductStates.put(T.Work_Product__c,TaskState);
        //if the work product is already in the map, then we know there is more than one task under that WP
        //in that case look at what the WP State is set to in the map
        //and then based on the State in the current task we are looking at, adjust the State value in the map accordingly. 
            } else {
                if (CurrentWPState == 'Completed') {
                    if (TaskState == 'In-Progress') {
                        WorkProductStates.put(T.Work_Product__c,TaskState);
                    }
                    else if (TaskState == 'Defined') {
                        WorkProductStates.put(T.Work_Product__c,'In-Progress');
                    }
                }
                else if (CurrentWPState == 'Defined' || CurrentWPState == NULL) {
                    if (TaskState == 'Completed') {
                        WorkProductStates.put(T.Work_Product__c,'In-Progress');
                    }
                    else if (TaskState == 'In-Progress') {
                        WorkProductStates.put(T.Work_Product__c,'In-Progress');
                    }
                }
            }                
        }

        Set<Work_Product__c> WPUpdateSet = new Set<Work_Product__c>();        
        List<Work_Product__c> WPUpdateList = new List<Work_Product__c>();
        Work_Product__c UpdatedWP;
        Map<ID,Datetime> WPDefinedDateMap = new Map<ID,Datetime>();
        
        //now find WorkProducts that don't have tasks assigned and so won't be represented in the map
        //do a query to find if those WPs ever had State set to Defined by checking Defined_Date_Time__c.
        //if it's not null we put it in a map for later comparison.  
        for (Work_Product__c wp : [SELECT ID, Defined_Date_Time__c FROM Work_Product__c WHERE ID IN :WpTriggerList]) {
            if (wp.Defined_Date_Time__c <> NULL ) {
                WPDefinedDateMap.put(wp.ID, wp.Defined_Date_Time__c);
            }
        }
        
        //now we go through the trigger list again 
        for(Work_Product_Task__c task : triggerList) {
            
            //if those work products have Defined_Date_Time set to something, set the state back to defined.
            //else set it to nothing.           
            if (!(WorkProductStates.containsKey(task.Work_Product__c)))  {
                UpdatedWP = new Work_Product__c();
                UpdatedWP.Id = task.Work_Product__c;
                //compare this wp to the map we made above.  If we find it we know
                //Defined_Date_Time__c is not null, and therefore in the absence of tasks
                //the WP State should be set to Defined. 
                if (WPDefinedDateMap.containsKey(task.Work_Product__c)) {
                    UpdatedWP.State__c='Defined';   
                } else {
                    UpdatedWP.State__c=NULL;
                }
                
                WPUpdateSet.add(UpdatedWP);
            }
            //for the work products that are in the map i.e. they have tasks under them
            //add it to a list of Work Products we will use to update
            else {
                UpdatedWP = new Work_Product__c();
                UpdatedWP.Id = task.Work_Product__c;
                UpdatedWP.State__c=WorkProductStates.get(task.Work_Product__c); 
                WPUpdateSet.add(UpdatedWP);
            }
            
        }
        
        //if there are work products to update, then update the Work Products        
        if (WPUpdateSet.size() > 0) { 
            for ( Work_Product__c LoopingWP : WPUpdateSet) {
                WPUPdateList.add(LoopingWP);
                }
                
            update WPUpdateList; 
        }
    }
    
    /**
    * @author       Kim Roth
    * @date         06/26/2013
    * @description  Sums the tasks estimates and to dos on every task for an iteration and release
    */
     public static void sumTaskEstimatesToDos(List<Work_Product_Task__c> triggerList) {
        
        List<ID> iterationIDList = new List<ID>();
        List<ID> releaseIDList = new List<ID>();
        List<ID> parentIDList = new List<ID>();
        List<ID> workProductIDList = new List<ID>();
        List<Work_Product_Task__c> workProductTasksForIteration = new List<Work_Product_Task__c>();
        List<Work_Product_Task__c> workProductTasksForRelease = new List<Work_Product_Task__c>();
        List<Work_Product_Task__c> workProductTasksForParent = new List<Work_Product_Task__c>();
        List<Iteration__c> iterationList = new List<Iteration__c>();
        List<SS_Release__c> releaseList = new List<SS_Release__c>();
        List<Work_Product__c> parentList = new List<Work_Product__c>();
        List<Work_Product__c> workProductList = new List<Work_Product__c>();
        
        //Create a list of work product IDs related to the tasks
        for(Work_Product_Task__c task : triggerList){
            workProductIDList.add(task.Work_Product__c);
        }
        
        system.debug('aadlfkjaldf');
        //query for all work products related to the updated tasks
        workProductList = [SELECT id, iteration__c, ss_release__c, parent__c FROM Work_Product__c WHERE id IN :workProductIDList];
        
        //query for list of iteration, release and parent IDs related to the updated tasks
        for(Work_Product__c workProd : workProductList){
            if(workProd.iteration__c <> NULL){
                iterationIDList.add(workProd.iteration__c);
            }
            if(workProd.ss_release__c <> NULL){
                releaseIDList.add(workProd.ss_release__c);
            }
            if(workProd.parent__c <> NULL){
                parentIDList.add(workProd.parent__c);
          	}
        }
        
        //Update iterations
        if(iterationIDList.size() > 0){       
            //query for all of the tasks related to the iterations in the list
            workProductTasksForIteration = [SELECT id, estimate__c, to_do__c, work_product__r.iteration__c from Work_Product_Task__c WHERE work_product__r.iteration__c IN :iterationIDList];        
            
            //query for all the iterations that need to be updated
            iterationList = [SELECT id, task_estimate__c, to_do__c FROM Iteration__c WHERE id IN :iterationIDList];
            
            //For each task, update iteration by adding the to do/estimate
            for(Iteration__c iteration : iterationList){
                iteration.task_estimate__c = 0;
                iteration.to_do__c = 0;
                for(Work_Product_Task__c task : workProductTasksForIteration){
                    if(task.work_product__r.iteration__c == iteration.id){
                        if(task.estimate__c <> NULL){
                            iteration.task_estimate__c+=task.estimate__c;
                        }
                        if(task.to_do__c <> NULL){
                            iteration.to_do__c+=task.to_do__c;
                        }
                    }
                }
            }
            update iterationList; 
        }
        
        //Update releases
        if(releaseIDList.size() > 0){ 
        	
        	//query for all the releases that need to be updated
            releaseList = [SELECT id, task_estimate__c, to_do__c FROM SS_Release__c WHERE id IN :releaseIDList];
                 
            //query for all of the tasks related to the releases in the list
            workProductTasksForRelease = [SELECT id, estimate__c, to_do__c, work_product__r.ss_release__c from Work_Product_Task__c WHERE work_product__r.ss_release__c IN :releaseIDList];
            
            //For each task, update release by adding the to do/estimate
            for(SS_Release__c release : releaseList){
                release.task_estimate__c = 0;
                release.to_do__c = 0;
                for(Work_Product_Task__c task : workProductTasksForRelease){
                    if(task.work_product__r.ss_release__c == release.id){
                        if(task.estimate__c <> NULL){
                            release.task_estimate__c+=task.estimate__c;
                        }
                        if(task.to_do__c <> NULL){
                            release.to_do__c+=task.to_do__c;
                        }
                    }
                }
            }
            update releaseList; 
        } 
        
        
        //Update parent work products
        if(parentIDList.size() > 0){
        	
        	//query for all parent work products
        	RecordType parentWPRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Parent User Story' AND SobjectType = 'Work_Product__c'];
            parentList = [SELECT id, plan_estimate_parent__c, accepted__c, to_do_parent__c, task_estimate_parent__c FROM Work_Product__c WHERE id IN :parentIDList AND recordTypeID = :parentWPRecordType.id];
            
            //query for all of the tasks related to the parents in the list
            workProductTasksForParent = [SELECT id, estimate__c, to_do__c, work_product__r.parent__c from Work_Product_Task__c WHERE work_product__r.parent__c IN :parentIDList];
            
            //For each task, update parent by adding the to do/estimate
            for(Work_Product__c parent : parentList){
                parent.task_estimate_parent__c = 0;
                parent.to_do_parent__c = 0;
                for(Work_Product_Task__c task : workProductTasksForParent){
                    if(task.work_product__r.parent__c == parent.id){
                        if(task.estimate__c <> NULL){
                            parent.task_estimate_parent__c+=task.estimate__c;
                        }
                        if(task.to_do__c <> NULL){
                            parent.to_do_parent__c+=task.to_do__c;
                        }
                    }
                }
            }
            update parentList; 
        	
        }
        
     }
    
    /**
    * @author       Kim Roth
    * @date         06/27/2013
    * @description  Updates the iteration with information from the work product
    */
    public static void updateIterationFromWorkProduct(List<Work_Product__c> triggerList){
        
        List<ID> iterationIDList = new List<ID>();
        List<Iteration__c> iterationList = new List<Iteration__c>();
        List<Work_Product__c> workProductList = new List<Work_Product__c>();
        
        //Create a list of iteration IDs related to the updated work products
        for(Work_Product__c workProduct : triggerList){
            if(workProduct.iteration__c <> NULL){
                iterationIDList.add(workProduct.iteration__c);
            }
        }
        
        if(iterationIDList.size() > 0){
            //query for all iterations related to the updated work products
            iterationList = [SELECT id, plan_estimate__c, accepted__c FROM Iteration__c WHERE id IN :iterationIDList];
               
            //query for list of work products related to the iterations
            workProductList = [SELECT id, iteration__c, plan_estimate__c, accepted_date_time__c, state__c FROM Work_Product__c WHERE iteration__c IN :iterationIDList];
       
            //For each work product, update iteration field by adding the # accepted and sum of plan estimate
            for(Iteration__c iteration : iterationList){
                
                iteration.accepted__c = 0;
                iteration.plan_estimate__c = 0;
                
                for(Work_Product__c workProduct : workProductList){
                    if(workProduct.iteration__c == iteration.id){
                        if(workProduct.plan_estimate__c <> NULL){
                            iteration.plan_estimate__c+=integer.valueOf(workProduct.plan_estimate__c);//JV 11-7-13: Added integer.valueOf() to convert String to Integer
                        
                            //sum plan estimate for accepted work products
                            if(workProduct.state__c == 'Accepted'){
                                iteration.accepted__c+=integer.valueOf(workProduct.plan_estimate__c); //JV 11-7-13: Added integer.valueOf() to convert String to Integer
                            }
                        }
                    }
                }
            }
            update iterationList; 
        } 
        
    }
    
    
    /**
    * @author       Kim Roth
    * @date         06/27/2013
    * @description  Updates the release with information from the work product
    */
    public static void updateReleaseFromWorkProduct(List<Work_Product__c> triggerList){
        
        List<ID> releaseIDList = new List<ID>();
        List<SS_Release__c> releaseList = new List<SS_Release__c>();
        List<Work_Product__c> workProductList = new List<Work_Product__c>();
        
        //Create a list of release IDs related to the updated work products
        for(Work_Product__c workProduct : triggerList){
            if(workProduct.ss_release__c <> NULL){
                releaseIDList.add(workProduct.ss_release__c);
            }
        }
        
        if(releaseIDList.size() > 0){
            //query for all releases related to the updated work products
            releaseList = [SELECT id, plan_estimate__c, accepted__c FROM SS_Release__c WHERE id IN :releaseIDList];
            
            //query for list of work products related to the releases
            workProductList = [SELECT id, ss_release__c, plan_estimate__c, accepted_date_time__c, state__c FROM Work_Product__c WHERE ss_release__c IN :releaseIDList];
       
            //For each work product, update release field by adding the # accepted and sum of plan estimate
            for(SS_Release__c release : releaseList){
                
                release.accepted__c = 0;
                release.plan_estimate__c = 0;
                
                for(Work_Product__c workProduct : workProductList){
                    if(workProduct.ss_release__c == release.id){
                        if(workProduct.plan_estimate__c <> NULL){
                            release.plan_estimate__c+=integer.valueOf(workProduct.plan_estimate__c); //JV 11-7-13: Added integer.valueOf() to convert String to Integer
                        
                            //sum plan estimate for accepted work products
                            if(workProduct.state__c == 'Accepted'){
                                release.accepted__c+=integer.valueOf(workProduct.plan_estimate__c); //JV 11-7-13: Added integer.valueOf() to convert String to Integer
                            }
                        }
                    }
                }
            }
            update releaseList;
        }       
    }
    
    /**
    * @author       Mark Baker
    * @date         06/27/2013
    * @description  Validates that closed Defects cannot be switched to User Story record types.
    */
     public static void preventClosedDefectsChanging (list<Work_Product__c> TriggerNewList,list<Work_Product__c> TriggerOldList) {
        
        integer I;
        RecordType DefectRecordType = [SELECT Id FROM RecordType WHERE Name = 'Defect' AND SobjectType = 'Work_Product__c'];
        
        for (I=0; I<TriggerNewList.Size(); I++) {
            if (TriggerOldList[I].Defect_State__c == 'Closed' && TriggerOldList[I].RecordTypeId == DefectRecordType.Id && TriggerNewList[I].RecordTypeId <> TriggerOldList[I].RecordTypeId) {
                TriggerNewList[I].addError('You cannot convert a Closed Defect to a User Story.');
            }
        }
        
     }
     
     
    /**
    * @author       Kim Roth
    * @date         07/02/2013
    * @description  Updates the parent work product with information from the work product
    */
    public static void updateParentWorkProductFromChildWorkProduct(List<Work_Product__c> triggerList){
        
        RecordType parentWPRecordType;
        List<ID> parentIDList = new List<ID>();
        List<Work_Product__c> parentWPList = new List<Work_Product__c>();
        List<Work_Product__c> workProductList = new List<Work_Product__c>();
        
        //Get parent user story record type id
        parentWPRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Parent User Story' AND SobjectType = 'Work_Product__c'];
        
        //Create a list of parent IDs related to the updated work products
        for(Work_Product__c workProduct : triggerList){
            if(workProduct.parent__c <> NULL){
                parentIDList.add(workProduct.parent__c);
            }
        }
        
        if(parentIDList.size() > 0){
            //query for all parent work products
            parentWPList = [SELECT id, plan_estimate_parent__c, accepted__c FROM Work_Product__c WHERE id IN :parentIDList AND recordTypeID = :parentWPRecordType.id];
            
            //query for a list of work products related to the parent work product
            workProductList = [SELECT id, parent__c, plan_estimate__c, accepted_date_time__c FROM Work_Product__c WHERE parent__c IN :parentIDList];
            
            //for each work product, update the parent work product by adding the sum of plan estimate 
            for(Work_Product__c parent : parentWPList){
                parent.plan_estimate_parent__c = 0;  
                parent.accepted__c = 0;               
                for(Work_Product__c workProduct : workProductList){
                    if(workProduct.parent__c == parent.id) {
                        if(workProduct.plan_estimate__c <> NULL){
                            parent.plan_estimate_parent__c+=integer.valueOf(workProduct.plan_estimate__c);
                            
                             //sum plan estimate for accepted work products
                            if(workProduct.accepted_date_time__c <> NULL){
                                parent.accepted__c+=integer.valueOf(workProduct.plan_estimate__c);
                            }
                        }
                    }
                }
            }

            update parentWPList;        
        }
    
    }   
    
    
}