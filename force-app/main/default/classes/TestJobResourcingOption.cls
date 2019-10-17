@isTest
private class TestJobResourcingOption {
	
	static Week__c setupForDEs(EmployeeInformation emp) {
		Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
													Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
													Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
													Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
													Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
													Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
													Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
													Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
		Database.insert(sp);
		
		Week__c w = new Week__c(Employee__c = emp.employeeID, Shift_Pattern__c = sp.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
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

	static Employee__c createEmployee(String firstName, String secondName, String empNum, ID districtID, ID supplierID) {
		
		Employee__c emp = new Employee__c(Name = firstName + ' ' + secondName, First_Name__c = firstName, Last_Name__c = secondName,
											Employee_Number__c = empNum, Resource_Type__c= 'Installer', Inactive__c = false,
											Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
											Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
											District__c = districtId, Net_Promoter_Score__c = 10, Supplier__c = supplierID,Postcode__c = 'ab1 cd1');
		
		return emp;
		
	}
	
	static List<Employee__c> insertEmployees(List<Employee__c> toInsert) {
		Database.insert(toInsert);
		
		Set<ID> empIDs = new Set<ID>();
		
		for(Employee__c e : toInsert) {
			empIDs.add(e.ID);
		}
		
		List<Employee__c> fromDB = 
				[Select e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__c, e.Resource_Type__c, e.Resource_Id__c, 
				e.Region__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, e.Name, 
				e.Manager__c, e.Last_Name__c, e.Inactive__c, e.Id, e.Group__c,e.First_Name__c, e.End_Date__c, e.Employee_Record_ID__c, 
				e.Employee_Number__c, e.Emp_type__c, e.Email__c, e.District__c, e.District_ID__c, e.Contractor_Band__c, 
				e.Always_Works_With__c, e.Always_Works_Alone__c, e.District__r.Region__c , e.Supplier__r.Name, e.District__r.Name,
				(select Employee__c, Employee__r.Always_Works_With__c, Type__c from Employee_Postcodes__r ),Postcode__c , Skip_Rule__c
				From Employee__c e where e.Id IN :empIDs];
		return fromDB;
	}

	static void createDECs1(EmployeeInformation emp) {
		Week__c w = setupForDEs(emp);
		
		// Create some diary entries
		Date startOfNextWeek = Date.today().addDays(7).toStartOfWeek();
		
		Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0,
									Start__c = DateTime.newInstance(startOfNextWeek, Time.newInstance(8,0,0,0)), 
									End__c = DateTime.newInstance(startOfNextWeek.addDays(4), Time.newInstance(17,0,0,0)), 
									RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

		// Insert them 
		List<Diary_Entry__c> des = insertDEs(new List<Diary_Entry__c>{de1});
		//List<DiaryEntryCollection> decs = DiaryEntryCollection.createDECs(des, true, emp);
		emp.availability.addAvailability(des, true);
		//return decs;
	}

	static List<ResourceOption> createResourceOptions1() {
    	Phase3TestHelper.createSearchParameters();
    	Job__c job = Phase3TestHelper.createJob1();
		JobInformation ji = new JobInformation(job.ID);
    	SearchBlackBox sbb = new SearchBlackBox(job.ID);
		sbb.setJobInfo(ji);
		BlackBoxOptions bbo = new BlackBoxOptions();
		sbb.setOptions(bbo);

        // Create Employee and Employee Information object
        District__c district = Phase3TestHelper.createTestGeographyDistrict();
		Supplier__c supp = Phase3TestHelper.createSupplier();
        
        // Primary Resource Options
        Employee__c emp1 = createEmployee('testJRO1FN', 'testJRO1SN', '0002991', district.ID, supp.ID);        
        Employee__c emp2 = createEmployee('testJRO2FN', 'testJRO2SN', '0002992', district.ID, supp.ID);
		
        List<Employee__c> primaryEmployees = insertEmployees(new List<Employee__c> {emp1, emp2});
        
        EmployeeInformation ei1 = new EmployeeInformation(primaryEmployees[0]);
        ei1.skillsAndHours.put('MECHANICAL', 2.0);
        EmployeeInformation ei2 = new EmployeeInformation(primaryEmployees[1]);
        ei2.skillsAndHours.put('MECHANICAL', 2.0);
		createDECs1(ei1);
		createDECs1(ei2);
        
        ResourceOption ro1 = new ResourceOption(new Map<String, Double>{'MECHANICAL' => 1.0}, ei1.availability.getDECs(true)[0], ei1, ji, 0.0);
		ResourceOption ro2 = new ResourceOption(new Map<String, Double>{'MECHANICAL' => 1.0}, ei2.availability.getDECs(true)[0], ei2, ji, 0.0);
		
		// Secondary Resource Options
		Employee__c emp3 = createEmployee('testJRO3FN', 'testJRO3SN', '0002993', district.ID, supp.ID);        
        Employee__c emp4 = createEmployee('testJRO4FN', 'testJRO4SN', '0002994', district.ID, supp.ID);
        
		List<Employee__c> secondaryEmployees = insertEmployees(new List<Employee__c> {emp3, emp4});

        EmployeeInformation ei3 = new EmployeeInformation(secondaryEmployees[0]);
        ei1.skillsAndHours.put('POWERFLUSH', 2.0);
        EmployeeInformation ei4 = new EmployeeInformation(secondaryEmployees[1]);
        ei2.skillsAndHours.put('POWERFLUSH', 2.0);		
		createDECs1(ei3);
		createDECs1(ei4);

		ResourceOption ro3 = new ResourceOption(new Map<String, Double>{'POWERFLUSH' => 2.0}, ei3.availability.getDECs(true)[0], ei3, ji, 0.0);
		ResourceOption ro4 = new ResourceOption(new Map<String, Double>{'POWERFLUSH' => 2.0}, ei4.availability.getDECs(true)[0], ei4, ji, 0.0);
		
		return new List<ResourceOption>{ro1, ro2, ro3, ro4};
	}

	static testMethod void constructorsTest1() {
        JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0], ROs[1]});
        
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2], ROs[3]});
        
    }

	static testMethod void constructorsTest2() {
        JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].neverWorksWith = ROs[1].employeeID;
        ROs[0].skillsRemoved = true;
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0], ROs[1]});
        ROs[2].neverWorksWith = ROs[3].employeeID;
        ROs[2].skillsRemoved = true;
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2], ROs[3]});
        jro2.getPrimaryNames();
        jro2.getEndTime(ROs[0].employeeID);
        jro2.getEndTime(ROs[2].employeeID);
    }

    static testMethod void nonVFGettersTest1() {
    	JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0], ROs[1]});
        
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2], ROs[3]});
        
        jro2.getEndJobStart(1, 4);
        jro2.getPrimarySkills();
        jro2.getPrimaryResourceType();
        jro2.getHoursRemaining();
    }
    
    static testMethod void nonVFGettersTest2() {
    	JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2]});
        
        jro2.getEndJobStart(1, 4);
        jro2.getPrimarySkills();
        jro2.getPrimaryResourceType();
        jro2.getHoursRemaining();
    }
    
    static testMethod void VFGettersTest() {
    	JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0], ROs[1]});
        
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2], ROs[3]});
        jro2.getPrimaryNames();
        jro2.getPrimaryType();
        jro2.getPrimaryGeography();
        jro2.getPrimaryJobSkills();
        jro2.getPrimaryNumberOfHoursSatisfied();
        jro2.getPrimaryGapHours();
        jro2.getPrimaryRemainingHours();
        jro2.getPrimaryStart();
        jro2.getSecondaryNames();
        jro2.getSecondaryType();
        jro2.getSecondaryGeography();
        jro2.getSecondaryJobSkills();
        jro2.getSecondaryNumberOfHoursSatisfied();
        

    }
    
    static testMethod void methodsTest() {
		JobResourcingOption jro1 = new JobResourcingOption();
        List<ResourceOption> ROs = createResourceOptions1();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0], ROs[1]});
        
        JobResourcingOption jro2 = new JobResourcingOption(jro1, new List<ResourceOption> {ROs[2], ROs[3]});
        jro2.print();
        jro2.toSearchResults(DateTime.now(), 0);
    }
}