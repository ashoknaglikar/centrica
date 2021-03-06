/**
* CLASS - AutoScheduleDispatchOrderToEDI
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to call a Schedular class 
*           which will populate Orders ready to be dispatched to EDI into interface object.
*           This class will be called from VF to scedule the job to populate orders every 15 minutes.
*/

public class AutoScheduleDispatchOrderToEDI
{
    //VARIABLE DECLARATION SECTION.
    String sCron55;
    String sCron15;
    String sCron30;
    String sCron45;
    
    //Suguna
    /*String sNPSCron0;
    String sNPSCron15;
    String sNPSCron30;
    String sNPSCron45;
    
    String sNPSCron0_1;
    String sNPSCron15_1;
    String sNPSCron30_1;
    String sNPSCron45_1;*/
    //ends
    
    String sCronPO55;
    String sRenderJobInfoBlock;
    String existingJobsMessage = null;
    String currentJobsMessage = null;
    
    List<String> existingScheduledJobList;
    List<String> currentlyScheduledJobList;
    List<String> existingJobNameList;
    List<String> currentlyJobNameList;
    
    List<String> cronExpressionList;
    List<String> jobNameList;
    List<CronTrigger> cronTriggerList;
    Map<String, String> cronStringJobNameMap;
    Map<String, String> nameExpressionMap;
    
    //PUBLIC CONSTRUCTOR.
    public AutoScheduleDispatchOrderToEDI()
    {
        //INSTANTIATING COLLECTIONS.
        existingScheduledJobList = new List<String>();
        currentlyScheduledJobList = new List<String>();
        existingJobNameList = new List<String>();
        currentlyJobNameList = new List<String>();
        cronTriggerList = new List<CronTrigger>(); 
        
        cronExpressionList = new List<String>();
        jobNameList = new List<String>();
        cronTriggerList = new List<CronTrigger>();
        cronStringJobNameMap = new Map<String,String>();
        nameExpressionMap = new Map<String,String>();
        
        //SETTING THE VALUE SO THAT JOBS INFO BLOCK SHOULD NOT BE RENDERED FIRST TIME. 
        sRenderJobInfoBlock = 'false';  
        
        //ASSIGNING CRON EXPRESSION LITERALS. 
        /*Integer hr = System.now().hour();
        System.debug('---------IMPORTANT   '+hr);   
        if(hr == 12){
            Integer dayToday = ((System.now()).Day()+ 1);
            
           sCron55 = '0 55 7-12 ? * MON-SAT *';
            system.debug('testinggggggggggggg'+sCron55);
           // sCron55 = '0 55 * ? * * *';
            sCron15 = '0 01 7-12 ? * MON-SAT *';
            sCron30 = '0 30 7-12 ? * MON-SAT *';
            sCron45 = '0 45 7-12 ? * MON-SAT *';
           /* sCron55 = '0 55 7-22 '+dayToday+' * MON-SAT *';
            system.debug('testinggggggggggggg'+sCron55);
            sCron15 = '0 15 7-22 '+dayToday+' * MON-SAT *';
            sCron30 = '0 30 7-22 '+dayToday+' * MON-SAT *';
            sCron45 = '0 45 7-22 '+dayToday+' * MON-SAT *';
            
       } else{ */  
            sCron55 = '0 55 7-22 ? * MON-SAT *';
           // sCron55 = '0 55 * ? * * *';
            sCron15 = '0 15 7-22 ? * MON-SAT *';
            sCron30 = '0 30 7-22 ? * MON-SAT *';
            sCron45 = '0 45 7-22 ? * MON-SAT *';
            
            //Suguna - every 15 minutes between Mon – Fri 08:00 – 20:00 Sat, Sun 10:00 – 18:00. 
            /*sNPSCron0  = '0 0 8-20 ? * MON-FRI *';
            sNPSCron15 = '0 15 8-19 ? * MON-FRI *';
            sNPSCron30 = '0 30 8-19 ? * MON-FRI *';
            sNPSCron45 = '0 45 8-19 ? * MON-FRI *';
    
            sNPSCron0_1  = '0 0 10-18 ? * SAT-SUN *';
            sNPSCron15_1 = '0 15 10-17 ? * SAT-SUN *';
            sNPSCron30_1 = '0 30 10-17 ? * SAT-SUN *';
            sNPSCron45_1 = '0 45 10-17 ? * SAT-SUN *';*/
            //ends
            
       // }
        
        //POPULATING COLLECTIONS.
        cronExpressionList.add(sCron55);
        cronExpressionList.add(sCron15);
        cronExpressionList.add(sCron30);
        cronExpressionList.add(sCron45);
        
        //Suguna
        /* cronExpressionList.add(sNPSCron0);
          cronExpressionList.add(sNPSCron15);
           cronExpressionList.add(sNPSCron30);
            cronExpressionList.add(sNPSCron45);
             cronExpressionList.add(sNPSCron0_1);
              cronExpressionList.add(sNPSCron15_1);
               cronExpressionList.add(sNPSCron30_1);
                cronExpressionList.add(sNPSCron45_1);*/
            //ends    
        
        string testAppender = '';
        if(Lock.isTestRunner)
        {
            testAppender = '_test';
        }
       
       
        jobNameList.add('FaxAndEDIJobFor55thMinute'+testAppender);
        jobNameList.add('FaxAndEDIJobFor15thMinute'+testAppender);
        jobNameList.add('FaxAndEDIJobFor30thMinute'+testAppender);
        jobNameList.add('FaxAndEDIJobFor45thMinute'+testAppender);
        
        nameExpressionMap.put('FaxAndEDIJobFor55thMinute'+testAppender,sCron55);
        nameExpressionMap.put('FaxAndEDIJobFor15thMinute'+testAppender,sCron15);
        nameExpressionMap.put('FaxAndEDIJobFor30thMinute'+testAppender,sCron30);
        nameExpressionMap.put('FaxAndEDIJobFor45thMinute'+testAppender,sCron45);
       
        cronStringJobNameMap.put(sCron55,'FaxAndEDIJobFor55thMinute'+testAppender);
        cronStringJobNameMap.put(sCron15,'FaxAndEDIJobFor15thMinute'+testAppender);
        cronStringJobNameMap.put(sCron30,'FaxAndEDIJobFor30thMinute'+testAppender);
        cronStringJobNameMap.put(sCron45,'FaxAndEDIJobFor45thMinute'+testAppender);  
        
        //Suguna
        /*jobNameList.add('NPSTriggerFor0thMinute'+testAppender);
        jobNameList.add('NPSTriggerFor15thMinute'+testAppender);
        jobNameList.add('NPSTriggerFor30thMinute'+testAppender);
        jobNameList.add('NPSTriggerFor45thMinute'+testAppender);
        jobNameList.add('NPSTriggerFor0thMinute_1'+testAppender);
        jobNameList.add('NPSTriggerFor15thMinute_1'+testAppender);
        jobNameList.add('NPSTriggerFor30thMinute_1'+testAppender);
        jobNameList.add('NPSTriggerFor45thMinute_1'+testAppender);
        
        nameExpressionMap.put('NPSTriggerFor0thMinute'+testAppender,sNPSCron0);
        nameExpressionMap.put('NPSTriggerFor15thMinute'+testAppender,sNPSCron15);
        nameExpressionMap.put('NPSTriggerFor30thMinute'+testAppender,sNPSCron30);
        nameExpressionMap.put('NPSTriggerFor45thMinute'+testAppender,sNPSCron45);
        nameExpressionMap.put('NPSTriggerFor0thMinute_1'+testAppender,sNPSCron0_1);
        nameExpressionMap.put('NPSTriggerFor15thMinute_1'+testAppender,sNPSCron15_1);
        nameExpressionMap.put('NPSTriggerFor30thMinute_1'+testAppender,sNPSCron30_1);
        nameExpressionMap.put('NPSTriggerFor45thMinute_1'+testAppender,sNPSCron45_1);
        
        cronStringJobNameMap.put(sNPSCron0,'NPSTriggerFor0thMinute'+testAppender);
        cronStringJobNameMap.put(sNPSCron15,'NPSTriggerFor15thMinute'+testAppender);
        cronStringJobNameMap.put(sNPSCron30,'NPSTriggerFor30thMinute'+testAppender);
        cronStringJobNameMap.put(sNPSCron45,'NPSTriggerFor45thMinute'+testAppender);
        cronStringJobNameMap.put(sNPSCron0_1,'NPSTriggerFor0thMinute_1'+testAppender);
        cronStringJobNameMap.put(sNPSCron15_1,'NPSTriggerFor15thMinute_1'+testAppender);
        cronStringJobNameMap.put(sNPSCron30_1,'NPSTriggerFor30thMinute_1'+testAppender);
        cronStringJobNameMap.put(sNPSCron45_1,'NPSTriggerFor45thMinute_1'+testAppender);*/
        //ends
      /*       
        jobNameList.add('SAPPOandGRJobFor55thMinute');            
        nameExpressionMap.put('SAPPOandGRJobFor55thMinute',sCron55);
        cronStringJobNameMap.put(sCron55,'SAPPOandGRJobFor55thMinute'); 
     */
    }
    
    /**
    This  method is called from VF which will in turn schedule an Apex job
    to populate orders ready to be dispatched to EDI.    
    */
    public void scheduleOrdersManually()
    {
        System.debug('STEP 1 :Inside method from VF');
        
        //SETTING THE VALUE SO THAT JOBS INFO BLOCK SHOULD RENDERED WHEN USER CLICKS BUTTON.
        sRenderJobInfoBlock = 'true';
        
        System.debug('### STEP 2 :Cron expression list: '+cronExpressionList );
        
        //GETTING INFORMATION ABOUT SCHEDULED JOBS.
        cronTriggerList = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger where CronExpression in : cronExpressionList 
                          order by CronExpression];
        
        //IDENTIFYING EXISTING SCHEDULED JOBS.       
        for(integer i = 0; i < cronExpressionList.size(); i++ )
        {
            for(CronTrigger ct : cronTriggerList )
            {
                if(cronExpressionList[i].equals(ct.CronExpression))
                {
                    //POPULATING EXISTING JOBS LIST.
                    existingScheduledJobList.add(cronStringJobNameMap.get(ct.CronExpression));                   
                }
            } 
        }
        
        System.debug('### STEP 3 : existingScheduledJobList: '+existingScheduledJobList );
        
        //IDENTIFYING JOBS WHICH NEEDS TO BE SCHEDULED.
        for(integer i = 0; i < jobNameList.size(); i++ )
        {
            integer iFlag = 1;
            for(String existingJob : existingScheduledJobList)
            {
                if(jobNameList[i] == existingJob)
                {
                    iFlag = 2;                    
                }                
            }
           if(iFlag != 2){
                
                //POPULATING LIST OF TO BE SCHEDULED JOBS.
                currentlyScheduledJobList.add(cronStringJobNameMap.get(cronExpressionList[i]));
           }
             
        }        
        System.debug('### STEP 4 : currentlyScheduledJobList: '+currentlyScheduledJobList );
        
        //IF CURRENTLY TO BE SCHEDULED JOB LIST  CONTAINS RECORD,SCHEDULE THAT JOB.
        if(currentlyScheduledJobList != null && currentlyScheduledJobList.size() > 0)
        {
            System.debug('### STEP 5 : ' );
            for(integer i=0; i < currentlyScheduledJobList.size(); i++ )
            {
                String jobName = currentlyScheduledJobList[i];
                String jobExpression = nameExpressionMap.get(currentlyScheduledJobList[i]);
                System.debug('### STEP 6 : jobExpression: '+jobExpression);
                System.debug('### STEP 7 : jobName: '+jobName );
                
                   //Suguna
                   /*if(jobName.startsWith('NPS'))
                   {
                       System.schedule(jobName ,jobExpression , new NPSTriggerNotificationScheduler()); 
                   }*/
                   //else
                   //{
                       System.schedule(jobName ,jobExpression , new ProcessOrderForFaxAndEDI());                
                   //}
                   
                
                System.debug('### STEP 8 : job scheduled' ); 
            }
        }
        
        //DISPLAY A MESSAGE IF THERE ARE NO JOBS AVAILABLE FOR CURRENT SCHEDULING.
        if(currentlyScheduledJobList!=null && currentlyScheduledJobList.size()==0)
        {           
            if(currentlyScheduledJobList.size() == 0){
                currentJobsMessage = 'There are no jobs currently scheduled.';
            }
        }
        
        //DISPLAY A MESSAGE IF THERE ARE NO EXISTING SCHEDULED JOBS.
        if(existingScheduledJobList!=null && existingScheduledJobList.size()==0)
        {
            if(existingScheduledJobList.size() == 0){
                existingJobsMessage = 'There are no jobs already scheduled.';   
            } 
        }      
    }
    
    /**
    RETURNS A VALUE TO DECIDE RENDERING OF INFORMATION BLOCK AND BUTTON. 
    */
    public String getsRenderJobInfoBlock(){
        return sRenderJobInfoBlock;
    }
    
    /**
    RETURNS AN APPROPRIATE MESSAGE IF NO EXISTING JOBS AVAILABLE.
    */
    public String getExistingJobsMessage(){
        return existingJobsMessage;
    }
    
    /**
    RETURNS AN APPROPRIATE MESSAGE IF NO JOBS AVAILABLE FOR SCHEDULING.
    */
    public String getCurrentJobsMessage(){
        return currentJobsMessage;
    }
    
    /**
    RETURNS A LIST OF EXISTING SCHEDULED JOBS.
    */
    public List<String> getExistingJobs(){
            
        return existingScheduledJobList;
    } 
    
    /**
    RETURNS A LIST OF CURRENTLY SCHEDULED JOBS.
    */
    public List<String> getCurrentJobs(){       
        return currentlyScheduledJobList;
    }
    
}