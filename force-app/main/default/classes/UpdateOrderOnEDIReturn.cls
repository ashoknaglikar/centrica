/*
* CLASS - UpdateOrderOnEDIReturn
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to update orders' EDI status via a batch apex class
*/
global class UpdateOrderOnEDIReturn implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to updateOrders method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        EDIStatusUpdate eOrder = new EDIStatusUpdate();
        eOrder.updateOrders();
    }
}