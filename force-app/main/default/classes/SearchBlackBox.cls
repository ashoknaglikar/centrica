/* SearchBlackBox

    This class is used to perform a search for a Job. The actual work is actually farmed out
    to other classes, and this class merely extracts some job details and starts a method
    in a worker class.
    
    A constructor takes an ID of the Job to search for; the startSearch() method can then
    be called to execute the actual search. Though this class can be instantiated and methods
    invoked directly, we have provided interfaces to call instead - see BlackBoxIF and 
    IPSFromSearchObject for more information. Though the interfaces are currently virtually
    empty, this design has been used to protect against future changes to the Search Black Box.     
    
*/
public with sharing class SearchBlackBox { 

    // Some static variables that are used, for example, in SOQL queries 
    public static final String GAP_DIARY_ENTRY_TYPE = 'Availability';
    public static final String UNAVAILABILITY_DIARY_ENTRY_TYPE = 'Unavailability';
    public static final String JOB_ELEMENT_WORK_TYPE = 'Work';
    public static final String EMPLOYEE_RESOURCE_TYPE = 'Installer';
    public static final String PC_SECTOR_TYPE = 'Installation'; 
    public static final String OWN_LABOUR = 'Own Labour';
    public static final String CONTRACTOR = 'Contractor';
    
    // Cognizant - CHI Phase III CR-002 implementation... START
    // Below line of code has been moved to AddNewSkill.cls. Hence, user needs to change in that class only 
    // if in future primary skill will get changed.
    
    /*public static final String PRIMARY_SKILL = 'MECHANICAL';
    public static final Set<String> SKILLS_TO_IGNORE = new Set<String>{'SCAFFOLDER'};
    public static final Set<String> SKILLS_PLANNED_FROM_END = new Set<String>{'ELECTRICAL'};*/
    
    public static final String PRIMARY_SKILL = AddNewSkill.PRIMARY_SKILL;
    public static final Set<String> SKILLS_TO_IGNORE = AddNewSkill.SKILLS_TO_IGNORE;
    public static final Set<String> SKILLS_PLANNED_FROM_END = AddNewSkill.SKILLS_PLANNED_FROM_END;

    // Cognizant - CHI Phase III CR-002 implementation... END
    
    // Objects to hold job information and options/parameters
    public static JobInformation jobInfo = null;
    public static BlackBoxOptions optsAndParms = null;
    // ID of the job
    public static ID jobID = null;
    // An object to hold the candidates and information about them 
    //private EmployeeInformationCollection employees = new EmployeeInformationCollection();
    private SearchWorker worker = new SearchWorker();
    
    /* SearchBlackBox(ID jID)
        Constructor. */
    public SearchBlackBox(ID jID) {
        jobID = jID;
    }
    
    /* setJobInfo(JobInformation ji) 
        Setter for jobInfo. This is to make testing easier than of actual use... */
    public void setJobInfo(JobInformation ji) {
        jobInfo = ji;
    }
    
    /* setOptions(BlackBoxOptions bbo)
        Setter for optsAndParms. This is to make testing easier than of actual use... */
    public void setOptions(BlackBoxOptions bbo) {
        optsAndParms = bbo;
    }
    
    
    
    public List<List<JobResourcingOption>> startSearch() {
        return startSearch(false);
        
    }
    
    /* startSearch()
        Executes a planner search for the job with the ID passed into the constructor. This
        method returns a List<List<JobResourcingOption>>. JobResourcingOption holds information
        about a resourcing option for a job - see that class for more information. 
        
        There are two lists returned - the first is a list of one representing the "business 
        best" option; the second list is a list of all options for the customer preferred date,
        ranked in order of business preference from best to worst, according to business 
        criteria. 
        
        if ignoreLocking is true then the job.job_locked__c value is ignored. If false and job_locked__c is true then 
        a jobLockingException is thrown. 
        */
    public List<List<JobResourcingOption>> startSearch(boolean ignoreLocking) {
        Datetime starts = Datetime.now();
        // Extract information about the job and search options/parameters
        extractJobInformation(jobID);
        //rjd - if the job is locked, throw a new JobLockingException. 
        if(jobInfo.isLocked && !ignoreLocking){
            throw new JobLockingException('This job is currently locked. Please try again later.');
        }
        extractOptionsAndParameters();
        system.debug(LoggingLevel.INFO, 'After job and options: ' + Limits.getScriptStatements());
        
        // Call the doSearch() method on the SearchWorked object
        List<List<JobResourcingOption>> results = worker.doSearch();
        System.debug('Results-->'+results);
        JobResourcingOption bestBusiness = null;
        
        /*
        try{
        if(results[0] != null && !results[0].isEmpty()) {
            bestBusiness = getBestBusinessOption(results[0]);
            ResourceOption ro = (bestBusiness.primaryResources.size() == 2 && bestBusiness.primaryResources[1].hoursTotal > bestBusiness.primaryResources[0].hoursTotal) 
                                    ? bestBusiness.primaryResources[1]
                                    : bestBusiness.primaryResources[0];
            List<List<String>> distancesAndTimesForAll = new List<List<String>>();
            distancesAndTimesForAll = Utilities.findDistanceBetweenPostcodes(ro.employeePostCode.trim().replaceAll(' ',''), SearchBlackBox.jobInfo.job.CHI_Lead__r.Install_Postcode__c.trim().replaceAll(' ',''));
            bestBusiness.primaryResourceDistanceFromJob = distancesAndTimesForAll[0][0];
            bestBusiness.primaryResourceTravelTimeFromJob = distancesAndTimesForAll[0][2];
        }
        }catch (exception excp)
        {
            System.debug('Exception occured in finding distance buisness best option ---> '+excp.getMessage());
        }
        */
        
        
        //google distance finder change
        String origin = '';
        Date jobStartDate ;
        List<List<String>> distancesAndTimesForAll = new List<List<String>>();
        System.debug('Results[0]-->'+results[0]);
        try{
            
                for(JobResourcingOption jro : results[0]){
                    ResourceOption ro = (jro.primaryResources.size() == 2 && jro.primaryResources[1].hoursTotal > jro.primaryResources[0].hoursTotal) 
                                        ? jro.primaryResources[1]
                                        : jro.primaryResources[0];
                    origin+=(ro.employeePostCode!=null ||ro.employeePostCode == '')?ro.employeePostCode.trim().replaceAll(' ','+')+'|' : SearchBlackBox.jobInfo.job.CHI_Lead__r.Install_Postcode__c.trim().replaceAll(' ','+')+'|';
                    jobStartDate=SearchBlackBox.jobInfo.job.Customer_Preferred_Date__c;
                }
                /*
                  system.debug('origin --- >'+origin);
                  distancesAndTimesForAll=  Utilities.findDistanceBetweenPostcodes(origin, (SearchBlackBox.jobInfo.job.CHI_Lead__r.Install_Postcode__c).trim().replaceAll(' ','+'),jobStartDate);
                
                  if(results[0].size() == distancesAndTimesForAll.size()){
                    for(Integer i = 0; i < results[0].size(); i++){
                        ResourceOption ro = (results[0][i].primaryResources.size() == 2 && results[0][i].primaryResources[1].hoursTotal > results[0][i].primaryResources[0].hoursTotal) 
                                        ? results[0][i].primaryResources[1]
                                        : results[0][i].primaryResources[0];
                        if(ro.employeePostCode!=null &&  distancesAndTimesForAll[i].size()==6)
                        {
                            results[0][i].primaryResourceDistanceFromJob = distancesAndTimesForAll[i][0];
                            results[0][i].primaryResourceTravelTimeFromJob = distancesAndTimesForAll[i][2];
                            results[0][i].primaryTravelTime = decimal.valueof(distancesAndTimesForAll[i][3]);
                            results[0][i].primaryResourceTrafficTravelTimeFromJob = distancesAndTimesForAll[i][4];
                        }else if(ro.employeePostCode==null)
                        {
                            results[0][i].primaryResourceDistanceFromJob = 'No Home PC';
                            results[0][i].primaryResourceTravelTimeFromJob = 'No Home PC';
                            results[0][i].primaryTravelTime =0;
                            results[0][i].primaryResourceTrafficTravelTimeFromJob ='No Home PC';
                        }else
                        {   
                        	results[0][i].primaryResourceDistanceFromJob = 'PC Error';
                            results[0][i].primaryResourceTravelTimeFromJob = 'PC Error';
                            results[0][i].primaryTravelTime =0; 
                        	results[0][i].primaryResourceTrafficTravelTimeFromJob ='PC Error';
                        }
                    }
                }
                */
                bestBusiness = getBestBusinessOption(rankOptions(results[0]));
        }catch(Exception excp){
            
            System.debug('Exception occured in finding distance customer preferred options ---> '+excp.getMessage());
            
        }
        system.debug(LoggingLevel.INFO, 'After customer options: ' + Limits.getScriptStatements());
        
        
        
        List<JobResourcingOption> rankedCustomerOptions = new List<JobResourcingOption>();
        if(results[1] != null && !results[1].isEmpty()) {
            rankedCustomerOptions = rankOptions(results[1]);
        }
        
        serializeOptions(new List<List<JobResourcingOption>> { new List<JobResourcingOption> {bestBusiness}, rankedCustomerOptions});
        system.debug(LoggingLevel.INFO, 'Time started: ' + starts);
        system.debug(LoggingLevel.INFO, 'Time finished: ' + Datetime.now());
        return new List<List<JobResourcingOption>> { new List<JobResourcingOption> {bestBusiness}, rankedCustomerOptions};
    }

    /* extractJobInformation(ID jobID)
        Extracts the Job object with the provided ID, and creates a new instance of the JobInformation
        object that holds the relevant information about the Job. */
    private void extractJobInformation(ID jID) {
        jobInfo = new JobInformation(jID);
    }

    /* extractOptionsAndParameters()
        Creates a new BlackBoxOptions object which will, in turn, extract the Search Parameter object.
        See the BlackBoxOptions class for more information. */
    private void extractOptionsAndParameters() {
        optsAndParms = new BlackBoxOptions(jobInfo.job);
    }

    /* rankOptions(List<JobResourcingOption> options)
        Ranks a list of JobResourcingOptions according to the business criteria. The logic of how options are
        ranked is contained in the RankOptions class. Note that though this has been designed for use 
        for customer options, it will accept any list of JobResourcingOptions and rank them according to the
        criteria as implemented in RankOptions. */
    private List<JobResourcingOption> rankOptions(List<JobResourcingOption> options) {
        RankOptions rank = new RankOptions();
        //google distance finder change
        String origin = '';
        Date jobStartDate;
        List<List<String>> distancesAndTimesForAll = new List<List<String>>();
        try{
            
                for(JobResourcingOption jro : options){
                    ResourceOption ro = (jro.primaryResources.size() == 2 && jro.primaryResources[1].hoursTotal > jro.primaryResources[0].hoursTotal) 
                                        ? jro.primaryResources[1]
                                        : jro.primaryResources[0];
                    origin+=(ro.employeePostCode!=null ||ro.employeePostCode == '')?ro.employeePostCode.trim().replaceAll(' ','+')+'|' : SearchBlackBox.jobInfo.job.CHI_Lead__r.Install_Postcode__c.trim().replaceAll(' ','+')+'|';
                    jobStartDate=SearchBlackBox.jobInfo.job.Customer_Preferred_Date__c!=null?SearchBlackBox.jobInfo.job.Customer_Preferred_Date__c:system.today();
                }
                  system.debug('origin --- >'+origin);
                  distancesAndTimesForAll=  Utilities.findDistanceBetweenPostcodes(origin, (SearchBlackBox.jobInfo.job.CHI_Lead__r.Install_Postcode__c).trim().replaceAll(' ','+'),jobStartDate);
                
                  if(options.size() == distancesAndTimesForAll.size()){
                    for(Integer i = 0; i < options.size(); i++){
                        ResourceOption ro = (options[i].primaryResources.size() == 2 && options[i].primaryResources[1].hoursTotal > options[i].primaryResources[0].hoursTotal) 
                                        ? options[i].primaryResources[1]
                                        : options[i].primaryResources[0];
                        if(ro.employeePostCode!=null  && distancesAndTimesForAll[i].size()==6)
                        {
                            options[i].primaryResourceDistanceFromJob = distancesAndTimesForAll[i][0];
                            options[i].primaryResourceTravelTimeFromJob = distancesAndTimesForAll[i][2];
                            options[i].primaryTravelTime = decimal.valueof(distancesAndTimesForAll[i][3]);
                            options[i].primaryResourceTrafficTravelTimeFromJob = distancesAndTimesForAll[i][4];
                        }else if(ro.employeePostCode==null )
                        {
                            options[i].primaryResourceDistanceFromJob = 'No Home PC';
                            options[i].primaryResourceTravelTimeFromJob = 'No Home PC';
                            options[i].primaryTravelTime =0; 
                            options[i].primaryResourceTrafficTravelTimeFromJob ='No Home PC';
                        }else
                        {   
                        	options[i].primaryResourceDistanceFromJob = 'PC Error';
                            options[i].primaryResourceTravelTimeFromJob = 'PC Error';
                            options[i].primaryTravelTime =0;
                            options[i].primaryResourceTrafficTravelTimeFromJob ='PC Error';
                        }   
                    }
                }
                
        }catch(Exception excp){
            
            System.debug('Exception occured in finding distance customer preferred options ---> '+excp.getMessage());
            
        }
        system.debug(LoggingLevel.INFO, 'After customer options: ' + Limits.getScriptStatements());
        
        return rank.rankOptions(options);
    }

    /* getBestBusinessOption(List<JobResourcingOption> businessOptions)
        Takes a list of JobResourcingOptions and returns the one that occurs earliest. */
    private JobResourcingOption getBestBusinessOption(List<JobResourcingOption> businessOptions) {
        if(businessOptions == null || businessOptions.isEmpty()) {
            return null;
        }
        
        if(businessOptions.size() == 1) {
            if(skipbusinessbest(businessOptions[0]))
            return businessOptions[0];
            else
            return null;
        } else {
            system.debug(LoggingLevel.INFO,'=======BusinessOptions--->'+businessOptions.size());
            JobResourcingOption best = businessOptions[0];
            
            for(Integer i = 1 ; i < businessOptions.size() ; i++) {
                
                if(businessOptions[i].primaryStartDT < best.primaryStartDT)
                    if(skipbusinessbest(businessOptions[i])) //Change by Ashok G
                    best = businessOptions[i];
                    
            }  
            //Check for very first entry..
            if(skipbusinessbest(best))
            return best;
            else
            return null;
           
        }
    }
    
    /* serializeOptions(List<List<JobResourcingOption>> options)
        Takes a List of List of JobResourcingOptions and writes them to the Database as 
        Search_Result__c objects. */
    private void serializeOptions(List<List<JobResourcingOption>> options) {
        List<Search_Result__c> serialiseThese = new List<Search_Result__c>(); 
        Datetime dtid = Datetime.now();
        Integer count = 0;
        for(List<JobResourcingOption> jros : options) {
            // For each List of JROs...
            for(JobResourcingOption jro : jros) {
                // For each JRO in this list 
                if(jro == null)
                    continue;
                // Call the appropriate method on the JRO which returns the JRO in a list of Search_Result__c objects. These 
                // are added to the listed to be added to the database. The DTID and count variables are passed in to construct
                // an identifier linking all Search Results for each JRO. 
                serialiseThese.addAll(jro.toSearchResults(dtid, count));
                count++;
            }
        }
        
        // If there are any objects to write to the database, do so.
        if(!serialiseThese.isEmpty()) {
            Database.insert(serialiseThese);
        }
    } 
    
    public Boolean skipbusinessbest(JobResourcingOption businessoption){
     Boolean chek = false;
     String WST = businessOption.PrimaryResources[0].entry.WeekMap.values()[0];
     System.debug(LoggingLevel.INFO,'----------WST--->'+WST);   
     if(WST!=null){
        String[] MMST = WST.Split('-');
        string MstartTime = MMST[0];
        String MidstartTime = MMST[1];
        String PTime = string.valueof(businessOption.primaryStartDT.Time());
        string[] FEndTime = PTime.split(':');
        string ET = FEndTime[0]+':'+FEndTime[1];
        Double diff = DateTimeHelper.hoursBetweenStartEndHours(ET,MstartTime);
        Double diff1 = DateTimeHelper.hoursBetweenStartEndHours(ET,MidstartTime);
        system.debug(LoggingLevel.INFO,'=================diff-->'+diff+' '+diff1+' '+businessOption.primaryStartDT);
        if(diff == 0.0 || diff1 == 0.0)
        chek = TRUE;
     }
     
     if(string.Valueof(system.label.Skip_8_12_Rule)=='yes' || SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c ) //SearchBlackBox.JobInfo.Job.Skip_8_12_Rule__c
     chek = TRUE;
     
     return chek;  
     
    }
     
    /* extractEmployees()
        Extracts Employees from the database that may be suitable for this Job.*/
    /*private void extractEmployees() {
        //worker.employeeSetup();
        Date todaysDate = Date.today();
        Date custsDate = optsAndParms.customerPreferredDate;
        Integer window = optsAndParms.schedulingWindow;
        
        // Select the relevant Postcode Sector for this Job. We also pull out Employee Postcode Sectors 
        // for Employees that cover the Postcode Sector within the windows this job may take place in
        // (today + scheduling window, and customer's preferred date + scheduling window)    
        Postcode_Sector__c pcSector = null;
        Set<ID> empIDs = new Set<ID>();
        
        pcSector = [select ID, Sub_Patch__r.District__c, Sub_Patch__r.District__r.Region__c,
                            (select Employee__c, Employee__r.Always_Works_With__c, Type__c, Employee__r.Name 
                            from Employee_Postcodes__r 
                            where (Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate.addDays(window))
                                or (Start_Date__c >= :todaysDate and Start_Date__c <= :todaysDate.addDays(window))
                                or (End_Date__c >= :todaysDate and End_Date__c <= :todaysDate.addDays(window))
                                or (Start_Date__c <= :custsDate and End_Date__c >= :custsDate.addDays(window))
                                or (Start_Date__c >= :custsDate and Start_Date__c <= :custsDate.addDays(window))
                                or (End_Date__c >= :custsDate and End_Date__c <= :custsDate.addDays(window))
                            ) 
                    from Postcode_Sector__c p where p.Name=:jobInfo.postcodeSector and p.Type__c=:PC_SECTOR_TYPE limit 1];
        
        // Loop over Employee Postcode Sectors - if an Employee has an EPS within the given date, they are
        // a potential candidate for this job, so we store their ID in a set            
        for(Employee_Postcode_Sectors__c[] employeePostcodes : pcSector.Employee_Postcodes__r) {
            for(Employee_Postcode_Sectors__c employeePostcode : employeePostcodes) {
                empIDs.add(employeePostcode.Employee__c);
                
                // If this employee has an "Always Works With" link, add the employee they always work with to empIDs to 
                // make sure they are also extracted in the next step.
                if(employeePostcode.Employee__r.Always_Works_With__c != null)
                    empIDs.add(employeePostcode.Employee__r.Always_Works_With__c);
            }
        }
        
        
        Set<ID> blacklist = new Set<ID>();
        
        // Pull out IDs of employees that are already assigned on the job
        for(Diary_Entry__c de : [select d.Week__r.Employee__c, d.Week__r.Employee__r.Always_Works_With__c, d.Week__r.Employee__r.Name 
                                    from Diary_Entry__c d where Job__c = :jobID]) {
            // Check if the ID of the employee on this Diary Entry has already has his ID put into empIDs (i.e. he covers
            // the postcode sector). If so, and if he has an Always Works With link, add that ID as well. The set called 
            // Blacklist is used to make sure this only happens once! All this ensures that an Always Works With is only
            // added if the Employee has Employee Postcode Sectors, otherwise they may be dragged in on a Job in an area
            // they do not cover.  
            if(empIDs.contains(de.Week__r.Employee__c) && !blacklist.contains(de.Week__r.Employee__c) 
                && de.Week__r.Employee__r.Always_Works_With__c != null) {
                empIDs.add(de.Week__r.Employee__r.Always_Works_With__c);
            } else {
                blacklist.add(de.Week__r.Employee__c);
            }
            // Also add the employee 
            system.debug(LoggingLevel.INFO, 'adding employee from DE: ' + de.Week__r.Employee__c);
            empIDs.add(de.Week__r.Employee__c);
        }

        // Bring in the ID of the named employee if there is one, and if they have an Always Works With, that ID as well  
        if(jobInfo.namedEmployee != null)
            empIDs.add(jobInfo.namedEmployee);
        if(jobInfo.namedEmployeeAWW != null)
            empIDs.add(jobInfo.namedEmployeeAWW);
        
        // Set some information on the JobInformation object that we previously did not have. 
        jobInfo.jobDistrict = pcSector.Sub_Patch__r.District__c;
        jobInfo.jobArea = pcSector.Sub_Patch__r.District__r.Region__c;
        
        // Select out Employees that either:
        //      a. cover this Job's Postcode Sector (determined in the above SOQL query and therefore with an ID in empIDs)
        //      b. cover this district and work anywhere in the district
        //      c. cover this region and work anywhere in the region
        // and also have the relevant resource type for installation employees 
        // and are not marked as inactive
        
        for(Employee__c e : [select (select Type__c 
                                        from Employee_Postcodes__r
                                        where Postcode_Sector__c = :pcSector.ID),
                                    e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__r.Name, e.Supplier__c,
                                    e.Region__c, e.Pool_Diary__c, e.Never_Works_With__c, e.District__r.Region__c,
                                    e.Name, e.Id, e.District__r.Name, e.District__c, e.Always_Works_With__c, e.Always_Works_Alone__c,
                                    e.Own_Labour__c, e.Net_Promoter_Score__c, e.Contractor_Band__c
                            from Employee__c e
                            where   (e.ID IN :empIDs
                                    or (e.District__c = :pcSector.Sub_Patch__r.District__c 
                                        and Works_Anywhere_In_District__c = true)
                                    or (e.District__r.Region__c = :pcSector.Sub_Patch__r.District__r.Region__c 
                                        and Works_Anywhere_In_Area__c = true)
                                    )
                                    and Resource_Type__c = :EMPLOYEE_RESOURCE_TYPE
                                    and Inactive__c = false]) {
                                        
            // This employee covers this area, put the employee into a Map. Note that though he covers the area, he may not 
            // have skills or availability for this Job - that is determined in the next step.
            employees.addEmployee(e);
        }
    }*/
    
    /* addEmployeeSkills()
        Add employee skills to our Employee objects - this is done in the EmployeeInformationCollection */
    /*private void addEmployeeSkills() {
        employees.addEmployeeSkills();
    }*/

    /* extractAvailability()
        Add employee availablity to our Employee objects - this is done in the EmployeeInformationCollection */
    /*private void extractAvailability() {
        employees.addEmployeeAvailability(); //jobInfo.job.Customer_Preferred_Date__c, optsAndParms.schedulingWindow, jobInfo.job.ID);
    }*/
    
    /* constructBusinessResourcingOptions()
        Runs the search algorithm to find resourcing options for a Job that suits the business i.e. occurs
        as soon as possible. */
    /*private List<JobResourcingOption> constructBusinessResourcingOptions() {
        return employees.constructBusinessResourcingOptions();
    }*/

    /* constructCustomerResourcingOptions()
        Runs the search algorithm to find resourcing options for a Job that suits the customer i.e. occurs
        as close to the customer's preferred date as possible. */
    /*private List<JobResourcingOption> constructCustomerResourcingOptions() {
        return employees.constructCustomerResourcingOptions();
    }*/

    public class JobLockingException extends Exception{}
}