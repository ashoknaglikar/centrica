@isTest
private class HK_ELESCSA_Report_Scheduler_test {

    static testMethod void HK_ELESCSA_Report_Scheduler_Method() {
        Test.StartTest();     
        HouseKeeping_ELESCSA_Report_Scheduler HK_ElescsaReport= new HouseKeeping_ELESCSA_Report_Scheduler();
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new HouseKeeping_ELESCSA_Report_Scheduler());
        HK_ElescsaReport.execute(sc); 
        Test.stopTest();
    }
}