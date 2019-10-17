//Helper class to plan the installation dates for a simple job
public class customerPortalHSAPlanHelper { 
    
   public static List<JobResourcingOption> candidatesList = new list<JobResourcingOption>();
    
   Public Static getHSAPlanInstallDateResponseJSON.installdateResponse InstallDateList(String oppId,String quoteID,String jobID, date customerPreferredDate,String navigate)
   {
      getHSAPlanInstallDateResponseJSON.installdateResponse returnResponse = new getHSAPlanInstallDateResponseJSON.installdateResponse();  
      getHSAPlanInstallDateResponseJSON.Error errorResponse = new getHSAPlanInstallDateResponseJSON.Error();  
      String custdate;
      boolean complexFlag = fetchJobByJob(jobID).Simple_Complex_Job__c == 'Complex';      
       List<Opportunity> oppList = [SELECT id,Opp_Id_Encrypted__c From Opportunity WHERE ID =:oppId];  
       
       returnResponse.jobId = jobId;
       returnResponse.quoteId = quoteId;
       //returnResponse.leadId = oppId;   
       returnResponse.leadId = oppId;           
       returnResponse.complexJob = complexFlag;
            if(customerPreferredDate !=null )
            {   
                returnResponse.customerPreferredDate = customerPreferredDate;                
            }
            else
            {
                returnResponse.customerPreferredDate = system.today();
            } 
       if(navigate!=null&& navigate=='Previous')
       {
           returnResponse.customerPreferredDate-=7;           
       }
       else if(navigate!=null&& navigate=='Next')
       {
           returnResponse.customerPreferredDate+=7;
       }
     if (!complexFlag)
     {
         
         /*BlackBoxOptions dt = new BlackBoxOptions();
         Date check = dt.HSACustomerPrefDate(returnResponse.customerPreferredDate);
         custdate = check.format();*/
         
         try
         {
             runsearch(jobId,returnResponse.customerPreferredDate.format());
             //runsearch(jobId,custdate);
             if(!candidatesList.isEmpty())   
              {
                    List<getHSAPlanInstallDateResponseJSON.JobResourcingOptions>  candiList = new List<getHSAPlanInstallDateResponseJSON.JobResourcingOptions>();
                    for(JobResourcingOption jobres:candidatesList)
                    {
                        getHSAPlanInstallDateResponseJSON.JobResourcingOptions js = new getHSAPlanInstallDateResponseJSON.JobResourcingOptions();
                        js.installDate= jobres.primaryStartDT.format();   
                        if(jobres.primaryStartDT.time() < time.newInstance(08, 00, 00, 00))
                        {
                            js.installDate= datetime.newInstance(jobres.primaryStartDT.date(), time.newInstance(08, 00, 00, 00)).format();
                        }
                        js.optionID=jobres.optionID;
                        candiList.add(js);
                    }
                   returnResponse.installOptions = candiList;
              }
         
         }catch(SearchBlackBox.JobLockingException ex){
               errorResponse.errorCode ='1';
               errorResponse.ErrorMessage = ex.getMessage();
               returnResponse.errorList.add(errorResponse);               
         }catch(Exception ex) {  
             errorResponse.errorCode ='2';
             errorResponse.ErrorMessage = ex.getMessage();
             returnResponse.errorList.add(errorResponse);                
         } 
     }
       system.debug('&@@Candidates--->'+candidatesList);
       system.debug('&@@respone  '+returnResponse);
       system.debug('&@@JSONrespone  '+JSON.serialize(returnResponse));
       return returnResponse;
   }
    
   public static void runSearch(string jobId, String customerPreferedDate) 
   {
         IPSFromSearchObject searchObject;
         String custdate;
         List<JobResourcingOption> candidates;        
         List<List<JobResourcingOption>> jobResourcingOptions;
         
            if(customerPreferedDate == null || customerPreferedDate == '')
            {
                cls_IsRun.customerPreferredDate = system.today();
            }
            else
            {
                cls_IsRun.customerPreferredDate = date.parse(customerPreferedDate);  
                system.debug('@@cust date :-------->'+cls_IsRun.customerPreferredDate );
            } 
         cls_IsRun.isPlanner = 'N';
         cls_IsRun.isPortal =true;
            
        if(jobID != null) {            
            searchObject = new IPSFromSearchObject(); 
            jobResourcingOptions = searchObject.startSearch(jobID);
            
         /* if(Test.isRunningTest())            
            {                
                jobResourcingOptions = new  List<List<JobResourcingOption>>();
                List<jobResourcingOption> jrlist = new List<jobResourcingOption>();
                jobResourcingOption jr1 = new jobResourcingOption();
                jr1.Day=null;jr1.optionID='2018-10-26,08:41:30:865-1';jr1.primaryStartDT=system.today();
                jobResourcingOption jr2 = new jobResourcingOption();
                jr2.Day=null;jr2.optionID='2018-10-26,08:41:30:865-2';jr2.primaryStartDT=system.today()+1;
                jobResourcingOption jr3 = new jobResourcingOption();
                jr3.Day=null;jr3.optionID='2018-10-26,08:41:30:865-3';jr3.primaryStartDT=system.today()+2;
                jobResourcingOption jr4 = new jobResourcingOption();
                jr4.Day=null;jr4.optionID='2018-10-26,08:41:30:865-3';jr4.primaryStartDT=system.today()+3;
                jobResourcingOption jr5 = new jobResourcingOption();
                jr5.Day=null;jr5.optionID='2018-10-26,08:41:30:865-3';jr5.primaryStartDT=system.today()+4;
                jrlist.add(jr1);
                jrlist.add(jr2);
                jrlist.add(jr3);jrlist.add(jr4);jrlist.add(jr5);
                jobResourcingOptions.add(jrlist);
                jobResourcingOptions.add(jrlist);
                jobResourcingOptions.add(jrlist);
            }*/
                 
            
            if(jobResourcingOptions != null)
            {
                if(jobResourcingOptions[1]!=null && !jobResourcingOptions[1].isEmpty()) { 
                    //primary and secondary candidadate lists
                    candidates = jobResourcingOptions[1];   
                    
                    for(JobResourcingOption jro : candidates )
                    {
                        if(jro.primaryStartDT != null)
                        jro.Day = jro.primaryStartDT.format('EEEEE');
                    }
                } 
            }            
            if(candidates!=null)
            {            
            candidatesList = showmore(candidates); 
            }
        }
         
     }
    
     public static list<JobResourcingOption> showmore(List<JobResourcingOption> candidates){
      
      SearchResultsController searchController = new SearchResultsController();
      integer count = Integer.Valueof(system.label.PortalPlanningOptionCount);      
      
      set<date> cand1 = new set<date>();
      list<jobResourcingOption> candi=new list<jobResourcingOption>(); //List to Hold Different Options 
        for(JobresourcingOption cand:candidates){
           boolean showResource = searchController.checkEligiblty(cand.PrimaryResources);
            system.debug('@@showResource '+showResource);
           if(!showResource) {
           continue;
           }             
           string s='12:00';
           time t = DateTimeHelper.stringToTime(s);
           if(SearchBlackBox.jobInfo.Job.S_P_Hours__c == 8.00 && cand.primaryStartDT.Time() == t){
             continue;
           }
            system.debug('@@candi '+candi);
            
           if(!cand1.contains(cand.primaryStartDT.Date()) && (cand.Day!='Saturday' && cand.Day!='Sunday')){
             cand1.add(cand.PrimaryStartDT.Date());             
             candi.add(cand); //Avoid Same dates
           }
        }      
      if(candi.size()>1) 
          searchController.sort1(candi);
         
      if(candi.size()<=count && candidates!=null){
      count = candi.size();
      }
         
      list<JobResourcingOption> candidates1 = new list<JobResourcingOption>();
        
        for(integer j=0;j<count;j++){
              candidates1.add(candi[j]); 
        } 
         system.debug('Candidates--->'+candidates1);
         return candidates1;
         
    }
    
    
     /*
    public static boolean validateJobSkillHoursHSA(String JobId)
    {
       
        AddNewSkill ObjNewSkill = new AddNewSkill(); 
        Map<String, Double> skillsAndHours = new Map<String, Double>(); 
        boolean complexFlag = FALSE ;        
       
        Job__c job = fetchJobByJob(jobId); 
        
        skillsAndHours= ObjNewSkill.setSkillHoursInfo(job, skillsAndHours);
        if(job.Scaffolder_Hours__c > 0) 
        {
           skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
        }
        
        Set<String> simple = new Set<String>{'BUILDING WORK','ELECTRICAL','MECHANICAL','POWERFLUSH','ROOF WORK','SPECIALIST BUILDING','LANDLORD CHECK','REMOTE HEATING','SCAFFOLDER'};
        boolean complextype = FALSE;
        Double totalSkills = 0.0;
        
         for(String sk : skillsAndHours.keySet()) {
               If(simple.contains(sk)){
                   if(sk!='ELECTRICAL')
                   totalSkills += skillsAndHours.get(sk);
              
               continue;
               }
               else
               complextype = TRUE;
            } 
        system.debug(totalSkills);
        system.debug(complextype);
        system.debug(job.Asbestos_Removal_Hours__c >0); 
        if(job.Customer_PreElectric__c== true || job.Asbestos_Removal_Hours__c >0 || complextype ||(!complextype && totalSkills>integer.valueOf(system.label.TotalSkillhours)))
        {
            complexFlag= TRUE;
        }
       
        system.debug(complextype);
        
        return complexFlag;
    }
    
    */
    public static Job__c fetchJobByJob(ID jobID) //JobInformation    
    {                      
        Job__c job = [select j.ID, j.Named_Electritian__c, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,skip_8_12_Rule__c,Squeeze_Job__c,j.S_P_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,j.Status__c,j.Sub_Status__c, Simple_Complex_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c,Asbestos_Removal_Hours__c,
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c,j.Named_Employee_2__c,j.Named_Employee_2__r.Supplier_Branch_Num__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c, Customer_PreElectric__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, j.Ecogen_Electrical_Hours__c, j.Ecogen_Mechanical_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c,j.Named_Employee__r.Supplier_Branch_Num__c,job_locked__c, j.Too_Many_Script_Statements__c, j.Landlord_Check_Hours__c,
                        j.Override_Gap_Size_Tolerance__c, j.Named_Employee__r.Resource_Type__c,Remote_Heating__c , j.ECO_Hours__c,Latest_customer_category__c, Balancing_Skill__c,
                        District__r.Contractor__c,  District__r.Contractor_Band1__c, District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                        District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c ,j.Finance_Expiry_Date__c,j.Installation_Date__c, Simple_Skills__c,
                        (select id,Week__c,Start__c,End__c,Employee_ID_18__c,Employee_Name__c,Sub_Type__c,Hours__c,Employee_ID__c from Diary_Entries__r)       
                        from Job__c j where j.ID = :jobID];
        
        return job;
    }
    
}