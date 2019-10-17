@isTest
private class AutoScheduleDispatchOrderToEDI_test {

    static testMethod void TestAutoSchduler() {
      
        //try
        {
            Lock.isTestRunner = true;
            AutoScheduleDispatchOrderToEDI ASDOEDI = new AutoScheduleDispatchOrderToEDI();  
            ASDOEDI.scheduleOrdersManually();
            String str = ASDOEDI.getsRenderJobInfoBlock();
            str = ASDOEDI.getExistingJobsMessage();
            str = ASDOEDI.getCurrentJobsMessage();
            List<String> lststr = ASDOEDI.getExistingJobs();
            lststr = ASDOEDI.getCurrentJobs();
            Lock.isTestRunner = false;
         // String s=ASDOEDI.sCron00;
            //system.assertEquals('null',ASDOEDI.getExistingJobsMessage());
            //system.assertEquals('null',ASDOEDI.getCurrentJobsMessage());
      
            //ASDOEDI.setExistingJobsMessage();
            //   String b = ASDOEDI.getExistingJobsMessage();
        }
        /*catch(system.exception e)
        {
        
        }*/
    }    
}