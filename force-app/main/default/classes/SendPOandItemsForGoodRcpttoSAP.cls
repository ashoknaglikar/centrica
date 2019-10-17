/*
* CLASS - sendPOtoSAP
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to send purchse order line item to SAP
*/
global class SendPOandItemsForGoodRcpttoSAP implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to updateOrders method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
    
        //Send Purchase Order to SAP
        BatchPopulateSFPO7523Records eOrder = new BatchPopulateSFPO7523Records();
        eOrder.createSAPBatch();
        
        //Send Items for Good Receipt
        BatchPopulateSFPO7524Records goodRctItems = new BatchPopulateSFPO7524Records();
        goodRctItems.GoodReceiptItems();
        
        //Send Items for Good Receipt
        BatchUpdateSFPO7524Records goodRctItemsupdate = new BatchUpdateSFPO7524Records();
        goodRctItemsupdate.UpdGoodReceiptItems();
        
        //Send Items for Good Receipt
        BatchUpdateSFPO7523Records updateSapstatus = new BatchUpdateSFPO7523Records ();
        updateSapstatus.updateSAPBatch();
        
        appointmentHistoryCreator.invokeBatch();


    }
}