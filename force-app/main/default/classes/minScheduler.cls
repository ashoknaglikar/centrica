global class minScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        
         GeoManager.fetchJobsbyQuery();  
         callTheNextMinuteJob(SC.getTriggerId());
        
    } 
    
    global void callTheNextMinuteJob(id JobID)
    {
        
       
        integer dayD = system.now().day();
        integer mon = system.now().month();
        integer min = system.now().minute() +1;
        integer hr = system.now().hour();
        
        if(min== 60 )
        {
        	min =00;
        	hr = hr+1;
        	if(hr > 23)
        	{
	        	hr = 00;
	        	dayD = system.now().adddays(1).day() ;
	        	mon =  system.now().adddays(1).month();
        	}
        }
        
        
        String day = string.valueOf(dayD);
        String month = string.valueOf(mon);
        String hour = string.valueOf(hr);
        String minute = string.valueOf(min);
        
        String second = string.valueOf(system.now().second());
        
        String strJobName = 'Trimble-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
        
        list<CronTrigger> cList = [SELECT Id, CronJobDetail.Id, NextFireTime, CronJobDetail.Name, CronJobDetail.JobType  FROM CronTrigger
                                  where CronJobDetail.JobType = '7' and CronJobDetail.Name = :strJobName ORDER BY CreatedDate ];
        if(cList.size()==0 && !test.isRunningTest())                     
        System.schedule(strJobName, strSchedule, new minScheduler());
        if(JobID!=null)
        System.abortJob(JobID);
    }
}