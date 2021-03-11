/* JobInformation

  A class that holds information about the Job being searched for.
  Primarily, this holds information about the skills and hours required for the job 

*/
public with sharing class JobInformation {

  public Job__c job = null;
  public String postcodeSector = null;
  public ID namedEmployee = null;
  // Named electritian change - Starts
  public ID namedElectritian = null;
  // Named electritian change - Ends
  public ID namedEmployeeAWW = null;
  public ID jobDistrict = null;
  public ID jobArea = null;
  public Map<String, Double> skillsAndHours = new Map<String, Double>(); 
  public list<string> simpleSkills = new list<string>();
  public list<string> optInSkills = new list<string>();
  public String primarySkill = null;
  public Double primaryHours = null;
  public Boolean isLocked = false;
  public Map<ID,ID> ExistngEntries = new Map<ID,ID>();
  public map<Id,List<DateTime>> wstartEndMap = new Map<Id,List<DateTime>>();
  //rjd - 2010-01-13 - adding if doublehanded
  public Boolean isDoubleHanded = false;
  //Defect 233
  public Boolean tooManyScriptStatements = false;
  
  // Cognizant - CHI Phase III CR-002 implementation... START 
  public AddNewSkill ObjNewSkill = new AddNewSkill();
  // Cognizant - CHI Phase III CR-002 implementation... END 
  
  // Named skills - CR - Starts
     public Set<String> namedSkillSet = new Set<String>();
     public Map<String,List<ID>> namedSkillEmpMap = new Map<String,List<ID>>();
  // Named skills - CR - Ends

  /* JobInformation(ID jobID)
    Constructor, taking a Job ID as a parameter. Calls setInformation to extract the relevant information from the Job. */  
  public JobInformation(ID jobID) {
    
    // Cognizant - CHI Phase III CR-002 implementation... START
         
    job = ObjNewSkill.fetchJobByJob(jobID);
    /*job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
            j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
            j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
            j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
            j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
            j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
            j.Named_Employee__r.Always_Works_With__c, job_locked__c, j.Too_Many_Script_Statements__c, 
            j.Override_Gap_Size_Tolerance__c, j.Named_Employee__r.Resource_Type__c
          
            from Job__c j where j.ID = :jobID];*/
      // Cognizant - CHI Phase III CR-002 implementation... END 
      
    setInformation();
  }
  
  /* setInformation()
    Extracts the relevant information from the Job, such as the skills required and the hours, named employees, 
    and determines the Job's primary skill. */
  public void setInformation() {
    
    isLocked = (job.Job_Locked__c=='Y');
    // Extract the relevant part of the Postcode for the postcode sector
    postcodeSector = job.CHI_Lead__r.Install_Postcode__c.subString(0, job.CHI_Lead__r.Install_Postcode__c.indexOf(' ')+2);

    // Look at each skill field and determine if there is any work on this job requried for it.
    // Skills and hours required for those skills are stored in a Map. This is done via if 
    // statements because of field names. The key values stored in the skillsAndHours Map are 
    // significant because they are used to look up Employee Skills - if the values in the 
    // Employee Skills dropdown change, they will also need to be changed here.   
    
    // Cognizant - CHI Phase III CR-002 implementation... START
        
        skillsAndHours = ObjNewSkill.setSkillHoursInfo(job, skillsAndHours);
        System.debug('skillsAndHours: ' + skillsAndHours);

        // simple skill change
        simpleSkills = ObjNewSkill.setSimpleSkills(job);
        optInSkills = ObjNewSkill.setOptInSkills(job);
        // Named skills - CR - Starts
        
           List<Job_Named_Skill_Resource__c> namedEmps = [Select Skill_Name__c,Employee__c,Employee__r.Always_Works_With__c from Job_Named_Skill_Resource__c where Job__c =: job.ID];
           if(namedEmps.size()>0){
             for(Job_Named_Skill_Resource__c j_Named_Resource_Skill : namedEmps){
                if(!namedSkillEmpMap.containsKey(j_Named_Resource_Skill.Skill_Name__c.toUpperCase())){
                    namedSkillSet.add(j_Named_Resource_Skill.Skill_Name__c.toUpperCase());
                    namedSkillEmpMap.put(j_Named_Resource_Skill.Skill_Name__c.toUpperCase(),new List<Id>());
                    namedSkillEmpMap.get(j_Named_Resource_Skill.Skill_Name__c.toUpperCase()).add(j_Named_Resource_Skill.Employee__c);
                    if(j_Named_Resource_Skill.Employee__r.Always_Works_With__c != null)
                    namedSkillEmpMap.get(j_Named_Resource_Skill.Skill_Name__c.toUpperCase()).add(j_Named_Resource_Skill.Employee__r.Always_Works_With__c);
                    
                }
             }
           }
           
        // Named skills - CR - Ends
        
        //Existing DiaryEntry Check -- ASHOK G
        if(job.Diary_Entries__r!=null){
        
           for(Diary_Entry__c Jdee: job.Diary_Entries__r){
           ExistngEntries.put(Jdee.week__c,Jdee.Employee_ID_18__c);
           
            if(wStartEndMap.containskey(Jdee.week__c)){
                      Datetime[] strtEnd = wStartEndMap.get(Jdee.Week__c);
                      if(Jdee.start__c < strtEnd[0])
                      strtEnd[0] = Jdee.start__c;
                      
                      if(Jdee.End__c > strtEnd[1])
                      strtEnd[1] = Jdee.End__c;
                      
                      wStartEndMap.put(Jdee.Week__c,strtEnd);
                   }else{
                      List<DateTime> startEnd = new list<DateTime>();
                      startEnd.add(Jdee.start__c);
                      startEnd.add(Jdee.End__c);
                      wStartEndMap.put(Jdee.Week__c,startEnd);
                      
                   }
           }
           
           
           
        }
        //ENd
        //Change BY ASHOK G
        /*Set<String> simple = new Set<String>{'BUILDING WORK','ELECTRICAL','MECHANICAL','POWERFLUSH','ROOF WORK','SPECIALIST BUILDING','LANDLORD CHECK','REMOTE HEATING'};
        boolean complextype = FALSE;
        Double totalSkills = 0.0;
        */
        if(cls_IsRun.isPlanner == 'N'){
            ObjNewSkill.validateJobSkillHoursHSA(skillsAndHours);
            /*for(String sk : skillsAndHours.keySet()) {
               If(simple.contains(sk)){
                   if(sk!='ELECTRICAL')
                   totalSkills += skillsAndHours.get(sk);
              
               continue;
               }
               else
               complextype = TRUE;
               
            }    
        
        //system.debug(LoggingLevel.INFO,'00000'+complextype+totalSkills);
        
        if(complextype){
        throw new SearchWorker.SearchException('Job With Skills that are complex are not accessed to plan');
        
        }
        else if(!complextype && totalSkills>integer.valueOf(system.label.TotalSkillhours))
        throw new SearchWorker.SearchException('Job skills should not exceed '+system.label.TotalSkillhours+' hours');     
        */
        
        }
        //END
        /*if(job.Building_Work_Hours__c > 0){
          skillsAndHours.put('BUILDING WORK', job.Building_Work_Hours__c);
        }
        if(job.Connect_Solar_Panel_Hours__c > 0){
          skillsAndHours.put('CONNECT SOLAR PANELS', job.Connect_Solar_Panel_Hours__c);
        }
        if(job.Contractor_Installation_Hours__c > 0){
          skillsAndHours.put('CONTRACTOR INSTALLATION', job.Contractor_Installation_Hours__c);
        }
        if(job.Electrical_Hours__c > 0){
          skillsAndHours.put('ELECTRICAL', job.Electrical_Hours__c);
        }
        if(job.Fire_Wall_Heater_Fixing_Hours__c > 0) {
          skillsAndHours.put('FIRE/WALL HEATER FIXING', job.Fire_Wall_Heater_Fixing_Hours__c);
        }
        if(job.LPG_Installation_Hours__c > 0) {
          skillsAndHours.put('LPG INSTALLATION', job.LPG_Installation_Hours__c);  
        }
        if(job.Mechanical_Hours__c > 0) {
          skillsAndHours.put('MECHANICAL', job.Mechanical_Hours__c);
        }
        if(job.Payment_Collection_Hours__c > 0) {
          skillsAndHours.put('PAYMENT COLLECTION', job.Payment_Collection_Hours__c);
        }
        if(job.PowerFlush_Hours__c > 0) {
          skillsAndHours.put('POWERFLUSH', job.PowerFlush_Hours__c);
        }
        if(job.Roof_Work_Hours__c > 0) {
          skillsAndHours.put('ROOF WORK', job.Roof_Work_Hours__c);
        }*/
        /* Cognizant----------Phase 5 Development---------------------- 30/07/2010:---------
        Scaffolder Skiil need to be removed from Job Planning module.
        Scaffolder is and itinary item and this needs to be handled by booking the 
        Appointment for the Job element.
        ----------------------------
        
        if(job.Scaffolder_Hours__c > 0) {
          skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
        }
    
        ending here...
        */
        /*if(job.Specialist_Building_Hours__c > 0) {
          skillsAndHours.put('SPECIALIST BUILDING', job.Specialist_Building_Hours__c);
        }
        if(job.Unvented_Hot_Water_Hours__c > 0) {
          skillsAndHours.put('UNVENTED HOT WATER', job.Unvented_Hot_Water_Hours__c);
        }
        if(job.Water_Heating_Fixing_Hours__c > 0) {
          skillsAndHours.put('WATER HEATER FIXING', job.Water_Heating_Fixing_Hours__c);
        }*/
        
     // Cognizant - CHI Phase III CR-002 implementation... END 
    
    // Check if the Job has a named employee, and if so, if that employee has an
    // employee they always work with.
    
     // Named electritian change - Starts
     if(job.Named_Electritian__c != null) {
        namedElectritian = job.Named_Electritian__c;
      }
    // Named electritian change - Ends
   
    if(job.Named_Employee__c != null) {
      if(job.Named_Employee__r.Resource_Type__c != SearchBlackBox.EMPLOYEE_RESOURCE_TYPE) {
        throw new SearchWorker.SearchException('Named employee is not an Installer.');
      }
      namedEmployee = job.Named_Employee__c;
      //Change By Ashok G -->Allow planning of two man team from the JOB screen
      if(job.Named_Employee_2__c!=null){
        //Employee__c e=[select id,name,Always_Works_With__c from employee__c where id=:namedEmployee]; 
       // e.Always_Works_With__c = job.Named_Employee_2__c;
        //update e;
        if(job.Named_Employee__r.Supplier_Branch_Num__c != job.Named_Employee_2__r.Supplier_Branch_Num__c){
         throw new SearchWorker.SearchException('Named employees supplier Num are not same..');
        }else
         namedEmployeeAWW = job.Named_Employee_2__c;
      }else if(job.Named_Employee__r.Always_Works_With__c != null)
        namedEmployeeAWW = job.Named_Employee__r.Always_Works_With__c;
        
        if(job.Named_Employee__r.Always_Works_With_Electrician__c != null)
        namedElectritian =job.Named_Employee__r.Always_Works_With_Electrician__c;
    }
    
   
    
    
    // Pick the primary skill - if the default present skill is present, pick that. 
    // If it's not present, choose the skill with the highest number of hours against it.
    
    // Cognizant - CHI Phase III CR-002 implementation... START
    /*if(skillsAndHours.containsKey(SearchBlackBox.PRIMARY_SKILL)) {
      primarySkill = SearchBlackBox.PRIMARY_SKILL;
      primaryHours = skillsAndHours.get(SearchBlackBox.PRIMARY_SKILL);*/
      
    if(skillsAndHours.containsKey(AddNewSkill.PRIMARY_SKILL)) {
      primarySkill = AddNewSkill.PRIMARY_SKILL;
      primaryHours = skillsAndHours.get(AddNewSkill.PRIMARY_SKILL);
      // Cognizant - CHI Phase III CR-002 implementation... END 
      
    } else {
      primarySkill = null;
      
      for(String skill : skillsAndHours.keySet()) {
        if(primarySkill == null) {
          primarySkill = skill;
          primaryHours = skillsAndHours.get(skill);
          continue;
        }
        Double currentSkillHours = skillsAndHours.get(skill);
        if(currentSkillHours > primaryHours) {
          primarySkill = skill;
          primaryHours = skillsAndHours.get(skill);
        }
      }
    }
    
    System.debug('primarySkill: ' + primarySkill);
    //rjd - 2010-01-13 - added
    isDoubleHanded = job.Double_Handed_Job__c;
    // Defect 233
    tooManyScriptStatements = job.Too_Many_Script_Statements__c;
  }
}