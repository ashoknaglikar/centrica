public class diaryEntryTriggerHelper {
    
    /*
        Author: Ashok Kumar nagaleekar
        Date: 19/07/2016
        Description: This class holds all the method to create the workday Records on week record. These records will be used to build engineer work day reports. 
        These records will be updated or created everytime a Diary entry record is created or updated. 
        
    */
    
    public static void processDiaryEntry(map<string, list<Diary_Entry__c>> weekIdDiaryEntryMap)
    {
        lock.workday = true;
        Map<Id, Week__c> allWeekDEMap = new map<Id, Week__c> ([Select Id, Name, Sunday_End_Time__c, Saturday_End_Time__c, Friday_End_Time__c, 
                                                            Thursday_End_Time__c, Wednesday_End_Time__c, Tuesday_End_Time__c, 
                                                            Monday_End_Time__c, Sunday_Start_Time__c, Saturday_Start_Time__c, 
                                                            Friday_Start_Time__c, Thursday_Start_Time__c, Wednesday_Start_Time__c, 
                                                            Tuesday_Start_Time__c, Monday_Start_Time__c, Week_Commencing__c,Employee__r.Pool_Diary__c,
                                                            Employee__c, Employee__r.Name, Monday_Unavailable_Hours__c,Tuesday_Unavailable_Hours__c,
                                                            Wednesday_Unavailable_Hours__c,Thursday_Unavailable_Hours__c,Friday_Unavailable_Hours__c,
                                                            Saturday_Unavailable_Hours__c,Sunday_Unavailable_Hours__c,Employee__r.Own_Labour__c, 
                                                            (Select Employee_Name__c, Type__c, Sub_Type__c, Start__c, Hours__c, End__c, Job__c, Job__r.Name, Overbooked_Hours__c,
                                                            week__c,Record_Type__c from Diary_Entries__r order by Start__c ), 
                                                            (select id, Date__c, Day__c ,   ExternalId__c from Workday_Reports__r) from Week__c where Id = : weekIdDiaryEntryMap.keyset()]);
        
        list<diaryEntryTriggerHelper.workdayInnerClass> workDayObjList = new list<diaryEntryTriggerHelper.workdayInnerClass>();
        
        diaryEntryTriggerHelper objHelper = new diaryEntryTriggerHelper();
        
        for(Week__c w: allWeekDEMap.values())
        {
            if(w.Employee__r.Pool_Diary__c!=true )
            workDayObjList.addall(objHelper.createWorkDayDetails(w));
        }
        if(workDayObjList.size()>0)
        objHelper.processDMLOperations(workDayObjList);
    }
    
    
    
    public list<diaryEntryTriggerHelper.workdayInnerClass> createWorkDayDetails(Week__c week)
    {
        map<date, diaryEntryTriggerHelper.workdayInnerClass> wordayDateMap = new map<date, diaryEntryTriggerHelper.workdayInnerClass>();
        list<diaryEntryTriggerHelper.workdayInnerClass> finalList = new list<diaryEntryTriggerHelper.workdayInnerClass>();
        for(Diary_Entry__c d: week.Diary_Entries__r)
        {
            list<diaryEntryTriggerHelper.workdayInnerClass> temp = breakDiaryEntriesInToDays(d, week);
            finalList.addall(temp);
        }
        
        for(diaryEntryTriggerHelper.workdayInnerClass  objWorkDay : finalList)
        {
            //system.debug('Debugging One by One -->'+objWorkDay);
            if(wordayDateMap.containskey(objWorkDay.date_x))
            {
                diaryEntryTriggerHelper.workdayInnerClass tempObj = wordayDateMap.get(objWorkDay.date_x);
                tempObj.nwdHours += objWorkDay.nwdHours;
                tempObj.unavailableHours += objWorkDay.unavailableHours;
                tempObj.travelTime += objWorkDay.travelTime;
                tempObj.avaialableHours += objWorkDay.avaialableHours;
                
               
                for(string j : objWorkDay.jobClassMap.keyset())
                {
                    jobInnerClass jobObj;
                    if(tempObj.jobClassMap.containsKey(j))
                    {
                        jobObj= tempObj.jobClassMap.get(j);
                        jobObj.hours += objWorkDay.jobClassMap.get(j).hours;
                        jobObj.overbooking += objWorkDay.jobClassMap.get(j).overbooking;
                        tempobj.jobClassMap.put(j,jobObj); 
                        
                    }else
                    {
                        jobObj= objWorkDay.jobClassMap.get(j);
                        
                        tempobj.jobClassMap.put(j,jobObj); 
                        
                    }
                     
                    
                }
                
                wordayDateMap.put(objWorkDay.date_x, tempObj);
                
            }else
            {
                wordayDateMap.put(objWorkDay.date_x, objWorkDay);
            }
            //system.debug('Building Map -->'+wordayDateMap);
            
        }
        //system.debug('createWorkDayDetails--->'+wordayDateMap.values());
        return wordayDateMap.values();
    }
    map<string, integer> jopPriority = new map<string, integer>();
    public list<diaryEntryTriggerHelper.workdayInnerClass> breakDiaryEntriesInToDays(Diary_Entry__c de, Week__c wk)
    {
       
        list<diaryEntryTriggerHelper.workdayInnerClass> finalList = new list<diaryEntryTriggerHelper.workdayInnerClass>();
        
        try{              
        integer numberofDays = de.Start__c.date().daysBetween(de.End__c.date());
        
        /*if(numberofDays == 0 && de.End__c > de.Start__c)
        {
            //week Last day scenrio: 
            numberofDays = 1;
        }*/
        
        double OverbookedHours = (de.Overbooked_Hours__c!=null)?de.Overbooked_Hours__c:0.00;
        double Hours = (de.Hours__c!=null)?de.Hours__c:0.00;
        
        for(integer i = 0; i<= numberofDays; i++)
        {
            
            Time standardTime = Time.newInstance(0, 0, 0, 0);

            DateTime stdStart = DateTime.newInstance(de.Start__c.adddays(i).date(), standardTime);
            if(de.Start__c >=stdStart)
            {
                stdStart = de.Start__c;
            }
            
            DateTime stdEnd =  DateTime.newInstance(de.Start__c.adddays(i+1).date(), standardTime);
            if(stdEnd>= de.End__c)
            {
                stdEnd = de.End__c;
            }
            system.debug('hours4Day---->'+stdStart+' '+stdEnd);
            double hours4Day = DateTimeHelper.calculateHours(stdStart, stdEnd, wk);
            
            
            if(hours4Day>0)
            {
                //system.debug('before -->'+de.Week__c +' '+de.Start__c.adddays(i));
                diaryEntryTriggerHelper.workdayInnerClass  wokdayObj = new diaryEntryTriggerHelper.workdayInnerClass(de.Week__c, de.Start__c.adddays(i));
                //system.debug('after -->'+wokdayObj);
                if(de.Record_Type__c == 'Unavailability')
                {
                    if(!isWeekend(stdStart.date()) && (de.Sub_Type__c == 'NWD - Working' || de.Sub_Type__c == 'NWD - Non Working'))
                    {
                        wokdayObj.nwdHours = hours4Day;
                    }else if(de.Sub_Type__c != 'NWD - Working' && de.Sub_Type__c != 'NWD - Non Working')
                    {
                        wokdayObj.unavailableHours = hours4Day;
                    }
                    
                }else if(de.Sub_Type__c == 'Travel Time')
                {
                    wokdayObj.travelTime = hours4Day+OverbookedHours;//de.Overbooked_Hours__c;
                }
                else if(de.Record_Type__c == 'Job Booking')
                {
                    decimal overBookingForthatDay = OverbookedHours*hours4Day/Hours; //de.Overbooked_Hours__c*hours4Day/de.Hours__c;
                    diaryEntryTriggerHelper.jobInnerClass jobObj = new diaryEntryTriggerHelper.jobInnerClass( stdStart, de.Job__r.Name,wk.Name);
                    if(wokdayObj.jobClassMap.ContainsKey(de.Job__c))
                    {
                        jobObj = wokdayObj.jobClassMap.get(de.Job__c);
                        jobObj.hours += hours4Day;
                        jobObj.overbooking += overBookingForthatDay;
                    }else
                    {
                        jobObj.hours = hours4Day;
                        jobObj.overbooking = overBookingForthatDay;
                    }
                    system.debug('Job -->'+jobObj);
                    wokdayObj.jobClassMap.put(de.Job__c, jobObj);
                    
                    if(!jopPriority.containsKey(de.Job__r.Name))
                    jopPriority.put(de.Job__r.Name, jopPriority.size()+1);
                   
                }else if(de.Record_Type__c == 'Availability')
                {
                    wokdayObj.avaialableHours = hours4Day;
                    
                }
                
                finalList.add(wokdayObj);
            }
           
            
           
        }
        }catch(Exception e){
            system.debug(LoggingLevel.INFO,'------>'+e.getMessage()+'---'+e.getlinenumber());
        }
        
        //system.debug('breakDiaryEntriesInToDays--->'+finalList);
        return  finalList;
        
    }
    
    public void processDMLOperations(list<workdayInnerClass> workDayObjList)
    {
        //system.debug('processDMLOperations--->'+workDayObjList);
        list<WorkdayReport__c> upsertWorkDayList = new list<WorkdayReport__c>();
        
        list<Job_Hour__c> upsertJobHourList = new list<Job_Hour__c>();
        
        Map<string,List<Job_Hour__c>> m = new Map<String,List<Job_Hour__c>>();
         
        list<string> jobHourExternalIdList = new list<string>();
        
        for(workdayInnerClass wokObj : workDayObjList)
        {
            list<Job_Hour__c> JHList = new list<Job_Hour__c>();
            WorkdayReport__c workDayInst = new WorkdayReport__c (
            Week__c = wokObj.weekId,
            ExternalId__c = wokObj.externalId,
            NWD__c = wokObj.nwdHours,
            Total_Travel_Time__c = wokObj.travelTime,
            Unavailability_Hours__c =  wokObj.unavailableHours,
            Available_hours__c =  wokObj.avaialableHours,
            Date__c = wokObj.date_x,
            Day__c = wokObj.day);
            
            upsertWorkDayList.add(workDayInst);
            
            for(jobInnerClass  jobObj : wokObj.jobClassMap.values())
            {   
            
                decimal jphours = (Math.Abs(jobObj.hours - Math.round(jobObj.hours)) <= Decimal.valueof(system.label.Job_Premier_Hour_window))? Math.round(jobObj.hours):jobObj.hours;
                Job_Hour__c jobHourObj = new Job_Hour__c(
                ExternalId__c = jobObj.externalId,
                Workday_Report__r = workDayInst,
                Overbooked_Hours__c = jobObj.overbooking,
                Premier_Hours__c = jphours,
                Job_Number__c = jobObj.jobNumber
                );
                if(jopPriority.containsKey(jobObj.jobNumber))
                jobHourObj.Order__c = jopPriority.get(jobObj.jobNumber);
                JHList.add(jobHourObj);
                jobHourExternalIdList.add(jobObj.externalId);
            }
            
           m.put(wokObj.externalId,JHList); 
        }
        
        if(upsertWorkDayList.size()>0)
        {
            Schema.SObjectField externalField = WorkdayReport__c.Fields.ExternalId__c;
            Database.UpsertResult [] cr = Database.upsert(upsertWorkDayList , externalField, false);
            
        }
       //Added By Ashok G to update the Workday_Report Id.
       for(WorkdayReport__c wr: upsertWorkDayList){
                  if(m.containskey(wr.ExternalId__c)){
                     for(Job_Hour__c jh: m.get(wr.ExternalId__c)){
                        jh.Workday_Report__c= wr.Id;
                        upsertJobHourList.add(jh);
                     }
                  }
        }
        //Change End
        if(upsertJobHourList.size()>0)
        {
            //system.debug('Job List-->'+upsertJobHourList);
            Schema.SObjectField externalField = Job_Hour__c.Fields.ExternalId__c;
            Database.UpsertResult [] cr = Database.upsert(upsertJobHourList , externalField, false);
            //system.debug('Result---->'+cr);
            
            
            
        }
        
        /*
            Delete all the Job hours which are not valid any more. 
            like Jobs suspended /cancelled/ replanned to a different date / engineers hours diary entries will needs to be removed. 
        */
        List<Job_Hour__c> deleteList = [select id from Job_Hour__c where Workday_Report__r.ExternalId__c in : m.keyset() and ExternalId__c NOT in : jobHourExternalIdList];
        if(deleteList.size()>0)
        delete deleteList;
        
    }
    
    public class workdayInnerClass
    {
        public string day;
        public date date_x;
        public string externalId ;
        public decimal nwdHours = 0;
        public decimal unavailableHours = 0;
        public decimal travelTime = 0;
        public decimal avaialableHours = 0;
        public Map<Id, jobInnerClass> jobClassMap;
        public string weekId;
        
        public workdayInnerClass(string weekId, dateTime date_x)
        {
            this.weekId = weekId;
            this.date_x =date_x.date();
            diaryEntryTriggerHelper obj = new diaryEntryTriggerHelper();
            externalId = weekId+string.valueof(date_x.date());
            day = obj.findDay(date_x.date());
            jobClassMap = new Map<id, jobInnerClass>();
        }
        
    }
    
    public class jobInnerClass
    {
        public string externalId;
        public decimal hours = 0;
        public decimal overbooking = 0;
        public string jobNumber;
        
        public jobInnerClass( dateTime date_x, string jobNumber, String weekId)
        {
            this.externalId = weekId+string.valueof(date_x.date())+jobNumber;
            this.jobNumber = jobNumber;
        }
        
    }
    
    public string findDay(date date_x)
    {
        map<string, string> fullDay = new  map<string, string> {'Sun'=> 'Sunday', 'Mon'=> 'Monday','Tue'=> 'Tuesday','Wed'=> 'Wednesday','Thu'=> 'Thursday','Fri'=> 'Friday','Sat'=> 'Saturday'};
        DateTime myDateTime = (DateTime) date_x;
        String dayOfWeek = myDateTime.format('E');
        return fullDay.get(dayOfWeek);
    }
    
    public boolean isWeekend(Date date_x)
    {
        DateTime myDateTime = (DateTime) date_x;
        String dayOfWeek = myDateTime.format('E');
        return (dayOfWeek == 'Sat' || dayOfWeek == 'Sun' ? true: false);
    }

}