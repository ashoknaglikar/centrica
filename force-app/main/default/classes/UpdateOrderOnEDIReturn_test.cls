@isTest
private class UpdateOrderOnEDIReturn_test {

    static testMethod void myUnitTest() {
          String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new UpdateOrderOnEDIReturn());
        UpdateOrderOnEDIReturn OrderEDI = new UpdateOrderOnEDIReturn();
        OrderEDI.execute(sc); 
    }
}