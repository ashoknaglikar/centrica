/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the Housekeeping_SAHRSF_Scheduler Class
        Create Date  	: 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class Housekeeping_SAHRSF_Scheduler_test {

    static testMethod void Housekeeping_SAHRSF_Method() 
    {
    	Test.StartTest();     
    	Housekeeping_SAHRSF_Scheduler HK_Sahrsf = new Housekeeping_SAHRSF_Scheduler();
    	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_SAHRSF_Scheduler());
        HK_Sahrsf.execute(sc); 
    	Test.stopTest();    
	
    }
}