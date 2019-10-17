/*
* CLASS - updatePOonSAPReturn
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to update purchse order line item on return ack from SAP
*/
global class updatePOonSAPReturn implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to updateOrders method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        BatchUpdateSFPO7523Records eOrder = new BatchUpdateSFPO7523Records();
        eOrder.updateSAPBatch();
    }
}