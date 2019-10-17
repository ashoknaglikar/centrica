global class SASF7525VendorRegionScheduler implements Schedulable { 
            
    global void execute(SchedulableContext sc) 
    {        
        SASF7525VendorSupplierRegionBatch SASF7525VendorRegion = new SASF7525VendorSupplierRegionBatch();
        SASF7525VendorRegion.createVendorBatch();
    }
}