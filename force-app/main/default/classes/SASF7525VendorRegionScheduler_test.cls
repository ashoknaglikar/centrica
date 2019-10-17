@isTest
private class SASF7525VendorRegionScheduler_test {

    static testMethod void myUnitTest() {
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new SASF7525VendorRegionScheduler());
        SASF7525VendorRegionScheduler SASFVendor = new SASF7525VendorRegionScheduler();
        SASFVendor.execute(sc); 
    }
}