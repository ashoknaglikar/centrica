@isTest
private class SASF7525VendorSupplierScheduler_test {

    static testMethod void myUnitTest() {
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new SASF7525VendorSupplierScheduler());
        SASF7525VendorSupplierScheduler SASFVendor = new SASF7525VendorSupplierScheduler();
        SASFVendor.execute(sc); 
    }
}