global class Housekeeping_Batch implements Database.Batchable<sObject>
{
    
    list<ID> toDelete = new list<ID>();
    global string query = '';
    global HouseKeepingJobName JobName {get; set;}
    
    global Housekeeping_Batch(String sQuery, HouseKeepingJobName sJobName)
    {
       query = sQuery;
       System.debug('query' +query);
       this.JobName = sJobName;  
    }
   global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords)
    {
        if(lstRecords != null && lstRecords.size() > 0)
            Database.delete(lstRecords, false);
    }
    global void finish(Database.BatchableContext BC)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'APPS-SALESFORCE-COGSupport@centrica.com'});
        mail.setReplyTo('APPS-SALESFORCE-COGSupport@centrica.com');
        mail.setSenderDisplayName('SFDC Batch Processing : Housekeeping Batch');
        mail.setSubject('SFDC Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR Housekeeping Batch');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //Check if scheduler needs to be restarted
        if(JobName != null)
        {   
            DateTime dtNow=System.now();
            dtNow=dtNow.addMinutes(5);
            String sDay=String.ValueOf(dtNow.day());
            String sMonth=String.ValueOf(dtNow.month());
            String sYear=String.ValueOf(dtNow.year());    
            String sHour=String.ValueOf(dtNow.hour());
            String sMinute=String.ValueOf(dtNow.minute());
            String sSecond=String.ValueOf(dtNow.second());
            String sInvokeScheduler = '0 ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
            System.debug('sInvokeScheduler' +sInvokeScheduler);
            String taskName = 'Delete Job : ' + JobName+(test.isRunningTest()?'test':'');
            /*if(JobName == HouseKeepingJobName.SFNB7521)
            {
                Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
                scheduleJob.StartBatchDelete = true;
                scheduleJob.JobBatch = JobName;
                System.debug('jobbatch' +JobName);
                //schedule the class
                System.schedule(taskName, sInvokeScheduler, scheduleJob);
            }
            else if(JobName == HouseKeepingJobName.SAHRSF)
            {
                Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
                scheduleJob.StartBatchDelete = true;
                System.debug('----------------------------- scheduleJob.StartBatchDelete = ' + scheduleJob.StartBatchDelete);    
                //schedule the class
                System.schedule(taskName, sInvokeScheduler, scheduleJob);
                //** 
            }
            else if(JobName == HouseKeepingJobName.SASF7525)
            {
                Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
                scheduleJob.StartBatchDelete = true;
                //schedule the class               
               System.schedule(taskName, sInvokeScheduler, scheduleJob);
                //** 
            }
            else if(JobName == HouseKeepingJobName.SFPO7523)
            {
                Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
                scheduleJob.StartBatchDelete = true;
                //schedule the class
                System.schedule(taskName, sInvokeScheduler, scheduleJob);
                //**
            }
            else if(JobName == HouseKeepingJobName.SFPO7524)
            {
                Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
                scheduleJob.StartBatchDelete = true;
                //schedule the class
                System.schedule(taskName, sInvokeScheduler, scheduleJob);
                //**
            }
            else 
            {
                if(JobName == HouseKeepingJobName.TopcallFaxBatch)
                {
                    HouseKeeping_SFPO7524_Scheduler scheduleJob = new HouseKeeping_SFPO7524_Scheduler();
                    scheduleJob.StartBatchDelete = true;
                    //schedule the class
                    System.schedule(taskName, sInvokeScheduler, scheduleJob);
                }
            }
            */
            
            Housekeeping_Scheduler scheduleJob = new Housekeeping_Scheduler();
            scheduleJob.StartBatchDelete = true;
            scheduleJob.JobBatch = JobName;
            System.debug('jobbatch' +JobName);
                //schedule the class
            if(!Test.isRunningTest()){
             System.schedule(taskName, sInvokeScheduler, scheduleJob);
            }else{
              if(JobName == HouseKeepingJobName.SFPO7524){
              taskName = taskName + 'Test';
              }
              system.schedule(taskName, sInvokeScheduler, scheduleJob);
              
            }
            //scheduleJob.JobBatch = null; 
        }
        }
    }