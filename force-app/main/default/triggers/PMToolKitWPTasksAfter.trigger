trigger PMToolKitWPTasksAfter on Work_Product_Task__c (after delete, after insert, after undelete, 
after update) {
    if (Trigger.isDelete) {
        PMToolKitWorkProductActions.setWorkProductState(trigger.Old);
        PMToolKitWorkProductActions.sumTaskEstimatesToDos(trigger.Old);
    }
    else {
        PMToolKitWorkProductActions.setWorkProductState(trigger.New);  
        PMToolKitWorkProductActions.sumTaskEstimatesToDos(trigger.New); 
    }
    
    
}