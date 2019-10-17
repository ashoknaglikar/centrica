/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InstallPlanningReturnTransferCont_Test {

    static TestMethod void testerTransfer(){
    
    //create a new job
    //mechhours = 12
    //only assign 2.8 hours to employee
    
    ID districtID = TestScenarioCreateDistrict();
    Account Acc = TestScenarioCreateAccount(districtID);
    Opportunity opty = TestScenarioCreateOppty(Acc);
    
    Job__c j = new Job__c();
    j.CHI_Lead__c = opty.Id;
    j.Status__c = 'Planned';
    j.Mechanical_Hours__c = 12;
    
    insert j;
    Supplier__c supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
    insert supplier;
    Employee__c e = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc123', 
        Resource_Type__c='Installer',
        X3G_phone_Number__c = 'Pay Monthly',
        Supplier__c = supplier.Id,
        Pool_Diary__c = false);
    insert e;
    
    Employee__c e1 = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc1234', 
        Resource_Type__c='Installer',
        Supplier__c = supplier.Id,
        Pool_Diary__c = false);
    insert e1;
    
    Employee_Skills__c es = new Employee_Skills__c(Employee__c = e.Id, Skill_Name__c='Mechanical');
    insert es; 
    
    //List<Employee_Skills__c> skills = [Select e.Skill_Name__c, e.Employee__c, e.Employee__r.Supplier__c From Employee_Skills__c e where skill_Name__c= 'Mechanical' and e.Employee__r.Supplier__c!= null limit 2];
    //Id transferTo = skills.get(1).Employee__c;
    Id transferTo = e.Id;
    
    Shift_Pattern__c shift = new Shift_Pattern__c(Name='Testing Shift Pattern1', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
    Database.insert(shift);
    
    //Shift_Pattern__c shift = [select id, s.Total_Hours__c, s.Sunday_End_Time__c, s.Wednesday_Start_Time__c, s.Monday_Start_Time__c, s.Monday_End_Time__c from Shift_Pattern__c s where name >= 'Monday-Friday 8-5' order by name limit 1];
    Week__c wk; 
    Week__c wk1;
    
    List<Week__c> weeks = new List<Week__c>();
    //add Mechanical entries
//      for(Employee_Skills__c sk : skills){
//          if(sk.Skill_Name__c == 'Mechanical'){
            wk = new Week__c(
                Employee__c = e.Id,
                Week_Commencing__c = System.today().addDays(20).toStartOfWeek(),
                Shift_Pattern__c = shift.Id,
                Monday_Max_Hours__c = 9.0,
                Tuesday_Max_Hours__c = 9.0,
                Wednesday_Max_Hours__c = 9.0,
                Thursday_Max_Hours__c = 9.0,
                Friday_Max_Hours__c = 9.0,
                Saturday_Max_Hours__c = 9.0,
                Sunday_Max_Hours__c = 9.0
            );
            weeks.add(wk);
            
            wk = new Week__c(
                Employee__c = e1.Id,
                Week_Commencing__c = System.today().addDays(20).toStartOfWeek(),
                Shift_Pattern__c = shift.Id,
                Monday_Max_Hours__c = 9.0,
                Tuesday_Max_Hours__c = 9.0,
                Wednesday_Max_Hours__c = 9.0,
                Thursday_Max_Hours__c = 9.0,
                Friday_Max_Hours__c = 9.0,
                Saturday_Max_Hours__c = 9.0,
                Sunday_Max_Hours__c = 9.0
            );
            weeks.add(wk);
 //         }
 //     }
    
    
    insert weeks;
    wk = weeks.get(0);
    wk1 = weeks.get(1);
    
    List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
    DateTime dt;
    dt = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c);
    diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Mechanical',
        Job__c = j.Id,
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 27),//adding a bit more to allow move overnight
        Hours__c = 12,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking')
    ));
    
    dt = DateTimeHelper.addHoursToDT(dt, 27);
   double d = 1.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTimeHelper.addHoursToDT(dt, 0) ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 1.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   d = 0.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Unavailability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 0.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 2),
        Hours__c = 2.0,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   //insert availability for employee to transfer to...
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk1.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c) ,
        End__c = (DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c)).addDays(4),
        Hours__c = 36,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   insert diaryEntries;
   
    
    
    List<Job_Element__c> elements = new List<Job_Element__c>(); 
    elements.add(new Job_Element__c(
        Type__c = 'Work',
        Status__c = 'Active',
        Units__c = 3.6,
        Skill__c = 'Mechanical',
        Line_Item_Id__c = 'abc123',
        Product_Id__c = 'abc123',
        Job__c = j.Id,
        Current_Supplier__c = 'ABC123',
        Current_Supplier_Number__c = '123'
    
    ));
     elements.add(new Job_Element__c(
        Type__c = 'Work',
        Status__c = 'Active',
        Sub_Status__c = 'Awaiting Order',
        Units__c = 3.6,
        Skill__c = 'Mechanical',
        Line_Item_Id__c = 'abc123',
        Product_Id__c = 'abc123',
        Job__c = j.Id
           
    ));
    insert elements;
    
    diaryEntries = [Select Id, Job__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where  Week__c =: wk.Id];
    
   
    
    
    //now do the test
    //start with return work
    
    //invalid standard controller
    InstallPlanningReturnTransferController con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(wk));
    ApexPages.CurrentPage().getParameters().put('type','Plan additional');
    con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    ApexPages.CurrentPage().getParameters().put('type','Transfer');
    con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    
    
    System.assertEquals(null, con.userMessage);
    System.assertEquals(null, con.showUserMessage);
    System.assertEquals(false, con.isAvailabilityRendered);
    //System.AssertEquals(2, con.Items.size());
    //System.AssertEquals(0, con.selectedItems.size());
    System.AssertEquals('start', con.stepIndex);
    System.AssertEquals('Transfer', con.wizardType);
    
    
    //System.AssertEquals(0, con.getBreakdown().size());
    con.returnToDefine();
   // System.AssertEquals('define', con.stepIndex);
    con.returnToStart();
   // System.AssertEquals('start', con.stepIndex);
    con.returnToJob();
    
    con.defineWork();
    
    //select a job element to return
    for(InstallPlanningReturnTransferController.JobElementItem je : con.Items){
        system.debug('in forlo');
        je.isSelected = true;
    }
    
    /*for(InstallPlanningReturnTransferController.DiaryItem DI : con.DItems){
           DI.reduction = 0.5;
           DI.isSelected = true;
    }*/
    
    con.defineWork();
    con.selectAll = true;
    con.selectAll();
    con.calculateSelectedHours();
    con.remedial = true;
    //con.planRemedialJob();
    //System.AssertEquals('Mechanical', con.getHoursIds());
    
    
    //System.AssertEquals('define', con.stepIndex);
    //System.AssertEquals(2, con.selectedItems.size());
    con.getEmployeeBreakdown();
    InstallPlanningReturnTransferController.HoursInformation hi = con.getBreakdown().get(0);
    system.debug('@@@@'+hi);
    List<InstallPlanningReturnTransferController.EntryRecord> records = hi.entries;
    System.AssertEquals(1, records.size());
    //records.get(0).reduction = 1.3;
    //con.confirm();
    
    //con.confirmTransfer();
    
    records.get(0).reduction = 1;
        diaryEntries = [Select Id, Job__c, Record_Type__c, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
    
    
    system.debug(LoggingLevel.INFO, 'Old Diary Entries-');
    for(Diary_Entry__c en : diaryEntries){
        system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
        system.debug(LoggingLevel.INFO, 'End'+en.End__c);
        system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
        system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
        
    }
        
        Map<String, InstallPlanningReturnTransferController.HoursInformation> tData = new Map<String, InstallPlanningReturnTransferController.HoursInformation>();
       
       for(InstallPlanningReturnTransferController.HoursInformation h : con.getBreakdown()){
        h.Job.Customer_Preferred_Date__c = System.today().addDays(20).toStartOfWeek();
        h.Job.Named_Employee__c = transferTo;
        tData.put(h.skill, h);
       }
        con.checkAvailability();
        con.confirmTransfer();
    
        diaryEntries = [Select Id, Job__c, RecordTypeId, d.Record_Type__c , Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
        system.debug(LoggingLevel.INFO, 'New Diary Entries-');
        for(Diary_Entry__c en : diaryEntries){
            system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
            system.debug(LoggingLevel.INFO, 'End'+en.End__c);
            system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
            system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
            
        }  
        hi.RemoveDiaryEntry(diaryEntries[0]);

    delete Acc;
    delete e;
    delete e1;
   }
      //Test class to ensure the page renders as expected
    //Test class to ensure the page renders as expected
   static TestMethod void testerReturn(){
    
    //create a new job
    //mechhours = 12
    //only assign 2.8 hours to employee
    
   ID districtID = TestScenarioCreateDistrict();
    Account Acc = TestScenarioCreateAccount(districtID);
    Opportunity opty = TestScenarioCreateOppty(Acc);
    
    Job__c j = new Job__c();
    j.CHI_Lead__c = opty.Id;
    j.Status__c = 'Planned';
    j.Mechanical_Hours__c = 12;
    
    insert j;
    Supplier__c supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
    insert supplier;
    
    Employee__c e = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc123', 
        Resource_Type__c='Installer',
        X3G_phone_Number__c = 'Pay Monthly',
        Supplier__c = supplier.Id,
        Pool_Diary__c = false);
    insert e;
    
    Employee_Skills__c es = new Employee_Skills__c(Employee__c = e.Id, Skill_Name__c='Mechanical');
    insert es; 
    
    //List<Employee_Skills__c> skills = [Select e.Skill_Name__c, e.Employee__c, e.Employee__r.Supplier__c From Employee_Skills__c e where skill_Name__c= 'Mechanical' and e.Employee__r.Supplier__c!= null limit 2];
    //Id transferTo = skills.get(1).Employee__c;
    Id transferTo = e.Id;
    Shift_Pattern__c shift = new Shift_Pattern__c(Name='Testing Shift Pattern1', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
    Database.insert(shift);
    Week__c wk;
    List<Week__c> weeks = new List<Week__c>();
    //add Mechanical entries
    //for(Employee_Skills__c sk : skills){
    //  if(sk.Skill_Name__c == 'Mechanical'){
            wk = new Week__c(
                Employee__c = e.Id,
                Week_Commencing__c = System.today().addDays(20).toStartOfWeek(),
                Shift_Pattern__c = shift.Id,
                Monday_Max_Hours__c = 9.0,
                Tuesday_Max_Hours__c = 9.0,
                Wednesday_Max_Hours__c = 9.0,
                Thursday_Max_Hours__c = 9.0,
                Friday_Max_Hours__c = 9.0,
                Saturday_Max_Hours__c = 9.0,
                Sunday_Max_Hours__c = 9.0
            );
            weeks.add(wk);
    //  }
    //}
    
    
    insert weeks;
    wk = weeks.get(0);
    
    List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
    DateTime dt;
    dt = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c);
    diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Mechanical',
        Job__c = j.Id,
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 27),//adding a bit more to allow move overnight
        Hours__c = 12,
        
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking')
    ));
    
    dt = DateTimeHelper.addHoursToDT(dt, 27);
   double d = 1.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTimeHelper.addHoursToDT(dt, 0) ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 1.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   d = 0.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Unavailability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 0.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 2),
        Hours__c = 2.0,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   //insert availability for employee to transfer to...
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c) ,
        End__c = (DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c)).addDays(4),
        Hours__c = 36,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   insert diaryEntries;
   
    
    
    List<Job_Element__c> elements = new List<Job_Element__c>(); 
    elements.add(new Job_Element__c(
        Type__c = 'Work',
        Status__c = 'Active',
        Units__c = 3.6,
        Skill__c = 'Mechanical',
        Line_Item_Id__c = 'abc123',
        Product_Id__c = 'abc123',
        Job__c = j.Id,
        Current_Supplier__c = 'ABC123',
        Current_Supplier_Number__c = '123'
    
    ));
    
    insert elements;
    
    diaryEntries = [Select Id, Job__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where  Week__c =: wk.Id];
    
   
    
    
    //now do the test
    //start with return work
    
    //invalid standard controller
    InstallPlanningReturnTransferController con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    ApexPages.CurrentPage().getParameters().put('type','Transfer');
    con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    
    
    System.assertEquals(null, con.userMessage);
    System.assertEquals(null, con.showUserMessage);
    System.assertEquals(false, con.isAvailabilityRendered);
    //System.AssertEquals(1, con.Items.size());
    //System.AssertEquals(0, con.selectedItems.size());
    //System.AssertEquals('start', con.stepIndex);
   // System.AssertEquals('Transfer', con.wizardType);
    
    
    //System.AssertEquals(0, con.getBreakdown().size());
    con.returnToDefine();
    //System.AssertEquals('define', con.stepIndex);
    con.returnToStart();
   // System.AssertEquals('start', con.stepIndex);
    con.returnToJob();
    
    con.defineWork();
    
    //select a job element to return
    for(InstallPlanningReturnTransferController.JobElementItem je : con.Items){
        je.isSelected = true;
    }
    /*for(InstallPlanningReturnTransferController.DiaryItem DI : con.DItems){
           DI.reduction = 1;
           DI.isSelected = true;
    }*/
    con.defineWork();
    //System.AssertEquals('Mechanical', con.getHoursIds());
    
    
    //System.AssertEquals('define', con.stepIndex);
    //System.AssertEquals(1, con.selectedItems.size());
    
    InstallPlanningReturnTransferController.HoursInformation hi = con.getBreakdown().get(0);
    List<InstallPlanningReturnTransferController.EntryRecord> records = hi.entries;
    //System.AssertEquals(1, records.size());
    //records.get(0).reduction = 1.3;
    //con.confirm();
    
    //con.confirmTransfer();
    
    records.get(0).reduction = 10;
        diaryEntries = [Select Id, Job__c, Record_Type__c, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
    
    
    system.debug(LoggingLevel.INFO, 'Old Diary Entries-');
    for(Diary_Entry__c en : diaryEntries){
        system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
        system.debug(LoggingLevel.INFO, 'End'+en.End__c);
        system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
        system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
        
    }
        
        Map<String, InstallPlanningReturnTransferController.HoursInformation> tData = new Map<String, InstallPlanningReturnTransferController.HoursInformation>();
       
       for(InstallPlanningReturnTransferController.HoursInformation h : con.getBreakdown()){
        h.Job.Customer_Preferred_Date__c = System.today().addDays(20).toStartOfWeek();
        h.Job.Named_Employee__c = transferTo;
        tData.put(h.skill, h);
       }
        con.confirm();
    
        diaryEntries = [Select Id, Job__c, RecordTypeId, d.Record_Type__c , Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
        system.debug(LoggingLevel.INFO, 'New Diary Entries-');
        for(Diary_Entry__c en : diaryEntries){
            system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
            system.debug(LoggingLevel.INFO, 'End'+en.End__c);
            system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
            system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
            
        }  
        hi.RemoveDiaryEntry(diaryEntries[0]);

    
   }
   //Added By Ashok G..
   static TestMethod void testerReturn1(){
    
    //create a new job
    //mechhours = 12
    //only assign 2.8 hours to employee
    
   ID districtID = TestScenarioCreateDistrict();
    Account Acc = TestScenarioCreateAccount(districtID);
    Opportunity opty = TestScenarioCreateOppty(Acc);
    
    Job__c j = new Job__c();
    j.CHI_Lead__c = opty.Id;
    j.Status__c = 'Planned';
    j.Mechanical_Hours__c = 12;
    
    insert j;
    Supplier__c supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
    insert supplier;
    
    Employee__c e = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc123', 
        Resource_Type__c='Installer',
        X3G_phone_Number__c = 'Pay Monthly',
        Supplier__c = supplier.Id,
        Pool_Diary__c = false);
    insert e;
    
    Employee_Skills__c es = new Employee_Skills__c(Employee__c = e.Id, Skill_Name__c='Mechanical');
    insert es; 
    
    //List<Employee_Skills__c> skills = [Select e.Skill_Name__c, e.Employee__c, e.Employee__r.Supplier__c From Employee_Skills__c e where skill_Name__c= 'Mechanical' and e.Employee__r.Supplier__c!= null limit 2];
    //Id transferTo = skills.get(1).Employee__c;
    Id transferTo = e.Id;
    Shift_Pattern__c shift = new Shift_Pattern__c(Name='Testing Shift Pattern1', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
    Database.insert(shift);
    Week__c wk;
    List<Week__c> weeks = new List<Week__c>();
    //add Mechanical entries
    //for(Employee_Skills__c sk : skills){
    //  if(sk.Skill_Name__c == 'Mechanical'){
            wk = new Week__c(
                Employee__c = e.Id,
                Week_Commencing__c = System.today().addDays(20).toStartOfWeek(),
                Shift_Pattern__c = shift.Id,
                Monday_Max_Hours__c = 9.0,
                Tuesday_Max_Hours__c = 9.0,
                Wednesday_Max_Hours__c = 9.0,
                Thursday_Max_Hours__c = 9.0,
                Friday_Max_Hours__c = 9.0,
                Saturday_Max_Hours__c = 9.0,
                Sunday_Max_Hours__c = 9.0
            );
            weeks.add(wk);
    //  }
    //}
    
    
    insert weeks;
    wk = weeks.get(0);
    
    List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
    DateTime dt;
    dt = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c);
    diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Mechanical',
        Job__c = j.Id,
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 27),//adding a bit more to allow move overnight
        Hours__c = 12,
        overbooked_hours__c=3,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking')
    ));
    
    dt = DateTimeHelper.addHoursToDT(dt, 27);
   double d = 1.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTimeHelper.addHoursToDT(dt, 0) ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 1.5,
        overbooked_Hours__c = 1,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   d = 0.5;
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Unavailability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, d),
        Hours__c = 0.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, d);
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 2),
        Hours__c = 2.0,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   //insert availability for employee to transfer to...
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c) ,
        End__c = (DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c)).addDays(4),
        Hours__c = 36,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   insert diaryEntries;
   
    
    
    List<Job_Element__c> elements = new List<Job_Element__c>(); 
    elements.add(new Job_Element__c(
        Type__c = 'Work',
        Status__c = 'Active',
        Units__c = 3.6,
        Skill__c = 'Mechanical',
        Line_Item_Id__c = 'abc123',
        Product_Id__c = 'abc123',
        Job__c = j.Id,
        Current_Supplier__c = 'ABC123',
        Current_Supplier_Number__c = '123'
    
    ));
    
    insert elements;
    
    diaryEntries = [Select Id, Job__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where  Week__c =: wk.Id];
    
   
    
    
    //now do the test
    //start with return work
    
    //invalid standard controller
    InstallPlanningReturnTransferController con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    ApexPages.CurrentPage().getParameters().put('type','DETransfer');
    con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    
    
    System.assertEquals(null, con.userMessage);
    System.assertEquals(null, con.showUserMessage);
    System.assertEquals(false, con.isAvailabilityRendered);
    //System.AssertEquals(1, con.Items.size());
    //System.AssertEquals(0, con.selectedItems.size());
    //System.AssertEquals('start', con.stepIndex);
   // System.AssertEquals('Transfer', con.wizardType);
    
    
    //System.AssertEquals(0, con.getBreakdown().size());
    con.returnToDefine();
    //System.AssertEquals('define', con.stepIndex);
    con.returnToStart();
   // System.AssertEquals('start', con.stepIndex);
    con.returnToJob();
    
    con.defineWork();
    
    //select a job element to return
    
    for(InstallPlanningReturnTransferController.DiaryItem DI : con.DItems){
           if(DI.DE.sub_Type__c == 'Mechanical')
           DI.reduction = 3;
           
           
    }
    con.defineWork();
    //System.AssertEquals('Mechanical', con.getHoursIds());
    con.dummyjob.Named_Employee__c = transferto;
    con.dummyjob.Customer_Preferred_date__c = System.today().addDays(20).toStartOfWeek();
    
    con.checkavailability();
    con.confirmTransfer();
    
    //System.AssertEquals('define', con.stepIndex);
    //System.AssertEquals(1, con.selectedItems.size());
    
    InstallPlanningReturnTransferController.HoursInformation hi = con.getBreakdown().get(0);
    List<InstallPlanningReturnTransferController.EntryRecord> records = hi.entries;
    //System.AssertEquals(1, records.size());
    //records.get(0).reduction = 1.3;
    //con.confirm();
    
    //con.confirmTransfer();
    
    
    
    
    

    
   }
   
    static testmethod Opportunity TestScenarioCreateOppty(){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar');        
        insert opty;        
        return opty;
    }
    
    
    static testmethod ID TestScenarioCreateDistrict(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        return district.ID;
    }
    
          
   static Account TestScenarioCreateAccount(Id districtID){
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=districtID, Code__c='yyyyyyyy');             
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
            
   static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    } 
}