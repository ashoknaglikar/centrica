//This is test class for workZoneScheduler apex class
@isTest
private class workZoneSchedulerTest{

static testmethod void InvokeSceduler()
   {
 
    Test.startTest();
    workZoneScheduler wzsch=new workZoneScheduler();
    String chron = '0 0 23 * * ?';        
    system.schedule('Test Sched', chron, wzsch);
    Test.stopTest();
   }

}