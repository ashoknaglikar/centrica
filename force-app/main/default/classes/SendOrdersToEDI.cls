/*
* CLASS - SendOrdersToEDI
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to send the chnaged/careetd orders to EDI via a batch apex class
*/
global class SendOrdersToEDI implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to reconcile method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        DispatchOrdertoEDI dOrder = new DispatchOrdertoEDI();
        dOrder.createOrderBatch();
        
    }
}