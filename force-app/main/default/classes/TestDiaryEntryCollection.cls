@isTest
private class TestDiaryEntryCollection {

    static SearchBlackBox setupSBB() {
        Phase3TestHelper.createSearchParameters();
        Job__c job = Phase3TestHelper.createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions();
        sbb.setOptions(bbo);
        return sbb;
    }
    
    static Week__c setupForDEs(Employee__c emp) {
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Database.insert(sp);
        
        Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = sp.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
                                Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
                                Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null,Morning_Start_Time__c=null,Mid_day_Start_Time__c=null);
        Database.insert(w);

        return w;
    }
    
    static Week__c setupForPoolDEs(Employee__c emp) {
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = true, Total_Hours__c = '500',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '18:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '18:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '18:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '18:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '18:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null,
                                                    Monday_Max_Hours__c = 100, Tuesday_Max_Hours__c = 100,
                                                    Wednesday_Max_Hours__c = 100, Thursday_Max_Hours__c = 100,
                                                    Friday_Max_Hours__c = 100, Saturday_Max_Hours__c = 100,
                                                    Sunday_Max_Hours__c = 100);
        Database.insert(sp);
        
        Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = sp.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
                                Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
                                Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
        Database.insert(w);

        return w;
    }
    
    static List<Diary_Entry__c> insertDEs(List<Diary_Entry__c> des) {
        Database.insert(des);
        Set<ID> deIDs = new Set<ID>();
        for(Diary_Entry__c de : des) {
            deIDs.add(de.ID);
        }
        
        List<Diary_Entry__c> fromDB = 
            [select d.ID, d.Hours__c, d.Week__r.Shift_Pattern__r.Monday_Start_Time__c, d.Week__r.Shift_Pattern__r.Monday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Tuesday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Wednesday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, d.Week__r.Shift_Pattern__r.Thursday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Friday_Start_Time__c, d.Week__r.Shift_Pattern__r.Friday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, d.Week__r.Shift_Pattern__r.Saturday_End_Time__c,
                    d.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, d.Week__r.Shift_Pattern__r.Sunday_End_Time__c,
                    d.Week__r.Monday_Available_Hours__c, d.Week__r.Tuesday_Available_Hours__c,
                    d.Week__r.Wednesday_Available_Hours__c, d.Week__r.Thursday_Available_Hours__c,
                    d.Week__r.Friday_Available_Hours__c, d.Week__r.Saturday_Available_Hours__c,
                    d.Week__r.Sunday_Available_Hours__c, d.Record_Type__c, d.Start__c, d.End__c,
                    d.Week__r.Monday_Start_Time__c, d.Week__r.Monday_End_Time__c,
                    d.Week__r.Tuesday_Start_Time__c, d.Week__r.Tuesday_End_Time__c,
                    d.Week__r.Wednesday_Start_Time__c, d.Week__r.Wednesday_End_Time__c,
                    d.Week__r.Thursday_Start_Time__c, d.Week__r.Thursday_End_Time__c,
                    d.Week__r.Friday_Start_Time__c, d.Week__r.Friday_End_Time__c,
                    d.Week__r.Saturday_Start_Time__c, d.Week__r.Saturday_End_Time__c,
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c,
                    d.week__r.Mid_day_Start_Time__c, d.Week__r.Morning_Start_Time__c
                from Diary_Entry__c d where d.Id IN :deIDs];
        return fromDB;
    }
    
    static List<Diary_Entry__c> createDEs1(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

        return insertDEs(new List<Diary_Entry__c> {de1});
    }
    
    static List<Diary_Entry__c> createDEs2(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));

        return insertDEs(new List<Diary_Entry__c> {de1});
    }

    static List<Diary_Entry__c> createDEs3(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
        Diary_Entry__c de2 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek.addDays(1), Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(1), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));

        return insertDEs(new List<Diary_Entry__c> {de1, de2});
    }
    
        static List<Diary_Entry__c> createDEs4(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
        Diary_Entry__c de2 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek.addDays(8), Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(8), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));

        return insertDEs(new List<Diary_Entry__c> {de1, de2});
    }
    
    static List<Diary_Entry__c> createPoolDEs1(Employee__c emp) {
        Week__c w = setupForPoolDEs(emp);
        Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

        return insertDEs(new List<Diary_Entry__c> {de1});
    }
    
    static testMethod void createDECsTest1() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs1(emp);
         
        // Testing: Availability
        // Testing: isBusiness == true
        // Testing: No unavailability
        DiaryEntryCollection.createDECs(entries, true, ei);
        // Testing: isBusiness == false
        DiaryEntryCollection.createDECs(entries, false, ei);
    }
    
    static testMethod void createDECsTest2() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs2(emp);
        
        // Alternate flows:
        // Testing: No availability
        DiaryEntryCollection.createDECs(entries, true, ei);
        
    }
    
    static testMethod void createDECsTest3() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs3(emp);
        
        // Alternate flows:
        // Testing: Availability and unavailability
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
        
        // Testing: print() 
        decs[0].print();
        
    }

    static testMethod void createDECsTest4() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs4(emp);
        
        // Alternate flows:
        // Testing: Availability and unavailability that don't overlap
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
    }
    
    static testMethod void constructorTest1() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs1(emp);
        DiaryEntryCollection dec = new DiaryEntryCollection(entries[0]);
    }
    
    static testMethod void addWorkingHoursTest() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs1(emp);
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
        decs[0].addWorkingHoursToStart(0);
        decs[0].addWorkingHoursToStart(100);
        decs[0].addWorkingHoursToStart(10);
    }
    
    static testMethod void getGapIDTest() {
       // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs1(emp);
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
        System.assertEquals(decs[0].getGapID(Datetime.now()), null);
        ID res = decs[0].getGapID(decs[0].startDT);
        System.assertEquals(res, entries[0].ID);
    }

    
    static testMethod void workingHoursBetweenTest() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createDEs1(emp);
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
        Double a = decs[0].workingHoursBetween(decs[0].startDT, decs[0].finishDT);
        System.assertEquals(a, 45);
    }
    
    static testMethod void poolTest() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createPoolEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        System.debug('ei.isPool: ' + ei.isPool);
        
        // Create Diary Entries
        List<Diary_Entry__c> entries = createPoolDEs1(emp);
        List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(entries, true, ei);
        decs[0].addWorkingHoursToStart(2);
    }   
    
    /*
        ToDo
        Create tests to check past and future DEs
        Check what's created to make sure it makes sense!
    */
    
    
}