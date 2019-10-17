/* DiaryEntryCollection

    DiaryEntryCollections hold information about an Employee's availability.
    
    Diary Entry sObjects hold information about periods of time in an Employee's diary; this may not 
    always be availability which may mean availability needs to be "broken up" or "joined together". 
    For example:
    
    - a person may already be booked on the job being searched for, therefore their Job Bookings   
        should be treatedas availability. There could be several of these and/or they could be adjacent  
        to availability. In this case, this should all be treated as one big block of availability
    - a person may be booked on the job being searched for, so these should be treated as availability;
        however, overlapping unavailability has been added since the job was booked, so some parts of 
        it (or possibly all of it) shouldn't be treated as availability.
    
    There is also the issue of offsetting a start time on a Diary Entry. For example, take a Diary Entry 
    runs from a Monday to Friday, we run the search on the Tuesday of the same week and we want to plan 
    a job with a start date of now or greater. If we only looked at the Diary Entry's start date, we'd 
    plan a job starting from the Monday.  
    
    The purpose of the DiaryEntryCollection class is to overcome these issues, and are used to represent
    several Diary Entries as one contiguous piece of time. An important piece of DiaryEntryCollections are 
    the associated DiaryEntryInfo objects - these hold information about the Diary Entry objects that make 
    up the collection. 
*/

public with sharing class DiaryEntryCollection {

    /* DiaryEntryInfo
        An inner class that holds information about the Diary Entries that make up a DiaryEntryCollection. 
        This class holds the Diary Entry belonging to this DEI, the start and end time and the hours in this
        DEI. Note that the start of the DEI may not match the start of the Diary Entry! */
        public static Boolean replan_skiprule = false;
    public class DiaryEntryInfo {
        public Diary_Entry__c entry = null;
        public Double hours = null;
        public DateTime startDT = null;
        public DateTime finishDT = null;
        public Double FrontGap = 0.0;
        public Double backGap = 0.0;
        public string MstartTime = null; //Hold the morning start time of the week
        public string MidStartTime = null;//Hold the midday start time of the week
        /* DiaryEntryInfo(Diary_Entry__c de, DateTime stDT, Datetime endDT)
            Constructor. Used to create DEIs for non-pool employees. Note that hours is set 
            outside this constructor. */
        public DiaryEntryInfo(Diary_Entry__c de, DateTime stDT, Datetime endDT) {
            entry = de;
            startDT = stDT;
            //if(SearchBlackBox.JobInfo.S_P_Hours__c>=12 &&)
            finishDT = endDT;
            MstartTime = de.Week__r.Morning_Start_Time__c;
            MidStartTime = de.Week__r.Mid_day_Start_Time__c;
            this.FrontGap = 0.0;
            this.BackGap = 0.0;
            
        }
        
        /* DiaryEntryInfo(Diary_Entry__c de, DateTime stDT, Datetime endDT, Double h)
            Constructor. Used to create DEIs for pool employees - the main difference is that hours is
            calculated before the constructor is called and is passed in as an argument. */
        public DiaryEntryInfo(Diary_Entry__c de, DateTime stDT, Datetime endDT, Double h) {
            
            //entry = [select id,Week__r.Monday_Start_Time__c, Week__r.Monday_End_Time__c from Diary_Entry__c where id=:de.id];
            entry = de;
            startDT = stDT;
            finishDT = endDT;
            hours = h;
            MstartTime = de.Week__r.Morning_Start_Time__c;
            MidStartTime = de.Week__r.Mid_day_Start_Time__c;
            FrontGap  = 0.0;
            BackGap = 0.0;
        }
        
        /* print()
            Prints information about this DEI. */
        public void print() {
            System.debug(LoggingLevel.INFO, 'dei.print(): ' + this);
        }
    }

    public List<DiaryEntryInfo> entryInfoObjects = new List<DiaryEntryInfo>(); // DiaryEntryInfo objects that make up this DEC
    public Map<ID,String> weekMap = new Map<ID,String>(); 
    public Double numberOfHours = 0.0; // Number of available hours in this collection 
    public Double TotFrontGap = 0.0;
    //public Double TotBackGap = 0.0;
    // Start and finish times of this DEC
    public DateTime startDT = null;
    public DateTime finishDT = null;
    // Shift pattern for this DEC. A DEC should only represent availability in one week 
    public List<List<String>> shifts = new List<List<String>>();
    public Boolean isPool = null;
    public boolean skip_8_12_Rule;
    
    /* DiaryEntryCollection(List<DiaryEntryInfo> entries, EmployeeInformation ei)
        Constructor. Creates a DiaryEntryCollection for the supplied employee out of the 
        DiaryEntryInfo objects provided - these should all be for the same calendar week and
        in chronological order. */
    public DiaryEntryCollection(List<DiaryEntryInfo> entries, EmployeeInformation ei) {
        
          System.debug(LoggingLevel.INFO, 'user debug EmployeeInformation:' + ei);
          system.debug(LoggingLevel.INFO,'-------->bus-->'+ei.availability.business);
          
          isPool = ei.isPool;
          String skipRule = string.Valueof(system.label.Skip_8_12_Rule); //Global switch
          //boolean skip_8_12_Rule = false;
          skip_8_12_Rule = false;
          Diary_Entry__c delist;
          if(skipRule == 'yes')
          skip_8_12_Rule = TRUE;
          else
          skip_8_12_Rule = FALSE;
          
        System.debug(LoggingLevel.INFO, 'entries.size(): ' + entries.size()+' '+skipRule);
        System.debug(LoggingLevel.INFO, 'Job-INFO: ' + SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c);
        //List<Diary_Entry__c> ExistingEntries = SearchBlackBox.JobInfo.Job.Diary_Entries__r;
        system.debug(LoggingLevel.INFO,'=========>91'+SearchBlackBox.JobInfo.ExistngEntries);
        set<Id> weekent = new set<Id>();
        Map<ID,ID> exst = SearchBlackBox.JobInfo.ExistngEntries;
        Map<ID,list<Datetime>> wstrtEndMap = SearchBlackBox.JobInfo.wstartEndMap; 
        
        if(entries.size() >1){
        for(DiaryEntryInfo ent : entries){
        if(delist == null)
        delist = ent.entry;
        else{
        if(ent.entry.start__c <= delist.start__c)
        delist = ent.entry;
        }}}
        
        //Skip rule for business best if same engineer in the job entries exist.
        if(ei.availability.business!=null){
           for(DiaryEntryCollection Dcs: ei.availability.business){
              for(DiaryEntryInfo Deei: Dcs.entryInfoObjects ){
                 if(Deei.entry.Week__c!=null)
                 weekent.add(Deei.entry.week__c);
              }
           }
        }
        if(!entries.isEmpty()) {
            // Set the shift information
            Diary_Entry__c entry = entries[0].entry;
            
            shifts = new List<List<String>> {
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Monday_Start_Time__c,
                                            entry.Week__r.Shift_Pattern__r.Monday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Tuesday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Wednesday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Thursday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Friday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Friday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Saturday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Sunday_End_Time__c}};
            
             
            // Loop over each DiaryEntryInfo object passed in. 
            for(DiaryEntryInfo dei : entries) {
                
                dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,dei.StartDT,shifts);
                /*DateTime FinalEndTime = Datetime.newInstance(dei.finishDT.date(),DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.finishDT.format('E'))][1])); 
                if(FinalEndTime >= dei.finishDT){
                dei.BackGap = 0.0;
                }else{
                dei.BackGap = DateTimeHelper.calculateHours(dei.finishDT,FinalEndTime,shifts); 
                } */
               
                if(entries.size() >1){
                if(delist != null && delist == dei.entry)
                replan_skiprule = true;
                else
                replan_skiprule = false;
                }
                    System.debug(LoggingLevel.INFO, 'diary entries DEI' + dei );           
                    Datetime deiStart = null;
                    Boolean alreadyexst = False;
                    //change by ASHOK G
                    if(dei.MstartTime==null)
                    dei.MstartTime = '08:00';
                    
                    if(dei.MidStartTime == null)
                    dei.MidStartTime = '12:00';
                    
                    //system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=>'+SearchBlackBox.JobInfo.job.Installation_Date__c+' '+dei.startDT.Date()+' '+SearchBlackBox.JobInfo.Job.Status__c+' '+SearchBlackBox.JobInfo.Job.Sub_Status__c+' '+SearchBlackBox.JobInfo.Job.S_P_Hours__c+' '+cls_IsRun.isPlanner);
                   //Change To skip Rule for Replan Job -- what If Business best holds the Same Engineer? // && SearchBlackBox.JobInfo.Job.Status__c == 'Pending' && SearchBlackBox.JobInfo.Job.Sub_Status__c=='ASP Added'
                   if(ei.skipRule || SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c)
                   {
                       skip_8_12_Rule = true;
                       //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c = true;
                   }
                   if(exst!=null && dei.entry.week__c!=null && exst.containsKey(dei.entry.week__c) && !skip_8_12_Rule /*&& !SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c*/ && SearchBlackBox.JobInfo.job.Installation_Date__c!=null && (dei.StartDt.Date()>=wstrtEndMap.get(dei.entry.week__c)[0].Date() && dei.StartDt.Date()<=wstrtEndMap.get(dei.entry.week__c)[1].Date())){
                      if(exst.get(dei.Entry.week__c) == ei.EmployeeId){ //
                      // PRB00029871 - to check if the existing entries obey 8/12 rule
                      if(replan_skiprule!=null && replan_skiprule == true)
                       {
                        system.debug(LoggingLevel.INFO,'entered replan_skiprule '+dei);
                        alreadyexst = TRUE;
                        skip_8_12_Rule = FALSE;
                        //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c = FALSE;
                       }
                       else{
                        alreadyexst = TRUE;
                        skip_8_12_Rule = TRUE;
                        //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c = TRUE;
                        }
                      }
                    }
                    
                    if(weekent!=null && weekent.contains(dei.entry.Week__c) && dei.entry.week__c!=null && !skip_8_12_Rule /*&& !SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c*/){
                       alreadyexst = FALSE;
                       skip_8_12_Rule = FALSE;
                       //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c = FALSE;
                    }
                    
                    
                    
                    system.debug(LoggingLevel.INFO,'startTIME: '+ dei.startDT+' '+alreadyexst+' '+SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c);
                    //change By Ashok G --> to only allow 8 hour jobs to only be planned
                    //for 8am starts only to help with planning efficiency
                    /*if(cls_IsRun.isPlanner == 'N' && SearchBlackBox.jobInfo.Job.S_P_Hours__c == 8.00 && String.valueof(system.label.DEC_switch_8hr) == 'On'){
                         system.debug(LoggingLevel.INFO,'Inside s_P_Hours Change');
                         if(dei.StartDT.time() > DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][1])){
                            // If the startDT of this DEI is after the day's shift end, wind it forward to the next day.
                            system.debug(LoggingLevel.INFO,'Line 124:'+dei.StartDT);
                            deiStart = Datetime.newInstance(dei.StartDT.date().addDays(1), 
                                                            DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))+1][0]));
                            //system.debug(LoggingLevel.INFO,'Line 126:'+dei.StartDT);
                            dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);
                        } else if (dei.StartDT.time() < DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][0])) {
                            // If the startDT of this DEI is before the day's shift start, wind it forward to the start time.
                            system.debug(LoggingLevel.INFO,'Line 130:'+dei.StartDT);
                            deiStart = Datetime.newInstance(dei.StartDT.date(), 
                                                            DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][0]));
                            
                            //system.debug(LoggingLevel.INFO,'Line 132:'+dei.StartDT);
                            dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);
                        }  else if(dei.StartDT.time() > DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][0])){
                           // If the startDT of this DEI is after the days's Shift start, wind it forward to the next day start time.    
                           system.debug(LoggingLevel.INFO,'asdfasdfasdfasdfasdfasdf'+dei.StartDT);
                           deiStart = Datetime.newInstance(dei.StartDT.date().addDays(1), 
                                                            DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))+1][0]));
                             
                           dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);//Change By AshoK G
                        }else{
                            deiStart = dei.startDT;
                            system.debug(LoggingLevel.INFO,'Else Part --->'+dei.startDt);
                        }
                           
                       
                    }else*/{
                       
                       
                       if(dei.StartDT.time() > DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][1])){
                            // If the startDT of this DEI is after the day's shift end, wind it forward to the next day.
                           // system.debug(LoggingLevel.INFO,'Line 124:'+dei.StartDT);
                            deiStart = Datetime.newInstance(dei.StartDT.date().addDays(1), 
                                                            DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))+1][0]));
                            
                            //system.debug(LoggingLevel.INFO,'Line 126:'+dei.StartDT);
                        } else if (dei.StartDT.time() < DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][0])) {
                            // If the startDT of this DEI is before the day's shift start, wind it forward to the start time.
                            //system.debug(LoggingLevel.INFO,'Line 130:'+dei.StartDT);
                            deiStart = Datetime.newInstance(dei.StartDT.date(), 
                                                            DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(dei.StartDT.format('E'))][0]));
                            
                            //system.debug(LoggingLevel.INFO,'Line 132:'+dei.StartDT);
                            
                        }// 8/12 RULE CHANGE -- ASHOK G
                        else if(dei.StartDT.time() > DateTimeHelper.stringToTime(dei.MidstartTime) && !skip_8_12_Rule /*&& !SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c*/){ //skip rule @Employee Level.
                            //If the StartDt of this DEI is after mid day shift start, wind it forward to the next day morning Start time.
                            //system.debug(LoggingLevel.INFO,'I am Inside '+dei.startDt);
                            
                            string existingday = dei.StartDT.format('E');
                            string newday =  Datetime.newInstance(dei.StartDT.date().adddays(1),
                                                                DateTimeHelper.stringToTime(dei.MstartTime)).format('E');
                            System.debug(Logginglevel.info,'existingday '+existingday);
                            System.debug(Logginglevel.info,'newday '+newday);
                            
                            //PRB00033228                              
                            if(!(existingday == 'Sun' && newday == 'Mon')){                              
                            deiStart = Datetime.newInstance(dei.StartDT.date().adddays(1),
                                                                DateTimeHelper.stringToTime(dei.MstartTime));
                            dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);//Change By AshoK G
                            }
                            else{
                            System.debug('Skipping the availability as the new start date falls on next week');
                            continue;}
                            
                            
                            //system.debug(LoggingLevel.INFO,'After: 133:'+deistart);
                        }  else if(dei.StartDT.time() > DateTimeHelper.stringToTime(dei.MStartTime) && !skip_8_12_Rule /*&& !SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c*/){
                            //If the StartDt of this DEI is after morning shift start, wind it forward to the midday Start time.
                            deiStart = Datetime.newInstance(dei.StartDT.date(),
                                                                DateTimeHelper.stringToTime(dei.MidStartTime));   
                            dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);//Change By AshoK G
                            //system.debug(LoggingLevel.INFO,'After:142:'+deistart);
                          
                        } else if(dei.StartDT.time() < DateTimeHelper.stringToTime(dei.MStartTime) && !skip_8_12_Rule /*&& !SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c*/){
                            //If the StartDt of this DEI is after morning shift start, wind it forward to the midday Start time.
                            deiStart = Datetime.newInstance(dei.StartDT.date(),
                                                                DateTimeHelper.stringToTime(dei.MStartTime)); 
                            dei.FrontGap = DateTimeHelper.calculateHours(dei.entry.Start__c,deiStart,shifts);//Change By AshoK G  
                            //system.debug(LoggingLevel.INFO,'After:142:'+deistart);
                            
                            
                        }
                        else {
                            deiStart = dei.startDT;
                            //system.debug(LoggingLevel.INFO,'Else Part --->'+dei.startDt);
                        }
                     
                    }
                    
                 
                // Check that we've not wound this forward past the DEI's end time, if so, move on to the next one.
                system.debug(LoggingLevel.INFO,'deistart and end '+'deiStart '+deiStart+'dei.finishDT '+dei.finishDT);
                //PRB00029837
                if(deiStart >= dei.finishDT){ 
                system.debug(LoggingLevel.INFO,'deiStart >= dei.finishDT - condition satisfied ');
                    continue;}

                // If startDT has not been set, set it to the deiStart that was set above.  
                if(startDT == null)
                    startDT = deiStart;
                
                // If the employee is not a pool, work out how many hours in the DEI
                // if ei.isPool, hours has been set
                if(!ei.isPool) {
                    dei.hours = workingHoursBetween(deiStart, dei.finishDT);
                    
                    
                    //PRB00031159
                    if(dei.hours != null && dei.entry.Hours__c != null && system.label.dec_switch == 'ON'){
                    Double hours_diff = dei.entry.Hours__c - dei.hours;
                    Datetime fin_date = DateTimeHelper.addHoursToDT(deiStart, dei.entry.Hours__c);
                    if((dei.entry.Hours__c != dei.hours) && (hours_diff == 0.01 || hours_diff == -0.01) && (fin_date == dei.finishDT)){
                    system.debug(LoggingLevel.INFO,'Entered loop :');
                    system.debug(LoggingLevel.INFO,'hours_diff '+hours_diff);
                    dei.hours = dei.entry.Hours__c;
                    }
                    }
                    //PRB00031159 
                }  
                
                // Add to the number of hours in the DEC
                //numberOfHours += dei.hours;
                
                //suguna - PH Jones Chnage- squeeze SP job hours while planning certain types of Jobs to certain types of employees
                numberOfHours += dei.hours +ei.overBookingExpHours;
                if(ei.overBookingExpHours>0.0 && numberOfHours>SearchBlackBox.JobInfo.Job.s_p_hours__c)
                dei.finishDT= DateTimeHelper.addWorkingHoursToDateTime1(dei.startDT,double.valueof(SearchBlackBox.JobInfo.Job.s_p_hours__c-ei.overBookingExpHours),shifts);
                //ends 
                

                entryInfoObjects.add(dei);
                weekmap.put(dei.entry.week__c,dei.MstartTime+'-'+dei.MidstartTime);
                //system.debug(LoggingLevel.INFO,'entryInfoObjects:'+entryInfoObjects);
                if(alreadyexst){
                skip_8_12_Rule = False;
                //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c = FALSE;
                }
                TotFrontGap += dei.FrontGap;

            }
            system.debug(LoggingLevel.INFO,'entryInfoObjects:168'+entryInfoObjects+' '+entryInfoObjects.size());
            // Set the finish time of the DEC
            if(entryInfoObjects.size() != 0)
                finishDT = entryInfoObjects[entryInfoObjects.size()-1].finishDT;
                
                
            
            system.debug(LoggingLevel.INFO,'FinishDt: 168 line :'+finishDT);
            // Add on any gap size tolerance to the number of hours in the DEC.
            if(numberOfHours > 0.0 && !ei.isPool)
                numberOfHours += SearchBlackBox.optsAndParms.gapSizeTolerance;
            
        }
    }

    public static List<DiaryEntryCollection> createDECs(List<Diary_Entry__c> entries, Boolean isBusiness, EmployeeInformation ei) {

        List<Diary_Entry__c> unavailability = new List<Diary_Entry__c>();
        List<Diary_Entry__c> availability = new List<Diary_Entry__c>();
        // Get the earliest DateTime that this DEC should start at.
        Datetime earliestDT = getEarliestDT(isBusiness);

        System.debug(LoggingLevel.INFO, 'earliestDT: ' + earliestDT);        
        // Split diary entries into availability and unavailability
        for(Diary_Entry__c de : entries) {
            System.debug(LoggingLevel.INFO, 'RecType: ' + de.Record_Type__c + ' start: ' + de.Start__c + ' End: ' + de.End__c);
            if(de.Record_Type__c == SearchBlackBox.UNAVAILABILITY_DIARY_ENTRY_TYPE) {
                unavailability.add(de);
                continue;
            } else if(de.Start__c < earliestDT && de.End__c < earliestDT){
                continue;
            }else if(de.Record_Type__c == 'Non Productive Job Booking'){ //PRB00029160
            continue;
            }
            availability.add(de);
        }
        System.debug(LoggingLevel.INFO, 'availability.size(): ' + availability.size());
        // If no availability, return
        if(availability.isEmpty()) {
            return null;
        }
        
        return createDECs(availability, unavailability, isBusiness, ei, getEarliestDT(isBusiness));

    }


    /* createDECs(List<Diary_Entry__c> entries, List<Diary_Entry__c> unavailability, Boolean isBusiness, EmployeeInformation ei)
        Static method to create DiaryEntryCollection for a list of Diary Entries. It processes the Diary Entries
        and creates the relevant DiaryEntryCollections, taking into account unavailability that may overlap
        with candidate Diary Entries.
        
        Diary Entries passed in to the method should occur within the same working week, should be in 
        chronological order, and should be for contiguous periods of time. */
    public static List<DiaryEntryCollection> createDECs(List<Diary_Entry__c> availability, List<Diary_Entry__c> unavailability, 
                                                        Boolean isBusiness, EmployeeInformation ei, DateTime earliestDT) {
                                                            
        System.debug(LoggingLevel.INFO, 'createDECs for: ' + ei.employeeName);
        System.debug(LoggingLevel.INFO, 'createDECs for: ' + unavailability);
        System.debug(LoggingLevel.INFO, 'createDECs for: ' + availability);
        
/*        List<Diary_Entry__c> unavailability = new List<Diary_Entry__c>();
        List<Diary_Entry__c> availability = new List<Diary_Entry__c>();
        // Get the earliest DateTime that this DEC should start at.
        Datetime earliestDT = getEarliestDT(isBusiness);
        System.debug(LoggingLevel.INFO, 'earliestDT: ' + earliestDT);
        
        // Split diary entries into availability and unavailability
        for(Diary_Entry__c de : entries) {
            System.debug(LoggingLevel.INFO, 'RecType: ' + de.Record_Type__c + ' start: ' + de.Start__c + ' End: ' + de.End__c);
            if(de.Record_Type__c == SearchBlackBox.UNAVAILABILITY_DIARY_ENTRY_TYPE) {
                unavailability.add(de);
                continue;
            } else if(de.Start__c < earliestDT && de.End__c < earliestDT){
                continue;
            }
            availability.add(de);
        }
        System.debug(LoggingLevel.INFO, 'availability.size(): ' + availability.size());
        // If no availability, return
        if(availability.isEmpty()) {
            return null;
        }*/
        
        List<DiaryEntryCollection> DECs = new List<DiaryEntryCollection>();
        
        // If the employee is a pool employee, call the createPoolDECs method instead
        if(ei.isPool) {
            DECs = createPoolDECs(availability, ei, earliestDT);
            if(DECs.isEmpty())
                return null;
            return DECs;
        }
        
        // If employee is not pool and unavailability is empty, creating a DEC is easy...
        if(unavailability.isEmpty()) {
            
            List<DiaryEntryInfo> DEIs = new List<DiaryEntryInfo>();
            // Loop over each Diary Entry and create a DiaryEntryInfo object for each 
            for(Diary_Entry__c av : availability) {
                // Check if we should use the Diary Entry's start time or if we need to adjust it
                System.debug(LoggingLevel.INFO, 'Av ID: ' + av.ID);
                
                Datetime avStart = av.Start__c;
                Double FrontGap=0.0;
                Double backGap = 0.0;
                if(av.Start__c < earliestDT){
                  // List<List<string>> shfts = weekshifts(av);
                    //FrontGap = DateTimeHelper.calculateHours(av.Start__c,earliestDT,shfts);
                    avStart = earliestDT;
                }
                
                //DEIs.add(new DiaryEntryInfo(av, avStart, av.End__c, FrontGap, backGap));
                DEIs.add(new DiaryEntryInfo(av, avStart, av.End__c));
                System.debug(LoggingLevel.INFO, 'GB: ' + DEIs);
            }
            
            if(DEIs.isEmpty())
                return null;
                
            // Create a new DiaryEntryCollection and return. 
            DiaryEntryCollection dec = new DiaryEntryCollection(DEIs, ei);
            //rjd - 2010-01-05 - trying to stop out of bounds errors for incorrect data.
            if(dec.finishDT == null){
                System.debug(LoggingLevel.INFO, 'dec.dinishDT is null - return null;');
                return null;
            }
            DECs.add(dec);
            return DECs;
        }
        
        // Employee is not pool, and unavailability is not empty - there is a separate method to handle this 
        return processAvailabilityAndUnavailability(availability, unavailability, ei, earliestDT);
    }

    /* processAvailabilityAndUnavailability(List<Diary_Entry__c> availability, List<Diary_Entry__c> unavailability,
                                            EmployeeInformation ei, DateTime earliestDT)
        This method contains the logic to process Diary Entries representing availability and unavailability and
        create the correct DiaryEntryCollections. This main reason for creating this method was to help make the
        createDECs more readable and manageable. */
    private static List<DiaryEntryCollection> processAvailabilityAndUnavailability( List<Diary_Entry__c> availability, 
                                                                                    List<Diary_Entry__c> unavailability,
                                                                                    EmployeeInformation ei, DateTime earliestDT) {
        List<DiaryEntryCollection> DECs = new List<DiaryEntryCollection>();
        
        // We loop over each availability Diary Entry and check if any unavailability Diary
        // Entries overlap with it. From there we work out what the DECs should be.
        
        system.debug(LoggingLevel.INFO,'process_av_unava availability '+ei.employeeName+' '+availability);
        Diary_Entry__c de_avchk;
        for(Diary_Entry__c av_chk : availability){
        if(de_avchk == null){
        de_avchk = av_chk;
        }else{
        if(av_chk.start__c <= de_avchk.start__c)
        de_avchk = av_chk;
        }}
        
        for(Diary_Entry__c av : availability) {
        
            if(av.start__c == de_avchk.start__c)
            replan_skiprule = true;
            else
            replan_skiprule = false;
            
            List<Diary_Entry__c> overlapping = new List<Diary_Entry__c>();
            
            for(Diary_Entry__c unav : unavailability) {
                // Create a list of unavailabilities that "touch" this availability
                if( unav.Start__c <= av.Start__c && unav.End__c >= av.End__c || 
                    unav.Start__c >= av.Start__c && unav.Start__c < av.End__c || 
                    unav.End__c > av.Start__c && unav.End__c <= av.End__c) {
                    overlapping.add(unav);
                } else if(unav.Start__c >= av.End__c) {
                    break;
                }
            }
            
            // Get the start of this availability and adjust if necessary
            Datetime currentAvStart = av.Start__c;
            //Double FrontGap = 0.0;
            //Double backGap = 0.0;
            if(currentAvStart < earliestDT){ 
                //Added by Ashok G
                /*List<List<string>> sfts = weekshifts(av);
                system.debug(LoggingLevel.INFO,'-=-=-=-=-=Ashok Debug:'+currentAvStart+' '+earliestDT);
                FrontGap = DateTimeHelper.calculateHours(currentAvStart,earliestDT,sfts);*/
                currentAvStart = earliestDT;
            }
            
            // Get the end of the current availability...
            Datetime currentAvEnd = av.End__c; 
            
            // If there is no overlapping unavailability, we can create a DEC for this availability 
            if(overlapping.isEmpty()) {
                // Create the DEC
                List<DiaryEntryInfo> dei = new List<DiaryEntryInfo>{new DiaryEntryInfo(av, currentAvStart, currentAvEnd)};
                System.debug(LoggingLevel.INFO, 'GB: ' + dei);
                DiaryEntryCollection dec = new DiaryEntryCollection(dei, ei);
                system.debug(LoggingLevel.INFO,'330:'+dec);
                system.debug(LoggingLevel.INFO,'382:'+decs);
                // If there are previously created DECs, we need to check if the DEC we are creating shares
                // its start with the previous DEC's end. If it does, we extend the previous DEC 
                if(!DECs.isEmpty()) {
                    DiaryEntryCollection previous = DECs[DECs.size()-1];
                    if(DateTimeHelper.dateEquals(previous.finishDT, dec.startDT)) {
                        // Add the previous DEC's DEIs
                        List<DiaryEntryInfo> DEIs = new List<DiaryEntryInfo>();
                        DEIs.addAll(previous.entryInfoObjects);
                        DEIs.addAll(dei);
                        // Create a new DEC
                        system.debug(LoggingLevel.INFO,'inside -=-=-');
                        dec = new DiaryEntryCollection(DEIs, ei);
                        // Remove the old one
                        DECs.remove(DECs.size()-1);
                    }
                }
                if(dec.finishDT!=null || dec.startDt!=null)
                DECs.add(dec);
                
                // Move on to the next availability 
                continue;
            }
            
            Datetime currentUnavStart = null;
            Datetime currentUnavEnd = null;
            
            // There is overlapping unavailability. We loop over each one that overlaps
            for(Diary_Entry__c unav : overlapping) { 
                // Gap of availability at start before first unav
                currentUnavStart = unav.Start__c;
                currentUnavEnd = unav.End__c;
                
                // Does this unavailability start after currentAvStart? On the first loop, currentAvStart will be equal 
                // to the start DateTime of the current availability. On subsequent loops, it will be equal to the end 
                // of the last unavailability; in this case, this is used as the start of the next bit of availability 
                // (assuming the unavailability )
                if(currentUnAvStart > currentAvStart) {
                    List<DiaryEntryInfo> dei = new List<DiaryEntryInfo>{new DiaryEntryInfo(av, currentAvStart, currentUnavStart)};
                    System.debug(LoggingLevel.INFO, 'GB: ' + dei);
                    DiaryEntryCollection dec = new DiaryEntryCollection(dei, ei);
                    
                    // If there are previously created DECs, we need to check if the DEC we are creating shares
                    // its start with the previous DEC's end. If it does, we extend the previous DEC.
                    if(!DECs.isEmpty()) {
                        DiaryEntryCollection previousDec = DECs[DECs.size()-1];
                        if(DateTimeHelper.dateEquals(previousDec.finishDT, currentAvStart)) {
                            // Add the previous DEC's DEIs
                            List<DiaryEntryInfo> DEIs = new List<DiaryEntryInfo>();
                            DEIs.addAll(previousDec.entryInfoObjects);
                            DEIs.addAll(dei);
                            // Create a new DEC
                            dec = new DiaryEntryCollection(DEIs, ei);
                            // Remove the old one
                            DECs.remove(DECs.size()-1);
                        }
                    }
                    if(dec.finishDT!=null || dec.startDt!=null)
                    DECs.add(dec);
                }
                
                if(currentUnavEnd < currentAvEnd && currentUnAvEnd > currentAvStart) {
                    currentAvStart = currentUnavEnd;
                } else {
                    // This unavailability runs past the availability's end point, 
                    // no need to look at any more unavs, break out of the loop.
                    currentAvStart = currentAvEnd;
                    break;
                }
            }
            
            // There may be availability between the end of the last unavailability and this availability's end
            // that we need to create a DEC out of.
            if(currentAvStart < currentAvEnd) {
                List<DiaryEntryInfo> dei = new List<DiaryEntryInfo>{new DiaryEntryInfo(av, currentAvStart, currentAvEnd)};
                System.debug(LoggingLevel.INFO, 'GB: ' + dei);
                DiaryEntryCollection dec = new DiaryEntryCollection(dei, ei);
                if(dec.finishDT!=null || dec.startDt!=null)
                DECs.add(dec);
            }
        }
        System.debug('DECs Kanitha '+DECs);
        return DECs;
    }

    /* createPoolDECs(List<Diary_Entry__c> availability, EmployeeInformation ei, DateTime earliestDT)
        This method is called to create DiaryEntryCollections for pool employees. This differs slightly
        from non-pool employees. A pool employee will always finish work on the same day that they 
        start a job on, provided they have enough hours available in the day. Typically, a pool employee
        will have more availability in a day than there are hours between the shift start and end of 
        that day.
        
        Because a pool employee finishes work on the day they start, although a Diary Entry may span
        more than one day, we create one DiaryEntryCollection for each day the Diary Entry covers. The
        hours in each DEC are determined by the relevant "Available Hours" fields on the corresponding
        Week object. */
    private static List<DiaryEntryCollection> createPoolDECs(List<Diary_Entry__c> availability, EmployeeInformation ei, DateTime earliestDT) {
        Diary_Entry__c entry = availability[0];
        
        // Get the shift pattern information for this employee 
        List<List<String>> shifts = new List<List<String>> {
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Monday_Start_Time__c,
                                            entry.Week__r.Shift_Pattern__r.Monday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Tuesday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Wednesday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Thursday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Friday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Friday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Saturday_End_Time__c},
                        new List<String> {  entry.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, 
                                            entry.Week__r.Shift_Pattern__r.Sunday_End_Time__c}};
                                            
        // Store the available hours in a list for easy, programmatic access 
        List<Double> availableHours = new List<Double> {entry.Week__r.Monday_Available_Hours__c, entry.Week__r.Tuesday_Available_Hours__c,
                                                entry.Week__r.Wednesday_Available_Hours__c, entry.Week__r.Thursday_Available_Hours__c,
                                                entry.Week__r.Friday_Available_Hours__c, entry.Week__r.Saturday_Available_Hours__c,
                                                entry.Week__r.Sunday_Available_Hours__c};
        
        List<DiaryEntryCollection> DECs = new List<DiaryEntryCollection>();
        
        // Defect XXX
        // If this pool diary is already on the job, we need to include the hours of his entry for the job.
        // We get the Diary Entries for this employee (if there are any - if not, entryOnJob will be null.)
        List<Diary_Entry__c> entryOnJob = EmployeeInformationCollection.entriesAlreadyOnJob.get(ei.employeeID);
        
        // Loop over each Diary Entry 
        for(Diary_Entry__c de : availability) {
            DateTime startDT = entry.Start__c;
            
            // A loop to create a Diary Entry Collection for each day
            do {
                if(shifts[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))][1] == null) {
                    System.debug(LoggingLevel.INFO, 'de.ID: ' + de.ID);
                }
                Time endT = DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))][1]);
                DateTime endDT = DateTime.newInstance(startDT.date(), endT);
                
                // Create a DEC if the current day is greater than or equal to the earliestDate passed into the method.
                // This ensures that DECs are not created for dates before the date the search is being run for 
                if(startDT.date() >= earliestDT.date()) {
                    Double hoursForDay = availableHours[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))];
                    // Defect XXX
                    // If this pool employee already has a diary entry on this Job, make sure we include those hours.
                    // If he is on the job, entryOnJob will only have entry in it, as work that pool employees do
                    // on a job cannot span multiple days 
                    if(entryOnJob != null && entryOnJob[0].Start__c.dayOfYear() == startDT.dayOfYear())
                        hoursForDay += entryOnJob[0].Hours__c;
                    DiaryEntryInfo dei = new DiaryEntryInfo(entry, startDT, endDT, hoursForDay);
                    System.debug(LoggingLevel.INFO, 'dei is: ' + dei);
                    //change by Ashok G
                    DiaryEntryCollection dec = new DiaryEntryCollection(new List<DiaryEntryInfo> {dei}, ei);
                    if(dec.finishDT!=null || dec.startDt!=null)
                    DECs.add(dec);
                    //DECs.add(new DiaryEntryCollection(new List<DiaryEntryInfo> {dei}, ei));
                }

                // Move startDT to the next day
                startDT = startDT.addDays(1);

                // If there's a shift time for the next day, set the time on startDT
                if(shifts[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))][0] != null) {
                    startDT = DateTime.newInstance(startDT.date(), 
                                                DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))][0]));
                } else
                    break;

            } while(startDT.dayOfYear() != entry.End__c.dayOfYear() + 1);
        }

        return DECs;
    }
    
    /* getEarliestDT(Boolean isBusiness)
        A helper method used to provide a DateTime which represents the earliest date and time that a DiaryEntryCollection 
        (or a DiaryEntryInfo) can start. */
    public static DateTime getEarliestDT(Boolean isBusiness) {
        if(isBusiness) {
            // If we are searching for business best (i.e. earliest) options, the earliest DateTime should be now
            if(cls_IsRun.isPlanner == 'N'){
            Date HSABusinessDate = SearchBlackBox.optsAndParms.HSACustomerPrefDate(Date.today());
            return DateTime.newInstance(HSABusinessDate, Time.newInstance(0,0,0,1));
            }else
             return Datetime.now();
        } else {
            // We are searching for a customer preferred date. If the customer preferred date is today, the earliest
            // start should be now (this may change). Otherwise, return the customer preferred date. 
            if(SearchBlackBox.optsAndParms.customerPreferredDate == Date.today()){
    //rjd 2010-01-11 - Trying to force cpd to be start of shift if today
                return DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,1));
                //return Datetime.now();
            }
            else
                return Datetime.newInstance(SearchBlackBox.optsAndParms.customerPreferredDate, Time.newInstance(0,0,0,1));
        }
    }
    
    /* addWorkingHoursToStart(Double hoursToAdd)
        Adds a number of hours to the start DateTime of this DiaryEntryCollection and returns it. We cannot reuse the
        similar method in DateTimeHelper as there is some additional logic required. */
    public Datetime addWorkingHoursToStart(Double hoursToAdd) {
        //System.debug(LoggingLevel.INFO, 'hoursToAdd: ' + hoursToAdd + ' numberOfHours: ' + numberOfHours + ' startDT: ' + startDT + ' finishDT: ' + finishDT);
        // If there aren't any hours to add, return the startDT unchanged
        if(hoursToAdd == 0.0)
            return startDT;
        
        // If we have been asked to add more hours than there are hours in the DEC, we return the finishDT.
        // This is not necessarily the most logical flow but other parts of the solution assume this behaviour
        // Note that we also have to take into account the gapSizeTolerance parameter!
        if((isPool && hoursToAdd >= numberOfHours) || 
            (!isPool && hoursToAdd >= numberOfHours - SearchBlackBox.optsAndParms.gapSizeTolerance)) {
            System.debug(Logginglevel.WARN, 'hoursToAdd was greater than numberOfHours');
            return finishDT;
        }
        
        // If this is a DEC for a pool employee, adding hours should not take the DateTime passed the end of the
        // employee's day.
        if(isPool) {
            // Add the hours to a copy of startDT
            DateTime answer = DateTime.newInstance(startDT.date(), startDT.time());
            answer = DateTimeHelper.addHoursToDT(answer, hoursToAdd);
            
            // Get the end of the day for the employee
            Time dayEnd = DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'))][1]);
            // If adding the hours has changed the date, or if the date is the same but the time is after the end of
            // the day, then return the end of the day, otherwise return the answer as it is.
            if(answer.dayOfYear() != startDT.dayOfYear() || answer.time() > dayEnd) {
                return DateTime.newInstance(startDT.date(), dayEnd);
            } else {
                return answer;
            }
        }

        // This part of the code only applies to non-pool employees
        // Set up some information for a loop - an Integer representing the current day, start and end times, and hours left to add
        Integer dayI = DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'));
        Time startTime = Time.newInstance(startDT.hour(), startDT.minute(),0,0); 
        Time endTime = DateTimeHelper.stringToTime(shifts[dayI][1]); 
        Double leftToAdd = hoursToAdd;
        DateTime answer = DateTime.newInstance(startDT.date(), startDT.time()); 
        
        // Whilst there are hours still to be added...
        while(leftToAdd > 0) {
            // How many hours between start and end for the current day?
            Double hoursToday = DateTimeHelper.subtractTime(endTime, startTime);
            // If there are more hours in the current day than there are left to be added, add the hours and break from the loop.
            if(hoursToday >= leftToAdd) {
                answer = DateTimeHelper.addHoursToDT(answer, leftToAdd);
                break;
            }

            // The current day does not contain enough hours, set the variables to the relevant values for the next day.
            dayI++;
            startTime = DateTimeHelper.stringToTime(shifts[dayI][0]); // next day's shift start
            endTime = DateTimeHelper.stringToTime(shifts[dayI][1]); // next day's shift end
            answer = DateTime.newInstance(answer.date().addDays(1), startTime);
            // Subtract the hours in the current day from what is left to add.
            leftToAdd -= hoursToday;
        }
        return answer;
    }

    /* getGapID(Datetime dt)
        Returns the ID of the first Diary Entry that covers the provided DateTime. */
    public ID getGapID(Datetime dt) {
        // Loop over the DiaryEntryInfo objects
        for(DiaryEntryInfo dei : entryInfoObjects) {
            // If this DEI covers the provided DateTime, return the ID
            if(dt >= dei.startDT && dt <= dei.finishDT)
                return dei.entry.ID;
        }
        // No ID found, return null.
        return null;
    }

    /* print()
        Print the information in this DiaryEntryCollection to System.debug(). */
    public void print() {
        System.debug(LoggingLevel.INFO, 'dec.print(): ' + this);
        for(DiaryEntryInfo dei : entryInfoObjects) {
            dei.print();
        }
    }

    /* workingHoursBetween(Datetime dt1, Datetime dt2)
        Returns the working hours between the two provided DateTimes according to the shift pattern for this DiaryEntryCollection.
        This method assumes that dt1 is earlier than dt2, and passes through to the caculateHours method in DateTimeHelper. */
    // assumption d1 = earlier, d2 = later
    public Double workingHoursBetween(Datetime dt1, Datetime dt2) {
        return DateTimeHelper.calculateHours(dt1, dt2, shifts);
    }
    
    /* DiaryEntryCollection(Diary_Entry__c entry)
        Constructor. No longer needed. */
    public DiaryEntryCollection(Diary_Entry__c entry) {
        shifts = new List<List<String>> {
                        new List<String> {  entry.Week__r.Monday_Start_Time__c, entry.Week__r.Monday_End_Time__c},
                        new List<String> {  entry.Week__r.Tuesday_Start_Time__c, entry.Week__r.Tuesday_End_Time__c},
                        new List<String> {  entry.Week__r.Wednesday_Start_Time__c, entry.Week__r.Wednesday_End_Time__c},
                        new List<String> {  entry.Week__r.Thursday_Start_Time__c, entry.Week__r.Thursday_End_Time__c},
                        new List<String> {  entry.Week__r.Friday_Start_Time__c, entry.Week__r.Friday_End_Time__c},
                        new List<String> {  entry.Week__r.Saturday_Start_Time__c, entry.Week__r.Saturday_End_Time__c},
                        new List<String> {  entry.Week__r.Sunday_Start_Time__c, entry.Week__r.Sunday_End_Time__c}};
    }   
    
    public static list<list<string>> weekshifts(Diary_Entry__c av){
        List<List<string>> shfts = new List<List<String>> {
                        new List<String> {  av.Week__r.Shift_Pattern__r.Monday_Start_Time__c,
                                            av.Week__r.Shift_Pattern__r.Monday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Tuesday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Wednesday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Thursday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Friday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Friday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Saturday_End_Time__c},
                        new List<String> {  av.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, 
                                            av.Week__r.Shift_Pattern__r.Sunday_End_Time__c}};
      return shfts;
    } 
    
}