public with sharing class JobBookingManager {
    
    /*Start of Public Methods~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //some constants
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');  
    
    public static Map<ID, Job_Booking_History__c> jbhByJobID = new Map<ID, Job_Booking_History__c>();
    
    public static void handleJBH(Job_Booking_History__c jbhRequest) {
        // If the job this JBH is assigned to is not in the jbhByJobID map, simply insert the JBH and return. 
        if(!jbhByJobID.containsKey(jbhRequest.Job__c)) {
            insert jbhRequest;
            jbhByJobID.put(jbhRequest.Job__c, jbhRequest);
            return;
        }

        Job_Booking_History__c existingJBH = jbhByJobID.get(jbhRequest.Job__c);
        
        // If Work Affected and Materials affected are already true, return as nothing can change. 
        if(existingJBH.Work_Affected__c && existingJBH.Materials_Affected__c)
            return;
        
        if(existingJBH != null) {
            if(existingJBH.Work_Affected__c == jbhRequest.Work_Affected__c 
                && existingJBH.Materials_Affected__c == jbhRequest.Materials_Affected__c) {
                // The JBH has the same values as the one already inserted, so do nothing.
                return;
            }
            
            Boolean upd = false;
            
            if(existingJBH.Work_Affected__c != jbhRequest.Work_Affected__c && jbhRequest.Work_Affected__c == true) {
                // Work affected value is different, for jbhRequest it is true, therefore the existingJBH should be updated
                upd = true;
                existingJBH.Work_Affected__c = true;
            }
            
            if(existingJBH.Materials_Affected__c != jbhRequest.Materials_Affected__c && jbhRequest.Materials_Affected__c == true) {
                // Work affected value is different, for jbhRequest it is true, therefore the existingJBH should be updated
                upd = true;
                existingJBH.Materials_Affected__c = true;
            }
            
            if(upd)
                update(existingJBH);
        }
        
    }
    
    /**************************************************************************
    * method name:  planOrReplanJob
    * purpose:      main interface into the booking code. Given a search result 
    *               Id from the search black box, book a job
    * return:       void
    * parameter(s): String optionId - the option identifier of the search result
    * exception(s): BookingException
    *
    **************************************************************************/
    public static void planOrReplanJob(String optionId)
    {
        //get the search results related to the option that was chosen for the booking
        List<Search_Result__c> searchResults = new List<Search_Result__c>();
        searchResults = [Select s.Start_Date_Time__c, s.Skill__c, s.Order__c,
            s.Option_Identifier__c, s.Job_ID__c, s.Job_ID__r.CHI_Lead__c, s.Id, s.Hours__c,Job_ID__r.Is_Remedial_Job__c ,Job_ID__r.Is_Downtime_Job__c,
            s.End_Date_Time__c, s.Diary_Entry_ID__c, s.Diary_Entry_ID__r.Employee_ID_18__c,Travel_Job__c From Search_Result__c s
            where s.Option_Identifier__c = :optionId
            order by s.Start_Date_Time__c asc];
          
        //option Id may be invalid...   
        if(searchResults.size() < 1)
        {
            throw new BookingException('Option id ['+ optionId +'] provided is not valid');
        }

        //option id is ok, now get some data that will be common to all searchResults
        Id myJobId = searchResults[0].Job_ID__c;
        
        //now get data that is per employee (per week really)
        //this is held in a map of weekIds to perEmployeeData 
        Map<Id, perEmployeeData> weekIdToEmpData = new Map<Id, perEmployeeData>();      
        //first thing to do is find out which weeks we need, map diary entries to weeks     
        Set<Id> diaryEntIdSet = new Set<Id>();
        
        // Populate Main Installer 
        string mainInstallerPayNum ;
        Id chiLeadId ; 
        decimal mechHours = 0;
        
               
        for(Search_Result__c searchResult : searchResults)
        {
            if(!(searchResults[0].Job_ID__r.Is_Remedial_Job__c || searchResults[0].Job_ID__r.Is_Downtime_Job__c) && searchResult.Skill__c == 'Mechanical' && mechHours < searchResult.Hours__c)
            {
            
                mechHours = searchResult.Hours__c;
                mainInstallerPayNum = searchResult.Diary_Entry_ID__r.Employee_ID_18__c;
                chiLeadId = searchResult.Job_ID__r.CHI_Lead__c;
            }
            diaryEntIdSet.add(searchResult.Diary_Entry_ID__c);          
        }
        
        Map<Id, Diary_Entry__c> diaryEntIdToDiaryEntMap = new Map<Id, Diary_Entry__c>(
            [Select d.Week__r.Sunday_End_Time__c, d.Week__r.Saturday_End_Time__c, 
            d.Week__r.Friday_End_Time__c, d.Week__r.Thursday_End_Time__c, 
            d.Week__r.Wednesday_End_Time__c, d.Week__r.Tuesday_End_Time__c,
             d.Week__r.Monday_End_Time__c, d.Week__r.Sunday_Start_Time__c, 
             d.Week__r.Saturday_Start_Time__c, d.Week__r.Friday_Start_Time__c, 
             d.Week__r.Thursday_Start_Time__c, d.Week__r.Wednesday_Start_Time__c, 
             d.Week__r.Tuesday_Start_Time__c, d.Week__r.Monday_Start_Time__c, 
             d.Week__c, d.Week__r.Employee__c , record_Type__c, Start__c, End__c         
             From Diary_Entry__c d where Id in :diaryEntIdSet]);
        //and find out which are pool diaries
        Set<Id> employeeIdSet = new Set<Id>();
        for(Diary_Entry__c de : diaryEntIdToDiaryEntMap.values())
        {
            employeeIdSet.add(de.Week__r.Employee__c);          
        }       
        Map<Id, Employee__c> employeeIdToEmployeeMap = new Map<Id, Employee__c>(
            [Select e.Pool_Diary__c From Employee__c e where Id in :employeeIdSet]);

        for(Search_Result__c searchResult : searchResults)
        {
            //get the week Id from the diaryEntIdToDiaryEntMap
            Id week_id;
            if(diaryEntIdToDiaryEntMap.Containskey(searchResult.Diary_Entry_ID__c))
            week_id = diaryEntIdToDiaryEntMap.get(searchResult.Diary_Entry_ID__c).week__c;
            //System.assert(week_id != null);
            if(weekIdToEmpData.containsKey(week_id))//already have data for this employee
            {
                weekIdToEmpData.get(week_id).addResult(searchResult);
                // CHI Phase III CR's - CR-004 - Starts
                weekIdToEmpData.get(week_id).mainEndTime = searchResult.End_Date_Time__c;
                // CHI Phase III CR's - CR-004 - Ends
            }
            else//need a new perEmployeeData object
            {
                Id emp_id = diaryEntIdToDiaryEntMap.get(searchResult.Diary_Entry_ID__c).Week__r.Employee__c;
                Boolean isPool = employeeIdToEmployeeMap.get(emp_id).Pool_Diary__c;
                system.debug('Before End Time -->'+searchResult.End_Date_Time__c);
                PerEmployeeData empData = new PerEmployeeData(week_id, 
                    searchResult.Start_Date_Time__c, searchResult.End_Date_Time__c, 
                    isPool, 
                    diaryEntIdToDiaryEntMap.get(searchResult.Diary_Entry_ID__c));
                empData.addResult(searchResult);
                weekIdToEmpData.put(week_id, empData);
            }           
        }
        Map<String, Boolean> doubleHandedOrNot = findDoubleHanded(searchResults);
        //now have a complete map of perEmployeeData, so need to generate the perSkillData
        for(Id weekId : weekIdToEmpData.keySet())
        {
            weekIdToEmpData.get(weekId).generateSkills(doubleHandedOrNot);
        }
        //now the skill data is all set up we can generate the entryDetails needed by the booking code
        List<WeekManager.EntryDetails> allEntryDetails = new List<WeekManager.EntryDetails>();
        //for each employee
        for(Id weekId : weekIdToEmpData.keySet())
        {
            PerEmployeeData empD = weekIdToEmpData.get(weekId);
            //for each 'per skill data'
            for(PerSkillData skillD : empD.getSkills())
            {
                WeekManager.EntryDetails entryD;
                if(skillD.skill == 'Travel Time') 
                {
                     entryD = new WeekManager.EntryDetails(myJobId, 
                                    null, weekId, 
                                    skillD.hours, skillD.startTime, skillD.endTime,
                                    skillD.skill, WeekManager.ENTRY_RECTYPE_BOOKING,
                                    skillD.overBookedHours,skillD.TravelJobId);
                }else
                {
                    entryD = new WeekManager.EntryDetails(myJobId, 
                                    null, weekId, 
                                    skillD.hours, skillD.startTime, skillD.endTime,
                                    skillD.skill, WeekManager.ENTRY_RECTYPE_BOOKING,
                                    skillD.overBookedHours);
                }                    
                allEntryDetails.add(entryD);
            }
        }
        
        //now actually plan the job
        planOrReplanJob(allEntryDetails, false);
        if(chiLeadId!=null &&  mainInstallerPayNum !=null)
        {
            cls_IsRun.generalTriggerSwitch = true;
            update (new Opportunity(id =chiLeadId, Installer__c = mainInstallerPayNum) );
        }
    }
    
    public static void planOrReplanJob(List<WeekManager.EntryDetails> entriesDetails) {
        planOrReplanJob(entriesDetails, true);
    }
    
    /**************************************************************************
    * method name:  planOrReplanJob
    * purpose:      This is an alternative to the main plan or replan above.
    *               This is used when the job is being replanned because some
    *               hours have been moved from one Employee to another.
    *               It is also used by the main plan or replan above once it
    *               has created the WeekManager.EntryDetails objects from the
    *               search results provided by the search black box
    * return:       void
    * parameter(s): List<WeekManager.EntryDetails> entriesDetails
    *               A list of details about an entry, see week manager class for
    *               details of the parameters required to construct a 
    *               EntryDetails object
    * exception(s): BookingException
    *
    **************************************************************************/
    public static void planOrReplanJob(List<WeekManager.EntryDetails> entriesDetails, Boolean calcHours)
    {
        ID jobID = null;
        try
        {
            jobID = entriesDetails[0].jobId;
        }
        catch(Exception e)
        {
            throw new BookingException('Job ID provided ('+ jobID +') is invalid or empty list sent to plan or replan job method. ' + e);
        }
        Job__c job;
        try
        {
            job = [Select j.Sub_Status__c, j.Status__c, j.Quote__c, j.Id, j.addExtraLogging__c From Job__c j where j.Id = : jobId];
        }
        catch(Exception e)
        {
            throw new BookingException('Job ID provided ('+ jobID +') is invalid' + e);
        }
        List<Diary_Entry__c> numDiaryEnts = [Select Id, Record_Type__c From Diary_Entry__c d where Job__r.Id = :jobID limit 1];
        Boolean isReplan = false;
        if(numDiaryEnts.size() > 0) //it is a rebooking
        {
            //if we are replanning we list the employees who were previously
            //due to complete the job
            job.previous_resources__c = generateEmployeeDetails(jobID);
            //then replan the job
            replanJob(entriesDetails, jobID, calcHours, job.addExtraLogging__c);
            isReplan = true;
        }
        else
        {
            planJob(entriesDetails, calcHours);
        }
        //now update the statuses on the job
        
        
        Boolean noQuote = false;
        if(job.quote__c == null){noQuote = true;}
        //if there is no quote from BigMachines yet then this is called 'allocation'
        //the job status will be Allocated - Awaiting Quote
        if(noQuote)
        {
            job.Status__c = 'Allocated';
            job.Sub_Status__c = 'Awaiting Quote';
            
        }
        else
        {
        //in the scenario where the quote has already been recieved from BM
        //the status will always be set to Planned. (The status may already be'Planned'
        //if this is a replan of an already planned Job
            if(job.Status__c != 'Planned')
            {
                job.Status__c = 'Planned';
                job.Sub_Status__c = 'Planned';
                //as this is the first time we are going to planned status
                //we need a job booking history for the interface
                Job_Booking_History__c jbh = new Job_Booking_History__c(
                    Work_Affected__c = true, Materials_Affected__c = true, Job__c = job.id);
                
                // DEFECT XXX
                // Rather than insert JBH, call handleJBH method instead. 
                //insert jbh;
                handleJBH(jbh);
            } else if(isReplan && job.Status__c == 'Planned') {
                // Defect XXX
                // Need a JBH if there has been a replan. Code above won't fire when a replan takes place
                Job_Booking_History__c jbh = new Job_Booking_History__c(
                    Work_Affected__c = true, Job__c = job.id);
                handleJBH(jbh);
                isReplan = false;
            }
        }
        //add the installation date to the job
        Datetime earliestDateTime;
        //need to find the possible new earliest date
        for(WeekManager.EntryDetails detail : entriesDetails)
        {
            if(earliestDateTime == null || earliestDateTime > detail.startTime)
            {
                earliestDateTime = detail.startTime;
            }   
        }
        //now convert to a date
        Date earliestDate = Date.newinstance(earliestDateTime.year(), earliestDateTime.month(), earliestDateTime.day());
        // This is a fix to send out correst email to customer on job planning. First update used to send 
        // previously the alerts but there was a bug it used to send old Insatllation date. So from this change 
        // This bug will be fixed. And this is used in Workflow
        job.Sent_text_to_customer__c = true;
        job.Date_Planned__c = system.today();
        //set the installation date on the job
        job.installation_date__c = earliestDate;
        
                 
        update job; 
        
        //if we are planning or replanning (and not allocating)
        //we must add the supplier details to the job elements
        if(!noQuote)//i.e. there is a quote
        {
            stampSupplierDetails(job);
        }
        
    }
    
    /**************************************************************************
    * method name:  suspendJob
    * purpose:      remove the job bookings for a job
    *               The status is set by code (elsewhere) calling this method
    * return:       void
    * parameter(s): Id Job - the id of the job that is being cancelled
    *               
    * exception(s): BookingException
    *
    **************************************************************************/
    //input will actually be resultoption objects
    public static void suspendJob(Id jobId)
    {
        //if we are suspending we list the employees who were previously
        //due to complete the job
        List<Job__c> jobs = [select previous_resources__c, sub_status__c, suspension_Reason__c from job__c where id = :jobId];
        if(jobs.size() != 1)
        {
            throw new BookingException('The job id provided (' + jobId + ') for suspend action is not valid');
        }
        suspendJob(jobs[0]);
        
        
    }
    
    public static void suspendJob(Job__c job){
        //list of diary entries for the specified job
        List<Diary_Entry__c> jobEntries = new List<Diary_Entry__c>([Select d.Week__c, d.Start__c, d.Record_Type__c, d.RecordTypeId, d.Job__c, d.End__c, Hours__c From Diary_Entry__c d where job__c = :job.Id or Travel_Job__c =: job.Id]);
        
        removeMultipleDiaryEntries(jobEntries, false);
    }
    /*End of Public Methods~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    
    /*Start of Private Methods (Helpers to this Class)~~~~~~~~~~~~~~~~~~~~~~~*/         
    //helper method to find out which skills are double handed
    private static Map<String, Boolean> findDoubleHanded(List<Search_Result__c> searchResults)
    {
        Map<String, Boolean> skillToDoubleHandedMap = new Map<String, Boolean>();
        for(Search_Result__c searchResult : searchResults)
        {
            //if a skills appears more than once in the results it is double handed
            if(skillToDoubleHandedMap.containsKey(searchResult.Skill__c))
            {
                skillToDoubleHandedMap.put(searchResult.Skill__c, true);
            }
            else
            {
                skillToDoubleHandedMap.put(searchResult.Skill__c, false);
            }
        }
        return skillToDoubleHandedMap;
    }
    
    

    
    //returns a string of details of employees on a job e.g.
    /*
    -- Replan 01/12/2009 10:46 --
 
    Previous Resources:
     
    John Smith 10456  Brittish Gas Services
    Peter Fry 22882  Brittish Gas Services
    David Gray C07327383  Atlas Electricals ltd.
    */
    public static string generateEmployeeDetails(Id jobId)
    {
        //get the diary entries on the job which gives the employee ids
        List<Diary_Entry__c> dEsOnJob = new List<Diary_Entry__c>(
            [Select d.Week__r.Employee__c, d.Week__c, d.Job__c, d.Record_Type__c 
            From Diary_Entry__c d where d.Job__c = :jobId]);
        //create a set of unique employee ids
        Set<Id> empIds = new Set<Id>();
        for(Diary_Entry__c deOnJob : dEsOnJob)
        {
            empIds.add(deOnJob.Week__r.Employee__c);
        }
        //use the set of employee ids to find out more about the employees
        List<Employee__c> emps = new List<Employee__c>([
            Select e.Supplier__r.Name, e.Supplier__c, e.Last_Name__c, 
            e.First_Name__c From Employee__c e where e.Id in :empIds]);
        //now create the string that we are interested
        String result = '';
        Datetime now = System.now();
        result += '-- Replan '+ now.day() + '/' + now.month() + '/' + now.year() + ' ' + now.hour() + ':' + now.minute() +' --\n\n';
        result += 'Previous Resources:\n\n';
        for(Employee__c emp : emps)
        {
            result += emp.First_Name__c + ' ' + emp.Last_Name__c + ' ' + emp.Supplier__r.Name + '\n';
        }
        return result;
    }
    
    //updates the job elements with suppliers added and creates job booking history
    //if the suppliers have changed
    private static void stampSupplierDetails(Job__c job)
    {
        //private static List<Job_Element__c> stampSupplierDetails(Job__c job)
        
        Map<String,Diary_Entry__c> skillToDiaryEntryMap = new Map<String,Diary_Entry__c>();
        Map<ID,Employee__c> idToEployeeSupplierInfoMap = new Map<ID,Employee__c>();
        List<Job__c> jobs = new List<Job__c>();
        jobs.add(job);
        QuoteProductDecompile.populateDiaryEntryAndSupplierMaps(skillToDiaryEntryMap, idToEployeeSupplierInfoMap, jobs);
        
//      system.debug(LoggingLevel.INFO, 'skillToDiaryEntryMap' + skillToDiaryEntryMap);
//      system.debug(LoggingLevel.INFO, 'idToEployeeSupplierInfoMap' + idToEployeeSupplierInfoMap);
        List<Id> empIds = new List<Id>(idToEployeeSupplierInfoMap.keySet());
        //System.debug(idToEployeeSupplierInfoMap.get(empIds[0]).Supplier__r.Supplier_Num__c);
        
        Map<String, Employee__c> skillToSupplierIntoMap = new Map<String, Employee__c>();
        //for every skill, find the supplier
        List<String> skills = new List<String>(skillToDiaryEntryMap.keySet());
        for(String skill : skills)
        {
            Diary_Entry__c dEWithEmpInfo = skillToDiaryEntryMap.get(skill);
            Id empId = dEWithEmpInfo.Week__r.Employee__c;
            Employee__c emp = idToEployeeSupplierInfoMap.get(empId);
            skillToSupplierIntoMap.put(skill, emp);
        }
        
/*      String interstingInfo = 'all skill suppliers are: \n';
        for(String skill : skills)
        {
            interstingInfo += 'Skill: ' + skill + '\n';
            interstingInfo += 'Supplier Name: ' + skillToSupplierIntoMap.get(skill).Supplier__r.Name + '\n';
            interstingInfo += 'Supplier No. : ' + skillToSupplierIntoMap.get(skill).Supplier__r.Supplier_Num__c + '\n';         
        }
        System.debug(interstingInfo);
*/      
        //now have a map of skills to supplier so need to update the job elements
        //get all of the related job elements
        List<Job_Element__c> jobEls = new List<Job_Element__c>(
            [Select j.Skill__c, j.Job__c, j.Id, j.Current_Supplier__c, 
            j.Current_Supplier_Number__c From Job_Element__c j 
            where j.Job__c = :job.Id and j.type__c = 'Work' and Sub_Status__c != 'Returned']);
//      if(jobEls.size() < 1)
//      {
//          throw new BookingException('Error while writing supplier to Job Elements. There are no active job elements on the Job (id: ' + Job.Id + ')');
//      }
        //there are 2 main scenarios, 1) we are planning or doing an ASP 2) We are replanning...
        //if any have a new supplier, we will need to write a job booking history
        Boolean foundNewSupplier = false;
        for(Job_Element__c jobEl :jobEls)
        {
    
            String thisSkill = '';
            // brm - 12-01-2010 - Added try catch to pick up on supplier/skill error
            try
            {
                thisSkill = jobEl.skill__c.toLowerCase();
                System.debug(thisSkill);    
                if(skillToSupplierIntoMap.get(thisSkill) == null || skillToSupplierIntoMap.get(thisSkill).Supplier__c == null) {
                    continue;       
                }
                //if the job element doesn't have any supplier info, this is 1) Planning or an ASP
                if(jobEl.Current_Supplier__c == null)
                {
                    jobEl.Current_Supplier__c = skillToSupplierIntoMap.get(thisSkill).Supplier__r.Name;
                    jobEl.Current_Supplier_Number__c = skillToSupplierIntoMap.get(thisSkill).Supplier__r.Supplier_Num__c;
                }
                //else we are 2) replanning so we set some statuses and update new suplier info instead
                else
                {
//                  system.debug(LoggingLevel.INFO, 'jobEl.Current_Supplier__c != skillToSupplierIntoMap.get(thisSkill).Supplier__r.Name');
//                  System.debug(jobEl.Current_Supplier__c + '!=' + skillToSupplierIntoMap.get(thisSkill).Supplier__r.Name);
                    if(jobEl.Current_Supplier__c != skillToSupplierIntoMap.get(thisSkill).Supplier__r.Name) //different supplier
                    {
                        foundNewSupplier = true;
                        //new supplier
                        jobEl.New_Supplier__c = skillToSupplierIntoMap.get(thisSkill).Supplier__r.Name;
                        jobEl.New_Supplier_Number__c = skillToSupplierIntoMap.get(thisSkill).Supplier__r.Supplier_Num__c;
                        //set status
                        jobEl.Sub_Status__c = 'Awaiting Order';
                    }//else supplier details are ok so do nothing
                }
            }
            catch (Exception e)
            {
                throw new BookingException('Cannot find a supplier on this job for the skill ' + thisSkill);
            }       
        }
        
        //now update the job elements with the supplier info
        update jobEls;
        
        //if any have a new supplier, we will need to write a job booking history
        if(foundNewSupplier)
        {
            Job_Booking_History__c jbh = new Job_Booking_History__c(Job__c = job.Id, Work_Affected__c = true);
            // DEFECT XXX
            // Rather than insert JBH, call handleJBH method instead. 
            //insert jbh;
            handleJBH(jbh);
        }
    }
    

    
    /**************************************************************************
    * method name:  replanJob
    * purpose:      remove changed diary entries of a job and replace with new ones
    * return:       void
    * parameter(s): entriesDetails - details of the new entries to be created
    *               Id jobId - id of the job being replanned
    * exception(s):
    *
    **************************************************************************/
    private static void replanJob(List<WeekManager.EntryDetails> entriesDetails,
                            Id jobId, Boolean calcHours, Boolean addExtraLogging)
    {
        //list of all of the entries on the job
        List<Diary_Entry__c> allEntsOnJob = new List<Diary_Entry__c>(
                    [Select d.Week__c, d.Name, d.Sub_Type__c, d.Start__c, d.record_Type__c,
                    d.RecordTypeId, d.Job__c, d.Hours__c, d.End__c, d.Overbooked_Hours__c 
                    From Diary_Entry__c d where Job__c = :jobId or Travel_Job__c=:jobId]
                    );
//      system.debug(LoggingLevel.INFO, ':)allEntsOnJob: ' + allEntsOnJob);
        //weeks and their weekManagers affected by the replan
        Map<Id, WeekManager> weekIdtoWeekMgrMap = new Map<Id, WeekManager>();
        //weeks and their associated entry details
        Map<Id, List<WeekManager.EntryDetails>> weekIdtoEntryDetailsMap = new Map<Id, List<WeekManager.EntryDetails>>();
        //entries that need to change as a result of the replan
        List<Diary_Entry__c> entriesNeedChange = new List<Diary_Entry__c>();
        //new details of entries that need to be created
        List<WeekManager.EntryDetails> detailsNeedCreate = new List<WeekManager.EntryDetails>();
        //details not needed because the diary entry will not change
        List<WeekManager.EntryDetails> detailsNotNeeded = new List<WeekManager.EntryDetails>();
        //have the search result details been matched against an existing diary entry?
        Map<Id, List<Diary_Entry__c>> entriesToChangeByWeek = new Map<Id, List<Diary_Entry__c>>();
        
        Boolean foundDetails;
        //for each diary entry on the job
        for(Diary_Entry__c existingEntry : allEntsOnJob)
        {
            foundDetails = false;
            //see if the diary entry needs to change
            for(WeekManager.EntryDetails entryDetail : entriesDetails)
            {
//              system.debug(LoggingLevel.INFO, 'entryDetail.endTime == existingEntry.End__c' + entryDetail.endTime + ' ' + existingEntry.End__c);
//              system.debug(LoggingLevel.INFO, 'entryDetail.skill == existingEntry.Sub_Type__c' + entryDetail.skill + ' ' +  existingEntry.Sub_Type__c);
//              system.debug(LoggingLevel.INFO, 'entryDetail.startTime == existingEntry.Start__c' + entryDetail.startTime + ' ' +  existingEntry.Start__c);
//              system.debug(LoggingLevel.INFO, 'entryDetail.week == existingEntry.Week__c' + entryDetail.week + ' ' +  existingEntry.Week__c);
                        
                system.debug(LoggingLevel.INFO, 'ExistingEntry Details:' + existingEntry.Start__c + ' ' + existingEntry.End__c + ' ' + existingEntry.Week__c);
                system.debug(LoggingLevel.INFO, 'ExistingEntry Details:' + entryDetail.startTime + ' ' + entryDetail.endTime + ' ' + entryDetail.skill);
                system.debug('***entryDetail.skill***'+entryDetail.skill+''+existingEntry.Sub_Type__c);
                system.debug('***entryDetail.week***'+entryDetail.week+''+existingEntry.Week__c);
                //try to find a matching entry and entry details
                //overBookedHours condition added as part of PRB00026805 fix 
                if(entryDetail.endTime == existingEntry.End__c &&
                        entryDetail.skill == existingEntry.Sub_Type__c &&
                        entryDetail.startTime == existingEntry.Start__c &&
                        entryDetail.week == existingEntry.Week__c &&
                        entryDetail.overBookedHours == existingEntry.Overbooked_Hours__c) 
                {
                    system.debug(LoggingLevel.INFO, 'This entry is already present on this job and doesnt need amendments' + '');
                    detailsNotNeeded.add(entryDetail);//don't need to check this detail record again
                    foundDetails = true;
                    break;
                }
            }
            //add to a list of entries that need to change
            if(!foundDetails)
            {
                entriesNeedChange.add(existingEntry);
            }
            
        }
//      system.debug(LoggingLevel.INFO, 'entriesNeedChange' + entriesNeedChange);
        Boolean foundNotNeeded;
        //add new details to a list of entries that need to be created
        for(WeekManager.EntryDetails fullListItem : entriesDetails)
        {
            foundNotNeeded = false;
            for(WeekManager.EntryDetails detailNotNeeded : detailsNotNeeded)
            {
                if(fullListItem == detailNotNeeded)
                {
                    foundNotNeeded = true;
                    break;
                }
            }
            if(!foundNotNeeded)//the fullListItem is not one that we dont need
            {
                System.debug(LoggingLevel.INFO, 'fullListItem: ' + fullListItem);
                detailsNeedCreate.add(fullListItem);
            }
        }
//      system.debug(LoggingLevel.INFO, 'detailsNeedCreate' + detailsNeedCreate);
        //group the entries that need to change by week
        for(Diary_Entry__c changeEnt : entriesNeedChange)
        {
            if(entriesToChangeByWeek.containsKey(changeEnt.week__c))
            {
                entriesToChangeByWeek.get(changeEnt.week__c).add(changeEnt);
            }
            else
            {
                List<Diary_Entry__c> entList = new List<Diary_Entry__c>();
                entList.add(changeEnt);
                entriesToChangeByWeek.put(changeEnt.week__c, entList);
            }
        }
        //query to get all diary entries for every week obtained above
        Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>();
        allEntriesByWeek = getDiaryEntryDataForWeeks(entriesToChangeByWeek.keySet());
        Integer count = 1;
        //for all of the weeks that need to change
        for(Id weekId : entriesToChangeByWeek.keySet())
        {
            Week__c week = allEntriesByWeek.get(weekId);
            //create a week manager and add it to a map
            WeekManager wm = new WeekManager(weekId, week.Diary_Entries__r, week);
            weekIdtoWeekMgrMap.put(weekId, wm);
            //remove the entries from the week
            if(addExtraLogging){
            addDiaryEntryLogging(entriesToChangeByWeek.get(weekId),count);
            count++;    
            }
            wm.removeEntry(entriesToChangeByWeek.get(weekId));
//          system.debug(LoggingLevel.INFO, 'entries that need changing ^&&^: ' + entriesToChangeByWeek.get(weekId));
        }
        
    
        //group the new details of entries that need to be created by week
        for(WeekManager.EntryDetails detailNeedCreate : detailsNeedCreate)
        {
            if(weekIdtoEntryDetailsMap.containsKey(detailNeedCreate.week))
            {
                weekIdtoEntryDetailsMap.get(detailNeedCreate.week).add(detailNeedCreate);
            }
            else
            {
                List<WeekManager.EntryDetails> detList = new List<WeekManager.EntryDetails>();
                detList.add(detailNeedCreate);
                weekIdtoEntryDetailsMap.put(detailNeedCreate.week, detList);
            }
        }
        //query for all of the diary entries for new weeks
        Map<Id, Week__c> allEntriesByWeek2 = new Map<Id, Week__c>();
        allEntriesByWeek2 = getDiaryEntryDataForWeeks(weekIdtoEntryDetailsMap.keySet());
        count = 1;
        //for all of the new details of entries that need to be created
        for(Id weekID : weekIdtoEntryDetailsMap.keySet())
        {
            WeekManager wm;
            //create a week manager and add it to a map if it does not yet exist
            if(!weekIdtoWeekMgrMap.containsKey(weekID))
            {
                Week__c week = allEntriesByWeek2.get(weekId);
                //create a week manager and add it to a map
                wm = new WeekManager(weekId, week.Diary_Entries__r, week);
                weekIdtoWeekMgrMap.put(weekId, wm);
            }
            else //if the week manager already exists
            {
                wm = weekIdtoWeekMgrMap.get(weekId);
            }
            //create the job bookings for the week
            // added this condition to check whether extra logging is requested
            if(addExtraLogging){    
                  addWeekManagerLogging(wm,count);
                  addEntryDetialsLogging(weekIdtoEntryDetailsMap.get(weekId),count);
                  count++;
                }
            wm.createEntry(weekIdtoEntryDetailsMap.get(weekId));
        }
        //lists to hold the data to be updated / deleted
        List<Diary_Entry__c> allDeletions = new List<Diary_Entry__c>();
        List<Diary_Entry__c> allUpserts = new List<Diary_Entry__c>();       
        //for each week manager
        for(Id weekMgrRef : weekIdtoWeekMgrMap.keySet())
        {
            //system.debug(LoggingLevel.INFO, 'entries for deletion on the week ' + weekMgrRef);
            //outputWeeksEntries(weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesForDeletion());
            //outputWeeksEntries(weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesList());
            //delete weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesForDeletion();
            //upsert weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesList();  
                    
            //add all of the modified / new entries to a list
            allUpserts.addAll(weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesList(calcHours));
            //add all of the deleted entries to a list
            allDeletions.addAll(weekIdtoWeekMgrMap.get(weekMgrRef).getWeeksEntriesForDeletion());
        }
        
//      for(Diary_Entry__c de : allUpserts)
//          system.debug(LoggingLevel.INFO, 'JBM.upserts:' + de);
        
//      system.debug(LoggingLevel.INFO, 'JBM.deletions 1:' + allDeletions);
        //get rid of any deleted entries that were never actually inserted into teh DB
        allDeletions = removeDummyDelsAndUnavs(allDeletions);
//      system.debug(LoggingLevel.INFO, 'JBM.deletions 2:' + allDeletions);
        //do the DML
        delete allDeletions;
        upsert new list<Diary_Entry__c>(new SET<Diary_Entry__c>(allUpserts));
        //update weeks for pool diaries

        //weeksList is list of weeks that have had a week manager created for them
        List<Week__c> weeksList = new List<Week__c>();
        for(WeekManager modWm : weekIdtoWeekMgrMap.values())
        {
            weeksList.add(modWm.getWeek());
        }       
    
//      system.debug(LoggingLevel.INFO, 'Weeks involved in replan: \n' + weeksList);                        
        
        update weeksList;       
    }   

    private static void planJob(List<WeekManager.EntryDetails> entriesDetails) {
        planJob(entriesDetails, true);
    }

    /**************************************************************************
    * method name:  planJob
    * purpose:      given job details create the required diary entries
    * return:       void
    * parameter(s): Id Job - the id of the job that is being booked
    *               Integer resultID - an arbitrary number representing a
    *               particular result from a result set
    *               Datetime searchTime - this in combination with resultId
    *               will identify a particular option from a set of results
    * exception(s):
    *
    **************************************************************************/
    //input will actually be resultoption objects
    private static void planJob(List<WeekManager.EntryDetails> entriesDetails, Boolean calcHours)
    {
        //map to hold the list of entry details for each week
        Map<Id, List<WeekManager.EntryDetails>> newEntDetailsByWeek = new Map<Id, List<WeekManager.EntryDetails>>();
        //map to hold the list of all diary entries for each week
        //Map<Id, List<Diary_Entry__c>> allEntriesByWeek = new Map<Id, List<Diary_Entry__c>>();
        
        //group the result data by week
        for(WeekManager.EntryDetails entDet : entriesDetails)
        {
            if(newEntDetailsByWeek.containsKey(entDet.week))
            {
                newEntDetailsByWeek.get(entDet.week).add(entDet);
            }
            else
            {
                List<WeekManager.EntryDetails> entDetails = new List<WeekManager.EntryDetails>();
                entDetails.add(entDet);
                newEntDetailsByWeek.put(entDet.week, entDetails);
            }
        }

        //query to get all diary entries for every week obtained above
        Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>();
        allEntriesByWeek = getDiaryEntryDataForWeeks(newEntDetailsByWeek.keySet());

        List<Week__c> weeksList = new List<Week__c>(allEntriesByWeek.values());
        
        //lists to hold the enries for upsert and deletion
        List<Diary_Entry__c> entriesForDeletion = new List<Diary_Entry__c>();
        List<Diary_Entry__c> entriesForUpsert = new List<Diary_Entry__c>();
        
        //create a week manager for each week
        for(Id weekId : newEntDetailsByWeek.keySet())
        {
            Week__c week = allEntriesByWeek.get(weekId);
            WeekManager wm = new WeekManager(weekId, week.Diary_Entries__r, week);
            
            //create the diary entries
            wm.createEntry(newEntDetailsByWeek.get(weekId));
            //collect the list of updated / new entries
            //collect the list of entries for deletion
//          system.debug(LoggingLevel.INFO, 'in the middle');
//          outputWeeksEntries(entriesForUpsert);           
            entriesForUpsert.addAll(wm.getWeeksEntriesList(calcHours)); // Fix?
        
            entriesForDeletion.addAll(wm.getWeeksEntriesForDeletion());
        }       
        //do the DML

//      outputWeeksEntries(entriesForUpsert);
        entriesForDeletion = removeDummyDelsAndUnavs(entriesForDeletion);
        
        
        system.debug(LoggingLevel.INFO, '##entriesForDeletion :' + entriesForDeletion);
        system.debug(LoggingLevel.INFO, '##entriesForUpsert :' + entriesForUpsert);
        
        if(label.systemAdminEmail == 'on')
        CreateEmail.CretaeSendTextEmail(new list<string>{userinfo.getUserEmail()}, 'Entries For Deletion -->'+JSON.serialize(entriesForDeletion) + '              \n entriesForUpsert  :'+JSON.serialize(entriesForUpsert) ,'Job Booking Manager line : 809');
        
        entriesForUpsert =  new list<Diary_Entry__c>(new set<Diary_Entry__c>(entriesForUpsert)); 
        entriesForDeletion = new list<Diary_Entry__c>(new set<Diary_Entry__c>(entriesForDeletion));
        delete entriesForDeletion;
        upsert entriesForUpsert;
        //update the week records
        update weeksList;
    }
    
    // Overloaded method to provide way of preventing calculation of hours without
    // breaking other calls to this method. Calling this method will mean hours
    // for diary entries will be calculated. This can be overridden by calling the
    // alternative version with false as a parameter 
    public static void removeMultipleDiaryEntries(List<Diary_Entry__c> jobEntries) {
        removeMultipleDiaryEntries(jobEntries, true);
    }
    
    //This method is not designed for general use but it is public because
    //it is used by the Unavailability Manager
    // gjb 2010-02-12 updated to take a boolean
    public static void removeMultipleDiaryEntries(List<Diary_Entry__c> jobEntries, Boolean calcHours)
    {
        //map to hold the list of job bookings for each week
        Map<Id, List<Diary_Entry__c>> jobBookingsByWeek = new Map<Id, List<Diary_Entry__c>>();
        //group the jobEntries data by week
        for(Diary_Entry__c jobEntry : jobEntries)
        {
            if(jobBookingsByWeek.containsKey(jobEntry.week__c))
            {
                jobBookingsByWeek.get(jobEntry.week__c).add(jobEntry);
            }
            else
            {
                List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
                diaryEntries.add(jobEntry);
                jobBookingsByWeek.put(jobEntry.week__c, diaryEntries);
            }
        }

        //query to get all diary entries for every week obtained above
        Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>();
        allEntriesByWeek = getDiaryEntryDataForWeeks(jobBookingsByWeek.keySet());

        //lists to hold the enries for upsert and deletion
        List<Diary_Entry__c> entriesForDeletion = new List<Diary_Entry__c>();
        List<Diary_Entry__c> entriesForUpsert = new List<Diary_Entry__c>();
        
        //list of all of the weeks
        List<Week__c> weeksList = new List<Week__c>(allEntriesByWeek.values());
        
        //create a week manager for each week
        for(Id weekId : jobBookingsByWeek.keySet())
        {
            Week__c week = allEntriesByWeek.get(weekId);
            WeekManager wm = new WeekManager(weekId, week.Diary_Entries__r, week);
            
            //create the diary entries
            wm.removeEntry(jobBookingsByWeek.get(weekId));
            //collect the list of updated / new entries
            //collect the list of entries for deletion
//          system.debug(LoggingLevel.INFO, 'in the middle');
//          outputWeeksEntries(entriesForUpsert);
                
            entriesForUpsert.addAll(wm.getWeeksEntriesList(calcHours)); 
        
            entriesForDeletion.addAll(wm.getWeeksEntriesForDeletion());
//          system.debug(LoggingLevel.INFO, '##DML Rows: ' + Limits.getDMLRows() + 'Limit: ' + Limits.getLimitDMLRows());
        }       
        //do the DML
//      system.debug(LoggingLevel.INFO, '##entriesForDeletion :' + entriesForDeletion);
//      system.debug(LoggingLevel.INFO, '##entriesForUpsert :' + entriesForUpsert);
//      outputWeeksEntries(entriesForUpsert);
        //remove any uncommited entries
        //do not want to delete Unavailability records - they can only be deleted
        //by the data loader or the Unavailability deletion button      
        system.debug('intial --->'+entriesForDeletion.size() +'  ' +entriesForDeletion);
        entriesForDeletion = removeDummyDelsAndUnavs(entriesForDeletion);

        system.debug('Before --->'+entriesForDeletion.size() +'  '+entriesForDeletion); 
        
        if(label.systemAdminEmail == 'on')
        
        CreateEmail.CretaeSendTextEmail(new list<string>{userinfo.getUserEmail()}, 'Entries For Deletion -->'+JSON.serialize(entriesForDeletion) + '              \n entriesForUpsert  :'+JSON.serialize(entriesForUpsert) ,'Job Booking Manager line : 886');
        /*string s = '';
        for (Diary_Entry__c r : entriesForUpsert) s += '\n' + r;
        system.debug(s);*/
         
        entriesForUpsert =  new list<Diary_Entry__c>(new set<Diary_Entry__c>(entriesForUpsert)); 
        entriesForDeletion = new list<Diary_Entry__c>(new set<Diary_Entry__c>(entriesForDeletion));
        delete entriesForDeletion;
        upsert entriesForUpsert;
        //update the week for pool diary
        
        update weeksList;       
    } 

    //may have some entries in the deletion list that were never comitted to the DB
    //and dont want unavailability records
    private static List<Diary_Entry__c> removeDummyDelsAndUnavs (List<Diary_Entry__c> entsToDelete)
    {
        set<Id> tempSetDels = new set<Id>();
        List<Diary_Entry__c> tempDels = new List<Diary_Entry__c>();
        system.debug('before loop --->'+entsToDelete.size());
        for(Diary_Entry__c delEnt : entsToDelete)
        {
            if(delEnt.Id != null && delEnt.RecordTypeId != ENTRY_RECTYPE_UNAVAIL)
            {
                if(!tempSetDels.contains(delEnt.Id))
                {
                    tempDels.add(delEnt);
                }   tempSetDels.add(delEnt.Id);
            }
        }
        system.debug('After loop --->'+tempDels.size());
        //tempDels.addall(tempSetDels);
        return tempDels;
    }   
    
    private static void outputWeeksEntries(List<Diary_Entry__c> weeksEnts)
    {
//      string debug = '';
//      for(Diary_Entry__c ent : weeksEnts)
//      {
//          debug += '\n\n' + ent.id + '\n' + ent.Start__c + '\n' + ent.End__c + '\n';
//      }
//      System.debug(debug);
    }
    
    //these last 2 methods are public becase they are used by unavailability manager too
    public static Map<Id, Week__c> getDiaryEntryDataForWeeks(Set<Id> weekIds)
    {
        Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>(
                [Select w.Id, w.Wednesday_Booked_Hours__c, w.Tuesday_Booked_Hours__c, 
                w.Thursday_Booked_Hours__c, w.Sunday_Booked_Hours__c, w.Saturday_Booked_Hours__c, 
                w.Monday_Booked_Hours__c, w.Friday_Booked_Hours__c, 
                w.Employee__r.Pool_Diary__c,
                w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Tuesday_Start_Time__c, 
                w.Tuesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, 
                w.Sunday_Start_Time__c, w.Sunday_End_Time__c, w.Saturday_Start_Time__c, 
                w.Saturday_End_Time__c, w.Monday_Start_Time__c, w.Monday_End_Time__c, 
                w.Friday_Start_Time__c, w.Friday_End_Time__c,
                    (Select Name, RecordTypeId, Record_Type__c, Start__c, End__c, Hours__c, Sub_Type__c, Week__c From Diary_Entries__r) 
                From Week__c w where id in :weekIds]);
        
        return allEntriesByWeek;
    }
    public static Map<Id, Week__c> getDiaryEntryDataForWeeks(List<Id> weekIds)
    {
        Set<Id> setweekIds = new Set<Id>();
        setweekIds.addAll(weekIds);     
        return getDiaryEntryDataForWeeks(setweekIds);
    }
    
    // Added these methods for checking extra logs in case of any issues.
    
    public static void addWeekManagerLogging(WeekManager wm, Integer count){
        
        List<Diary_Entry__c> weeksEntriesList = wm.getWeeksEntriesList(true);
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, 'Week manager logs number: '+count+' for the week with id '+wm.weekID);
        for(Diary_Entry__c de:weeksEntriesList){
        system.debug(LoggingLevel.INFO, 'weeksEntriesList for this weekmanager record: '+de);
        }
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
    }
    
    public static void addEntryDetialsLogging(List<WeekManager.EntryDetails> entriesDetails, Integer count){
        
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, 'WeekManager EntryDetails logs number: '+count+' for the week with id '+entriesDetails[0].week);
        for(WeekManager.EntryDetails we:entriesDetails){
        system.debug(LoggingLevel.INFO, 'skill is: '+we.skill);
        system.debug(LoggingLevel.INFO, 'start time: '+we.startTime);
        system.debug(LoggingLevel.INFO, 'end time: '+we.endTime);
        system.debug(LoggingLevel.INFO, 'recordTypeId: '+we.skill);
        system.debug(LoggingLevel.INFO, 'overBookedHours: '+we.overBookedHours);
        }
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
    }
    
    public static void addDiaryEntryLogging(List<Diary_Entry__c> entries, Integer count){
        
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, 'Existing entries on job which need change: '+count+' for the week with id '+entries[0].Week__c);
        for(Diary_Entry__c de:entries){     
        system.debug(LoggingLevel.INFO, 'Entries are as below: '+de);
        }
        system.debug(LoggingLevel.INFO, '#################################');
        system.debug(LoggingLevel.INFO, '#################################');
    }
    
    /*End of Private Methods (Helpers to this Class)~~~~~~~~~~~~~~~~~~~~~~~*/   
    
    /*Exceptions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    //exception for when there is a problem planning or replanning a job
    public class BookingException extends Exception{}   

    /*Start of Private Classes (Helpers to this Class)~~~~~~~~~~~~~~~~~~~~~*/   
    //private classes used in conversion 
    private class PerEmployeeData
    {
        public Id week_id;
        public Datetime mainStartTime;
        public Datetime mainEndTime;
        public Boolean isPoolDiary;
        private Diary_Entry__c relatedEntry; //related entry to use for shift pattern
        private List<perSkillData> skills = new List<perSkillData>();
        List<Search_Result__c> resultOptions = new List<Search_Result__c>();
        private boolean isOverBooked = false; //is the employee overbooked?
        
        public PerEmployeeData(Id week_id, Datetime startTime, Datetime endTime, Boolean isPoolDiary, Diary_Entry__c relatedEntry)
        {
            this.week_id = week_id;
            this.mainStartTime = startTime;
            this.mainEndTime = endTime;
            this.isPoolDiary = isPoolDiary;
            this.relatedEntry = relatedEntry;
            system.debug('In the Inner Class -->'+endTime+' '+mainEndTime);
        }
        
        public void addResult(Search_Result__c sRes)
        {
            resultOptions.add(sRes);
        }
        public List<perSkillData> getSkills()
        {
            return skills;
        }
        public void generateSkills(Map<String, Boolean> skillToDoubleHandedMap)
        {
            //sanity check that there are some skills to generate
            if(resultOptions.size() < 1)
            {
                throw new BookingException('Internal Error. Trying to generate skills when there are none to generate');
            }
            //check the end time, if it is not as expected
            //then the search may have used 'overbooked hours' which is where
            //a 'tolerance' is used to say that although a job doesn't fit in a gap, we put
            //it there anyway if it 'almost' fits e.g. it would fit if the gap was 0.5 hours longer
            //if there are overbooked hours, the calcultedEnd will be later than the givenEndTime
            //the givenEndTime however should never be later than the calcultedEnd
            
            Double totalHoursToBook = 0.0;
            //first work out the total hours being booked to this employee
            for(Search_Result__c resultOpt : resultOptions)
            {
                totalHoursToBook += resultOpt.Hours__c;
            }
            
            Map<String,List<Double>> skillToHoursAndExtraHoursMap;
            Datetime givenEndTime = mainEndTime;
            
            
/*
    rjd - 2010-01-26 - Creating new overbooking functionality
    If I know the totalHours on the job and I know how many hours are between
    the mainStartTime and mainEndTime then the difference will be the overbooked hours...
    Bug 277
*/
            system.debug(LoggingLevel.INFO, 'calculating overbooked hours: '+totalHoursToBook+'  ,'+mainStartTime+' , '+mainEndTime);
            system.debug('relatedEntry-->'+relatedEntry);
            double obHours = totalHoursToBook - DateTimeHelper.calculateHours(mainStartTime, mainEndTime, relatedEntry);
           
          /*  if(obHours < 0|| (obHours == 0.01 && mainEndTime != relatedEntry.End__c) ) {
                system.debug(LoggingLevel.INFO, 'making an adjustment to overbooked hours...');
                obHours = 0;
            } */
            
            //PRB00024926 fix starts
            
            if(obHours < 0 ) {
                system.debug(LoggingLevel.INFO, 'making an adjustment to overbooked hours...');
                obHours = 0;
            }
            //PRB00024926 fix ends
            
            system.debug(LoggingLevel.INFO, 'overbooked hours: '+obHours);
            
            
//          system.debug(LoggingLevel.INFO, 'calcultedEnd: ' + mainStartTime+','+ totalHoursToBook +','+ relatedEntry);
//          Datetime calcultedEnd = DatetimeHelper.addWorkingHoursToDateTime(mainStartTime, totalHoursToBook, relatedEntry);
//          system.debug(LoggingLevel.INFO, 'givenEndTime: ' + givenEndTime);
//          system.debug(LoggingLevel.INFO, 'calcultedEnd: ' + calcultedEnd);
            if((obHours > 0) && !isPoolDiary)//may be overbooked hours
            {
//              if(DatetimeHelper.dateGreaterThan(givenEndTime, calcultedEnd))//search gave invalid data
//              {
//                  throw new bookingException('Internal Error. Search results provided an end time that does not match the specified number of hours for the job booking');
//              }
//              else//there are overbooked hours
//              {
                    isOverBooked = true;
                    //as there are overbooked hours, these need to be distributed amongst the skills
                    //build up a map of skills and a list with element 0 as hours and 1 as extra hours
                    Double overBookedHours = obHours; //DatetimeHelper.calculateHours(givenEndTime, calcultedEnd, relatedEntry);
//                  system.debug(LoggingLevel.INFO, 'overBookedHours: ' + overBookedHours);
                    skillToHoursAndExtraHoursMap = new Map<String,List<Double>>();
                    //if the overBookedHours plus half an hour is greater than totalHoursToBook (unusual situation)
                    //totalHoursToBook - overBookedHours = amount of actual space in the gap
                    //this actual space should be split evenly so that each skill has at least
                    //some value > 0.0 in the hours field
                    Double availSpace = totalHoursToBook - overBookedHours;
                    
                    //for each skill, work out the division between hours and extra hours, the
                    //extra hours will be proportionate to the original number of hours before
                    //we decided we need to make adjustments due to this being an overbooking
                    Decimal proportion = availSpace / totalHoursToBook;
                    
                    // gjb - 2010-02-18 changing how proportion is rounded. In some cases with high overbooking values and small
                    // job bookings, rounding up on the proportion causes problems, so instead, round down.
                    //proportion = proportion.setScale(2);
                    proportion = proportion.setScale(2, RoundingMode.DOWN);
                    // end gjb
                    
                    Integer numOptions = resultOptions.size();
                    Integer w = 0;
                    Double totalNewHours = 0.0;
                    Double totalExtraHours = 0.0;
                    integer t =0;
                    for(Search_Result__c resultOpt : resultOptions)
                    {
                        List<Double> hoursList = new List<Double>();
                        Double newHours;
                        Double extraHours;
                        
                        // gjb 2010-03-18 - replacing hour calculation logic
                        // There were a couple of problems with the logic as before (which is commented out below):
                        // 1. In some scenarios, when calculating hours for the last skill, a negative number could occur
                        // This was in cases where the value of "proportion" had been rounded up and the last resultOpt only
                        // has a small number of hours; as a result, more hours had accumulated in totalNewHours than there in
                        // availSpace.
                        // 2. Because the hours is multiplied by the proportion, in some cases this could result in values 
                        // less than 0.01.
                        // To solve the first problem, calculations are done after the loop (further explanation below). 
                        // To solve the second problem, any combination of hours and proportion that will result in hours less 
                        // than 0.01 are handled differently. They are assigned 0.01 hours, and the remainder of skill hours 
                        // are assigned to the overbooked hours field.
                        if(resultOpt.hours__c * proportion < 0.01) {
                            newHours = (resultOpt.hours__c == 0.01) ? 0.01 : 0.02;
                            extraHours = resultOpt.hours__c - newHours;
                        } else {
                            newHours = (proportion * resultOpt.hours__c).setScale(2);
                            extraHours = resultOpt.hours__c - newHours;
                        }
                        
                        // Commented out as explained above.
                        /*w++;
                        if(w == numOptions)//if it is the last skill, use remaining hours to avoid rounding problems
                        {
                            newHours = availSpace - totalNewHours;
                            extraHours = overBookedHours - totalExtraHours;
                        }
                        else
                        {
                            newHours = proportion * resultOpt.hours__c;
                            extraHours = resultOpt.hours__c - newHours;
                        }*/
                        // end gjb
                        
                        totalNewHours += newHours;
                        totalExtraHours += extraHours;
                        
                        hoursList.add(newHours);
                        hoursList.add(extraHours);
                        string tempSkill = resultOpt.skill__c;
                        if(tempSkill == 'Travel Time')
                        {
                            tempSkill+=string.valueof(t);
                            t++;
                        }
                        skillToHoursAndExtraHoursMap.put(tempSkill, hoursList);
                        
                        system.debug(LoggingLevel.INFO, 'proportion: ' + proportion);
                        system.debug(LoggingLevel.INFO, 'newHours: ' + newHours);
                        system.debug(LoggingLevel.INFO, 'extraHours: ' + extraHours);
                    }
                    
                    // gjb 2010-03-18 - part of the change started above.
                    // The calculations above will likely have ended in one of two situations - either too many hours have been
                    // added to the Hours across the bookings (and therefore the end time of the last booking will be incorrect)
                    // or too many have been added to the Overbooked Hours (and therefore the gap won't be entirely used).
                    // We check first to see if we have more "normal" hours, and if so, we transfer hours to overbooked hours
                    // on skill that have enough hours to cover some or all of the difference. Otherwise, we check if too few hours
                    // have been assigned and if so, transfer hours from skills that have enough overbooked hours to
                    // cover some or all of the difference.
                    Decimal difference = 0;
                    if(totalNewHours > availSpace) {
                        // More "normal" hours have been added than there is available space, adjust one set of values to move
                        // some of these hours into the overbooking field
                        difference = totalNewHours - availSpace;
                        t =0;
                        for(String skill : skillToHoursAndExtraHoursMap.keySet()) {
                            List<Double> hoursAndExtraHours = skillToHoursAndExtraHoursMap.get(skill); 
                            
                            Double amountToSwap = 0;
                            if(hoursAndExtraHours[0] >= difference + 0.02) {
                                amountToSwap = difference;
                            } else if(hoursAndExtraHours[0] < difference && hoursAndExtraHours[0] > 0) {
                                amountToSwap = hoursAndExtraHours[0] - 0.02;
                            }
                            
                            List<Double> newValues = new List<Double> { hoursAndExtraHours[0] - amountToSwap, 
                                                                        hoursAndExtraHours[1] + amountToSwap};
                            // Now put the values back into the map
                            skillToHoursAndExtraHoursMap.put(skill, newValues);
                            
                            difference -= amountToSwap;
                            if(difference == 0)
                                break;

                        }
                    } else if(totalNewHours < availSpace) {
                        // Too many hours have been put into overbooked and the "normal" hours do not fill the gap, move some
                        // of the overbooked hours onto the "normal" hours field.
                        difference = availSpace - totalNewHours;
                        
                        for(String skill : skillToHoursAndExtraHoursMap.keySet()) {
                            List<Double> hoursAndExtraHours = skillToHoursAndExtraHoursMap.get(skill);
                            if(hoursAndExtraHours[1] <= 0)
                                continue;
                            
                            Double amountToSwap = (hoursAndExtraHours[1] >= difference) ? difference : hoursAndExtraHours[1];
                            
                            List<Double> newValues = new List<Double> { hoursAndExtraHours[0] + amountToSwap, 
                                                                        hoursAndExtraHours[1] - amountToSwap};
                            // Now put the values back into the map
                            skillToHoursAndExtraHoursMap.put(skill, newValues);
                            
                            difference -= amountToSwap;
                            if(difference == 0)
                                break;
                        }
                    }
                    system.debug('skillToHoursAndExtraHoursMap-->'+skillToHoursAndExtraHoursMap);
                    // end gjb
                }
//          }
            
            //result options need to be in the correct order: Mechanical, PowerFlush, Alphabetical Double Handed Skills, Alphabetcal other Skills
            orderResultOptions(skillToDoubleHandedMap);
                    
            //now the options are in order
            Datetime skillStart = mainStartTime;
            Datetime skillEnd;
            double skillHoursSum = 0.0;
            integer t=0;
            for(Search_Result__c resultOpt : resultOptions)
            {
                //the end time will be the current start time plus hours (taking shift pattern into account)
                //except for pool diary where each skill starts and ends at the same time
                PerSkillData pSkD;
                if(isPoolDiary)
                {
                    pSkD = new PerSkillData(mainStartTime, mainEndTime, resultOpt.Skill__c, resultOpt.Hours__c, skillToDoubleHandedMap.get(resultOpt.Skill__c));
                }
                else
                {
                    if(isOverBooked)//if overbooked the hours will be split between hours__c and extra hours
                    {
                        string tempSkill = resultOpt.skill__c;
                        if(tempSkill == 'Travel Time')
                        {
                            tempSkill+=string.valueof(t);
                            t++;
                        }
                        
                        Double adjustedHours = skillToHoursAndExtraHoursMap.get(tempSkill)[0];
                        Double extraHours = skillToHoursAndExtraHoursMap.get(tempSkill)[1];
 system.debug(LoggingLevel.INFO, 'Adjusted hours : '+adjustedHours+'### Extra hours : '+extraHours);
 system.debug(LoggingLevel.INFO, 'skillStart : '+skillStart+'### related entry' + relatedEntry);
                        skillHoursSum += adjustedHours;
                        //skillEnd = DatetimeHelper.addWorkingHoursToDateTime(skillStart, adjustedHours, relatedEntry);
                        skillEnd = DatetimeHelper.addWorkingHoursToDateTime(mainStartTime, skillHoursSum, relatedEntry);
 system.debug(LoggingLevel.INFO, 'skillHoursSum : '+skillHoursSum+'### skillEnd' + skillEnd);                       
                        system.debug(LoggingLevel.INFO, 'GB: ' + resultOpt.Skill__c);
                        system.debug(LoggingLevel.INFO, 'GB: ' + resultOpt.Hours__c);
                        if(resultOpt.skill__c == 'Travel Time')
                        {
                            pSkD = new PerSkillData(skillStart, skillEnd, resultOpt.Skill__c, adjustedHours, skillToDoubleHandedMap.get(resultOpt.Skill__c), extraHours, resultOpt.Travel_Job__c);
                        }else
                        {
                            pSkD = new PerSkillData(skillStart, skillEnd, resultOpt.Skill__c, adjustedHours, skillToDoubleHandedMap.get(resultOpt.Skill__c), extraHours);
                        }                   
                    }
                    else
                    {
                        skillHoursSum += resultOpt.Hours__c;
                        //skillEnd = DatetimeHelper.addWorkingHoursToDateTime(skillStart, resultOpt.Hours__c, relatedEntry);
                        skillEnd = DatetimeHelper.addWorkingHoursToDateTime(mainStartTime, skillHoursSum, relatedEntry);
                        /*system.debug(LoggingLevel.INFO, 'GB: ' + resultOpt.Skill__c);
                        system.debug(LoggingLevel.INFO, 'GB: ' + resultOpt.Hours__c);*/
                        if(resultOpt.skill__c == 'Travel Time')
                        {
                            pSkD = new PerSkillData(skillStart, skillEnd, resultOpt.Skill__c, resultOpt.Hours__c, skillToDoubleHandedMap.get(resultOpt.Skill__c),0.0, resultOpt.Travel_Job__c);
                        }else
                        {
                            pSkD = new PerSkillData(skillStart, skillEnd, resultOpt.Skill__c, resultOpt.Hours__c, skillToDoubleHandedMap.get(resultOpt.Skill__c));
                        }                             
                    }
                    skillStart = skillEnd;
                }
                skills.add(pSkD);
            }
//          System.debug(skills);
//          system.debug(LoggingLevel.INFO, 'skillEnd == mainEndTime ' + skillEnd + '==' + mainEndTime);
            /*
            if(!isPoolDiary)
            {
                //at the end the last skill should end at the main end time specified in the search results
                //if it is not then the search may have used 'overbooked hours' which is where
                //a 'tolerance' is used to say that although a job doesn't fit in a gap, we put
                //it there anyway if it 'almost' fits e.g. it would fit if the gap was 0.5 hours longer
                System.debug(skills);
                system.debug(LoggingLevel.INFO, 'skillEnd == mainEndTime ' + skillEnd + '==' + mainEndTime);
                if(isOverBooked)
                {
                    
                }

            }
            */
        }
        //result options need to be in the correct order: Mechanical, PowerFlush, Alphabetical Double Handed Skills, Alphabetcal other Skills
        private void orderResultOptions(Map<String, Boolean> skillToDoubleHandedMap)
        {
            // Cognizant - CHI Phase III CR-002 implementation... START
            
            List<Search_Result__c> tempResultOptions = new List<Search_Result__c>();
            
            AddNewSkill ObjNewSkill = new AddNewSkill();
            tempResultOptions = ObjNewSkill.orderResultOptions(resultOptions, skillToDoubleHandedMap, tempResultOptions);
            
            
            /*List<Search_Result__c> tempResultOptions = new List<Search_Result__c>();
            Search_Result__c firstResult;
            Search_Result__c secondResult;
            List<Search_Result__c> doubleHandedResults = new List<Search_Result__c>();
            List<Search_Result__c> otherResults = new List<Search_Result__c>();
            //categorise the results
            for(Search_Result__c resultOption : resultOptions)
            {
                if(resultOption.Skill__c == 'Mechanical')
                {
                    firstResult = resultOption;
                }
                else if(resultOption.Skill__c == 'Powerflush')
                {
                    secondResult = resultOption;
                }
                else if(skillToDoubleHandedMap.get(resultOption.Skill__c) == true)
                {
                    doubleHandedResults.add(resultOption);
                }
                else
                {
                    otherResults.add(resultOption);
                }           
            }
            
            //now put everything in the correct order
            if(firstResult != null) tempResultOptions.add(firstResult);
            if(secondResult != null) tempResultOptions.add(secondResult);           
            //put double handed and other results in alphabetical order         
            if(doubleHandedResults.size() > 0)
            {
                doubleHandedResults = makeResultsAlphabetical(doubleHandedResults);
                tempResultOptions.addAll(doubleHandedResults);
            }
            if(otherResults.size() > 0)
            {
                otherResults = makeResultsAlphabetical(otherResults);
                tempResultOptions.addAll(otherResults);
            }*/
            
            // Cognizant - CHI Phase III CR-002 implementation... END 

            this.resultOptions.clear();
            this.resultOptions = tempResultOptions;

        }
        private List<Search_Result__c> makeResultsAlphabetical(List<Search_Result__c> unorderedList)
        {
            Map<String, Search_Result__c> skillToResultMap = new Map<String, Search_Result__c>();
            List<Search_Result__c> orderedList = new List<Search_Result__c>();
            for(Search_Result__c unorderedItem : unorderedList)
            {
                skillToResultMap.put(unorderedItem.Skill__c, unorderedItem);
            }   
            List<String> skillNames = new List<String>(skillToResultMap.keySet());
            skillNames.sort();
            for(String skillName : skillNames)
            {
                orderedList.add(skillToResultMap.get(skillName));
            }
            return orderedList;
        }       
    }
    private class PerSkillData
    {
        public Datetime startTime;
        public Datetime endTime;    
        public String skill;
        public Double hours;
        public Boolean doubleHanded;
        public Double overBookedHours;
        public id TravelJobID;
        public PerSkillData( Datetime startTime, Datetime endTime, String skill, decimal hours, Boolean doubleHanded)
        {
            this.startTime = startTime;
            this.endTime = endTime;
            this.skill = skill;
            this.hours = hours;
            this.doubleHanded = doubleHanded;
            this.overBookedHours = 0.0;
        }       
        //this constructor is for when there are overbooked hours
        public PerSkillData( Datetime startTime, Datetime endTime, String skill, decimal hours, Boolean doubleHanded, decimal overBookedHours)
        {
            this.startTime = startTime;
            this.endTime = endTime;
            this.skill = skill;
            this.hours = hours;
            this.doubleHanded = doubleHanded;
            this.overBookedHours = overBookedHours;
        } 
        public PerSkillData( Datetime startTime, Datetime endTime, String skill, decimal hours, Boolean doubleHanded, decimal overBookedHours, Id TravelJobId)
        {
            this.startTime = startTime;
            this.endTime = endTime;
            this.skill = skill;
            this.hours = hours;
            this.doubleHanded = doubleHanded;
            this.overBookedHours = overBookedHours;
            this.TravelJobId = TravelJobId;
        }            
    }   
}