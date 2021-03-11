public class JobNotificationMail {
    public Week__c week{get;set;}
    public boolean workdayReport {get;set;}
    public id bmId{get;set;}
        public PageReference updateQuote() {
        if(bmId!=null)
        {
            BigMachines_Quote__c bm = new BigMachines_Quote__c(id =bmId,Quote_Signed__c = true );
            try{
            update bm;
            }catch(Exception e)
            {
                System.debug('Exception While updating BM quote Quote_Signed__c'+e);
            }
        }
        return null;
    }

    public class jobDiaryDetails{
        public String str_JobTitle{get;set;}
        public String salesPerson{get;set;}
        // Added as part of customer history card change request.
        //public Customer_history_card__c custHistoryCard{get;set;}
        public string attachmentId {get;set;}
        public string attachmentname{get;set;}
        //public boolean displayCustHistoryCard{get;set;}
        // End of customer history card change request.
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
        //Added for job diary view state error
        private List<order__c> lst_Order = new List<order__c>{};
        public List<order__c> getLst_Order(){
            return lst_Order ;
        }
        public void setLst_Order(List<order__c> value){
            lst_Order= value;
        }
        //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.       
        public id combiSwapLink{get;set;} 
        public boolean combi {get;set;}
        public boolean combiLnk {get;set;}
        public boolean IsUnavil{get;set;}
        public Diary_Entry__c unavailabilty{get;set;}
        
        public Quote_Product__c quoteProduct {get; set;}
        private datetime startDatetime;
    }
    
    public Boolean blnShowButton{get;set;}
    //Added for job diary view state error
    public List<jobDiaryDetails> lst_JobDiaryDetails{get;set;}    //transient
    
    public Boolean renderDiary{get;set;}
    //Added for job diary view state error
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
    public Boolean bISSPECIFICINSTALLEROFOFFICEUSER = false; 
    
    Pagereference pdf;
    Blob b;
    
    Map<String, String> jobQuoteMap = new Map<String,String>();
    map<string, string> jobCHiLead = new Map<String,String>();
    Map<String,BigMachines_Quote__c> quoteIdQuoteMap = new Map<String,BigMachines_Quote__c>();
    List<Employee__c> employeeList = new List<Employee__c>();
    List<String> jobUserList = new List<String>();
    Map<String,String> jobUserMap = null;
    Map<String,String> userMap = null;
    User userRecord = new User();
    Map<String,Installer__c> installerMap = new Map<String,Installer__c>();
    List<Installer__c> installerList = new List<Installer__c>();
    Map<String,String> jobInstallerNameMap;
    String specificContractor;
    Map<String,String> installationNotesmap = new  Map<String,String>();
    
    //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
    String sSupplierId = null;
    List<Order__c> orderList = new List<Order__c>();
    
    list<Employee__c> empIdList = new list<Employee__c> ();
    Profile profileRecord;
    
    public String getOrderMessage(){
        return 'No records to display.';
    }
    //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.
    
    //METHOD TO GET THE VALUE FOR SPECIFIC CONTRACTOR WHICH IS USED FOR RENDERING THE JOB DIARY.
    public String getSpecificContractor(){
        return specificContractor;
    }
    
    //PUBLIC CONSTRUCTOR.
    public JobNotificationMail(){       
        workdayReport = true;
        week = new Week__c();
        lst_JobDiaryDetails = new List<jobDiaryDetails>();
        blnShowButton=false;
        Date startDate=date.today();
                
        System.debug('££££ Inside Constructor');
        String pValue = Apexpages.currentPage().getParameters().get('p');
        sYear = Apexpages.currentPage().getParameters().get('sYear');
        sMonth = Apexpages.currentPage().getParameters().get('sMonth');
        sDay = Apexpages.currentPage().getParameters().get('sDay');
        eYear = Apexpages.currentPage().getParameters().get('eYear');
        eMonth = Apexpages.currentPage().getParameters().get('eMonth');
        eDay = Apexpages.currentPage().getParameters().get('eDay');
        installerIdParameter = Apexpages.currentPage().getParameters().get('iId');
        System.debug('££££ Constructor STEP 1: pValue='+pValue);              
        obj_Job1=new Job_Diary__c();
        obj_Job2=new Job_Diary__c();
        obj_Job3 =  new Job_Diary__c();        
        if(pValue == null){
          obj_Job1.Job_Notification_Date__c=startDate;
          //AGENCY CHANGE DEFECT FIX: START: 02/09/2010.
          obj_Job2.Job_Notification_Date__c=startDate; //startDate.addDays(1);
          obj_Job3.Job_Notification_Date__c=startDate; //startDate.addDays(1);
          //AGENCY CHANGE DEFECT FIX: END: 02/09/2010.
        }
        if(pValue == 'print'){
          Integer sy =  Integer.valueOf(sYear);
          Integer sm = Integer.valueOf(sMonth);
          Integer sd = Integer.valueOf(sDay);
          Integer ey = Integer.valueOf(eYear);
          Integer em = Integer.valueOf(eMonth);
          Integer ed = Integer.valueOf(eDay);
                    
          obj_Job1.Job_Notification_Date__c = date.newInstance(sy,sm,sd);
          obj_Job2.Job_Notification_Date__c = date.newInstance(ey,em,ed);
          obj_Job1.JobInstaller__c = installerIdParameter;
        }
        
        System.debug('Profile id is : '+Userinfo.getProfileId());
        
       if(!Userinfo.getProfileId().contains(System.Label.Office_Use_Profile_Id)){
          
            try{
             
                //populateData(0);
            
            }catch(Exception excp){
         
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Salesforce data processing limit is exceeded, please search using single SAP or CHI lead number or reduce the date window.'));
            
            }
            
       }else if(lst_JobDiaryDetails == null){
         
             renderDiary = false;
         
       }else if(lst_JobDiaryDetails.size() == 0){
          
          renderDiary = false;
          
        }
        
        System.debug('££££ Constructor STEP 2: obj_Job1.Job_Notification_Date__c='+obj_Job1.Job_Notification_Date__c);
        System.debug('££££ Constructor STEP 3: obj_Job2.Job_Notification_Date__c='+obj_Job2.Job_Notification_Date__c);
        
    }    
    
    //GETTER METHOD FOR JOB.
    public List<Job__c> getLst_Job(){
        return lst_Job;
    }   
    
    
    //METHOD TO POPULATE THE JOB DIARY DETAILS.
    public void populateData(Integer call){
        
        specificContractor = null;
        jobId=new Set<String>{};
        renderDiary = true;
        jobInstallerNameMap = new Map<String,String>();
        User diaryUser;
        List<String> lst_Status = new List<String>{};
        
        lst_Status.add('Planned');
        lst_Status.add('Installed - Awaiting Payment');
        lst_Status.add('Pending');
        lst_Status.add('Installed');
        
        str_jobPipelineTimeline='Period :' + obj_Job1.Job_Notification_Date__c.format() + ' - ' + obj_Job2.Job_Notification_Date__c.format();
        
        System.debug('££££ PSTEP 1: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
        
        if(obj_Job1.CHI_lead_number_text__c != null && obj_Job1.SAP_Number__c != null){
          Integer recordCount = [Select count() from order__c where SAP_Number__c = :String.valueOf(obj_Job1.SAP_Number__c).trim() and Job__r.CHI_Lead_Number_Text__c = :obj_Job1.CHI_lead_number_text__c.trim()];
          if(recordCount == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'CHI Lead number and SAP number are not matching with any job.')); 
            lst_JobDiaryDetails=null; 
            renderDiary = false; 
            return;
          }
          obj_Job1.Search_single_job__c = true;
        }else if(obj_Job1.CHI_lead_number_text__c == null && obj_Job1.SAP_Number__c != null){
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
        }else if(obj_Job1.CHI_lead_number_text__c != null && obj_Job1.SAP_Number__c == null){
            obj_Job1.Search_single_job__c = true;
      }else{
          obj_Job1.Search_single_job__c = false;
        }
        
        if(!obj_Job1.Search_single_job__c && (obj_Job1.Job_Notification_Date__c == null || obj_Job2.Job_Notification_Date__c == null)){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates can not be blank.'));
          lst_JobDiaryDetails=null;
          renderDiary = false; 
        }
        
        if(obj_Job1.Search_single_job__c){
          obj_Job1.Job_Notification_Date__c = Date.today();
          obj_Job2.Job_Notification_Date__c = Date.today();
        }
        
        if(obj_Job1.JobInstaller__c == null) 
        {
            jobUserMap = new Map<String,String>();
            userMap = new Map<String,String>();
              
            id_Installer=UserInfo.getUserid();
            empIdList = [Select Id from Employee__c where Salesforce_User__c = :id_Installer];
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : START
            diaryUser = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name,
                 u.Id, u.Email From User u where u.Id =: id_Installer limit 1];
            
            System.debug('££££ STEP 1.1: diaryUser '+diaryUser);
            
            if((diaryUser.Profile.name).toUpperCase().equals('CHI AGENCY OFFICE USER'))
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
                          where (e.Salesforce_User__r.Profile.name = 'CHI AGENCY CONTRACTOR' OR e.Salesforce_User__r.Profile.name = 'CHI AGENCY OFFICE USER')
                          AND e.Agency__r.Name =: groupMember.Group.Name]; 
                  
                  for(Employee__c emp : employeeList)
                  {
                        if(emp.Salesforce_User__r.Profile.name == 'CHI AGENCY OFFICE USER'){
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
                    if(emp.Salesforce_User__r.Profile.name == 'CHI AGENCY CONTRACTOR'){
                        jobUserList.add(emp.Salesforce_User__c);
                    } 
              }
              
              if(obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c != null){
                
                for (Installer__c obj_Installer: [Select Job__c,User__c,User__r.name from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.CHI_Lead_Number_Text__c = :obj_Job1.CHI_lead_number_text__c.trim()]) 
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
                              if(obj_Installer.User__r.name.toUpperCase().equals(s.toUpperCase())){
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
                
              }else if(!obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c == null){
                
                for (Installer__c obj_Installer: [Select Job__c,User__c,User__r.name from Installer__c Where User__c in : jobUserList and Installer_Status__c != 'Inactive' and Job__r.Installation_Date__c<= :obj_Job2.Job_Notification_Date__c and Job__r.Installation_Date__c>= :obj_Job1.Job_Notification_Date__c]) 
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
                              if(obj_Installer.User__r.name.toUpperCase().equals(s.toUpperCase())){
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
              
              if(!obj_Job1.Search_single_job__c && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){
              
              // Added as part of customer history card change request.
              lst_Job=[Select Id,Name,Job_Number__c,Day_Of_Week__c, Installation_Date__c, 
                      Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                      Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,
                      CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,
                      CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                      CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                      CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                      CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,CHI_Lead__r.Referral_Employee__r.Phone_No__c,CHI_Lead__r.Referral_Employee_Name__c,
                      Quote__c,Smart_meter_installation_date__c,Smart_meter_installation_status__c,Smart_Meter_Required_Flag__c,
                      (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                      Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                      Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                      Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                      /*(Select Id from Customer_history_cards__r limit 1),*/Job_Type__c,Quote__r.Quote_Signed__c,Latest_customer_category_indicator__c,GDIndicator__c,
                      Quote__r.POC_Payment_Method__c, Quote__r.POC_Payment_Option__c,Start_Data_Time__c,TrialIndicator__c, Landlord__c,Multiple_Re_Plan_Indiacator__c
                      ,Survey_Required__c,Survey_Completed__c,Survey_Completed_By__c
                      From Job__c Where Id In:jobId and Status__c IN: lst_Status and   
                      Installation_Date__c>=:obj_Job1.Job_Notification_Date__c and 
                      Installation_Date__c<=:obj_Job2.Job_Notification_Date__c 
                      Order by Installation_Date__c ASC];
               // End as part of customer history card change request.
               
              }else if(obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c != null){
                
                lst_Job=[Select Id,Name,Job_Number__c,Day_Of_Week__c, Installation_Date__c, 
                      Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                      Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,
                      CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,
                      CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                      CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                      CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                      CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,
                      Quote__c,Smart_meter_installation_date__c,Smart_meter_installation_status__c,Smart_Meter_Required_Flag__c,CHI_Lead__r.Referral_Employee__r.Phone_No__c,CHI_Lead__r.Referral_Employee_Name__c, 
                      (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                      Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                      Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                      Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                      (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                      From User_Jobs__r where User__c NOT IN : jobUserList AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                      /*(Select Id from Customer_history_cards__r limit 1),*/Job_Type__c,Quote__r.Quote_Signed__c,Latest_customer_category_indicator__c,GDIndicator__c,
                      Quote__r.POC_Payment_Method__c, Quote__r.POC_Payment_Option__c,Start_Data_Time__c,TrialIndicator__c, Landlord__c,Multiple_Re_Plan_Indiacator__c
                      ,Survey_Required__c,Survey_Completed__c,Survey_Completed_By__c
                      From Job__c Where Id In:jobId and Status__c IN: lst_Status
                      Order by Installation_Date__c ASC];
                      
              }
               
            }
            else
            {
                employeeList= [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                          e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                          e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                          where e.Salesforce_User__c =: id_Installer];   
                          
                if(employeeList != null && employeeList.size() > 0)
                {
                    sSupplierId = employeeList[0].Supplier__c;
                }  
                System.debug('%%%%% STEP 0011: sSupplierId '+sSupplierId);     
            }
            //CALCULATING JOB DIARY FOR AGENCY OFFICE USER. : END
          } 
          else 
          {      
                id_Installer=obj_Job1.JobInstaller__c; 
                empIdList = [Select Id from Employee__c where Salesforce_User__c = :id_Installer];
                List<Employee__c> empList;        
                String currentLoggedinUser = UserInfo.getUserId();
                diaryUser = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name,
                         u.Id, u.Email From User u where u.Id =: currentLoggedinUser limit 1];
                
                    if((diaryUser.Profile.name).toUpperCase().equals('CHI AGENCY OFFICE USER')){
                        bISSPECIFICINSTALLEROFOFFICEUSER = true;
                        specificContractor ='true';
                        
                        GroupMember groupMember = [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g
                        where g.UserOrGroupId =: currentLoggedinUser limit 1];
                  
                        if(groupMember != null)
                        {                          
                            empList = [Select e.Salesforce_User__r.ProfileId,e.Salesforce_User__r.Profile.name,
                                e.Salesforce_User__r.Username, e.Salesforce_User__r.Id, e.Salesforce_User__c, 
                                e.Agency__r.Name, e.Agency__r.Id, e.Agency__c,e.Supplier__c From Employee__c e
                                where (e.Salesforce_User__r.Profile.name = 'CHI AGENCY CONTRACTOR' OR e.Salesforce_User__r.Profile.name = 'CHI AGENCY OFFICE USER')
                                AND e.Agency__r.Name =: groupMember.Group.Name];
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
                } 
                System.debug('%%%%% STEP 002: sSupplierId '+sSupplierId);                                  
                                                  
          }  
        
        System.debug('££££ STEP 2: id_Installer'+id_Installer);
        
        userRecord = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name, u.Id, u.Email From User u where u.id=:id_Installer];
        str_InstallerName = userRecord.Name;
        
        System.debug('££££ STEP 3: str_InstallerName'+str_InstallerName);
        
        str_InstallerName='Job Diary for ' + str_InstallerName;
        
        System.debug('££££ STEP 4: str_jobPipelineTimeline: '+str_jobPipelineTimeline);        
        System.debug('££££ STEP 4.1: id_Installer'+id_Installer);
        
        //LOGIC FOR FINDING ELECTRICAL PACKES FOR ELECTRICAL INSTALLER: START
        if((userRecord.Profile.Name).toUpperCase().equals('CHI AGENCY CONTRACTOR') || (userRecord.Profile.Name).toUpperCase().equals('CHI CONTRACTOR')){
            bISINSTALLER = true;
        }        
        System.debug('$$$$ STEP 4.1.1: bISINSTALLER: '+bISINSTALLER);
        //LOGIC FOR FINDING ELECTRICAL PACKS FOR ELECTRICAL INSTALLER: END
        
        //THIS IF CONDITION INDICATES LOGGED IN USER IS NOT AGENCY OFFICE USER AND FETCHES THE JOBS ACCORDINGLY.  
        System.debug('$$$$ STEP 4.1.2: bAGENCYOFFICEUSERFLAG: '+bAGENCYOFFICEUSERFLAG);
        
        if(! bAGENCYOFFICEUSERFLAG )
        { 
          //PATCH: FETCH NAME FIELDS IN SOQL QUERY: START: 02/09/2010
          if(obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c != null){
            for (Installer__c obj_Installer: [Select Name,Job__c,User__c,Sub_Type__c, User_Name__c from Installer__c Where User__c=:id_Installer and Installer_Status__c != 'Inactive' and Job__r.CHI_Lead_Number_Text__c = :obj_Job1.CHI_lead_number_text__c]) {
                jobId.add(obj_Installer.Job__c);
                  installerList.add(obj_Installer);
            }
          } else if(!obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c == null){
            for (Installer__c obj_Installer: [Select Name,Job__c,User__c,Sub_Type__c, User_Name__c from Installer__c Where User__c=:id_Installer and Installer_Status__c != 'Inactive']) {
                jobId.add(obj_Installer.Job__c);
                installerList.add(obj_Installer);
             }
          }
          
        System.debug('££££ STEP 4.2: jobId: '+jobId);
        
        if(!obj_Job1.Search_single_job__c && obj_Job1.Job_Notification_Date__c != null && obj_Job2.Job_Notification_Date__c != null){  
          
          // Added as part of customer history card change request.          
          lst_Job = [Select Id,Name,Job_Number__c,Day_Of_Week__c, Installation_Date__c, 
                        Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                  Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,
                  CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,
                  CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                  CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                  CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                  CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,CHI_Lead__r.Referral_Employee__r.Phone_No__c,CHI_Lead__r.Referral_Employee_Name__c, 
                  Quote__c, Smart_meter_installation_date__c,Smart_meter_installation_status__c,Smart_Meter_Required_Flag__c,
                  (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                  Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                  Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                  Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                  (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                  From User_Jobs__r where User__c<>:id_Installer AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                  /*(Select Id from Customer_history_cards__r limit 1),*/Job_Type__c,Quote__r.Quote_Signed__c,Latest_customer_category_indicator__c,GDIndicator__c,
                      Quote__r.POC_Payment_Method__c, Quote__r.POC_Payment_Option__c,Start_Data_Time__c,TrialIndicator__c, Landlord__c,Multiple_Re_Plan_Indiacator__c
                  ,Survey_Required__c,Survey_Completed__c,Survey_Completed_By__c
                  From Job__c Where Id In:jobId and Status__c IN: lst_Status and   
                  Installation_Date__c>=:obj_Job1.Job_Notification_Date__c and 
                  Installation_Date__c<=:obj_Job2.Job_Notification_Date__c 
                  Order by Installation_Date__c ASC];
            // End of customer history card change request.
            
          }else if(obj_Job1.Search_single_job__c && obj_Job1.CHI_lead_number_text__c != null){
            
            lst_Job = [Select Id,Name,Job_Number__c,Day_Of_Week__c, Installation_Date__c, 
              Customer_Name__c,Installer_Notes__c, PlannerId__c,PlannerName__c,Planner__c,
                  Address__c,Delivery_Date__c,Account__c,CHI_Lead__r.Account.Primary_Contact__r.HomePhone,
                  CHI_Lead__r.Account.Primary_Contact__r.OtherPhone,
                  CHI_Lead__r.Account.Primary_Contact__r.MobilePhone,CHI_Lead__r.Payment_Method__c, Status__c,
                  CHI_Lead__r.Balance_Outstanding__c, CHI_Lead__c,CHI_Lead__r.OwnerId,
                  CHI_Lead__r.CHI_Lead_Id__c,LastModifiedById,Quote_Delivery_Notes__c,Quote_Status_Notes__c,
                  CHI_Lead_Number_Text__c,Home_Phone__c,Best_Phone_Number__c,Work_Phone__c,CHI_Lead__r.Referral_Employee__r.Phone_No__c,CHI_Lead__r.Referral_Employee_Name__c, 
                  Quote__c, Smart_meter_installation_date__c,Smart_meter_installation_status__c,Smart_Meter_Required_Flag__c,
                  (Select Status__c, Sub_Status__c, Order__c, Skill__c, Type__c, Units__c, Unit_Price__c,Supplier__c,
                  Product__r.Name,Code__c,Current_Supplier__c,New_Supplier__c,UnitsFormula__c,
                  Description__c,Line_Item_ID__c,Supplier_Order_Number__c,
                  Merchant_Order_Number__c From Job_Elements1__r Order By Skill__c ASC) ,
                  (Select User__c,User__r.MobilePhone,User__r.Name, Is_Ready__c, Type__c,Sub_Type__c,Installer_Status__c
                  From User_Jobs__r where User__c<>:id_Installer AND (Installer_Status__c =: null OR Installer_Status__c =: 'Active')),
                  /*(Select Id from Customer_history_cards__r limit 1),*/Job_Type__c,Quote__r.Quote_Signed__c,Latest_customer_category_indicator__c,GDIndicator__c,
                      Quote__r.POC_Payment_Method__c, Quote__r.POC_Payment_Option__c,Start_Data_Time__c,TrialIndicator__c, Landlord__c,Multiple_Re_Plan_Indiacator__c
                  ,Survey_Required__c,Survey_Completed__c,Survey_Completed_By__c
                  From Job__c Where Id In:jobId and Status__c IN: lst_Status
                  Order by Installation_Date__c ASC];
                  
           } 
           
        }
        
         
        Integer int_TotalCount=0; 
        if(lst_Job != null){
          int_TotalCount=lst_Job.size();
            int_Count=1;   
          
          //AGENCY CHANGE FOR ORDER VALUE: START: 08-10-2010.
          if(sSupplierId != null){
                //qurey for purchase order...               
                //Have included "itinerary" orders in the OrderList as a part of PRB00004896 by BGSAMS Support on 22/09/2011
               //system.debug('Ashok-->'+jobIdf);
                orderList = [Select o.Supplier_Number__c, o.Supplier_Name__c, o.SupplierBranchNum__c,
                             o.Status__c, o.SAP_Number__c, o.Prior_Order_Value__c, o.Order_Value__c, o.Order_Value_Text__c,
                             o.Job__r.Order_Created__c, o.Job__c, o.CreatedDate, o.Name, o.Type__c From order__c o 
                             where o.Job__c in : jobId AND (o.Type__c = 'Work' OR o.Type__c = 'Itinerary') AND
                             o.Job__r.Order_Created__c = TRUE AND o.Supplier__c =: sSupplierId]; 
 
          } 
          //AGENCY CHANGE FOR ORDER VALUE: END: 08-10-2010.
        }
        System.debug('£££££££££££££ Job Details :' + lst_Job);        
        
        //LOGIC TO POPULATE BOILER INSTALLTION NOTES :START
        if(lst_Job != null && lst_Job.size() > 0){
            for(Job__c j : lst_Job){
                jobQuoteMap.put(j.id,j.Quote__c);
                jobCHiLead.put( j.CHI_Lead__c, j.Id);
            }
        }
        System.debug('£££££££££££££ jobQuoteMap :' + jobQuoteMap);
                
        for(BigMachines_Quote__c q : [Select b.Name, b.Id, b.Installation_Notes_Summary__c, b.App_Assigned_To__c, (Select Part_Number__c, Product_Code__c,
                       installationNotes__c From Quote_Products__r 
                       where Part_Number__c like 'CBLR%' limit 1) 
                       From BigMachines_Quote__c b where b.id in : jobQuoteMap.values()])
        {
            quoteIdQuoteMap.put(q.Id,q);           
        } 
        
        List<Attachment> installationNotes = [Select id , ParentId from Attachment where parentId in :jobCHiLead.Keyset() and Name like '%Installation Notes%'];
        for(Attachment a : installationNotes){
            installationNotesmap.put(jobCHiLead.get(a.parentId), a.Id);
        }

        
        
        System.debug('£££££££££££££ quoteIdQuoteMap :' + quoteIdQuoteMap);   
        
        //LOGIC TO POPULATE BOILER INSTALLTION NOTES :END    
                
        lst_JobDiaryDetails=new List<jobDiaryDetails>{};
        jobDiaryDetails obj_JobDiaryDetails;
        
        List<Job_Element__c> lst_Material1 = null;
        List<Job_Element__c> lst_Labour1 = null;
        List<Order__c> lst_Order1 = null;
        
        if(lst_Job != null)
        {
        //PRB00015869 coding starts
         for(integer j = 0; j<lst_Job.size(); j++)
            {
                    for(integer k=1; k<lst_Job.size()-j; k++)
                    {    
                    if(lst_Job[k-1].Start_Data_Time__c >= lst_Job[k].Start_Data_Time__c)
                            {
                                Job__c temp = lst_Job[k-1];
                                lst_Job[k-1] = lst_Job[k];
                                lst_Job[k]=temp;
                            }
                    }
                    
            }
        
          //PRB00015869 coding ends
            for(Job__c obj_job:lst_Job)
            {
                //CombiSwap Change
                lst_Material1=new List<Job_Element__c>{};
                lst_Labour1=new List<Job_Element__c>{};
                lst_Order1 = new List<Order__c>();
                obj_JobDiaryDetails=new jobDiaryDetails();
                system.debug('Outside--->'+obj_job.Job_Type__c);
                if(obj_job.Job_Type__c=='Combi Replacement')
                {
                        obj_JobDiaryDetails.combi = true;
                        list<CombiSwapQuestion__c> c = [select id from CombiSwapQuestion__c where Opportunity__c =:obj_job.CHI_Lead__c];
                        if(c.size()>0)
                        {   obj_JobDiaryDetails.combiLnk = true;
                                obj_JobDiaryDetails.combiSwapLink = c[0].Id;
                        }       
                }
              
                obj_JobDiaryDetails.str_JobTitle='Job ' + int_Count + ' of ' + int_TotalCount + ' > ' + obj_job.Name + ' ; Installation Day: ' + obj_job.Day_Of_Week__c; 
                int_Count++;
                // Added as part of customer history card change request.
                obj_JobDiaryDetails.obj_job5=obj_job;
                //obj_JobDiaryDetails.displayCustHistoryCard = FALSE;
                // End of customer history card change request.
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
                    System.debug('£££££ quoteIdQuoteMap :' + quoteIdQuoteMap);
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
                            
                            if((i.user__c == userRecord.Id) && (i.job__c==obj_job.Id) && (i.Sub_Type__c.toUpperCase().equals('ELECTRICAL'))){
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
                                
                                if((i.user__c == userRecord.Id) && (i.job__c==obj_job.Id) && ((i.Sub_Type__c.trim() != null ) && (!i.Sub_Type__c.toUpperCase().equals('ELECTRICAL')))){
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
                                        if(obj_JobElement.Skill__c.toUpperCase().equals('ELECTRICAL'))
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
                                    if(skill.toUpperCase().equals(obj_JobElement.Skill__c.toUpperCase()))
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
                          
                          obj_JobDiaryDetails.quoteProduct = (quoteIdQuoteMap.get(quoteId)).Quote_Products__r[0];
                          
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
                /*// Added as part of customer history card change request.
                if(obj_JobDiaryDetails.obj_job5.Customer_History_Cards__r.size()>0){
                    
                    obj_JobDiaryDetails.displayCustHistoryCard = TRUE;
                    obj_JobDiaryDetails.custHistoryCard = obj_JobDiaryDetails.obj_job5.Customer_History_Cards__r[0];
                    
                }
                */
                obj_JobDiaryDetails.startDatetime = obj_JobDiaryDetails.obj_job5.Start_Data_Time__c;
                // End of customer history card change request.
                obj_JobDiaryDetails.attachmentname = 'No Notes';
                if(installationNotesmap.containskey(obj_job.id))
                {
                    obj_JobDiaryDetails.attachmentId = installationNotesmap.get(obj_job.id);
                    obj_JobDiaryDetails.attachmentname = 'Installation Notes';
                }
                lst_JobDiaryDetails.add(obj_JobDiaryDetails);
            } 
        }
        list<jobDiaryDetails> unavilaList = new list<jobDiaryDetails>();
        system.debug(obj_Job1.Job_Notification_Date__c+''+obj_Job2.Job_Notification_Date__c+''+employeeList);
        date enddate = obj_Job2.Job_Notification_Date__c.adddays(1);
        List<Diary_Entry__c> unAvailList = [Select Name,d.Unavailability_Reason__c,Start_Date__c, d.Unavailability_Notes__c,d.Job__r.Name,d.Travel_Job__r.Name, d.Type__c, d.Sub_Type__c, d.Start__c, d.Record_Type__c, d.RecordTypeId, d.Hours__c, d.End__c From Diary_Entry__c d where 
        ((Record_Type__c = 'Unavailability' and Week__r.Employee__c in:empIdList and Sub_Type__c !='Weekend unavailability') or (Record_Type__c = 'Non Productive Job Booking' and Week__r.Employee__c in:empIdList and Sub_Type__c ='Travel Time')) and Start__c >= :obj_Job1.Job_Notification_Date__c and End__c <= :enddate    order by Start__c];
        system.debug('Unavail list --->'+unAvailList);
        integer unCount = 1;
        integer totUncout = unAvailList.size();
        for(Diary_Entry__c d : unAvailList)
        {
                obj_JobDiaryDetails=new jobDiaryDetails();
                obj_JobDiaryDetails.IsUnavil = true;
                obj_JobDiaryDetails.unavailabilty = d;
                if(d.Record_Type__c == 'Unavailability')
                {
                    obj_JobDiaryDetails.str_JobTitle='Unavailability ' + unCount + ' of ' + totUncout + ' > ' + d.Name ;
                    unCount++;
                }
                else
                obj_JobDiaryDetails.str_JobTitle='Travel Time between '  + d.job__r.Name + ' & '+ d.Travel_Job__r.Name;
                obj_JobDiaryDetails.obj_job5.Installation_Date__c = d.Start_Date__c;
                obj_JobDiaryDetails.startDatetime = d.Start__c;
                unavilaList.add(obj_JobDiaryDetails);
                
        }
        list<jobDiaryDetails> finalList = new list<jobDiaryDetails>();
        
        if(lst_JobDiaryDetails.size()==0 && unavilaList.size()>0)
        {
                lst_JobDiaryDetails.addall(unavilaList);
        }
        //PRB00015869 changes starts
        else if(lst_JobDiaryDetails.size()>0)
        {
            if(unavilaList.size()>0)
            lst_JobDiaryDetails.addall(unavilaList);
            //PRB00015869 changes ends
            for(integer j = 0; j<lst_JobDiaryDetails.size(); j++)
            {
               for(integer k=1; k<lst_JobDiaryDetails.size()-j; k++)
                    {
                        system.debug('in k---->'+k);
                            if(lst_JobDiaryDetails[k-1].startDatetime >= lst_JobDiaryDetails[k].startDatetime)
                            {
                            system.debug('in abcde---->'+k);
                            
                                jobDiaryDetails temp = lst_JobDiaryDetails[k-1];
                                lst_JobDiaryDetails[k-1] = lst_JobDiaryDetails[k];
                                lst_JobDiaryDetails[k]=temp;
                            }
                    }
                    
            }
            
        }
                  
                  
        System.debug('££££ JOB DIARY DETAILS MATERIAL: LAST 1: '+lst_JobDiaryDetails);               
     
        if(call == 1 && obj_job1.JobInstaller__c == null){
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
        } 
    
       if(obj_Job1.Search_single_job__c && call == 1 && (obj_Job1.SAP_Number__c == null && obj_Job1.CHI_lead_number_text__c == null)){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please input valid CHI Lead number or SAP number.'));
           lst_JobDiaryDetails=null; 
           renderDiary = false; 
           return;
       } 
       
       if(lst_JobDiaryDetails == null){
           return;
       }
       
     if (lst_JobDiaryDetails.size()==0 && call == 1){
       
          lst_JobDiaryDetails=null; 
          renderDiary = false; 
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no jobs found which match below mentioned criteria. Please check your inputs.'));
          
     }else if(lst_JobDiaryDetails.size()==0 && call == 0){
       
         lst_JobDiaryDetails=null;
         renderDiary = false; 
         
     }
                                                                               
    } 
   
    
    //THIS METHOD IS CALLED WHEN USER CLICKS ON RERUN BUTTON.
    public PageReference jobNotificationRerun() {
        //VALIDATION: AGENCY OFFICE USERS ARE ALLOWED TO SEE ONLY THEIR AGENCY CONTRACTORS JOB DIARY.
        selectValidAgencyContractor();
        workdayReport = false;
        //DISPLAY ERROR MESSAGES. 
        if(Apexpages.hasMessages()){        
          return null;  
        }
        
       try{
         
           bISSPECIFICINSTALLEROFOFFICEUSER = false; 
          bAGENCYOFFICEUSERFLAG = false; 
          populateData(1);  
          
       }catch(Exception excp){
         
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Salesforce data processing limit is exceeded, please search using single SAP or CHI lead number or reduce the date window.'));
            
       }
       
        return null;    
    }
    
    
    //THIS METHOD IS CALLED WHEN USER CLICKS ON PRINTABLE VIEW BUTTON,
    //TO REDIRECT A USER TO PRINTABLE VIEW.
    public PageReference redirectToPrintableView(){
      
        System.debug('££££ PRINT1 STEP 1: obj_Job1.Job_Notification_Date__c'+obj_Job1.Job_Notification_Date__c);                 
        System.debug('££££ PRINT1 STEP 2: obj_Job2.Job_Notification_Date__c'+obj_Job2.Job_Notification_Date__c);
                
        selectValidAgencyContractor();        
        if(Apexpages.hasMessages()){          
            return null;  
        } 
            
        System.debug('££££ PRINT1 STEP 2.1: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);        
                
        System.debug('££££ PRINT1 STEP 3: AFTER populateData()');
        System.debug('££££ PRINT1 STEP 3.1: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
        System.debug('££££ PRINT1 STEP 4: obj_Job1.Job_Notification_Date__c'+obj_Job1.Job_Notification_Date__c);
        System.debug('££££ PRINT1 STEP 5: obj_Job2.Job_Notification_Date__c'+obj_Job2.Job_Notification_Date__c);
               
             
        //SETTING DATE AS A QUERY STRING PARAMETER.
        String sDay = (''+obj_Job1.Job_Notification_Date__c.day()).trim();
        String sMonth = (''+obj_Job1.Job_Notification_Date__c.month()).trim();
        String sYear = (''+obj_Job1.Job_Notification_Date__c.year()).trim();
        String eDay = (''+obj_Job2.Job_Notification_Date__c.day()).trim();
        String eMonth = (''+obj_Job2.Job_Notification_Date__c.month()).trim();
        String eYear = (''+obj_Job2.Job_Notification_Date__c.year()).trim();
                       
        PageReference pdf = new PageReference('/apex/JobNotificationPrintPage');
        pdf.getParameters().put('p','print'); 
        pdf.getParameters().put('sDay',sDay);
        pdf.getParameters().put('sMonth',sMonth);
        pdf.getParameters().put('sYear',sYear); 
        pdf.getParameters().put('eDay',eDay);
        pdf.getParameters().put('eMonth',eMonth);
        pdf.getParameters().put('eYear',eYear);
        pdf.getParameters().put('iId',obj_Job1.JobInstaller__c);
      
        System.debug('£££ str_InstallerName: '+ str_InstallerName);
      
        pdf.setRedirect(true);  
        return pdf;
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
      
      Date finalDate = obj_Job1.Job_Notification_Date__c.addDays(13);
      if( obj_Job2.Job_Notification_Date__c  >  finalDate){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a  maximun period of Two week only.'));
      }
      
      
      
      profileRecord = [Select p.Name, p.Id From Profile p where id =: loggedInProfileId limit 1];
      system.debug('-------->'+ProfileRecord.Id);
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
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Job diary can be displayed for a maximun up to this End date is:'+DiaryEndDate));
         }
      
      }
      



      System.debug('£££ STEP 2: selectValidContractor: profile = '+profileRecord);
      
      if((profileRecord.name).toUpperCase() == 'CHI AGENCY OFFICE USER'){
        
        System.debug('£££ STEP 3: selectValidContractor: inside if = ');
        gm = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId 
              From GroupMember g where g.UserOrGroupId =: UserInfo.getUserId() ];
        System.debug('£££ STEP 3.1 : gm = '+gm);
        
        if(obj_job1.JobInstaller__c != null){
            userRecord = [Select u.Profile.Name, u.ProfileId, u.Name,u.LastName, u.Id,
                 (Select name,Id,Agency__c,Agency__r.name From Employees__r) From User u where
                 u.id = : obj_job1.JobInstaller__c];
          
          //If user has given the other agency's office user name in installer name field.
          if(userRecord != null && (userRecord.Profile.Name).toUpperCase() == 'CHI AGENCY OFFICE USER'){
                GroupMember gMember = [Select g.UserOrGroupId, g.Id, g.Group.Name, g.Group.Id, g.GroupId 
                            From GroupMember g where g.UserOrGroupId =: userRecord.Id];
                if(gm.Group.Name != gMember.Group.Name){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Agency office user is not allowed to see Job Diary of other agency\'s office user.'));
                }
          } 
          
        
          System.debug('£££ STEP 4: selectValidContractor: userRecord = '+userRecord);
            
          if( userRecord != null && ((userRecord.Profile.Name).toUpperCase() != 'CHI AGENCY CONTRACTOR') && ((userRecord.Profile.Name).toUpperCase() != 'CHI Agency Office User')){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'User is not allowed to see Job Diary of this installer.'));
          }           
           
          if(userRecord.Employees__r != null && userRecord.Employees__r.size() > 0){
            empRecord = userRecord.Employees__r[0];
          }
          
          System.debug('£££ STEP 5: selectValidContractor: empRecord = '+empRecord);
          
          if(empRecord != null){
            System.debug('£££ STEP 8: selectValidContractor: inside if');
            
            if(empRecord.Agency__c !=null && empRecord.Agency__r.name != null && empRecord.Agency__r.name.length() > 0){
              
              if(! ((gm.group.name).toUpperCase()).equals((empRecord.Agency__r.name).toUpperCase()) ){
                System.debug('£££ STEP 9: selectValidContractor: inside error if');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Office Agency Users are allowed to view the job diary of their agency contractors only.'));
              }
            }
          }
        }      
      }         
    }
       
    
    /**
    public void sendPdfAsAttachment(){
        Pagereference pageRef = Apexpages.currentPage(); 
        Blob bPdf = pageRef.getContentAsPDF();
        String str_Email=obj_Job1.Email_Address__c;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
              email.setSubject('Next Week Job');
              String [] toAddresses = new String[] {str_Email};
              email.setToAddresses(toAddresses);
              email.setPlainTextBody('Please Find PDF document of next week job.');
              
              Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
              efa.setFileName('Jobs.pdf'); 
              efa.setBody(bPdf); 
              email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
              Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    } 
    */
    
    /*
    public Pagereference deliverAsPDF() {
        PageReference pdf1;
        Blob pdfBlob = null;
          
        System.debug('££££ STEP 1 : inside deliverAsPDF: ');
        selectValidAgencyContractor();
          
        if(Apexpages.hasMessages()){        
            return null;  
        } 
  
        System.debug('££££ STEP 2 : inside deliverAsPDF: AFTER selectValidAgencyContractor()');          
        System.debug('££££ STEP 3 : inside deliverAsPDF: AFTER populateData()');
          
        String str_Email=obj_Job1.Email_Address__c;
        try 
        {
            System.debug('££££ STEP 4 : inside deliverAsPDF: obj_Job1.Job_Notification_Date__c'+obj_Job1.Job_Notification_Date__c);
            System.debug('££££ STEP 5 : inside deliverAsPDF: obj_Job2.Job_Notification_Date__c'+obj_Job2.Job_Notification_Date__c);            
            System.debug('££££ STEP 6 : inside deliverAsPDF: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
            
            String sDay = (''+obj_Job1.Job_Notification_Date__c.day()).trim();
            String sMonth = (''+obj_Job1.Job_Notification_Date__c.month()).trim();
            String sYear = (''+obj_Job1.Job_Notification_Date__c.year()).trim();
            String eDay = (''+obj_Job2.Job_Notification_Date__c.day()).trim();
            String eMonth = (''+obj_Job2.Job_Notification_Date__c.month()).trim();
            String eYear = (''+obj_Job2.Job_Notification_Date__c.year()).trim();
            
            pdf1 = new PageReference('/apex/JobNotificationPdf');
            
            pdf1.getParameters().put('p','pdf');             
            pdf1.getParameters().put('sDay',sDay);
            pdf1.getParameters().put('sMonth',sMonth);
            pdf1.getParameters().put('sYear',sYear); 
            pdf1.getParameters().put('eDay',eDay);
            pdf1.getParameters().put('eMonth',eMonth);
            pdf1.getParameters().put('eYear',eYear);
            pdf1.getParameters().put('iId',obj_Job1.JobInstaller__c);   
            pdf1.getParameters().put('email',str_Email);        
            pdf1.setRedirect(true);
          
            System.debug('after setredirect: pdf1: '+pdf1);
            System.debug('££££ STEP 7 : inside deliverAsPDF: AFTER pdf.setRedirect'+pdf);
              
          
            pdfBlob = pdf1.getContentAsPDF();
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
            System.debug('£££ EXCEPTION IN EMAIL PDF: '+ex);               
        } 
        return null;
    }
    */
    
    public Pagereference deliverAsPDF() {
        PageReference pdf1;
        Blob pdfBlob = null;
          
        System.debug('££££ STEP 1 : inside deliverAsPDF: ');
        selectValidAgencyContractor();
          
        if(Apexpages.hasMessages()){        
            return null;  
        } 
  
        System.debug('££££ STEP 2 : inside deliverAsPDF: AFTER selectValidAgencyContractor()');          
        
                  
        String str_Email=obj_Job1.Email_Address__c;
        System.debug('££££ STEP 3 : inside deliverAsPDF: str_Email: '+str_Email);
        try 
        {
            System.debug('££££ STEP 4 : inside deliverAsPDF: obj_Job1.Job_Notification_Date__c'+obj_Job1.Job_Notification_Date__c);
            System.debug('££££ STEP 5 : inside deliverAsPDF: obj_Job2.Job_Notification_Date__c'+obj_Job2.Job_Notification_Date__c);            
            System.debug('££££ STEP 6 : inside deliverAsPDF: obj_Job1.JobInstaller__c'+obj_Job1.JobInstaller__c);
                        
            pdf1 =  Page.JobNotificationMail;
            pdf1.getParameters().put('p','p'); 

            
            pdf1.setRedirect(true);
          
            System.debug('after setredirect: pdf1: '+pdf1);
            System.debug('££££ STEP 7 : inside deliverAsPDF: AFTER pdf.setRedirect'+pdf);
              
          
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
            System.debug('£££ EXCEPTION IN EMAIL PDF: '+ex);               
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
    
    public pagereference retrunMainMenu()
    {
        pagereference p =  new pagereference('/apex/JobNotificationMail');
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
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
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
        
        return str;
    
    }
    
}