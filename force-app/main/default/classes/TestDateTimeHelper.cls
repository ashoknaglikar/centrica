@isTest
private class TestDateTimeHelper {

	static Week__c setupForDEs(Employee__c emp) {
		Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
													Monday_Start_Time__c = '09:00', Monday_End_Time__c = '17:00',
													Tuesday_Start_Time__c = '09:00', Tuesday_End_Time__c = '17:00',
													Wednesday_Start_Time__c = '09:00', Wednesday_End_Time__c = '17:00',
													Thursday_Start_Time__c = '09:00', Thursday_End_Time__c = '17:00',
													Friday_Start_Time__c = '09:00', Friday_End_Time__c = '17:00',
													Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
													Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
		Database.insert(sp);
		
		Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = sp.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
								Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
								Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
		Database.insert(w);

		w = [select w.Week_Commencing__c, w.Monday_Start_Time__c, w.Monday_End_Time__c, w.Tuesday_Start_Time__c, w.Tuesday_End_Time__c,
					w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, 
					w.Friday_Start_Time__c, w.Friday_End_Time__c, w.Saturday_Start_Time__c, w.Saturday_End_Time__c,
					w.Sunday_Start_Time__c, w.Sunday_End_Time__c
					from Week__c w where w.ID = :w.ID];

		return w;
	}

	static List<Diary_Entry__c> insertDEs(List<Diary_Entry__c> des) {
		Database.insert(des);
		Set<ID> deIDs = new Set<ID>();
		for(Diary_Entry__c de : des) {
			deIDs.add(de.ID);
		}
		
		List<Diary_Entry__c> fromDB = 
			[select d.ID,
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
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c, d.Hours__c
				from Diary_Entry__c d where d.Id IN :deIDs];
		return fromDB;
	}

	static List<Diary_Entry__c> createDE() {
		Employee__c emp = setupJobAndEmployee();
		Week__c w = setupForDEs(emp);
		
		// Create some diary entries
		Date startOfNextWeek = Date.today().addDays(7).toStartOfWeek();
		
		Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
									Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(9,0,0,0)), 
									End__c = DateTime.newInstance(startOfNextWeek.addDays(4), Time.newInstance(17,0,0,0)), 
									RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

		// Insert them with
		return insertDEs(new List<Diary_Entry__c>{de1});
	}

	static Week__c createWeek() {
		Employee__c emp = setupJobAndEmployee();
		Week__c w = setupForDEs(emp);
		return w;
	}

	static Employee__c setupJobAndEmployee() {
		Phase3TestHelper.createSearchParameters();
    	Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions(job);
		sbb.setOptions(bbo);
		
		// Create Employee and Employee Information object
        Employee__c emp = Phase3TestHelper.createEmployee();
        EmployeeInformation ei = new EmployeeInformation(emp);
        return emp;
	}

    static testMethod void calculateHoursDETest() {
        List<Diary_Entry__c> des = createDE();
        
        // Coverage only, calculate hours tested in calculateHoursShiftsTest
        DateTimeHelper.calculateHours(des[0].Start__c, des[0].End__c, des[0]);
    }
    
    static testMethod void calculateHoursWeekTest() {
    	Week__c w = createWeek();
        // Coverage only, calculate hours tested in calculateHoursShiftsTest
        Date d = w.Week_Commencing__c;
        
        DateTimeHelper.calculateHours(Datetime.newInstance(d, Time.newInstance(10,0,0,0)), 
        													Datetime.newInstance(d, Time.newInstance(12,0,0,0)), w);
        
    }
    
    static testMethod void calculateHoursShiftsTest() {
    	List<List<String>> shifts = new List<List<String>>{
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {null, null},
    										new List<String> {null, null}};
    	Date d = Date.today().addDays(7).toStartOfWeek();
    	DateTime dt1 = DateTime.newInstance(d, Time.newInstance(12,0,0,0));
    	DateTime dt2 = DateTime.newInstance(d, Time.newInstance(12,0,0,0));
    	
        // Start == end
		Double result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 0);
		
        // Start == end after normalisation
		dt1 = DateTime.newInstance(d, Time.newInstance(21,0,0,0));
		dt2 = DateTime.newInstance(d, Time.newInstance(21,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 0);
		
		dt1 = DateTime.newInstance(d, Time.newInstance(5,0,0,0));
		dt2 = DateTime.newInstance(d, Time.newInstance(5,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 0);
		
		dt1 = DateTime.newInstance(d, Time.newInstance(21,0,0,0));
		dt2 = DateTime.newInstance(d.addDays(1), Time.newInstance(5,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 0);
		
		dt1 = DateTime.newInstance(d, Time.newInstance(5,0,0,0));
		dt2 = DateTime.newInstance(d, Time.newInstance(21,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 8);
		
        // Start and end on same day
        dt1 = DateTime.newInstance(d, Time.newInstance(12,0,0,0));
		dt2 = DateTime.newInstance(d, Time.newInstance(14,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 2);
        
		// Start and end on different days
		dt1 = DateTime.newInstance(d, Time.newInstance(12,0,0,0));
		dt2 = DateTime.newInstance(d.addDays(1), Time.newInstance(14,0,0,0));
		result = DateTimeHelper.calculateHours(dt1, dt2, shifts);
		System.assertEquals(result, 10);
    }
    
    // brm - 13-01-2010 - test method to check rounding problem
    static testmethod void calculateHoursRoundingTest()
    {
    	List<List<String>> shifts = new List<List<String>>{
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {'09:00', '17:00'},
    										new List<String> {null, null},
    										new List<String> {null, null}};
    	
    	System.debug('--------------------- plus 40 minutes: ');
    	
    	DateTime startDt = DateTime.newInstance(2010, 1, 15, 16, 0, 0);
    	System.debug('--------------------- start date: ' + startDt);
    	DateTime endDt = startDt.addMinutes(40);
    	System.debug('--------------------- end date: ' + endDt);
    	
		Double hrs = DateTimeHelper.calculateHours(startDt, endDt, shifts);
		system.assertequals(0.67, hrs);
		System.debug('--------------------- calculated hours: ' + hrs);
		
		
		System.debug('--------------------- plus 20 minutes: ');
		
		startDt = DateTime.newInstance(2010, 1, 15, 16, 0, 0);
    	System.debug('--------------------- start date: ' + startDt);
    	endDt = startDt.addMinutes(20);
    	System.debug('--------------------- end date: ' + endDt);
    	
		hrs = DateTimeHelper.calculateHours(startDt, endDt, shifts);
		system.assertequals(0.33, hrs);
		System.debug('--------------------- calculated hours: ' + hrs);
    }
    
    static testMethod void addWorkingHoursToDateTimeTest() {
    	List<Diary_Entry__c> des = createDE();
    	System.debug('des[0].Start__c: ' + des[0].Start__c);
    	
        // hoursToAdd == 0.0
        DateTime dt = DateTimeHelper.addWorkingHoursToDateTime(des[0].Start__c, 0.0, des[0]);
        System.assertEquals(dt, des[0].Start__c);
        
        // hoursToAdd != 0.0
        dt = DateTimeHelper.addWorkingHoursToDateTime(des[0].Start__c, 10.0, des[0]);
        System.assertEquals(dt, Datetime.newInstance(des[0].Start__c.date().addDays(1), Time.newInstance(11,0,0,0)));
    }
    
    static testMethod void sameWeekTest() {
		Datetime dt1 = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,0,0,0));
		Datetime dt2 = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,0,0,0));
		
		System.assertEquals(true, DateTimeHelper.sameWeek(dt1, dt2));
		
		dt1 = Datetime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(12,0,0,0));
		System.assertEquals(false, DateTimeHelper.sameWeek(dt1, dt2));
		
		dt1 = DateTime.newInstance(Date.today().addDays(14).toStartOfWeek(), Time.newInstance(12,0,0,0));
		System.assertEquals(false, DateTimeHelper.sameWeek(dt1, dt2));
		
		System.assertEquals(true, DateTimeHelper.sameWeek(Datetime.now(), Datetime.now()));
		
    }
    
    static testMethod void normaliseDateTimeTest() {
    	List<List<String>> shifts = new List<List<String>>{
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {null, null},
									new List<String> {null, null}};
		Date d = Date.today().addDays(7).toStartOfWeek();
    	
    	// After end
    	DateTime dt1 = DateTime.newInstance(d, Time.newInstance(17,1,0,0));
    	DateTime result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(result, DateTime.newInstance(d.addDays(1), Time.newInstance(9,0,0,0)));
    	
    	// Equal to end
    	dt1 = DateTime.newInstance(d, Time.newInstance(17,0,0,0));
    	result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(result, DateTime.newInstance(d, Time.newInstance(17,0,0,0)));
    	
    	// Before start
    	dt1 = DateTime.newInstance(d.addDays(1), Time.newInstance(5,0,0,0));
    	result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(result, DateTime.newInstance(d.addDays(1), Time.newInstance(9,0,0,0)));
    	
    	// equal to start
    	dt1 = DateTime.newInstance(d.addDays(1), Time.newInstance(9,0,0,0));
    	result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(result, DateTime.newInstance(d.addDays(1), Time.newInstance(9,0,0,0))); 
    }
    
    static testMethod void hoursBetweenShiftsTest() {
        Double result = DateTimeHelper.hoursBetweenShifts('17:00','08:00');
        System.assertEquals(result, 15);
    }
    
    static testMethod void hoursBetweenStartEndHoursTest() {
        Double result = DateTimeHelper.hoursBetweenStartEndHours('08:00', '17:00');
        System.assertEquals(result, 9);
    }
    
    static testMethod void normaliseDateTimeTest1() {
    	List<List<String>> shifts = new List<List<String>>{
									new List<String> {'09:00', '17:00'},
									new List<String> {null, null},
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {'09:00', '17:00'},
									new List<String> {null, null},
									new List<String> {null, null}};
		Date d = Date.today().addDays(7).toStartOfWeek();
    
    	// After end
    	DateTime dt1 = DateTime.newInstance(d, Time.newInstance(17,1,0,0));
    	DateTime result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(DateTime.newInstance(d.addDays(2), Time.newInstance(9,0,0,0)), result);
    	
    	//before start
    	dt1 = DateTime.newInstance(d, Time.newInstance(8,0,0,0));
    	result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(DateTime.newInstance(d, Time.newInstance(9,0,0,0)), result);
    	
    	
    	// After end on last day
    	dt1 = DateTime.newInstance(d.addDays(6), Time.newInstance(17,0,0,0));
    	try{
    		result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	}catch(Exception ex){}
    	
    	// valid
    	dt1 = DateTime.newInstance(d, Time.newInstance(9,0,0,0));
    	result = DateTimeHelper.normaliseDateTime(dt1, shifts);
    	System.assertEquals(DateTime.newInstance(d, Time.newInstance(9,0,0,0)), result); 
    }
}