public global with sharing class GroupAvailabilityGeneration {
    /*
        This class mainly used to for generating shift patterns for Group of employee. 
        If number of employees in the group is less then 40 we use future method to generate shift pattern.
        or else we use batch class GroupShiftPatternBatch is used.
        
        ------------------------For 40 and less------------------------
        The main basis of this class lies in the follwoing points:
        
        When we generate weeks for group, shift pattern is same for all the employees so in order to immprove the performance of the code. 
        1) We create one sample Week and a sample list of Diary enty. 
        2) We then just clone the above week and Diary enty to all other employees.
        
        ----------------------For Large Groups--------------------------
        Here in this case when we find the number of employees is more then 40 then we use batch process:
        1) we create as many child work cycles as there employees in the group, which are same as parent cycles.(Each employee will have a individual Workcycle.)
        2) We set the batch status of these child Workcycles to 'Process'.
        3) In night we schedule a batch which then picks these individual Workcycles and generate the Weeks.
        4) If process is sucess then we Stamp 'Complete' on Batch status.
        5) In case of failure we stamp 'Error' and error msg on the respective Workcycles.
        6) after the completion of batch we send the email alerts to rspective creators of parent cycles. 
                        ******************IMPORTANT**************
                        
        Test class for this class is in the RegenrateAvailabilty_Test with name groupShiftPattern method.                   
    */
    public static Map<String, String> maxHourMap = new Map<String, String>();
    public static Map<String, String> UnavHourMap = new Map<String, String>();
    public static Savepoint  sp;
    public static List<Diary_Entry__c> nonPoolDiaryEntries=new List<Diary_Entry__c>();
    public static List<Diary_Entry__c> poolDiaryEntries = new List<Diary_Entry__c>();
    public static String availableEntryType = Utilities.getRecordTypeId('Availability', 'Diary_Entry__c');
    public static String unavailableEntryType = Utilities.getRecordTypeId('Unavailability', 'Diary_Entry__c'); 
    public static List<Diary_Entry__c> entriesToIns = new List<Diary_Entry__c>();
    
    /*
        This is a fufture method where we process create weeks and diary entries for a group as it is very bulk process. 
        As this is a async process we send an email to user and workcycle creator when the process completes.
        
        
    */
    @future(callout = true)
    public static void Start(Id workCycleID, set<Id> employeeId)
    {
        GroupAvailabilityGeneration  gAvGen = new GroupAvailabilityGeneration();
        List<Week__c> weeks = new List<Week__c>();
        Work_Cycle__c workCycle = [Select Name,Employee__c,Employee__r.Pool_Diary__c,Number_of_Weeks__c,Shift_Pattern__c,
        Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,Shift_Pattern__r.Monday_Max_Hours__c,
        Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,Shift_Pattern__r.Tuesday_Max_Hours__c,
        Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,Shift_Pattern__r.Wednesday_Max_Hours__c,
        Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,Shift_Pattern__r.Thursday_Max_Hours__c,
        Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,Shift_Pattern__r.Friday_Max_Hours__c,
        Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,Shift_Pattern__r.Saturday_Max_Hours__c,
        Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,Shift_Pattern__r.Sunday_Max_Hours__c,
        Start_Date__c,Shift_Pattern__r.Pool_Shift_Pattern__c, Shift_Pattern__r.Sun_Unav_End_Time__c,
        Shift_Pattern__r.Sat_Unav_End_Time__c, Shift_Pattern__r.Fri_Unav_End_Time__c, Shift_Pattern__r.Thu_Unav_End_Time__c,
        Shift_Pattern__r.Wed_Unav_End_Time__c, Shift_Pattern__r.Tue_Unav_End_Time__c, Shift_Pattern__r.Mon_Unav_End_Time__c,
        Shift_Pattern__r.Sun_Unav_Start_Time__c, Shift_Pattern__r.Sat_Unav_Start_Time__c, Shift_Pattern__r.Fri_Unav_Start_Time__c,
        Shift_Pattern__r.Thu_Unav_Start_Time__c, Shift_Pattern__r.Wed_Unav_Start_Time__c, Shift_Pattern__r.Tue_Unav_Start_Time__c,
        Shift_Pattern__r.Mon_Unav_Start_Time__c,Shift_Pattern__r.Unavailability_Reason__c, CreatedBy.Email, Group__r.Name from Work_Cycle__c where Id=:workCycleID];
        
        integer numberOfWeeks = (workCycle.Number_of_Weeks__c).intValue();
        try{    
            Week__c weekInstance;
            string status;
            sp = Database.setSavepoint();
            maxHourMap = GroupAvailabilityGeneration.calculateMaxHours(workCycle);
            system.debug('maxHourMap--->'+maxHourMap);
            GenerateAvailability.maxHourMap = maxHourMap;
            if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c)
            UnavHourMap = GenerateAvailability.calculateUnavailaHours(workCycle);
            Double totalHours = GenerateAvailability.populateMaxHoursOnWeek(maxHourMap);
            weekInstance = gAvGen.createSampleWeek(workCycle,maxHourMap,totalHours);
            for(Id empid: employeeId)
            {
                 Date startDateNextOfWeek = workCycle.Start_Date__c;
                 
                 for(Integer i=0;i<numberOfWeeks;i++){
                    Week__c nwWeek = weekInstance.clone(false,true);
                    nwWeek.Employee__c = empid;
                    nwWeek.Week_Commencing__c = startDateNextOfWeek;
                    nwWeek.Merge_Num__c= i;
                    weeks.add(nwWeek);          
                    startDateNextOfWeek = (startDateNextOfWeek.toStartOfWeek()).addDays(7);
                    
                 }
            }     
            Exception e;
            if(weeks.size()>0){
                
                try{                
                       Database.insert(weeks);
                    
                    }catch(Exception excp){
                        
                        gAvGen.sendMail(excp,workCycle);
                        // Revert the database to the original state
                        Database.rollback(sp);
                        //return 'Error in inserting weeks and gaps.';
                        
                    }           
                        
            }
           List<Diary_Entry__c> sampleEntries = new List<Diary_Entry__c>();
           weekInstance.Week_Commencing__c = workCycle.Start_Date__c;
           sampleEntries = gAvGen.createSampleEntries(workCycle, weekInstance);
        
           for(Week__c weekRecord:weeks){ 
                list<Diary_Entry__c> delst = new list<Diary_Entry__c>();
                for(Diary_Entry__c d:sampleEntries)
                {
                    Diary_Entry__c de = d.clone(false,true);
                    de.Week__c = weekRecord.Id;
                    integer sd = (weekRecord.Merge_Num__c *7).intValue();
                    //PRB00026426 fix starts
                 //   de.Start__c = d.Start__c.adddays(sd);
                 //   de.End__c = d.End__c.adddays(sd);
                 de.Start__c = Datetime.newInstance(d.Start__c.Date().addDays(sd),d.Start__c.time());
                 de.End__c = Datetime.newInstance(d.End__c.Date().addDays(sd),d.End__c.time());
                   //PRB00026426 fix ends
                 delst.add(de);
                    
                }
                
                entriesToIns.addall(delst);
            }
            insert entriesToIns;
        
            
             User userMail = [Select Email from User where id =:userinfo.getUserId()];  
             Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
             email1.setSubject('Workcycle: '+workCycle.Name+' is processed.');      
             String[] toAddresses = system.label.Exception_emails_for_batches.split(',');      
             email1.setToAddresses(toAddresses);      
             email1.setPlainTextBody('Workcycle: '+workCycle.Name+' is processed for the Group '+Workcycle.Group__r.Name+'.');      
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
            
        }
        catch(Exception excp)
        {
            gAvGen.sendMail(excp,workCycle);// Revert the database to the original state
            Database.rollback(sp);
            
        }
    }
    
    public string createWorkcycle(Work_Cycle__c workCycle, set<Id> employeeId)
    {   
        list<Work_Cycle__c> workCycleLst = new list<Work_Cycle__c>();
        
        for(id i: employeeId)
        {
            Work_Cycle__c w = new Work_Cycle__c();
            w = workCycle.clone(false,true);
            w.Employee__c = i;
            w.Work_Cycle__c = workCycle.Id;
            w.Group__c = null;
            w.Batch_Status__c = 'Process';
            workCycleLst.add(w);
        }
        insert workCycleLst;
        return null;
    }
    
    public void sendMail(Exception e, Work_Cycle__c workCycle)
    {
        System.debug('An exception occured in Group Availability Generation of Availability:  '+e.getMessage()+' Error in line number : '+e.getLineNumber());         
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
        email1.setSubject('Exception thrown while Group Availability Generation.'+workCycle.Name);      
        String[] toAddresses = new String[] {'APPS-SALESFORCE-COGSupport@centrica.com',workCycle.CreatedBy.Email};    
        email1.setPlainTextBody ('An exception occured in Group Availability Generation of Availability:  '+e.getMessage()+' Error in line number : '+e.getLineNumber());   
        email1.setToAddresses(toAddresses);      
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
    }
    public Week__c createSampleWeek(Work_Cycle__c workCycle, Map<String, String> maxHourMp, Double totalHours)
    {
            
        Week__c weekInstance = new Week__c();
        weekInstance.Shift_Pattern__c = workCycle.Shift_Pattern__c;
        weekInstance.Total_Hours__c = totalHours;
        
        // This part of code checks if shift pattern is pool.
        // If yes then we populate mx hours on week record. (monday till sunday)
            
         if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c){
            
             if((maxHourMap.get('Mon')).length() > 0){
                  weekInstance.Monday_Max_Hours__c = Double.valueOf(maxHourMp.get('Mon'));
               }
             if((maxHourMap.get('Tue')).length() > 0){
                  weekInstance.Tuesday_Max_Hours__c = Double.valueOf(maxHourMp.get('Tue'));
               }
             if((maxHourMap.get('Wed')).length() > 0){
                  weekInstance.Wednesday_Max_Hours__c = Double.valueOf(maxHourMp.get('Wed'));
               }
             if((maxHourMap.get('Thu')).length() > 0){
                  weekInstance.Thursday_Max_Hours__c = Double.valueOf(maxHourMp.get('Thu'));
              }
             if((maxHourMap.get('Fri')).length() > 0){
                 weekInstance.Friday_Max_Hours__c = Double.valueOf(maxHourMp.get('Fri'));
             }
             if((maxHourMap.get('Sat')).length() > 0){
                 weekInstance.Saturday_Max_Hours__c = Double.valueOf(maxHourMp.get('Sat'));
            }
             if((maxHourMap.get('Sun')).length() > 0){
                weekInstance.Sunday_Max_Hours__c = Double.valueOf(maxHourMp.get('Sun'));
            }   
                                          
        }
        system.debug('weekInstance--->'+weekInstance);
        return weekInstance;
    }
    
    public list<Diary_Entry__c> createSampleEntries(Work_Cycle__c workCycle,Week__c weekRecord)
    {
        list<Diary_Entry__c> sampleDE = new list<Diary_Entry__c>();
         if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c){
                    
                  GenerateAvailability.generatePoolDiary(workCycle,weekRecord);
                  sampleDE.addall(GenerateAvailability.poolDiaryEntries);
                  GenerateAvailability.poolDiaryEntries.Clear();  
            } else {
                 
                  GenerateAvailability.generateEntries(workCycle,weekRecord);
                  
                  sampleDE.addall(GenerateAvailability.splitAvailabilty(GenerateAvailability.nonPoolDiaryEntries,workCycle));
                  GenerateAvailability.nonPoolDiaryEntries.clear();
                 
            }
        system.debug('sampleDE---->'+sampleDE);
        return sampleDE;
    }
    
    
    webservice static string removeShiftPattern(Id[]workCycleID)
    {
        RegenrateAvailabilty objRegen = new RegenrateAvailabilty(); 
        Work_Cycle__c workCycle = RegenrateAvailabilty.RetrieveWorkCycle(workCycleID[0]);
        set<id> empIds = new set<id>();
        if(workCycle.Group__c!= null)
        {
            empIds = objRegen.retrieveEmployee(workCycle.Group__c,workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c);
        }else if(workCycle.Employee__c!=null)
        {
            empIds.add(workCycle.Employee__c);
        }
        set<string> empName = new set<string>();
        if(empIds.size()>20)
        {
            GroupAvailabilityGeneration.checkWeeksfuture(workCycleID[0],empIds);
            return('As Group is big. Please wait for mail for results.');
        }
        else
        {
            empName = GroupAvailabilityGeneration.checkWeeks(workCycle,empIds,true);
            string name = '';
            for(string n : empName)
            {
                                    
                name = name + n+ '\n';
                
            }
            if(name != '')
            {
              if(workCycle.Employee__c!= null)
              {
                return('Weeks can not be removed as they have got Jobs or Unavailabilities');
              }else
              {
                return('Weeks were sucessfully deleted but With some Exceptions as following of them have got Jobs or Unavailabilities: '+name);
              }
            }
            else
            return('Weeks were sucessfully Deleted' );
        }
        
        return null;
        
    }
    
    @future(callout = true)
    public static void checkWeeksfuture(id workCycleId,set<Id> empIds){
        
        RegenrateAvailabilty objRegen = new RegenrateAvailabilty(); 
        Work_Cycle__c workCycle = RegenrateAvailabilty.RetrieveWorkCycle(workCycleId);
        set<string> empName = new set<string>();
        empName = GroupAvailabilityGeneration.checkWeeks(workCycle,empIds,true);
        GroupAvailabilityGeneration.sendresultmail(empName,workCycle);
        }
        
    public static set<String> checkWeeks(Work_Cycle__c workCycle,set<Id> empIds, boolean bDelete )
    {
        
         Integer numberOfWeeks = (workCycle.Number_of_Weeks__c).intValue();
         Date workCycleEndDate = workCycle.Start_Date__c.addDays((numberOfWeeks*7)-1);
         Map<id,Week__c> WeekMap = new  Map<id,Week__c> ([Select Id, Name, Week_Commencing__c,Employee__r.Name from Week__c where 
                                           (Week_Commencing__c >= :(workCycle.Start_Date__c) 
                                           and Week_Commencing__c < :workCycleEndDate)
                                           and Employee__c in :empIds]);
        map<id,list<Week__c>> empWeekMap= new map<id,list<Week__c>>();
         for(Week__c w: WeekMap.values())
         {
            list<Week__c> wkLst = new list<Week__c>();
            if(empWeekMap.containsKey(w.Employee__c))
            {
                wkLst = empWeekMap.get(w.Employee__c);
                wkLst.add(w);
            }else
            {
                wkLst.add(w);
            }
            empWeekMap.put(w.Employee__c,wkLst);
            
         }
         set<string> empName = new set<string>();                            
         if(system.label.DeleteDirect == 'Yes')
         {
             delete WeekMap.values();
             return empName;
         }
         list<Diary_Entry__c> deLst = new list<Diary_Entry__c>();
         
         deLst = GroupAvailabilityGeneration.RetrieveEntries(WeekMap.values());
           
         if(deLst.size()>0)
         {
             for(Diary_Entry__c de : deLst)       
             {
                if(WeekMap.containsKey(de.Week__c))
                {
                    empWeekMap.remove(WeekMap.get(de.Week__c).Employee__c);
                    
                    empName.add(de.Employee_Name__c); 
                }
             }
         }
         if(empWeekMap.size()>0 && bDelete)
         {
            list<Week__c> delWeeks = new list<Week__c>();
            for(List<Week__c> wl:empWeekMap.values())
            {
                delWeeks.addall(wl);
            }
            delete delWeeks;
         }
         system.debug('empName--->'+empName);
         return empName;
                              
    }
    
    public static list<Diary_Entry__c> RetrieveEntries(list<Week__c> weeks)
    {
        List<Diary_Entry__c> diaries = [Select d.Id,d.Type__c, d.Sub_Type__c, d.Start__c, d.Record_Type__c,Week__c,
                                     d.Job__c, d.End__c,d.Unavailability_Reason__c,Employee_ID_18__c,Employee_Name__c From Diary_Entry__c
                                      d where d.Week__c in : weeks and((d.Type__c= 'Unavailability' and d.Sub_Type__c!= 'Weekend unavailability')or d.Type__c= 'Job Booking')];
   
        return diaries;  
    }
    public static void sendresultmail(set<string> empName,Work_Cycle__c w){
        string name = '';
        integer i= 1;
        for(string s : empName)
        {
            name= name + ''+i+'. '+s+'\n';
            i= i+1;
        }
        User userMail = [Select Email from User where id =:userinfo.getUserId()];  
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
        email1.setSubject('Removing Shift pattern is complete for Workcycle: '+w.Name);      
        String[] toAddresses = new String[] {w.CreatedBy.Email,userMail.Email};  
        if(name == '')  
        email1.setPlainTextBody ('Weeks were sucessfully deleted.');   
        else
        email1.setPlainTextBody ('Weeks were sucessfully deleted but with some exceptions.\n Following Employees have got Job booking or Unavailabilities in their Diaries.\n'+name+'\n\n\n Cheers \n British Gas');   
        email1.setToAddresses(toAddresses);      
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
        
        
    }
    public static Map<String,String> calculateMaxHours(Work_Cycle__c workCycle){
    
              maxHourMap.clear();
                                   
             // Check if start & end times are not empty. 
             // Then, calculate max hours difference & put it in map.
             // If start & end times are empty put empty string in map.
               
          if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c 
             && ((((String)workCycle.Shift_Pattern__r.Monday_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Monday_End_Time__c) != null))){
                                    
                    maxHourMap.put('Mon',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                  (workCycle.Shift_Pattern__r.Monday_Start_Time__c,
                                   workCycle.Shift_Pattern__r.Monday_End_Time__c)));
                                                          
                                     }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                               && String.valueOf(workCycle.Shift_Pattern__r.Monday_Max_Hours__c)!= null){
                                    
                                           maxHourMap.put('Mon',String.valueOf(workCycle.Shift_Pattern__r.Monday_Max_Hours__c));
                                        
                                        }else{
                                    
                                           maxHourMap.put('Mon', '');
                                    
                                         }

          if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
             &&((((String)workCycle.Shift_Pattern__r.Tuesday_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Tuesday_End_Time__c) != null))){
                                    
                   maxHourMap.put('Tue',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                 (workCycle.Shift_Pattern__r.Tuesday_Start_Time__c,
                                  workCycle.Shift_Pattern__r.Tuesday_End_Time__c)));
                                                          
                                      }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                                  && String.valueOf(workCycle.Shift_Pattern__r.Tuesday_Max_Hours__c)!= null){
                                    
                                              maxHourMap.put('Tue',String.valueOf(workCycle.Shift_Pattern__r.Tuesday_Max_Hours__c));
                                        
                                         }else{
                                    
                                              maxHourMap.put('Tue', '');
                                    
                                             }
                                      
        if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
           &&((((String)workCycle.Shift_Pattern__r.Wednesday_Start_Time__c) != null)
           && (((String)workCycle.Shift_Pattern__r.Wednesday_End_Time__c) != null))){
                                    
                                    maxHourMap.put('Wed',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Wednesday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Wednesday_End_Time__c)));
                                                          
                                 }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                           && String.valueOf(workCycle.Shift_Pattern__r.Wednesday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Wed',String.valueOf(workCycle.Shift_Pattern__r.Wednesday_Max_Hours__c));
                                        
                                      }else{
                                    
                                          maxHourMap.put('Wed', '');
                                    
                                       }

      if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
         &&((((String)workCycle.Shift_Pattern__r.Thursday_Start_Time__c) != null)
         && (((String)workCycle.Shift_Pattern__r.Thursday_End_Time__c) != null))){
                                    
                                    maxHourMap.put('Thu',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Thursday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Thursday_End_Time__c)));
                                                          
                                 } else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                             && String.valueOf(workCycle.Shift_Pattern__r.Thursday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Thu',String.valueOf(workCycle.Shift_Pattern__r.Thursday_Max_Hours__c));
                                        
                                      }else{
                                    
                                           maxHourMap.put('Thu', '');
                                    
                                       }
                                
    if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
       && ((((String)workCycle.Shift_Pattern__r.Friday_Start_Time__c) != null)
       && (((String)workCycle.Shift_Pattern__r.Friday_End_Time__c) != null))){
                                    
                                     maxHourMap.put('Fri',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Friday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Friday_End_Time__c)));
                                                          
                                 }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                             && String.valueOf(workCycle.Shift_Pattern__r.Friday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Fri',String.valueOf(workCycle.Shift_Pattern__r.Friday_Max_Hours__c));
                                        
                                      }else{
                                    
                                          maxHourMap.put('Fri', '');
                                    
                                       }

  if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c 
     &&((((String)workCycle.Shift_Pattern__r.Saturday_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Saturday_End_Time__c) != null))){
                                    
                                     maxHourMap.put('Sat',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Saturday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Saturday_End_Time__c)));
                                                          
                                 }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
                                            && String.valueOf(workCycle.Shift_Pattern__r.Saturday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Sat',String.valueOf(workCycle.Shift_Pattern__r.Saturday_Max_Hours__c));
                                        
                                      }else{
                                    
                                           maxHourMap.put('Sat', '');
                                    
                                       }
  if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c
     &&((((String)workCycle.Shift_Pattern__r.Sunday_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Sunday_End_Time__c) != null))){
                                    
                                      maxHourMap.put('Sun',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Sunday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Sunday_End_Time__c)));
                                                          
                                   }else if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c 
                                                && String.valueOf(workCycle.Shift_Pattern__r.Sunday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Sun',String.valueOf(workCycle.Shift_Pattern__r.Sunday_Max_Hours__c));
                                        
                                      }else{
                                    
                                            maxHourMap.put('Sun', '');
                                    
                                       }

             if((maxHourMap.get('Mon').indexOf('-') ==  0) || (maxHourMap.get('Tue').indexOf('-') ==  0) ||
                (maxHourMap.get('Wed').indexOf('-') ==  0) || (maxHourMap.get('Thu').indexOf('-') ==  0) ||
                (maxHourMap.get('Fri').indexOf('-') ==  0) || (maxHourMap.get('Sat').indexOf('-') ==  0) ||
                (maxHourMap.get('Sun').indexOf('-') ==  0)){
                    maxHourMap.clear();
                    maxHourMap.put('validationErrorNegative', 'Shift pattern is invalid. Please modify the corresponding shift pattern.');
             }
             system.debug('maxHourMap--->'+maxHourMap);
             return maxHourMap;
             
    }
        
    

}