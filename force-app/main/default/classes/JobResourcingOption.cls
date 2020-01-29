/* JobResourcingOption
    A class that holds a resourcing option for a job.
    
    Employees assigned in this option are represented by ResourceOptions and there are
    also other methods to help collate relevant information for the search and the
    Visualforce results page.
*/
public with sharing class JobResourcingOption {
    // Resources in this option, in two lists - primaryResources (who are assigned)
    // to do the primary skil and secondaryResources (who are doing the skills the 
    // primary resources can not)
    public List<ResourceOption> primaryResources = new List<ResourceOption>();
    public List<ResourceOption> secondaryResources = new List<ResourceOption>();
    // skillsFullyAssigned - Skills that have been fully assigned
    public Set<String> skillsFullyAssigned = new Set<String>();
    // skillsAndHoursAssigned - Hours that have been assigned for each skill
    public Map<String, Double> skillsAndHoursAssigned = new Map<String, Double>(); 
    // employeesAssigned - Employees assigned to this option
    public Set<ID> employeesAssigned = new Set<ID>();
    // employeesNeverWorkWith - Employees that people assigned to this option will not work with 
    public Set<ID> employeesNeverWorkWith = new Set<ID>();
    // Start and end datetimes for the primary resources
    public Datetime primaryStartDT = null;
    public Datetime primaryEndDT = null;
    public String  Day{get;set;}
    
    public Set<ID> employeesAlwaysWorksWithElec = new Set<ID>();
    
    // lowestGeography - holds lowest (least best) geography amongst all primary resources on the option
    public String lowestGeography = null;
    // primaryHasSkillsRemoved - indicates is a primary resource did not have a gap big enough to
    // fulfill all the skills he is capable of doing on the job
    public Boolean primaryHasSkillsRemoved = false;
    public String optionID {get;set;}
    //public Set<String> primarySkillsFullyAssigned = new Set<String>();
    public Integer primarySkillsCount = 0;
    //Google Distance Finder Change
    public String primaryResourceDistanceFromJob{get;set;}
    public String primaryResourceTravelTimeFromJob{get;set;}
    public decimal primaryTravelTime{get;set;}
    public string primaryResourceTrafficTravelTimeFromJob{get;set;}
    // CHI Phase III CR's - CR-004 - Starts
    // Checks if skills planned from the end are already added on this job resourcing option.
    // If an employee does mechanical & electrical work on his own job only then, 
    // he should be brought up as an option for both the skills or none.
    // Mechanical is always considered as primary skill in black box search.
    // isSPFEAlreadyAdded - is already contains resources for skills planned from the end.
    
    public boolean isSPFEAlreadyAdded {get; set;}
    public Set<String> spfeStillNotAllocated =  new Set<String>();
    public boolean ignoreThisJRO {get; set;}
    
    
    // CHI Phase III CR's - CR-004 - Ends
    
    
    /* JobResourcingOption()
        Default constructor. Doesn't do anything, but needs to be present as in Apex, you have to 
        specifically write a default constructor if you want to use one when there are non-default
        constructors as well. */
    public JobResourcingOption() {}
    
    /* JobResourcingOption(JobResourcingOption original, List<ResourceOption> secondary)
        Copy constructor - takes a JRO and copies its details, as well as a list of 
        ResourceOptions to add as secondary resources to the option. */
    public JobResourcingOption(JobResourcingOption original, List<ResourceOption> secondary) {
        primaryResources.addAll(original.primaryResources);
        skillsFullyAssigned.addAll(original.skillsFullyAssigned);
        employeesAssigned.addAll(original.employeesAssigned);
        skillsAndHoursAssigned = original.skillsAndHoursAssigned;
        employeesNeverWorkWith = employeesNeverWorkWith; 
        primaryStartDT = original.primaryStartDT;
        primaryEndDT = original.primaryEndDT;
        primaryHasSkillsRemoved = original.primaryHasSkillsRemoved;
        primarySkillsCount = original.primarySkillsCount;
        lowestGeography = original.lowestGeography;
        primaryResourceDistanceFromJob = original.primaryResourceDistanceFromJob;
        system.debug(LoggingLevel.INFO,'-=-=-=--=-=--=PR: '+primaryResources);
        employeesAlwaysWorksWithElec = original.employeesAlwaysWorksWithElec;
         //system.debug('@@@@primaryStartDT'+primaryStartDT);
        //Day=primaryStartDT.format('EEEEE');
       // system.debug('@@@@Day'+Day);
        //system.debug('@@@@@original.primaryStartDT.format('EEEEE')'+original.primaryStartDT.format('EEEEE'));
        //primarySkillsFullyAssigned.addAll(original.primarySkillsFullyAssigned);
        //system.debug(LoggingLevel.INFO, 'original.primarySkillsFullyAssigned: ' + original.primarySkillsFullyAssigned);
        //system.debug(LoggingLevel.INFO, 'primarySkillsFullyAssigned: ' + primarySkillsFullyAssigned);
        addSecondaryOptions(secondary);
        
        for(ResourceOption ro : secondary) {
            employeesAssigned.add(ro.employeeID);
        }
    }
    
    /* addPrimaryOptions(List<ResourceOption> resources)
        Adds primary options to this option. The reason for using this method is to allow for
        aggregation of information about the options to be collected. */
    public void addPrimaryOptions(List<ResourceOption> resources) {
        system.debug(LoggingLevel.INFO, 'employeesAssigned: ' + employeesAssigned);
        
        for(ResourceOption resource : resources) {
            system.debug(LoggingLevel.INFO, 'adding resource as primary: ' + resource);
            primaryResources.add(resource);
            employeesAssigned.add(resource.employeeID);
            //skillsFullyAssigned.addAll(resource.skillsFullyCovered);
            addSkillsHoursBreakdown(resource.skillHoursAssigned);
            // Set the primary start datetime if necessary
            if(primaryStartDT == null || resource.startDT < primaryStartDT)
                primaryStartDT = resource.startDT;
            // Set the primary end datetime if necessary
            if(primaryEndDT == null || resource.endDT > primaryEndDT)
                primaryEndDT = resource.endDT;
            // If this option has a "neverWorksWith", add it to the relevant Set
            if(resource.neverWorksWith != null)
                employeesNeverWorkWith.add(resource.neverWorksWith);
                
            if(resource.alwaysWorksWithElectrician!=null)
            employeesAlwaysWorksWithElec.add(resource.alwaysWorksWithElectrician);
            // If this option has had skills removed, set the flag.
            if(resource.skillsRemoved)
                primaryHasSkillsRemoved = true;
            // Set lowestGeography is necessary
            if(lowestGeography == null || RankOptions.GEOGRAPHY_RANKINGS.get(lowestGeography) 
                                            < RankOptions.GEOGRAPHY_RANKINGS.get(resource.geography)) {
                lowestGeography = resource.geography;
            }
        }
       
        //primarySkillsFullyAssigned = skillsFullyAssigned.clone();
        primarySkillsCount = skillsFullyAssigned.size();
        //system.debug(LoggingLevel.INFO, 'addPrimaryOptions skillsFullyAssigned: ' + skillsFullyAssigned + ' ' + primarySkillsFullyAssigned);
    }
    
    /* addSecondaryOptions(List<ResourceOption> resources)
        Adds secondary ResourceOptions to a JRO.*/
    public void addSecondaryOptions(List<ResourceOption> resources) {
        for(ResourceOption resource : resources) {
            secondaryResources.add(resource);
            employeesAssigned.add(resource.employeeID);
            skillsFullyAssigned.addAll(resource.skillsFullyCovered);
            addSkillsHoursBreakdown(resource.skillHoursAssigned);
            if(resource.neverWorksWith != null)
                employeesNeverWorkWith.add(resource.neverWorksWith);
            if(resource.alwaysWorksWithElectrician!=null)
            employeesAlwaysWorksWithElec.add(resource.alwaysWorksWithElectrician);
        }
    }
    
    /* getPrimaryWithMostHours()
        Returns the primary ResourceOption that is doing the most hours on the job. */
    private ResourceOption getPrimaryWithMostHours() {
        ResourceOption option = (primaryResources.size() == 2 && primaryResources[1].hoursTotal > primaryResources[0].hoursTotal) 
                                ? primaryResources[1]
                                : primaryResources[0];

        return option;
    }
    
    /* rjd - 2010-01-14 - Returns the ResourceOption that finishes last on the job. */
    private ResourceOption getResourceWhoFinishesLast() {
        
        ResourceOption ro;
        DateTime tmp;
        //presume that the startDT+hoursTotal is the time they finish
        for(ResourceOption option : primaryResources){
            if(ro == null){
                ro = option;
                tmp = DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal);
                continue;
            }
            if(DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal) > tmp){
                ro = option;
                tmp = DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal);
            }
            
        }
        for(ResourceOption option : secondaryResources){
            if(ro == null){
                ro = option;
                tmp = DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal);
                continue;
            }
            if(DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal) > tmp){
                ro = option;
                tmp = DateTimeHelper.addHoursToDT(option.startDT,option.hoursTotal);
            }
            
        }
        system.debug(LoggingLevel.INFO, 'getResourceWhoFinishesLast '+ro+','+tmp);
        return ro;
    }
    
    
    
    /* getEndJobStart(Double offsetFromEnd, Double hoursForSkill)
        Gets the start time for jobs planned backwars from the end of a primary
        resource's time on a job.
        
        NOTE: This assumes no more than 2 primary resources!
        Assumption: We calculate the working hours between the start and end datetimes
        using the shift pattern of the employee with the most hours */
    public DateTime getEndJobStart(Double offsetFromEnd, Double hoursForSkill) {
        // Get the RO with most hours and store number of hours
        //ResourceOption option = getPrimaryWithMostHours();
        //there is a problem when the primary finishes well before the secondary so that the fromEnd finishes before the 
        ResourceOption option = getResourceWhoFinishesLast();
        
        Double primaryHours = option.isPool ? option.entry.workingHoursBetween(option.startDT, option.endDT) : option.hoursTotal;
        
        // Work out how many hours we need to add to the start to reach the time we
        // need to plan jobs planned at the end of the job from.
        Double offsetHours = primaryHours * ((100 - offsetFromEnd)/100);
        system.debug(LoggingLevel.INFO, 'primary hours, offsetHours:'+primaryHours+','+offsetHours);
        //system.debug(LoggingLevel.INFO, 'returning:'+addWorkingHoursToStart(offsetHours, option));
        return addWorkingHoursToStart(offsetHours, option);
    } 
    
    /* addWorkingHoursToStart(Double hoursToAdd, ResourceOption option)
        Adds the hoursToAdd to the start datetime of the option. Passes through to the
        method on the EmployeeAvailability object. */
    private DateTime addWorkingHoursToStart(Double hoursToAdd, ResourceOption option) {
        return option.entry.addWorkingHoursToStart(hoursToAdd);
    }
    
    /* addSkillsHoursBreakdown(Map<String, Double> skillHours)
        Takes a Map of skills and hours assigned and adds the value to a map that holds
        the total number of hours per skill for this option. */
    private void addSkillsHoursBreakdown(Map<String, Double> skillHours) {
        for(String skill : skillHours.keySet()) {
            Double hours = skillsAndHoursAssigned.containsKey(skill) ? skillsAndHoursAssigned.get(skill) : 0.0;
            hours += skillHours.get(skill);
            skillsAndHoursAssigned.put(skill, hours);
            system.debug(LoggingLevel.INFO, 'hours for skill on job: ' + SearchBlackBox.jobInfo.skillsAndHours.get(skill));
            system.debug(LoggingLevel.INFO, 'hours: ' + hours);
            if(hours >= SearchBlackBox.jobInfo.skillsAndHours.get(skill)) {
                skillsFullyAssigned.add(skill);
                //primarySkillsFullyAssigned.add(skill);
            }
        }
    }
    
    /* getPrimarySkills()
        Gets the skills of the primary resources in this JRO. */
    public Set<String> getPrimarySkills() {
        Set<String> primarySkills = new Set<String>();
        primarySkills.addAll(primaryResources[0].skillsFullyCovered);
        if(primaryResources.size() > 1) {
            primarySkills.addAll(primaryResources[1].skillsFullyCovered);
        } 
        return primarySkills;
    }
    
    /* getPrimaryResourceType()
        Gets the resource type of the primary resource on this JRO. */
    public String getPrimaryResourceType() {
        if(primaryResources.size() == 1)
            return primaryResources[0].resourceType;
        else{
            String lowest = primaryResources[0].resourceType;
            for(ResourceOption ro : primaryResources) {
                String s = ro.resourceType;
                if(SearchBlackBox.optsAndParms.resourceRankingMap.get(s) < SearchBlackBox.optsAndParms.resourceRankingMap.get(lowest)) {
                    lowest = s; 
                }
            }
            return lowest;
        }
    }
    
    /* getHoursRemaining()
        Returns the highest number of hours remaining on primary resources assigned in this JRO. */
    public Double getHoursRemaining() {
        if(primaryResources.size() > 1) {
            if(primaryResources[0].hoursRemainingInGap > primaryResources[1].hoursRemainingInGap)
                return primaryResources[0].hoursRemainingInGap;
            else
                return primaryResources[1].hoursRemainingInGap;
        } else 
            return primaryResources[0].hoursRemainingInGap;
    }
    
    
    
    /*
        Visualforce getters
        
        The following are all methods used for the Visualforce results page.
    */
    
    /* getPrimaryNames()
        Returns the names of primary resources in this JRO. */
    public String getPrimaryNames() {
        String s = primaryResources[0].employeeName;
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + primaryResources[i].employeeName;
            }
        }
        if(primaryHasSkillsRemoved)
            s += ' *SR*';
        return s;
    }
    
    /* getPrimaryType()
        Returns the resource types of primary resources in this JRO. */
    public String getPrimaryType() {
        String s = primaryResources[0].resourceType;
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + primaryResources[i].resourceType;
            }
        }
        return s;
    }
    
    /* getPrimaryGeography()
        Returns the geographies of primary resources in this JRO. */
    public String getPrimaryGeography() {
        String s = primaryResources[0].geography;
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + primaryResources[i].geography;
            }
        }
        return s;
    }
    
    /* getPrimaryJobSkills()
        Returns the skills of the primary resources in this JRO. */
    // Cognizant - CHI Phase III CR-002 implementation... START
    public String getPrimaryJobSkills() {
        String s = null;
        Set<String> blah = new Set<String>();
        for(ResourceOption ro : primaryResources) {
            if(s != null)
                s += ' / ';
            Boolean first = true;
            for(String t : ro.skillHoursAssigned.keySet()) {
                if(s == null){
                    s = t.subString(0,1);
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s = 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s = 'EG';
                    }
                }
                else if(first){
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s += 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s += 'EG';
                    }else
                    s += t.subString(0,1);
                }
                else{
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s += ', ' + 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s += ', ' + 'EG';
                    }else
                    s += ', ' + t.subString(0,1);
                }
                first = false;
            }
        }
        s += ' : ' + primarySkillsCount;
        return s;
    }
    // Cognizant - CHI Phase III CR-002 implementation... END
    /* getPrimaryNumberOfHoursSatisfied()
        Returns number of hours satisfied by primary resources in this JRO. */
    public String getPrimaryNumberOfHoursSatisfied() {
        String s = String.valueOf(Decimal.valueOf(primaryResources[0].hoursTotal).setScale(2));
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + String.valueOf(Decimal.valueOf(primaryResources[i].hoursTotal).setScale(2));
            }
        }
        return s;
    }
    
    /* getPrimaryFrontHours()
        Returns number of hours in gaps of primary resources in this JRO. */
    public String getPrimaryFrontHours() {
        String s = String.valueOf(Decimal.valueOf(primaryResources[0].entry.TotFrontGap).setScale(2));
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + String.valueOf(Decimal.valueOf(primaryResources[i].entry.TotFrontGap).setScale(2));
            }
        }
        return s;
    }
    
     /* getPrimaryBackHours()
        Returns number of hours in gaps of primary resources in this JRO. */
    public String getPrimaryBackHours() {
        String s = String.valueOf(Decimal.valueOf(primaryResources[0].BackGap).setScale(2));
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + String.valueOf(Decimal.valueOf(primaryResources[i].BackGap).setScale(2));
            }
        }
        return s;
    }
    
    /* getPrimaryGapHours()
        Returns number of hours in gaps of primary resources in this JRO. */
    public String getPrimaryGapHours() {
        String s = String.valueOf(Decimal.valueOf(primaryResources[0].entry.numberOfHours).setScale(2));
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + String.valueOf(Decimal.valueOf(primaryResources[i].entry.numberOfHours).setScale(2));
            }
        }
        return s;
    }
    
    /* getPrimaryRemainingHours()
        Returns number of remaining hours in the gaps of primary resources in this JRO. */
    public String getPrimaryRemainingHours() {
        String s = String.valueOf(Decimal.valueOf(primaryResources[0].hoursRemainingInGap).setScale(2));
        if(primaryResources.size() > 1) {
            for(Integer i = 1 ; i < primaryResources.size(); i++) {
                s += ' / ' + String.valueOf(Decimal.valueOf(primaryResources[i].hoursRemainingInGap).setScale(2));
            }
        }
        return s;
    }
    
    /* getPrimaryStart()
        Returns the start date time of the primary resources in this JRO. */
    public String getPrimaryStart() {
        return primaryStartDT.format();
    }

    /* getSecondaryNames()
        Returns the names of the secondary resources in this JRO.*/
    public String getSecondaryNames() {
        String s = null;
        for(ResourceOption ro : secondaryResources) {
            if(s == null)
                s = ro.employeeName;
            else
                s += ', ' + ro.employeeName; 
        }
        return s;
    }
    
    /* getSecondaryType()
        Returns the resource types of secondary resources in this JRO. */
    public String getSecondaryType() {
        String s = null;
        for(ResourceOption ro : secondaryResources) {
            if(s == null)
                s = ro.resourceType;
            else
                s += ', ' + ro.resourceType; 
        }
        return s;
    }
    
    /* getSecondaryGeography()
        Returns the geographies of secondary resources in this JRO. */
    public String getSecondaryGeography() {
        String s = null;
        for(ResourceOption ro : secondaryResources) {
            if(s == null)
                s = ro.geography;
            else
                s += ', ' + ro.geography; 
        }
        return s;
    }
    
    /* getSecondaryJobSkills()
        Returns the skills of secondary resources in this JRO. */
    // Cognizant - CHI Phase III CR-002 implementation... START
    public String getSecondaryJobSkills() {
        String s = null;
        for(ResourceOption ro : secondaryResources) {
            if(s != null)
                s += ' / ';
            Boolean first = true;
            for(String t : ro.skillHoursAssigned.keySet()) {
                if(s == null){
                    s = t.subString(0,1);
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s = 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s = 'EG';
                    }
                }
                else if(first){
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s += 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s += 'EG';
                    }else
                    s += t.subString(0,1);
                }
                else{
                    if(t.equalsIgnoreCase('Ecogen Mechanical')){
                        s += ', ' + 'MEG';
                    }else if(t.equalsIgnoreCase('Ecogen Electrical')){
                        s += ', ' + 'EG';
                    }else
                    s += ', ' + t.subString(0,1);
                }
                first = false;
            }
        }
        return s;
    }
   // Cognizant - CHI Phase III CR-002 implementation... END
    /* getSecondaryNumberOfHoursSatisfied()
        Returns the number of hours satisied by secondary resources in this JRO. */
    public String getSecondaryNumberOfHoursSatisfied() {
        String s = null;
        for(ResourceOption ro : secondaryResources) {
            if(s == null)
                s = String.valueOf(Decimal.valueOf(ro.hoursTotal).setScale(2));
            else
                s += ', ' + String.valueOf(Decimal.valueOf(ro.hoursTotal).setScale(2)); 
        }
        return s;
    }   
    
    /* toSearchResults(Datetime dtid, Integer count)
        Loops over resources in this JRO and creates relevant Search Result objects for
        writing to the database. */
    public List<Search_Result__c> toSearchResults(Datetime dtid, Integer count) {
        List<Search_Result__c> results = new List<Search_Result__c>();
        optionID = dtid.formatGmt('yyyy-MM-dd,HH:mm:ss:SS') + '-' + count.format();
        for(ResourceOption ro : primaryResources) {
            system.debug(LoggingLevel.INFO, 'about to call ro.toSearchResults');
            results.addAll(ro.toSearchResults(optionID));
        }
        
        for(ResourceOption ro : secondaryResources) {
            results.addAll(ro.toSearchResults(optionID));
        }
        
        return results;
    }
    
    /* getEndTime(ID empID)
        Gets the end time of a specific resource on a job. If the resource is not assigned to the
        job, this method returns null. */
    public DateTime getEndTime(ID empID) {
        if(!employeesAssigned.contains(empID))
            return null;
            
        for(ResourceOption ro : primaryResources) {
            if(ro.employeeID == empID) {
                return ro.endDT;
            }
        }
        
        for(ResourceOption ro : secondaryResources) {
            if(ro.employeeID == empID) {
                return ro.endDT;
            }
        }
        return null;
    }
    
    /* print()
        Prints details of thie JRO to the System.debug() log. */
    public void print() {
        /*system.debug(LoggingLevel.INFO, '~~~~~~~~~~~~~~~~ JRO ~~~~~~~~~~~~~~~~');
        system.debug(LoggingLevel.INFO, 'PRIMARY START: ' + primaryStartDT);
        system.debug(LoggingLevel.INFO, 'PRIMARY END: ' + primaryEndDT);
        system.debug(LoggingLevel.INFO, 'PRIMARY RESOURCES');
        for(ResourceOption ro : primaryResources) {
            ro.print();
        }
        system.debug(LoggingLevel.INFO, 'SECONDARY RESOURCES');
        for(ResourceOption ro : secondaryResources) {
            ro.print();
        }
        system.debug(LoggingLevel.INFO, 'SKILLS FULLY ASSIGNED: ');
        for(String s : skillsAndHoursAssigned.keySet()) {
            system.debug(LoggingLevel.INFO, 'Skill/hour: ' + s + ' ' + skillsAndHoursAssigned.get(s));
        }
        system.debug(LoggingLevel.INFO, 'EMPLOYEES ASSIGNED: ');
        for(ID s : employeesAssigned) {
            System.debug(s);
        }
        system.debug(LoggingLevel.INFO, 'EMPLOYEES NEVER WORK WITH: ');
        for(ID s : employeesNeverWorkWith) {
            System.debug(s);
        }
        system.debug(LoggingLevel.INFO, '~~~~~~~~~~~~~~~~ END JRO ~~~~~~~~~~~~~~~~');*/
    }
}