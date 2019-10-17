/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the Housekeeping_NBBS_Scheduler Class
        Create Date  	: 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_NBBS_Scheduler_test {

    static testMethod void Housekeeping_NBBS_Scheduler_method()
     {
     	Test.StartTest();
      	Housekeeping_NBBS_Scheduler HK_Nbbs = new Housekeeping_NBBS_Scheduler();
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_NBBS_Scheduler());
        HK_Nbbs.execute(sc); 
        Test.stopTest();
    }
}