/*
        Author          : Cognizant
        Functionality   : This is a Test class for the Housekeeping_SearchResult Class
        Create Date     : 31 Oct 2011
        Change History  :
        Modified Date   :
 */
@isTest
private class HK_SearchResult_Scheduler_test {

    static testMethod void HK_SearchResult_Scheduler_method() 
    {
        Test.StartTest();     
        Housekeeping_SearchResult_Scheduler HK_searchresult= new Housekeeping_SearchResult_Scheduler();
        String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_SearchResult_Scheduler());
        HK_searchresult.execute(sc); 
        Test.stopTest();
    }
}