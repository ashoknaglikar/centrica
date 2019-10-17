trigger CS_AllPartMaterialTrigger on CS_Part_Material__c (after insert, after update, before delete) {

    // Do not execute for any user that has the No Triggers flag set to true
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c) 
    { 
        if (Trigger.isDelete) {
            CS_AllMaterialTriggerHelper.updatePartTotalMCostAfterPMDeletion(Trigger.oldMap); 
        }
        else {
            CS_AllMaterialTriggerHelper.updatePartTotalMCost(Trigger.newMap, 'partMaterial');   
        }
    }    
}