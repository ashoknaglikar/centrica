@isTest
private class HK_GasSafe_Report_Scheduler_test {

    static testMethod void HK_GasSafe_Report_Method() {
       	Test.StartTest();     
        HouseKeeping_GasSafe_Report_Scheduler HK_GassafeReport= new HouseKeeping_GasSafe_Report_Scheduler();
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new HouseKeeping_GasSafe_Report_Scheduler());
        HK_GassafeReport.execute(sc); 
        Test.stopTest();
    }
}