/*
* CLASS - UpdateItemsOnGoodRcpt
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to update order line items EDI status via a batch apex class
*/
global class UpdateItemsOnGoodRcpt implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to updateOrders method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        BatchUpdateSFPO7524Records goodRctItems = new BatchUpdateSFPO7524Records();
        goodRctItems.UpdGoodReceiptItems();
    }
}