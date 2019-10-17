public class AutoScheduleDispatchToSAP {
    //VARIABLE DECLARATION SECTION.
    String sCron00;
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
    
    public AutoScheduleDispatchToSAP()
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
        Integer hr = System.now().hour();
        System.debug('---------IMPORTANT   '+hr);   
        /*if(hr == 20){
            Integer dayToday = (System.now()).Day();
            dayToday+=1;
            sCron00 = '0 00 8-20 '+dayToday+' * MON-SAT *';
       } else
       */
       {   
            sCron00 = '0 00 8-22 ? * MON-SAT *';
           // sCron00 = '0 00 * ? * * *';
        }
        string  testAppender= '';
        if(Lock.isTestRunner)
        testAppender = '_test';
        
        //POPULATING COLLECTIONS.
        cronExpressionList.add(sCron00);
        jobNameList.add('SAPPOandGRJobFor00thMinute'+testAppender);            
        nameExpressionMap.put('SAPPOandGRJobFor00thMinute'+testAppender,sCron00);
        cronStringJobNameMap.put(sCron00,'SAPPOandGRJobFor00thMinute'+testAppender); 
     
    }
    public void scheduleOrdersManually()  {
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
           //if(iFlag != 2){
                
                //POPULATING LIST OF TO BE SCHEDULED JOBS.
                currentlyScheduledJobList.add(cronStringJobNameMap.get(cronExpressionList[i]));
           //}
             
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
                System.schedule(jobName ,jobExpression , new SendPOandItemsForGoodRcpttoSAP());
                
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