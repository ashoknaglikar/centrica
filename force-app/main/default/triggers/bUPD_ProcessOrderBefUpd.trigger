/*
*    Functionality of this trigger - 
*    1. Auto submit the order for approval
*/
trigger bUPD_ProcessOrderBefUpd on order__c (before update) {
    Order__c[] oldOrderList = Trigger.old;
    Integer cnt = 0;
    try {
        for(order__c order : Trigger.new){
            // checking the approval process
            
            System.debug('#old= #'+oldOrderList[cnt].job_delivery_date__c +' : '+order.job_delivery_date__c);
            if(!(order.Sync__c) ){
                Decimal oldVal = oldOrderList[cnt].Active_Line_Item_Value__c - oldOrderList[cnt].Inactive_Line_Item_Value__c;
                Decimal newVal = order.Active_Line_Item_Value__c - order.Inactive_Line_Item_Value__c;
                System.debug('@OLD = @'+oldVal);
                System.debug('@NEW = @'+newVal);
                if(oldVal != newVal && newVal >= 3000){
                   if(oldOrderList[cnt].Inactive_Line_Item_Value__c >= 0 && oldOrderList[cnt].Inactive_Line_Item_Value__c < order.Inactive_Line_Item_Value__c){
                   }else{
                   order.Topcall_Fax_Status__c='';
                   order.P5_SAP_Status__c='';
                   order.P5_Good_Receipting_Status__c='';
                   order.EDI_Status__c='';
                   order.Approved__c = false;
                   Approval.ProcessSubmitRequest objAppreq = new Approval.ProcessSubmitRequest();
                   objAppreq.setComments('Submitting request for approval.');
                   objAppreq.setObjectId(order.id);
                   Approval.ProcessResult result = Approval.process(objAppreq); 
                   //System.assert(result.isSuccess());        
                   }
                }
             }
             CancelOrderLineItemsCntrl canOrdr = new CancelOrderLineItemsCntrl();
             order = canOrdr.setOrderStat(order);             
             
             cnt++;
        }
    } catch(Exception ex){
        System.debug('Exception = '+ex);
    }
}