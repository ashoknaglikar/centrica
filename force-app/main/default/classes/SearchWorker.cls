/* SearchWorker

    This class contains the logic for the Search Black Box. It processes data held in an 
    EmployeeInformationCollection to propose resourcing options for a job.
*/
    
public with sharing class SearchWorker {
    private integer stackDepthCount = 0;
    public EmployeeInformationCollection employees {public get; private set;} // Holds information about Employees 
    public Boolean businessAvailabilityFlag {public get; private set;} // Flag that shows whether search is for business or customer date
    //Added as part of PRB00028301
    private Boolean skillsfullycoveredcheck = false;
    private Set<String> skillsCoveredcheckmap = new Set<String>();
    //Added as part of PRB00028301
    // Defect 229
    // A set that holds the IDs of Employees that have someone they always work with and have an option with that 
    // employee returned. This set is checked before pairs are processed.
    Set<ID> AWWEmpsWithOption = new Set<ID>();
    
    public class SearchException extends Exception {}
    
    /* SearchWorker()
        Constructor. Initialises class variables. */
    public SearchWorker() {
        employees = new EmployeeInformationCollection();
        businessAvailabilityFlag = true;
    }

    /* doSearch()
        Calls the necessary methods to perform the search. Returns two lists, the first containing
        options for the business date, the second containing options for the customer preferred
        date. Note that, as returned by this method, these are not stored in any particular order. */
    public List<List<JobResourcingOption>> doSearch() {
        employees.setupEmployeeInformation();
        system.debug(LoggingLevel.INFO, 'After employee setup: ' + Limits.getScriptStatements());
        List<JobResourcingOption> businessOptions = constructBusinessResourcingOptions();
        //List<JobResourcingOption> businessOptions = new List<JobResourcingOption>(); 
        system.debug(LoggingLevel.INFO, 'After business options: ' + Limits.getScriptStatements());
        List<JobResourcingOption> customerOptions = constructCustomerResourcingOptions();
        return new List<List<JobResourcingOption>>{businessOptions, customerOptions};
    }

    /* constructBusinessResourcingOptions()
        Method that starts the logic that determines what business options are available. */
    private List<JobResourcingOption> constructBusinessResourcingOptions() { 
        businessAvailabilityFlag = true;
        // Defect 233
        if(!employees.checkSkillsCanBeCovered(businessAvailabilityFlag)) {
            system.debug(LoggingLevel.INFO, 'Business options are missing someone to do one of the skills');
            // Not all skills can be covered, so don't do the processing
            return new List<JobResourcingOption>();
        }
        // End Defect 233
        
        // Temporary fix to help debugging
        if(!SearchResultsController.planBusiness) {
            system.debug(LoggingLevel.INFO, 'Found npb, returning empty list');
            return new List<JobResourcingOption>();
        }
        
        // Defect 229
        AWWEmpsWithOption.clear();
        // Check if this is a double handed search and call the appropriate method
        if(SearchBlackBox.jobInfo.job.Heavy_Appliance__c&&system.label.Heavy_Appliance_Job=='on'&&!SearchBlackBox.jobInfo.job.Override_Heavy_Appliance__c)
            return constructDoubleHandedOptionsHeavy(SearchBlackBox.jobInfo.namedEmployee);
        if(SearchBlackBox.jobInfo.isDoubleHanded)
            return constructDoubleHandedOptions(SearchBlackBox.jobInfo.namedEmployee);
        if(SearchBlackbox.optsAndParms.doubleHanded) {
            List<JobResourcingOption> output = constructSingleHandedResourcingOptions(SearchBlackBox.jobInfo.namedEmployee);
            //System.debug(output);
            output.addAll(constructDoubleHandedOptions(SearchBlackBox.jobInfo.namedEmployee));
            //System.debug(output);
            return output;
        } else {
            return constructSingleHandedResourcingOptions(SearchBlackBox.jobInfo.namedEmployee);
        }
    }
    
    /* constructCustomerResourcingOptions()
        Method that starts the logic that determines what customer options are available. */
    private List<JobResourcingOption> constructCustomerResourcingOptions() { 
        businessAvailabilityFlag = false;
        // Defect 233
        if(!employees.checkSkillsCanBeCovered(businessAvailabilityFlag)) {
            // Not all skills can be covered, so don't do the processing
            system.debug(LoggingLevel.INFO, 'Customer options are missing someone to do one of the skills');
            return new List<JobResourcingOption>();
        }
        // End Defect 233
        
        // Temporary fix to help debugging
        if(!SearchResultsController.planCustomer) {
            system.debug(LoggingLevel.INFO, 'Found npc, returning empty list');
            return new List<JobResourcingOption>();
        }
        
        // Defect 229
        AWWEmpsWithOption.clear();
        // Check if this is a double handed search and call the appropriate method
        if(SearchBlackBox.jobInfo.job.Heavy_Appliance__c&&system.label.Heavy_Appliance_Job=='on'&&!SearchBlackBox.jobInfo.job.Override_Heavy_Appliance__c)
            return constructDoubleHandedOptionsHeavy(SearchBlackBox.jobInfo.namedEmployee);
        if(SearchBlackBox.jobInfo.isDoubleHanded)
            return constructDoubleHandedOptions(SearchBlackBox.jobInfo.namedEmployee);
        if(SearchBlackbox.optsAndParms.doubleHanded) {
            List<JobResourcingOption> output = constructSingleHandedResourcingOptions(SearchBlackBox.jobInfo.namedEmployee);
            //System.debug(output);
            output.addAll(constructDoubleHandedOptions(SearchBlackBox.jobInfo.namedEmployee));
            //System.debug(output);
            return output;
        } else {
            return constructSingleHandedResourcingOptions(SearchBlackBox.jobInfo.namedEmployee);
        }
    }
    
    /* constructSingleHandedResourcingOptions(ID namedEmployee)
        Main method that searched for single handed resourcing options for a job. */
    private List<JobResourcingOption> constructSingleHandedResourcingOptions(ID namedEmployee) {
        
        // A list to hold any resourcing options found 
        List<JobResourcingOption> resourcingOptions = new List<JobResourcingOption>();
        
        // We populate a Set containing IDs of potential employees for the Job; if there is a named resource on the Job, 
        // this will be the only ID in the set, otherwise, all employees with the primary skill are added to the set.  
        Set<ID> employeesToConsider = new Set<ID>();
        if(namedEmployee == null)
            employeesToConsider = employees.employeesWithPrimarySkill;
        else
            employeesToConsider.add(namedEmployee);
        
        // We have another Set containing any employees that are found in "Always Works With" links.
        // If an employee always works with another, we store the ID of the other employee in a list, then process the pair
        // later as if they were a double handed pair. Note that currently, this creates options for an employee on his own
        // as well as a pairing with his AlwaysWorksWith partner. This can be changed as noted in the comments below
        Set<ID> alwaysWorksWithEmps = new Set<ID>();
        
        // Loop over the set we populated earlier...
        for(ID empIDWithPrimarySkill : employeesToConsider) {
            
            EmployeeInformation ei = employees.getEmployee(empIDWithPrimarySkill);
            JobResourcingOption jro = null;
            
            // If the current employee has an AlwaysWorksWith and that Employee's information has been extracted
            // and if the AlwaysWorksWith employee has not already been added, add this employee to the set. This
            // last condition prevents pairs being assessed twice.
            
            // Temporary fix - if no ei or no employees, continue. This shouldn't happen, need to investigate.
            if(ei == null)
                continue;

            if(ei.alwaysWorksWith != null && employees.employees.containsKey(ei.alwaysWorksWith)) {
                if(!alwaysWorksWithEmps.contains(ei.alwaysWorksWith))
                    alwaysWorksWithEmps.add(ei.employeeID);
                // CR-XXX
                // If an employee should not be considered when AlwaysWorkTogether is present, putting a "continue"
                // here will move on to the next employee - the pair will then be processed later.
                
                continue;
            }
            
            // Find a JobResourcingOption for this Employee
            jro = findPrimaryOption(ei);
            
            // If not JRO was found, jro will be null - continue moves onto the next employee.
            if(jro == null) {
                system.debug(LoggingLevel.INFO, 'continuing for: ' + ei.employeeName);
                continue;
            }

            // If we reach this part, this Employee can work on this Job. First we fill any skills gaps.
            List<JobResourcingOption> options = fillSkillGaps(jro);
            
            // If the skills gaps cannot be filled, there will be no options - continue to the next Employee 
            if(options.isEmpty()) {
                system.debug(LoggingLevel.INFO, 'continuing for: ' + ei.employeeName);
                continue;
            }

            // Now plan skills planned back from the end of a job
            options = planSkillsFromEnd(options);
            
            // Again, if there is no option for skills planned from the end, options will be empty, 
            // continue to move on to next Employee
            if(options.isEmpty()) {
                system.debug(LoggingLevel.INFO, 'continuing for: ' + ei.employeeName);
                continue;
            }
            
            // If we reach this point, there are valid options - add them to the list
            resourcingOptions.addAll(options);
        }
        
        // If none of the Employees had AlwaysWorksWith links, we can return the options as they are.
        if(alwaysWorksWithEmps.isEmpty())
            return resourcingOptions;

        // Loop over each of the Employees that had AlwaysWorksWith links
        for(ID awwID : alwaysWorksWithEmps) {
                
            // Get the Employees that Always Work Together
            EmployeeInformation firstEI = employees.getEmployee(awwID);
            EmployeeInformation secondEI = employees.getEmployee(firstEI.alwaysWorksWith);
            
            // Call the processDoubleHandedPair method to see if they can work on this job together
            // Note that the processDoubleHandedPair method also takes care of skills gaps 
            List<JobResourcingOption> options = processDoubleHandedPair(firstEI, secondEI);
            
            // If no options were returned, continue to the next loop
            if(options == null || options.isEmpty()) {
                system.debug(LoggingLevel.INFO, 'No AWW options found');
                continue;
            }
            
            // Now skills planned back from the end of a job
            options = planSkillsFromEnd(options);
            // If options is empty, there are no options for this pair, continue to the next loop
            if(options.isEmpty())
                continue;
            
            // Add all options
            resourcingOptions.addAll(options);
            // Defect 229
            // Add this employee's ID to the set created above - this will prevent this pairing
            // being considered for a second time when we get to the AWW Employee.
            AWWEmpsWithOption.add(firstEI.employeeID);
            AWWEmpsWithOption.add(firstEI.alwaysWorksWith);
            system.debug(LoggingLevel.INFO, 'Added ' + firstEI.alwaysWorksWith + ' to AWWEmpsWithOption');
        }
        
        // Return options.
        return resourcingOptions;
    }

    /* planSkillsFromEnd(List<JobResourcingOption> options)
        Takes a list of JobResourcingOptions and attempts to plan any skills that need to be planned backward
        from the end of a job. There are certain job skills that are planned from a point calculated backwards
        from the end time of the primary resource on a Job. There is a Search Parameter that controls how far
        back from the end these skills are planned. For example, if that parameters is set to 10% and a primary
        resource does 10 hours on a Job, finishing at 3pm, the skills planned from the end are planned from
        2pm, as 10% of 10 hours is 1 hour and this is taken away from 3pm. 
        
        Because of Governor Limits around the number of statements, a resource for each skill planned from the
        end is picked at random. This may change after feedback from System Test. CR-XXX */
    private List<JobResourcingOption> planSkillsFromEnd(List<JobResourcingOption> options) {
        // Determine what skills on this job are planned from the end
        Set<String> skillsFromEnd = SearchBlackBox.jobInfo.skillsAndHours.keySet().clone();
        skillsFromEnd.retainAll(SearchBlackBox.SKILLS_PLANNED_FROM_END);
        
        // CHI Phase III CR's - CR-004 - Starts
        // Clone orignal set for the skills which are planned from the end.
        
        
        // If there are no skills to be planned from the end, the options can be returned as they are.
        if(skillsFromEnd.isEmpty())
            return options;
        
        // Otherwise, create a new list to store options in 
        List<JobResourcingOption> optionsToReturn = new List<JobResourcingOption>(); 
        
  // Named electritian change - Starts
        
     // Loop over each option passed in
  
   if(SearchBlackBox.jobInfo.namedElectritian != null){
        
     for(JobResourcingOption jro : options) {
           
            List<ResourceOption> ros = new List<ResourceOption>();
            
            // Loop over each skill we're planning from the end
            
            for(String skill : skillsFromEnd) {
                
                ResourceOption ro = null; // Will hold an Employee for this skill if found...
                
                System.debug('Planning job from end:endoffset,skill '+SearchBlackbox.optsAndParms.endOffset+','+SearchBlackBox.jobInfo.skillsAndHours.get(skill));
                // Get the DateTime for when skills planned from the end should be planned from.
                Datetime planFrom = jro.getEndJobStart(SearchBlackbox.optsAndParms.endOffset, SearchBlackBox.jobInfo.skillsAndHours.get(skill));
                
                
                System.debug('planFrom '+planFrom);
                // Get Employees with this skill - if there are none, break out of this loop (and continue with the next JRO)
                Set<ID> empsWithSkill = employees.employeeIDsBySkill.get(skill);
                if(empsWithSkill == null || empsWithSkill.isEmpty()) {
                    break;
                }
                
                // Convert Employees into a List...
               
                Boolean contains = empsWithSkill.contains(SearchBlackBox.jobInfo.namedElectritian);
                
                if(contains == false){
                    
                    break;
                    
                }
                
                List<ID> empsWithSkillList = new List<ID>();
                
                empsWithSkillList.add(SearchBlackBox.jobInfo.namedElectritian);
      
                    // Get the only the named electritian
                    
                    EmployeeInformation ei = employees.getEmployee(SearchBlackBox.jobInfo.namedElectritian);
                    
                    if(ei == null){
                        break;
                    }
                    
                    Set<ID> AlwaysWorksWithElecIDs= employees.AlwaysWorksWithElecIDs;
                    if(AlwaysWorksWithElecIDs.contains(SearchBlackBox.jobInfo.namedElectritian))
                    {
                        if((jro.employeesAlwaysWorksWithElec==null||jro.employeesAlwaysWorksWithElec.isempty())&& SearchBlackBox.jobInfo.namedEmployee==null)
                        break;
                        
                        boolean isSkipThisJro = false;
                        for(ResourceOption r:jro.primaryResources)
                        {
                           if(r.employeeID!=SearchBlackBox.jobInfo.namedEmployee && r.alwaysWorksWithElectrician!=SearchBlackBox.jobInfo.namedElectritian)
                           isSkipThisJro=true;
                        }
                       if(isSkipThisJro)
                       break;
                    }
                    else{
                        if((jro.employeesAlwaysWorksWithElec!=null && !jro.employeesAlwaysWorksWithElec.isempty())&& SearchBlackBox.jobInfo.namedEmployee==null)
                        break;
                    }
                    
                    //suguna -PH Jones change
                    EmployeeInformation ei2;
                    if(SearchBlackBox.jobInfo.namedEmployee!=null)
                      ei2 = employees.getEmployee(SearchBlackBox.jobInfo.namedEmployee);
                     else
                     {
                        if(jro.primaryResources.size()==1)
                          ei2= employees.getEmployee(jro.primaryResources[0].employeeID);
                        else if(jro.primaryResources.size()>1)
                        {
                          EmployeeInformation ei1 = employees.getEmployee(jro.primaryResources[0].employeeID);
                          if(ei1.overBookingExpHours>0.0)
                          ei2=ei1;
                          else
                          ei2= employees.getEmployee(jro.primaryResources[1].employeeID);
                        }
                     }
                
                     if(ei2.overBookingExpHours>0.0)
                     {
                        List<DiaryEntryCollection> dlist= ei.availability.getDECs(businessAvailabilityFlag);
                        List<List<String>> shifts = getShifts(dlist[0].entryInfoObjects[0].entry);
                        planFrom = DateTimeHelper.subtractWorkingHoursToDateTime(planFrom,double.valueof(ei2.overBookingExpHours),shifts);
                     }
                     //ends
                    
                    
                   
                    // If the employee is already on the job, we should use his end time instead of "planFrom"
                    // otherwise a job booking may be scheduled before the employee has finished his other skills!
                    if(jro.employeesAssigned.contains(ei.employeeID)) {
                        ro = findSuitableGap(ei, jro, skillsFromEnd, ei.getHoursForSkills(skillsFromEnd), jro.getEndTime(ei.employeeID), 
                                    null, true);
                    } else {
                        ro = findSuitableGap(ei, jro, skillsFromEnd, ei.getHoursForSkills(skillsFromEnd), planFrom, null, true);
                    }
                    
                // If no ResourceOption was found, break (and move on to next JRO), otherwise, add it to the list 
                // and move on to the next skill. 
                if(ro == null) {
                    // Clear the list, otherwise people found will be added, even though not all skills were resourced
                    ros.clear();
                    break;
                } else
                    ros.add(ro);
            }
            
            if(!ros.isEmpty()) {
                
                // If ros is not empty, we've found options for all skills planned from end.
                // Add them to the JRO as secondary options 
                System.debug('found options');
                jro.addSecondaryOptions(ros);
                optionsToReturn.add(jro);
                
            }
            
        }
        
       return optionsToReturn; 
   
   }   
        
   // Named electritian change - ends
        
        // CHI Phase III CR's - CR-004 - Starts
        
        // Major loop I starts
        
       for(JobResourcingOption jro_ODOMJ : options) {
            // In order to avoid null pointer exception default this falg to false.
            jro_ODOMJ.isSPFEAlreadyAdded = false;
            jro_ODOMJ.ignoreThisJRO = false;
            
            // We assume that if we are exceeding number of script statements limit behind the plan job button then planners will tick the 
            // box called too many script statements on job and then again electrical search will not consider CR-003.
            
            if(SearchBlackBox.jobInfo.tooManyScriptStatements){
              
              break;
              
            }
            
            List<ResourceOption> ros_ODOMJ = new List<ResourceOption>();
           
            // Loop over each skill we're planning from the end for ODOMJ
           
            for(String skill_ODOMJ : skillsFromEnd) {
               
                ResourceOption ro_ODOMJ = null; // Will hold an Employee for this skill if found...
                
                Boolean continueToNextSkill = true;
                
                // Get Employees with this skill - if there are none, break out of this loop (and continue with the next JRO)
                Set<ID> empsWithSkill_ODOMJ = employees.employeeIDsBySkill.get(skill_ODOMJ);
                
                if(empsWithSkill_ODOMJ == null || empsWithSkill_ODOMJ.isEmpty()) {
                    break;
                }
                
                // Convert Employees into a List...
               
                List<ID> empsWithSkillList_ODOMJ = new List<ID>();
                
                empsWithSkillList_ODOMJ.addAll(empsWithSkill_ODOMJ);
                
                // Loop over each employee who has this skill and check whether he is already a part of this JRO.
                // If he performs skill_ODOMJ only on his job then he has to be part of JRO otherwise we need to make sure 
                // that this JRO is ignored by next major for loop II.
                
                for(ID emp_id:empsWithSkillList_ODOMJ){
                    
                    EmployeeInformation ei_ODOMJ = employees.getEmployee(emp_id);
                    if(ei_ODOMJ.skillsAndODOMJ.get(skill_ODOMJ) && jro_ODOMJ.employeesAssigned.contains(emp_id)){
                         
                        ro_ODOMJ = findSuitableGap(ei_ODOMJ, jro_ODOMJ, skillsFromEnd, ei_ODOMJ.getHoursForSkills(skillsFromEnd), jro_ODOMJ.getEndTime(ei_ODOMJ.employeeID), 
                                                null, true);
                
                        if(ro_ODOMJ != null) {
                            // This indicates that employee E1 does mechanical and electrical on his own job only.
                            // He has sufficient gap to perform both the skills on this job. So we need to make sure that 
                            // he is the only electritian on his job.
                            ros_ODOMJ.add(ro_ODOMJ);
                            jro_ODOMJ.skillsFullyAssigned.add(skill_ODOMJ);
                            // If we find the correct employee for correct availability & skill then go to next skill.
                            break;
                        }else{
                            // This indicates that employee E1 does mechanical and electrical on his own job only.
                            // He does not have sufficient gap to perform both the skills on this job. So we need to make sure that 
                            // this jro (job resource option) is totally ignored and not brought back by black box.
                            // Once we make isSPFEAlreadyAdded to true this is then ignored by next set of for loops.
                            jro_ODOMJ.ignoreThisJRO = true;
                            continueToNextSkill = false;
                            break;
                        }
                     }
                  }   
                 
                 // skill_ODOMJ is performed by some employee on ODOMJ but he was not having sufficient gap to perform it.
                 // This whistles that we need to go to next JRO rather than next skill.
                 if(!continueToNextSkill){
                    
                    break;
                    
                 }

               } 
             
             // This indicates that one of the employees who is part of this JRO also has got one of the SPFE which is ODOMJ.
             // But he was not having sufficient gap to perform this skill so we need to ignore this JRO completely.
             if(jro_ODOMJ.ignoreThisJRO){
                
                continue;
                
              }
               
              if(!ros_ODOMJ.isEmpty()) {
               
                // If ros is not empty, we've found options for all skills planned from end.
                // Add them to the JRO as secondary options 
                // check whether all the skills which are planned from end are covered by this resource option.
                // PFE - Plan from end.
              
                  Set<String> skillsCovered_SPFM = new Set<String>(); // - stores all the skills which are ODOMJ and planned from the end 
                  Set<String> emp_skills_ODOMJ_PFE = new Set<String>(); // - stores all the skills which emlpoyee does on his own job only and which fall under catagory PFE.
                  Set<String> skillsFromEnd_Cloned_Not_Allocated = new Set<String>(); // - stores all the skills which are PFE & not ODOMJ and not yet added to this JRO.
                  
                  for(ResourceOption ro_individual:ros_ODOMJ){
                      skillsCovered_SPFM.addAll(ro_individual.skillsFullyCovered);
                      skillsCovered_SPFM.retainAll(SearchBlackBox.SKILLS_PLANNED_FROM_END);
                      emp_skills_ODOMJ_PFE = (employees.getEmployee(ro_individual.employeeID).skillsAndODOMJ.keySet());
                      emp_skills_ODOMJ_PFE.retainAll(skillsFromEnd);
                  }
                  
                  skillsFromEnd_Cloned_Not_Allocated = skillsFromEnd.clone();
                  skillsFromEnd_Cloned_Not_Allocated.removeAll(emp_skills_ODOMJ_PFE);
                  
                  // Skills planned from end which are yet not allocated on this JRO should be populated on this JRO 
                  // so that these are considered by next for loop.
                  if(skillsFromEnd_Cloned_Not_Allocated.size()>0){
                        system.debug(LoggingLevel.INFO, '###There are still Skills PFE to be added###');
                        jro_ODOMJ.spfeStillNotAllocated.addAll(skillsFromEnd_Cloned_Not_Allocated);
                        system.debug(LoggingLevel.INFO, '###There are still Skills PFE to be added###'+skillsFromEnd_Cloned_Not_Allocated);
                    }
                  
                  // If the ODOMJ - PFE skills assigned to employee in above part of code is equal to all the SPFE & ODOMJ then 
                  // we are interesterd in adding them all to this JRO. 
                  // If any of the non ODOMJ PFE skill is still to be added then this should be taken care by next for loop.
                  if(skillsCovered_SPFM.containsAll(emp_skills_ODOMJ_PFE)){
                    system.debug(LoggingLevel.INFO, '###found options###');
                    jro_ODOMJ.addSecondaryOptions(ros_ODOMJ);
                    if(skillsFromEnd_Cloned_Not_Allocated.size()==0)
                    optionsToReturn.add(jro_ODOMJ);
                    jro_ODOMJ.isSPFEAlreadyAdded=true;
                  }
                  // If the ODOMJ - PFE skills assigned to employee in above part of code is not equal to all the SPFE & ODOMJ then 
                  // this JRO should be ignored by next for loop. 
                  else{
                        jro_ODOMJ.ignoreThisJRO=true;
                  }
                
               }
               
            } 
         
         // Major loop I ends   
         
        // CHI Phase III CR's - CR-004 - Ends
        
        // Loop over each option passed in
        
        // Major loop II Starts
           
        for(JobResourcingOption jro : options) {
            List<ResourceOption> ros = new List<ResourceOption>();
            
            // CHI Phase III CR's - CR-004 - Starts
            // This JRO contains an employee who is doing one of the non SPFE skills.
            // This employee does one of the SPFE ODOMJ but havent got enough gap to perform the SPFE.
            // In this case we ignore this JRO fully and go to next one.
            if(!SearchBlackBox.jobInfo.tooManyScriptStatements){
                    
                    if(jro.ignoreThisJRO){
                        continue;
                    }
                    
            }
            // CHI Phase III CR's - CR-004 - Ends
            
            // Loop over each skill we're planning from the end
            for(String skill : skillsFromEnd) {
                
                system.debug(LoggingLevel.INFO,'carrying on 1') ;
                
                // CHI Phase III CR's - CR-004 - Starts
           
                // If this skill is already added to this JRO in last for loop then we can go to next skill.
                 
                 if(!SearchBlackBox.jobInfo.tooManyScriptStatements){
                    
                    if(jro.isSPFEAlreadyAdded && jro.skillsFullyAssigned.contains(skill)){
                       System.debug(LoggingLevel.Info,'How many times am I here');
                       continue;
                   }
                   
                 }
                
                  // When size of jro.spfeStillNotAllocated is greater than zero, it indicates that there are few of the skills which are 
                  // planned from end and whcih are ODOMJ, these should have been already added on this JRO in previous loop.
                  // There can be few of the skills which are planned from end and are not ODOMJ and these wouldn't have been added on this JRO in previous 
                  // loop so we need to add them here in this loop.
                  
                  // Also if size of jro.spfeStillNotAllocated is zero then either all the skills planned from end are already added to this JRO or none of them is added.
                  // If all of the are already added then jro.isSPFEAlreadyAdded would have been true and we never come to this place in the code.
                  // If jro.spfeStillNotAllocated.size()>0 then few of the ODOMJ & PFE are planned and remaining are not yet planned because these are not ODOMJ but are PFE.
                  
                  // if this skill does not have non zero hours to be planned then we can go to next skill.
                  // This is not part of this change but a system improvement which should have been done already in phase III.
                  
                  if(!SearchBlackBox.jobInfo.skillsAndHours.containsKey(skill)){
                    
                    continue;
                    
                  }
                  
                  if(jro.spfeStillNotAllocated.size()>0){
                      if(!jro.spfeStillNotAllocated.contains(skill)){
                        continue;
                      }
                   }
                   
                // CHI Phase III CR's - CR-004 - Ends
                
                ResourceOption ro = null; // Will hold an Employee for this skill if found...
                system.debug(LoggingLevel.INFO,'carrying on 2') ;
                system.debug(LoggingLevel.INFO, 'Planning job from end:endoffset,skill '+SearchBlackbox.optsAndParms.endOffset+','+SearchBlackBox.jobInfo.skillsAndHours.get(skill));
                // Get the DateTime for when skills planned from the end should be planned from.
                Datetime planFrom = jro.getEndJobStart(SearchBlackbox.optsAndParms.endOffset, SearchBlackBox.jobInfo.skillsAndHours.get(skill));
                
                
                
                //ends
                
                //Suguna- Always works with Electrician
                Set<ID> empsWithSkill= jro.employeesAlwaysWorksWithElec;
                system.debug('empsWithSkill '+empsWithSkill);
                if(empsWithSkill == null || empsWithSkill.isEmpty()) 
                {
                    empsWithSkill = employees.employeeIDsBySkill.get(skill);
                    empsWithSkill.removeAll(employees.alwaysWorksWithInstallerElecIds);
                    empsWithSkill.removeAll(employees.AlwaysWorksWithElecIDs);
                }
                system.debug('empsWithSkill 2 '+empsWithSkill);     
                // Get Employees with this skill - if there are none, break out of this loop (and continue with the next JRO)
                //Set<ID> empsWithSkill = employees.employeeIDsBySkill.get(skill);
                if(empsWithSkill == null || empsWithSkill.isEmpty()) {
                    break;
                }
                
                
                // Convert Employees into a List...
                List<ID> empsWithSkillList = new List<ID>();
                empsWithSkillList.addAll(empsWithSkill);
                
                // Pick one at random
                Integer count = 0;
                Integer size = empsWithSkill.size();
                
                // Use a set to check that this option hasn't been tried already.
                Set<Integer> alreadyTried = new Set<Integer>();

                do {
                    // Get a random number
                    Integer rdm = (Math.random() * 100).intValue();
                    if(rdm == 0)
                        rdm = 1;
                    else
                        rdm = Math.Mod(rdm, size);

                    if(rdm >= size)
                        rdm = size-1;
                    
                    // If we've tried this option already, move onto the next one.
                    if(alreadyTried.contains(rdm))
                        continue;
                    
                    // Get the Employee at this random position
                    EmployeeInformation ei = employees.getEmployee(empsWithSkillList[rdm]);
                    system.debug('Sugu 1 '+ei);
                    
                    // If this ei have been already used in first for loop then it is ODOMJ and will not be added to any other JRO.
                    // So we dont need extra check here to make sure that ei which is already used in first loop is not assigned 
                    // to any other JRO.
                    
                    //suguna -PH Jones change
                      EmployeeInformation ei2;
                         if(SearchBlackBox.jobInfo.namedEmployee!=null)
                         ei2 = employees.getEmployee(SearchBlackBox.jobInfo.namedEmployee);
                         else
                         {
                              if(jro.primaryResources.size()==1)
                              ei2= employees.getEmployee(jro.primaryResources[0].employeeID);
                              else if(jro.primaryResources.size()>1)
                              {
                                 EmployeeInformation ei1 = employees.getEmployee(jro.primaryResources[0].employeeID);
                                 if(ei1.overBookingExpHours>0.0)
                                 ei2=ei1;
                                 else
                                 ei2= employees.getEmployee(jro.primaryResources[1].employeeID);
                              }
                         }
                         ei2 = employees.getEmployee(jro.primaryResources[0].employeeID);
                
                         if(ei2.overBookingExpHours>0.0)
                         {   
                           List<DiaryEntryCollection> dlist= ei.availability.getDECs(businessAvailabilityFlag);
                           List<List<String>> shifts = getShifts(dlist[0].entryInfoObjects[0].entry);
                           planFrom = DateTimeHelper.subtractWorkingHoursToDateTime(planFrom,double.valueof(ei2.overBookingExpHours),shifts);
                         }
                    //ends
                    
                    if(ei.skillsAndODOMJ.get(skill) && !jro.employeesAssigned.contains(ei.employeeID)) {
                        alreadyTried.add(rdm);
                        count++;
                        continue;
                    }

                    // FIX: If the employee is already on the job, we should use his end time instead of "planFrom"
                    // otherwise a job booking may be scheduled before the employee has finished his other skills!
                    if(jro.employeesAssigned.contains(ei.employeeID)) {
                        ro = findSuitableGap(ei, jro, skillsFromEnd, ei.getHoursForSkills(skillsFromEnd), jro.getEndTime(ei.employeeID), 
                                                null, true);
                    } else {
                        ro = findSuitableGap(ei, jro, skillsFromEnd, ei.getHoursForSkills(skillsFromEnd), planFrom, null, true);
                    }
                    
                    alreadyTried.add(rdm);
                    count++;
                } while(count < size && ro == null); // This will loop while an option has not been found and whilst
                                                     // the number of loops is less than the number of employees with the skill
                
                // If no ResourceOption was found, break (and move on to next JRO), otherwise, add it to the list 
                // and move on to the next skill. 
                if(ro == null) {
                    // Clear the list, otherwise people found will be added, even though not all skills were resourced
                    ros.clear();
                    break;
                } else
                    ros.add(ro);
            }
            
            if(!ros.isEmpty()) {
                // If ros is not empty, we've found options for all skills planned from end.
                // Add them to the JRO as secondary options 
                system.debug(LoggingLevel.INFO, 'found options');
                jro.addSecondaryOptions(ros);
                optionsToReturn.add(jro);
            }
        }
        // Major loop II ends
        return optionsToReturn;
    }
    
    /* findPrimaryOption(EmployeeInformation ei)
        Takes an EmployeeInformation object and tries to find a suitable primary resourcing option for the 
        Employee. If successful, a JobResourcingOption is returned; otherwise, null is returned.*/
    private JobResourcingOption findPrimaryOption(EmployeeInformation ei) {
        ResourceOption option = null;

        // If there's an earliestGap, this employee has a suitable gap for all their skills, 
        // therefore use this gap and employee as a resourcing option and return it.
        DiaryEntryCollection earliestGap = ei.availability.getEarliest(businessAvailabilityFlag);
        system.debug(LoggingLevel.INFO, 'earliestGap: ' + earliestGap);
        if(earliestGap != null)
            option = new ResourceOption(ei.skills, earliestGap, ei, SearchBlackBox.jobInfo);

        // If employee doesn't have a gap large enough for all his skills, need to look at
        // their largest gap instead and work out what skills they can do in this time 
        if(option == null) {
            DiaryEntryCollection largestGap = ei.availability.getLargest(businessAvailabilityFlag);
            if(largestGap != null) {
                if(largestGap.numberOfHours < SearchBlackBox.jobInfo.primaryHours) {
                    // Largest gap does not have enough hours for the primary skill - do nothing!
                } else if(largestGap.numberOfHours >= SearchBlackBox.jobInfo.primaryHours) {
                    // Employee's largest gap can hold the number of hours for at least the primary skill,
                    // call the removeSkillsToFitGap method to find optimal skills for size of gap
                    option = removeSkillsToFitGap(largestGap, ei, ei.Skills, true);
                }
            }
        }
        
        if(option == null) {
            // If option is null, no option for this Employee was found and null is returned.
            return null;
        } else {
            // Otherwise, a JobResourcingOption is created and returned.
            JobResourcingOption jro = new JobResourcingOption();
            jro.addPrimaryOptions(new List<ResourceOption>{option});
            return jro;
        }
    }
    
    /* removeSkillsToFitGap(DiaryEntryCollection largestGap, EmployeeInformation ei,
                            Set<String> candidateSkills, boolean isPrimaryCandidate)
        Overloaded version of the removeSkillsToFitGap method. */
    private ResourceOption removeSkillsToFitGap(DiaryEntryCollection largestGap, EmployeeInformation ei,
                                                Set<String> candidateSkills, boolean isPrimaryCandidate) {
                                                    
        ResourceOption result = removeSkillsToFitGap(largestGap, largestGap.numberOfHours, largestGap.startDT, ei, 
                                                    candidateSkills, isPrimaryCandidate);
        return result;
    }   

    /* removeSkillsToFitGap(DiaryEntryCollection largestGap, Double numberOfHours,
                                                Datetime startTimeToUse, EmployeeInformation ei,
                                                Set<String> candidateSkills, boolean isPrimaryCandidate)
        Takes information about a Job's skills, an Employee, and his availability and tries to find the best
        use of the employees available time to fill those skills on the job.
        
        Though the number of hours available in the gap could be determined in this method, it is accepted
        as a parameter as it may have been calculated elsewhere and this saves on statements that would
        be used to recalculate this information.
        
        This method also considers a start time different to the one on the DiaryEntryCollection passed in
        to the method. */
    private ResourceOption removeSkillsToFitGap(DiaryEntryCollection largestGap, Double numberOfHours,
                                                Datetime startTimeToUse, EmployeeInformation ei,
                                                Set<String> candidateSkills, boolean isPrimaryCandidate) {
        // Find out what the optimal skills are for this number of hours
        Set<String> bestSkills = getBestSkills(candidateSkills, numberOfHours, isPrimaryCandidate);
        
        // It's possible no configuration of skills that will be suitable - if so, return null  
        if(bestSkills.isEmpty()) {
            return null;
        }
        
        // bestSkills is not empty, create a new ResourceOption
        
        ResourceOption result = null;
        if(DateTimeHelper.dateLessThan(largestGap.startDT, startTimeToUse)) {
            // If we are changing the start time, calculate the hours between the DEC's start and the 
            // adjusted start and call the ResourceOption constructor that takes an offset  
            system.debug(LoggingLevel.INFO, 'largestGap.startDT: ' + largestGap.startDT + 'largestGap.finishDT: ' + largestGap.finishDT + ' startTimeToUse: ' + startTimeToUse);
            Double offset = largestGap.workingHoursBetween(largestGap.startDT, startTimeToUse);
            result = new ResourceOption(bestSkills, largestGap, ei, SearchBlackBox.jobInfo, offset);
        } else {
            // If we are not changing the start time, call a slightly more boring constructor...
            result = new ResourceOption(bestSkills, largestGap, ei, SearchBlackBox.jobInfo);
        }
        
        // If result was created, indicate that skills were removed
        if(result != null) {
            result.skillsRemoved = true;
        }

        return result;
    }
    
    /* getBestSkills(Set<String> candidateSkills, Double numberOfHours, Boolean addPrimarySkills)
        Works out what skills best fit a number of hours. This loops over every skill the candidate can do on a job,
        and then loops over other skills, working out if they also fit. */
    private Set<String> getBestSkills(Set<String> candidateSkills, Double numberOfHours, Boolean addPrimarySkills) {
        Set<String> bestSkills = new Set<String>();
        // As we move through the skills, we keep track of which ones have already been considered.
        Set<String> skillsConsidered = new Set<String>();
        Double best = numberOfHours; // lower is best
        
        // Loop over each of the skills that the candidate can do on a job
        for(String skill : candidateSkills) {
            skillsConsidered.add(skill);
            Set<String> skillsThatFit = new Set<String>();
            Double hoursLeftInGap = numberOfHours;
            
            // What are the other skills this person can do - remove skills that have already been considered.
            Set<String> otherCandidateSkills = candidateSkills.clone();
            otherCandidateSkills.removeAll(skillsConsidered);
            
            // ASSUMPTION: If primary candidate, assign primary skill first
            if(addPrimarySkills && skill != SearchBlackBox.jobInfo.primarySkill) {
                hoursLeftInGap -= SearchBlackBox.jobInfo.skillsAndHours.get(SearchBlackBox.jobInfo.primarySkill);
                skillsThatFit.add(SearchBlackBox.jobInfo.primarySkill);
                otherCandidateSkills.remove(SearchBlackBox.jobInfo.primarySkill);
            }
            
            // Loop over the other skills that the candidate can do.
            // Example: if a candidate can do skills A, B and C, skill A is considered in the first outer loop, 
            // skills B and C in the inner loop. Skill B is used for the second outer loop but we do not consider
            // skill A in the inner loops, as the pairing of skills A and C have already been considered. 
            for(String aSkill : otherCandidateSkills) {
                Double hoursForThisSkill = SearchBlackBox.jobInfo.skillsAndHours.get(aSkill);
                if(hoursForThisSkill <= hoursLeftInGap) {
                    // This skill will fit into this current option, add it to the Set, and subtract the hours 
                    skillsThatFit.add(aSkill);
                    hoursLeftInGap -= hoursForThisSkill;
                    // Check if this is option is better than the current best option - if there are a smaller
                    // number of hours left than the previous best, this is a better option.
                    if(hoursLeftInGap <= best) {
                        best = hoursLeftInGap;
                        bestSkills = skillsThatFit;
                    }
                }
            }           
        }
        
        return bestSkills;
    }
    
    /* fillSkillGaps(JobResourcingOption jro)
        A method that attempts to fill the missing skills on the JobResourcingOption passed into the method. */
    private List<JobResourcingOption> fillSkillGaps(JobResourcingOption jro) {
        system.debug(LoggingLevel.INFO, 'fillSkillGaps() '+ jro);
        // Work out which skills need filling (ignoring skills planned from the end of a job)
        Set<String> skillsToFill = SearchBlackBox.jobInfo.skillsAndHours.keySet().clone();
        skillsToFill.removeAll(jro.skillsFullyAssigned);
        
        
        //rjd - 2010-01-13 : if I remove this then electicians are found!!!!!!
        skillsToFill.removeAll(SearchBlackBox.SKILLS_PLANNED_FROM_END);

        // If there are no skills to fill, return.
        if(skillsToFill.isEmpty()) {
            system.debug(LoggingLevel.INFO, 'no skills to fill');
            return new List<JobResourcingOption>{jro};
        }
        
        // Find the best Employees to fill the skills gaps
        Set<ID> secondaryIDs = findBestSecondaryOptions(jro, skillsToFill);
        
        if(secondaryIDs == null || secondaryIDs.isEmpty())
            return new List<JobResourcingOption>();
        
        // Create secondary ResourceOptions for the jro 
        List<List<ResourceOption>> secondaryOptions = constructSecondaryOptions(jro, skillsToFill, secondaryIDs);
        
        // Now convert secondaryOptions into JobResourcingOptions
        List<JobResourcingOption> jros = new List<JobResourcingOption>();
        for(List<ResourceOption> secondaryOption : secondaryOptions) {
            if(!secondaryOption.isEmpty()) {
                jros.add(new JobResourcingOption(jro, secondaryOption));
            }
        }

        return jros;
    }   
    
    /* findBestSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill)
        An overloaded version of findBestSecondaryOptions which, in turn, determines which Employees 
        are best to fill skill gaps. */
    private Set<ID> findBestSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill) {
        return findBestSecondaryOptions(jro, skillsToFill, null);
    }
    
    /* findBestSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill, Set<ID> idsToIgnore)
        Returns a Set of IDs indicating which employees will be best to fill skill gaps for the JobResourcingOption
        passed into the method. */ 
    private Set<ID> findBestSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill, Set<ID> idsToIgnore) {
        system.debug(LoggingLevel.INFO, 'findBestSecondaryOptions:: '+jro+','+skillsToFill+','+idsToIgnore);
        Set<ID> secondaryIDs = new Set<ID>();
        
        // For each skill that needs filling, get the IDs of Employees that can do that skill.
        for(String skill : skillsToFill) {
            Set<ID> employeesWithSkill = employees.employeeIDsBySkill.get(skill);
            system.debug(LoggingLevel.INFO, 'employeesWithSkill:: '+employeesWithSkill);
            if(employeesWithSkill != null) {
                secondaryIDs.addAll(employeesWithSkill);
            } else
                return null;
        }
        
        // Remove any Employees already assigned to the job, any Employees that a resource on the job never works
        // with, and any Employee IDs to ignore, as passed into the method 
        secondaryIDs.removeAll(jro.employeesAssigned);
        secondaryIDs.removeAll(jro.employeesNeverWorkWith);
        if(idsToIgnore != null) {
            secondaryIDs.removeAll(idsToIgnore);
        }
        
        // A Map to hold a counts of how many skills each Employee can do
        Map<Integer, List<ID>> skillsFulfilled = new Map<Integer, List<ID>>();
        
        // For each Employee with a skill that fills one of the gaps
        for(ID secondaryID : secondaryIDs) {
            // How many missing skills does this person have?
            Set<String> skillsFit = employees.getEmployee(secondaryID).getSkills(skillsToFill);
            Integer count = skillsFit.size();
            
            // Add the result to the Map
            List<ID> temp = skillsFulfilled.containsKey(count) ? skillsFulfilled.get(count) : new List<ID>();
            temp.add(secondaryID);
            skillsFulfilled.put(count, temp);
        }
        
        // Create a list out of the Integers in the skillsFulfilled Map so that we can sort them and
        // find out the highest number of skills filled by Employees.
        List<Integer> tempList = new List<Integer>();
        tempList.addAll(skillsFulfilled.keySet());
        tempList.sort();
        secondaryIDs.clear();
        
        if(!tempList.isEmpty()) {
            Integer highestFulfilled = 0;
            Integer nextHighestFulfilled = 0;
            
            //Get the last element (highest number of skill gaps filled) and add the IDs of Employees with that number of skills
            highestFulfilled = tempList.get(tempList.size()-1);
            secondaryIDs.addAll(skillsFulfilled.get(highestFulfilled));
            
            // Check if there's a "next highest" number - if so, add these Employees as well.
            if(tempList.size()-2 >= 0) {
                nextHighestFulfilled = tempList.get(tempList.size()-2);
                secondaryIDs.addAll(skillsFulfilled.get(nextHighestFulfilled));
            } 
            
        }

        return secondaryIDs;
    }

    /* constructSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill, Set<ID> secondaryIDs)
        This method is used to create resource options to fill skill gaps on a JobResourcingOption. A set of 
        Employee IDs is passed in which indicates what Employees should be considered to fill the gaps.  */
    private List<List<ResourceOption>> constructSecondaryOptions(JobResourcingOption jro, Set<String> skillsToFill, Set<ID> secondaryIDs) {

        List<List<ResourceOption>> secondaryOptions = new List<List<ResourceOption>>();

        // For each ID...
        for(ID sid : secondaryIDs) {
            // Get the Employee
            EmployeeInformation ei = employees.getEmployee(sid);
            
            

            // Get hours for the skills that this Employee can do and that need filling
            // CR-XXX - this should be ei.getSkillsNotODOMJ(skillsToFill), due to the data however, it gets difficult to resoruce the  
            // job and the code can go into a bit of a spiral. This can be fixed, either here or by improving findBestSecondaryOptions
            //rjd - 15-12-2009 - Changing to getSkillsNotODOMJ from getSkills as mentioned above.
            //Set<String> employeesSkills = ei.getSkills(skillsToFill);
            Set<String> employeesSkills = ei.getSkillsNotODOMJ(skillsToFill);
            if(employeesSkills == null || employeesSkills.isEmpty())
                continue;
            Double hours = ei.getHoursForSkills(employeesSkills);

            // Do they have a suitable gap?
            ResourceOption ro = findSuitableGap(ei, jro, employeesSkills, hours);
            
            
            if(ro == null) {
                // No suitable gap was found
                continue;
            }
            
            // If a resource option was found, add it to a list of resource options
            List<ResourceOption> secondaryOption = new List<ResourceOption>();
            secondaryOption.add(ro);

            // What missing skills remain?
            Set<String> skillsStillRemaining = skillsToFill.clone();
            skillsStillRemaining.removeAll(ro.skillsFullyCovered);
            
            // If there are still skills that need to be filled on the job.
            if(!skillsStillRemaining.isEmpty()) {
                // Create a set of IDs to act as a "blacklist" of employees to ignore when calling the
                // findBestSecondaryOptions method - this is because this employee should not be considered
                // to fill skill gaps he has!
                Set<ID> assignedAsBackup = new Set<ID>();
                assignedAsBackup.add(ei.employeeID);
                
                // Find the IDs of people who can do the remaining skills
                Set<ID> t = findBestSecondaryOptions(jro, skillsStillRemaining, assignedAsBackup);
                
                if(t == null || t.isEmpty()) {
                    // There aren't any options for the remaining skills.
                    continue;
                }

                // There are Employees who can fill the gaps left by this employee, we call this method again
                // with the same JRO, the skills left to fill and the IDs of Employees with the remaining skills
                // found above.
                List<List<ResourceOption>> r;
                if(stackDepthCount < 20){
                    stackDepthCount ++;
                 r = constructSecondaryOptions(jro, skillsStillRemaining, t);
                }
                if(r == null)
                    break;
                
                for(List<ResourceOption> l : r) {
                    secondaryOption.addAll(l);
                    for(ResourceOption temp : l) {
                        skillsStillRemaining.removeAll(temp.skillHoursAssigned.keySet());
                    }
                }
                
                if(!skillsStillRemaining.isEmpty()) {
                    secondaryOption = null;
                    break;
                }
            }
            
            if(secondaryOption != null && !secondaryOption.isEmpty()) {// && skillsStillRemaining.isEmpty()) { // && skillsToFill have been filled.
                // This secondary candidate is an option
                secondaryOptions.add(secondaryOption);
                
                // To avoid using resources too intensively to build these up, 
                // once we have an option break and carry on
                break;
            }
        }

        return secondaryOptions;
    }
    
    /* findSuitableGap(EmployeeInformation ei, JobResourcingOption jro, Set<String> employeesSkills, Double hours)
        Overloaded method for the findSuitableGap method - see that method below for more information. The main difference
        between them is that this method uses the JobResourcingOption's start and end DateTimes to call the overloaded version
        of this method. */
    private ResourceOption findSuitableGap(EmployeeInformation ei, JobResourcingOption jro, Set<String> employeesSkills, Double hours) {
        return findSuitableGap(ei, jro, employeesSkills, hours, jro.primaryStartDT, jro.primaryEndDT, false);
    }
    
    /* findSuitableGap(EmployeeInformation ei, JobResourcingOption jro, Set<String> employeesSkills,  
                       Double hours, DateTime currentStart, DateTime currentEnd)
        This method is used to find a suitable gap for an employee, to do a set of skills on a JobResourcingOption. The employee
        and the skills we want him to do are passed into the method, as is the number of hours we want him to do. The reason for
        passing in the number of hours rather than working it out from the skills we are looking for is that we may be calling
        this method when trying to split skills between Employees, therefore we may not want them to do all the hours for that 
        skill.
        
        This method also takes start and end parameters representing start and end times to control the behaviour of the method,
        and to control what gaps are considered suitable. currentStart is a DateTime that we want to look for a gap from, i.e.
        the earliest a suggested gap will start. currentEnd is used to indicate the current end point of a Job, for example, to
        prevent suggestions of gaps that take place after currentEnd. This parameter can be null, for circumstances where 
        this does not need to be considered.
        
        */
    private ResourceOption findSuitableGap(EmployeeInformation ei, JobResourcingOption jro, Set<String> employeesSkills,  
                                            Double hours, DateTime currentStart, DateTime currentEnd, Boolean sameDayOnly) {
        // Some variables used throughout the method.
        // 2 DECs, one to hold earliestGap (first available gap that can take all skills), one to hold largestGap (largest gap
        // that this employee has)
        DiaryEntryCollection earliestGap = null;
        DiaryEntryCollection largestGap = null;

        // We may have situations where a suitable gap starts before currentStart - therefore, we need an "adjustment" 
        // to that gap's start DateTime. adjustment holds the number of working hours that need to be added to the gap's
        // start to bring it up to the currentStart. largestAdjustment holds the adjustment for the largest available gap. 
        Double adjustment = 0.0;
        Double largestAdjustment = 0.0;
        Double largestSize = 0.0;           // Holds the numberOfHours in the Employee's largest gap
        
       
        
        // Loop through each of the Employee's DECs
        for(DiaryEntryCollection de : ei.availability.getDECs(businessAvailabilityFlag)) {
            adjustment = 0.0;
           system.debug(LoggingLevel.INFO, 'diary entry : '+de );
              system.debug(LoggingLevel.INFO, 'currentStart, currentEnd, de.startDT, de.finishDT' + currentStart + ', ' + currentEnd + ', ' + de.startDT + ', ' + de.finishDT);
            
            // If there was a currentEnd passed into the method and the current DEC starts after that end point,
            // break out of this loop, as this DEC is not suitable and subsequent DECs will only start after this one  
            if(currentEnd != null && de.startDT >= currentEnd) {
                break;
            }

            // If the current DEC starts before currentStart, this gap may be useful...
            if(de.startDT < currentStart) {
                // If the current DEC's finish is before currentStart, this gap isn't useful, but we 
                // should move on to the next DEC, as that one may be suitable.
                
                // DEFECT XXX
                // Changed this "if" statement logic. First part is as before, so if employee is not pool and
                // de finishes before currentStart, continue.
                // If the employee is pool, and the de finish is before current start, and we don't want
                // a diary entry on the same day OR we do want one on the same day but the de's day is before
                // current start's day, then continue.
                if((!ei.isPool && de.finishDT <= currentStart) 
                    || (ei.isPool && ((!sameDayOnly || (sameDayOnly && de.startDT.dayOfYear() < currentStart.dayOfYear()))
                        && de.finishDT < currentStart))) {
                    system.debug(LoggingLevel.INFO, 'continuing');
                    continue;
                }
                
                // This gap overlaps with the primary start, so we need to make an adjustment
                // DEFECT XXX - as above, some changes made. If employee is not pool, behave as before.
                if(!ei.isPool)
                    adjustment = de.workingHoursBetween(de.startDT, currentStart);
                else {
                    if(sameDayOnly && de.finishDT <= currentStart) {
                        // Employee is not pool, we want a dec on same day only, and this dec finishes before the current start
                        // so we make the adjustment to the full day, minus 5 minutes (0.08 of an hour)
                        adjustment = de.workingHoursBetween(de.startDT, de.finishDT) - 0.08;
                    } else {
                        // Either this isn't same Day only or this dec finishes after currentStart, so calculate
                        // adjustment as before.
                        adjustment = de.workingHoursBetween(de.startDT, currentStart);
                    }
                }
                system.debug(LoggingLevel.INFO, 'adjustment: ' + adjustment);
            }

            // Defect 258
            // Pool diaries need to be handled slightly differently...
            /*if(ei.isPool) { 
                if(de.numberOfHours >= hours) {
                    // This employee is a pool employee and has enough hours left within this DEC to do the hours
                    earliestGap = de;
                    break;
                } else if(sameDayOnly) {
                    // Employee is pool but does not have enough hours and we are only looking for DECs that are
                    // the same day as currentStart. If we have reached this far, the DEC is on the same day but
                    // does not have enough hours, hence we break, as this employee does not have suitable availability. 
                    break;
                } else if(de.numberOfHours >= largestSize) {
                    // This employee is a pool and does not have enough hours to do all skills, but it is the largest
                    // gap we've processed. As we are not looking for same day only, we keep track of the largest
                    // DEC that we have processed. 
                    largestGap = de;
                    largestAdjustment = adjustment;
                    largestSize = de.numberOfHours;
                }
                continue;
            }
            // - End fix for Defect 258
            if(de.numberOfHours - adjustment >= hours) {
                // This gap is big enough for all skills, set the earliestGap variable and break out
                // of the loop as we don't need to look at any more gaps
                earliestGap = de;
                break;
            } else if(de.numberOfHours - adjustment > largestSize) {
                // This gap is the largest we've yet seen, update the "largest" variables
                largestGap = de;
                largestSize = de.numberOfHours - adjustment;
                largestAdjustment = adjustment;
            }*/
            /* WIP */
            if(ei.isPool) { 
                if(sameDayOnly && de.startDT.dayOfYear() > currentStart.dayOfYear()) {
                    // Looking for a DEC starting on same day as currentStart - this doesn't fit the bill so break.
                    system.debug(LoggingLevel.INFO, 'a');
                    break;
                } else if(de.numberOfHours >= hours) {
                    // This employee is a pool employee and has enough hours left within this DEC to do the hours
                    system.debug(LoggingLevel.INFO, 'b');
                    earliestGap = de;
                    break;
                } else if(!sameDayOnly && de.numberOfHours >= largestSize) {
                    // This employee is a pool and does not have enough hours to do all skills, but it is the largest
                    // gap we've processed. As we are not looking for same day only, we keep track of the largest
                    // DEC that we have processed. 
                    system.debug(LoggingLevel.INFO, 'c');
                    largestGap = de;
                    largestAdjustment = adjustment;
                    largestSize = de.numberOfHours;
                }
            } else {
                if(sameDayOnly && de.startDT.dayOfYear() > currentStart.dayOfYear()) {
                    // Looking for a DEC starting on same day as currentStart - this doesn't fit the bill so break.
                    break;
                } else if(de.numberOfHours - adjustment >= hours) {
                    // This gap is big enough for all skills, set the earliestGap variable and break out
                    // of the loop as we don't need to look at any more gaps
                    System.debug(ei.employeeName + ' has enough hours: ' + de.numberOfHours + ' - ' + adjustment + ' = ' + hours);
                    earliestGap = de;
                    break;
                } else if(!sameDayOnly && de.numberOfHours - adjustment > largestSize) {
                    // This gap is the largest we've yet seen, update the "largest" variables. We don't do this
                    // if sameDayOnly is true.
                    system.debug(LoggingLevel.INFO, 'largest found...');
                    largestGap = de;
                    largestSize = de.numberOfHours - adjustment;
                    largestAdjustment = adjustment;
                }
            }
        }

        ResourceOption ro = null;
        if(earliestGap != null) {
            // We found a gap with enough hours for all skills, create a new ResourceOption for that
            ro = new ResourceOption(employeesSkills, earliestGap, ei, SearchBlackBox.jobInfo, adjustment);
        } else if(largestGap != null) {
            // There wasn't a gap with enough hours for all skills but there was a gap with a number
            // of hours - call removeSkillsToFitGap to get a ResourceOption that best uses the largest 
            // gap (if no use can be made of the largest gap, null will be returned)
            system.debug(LoggingLevel.INFO, 'trying to remove skills');
            if(ei.isPool && currentStart.time() > largestGap.finishDT.time()) {
                // If this employee is a pool diary and we are looking for this employee to start
                // after his shift ends, we need to change the start time to 5 minutes before
                // the end of his day i.e. we ask them to start as late as possible 
                ro = removeSkillsToFitGap(largestGap, largestGap.numberOfHours - largestAdjustment, 
                                            largestGap.finishDT.addMinutes(-5), ei, employeesSkills, false);
            } else {
                ro = removeSkillsToFitGap(largestGap, largestGap.numberOfHours - largestAdjustment, 
                                            currentStart, ei, employeesSkills, false);
            }
        }
        
        //SB fix
        if(ro!=null)
        {
            if(ei.ispool && ro.startDT==ro.EndDT && ro.hoursTotal==hours && ro.hoursTotal<=adjustment)
            {
                List<List<String>> shifts = getShifts(ro.entry.entryInfoObjects[0].entry);
                ro.startDT= DateTimeHelper.subtractWorkingHoursToDateTime(ro.endDT,hours,shifts);
            }
        }
        system.debug(LoggingLevel.INFO, 'returning ro: ' + ro);
        return ro;
    }

    /* constructDoubleHandedOptions(ID namedEmployee)
        This method creates double handed resourcing options for a Job. */
    private List<JobResourcingOption> constructDoubleHandedOptions(ID namedEmployee) {
        system.debug(LoggingLevel.INFO, 'AWWEmpsWithOption: ' + AWWEmpsWithOption);
        Map<String, Double> jobSkillsAndHours = SearchBlackBox.jobInfo.skillsAndHours;
        List<JobResourcingOption> businessOptions = new List<JobResourcingOption>();
        set<ID> alwaysWorkAlone= new set<ID>();
        
        // We populate a nested list with potential Employee IDs for the Job. For double handed jobs, two resources
        // split the primary skill (and other skills they share). These resources must be from the same Supplier,
        // hence the nested list; each list contains the IDs of a supplier's Employees with the primary skill  
        List<List<ID>> supplierCandidates = new List<List<ID>>(); 
        if(namedEmployee != null) {
            // If there's a named employee, add him and the employees at his supplier
            system.debug(LoggingLevel.INFO, 'namedEmployee: ' + namedEmployee);
            EmployeeInformation ei = employees.getEmployee(namedEmployee); 
            supplierCandidates.add(employees.primaryBySupplierID.get(ei.supplierID));
            //system.debug(LoggingLevel.INFO,'supplier Candidates---->'+supplierCandidates+' '+supplierCandidates.size());
        } else {
            // Candidates for a double handed job must be from the same supplier i.e. an Employee from Supplier A can
            // only "double hand" the primary skill for a Job with other Employees from Supplier A
            system.debug(LoggingLevel.INFO, 'No Named Employee');
            
            supplierCandidates.addAll(employees.primaryBySupplierID.values());
            /* DEBUG
            for(ID sID : employees.primaryBySupplierID.keySet()) {
                system.debug(LoggingLevel.INFO, 'Supplier: ' + sID);
                if(sID == 'a09S0000000vLlEIAU' || sID == 'a0920000001n5ltAAA' || sID == 'a0920000001n5s4AAA')
                    continue;
                system.debug(LoggingLevel.INFO, 'Supplier candidates: ' + employees.primaryBySupplierID.get(sID));
                supplierCandidates.add(employees.primaryBySupplierID.get(sID));
            }*/
        }
         
        // This loops over lists of Employee IDs, each list belongs to a supplier.
        for(List<ID> supplierEmployees : supplierCandidates) {
            // If there are less than 2 Employees for this supplier, there's no one to compare
            if(supplierEmployees.size() < 2)
                continue;
            
           // system.debug(LoggingLevel.INFO,'--=-=-=-=-=->'+supplierEmployees.size()+' '+supplierEmployees);
            // Code used for debugging - this can be used to cut down the employees looped over
            /* DEBUG!
            Integer debugCountStart = 0;
            Integer debugCountEnd = 2;
            Integer debugCounter = 0;
            system.debug(LoggingLevel.INFO, 'start: ' + debugCountStart + ' end: ' + debugCountEnd + ' counter: ' + debugCounter);*/
            
            // We loop over the list of Employee IDs, comparing the employee with the ID in "first" with everyone
            // to the "right" of him in the list.
            for(Integer start = 0 ; start <= supplierEmployees.size() - 1; start++) {
                /* DEBUG
                system.debug(LoggingLevel.INFO, 'start: ' + debugCountStart + ' end: ' + debugCountEnd + ' counter: ' + debugCounter);
                if(debugCounter >= debugCountStart && debugCounter < debugCountEnd) {
                    system.debug(LoggingLevel.INFO, 'Processing');
                    debugCounter++;
                } else {
                    system.debug(LoggingLevel.INFO, 'Not Processing');
                    //debugCounter++;
                    continue;
                }*/
                system.debug(LoggingLevel.INFO,''+supplierEmployees[start]);
                // Get the ID of the current Employee. 
                ID first = supplierEmployees[start];
                system.debug(LoggingLevel.INFO, 'first ID: ' + first);
                
                // DEBUG
                //if(first == 'a0A20000002Rs3JEAS')
                //  continue;

                // If there's a named Employee and "first" is not that employee, move on to the next Employee 
                if(namedEmployee != null && first != namedEmployee) {
                    continue;
                }
                system.debug(LoggingLevel.INFO,'I am ok');
                // Get the EmployeeInformation object and check whether he always works alone. If so, continue!
                EmployeeInformation firstEI = employees.getEmployee(first);
                if(firstEI.alwaysWorksAlone)
                    continue;

                // ASSUMPTION: If employee always works with someone else, consider only that pairing 
                if(firstEI.alwaysWorksWith != null) {
                    // Defect 229
                    // Check to see if the employee this person always works with has already had a proposed option  
                    if(AWWEmpsWithOption.contains(firstEI.alwaysWorksWith)) {
                        continue;
                    }
                    EmployeeInformation secondEI = employees.getEmployee(firstEI.alwaysWorksWith);
                    List<JobResourcingOption> options = processDoubleHandedPair(firstEI, secondEI);
                    system.debug(LoggingLevel.INFO, '778 options '+options);
                    if(options != null && !options.isEmpty()){
                        // Defect 229 - because of the fix below (rjd 2010-01-13), this line is no longer needed as it
                        // happens below.
                        //businessOptions.addAll(options);
                        
          //rjd - 2010-01-13 - stolen from below...
          //Problem with planFromEndOfJob skills being ignored.
                        // Now skills planned back from the end of a job
                        options = planSkillsFromEnd(options);
                        // If no options are returned, continue.
                        if(options != null && !options.isEmpty()) {
                            businessOptions.addAll(options);
                            // Defect 229
                            // Add this employee's ID to the set created above - this will prevent this pairing
                            // being considered for a second time when we get to the AWW Employee.
                            AWWEmpsWithOption.add(firstEI.employeeID);
                        }
                    }
                    continue;
                }
                
                // DEBUG
                //Set<ID> ignoreThese = new Set<ID>{'a0A20000002RtitEAC'};

                // Defect 233
                JobResourcingOption bestJRO = null; // Short circuit 1
                
                // Loop over the other Employees for this supplier.
                for(Integer count = start+1; count < supplierEmployees.size(); count++) {
                    ID second = supplierEmployees[count];
                    system.debug(LoggingLevel.INFO, 'second ID: ' + second);
                    
                    // DEBUG
                    //if(ignoreThese.contains(second))
                    //  continue;
                    
                    EmployeeInformation secondEI = employees.getEmployee(second);
                    
                    // There are some situations where we shouldn't compare this "second" employee to "first"
                    if((secondEI.alwaysWorksAlone) || secondEI.alwaysWorksWith != null || firstEI.employeeID == secondEI.employeeID ||
                        (firstEI.neverWorksWith == secondEI.employeeID) || secondEI.neverWorksWith == firstEI.employeeID||alwaysWorkAlone.contains(firstEI.employeeID))
                        continue;
                    
                    // Defect 233
                    // Short circuit 1 - This piece of code (along with some others below) can be used to ease the number
                    // of statements used. We keep track of the "best" JRO - the earliest JRO. If we have a bestJRO, and the
                    // current Employee's DECs are later than the JRO's start, this employee will not be better, so skip it 
                    if(SearchBlackBox.jobInfo.tooManyScriptStatements && bestJRO != null) {
                        DiaryEntryCollection earliestDEC = secondEI.availability.getEarliest(businessAvailabilityFlag);
                        if(earliestDEC != null && earliestDEC.startDT >= bestJRO.primaryStartDT) {
                            continue;
                        } else if(earliestDEC == null) {
                            DiaryEntryCollection largestDEC = secondEI.availability.getLargest(businessAvailabilityFlag);
                            if(largestDEC != null && largestDEC.startDT >= bestJRO.primaryStartDT)
                                continue;
                        }
                    }
                    
                    // Call the method to process this pair of employees
                    List<JobResourcingOption> options = processDoubleHandedPair(firstEI, secondEI);
                    system.debug(LoggingLevel.INFO, '820 options '+options);
                    // If no options are returned, continue.
                    if(options == null || options.isEmpty())
                        continue;

                    // Now skills planned back from the end of a job
                    options = planSkillsFromEnd(options);
                    // If no options are returned, continue.
                    if(options == null || options.isEmpty())
                        continue;
                    else {
                        businessOptions.addAll(options);
                         alwaysWorkAlone.add(firstEI.employeeID);
                        // Short circuit 1
                        if(SearchBlackBox.jobInfo.tooManyScriptStatements) {
                            for(JobResourcingOption jro : options) {
                                if(bestJRO == null) {
                                    bestJRO = jro;
                                    continue;
                                } else if(jro.primaryStartDT <= bestJRO.primaryStartDT) {
                                    bestJRO = jro;
                                    continue;
                                }
                            }
                        }
                        // Short circuit 2
                        //break;
                    }
                }
            }
        }
        
        return businessOptions;
    }

    /* processDoubleHandedPair(EmployeeInformation firstEI, EmployeeInformation secondEI)
        Overloaded version of the processDoubleHandedPair method. This calls the 3-parameter version of the method, 
        passing in all skills on the job i.e. it processes a pair looking for all skills on a Job. */
    private List<JobResourcingOption> processDoubleHandedPair(EmployeeInformation firstEI, EmployeeInformation secondEI) {
        return processDoubleHandedPair(firstEI, secondEI, SearchBlackBox.jobInfo.skillsAndHours.keySet());
    }

    /* processDoubleHandedPair(EmployeeInformation firstEI, EmployeeInformation secondEI, Set<String> skills)
        Considers two Employees for a set of skills - all passed into the method. */
    private List<JobResourcingOption> processDoubleHandedPair(EmployeeInformation firstEI, EmployeeInformation secondEI, Set<String> skills) {
        // What skills do they share?
        // ASSUMPTION: Not bothered about "Only do on my Jobs", so use "getSkills" rather than "getSkillsNotODOMJ".
        // Using getSkillsNotODOMJ may help reduce the number of script statements ?
        
        //rjd - 2010-01-11 - Trying to stop problems with the second employee of a pair not
        //being available (e.g. inactive)
        if(firstEI == null || secondEI==null)
            return null;
        Set<String> sharedSkills = firstEI.getSkills(skills);
        sharedSkills.removeAll(SearchBlackBox.SKILLS_PLANNED_FROM_END);
        sharedSkills.retainAll(secondEI.getSkills(skills));
        System.debug('sharedSkills display'+sharedSkills);
        
        // If there are no shared skills or one of the shared skills is not the primary skill, return null
        if(sharedSkills.isEmpty() || !sharedSkills.contains(SearchBlackBox.jobInfo.primarySkill))
            return null;
        
        List<JobResourcingOption> jros = new List<JobResourcingOption>();
        
        // 2. How many hours do they need to do these skills?
        // ASSUMPTION: if we did this on secondEI, we'd get the same answer
        Double sharedHours = firstEI.getHoursForSkills(sharedSkills);
        for(DiaryEntryCollection de1 : firstEI.availability.getDECs(businessAvailabilityFlag)) {
            for(DiaryEntryCollection de2 : secondEI.availability.getDECs(businessAvailabilityFlag)) {
                
                // Temporary fix to help debugging
                /*if(de2 == null || de1 == null) {
                    throw new SearchException('Null Pointer Exception: ' + de2 + ' ' + de1);
                } else if(de2.startDT == null || de1.finishDT == null) {
                    throw new SearchException('Null Pointer Exception: de2Start: ' + de2.StartDT + ' de1Finish: ' 
                                                + de1.finishDT + ' de2 EIO: ' + de2.entryInfoObjects + ' de1 EIO: ' + de1.entryInfoObjects
                                                + 'de2: ' + de2 + 'de1: ' + de1);
                }*/
                if(de2.startDT == null || de1.finishDT == null) {
                    system.debug(LoggingLevel.INFO, 'de2.startDT: ' + de2.startDT + ' de1.finishDT: ' + de1.finishDT);
                    continue;
                }
               
                
                //  if(de2.startDT.dayOfYear() > de1.finishDT.dayOfYear()) 
                //      break;
                
                  //PRB00027083 fix starts
            
                if(de2.startDT.year() == de1.finishDT.year() ){
                    if(de2.startDT.dayOfYear() > de1.finishDT.dayOfYear()) 
                        break;
                }
                else if(de2.startDT.year()> de1.finishDT.year()){
                    break;
                }
                 //PRB00027083 fix ends
                system.debug(LoggingLevel.INFO, 'de2.startDT: ' + de2.startDT + ' de1.finishDT: ' + de1.finishDT+ ' de2.finishDT: ' + de2.finishDT+'de1.startDT: ' + de1.startDT);
                // Compare these two DECs
                List<JobResourcingOption> options = compareDECs(de1, de2, firstEI, secondEI, sharedSkills, sharedHours);
                
                if(options == null || options.isEmpty()) {
                    // If no options are returned, move onto the next DEC of the second Employee
                    continue;
                }
                // We have options to add
                jros.addAll(options);
                break;
            }
            // If jros is not empty, stop looking for suitable DECs
            if(!jros.isEmpty())
                break;
        }

        if(jros.isEmpty())
            return null;
        else 
            return jros;
    }

    /* compareDECs(DiaryEntryCollection de1, DiaryEntryCollection de2, EmployeeInformation firstEI,
                                                    EmployeeInformation secondEI, Set<String> sharedSkills, Double sharedHours)
        Takes two DiaryEntryCollections and sees if they are suitable for the Employees they belong to work on a job
        together as a "Double Handed Pair". */
    private List<JobResourcingOption> compareDECs(DiaryEntryCollection de1, DiaryEntryCollection de2, EmployeeInformation firstEI,
                                                    EmployeeInformation secondEI, Set<String> sharedSkills, Double sharedHours) {
       
        
        if(!((de2.startDT >= de1.startDT && de2.startDT <= de1.finishDT) ||
                (de2.finishDT >= de1.startDT && de2.finishDT <= de1.finishDT) ||
                (de2.startDT <= de1.startDT && de2.finishDT >= de1.finishDT))) {
                
            // These DECs do not overlap
            return null;
        }
        
         //Suguna - heavy appliance fix 
        // heavy appliance fix 
       if(SearchBlackBox.jobInfo.job.Heavy_Appliance__c&&system.label.Heavy_Appliance_Job=='on'&&!SearchBlackBox.jobInfo.job.Override_Heavy_Appliance__c)
        {
                 if(de2.startDT!=de1.startDT) {
                           if(de2.startDT<de1.startDT)
                           {
                               de2.numberOfHours=de2.numberOfHours - de2.workingHoursBetween(de2.startDT,de1.startDT);
                               //de2.startDT= Datetime.newInstance(de2.StartDT.date().adddays(1),DateTimeHelper.stringToTime(de2.entryInfoObjects[0].MstartTime));
                               de2.startDT = de1.startDT;
                               
                           }
                           else if(de1.startDT<de2.startDT)
                           {
                                de1.numberOfHours=de1.numberOfHours - de1.workingHoursBetween(de1.startDT,de2.startDT);
                               //de1.startDT=Datetime.newInstance(de1.StartDT.date().adddays(1),DateTimeHelper.stringToTime(de1.entryInfoObjects[0].MstartTime));
                               de1.startDT =de2.startDT;
                           }
                 }
        }
       
        // We use some variables depending on which DEC is earliest. This is because we do not know which DEC passed in is 
        // earliest, so we work it out here so that calling methods don't need to worry about what way round the information
        // is passed in.
        DiaryEntryCollection earliest = null;
        DiaryEntryCollection latest = null;
        EmployeeInformation earliestEI = null;
        EmployeeInformation latestEI = null;
        
        // Set the variables
        if(de1.startDT <= de2.startDT) {
            earliest = de1;
            earliestEI = firstEI;
            latest = de2;
            latestEI = secondEI;
        } else {
            earliest = de2;
            earliestEI = secondEI;
            latest = de1;
            latestEI = firstEI;
        }
       
        // More variables needed to do what we need - we need to know the Datetimes of earliest and latest starting DEC 
        Datetime earliestStart = earliest.startDT;
        Datetime latestStart = latest.startDT;
        Datetime earliestEnd = earliest.finishDT <= latest.finishDT ? earliest.finishDT : latest.finishDT;
        

        // Work out how many hours are in the earliest and latest DEC. This is done differently depending on whether the Employees are
        // Pool or not.
        //Double earliestShared = earliest.isPool ? earliest.numberOfHours : earliest.workingHoursBetween(latestStart, earliestEnd);
        //Double latestShared = latest.isPool ? latest.numberOfHours : latest.workingHoursBetween(latestStart, earliestEnd);
        
        // Defect XXX
        // Changed so that gap size tolerance is included in these calculations.
        Double earliestShared = earliest.isPool 
                                ? earliest.numberOfHours
                                : (earliest.workingHoursBetween(latestStart, earliestEnd) + SearchBlackBox.optsAndParms.gapSizeTolerance);
        Double latestShared = latest.isPool 
                                ? latest.numberOfHours 
                                : (latest.workingHoursBetween(latestStart, earliestEnd) + SearchBlackBox.optsAndParms.gapSizeTolerance);
         
         
        // We also need to consider offsets between the two DECs. There is the difference between when the earliest and  
        // latest DECs start times, and also how much time there is between when the Employees can start on the Job
        Double DECstartOffset = earliest.workingHoursBetween(earliestStart, latestStart);
        Double jobStartOffset = 0.0;
        
        // Employees may be allowed to start at different times - this is controlled by a parameter. If the difference between
        // the DECs is greater than the parameter, set the offset to the value of the parameter. If not, if the difference
        // between the two DECs is greater than 0, set the offset to that value.
        if(DECstartOffset >= SearchBlackbox.optsAndParms.hoursBetweenResources) {
            jobStartOffset = SearchBlackbox.optsAndParms.hoursBetweenResources;
        } else if(DECstartOffset > 0) {
            jobStartOffset = DECstartOffset;
        }
       
        
        // Defect 239
        // If the jobStartOffset is greater than the hours shared, these DECs should not be considered
        if(jobStartOffset >= sharedHours)
            return null;

        List<ResourceOption> primaryOptions = null;

        if(earliestShared + latestShared + jobStartOffset >= sharedHours) {
            // If there are enough hours between the two resources for all their skills, split all their skills
                system.debug(LoggingLevel.INFO, 'Splitting all shared skills');
            primaryOptions = splitSharedSkills(earliest, latest, earliestEI, latestEI, sharedSkills, 
                                                earliestShared, latestShared, jobStartOffset, DECstartOffset, sharedHours);
                                                                    
        } else if(earliestShared + latestShared + jobStartOffset >= SearchBlackBox.jobInfo.primaryHours) {
            // If there is not enough time for all their skills to be split, but there is enough time to split 
            // the primary skill, then split that skill only.
            system.debug(LoggingLevel.INFO, 'Splitting primary skill only');
            skillsfullycoveredcheck = true; //Added as part of PRB00028301
            System.debug('skillsfullycoveredcheck '+skillsfullycoveredcheck);
            primaryOptions = splitSharedSkills(earliest, latest, earliestEI, latestEI, 
                                                new Set<String>{SearchBlackBox.jobInfo.primarySkill},
                                                earliestShared, latestShared, jobStartOffset, DECstartOffset, 
                                                SearchBlackBox.jobInfo.primaryHours);
        }

        // If there aren't any options, return null
        if(primaryOptions == null || primaryOptions.isEmpty()) {
            system.debug(LoggingLevel.INFO, 'no primary options, returning null');
            return null;
        }
        
        // If we have ResourceOptions, create a Job Resourcing Option.
        JobResourcingOption jro = new JobResourcingOption();
        jro.addPrimaryOptions(primaryOptions); 
        
        // And now for the secondary candidates to fill missing skills
        List<JobResourcingOption> options = fillSkillGaps(jro);
        
        return options;
    }
    
    /* splitSharedSkills(DiaryEntryCollection de1, DiaryEntryCollection de2, EmployeeInformation ei1, 
                        EmployeeInformation ei2, Set<String> sharedSkills, Double earliestShared, 
                        Double latestShared, Double jobStartOffset, Double DECstartOffset)
                                                    
        This method takes a Set of skills and splits them between Employees and the DECs passed into the method. 
        ResourceOptions are created taking into account the offsets passed in to the method. Information about the number of
        hours available in the earliest and latest DECs is passed into the method rather than recalculated here to prevent
        overuse of script statements.
        */
    private List<ResourceOption> splitSharedSkills(DiaryEntryCollection de1, DiaryEntryCollection de2, EmployeeInformation ei1, 
                                                    EmployeeInformation ei2, Set<String> sharedSkills, Double earliestShared, 
                                                    Double latestShared, Double jobStartOffset, Double DECstartOffset, Double hoursToSplit) {

        // ASSUMPTION here that de1 is earlier than de2, and that de1 belongs to ei1 and de2 belongs to ei2.
        
        // Defect 239 
        // This gives a percentage as a decimal - it is used to determine how much of a skill should be assigned to the
        // DEC and Employee with most hours.
        
        // Commented out as part of fix for Defect 239
        //Double totalSharedHours = earliestShared + latestShared + jobStartOffset;
        //Double largerProportion = (earliestShared + jobStartOffset > latestShared) 
        //                            ? ((earliestShared + jobStartOffset) * 1.0) / totalSharedHours 
        //                            : (latestShared * 1.0) / totalSharedHours;
                                    
        
        // How much work is there after the jobStartOffset is taken into account? jobStartOffset represents
        // how much earlier the earliest employee can start before the latest employee
        Double hoursWithoutOffset = (hoursToSplit - jobStartOffset);
        Double largerProportion = 0.0;
        if(hoursWithoutOffset / 2 <= earliestShared && hoursWithoutOffset / 2 <= latestShared) {
            // Each employee has enough time for half of the remaining work
            largerProportion = ((hoursWithoutOffset / 2) + jobStartOffset) / hoursToSplit;  
            System.debug('largerProportion if'+largerProportion);
        } else {
            // One of the employees does not have enough hours for a 50/50 split, therefore we'll assign them
            // all the hours they can do, and the other employee will get the larger share 
            if(earliestShared > latestShared) {
                // earliestShared has more hours
                largerProportion = (hoursToSplit - latestShared) / hoursToSplit;
                System.debug('largerProportion else if'+largerProportion);
            } else {
                // latestShared has more hours, or is equal
                largerProportion = (hoursToSplit - earliestShared) / hoursToSplit;
                 System.debug('largerProportion else else'+largerProportion);
            }
        }
        
        // - End fix for Defect 239

        // Maps to hold how much of each skill each Employee is doing.
        Map<String, Double> skillsHoursSplit1 = new Map<String, Double>();
        Map<String, Double> skillsHoursSplit2 = new Map<String, Double>();  
        
        // Loop over the skills and put the values for each skill into the above Maps
        for(String skill : sharedSkills) {
        System.debug('skill loop'+skill);
            Double currentSkillHours = SearchBlackBox.jobInfo.skillsAndHours.get(skill);
            Decimal largerHours = (currentSkillHours * 1.0) * largerProportion;
            // Defect 257
            //Decimal smallerHours = (currentSkillHours * 1.0) * (1.0 - largerProportion);
            Decimal smallerHours = currentSkillHours - largerHours.setScale(2).doubleValue();
            System.debug('largerHours disp'+largerHours+' smallerHours disp '+smallerHours);
            skillsHoursSplit1.put(skill, largerHours.setScale(2).doubleValue());
            skillsHoursSplit2.put(skill,  smallerHours.setScale(2).doubleValue());
            System.debug('skillsHoursSplit1 disp'+skillsHoursSplit1);
            System.debug('skillsHoursSplit2 disp'+skillsHoursSplit2);
        }
  
  //PRB00024926  
  
  //fix for entries getting swapped between named employee and always works with employee on changing the named employee in the job    
  
List<Diary_Entry__c> existingEmployeeslist = new List<Diary_Entry__c>([Select Employee_Name__c,Sub_Type__c,Hours__c,Employee_ID__c from Diary_Entry__c d where d.job__c =: SearchBlackBox.jobInfo.job.id and d.Sub_Type__c != 'Travel Time']);
        Map<Id,Map<String,Double>> employeeidwithskillsandhours = new Map<Id,Map<String,Double>>();
        
        System.debug('existingEmployeeslist '+existingEmployeeslist);
        boolean ei1split1 = false;
        boolean ei1split2 = false;
        boolean ei2split1 = false;
        boolean ei2split2 = false;
        
     if(existingEmployeeslist.size() >0){
        for(Diary_Entry__c em :existingEmployeeslist){
       if(!employeeidwithskillsandhours.keySet().contains(em.Employee_ID__c))
       employeeidwithskillsandhours.put(em.Employee_ID__c,new Map<String,Double>{em.Sub_Type__c.toUpperCase() => em.Hours__c});
       else
        employeeidwithskillsandhours.get(em.Employee_ID__c).put(em.Sub_Type__c.toUpperCase(),em.Hours__c);       
        }
        System.debug('employeeidwithskillsandhours '+employeeidwithskillsandhours);
         if(employeeidwithskillsandhours.keyset().contains(ei1.employeeID) && employeeidwithskillsandhours.keyset().contains(ei2.employeeID)){
        for(Id empid : employeeidwithskillsandhours.keyset()){
    
                
                ei1split1 = diaryentriescomparisonmethod(ei1.employeeID,skillsHoursSplit1,employeeidwithskillsandhours);    
                ei1split2 = diaryentriescomparisonmethod(ei1.employeeID,skillsHoursSplit2,employeeidwithskillsandhours);
                ei2split1 = diaryentriescomparisonmethod(ei2.employeeID,skillsHoursSplit1,employeeidwithskillsandhours);
                ei2split2 = diaryentriescomparisonmethod(ei2.employeeID,skillsHoursSplit2,employeeidwithskillsandhours);
            
         } 
         System.debug('ei1split1,ei1split2,ei2split1,ei2split2 '+ei1split1+ei1split2+ei2split1+ei2split2);  
        }
        }
        
       // Create ResourceOptions for the Employees. We also try and assign any additional skills they have for the job  
        // but are not shared and that they have time for. 
        // We also have to determine which of the Employees has the largest amount of hours.         
        if(earliestShared + jobStartOffset > latestShared || (ei1split1 == true && ei2split2 == true && ei1split2 == false && ei2split1 == false)) {
            System.debug('Inside if condition ');
            // Earliest DEC is bigger
            ResourceOption ro1 = addAdditionalSkills(skillsHoursSplit1, de1, ei1, DECstartOffset - jobStartOffset, null);
            //PRB00028301 start
            if(ro1.skillsFullyCovered != null)
            skillsCoveredcheckmap = ro1.skillsFullyCovered.clone(); 
            System.debug('skillsCoveredcheckmap if loop: '+skillsCoveredcheckmap);         
            //PRB00028301 end
            // The following may be needed to remove skills that were assigned to ro1 as otherwise we may assign skills twice.
            //Set<String> additionalSkillsCovered = ro1.skillsFullyCovered.clone();
            //additionalSkillsCovered.removeAll(skillsHoursSplit1.keySet());         
            ResourceOption ro2 = addAdditionalSkills(skillsHoursSplit2, de2, ei2, 0, null);//, additionalSkillsCovered);
            
            if(ro1 == null || ro2 == null)
                return null;
            return new List<ResourceOption> {ro1, ro2};
        } else {
             // Latest DEC is bigger
            ResourceOption ro1 = addAdditionalSkills(skillsHoursSplit2, de1, ei1, DECstartOffset - jobStartOffset, null);
             // The following may be needed to remove skills that were assigned to ro1 as otherwise we may assign skills twice.
            //Set<String> additionalSkillsCovered = ro1.skillsFullyCovered.clone();
            //additionalSkillsCovered.removeAll(skillsHoursSplit1.keySet());
            //PRB00028301 start
            if(ro1.skillsFullyCovered != null)
            skillsCoveredcheckmap = ro1.skillsFullyCovered.clone(); 
            System.debug('skillsCoveredcheckmap else loop: '+skillsCoveredcheckmap);         
            //PRB00028301 end 
            ResourceOption ro2 = addAdditionalSkills(skillsHoursSplit1, de2, ei2, 0, null);//, additionalSkillsCovered);
           
            if(ro1 == null || ro2 == null)
                return null;
            return new List<ResourceOption> {ro2, ro1};
        }
    }
 
    /* addAdditionalSkills(Map<String, Double> alreadyAssigned, DiaryEntryCollection dec, 
                                                EmployeeInformation ei, Double addToStart)
        This method is used when splitting skills between Employees. It takes an assignment of skills and hours doing those
        skills that we are booking into an Employee's DEC. Before we do that, we try and fit any additional skills into the
        DEC - this means that in addition to skills shared between two resources that are being split, we try and add any other
        skills they have in their remaining time. This could include skills one employee has but the other does not. 
        
        There is also a Set of Strings that can be passed in - these are skills that should not be assigned. This may be
        needed to fix something in the splitSharedSkills method above to prevent skills getting assigned twice. However, it
        has not been tested in time for deployment, so it's use is currently commented out. */
    private ResourceOption addAdditionalSkills(Map<String, Double> alreadyAssigned, DiaryEntryCollection dec, 
                                                EmployeeInformation ei, Double addToStart, Set<String> skillsToIgnore) {
        // What additional skills are needed?
        Set<String> skills = SearchBlackBox.jobInfo.skillsAndHours.keySet().clone();
        skills.removeAll(alreadyAssigned.keySet());
        //PRB00028301 starts
        System.debug('skills display before removal '+skills);
        if(skillsfullycoveredcheck == true){
        if(skillsCoveredcheckmap != null)
        skills.removeAll(skillsCoveredcheckmap);      
        } 
        System.debug('skills display after removal '+skills);
        //PRB00028301 ends
        // This may be required to prevent skills being assigned to more than one person
        //if(skillsToIgnore != null && !skillsToIgnore.isEmpty())
        //  skills.removeAll(skillsToIgnore);
        
        // Find which of the skills this employee has
        skills = ei.getSkills(skills);
        
        // How much time is needed for the remaining skills this employee can do?
        Double timeForSkills = ei.getHoursForSkills(skills);
        
        // How much time does resource have left? 
        Double hoursAssigned = 0.0;
        for(Double d : alreadyAssigned.values()) {
            hoursAssigned += d;
        }
        
        // Which outstanding skill needs the lowest amount of hours? We track this as if the gaps aren't big enough
        // for even the lowest number of hours, we needn't bother looking for options.  
        Double lowest = null;
        for(String skill : skills) {
            if(lowest == null || SearchBlackBox.jobInfo.skillsAndHours.get(skill) < lowest)
                lowest = SearchBlackBox.jobInfo.skillsAndHours.get(skill);
        }
        
        // Find out when this person will finish the work they have been assigned 
        Datetime sharedEndTime = dec.addWorkingHoursToStart(addToStart + hoursAssigned);
        
        //suguna - PH Jones Change
        if(ei.overBookingExpHours>0.0 )
        {
            List<List<String>> shifts = getShifts(dec.entryInfoObjects[0].entry);
            dec.finishDT= DateTimeHelper.subtractWorkingHoursToDateTime(sharedEndTime,double.valueof(ei.overBookingExpHours),shifts);
        }
        //suguna - ends
        
        
        // If lowest is null, there are no other skills to plan. If the Employee is not a pool and the end time is the same as 
        // the DEC end time, there's no more time to book into. If the Employee is a Pool and the hours left is less than 
        // "lowest" there's no more time to book into. In all these circumstances, create the ResourceOption.
        // Defect XXX
        // There are cases where individuals in a double handed pairing may have skills the other person does not. If there is
        // still time remaining between the start and end of the diary entry, or gap size tolerance, we can possibly fit these 
        // individual skills in. The "!ei.isPool" part of this if statement did not originally consider the gap size tolerance.
        // It checked the sharedEndTime and DEC finish time, however this does not properly account for the gapSizeTolerance.
        //
        // We have moved the timeLeft initialisation to before the if statement and changed how it is worked out. We have the
        // information passed into the method, and so don't need to call the workingHoursBetween method. This now takes into
        // account the gapSizeTolerance and saves on script statements. It should also make the sharedEndTime calculation
        // redundant, though this requires some testing. timeLeft is now used in the if statement.
                
        // Work out how much time is left to book into.
        Double timeLeft = ei.isPool 
                        ? dec.numberOfHours - hoursAssigned 
                        //: dec.workingHoursBetween(sharedEndTime, dec.finishDT); // changed as part of gapSizeTolerance fix mentioned above
                        : dec.numberOfHours - (addToStart + hoursAssigned );
                        
                        
        
        if(lowest == null 
            //|| (!ei.isPool && sharedEndTime == dec.finishDT // - modified as described above and shown below.
            || (!ei.isPool && sharedEndTime == dec.finishDT && timeLeft < lowest) 
            || (ei.isPool && dec.numberOfHours - hoursAssigned < lowest)) {
            // No time for additional skills, return new ResourceOption
            ResourceOption ro = new ResourceOption(alreadyAssigned, dec, ei, SearchBlackBox.jobInfo, addToStart);
            ro.skillsRemoved = true;
            return ro;
        }
        
        if(timeLeft < lowest) {
            // Time left is lower than the skill requiring the lowest amount of hours - create a RO 
            ResourceOption ro = new ResourceOption(alreadyAssigned, dec, ei, SearchBlackBox.jobInfo, addToStart);
            ro.skillsRemoved = true;
            return ro;
        } else if(timeLeft >= timeForSkills) {
            // Employee has enough time for all additional skills, put the details into the alreadyAssigned Map and create the RO.
            for(String skill : skills) {
                alreadyAssigned.put(skill, SearchBlackBox.jobInfo.skillsAndHours.get(skill));
            }
            return new ResourceOption(alreadyAssigned, dec, ei, SearchBlackBox.jobInfo, addToStart);
        } else {
            // There is time to book into, but not enough for all additional skills - get the best fit of skills for the
            // gap and create the RO.
            system.debug(LoggingLevel.INFO, 'GETTING BEST SKILLS...');
            Set<String> bestSkills = getBestSkills(skills, timeLeft, false);
            for(String skill : bestSkills) {
                alreadyAssigned.put(skill, SearchBlackBox.jobInfo.skillsAndHours.get(skill));
            }
            ResourceOption ro = new ResourceOption(alreadyAssigned, dec, ei, SearchBlackBox.jobInfo, addToStart);
            ro.skillsRemoved = true;
            return ro;
        }       
    }
    //PRB00024926 
    // added method for comparing diary entries skills and hours
       boolean diaryentriescomparisonmethod(Id empid,Map<String, Double> skillsHoursSplitmap,Map<Id,Map<String,Double>> employeeidwithskillsandhoursmap){
        boolean temp = false;
        for(String splitmap : skillsHoursSplitmap.keyset()){
            if(employeeidwithskillsandhoursmap.get(empid).get(splitmap) !=null){
          if(skillsHoursSplitmap.get(splitmap) == employeeidwithskillsandhoursmap.get(empid).get(splitmap))
              temp = true;
          else{
              temp = false;
              break;
                }}
            else{
                temp = false;
              break;
            }
            }
            System.debug('temp '+temp);
        return temp;}
        
    private List<JobResourcingOption> constructDoubleHandedOptionsHeavy(ID namedEmployee) {
        Map<String, Double> jobSkillsAndHours = SearchBlackBox.jobInfo.skillsAndHours;
        List<JobResourcingOption> businessOptions = new List<JobResourcingOption>();
        set<ID> alwaysWorkAlone= new set<ID>();
        
        
        List<List<ID>> supplierCandidates = new List<List<ID>>(); 
        if(namedEmployee != null) {
            EmployeeInformation ei = employees.getEmployee(namedEmployee); 
            supplierCandidates.add(employees.primaryBySupplierID.get(ei.supplierID));
        } else {
            supplierCandidates.addAll(employees.primaryBySupplierID.values());
        }
         
        
        for(List<ID> supplierEmployees : supplierCandidates) {
            if(supplierEmployees.size() < 2)
                continue;
           
            for(Integer start = 0 ; start <= supplierEmployees.size() - 1; start++) {
               
                ID first = supplierEmployees[start];
                
                if(namedEmployee != null && first != namedEmployee) {
                    continue;
                }
                
                EmployeeInformation firstEI = employees.getEmployee(first);
               // if(firstEI.alwaysWorksAlone && firstEI.employeeNumber.startsWith('CO') )
                  if(firstEI.alwaysWorksAlone && !firstEI.ownLabour)
                    continue;

                
                if(firstEI.alwaysWorksWith != null) {
                    if(AWWEmpsWithOption.contains(firstEI.alwaysWorksWith)) {
                        continue;
                    }
                    EmployeeInformation secondEI = employees.getEmployee(firstEI.alwaysWorksWith);
                    List<JobResourcingOption> options = processDoubleHandedPair(firstEI, secondEI);
                    if(options != null && !options.isEmpty()){
                        
                        options = planSkillsFromEnd(options);
                        if(options != null && !options.isEmpty()) {
                            businessOptions.addAll(options);
                            AWWEmpsWithOption.add(firstEI.employeeID);
                        }
                    }
                    continue;
                }
                
                
                JobResourcingOption bestJRO = null; // Short circuit 1
                
                for(Integer count = start+1; count < supplierEmployees.size(); count++) {
                    ID second = supplierEmployees[count];
                    system.debug(LoggingLevel.INFO, 'second ID: ' + second);
                    
                    EmployeeInformation secondEI = employees.getEmployee(second);
                    
                    
                   if((secondEI.alwaysWorksAlone && !secondEI.ownLabour) || secondEI.alwaysWorksWith != null || firstEI.employeeID == secondEI.employeeID ||
                       (firstEI.neverWorksWith == secondEI.employeeID) || secondEI.neverWorksWith == firstEI.employeeID||(alwaysWorkAlone.contains(firstEI.employeeID)&&SearchBlackBox.jobInfo.job.Heavy_Appliance__c==true))
                       continue;
                        
                        /*if((secondEI.alwaysWorksAlone && SearchBlackBox.jobInfo.job.Heavy_Appliance__c==false) || secondEI.alwaysWorksWith != null || firstEI.employeeID == secondEI.employeeID ||
                        (firstEI.neverWorksWith == secondEI.employeeID) || secondEI.neverWorksWith == firstEI.employeeID||(alwaysWorkAlone.contains(firstEI.employeeID)&&SearchBlackBox.jobInfo.job.Heavy_Appliance__c==true))
                        continue;*/
                   
                    if(SearchBlackBox.jobInfo.tooManyScriptStatements && bestJRO != null) {
                        DiaryEntryCollection earliestDEC = secondEI.availability.getEarliest(businessAvailabilityFlag);
                        if(earliestDEC != null && earliestDEC.startDT >= bestJRO.primaryStartDT) {
                            continue;
                        } else if(earliestDEC == null) {
                            DiaryEntryCollection largestDEC = secondEI.availability.getLargest(businessAvailabilityFlag);
                            if(largestDEC != null && largestDEC.startDT >= bestJRO.primaryStartDT)
                                continue;
                        }
                    }
                    
                    
                    List<JobResourcingOption> options = processDoubleHandedPair(firstEI, secondEI);
                    system.debug(LoggingLevel.INFO, '820 options '+options);
                    
                    if(options == null || options.isEmpty())
                        continue;
                   
                    options = planSkillsFromEnd(options);
                    if(options == null || options.isEmpty())
                        continue;
                    else {
                        businessOptions.addAll(options);
                        alwaysWorkAlone.add(firstEI.employeeID);
                        // Short circuit 1
                        if(SearchBlackBox.jobInfo.tooManyScriptStatements) {
                            for(JobResourcingOption jro : options) {
                                if(bestJRO == null) {
                                    bestJRO = jro;
                                    continue;
                                } else if(jro.primaryStartDT <= bestJRO.primaryStartDT) {
                                    bestJRO = jro;
                                    continue;
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        return businessOptions;
    }
    
    //Suguna - PH Jones Change
    public List<List<String>> getShifts(Diary_Entry__c entry){
             return new List<List<String>> {
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
         }

}