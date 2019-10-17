global class ProcessOrderForFaxAndEDI implements Schedulable{
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to reconcile method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        //PURPOSE - The Purpose of this class is to Send Orders to Topcall Interface Class
        TopcallFaxHeaderRecord.reconcile(System.Label.TOP_CALL_INTERFACE_STATUS);
        
        //PURPOSE - The Purpose of this class is to send the changed/created orders to EDI via a batch apex class
        
        //Method commented out as work is in progress
        DispatchOrdertoEDI dOrder = new DispatchOrdertoEDI();
        dOrder.createOrderBatch();
        
        //PURPOSE - The Purpose of this class is to update orders' EDI status via a batch apex class
        EDIStatusUpdate eOrder = new EDIStatusUpdate();
        eOrder.updateOrders();
        //scheduleClassMethod();
    }
    
   /* private void scheduleClassMethod(){
        DateTime dtNow=System.now();
        dtNow=dtNow.addMinutes(15);
        String sDay=String.ValueOf(dtNow.day());
        String sMonth=String.ValueOf(dtNow.month());
        String sYear=String.ValueOf(dtNow.year());
        String sHour=String.ValueOf(dtNow.hour());
        String sMinute=String.ValueOf(dtNow.minute());
        String sSecond=String.ValueOf(dtNow.second());
        
        String sTriggerClass='0 ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        System.schedule('TopcallFax'+sMinute+'min',sTriggerClass , new GenerateTopcallPage());
    }*/
}