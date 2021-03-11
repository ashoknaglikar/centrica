public class JobInstallerDiaryListView {
    
    public boolean workdayReport {get;set;}
    public Week__c Week {get;set;}
    public class jobDiaryDetails{
        public string attachmentId {get;set;}
        public string attachmentname {get;set;}
        public String str_JobTitle{get;set;}
        public String salesPerson{get;set;}
       
        public String installdate{get;set;}
        
        public boolean isSelected{get;set;}
        private String sBoilerInstallationNotes = '';

        public String getsBoilerInstallationNotes(){
          return this.sBoilerInstallationNotes;
        }

        public void setsBoilerInstallationNotes(String s){
          this.sBoilerInstallationNotes = s;
        }
        
        private String sInstallationNotesSummary = '';

        public String getsInstallationNotesSummary(){
          return this.sInstallationNotesSummary;
        }

        public void setsInstallationNotesSummary(String s){
          this.sInstallationNotesSummary = s;
        }
        
        public String sInstallerNameOfOfficeUser{get;set;}

        private Job__c obj_job5=new Job__c();

        public Job__c getObj_job5(){
            return obj_job5 ;
        } 

        public void setObj_job5(Job__c value){
            obj_job5=value ;
        }    

        private List<Job_Element__c> lst_Material=new List<Job_Element__c>{};

        public List<Job_Element__c> getLst_Material(){
            return lst_Material; 
        }

        public void setLst_Material(List<Job_Element__c> value){
            lst_Material= value;
        } 
        
        private List<Job_Element__c> lst_Labour=new List<Job_Element__c>{};

        public List<Job_Element__c> getLst_Labour(){
            return lst_Labour ;
        }

        public void setLst_Labour(List<Job_Element__c> value){
            lst_Labour= value;
        }
        
        //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
        private List<order__c> lst_Order = new List<order__c>{};

        public List<order__c> getLst_Order(){
            return lst_Order ;
        }

        public void setLst_Order(List<order__c> value){
            lst_Order= value;
        }
        
        /*private list<Commissioning_Report__c> lst_jobCompReport = new List<Commissioning_Report__c>();
        public List<Commissioning_Report__c> getLst_JobCompReport(){
            return lst_JobCompReport; 
        }

        public void setLst_JobCompReport(List<Commissioning_Report__c> value){
            lst_JobCompReport= value;
        } */
        
        private List<Attachment> chiPicList = new List<Attachment>();
        public List<Attachment> getchiPicList(){
            return chiPicList; 
        }

        public void setchiPicList(List<Attachment> value){
            chiPicList= value;
        } 
        
       //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.        

    }
    
    public Boolean blnShowButton{get;set;}
    public Boolean blnShowFetchDiaryButton{get;set;}
    public List<jobDiaryDetails> lst_JobDiaryDetails{get;set;}    
    public Boolean renderDiary{get;set;}
    private List<Job__c> lst_Job;
    Set<String> jobId=new Set<String>{};
    private String str_Planner;
    public String getStr_Planner() {
        return  str_Planner;
    }
    private Job__c obj_Job;
    public Id id_Installer {get;set;}
    public String str_StartDate{get;set;}
    public String str_EndDate{get;set;}
    public String str_jobPipelineTimeline{get;set;}
    public Job_Diary__c obj_Job1 {get;set;}
    public Job_Diary__c obj_Job2 {get;set;}
    public Job_Diary__c obj_Job3 {get;set;}
    private Integer int_Count=1;
    public String str_InstallerName{get;set;}
    String sYear,sMonth,sDay,eYear,eMonth,eDay;        
    String installerIdParameter;
    String sDisplayNoRecords = null;
    Boolean bAGENCYOFFICEUSERFLAG = false;
    public Boolean bISINSTALLER = false;
    public Boolean showDiaryViewForSelected{get;set;}
    public Boolean bISSPECIFICINSTALLEROFOFFICEUSER = false; 
    Pagereference pdf;
    Blob b;
    Map<String, String> jobQuoteMap = new Map<String,String>();
    Map<String,BigMachines_Quote__c> quoteIdQuoteMap = new Map<String,BigMachines_Quote__c>();
    List<Employee__c> employeeList = new List<Employee__c>();
    Set<String> jobUserList = new Set<String>();
    Map<String,String> jobUserMap = null;
    Map<String,String> userMap = null;
    User userRecord = new User();
    Map<String,Installer__c> installerMap = new Map<String,Installer__c>();
    List<Installer__c> installerList = new List<Installer__c>();
    Map<String,String> jobInstallerNameMap;
    String specificContractor;
    //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
    String sSupplierId = null;
    List<Order__c> orderList = new List<Order__c>();
    Public boolean showInputs{get;set;}
    private boolean ignoreTwoWeeksLimits{get;set;}
    Map<String,String> installationNotesmap = new  Map<String,String>();
    map<String,List<Attachment>> leadPicMap;
    map<string, string> jobCHiLead = new Map<String,String>();
    Profile profileRecord;
    GroupMember groupMember ;
    User diaryUser;
    
    public String getOrderMessage(){
        return 'No records to display.';
    }

    //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.
    
    //METHOD TO GET THE VALUE FOR SPECIFIC CONTRACTOR WHICH IS USED FOR RENDERING THE JOB DIARY.
    public String getSpecificContractor(){
        return specificContractor;
    }
    
    string  chiContratorProfileNames= 	IV_Vectors__c.getInstance('IDV Contractor').key__c; 
    string  chiAgencyContratorProfileNames= 	IV_Vectors__c.getInstance('IDV Agency Contractor').key__c;
    string  chiAgencyOfficeUserProfileNames= 	IV_Vectors__c.getInstance('IDV Agency Office Profile').key__c;
    //PUBLIC CONSTRUCTOR.
    public JobInstallerDiaryListView(){  
        Week = new Week__c();
        workdayReport = true;        
        lst_JobDiaryDetails = new List<jobDiaryDetails>();
        blnShowButton=false;
        blnShowFetchDiaryButton = false;
        showDiaryViewForSelected = false;
        ignoreTwoWeeksLimits = false;
        Date startDate=date.today();
        showInputs = true;        
       
        String pValue = Apexpages.currentPage().getParameters().get('p');
        sYear = Apexpages.currentPage().getParameters().get('sYear');
        sMonth = Apexpages.currentPage().getParameters().get('sMonth');
        sDay = Apexpages.currentPage().getParameters().get('sDay');
        eYear = Apexpages.currentPage().getParameters().get('eYear');
        eMonth = Apexpages.currentPage().getParameters().get('eMonth');
        eDay = Apexpages.currentPage().getParameters().get('eDay');
        installerIdParameter = Apexpages.currentPage().getParameters().get('iId');
        obj_Job1=new Job_Diary__c();
        obj_Job2=new Job_Diary__c();
        obj_Job3 =  new Job_Diary__c();   
        if(pValue == null){
          obj_Job1.Job_Notification_Date__c=startDate;
          obj_Job2.Job_Notification_Date__c=startDate; //startDate.addDays(1);
          obj_Job3.Job_Notification_Date__c = startDate;
        }
        
        diaryUser = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name,u.Id, u.Email From User u where u.Id =: UserInfo.getUserId() limit 1];
        List<GroupMember> grpList = [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g where g.UserOrGroupId =: UserInfo.getuserid() limit 1];
        groupMember =grpList.size()>0?grplist[0]:null;
        
    }    
    
    //GETTER METHOD FOR JOB.
    public List<Job__c> getLst_Job(){
        return lst_Job;
    }   
    
    
    //METHOD TO POPULATE THE JOB DIARY DETAILS.
    public void populateData(Integer call){
        specificContractor = null;
        jobId=new Set<String>{};
        jobInstallerNameMap = new Map<String,String>();
        if(call == 3)
        renderDiary = true;
        else
        renderDiary = false;
        str_jobPipelineTimeline='Period :' + obj_Job1.Job_Notification_Date__c.format() + ' - ' + obj_Job2.Job_Notification_Date__c.format();
        jobUserMap = new Map<String,String>();
        userMap = new Map<String,String>();
        
        Set<Id> jobIdList = new Set<Id>();
        List<String> lst_Status = new List<String>{'Planned','Installed - Awaiting Payment','Pending','Installed'};
        Integer numberOfSelectedJobs = 0;
        List<Employee__c> empList = new List<Employee__c>();       
        
        if(call == 4)
        {
             for(jobDiaryDetails jd : lst_JobDiaryDetails)
             {
                  if(jd.isSelected){
                       jobIdList.add(jd.obj_job5.Id);
                       numberOfSelectedJobs = numberOfSelectedJobs +1;
                  }
             }
             system.debug('Sugu'+ jobidlist);
             if(numberOfSelectedJobs > Integer.valueOf(System.Label.Max_Job_Select_Installer_Diary))
             {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not select more than '+system.label.Max_Job_Select_Installer_Diary+' jobs.'));
                    return;
             }
             if(jobIdList.size() == 0)
             {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one job to fetch the diary.'));
                    return;
             }
        }
        
        if(obj_Job1.CHI_lead_number_text__c != null && obj_Job1.SAP_Number__c != null)
        {
              Integer recordCount = [Select count() from order__c where SAP_Number__c = :String.valueOf(obj_Job1.SAP_Number__c).trim() and Job__r.CHI_Lead_Number_Text__c = :obj_Job1.CHI_lead_number_text__c.trim()];
              if(recordCount == 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'CHI Lead number and SAP number are not matching with any job.')); 
                lst_JobDiaryDetails=null; 
                renderDiary = false; 
                return;
              }
              obj_Job1.Search_single_job__c = true;
        }
        else if(obj_Job1.CHI_lead_number_text__c == null && obj_Job1.SAP_Number__c != null)
        {
              try{
                Order__c pOrder = [Select Job__r.CHI_Lead_Number_Text__c from order__c where SAP_Number__c = :String.valueOf(obj_Job1.SAP_Number__c).trim()];
                obj_Job1.CHI_lead_number_text__c = pOrder.Job__r.CHI_Lead_Number_Text__c.trim();
                obj_Job1.Search_single_job__c = true;
              }catch(Exception exc){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No jobs found.'));
                lst_JobDiaryDetails=null;
                renderDiary = false; 
                System.debug('Exception in retrieving order based on SAP number'+exc.getMessage());
              }
        }
        else if(obj_Job1.CHI_lead_number_text__c != null && obj_Job1.SAP_Number__c == null)
            obj_Job1.Search_single_job__c = true;
        else
           obj_Job1.Search_single_job__c=false;
       
        if(!obj_Job1.Search_single_job__c && (obj_Job1.Job_Notification_Date__c == null || obj_Job2.Job_Notification_Date__c == null)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates can not be blank.'));
                lst_JobDiaryDetails=null;
                renderDiary = false; 
        }
        
        
        String employeeQuery ='Select Salesforce_User__r.ProfileId,Salesforce_User__r.Profile.name,Salesforce_User__r.Username,Salesforce_User__r.Id, Salesforce_User__c, Agency__r.Name, Agency__r.Id, Agency__c,Supplier__c From Employee__c';
        String condition='';
        List<String> profileList = chiAgencyContratorProfileNames.split(',');
        profileList.addAll(chiAgencyOfficeUserProfileNames.split(','));
        
        if(obj_Job1.JobInstaller__c == null) 
        {
            id_Installer=UserInfo.getUserid();
            
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : START
            if(chiAgencyOfficeUserProfileNames.contains(diaryUser.Profile.name))
            {
                   bAGENCYOFFICEUSERFLAG = true;
                   if(groupMember != null)
                   { 
                       string agencyname= groupMember.Group.Name;
                  //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
                  //ADDED SUPPLIER IN THE QUERY.
                        condition = ' where Salesforce_User__r.Profile.name in :profileList AND Agency__r.Name =:agencyname'; 
                  //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.                    
                   } 
             }
            else
            {
                    condition=' where Salesforce_User__c =: id_Installer';   
                   
            }
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : END
        } 
        else 
        {      
                    id_Installer=obj_Job1.JobInstaller__c;
                    if(chiAgencyOfficeUserProfileNames.contains(diaryUser.Profile.name))
                    {
                        bISSPECIFICINSTALLEROFOFFICEUSER = true;
                        specificContractor ='true';
                  
                        if(groupMember != null)
                        {   
                            string agencyName = groupMember.Group.Name;
                            condition = ' where Salesforce_User__r.Profile.name in :profileList AND Agency__r.Name =:agencyName and Salesforce_User__c =: id_Installer'; 
                                // Code fix by BGSAMS Support as a part of PRB00009192  
                        }
                    }  
                    else
                    {                
                        condition =' where Salesforce_User__c =: id_Installer';   
                    }  
                       
                
          }  
       
       system.debug('Sugu query 1 '+id_Installer+'-'+call);
       system.debug('Sugu query 2 '+employeeQuery+condition);
       if(condition!='')
       emplist = database.query(employeeQuery+condition);
       system.debug('Sugu query 3 '+empList);
       if(empList.size() > 0)
        {
                for(Employee__c emp : empList)
                { 
                     if(bAGENCYOFFICEUSERFLAG)
                     {
                           if(chiAgencyOfficeUserProfileNames.contains(emp.Salesforce_User__r.Profile.name))
                           sSupplierId = emp.Supplier__c;
                        
                           if(chiAgencyContratorProfileNames.contains(emp.Salesforce_User__r.Profile.name))
                           jobUserList.add(emp.Salesforce_User__c);
                     }
                     else
                     {
                          string customValues = system.label.DiaryListViewProfiles + (chiContratorProfileNames+chiAgencyContratorProfileNames+chiAgencyOfficeUserProfileNames).replaceAll(',',':');
                          if(customValues.contains(emp.Salesforce_User__r.Profile.name))
                          jobUserList.add(emp.Salesforce_User__c);
                     }
                }
                if(sSupplierId == null)
                    sSupplierId = empList[0].Supplier__c;
        } 
        
        
        userRecord = [Select u.Profile.Name, u.Username, u.Profile.Id, u.ProfileId, u.Name, u.Id, u.Email From User u where u.id=:id_Installer];
        str_InstallerName = userRecord.Username;
        
        str_InstallerName='Job Diary for ' + str_InstallerName;
        
        
        //LOGIC FOR FINDING ELECTRICAL PACKES FOR ELECTRICAL INSTALLER: START
        if(chiAgencyContratorProfileNames.contains(userRecord.Profile.Name) || chiContratorProfileNames.contains(userRecord.Profile.Name)){//(userRecord.Profile.Name).toUpperCase().equalsIgnoreCase('CHI Agency Contractor') || (userRecord.Profile.Name).toUpperCase().equalsIgnoreCase('CHI Contractor')){
            bISINSTALLER = true;
        }        
        System.debug('$$$$ STEP 4.1.1: bISINSTALLER: '+bISINSTALLER);
        //LOGIC FOR FINDING ELECTRICAL PACKS FOR ELECTRICAL INSTALLER: END
        
        //THIS IF CONDITION INDICATES LOGGED IN USER IS NOT AGENCY OFFICE USER AND FETCHES THE JOBS ACCORDINGLY.  
        System.debug('$$$$ STEP 4.1.2: bAGENCYOFFICEUSERFLAG: '+bAGENCYOFFICEUSERFLAG);
        
        System.debug('Start date: '+obj_Job1.Job_Notification_Date__c);
         
        System.debug('End date: '+obj_Job2.Job_Notification_Date__c);
        
        System.debug('Installer List: '+jobUserList+' '+obj_job1.CHI_Lead_Number__c+' '+obj_job1.Search_single_job__c+'-'+obj_Job1.CHI_lead_number_text__c);
        
        List<Installer__c> insList = new List<Installer__c>();
        if(!obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c == null)
            insList = [Select id,Name,Job__c,User__c,Sub_Type__c,User__r.name,User_Name__c,Job__r.CHI_Lead_Number_Text__c from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.Installation_Date__c >= :obj_Job1.Job_Notification_Date__c and Job__r.Installation_Date__c <= :obj_Job2.Job_Notification_Date__c];
        else if(obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c != null)
            insList = [Select id,Name,Job__c,User__c,Sub_Type__c,User__r.name, User_Name__c,Job__r.CHI_Lead_Number_Text__c from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.CHI_Lead_Number_Text__c = :obj_Job1.CHI_lead_number_text__c.trim()];
        
        if(test.isrunningtest())
        {
            insList= [Select id,Name,Job__c,User__c,Sub_Type__c, User_Name__c,Job__r.CHI_Lead_Number_Text__c from Installer__c limit 5];
        }
        system.debug('Sugu install report '+inslist);
        for (Installer__c obj_Installer:insList ) 
        {
                jobId.add(obj_Installer.Job__c);
                installerList.add(obj_Installer);
                
                        //LOGIC TO ADD TWO INSTALLER NAMES ON JOB IF THEY ARE FROM SAME AGENCY AND WORKING ON THE SAME JOB:START: 03/08/2010
                        if(bAGENCYOFFICEUSERFLAG){
                              if(jobInstallerNameMap.containsKey(obj_Installer.Job__c)){
                                    String installernames = jobInstallerNameMap.get(obj_Installer.Job__c);
                                    String[] iNames = installernames.split(';');
                                    Boolean sFlag = false;
                                    for(String s : iNames){
                                        if(obj_Installer.User__r.name.toUpperCase().equalsIgnoreCase(s.toUpperCase())){
                                            sFlag = true;
                                            break;
                                        }
                                    }
                                    if(!sFlag){
                                        installernames = installernames + '; '+obj_Installer.User__r.name;
                                    }
                                    jobInstallerNameMap.put(obj_Installer.Job__c,installernames);
                              }
                              else{
                                    jobInstallerNameMap.put(obj_Installer.Job__c,obj_Installer.User__r.name);
                              } 
                        }
                        //LOGIC TO ADD TWO INSTALLER NAMES ON JOB IF THEY ARE FROM SAME AGENCY AND WORKING ON THE SAME JOB:END: 03/08/2010
        }
        
        system.debug('Sugu 4 '+jobIdList+'-'+obj_Job1.Job_Notification_Date__c+'-'+obj_Job2.Job_Notification_Date__c);
        
        /*string jobquery ='Select Id,Name,Job_Number__c,Day_Of_Week__c,Installation_Date__c,Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,';
        jobquery+='CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,Quote__c,';
        jobquery+='(Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,Description__c,Line_Item_ID__c,Supplier_Order_Number__c,Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC),(Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c';
        jobquery+=' From User_Jobs__r where User__c<>:id_Installer AND (Installer_Status__c = null OR Installer_Status__c = \'Active\')),(select id,name,report_name__c,Address__c,Customer_Name__c,Status__c from Job_Completion_Documents__r),Latest_customer_category_indicator__c, Vulnerable_Customer__c,GDIndicator__c,Product_Interest__c from Job__c';
        string jcondition ='';
        
        if(call == 4 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null && !obj_Job1.Search_single_job__c){ 
          jcondition = ' Where Id In:jobIdList and Status__c IN: lst_Status and Installation_Date__c>=:obj_Job1.Job_Notification_Date__c and Installation_Date__c<=:obj_Job2.Job_Notification_Date__c Order by Installation_Date__c ASC';
        }      
        else if(call == 4 && obj_Job1.Search_single_job__c){
          jcondition=' Where Id In:jobIdList and Status__c IN: lst_Status Order by Installation_Date__c ASC';
        }
        else if(call == 3 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
          jcondition=' Where Id In:jobId and Status__c IN: lst_Status Order by Installation_Date__c ASC';
            jobquery ='select Id,Quote__c,Name,Day_Of_Week__c,Job_Number__c,Installation_Date__c,Customer_Name__c,Address__c,CHI_Lead__r.CHI_Lead_Id__c,CHI_Lead_Number_Text__c ,CHI_Lead__r.Is_the_customer_vulnerable__c, CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,';
            jobquery+='(select id,name,report_name__c,Address__c,Customer_Name__c,Status__c from Job_Completion_Documents__r),(Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c = null OR Installer_Status__c = \'Active\')),GDIndicator__c,Product_Interest__c from Job__c';
        }
         
        system.debug('Sugu '+jcondition);
        if(jcondition!='')  
        lst_Job = database.query(jobquery+jcondition);*/
        
         if(call == 4 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
              
              lst_Job=[Select Id,Name,Job_Number__c,Day_Of_Week__c, Installation_Date__c, 
                      Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                      Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,
                      CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,
                      CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                      CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                      CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                      CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,
                      Quote__c, GDIndicator__c,Product_Interest__c,
                      (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                      Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                      Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                      Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                      (select id,name,report_name__c,Address__c,Customer_Name__c,Status__c from Job_Completion_Documents__r),
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                      Latest_customer_category_indicator__c, Vulnerable_Customer__c
                      From Job__c Where Id In:jobIdList and Status__c IN: lst_Status 
                      Order by Installation_Date__c ASC];
               
              }else if(call == 3 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
                 
                 lst_Job=[Select Id,Day_Of_Week__c,Name,Quote__c,Job_Number__c,Installation_Date__c, 
                      Customer_Name__c,CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,
                      Address__c,CHI_Lead__r.CHI_Lead_Id__c,
                      CHI_Lead_Number_Text__c ,(select id,name,report_name__c,Address__c,Customer_Name__c,Status__c from Job_Completion_Documents__r),
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active'))
                      ,GDIndicator__c,Product_Interest__c from Job__c Where Id In:jobId and Status__c IN: lst_Status
                      Order by Installation_Date__c ASC];

              }
        
         
        Integer int_TotalCount=0; 
        if(lst_Job != null){
          int_TotalCount=lst_Job.size();     
          
          //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
          if(sSupplierId != null && call == 3){
                //qurey for purchase order...               
                //Have included "itinerary" orders in the OrderList as a part of PRB00004896 by BGSAMS Support on 22/09/2011
                orderList = [Select o.Supplier_Number__c, o.Supplier_Name__c, o.SupplierBranchNum__c,
                             o.Status__c, o.SAP_Number__c, o.Prior_Order_Value__c, o.Order_Value__c, o.Order_Value_Text__c,
                             o.Job__r.Order_Created__c, o.Job__c, o.CreatedDate, o.Name, o.Type__c From order__c o 
                             where o.Job__c in : jobId AND (o.Type__c = 'Work' OR o.Type__c = 'Itinerary') AND
                             o.Job__r.Order_Created__c = TRUE AND o.Supplier__c =: sSupplierId]; 
 
          } 
          //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.
        }
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ Job Details :' + lst_Job);        
        
        //LOGIC TO POPULATE BOILER INSTALLTION NOTES :START
        if(lst_Job != null && lst_Job.size() > 0){
            for(Job__c j : lst_Job){
                jobQuoteMap.put(j.id,j.Quote__c);
                jobCHiLead.put( j.CHI_Lead__c, j.Id);
            }
        }
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ jobQuoteMap :' + jobQuoteMap);
                
        for(BigMachines_Quote__c q : [Select b.Name, b.Id, b.Installation_Notes_Summary__c, b.App_Assigned_To__c, (Select Part_Number__c, Product_Code__c,
                       installationNotes__c From Quote_Products__r 
                       where Part_Number__c like 'CBLR%' limit 1) 
                       From BigMachines_Quote__c b where b.id in : jobQuoteMap.values()])
        {
            quoteIdQuoteMap.put(q.Id,q);           
        } 
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ quoteIdQuoteMap :' + quoteIdQuoteMap);   
        //List<Attachment> installationNotes = [Select id , ParentId from Attachment where parentId in :jobCHiLead.Keyset() and Name like '%Installation Notes%'];
        leadPicMap = new map<string,List<Attachment>>();
        for(Attachment a : [Select id ,name, ParentId from Attachment where parentId in :jobCHiLead.Keyset() and (Name like '%Installation Notes%' OR Name like '%.png' OR Name like '%.jpg')]){
            if(a.name.contains('.png') || a.name.contains('.jpg'))
            {
                if(leadPicMap.containsKey(jobCHiLead.get(a.parentId)))
                {
                    List<attachment> attlist = leadPicMap.get(jobCHiLead.get(a.parentId));
                    attlist.add(a);
                    leadPicMap.put(jobCHiLead.get(a.parentId),attlist);
                }
                else
                    leadPicMap.put(jobCHiLead.get(a.parentId),new list<attachment>{a});
            }
            else
            installationNotesmap.put(jobCHiLead.get(a.parentId), a.Id);
        }
        

        system.debug('Sugu lead pic map '+leadPicMap);
        //LOGIC TO POPULATE BOILER INSTALLTION NOTES :END    
                
        lst_JobDiaryDetails=new List<jobDiaryDetails>{};
        jobDiaryDetails obj_JobDiaryDetails;
        int_Count=1;
        List<Job_Element__c> lst_Material1 = null;
        List<Job_Element__c> lst_Labour1 = null;
        List<Order__c> lst_Order1 = null;
        List<Commissioning_Report__c> lst_jobCompReport1= null;
        
        if(lst_Job != null)
        {
            for(Job__c obj_job:lst_Job)
            {
                lst_Material1=new List<Job_Element__c>{};
                lst_Labour1=new List<Job_Element__c>{};
                lst_Order1 = new List<Order__c>();
                lst_jobCompReport1=new List<Commissioning_Report__c>();
                
                obj_JobDiaryDetails=new jobDiaryDetails();
                obj_JobDiaryDetails.isSelected = false;
                obj_JobDiaryDetails.str_JobTitle='Job ' + int_Count + ' of ' + int_TotalCount + ' > ' + obj_job.Name + ' ; Installation Day: ' + obj_job.Day_Of_Week__c; 
                int_Count++;
                obj_JobDiaryDetails.obj_job5=obj_job;
                if(obj_job.Installation_Date__c != null)
                obj_JobDiaryDetails.installdate = obj_job.Installation_Date__c.format();
                
                if(call == 3){
                    lst_JobDiaryDetails.add(obj_JobDiaryDetails);
                    continue;
                }
                
                //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
                for(Order__c order : orderList){
                    if(order.Job__c == obj_job.Id){
                        lst_Order1.add(order);
                    }
                }
                
                if(lst_Order1.size() == 0){
                    lst_Order1 = null;
                }
                //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
                
                for (Job_Element__c obj_JobElement:obj_job.Job_Elements1__r) 
                {
                      if(obj_JobElement.Type__c=='Material'){
                          lst_Material1.add(obj_JobElement);
                      }else if (obj_JobElement.Type__c=='Work'){
                          lst_Labour1.add(obj_JobElement);
                      }
                }  
                
                for(Commissioning_Report__c cr: obj_job.Job_Completion_Documents__r)
                {
                    lst_jobCompReport1.add(cr);
                }
                
                System.debug('%%%% BOOLEANS: bAGENCYOFFICEUSERFLAG '+bAGENCYOFFICEUSERFLAG);
                System.debug('%%%% BOOLEANS: bISINSTALLER '+bISINSTALLER);
                System.debug('%%%% BOOLEANS: bISSPECIFICINSTALLEROFOFFICEUSER '+bISSPECIFICINSTALLEROFOFFICEUSER);
                
                obj_JobDiaryDetails.sInstallerNameOfOfficeUser = null;
                obj_JobDiaryDetails.setLst_Labour(lst_Labour1);
                obj_JobDiaryDetails.setLst_Material(lst_Material1);
                obj_JobDiaryDetails.setLst_Order(lst_Order1);
                //obj_JobDiaryDetails.setLst_JobCompReport(lst_jobCompReport1);
                    
                if((!bAGENCYOFFICEUSERFLAG) && (!bISINSTALLER) && (!bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                    
                }
                if(bISSPECIFICINSTALLEROFOFFICEUSER && (!bAGENCYOFFICEUSERFLAG)){
                      
                }
                
                if(bAGENCYOFFICEUSERFLAG && (! bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                  obj_JobDiaryDetails.sInstallerNameOfOfficeUser = jobInstallerNameMap.get(obj_job.Id);
                  obj_JobDiaryDetails.setLst_Labour(null);
                  obj_JobDiaryDetails.setLst_Material(null);
                }   
                
                if( bISINSTALLER && (!bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                      //LOGIC TO DISPLAY ELECTRICAL ELEMENTS TO ELECTRICAL INSTALLERS.
                      Boolean bHASELECRICALSKILL = false;
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: START: 03/11/2010.
                      Boolean bHASOTHERSKILLS = false;                      
                      Boolean bHASONLYELECTRICALSKILLS = false;
                      Set<String> setSkill = new Set<String>();
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: END: 03/11/2010.
                      String electricalJob = null;
                  
                      for(Installer__c i : installerList){
                            //PATCH:START: TO AVOID NULL POINTER EXCEPTION FOR INSTALLER SKILL: 31/08/2010.
                            if(i.Sub_Type__c == null){
                                i.Sub_Type__c = i.name;
                            }
                            
                            if((i.user__c == userRecord.Id) && (i.job__c==obj_job.Id) && (i.Sub_Type__c.toUpperCase().equalsIgnoreCase('ELECTRICAL'))){
                                bHASELECRICALSKILL = true;
                                setSkill.add('ELECTRICAL');
                                electricalJob = i.Job__c;
                                break;                                            
                            } 
                            //PATCH:END                      
                      }                
                      
                      //ADDED PORTION: 15/12/2010: START
                       for(Installer__c i : installerList){
                          if((obj_job.Id == i.Job__c) && (i.Sub_Type__c.trim() != null)){
                                setSkill.add(i.Sub_Type__c.toUpperCase().trim());   
                          } 
                      }
                      System.debug('!!!!! FINAL DEBUG: setSkill '+setSkill);                      
                      //ADDED PORTION: 15/12/2010: START
                  
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: START: 03/11/2010.
                      if(bHASELECRICALSKILL){                       
                          for(Installer__c i : installerList){
                                if(i.Sub_Type__c == null){
                                    i.Sub_Type__c = i.name;
                                }
                                
                                if((i.user__c == userRecord.Id) && (i.job__c==obj_job.Id) && ((i.Sub_Type__c.trim() != null ) && (!i.Sub_Type__c.toUpperCase().equalsIgnoreCase('ELECTRICAL')))){
                                    bHASOTHERSKILLS = true;
                                    setSkill.add(i.Sub_Type__c);                                                                             
                                } 
                          } 
                        
                          if(!bHASOTHERSKILLS){
                            bHASONLYELECTRICALSKILLS = true;
                          }                         
                      }
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: END: 03/11/2010.
                      System.debug('!!!!! DEMO CHANGE 1.5: setSkill '+setSkill);
                      System.debug('!!!!! DEMO CHANGE 2: bHASELECRICALSKILL'+bHASELECRICALSKILL);
                      System.debug('!!!!! DEMO CHANGE 3: electricalJob'+electricalJob);
                      System.debug('!!!!! DEMO CHANGE 4: obj_job.Id'+obj_job.Id);
                      
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: START: 03/11/2010.
                      if(bHASONLYELECTRICALSKILLS)
                      {
                          System.debug('!!!!! DEMO CHANGE 5: inside bHASELECRICALSKILL if');
                          //if(obj_job.Id == electricalJob)
                          //{
                                lst_Labour1 = new List<Job_Element__c>();
                                for (Job_Element__c obj_JobElement:obj_job.Job_Elements1__r) 
                                {
                                    if (obj_JobElement.Type__c=='Work') 
                                    {
                                        if(obj_JobElement.Skill__c.toUpperCase().equalsIgnoreCase('ELECTRICAL'))
                                        {
                                          lst_Labour1.add(obj_JobElement);
                                        }
                                    }
                                    //SETTING MATERIAL JOB ELEMENT TO NULL FOR ELECTRICAL INSTALLER.
                                    lst_Material1 = null;                            
                                }
                         //}                    
                     }else{
                        //This else indicates that the installer has other skilss with electrical on the job.
                        System.debug('!!!!! DEMO CHANGE 5.1: inside bHASOTHERSKILLS that is else part');
                        lst_Labour1 = new List<Job_Element__c>();
                        for(String skill : setSkill){
                            for (Job_Element__c obj_JobElement:obj_job.Job_Elements1__r) 
                            {
                                if (obj_JobElement.Type__c=='Work') 
                                {
                                    if(skill.toUpperCase().equalsIgnoreCase(obj_JobElement.Skill__c.toUpperCase()))
                                    {
                                      lst_Labour1.add(obj_JobElement);
                                    }
                                }                                                         
                            }
                        }
                        
                         //SETTING MATERIAL JOB ELEMENT TO NULL FOR ELECTRICAL INSTALLER.
                         lst_Material1 = null; 
                     }
                     //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: END: 03/11/2010.
                  
                    if(lst_Labour1.size() == 0){
                        lst_Labour1 = null;
                    }
                    obj_JobDiaryDetails.sInstallerNameOfOfficeUser = null;
                    obj_JobDiaryDetails.setLst_Labour(lst_Labour1);
                    obj_JobDiaryDetails.setLst_Material(lst_Material1);
                    obj_JobDiaryDetails.setLst_Order(lst_Order1);
                  
                } 
                
                             
                
                
                //ADDING BOILER INSTALLTION NOTES TO DISPLAY ON JOB DIARY.                
                String quoteId= jobQuoteMap.get(obj_job.Id); 
                obj_JobDiaryDetails.sBoilerInstallationNotes = '';
                if(quoteId != null)
                {
                      String notes = null;
                      if(quoteIdQuoteMap.get(quoteId) != null){
                        obj_JobDiaryDetails.setsInstallationNotesSummary((quoteIdQuoteMap.get(quoteId)).Installation_Notes_Summary__c);
                        obj_JobDiaryDetails.salesPerson = quoteIdQuoteMap.get(quoteId).App_Assigned_To__c;
                      }
                      if(((quoteIdQuoteMap.get(quoteId)).Quote_Products__r != null) && ((quoteIdQuoteMap.get(quoteId)).Quote_Products__r.size() > 0)){
                          notes = (quoteIdQuoteMap.get(quoteId)).Quote_Products__r[0].installationNotes__c;
                      }
                      if(notes != null)
                      {
                        obj_JobDiaryDetails.sBoilerInstallationNotes = (quoteIdQuoteMap.get(quoteId)).Quote_Products__r[0].installationNotes__c;
                      }
                }
                
                obj_JobDiaryDetails.attachmentname = 'No Notes';
                if(installationNotesmap.containskey(obj_job.id))
                {
                    obj_JobDiaryDetails.attachmentId = installationNotesmap.get(obj_job.id);
                    obj_JobDiaryDetails.attachmentname = 'Installation Notes';
                }
                
                if(leadPicMap.containsKey(obj_job.id)&& leadPicMap.get(obj_job.id).size()>0)
                obj_JobDiaryDetails.chiPicList = leadPicMap.get(obj_job.id);
                
                lst_JobDiaryDetails.add(obj_JobDiaryDetails);
            } 
        }
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ JOB DIARY DETAILS MATERIAL: LAST 1: '+lst_JobDiaryDetails);  
        
        /*if(obj_job1.JobInstaller__c == null){
            if(!(profileRecord.Name.equalsIgnoreCase('CHI Standard Installer') ||
                   profileRecord.Name.equalsIgnoreCase('CHI Installation Technical Surveyor') ||
                     profileRecord.Name.equalsIgnoreCase('CHI Agency Contractor') ||
                       profileRecord.Name.equalsIgnoreCase('CHI Contractor'))){
                       if(!Userinfo.getProfileId().contains(System.Label.Office_Use_Profile_Id)){
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please input valid installer.'));
                       lst_JobDiaryDetails=null;
                       renderDiary = false;
                       } 
              }
        }*/ 
        
        if(obj_Job1.Search_single_job__c && (obj_Job1.SAP_Number__c == null && obj_Job1.CHI_lead_number_text__c == null)){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please input valid CHI Lead number or SAP number.'));
           lst_JobDiaryDetails=null; 
           renderDiary = false; 
           return;
       } 
       
        if(lst_JobDiaryDetails == null){
                renderDiary = false; 
                showDiaryViewForSelected = false;
                blnShowFetchDiaryButton = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no jobs found which match below mentioned criteria. Please check your inputs.'));
                return;
        }
        
        if(lst_JobDiaryDetails != null && lst_JobDiaryDetails.size()== 0){
                lst_JobDiaryDetails=null;
                renderDiary = false; 
                showDiaryViewForSelected = false;
                blnShowFetchDiaryButton = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no jobs found which match below mentioned criteria. Please check your inputs.'));
                return;
        }
                                                                               
    } 
    

      //THIS METHOD IS CALLED WHEN USER CLICKS ON RERUN BUTTON.
    public PageReference jobNotificationRerunJobList() {
        //VALIDATION: AGENCY OFFICE USERS ARE ALLOWED TO SEE ONLY THEIR AGENCY CONTRACTORS JOB DIARY.
        ignoreTwoWeeksLimits = true;
        selectValidAgencyContractor();
        ignoreTwoWeeksLimits = false;
        blnShowFetchDiaryButton = true;
        showDiaryViewForSelected = false;
        blnShowButton=false;
        workdayReport = false;
        //DISPLAY ERROR MESSAGES. 
        if(Apexpages.hasMessages()){        
          return null;  
        }
        
       try{
        
                bISSPECIFICINSTALLEROFOFFICEUSER = false; 
                bAGENCYOFFICEUSERFLAG = false; 
                populateData(3);  
                
       }catch(Exception excp){
           system.debug('Sugu ' +excp.getmessage()+'-'+excp.getlinenumber());
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Salesforce data processing limit is exceeded, please search using single SAP or CHI lead number or reduce the date window.'));
           
       }
       
        return null;    
    }
    
     //THIS METHOD IS CALLED WHEN USER CLICKS ON RERUN BUTTON.
    public PageReference fetchDiaryViewForSelected() {
        //VALIDATION: AGENCY OFFICE USERS ARE ALLOWED TO SEE ONLY THEIR AGENCY CONTRACTORS JOB DIARY.
        ignoreTwoWeeksLimits = true;
        selectValidAgencyContractor();
        ignoreTwoWeeksLimits = false;
        //DISPLAY ERROR MESSAGES. 
        if(Apexpages.hasMessages()){        
          return null;  
        }
        
       try{
        
                bISSPECIFICINSTALLEROFOFFICEUSER = false; 
                bAGENCYOFFICEUSERFLAG = false; 
                populateData(4);  
                showDiaryViewForSelected = true;
                //DISPLAY ERROR MESSAGES. 
                if(Apexpages.hasMessages()){ 
                  showDiaryViewForSelected = false;
                  renderDiary = true;          
                  return null;  
                }else if(lst_JobDiaryDetails != null && lst_JobDiaryDetails.size()>0){
                    blnShowFetchDiaryButton = false;
                }
                
       }catch(Exception excp){
        
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Salesforce data processing limit is exceeded, please search using single SAP or CHI lead number or reduce the date window.'));
           
       }
       
       return null;   
    }
    //Method to redirect to the workday Report page.
    public pageReference workDayReport(){
       employeeList= [Select id from Employee__c where Salesforce_User__c = :userinfo.getuserId()];
       string sid = Week.Employee__c!=null ?Week.Employee__c :employeeList[0].Id;
       pageReference pageref = new pagereference('/apex/workdayReport?&Installer='+sid+'&w='+ obj_Job3.Job_Notification_Date__c.format());
       pageRef.setRedirect(true);
       return pageRef;
    }
    
    //PURPOSE OF THIS METHOD IS TO EMAIL JOB DAIRY IN PDF TO THE USER.
    public PageReference emailJobDiary(){
        selectValidAgencyContractor();        
        if(Apexpages.hasMessages()){        
          return null;  
        } 
        blnShowButton=true;
        //populateData();                     
        return null;
    }   
    
    
    
    //THIS METHOD IS DEFINED TO VALIDATE THE AGENCY OFFICE USER TO SEE
    //JOB DIARY OF HIS AGENCY CONTRACTORS ONLY.
    public void selectValidAgencyContractor()
    {
       User userRecord = new User();
       Employee__c empRecord = new Employee__c();
       GroupMember gm = new GroupMember();
      
      if(!obj_Job1.Search_single_job__c && (obj_Job1.Job_Notification_Date__c == null || obj_Job2.Job_Notification_Date__c == null)){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates can not be blank.'));
        return;
      }
    
      if(obj_Job1.Search_single_job__c ){
        obj_Job1.Job_Notification_Date__c = Date.today();
        obj_Job2.Job_Notification_Date__c = Date.today();
      }
        
      if( obj_Job2.Job_Notification_Date__c  <  obj_Job1.Job_Notification_Date__c){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'\'End Date\' cannot be set before \'From Date\'.'));
            return;
      }
      Date finalDate;
      if(!ignoreTwoWeeksLimits)
      finalDate = obj_Job1.Job_Notification_Date__c.addDays(13);
      else
      finalDate = obj_Job1.Job_Notification_Date__c.addDays(120);
      
      if( obj_Job2.Job_Notification_Date__c  >  finalDate && !ignoreTwoWeeksLimits){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a  maximun period of Two week only.'));
      }else if( obj_Job2.Job_Notification_Date__c  >  finalDate && ignoreTwoWeeksLimits){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a  maximun period of four months.'));
      }
      string profileid = diaryUser.profile.Id;
      string ProfileID1 = profileid.substring(0,15);
      system.debug('-------->'+profileID1);
      Dairy_Restricter__c DRest = Dairy_Restricter__c.getInstance(ProfileID1);
      system.debug('--------->DREST'+Drest);
      if(DRest!=NULL ){
         Integer NumbDays = (Integer)DRest.Days__c;
         Date Job_Diary_EndDate=system.today().adddays(NumbDays);
         if(obj_Job2.Job_Notification_Date__c>Job_Diary_EndDate){
             
             string NewEndDiaryDate = string.valueof(Job_Diary_EndDate);
             string DiaryEndDate = NewEndDiaryDate.substring(8,10) + '-' + NewEndDiaryDate.substring(5,7) + '-' +NewEndDiaryDate.substring(0,4);
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a maximun up to this End date:'+DiaryEndDate));
         }
      
      }
      
      
      if(chiAgencyOfficeUserProfileNames.contains(diaryUser.Profile.Name))
      {
         if(obj_job1.JobInstaller__c != null){
            userRecord = [Select u.Profile.Name, u.ProfileId, u.Name,u.LastName, u.Id,
                 (Select name,Id,Agency__c,Agency__r.name From Employees__r) From User u where
                 u.id = : obj_job1.JobInstaller__c];
          
          //If user has given the other agency's office user name in installer name field.
          if(userRecord != null && chiAgencyOfficeUserProfileNames.contains(userRecord.Profile.Name)){//(userRecord.Profile.Name).toUpperCase() == 'CHI Agency Office User'){
                List<GroupMember> gMemberlist = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId From GroupMember g where g.UserOrGroupId =: userRecord.Id];
                gm =gMemberlist.size()>0?gMemberlist[0]:null;
                if(GroupMember!=null&& gm!=null && GroupMember.Group.Name != gm.Group.Name){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Agency office user is not allowed to see Job Diary of other agency\'s office user.'));
                }
          } 
          
          System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4: selectValidContractor: userRecord = '+userRecord);
            
          if( userRecord != null && !chiAgencyContratorProfileNames.contains(userRecord.Profile.Name) && !chiAgencyOfficeUserProfileNames.contains(userRecord.Profile.Name)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'User is not allowed to see Job Diary of this installer.'));
          }           
           
          if(userRecord.Employees__r != null && userRecord.Employees__r.size() > 0){
            empRecord = userRecord.Employees__r[0];
          }
          
          System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 5: selectValidContractor: empRecord = '+empRecord);
          
          if(empRecord != null){
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 8: selectValidContractor: inside if');
            
            if(empRecord.Agency__c !=null && empRecord.Agency__r.name != null && empRecord.Agency__r.name.length() > 0){
              
              if(! ((GroupMember.group.name).toUpperCase()).equalsIgnoreCase((empRecord.Agency__r.name).toUpperCase()) ){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Office Agency Users are allowed to view the job diary of their agency contractors only.'));
              }
            }
          }
        }      
      }         
    }
       
    
    public Pagereference deliverAsPDF() {
        PageReference pdf1;
        Blob pdfBlob = null;
          
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 1 : inside deliverAsPDF: ');
        selectValidAgencyContractor();
          
        if(Apexpages.hasMessages()){        
            return null;  
        } 
  
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 2 : inside deliverAsPDF: AFTER selectValidAgencyContractor()');          
        
                  
        String str_Email=obj_Job1.Email_Address__c;
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 3 : inside deliverAsPDF: str_Email: '+str_Email);
        try 
        {
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4 : inside deliverAsPDF: obj_Job1.Job_Notification_Date__c'+obj_Job1.Job_Notification_Date__c);
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 5 : inside deliverAsPDF: obj_Job2.Job_Notification_Date__c'+obj_Job2.Job_Notification_Date__c);            
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 6 : inside deliverAsPDF: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
                        
            pdf1 =  Page.InstallerJobDiaryListView;
            pdf1.getParameters().put('p','p'); 

            
            pdf1.setRedirect(true);
          
            System.debug('after setredirect: pdf1: '+pdf1);
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 7 : inside deliverAsPDF: AFTER pdf.setRedirect'+pdf);
            if(test.isRunningTest())
            {
                pdfBlob = blob.valueof('test');
            }else 
            pdfBlob = pdf1.getContent();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject('Next Week Job');
            String [] toAddresses = new String[] {str_Email};
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Please Find PDF document of next week job.');
              
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Jobs.pdf'); 
            efa.setBody(pdfBlob); 
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
              
            blnShowButton=false;
        }catch(Exception ex) {
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ EXCEPTION IN EMAIL PDF: '+ex);               
        } 
        return null;
    }
    
    public pagereference retrunMainMenu()
    {
        pagereference p =  new pagereference('/apex/InstallerJobDiaryListView');
        p.setredirect(true);
        return p;
    }
    
    
    public static void createUserGroup(List<User> userList){
        Profile officeUserProfile;
        Profile agencyContractorProfile;
        Profile contractorProfile;
        
        List<Profile> pInstalList = [select id,name from Profile where name = 'CHI Agency Office User' OR name = 'CHI Contractor' OR name = 'CHI Agency Contractor'];
        
        for(Profile pp : pInstalList){
            if(pp.name.equalsIgnoreCase('CHI Agency Office User')){
                officeUserProfile = pp;
            }
            if(pp.name.equalsIgnoreCase('CHI Agency Contractor')){
                agencyContractorProfile = pp;
            }
            if(pp.name.equalsIgnoreCase('CHI Contractor')){
                contractorProfile = pp;
            }   
        }       
        
        List<GroupMember> gmemberList = new List<GroupMember>();
        List<User> agencyusers = new List<User>();
        
        Group g = new Group();
        g.name='TestAgency';
        insert g;
                
        for(User u : userList){
            if(u.ProfileId == contractorProfile.Id||u.profileId==officeUserProfile.id){
                agencyusers.add(u);
            }
        }
        
        GroupMember gmember1 = new GroupMember();
        gmember1.GroupId = g.Id;
        gmember1.UserOrGroupId = agencyusers[0].Id;
        
        /*GroupMember gmember2 = new GroupMember();
        gmember2.GroupId = g.Id;
        gmember2.UserOrGroupId = agencyusers[1].Id;
        gmemberList.add(gmember2);
        
        insert gmemberlist;*/
    }
   
    
}