public without sharing class InstallPlanningReturnTransferController {

    
    // brm - 15-01-2010 - AvailabilityError exception
    public class AvailabilityException extends Exception {}

    //some constants
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    public static final String ENTRY_RECTYPE_NPJB = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
    List<Diary_Entry__c> nwdDiaryEntry ;
  
    /*
    Controller of return work VF page.
    
    Functionality is to build a series of pages in a wizard to choose work items.
    The page has duplicate roles to transfer/return hours to the job
    
    Input is the job (via standardController) to which the work items to return/transfer relate.
    */
    
    public Job__c thisJob{get; set;}
    public List<ID> weekIds{get; set;}
    public String userMessage{get; set;}        
    public Boolean showUserMessage{get; set;}
    public Boolean isAvailabilityRendered{get; set;}    
    public Boolean isConfirmRendered{get; set;}
    // Cognizant support fix - Transfer hours does not consider employee skills.
    public Boolean isEmployeeNotHaveSkill{get; set;}
    public Boolean isEmployeeNotActive{get; set;} // As a part of  - PRB00008082 -BGSAMSSupport
    
    // Plan additional skills CR - Starts
    public Map<String,List<String>> empNameSkillsNotFoundMap = new Map<String,List<String>>();
    // Plan additional skills CR - Ends
    
    public List<JobElementItem> Items{get; set;}
    public List<JobElementItem> selectedItems{get; set;}
    

    public List<DiaryItem> DItems{get;set;}
    public List<DiaryItem> selectedDItems{get;set;}
    public string tHours{get;set;}    
    public boolean Tran{get;set;}
    public boolean DETran{get;set;}
    public List<HoursInformation> Availability {get;set;}
    
    // brm - 15-01-2010 - new employee hours class
    public List<EmployeeData> employeeHoursInformation {get; private set;}
    
    //variable to hold info on where in the wizard we are at.
    public string stepIndex{get; set;} //will be {start, define, transfer}
    //this tells the system which wizard path to follow.
    public string wizardType{get; private set;} //Return or Transfer
    
    public string errorText{get; set;}
    
    // Plan additional skills CR - Starts

    public boolean selectAll{get;set;}
    public Boolean replanMode{get; set;}
    public Job__c dummyJob{get;set;}
    public List<ReplanHoursInformation> listReplanhoursInfo{get;set;}
    
    // Plan additional skills CR - Ends
    
    // CR- 28 day remedial call Change - Start
    public boolean remedial {get;set;}
    
    // CR- 28 day remedial call Change - End
    public String getHoursIds(){
        String output = '';
        for(string s: his.keySet()){
            output += ','+s.replace(' ','_');
        }
        
        // brm - 11-01-2010 - Added a check to the output length to stop the code from breaking if 
        // there are no diary entries for this job
        return (output.length() > 0 ? output.substring(1) : '');
    } 
        
    //string is the skill name (Building, PowerFlush..)
    private Map<string, HoursInformation> his;
    
    //transferring hours could use these...
    Employee__c fromEmployee;
    Date fromDate;
    Employee__c toEmployee;
    Date toDate;
    
    // Cognizant - CHI Phase III CR-002 implementation... START 
    
    public AddNewSkill ObjNewSkill = new AddNewSkill();
    
    // Cognizant - CHI Phase III CR-002 implementation... END 
    
    // TT
    InstallPlanningRTHelper help = new InstallPlanningRTHelper();
    //TT
    // ++ Variable declaration for CR#884 start
    public List<transferHours> hourList {get; set;}
    Map<String,transferHours> skillmap = new Map<String,transferHours>();
    List<String> basicSkillList = new List<String> {'Mechanical' ,'Building Work','Powerflush', 'Electrical' , 'ECO'};
    Set<String> basicSkillSet = new Set<String> ();
    public double totalHours {get; set;}
    // -- Variable declaration for CR#884 end
    
    //TT
    public boolean travelOverBook{get;set;}
    Utilities util = new Utilities();
    //TT
    
    public InstallPlanningReturnTransferController(ApexPages.StandardController con) {
        
        // Plan additional skills CR - Starts        
        selectAll = false;
        dummyJob = new Job__c();
        // Plan additional skills CR - Ends
        remedial = false;
        stepIndex = 'start';
        isAvailabilityRendered = false;
        isConfirmRendered = false;
        Tran = false;
        DETran = false;
        his = new Map<string, HoursInformation>();
        wizardType = (ApexPages.CurrentPage().getParameters().get('type') == null ? 'Return' : ApexPages.CurrentPage().getParameters().get('type'));

        // Plan additional skills CR - Starts
        if(wizardType == 'Plan additional'){
            replanMode = true;
        }else if(wizardType == 'NpRw')
        {
            wizardType = 'Plan Non Productive';
            remedial= true;
        }else if(wizardType == 'DETransfer') 
        {
            wizardType= 'DETransfer';
            Tran = True;
        }else{
           wizardType= 'Transfer';

           
        }
        // Plan additional skills CR - Ends

        Items = new List<JobElementItem>();
        selectedItems = new List<JobElementItem>();
        DItems = new List<DiaryItem>(); //Added by Ashok G
        selectedDItems = new List<DiaryItem>(); //Added by Ashok G

        if(con.getId() == null){            
            errorText = 'Please provide a valid job id parameter.';
            stepIndex = 'error';
            return;   
            }
        
     // CHI CR-000173 - Do not show 'Returned' work when transferring hrs
                
        // Cognizant - CHI Phase III CR-002 implementation... START     
        List<Job__c> jobs = ObjNewSkill.fetchJobforTransferringHours(con.getId());
        
        /*List<Job__c> jobs = [select ID, Name,
                                j.Water_Heating_Fixing_Hours__c,
                                j.Unvented_Hot_Water_Hours__c, 
                                j.Total_Job_Hours__c,
                                j.Specialist_Building_Hours__c,
                                j.Solar_Hours__c,
                                j.Scaffolder_Hours__c,
                                j.Roof_Work_Hours__c,
                                j.PowerFlush_Hours__c,
                                j.Payment_Collection_Hours__c,
                                j.Mechanical_Hours__c,
                                j.LPG_Installation_Hours__c,
                                j.Fire_Wall_Heater_Fixing_Hours__c,
                                j.Electrical_Work_ASP_Hours__c,
                                j.Electrical_Hours__c,
                                j.Contractor_Installation_Hours__c,
                                j.Connect_Solar_Panel_Hours__c,
                                j.Building_Work_Hours__c,
                                j.Asbestos_Removal_Hours__c, 
                                j.Asbestos_Removal_Fixed_Rate_Hours__c,
                                Job_Locked__c,
            (select IsDeleted, Name, Current_Supplier__c, Current_Supplier_Number__c, Units__c, Status__c, Skill__c, Product_ID__c, Line_Item_ID__c, ID, Description__c, Code__c from Job_Elements1__r where type__c='Work' AND Status__c='Active' AND Sub_Status__c != 'Returned' order by Skill__c,Line_Item_ID__c)
             from Job__c j where j.ID =: con.getId()]; */
             // Cognizant - CHI Phase III CR-002 implementation... END 
                
        if(jobs.size() != 1){
            errorText = 'An invalid record id  has been received.';
            stepIndex = 'error';
            return;
        }
        thisJob = jobs[0];
        
        //set the job to be the one pulled from the DB.
        
        //the job elements for the job are in the Job_Elements1__r relationship
        if(thisJob.Job_Elements1__r.size() == 0){
            stepIndex = 'error';
            errorText = 'No work items were found for this job.';
            return;
        }

        //Change by Ashok G --start
        //the diary Entrys for the job are in the Diary_Entries__r relationship
        if(thisJob.Diary_Entries__r.size()==0 && Tran){
          stepIndex = 'error';
          errorText = 'No Diary Entries were found for this job.';
          return;
        }
        //change End
        if(thisJob.Job_Locked__c == 'Y'){
            stepIndex = 'error';
            errorText = 'This job is currently locked. The job elements cannot be updated at this time.';
            return;
        }
        
        //Suguna
        List<Order__c> orders = [select id,status__c from order__c where Job__c=:thisJob.id and status__c='Goods Receipted' and Type__c='Work'];
        if(!orders.isEmpty()&&thisJob.status__c=='Installed')
        {
                    stepIndex = 'error';
                    errorText = 'Warning: Work cannot be transferred as orders are Goods Receipted. Please email Payment Control to check that the purchase order has not been paid and can be un-goods receipted.';
                    return;       
        }
        
        
        //will only gets here if the job elements list has items.
        //fill the items list with the available job_element__c items
        // Plan additional skills CR - Starts         
       if(!Tran){
           for(Job_Element__c je : thisJob.Job_Elements1__r){
                     JobElementItem jeItem;
                     system.debug(LoggingLEvel.INFO,'wizardType--->'+wizardType+' '+je.Sub_Status__c+' '+remedial);
                     if(wizardType == 'Plan additional' && je.Sub_Status__c.equalsIgnoreCase('Awaiting Order') 
                                                                                && je.Order__c == null &&
                                  je.Current_Supplier__c == null && je.Current_Supplier_Number__c == null || remedial == true){
                                 jeItem = new JobElementItem(je);
                                 jeItem.isSelected = true;
                                 Items.add(jeItem);

                                 selectAll = true;
                     }else if(wizardType != 'Plan additional'){
                        system.debug('in loop');
                                 Items.add(new JobElementItem(je));

                     }
                     system.debug('Items--->'+Items);


            }
            if(Items.size() == 0 && wizardType == 'Plan additional'){
                    stepIndex = 'error';
                    errorText = 'No work items were found for this job which can be planned.';

                    return;
            }
            basicSkillSet.addAll(basicSkillList);
            hourList = new List<transferHours>();
            skillmap = new Map<String,transferHours>();
            totalHours = 0;
            for(JobElementItem je : Items)
            {
                transferHours hour = new transferHours();
                hour.skill = je.jE.Skill__c;
                //hour.hours = je.jE.Units__c;
                skillmap.put(je.jE.Skill__c , hour);
            }
        
        
        }else{
            system.debug('Size of Diary---->'+thisJob.Diary_Entries__r.size());
            //Change By ASHOK G
            
                for(Diary_Entry__c de1: thisJob.Diary_Entries__r){
                system.debug('I am Inside');
                  DiaryItem deItem;
                  if(wizardType!='Plan additional'){
                     DItems.add(new DiaryItem(de1));
                  }
                }
                basicSkillSet.addAll(basicSkillList);
                hourList = new List<transferHours>();
                skillmap = new Map<String,transferHours>();
                totalHours = 0;
                for(DiaryItem de : DItems)
                {
                    transferHours hour = new transferHours();
                    hour.skill = de.dE.sub_Type__c;
                    //hour.hours = je.jE.Units__c;
                    skillmap.put(de.dE.sub_Type__c , hour);
                }
        }
        //Change End
        system.debug('Items--->'+DItems);  

        
        // ++ Added for CR#884 start
        
        
        // -- Added for CR#884 end  
        //Change By Ashok G
        
        system.debug('skill Map---->'+skillMap);
        hourList = sortSkills(skillmap);

        system.debug('skill Map---->'+skillMap);
        //Change End

        
    }
    // Plan additional skills CR - Ends

    public List<EmployeeData> getEmployeeBreakdown()
    {
        return employeeHoursInformation;
    }
    
    public List<HoursInformation> getBreakdown(){
        return his.values();
        
    }
    
    //we dont't need to go anywhere so return null;
    public PageReference defineWork(){
        
        stepIndex = 'define';
        //if navigating backward need to clear already selected items
        selectedItems.clear();
        selectedDItems.clear(); //change by ASHOK G
        
        List<Diary_Entry__c> diaryEntryes = new List<Diary_Entry__c>();
        for(JobElementItem i : Items){
            if(i.isSelected){
                selectedItems.add(i);
            }
            
        }


        //Added By Ashok G
        for(DiaryItem j: DItems){
         /* if(j.isSelected){
             selectedDItems.add(j);
             diaryEntryes.add(j.dE);
          }*/
           
          if(j.reduction > 0){
              double thrs = (j.dE.Hours__c == null ? 0 : j.dE.Hours__c) + (j.dE.Overbooked_Hours__c == null ? 0: j.dE.OverBooked_Hours__c);
              double totlHours = Decimal.valueOf(thrs).setScale(2);
              if(j.reduction > totlHours){
               stepIndex = 'start';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please only enter values up to the Skill Hours for each individual.'));
               return null;
              }
              selectedDItems.add(j);
              diaryEntryes.add(j.dE);
         }
       } 
        if(selectedDItems.size() == 0 && Tran){
            stepIndex = 'start';

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Entries have been selected. Please selected at least one Entry.'));
        }
        //End
        if(selectedItems.size() == 0 && !Tran){
            stepIndex = 'start';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No work elements have been selected. Please selected at least one work element.'));
        }        
        
        //create a collection of the chosen skills that are to be reduced
        Set<String> skillsToGet = new Set<String>();
        for(JobElementItem jei : selectedItems){
            if(!skillsToGet.contains(jei.jE.Skill__c))
                skillsToGet.add(jei.jE.Skill__c);
        }
        
         HoursInformation hi;
      
      // Plan additional skills CR - Starts  
      
      if(wizardType == 'DETransfer'){

      his = new map<string, HoursInformation>();
        system.debug('his-->'+his);
        for(Diary_Entry__c e : diaryEntryes){ //for(Diary_Entry__c e : diaryEntries)
            
            if(!his.containsKey(e.Sub_Type__c)){
                hi = new HoursInformation(e.Sub_Type__c);
                hi.addDiaryEntry(e);
                his.put(e.Sub_Type__c, hi);
            }else{
                hi = his.get(e.Sub_Type__c);
                hi.addDiaryEntry(e);
             }
         }
         
         /*for(HoursInformation h: his.values()){
                 for(EntryRecord eR: h.entries){
                    for(DiaryItem dEIt: selectedDItems){
                    system.debug(LoggingLevel.INFO,''+dEIt.hInfo.Job.Named_Employee__c);
                       if(eR.ent.Id == dEIt.dE.id){
                           eR.Reduction = dEIt.reduction;
                       }
                    }
                 }
         }*/
         DETran = TRUE;
          system.debug('his After-->'+his);  
      } else if(wizardType == 'Transfer'){
             // Plan additional skills CR - Ends
            
        //Sub_type__c is the key for the work type
        List<Diary_Entry__c> diaryEntries = [Select d.week__r.Employee__c,d.supplier_num__c,d.Sub_Type__c, d.Hours__c, d.OverBooked_Hours__c, d.Employee_Name__c, d.Employee_ID__c , Job_hours__c
            From Diary_Entry__c d where job__c =: thisJob.Id and RecordTypeId =: RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking') and d.Sub_Type__c in : skillsToGet];

        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=364:'+diaryEntries+' '+skillsToGet);
        // brm - 11-01-2010 - If there are no diary entries add a user friendly message
        if (diaryEntries.size() == 0)
        {
            stepIndex = 'error';
            errorText = 'There are no diary entries available for this job.';
            return null;
        }
        for(Diary_Entry__c e : diaryEntries){
            
            if(!his.containsKey(e.Sub_Type__c)){
                hi = new HoursInformation(e.Sub_Type__c);
                hi.addDiaryEntry(e);
                his.put(e.Sub_Type__c, hi);
            }else{
                hi = his.get(e.Sub_Type__c);
                hi.addDiaryEntry(e);
             }
         }



           system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=383:'+his);
      }   
      // Plan additional skills CR - Starts
       else{
            
          for(String skill : skillsToGet){
            hi = new HoursInformation(skill);
            his.put(skill, hi);
            System.debug('hours and corresponding skills'+skill+his.get(skill));
          }

      }
      // Plan additional skills CR - Ends

        //Skip this step -- Ashok G
        //for each of the selected items, add the hours to the skill type.
        if(!Tran){
            for(JobElementItem jei : selectedItems){
                // brm - 16-01-2010 - If there is a null pointer exception on this line it 
                // means there is no diary entries on this job for this skill
                his.get(jei.jE.Skill__c).addHours(jei.jE.Units__c);
            }
        }


        // Plan additional skills CR - Starts
        if(wizardType == 'Plan additional' || remedial){
            listReplanhoursInfo = new List<ReplanHoursInformation>();
            replanMode =  true;
            Job__c job;
            for(String skill : skillsToGet){
              ReplanHoursInformation rHoursInfo = new ReplanHoursInformation();
              job = new Job__c();
              rHoursInfo.skill = skill;
              rHoursInfo.totalHours = his.get(skill).totalHours;
              rHoursInfo.job = job;
              listReplanhoursInfo.add(rHoursInfo);
            }
        }
        // Plan additional skills CR - Ends
        
        return null;
    }
    /*
        If the item has been selected and the value has been set then pass to the updateData
        private method.
        TODO: finish this off
    */
    public PageReference confirm(){
        map<boolean,string> theresult;

        //updateTotalHours(); //Added by Ashok G
        //Now update the system with the new data...
        if(wizardType == 'return'){
            theresult = updateReturnData(selectedItems);
        //if update was successful then redirect back to job otherwise show message.
            if(theresult.containsKey(true))
                return returnToJob();
            else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'An error has occurred updating data.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, theresult.get(false)));
            }
        }
        else{
            stepIndex = 'transfer';
            
        }
        
        return null;
    }
    

    //Update the Total Hours in Hours INformation
    public void updateTotalHours(){
      for(HoursInformation hi:his.values()){
        hi.totalHours = hi.totalReduction;
      }
    }
    
     //This button will take the user back to the Start.                                  
    public PageReference returnToStart() {
        stepIndex = 'start';
        //clear the hours information list
        his.clear();
        // brm - 19-01-2010 - clear employee info
        if (employeeHoursInformation != null) employeeHoursInformation.clear();
        isConfirmRendered = false;
        isAvailabilityRendered = false;
        return null;
    }
     //This button will take the user back to the define step.                                  
    public PageReference returnToDefine() {
        stepIndex = 'define';
       
        return null;
    }
    
    
    //This button will take the user back to the Job.                                  
    public PageReference returnToJob() {
        
        PageReference pageRef; 
        if(ApexPages.currentPage().getParameters().get('retURL') != null)
            pageRef = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        else
            pageRef = new PageReference('/'+thisJob.ID);                                                
        
        pageRef.setRedirect(true);      
        return pageRef;
    }

    //This button will take the user back to the Job.                                  
    public PageReference confirmTransfer() 
    {
        Job__c Job = [select Order_Locking_User__r.Name,Count_Job_Order__c,Needs_Re_Planing__c from Job__c where Id = :thisJob.Id];

         
          cls_IsRun.setisinstUpdCustCatMasRec();
        Employee__c employee;
        Job_Booking_History__c jbh;         
        List<Job_Element__c> jobElements = new List<Job_Element__c>();               
        Boolean setJBH = false; 
        Pagereference p;
        
        // Plan additional skills CR - Starts
        wizardType = (ApexPages.CurrentPage().getParameters().get('type') == null ? 'Return' : ApexPages.CurrentPage().getParameters().get('type'));
        // Plan additional skills CR - Ends
        
        System.Savepoint sp = Database.setSavepoint();
        
        
        //try{
        
   
            if(thisJob != null && his!= null)
            {
                //1.Manipulate Diary Entries for selected Employees and skills.
                InstallPlanningRTHelper help = new InstallPlanningRTHelper();
                
                // Plan additional skills CR - Starts
                if(wizardType != 'Plan additional'){
                    
                  help.updateDiaryEntries(thisJob,his);
                  
                }
                
                // Plan additional skills CR - Ends

                                  
                //if(his.size() > 0)
                // brm - 16-01-2010 - Check the new employee hours list is greater than zero (i.e. it has some data)
                if (employeeHoursInformation.size() > 0)
                {               
                    //WeekManager.EntryDetails jobBooking;
                    List<WeekManager.EntryDetails> entryDetails = new List<WeekManager.EntryDetails>();
                    
                    // brm - 16-01-2010 - Loop through selected employees
                    for (EmployeeData emp : employeeHoursInformation)
                    {
                        // brm - 16-01-2010 - Throw error if this employee has no availability for the selected dates
                        if (emp.availability == null) throw new AvailabilityException('Cannot find availability for all selected employees on the selected dates.');
                        
                        // brm - 16-01-2010 - Create diary entries for the current employee
                        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=emp:'+emp.availability+' '+emp);
                        List<WeekManager.EntryDetails> employeeJobEntries = createDiaryEntriesForEmployee(emp.availability, emp);
                        entryDetails.addAll(employeeJobEntries);
                        system.debug(LoggingLevel.INFO,'Entry Details--->'+entryDetails);
                    // brm - 16-01-2010 - Continue doing hours information logic already in place
                    for (HoursInformation hi : emp.his)
                    //for(HoursInformation hi : his.values())           
                    {
                        if(hi.totalReduction > 0){
                            // brm - 16-01-2010 - Old job booking creation
                            /*if(hi.diaryEntries.size() > 0){
                                jobBooking = new WeekManager.EntryDetails(thisJob.ID, null,hi.diaryEntries[0].Week__r.Id, hi.totalReduction,hi.start, DateTimeHelper.addHoursToDT(hi.start, hi.totalReduction),hi.skill,ENTRY_RECTYPE_BOOKING);                 
                                entryDetails.add(jobbooking);
                            }*/
                            system.debug('hi.job.Named_Employee__c-->'+hi.job.Named_Employee__c);
                            List<Employee__c> employees = [Select e.id, e.Name, e.Supplier__r.Name, e.Supplier__r.Supplier_Num__c,  e.Supplier__c, e.Resource_Type__c From Employee__c e WHERE e.Resource_Type__c = 'Installer' AND e.Id =:hi.job.Named_Employee__c];
                            if(employees.size() > 0)
                                employee = employees[0];
                            else{
                                system.debug('hi.job.Named_Employee__c-->'+hi.job.Named_Employee__c);
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The employee does not have a Resource type of "Installer"'));
                                database.rollback(sp);
                                return null;
                            }  
                           
                            if(employee != null)
                            {                       
        
                                //2. Book the transferred hours into the gaps identified in the employee diary for each skill                                           
                                //iterate through the selected job elements and where the skill matches this employee set the supplier.
                                for(JobElementItem j : selectedItems)
                                {
                                    //check to see if this employee has the correct skills                      
                                    if(j.JE.Skill__c == hi.Skill)
                                    {               
                                        //3. Manipulate job element supplier order information as appropriate to scenario:
                                        //      a) Determine whether to populate 'new supplier fields'          
                                        if(j.JE.Current_Supplier__c != null)
                                        {                                                       
                                            if(j.JE.Current_Supplier__c != employee.Supplier__r.Name && j.JE.Current_Supplier_Number__c != employee.Supplier__r.Supplier_Num__c)
                                            {
                                                j.JE.New_Supplier__c = employee.Supplier__r.Name;
                                                j.JE.New_Supplier_Number__c = employee.Supplier__r.Supplier_Num__c;                             
                                                j.JE.Sub_Status__c = 'Awaiting Order';
                                                    
                                                jobElements.add(j.JE);                                                                                      
//                                              setJBH = true;
                                                                                                                                                                                                
                                            }                                                                       
                                        }                               
                                    }
                                                                                                                                                                                    
                                }
                                                        
                            }
                            employee = null;        
                        }
                        
                        // Plan additional skills CR - Starts
                        else if(wizardType == 'Plan additional'){
                            
                            
                            system.debug('hi.job.Named_Employee__c->'+ hi);
                             List<Employee__c> employees = [Select e.id, e.Name, e.Supplier__r.Name, e.Supplier__r.Supplier_Num__c, e.Supplier__c, e.Resource_Type__c From Employee__c e WHERE e.Resource_Type__c = 'Installer' AND e.Id =:hi.job.Named_Employee__c];
                             system.debug('hi.job.Named_Employee__c-->'+hi.job.Named_Employee__c);
                             for(JobElementItem j : selectedItems){
                                  if(employees.size() > 0){
                                      employee = employees[0];
                                  }else{
                                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The employee does not have a Resource type of "Installer"'));
                                      database.rollback(sp);
                                      return null;
                                  }  
                             if(j.JE.Skill__c == hi.Skill){
                                 if(j.JE.Current_Supplier__c != employee.Supplier__r.Name && j.JE.Current_Supplier_Number__c != employee.Supplier__r.Supplier_Num__c){
                                       j.JE.Current_Supplier__c = employee.Supplier__r.Name;
                                       j.JE.Current_Supplier_Number__c = employee.Supplier__r.Supplier_Num__c;                             
                                       j.JE.Sub_Status__c = 'Awaiting Order';
                                       jobElements.add(j.JE);                                                                                      
                                 }   
                             }                               
                        }
                      
                            
                            
                            
                        }   
                        // Plan additional skills CR - Ends
                                                                                                                            
                    }
                    }
                    
                    //create EntryDetails for the 'already created' diary items...
                    
                    //overbooked hours added as part of the prbfix PRB00026805 
                     
                    List<Diary_Entry__c> diaryEntries = [Select d.week__c,d.Record_Type__c, d.Job__c, d.Hours__c, d.Start__c, d.End__c, d.Sub_Type__c, d.Overbooked_Hours__c,Job_Hours__c From Diary_Entry__c d where job__c =: thisJob.Id or Travel_Job__c = : thisJob.Id ];

                    system.debug(LoggingLevel.INFO,'-=-=-=-=-=DE of Job:'+diaryEntries);
                    for(Diary_Entry__c de : diaryEntries){
                        //if(de.Record_Type__c!='Non Productive Job Booking')
                        entryDetails.add(new WeekManager.EntryDetails(de.Job__c, null, de.week__c, de.Hours__c, de.Start__c, de.End__c ,de.Sub_Type__c ,ENTRY_RECTYPE_BOOKING ,de.Overbooked_Hours__c));
                    }

                    system.debug(LoggingLevel.INFO,'----------------=========>'+entryDetails);
                    if(entryDetails.size() > 0){
                        JobBookingManager.planOrReplanJob(entryDetails, false);
                    }
                           
                    if(jobElements.size() > 0)
                    {
                        update jobElements;
                        jobElements.clear();
                    }                               
                }
                
                
     
            }
                         
             
            //b) Determine whether to update status and sub-status fields.  
//          if(setJBH)
//          {
                //4. TODO: Write a record to job booking history as history appropriate to be detected by the interface
                //jbh = new Job_Booking_History__c(Work_Affected__c= true, Job__c=thisJob.Id);                  
                //insert jbh;           
//          }   
            /*
        }catch(System.Exception ex){
            ApexPages.addMessages(ex);
            system.debug(LoggingLevel.INFO, 'Error: ' + ex);
            Database.rollback(sp);
            return null;
        }
            */   
            
        // Delete all the availabilities with zero hours in these weeks
        
        weekIds = new List<Id>();
        
        for (EmployeeData employeeData : employeeHoursInformation)
        {
            weekIds.add(employeeData.availability.Week__c);
        }
        
        if(weekIds.size()>0){
            List<Diary_Entry__c> zeroHoursDeList = [Select id from Diary_Entry__c where Week__c in :weekIds and Hours__c <= 0.00];
            if(zeroHoursDeList.size()>0){
                Database.delete(zeroHoursDeList);
            }
        }
        // Change Name :Regeneration of orders while transfer of job elements :start-Cognizant 05 September 2013
         //Check count of job orders  and if >0 then redirecting to the purchaseammendmentpage and upon page loads action call.
         List<Id> jobIdList = new List<Id>{thisJob.ID};
         JobSharingCls.createJobSharing(jobIdList);
         
         if(job.Count_Job_Order__c!=0 && WizardType!='DETransfer') //Added to skip the Purchase order generation for sameSupplier
         {
            
             p=new PageReference(System.Label.AutoRegeneration+job.id);
                
         }
         else 
         {   
            // Plan additional skills CR - Starts
           
           
            p = new PageReference('/'+thisJob.ID);                                                
            
            // Plan additional skills CR - Ends
            
        }
        
        
        
        List<NWD_Detail__c> exisitingNwd= [Select id,Employee_Name__c,Job_Number__c,Hours__c from NWD_Detail__c where Job_Number__c= :thisJob.ID];
        
        if(exisitingNwd.size()>0)
        delete exisitingNwd;
        
        Diary_Entry__c[] des = [Select d.Week__r.Id, d.Week__r.Sunday_End_Time__c, d.Week__r.Saturday_End_Time__c, d.Week__r.Friday_End_Time__c,Job__c,
                    d.Week__r.Thursday_End_Time__c, d.Week__r.Wednesday_End_Time__c, d.Week__r.Tuesday_End_Time__c, 
                    d.Week__r.Monday_End_Time__c, d.Week__r.Sunday_Start_Time__c, d.Week__r.Saturday_Start_Time__c, 
                    d.Week__r.Friday_Start_Time__c, d.Week__r.Thursday_Start_Time__c, d.Week__r.Wednesday_Start_Time__c, 
                    d.Week__r.Tuesday_Start_Time__c, d.Week__r.Monday_Start_Time__c, d.Week__r.Week_Commencing__c,d.Week__r.Employee__r.Pool_Diary__c,
                    d.Week__r.Employee__c, d.Week__r.Employee__r.Name, d.Week__c, d.Type__c, d.Sub_Type__c, d.Start__c, d.Hours__c, d.End__c,
                    d.Week__r.Monday_Unavailable_Hours__c,d.Week__r.Tuesday_Unavailable_Hours__c,d.Week__r.Wednesday_Unavailable_Hours__c,
                    d.Week__r.Thursday_Unavailable_Hours__c,d.Week__r.Friday_Unavailable_Hours__c,d.Week__r.Saturday_Unavailable_Hours__c,
                    d.Week__r.Sunday_Unavailable_Hours__c,d.Week__r.Release_Date__c,d.Week__r.Category_Num__c,
                    d.Week__r.Monday_Max_Hours__c,d.Week__r.Tuesday_Max_Hours__c,d.Week__r.Wednesday_Max_Hours__c,
                    d.Week__r.Thursday_Max_Hours__c,d.Week__r.Friday_Max_Hours__c,d.Week__r.Saturday_Max_Hours__c,
                    d.Week__r.Sunday_Max_Hours__c,d.week__r.Locking_User__c,d.Week__r.Monday_Booked_Hours__c,d.Week__r.Tuesday_Booked_Hours__c,
                    d.Week__r.Wednesday_Booked_Hours__c,d.Week__r.Thursday_Booked_Hours__c,d.Week__r.Friday_Booked_Hours__c,d.Week__r.Saturday_Booked_Hours__c,
                    d.Week__r.Sunday_Booked_Hours__c,d.Overbooked_Hours__c,d.Week__r.Employee__r.Own_Labour__c,d.Employee_Name__c,Job_hours__c,Employee_ID_18__c
                    From Diary_Entry__c d where Job__c =:thisJob.ID order by d.start__c ASC];
        
        set<id> weeklist = new set<id>();
        /*for(Diary_Entry__c weekids: des)
        {
           weeklist.add(weekids.Week__r.Id);
             
        }*/
        
        
        //Travel Time Change Start=====> Change By AShok G
         
         List<Diary_Entry__c> TravelDE = new List<Diary_Entry__c>();
         map<Id,List<DateTime>> wstartEndMap = new Map<Id,List<DateTime>>(); //Hold Week Start End Times
         //Map<Id,List<Diary_Entry__c>> WDemap = new Map<Id,list<Diary_Entry__c>>();
         string mainInstallerPayNum ;
         Id chiLeadId ; 
              for(Diary_Entry__c bo: des){
                  
                // Populate Main Installer
                
                decimal mechHours = 0;
                bo.Overbooked_Hours__c = bo.Overbooked_Hours__c!=null?bo.Overbooked_Hours__c:0;
                if( !(thisJob.Is_Remedial_Job__c || thisJob.Is_Downtime_Job__c) && bo.Sub_Type__c == 'Mechanical' && mechHours < bo.Hours__c + bo.Overbooked_Hours__c)
                {
                    mechHours = bo.Hours__c + bo.Overbooked_Hours__c;
                    mainInstallerPayNum = bo.Employee_ID_18__c;
                    chiLeadId = thisJob.CHI_Lead__c;
                }
                
                   weeklist.add(bo.Week__r.Id);
                    
                   if(wStartEndMap.containskey(bo.week__c)){
                      Datetime[] strtEnd = wStartEndMap.get(bo.Week__c);
                      if(bo.start__c < strtEnd[0])
                      strtEnd[0] = bo.start__c;
                      
                      if(bo.End__c > strtEnd[1])
                      strtEnd[1] = bo.End__c;
                      
                      wStartEndMap.put(bo.Week__c,strtEnd);
                   }else{
                      List<DateTime> startEnd = new list<DateTime>();
                      startEnd.add(bo.start__c);
                      startEnd.add(bo.End__c);
                      wStartEndMap.put(bo.Week__c,startEnd);
                      
                   }
                   
                   /*if(WDemap.containskey(bo.Week__c)){
                   list<Diary_Entry__c> tempList = new list<Diary_Entry__c>();
                   tempList.addall(WDemap.get(bo.Week__c));
                   tempList.add(bo); 
                     WDemap.put(bo.Week__c,tempList);
                     
                   }else{
                     list<Diary_Entry__c> diaries = new list<Diary_Entry__c>();
                     diaries.add(bo);
                     WDemap.put(bo.Week__c,diaries);
                   }*/
                   
               } 
        
        system.debug('##weeklist'+weeklist);
        for(EmployeeData employeeData : employeeHoursInformation){
             if(employeeData!=null && employeeData.travelHis!=null)     
             for(HoursInformation his: employeeData.travelHis){      
                  if(his.Skill == 'Travel Time' && wstartEndMap.containskey(employeeData.availability.Week__c))
                  {     
                        //booking = new WeekManager.EntryDetails(thisJob.ID, null,availability.Week__r.Id, (hi.totalHours-hi.overBookedHours), currentStart, null,hi.skill,ENTRY_RECTYPE_BOOKING,hi.overBookedHours,hi.travelJob);

                        //system.debug(LoggingLevel.INFO,'========caslc:'+de+' '+DateTimeHelper.addWorkingHoursToDateTime(sr.result.Start_Date_Time__c,(hi.totalHours-hi.overBookedHours),employeeData.availability));
                        if(his.Order == 'Front'){
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.Week__c = employeeData.availability.Week__c;
                          TravDE.Travel_Job__c = his.travelJob;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c = thisJob.ID;
                          TravDE.Hours__c = his.totalHours-his.overBookedHours;
                          TravDE.Start__c = wstartEndMap.get(employeeData.availability.Week__c)[0];
                          TravDE.End__c = DateTimeHelper.addWorkingHoursToDateTime(TravDE.Start__c,TravDE.Hours__c,employeeData.availability);

                          TravelDE.add(TravDE);
                        
                        }else{
                        
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.Week__c = employeeData.availability.Week__c;
                          TravDE.Travel_Job__c = his.travelJob;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c = thisJob.ID;
                          TravDE.Hours__c = his.totalHours-his.overBookedHours;
                          TravDE.Start__c = wstartEndMap.get(employeeData.availability.Week__c)[1];
                          TravDE.End__c = DateTimeHelper.addWorkingHoursToDateTime(TravDE.Start__c,TravDE.Hours__c,employeeData.availability);

                          TravelDE.add(TravDE);
                     }
                   }  
                     
               }  
            }
        
        if(TravelDE.size()>0)
        insert TravelDE; 
        //Travel Time Change END -->
        
        Map<Id, double> NWDEgnineerIdTimeMap = new Map<Id, double> ();
        nwdDiaryEntry = new list <Diary_Entry__c>();
        nwdDiaryEntry = [select id,Week__c,start__c,End__c from Diary_Entry__c Where Week__c = :weeklist and Sub_Type__c = 'NWD - Working'];
        system.debug('##nwdentry'+nwdDiaryEntry);
         for(Diary_Entry__c de: des)
         {
         
            for(Diary_Entry__c nwd : nwdDiaryEntry)
                {
                    
                     dateTime startNWDTime;
                     dateTime endNWDTime;
                     double NWDHours =0;
                    if((de.Week__c == nwd.Week__c) && ((de.Start__c< nwd.End__c && de.End__c> nwd.Start__c) || (de.Start__c<= nwd.Start__c && de.End__c>= nwd.End__c)))
                    {
                        system.debug('--->inside<--');
                        system.debug('--->inside<--'+de.Start__c+'-----'+de.End__c);
                        system.debug('--->inside<--'+nwd.Start__c+'-----'+nwd.End__c);
                        if(de.Start__c>= nwd.Start__c)
                        {
                            startNWDTime = de.Start__c;
                        }else{
                            startNWDTime = nwd.Start__c;
                            
                        }
                        
                        if(de.End__c >= nwd.End__c)
                        {
                            endNWDTime = nwd.End__c;
                        }else
                        {
                            endNWDTime = de.End__c;
                        }
                        
                        NWDHours = DateTimeHelper.calculateHours(startNWDTime, endNWDTime, de);
                        //overbooked hours calculation on NWD
                        if(de.Overbooked_Hours__c!=NULL && nwd.End__c>=de.End__c)
                        NWDHours +=de.Overbooked_Hours__c;
                        
                        system.debug('NWD Hours--->'+NWDHours);
                        
                        if(NWDEgnineerIdTimeMap.containsKey(de.Week__r.Employee__c))
                        {
                            NWDHours+= NWDEgnineerIdTimeMap.get(de.Week__r.Employee__c);
                        }
                        NWDEgnineerIdTimeMap.put(de.Week__r.Employee__c, NWDHours);
                        
                        system.debug('---->'+NWDEgnineerIdTimeMap);
                        
                    }
                }
                
             }   
            list<NWD_Detail__c> insertNewList = new list<NWD_Detail__c>();  
            for(id empid : NWDEgnineerIdTimeMap.keyset())
            {  
                if(NWDEgnineerIdTimeMap.get(empid)== 0.0){
                  //exclude record with 0.0 hours
                }
                 else
                 insertNewList.add( new NWD_Detail__c(Employee_Name__c = empid, Job_Number__c = job.Id, Hours__c = NWDEgnineerIdTimeMap.get(empid)));
            }
            system.debug('##nwd detail list'+insertNewList);
            cls_IsRun.generalTriggerSwitch = true;
            if(chiLeadId!=null && mainInstallerPayNum!=null)
            update (new Opportunity(id =chiLeadId, Installer__c  = mainInstallerPayNum) );
            if(insertNewList.size()>0)
            insert insertNewList;
        
        p.setRedirect(true);
        return p;    
}

    
    // TODO: brm - setup start, end, duration into entrydetail objects (maybe create entrydetail instead of sticking it in hours information object again)
    private List<WeekManager.EntryDetails> createDiaryEntriesForEmployee(Diary_Entry__c availability, EmployeeData data)
    {
        // brm - 15-01-2010 - Setup data for shift pattern checking
        Week__c week = availability.Week__r;
        Date weekStart = week.Week_Commencing__c;
        
        List<Shift> shifts = new List<Shift>();
        // brm - 15-01-2010 - Store shifts in a list
        shifts.add(new Shift(week.Monday_Start_Time__c, week.Monday_End_Time__c));
        shifts.add(new Shift(week.Tuesday_Start_Time__c, week.Tuesday_End_Time__c));
        shifts.add(new Shift(week.Wednesday_Start_Time__c, week.Wednesday_End_Time__c));
        shifts.add(new Shift(week.Thursday_Start_Time__c, week.Thursday_End_Time__c));
        shifts.add(new Shift(week.Friday_Start_Time__c, week.Friday_End_Time__c));
        shifts.add(new Shift(week.Saturday_Start_Time__c, week.Saturday_End_Time__c));
        shifts.add(new Shift(week.Sunday_Start_Time__c, week.Sunday_End_Time__c));
        
        // brm - 16-01-2010 - Get start of availability
        DateTime currentStart = availability.start__c;
        
        List<WeekManager.EntryDetails> employeeBookings = new List<WeekManager.EntryDetails>();
        // brm - 15-01-2010 - Loop through all hours information for current employee
        for(HoursInformation hi : data.his)
        {
            // brm - 15-01-2010 - create initial version of a booking (before shift pattern logic)
            WeekManager.EntryDetails booking;
            if(data.isPoolEmployee){
               double actual = hi.totalHours - hi.overBookedHours;  
               booking = new WeekManager.EntryDetails(thisJob.ID, null,availability.Week__r.Id, actual, currentStart, null,hi.skill,ENTRY_RECTYPE_BOOKING);
            }
            // TT Start
            /*else if(hi.travelJob!=null)
            {
                booking = new WeekManager.EntryDetails(thisJob.ID, null,availability.Week__r.Id, (hi.totalHours-hi.overBookedHours), currentStart, null,hi.skill,ENTRY_RECTYPE_BOOKING,hi.overBookedHours,hi.travelJob);
            }*/
            //TT End
            else if(hi.overBookedHours<=0.00){
               booking = new WeekManager.EntryDetails(thisJob.ID, null,availability.Week__r.Id, hi.totalHours, currentStart, null,hi.skill,ENTRY_RECTYPE_BOOKING);
            } else if(hi.overBookedHours>0.00){
               system.debug(LoggingLevel.INFO,'--=-=-=-=-=-=Inside CreateDEforEmpl:'+hi);
               booking = new WeekManager.EntryDetails(thisJob.ID, null,availability.Week__r.Id, (hi.totalHours-hi.overBookedHours), currentStart, null,hi.skill,ENTRY_RECTYPE_BOOKING);
               booking.overBookedHours = hi.overBookedHours;
            }   
            
            // brm - 15-01-2010 - sort out booking so that start and end dates are inside shift patterns
            convertToShiftPattern(booking, weekStart, availability.end__c.Date(), shifts);
            employeeBookings.add(booking);
            
            // brm - 16-01-2010 - Increase avail hours start date to after the current booking (any other bookings will then appear after this one)
            currentStart = booking.endTime;
        }
        
        return employeeBookings;
    }
    
    public PageReference checkAvailability()
    {        
        //iterate through the his collection and generate the  

        DateTime startDateTime;
        isAvailabilityRendered = true; 
        boolean found = false;
        isConfirmRendered = true;
        wizardType = (ApexPages.CurrentPage().getParameters().get('type') == null ? 'Return' : ApexPages.CurrentPage().getParameters().get('type'));
        Map<Id, EmployeeData> hiMap = new Map<Id, EmployeeData>();

        if(Tran) {  //Added By Ashok G
            his = new Map<string,HoursInformation>();
            defineWork();
            confirm();
            //updateEntriesReduction();
            for(HoursInformation h: his.values()){
                 system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+h);
                 system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+selectedDItems);
                 system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+h.entries);
                 for(EntryRecord eR: h.entries){
                    for(DiaryItem dEIt: selectedDItems){
                    system.debug(LoggingLevel.INFO,''+dEIt.hInfo.Job.Named_Employee__c);
                       if(eR.ent.Id == dEIt.dE.id){
                           eR.Reduction = dEIt.reduction;
                            
                       }
                      
                    }
                 }
                 if(dummyJob.Named_Employee__c != null){
                              h.job.Named_Employee__c = dummyJob.Named_Employee__c;
                 }
                 if(dummyJOb.customer_preferred_date__c != null){
                     h.job.customer_preferred_date__c = dummyJob.customer_Preferred_Date__c;
                 }
                h.totalHours = h.TotalReduction;
               }
            
            system.debug(loggingLevel.INFO,'-=-=-=-=-=-'+his.values());
            
            
            
           
        }
        // Plan additional skills CR - Starts
        if(wizardType == 'Plan additional'){
            System.debug('########################'+wizardType);
            for (HoursInformation hi : his.values()){
                for(ReplanHoursInformation rHoursInfo : listReplanhoursInfo){
                    if(rHoursInfo.skill == hi.skill){
                        if(rHoursInfo.job.Customer_Preferred_Date__c == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select  "Not Before"  date to proceed.'));
                            isConfirmRendered = false;
                            return null;
                        }else if(rHoursInfo.job.Named_Employee__c == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select  "Named employee"  to proceed.'));
                            isConfirmRendered = false;
                            return null;
                        }
                        hi.job = rHoursInfo.job;
                    }
                }
            }
        }
        // Plan additional skills CR - Ends
        
        // Cognizant support fix - Transfer hours does not consider employee skills.
        isEmployeeNotHaveSkill = checkEmployeeSkills();

        system.debug(LoggingLevel.INFO,'-=-=-=-998:'+isEmployeeNotHaveSkill);
        // Plan additional skills CR - Starts
        if(wizardType == 'Plan additional' && isEmployeeNotHaveSkill){
             String allSkills = '';
             for(String empName : empNameSkillsNotFoundMap.keySet()){
                List<String> skillList = empNameSkillsNotFoundMap.get(empName);
                allSkills = '';
                if(skillList.size()<=0){
                    continue;
                }else{
                    Integer i = 0;
                    for(String skill : skillList){
                        if(i == 0)
                        allSkills = allSkills + skill;
                        else
                        allSkills = allSkills + ', ' + skill;
                        i++;
                    }
                }
             isConfirmRendered = false; 
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, empName + ' does not have ' + allSkills + ' skill.'));
          }
             return null;
             
        }else if(wizardType == 'Plan additional' && !isEmployeeNotHaveSkill){
             stepIndex = 'Plan additional';
        }
        // Plan additional skills CR - Ends
        
        // brm - 15-01-2010 - combine hours information for each employee
        for (HoursInformation hi : his.values())
        {
            system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=-=1021:'+hi);
            
            if (!hiMap.containsKey(hi.Job.Named_Employee__c)) hiMap.put(hi.Job.Named_Employee__c, new EmployeeData(hi.Job.Named_Employee__c));
            
            hiMap.get(hi.Job.Named_Employee__c).his.add(hi);
        }
        // brm - 16-01-2010 - Add hours info grouped by employee to global variable
        employeeHoursInformation = hiMap.values();
        
        // brm - 15-01-2010 - loop through all employees
        for (EmployeeData employee : employeeHoursInformation)
        {
            system.debug(LoggingLevel.INFO, '-------------------EmployeeId: ' + employee.employeeId);

            system.debug(LoggingLevel.INFO, '-------------------Employee Hours Info: ' + employee.his);
            Double combinedHours = 0;
            startDateTime = null;
            
           
            
            // brm - 19-01-2010 - try and get an availability to fit the job booking
            Employee__c emp = [Select Pool_Diary__c,Supplier_Branch_Num__c from Employee__c where ID =:employee.employeeId]; 
            
            
            // brm - 15-01-2010 - combine hours for each employee and get earliest start date
            for(HoursInformation hi : employee.his)
            {
                System.debug(LoggingLevel.INFO,'Hoursinformation---->'+hi.entries);
                System.debug('########################');
                System.debug('########################');
                // brm - 19-01-2010 - Combine all hours from hours information
                
                combinedHours += hi.totalHours; //hi.totalHours change by Ashok G
                //combinedHours += 0.10;
                // brm - 19-01-2010 - Get the earliest date selected
                if (startDateTime == null || hi.job.Customer_Preferred_Date__c < startDateTime.Date())
                {
                    startDateTime = datetime.newInstance(hi.Job.Customer_Preferred_Date__c.Year(), hi.Job.Customer_Preferred_Date__c.Month(), hi.Job.Customer_Preferred_Date__c.Day(), 0, 0, 0);
                }
                //Added By Ashok G to transfer hours for the same supplier.
                if(Tran){
                    for(EntryRecord entrec: hi.entries){
                         if(emp.Supplier_Branch_Num__c == entrec.EmpSupNum){
                           continue;
                         }else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Employees should have a same supplier to transfer hours.'));
                            isConfirmRendered = false;
                            return null;
                         }
                    }
               }
            }
            system.debug(LoggingLevel.INFO, '-------------------Combined Hours: ' + combinedHours);
            system.debug(LoggingLevel.INFO, '-------------------startDateTime: ' + startDateTime);
            


            
            
            employee.isPoolEmployee = emp.Pool_Diary__c;
                        
            // Plan additional skills CR - Starts
            employee.nonOverBookedHours = 0.0;
            // Plan additional skills CR - Ends
            double travelHours =0.00;
            employee.availability = retrieveAvailability(employee, startDateTime, combinedHours);
            // if(system.label.TrasferTravel == 'on' && !employee.isPoolEmployee  && employee.availability!=null) 
            // PRB00014924 - Fix to let transfer hours work only when the hours are transferred to a BGS Employee
           system.debug(LoggingLevel.INFO,'-------Checkavailablity of Employee:'+combinedHOurs+' '+TravelHours+' '+employee.availability);
           if(employee.availability!=null)
           employee.endDateTime = DateTimeHelper.addWorkingHoursToDateTime(employee.availability.Start__c, combinedHOurs, employee.availability);
          
          if(system.label.TrasferTravel == 'on' && emp.Supplier_Branch_Num__c=='2017'  && employee.availability!=null)
            {
            map<string, list<string>> indayTravel = help.calculateIndayTravel(employee.availability, thisJob, combinedHours);
            list<HoursInformation> frontHours = new list<HoursInformation>();
            list<HoursInformation> backHours = new list<HoursInformation>();
            
            if(indayTravel!=null && indayTravel.size()>0)
            {
                system.debug('Display IN Day Travel--->'+indayTravel);
                for(string eng : indayTravel.keyset())
                {

                    
                    for(string travel : indayTravel.get(eng))
                    {
                        HoursInformation TravelHi = new HoursInformation('Travel Time'); 
                        string[] travelInfo = travel.split('/');
                        travelHours +=double.valueof(travelInfo[1]);
                        TravelHi.skill = 'Travel Time';
                        TravelHi.totalHours = double.valueof(travelInfo[1]);
                        TravelHi.travelJob = travelInfo[0];
                        TravelHi.Order = travelInfo[2]; //Hold the order of the Travel job By AshoK G
                        if(travelInfo[2] == 'Front')
                        {
                            frontHours.add(TravelHi);
                            
                        }
                        else
                        {
                            backHours.add(TravelHi);
                            
                        }   
                        TravelHi.job = hiMap.get(employee.employeeId).his[0].job;
                    }
                    
                    
                }
                employee.backTravel = travelHours;
                employee.combinedHours = combinedHours;//+travelHours;
                datetime newEnd = DateTimeHelper.addWorkingHoursToDateTime(employee.availability.Start__c, employee.combinedHours, employee.availability);
                if(newEnd> employee.availability.End__c)
                {
                    employee.availability.Overbooked_Hours__c= DateTimeHelper.calculateHours(employee.availability.End__c , newEnd,employee.availability);
                    travelOverBook =true;
                    util.setErrorMsg(true, 'Needs Overbooking for '+employee.availability.Employee_Name__c   +' Travel by:'+employee.availability.Overbooked_Hours__c+' . So please confirm.'   );
                }   
                else 
                {
                    employee.availability.Overbooked_Hours__c = null;
                }
                
                list<HoursInformation> finalHours = new list<HoursInformation>();
                frontHours.addall(backHours);
               //finalHours.addall(frontHours);
                finalHours.addall(employee.his);
                //finalHours.addall(backHours);
                employee.his = finalHours;
                employee.travelHis = frontHours;
                
            }
            
            
            }
            system.debug(LoggingLevel.INFO,'-------Checkavailablity of Employee:'+combinedHOurs+' '+TravelHours+' '+employee.availability);
            employee.combinedHours = combinedHours;//+travelHours;
            
            // Plan additional skills CR - Starts
            if(employee.availability != null){
                if(employee.availability.Overbooked_Hours__c != null)
                  employee.nonOverBookedHours = employee.combinedHours - employee.availability.Overbooked_hours__c;
            }
            
            if(employee.availability != null){
                if(employee.availability.Overbooked_Hours__c == null){
                  employee.nonOverBookedHours = employee.combinedHours;
                  employee.availability.Overbooked_hours__c = 0.0;
                }
            }
            // Plan additional skills CR - Ends
            
            setOverBookedHoursForEachSkill(employee);
            system.debug(LoggingLevel.INFO,'Enployee--->'+employee);
            system.debug(LOggingLevel.INFO,'Enployee--->'+employee.his);
            // brm - 19-01-2010 - don't render the confirm transfer button if some availabilities are not found
            if (employee.availability == null) isConfirmRendered = false;
            
            // Plan additional skills CR - Starts
            if(wizardType == 'Plan additional' && employee.availability == null){
                isConfirmRendered = false;  
                String empName = [Select Name from Employee__c where ID = :employee.employeeId].Name;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, empName + ' does not have sufficient availability. Please change the employee or date and search again.'));
            }
            // Plan additional skills CR - Ends
            
        }

        system.debug(LoggingLevel.INFO,'1191:'+getemployeebreakdown());
        system.debug(LoggingLevel.INFO,'1191:'+isConfirmRendered+' '+isAvailabilityRendered);
        return null;
    }
    
    private void setOverBookedHoursForEachSkill(EmployeeData empData){
        
        if(empData.availability == null){
            
            return;
            
        }
        
        if(empData.availability.Overbooked_Hours__c == null){
            
            empData.availability.Overbooked_Hours__c = 0.00;
            
        }
        
        Double totalOverBookingRequired = empData.availability.Overbooked_Hours__c;
        
        if(totalOverBookingRequired<=0.00){
            
            return;
            
        }
        
       for(HoursInformation hi : empData.his){
            system.debug('Each HI---->'+hi);    
            hi.overBookedHours =   double.valueof(decimal.valueof(totalOverBookingRequired * (hi.totalHours/empData.combinedHours)).setscale(2));      
               
        }
        
        
    }
    
    // FIX - Cognizant Support - Process Pool Diaries Seperately.
    // This method needs restructuring because it considers pool as well as non pool diaries in same way.
    // Also there is complex calculation involved when we try to transfer hours for pool resources.
    // We are writing a seperate method to process pool diaries.
    
    // brm - 19-01-2010 - Logic to get a valid availability for the selected date
    // gjb - 09-02-2010 - Changed signature to accept ID rather than a string
    //private Diary_Entry__c retrieveAvailability(String employeeId, DateTime selectedDateTime, Double hours)
    private Diary_Entry__c retrieveAvailability(EmployeeData empData, DateTime selectedDateTime, Double hours)
    {
        String userId = Userinfo.getUserId();
        boolean isPoolEmp = empData.isPoolEmployee;
        
        ID employeeId = empData.employeeId;
        
        // brm - 19-01-2010 - Get start of week
        Date startOfWeek = selectedDateTime.Date().toStartOfWeek();
        
        Double hoursToTransfer = hours;
        
        Double availableHours = 0.00;
        
        Double hoursNeedToBeOverbooked = 0.00;
        
        Double hoursNeedToBeBookedNormally = 0.00;
        
        Double minimumAvailableHours = Double.valueOf(System.label.Minimum_Available_Hours_For_TW);
        
        if(!isPoolEmp){
                
                hours = minimumAvailableHours*empData.his.size();
            
        }
        
        System.debug(LoggingLevel.INFO,'hours--->'+hours);
        
        // brm - 19-01-2010 - Convert employee id to 15 char id if needed
        // gjb - 09-02-2010 - Using ID rather than a string
        //employeeId = (employeeId.length() > 15 ? employeeId.substring(0, 15) : employeeId);
        
        // FIX - Cognizant Support - Process Pool Diaries Seperately.
        // Added 22 extra fields in below query
        // brm - 19-01-2010 - get all diary entries for this week that may be able to fit the job booking
        Diary_Entry__c[] des = [Select d.Week__r.Id, d.Week__r.Sunday_End_Time__c, d.Week__r.Saturday_End_Time__c, d.Week__r.Friday_End_Time__c, 
                    d.Week__r.Thursday_End_Time__c, d.Week__r.Wednesday_End_Time__c, d.Week__r.Tuesday_End_Time__c, 
                    d.Week__r.Monday_End_Time__c, d.Week__r.Sunday_Start_Time__c, d.Week__r.Saturday_Start_Time__c, 
                    d.Week__r.Friday_Start_Time__c, d.Week__r.Thursday_Start_Time__c, d.Week__r.Wednesday_Start_Time__c, 
                    d.Week__r.Tuesday_Start_Time__c, d.Week__r.Monday_Start_Time__c, d.Week__r.Week_Commencing__c,d.Week__r.Employee__r.Pool_Diary__c,
                    d.Week__r.Employee__c, d.Week__r.Employee__r.Name, d.Week__c, d.Type__c, d.Sub_Type__c, d.Start__c, d.Hours__c, d.End__c,
                    d.Week__r.Monday_Unavailable_Hours__c,d.Week__r.Tuesday_Unavailable_Hours__c,d.Week__r.Wednesday_Unavailable_Hours__c,
                    d.Week__r.Thursday_Unavailable_Hours__c,d.Week__r.Friday_Unavailable_Hours__c,d.Week__r.Saturday_Unavailable_Hours__c,
                    d.Week__r.Sunday_Unavailable_Hours__c,d.Week__r.Release_Date__c,d.Week__r.Category_Num__c,
                    d.Week__r.Monday_Max_Hours__c,d.Week__r.Tuesday_Max_Hours__c,d.Week__r.Wednesday_Max_Hours__c,
                    d.Week__r.Thursday_Max_Hours__c,d.Week__r.Friday_Max_Hours__c,d.Week__r.Saturday_Max_Hours__c,
                    d.Week__r.Sunday_Max_Hours__c,d.week__r.Locking_User__c,d.Week__r.Monday_Booked_Hours__c,d.Week__r.Tuesday_Booked_Hours__c,
                    d.Week__r.Wednesday_Booked_Hours__c,d.Week__r.Thursday_Booked_Hours__c,d.Week__r.Friday_Booked_Hours__c,d.Week__r.Saturday_Booked_Hours__c,
                    d.Week__r.Sunday_Booked_Hours__c,d.Overbooked_Hours__c,d.Week__r.Employee__r.Own_Labour__c,d.Employee_Name__c,Job_Hours__c
                                                                              
                        From Diary_Entry__c d WHERE d.Week__r.Employee__c =:employeeId AND d.RecordTypeId =: RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability') 
                        // brm - 19-01-2010 - get current week entry
                        AND Week__r.Week_Commencing__c = :startOfWeek
                        // brm - 19-01-2010 - end date must be greater than or equal to selected date
                        AND d.END__c >= : selectedDateTime
                        // brm - 19-01-2010 - hours must be greater than combined hours
                        AND d.hours__c >= :hours ORDER BY d.Start__c ASC];
        
        // brm - 19-01-2010 - If there are diary entries to process
        if (des.size() > 0)
        {
            
           // FIX - Cognizant Support - Process Pool Diaries Seperately.
           // Redirecting to a different method for processing pool diaries.
            if(des[0].Week__r.Employee__r.Pool_Diary__c){
                if(des.size()!=1){
                    return null;
                }
                Diary_Entry__c de = processPoolDiaryForTransferWork(employeeId,selectedDateTime,hours,des);
                if(de == null){
                    return null;
                }
                return de;
            }
            
            // brm - 19-01-2010 - Get shifts for this week
            Week__c week = des.get(0).Week__r;
            
            
            
            
            List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{week.Monday_Start_Time__c, week.Monday_End_Time__c},
                                        new List<String>{week.Tuesday_Start_Time__c, week.Tuesday_End_Time__c},
                                        new List<String>{week.Wednesday_Start_Time__c, week.Wednesday_End_Time__c},
                                        new List<String>{week.Thursday_Start_Time__c, week.Thursday_End_Time__c},
                                        new List<String>{week.Friday_Start_Time__c, week.Friday_End_Time__c},
                                        new List<String>{week.Saturday_Start_Time__c, week.Saturday_End_Time__c},
                                        new List<String>{week.Sunday_Start_Time__c, week.Sunday_End_Time__c}};
            
            // brm - 19-01-2010 - now search for a valid diary entry
            string jobCateogry = thisJob.Latest_Customer_Category__c; 
            id profileId = userinfo.getProfileId();
            for (Diary_Entry__c de : des)
            {
             if(!system.label.SystemAdminId.contains(profileId) && de.Week__r.Locking_User__c != null && de.Week__r.Locking_User__c != userId
                ||(de.Week__r.Release_Date__c == null && de.Week__r.Category_Num__c  < jobCateogry)
                ||(de.Week__r.Release_Date__c != null &&  de.Week__r.Release_Date__c > system.today() && de.Week__r.Category_Num__c  < jobCateogry))
         {system.Debug('----de.Week__r.Locking_User__c----'+de.Week__r.Locking_User__c);
            continue;
         }
                // brm - 19-01-2010 - If the entry start date is less than the selected date time
                if (de.Start__c < selectedDateTime)
                {
                    // brm - 19-01-2010 - get shift hours between start of entry and selected date
                    Double hoursBeforeSelected = DateTimeHelper.calculateHours(de.Start__c, selectedDateTime, shifts);
                    // brm - 19-01-2010 - subtract shift hours from entry hours
                    de.Hours__c -= hoursBeforeSelected;
                    
                    if(de.Hours__c<minimumAvailableHours && hoursToTransfer > de.Hours__c){
                        
                        continue;
                        
                    }
                    
                    // brm - 19-01-2010 - If this diary entry can still fit the job booking
                    if (de.Hours__c >= hoursToTransfer)
                    {
                        // brm - 19-01-2010 - Modify entry start to start of shift and return
                        de.Start__c = DateTimeHelper.normaliseDateTime(selectedDateTime, shifts);
                        return de;
                        
                    }else {
                        
                        de.Start__c = DateTimeHelper.normaliseDateTime(selectedDateTime, shifts);
                        de.Overbooked_Hours__c = hoursToTransfer- de.Hours__c;
                        return de;
                        
                    }
                    
                }
                else
                {
                     if(de.Hours__c<minimumAvailableHours){
                        
                       continue;
                        
                    }
                    
                    de.Start__c = DateTimeHelper.normaliseDateTime(de.Start__c, shifts);
                    
                    // brm - 19-01-2010 - If this diary entry can still fit the job booking
                    if (de.Hours__c >= hoursToTransfer)
                    {
                        // brm - 19-01-2010 - Modify entry start to start of shift and return
                        return de;
                        
                    }else {
                        
                        de.Overbooked_Hours__c = hoursToTransfer- de.Hours__c;
                        return de;
                        
                    }
                }
            }
        }
        
        return null;
    }
    
   // FIX - Cognizant Support - Process Pool Diaries Seperately.
   // This method is newly written to process pool diaries.
         
    private Diary_Entry__c processPoolDiaryForTransferWork(ID employeeTransferWorkToId, DateTime notBeforeDateTime, Double hoursToTransfer,Diary_Entry__c[] des){
        
        System.debug(LoggingLevel.Info,'Start processPoolDiaryForTransferWork');
        Date startOfWeek = notBeforeDateTime.Date().toStartOfWeek();
        Map<Integer, String> WEEK_DAY_INTEGERS 
                = new Map<Integer, String> {0 =>'Mon', 1 => 'Tue', 2 => 'Wed', 3 => 'Thu', 4 => 'Fri',
                                            5 => 'Sat', 6 => 'Sun'};
        Integer offset = startOfWeek.daysBetween(notBeforeDateTime.date());
        Integer maxOffset = 6;
        Week__c week = des.get(0).Week__r;
        Diary_Entry__c de = des[0];
        List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{week.Monday_Start_Time__c, week.Monday_End_Time__c},
                                        new List<String>{week.Tuesday_Start_Time__c, week.Tuesday_End_Time__c},
                                        new List<String>{week.Wednesday_Start_Time__c, week.Wednesday_End_Time__c},
                                        new List<String>{week.Thursday_Start_Time__c, week.Thursday_End_Time__c},
                                        new List<String>{week.Friday_Start_Time__c, week.Friday_End_Time__c},
                                        new List<String>{week.Saturday_Start_Time__c, week.Saturday_End_Time__c},
                                        new List<String>{week.Sunday_Start_Time__c, week.Sunday_End_Time__c}};
        Map<String,Double> dayToAvailableHoursMap = new Map<String,Double>();
        dayToAvailableHoursMap = calculatePoolAvailability(week); 
        System.debug(LoggingLevel.Info,'Offset value is : '+offset);
        for(Integer i = offset;i<=maxOffset;i++){
            if((dayToAvailableHoursMap.get(WEEK_DAY_INTEGERS.get(i)))>=hoursToTransfer){
                System.debug(LoggingLevel.Info,'Transferring on : '+i);
                System.debug(LoggingLevel.Info,'Exit processPoolDiaryForTransferWork');
                return calculateStartAndHoursForPool(de,notBeforeDateTime,hoursToTransfer,shifts,i);
            }
        }
        
        return null;
        
    }
    
   // FIX - Cognizant Support - Process Pool Diaries Seperately.
   // This method is newly written to calculate pool availability.
         
    private Map<String,Double> calculatePoolAvailability(Week__c w){
         
         Map<String,Double> dayToAvailableHoursMap = new Map<String,Double>();
         dayToAvailableHoursMap.put('Mon',(
                                          ((w.Monday_Max_Hours__c == null) ? 0.00 : w.Monday_Max_Hours__c)-
                                          (
                                            ((w.Monday_Booked_Hours__c == null) ? 0.00 : w.Monday_Booked_Hours__c)+
                                            ((w.Monday_Unavailable_Hours__c == null) ? 0.00 : w.Monday_Unavailable_Hours__c)
                                           )
                                           ));
         dayToAvailableHoursMap.put('Tue',(
                                          ((w.Tuesday_Max_Hours__c == null) ? 0.00 : w.Tuesday_Max_Hours__c)-
                                          (
                                            ((w.Tuesday_Booked_Hours__c == null) ? 0.00 : w.Tuesday_Booked_Hours__c)+
                                            ((w.Tuesday_Unavailable_Hours__c == null) ? 0.00 : w.Tuesday_Unavailable_Hours__c)
                                           )
                                           ));
         dayToAvailableHoursMap.put('Wed',(
                                          ((w.Wednesday_Max_Hours__c == null) ? 0.00 : w.Wednesday_Max_Hours__c)-
                                          (
                                            ((w.Wednesday_Booked_Hours__c == null) ? 0.00 : w.Wednesday_Booked_Hours__c)+
                                            ((w.Wednesday_Unavailable_Hours__c == null) ? 0.00 : w.Wednesday_Unavailable_Hours__c)
                                           )
                                           ));
         dayToAvailableHoursMap.put('Thu',(
                                          ((w.Thursday_Max_Hours__c == null) ? 0.00 : w.Thursday_Max_Hours__c)-
                                          (
                                            ((w.Thursday_Booked_Hours__c == null) ? 0.00 : w.Thursday_Booked_Hours__c)+
                                            ((w.Thursday_Unavailable_Hours__c == null) ? 0.00 : w.Thursday_Unavailable_Hours__c)
                                           )
                                           ));
         dayToAvailableHoursMap.put('Fri',(
                                          ((w.Friday_Max_Hours__c == null) ? 0.00 : w.Friday_Max_Hours__c)-
                                          (
                                            ((w.Friday_Booked_Hours__c == null) ? 0.00 : w.Friday_Booked_Hours__c)+
                                            ((w.Friday_Unavailable_Hours__c == null) ? 0.00 : w.Friday_Unavailable_Hours__c)
                                           )
                                           ));   
         dayToAvailableHoursMap.put('Sat',(
                                          ((w.Saturday_Max_Hours__c == null) ? 0.00 : w.Saturday_Max_Hours__c)-
                                          (
                                            ((w.Saturday_Booked_Hours__c == null) ? 0.00 : w.Saturday_Booked_Hours__c)+
                                            ((w.Saturday_Unavailable_Hours__c == null) ? 0.00 : w.Saturday_Unavailable_Hours__c)
                                           )
                                           ));
         dayToAvailableHoursMap.put('Sun',(
                                          ((w.Sunday_Max_Hours__c == null) ? 0.00 : w.Sunday_Max_Hours__c)-
                                          (
                                            ((w.Sunday_Booked_Hours__c == null) ? 0.00 : w.Sunday_Booked_Hours__c)+
                                            ((w.Sunday_Unavailable_Hours__c == null) ? 0.00 : w.Sunday_Unavailable_Hours__c)
                                           )
                                           ));
        return dayToAvailableHoursMap;
    }
 
 // FIX - Cognizant Support - Calculate start time & hours for pool resource.
 // This method is newly written to calculate start time and available hours for pool diary.

  private Diary_Entry__c calculateStartAndHoursForPool(Diary_Entry__c de,DateTime notBeforeDateTime, Double hoursToTransfer,List<List<String>> shifts, Integer day){

        Integer offset = (notBeforeDateTime.Date().toStartOfWeek()).daysBetween(notBeforeDateTime.date());

       // Scenario when we want to transfer on Monday but only Tuesday is available.
        if( offset < day )
        {
            notBeforeDateTime = notBeforeDateTime.addDays(day-offset);
        }

        if (de.Start__c < notBeforeDateTime)
                {
                    if (de.Hours__c >= hoursToTransfer)
                    {
                        de.Start__c = DateTimeHelper.normaliseDateTime(notBeforeDateTime, shifts);
                        System.debug(LoggingLevel.Info,'Actual transfer can be done on : '+  de.Start__c);
                        return de;
                    }
                }
        else
              {
                    if(de.Hours__c >= hoursToTransfer){
                        return de;
                    }
              }
              
      return null;
      
   }

    // brm - 16-01-2010 - validate hours information with shift pattern
    private void convertToShiftPattern(WeekManager.EntryDetails entry, Date weekStart, Date availEnd, List<Shift> shifts)
    {
        // brm - 15-01-2010 - make sure start is within a shift pattern
        DateTime startDate = entry.startTime;
        system.debug(LoggingLevel.INFO, '------------------ current booking: ' + entry);
        system.debug(LoggingLevel.INFO, '------------------ week start: ' + weekStart);
        system.debug(LoggingLevel.INFO, '------------------ avail end: ' + availEnd);
        system.debug(LoggingLevel.INFO, '------------------ shifts: ' + shifts);
        
        Boolean invalidStart = true;
        // brm - 15-01-2010 - Loop from start date of availability to end date of availability
        for (Integer day = weekStart.daysBetween(entry.startTime.Date()); day <= weekStart.daysBetween(availEnd); day++)
        {
            // brm - 15-01-2010 - Get current day shift pattern
            Shift current = shifts.get(day);
            
            // brm - 16-01-2010 - make sure the day has a shift
            if (current.startTime != null && current.endTime != null)
            {
                // brm - 16-01-2010 - if the start date is less than the end shift then we have a valid start date
                if (startDate.Time() < DateTimeHelper.stringToTime(current.endTime)) { invalidStart = false; break; }
                else
                {
                    // brm - 15-01-2010 - setup start date for next 
                    startDate = startDate.addDays(1);
                    startDate = startDate.addHours(-startDate.hour());
                    startDate = startDate.addMinutes(-startDate.minute());
                    
                    // brm - 16-01-2010 - If next day shift is null, skip next time/shift setup
                    if (shifts.get(day+1).startTime == null) continue;
                    // brm - 16-01-2010 - get shift pattern of next day
                    Time t = DateTimeHelper.stringToTime(shifts.get(day+1).startTime);
                    
                    // brm - 16-01-2010 - set time component to new day shift pattern
                    startDate = startDate.addHours(t.hour());
                    startDate = startDate.addMinutes(t.minute());
                }
            }
        }
        
        system.debug(LoggingLevel.INFO, '------------------ invalid start date = ' + invalidStart);
        system.debug(LoggingLevel.INFO, '------------------ start date: ' + startDate);
        
        // brm - 16-01-2010 - If the start has been validated
        if (invalidStart == false)
        {
            // brm - 15-01-2010 - add valid start to booking
            entry.startTime = startDate;
            system.debug(LoggingLevel.INFO, '---------------- valid start date: ' + entry.startTime);
            
            // brm - 15-01-2010 - setup initial end as the start
            DateTime endDateTime = entry.startTime;
            
            // brm - 15-01-2010 - setup initial hours to go as duration
            Double hoursToGo = entry.hours;
            // brm - 15-01-2010 - Loop until we have used up all hours
            while (hoursToGo > 0)
            {
                system.debug(LoggingLevel.INFO, '---------------- current end date: ' + endDateTime);
                system.debug(LoggingLevel.INFO, '---------------- total hours left: ' + hoursToGo);
                
                // brm - 15-01-2010 - get current day's shift
                Shift current = shifts.get(weekStart.daysBetween(endDateTime.Date()));
                
                // brm - 15-01-2010 - setup initial hours to go as duration
                Double currentShiftHoursLeft = DateTimeHelper.subtractTime(DateTimeHelper.StringToTime(current.endTime), endDateTime.Time());
                system.debug(LoggingLevel.INFO, '---------------- hours left for current day: ' + currentShiftHoursLeft);
                
                // brm - 15-01-2010 - If the hours to go can fit in current shift
                if(hoursToGo-currentShiftHoursLeft < 0.3 && hoursToGo-currentShiftHoursLeft >0)
                {
                    hoursToGo = currentShiftHoursLeft;
                }
                if (currentShiftHoursLeft >= hoursToGo)
                {
                    system.debug(LoggingLevel.INFO, '---------------- adding final shift hours to current end date:' + endDateTime + ' plus ' + hoursToGo);
                    endDateTime = DateTimeHelper.addHoursToDT(endDateTime, hoursToGo);
                    break;
                }
                else
                {
                    // brm - 15-01-2010 - Reduce hours to go by remaining hours left on current shift
                    hoursToGo -= currentShiftHoursLeft;
                    
                    // brm - 15-01-2010 - Set shift to null 
                    current = null;
                    
                    system.debug(LoggingLevel.INFO, '---------------- finding next shift day:');
                    // brm - 16-01-2010 - try and find a shift for the next day (loops until a valid shift is found)
                    while (current == null || current.startTime == null || current.endTime == null)
                    {
                        // brm - 16-01-2010 - setup end date for next day
                        endDateTime = endDateTime.addDays(1);
                        // brm - 16-01-2010 - reset time component to zero
                        endDateTime = endDateTime.addHours(-startDate.hour());
                        endDateTime = endDateTime.addMinutes(-startDate.minute());
                        system.debug(LoggingLevel.INFO, '---------------- current next shift day:' + endDateTime);
                        
                        // brm - 16-01-2010 - get current day in week
                        Integer day = weekStart.daysBetween(endDateTime.Date());
                        
                        // brm - 16-01-2010 - If the current day is greater than 6 something has gone wrong somewhere...
                        if (day >= 7) throw new AvailabilityException('The selected availability doesn\'t have enough hours for the job booking.');
                        // brm - 16-01-2010 - Get current shift for this day
                        current = shifts.get(day);
                        system.debug(LoggingLevel.INFO, '---------------- shift day: ' + day);
                    }
                    
                    // brm - 15-01-2010 - get shift start time
                    Time t = DateTimeHelper.stringToTime(current.startTime);
                    
                    // brm - 15-01-2010 - add shift start time to end date time
                    endDateTime = endDateTime.addHours(t.hour());
                    endDateTime = endDateTime.addMinutes(t.minute());
                }
            }
            /* brm - 16-01-2010 - todo - May need to make sure start and end are still inside the availability entry
                This should only break if the stored availability is not big enough to fit 
                (i.e. something has gone terribly wrong)
            */
            entry.endTime = endDateTime;
            system.debug(LoggingLevel.INFO, '---------------- final end date: ' + entry.endTime);
        }
    }
    
    // brm - 07-01-2010 - class to seperate days of week into shifts
    public class Shift
    {
        String startTime;
        String endTime;
        
        public Shift(String st, String en)
        {
            this.startTime = st;
            this.endTime = en;
        }
    }
 
    
    //method to update the job_element__c records for the return functionality 
    private Map<boolean, string> updateReturnData(List<JobElementItem> items){
        System.Savepoint sp = Database.setSavepoint();
        try{
            //1. Update job elements to have status of Returned 
            List<Job_Element__c> toUpdate = new List<Job_Element__c>();
            for(JobElementItem jei : selectedItems)
            {
                jei.jE.Status__c = 'Returned';
                toUpdate.add(jei.jE);
            }
            
            update toUpdate;
            
            //2. Reduce values in skills on job
            for(HoursInformation hi : his.values())
            {
                // Cognizant - CHI Phase III CR-002 implementation... START 
                
                thisJob = ObjNewSkill.reduceSkillValues(thisJob, hi.skill, hi.totalReduction);
                
                if(hi.skill == 'Mechanical')
                    thisJob.Mechanical_Hours__c -= hi.totalReduction; 
                else if(hi.skill == 'Building Work')
                    thisJob.Building_Work_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Unvented_Hot_Water')
                    thisJob.Unvented_Hot_Water_Hours__c -= hi.totalReduction; 
                else if(hi.skill == 'Specialist_Building_Work')
                    thisJob.Specialist_Building_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Scaffolder')
                    thisJob.Scaffolder_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Roof_Work')
                    thisJob.Roof_Work_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Powerflush')
                    thisJob.PowerFlush_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Payment_Collection')
                    thisJob.Payment_Collection_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'LPG_Installation')
                    thisJob.LPG_Installation_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Fire/Wall_Heater_Fixing')
                    thisJob.Fire_Wall_Heater_Fixing_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Electrical_Work_ASP')
                    thisJob.Electrical_Work_ASP_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Electrical')
                    thisJob.Electrical_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Contractor_Installation')
                    thisJob.Contractor_Installation_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Connect_Solar_Panels')
                    thisJob.Connect_Solar_Panel_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Asbestos_Removal')
                    thisJob.Asbestos_Removal_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Asbestos_Removal-Fixed_Rate')
                    thisJob.Asbestos_Removal_Fixed_Rate_Hours__c -= hi.totalReduction;
                else if(hi.skill == 'Water_Heater_Fixing')
                    thisJob.Water_Heating_Fixing_Hours__c -= hi.totalReduction;

                // Cognizant - CHI Phase III CR-002 implementation... END
            }
            
            // brm - 08-01-2010 - Gets around the validation rules when changing hours
            thisJob.Trigger_Update_Work_Hours__c = System.Now();
            update thisJob;
            
            //3. Manipulate diary entries....
           
            
            help.updateDiaryEntries(thisJob, his);                      
            
            
            //4. Add Job Booking History item
            Job_Booking_History__c jbh = new Job_Booking_History__c(
                Job__c = thisJob.Id,
                Work_Affected__c = true
            );
            insert jbh;
            
        }catch(System.Exception ex){
            Database.rollback(sp);
            return new Map<boolean, string>{false => ex.getMessage()};
        }
        return new Map<boolean, string>{true => 'Success'};
        //return new Map<boolean, string>{false => ''};
    }
    
    
     /* brm - 15-01-2010
        Subclass to store hours information by employee
    */
    public class EmployeeData
    {
        //public String employeeId {get; private set;}
        public ID employeeId {get; private set;}
        
        public Diary_Entry__c availability {get; set;}
        public Double combinedHours {get; set;}
        public List<HoursInformation> his {get; private set;}
        public List<HoursInformation> travelHis {get; private set;}
        public boolean isPoolEmployee {get;set;}

        public datetime endDateTime {get;set;}
        // Plan additional skills CR - Starts
        public Double nonOverbookedHours {get;set;}
        // Plan additional skills CR - Ends
        
        public EmployeeData(ID empId)
        {
            this.employeeId = empId;
            this.his = new List<HoursInformation>();
        }
        
        public String getEmployeeName()
        {
            String name = '';
            if (availability != null)
            {
                name = availability.week__r.employee__r.name;
            }
            return name;
        }
        
        public double frontTravel {get;set;}
        public double backTravel {get;set;}
       
    }
    
    /*
    Subclass to hold the row item data. Just the job_element__c item and an indicator
    whether selected or not.
    */
    public without sharing  class JobElementItem {
        
        public Boolean isSelected{get; set;}
        public Job_Element__c jE{get; private set;}
        
        public JobElementItem(Job_Element__c jE){
            this.jE = jE;
            isSelected = false;
        }
    }
    
    
    /*
    Subclass to hold the row item data. Just the Diary Entry and an indicator
    whether selected or not.
    */
    public without sharing  class DiaryItem {
        
        public Boolean isSelected{get; set;}
        public Diary_Entry__c dE{get; private set;}
        public HoursInformation hinfo{get;private set;}
        public double reduction{get;set;}
        
        public DiaryItem(Diary_Entry__c dE1){
            this.dE = dE1;
            isSelected = false;
            hInfo= new HoursInformation(dE1.sub_Type__c);
        }
    }
    
    /*
    Subclass to hold the Hours information
    */
    public without sharing class HoursInformation{
        public string skill{get; set;}
        public List<EntryRecord> entries{get; set;}
        public double totalHours{get; set;}
        public double duration{get; set;}
        public datetime start{get; set;}
        public Diary_Entry__c[] diaryEntries{get;set;}
        //create an id to use in the page to reference the correct item
        public string myId{get; private set;}
        public String Order{get;Private set;} //Added By Ashok G to hold the order of the TRavel job.
        //Hijacking a job__c record as it has the field types required in UI
        //job.Named_Employee__c is the employee to transfer work to
        //job.Customer_Preferred_Date__c  is the 'Not Before' date.
        public Job__c job{get; set;}
        
        // brm - 15-01-2010 - Stores end date time
        public datetime endDT{get; set;}
        
        public Double overBookedHours{get; set;}
        
        public HoursInformation(string skill){
            
            this.skill = skill;
            entries = new List<EntryRecord>();
            totalHours = 0;
            myId = skill.replace(' ','_');
            job = new Job__c();
            overBookedHours = 0.00;
            
        }
        
        //add a diary entry to the hoursInformation entry
        public void addDiaryEntry(Diary_Entry__c ent ){
            entries.add(new EntryRecord(ent));
            
        }
        
        //public double aa=0;
        public double totalReduction{ get{
            double reduction = 0;
            system.debug('outside' +reduction);
            //work out the total reduction for the skill type.
            for(EntryRecord er : entries) {
            system.debug('*reductionnnnnnn'+er);
            if(er.reduction!=null)
                {
                reduction += er.reduction;
                
                system.debug('inside' +reduction);
                }
            }
            //system.debug('ynew'+er.reduction);
            system.debug('fnew'+reduction);
            return reduction;
            
        }}
        
        //remove an entry from the hoursInformation entry
        //just here for completeness
        public void RemoveDiaryEntry(Diary_Entry__c ent ){
            for(integer i = entries.size()-1; i >= 0; i--){
                if(entries[i].ent.Id == ent.Id){
                    entries.remove(i);
                    break;
                }
            }
        }
        public void addHours(double hours){
            totalHours += hours;
        }
        
        string travelJob;
    }
    
    /*
    Subclass to hold the diray entry row item data. 
    Holds Diary_Entry__c and reduction amount
    */
    public without sharing  class EntryRecord {
        
        public double reduction{get; set;}
        public Diary_Entry__c ent{get; private set;}
        public String EmployeeName{get; private set;}
        //will hold the hours + overbooked hours
        public decimal totalHours{get; private set;}
        public String EmpSupNum{get; private Set;}
        
        public EntryRecord(Diary_Entry__c ent){
            this.ent = ent;
            this.EmpSupNum = ent.supplier_num__c;
            double th = (ent.Hours__c == null ? 0 : ent.Hours__c) + (ent.Overbooked_Hours__c == null ? 0: ent.OverBooked_Hours__c);
            totalHours = Decimal.valueOf(th).setScale(2);
        }
    }
    
    
    // Plan additional skills CR - Starts
    /*
    Subclass to hold the Hours information for replan mode
    */
    public without sharing class ReplanHoursInformation{
        public string skill{get; set;}
        public Job__c job{get; set;}
        public ID weekId{get;set;}
        public double totalHours{get; set;}
    }
    // Plan additional skills CR - Ends
    
    // Cognizant support fix - Transfer hours does not consider employee skills.
    
    private boolean checkEmployeeSkills(){
        
        Boolean isEmployeeNotHaveSkill = false;
        
        Map<ID,List<Employee_Skills__c>> empAndEmpSkillsMap = new Map<ID,List<Employee_Skills__c>>();
        
        List<ID> hisEmpList = new List<ID>();
        
        List<HoursInformation> hiList = new List<HoursInformation>();
        
        // Plan additional skills CR - Starts
        empNameSkillsNotFoundMap = new Map<String,List<String>>();
        
        Map<Id,String> empIDNameMap = new Map<Id,String>();
        // Plan additional skills CR - Ends
        
        for(HoursInformation hi:his.values()){
            if(hi.Job.Named_Employee__c!=null){
                hisEmpList.add(hi.Job.Named_Employee__c);
                hiList.add(hi);
            } 
        }
        
        // Plan additional skills CR - Starts
        Employee_Skills__c[] empSkills = [select Employee__r.ID, Employee__r.Name, Skill_Name__c from Employee_Skills__c where Employee__c in :hisEmpList];
        
        Employee__c[] empList = [select ID, Name, Inactive__c from Employee__c where ID in :hisEmpList];
        
        for(Employee__c e : empList){
            if(!empNameSkillsNotFoundMap.containsKey(e.Name)){
                empNameSkillsNotFoundMap.put(e.Name,new List<String>());
                empIDNameMap.put(e.ID,e.Name);
            }else{
                continue;
            }
        }
        
        if(empSkills.size() == 0) {
            isEmployeeNotHaveSkill = true;
        } 
        /*As a part of  - PRB00008082 -BGSAMSSupport - starts */
        isEmployeeNotActive= false;    
        List<ID> empinactive = new List<ID>();
        for (Employee__c e : empList){
        if(e.Inactive__c == true)
        empinactive.add(e.Id);
        }
        if(empinactive.size()> 0) {
            isEmployeeNotActive = true;
            isAvailabilityRendered = false;
         } 
        /*As a part of  - PRB00008082 -BGSAMSSupport - ends */
        for(Employee_Skills__c empsks:empSkills){
            if(empAndEmpSkillsMap.containsKey(empsks.Employee__r.ID)){
                empAndEmpSkillsMap.get(empsks.Employee__r.ID).add(empsks);
            }else{
                empAndEmpSkillsMap.put(empsks.Employee__r.ID,new List<Employee_Skills__c>());
                empAndEmpSkillsMap.get(empsks.Employee__r.ID).add(empsks);
            }
        }
        
        Boolean foundEmpSkill = false;
        String hisSkill;
        String empSkill;
        
        for(HoursInformation hisRecord:hiList){
            foundEmpSkill = false;
            hisSkill = hisRecord.skill.toUpperCase();
                for(Employee_Skills__c empSkillRecord:empAndEmpSkillsMap.get(hisRecord.Job.Named_Employee__c)){
                    empSkill = empSkillRecord.Skill_Name__c.toUpperCase();
                    if(empSkill.equalsIgnoreCase(hisSkill)){
                        foundEmpSkill = true;
                        System.debug(LoggingLevel.info,'Skill Matched!!!!');
                    }
                }
           if(foundEmpSkill){
             // do nothing
           }else{
              isEmployeeNotHaveSkill = true;
              empNameSkillsNotFoundMap.get(empIDNameMap.get(hisRecord.Job.Named_Employee__c)).add(hisSkill);
           }          
        }
        
        return isEmployeeNotHaveSkill;
        // Plan additional skills CR - Ends
        
    }
  
  // Plan additional skills CR - Starts
  public PageReference selectAll(){
        if(this.selectAll != null){
            

            for(DiaryItem item : DItems)
            {
                item.IsSelected = selectAll;
            } 
            //calculateSelectedHours(); 
        }
        
        return null;      
    } 
  public PageReference planRemedialJob()
  {
    system.debug('Remedial Work1-->'+his);
    system.debug('Remedial Work2-->'+employeeHoursInformation);
    for (HoursInformation hi : his.values()){
        for(ReplanHoursInformation rHoursInfo : listReplanhoursInfo){
                if(rHoursInfo.skill == hi.skill){
                    if(rHoursInfo.job.Previous_Start_Time__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select  "Diary Start Date  date to proceed.'));
                        isConfirmRendered = false;
                        return null;
                    }else if(rHoursInfo.job.Named_Employee__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select  "Named employee"  to proceed.'));
                        isConfirmRendered = false;
                        return null;
                    }
                    hi.job = rHoursInfo.job;
               }
        }
    }
   
    
    isEmployeeNotHaveSkill = checkEmployeeSkills();
    if(remedial && isEmployeeNotHaveSkill)
    {
         String allSkills = '';
         for(String empName : empNameSkillsNotFoundMap.keySet())
         {
             List<String> skillList = empNameSkillsNotFoundMap.get(empName);
             allSkills = '';
             if(skillList.size()<=0){
                continue;
                }
                else{
                    Integer i = 0;
                    for(String skill : skillList){
                        if(i == 0)
                        allSkills = allSkills + skill;
                        else
                        allSkills = allSkills + ', ' + skill;
                        i++;
                    }
                }
            isConfirmRendered = false; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, empName + ' does not have ' + allSkills + ' skill.'));
        }
        return null;
    
    }else if( remedial && !isEmployeeNotHaveSkill)
    {
        Boolean generateOrder;
        list<Diary_Entry__c> nonProdDe = new list<Diary_Entry__c>();
        date installationDate;
        nonProdDe = [Select Id from Diary_Entry__c where Job__c =:thisJob.Id];
        if(nonProdDe.size()>0) 
        delete nonProdDe;
        {
            nonProdDe = new list<Diary_Entry__c>();
            generateOrder = true;
        }
        for (HoursInformation hi : his.values())
        {
           Diary_Entry__c d = new Diary_Entry__c();
           d.RecordTypeId = ENTRY_RECTYPE_NPJB;
           d.Job__c = thisJob.Id;
           d.Sub_Type__c = hi.skill;
           d.Start__c = hi.job.Previous_Start_Time__c;
           d.Hours__c = hi.totalHours;
           d.End__c = hi.job.Previous_Start_Time__c+(hi.totalHours/24);
           date start =  hi.job.Previous_Start_Time__c.date().toStartOfWeek();
           Week__c w = [select id from Week__c where Employee__c = :hi.job.Named_Employee__c and Week_Commencing__c= : start limit 1];
           if(w!=null)
           d.Week__c = w.Id;
           nonProdDe.add(d);
           if(installationDate == null || installationDate > d.Start__c.date())
           installationDate = d.Start__c.date();
        }
        try
        {
            if(nonProdDe.size()>0)
            insert nonProdDe;
            
            Job__c j = new Job__c (Status__c = 'Planned', Sub_Status__c= 'Planned', Id= thisJob.Id, Installation_Date__c= installationDate, Date_Planned__c = system.today(),Order_Created__c = true);
            update j;
            
            if(!generateOrder && !Tran)
            {
                AutoGeneratePurchaseOrders newObj = new AutoGeneratePurchaseOrders();
                newObj.autoGenerateOrders(j);
            }   
            return(new PageReference('/'+j.Id) );
        }catch (Exception e)
        {
            system.debug('Exception in non Productive planning Code'+e);    
        }
        
    }
    return null;
  }
  // ++ Added for CR#884 start
  public void calculateSelectedHours()
  {
    hourList = new List<transferHours>();
    for(JobElementItem je : Items)
    {
        if(je.isSelected == true)
        {
            //totalHours = 0;
            transferHours hour = new transferHours();
            if(skillmap.containsKey(je.jE.Skill__c))
            {
                hour = skillmap.get(je.jE.Skill__c);
                //totalHours = totalHours + hour.hours;
                if(!hour.elementIds.contains(je.jE.id))
                {
                    hour.elementIds.add(je.jE.id);
                    hour.skillStyle = 'color:#4842F5;';
                    hour.hours = hour.hours + je.jE.Units__c;
                    totalHours = totalHours + je.jE.Units__c;
                }
            }
            skillmap.put(je.jE.Skill__c , hour);
            
        }
        else
        {
            transferHours hour = new transferHours();
            if(skillmap.containsKey(je.jE.Skill__c))
            {
                hour = skillmap.get(je.jE.Skill__c);
                //totalHours = totalHours - hour.hours;
                if(hour.elementIds.contains(je.jE.id))
                {
                    hour.hours = hour.hours - je.jE.Units__c;
                    hour.skillStyle = '';
                    hour.elementIds.remove(je.jE.id);
                    totalHours = totalHours - je.jE.Units__c;
                }
            }
            skillmap.put(je.jE.Skill__c , hour);
        }
        system.debug('------skillmap-------------'+skillmap);
    }
    if(skillmap != null && skillmap.values() != null )
    {
        hourList = sortSkills(skillmap);
    }
  }
  
  list<transferHours> sortSkills(map<string,transferHours> skillMap)
  {
    List<string> skillset = new List<string>();
    skillset.addAll(skillMap.keySet());
    skillset.sort();
    system.debug('------skillset-------------'+skillset);
    List<transferHours> tmpHourList = new List<transferHours>();
    List<transferHours> basicHourList = new List<transferHours>();
    for(String tmpSkill : basicSkillList)
    {
        transferHours tmpHour = new transferHours();
        //tmpHour.skill = tmpSkill;
        tmpHour = skillMap.get(tmpSkill);
        basicHourList.add(tmpHour);
    }
    tmpHourList.addAll(basicHourList);
    for(String skill : skillset)
    {
        if(!basicSkillSet.contains(skill))
        tmpHourList.add(skillMap.get(skill));
    }
    return tmpHourList;
  }
  public class transferHours
  {
    public string skill {get; set;}
    public double hours {get; set;}
    public set<Id> elementIds {get; set;}
    public string skillStyle {get; set;}
    public transferHours()
    {
        skill = '';
        hours = 0;
        elementIds = new set<Id>();
        skillStyle = '';
    }
  }
 
  // -- Added for CR#884 start
  /*public void updateEntriesReduction(){
  
  for(HoursInformation h: his.values()){
     system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+h);
     system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+selectedDItems);
     system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=In 2223:'+h.entries);
     for(EntryRecord eR: h.entries){
        for(DiaryItem dEIt: selectedDItems){
        system.debug(LoggingLevel.INFO,''+dEIt.hInfo.Job.Named_Employee__c);
           if(eR.ent.Id == dEIt.dE.id){
               eR.Reduction = dEIt.reduction;
               if(dEIt.hInfo.Job.Named_Employee__c != null){
                  h.job.Named_Employee__c = dEIt.hInfo.JOb.Named_Employee__c;
                  if(dEIt.hInfo.Job.customer_Preferred_Date__c !=null){
                  h.job.customer_Preferred_Date__c = dEIt.hInfo.Job.Customer_preferred_date__c;
                  } 
                  else{
                  stepIndex = 'Error';
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select Customer Preferred date.'));
                  return;
                  }
                  
              }else{
               stepIndex = 'Error';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select the Employee you want to Transfer.'));
               return;
              }
               
                
           }
          
        }
     }
    
   }
   //return null;
  }
  */
  
  
}