global class SASF7525VendorSupplierScheduler implements Schedulable { 
            
    global void execute(SchedulableContext sc) 
    {        
        SASF7525VendorSupplierInterBatch SASF7525VendorSupp = new SASF7525VendorSupplierInterBatch();
        SASF7525VendorSupp.createVendorBatch();
    }

}