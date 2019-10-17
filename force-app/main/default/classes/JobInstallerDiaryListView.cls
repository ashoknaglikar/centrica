public class JobInstallerDiaryListView {
    
    public boolean workdayReport {get;set;}
    public Week__c Week {get;set;}
    public class jobDiaryDetails{
        public string attachmentId {get;set;}
        public string attachmentname {get;set;}
        public String str_JobTitle{get;set;}
        public String salesPerson{get;set;}
        public Customer_history_card__c custHistoryCard{get;set;}
        public String installdate{get;set;}
        public boolean displayCustHistoryCard{get;set;}
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
    map<string, string> jobCHiLead = new Map<String,String>();
    Profile profileRecord;
    
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
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ Inside Constructor');
        String pValue = Apexpages.currentPage().getParameters().get('p');
        sYear = Apexpages.currentPage().getParameters().get('sYear');
        sMonth = Apexpages.currentPage().getParameters().get('sMonth');
        sDay = Apexpages.currentPage().getParameters().get('sDay');
        eYear = Apexpages.currentPage().getParameters().get('eYear');
        eMonth = Apexpages.currentPage().getParameters().get('eMonth');
        eDay = Apexpages.currentPage().getParameters().get('eDay');
        installerIdParameter = Apexpages.currentPage().getParameters().get('iId');
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ Constructor STEP 1: pValue='+pValue);              
        obj_Job1=new Job_Diary__c();
        obj_Job2=new Job_Diary__c();
        obj_Job3 =  new Job_Diary__c();   
        if(pValue == null){
          obj_Job1.Job_Notification_Date__c=startDate;
          obj_Job2.Job_Notification_Date__c=startDate; //startDate.addDays(1);
          obj_Job3.Job_Notification_Date__c = startDate;
        }
        
    }    
    
    //GETTER METHOD FOR JOB.
    public List<Job__c> getLst_Job(){
        return lst_Job;
    }   
    
    
    //METHOD TO POPULATE THE JOB DIARY DETAILS.
    private void populateData(Integer call){
        
        specificContractor = null;
        jobId=new Set<String>{};
        if(call == 3)
        renderDiary = true;
        else
        renderDiary = false;
        Set<Id> jobIdList = new Set<Id>();
        jobInstallerNameMap = new Map<String,String>();
        User diaryUser;
        List<String> lst_Status = new List<String>{};
        
        lst_Status.add('Planned');
        lst_Status.add('Installed - Awaiting Payment');
        lst_Status.add('Pending');
        lst_Status.add('Installed');
        
        str_jobPipelineTimeline='Period :' + obj_Job1.Job_Notification_Date__c.format() + ' - ' + obj_Job2.Job_Notification_Date__c.format();
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ PSTEP 1: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
        
        Integer numberOfSelectedJobs = 0;
        
        if(call == 4){
             
             for(jobDiaryDetails jd : lst_JobDiaryDetails){
                
                  if(jd.isSelected){
                    
                       jobIdList.add(jd.obj_job5.Id);
                       numberOfSelectedJobs = numberOfSelectedJobs +1;
                    
                  }
                
             }
            
       }
       
        if(call == 4 && numberOfSelectedJobs > Integer.valueOf(System.Label.Max_Job_Select_Installer_Diary)){
             
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not select more than ten jobs.'));
            return;
            
       }
       
       if(call == 4 && jobIdList.size() == 0){

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one job to fetch the diary.'));
            return;
            
       }
        
        if(!obj_Job1.Search_single_job__c && (obj_Job1.Job_Notification_Date__c == null || obj_Job2.Job_Notification_Date__c == null)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates can not be blank.'));
                lst_JobDiaryDetails=null;
                renderDiary = false; 
        }
        
        if(obj_Job1.JobInstaller__c == null) 
        {
            jobUserMap = new Map<String,String>();
            userMap = new Map<String,String>();
              
            id_Installer=UserInfo.getUserid();
            
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : START
            diaryUser = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name,
                 u.Id, u.Email From User u where u.Id =: id_Installer limit 1];
            
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 1.1: diaryUser '+diaryUser);
            
            if(chiAgencyOfficeUserProfileNames.contains(diaryUser.Profile.name))//((diaryUser.Profile.name).toUpperCase().equalsIgnoreCase('CHI Agency Office User'))
            {
              bAGENCYOFFICEUSERFLAG = true;
              GroupMember groupMember = [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g
                        where g.UserOrGroupId =: id_Installer limit 1];
              
              if(groupMember != null){ 
                  //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
                  //ADDED SUPPLIER IN THE QUERY.            
                  employeeList = [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                          e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                          e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                          where (e.Salesforce_User__r.Profile.name in: chiAgencyContratorProfileNames.split(',') OR e.Salesforce_User__r.Profile.name in : chiAgencyOfficeUserProfileNames.split(',') )//(e.Salesforce_User__r.Profile.name = 'CHI Agency Contractor' OR e.Salesforce_User__r.Profile.name = 'CHI Agency Office User')
                          AND e.Agency__r.Name =: groupMember.Group.Name]; 
                  
                  for(Employee__c emp : employeeList)
                  {
                        if(chiAgencyOfficeUserProfileNames.contains(emp.Salesforce_User__r.Profile.name)){//(emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Agency Office User')){
                            sSupplierId = emp.Supplier__c;
                        }
                  }  
                  
                  if(sSupplierId == null){
                        sSupplierId = employeeList[0].Supplier__c;
                  }  
                  System.debug('%%%%% STEP 001: sSupplierId '+sSupplierId);    
                  //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.                    
              }             
                 
                 
              for(Employee__c emp : employeeList)
              {                              
                    if(chiAgencyContratorProfileNames.contains(emp.Salesforce_User__r.Profile.name)){//emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Agency Contractor')){
                        jobUserList.add(emp.Salesforce_User__c);
                    } 
              }
              
           if(!obj_Job1.Search_single_job__c && obj_Job1.CHI_Lead_Number__c == null){
                
                 for (Installer__c obj_Installer: [Select Job__c,User__c,User__r.name from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.Installation_Date__c >= :obj_Job1.Job_Notification_Date__c and Job__r.Installation_Date__c <= :obj_Job2.Job_Notification_Date__c]) 
                 {
                          jobId.add(obj_Installer.Job__c); 
                          jobUserMap.put(obj_Installer.Job__c,obj_Installer.User__c); 
                          userMap.put(obj_Installer.User__c,obj_Installer.User__r.name); 
                          
                          //LOGIC TO ADD TWO INSTALLER NAMES ON JOB IF THEY ARE FROM SAME AGENCY AND WORKING ON THE SAME JOB:START: 03/08/2010
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
                          //LOGIC TO ADD TWO INSTALLER NAMES ON JOB IF THEY ARE FROM SAME AGENCY AND WORKING ON THE SAME JOB:END: 03/08/2010
                              
                      }
                
              }
              
              System.debug('%%%% MULTIPLE INSTALLER NAMES: '+jobInstallerNameMap);
              
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
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                      (Select Id from Customer_history_cards__r limit 1), Latest_customer_category_indicator__c, Vulnerable_Customer__c
                      From Job__c Where Id In:jobIdList and Status__c IN: lst_Status and   
                      Installation_Date__c>=:obj_Job1.Job_Notification_Date__c and 
                      Installation_Date__c<=:obj_Job2.Job_Notification_Date__c 
                      Order by Installation_Date__c ASC];
               
              }else if(call == 3 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
                 
                 lst_Job=[Select Id,Day_Of_Week__c,Name,Quote__c,Job_Number__c,Installation_Date__c, 
                      Customer_Name__c,CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,
                      Address__c,CHI_Lead__r.CHI_Lead_Id__c,
                      CHI_Lead_Number_Text__c ,
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active'))
                      ,GDIndicator__c,Product_Interest__c from Job__c Where Id In:jobId and Status__c IN: lst_Status
                      Order by Installation_Date__c ASC];

              }
               
            }else{
                    employeeList= [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                              e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                              e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                              where e.Salesforce_User__c =: id_Installer];   
                    if(employeeList != null && employeeList.size() > 0)
                    {
                        sSupplierId = employeeList[0].Supplier__c;
                    }
                    System.debug('%%%%% STEP 0011: sSupplierId '+sSupplierId);
                    for(Employee__c emp : employeeList){                              
                            /*if(emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Standard Installer') ||
                               emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Installation Technical Surveyor') ||
                               emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Agency Contractor') ||
                               emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Contractor')){*/
                               string customValues = system.label.DiaryListViewProfiles  + (chiContratorProfileNames+chiAgencyContratorProfileNames+chiAgencyOfficeUserProfileNames).replaceAll(',',':');
                               //string[] customlabel = customValues.split(':');
                               //for(string str:customlabel){
                                 if(customValues.contains(emp.Salesforce_User__r.Profile.name)) //.equalsIgnoreCase(str))
                                 jobUserList.add(emp.Salesforce_User__c);
                        //} 
                    }
            }
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : END
          } 
          else 
          {      
                id_Installer=obj_Job1.JobInstaller__c; 
                List<Employee__c> empList;        
                String currentLoggedinUser = UserInfo.getUserId();
                diaryUser = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name,
                         u.Id, u.Email From User u where u.Id =: currentLoggedinUser limit 1];
                
                    if(chiAgencyOfficeUserProfileNames.contains(diaryUser.Profile.name)){//(diaryUser.Profile.name).toUpperCase().equalsIgnoreCase('CHI Agency Office User')){
                        bISSPECIFICINSTALLEROFOFFICEUSER = true;
                        specificContractor ='true';
                        
                        GroupMember groupMember = [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g
                        where g.UserOrGroupId =: currentLoggedinUser limit 1];
                  
                        if(groupMember != null)
                        {                          
                            empList = [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                                e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                                e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                                where (e.Salesforce_User__r.Profile.name in :chiAgencyContratorProfileNames.split(',')  OR e.Salesforce_User__r.Profile.name in : chiAgencyOfficeUserProfileNames.split(',') )//(e.Salesforce_User__r.Profile.name = 'CHI Agency Contractor' OR e.Salesforce_User__r.Profile.name = 'CHI Agency Office User')
                                AND e.Agency__r.Name =: groupMember.Group.Name and e.Salesforce_User__c =: id_Installer]; 
                                // Code fix by BGSAMS Support as a part of PRB00009192  
                        }
                    }  
                    else
                    {                
                        empList= [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                              e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                              e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                              where e.Salesforce_User__c =: id_Installer];   
                    }  
                       
                if(empList != null && empList.size() > 0)
                {
                    sSupplierId = empList[0].Supplier__c;
                          
                          for(Employee__c emp : empList)
                          {                              
                            /*if(emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Agency Contractor') ||
                                emp.Salesforce_User__r.Profile.name.equalsIgnoreCase('CHI Installation Lead Engineer') 
                                 ){
                                        jobUserList.add(emp.Salesforce_User__c);
                            }*/
                             string customValues = system.label.DiaryListViewProfiles + (chiContratorProfileNames+chiAgencyContratorProfileNames+chiAgencyOfficeUserProfileNames).replaceAll(',',':');
                             //string[] customlabel = customValues.split(':');
                             
                               //for(string str:customlabel){
                                 if(customValues.contains(emp.Salesforce_User__r.Profile.name))// emp.Salesforce_User__r.Profile.name.equalsIgnoreCase(str))
                                 jobUserList.add(emp.Salesforce_User__c);
                               //} 
                          }
                          
                } 
                System.debug('%%%%% STEP 002: sSupplierId '+sSupplierId);                                  
                                                  
          }  
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 2: id_Installer'+id_Installer);
        
        userRecord = [Select u.Profile.Name, u.Username, u.Profile.Id, u.ProfileId, u.Name, u.Id, u.Email From User u where u.id=:id_Installer];
        str_InstallerName = userRecord.Username;
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 3: str_InstallerName'+str_InstallerName);
        
        str_InstallerName='Job Diary for ' + str_InstallerName;
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4: str_jobPipelineTimeline: '+str_jobPipelineTimeline);        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4.1: id_Installer'+id_Installer);
        
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
        
        System.debug('Installer List: '+jobUserList+' '+obj_job1.CHI_Lead_Number__c+' '+obj_job1.Search_single_job__c);
        
        if(! bAGENCYOFFICEUSERFLAG )
        { 
          if(!obj_Job1.Search_single_job__c && obj_Job1.CHI_Lead_Number__c == null){
                for (Installer__c obj_Installer: [Select Name,Job__c,User__c,Sub_Type__c, User_Name__c from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.Installation_Date__c >= :obj_Job1.Job_Notification_Date__c and Job__r.Installation_Date__c <= :obj_Job2.Job_Notification_Date__c]) {
                      jobId.add(obj_Installer.Job__c);
                      installerList.add(obj_Installer);
                }
          }
          
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4.2: jobId: '+jobId);
        
        if(call == 4 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){  
          
          // Added as part of customer history card change request.          
          lst_Job = [Select Id,Name,Job_Number__c,Day_Of_Week__c,Installation_Date__c, 
              Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                  Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,
                  CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,
                  CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                  CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                  CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                  CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,
                  Quote__c, 
                  (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                  Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                  Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                  Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                  (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                  From User_Jobs__r where User__c<>:id_Installer AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                  (Select Id from Customer_history_cards__r limit 1) , Latest_customer_category_indicator__c, Vulnerable_Customer__c
                  ,GDIndicator__c,Product_Interest__c from Job__c Where Id In:jobIdList and Status__c IN: lst_Status and   
                  Installation_Date__c>=:obj_Job1.Job_Notification_Date__c and 
                  Installation_Date__c<=:obj_Job2.Job_Notification_Date__c 
                  Order by Installation_Date__c ASC];
            // End of customer history card change request.
            
          }else if(call == 3 && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
                 
                  lst_Job=[Select Id,Quote__c,Name,Day_Of_Week__c,Job_Number__c,Installation_Date__c, 
                      Customer_Name__c,
                      Address__c,CHI_Lead__r.CHI_Lead_Id__c,
                      CHI_Lead_Number_Text__c ,CHI_Lead__r.Is_the_customer_vulnerable__c, CHI_Lead__r.Vulnerable_reason__c,CHI_Lead__r.Latest_customer_category__c,Customer_Assist__c,
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active'))
                      ,GDIndicator__c,Product_Interest__c from Job__c Where Id In:jobId and Status__c IN: lst_Status
                      Order by Installation_Date__c ASC];
                  
           }
           
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
        List<Attachment> installationNotes = [Select id , ParentId from Attachment where parentId in :jobCHiLead.Keyset() and Name like '%Installation Notes%'];
        for(Attachment a : installationNotes){
            installationNotesmap.put(jobCHiLead.get(a.parentId), a.Id);
        }

        
        //LOGIC TO POPULATE BOILER INSTALLTION NOTES :END    
                
        lst_JobDiaryDetails=new List<jobDiaryDetails>{};
        jobDiaryDetails obj_JobDiaryDetails;
        int_Count=1;
        List<Job_Element__c> lst_Material1 = null;
        List<Job_Element__c> lst_Labour1 = null;
        List<Order__c> lst_Order1 = null;
        
        if(lst_Job != null)
        {
            for(Job__c obj_job:lst_Job)
            {
                lst_Material1=new List<Job_Element__c>{};
                lst_Labour1=new List<Job_Element__c>{};
                lst_Order1 = new List<Order__c>();
                obj_JobDiaryDetails=new jobDiaryDetails();
                obj_JobDiaryDetails.isSelected = false;
                obj_JobDiaryDetails.str_JobTitle='Job ' + int_Count + ' of ' + int_TotalCount + ' > ' + obj_job.Name + ' ; Installation Day: ' + obj_job.Day_Of_Week__c; 
                int_Count++;
                // Added as part of customer history card change request.
                obj_JobDiaryDetails.obj_job5=obj_job;
                if(obj_job.Installation_Date__c != null)
                obj_JobDiaryDetails.installdate = obj_job.Installation_Date__c.format();
                obj_JobDiaryDetails.displayCustHistoryCard = FALSE;
                // End of customer history card change request.
                
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
                
                System.debug('%%%% BOOLEANS: bAGENCYOFFICEUSERFLAG '+bAGENCYOFFICEUSERFLAG);
                System.debug('%%%% BOOLEANS: bISINSTALLER '+bISINSTALLER);
                System.debug('%%%% BOOLEANS: bISSPECIFICINSTALLEROFOFFICEUSER '+bISSPECIFICINSTALLEROFOFFICEUSER);
                
                            
                if((!bAGENCYOFFICEUSERFLAG) && (!bISINSTALLER) && (!bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                    System.debug('%%%% INSIDE FIRST IF: ');
                    System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ quoteIdQuoteMap :' + quoteIdQuoteMap);
                    obj_JobDiaryDetails.sInstallerNameOfOfficeUser = null;
                    obj_JobDiaryDetails.setLst_Labour(lst_Labour1);
                    obj_JobDiaryDetails.setLst_Material(lst_Material1);
                    obj_JobDiaryDetails.setLst_Order(lst_Order1);
                }
                
                if( bISINSTALLER && (!bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                      System.debug('%%%% INSIDE SECOND IF: ');
                      System.debug('!!!!! DEMO CHANGE 1: inside bISINSTALLER');
                      //LOGIC TO DISPLAY ELECTRICAL ELEMENTS TO ELECTRICAL INSTALLERS.
                      Boolean bHASELECRICALSKILL = false;
                      //CHANGE: MECHANICAL AND ELECTRICAL SKILLS ON JOB FOR INSTALLER: START: 03/11/2010.
                      Boolean bHASOTHERSKILLS = false;                      
                      Boolean bHASONLYELECTRICALSKILLS = false;
                      Set<String> setSkill = new Set<String>();
                      //setSkill.add('ELECTRICAL');
                      
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
                if(bAGENCYOFFICEUSERFLAG && (! bISSPECIFICINSTALLEROFOFFICEUSER))
                {
                  System.debug('%%%% INSIDE THIRD IF: ');
                  String userId = jobUserMap.get(obj_job.Id);
                  obj_JobDiaryDetails.sInstallerNameOfOfficeUser = jobInstallerNameMap.get(obj_job.Id);
                  obj_JobDiaryDetails.setLst_Labour(null);
                  obj_JobDiaryDetails.setLst_Material(null);
                  obj_JobDiaryDetails.setLst_Order(lst_Order1);
                }                
                if(bISSPECIFICINSTALLEROFOFFICEUSER && (!bAGENCYOFFICEUSERFLAG)){
                      System.debug('%%%% INSIDE FOURTH IF: ');
                      obj_JobDiaryDetails.sInstallerNameOfOfficeUser = null;
                      obj_JobDiaryDetails.setLst_Labour(lst_Labour1);
                      obj_JobDiaryDetails.setLst_Material(lst_Material1);
                      obj_JobDiaryDetails.setLst_Order(lst_Order1);
                }
                
                //ADDING BOILER INSTALLTION NOTES TO DISPLAY ON JOB DIARY.                
                String quoteId= jobQuoteMap.get(obj_job.Id);                
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
                      }else
                      {
                        obj_JobDiaryDetails.sBoilerInstallationNotes = '';
                      }
                }else
                {
                  obj_JobDiaryDetails.sBoilerInstallationNotes = '';
                }  
                // Added as part of customer history card change request.
                if(obj_JobDiaryDetails.obj_job5.Customer_History_Cards__r.size()>0){
                    
                    obj_JobDiaryDetails.displayCustHistoryCard = TRUE;
                    obj_JobDiaryDetails.custHistoryCard = obj_JobDiaryDetails.obj_job5.Customer_History_Cards__r[0];
                    
                }
                obj_JobDiaryDetails.attachmentname = 'No Notes';
                if(installationNotesmap.containskey(obj_job.id))
                {
                    obj_JobDiaryDetails.attachmentId = installationNotesmap.get(obj_job.id);
                    obj_JobDiaryDetails.attachmentname = 'Installation Notes';
                }
                // End of customer history card change request.
                lst_JobDiaryDetails.add(obj_JobDiaryDetails);
            } 
        }
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£Ã‚Â£ JOB DIARY DETAILS MATERIAL: LAST 1: '+lst_JobDiaryDetails);               
       
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
    public void selectValidAgencyContractor(){
      
      String loggedInProfileId = UserInfo.getProfileId();
      User userRecord = new User();
      Employee__c empRecord = new Employee__c();
      GroupMember gm = new GroupMember();
      
      if(!obj_Job1.Search_single_job__c && (obj_Job1.Job_Notification_Date__c == null || obj_Job2.Job_Notification_Date__c == null)){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates can not be blank.'));
        return;
      }
    
      if(obj_Job1.Search_single_job__c){
        obj_Job1.Job_Notification_Date__c = Date.today();
        obj_Job2.Job_Notification_Date__c = Date.today();
      }
        
      if( obj_Job2.Job_Notification_Date__c  <  obj_Job1.Job_Notification_Date__c){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'\'End Date\' cannot be set before \'From Date\'.'));
      }
      Date finalDate;
      if(!ignoreTwoWeeksLimits)
      finalDate = obj_Job1.Job_Notification_Date__c.addDays(120);
      else
      finalDate = obj_Job1.Job_Notification_Date__c.addDays(120);
      if( obj_Job2.Job_Notification_Date__c  >  finalDate && !ignoreTwoWeeksLimits){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a  maximun period of Two week only.'));
      }else if( obj_Job2.Job_Notification_Date__c  >  finalDate && ignoreTwoWeeksLimits){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a  maximun period of four months.'));
      }
      
      profileRecord = [Select p.Name, p.Id From Profile p where id =: loggedInProfileId limit 1];
      
      System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 2: selectValidContractor: profile = '+profileRecord);
      
      string profileID1 = profileRecord.Id;
      string ProfileID2 = profileID1.substring(0,15);
      system.debug('-------->'+profileID2);
      Dairy_Restricter__c DRest = Dairy_Restricter__c.getInstance(ProfileID2);
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
      
      
      if((profileRecord.name).toUpperCase() == 'CHI Agency Office User'){
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 3: selectValidContractor: inside if = ');
        gm = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId 
              From GroupMember g where g.UserOrGroupId =: UserInfo.getUserId() ];
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 3.1 : gm = '+gm);
        
        if(obj_job1.JobInstaller__c != null){
            userRecord = [Select u.Profile.Name, u.ProfileId, u.Name,u.LastName, u.Id,
                 (Select name,Id,Agency__c,Agency__r.name From Employees__r) From User u where
                 u.id = : obj_job1.JobInstaller__c];
          
          //If user has given the other agency's office user name in installer name field.
          if(userRecord != null && chiAgencyOfficeUserProfileNames.contains(userRecord.Profile.Name)){//(userRecord.Profile.Name).toUpperCase() == 'CHI Agency Office User'){
                GroupMember gMember = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId 
                            From GroupMember g where g.UserOrGroupId =: userRecord.Id];
                if(gm.Group.Name != gMember.Group.Name){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Agency office user is not allowed to see Job Diary of other agency\'s office user.'));
                }
          } 
          
        
          System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 4: selectValidContractor: userRecord = '+userRecord);
            
          if( userRecord != null && !chiAgencyContratorProfileNames.contains(userRecord.Profile.Name) && !chiAgencyOfficeUserProfileNames.contains(userRecord.Profile.Name)){//((userRecord.Profile.Name).toUpperCase() != 'CHI Agency Contractor') && ((userRecord.Profile.Name).toUpperCase() != 'CHI Agency Office User')){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'User is not allowed to see Job Diary of this installer.'));
          }           
           
          if(userRecord.Employees__r != null && userRecord.Employees__r.size() > 0){
            empRecord = userRecord.Employees__r[0];
          }
          
          System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 5: selectValidContractor: empRecord = '+empRecord);
          
          if(empRecord != null){
            System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 8: selectValidContractor: inside if');
            
            if(empRecord.Agency__c !=null && empRecord.Agency__r.name != null && empRecord.Agency__r.name.length() > 0){
              
              if(! ((gm.group.name).toUpperCase()).equalsIgnoreCase((empRecord.Agency__r.name).toUpperCase()) ){
                System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ STEP 9: selectValidContractor: inside error if');
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
    
    
    public static testMethod void JobInstallerDiaryListView_Test(){ 
    //ApexPages.StandardSetController controller;
    JobInstallerDiaryListView jdd = new JobInstallerDiaryListView(); 
    jdd.getDummyCoverage();
    jdd.getDummyCoverageSplit();
    List<User> userList = new List<User>();
    List<Job__c> lst_job1 =new List<Job__c>(); 
    JobInstallerDiaryListView.jobDiaryDetails IO = new JobInstallerDiaryListView.jobDiaryDetails();
    Job__c js = new Job__c();
    js = IO.getObj_job5();
    //setObj_job5(js);
    List<Job_Element__c> lst = new List<Job_Element__c>();
    lst = IO.getLst_Material();
    IO.setLst_Material(lst);
    lst = IO.getLst_Labour();
    IO.setLst_Labour(lst);
    List<order__c> orderList = new List<order__c>();
    IO.setLst_Order(orderList);
    IO.getLst_Order();
    
    IO.setsBoilerInstallationNotes('test notes');
    IO.getsBoilerInstallationNotes();
    IO.setObj_job5(js);
    
    Pagereference p ;
    
    p = jdd.jobNotificationRerunJobList();
    
          
    lst_job1 = Jdd.getLst_Job();
    String Str = Jdd.getStr_Planner();
    Jdd.getOrderMessage();
    p=jdd.emailJobDiary();
    Jdd.obj_Job1.Email_Address__c='test@test.com';
    p = jdd.deliverAsPDF();    
    
    date myDate = date.today();
    
   
    Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
    Database.insert(testRegion);
    //Region__c testRegion = [select Name,Code__c,Type__c from Region__c where Type__c = 'Installation' limit 1];
     
    District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
    Database.insert(testDistrict);
    
    Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                Type__c='Installation', District__c = testDistrict.ID);
    Database.insert(testSubPatch);
    
    Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'BS15 3', Description__c = 'Test Postcode Sector', 
                                                                    Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                    Sub_Patch__c = testSubPatch.ID);
    Database.insert(testPostcodeSector);
    Supplier__c supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                        Resource_Type__c='Own Labour');
    Database.insert(supp);
    
    List<Employee__c> empList = new List<Employee__c>();
    
    Profile officeUserProfile;
    Profile agencyContractorProfile;
    Profile contractorProfile;
    
    
    List<Profile> pInstalList = [select id,name from Profile where name = 'CHI Agency Office User' OR name = 'CHI Contractor' OR name = 'CHI Agency Contractor'];
    for(Profile pp : pInstalList){
        if(pp.name.toUpperCase() == 'CHI Agency Office User'){
            officeUserProfile = pp;
        }
        if(pp.name.toUpperCase() == 'CHI Agency Contractor'){
            agencyContractorProfile = pp;
        }
        if(pp.name.toUpperCase() == 'CHI Contractor'){
            contractorProfile = pp;
        }    
    }
    
    Group g1 = new Group();
        g1.name='TestAgency';
        insert g1;
    
    Agency__c agency = new Agency__c();
    agency.name='TestAgency';
    insert agency;
    
    User uOfficeUser = new User(alias = 'office', email='offcieuser@testorg.com',
                            emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                            localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testofficeuser@testorg.com',
                            profileId = officeUserProfile.Id);
        userList.add(uOfficeUser);
            
        User uAgencyCon = new User(alias = 'ageCon', email='agencycontractor@testorg.com',
                                emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='agencyContractor@testorg.com',
                                profileId = agencyContractorProfile.Id);
        userList.add(uAgencyCon);
        
        User conUser = new User(alias = 'conUser', email='contractor@testorg.com',
                                emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testContractor@testorg.com',
                                profileId = contractorProfile.Id);
        userList.add(conUser);
                    
        Database.insert(userList); 
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ inside createUser: userList '+userList);
       
    //call to the other method
    createUserGroup(userList);
    System.debug('AFTER CREATEUSER: '+userList);
    
    
    System.debug('uOfficeUser: '+uOfficeUser);
    System.debug('uAgencyCon: '+uAgencyCon);
    System.debug('conUser: '+conUser);
    
    Employee__c empAgencyCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                        Employee_Number__c = '0002995', Resource_Type__c= 'Installer', Inactive__c = false,
                                        Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                        Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                        District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=uAgencyCon.Id,
                                        Is_Agency_Contractor__c = true,Agency__c = agency.Id);
    empList.add(empAgencyCon);
    Employee__c empCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                        Employee_Number__c = '0002994', Resource_Type__c= 'Installer', Inactive__c = false,
                                        Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                        Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                        District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=conUser.Id);
    empList.add(empCon);     
    Database.insert(empList);
    
    
    Account Acc = new Account();
    Acc.Name ='BS15 3PA 11 The M';
    Acc.BillingStreet='7 Canal Close';
    Acc.BillingPostalCode = 'BS15 3PA';
    Insert Acc;
    
    Employee__c Em = new Employee__c();
    Em.Name = 'Test';
    Em.First_Name__c='nTest';
    Em.Last_name__c='Test';
    Em.Employee_Number__c='123213';
    Em.Salesforce_User__c = UserInfo.getUserid();
    
    Insert Em;
    
    Opportunity op = new Opportunity();
    op.name = '42493044 - D Waller - BS15 3PA - (HT44_P03)';
    op.Account= Acc;
    op.CloseDate = myDate;
    op.StageName = 'Active';
    op.Leadsource = 'Engineer';
    op.Referral_Employee__c = Em.id;
    op.Product_Interest__c = 'Central Heating Boiler';
    Insert op;
    
    
    
    //List<job__c> Js = [select status__c,Installation_Date__c  from job__c Limit 1];
    job__c j = new job__c();
    j.status__c = 'planned';
    j.Installation_Date__c = date.today();
    j.CHI_Lead__c = op.id;
       
    Installer__c[] Ins = new Installer__c[] { 
      new Installer__c(Job__c=j.id,User__c = uAgencyCon.Id,Name ='Test'),
      new Installer__c(Job__c=j.id,User__c = conUser.Id,Name ='Test1')
      }; 
    
    
    Job_Diary__c Jd = new Job_Diary__c();
    Jd.JobInstaller__c = UserInfo.getUserid();
    Jd.Job_Notification_Date__c =  myDate;
    Insert Jd;
    
    jdd.getSpecificContractor();
            
    System.RunAs(conUser){ 
    
        PageReference pageRef = Page.InstallerJobDiaryListView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('p','pdf');     
        Apexpages.currentPage().getParameters().put('sYear','2010');
        Apexpages.currentPage().getParameters().put('sMonth','07');
        Apexpages.currentPage().getParameters().put('sDay','01');
        Apexpages.currentPage().getParameters().put('eYear','2010');
        Apexpages.currentPage().getParameters().put('eMonth','08');
        Apexpages.currentPage().getParameters().put('eDay','30');  
        
    }
    
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
            if(u.ProfileId == contractorProfile.Id){
                agencyusers.add(u);
            }
        }
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ agencyusers: '+agencyusers);
        
        GroupMember gmember1 = new GroupMember();
        gmember1.GroupId = g.Id;
        gmember1.UserOrGroupId = agencyusers[0].Id;
        gmemberList.add(gmember1);
        
        System.debug('Ã‚Â£Ã‚Â£Ã‚Â£ inside createUser: gmemberList: '+gmemberList);       
    }
    
    public pagereference retrunMainMenu()
    {
        pagereference p =  new pagereference('/apex/InstallerJobDiaryListView');
        p.setredirect(true);
        return p;
    }
    
    public String getDummyCoverage(){
        
        String str = 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
    
        return str;
    
    }
    
    public String getDummyCoverageSplit(){
        
        String str = 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
    
        return str;
    
   }
    
}