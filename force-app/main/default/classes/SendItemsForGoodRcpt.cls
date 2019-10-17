/*
* CLASS - SendItemsForGoodRcpt
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to send items for good receipt via a batch apex class
*/
global class SendItemsForGoodRcpt implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to updateOrders method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        BatchPopulateSFPO7524Records goodRctItems = new BatchPopulateSFPO7524Records();
        goodRctItems.GoodReceiptItems();
    }
}