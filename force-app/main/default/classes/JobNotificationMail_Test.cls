@isTest

public class JobNotificationMail_Test{
        static Account Acc;
        static Opportunity op;
        static BigMachines_Quote__c bm;      
        static Region__c testRegion;
        static District__c testDistrict;
        static Sub_Patch__c testSubPatch;
        static Postcode_Sector__c testPostcodeSector;
        static Supplier__c supp;      
        static List<User> userList = new List<user>();
        static List<Profile> pInstalList = new List<Profile>();
        static List<Employee__c> empList = new List<Employee__c>();
        static Profile officeUserProfile;
        static Profile agencyContractorProfile;
        static Profile contractorProfile;
        static Group g1;
        static Agency__c agency;
        static User uOfficeUser,uAgencyCon,conUser;
        static Employee__c empAgencyCon,empCon,Em;
        static job__c j;
        static Installer__c[] Ins;
        static Job_Diary__c Jd;      
         
        public static void createUserGroup(List<User> userListTemp){      
            
            List<GroupMember> gmemberList = new List<GroupMember>();
            List<User> agencyusers = new List<User>();
            
            Group g = new Group();
            g.name='TestAgency';
            insert g;
                    
            for(User u : userListTemp){
                if(u.ProfileId == contractorProfile.Id){
                    agencyusers.add(u);
                }
            }
            
            System.debug('£££ agencyusers: '+agencyusers);
            
            /*GroupMember gmember1 = new GroupMember();
            gmember1.GroupId = g.Id;
            gmember1.UserOrGroupId = agencyusers[0].Id;
            insert gmember1;        
            gmemberList.add(gmember1);*/
            
            for(User u : agencyusers){
               gmemberList.add(new GroupMember(GroupId = g.Id,UserOrGroupId = u.id)); 
            } 
            insert gmemberList;         
            System.debug('£££ inside createUser: gmemberList: '+gmemberList);       
    }
   
    
    static void createData(){
        date myDate = date.today();
        
        Acc = new Account();
        Acc.Name ='BS15 3PA 11 The M';
        Acc.BillingStreet='7 Canal Close';
        Acc.BillingPostalCode = 'BS15 3PA';
        Insert Acc;
        
        op = new Opportunity();
        op.name = '42493044 - D Waller - BS15 3PA - (HT44_P03)';
        op.Account= Acc;
        op.CloseDate = myDate;
        op.StageName = 'Active';
        op.Leadsource = 'Engineer';
        op.Referral_Employee__c = Em.id;
        op.Product_Interest__c = 'Central Heating Boiler';
        Insert op;
        
        bm = testClassHelper.createBMQuote(op);
        insert bm;
        
        testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        Database.insert(testRegion);
         
        testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
        Database.insert(testDistrict);
        
        testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                    Type__c='Installation', District__c = testDistrict.ID);
        Database.insert(testSubPatch);
        
        testPostcodeSector = new Postcode_Sector__c(Name = 'BS15 3', Description__c = 'Test Postcode Sector', 
                                                                        Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                        Sub_Patch__c = testSubPatch.ID);
        Database.insert(testPostcodeSector);
        
        supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                            Resource_Type__c='Own Labour');
        Database.insert(supp);
        
        pInstalList = [select id,name from Profile where name = 'CHI AGENCY OFFICE USER' OR name = 'CHI CONTRACTOR' OR name = 'CHI AGENCY CONTRACTOR'];
        for(Profile pp : pInstalList){
            if(pp.name.toUpperCase() == 'CHI AGENCY OFFICE USER'){
                officeUserProfile = pp;
            }
            if(pp.name.toUpperCase() == 'CHI AGENCY CONTRACTOR'){
                agencyContractorProfile = pp;
            }
            if(pp.name.toUpperCase() == 'CHI CONTRACTOR'){
                contractorProfile = pp;
            }    
        }
        
        /*g1 = new Group();
        g1.name='TestAgency';
        insert g1;
        
        agency = new Agency__c();
        agency.name='TestAgency';
        insert agency;*/
        
        uOfficeUser = new User(alias = 'office', email='offcieuser@testorg.com',
                                emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testofficeuser@testorg.com',
                                profileId = officeUserProfile.Id);
        userList.add(uOfficeUser);
                
        uAgencyCon = new User(alias = 'ageCon', email='agencycontractor@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='agencyContractor@testorg.com',
                                    profileId = agencyContractorProfile.Id);
        userList.add(uAgencyCon);
            
        conUser = new User(alias = 'conUser', email='contractor@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testContractor@testorg.com',
                                    profileId = contractorProfile.Id);
        userList.add(conUser);
                        
        Database.insert(userList); 
        System.debug('£££ inside createUser: userList '+userList);
           
        //call to the other method
        createUserGroup(userList);
        System.debug('AFTER CREATEUSER: '+userList);
        System.debug('uOfficeUser: '+uOfficeUser);
        System.debug('uAgencyCon: '+uAgencyCon);
        System.debug('conUser: '+conUser);
        
        empAgencyCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002995', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=uAgencyCon.Id,
                                            Is_Agency_Contractor__c = true,Agency__c = agency.Id);
        empList.add(empAgencyCon);
        empCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002994', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=conUser.Id);
        empList.add(empCon);     
        Database.insert(empList);
        
        Em = new Employee__c();
        Em.Name = 'Test';
        Em.First_Name__c='nTest';
        Em.Last_name__c='Test';
        Em.Employee_Number__c='123213';
        Em.Salesforce_User__c = UserInfo.getUserid();
        Insert Em;
        
        j = new job__c();
        j.status__c = 'planned';
        j.Installation_Date__c = date.today();
        j.CHI_Lead__c = op.id;
        insert j;        
           
        Ins = new Installer__c[] { 
          new Installer__c(Job__c=j.id,User__c = uAgencyCon.Id,Name ='Test'),
          new Installer__c(Job__c=j.id,User__c = conUser.Id,Name ='Test1')
          }; 
        insert Ins;  
                
        Jd = new Job_Diary__c();
        Jd.JobInstaller__c = UserInfo.getUserid();
        Jd.Job_Notification_Date__c =  myDate;
        Insert Jd;
    
    }
   
    public static testMethod void method1(){
        JobNotificationMail jdd = new JobNotificationMail(); 
        jdd.getDummyCoverage();
        jdd.getDummyCoverageSplit(); 
    }

   /* public static void createUserGroup(List<User> userList){
        Profile officeUserProfile;
        Profile agencyContractorProfile;
        Profile contractorProfile;
        
        List<Profile> pInstalList = [select id,name from Profile where name = 'CHI AGENCY OFFICE USER' OR name = 'CHI CONTRACTOR' OR name = 'CHI AGENCY CONTRACTOR'];
        
        for(Profile pp : pInstalList){
            if(pp.name == 'CHI AGENCY OFFICE USER'){
                officeUserProfile = pp;
            }
            if(pp.name == 'CHI AGENCY CONTRACTOR'){
                agencyContractorProfile = pp;
            }
            if(pp.name == 'CHI CONTRACTOR'){
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
        
        System.debug('£££ agencyusers: '+agencyusers);
        
        GroupMember gmember1 = new GroupMember();
        gmember1.GroupId = g.Id;
        gmember1.UserOrGroupId = agencyusers[0].Id;
        //insert gmember1;        
        gmemberList.add(gmember1);
        
        System.debug('£££ inside createUser: gmemberList: '+gmemberList);       
    }

        
     public static testMethod void JobNotificationMail_Test(){ 
    //ApexPages.StandardSetController controller;
    JobNotificationMail jdd = new JobNotificationMail(); 
    //jdd.getDummyCoverage();
    //jdd.getDummyCoverageSplit();
    List<User> userList = new List<User>();
    List<Job__c> lst_job1 =new List<Job__c>(); 
    JobNotificationMail.jobDiaryDetails IO = new JobNotificationMail.jobDiaryDetails();
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
    
    IO.getsInstallationNotesSummary();
    IO.setsInstallationNotesSummary('Summary'); 
    IO.setsBoilerInstallationNotes('test notes');
    IO.getsBoilerInstallationNotes();
    IO.setObj_job5(js);
    
    Pagereference p ;
    
    p = jdd.jobNotificationRerun();
    
          
    lst_job1 = Jdd.getLst_Job();
    String Str = Jdd.getStr_Planner();
    Jdd.getOrderMessage();
    p=jdd.emailJobDiary();
    Jdd.obj_Job1.Email_Address__c='test@test.com';
    p = jdd.deliverAsPDF();    
      
    jdd.redirectToPrintableView();
    
        p = Page.JobNotificationPrintPage;
        Test.setCurrentPage(p);
        ApexPages.currentPage().getParameters().put('p','print');     
        Apexpages.currentPage().getParameters().put('sYear','2010');
        Apexpages.currentPage().getParameters().put('sMonth','07');
        Apexpages.currentPage().getParameters().put('sDay','01');
        Apexpages.currentPage().getParameters().put('eYear','2010');
        Apexpages.currentPage().getParameters().put('eMonth','08');
        Apexpages.currentPage().getParameters().put('eDay','30'); 
    
    
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
    
    
    List<Profile> pInstalList = [select id,name from Profile where name = 'CHI AGENCY OFFICE USER' OR name = 'CHI CONTRACTOR' OR name = 'CHI AGENCY CONTRACTOR'];
    for(Profile pp : pInstalList){
        if(pp.name.toUpperCase() == 'CHI AGENCY OFFICE USER'){
            officeUserProfile = pp;
        }
        if(pp.name.toUpperCase() == 'CHI AGENCY CONTRACTOR'){
            agencyContractorProfile = pp;
        }
        if(pp.name.toUpperCase() == 'CHI CONTRACTOR'){
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
        System.debug('£££ inside createUser: userList '+userList);
       
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
    
    BigMachines_Quote__c bm = testClassHelper.createBMQuote(op);
    insert bm;    
    
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
    
        PageReference pageRef = Page.JobNotificationMail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('p','pdf');     
        Apexpages.currentPage().getParameters().put('sYear','2010');
        Apexpages.currentPage().getParameters().put('sMonth','07');
        Apexpages.currentPage().getParameters().put('sDay','01');
        Apexpages.currentPage().getParameters().put('eYear','2010');
        Apexpages.currentPage().getParameters().put('eMonth','08');
        Apexpages.currentPage().getParameters().put('eDay','30');  
       } 
    
    System.RunAs(uAgencyCon){ 
    jdd.bmId =  bm.id;
    jdd.updateQuote();
     
   Test.setCurrentPage(p);
   JobNotificationMail jdd1 = new JobNotificationMail(); 
   jdd1.obj_Job1.CHI_Lead_Number__c = 123456;
   jdd1.obj_Job1.SAP_Number__c = 1234;
   jdd1.jobNotificationRerun(); 
    
   jdd1.obj_Job1.CHI_Lead_Number__c = null;
   jdd1.obj_Job1.SAP_Number__c = 1234;
   jdd1.jobNotificationRerun(); 
    
   jdd1.obj_Job1.CHI_Lead_Number__c = 123456;
   jdd1.obj_Job1.SAP_Number__c = null;
   jdd1.jobNotificationRerun(); 
    
   jdd1.obj_Job1.CHI_Lead_Number__c = null;
   jdd1.obj_Job1.SAP_Number__c = null;
   jdd1.jobNotificationRerun();
    
   jdd1.obj_Job1.Search_single_job__c = true;
   jdd1.obj_Job1.Job_Notification_Date__c = null;
   jdd1.jobNotificationRerun();
   
   jdd1.obj_Job1.Search_single_job__c = true;
    jdd1.jobNotificationRerun(); 
     
   jdd1.obj_Job1.Job_Notification_Date__c = System.today();
    jdd1.obj_Job2.Job_Notification_Date__c = System.today().addDays(10);
    
     
  }   
    
  System.RunAs(uOfficeUser){
    Test.setCurrentPage(p);
   JobNotificationMail jdd2 = new JobNotificationMail(); 
    
   jdd2.obj_Job1.CHI_Lead_Number__c = 123456;
   jdd2.obj_Job1.SAP_Number__c = 1234;
   jdd2.id_Installer = uOfficeUser.id;
   jdd2.populateData(1);
    
  }  
}*/
}