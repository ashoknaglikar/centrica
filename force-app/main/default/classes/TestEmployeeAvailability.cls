@isTest
private class TestEmployeeAvailability {

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
                                Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null, Morning_Start_Time__c = '08:00', Mid_day_Start_Time__c = '12:00');
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
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c, Week__r.Morning_Start_Time__c, Week__r.Mid_day_Start_Time__c
                from Diary_Entry__c d where d.Id IN :deIDs];
        return fromDB;
    }
    
    static List<Diary_Entry__c> createDEs1(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        
        // Create some diary entries
        Date startOfNextWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek.addDays(4), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

        // Insert them with
        return insertDEs(new List<Diary_Entry__c>{de1});
    }

    static List<Diary_Entry__c> createDEs2(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        
        // Create some diary entries
        Date startOfNextWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));

        // Insert them with
        return insertDEs(new List<Diary_Entry__c>{de1});
    }
    
    static List<Diary_Entry__c> createDEs3(Employee__c emp) {
        Week__c w = setupForDEs(emp);
        
        // Create some diary entries
        Date startOfNextWeek = Date.today().addDays(7).toStartOfWeek();
        
        Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

        Diary_Entry__c de2 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(17,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek.addDays(1), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
                                    
        Diary_Entry__c de3 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek.addDays(2), Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek.addDays(2), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
        
        Diary_Entry__c de4 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
                                    Start__c = DateTime.newInstance(startOfNextWeek.addDays(8), Time.newInstance(8,0,0,0)), 
                                    End__c = DateTime.newInstance(startOfNextWeek.addDays(8), Time.newInstance(17,0,0,0)), 
                                    RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
        // Insert them with
        return insertDEs(new List<Diary_Entry__c>{de1, de2, de3, de4});
    }
    
    static testMethod void addAvailabilityTest1() {
        
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);

        // One DE
        List<Diary_Entry__c> des = createDEs1(emp);
        EmployeeAvailability ea = new EmployeeAvailability(ei);
        ea.addAvailability(des, true);
    }

    static testMethod void addAvailabilityTest2() {
        
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);

        // One DE != SearchBlackBox.GAP_DIARY_ENTRY_TYPE
        List<Diary_Entry__c> des = createDEs2(emp);
        EmployeeAvailability ea = new EmployeeAvailability(ei);
        ea.addAvailability(des, false);
    }

    static testMethod void addAvailabilityTest3() {
        
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        // More than one DE with Adjacent DEs, with DEs in more than one week, 
        // and in same week with non-adjacent DEs
        List<Diary_Entry__c> des = createDEs3(emp);
        EmployeeAvailability ea = new EmployeeAvailability(ei);
        ea.addAvailability(des, true);
    }

    static testMethod void methodsTest1() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);

        // One DE
        List<Diary_Entry__c> des = createDEs1(emp);
        EmployeeAvailability ea = new EmployeeAvailability(ei);
        ea.addAvailability(des, true);
        
        ea.getEarliest(true);
        ea.getLargest(true);
        ea.getDECs(true);
    }
    
    static testMethod void methodsTest2() {
        // Create SearchBlackBox and BlackBoxOptions
        SearchBlackBox sbb = setupSBB();
        
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);

        // One DE
        List<Diary_Entry__c> des = createDEs1(emp);
        EmployeeAvailability ea = new EmployeeAvailability(ei);
        ea.addAvailability(des, false);
        
        ea.getEarliest(false);
        ea.getLargest(false);
        ea.getDECs(false);
        des.clear();
        ea.addAvailability(des, false);
        
        ea.print();
    }
}