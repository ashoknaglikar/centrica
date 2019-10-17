/*
   		Author          : Cognizant
   		Functionality  	: This is a Test class for the Housekeeping_SASF7525Supplier_Scheduler Class
        Create Date  	: 26 July 2010
        Change History  :
        Modified Date   :
 */
@isTest
private class HK_SASF7525Supplier_Scheduler_test {

    static testMethod void HK_SASF7525Supplier_Scheduler_method() 
    {
    	Test.StartTest();     
        Housekeeping_SASF7525Supplier_Scheduler HK_Sasf_supplier= new Housekeeping_SASF7525Supplier_Scheduler();
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_SASF7525Supplier_Scheduler());
        HK_Sasf_supplier.execute(sc); 
        Test.stopTest();
    }
}