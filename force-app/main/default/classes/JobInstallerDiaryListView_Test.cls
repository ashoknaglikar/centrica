@isTest
    Public Class JobInstallerDiaryListView_Test
    {
        static list<IV_Vectors__c> inserlist=  new list<IV_Vectors__c>();
        static Region__c testRegion;
        static District__c testDistrict;
        static Sub_Patch__c testSubPatch;
        static Postcode_Sector__c testPostcodeSector;
        static Supplier__c supp;
        static List<Employee__c> empList = new List<Employee__c>();
        static List<Profile> pInstalList = new List<Profile>();
        static Group g1 = new Group();
        static Agency__c agency = new Agency__c();
        static  List<User> userList = new List<User>();
        static Account Acc = new Account();
        static Employee__c Em = new Employee__c();
        static Opportunity op = new Opportunity();
        static job__c j = new job__c();
        static Installer__c[] Ins;
        static Job_Diary__c Jd = new Job_Diary__c();
        static attachment[] attachList;
        static BigMachines_Quote__c bm;
        static order__c order;
        static list<Job_Element__c> je;
        
            
        static void createtestdata()
        {
             inserlist.add(new IV_Vectors__c (name = 'IDV Contractor', key__c = 'CHI Contractor,CHI Contractor - UAT' ));
             inserlist.add(new IV_Vectors__c (name = 'IDV Agency Contractor', key__c = 'CHI Agency Contractor - UAT,CHI Agency Contractor' ));
             inserlist.add(new IV_Vectors__c (name = 'IDV Agency Office Profile', key__c = 'CHI Agency Office User' ));
             insert inserlist;
             
             testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
             Database.insert(testRegion);
     
            testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
            Database.insert(testDistrict);
            
            testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', type__c='Installation', District__c = testDistrict.ID);
            Database.insert(testSubPatch);
            
            testPostcodeSector = new Postcode_Sector__c(Name = 'BS15 3', Description__c = 'Test Postcode Sector',water_Hardness__c = 99, Type__c = 'Installation', Sub_Patch__c = testSubPatch.ID);
            Database.insert(testPostcodeSector);
            
            supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', Resource_Type__c='Own Labour');
            Database.insert(supp);
    
            Profile officeUserProfile;
            Profile agencyContractorProfile;
            Profile contractorProfile;
            profile stdInstaller;
            profile sysAdmin;
            
            pInstalList = [select id,name from Profile where name = 'CHI Agency Office User' OR name = 'CHI Contractor' OR name = 'CHI Agency Contractor' OR name ='CHI Standard Installer' OR name ='System Administrator'];
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
                
                if(pp.name.toUpperCase() == 'CHI Standard Installer'){
                    stdInstaller = pp;
                }
                if(pp.name.toUpperCase() == 'system Administrator'){
                    sysAdmin = pp;
                }  
            }
            
            g1.name='TestAgency';
            insert g1;
           
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
            
            User stdUser = new User(alias = 'stdUser', email='stadinstaller@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestCon', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='stdinstaller@testorg.com',
                                    profileId = stdInstaller.Id);
            userList.add(stdUser);
            
            User systemAdmin = new User(alias = 'stdUser', email='stadinstaller@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestCon', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testsysAdmin@testorg.com',
                                    profileId = sysAdmin.Id);
            userList.add(systemAdmin);
                    
            Database.insert(userList); 
    
            
    
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
    
                acc = TestclassHelper.createAccout();
                insert acc;
            
               /* Contact con = TestclassHelper.createContact(acc);
                insert con;*/
            
                op = TestclassHelper.createCHILead(acc);
                op.CHI_Lead_Id__c='4712345';
                insert op;
                
                District__c district=testclassHelper.createDistrict();
                insert district;
                
                bm = TestClassHelper.createBMQuote(op);
                insert bm;
                
                j= testclassHelper.createJob('Planned','Planned',op.id,district.id);
                j.Quote__c = bm.id;
                j.Installation_Date__c = system.today();
                insert j;
               
                 
                Em.Name = 'Test';
                Em.First_Name__c='nTest';
                Em.Last_name__c='Test';
                Em.Employee_Number__c='123213';
                Em.Salesforce_User__c = UserInfo.getUserid();
                Insert Em;
                 
                 system.runAs(userlist[4])
                 {
                Ins = new Installer__c[] {new Installer__c(Job__c=j.id,User__c = uAgencyCon.Id,Name ='Test'),new Installer__c(Job__c=j.id,User__c = conUser.Id,Name ='Test1'),new Installer__c(Job__c=j.id,User__c = userinfo.getuserid(),Name ='Test2')};
                insert ins;
                
                JobInstallerDiaryListView.createUserGroup(userList);
                 }
                
                Jd.JobInstaller__c = UserInfo.getUserid();
                Jd.Job_Notification_Date__c =  system.today();
                Insert Jd;
                
                order = new order__c(SAP_Number__c='12345',job__c=j.id);
                insert order;
                
                je=new List<Job_Element__c>{new Job_Element__c(Job__c=j.id,type__c='Material',Skill__c='Mechanical'),new Job_Element__c(Job__c=j.id,type__c='Work',Skill__c='Electrical')};
                insert je;
                
                attachList = new attachment[]{new attachment(name='test.png',parentid=op.id,body=blob.valueOf('test')),new attachment(name='test.jpg',parentid=op.id,body=blob.valueOf('test')),new attachment(body=blob.valueof('test'),name='test Installation Notes',parentid=op.id)};
                insert attachlist;
        }
    	
   static testMethod void method1()
    { 
            createtestdata();
            JobInstallerDiaryListView jdd = new JobInstallerDiaryListView(); 
            JobInstallerDiaryListView.jobDiaryDetails IO = new JobInstallerDiaryListView.jobDiaryDetails();
            String Str = Jdd.getStr_Planner();
            Jdd.getOrderMessage();
            jdd.getSpecificContractor();
    

        JobInstallerDiaryListView.jobDiaryDetails dDetails=new JobInstallerDiaryListView.jobDiaryDetails();
        dDetails.attachmentId='';
        dDetails.attachmentname='a1';
        dDetails.str_JobTitle='Installer';
        dDetails.salesPerson='';
        dDetails.installdate='';
        dDetails.isSelected=true;
        string summary=dDetails.getsInstallationNotesSummary();
        dDetails.setsInstallationNotesSummary('test1');
        dDetails.sInstallerNameOfOfficeUser='test1';
        dDetails.setObj_job5(j);
        dDetails.getObj_job5();
        dDetails.setsBoilerInstallationNotes('test notes');
        dDetails.getsBoilerInstallationNotes();
        dDetails.setLst_Material(new List<Job_Element__c>{});
        dDetails.getLst_Material();
         dDetails.setLst_Labour(new List<Job_Element__c>{});
        dDetails.getLst_Labour();
         dDetails.setLst_order(new List<order__c>{});
        dDetails.getLst_order();
        dDetails.setchiPicList(attachlist);
        dDetails.getchiPicList();
        jdd.lst_JobDiaryDetails= new List<JobInstallerDiaryListView.jobDiaryDetails>{dDetails};
        jdd.str_StartDate='';
        jdd.str_EndDate='';
        jdd.getLst_Job();
        jdd.obj_Job1.Search_single_job__c=true;
        jdd.obj_Job1.SAP_Number__c=123456;
        jdd.obj_Job1.CHI_lead_number_text__c=null;
            jdd.fetchDiaryViewForSelected();
        jdd.obj_Job1.CHI_lead_number_text__c='4712345';
            jdd.fetchDiaryViewForSelected();
        jdd.obj_Job1.SAP_Number__c=null;
            jdd.fetchDiaryViewForSelected();
            
        jdd.obj_Job1.SAP_Number__c=123456;
        jdd.obj_Job1.CHI_lead_number_text__c='1235';
        jdd.populatedata(3);
                 
    System.RunAs(userlist[0]){ 
    
        PageReference pageRef = Page.InstallerJobDiaryListView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('p','pdf');     
        Apexpages.currentPage().getParameters().put('sYear','2010');
        Apexpages.currentPage().getParameters().put('sMonth','07');
        Apexpages.currentPage().getParameters().put('sDay','01');
        Apexpages.currentPage().getParameters().put('eYear','2010');
        Apexpages.currentPage().getParameters().put('eMonth','08');
        Apexpages.currentPage().getParameters().put('eDay','30');  
        JobInstallerDiaryListView jdd0 = new JobInstallerDiaryListView(); 
    }
    
    
   } 
   
   
     static testMethod void method2()
     { 
            createtestdata();
             PageReference pageRef = Page.InstallerJobDiaryListView;
             Test.setCurrentPage(pageRef);
             JobInstallerDiaryListView jdd = new JobInstallerDiaryListView(); 
            JobInstallerDiaryListView.jobDiaryDetails IO = new JobInstallerDiaryListView.jobDiaryDetails();
            jdd.obj_Job1.job_Notification_Date__c=system.today();
            jdd.obj_Job2.Job_Notification_Date__c=system.today();
            jdd.obj_Job1.Email_Address__c = 'test@abc.com';
            jdd.obj_Job1.JobInstaller__c=userList[0].id;
            jdd.deliverAsPDF();
            jdd.workDayReport();
            jdd.emailJobDiary();
            jdd.retrunMainMenu();
            jdd.selectValidAgencyContractor();
            jdd.jobNotificationRerunJobList();
            jdd.fetchDiaryViewForSelected();
            
            
            system.runas(userlist[0])
            {
                jdd.selectValidAgencyContractor();
                jdd.jobNotificationRerunJobList();
                jdd.fetchDiaryViewForSelected();
            }
     }
     
     static testMethod void method3()
     { 
            createtestdata();
            system.runAs(userlist[0])
            {
                 PageReference pageRef = Page.InstallerJobDiaryListView;
                 Test.setCurrentPage(pageRef);
                 JobInstallerDiaryListView jdd = new JobInstallerDiaryListView(); 
                JobInstallerDiaryListView.jobDiaryDetails IO = new JobInstallerDiaryListView.jobDiaryDetails();
                jdd.obj_Job1.job_Notification_Date__c=system.today();
                jdd.obj_Job2.Job_Notification_Date__c=system.today();
                jdd.obj_Job1.Email_Address__c = 'test@abc.com';
                jdd.obj_Job1.JobInstaller__c=userList[0].id;
                jdd.populatedata(3);
                jdd.selectValidAgencyContractor();
            }
            
     }
  
  }