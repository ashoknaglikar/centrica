/* EmployeeInformationCollection
    A class that holds information about Employees that are candidates for a job. The class also
    holds the logic to extract the Employees and information about them (such as skills and 
    availability) from the database. 
    
    The heart of this class is a Map of EmployeeInformation objects keyed by their ID. Other
    methods in the class control what's added to/read from this list, and other Maps and Sets
    provide ways of holding data that make processing easier later on. 
    
*/
public with sharing class EmployeeInformationCollection {
    
    // Maps and Sets that hold the employees and associated information in a number of
    // useful ways
    public map<id, set<string>> employeeIdWithOptOutSkill = new map<id, set<string>>();
    public Map<ID, EmployeeInformation> employees {public get; private set;}
    public Set<ID> employeeIDs {public get; private set;}
    public Set<ID> employeesWithPrimarySkill {public get; private set;}
    public Map<String, Set<ID>> employeeIDsBySkill {public get; private set;}
    public Map<ID, List<ID>> primaryBySupplierID {public get; private set;}
    
    public set<ID> AlwaysWorksWithElecIDs {public get; private set;}
    // JobInformation and BlackBoxOptions objects - makes referencing easier...
    public JobInformation jobInfo = null;
    public BlackBoxOptions bo = null;
    
    // Defect 233
    public Set<String> skillsCoveredForBusinessBest = new Set<String>();
    public Set<String> skillsCoveredForCustomerPreferred = new Set<String>();
    
    // Defect XXX
    // Map to hold Diary Entries of people already on the job
    public static Map<ID, List<Diary_Entry__c>> entriesAlreadyOnJob = new Map<ID, List<Diary_Entry__c>>(); 


    // removemethod()

    public void removeEmployees(set<id> employeeIds)
    {
        employeeIDs.removeAll(employeeIds);
        employeesWithPrimarySkill.removeAll(employeeIds);
        
        for(id i : employeeIds)
        {
            employees.remove(i);
           
        }
    }
    
    /* EmployeeInformationCollection()
        Constructor. Initialises class variables. */
    public EmployeeInformationCollection() {
        employees = new Map<ID, EmployeeInformation>();
        employeeIDs = new Set<ID>();
        employeesWithPrimarySkill = new Set<ID>();
        employeeIDsBySkill = new Map<String, Set<ID>>();
        primaryBySupplierID = new Map<ID, List<ID>>();
        AlwaysWorksWithElecIDs= new set<id>();
    }

    /* setJobInfo(JobInformation ji)
        Sets the jobInfo variable. This helps make code a little easier to read. */
    public void setJobInfo(JobInformation ji) {
        jobInfo = ji;
    }
    
    /* setOptions(BlackBoxOptions opts)
        Sets the bo variable. This helps make code a little easier to read. */
    public void setOptions(BlackBoxOptions opts) {
        bo = opts;
    }

    /* addEmployee(Employee__c e)
        Adds an Employee to the collection if they are not already in it. */
    public void addEmployee(Employee__c e, decimal overBookingExpHours) {
        if(!employees.containsKey(e.ID)) {
            EmployeeInformation ei = new EmployeeInformation(e);
            ei.overBookingExpHours = overBookingExpHours;
            employees.put(e.ID, ei);
            //System.debug(LoggingLevel.INFO, 'employees.put: ' + e.ID + ' - ' + ei.employeeName);
            employeeIDs.add(e.ID);
            if(e.Always_Works_with_Electrician__c!=null)
            AlwaysWorksWithElecIDs.add(e.Always_Works_with_Electrician__c);
        }
    }

    /* getEmployee(ID empID)
        Returns the EmployeeInformation for an Employee from the Map, if present. */
    public EmployeeInformation getEmployee(ID empID) {
        //System.debug(LoggingLevel.INFO, 'empId'+empId+'--'+employees.get(empID));
        return employees.get(empID);
    }

    /* setupEmployeeInformation()
        Calls the methods that extract information about Employees, their skills and their availability from the
        Database and process the information for the black box processing. */
    
    public void setupEmployeeInformation() {
        // We set internal references to the JobInformation and BlackBoxOptions to make it easier and more
        // readable to access these objects
        jobInfo = SearchBlackBox.jobInfo;
        bo = SearchBlackBox.optsAndParms;
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-isPlanner:'+cls_IsRun.isPlanner);
        //Change By Ashok G
        Date custsDate = bo.customerPreferredDate;
        Date FinExpDate = bo.FinanceExpDate;
        Date TodaysDate = Date.Today();
        //Date TodaysDate =bo.customerPreferredDate;
        //Date InstDate = bo.InstallDate ; 
        if(FinExpDate != null){
            if(custsDate > FinExpDate){
             throw new SearchWorker.SearchException(system.label.Finance_Expiry_Error);
            }
            
            if(TodaysDate > FinExpDate){
             throw new SearchWorker.SearchException(system.label.Finance_Expiry_Error1);
            }
                       
        }
        
        if(cls_IsRun.isPlanner == 'N'){
           if(cls_IsRun.isPortal==true)
            {
                if(custsDate>TodaysDate.addDays(integer.valueof(system.label.maximumDayCustomerPortal))){
                throw new searchWorker.SearchException(system.label.HSA_Expiry_Error_Portal);
                }
            }
            else
            {   
                if(custsDate>TodaysDate.addDays(integer.valueof(system.label.Length_of_time))){
                throw new searchWorker.SearchException(system.label.HSA_Expiry_Error);
                }
            }
        }
       
        
        extractEmployeesWithSimpleSkills();

        //Change End
        extractEmployees();
     //  Cognizant support fix - Geography fix.
     //  Call the newly added method to populate employee postcode sectors against employeeinformation 
        populateEmployeePostcodeSectors();
        addEmployeeSkills();
        addEmployeeAvailability();
        // Defect 233
        checkSkillsCanBeCovered();
    }
    
    /* checkSkillsCanBeCovered()
        After employee availability has been added, we check that all skills have someone with some
        availability. If not, an exception is thrown and the search ends here. 
        
        This covers part of Defect 233. */
    
    public void checkSkillsCanBeCovered() {
        for(String skill : jobInfo.skillsAndHours.keySet()) {
            
            
            if(employeeIDsBySkill.get(skill) == null || employeeIDsBySkill.get(skill).isEmpty() && cls_IsRun.isPlanner == 'N'  )
            {
                 throw new SearchWorker.SearchException('There are no available resources on this date, please choose an alternative date' );
            }   
            
            else if(employeeIDsBySkill.get(skill) == null || employeeIDsBySkill.get(skill).isEmpty() && cls_IsRun.isPlanner != 'N' ) {
                throw new SearchWorker.SearchException('The ' + skill.toUpperCase() + ' ' +
                        'skill can not be fulfilled by the employees in this area' +
                        // Named skills - CR - Starts
                        ' or it might be possible that you have selected a named skill resource who does not have this skill.' +
                        // Named skills - CR - Ends
                        ' Make sure there is an ' +
                        'employee in the area with this skill and that they have availability. Alternatively, ' +
                        'choose a different Customer Preferred Date');
            }   
        }
    }
    
    /* checkSkillsCanBeCovered(Boolean isBusiness)
        Checks whether all skills have someone available for business best/customer preferred date, determined
        by the boolean passed into the metho. 
        
        This covers part of Defect 233. */
    public Boolean checkSkillsCanBeCovered(Boolean isBusiness) {
        if(isBusiness) {
            return skillsCoveredForBusinessBest.containsAll(jobInfo.skillsAndHours.keySet());
        } else {
            return skillsCoveredForCustomerPreferred.containsAll(jobInfo.skillsAndHours.keySet());
        }
    }
    
    /* extractEmployees()
        Extracts Employees from the database that may be suitable for this Job. */
    public void extractEmployees() {
        Date todaysDate = Date.today();
        //Date todaysDate =bo.customerPreferredDate;
        Date custsDate = bo.customerPreferredDate;
        Integer window = bo.schedulingWindow;
        
          Date FinanceExpDate = bo.FinanceExpDate;
          Date todaysDatepluswindow = todaysDate.addDays(window);
          Date custsDatepluswindow = custsdate.addDays(window);
          if(FinanceExpDate != null){
            if(custsDate.addDays(window)>FinanceExpDate)
            custsDatepluswindow = FinanceExpDate;
            
            if(todaysDatePlusWindow > FinanceExpDate)
            todaysDatePlusWindow = FinanceExpDate;
            
          }
        
        // Select the relevant Postcode Sector for this Job. We also pull out Employee Postcode Sectors 
        // for Employees that cover the Postcode Sector within the windows this job may take place in
        // (today + scheduling window, and customer's preferred date + scheduling window)    
        Postcode_Sector__c pcSector = null;
        Set<ID> empIDs = new Set<ID>();
        List<Postcode_Sector__c> sectors = new List<Postcode_Sector__c>();
        if(custsDate != null)
        {
            sectors = [select ID, Sub_Patch__r.District__c, Sub_Patch__r.District__r.Region__c,
                            (select Employee__c, Employee__r.Always_Works_With__c, Type__c, Employee__r.Name, Employee__r.Inactive__c,Employee__r.Is_Active_Salesforce_User__c,
                                    Employee__r.Always_Works_with_Electrician__c
                            from Employee_Postcodes__r 
                            where ((Start_Date__c <= :todaysDate and End_Date__c >= :todaysDatepluswindow )
                                or (Start_Date__c >= :todaysDate and Start_Date__c <= :todaysDatepluswindow )
                                or (End_Date__c >= :todaysDate and End_Date__c <= :todaysDatepluswindow )
                                or (Start_Date__c <= :custsDate and End_Date__c >= :custsDatepluswindow)
                                or (Start_Date__c >= :custsDate and Start_Date__c <= :custsDatepluswindow)
                                or (End_Date__c >= :custsDate and End_Date__c <= :custsDatepluswindow))
                                and Employee__r.Inactive__c = false // only get active employees
                                and Employee__r.Is_Active_Salesforce_User__c = 'true' //PRB00033753
                            ) 
                    from Postcode_Sector__c p where p.Name=:jobInfo.postcodeSector 
                                                and p.Type__c=:SearchBlackBox.PC_SECTOR_TYPE];
        }
        
        
        if(sectors.size() == 0) {
            throw new SearchWorker.SearchException('No Installation Postcode Sectors exist for this address.');
        } else if (sectors.size() > 1) {
            throw new SearchWorker.SearchException('Multiple Installation Postcode Sectors exist for this address.');
        }
        
        pcSector = sectors[0];
        system.debug('pcsector-->'+pcSector);
        
        Map<Id, Employee__c> tmpEmployees = new Map<Id, Employee__c>();
        for(Employee_Postcode_Sectors__c[] employeePostcodes : pcSector.Employee_Postcodes__r) {
            for(Employee_Postcode_Sectors__c employeePostcode : employeePostcodes) {
                tmpEmployees.put(employeePostcode.Employee__c, employeePostcode.Employee__r);
            }
        }
        
        // Loop over Employee Postcode Sectors - if an Employee has an EPS within the given date, they are
        // a potential candidate for this job, so we store their ID in a set            
        for(Employee_Postcode_Sectors__c[] employeePostcodes : pcSector.Employee_Postcodes__r) {
            for(Employee_Postcode_Sectors__c employeePostcode : employeePostcodes) {
                system.debug('Exception --->'+employeePostcode.Employee__c+' '+employeePostcode.Employee__r.Name+' '+employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                //rjd - 21-12-2009 - check for the case where always works with employee is inactive(i.e. not in employees list). Don't add to the list in this case
                  /*if(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With__c != null && tmpEmployees.containsKey(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With__c) && 
                  (tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With_Electrician__c != null&& tmpEmployees.containsKey(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With_Electrician__c))){
                        empIDs.add(employeePostcode.Employee__c);
                      // If this employee has an "Always Works With" link, add the employee they always work with to empIDs to 
                      // make sure they are also extracted in the next step.
                        if(employeePostcode.Employee__r.Always_Works_With__c != null)
                        empIDs.add(employeePostcode.Employee__r.Always_Works_With__c);
                        
                        if(employeePostcode.Employee__r.Always_Works_With_Electrician__c != null)
                        empIDs.add(employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }
                     // Cognizant support fix - If employee does not have anyone who he always works with but if he does  
                     // have valid employee postcode sector for the job then add him.
                  else if(employeePostcode.Employee__r.Always_Works_With__c == null&&employeePostcode.Employee__r.Always_Works_With_Electrician__c!=null && tmpEmployees.containsKey(employeePostcode.Employee__c)&& tmpEmployees.containsKey(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With_Electrician__c)){
                    empIDs.add(employeePostcode.Employee__c);
                    empIDs.add(employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                    system.debug('Exception sugu 2--->'+employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }
                  else if(employeePostcode.Employee__r.Always_Works_With__c != null&&employeePostcode.Employee__r.Always_Works_With_Electrician__c==null && tmpEmployees.containsKey(employeePostcode.Employee__c)&& tmpEmployees.containsKey(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With__c)){
                    empIDs.add(employeePostcode.Employee__c);
                    empIDs.add(employeePostcode.Employee__r.Always_Works_With__c);
                    system.debug('Exception sugu 3--->'+employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }
                  else if(employeePostcode.Employee__r.Always_Works_With__c == null &&employeePostcode.Employee__r.Always_Works_With_Electrician__c==null&& tmpEmployees.containsKey(employeePostcode.Employee__c)){
                    empIDs.add(employeePostcode.Employee__c);
                    system.debug('Exception sugu 4--->'+employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }*/
                  if(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With__c != null && tmpEmployees.containsKey(tmpEmployees.get(employeePostcode.Employee__c).Always_Works_With__c)){
                        empIDs.add(employeePostcode.Employee__c);
                        if(employeePostcode.Employee__r.Always_Works_With__c != null)
                        empIDs.add(employeePostcode.Employee__r.Always_Works_With__c);
                        if(employeePostcode.Employee__r.Always_Works_With_Electrician__c != null)
                        empIDs.add(employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }
                  else if(employeePostcode.Employee__r.Always_Works_With__c == null && tmpEmployees.containsKey(employeePostcode.Employee__c)){
                        empIDs.add(employeePostcode.Employee__c);
                        if(employeePostcode.Employee__r.Always_Works_With_Electrician__c != null)
                        empIDs.add(employeePostcode.Employee__r.Always_Works_With_Electrician__c);
                  }
            }
        }
        
        Set<ID> blacklist = new Set<ID>();
        
        // Pull out IDs of employees that are already assigned on the job
        // added Is_Active_Salesforce_User__c = true as part of PRB00033753
        for(Diary_Entry__c de : [select d.Week__r.Employee__c, d.Week__r.Employee__r.Always_Works_With__c, d.Week__r.Employee__r.Name,d.Week__r.Employee__r.Always_Works_With_Electrician__c,
                                 d.Start__c, d.Hours__c  , d.Week__r.Locking_User__c,d.Week__r.Category_Num__c,d.Week__r.Release_Date__c,
                                 d.Week__r.Lockers1__c from Diary_Entry__c d where Job__c = :SearchBlackBox.jobID //or Job_Travel__c =  :SearchBlackBox.jobID)
                                 and d.Week__r.Employee__r.Inactive__c = false and d.Week__r.Employee__r.Is_Active_Salesforce_User__c = 'true']) {
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
            
            if(empIDs.contains(de.Week__r.Employee__c) && !blacklist.contains(de.Week__r.Employee__c)
            && de.Week__r.Employee__r.Always_Works_With_Electrician__c!= null) {
            empIDs.add(de.Week__r.Employee__r.Always_Works_With_Electrician__c);
            } else {
                blacklist.add(de.Week__r.Employee__c);
            }
            
            // Also add the employee 
            //System.debug(LoggingLevel.INFO, 'adding employee from DE: ' + de.Week__r.Employee__c);
            empIDs.add(de.Week__r.Employee__c);
            
            // Defect XXX
            // Add diary entry to entriesAlreadyOnJob
            List<Diary_Entry__c> employeeJobEntries = (entriesAlreadyOnJob.containsKey(de.Week__r.Employee__c)) 
                                                        ? entriesAlreadyOnJob.get(de.Week__r.Employee__c)
                                                        : new List<Diary_Entry__c>();
            employeeJobEntries.add(de);
            entriesAlreadyOnJob.put(de.Week__r.Employee__c, employeeJobEntries);
              
            
        }

        // Bring in the ID of the named employee if there is one, and if they have an Always Works With, that ID as well  
        if(jobInfo.namedEmployee != null)
            empIDs.add(jobInfo.namedEmployee);
        if(jobInfo.namedEmployeeAWW != null)
            empIDs.add(jobInfo.namedEmployeeAWW);
            
            
     // Bring in the ID of the named electrician if there is one
        
         if(SearchBlackBox.jobInfo.namedElectritian != null){
            
            empIDs.add(jobInfo.namedElectritian);
            
        }
        
        // Named electritian change - Starts
        
         if(jobInfo.namedSkillSet.size()>0){
            
            for(List<ID> empIdList : jobInfo.namedSkillEmpMap.values()){
             
                 empIDs.addAll(empIdList);
                 System.debug('Named employees : '+empIdList);
            
            }
            
         }
        
        // Named electritian change - Ends
        
        // Set some information on the JobInformation object that we previously did not have. 
        jobInfo.jobDistrict = pcSector.Sub_Patch__r.District__c;
        jobInfo.jobArea = pcSector.Sub_Patch__r.District__r.Region__c;
        
        // Select out Employees that either:
        //      a. cover this Job's Postcode Sector (determined in the above SOQL query and therefore with an ID in empIDs)
        //      b. cover this district and work anywhere in the district
        //      c. cover this region and work anywhere in the region
        // and also have the relevant resource type for installation employees 
        // and are not marked as inactive
        
        List<Employee__c> employeeList =  [select (select Type__c,Start_Date__c,End_Date__c 
                                        from Employee_Postcodes__r
                                        where Postcode_Sector__c = :pcSector.ID),
                                    e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__r.Name, e.Supplier__c,
                                    e.Region__c, e.Pool_Diary__c, e.Never_Works_With__c, e.District__r.Region__c,Postcode__c,e.Always_Works_with_Electrician__c,
                                    e.Name, e.Id, e.District__r.Name, e.District__c, e.Always_Works_With__c, e.Always_Works_Alone__c,e.Employee_Number__c,
                                    e.Own_Labour__c, e.Net_Promoter_Score__c, e.Contractor_Band__c, e.Inactive__c, e.Skip_Rule__c, e.Is_Active_Salesforce_User__c
                            from Employee__c e
                            where   (e.ID IN :empIDs
                  or (e.District__c = :pcSector.Sub_Patch__r.District__c and Works_Anywhere_In_District__c = true)  
                    //Cognizant support fix - If employee works anywhere in district
                    //rjd - 2010-01-06 - changing to allow filtering on employee_postcodes__r.type=primary - Not required.
                                    or (e.District__r.Region__c = :pcSector.Sub_Patch__r.District__r.Region__c 
                                        and Works_Anywhere_In_Area__c = true)
                                    )
                                    and Resource_Type__c = :SearchBlackBox.EMPLOYEE_RESOURCE_TYPE
                                    and Inactive__c = false and Is_Active_Salesforce_User__c = 'true'];
                                    
             
             //PH Jones change - Get overbooking Excettion details form the employee if exists.
             map<id,decimal> empIdOverBKHousMap = new map<id,decimal>();
             if(jobInfo.job.Overbooking_Identifier__c != 'NA')
             {
                 set<id> empIdsList = new set<id>();
                 for(Employee__c emp : employeeList){
                     empIdsList.add(emp.Id);
                 }
                 
                 for(OverbookingException__c obe : [select Overbooking_Identifier__c , Employee__c, Hours__c  from OverbookingException__c where Employee__c in :empIdsList and Overbooking_Identifier__c = :jobInfo.job.Overbooking_Identifier__c and Hours__c >0 ])
                 {
                     empIdOverBKHousMap.put(obe.Employee__c, obe.Hours__c);
                 }
             }
                                            
            for(Employee__c e : employeeList)
            {
                                        
                  if(cls_isRun.isPortal==true && e.Skip_Rule__c==true)
                  continue;
                  
                  decimal overBookingExpHours = empIdOverBKHousMap.containskey(e.id)? empIdOverBKHousMap.get(e.Id):0.00;
                  
            // This employee covers this area, put the employee into a Map. Note that though he covers the area, he may not 
            // have skills or availability for this Job - that is determined in the next step.
            
            //System.debug(LoggingLevel.INFO, 'Found '+e.name+'---'+e);
      //Cognizant support fix - Geography fix.
      if(e.Works_Anywhere_In_Area__c && e.District__r.Region__c == jobInfo.jobArea){
                //System.debug(LoggingLevel.INFO, 'Works_Anywhere_In_Area__c adding '+e.Name);
                
                addEmployee(e, overBookingExpHours);
            }
      //Cognizant support fix - Geography fix.
      else if(e.Works_Anywhere_In_District__c && e.District__c == jobInfo.jobDistrict){
                System.debug(LoggingLevel.INFO, 'Works_Anywhere_In_District__c adding '+e.Name);
                addEmployee(e, overBookingExpHours);
            }
            else if(e.Employee_Postcodes__r.size() > 0){
      
     // Cognizant support fix - Geography fix.
     // An employee can have multiple postcode secotors whose code is equal to job postcode sector but of 
     // different types and different date ranges.
     // We do not consider this scenario because it is a huge code change.
     // Rather if an employee is having job postcode sector within any of two date windows we add him in.
     // His first postcode sector will be considered as his default geography type irrespective of date when 
     // he is bening retuned by search.
     
                if(e.Employee_Postcodes__r[0].type__c == 'primary'){
                    //System.debug(LoggingLevel.INFO, 'Employee_Postcodes__r[0].type__c == primary adding '+e.Name);
                    addEmployee(e, overBookingExpHours);
                }else if(e.Employee_Postcodes__r[0].type__c == 'secondary'){
                    //System.debug(LoggingLevel.INFO, 'Employee_Postcodes__r[0].type__c == secondary adding '+e.Name);
                    addEmployee(e, overBookingExpHours);
                } else if(e.Employee_Postcodes__r[0].type__c == 'Away') {
                    // Temporary fix for Away geographies
                    addEmployee(e, overBookingExpHours);
                }
            }
            else{
                //System.debug(LoggingLevel.INFO, 'empIDs -----'+empIDs);
                for(Id i : empIDs){
                    System.debug(e.id);
                    if(e.id == i){
                        //System.debug(LoggingLevel.INFO, 'empIDs adding '+e.Name);
                        addEmployee(e, overBookingExpHours);
                    }
                        
                }
                
            }
            //addEmployee(e);
        }
        
        // Defect XXX
        // Check for Employee Postcode Sectors that are of type Away and not for the postcode sector for this job.
        // These will represent times where an employee who has a postcode sector for this area is NOT working in this area.
        // We loop over these postcode sectors and store their start and end times on the relevant EmployeeInformation object
        for(Employee_Postcode_Sectors__c epcs : [select Type__c, Start_Date__c, End_Date__c, Employee__c, Postcode_Sector__r.Name,
                                                 Postcode_Sector__r.Sub_Patch__r.District__r.Region__c,Postcode_Sector__r.Sub_Patch__r.District__c
                                                 from Employee_Postcode_Sectors__c 
                                                 where Type__c = 'Away'
                                                    and Employee__c in :employeeIDs //:checkForAwayGeography - check all employees
                                                    and Postcode_Sector__c != :pcSector.ID
                                                    and ((Start_Date__c < :todaysDatepluswindow and End_Date__c > :todaysDate)
                                                        or (Start_Date__c < :custsDatepluswindow and End_Date__c > :custsDate))]) {
            EmployeeInformation ei = employees.get(epcs.Employee__c);
            // If this start date is not in the map on the EmployeeInformation object, or if it is in the map and the end date associated
            // with it is earlier than the one on this Employee Postcode Sector, put the values into the map.
            // The reason we check if the one in the map is earlier or not is in the case where there is more than 1 away geography that start
            // at the same time, the one with the latest end time is kept in the map, as this will represent both of them anyway. 
            if(!ei.availability.awayGeographyStartEnd.containsKey(epcs.Start_Date__c)
                || (ei.availability.awayGeographyStartEnd.containsKey(epcs.Start_Date__c) 
                && ei.availability.awayGeographyStartEnd.get(epcs.Start_Date__c) < epcs.End_Date__c)) {
                
                // Cognizant support - Code Fix - Phil Dennison
                
                // If an employee is added in employeeinformation as 'Away' geography 
                // then he should be considered as avaibale candidate for the job even if he is away for some 
                // other postcode sector for the same duration of time.
                
                // Also if by mistake planner marks emplpoyee as away in the same district & if employee works anywhere in the district
                // or in the same region and employee works anywhre in the region then 
                // he should be considered as available candidate on the job.
                
                System.debug(LoggingLevel.INFO, 'Employee id is: ' + ei.employeeID);
                
                if(ei.geographyType == 'Away'){
                    continue;
                }else if(ei.anywhereInDistrict && epcs.Postcode_Sector__r.Sub_Patch__r.District__c == ei.district){
                    continue;
                }else if(ei.anywhereInArea && epcs.Postcode_Sector__r.Sub_Patch__r.District__r.Region__c == ei.region){
                    continue;
                }
                
                ei.availability.awayGeographyStartEnd.put(epcs.Start_Date__c, epcs.End_Date__c);
                
            }
        }
    }
    
    
    /* addEmployeeSkills()
        Extracts information about employee skills and stores it against the relevant EmployeeInformation object. */
    public void addEmployeeSkills() {
        // Get the skills required for this job
        Set<String> jobSkills = jobInfo.skillsAndHours.keySet();
        
        Set<ID> alreadyAdded = new Set<ID>();
        
        set<id> employeesTobeRemoved = new set<Id>();
        system.debug('testing installer'+employeeIDs.contains('a0Aw000002WGKkhEAH'));
       

        for(Employee_Skills__c skill : [select Employee__c, Skill_Name__c, Skill_Type__c, Own_Jobs_Only__c, ID 
                                        from Employee_Skills__c 
                                        where Employee__c IN :employeeIDs
                                        and Skill_Name__c IN :jobSkills]) 
        {
            // Get the EmployeeInformation object for the Employee this skill belongs to 
            // and the number of hours for the skill on the job.
            EmployeeInformation ei = employees.get(skill.Employee__c);
            String skillName = skill.Skill_Name__c.toUpperCase();
           
            // Named skills - CR - Starts
            if(jobInfo.namedSkillSet != null){
                
              if(jobInfo.namedSkillSet.contains(skillName)){
                
                if(jobInfo.namedSkillEmpMap.get(skillName).size() == 1)
                        if(jobInfo.namedSkillEmpMap.get(skillName)[0] != skill.Employee__c)
                           continue;
                           
                if(jobInfo.namedSkillEmpMap.get(skillName).size() == 2)
                        if(jobInfo.namedSkillEmpMap.get(skillName)[0] != skill.Employee__c &&
                               jobInfo.namedSkillEmpMap.get(skillName)[1] != skill.Employee__c)
                                continue;
                                
               }
              
            }
            // Named skills - CR - Ends
            System.debug('###SkillName###'+skillName);
            
            Double hoursForSkill= jobInfo.skillsAndHours.get(skillName);
            
            // If this is not a skill planned from the end and the employee has not already had this skill added,
            // update the information on the EmployeeInformation object. 
            if(jobInfo.skillsAndHours.containskey(skillName) &&!SearchBlackBox.SKILLS_PLANNED_FROM_END.contains(skillName) && !ei.skills.contains(skillName)) {
                System.debug('###SkillDebug###'+ei.hoursAbleToFulfil  +'###'+hoursForSkill);
                ei.hoursAbleToFulfil += hoursForSkill;
                
                ei.skills.add(skillName);
            }
            
            // Add the skill and hours to the object. Note that ei.skills only holds skills that are not planned from 
            // the end, and skillsAndHours contains skils that are and are not planned from the end.
            ei.skillsAndHours.put(skillName, hoursForSkill);
            ei.skillsAndODOMJ.put(skillName, skill.Own_Jobs_Only__c);
           
            if(jobInfo.namedSkillSet != null){
              if(jobInfo.namedSkillSet.contains(skillName)){
                  ei.skillsAndODOMJ.put(skillName,false);
              }
            }
            
            // Add this employee ID against this skill - this allows easy access to employee IDs with a particular skill
            Set<ID> temp = employeeIDsBySkill.containsKey(skillName) 
                            ? employeeIDsBySkill.get(skillName) 
                            : new Set<ID>();
            temp.add(ei.employeeID);
            employeeIDsBySkill.put(skillName, temp);
            system.debug('employeeIDsBySkill -->'+employeeIDsBySkill) ;
            
            // If this skill matches the job's primary skill, and the employee is the right resource type for this job (i.e.
            // is own labor/a contractor for a job that needs that type of labour), add the Employee ID to a couple of lists
            if(skillName == jobInfo.primarySkill && ei.isRightResourceTypeForPrimary() ) {

                
                if(alreadyAdded.contains(ei.employeeID)) { // Fix for the case where an employee has the primary skill twice
                    continue;
                }

                /*
                    Simple skill change.
                    Code checks the primary employee can do all the simple skills job before proceeding if not they will be removed.

                */
                
                if(jobInfo.simpleSkills.size()>0 && employeeIdWithOptOutSkill.containsKey(ei.employeeID))
                {
                    for(string s: jobInfo.simpleSkills)
                    {
                        system.debug('Simpmle skill being checked'+s+' '+employeeIdWithOptOutSkill);
                        if(employeeIdWithOptOutSkill.get(ei.employeeID).contains(s))
                        {
                            system.debug('Simpmle skill found'+ei.employeeID);
                            employeesTobeRemoved.add(ei.employeeID);
                            break;

                        }
                    }
                }
                if(employeesTobeRemoved.contains(ei.employeeID))
                continue;
                
                //System.debug(LoggingLevel.INFO, 'has primary skill: ' + ei.employeeName);
                
                //System.debug(LoggingLevel.INFO, 'adding: ' + ei.employeeName);
                system.debug('Adding Employee id '+ei.employeeID);
                employeesWithPrimarySkill.add(ei.employeeID);
                List<ID> currentList = primaryBySupplierID.containsKey(ei.supplierID) ? primaryBySupplierID.get(ei.supplierID) 
                                                                                    : new List<ID>();
                currentList.add(ei.employeeID);
                primaryBySupplierID.put(ei.supplierID, currentList);
                alreadyAdded.add(ei.employeeID);
            }
            
            
        }
        
        //Suguna- Where roof work exists AND there is scaffolding,ignore the check for the roof skill done on the mechanical installer.
        //if(jobInfo.job.Roof_Work_Hours__c>0&&JobInfo.job.Scaffolder_Hours__c>0&&System.Label.Scaffolding_override_for_Roof_skill=='on')
        if(jobInfo.job.Roof_Work_Hours__c>0&&JobInfo.job.Scaffolding_Required__c=='Yes'&&System.Label.Scaffolding_override_for_Roof_skill=='on')
        {  
            String SkillName ='ROOF WORK';
            Set<ID> mechInstallars = employeeIDsBySkill.containsKey('MECHANICAL')?employeeIDsBySkill.get('MECHANICAL'):new set<ID>();            
            set<ID> roofWorkers =  employeeIDsBySkill.containsKey(skillName) ? employeeIDsBySkill.get(skillName) : new Set<ID>();            
            roofWorkers.addAll(mechInstallars);
            employeeIDsBySkill.put(SkillName,roofWorkers);
        
            
            for(id empId :mechInstallars)
            {
                EmployeeInformation ei = employees.get(empId);
                ei.skills.add(SkillName);
                Double hoursForSkill1 = jobInfo.skillsAndHours.get(SkillName);
                ei.skillsAndHours.put(SkillName, hoursForSkill1);
                ei.skillsAndODOMJ.put(SkillName, true);
            }
        }
        //ends
        
        system.debug('Employees to be remove ->'+employeesTobeRemoved) ;
        system.debug('Employees to be added ->'+employeesWithPrimarySkill);
        if(employeesTobeRemoved.size()>0)
        {
            removeEmployees(employeesTobeRemoved);
        }
        //System.debug(LoggingLevel.INFO, 'primary suppliers: ' + primaryBySupplierID.keySet());
        
        // gjb 2010-02-12 check that the named employee has the primary skill, if not, throw exception.
        if(jobInfo.namedEmployee != null && !employeesWithPrimarySkill.contains(jobInfo.namedEmployee)) {
            throw new SearchWorker.SearchException('Named employee does not have primary skill for this job.');
        }
    }
    
    /* addEmployeeAvailability()
        Extracts infromation from the database about Employee availability and stores it against the related 
        EmployeeInformation and EmployeeAvailability objects. */
    public void addEmployeeAvailability() {
        // Construct date information
//rjd - 2010-01-08 - this looks a little weird... Why 3 o'clock am ??
        Time t = Time.newInstance(3,0,0,0);
        Datetime custsDate = bo.customerPreferredDate != null 
                                    ? Datetime.newInstance(bo.customerPreferredDate, t) 
                                    : Datetime.newInstance(Date.today(), t);
        Datetime todaysDate = Datetime.newInstance(Date.today(), t);
        Datetime todayPlusWindow = todaysDate.addDays(bo.schedulingWindow);
        Datetime custsDatePlusWindow = custsDate.addDays(bo.schedulingWindow);
        
        //Change By Ashok G
        Datetime FinanceExpDate = bo.FinanceExpdate != null
                                    ? Datetime.newInstance(bo.FinanceExpDate, t)
                                    : null;
        /*Datetime FinanceExpDate = null;
        
        if(FinExpDate != null)
        FinanceExpDate = Datetime.newInstance(bo.FinanceExpDate, t);
        */
        if(FinanceExpDate != null){
           if(todayPlusWindow > FinanceExpDate)
           todayPlusWindow = FinanceExpDate;
           
           if(custsDatePlusWindow > FinanceExpDate)
           custsDatePlusWindow = FinanceExpDate;
        }
        
        
        // For employees, extract their availability and shift patterns from
        //  - today until today + scheduling window
        //  - customer's preferred date until customer's preferred date + scheduling window
        
        Set<ID> found = populateEmployeeAvailability(todaysDate, todayPlusWindow, SearchBlackBox.jobID, true);
        found.addAll(populateEmployeeAvailability(custsDate, custsDatePlusWindow, SearchBlackBox.jobID, false));

        // There may be Employees that have been extracted that do not have availability - we now remove
        // those that do not have availability from the relevant collections
        
        Set<ID> employeesWithoutAvailability = employeeIDs.clone();
        employeesWithoutAvailability.removeAll(found);
        employeeIDs.removeAll(employeesWithoutAvailability);
        employeesWithPrimarySkill.removeAll(employeesWithoutAvailability);
        
        if(jobInfo.namedEmployee != null) {
            System.debug(LoggingLevel.INFO, 'GB: ' + jobInfo.namedEmployee);
            if(employeesWithoutAvailability.contains(jobInfo.namedEmployee)) {
                throw new SearchWorker.SearchException('Named resource on Job does not have suitable availability.');
            }
        }
        
        //System.debug(LoggingLevel.INFO, 'employeesWithoutAvailability: ' + employeesWithoutAvailability);
        
        for(ID empID : employeesWithoutAvailability) {
            employees.remove(empID);
        }
        
        // Remove employees without availability from supplier lists as well
        for(ID primarySupplier : primaryBySupplierID.keySet()) {
            List<ID> primaryCandidatesFromSupplier = primaryBySupplierID.get(primarySupplier);
            //System.debug(LoggingLevel.INFO, 'primaryCandidatesFromSupplier: ' + primaryCandidatesFromSupplier);
            List<ID> newList = new List<ID>();
            for(Integer i = 0; i < primaryCandidatesFromSupplier.size() ; i++) {
                if(!employeesWithoutAvailability.contains(primaryCandidatesFromSupplier[i])) {
                    newList.add(primaryCandidatesFromSupplier[i]);
                }
            }
            primaryBySupplierID.put(primarySupplier, newList);
        }
        
        // Finally, remove employees without availability from employeeIDsBySkill sets. 
        for(String skill : employeeIDsBySkill.keySet()) {
            //System.debug(LoggingLevel.INFO, 'skill is: ' + skill);
            Set<ID> temp = employeeIDsBySkill.get(skill);
            temp.removeAll(employeesWithoutAvailability);
        }
    }
    
    /* populateEmployeeAvailability(Datetime first, Datetime second, ID jobID, Boolean isBusiness)
        This method retrieves the relevant Diary Entries for employees with relevant skills for the job and creates
        EmployeeAvailability against the relevant EmployeeInformation. This method was created to make the 
        addEmployeeAvailability method more managable and readable.
        
        This method returns a Set of IDs indicating Employees who had suitable availability found. */
    private Set<ID> populateEmployeeAvailability(Datetime first, Datetime second, ID jobID, Boolean isBusiness) {
        // Set to hold IDs of employees with availability.
        Set<ID> found = new Set<ID>();
          system.debug('startTime '+second);
          system.debug('endTime '+first);
        // The query retrieves Diary Entries ordered by Employee and then by Start Date. 
        // The logic loops over retrieved Diary Entries, storing them in a list until the Employee they belong to changes.
        // The list is then passed to the appropriate method to create availability models. 
        List<Diary_Entry__c> currentEmployeesDEs = new List<Diary_Entry__c>();
        ID previousEmpID = null;
        
        List<Employee_Postcode_Sectors__c> empPostcodeSectors = new List<Employee_Postcode_Sectors__c>();
        String userId = Userinfo.getUserId();
        for(Diary_Entry__c entry : [select d.ID, d.Week__c, d.Hours__c, d.Week__r.Employee__c, d.Week__r.Employee__r.Always_Works_With__c, d.Start__c, d.End__c, d.Record_Type__c,d.Week__r.Employee__r.Always_Works_With_Electrician__c,
                                    d.Week__r.Shift_Pattern__r.Monday_Start_Time__c, d.Week__r.Shift_Pattern__r.Monday_End_Time__c,d.Week__r.Morning_Start_Time__c,d.Week__r.Mid_day_Start_Time__c,
                                    d.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Tuesday_End_Time__c,
                                    d.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Wednesday_End_Time__c,
                                    d.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, d.Week__r.Shift_Pattern__r.Thursday_End_Time__c,
                                    d.Week__r.Shift_Pattern__r.Friday_Start_Time__c, d.Week__r.Shift_Pattern__r.Friday_End_Time__c,
                                    d.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, d.Week__r.Shift_Pattern__r.Saturday_End_Time__c,
                                    d.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, d.Week__r.Shift_Pattern__r.Sunday_End_Time__c,
                                    d.Week__r.Monday_Available_Hours__c, d.Week__r.Tuesday_Available_Hours__c, d.Week__r.Wednesday_Available_Hours__c,
                                    d.Week__r.Thursday_Available_Hours__c, d.Week__r.Friday_Available_Hours__c, d.Week__r.Saturday_Available_Hours__c,
                                    d.Week__r.Sunday_Available_Hours__c, d.Job__c,d.Week__r.Employee__r.Name , d.Week__r.Locking_User__c,Week__r.Release_Date__c,d.Week__r.Lockers1__c,
                                    Week__r.Category_Num__c/*,week__r.employee__r.over_booking_hours__c*/
                                    from Diary_Entry__c d 
                                    where   (    
                                                d.Start__c <= :second and d.End__c >= :first
                                                and
                                                (
                                                    (d.Job__c = :jobID and d.Week__r.Employee__r.Inactive__c = false and d.Week__r.Employee__r.Is_Active_Salesforce_User__c = 'true') or
                                                    (d.Week__r.Employee__c IN :employeeIDs
                                                        and ((d.Record_Type__c = :SearchBlackBox.GAP_DIARY_ENTRY_TYPE )
                                                            or 
                                                            (d.Record_Type__c = :SearchBlackBox.UNAVAILABILITY_DIARY_ENTRY_TYPE AND d.Sub_Type__c != 'NWD - Working'))
                                                    )
                                                ) and d.Hours__c != 0.00 //PRB00029837
                                            ) order by d.Week__r.Employee__c, d.Start__c]){
                                                
         system.debug('diaryEntry '+entry);
                                                
         //Cognizant Support Fix - Geography fix.
         //Check for employee postcode start and end date
         
         // ++ Added for Week lock change start
         // Week Reserve Change- Winter Changes - Start
         string jobCateogry = jobInfo.job.Latest_Customer_Category__c;
         id profileId = userinfo.getProfileId();
         
         if(!system.label.SystemAdminId.contains(profileId) && entry.Week__r.Locking_User__c != null && entry.Week__r.Locking_User__c != userId
           ||(entry.Week__r.Release_Date__c == null && entry.Week__r.Category_Num__c  < jobCateogry)
           ||(entry.Week__r.Release_Date__c != null &&  entry.Week__r.Release_Date__c > system.today() && entry.Week__r.Category_Num__c  < jobCateogry)
           || (entry.Week__r.lockers1__c!=null && (!entry.Week__r.lockers1__c.contains(userinfo.getusername()))))
         {
            continue;
         }
         // -- Added for Week lock change end
         // Week Reserve Change- Winter Changes - End
         try{
            
         EmployeeInformation ei_ecp = employees.get(entry.Week__r.Employee__c);  
         
         
               
         if(!(ei_ecp.anywhereInArea && ei_ecp.region == jobInfo.jobArea)
             &&
            !(ei_ecp.anywhereInDistrict && ei_ecp.district == jobInfo.jobDistrict) 
             &&
             (entry.Record_Type__c == SearchBlackBox.GAP_DIARY_ENTRY_TYPE) 
             &&
            !(ei_ecp.isPool)){
                
                empPostcodeSectors = ei_ecp.empJobPostcodeSectors;
               
                if(empPostcodeSectors!=null && ei_ecp.alwaysWorksWith!=null){
                    if(entry.Week__r.Employee__r.Always_Works_With__c!=null)
                    if(employees.get(entry.Week__r.Employee__r.Always_Works_With__c)!=null)
                    if(employees.get(entry.Week__r.Employee__r.Always_Works_With__c).empJobPostcodeSectors!=null)
                    empPostcodeSectors.addAll(employees.get(entry.Week__r.Employee__r.Always_Works_With__c).empJobPostcodeSectors);
                }
                
                 //Suguna - Always Works with Electrician
                 if(empPostcodeSectors!=null && ei_ecp.alwaysWorksWithElectrician!=null){
                    if(entry.Week__r.Employee__r.Always_Works_With_Electrician__c!=null)
                    if(employees.get(entry.Week__r.Employee__r.Always_Works_With_Electrician__c)!=null)
                    if(employees.get(entry.Week__r.Employee__r.Always_Works_With_Electrician__c).empJobPostcodeSectors!=null)
                    empPostcodeSectors.addAll(employees.get(entry.Week__r.Employee__r.Always_Works_With_Electrician__c).empJobPostcodeSectors);
                }
             
             boolean toBeConsidered = false;
         map<string, Id> availabliltyIdMap = new map<string, Id>();
             for(Employee_Postcode_Sectors__c empc:empPostcodeSectors){
               
                if((((empc.Start_Date__c <= entry.Start__c.date() && empc.End_Date__c >= entry.End__c.date())
                  || (empc.Start_Date__c >= entry.Start__c.date() && empc.Start_Date__c <= entry.End__c.date())
                  || (empc.End_Date__c >= entry.Start__c.date() && empc.End_Date__c <= entry.End__c.date()))  )){
                    
                    if(empc.Type__c == 'Away' && empc.Postcode_Sector__r.Name != jobInfo.postcodeSector)
                    {
                      toBeConsidered = false;
                      break;
                       
                    }else
                  {
                    toBeConsidered = true;
                  }
                }
               /*
               toBeConsidered = true;
                if((!((empc.Start_Date__c <= entry.Start__c.date() && empc.End_Date__c >= entry.End__c.date())
                  || (empc.Start_Date__c >= entry.Start__c.date() && empc.Start_Date__c <= entry.End__c.date())
                  || (empc.End_Date__c >= entry.Start__c.date() && empc.End_Date__c <= entry.End__c.date())))){
                    
                    if(!availabliltyIdMap.containskey(empc.Name))
                       toBeConsidered = false;
                   else if(entry.Id != availabliltyIdMap.get(empc.Name))
                   {
                       toBeConsidered = false;
                   }
                }else
                {
                  
                  availabliltyIdMap.put(empc.Name,entry.Id); 
                  toBeConsidered = true;
                }
                availabliltyIdMap.clear();
                */
             }   
            
            // Fix for named employee or someone who always works with named employee - Starts
            if(jobInfo.namedEmployee != null) {
                 if(jobInfo.namedEmployee == entry.Week__r.Employee__c){
                    toBeConsidered = true;
                     }
                }
           if(jobInfo.namedEmployeeAWW != null) {
                 if(jobInfo.namedEmployeeAWW == entry.Week__r.Employee__c){
                   toBeConsidered = true;
                     }
           }
          // Fix for named employee or someone who always works with named employee - Ends 
            
            if(!toBeConsidered){
                
                  continue;
                  
            }
            
         }
         
      } // try ends here 
      catch(Exception excp){
        
        //error occured go to next diary entry.
       // continue doing what we were doing before this fix.
        
      }
                                                
            if(previousEmpID == null) {
                // this should only happen on the first loop
                previousEmpID = entry.Week__r.Employee__c;
            } else if(previousEmpID != entry.Week__r.Employee__c) {
                // Employee on this Diary Entry does not match the previous Employee.
                EmployeeInformation ei = employees.get(previousEmpID);
                // Pass the availability in the list to theaddAvailability method... 
//                try{ 

                // This try/catch is a temporary fix to handle incorrect data - if the shift pattern data
                // causes an exception, catch it and move onto the next person. Because the employee
                // will not be added to the "found" set, this employee should not be considered
                // in the search.
                try {
                    if(ei == null){
                    System.debug(LoggingLevel.INFO,'Employee information object is null for : '+previousEmpID);}
                    if(ei.availability == null){
                    System.debug(LoggingLevel.INFO,'Employee availability object is null for : '+previousEmpID);}
                    system.debug(LoggingLevel.INFO,'Line 754:'+currentEmployeesDEs+' '+isBusiness);
                    ei.availability.addAvailability(currentEmployeesDEs, isBusiness);
                } catch (DateTimeHelper.ShiftException exc) {
                    System.debug(LoggingLevel.INFO, 'DateTimeHelper.ShiftException');
                    currentEmployeesDEs.clear();
                    previousEmpID = entry.Week__r.Employee__c;
                    continue;
                }
//                }catch(Exception ex){
//                  throw new EmployeeException('An exception has been caught for employee' + entry.Week__r.Employee__r.Name+' : '+ex.getMessage());
//                }

                // If the employee has availability, add their ID to "found". We check if the employee has a "largest" gap
                // for this availability type (business/customer). If not, he has no availability
                if(ei.availability.getLargest(isBusiness) != null) {
                    found.add(previousEmpID);
                    // Defect 233
                    if(isBusiness) {
                        skillsCoveredForBusinessBest.addAll(ei.skillsAndHours.keySet());
                    } else {
                        skillsCoveredForCustomerPreferred.addAll(ei.skillsAndHours.keySet());
                    }
                    // End Defect 233
                }

                // .. clear the list
                currentEmployeesDEs.clear();
                // update the previousEmpID 
                previousEmpID = entry.Week__r.Employee__c;
            }
            currentEmployeesDEs.add(entry);
        }

        // When the loop is finished, there may be Diary Entries belonging to the last employee that need adding  
        if(previousEmpID != null) {
            EmployeeInformation ei = employees.get(previousEmpID);
            // This try/catch is a temporary fix to handle incorrect data - see note before 
            // try/catch in above loop 
            try {
                system.debug(LoggingLevel.INFO,'Line 792:'+currentEmployeesDEs+' '+isBusiness);
                ei.availability.addAvailability(currentEmployeesDEs, isBusiness);
                if(ei.availability.getLargest(isBusiness) != null) {
                    found.add(previousEmpID);
                    // Defect 233
                    if(isBusiness) {
                        skillsCoveredForBusinessBest.addAll(ei.skillsAndHours.keySet());
                    } else {
                        skillsCoveredForCustomerPreferred.addAll(ei.skillsAndHours.keySet());
                    }
                    // End defect 233
                }
            } catch (DateTimeHelper.ShiftException exc) {
                System.debug(LoggingLevel.INFO, 'DateTimeHelper.ShiftException');
                // Do nothing
            }
        }
        
        system.debug('diaryEntry found '+found);
        return found;
    }
    
    public class EmployeeException extends System.Exception{}
   
   //Cognizant support fix - Geography fix.
  // Added this new method
   
    public void populateEmployeePostcodeSectors()
    {
      
      //Date todaysDate = Date.today();
      Date todaysDate =date.newinstance(2018,12,30).adddays(0);
      Date custsDate = bo.customerPreferredDate;
      Integer window = bo.schedulingWindow;
      
      Date FinanceExpDate = bo.FinanceExpDate;
      //Change By Ashok G
      Date todaysDatepluswindow = todaysDate.addDays(window);
      Date custsDatepluswindow = custsdate.addDays(window);
      if(FinanceExpDate != null)
      {
        if(custsDatepluswindow > FinanceExpDate)
        custsDatepluswindow = FinanceExpDate;
        
        if(todaysDatePlusWindow > FinanceExpDate)
        todaysDatePlusWindow = FinanceExpDate;
      }
      //Change END
      
      
      
     
      Postcode_Sector__c[] sectors = 
              [select ID, 
               (select Employee__c, Employee__r.Id, Start_Date__c, End_Date__c, Postcode_Sector__r.Name
                 from Employee_Postcodes__r 
                 where ((Start_Date__c <= :todaysDate and End_Date__c >= :todaysDatepluswindow)
                     or (Start_Date__c >= :todaysDate and Start_Date__c <= :todaysDatepluswindow)
                     or (End_Date__c >= :todaysDate and End_Date__c <= :todaysDatepluswindow)
                     or (Start_Date__c <= :custsDate and End_Date__c >= :custsDatepluswindow)
                     or (Start_Date__c >= :custsDate and Start_Date__c <= :custsDatepluswindow)
                     or (End_Date__c >= :custsDate and End_Date__c <= :custsDatepluswindow))
                     and Employee__r.Inactive__c = false // only get active employees
                     and Employee__r.Is_Active_Salesforce_User__c = 'true'
              ) 
          from Postcode_Sector__c p where p.Name=:jobInfo.postcodeSector 
                        and p.Type__c=:SearchBlackBox.PC_SECTOR_TYPE];
    
    if(sectors.size() == 0) {
       return;
    }else if (sectors.size() > 1) {
       return;    
    }
    
    Postcode_Sector__c pcSector  = sectors[0];
    
    Map<Id, List<Employee_Postcode_Sectors__c>> empAndEmpPostcodeSectorMap = new Map<Id, List<Employee_Postcode_Sectors__c>>();
    
    List<Employee_Postcode_Sectors__c> tmpEmployeePostcodeSectors = new List<Employee_Postcode_Sectors__c>();
    
      for(Employee_Postcode_Sectors__c[] employeePostcodes : pcSector.Employee_Postcodes__r) {
         for(Employee_Postcode_Sectors__c employeePostcode : employeePostcodes) {
            if(empAndEmpPostcodeSectorMap.get(employeePostcode.Employee__r.Id)==null){
               empAndEmpPostcodeSectorMap.put(employeePostcode.Employee__r.Id,new List<Employee_Postcode_Sectors__c>{employeePostcode});
            }else{
                   tmpEmployeePostcodeSectors = empAndEmpPostcodeSectorMap.get(employeePostcode.Employee__r.Id);
                   tmpEmployeePostcodeSectors.add(employeePostcode);
                   empAndEmpPostcodeSectorMap.put(employeePostcode.Employee__r.Id,tmpEmployeePostcodeSectors);
             }
          }
      }
    for(ID empID : empAndEmpPostcodeSectorMap.keySet()) {
        EmployeeInformation ei = employees.get(empID);
        if(ei!=null && empAndEmpPostcodeSectorMap.get(empID)!=null)
        ei.empJobPostcodeSectors = empAndEmpPostcodeSectorMap.get(empID);
    }
    
  }


  public void extractEmployeesWithSimpleSkills()
  {
    // Get the skills required for this job
        list<String> jobSkills = jobInfo.simpleSkills;
        system.debug('job Skills -->'+jobSkills);
        //Set<ID> alreadyAdded = new Set<ID>();
        
        for(Optout_Skill__c skill : [select Employee__c, Skill__c
                                        from Optout_Skill__c where Skill__c IN :jobSkills
                                        and Employee__r.Inactive__c = false]) {
            if(!employeeIdWithOptOutSkill.containskey(skill.Employee__c))
            employeeIdWithOptOutSkill.put(skill.Employee__c, new set<string>{skill.Skill__c});
            else
            employeeIdWithOptOutSkill.get(skill.Employee__c ).add(skill.Skill__c);

        }

  }

 // New method ends here.
}