/*
        Author          : Cognizant
        Functionality   : This is a Test class for the HouseKeeping_TopcallBatch_scheduler Class
        Create Date     : 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class HouseKeeping_TopcallBatch_scheduler_test {

    static testMethod void myUnitTestHouseKeeping_TopcallBatch_scheduler_method() 
    {
    	Test.startTest();
        HouseKeeping_TopcallBatch_scheduler HK_Topcall= new HouseKeeping_TopcallBatch_scheduler();
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new HouseKeeping_TopcallBatch_scheduler());
        HK_Topcall.execute(sc); 
        Test.stopTest();
    }
}