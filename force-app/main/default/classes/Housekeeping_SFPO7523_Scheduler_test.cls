/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the Housekeeping_SFPO7523_Scheduler Class
        Create Date  	: 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_SFPO7523_Scheduler_test {

    static testMethod void Housekeeping_SFPO7523_Scheduler_Method() {
    	Test.StartTest();    
        Housekeeping_SFPO7523_Scheduler HK_SFPO = new Housekeeping_SFPO7523_Scheduler();
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_SFPO7523_Scheduler());
        HK_SFPO.execute(sc); 
        Test.stopTest();
    }
}