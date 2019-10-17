/*
        Author          : Cognizant
        Functionality   : This is a Test class for the Housekeeping_SFED7542_Scheduler Class
        Create Date     : 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_SFED7542_Scheduler_test {

    static testMethod void Housekeeping_SFED7542_Scheduler_Method()
    {
       Test.StartTest();     
       Housekeeping_SFED7542_Scheduler HK_SFED= new Housekeeping_SFED7542_Scheduler();
       String context= '0 0 0 * * ? *';
       SchedulableContext sc;
       System.schedule('testScheduledApex',context, new Housekeeping_SFED7542_Scheduler());
       HK_SFED.execute(sc); 
       Test.stopTest();
    }
}