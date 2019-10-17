@isTest
private class TestResourceOption {

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
			[select d.ID, d.Week__r.Shift_Pattern__r.Monday_Start_Time__c, d.Week__r.Shift_Pattern__r.Monday_End_Time__c,
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
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c, d.Hours__c,Week__r.Morning_Start_Time__c, Week__r.Mid_day_Start_Time__c
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

    static testMethod void constructorTest1() {
    	Phase3TestHelper.createSearchParameters();
    	Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);
    	
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
		ei.skillsAndHours.put('MECHANICAL', 2.0);
        
        // One DE
		List<Diary_Entry__c> des = createDEs1(emp);
		System.debug('des[0].hours: ' + des[0].Hours__c);
		List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, ei);
		System.debug('decs[0].numberOfHours: ' + decs[0].numberOfHours);
		
		ResourceOption ro = new ResourceOption(new Set<String>{'MECHANICAL'}, decs[0], ei, ji);
    }
    
    // The constructor tested in this test is no longer present.
    /*static testMethod void constructorTest2() {
		Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);
    	
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
		ei.skillsAndHours.put('MECHANICAL', 2.0);
        
        // One DE
		List<Diary_Entry__c> des = createDEs1(emp);
		System.debug('des[0].hours: ' + des[0].Hours__c);
		List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, ei);
		System.debug('decs[0].numberOfHours: ' + decs[0].numberOfHours);
		
		Date adjustedDate = Date.today().addDays(7).toStartOfWeek().addDays(1);
		Time adjustedTime = Time.newInstance(13,0,0,0);
		Datetime adjustedStart = Datetime.newInstance(adjustedDate, adjustedTime);
		ResourceOption ro = new ResourceOption(new Set<String>{'MECHANICAL'}, decs[0], ei, ji, adjustedStart);
    }*/
    
    static testMethod void constructorTest3() {
    	Phase3TestHelper.createSearchParameters();
		Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);
    	
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
		ei.skillsAndHours.put('MECHANICAL', 2.0);
        
        // One DE
		List<Diary_Entry__c> des = createDEs1(emp);
		System.debug('des[0].hours: ' + des[0].Hours__c);
		List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, ei);
		System.debug('decs[0].numberOfHours: ' + decs[0].numberOfHours);
		
		ResourceOption ro1 = new ResourceOption(new Map<String, Double>{'MECHANICAL' => 1.0}, decs[0], ei, ji, 0.0);
		ResourceOption ro2 = new ResourceOption(new Map<String, Double>{'MECHANICAL' => 1.0}, decs[0], ei, ji, 1.0);
    }
    
    static testMethod void constructorTest4() {
    	Phase3TestHelper.createSearchParameters();
		Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);
    	
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
		ei.skillsAndHours.put('MECHANICAL', 2.0);
        
        // One DE
		List<Diary_Entry__c> des = createDEs1(emp);
		System.debug('des[0].hours: ' + des[0].Hours__c);
		List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, ei);
		System.debug('decs[0].numberOfHours: ' + decs[0].numberOfHours);
		
		ResourceOption ro1 = new ResourceOption(new Set<String>{'MECHANICAL'}, decs[0], ei, ji, 0.0);
		ResourceOption ro2 = new ResourceOption(new Set<String>{'MECHANICAL'}, decs[0], ei, ji, 1.0);
    }
    
    static testMethod void methodsTest() {
        Phase3TestHelper.createSearchParameters();
    	Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);
    	
        // Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
		ei.skillsAndHours.put('MECHANICAL', 2.0);
        
        // One DE
		List<Diary_Entry__c> des = createDEs1(emp);
		System.debug('des[0].hours: ' + des[0].Hours__c);
		List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, ei);
		System.debug('decs[0].numberOfHours: ' + decs[0].numberOfHours);
		
		ResourceOption ro = new ResourceOption(new Set<String>{'MECHANICAL'}, decs[0], ei, ji);
		ro.print();
		ro.toSearchResults(Datetime.now().format()+'-0');
    }
}