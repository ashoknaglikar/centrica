/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the HouseKeeping_SFPO7524_Scheduler Class
        Create Date  	: 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class HouseKeeping_SFPO7524_Scheduler_test {

    static testMethod void HouseKeeping_SFPO7524_Scheduler_Method()
    {
    	Test.StartTest();     
        HouseKeeping_SFPO7524_Scheduler HK_SFPO = new HouseKeeping_SFPO7524_Scheduler();
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new HouseKeeping_SFPO7524_Scheduler());
        HK_SFPO.execute(sc); 
        Test.stopTest();
    }
}