@isTest
private class UpdatePOonSAPReturn_test {

    static testMethod void myUnitTest() {
          String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new updatePOonSAPReturn());
        updatePOonSAPReturn POSAP = new updatePOonSAPReturn();
        POSAP.execute(sc); 
    }
}