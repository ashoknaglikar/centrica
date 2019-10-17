@isTest
private class Housekeeping_Job_Booking_History_test {

    static testMethod void Housekeeping_Job_Booking_Histor_Method() {
        Test.StartTest();     
        Housekeeping_Job_Booking_History HK_JBH= new Housekeeping_Job_Booking_History();
       	String context= '0 0 0 * * ? *';
        SchedulableContext sc;
        System.schedule('testScheduledApex',context, new Housekeeping_Job_Booking_History());
        HK_JBH.execute(sc); 
        Test.stopTest();
    }
}