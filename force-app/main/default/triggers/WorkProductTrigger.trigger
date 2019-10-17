/**
* @author       Kim Roth        
* @date         06/15/2013
* @description  Trigger for workproduct
*
*    -----------------------------------------------------------------------------
*    Developer                  Date                Description
*    -----------------------------------------------------------------------------
*   
*    Kim Roth					06/15/2013			Initial creation
*/

trigger WorkProductTrigger on Work_Product__c (after delete, after insert, after undelete, after update, before update) {
  
  if(Trigger.isBefore) {
    PMToolKitWorkProductActions.preventClosedDefectsChanging(Trigger.new, Trigger.old);
  } else if(Trigger.isAfter) {
    if (Trigger.isDelete) {
        PMToolKitWorkProductActions.updateIterationFromWorkProduct(Trigger.old);
        PMToolKitWorkProductActions.updateReleaseFromWorkProduct(Trigger.old);
        PMToolKitWorkProductActions.updateParentWorkProductFromChildWorkProduct(Trigger.old);
    } else {
        PMToolKitWorkProductActions.updateIterationFromWorkProduct(Trigger.new);
        PMToolKitWorkProductActions.updateReleaseFromWorkProduct(Trigger.new);
        PMToolKitWorkProductActions.updateParentWorkProductFromChildWorkProduct(Trigger.new);
    }    
  }
}