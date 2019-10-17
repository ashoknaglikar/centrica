global class dummyclass{

webservice static void sendedi(){
   DispatchOrdertoEDI d = new DispatchOrdertoEDI ();
   d.createOrderBatch();

}

webservice static void getedi(){
    EDIStatusUpdate eOrder = new EDIStatusUpdate();
    eOrder.updateOrders(); 

}
webservice static void sendsappo(){
       BatchPopulateSFPO7523Records BP1 = NEW BatchPopulateSFPO7523Records();
       BP1.createSAPBatch();

} 
webservice static void setdeposit(){
       PerformOpportunityReconcilliation.reconcile();

}
webservice static void getsappo(){
        BatchUpdateSFPO7523Records BP2 = NEW BatchUpdateSFPO7523Records();
       BP2.updateSAPBatch();

}
webservice static void sendgrdata(){

        BatchPopulateSFPO7524Records UPD_rcpt1 = new BatchPopulateSFPO7524Records();
        UPD_rcpt1.GoodReceiptItems();
}
webservice static void getgrdata(){
        BatchUpdateSFPO7524Records UPD_rcpt2 = NEW BatchUpdateSFPO7524Records ();
        UPD_rcpt2.UpdGoodReceiptItems(); 

}
webservice static void getvendordata(){
        SASF7525VendorSupplierRegionBatch UPD_rcpt2 = NEW SASF7525VendorSupplierRegionBatch ();
        UPD_rcpt2.createVendorBatch(); 

}
webservice static void deledidata(){
        BatchDeleteSFPO7541ErrRecords del_edi = NEW BatchDeleteSFPO7541ErrRecords ();
        del_edi.deleteErrorData(); 

}
webservice static void sdledi(){
        AutoScheduleDispatchOrderToEDI sdl_edi = NEW AutoScheduleDispatchOrderToEDI ();
        sdl_edi.scheduleOrdersManually(); 

}
webservice static void sdlSAP(){
        AutoScheduleDispatchToSAP sdl_SAP = new AutoScheduleDispatchToSAP();
        sdl_SAP.scheduleOrdersManually(); 

}

}