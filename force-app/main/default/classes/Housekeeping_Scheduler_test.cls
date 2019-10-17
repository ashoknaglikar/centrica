/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the Housekeeping_Scheduler Class
        Create Date  	: 22 May 2013
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_Scheduler_test {

    static testMethod void Housekeeping_Scheduler_method()
     {
        Test.StartTest();
      	Housekeeping_Scheduler HK_nss = new Housekeeping_Scheduler();
        String context= '0 52 8,10,12,14,16,18,20,22 ? * THU	';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_Scheduler());
        HK_nss.execute(sc); 
        HK_nss.StartBatchDelete=true;
        HK_nss.execute(sc); 
        Test.stopTest();
    }
}