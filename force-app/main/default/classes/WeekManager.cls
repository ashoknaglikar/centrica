public with sharing class WeekManager {
    
    //some constants
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    
    //Attributes of the week
    public Id weekId;//sf ID of the week
    private week__c week;
    //a map of the weeks entries that will be maintained in start date order
    public Map<Id, Diary_Entry__c> weeksEntriesMap;
    private List<Diary_Entry__c> weeksEntriesList;//same values as map plus uncommited records
    private List<Diary_Entry__c> weeksEntriesForDeletion = new List<Diary_Entry__c>();//Entries marked for deletion
    //is the week for a pool diary?
    public boolean poolDiary {public get; private set;}
    
    
    //constructors
    /*
    public WeekManager(Id weekId)
    {
        this.weekId = weekId;
        weeksEntriesMap = new Map<Id, Diary_Entry__c>([select id, start__c, end__c, week__c, hours__c, RecordTypeId, Employee__c from Diary_Entry__c where week__c = :weekId]);
        weeksEntriesList = weeksEntriesMap.values();
    }
    */
    
    //should use this to avoid unecessary queries
    public WeekManager(Id weekId, List<Diary_Entry__c> weeksEntries, Week__c week)
    {
        this.weekId = weekId;
        weeksEntriesList = weeksEntries;        
        weeksEntriesMap = new Map<Id, Diary_Entry__c>();
        weeksEntriesMap.putAll(weeksEntries);
        this.week = week;
        this.poolDiary = week.Employee__r.Pool_Diary__c;
        system.debug(LoggingLevel.INFO, 'this.poolDiary ' + this.poolDiary);
    }
    
    //Inner Classes
    /**************************************************************************
    * purpose:      An EntryDetails object that contains the
    *               following details:
    *               Id jobId - the id of the job that the booking relates to
    *               List<Id> affectedEntries - the id's of entries modified by
    *               creating new entry
    *               Id week - the id of the week that the entry is in
    *               Double hours - the number of hours that the job will take
    *               Datetime startTime - The date and time that the entry starts
    *               Datetime endTime - The date and time that the entry ends
    *               String skill - The skill of the job
    *               ID recordTypeId - the record type of the diary entry
    *
    **************************************************************************/
    public class EntryDetails
    {
        public Id jobId; //- the id of the job that the booking relates to
        public List<Diary_Entry__c> affectedEntries;// the entries modified by
                                        // creating new entry
        public Id week; //- the id of the week that the entry is in
        public Double hours; //- the number of hours that the job will take
        public Datetime startTime; //- The date and time that the entry starts
        public Datetime endTime; //- The date and time that the entry ends
        public String skill; //- The skill of the job
        public Id recordTypeId; //- the record type of the diary entry
        public Double overBookedHours; //any overbooked hours for the job
        public id TravelJobId; // travel Job Id
        public EntryDetails(Id jobId, List<Diary_Entry__c> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String skill, ID recordTypeId, Double overBookedHours)
                            
        {
            this.jobId = jobId;
            //this.affectedEntries = affectedEntries;//dont use this anymore
            this.week = week;
            this.hours = hours;
            this.startTime = startTime;
            this.endTime = endTime;
            this.skill = skill;
            this.recordTypeId = recordTypeId;
            this.overBookedHours = overBookedHours;                                                                     
        }
        public EntryDetails(Id jobId, List<Diary_Entry__c> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String skill, ID recordTypeId)
                            
        {
            this(jobId, affectedEntries, week, hours, startTime, endTime,
                            skill, recordTypeId, 0.0);                                                  
        }   
        
        public EntryDetails(Id jobId, List<Diary_Entry__c> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String skill, ID recordTypeId, Double overBookedHours,Id TravelJobId)
                            
        {
            this.jobId = jobId;
            this.week = week;
            this.hours = hours;
            this.startTime = startTime;
            this.endTime = endTime;
            this.skill = skill;
            this.recordTypeId = recordTypeId;
            this.TravelJobId = TravelJobId; 
            this.overBookedHours = overBookedHours;     
                                                                    
        }   
    }
    /**************************************************************************
    * purpose:      virtual class for holding results from modifying a diary
    *               entry
    *
    **************************************************************************/ 
    public virtual class EntryResult
    {
        public Diary_Entry__c newEntry;
        public List<Diary_Entry__c> modifiedEntries = new List<Diary_Entry__c>();
        private List<Diary_Entry__c> removedEntries = new List<Diary_Entry__c>();
        //constructor
        public EntryResult(Diary_Entry__c newEntry)
        {
            this.newEntry = newEntry;                                                                   
        }
        public EntryResult()
        {
                                                                                
        }       
        //method to allow the addition of modified entries
        public virtual void addModEntry(Diary_Entry__c modEntry)
        {
            if(modEntry != null)
            {
                modifiedEntries.add(modEntry);
            }       
        }
        //method to allow the addition of modified entries
        public virtual void addModEntry(List<Diary_Entry__c> modEntries)
        {
            modifiedEntries.addAll(modEntries);
        }   
        //method to allow the addition of deleted entries
        public virtual void addDelEntry(Diary_Entry__c delEntry)
        {
            /*
            if(delEntry.Id != null)
            {
                removedEntries.add(delEntry);
            }
            */
            removedEntries.add(delEntry);
            
        }
        //method to allow the addition of deleted entries
        public virtual void addDelEntry(List<Diary_Entry__c> delEntries)
        {
            for(Diary_Entry__c delEnt : delEntries)
            {
                addDelEntry(delEnt);
            }       
        }   
    }
    
    /**************************************************************************
    * purpose:      Contains the results of a diary entry creation
    *               new diary entry
    *               any entries (gaps) that were modified
    *
    **************************************************************************/
    public class CreateEntryResult extends EntryResult
    {
        
        public Diary_Entry__c nextGap;//the next gap for multiple booking inserts 
        public CreateEntryResult()
        {

        }
        public CreateEntryResult(Diary_Entry__c entryToCreate)
        {
            super(entryToCreate);
        }
    }   
    
    /**************************************************************************
    * purpose:      Contains the results of a diary entry removal
    *               removed diary entry
    *               any entries (gaps) that were modified
    *
    **************************************************************************/
    public class RemoveEntryResult extends EntryResult
    {
        
        public RemoveEntryResult()
        {

        }
        public RemoveEntryResult(Diary_Entry__c entryToRemove)
        {
            super(entryToRemove);
        }
    }
        
    //Public Methods
    /**************************************************************************
    * method name:  getEntriesByType
    * purpose:      returns a subset of the weeks diary entries of a particular
    *               type e.g. 'Job Booking'
    * return:       List<Diary_Entry__c> result - a list of Diary Entries with
    *               a particular record type
    * parameter(s): Id entryRecordType - The Diary Entry Record Type of the
    *               diary entries to be returned
    * exception(s):
    *
    **************************************************************************/ 
    /* method not used
    public List<Diary_Entry__c> getEntriesByType(Id entryRecordType)
    {
        List<Diary_Entry__c> result = new List<Diary_Entry__c>();
        for(Diary_Entry__c weekEntry : this.weeksEntriesList)
        {
            if(weekEntry.RecordTypeId == entryRecordType)
            {
                result.add(weekEntry);
            }
        }
        return result;
    }
    */
    /**************************************************************************
    * method name:  getWeek
    * purpose:      returns the week object
    * return:       Week__c
    * parameter(s): none
    * exception(s):
    *
    **************************************************************************/ 
    public Week__c getWeek()
    {
        return week;
    }
    /**************************************************************************
    * method name:  removeUnavailability
    * purpose:      return the Id of an unavailability diary entry to be deleted
    *               and any modified entries resulting from the removal
    * return:       List<Diary_Entry__c> result - a list of Diary Entries with
    *               a particular record type
    * parameter(s): Id entryRecordType - The Diary Entry Record Type of the
    *               diary entries to be returned
    * exception(s):
    *
    **************************************************************************/     
    /* dont use this anymore, just use remove entry
    public RemoveEntryResult removeUnavailability(Diary_Entry__c unavToRemove)
    {
        
        //RemoveEntryResult result = new RemoveEntryResult(unavToRemove);           
        //result.addModEntry(DiaryEntryManager.removeDiaryEntry(unavToRemove, weeksEntriesList));
        //this.weeksEntriesForDeletion.add(unavToRemove);
        //return result;
        
        RemoveEntryResult result = DiaryEntryManager.removeDiaryEntry(unavToRemove, weeksEntriesList, poolDiary);
        this.weeksEntriesForDeletion.addAll(result.removedEntries);
        this.weeksEntriesForDeletion.add(unavToRemove);
        return result;
    }
    */
    /**************************************************************************
    * method name:  getWeeksEntriesForDeletion
    * purpose:      getter for the entries on a week that are marked for deletion
    * return:       List<Diary_Entry__c> weeksEntriesForDeletion
    * parameter(s): none
    * exception(s):
    *
    **************************************************************************/ 
    public List<Diary_Entry__c> getWeeksEntriesForDeletion()
    {
        return weeksEntriesForDeletion;
    }
    /**************************************************************************
    * method name:  getWeeksEntriesList
    * purpose:      getter for the entries on a week that may be upserted
    * return:       List<Diary_Entry__c> weeksEntriesList
    * parameter(s): none
    * exception(s):
    *
    **************************************************************************/
    public List<Diary_Entry__c> getWeeksEntriesList(Boolean calcHours)
    {
        //make sure all of the hours are correct before returning
        Double hours;
        for(Diary_Entry__c weekEntry : weeksEntriesList)
        {
            //do not want to change hours for pool diary
            //as this is managed elsewhere
            if(!poolDiary)
            {
                try
                {
                    system.debug(LoggingLevel.INFO, 'About to call calc hours with following params: ');
                    system.debug(LoggingLevel.INFO, 'start time:' + weekEntry.Start__c);
                    system.debug(LoggingLevel.INFO, 'end time:' + weekEntry.End__c);
                    system.debug(LoggingLevel.INFO, 'week: ' + week);
                    system.debug(LoggingLevel.INFO, 'weekEntry.Hours: ' + weekEntry.Hours__c + ' calcHours: ' + calcHours + ' recordType: ' + weekEntry.Record_Type__c);
                    
                    // gjb 2010-02-09 Changed the logic. Basically if calcHours is false, hours != null and the
                    // entry is not of Availability recored type, don't calculate the hours.
                    // There are currently two routes through this logic where calchours is false - firstly, from
                    // planOrReplan, and secondly, from createUnavailability. In both cases, availability should
                    // be recalculated, hence the clause about record type == Availability; in the second case, 
                    // unavailability should also be recalculated, however weekEntry.Hours should be null, so
                    // this should trigger the recalculation.
                    
                    // gjb 2010-02-12 There is now a third route to this code where calcHours is false - from
                    // suspendJob (which calls removeMultipleDiaryEntries). Because suspending jobs causes all
                    // diary entries to be evaluated, job bookings on other jobs in an employee's work for 0.01
                    // hours were causing problems. In the case of a job suspend, only availabilities should have
                    // their hours calculated - job bookings for the suspended job will become availability (or 
                    // not if there is unavailability), and they will need their hours calculating. Other job
                    // bookings and unavailability in the week should remain unchanged. 
                                                
                    if(!calcHours && weekEntry.Hours__c != null && weekEntry.RecordTypeId != ENTRY_RECTYPE_AVAIL)
                        hours = weekEntry.Hours__c;
                    else 
                        hours = Datetimehelper.calculateHours(weekEntry.Start__c, weekEntry.End__c, week);
                        
                    // gjb 2010-02-12 - This might be useful but is currently not needed...
                    //if(hours == 0 && weekEntry.Hours__c == 0.01)
                    //  hours = weekEntry.Hours__c;
                        
                    system.debug(LoggingLevel.INFO, 'hours is: ' + hours);
                }
                catch(Exception e) //completely outside of working hours
                {
                    system.debug(LoggingLevel.INFO, 'Exception in calculating hours: ' + e);
                    hours = 0.00;
                }
                weekEntry.Hours__c = hours;
            }
        }
        
        return weeksEntriesList; 
    }
    //Private Methods
    
    
    /**************************************************************************
    * method name:  removeEntry
    * purpose:      remove a diary entry, typically a Job booking  and manage the 
    *               gaps around it
    * return:       
    * parameter(s): List<Diary_Entry__c> removalEntries - A list of entries to remove
    * exception(s):
    *
    **************************************************************************/ 
    public void removeEntry(List<Diary_Entry__c> removalEntries)
    {
        //a result of a single booking removal
        RemoveEntryResult singleResult;
        
        //for each job booking
        for(Diary_Entry__c remEntry : removalEntries)
        {
            //insert the booking and get the result
            singleResult = DiaryEntryManager.removeDiaryEntry(remEntry, weeksEntriesList, poolDiary);       
            
            //update the weeks lists of entries to be modified and deleted
            //any deleted gaps
            system.debug('@@singleResult'+singleResult.removedEntries);
            this.weeksEntriesForDeletion.addAll(singleResult.removedEntries);
            //any new gaps created or modifies
            upsertDiaryEntries(singleResult.modifiedEntries);
            //remove and delted entries
            weeksEntriesList = checkDeletions();
            //some modification of the pool diary data is required if the week
            //represents a pool diary
            if(poolDiary)
            {
                system.debug(LoggingLevel.INFO, 'entries: ' + singleResult.modifiedEntries);
                // Defect XXX
                // gjb 2010-03-03 - If the employee is a pool diary, do not add all his diary entries for the week
                // to be upserted, as if he is a pool diary, there may be hundreds of diary entries for the week
                // and because of the way pool diaries work, there is no need to update the other records. The 
                // modified entries on the singleResult should contain the diary entry we need to upload.
                weeksEntriesList = singleResult.modifiedEntries;
                updatePoolWeek(remEntry, false);
                //get the availability gap for the weekto add the hours back on
                /*
                for(Diary_Entry__c possGap : weeksEntriesList)
                {
                    system.debug(LoggingLevel.INFO, 'possi ble gap: ' + possGap);
                    if(possGap.RecordTypeId == ENTRY_RECTYPE_AVAIL)
                    {
                        system.debug(LoggingLevel.INFO, 'found gap: ' + possGap);
                        possGap.Hours__c += remEntry.hours__c;
                        system.debug(LoggingLevel.INFO, 'found gap after hour mod: ' + possGap);
                        List<Diary_Entry__c> possGapList = new List<Diary_Entry__c>();
                        possGapList.add(possGap);
                        upsertDiaryEntries(possGapList);
                        break;
                    }
                }
                */
            }           
        }
    }
    
    /**************************************************************************
    * method name:  createEntry
    * purpose:      create a diary entry, typically a Job booking  and manage the 
    *               gaps around it
    * return:       CreateEntryResult result - An object of type CreateEntryResult
    *               which contains the created entry, and a list of
    *               gaps that were modified / created
    * parameter(s): EntryDetails entry - An EntryDetails object that contains the
    *               details about the entry to be created
    * exception(s):
    *
    **************************************************************************/ 
    public void createEntry(List<EntryDetails> EntDets)
    {
        /*Id jobId, List<Id> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String entryType, String skill, ID recordTypeId)*/
        
        //a result of a single booking insert
        CreateEntryResult singleResult;
        //find the gap that the booking will go into
        Diary_Entry__c gap;
        //if this is true then the search result has told us which gap
        //if(EntDets[0].affectedEntries.size() == 1)
        //{
        //  gap = EntDets[0].affectedEntries[0];
        //}
        //else//have to work out the gap ourselves
        //{
        gap = findGap(EntDets[0].startTime, EntDets[0].endTime);
        //}     
        //for each job booking
        for(EntryDetails entryDetail : EntDets)
        {

            //system.debug(LoggingLevel.INFO, 'entryDetail.affectedEntries.size()' + entryDetail.affectedEntries.size());
            //insert the booking and get the result
            System.debug('gap '+gap);
            
            //PRB00028286 fix starts
            if(system.label.Planning_gap_switch == 'on'){
            if(gap == null || !((DatetimeHelper.dateGreaterThanOrEqual(entryDetail.startTime, gap.Start__c)) && 
            (DatetimeHelper.dateLessThanOrEqual(entryDetail.endTime,gap.End__c))))
            {
            System.debug('The gap is either null or not a suitable gap '); 
            
            gap = findGap(entryDetail.startTime, entryDetail.endTime);
            }
            }
            //PRB00028286 fix ends
            if(entryDetail.skill == 'Travel Time')
            {
                singleResult = DiaryEntryManager.insertTravelBooking(entryDetail.jobId, gap, 
                                entryDetail.recordTypeId, entryDetail.startTime, 
                                entryDetail.endTime, entryDetail.hours, entryDetail.skill, poolDiary, 
                                entryDetail.overBookedHours, entryDetail.TravelJobId);
            }else
            {
            singleResult = DiaryEntryManager.insertBooking(entryDetail.jobId, gap, 
                                entryDetail.recordTypeId, entryDetail.startTime, 
                                entryDetail.endTime, entryDetail.hours, entryDetail.skill, poolDiary, 
                                entryDetail.overBookedHours);           
            }                   
            //if there is another booking then provide the gap record it will go into
            gap = singleResult.nextGap;
            //update the weeks lists of entries to be modified and deleted
            //any deleted gaps
            this.weeksEntriesForDeletion.addAll(singleResult.removedEntries);   
            //the new job booking
            this.weeksEntriesList.add(singleResult.newEntry);
            //any new gaps created or modifies
            upsertDiaryEntries(singleResult.modifiedEntries);
            //remove any delted entries
            weeksEntriesList = checkDeletions();
            //some modification of the pool diary data is required if the week
            //represents a pool diary
            if(poolDiary)
            {
                system.debug(LoggingLevel.INFO, 'Before pool diary week update: ' + week);
                updatePoolWeek(entryDetail, true);
                //update the availability gap on the week
                /*
                for(Diary_Entry__c possGap : weeksEntriesList)
                {
                    system.debug(LoggingLevel.INFO, 'possi ble gap: ' + possGap);
                    if(possGap.RecordTypeId == ENTRY_RECTYPE_AVAIL)
                    {
                        system.debug(LoggingLevel.INFO, 'found gap: ' + possGap);
                        possGap.Hours__c -= entryDetail.hours;
                        system.debug(LoggingLevel.INFO, 'found gap after hour mod: ' + possGap);
                        List<Diary_Entry__c> possGapList = new List<Diary_Entry__c>();
                        possGapList.add(possGap);
                        upsertDiaryEntries(possGapList);
                        break;
                    }
                }
                */
                system.debug(LoggingLevel.INFO, 'After pool diary week update: ' + week);               
            }
        }
                
    }
    
    /**************************************************************************
    * method name:  createUnavailability
    * purpose:      create a diary entry, of type unavailability
    * return:       CreateEntryResult result - An object of type CreateEntryResult
    *               which contains the created entry, and a list of
    *               gaps that were modified / created
    * parameter(s): List<Diary_Entry__c> unavsToRemove - List of unavailability
    *               Diary Entries that need to be created
    * exception(s):
    *
    **************************************************************************/ 
    public void createUnavailability(List<Diary_Entry__c> unavsToCreate)
    {
        /*Id jobId, List<Id> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String entryType, String skill, ID recordTypeId)*/
        
        //a result of a single unavailability insert
        CreateEntryResult singleResult;
        system.debug(LoggingLevel.INFO, 'Create Unavailabilities:- '+unavsToCreate);
        //for each unavailability
        for(Diary_Entry__c unavToCreate : unavsToCreate)
        {
            //insert the unavailability and get the result
            
            singleResult = DiaryEntryManager.insertUnavailability(unavToCreate, weeksEntriesList);          
            system.debug(LoggingLevel.INFO, 'SingleResult:- '+singleResult);
            //update the weeks lists of entries to be modified and deleted
            //any deleted gaps
            this.weeksEntriesForDeletion.addAll(singleResult.removedEntries);   
            //the new job booking
            this.weeksEntriesList.add(unavToCreate);
            //any new gaps created or modifies
            upsertDiaryEntries(singleResult.modifiedEntries);
            //remove any delted entries
            weeksEntriesList = checkDeletions();
        }       
    }   
    
    //Parameter Boolean plus - if false means minus
    private void updatePoolWeek(EntryDetails entryDetail, Boolean plus)
    {
        //find out which day of the week the entry starts
        String dayString = entryDetail.startTime.format('E');
        system.debug(LoggingLevel.INFO, 'dayString: ' + dayString);
        //add the hours to the booked hours
        if(dayString == 'Mon')
        {
            week.Monday_Booked_Hours__c = changeHours(week.Monday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Tue')
        {
            week.Tuesday_Booked_Hours__c = changeHours(week.Tuesday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Wed')
        {
            week.Wednesday_Booked_Hours__c = changeHours(week.Wednesday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Thu')
        {
            week.Thursday_Booked_Hours__c = changeHours(week.Thursday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Fri')
        {
            week.Friday_Booked_Hours__c = changeHours(week.Friday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Sat')
        {
            week.Saturday_Booked_Hours__c = changeHours(week.Saturday_Booked_Hours__c, entryDetail.hours, plus);
        }
        else if(dayString == 'Sun')
        {
            week.Sunday_Booked_Hours__c = changeHours(week.Sunday_Booked_Hours__c, entryDetail.hours, plus);
        }                                                       
        //if there are too many booked hours throw an exception
        //todo
    }
    
    //Parameter Boolean plus - if false means minus
    private void updatePoolWeek(Diary_Entry__c entryDetail, Boolean plus)
    {
        //find out which day of the week the entry starts
        String dayString = entryDetail.start__c.format('E');
        system.debug(LoggingLevel.INFO, 'dayString: ' + dayString);
        //add the hours to the booked hours
        if(dayString == 'Mon')
        {
            week.Monday_Booked_Hours__c = changeHours(week.Monday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Tue')
        {
            week.Tuesday_Booked_Hours__c = changeHours(week.Tuesday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Wed')
        {
            week.Wednesday_Booked_Hours__c = changeHours(week.Wednesday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Thu')
        {
            week.Thursday_Booked_Hours__c = changeHours(week.Thursday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Fri')
        {
            week.Friday_Booked_Hours__c = changeHours(week.Friday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Sat')
        {
            week.Saturday_Booked_Hours__c = changeHours(week.Saturday_Booked_Hours__c, entryDetail.hours__c, plus);
        }
        else if(dayString == 'Sun')
        {
            week.Sunday_Booked_Hours__c = changeHours(week.Sunday_Booked_Hours__c, entryDetail.hours__c, plus);
        }                                                       

        //if there are too many booked hours throw an exception
        //todo
    }
    
    private static Double changeHours(Double currentHour, Double newHour, Boolean plus)
    {
        Double existingHour = 0.0;
        if(currentHour != null)
        {
            existingHour = currentHour;
        }
        if(plus)
        {
            return existingHour + newHour;
        }
        else
        {
            return existingHour - newHour;
        }
    }
    
    //helper method to ensure no duplicates in entries list
    //and no entries in both upsert and delete lists
    private void upsertDiaryEntries(List<Diary_Entry__c> modOrNewEntries)
    {
        //outputWeeksEntries(weeksEntriesList, 'before adding non duplicate entries');
        //DiaryEntryManager.outputDiary2(weeksEntriesList, 'before adding non duplicate entries');
//      system.debug(LoggingLevel.INFO, 'modOrNewEntries: '+ modOrNewEntries);
        for(Diary_Entry__c modOrNewEntry : modOrNewEntries)
        {
            // Added this condition to avoid null pointer exceptio. 
            // I dont know why this is happening but can overcome this exception using this.
            
            if (modOrNewEntry == null){
                
                continue;
                
            }
            
            if(modOrNewEntry.Id == null) 
            {
                //check that we haven't already added this entry
                Boolean inAlready = false;
                system.debug('ASHOK Week Change 1: '+modOrNewEntry);
                for(Diary_Entry__c existingEntry : weeksEntriesList)
                {
                    system.debug('ASHOK Week CHange 2: '+existingEntry);
                    system.debug('ASHOK Week CHange 3: '+string.valueof(modOrNewEntry == existingEntry));
                    if(modOrNewEntry == existingEntry)
                    {
                        inAlready = true;
                        break;
                    }
                }
                if(!inAlready)
                {
                    //new entry so just insert into list
                    weeksEntriesList.add(modOrNewEntry);
                }               
                continue;
            }
            
            Integer i = 0;
            Boolean found = false;
            for(Diary_entry__c existingEntry : weeksEntriesList)
            {
                if(existingEntry.Id == modOrNewEntry.Id)
                {
                    found = true;
                    break;
                }
                i++;
            }
            if(found)
            {
                weeksEntriesList.remove(i);
                system.debug(LoggingLevel.INFO, 'weeksEntriesList.remove(i); - ' + i);
                found = false;
            }

            weeksEntriesList.add(modOrNewEntry);
        }
        //outputWeeksEntries(weeksEntriesList, 'after adding non duplicate entries');
        //DiaryEntryManager.outputDiary2(weeksEntriesList, 'after adding non duplicate entries');
    }
    private List<Diary_Entry__c> checkDeletions()
    {
        Boolean found;
        List<Diary_Entry__c> copyWeeksList = new List<Diary_Entry__c>();
        for(Diary_Entry__c upsertEnt : weeksEntriesList)
        {
            found = false;
            for(Diary_Entry__c delEnt : weeksEntriesForDeletion)
            {
                if(delEnt.Id != null && delEnt.Id == upsertEnt.Id)
                {
                    found = true;
                }
                else
                {
                    if(delEnt == upsertEnt)
                    {
                        found = true;
                    }
                }
            }
            if(!found)
            {
                copyWeeksList.add(upsertEnt);
            }
            
        }
        return copyWeeksList;
    }
    
    //find a gap in a week based on a start and end time that will fit in the gap
    private Diary_Entry__c findGap(Datetime startTime, Datetime endTime)
    {
        List<Diary_Entry__c> findings = new List<Diary_Entry__c>();
        outputWeeksEntries(weeksEntriesList, 'Entries before searching for a gap for booking');
        for(Diary_Entry__c weekEntry : weeksEntriesList)
        {
            system.debug('Start time'+ startTime);
            system.debug('endTime'+ endTime);
            system.debug('weekEntry.Start__c'+ weekEntry.Start__c);
            system.debug('weekEntry.End__c'+ weekEntry.End__c);
            Double diffcheck=DatetimeHelper.SubtractDate(startTime, weekEntry.Start__c); 
            Double diffcheck1=DatetimeHelper.SubtractDate(endTime, weekEntry.End__c);
            if((DatetimeHelper.dateGreaterThanOrEqual(startTime, weekEntry.Start__c) || (diffcheck == -0.01 || diffcheck == -0.02|| diffcheck == -0.03 ))&&
                    (DatetimeHelper.dateLessThanOrEqual(endTime, weekEntry.End__c) ||(diffcheck1 == 0.01 ||diffcheck1 == 0.02 ||diffcheck1 == 0.03 ))&&
                    weekEntry.RecordTypeId == ENTRY_RECTYPE_AVAIL)
            {
               findings.add(weekEntry);
            }
            
        }
        system.debug('findings'+findings);
        if(findings.size() == 1)
        {
            system.debug(LoggingLevel.INFO, 'This is the gap which we found: '+ findings[0]);
            return findings[0];
        }
        else if(findings.size() == 0)
        {
            throw new WeekMananagerException('Did not find an availability record to replace with a job booking for booking dates: Start: ' + startTime + ' End: ' + endTime);
        }
        else
        {
            throw new WeekMananagerException('Data integrity problem, overlapping Availability records');
        }
    }
    
    private void outputWeeksEntries(List<Diary_Entry__c> weeksEnts, String comment)
    {
        string debug = '\n' + comment + '\n';
        String typeStr = 'Record type has no value';
        system.debug(LoggingLevel.INFO, '#################################');
        for(Diary_Entry__c ent : weeksEnts)
        {       
            if(ent.RecordTypeId == ENTRY_RECTYPE_BOOKING)typeStr = 'Job Booking';
            if(ent.RecordTypeId == ENTRY_RECTYPE_AVAIL)typeStr = 'Availability';
            if(ent.RecordTypeId == ENTRY_RECTYPE_UNAVAIL)typeStr = 'Unavailability';
            //debug += ent.id + '\n' + ent.Start__c + '\n' + ent.End__c + '\n' + typeStr + '\n';
            system.debug(LoggingLevel.INFO, 'outputweekEntries: '+ent);
        }
       system.debug(LoggingLevel.INFO, '#################################');
        
    }
    public class WeekMananagerException extends Exception{} 
}