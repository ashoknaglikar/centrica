@isTest (SeeAllData=true)
public class DiaryDisplayWorker_Test {
    
    static Employee__c emp;
    Shift_Pattern__c sPattern;
    static Employee__c empWorksWith;
    static Employee_Postcode_Sectors__c  emppost;
    static district__c dist;
    static Region__c  testregion;
    static Sub_Patch__c subpatch;
    static Postcode_Sector__c pcode;
    static Datetime weekStart;
    static String postCode;
    static String endTime;
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Opportunity opp;
    static BigMachines_Quote__c quote;
    static Job__c job;
    static Week__c week;
    static Diary_Entry__c DEntry;
    static double length;
    static String avType;
    static String URL;
    static String jobCode;
    static Double jobHours;
    static DateTime startDate;
    static DateTime endDate;
    static string subType;
    static string unAvailRecTypeId;
     static string NProdBRecTypeId;
    
    static void createData()
    {
        cls_IsRun.dontFireTriggers = true;
        cls_IsRun.generalTriggerSwitch = true;
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id);
        insert emp;
        
        testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Region__c=testRegion.id,Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist;
        
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        
        emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
         //inserting opportunity with different employee
         opp = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addyears(1),                                                 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                        
         insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                        POC_Payment_Method__c = 'Finance',
                                         Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                         is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                         Job_Type__c = '13' , Product_Type_ID__c = 'ECH');
        insert quote;
        
        job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                        Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5,previous_resources__c = ' ',
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),Installer__c=UserInfo.getUserId());
   
            
        job.Status__c='Planned';
        job.Is_Remedial_Job__c = true;
        insert job;
        
        week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        
        DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id , Job__c = job.id , Start__c = system.now() , End__c = system.now().adddays(7) , Type__c = 'Job Booking');
        insert DEntry;
        
        weekStart = system.now();
        postCode = 'PH2 6NF';
        endTime = '12:12';
        length = 12.0;
        avType = 'Start';
        URL = 'www.google.com';
        jobCode = 'testCode';
        jobHours = 12.0;
        startDate = system.now();
        endDate = system.now().adddays(5);
        subType = 'Survey Booking';
        unAvailRecTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Job Booking');
    }
    
    static testmethod void testDiaryDisplay()
    {
        createData();
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek().adddays(2), Time.newInstance(9,0,0,0));
        //DateTime endDT= DateTime.newInstance(Date.today().toStartOfWeek().adddays(4), Time.newInstance(9,0,0,0));
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
        List<DiaryDisplayWorker.GraphicDisplay> graphD=noAvailLine.getGraphicNoAvailabilityLines();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
         
        DiaryDisplayWorker.GraphicDisplay graphic = new DiaryDisplayWorker.GraphicDisplay();
        graphic.hours = 4;
        graphic.getLength();
        graphic.bgColour = 'JobBooking.gif';
        graphic.jobHours = 3;
        graphic.skill = 'Mechanical';
        graphic.installPostCode = 'PH2 6NF';
        graphic.getoutputstring();
        graphic.getInstallPostCode();
        boolean info=graphic.getShowInformation();
        string getcolor=graphic.getcolour();
        string getBColor=graphic.getbgcolour();
        string getB1Color=graphic.getInformation();
        string getB2Color=graphic.getBorderLeft();
        string getB3Color=graphic.getBorderRight();
        string getBwColor=graphic.getwidth();
        string getBuColor=graphic.getURL();
        string getBjColor=graphic.getJobCode();
        string getBSTColor=graphic.getSubType();
         noAvailLine.getGraphicNonProdLines();
        noAvailLine.LastNoneAvailabilityEndDate = system.now();
        
        DiaryDisplayWorker.Employee employee = new DiaryDisplayWorker.Employee(emp.Name , emp.Emp_type__c , emp , weekStart , emp.Primary_Role__c , postCode);
        employee.getAllCols();
        employee.getemployeeObject();
        employee.getEmployeeName();
        employee.getEmployeeURL();
        employee.getavailabilityhours();
        //employee.LastEndDate=startDT;
        employee.addToEndOfDayNW(noAvailLine , endTime);
        employee.getnoPrdLines();
      
        
        job = [select id,Job_Type__c,Install_Postcode__c , CHI_Lead__r.CHI_Lead_Id__c,
              Name , Customer_Name__c , Status__c , Sub_Status__c , Installation_Address__c ,
              Phone_Number__c , CHI_Lead__r.Latest_customer_category__c , Green_Deal__c ,
              Is_Remedial_Job__c , Is_Downtime_Job__c , CHI_Lead__r.Non_Op__c
              from Job__c where id=: job.id];
        system.debug('----------job.Job_Type__c----'+job.Job_Type__c);
        
        DEntry.Type__c = 'Job Booking';
        DEntry.Job__r = job;
        DEntry.RecordTypeId = unAvailRecTypeId;
        update DEntry;
        DEntry = [select id,Record_Type__c , Type__c , Job__c ,Job__r.Install_Postcode__c,
                 Employee__c , Week__c , Start__c , End__c ,Job__r.Name,Job__r.Customer_Name__c,Job__r.Status__c,Job__r.Sub_Status__c,Job__r.Installation_Address__c,Job__r.Phone_Number__c,Job__r.CHI_Lead__r.Latest_customer_category__c,
                 Job__r.Engineer_Working_NWD__c,Job__r.Job_Type__c,Job__r.Quote__r.Job_Type__c,Job__r.Green_Deal__c,Job__r.Is_Remedial_Job__c,Job__r.Is_Downtime_Job__c,Job__r.CHI_Lead__r.Non_Op__c,
                 Product_Id__c,hours__c , Sub_Type__c , Week__r.Id , Week__r.Week_Commencing__c ,Week__r.Monday_Max_Hours__c,Week__r.Monday_Unavailable_Hours__c,Week__r.Monday_Booked_Hours__c,
                    Week__r.Tuesday_Max_Hours__c,Week__r.Tuesday_Unavailable_Hours__c,Week__r.Tuesday_Booked_Hours__c,
                    Week__r.Wednesday_Max_Hours__c,Week__r.Wednesday_Unavailable_Hours__c,Week__r.Wednesday_Booked_Hours__c,
                    Week__r.Thursday_Max_Hours__c,Week__r.Thursday_Unavailable_Hours__c,Week__r.Thursday_Booked_Hours__c,
                    Week__r.Friday_Max_Hours__c,Week__r.Friday_Unavailable_Hours__c,Week__r.Friday_Booked_Hours__c,
                    Week__r.Saturday_Max_Hours__c,Week__r.Saturday_Unavailable_Hours__c,Week__r.Saturday_Booked_Hours__c,            
                    Week__r.Sunday_Max_Hours__c,Week__r.Sunday_Unavailable_Hours__c,Week__r.Sunday_Booked_Hours__c,

                 job__r.CHI_Lead__r.CHI_Lead_Id__c,Job__r.Own_Labour__c,Job__r.Contractors__c,Job__r.Secondary_Job_Type_New__c,Job__r.Double_Handed_Job__c
                 from Diary_Entry__c where id=: DEntry.id];
        employee.thisWeek = week;
        noAvailLine.barChart2 = new List<DiaryDisplayWorker.GraphicDisplay>();
        noAvailLine.barChart3 = new List<DiaryDisplayWorker.GraphicDisplay>();
        employee.addBarAvailability(length , avType , URL , jobCode , jobHours , DEntry , startDate , endDate);
        employee.addBarNoAvailability(noAvailLine , length , avType , URL , subType , jobHours , DEntry);
        employee.getGraphicDisplay();
        List<Diary_Entry__c> diaryE=employee.getdiaryEntries();
        
        
        Diary_Entry__c DEntry1=new Diary_Entry__c();
        DEntry1=NULL;
        
        //employee.employeeObject.Pool_Diary__c = true;
        employee.addEntry(DEntry1 , startDate+1, endDate,dist.id);
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+2;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+3;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+4;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+5;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+6;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.employeeObject.Pool_Diary__c = true;        
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        employee.employeeObject.Pool_Diary__c = false; 
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
         
        
    }
    static testmethod void testDiaryDisplay1()
    {
        
        Profile p = [SELECT p.ID FROM profile p WHERE name='CHI Standard Installer' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                    Email = 'a1@b.com', Username='user123454321@testorg.com',
                                    ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                    Migration_ID__c = 'user1@hotmail.com',
                                    TimeZoneSidKey = 'Europe/London', 
                                    LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US',IsActive = true);
        user.EmployeeNumber = '1234321';
        insert user;
        
        system.runas(user){
        createData();    
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
       
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
        DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
       
        
        DiaryDisplayWorker.formatDouble(10, 2);
        worker.getEmployeesForDiary(dist.id,startDT,endDT, null); 
        
        
        noAvailLine.getGraphicNonProdLines();
        noAvailLine.LastNoneAvailabilityEndDate = system.now();
        
        DiaryDisplayWorker.Employee employee = new DiaryDisplayWorker.Employee(emp.Name , emp.Emp_type__c , emp , weekStart , emp.Primary_Role__c , postCode);
        employee.getAllCols();
        employee.getemployeeObject();
        employee.getEmployeeName();
        employee.getEmployeeURL();
        employee.getavailabilityhours();
        employee.LastEndDate=startDT;
        employee.addToEndOfDayNW(noAvailLine , endTime);
        employee.getnoPrdLines();
        
        //employee.locked=false;
        employee.mon='5';
        employee.tue='5';
        employee.wed='5';
        employee.thu='5';
        employee.fri='5';
        employee.sat='5';
        employee.sun='5';
        employee.category=2;     
        string roleS=employee.getStr_Role();
        string roleS1=employee.getStr_PostCode();
        Week__c weekRecord=employee.getthisWeek();
        List<DiaryDisplayWorker.NoAvailabilityLine> noAvail=employee.getNoAvailLines();
        string roleS2=employee.getdebugsegment();
        Integer roleS3=integer.valueOf(employee.getSegments());
        
        job = [select id,Job_Type__c,Install_Postcode__c , CHI_Lead__r.CHI_Lead_Id__c,
              Name , Customer_Name__c , Status__c , Sub_Status__c , Installation_Address__c ,
              Phone_Number__c , CHI_Lead__r.Latest_customer_category__c , Green_Deal__c ,
              Is_Remedial_Job__c , Is_Downtime_Job__c , CHI_Lead__r.Non_Op__c
              from Job__c where id=: job.id];
        system.debug('----------job.Job_Type__c----'+job.Job_Type__c);
         
        DEntry.Type__c = 'Job Booking';
        DEntry.Job__r = job;
        DEntry.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Job Booking');
        update DEntry;
       
                                 
        employee.thisWeek = week;
        noAvailLine.barChart2 = new List<DiaryDisplayWorker.GraphicDisplay>();
        noAvailLine.barChart3 = new List<DiaryDisplayWorker.GraphicDisplay>();
        employee.addBarAvailability(length , avType , URL , jobCode , jobHours , DEntry , startDate , endDate);
        employee.addBarNoAvailability(noAvailLine , length , avType , URL , subType , jobHours , DEntry);
        employee.getGraphicDisplay();
                
        DEntry.Type__c = 'Unavailability';
        DEntry.Job__r = job;
        DEntry.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Unavailability');
        update DEntry;
        
         
         DEntry = [select id,Record_Type__c , Type__c , Job__c ,Job__r.Install_Postcode__c,
                 Employee__c , Week__c , Start__c , End__c ,Job__r.Name,Job__r.Customer_Name__c,Job__r.Status__c,Job__r.Sub_Status__c,Job__r.Installation_Address__c,Job__r.Phone_Number__c,Job__r.CHI_Lead__r.Latest_customer_category__c,
                 Job__r.Engineer_Working_NWD__c,Job__r.Job_Type__c,Job__r.Quote__r.Job_Type__c,Job__r.Green_Deal__c,Job__r.Is_Remedial_Job__c,Job__r.Is_Downtime_Job__c,Job__r.CHI_Lead__r.Non_Op__c,
                 Product_Id__c,hours__c , Sub_Type__c , Week__r.Id , Week__r.Week_Commencing__c ,Week__r.Monday_Max_Hours__c,Week__r.Monday_Unavailable_Hours__c,Week__r.Monday_Start_Time__c,Week__r.Monday_End_Time__c,
                    Week__r.Tuesday_Start_Time__c,Week__r.Tuesday_End_Time__c,
                    Week__r.Wednesday_Start_Time__c,Week__r.Wednesday_End_Time__c,
                    Week__r.Thursday_Start_Time__c,Week__r.Thursday_End_Time__c,
                    Week__r.Friday_Start_Time__c,Week__r.Friday_End_Time__c,
                    Week__r.Saturday_Start_Time__c,Week__r.Saturday_End_Time__c,
                    Week__r.Tuesday_Max_Hours__c,Week__r.Tuesday_Unavailable_Hours__c,Week__r.Tuesday_Booked_Hours__c,
                    Week__r.Wednesday_Max_Hours__c,Week__r.Wednesday_Unavailable_Hours__c,Week__r.Wednesday_Booked_Hours__c,
                    Week__r.Thursday_Max_Hours__c,Week__r.Thursday_Unavailable_Hours__c,Week__r.Thursday_Booked_Hours__c,
                    Week__r.Friday_Max_Hours__c,Week__r.Friday_Unavailable_Hours__c,Week__r.Friday_Booked_Hours__c,
                    Week__r.Saturday_Max_Hours__c,Week__r.Saturday_Unavailable_Hours__c,Week__r.Saturday_Booked_Hours__c,            
                    Week__r.Sunday_Max_Hours__c,Week__r.Sunday_Unavailable_Hours__c,Week__r.Sunday_Booked_Hours__c,

                 job__r.CHI_Lead__r.CHI_Lead_Id__c
                 from Diary_Entry__c where id=: DEntry.id];
                 
        system.debug('--------------->Unavailability:'+DEntry.Record_Type__c);
        employee.thisWeek = week;
        noAvailLine.barChart2 = new List<DiaryDisplayWorker.GraphicDisplay>();
        noAvailLine.barChart3 = new List<DiaryDisplayWorker.GraphicDisplay>();
        employee.addBarAvailability(length , avType , URL , jobCode , jobHours , DEntry , startDate , endDate);
        employee.addBarNoAvailability(noAvailLine , length , avType , URL , subType , jobHours , DEntry);
        employee.getGraphicDisplay();
        
        /*Diary_Entry__c DEntry1 = new Diary_Entry__c();
        DEntry1=NULL;
        
        employee.employeeObject.Pool_Diary__c = true;
        
        employee.addEntry(DEntry1 , startDate , endDate);*/
       // employee.LastEndDate = NULL;
        employee.LastEndDate =date.today()+30;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        //employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+1;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        
        
        DEntry.start__c = system.now()+2;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+2;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+3;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-3;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+3;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+3;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
                
        DEntry.start__c = system.now()+4;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-4;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+4;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+4;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+4;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+2;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+5;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-5;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+5;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+5;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+5;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+2;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+5;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+3;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()-6;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+2;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+3;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        DEntry.start__c = system.now()+6;
        update DEntry;
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+4;
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
              
        DiaryDisplayWorker.GraphicDisplay graphic1 = new DiaryDisplayWorker.GraphicDisplay();
        graphic1.hours = 10;
        graphic1.getLength();
        graphic1.bgColour = 'JobBooking.gif';
        graphic1.jobHours = 9;
        graphic1.skill = 'Mechanical';
        graphic1.installPostCode = 'PH2 6NF';
        graphic1.getoutputstring();
        graphic1.getInstallPostCode();
      }  
    }
    
     static void createData1()
    {
        cls_IsRun.dontFireTriggers = true;
        cls_IsRun.generalTriggerSwitch = true;
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
        
        //prepare employee data
        testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Region__c=testRegion.id,Own_labour_Employee__c=0,Away__c=0,On_Loan__c=0,Contractor_Non_Pool__c=0,Contractor_Pool__c=0);
        insert dist;
        
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id,District__c=dist.id);
        insert emp;
        
       
        
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        
        emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
         //inserting opportunity with different employee
         opp = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addyears(1),                                                 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                        
         insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                        POC_Payment_Method__c = 'Finance',
                                         Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                         is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                         Job_Type__c = '13' , Product_Type_ID__c = 'ECH');
        insert quote;
        
        job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                        Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5,previous_resources__c = ' ',
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),Installer__c=UserInfo.getUserId());
   
            
        job.Status__c='Planned';
        job.Is_Remedial_Job__c = true;
        insert job;
        
        week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        
        DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id , Job__c = job.id , Start__c = system.now() , End__c = system.now().adddays(7) , Type__c = 'Job Booking');
        insert DEntry;
        
        weekStart = system.now();
        postCode = 'PH2 6NF';
        endTime = '12:12';
        length = 12.0;
        avType = 'Start';
        URL = 'www.google.com';
        jobCode = 'testCode';
        jobHours = 12.0;
        startDate = system.now();
        endDate = system.now().adddays(5);
        subType = 'Survey Booking';
        NProdBRecTypeId= RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Non Productive Job Booking');
    }
    
     
     static testmethod void testDiaryDisplay3()
    {
        createData1();
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek().adddays(2), Time.newInstance(9,0,0,0));
        //DateTime endDT= DateTime.newInstance(Date.today().toStartOfWeek().adddays(4), Time.newInstance(9,0,0,0));
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
        List<DiaryDisplayWorker.GraphicDisplay> graphD=noAvailLine.getGraphicNoAvailabilityLines();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
         
        DiaryDisplayWorker.GraphicDisplay graphic = new DiaryDisplayWorker.GraphicDisplay();
        graphic.hours = 4;
        graphic.getLength();
        graphic.bgColour = 'JobBooking.gif';
        graphic.jobHours = 3;
        graphic.skill = 'Mechanical';
        graphic.installPostCode = 'PH2 6NF';
        graphic.getoutputstring();
        graphic.getInstallPostCode();
        boolean info=graphic.getShowInformation();
        string getcolor=graphic.getcolour();
        string getBColor=graphic.getbgcolour();
        string getB1Color=graphic.getInformation();
        string getB2Color=graphic.getBorderLeft();
        string getB3Color=graphic.getBorderRight();
        string getBwColor=graphic.getwidth();
        string getBuColor=graphic.getURL();
        string getBjColor=graphic.getJobCode();
        string getBSTColor=graphic.getSubType();
         noAvailLine.getGraphicNonProdLines();
        noAvailLine.LastNoneAvailabilityEndDate = system.now();
        
        DiaryDisplayWorker.Employee employee = new DiaryDisplayWorker.Employee(emp.Name , emp.Emp_type__c , emp , weekStart , emp.Primary_Role__c , postCode);
        employee.getAllCols();
        employee.getemployeeObject();
        employee.getEmployeeName();
        employee.getEmployeeURL();
        employee.getavailabilityhours();
        //employee.LastEndDate=startDT;
        employee.addToEndOfDayNW(noAvailLine , endTime);
        employee.getnoPrdLines();
      
        
        job = [select id,Job_Type__c,Install_Postcode__c , CHI_Lead__r.CHI_Lead_Id__c,
              Name , Customer_Name__c , Status__c , Sub_Status__c , Installation_Address__c ,
              Phone_Number__c , CHI_Lead__r.Latest_customer_category__c , Green_Deal__c ,
              Is_Remedial_Job__c , Is_Downtime_Job__c , CHI_Lead__r.Non_Op__c
              from Job__c where id=: job.id];
        system.debug('----------job.Job_Type__c----'+job.Job_Type__c);
        
        DEntry.Type__c = 'Job Booking';
        DEntry.Job__r = job;
        DEntry.RecordTypeId = NProdBRecTypeId;
        update DEntry;
        DEntry = [select id,Record_Type__c , Type__c , Job__c ,Job__r.Install_Postcode__c,
                 Employee__c , Week__c , Start__c , End__c ,Job__r.Name,Job__r.Customer_Name__c,Job__r.Status__c,Job__r.Sub_Status__c,Job__r.Installation_Address__c,Job__r.Phone_Number__c,Job__r.CHI_Lead__r.Latest_customer_category__c,
                 Job__r.Engineer_Working_NWD__c,Job__r.Job_Type__c,Job__r.Quote__r.Job_Type__c,Job__r.Green_Deal__c,Job__r.Is_Remedial_Job__c,Job__r.Is_Downtime_Job__c,Job__r.CHI_Lead__r.Non_Op__c,
                 Product_Id__c,hours__c , Sub_Type__c , Week__r.Id , Week__r.Week_Commencing__c ,Week__r.Monday_Max_Hours__c,Week__r.Monday_Unavailable_Hours__c,Week__r.Monday_Booked_Hours__c,
                    Week__r.Tuesday_Max_Hours__c,Week__r.Tuesday_Unavailable_Hours__c,Week__r.Tuesday_Booked_Hours__c,
                    Week__r.Wednesday_Max_Hours__c,Week__r.Wednesday_Unavailable_Hours__c,Week__r.Wednesday_Booked_Hours__c,
                    Week__r.Thursday_Max_Hours__c,Week__r.Thursday_Unavailable_Hours__c,Week__r.Thursday_Booked_Hours__c,
                    Week__r.Friday_Max_Hours__c,Week__r.Friday_Unavailable_Hours__c,Week__r.Friday_Booked_Hours__c,
                    Week__r.Saturday_Max_Hours__c,Week__r.Saturday_Unavailable_Hours__c,Week__r.Saturday_Booked_Hours__c,            
                    Week__r.Sunday_Max_Hours__c,Week__r.Sunday_Unavailable_Hours__c,Week__r.Sunday_Booked_Hours__c,

                 job__r.CHI_Lead__r.CHI_Lead_Id__c,Job__r.Own_Labour__c,Job__r.Contractors__c,Job__r.Double_Handed_Job__c
                 from Diary_Entry__c where id=: DEntry.id];
        employee.thisWeek = week;
        noAvailLine.barChart2 = new List<DiaryDisplayWorker.GraphicDisplay>();
        noAvailLine.barChart3 = new List<DiaryDisplayWorker.GraphicDisplay>();
        employee.addBarAvailability(length , avType , URL , jobCode , jobHours , DEntry , startDate , endDate);
        employee.addBarNoAvailability(noAvailLine , length , avType , URL , subType , jobHours , DEntry);
        employee.getGraphicDisplay();
        List<Diary_Entry__c> diaryE=employee.getdiaryEntries();
        
        
        Diary_Entry__c DEntry1=new Diary_Entry__c();
        DEntry1=NULL;
        
        //employee.employeeObject.Pool_Diary__c = true;
        employee.addEntry(DEntry1 , startDate+1, endDate,dist.id);
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now();
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+1;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+2;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+3;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+4;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+5;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.thisnoAvLine.LastNoneAvailabilityEndDate = system.now()+6;
        employee.addEntry(DEntry1 , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '09:00' , '10:00');
        
        employee.employeeObject.Pool_Diary__c = true;        
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
        
        employee.employeeObject.Pool_Diary__c = false; 
        employee.addEntry(DEntry , startDate , endDate,dist.id);
        employee.addDayDiaryEntry(noAvailLine , '11:00' , '13:00');
         
        
    }
      static testmethod void testDiaryDisplay4()
    {
        createData();
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek().adddays(2), Time.newInstance(9,0,0,0));
        //DateTime endDT= DateTime.newInstance(Date.today().toStartOfWeek().adddays(4), Time.newInstance(9,0,0,0));
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        emp.Works_Anywhere_In_District__c=true;
       
        
        update emp;
        emppost.Start_Date__c=date.today();
        emppost.End_Date__c=date.today()+10;
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
        List<DiaryDisplayWorker.GraphicDisplay> graphD=noAvailLine.getGraphicNoAvailabilityLines();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
         
         }
         static testmethod void testDiaryDisplay5()
    {
        createData1();
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek().adddays(2), Time.newInstance(9,0,0,0));
        //DateTime endDT= DateTime.newInstance(Date.today().toStartOfWeek().adddays(4), Time.newInstance(9,0,0,0));
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        emp.Works_Anywhere_In_District__c=true;
       
        
        update emp;
        
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
        List<DiaryDisplayWorker.GraphicDisplay> graphD=noAvailLine.getGraphicNoAvailabilityLines();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
         
         }
        
         
         static testmethod void testDiaryDisplay6()
       {
       
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
         dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist;
        district__c dist2 = new district__c(name='Kent1 & East Surrey',Code__c = 'TN912',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
       insert dist2;
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist2.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId(),Works_Anywhere_In_District__c =true ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991',District__c= dist.id, Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id);
        insert emp;
         emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
        //prepare employee data
        startDate = system.now();
        endDate = system.now().adddays(5);
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
      }
       static testmethod void testDiaryDisplay7()
       {
         account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
         dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist;
        district__c dist2 = new district__c(name='Kent1 & East Surrey',Code__c = 'TN912',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
       insert dist2;
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist2.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId(),Works_Anywhere_In_District__c =false,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991',District__c= dist.id, Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id);
        insert emp;
         emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
        //prepare employee data
        startDate = system.now();
        endDate = system.now().adddays(5);
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
         }
         
          static testmethod void testDiaryDisplay8()
       {
       
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
         dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist;
        district__c dist2 = new district__c(name='Kent1 & East Surrey',Code__c = 'TN912',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
       insert dist2;
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist2.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        emp = new Employee__c(Name = 'testJI1',Pool_Diary__c=true, Salesforce_User__c = UserInfo.getUserId(),Works_Anywhere_In_District__c =true ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991',District__c= dist.id, Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id);
        insert emp;
        
         emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
       
        //prepare employee data
        startDate = system.now();
        endDate = system.now().adddays(5);
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
      }
      static testmethod void testDiaryDisplay9()
       {
       
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert empWorksWith;
         dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist;
        District__c dist2 = new district__c(name='Kent1 & East Surrey',Code__c = 'TN12',Type__c='Installation',Own_labour_Employee__c=1,Away__c=2,On_Loan__c=3,Contractor_Non_Pool__c=4,Contractor_Pool__c=5);
        insert dist2;
        Sub_Patch__c subpatch1 = new Sub_Patch__c(name='Kent 1& East Surrey S06',code__c='test_S16', district__c=dist2.id,type__c='Installation');
        insert subpatch1;
        
        Postcode_Sector__c pcode1 = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch1.id,name='TN4 2');
        insert pcode1;
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        emp = new Employee__c(Name = 'testJI1',Pool_Diary__c=true, Salesforce_User__c = UserInfo.getUserId(),Works_Anywhere_In_District__c =true ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991',District__c= dist.id, Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id);
        insert emp;
        
         emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost;
        Employee_Postcode_Sectors__c  emppost1 = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode1.id,Start_Date__c=Date.today().toStartOfWeek(),End_Date__c=date.today().toStartOfWeek().adddays(3), Type__c = 'Away');
        insert emppost1;
       
        //prepare employee data
        startDate = system.now();
        endDate = system.now().adddays(5);
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        worker.getEmployeesForDiary(dist.id,startDate,endDate, null); 
      }
      
       static testmethod void testDiaryDisp()
    {
        createData();
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek().adddays(2), Time.newInstance(9,0,0,0));
        //DateTime endDT= DateTime.newInstance(Date.today().toStartOfWeek().adddays(4), Time.newInstance(9,0,0,0));
        
       /* Shift_Pattern__c shiftP=new Shift_Pattern__c();
        shiftP.Pool_Shift_Pattern__c=true;
        shiftP.Monday_Max_Hours__c=Decimal.valueOf('1:1');
        shiftP.Tuesday_Max_Hours__c='1:1';
        shiftP.Wednesday_Max_Hours__c='1:1';
        shiftP.Thursday_Max_Hours__c='1:1';
        shiftP.Friday_Max_Hours__c='1:1';
        shiftP.Saturday_Max_Hours__c='1:1';
        shiftP.Sunday_Max_Hours__c='1:1'; 
        
        insert shiftP;
        
        week.Shift_Pattern__c=shiftP.id;
        update week;*/
        DEntry.Hours__c=2;
        update DEntry;    
        
        DiaryDisplayWorker worker = new DiaryDisplayWorker();
        
        DiaryDisplayWorker.Employee empl1 = new DiaryDisplayWorker.Employee(emp.Name , emp.Emp_type__c , emp , weekStart , emp.Primary_Role__c , postCode);
      
        worker.employees.add(empl1); 
        List<DiaryDisplayWorker.Employee> eList=worker.getEmployees();
        DiaryDisplayWorker.Employee empl=worker.findEmployee(emp.id);
         
        
        DiaryDisplayWorker.NoAvailabilityLine noAvailLine = new DiaryDisplayWorker.NoAvailabilityLine();
        List<DiaryDisplayWorker.GraphicDisplay> graphD=noAvailLine.getGraphicNoAvailabilityLines();
        
        
        worker.getEmployeesForDiary(dist.id,startDate,endDate,null); 
        worker.getDiaryEntry(startDate,endDate,dist.id);
         
         }
         
         
}