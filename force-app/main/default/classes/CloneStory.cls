/**
* @author       Sanjay Gidwani      
* @date         06/11/2013
* @description  Controller class for the clone story page.  Responsible for 
*               retrieveing and presenting the old user story details with 
*               tasks for the user to modify and add to the new user story 
*
*    --------------------------------------------------------------------------
*    Developer                  Date                Description
*    --------------------------------------------------------------------------
*   
*    Sanjay Gidwani             06/11/2013          Created
*/


public with sharing class CloneStory {
    
    public Work_Product__c workProduct {get; private set;}
    public List<CheckedTask> taskList  {get; set;}
    
    public CloneStory(){
        Id id = ApexPages.currentPage().getParameters().get('id');
        
        //TODO: Throw exeception if ID == null
        workProduct = 
            [SELECT Name,Description__c, Acceptance_Critiera__c,
                Iteration__c, Project__c,  Owner__c, SS_Release__c,
                Parent__c, State__c, Ready__c,Blocked__c, 
                Blocked_Reason__c, Plan_Estimate__c,
                (SELECT Name, Description__c, Owner__c, State__c, 
                    Ready__c, Blocked__c, Blocked_Reason__c, Estimate__c, To_Do__c,
                    Time_Spent__c, Notes__c FROM Work_Product_Task__r 
                    WHERE State__c != 'Completed')
                FROM Work_Product__c  WHERE Id = :id  LIMIT 1];
        
        taskList = new List<CheckedTask>();
        
        for(Work_Product_Task__c task: workProduct.Work_Product_Task__r){
            CheckedTask checkedTask = new CheckedTask();
            CheckedTask.task = task;
           
            taskList.add(checkedTask);
        }
    } 
    
    public PageReference save() {
        Work_Product__c clonedWorkProduct = new Work_Product__c();
        
        try {
            //Copy workproduct to new WP object
            clonedWorkProduct = workProduct;
            clonedWorkProduct.Continued_From__c = workProduct.Id;
            clonedWorkProduct.Id = null;
            
            //insert work product
            Database.insert(clonedWorkProduct);
            
            List<Work_Product_Task__c> tasks = new List<Work_Product_Task__c>();
            List<Id> taskIdsToDelete = new List<Id>();
            for(Integer i =0; i<taskList.size(); i++){
                if(taskList[i].checked){
                    //build the list of IDs to delete          
                    system.debug(String.valueof(i) + taskList[i].task.Id);      
                    taskIdsToDelete.add(taskList[i].task.Id);
                    
                    //set the id to the cloned id
                    //taskList[i].task.Id = null;
                    taskList[i].task.Work_Product__c = clonedWorkProduct.Id;
                    tasks.add(taskList[i].task);
                }
            }
            
            //insert tasks
            Database.update(tasks);
            //delete the old tasks
            //Database.delete(taskIdsToDelete);
        
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
        }
        
        //  After Save, navigate to the default view page:
        return (new ApexPages.StandardController(clonedWorkProduct)).view();
    }
    
    public PageReference cancel(){
        return (new ApexPages.StandardController(workProduct)).view();
    }

    public class CheckedTask {
        public Work_Product_Task__c task{get;set;}
        public Boolean checked{get;set;}
        public CheckedTask(){
            this.task = new Work_Product_Task__c();
            checked = false;
        }
    }

}