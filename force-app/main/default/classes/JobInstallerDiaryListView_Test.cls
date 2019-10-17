@isTest
    Public Class JobInstallerDiaryListView_Test
    {
        @testSetup
        static  void setupdata()
        { 
            
             list<IV_Vectors__c> inserlist  = new list<IV_Vectors__c>();
             inserlist.add(new IV_Vectors__c (name = 'IDV Contractor', key__c = 'CHI Contractor,CHI Contractor - UAT' ));
             inserlist.add(new IV_Vectors__c (name = 'IDV Agency Contractor', key__c = 'CHI Agency Contractor - UAT,CHI Agency Contractor' ));
             inserlist.add(new IV_Vectors__c (name = 'IDV Agency Office Profile', key__c = 'CHI Agency Office User' ));
             insert inserlist;
             
        }
    	
    static testMethod void JobInstallerDiaryListView(){ 
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
    JobInstallerDiaryListView.createUserGroup(userList);
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
    

        JobInstallerDiaryListView.jobDiaryDetails dDetails=new JobInstallerDiaryListView.jobDiaryDetails();
        dDetails.attachmentId='';
        dDetails.attachmentname='a1';
        dDetails.str_JobTitle='Installer';
        dDetails.salesPerson='';
        dDetails.custHistoryCard=new Customer_history_card__c();
        dDetails.installdate='';
        dDetails.displayCustHistoryCard=true;
        dDetails.isSelected=true;
       //dDetails.combi=true;
        //dDetails.combiLnk=true;
        
        //dDetails.quoteProduct=new Quote_Product__c();
        //dDetails.IsUnavil=true;
        //dDetails.unavailabilty=new Diary_Entry__c();
        string summary=dDetails.getsInstallationNotesSummary();
        dDetails.setsInstallationNotesSummary('test1');
        dDetails.sInstallerNameOfOfficeUser='test1';
        pageReference pg=jdd.retrunMainMenu();
        jdd.str_StartDate='';
        jdd.str_EndDate='';
        pageReference pgRef=jdd.fetchDiaryViewForSelected();
        pageReference pRef=jdd.workDayReport();
                 
    System.RunAs(uOfficeUser){ 
    
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
  
  }