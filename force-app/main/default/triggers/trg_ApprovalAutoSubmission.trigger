trigger trg_ApprovalAutoSubmission on Consumables_Requests__c (after update) {
    /**
        Auto Submission of Approval Process for Consumable Request 
        where Capital Items have been ordered by the Installers.
    */
   if (cls_IsRun.isConsumReq==false){  
   cls_IsRun.setIsConsumReq();

    try {
        for (Consumables_Requests__c obj_Consumables:Trigger.new) {
            //Create an approval request for the Consumable Request
            Approval.ProcessSubmitRequest appRequest = new Approval.ProcessSubmitRequest();
            appRequest.setComments('Submitting request for approval');
            appRequest.setObjectId(obj_Consumables.id);
            //Submit the approval request for the Consumable Request
            Approval.ProcessResult result = Approval.process(appRequest);
        }
    } catch(Exception ex) {
        System.debug(ex.getMessage());
    }
   }
}