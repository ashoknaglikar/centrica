/* EmployeeInformation
  A class that holds information about an Employee, as well as some helper
  methods that can be used by the search black box. 
*/
public with sharing class EmployeeInformation {
  
  // Employee attributes
  public boolean anywhereInDistrict {get; set;}
  public boolean anywhereInArea {get; set;}
  public boolean isPool {get; set;}
  public boolean alwaysWorksAlone {get; set;}
  public boolean ownLabour {get; set;}
  public ID employeeID {get; set;}
  public ID supplierID {get; set;}
  public ID alwaysWorksWith {get; set;}
  public ID neverWorksWith {get; set;}
  public ID region {get; set;}
  public ID district {get; set;}
  public String employeeName {get; set;}
  public String supplierName {get; set;}
  public String districtName {get; set;}
  public String geographyType {get; set;}
  public String resourceType {get; set;}
  public Double nps {get; set;}
  public boolean skipRule {get;set;}
  public double overBookingExpHours {get;set;}
  public ID alwaysWorksWithElectrician {get; set;}
  
  public String employeeNumber{get;set;}
  //public String status {get;set;}
  //Google Distance Finder Change
  public String employeePostCode {get; set;}
  
  // Information about the skills (and hours) this employee can do on this job.
  public Set<String> skills = new Set<String>(); // ONLY contains skills planned from start
  public set<string> simpleSkills = new set<string>();
  public Map<String, Double> skillsAndHours = new Map<String, Double>(); // INCLUDES skills planned from end
  public Double hoursAbleToFulfil = 0.0; // Hours this employee can do on this job if he does all the skills he can fulfil 
  // ODOMJ = Only Do On My Job - basically a map with this employee's skills as the key
  // and whether the skill is ODOMJ as the value. If true, then this employee will only
  // do the skill where he is a primary candidate  on a job.
  public Map<String, Boolean> skillsAndODOMJ = new Map<String, Boolean>(); 
  public EmployeeAvailability availability = new EmployeeAvailability(this);

    // Cognizant support fix - Geography fix.
    public List<Employee_Postcode_Sectors__c> empJobPostcodeSectors = new List<Employee_Postcode_Sectors__c>();
    

  /* EmployeeInformation(Employee__c e)
    Constructor. Takes an Employee sObject and sets the variables to the relevant values.  */
  public EmployeeInformation(Employee__c e) {
    overBookingExpHours = 0.00;
    // These should be self explanatory
    anywhereInDistrict  = e.Works_Anywhere_in_District__c;
    anywhereInArea  = e.Works_Anywhere_in_Area__c;
    isPool  = e.Pool_Diary__c;
    alwaysWorksAlone  = e.Always_Works_Alone__c;
    employeeID  = String.valueOf(e.ID).subString(0, 15); // TODO: is the substring needed?
    supplierID  = e.Supplier__c;
    alwaysWorksWith  = e.Always_Works_With__c;
    neverWorksWith  = e.Never_Works_With__c;
    region  = e.District__r.Region__c;
    district  = e.District__c;
    employeeName  = e.Name;
    supplierName  = e.Supplier__r.Name;
    districtName  = e.District__r.Name;
    nps = e.Net_Promoter_Score__c;
    employeePostCode = e.Postcode__c;
    skipRule = e.Skip_Rule__c;
    employeeNumber = e.Employee_Number__c;
    alwaysWorksWithElectrician = e.Always_Works_with_Electrician__c;
    //Change By Ashok G
    //status = e.Inactive__c==TRUE?'InActive':'Active';
    
    /*System.debug(LoggingLevel.INFO, 'EmployeeInformation >>');
    System.debug(LoggingLevel.INFO, 'e.District__c: ' + e.District__c);
    System.debug(LoggingLevel.INFO, 'e.Employee_Postcodes__r.size(): ' + e.Employee_Postcodes__r.size());
    System.debug(LoggingLevel.INFO, 'SearchBlackBox.jobInfo.jobDistrict: ' + SearchBlackBox.jobInfo.jobDistrict);
    System.debug(LoggingLevel.INFO, 'SearchBlackBox.jobInfo.jobArea: ' + SearchBlackBox.jobInfo.jobArea);*/
    System.debug(LoggingLevel.INFO, 'SearchBlackBox.jobInfo.namedEmployee: ' +SearchBlackBox.jobInfo.namedEmployee+' '+e.id);
    if(SearchBlackBox.jobInfo.job.Named_Employee_2__c!=null && SearchBlackBox.jobInfo.namedEmployee == e.id){
      alwaysWorksWith =  SearchBlackBox.jobInfo.job.Named_Employee_2__c;
      alwaysWorksAlone = false;
    }
   
   
    // Determine the geography type for this employee.
    if(e.Employee_Postcodes__r != null && e.Employee_Postcodes__r.size() > 0) {
      // 1. If she has Employee Postcode Sectors, get the geography from those.
      // TODO - Can we do this or should we do it on EmployeeAvailability/DEC instead?
      // PRB00026252 fix starts
      String js = JSON.serialize(e.Employee_Postcodes__r);
      boolean startdatechk = js.contains('Start_Date__c');
      boolean enddatechk = js.contains('End_Date__c');  
      Date todaysDate = Date.today();  
      if(SearchBlackBox.optsAndParms!= null){
      Date custsDate = SearchBlackBox.optsAndParms.customerPreferredDate;
              for(Employee_Postcode_Sectors__c empcodes :e.Employee_Postcodes__r){
                  system.debug(LoggingLevel.INFO, empcodes.Type__c+  startdatechk+ enddatechk+custsDate);
              if(startdatechk && enddatechk){              
                if((empcodes.Start_Date__c <= todaysDate  && empcodes.End_Date__c >= todaysDate) ||
                   (empcodes.Start_Date__c <= custsDate.adddays(integer.valueof(IV_Vectors__c.getInstance('Engineer Postcode Start Date Window').Key__c)) && empcodes.End_Date__c >= custsDate)){
                   geographyType = geographyType!=IV_Vectors__c.getInstance('Away').Key__c? empcodes.Type__c: 'Away';
                   //geographyType = empcodes.Type__c;
                   } 
                   }
                   }
                   system.debug(LoggingLevel.INFO, 'geographyType-->'+geographyType);}
       else{
       for(Employee_Postcode_Sectors__c empcode :e.Employee_Postcodes__r){ 
        if(startdatechk && enddatechk){       
        if(empcode.Start_Date__c <= todaysDate  && empcode.End_Date__c >= todaysDate) {
         geographyType = empcode.Type__c;
          }}}      
       }
             if(geographyType == null)
             {
             if(e.District__c == SearchBlackBox.jobInfo.jobDistrict) {
                geographyType = 'District';
                } else if(e.District__r.Region__c == SearchBlackBox.jobInfo.jobArea) {
                geographyType = 'Area';
                } else {
                geographyType = 'Off Patch';
                }    
             }      
       // PRB00026252 fix ends
    } else if(e.District__c == SearchBlackBox.jobInfo.jobDistrict) {
      // 2. If no Employee Postcode Sectors, does the employee cover this district?
      geographyType = 'District';
    } else if(e.District__r.Region__c == SearchBlackBox.jobInfo.jobArea) {
      // 3. If no EPS and does not cover the district, does the employee cover the Region/Area?
      geographyType = 'Area';
    } else {
      // Should only ever see this if the data is incorrect. If a user sees "Unknown" the data should be checked.
      geographyType = 'Off Patch';
    }
    
    // Set resource type - this is shown on a formula field on the Employee__c object; 1 = Own Labour, otherwise = Contractor 
    if(e.Own_Labour__c == 1) {
      resourceType = SearchBlackBox.OWN_LABOUR;
      ownLabour = true;
    } else {
      ownLabour = false;
      resourceType = SearchBlackBox.CONTRACTOR;
      if(e.Contractor_Band__c != null)
        resourceType += ' ' + e.Contractor_Band__c;
    }
      
    //System.debug(LoggingLevel.INFO, 'Create EmployeeInformation for: ' + employeeName);
  }  
  
  /* getHoursForSkills(Set<String> skills)
    A method that takes a Set of skills and returns the number of hours the employee can fulfil
    of those skills. This only counts hours for skills the employee can do. */
  public Double getHoursForSkills(Set<String> skillSet) {
    Double count = 0.0;
    for(String skill : skillSet) {
      if(skillsAndHours.containsKey(skill))
        count += skillsAndHours.get(skill);
    }
    return count;
  }
  
  /* getSkills(Set<String> skills)
    Takes a Set of skills and returns the skills within that Set that this Employee can fulfill. */
  public Set<String> getSkills(Set<String> skillSet) {
    Set<String> temp = skillSet.clone();
    temp.retainAll(skills);
    return temp; 
  }
  
  /* getSkillsNotODOMJ(Set<String> skills)
    Takes a Set of skills and returns the skills within that Set that the Employee has and that the
    Employee will do on jobs where he is not the primary resource i.e. skills where the corresponding 
    value in the skillsAndODOMJ Map is equal to false*/
  public Set<String> getSkillsNotODOMJ(Set<String> skillSet) {
    Set<String> results = new Set<String>();
    
    for(String skill : skillSet) {
      if(skillsAndODOMJ.containsKey(skill) && !skillsAndODOMJ.get(skill))
        results.add(skill);
    }
    return results; 
  }

  /* isRightResourceTypeForPrimary()
    Returns a boolean indicating whether this employee is of the right resource type to be considered a 
    primary candidate. For example, if the job options indicate Own Labour and this employee is a
    BGS employee, return true. If they are not a BGS employee and the job options indicate non-BGS 
    employees can be considered, return true. If either of these are not the case, return false. 
  */
  public boolean isRightResourceTypeForPrimary() {
    if(SearchBlackBox.optsAndParms.ownLabour && ownLabour)
      return true;
    if(SearchBlackBox.optsAndParms.contractors && !ownLabour)
      return true;
    return false;
  }

}