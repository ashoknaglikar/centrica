/* ResourceOption
    ResourceOption represents a specific resource (employee) option for a job.
    Typically, ResourceOptions are stored in JobResourcingOption - a JRO is a 
    full resourcing option for a job, where as a ResourceOption represents one
    employee on the job and, amongst other things, the skills they are 
    performing.
*/
public with sharing class ResourceOption {
    // Variables - these hold information about this resourcing option
    public ID employeeID = null;
    public DiaryEntryCollection entry = null;
    public ID neverWorksWith = null;
    public Set<String> skillsFullyCovered = new Set<String>();
    public Map<String, Double> skillHoursAssigned = new Map<String, Double>();
    public Datetime startDT = null;
    public Datetime endDT = null;
    public Double hoursTotal = null;
    public boolean skillsRemoved = false;
    public String geography = null;
    public String resourceType = null;
    public String employeeName = null;
    public Double hoursRemainingInGap = null;
    public Boolean isPool = null;
    //Front & back Gap of Entry
    public Double BackGap = null;
    
    //Google Distance finder change
    public String employeePostCode {get; set;}
    
    /* ResourceOption(Set<String> skills, DiaryEntryCollection gap, EmployeeInformation ei, JobInformation jobInfo)
        Constructor. Takes a Set of skills that this employee is being assigned on a job,
        a DiaryEntryCollection of the employee's to use, an EmployeeInformation object and 
        the JobInformation object containing the details of the job. */
    public ResourceOption(Set<String> skills, DiaryEntryCollection gap,
                            EmployeeInformation ei, JobInformation jobInfo) {
        
        // Set initial details
        setupEmployeeInfo(ei);
        skillsFullyCovered = skills;
        
        hoursTotal = 0.0;
        // Look over the skills passed in to the constructor, for each one, store how
        // many hours each skill requires in the skillHoursAssigned Map, and keep a 
        // running total so that hoursTotal contains the total number of hours assigned   
        for(String skill : skills) {
            Double currentSkillHours = jobInfo.skillsAndHours.get(skill);
            skillHoursAssigned.put(skill, currentSkillHours);
            hoursTotal += currentSkillHours;
        }
        
        // Set the start datetime, and calculate the end datetime
        system.debug(LoggingLevel.INFO, 'setting up times for: ' + ei.employeeName);
        setupTimes(gap, null, hoursTotal);
        system.debug(LoggingLevel.INFO,'-=-=-=--=Resource Ashok:'+entry);
    }
    
    /* ResourceOption(Map<String, Double> skillsAndHours, DiaryEntryCollection gap, 
                            EmployeeInformation ei, JobInformation jobInfo, Double startOffset)
        Constructor. This constructor is different to the preceding constructors in two main ways:
        Firstly, rather than passing in a Datetime object to represent a start datetime other than
        the start datetime of the DiaryEntryCollection, a Double is passed in that represents how 
        many working hours should be added to the DEC's start to reach the start date time we want 
        to use.
        Secondly, a Map of skills and hours is passed in rather than a Set of skills. This is 
        because this constructor is used when splitting hours between different employees. The Map
        contains the skills covered and the hours this employee is being assigned. */
    public ResourceOption(Map<String, Double> skillsAndHours, DiaryEntryCollection gap, 
                            EmployeeInformation ei, JobInformation jobInfo, Double startOffset) {
        setupEmployeeInfo(ei);
        
        hoursTotal = 0.0;
        // Look over the skills passed in to the constructor, for each one, store how
        // many hours each skill requires in the skillHoursAssigned Map, and keep a 
        // running total so that hoursTotal contains the total number of hours assigned.
        // Also, check to see if this employee is doing all the hours for any of the 
        // skills assigned to her.  
        for(String skill : skillsAndHours.keySet()) {
            Double hours = skillsAndHours.get(skill);
            skillHoursAssigned.put(skill, hours);
            hoursTotal += hours;
            
            if(hours == jobInfo.skillsAndHours.get(skill)) {
                skillsFullyCovered.add(skill);
            }
        }
        
        //system.debug(LoggingLevel.INFO, 'hoursTotal: ' + hoursTotal + ', startOffset: ' + startOffset + ', gap hours: ' + gap.numberOfHours);
        
        if(startOffset == 0) {
            // If there is no start offset, the start datetime is equal to the gap's start
            system.debug(LoggingLevel.INFO, 'startOffset == 0: ' + (startOffset == 0));
            setupTimes(gap, null, hoursTotal);
        } else {
            // Otherwise, we need to work out the start datetime by adding the startOffset to the gap's start
            system.debug(LoggingLevel.INFO, 'startOffset != 0: ' + (startOffset == 0));
            //setupTimes(gap, gap.addWorkingHoursToStart(startOffset), hoursTotal);
            setupTimes(gap, gap.addWorkingHoursToStart(startOffset), hoursTotal + startOffset);
        }
    }
    
    /* ResourceOption(Set<String> skills, DiaryEntryCollection gap, 
                            EmployeeInformation ei, JobInformation jobInfo, Double startOffset)
        Constructor. Similar to the above, except that it takes a Set of skills rather than a Map
        of skills and hours */
    public ResourceOption(Set<String> skills, DiaryEntryCollection gap, 
                            EmployeeInformation ei, JobInformation jobInfo, Double startOffset) {
        setupEmployeeInfo(ei);
        skillsFullyCovered = skills;

        hoursTotal = 0.0;
        for(String skill : skills) {
            Double hours = jobInfo.skillsAndHours.get(skill);
            skillHoursAssigned.put(skill, hours);
            hoursTotal += hours;
            
            if(hours == jobInfo.skillsAndHours.get(skill)) {
                skillsFullyCovered.add(skill);
            }
        }
        
        //system.debug(LoggingLevel.INFO, 'startOffset is: ' + startOffset + ', hoursTotal is: ' + hoursTotal);
        if(startOffset == 0) {
            //system.debug(LoggingLevel.INFO, 'startOffset == 0');
            setupTimes(gap, null, hoursTotal);
        } else {
            //setupTimes(gap, gap.addWorkingHoursToStart(startOffset), hoursTotal);
            setupTimes(gap, gap.addWorkingHoursToStart(startOffset), hoursTotal + startOffset);
        }
    }
    
    /* setupEmployeeInfo(EmployeeInformation ei)
        Extracts relevant information from the EmployeeInformation object and stores it in the
        relevant variables. */
    private void setupEmployeeInfo(EmployeeInformation ei) {
        employeeID = ei.employeeID;
        employeeName = ei.employeeName;
        neverWorksWith = ei.neverWorksWith;
        geography = ei.geographyType; 
        resourceType = ei.resourceType;
        isPool = ei.isPool;
        //google distance finder change
        employeePostCode = ei.employeePostCode;
        
    }
    
    /* setupTimes(DiaryEntryCollection gap, Datetime adjustedStart, Double hTotal)
        Sets the variables on this object related to times. */
    private void setupTimes(DiaryEntryCollection gap, Datetime adjustedStart, Double hTotal) {
        entry = gap;
        
        if(adjustedStart == null)
            startDT = gap.startDT;
         else
            startDT = adjustedStart;
        
        startDT = DateTimeHelper.normaliseDateTime(startDT, gap.shifts);
        endDT = gap.addWorkingHoursToStart(hTotal);
      
        //Suguna - 2 men team start time to 8AM/12PM
        system.debug('SKILLS_PLANNED_FROM_END'+SearchBlackBox.SKILLS_PLANNED_FROM_END);
        if(!skillsFullyCovered.contains('ELECTRICAL'))
        {
                    time MidStartTime = DateTimeHelper.stringToTime(gap.entryInfoObjects[0].MidStartTime);
                    time MstartTime = DateTimeHelper.stringToTime(gap.entryInfoObjects[0].MStartTime);
                    if(startDT.time()< MidStartTime &&startDT.time()> MStartTime && !gap.skip_8_12_Rule)
                    {
                       Double hoursToadd = DateTimeHelper.subtractTime(MidStartTime,startDT.time());
                       startDT= Datetime.newInstance(StartDT.date(),MidStartTime);
                       endDT = gap.addWorkingHoursToStart(hTotal+hoursToadd);
                    }
                    else if(startDT.time()>MidStartTime && !gap.skip_8_12_Rule)
                    {
                       Integer dayI = DateTimeHelper.DAYS_OF_WEEK.get(startDT.format('E'));
                       Time endTime = DateTimeHelper.stringToTime(gap.shifts[dayI][1]); 
                       Double hoursToadd = DateTimeHelper.subtractTime(endTime,startDT.time());
                       string existingday = StartDT.format('E');
                       string newday = Datetime.newInstance(StartDT.date().adddays(1),MstartTime).format('E');
                       if(!(existingday == 'Sun' && newday == 'Mon')){  
                       startDT= Datetime.newInstance(StartDT.date().adddays(1),MStartTime);
                       endDT = gap.addWorkingHoursToStart(hTotal+hoursToadd);}
                    }
                }
        //Ends
        
        //--=-=-=>
        List<list<String>> shifts = gap.shifts;
        
        //DateTime FinalEndTime = Datetime.newInstance(endDT.date(),DateTimeHelper.stringToTime(shifts[DateTimeHelper.DAYS_OF_WEEK.get(endDT.format('E'))][1])); 
        /*if(gap.finishDT >= endDT && FinalEndTime <= gap.finishDT){
        BackGap = DateTimeHelper.calculateHours(endDT,FinalEndTime,shifts);                                                    
        }*/
        if(endDT >= gap.finishDT){
        BackGap = 0.0;
        }else{
        BackGap = DateTimeHelper.calculateHours(endDT,gap.finishDT,shifts); 
        } 
        // If there is a gap size tolerance (search parameter), we may have added more hours than there are in the
        // Diary Entry. If this is the case, we should set the end time of the ResourceOption to the end time of
        // the Diary Entry - this helps the job booking code and logic.
        if(endDT > gap.finishDT && !isPool)
            endDT = gap.finishDT;
        hoursRemainingInGap = gap.numberOfHours - hTotal;
    }
    
    /* toSearchResults(String optionID)
        Converts this RO to a list of Search Result objects for writing to the database. */
    public List<Search_Result__c> toSearchResults(String optionID) {
        List<Search_Result__c> results = new List<Search_Result__c>();
        ID gapID = entry.getGapID(startDT); 
        system.debug(LoggingLevel.INFO, 'gapID is: ' + gapID);
        for(String skill : skillHoursAssigned.keySet()) {
            Search_Result__c sr = new Search_Result__c(Skill__c = skill, Hours__c = skillHoursAssigned.get(skill), 
                                                        Start_Date_Time__c = startDT, End_Date_Time__c = endDT, 
                                                        Job_ID__c = SearchBlackBox.jobInfo.job.ID,
                                                        Gap_Tolerance__c = SearchBlackBox.optsAndParms.gapSizeTolerance,
                                                        Diary_Entry_ID__c = gapID, Option_Identifier__c = optionID);
            results.add(sr);
        }
        return results;
    }
     
    public class GapIDException extends Exception{}
     
    /* print()
        Prints the details of thie ResourceOption to the debug log. 
    */
    public void print() {
        //system.debug(LoggingLevel.INFO, '<><><><><><><><>< RESOURCE OPTION <><><><><><><><><');
        //system.debug(LoggingLevel.INFO, 'empID: ' + employeeID);
        //system.debug(LoggingLevel.INFO, 'entry: ' + entry);
        //system.debug(LoggingLevel.INFO, 'neverWorksWith: ' + neverWorksWith);
        for(String s : skillsFullyCovered) {
            //system.debug(LoggingLevel.INFO, 'Skill fully covered: ' + s);
        }
        for(String s : skillHoursAssigned.keySet()) {
            //system.debug(LoggingLevel.INFO, 'Skill hours: ' + s + ' ' + skillHoursAssigned.get(s));
        }
        //system.debug(LoggingLevel.INFO, 'skillsRemoved: ' + skillsRemoved);
        //system.debug(LoggingLevel.INFO, 'Geography: ' + geography);
        //system.debug(LoggingLevel.INFO, 'resourceType: ' + resourceType); 
        //system.debug(LoggingLevel.INFO, 'Starts: ' + startDT);
        //system.debug(LoggingLevel.INFO, 'Finishes: ' + endDT);
        //system.debug(LoggingLevel.INFO, 'Total hours: ' + hoursTotal);
        //system.debug(LoggingLevel.INFO, 'hoursRemainingInGap: ' + hoursRemainingInGap);
        //system.debug(LoggingLevel.INFO, '<><><><><><><><>< END RESOURCE OPTION <><><><><><><><><');
    }
}