@isTest
private class SendOrderstoEDI_test {

    static testMethod void myUnitTest() {
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new SendOrdersToEDI());
        SendOrdersToEDI OrderEDI = new SendOrdersToEDI();
        OrderEDI.execute(sc);  
    }
}