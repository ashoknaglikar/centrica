@isTest
private class TestSearchBlackBox2 {

    // Named employee CR - Starts
    public static List<Employee__c> empList = new List<Employee__c>();
    // Named employee CR - Ends

	class SBBTestEmployee {
		List<String> skills = new List<String>();
		List<Boolean> ownJobsOnly = new List<Boolean>();
		String fullName = '';
		String firstName = '';
		String lastName = '';
		String empNum = '';
		ID supplierID;
		ID districtID;
		Employee__c empSObject;
		
		public SBBTestEmployee(List<String> skillList, List<Boolean> ownJobs, String fn, String ln, String en, ID suppID, ID dID) {
			skills = skillList.clone();
			ownJobsOnly = ownJobs.clone();
			firstName = fn;
			lastName = ln;
			fullName = fn + ' ' + ln;
			empNum = en;
			supplierID = suppID;
			districtID = dID;
		}
		
		public Employee__c createEmployeeSObject() {
			empSObject = new Employee__c(Name = fullName, Last_Name__c = lastName, First_Name__c = firstName, Pool_Diary__c = false,
													Employee_Number__c = empNum,Supplier__c = supplierID, Resource_Type__c = 'Installer', 
													Inactive__c = false, Works_Anywhere_In_District__c = true, District__c = districtID);
			System.debug('Created Employee__c: ' + empSObject);
			return empSObject;
		}
		
		public List<Employee_Skills__c> createEmployeeSkillsSObjects() {
			List<Employee_Skills__c> toReturn = new List<Employee_Skills__c>();
			Integer count = 0;  
			for(String skill : skills) {
				System.debug('empSObject: ' + empSObject);
				System.debug('ownJobsOnly[count]: ' + ownJobsOnly[count]);
				Employee_Skills__c empSkill = new Employee_Skills__c(Skill_Name__c = skill, Skill_Type__c = 'Own and Others Jobs', 
													Employee__c = empSObject.ID, Own_Jobs_Only__c = ownJobsOnly[count]);
				count++;
				toReturn.add(empSkill);
			}
			
			return toReturn;
		}
	}

	static Search_Parameter__c setupSearchParameter() {
		Search_Parameter__c sp = null;
		
		try {
			sp = [Select s.SystemModstamp, s.Scheduling_Window__c, s.OwnerId, s.Name, s.LastModifiedDate, 
					s.LastModifiedById, s.IsDeleted, s.Id, s.Gap_Size_Tolerance__c, s.End_Date_Time_Offset__c, 
					s.Double_Handed_Threshold__c, s.CreatedDate, s.CreatedById, s.Acceptable_Remaining_Gap__c 
					From Search_Parameter__c s where s.Type__c='DEFAULT' limit 1];
		} catch (Exception exc) {
			sp = new Search_Parameter__c(Type__c='DEFAULT', Scheduling_Window__c = 5, Gap_Size_Tolerance__c = 0, 
																	Acceptable_Remaining_Gap__c = 7, Double_Handed_Threshold__c = 16, 
																	End_Date_Time_Offset__c = 0.10);
			Database.insert(sp);
			sp = [Select s.SystemModstamp, s.Scheduling_Window__c, s.OwnerId, s.Name, s.LastModifiedDate, 
					s.LastModifiedById, s.IsDeleted, s.Id, s.Gap_Size_Tolerance__c, s.End_Date_Time_Offset__c, 
					s.Double_Handed_Threshold__c, s.CreatedDate, s.CreatedById, s.Acceptable_Remaining_Gap__c 
					From Search_Parameter__c s where s.Type__c='DEFAULT' limit 1];
		}
		return sp;
	}

	static Shift_Pattern__c createShiftPattern() {
		Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
													Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
													Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
													Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
													Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
													Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
													Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
													Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
		Database.insert(sp);
		
		return sp;
	}
	
	static District__c createTestDistrict() {
		Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation',Geography_Code__c ='09');
		
		Database.insert(testRegion);
		
		District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
		Database.insert(testDistrict);
		
		return testDistrict;
	}
	
	static Postcode_Sector__c createTestPostcodeSector(District__c testDistrict) {
		Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
													Type__c='Installation', District__c = testDistrict.ID);
		Database.insert(testSubPatch);
		
		Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'XX99 9', Description__c = 'Test Postcode Sector', 
																		Water_Hardness__c = 99, Type__c = 'Installation', 
																		Sub_Patch__c = testSubPatch.ID);
		Database.insert(testPostcodeSector);
		
		return testPostcodeSector;
	}
	
	static Account createAccount() {
		Account acc = new Account(Name = 'Test SBB', BillingStreet='18 Roundacre', 
										BillingPostalCode='XX99 9TS', BillingCity='London', 
										BillingCountry='UK', BillingState='London');
		Database.insert(acc);
		acc = [Select a.Type, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, 
				a.ShippingCity, a.Sales_Subpatch__c, a.Sales_Region__c, a.Sales_District__c, a.Primary_Contact__c, 
				a.Name, a.Id, a.Description, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity
				From Account a where a.Id = :acc.Id];
		return acc;
	}
	
	static Campaign createCampaign() {
		Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
		Database.insert(camp);
		camp = [Select c.Type, c.Status, c.StartDate, c.Source__c, c.Name, c.Id
				From Campaign c Where c.Id = :camp.Id];
		return camp;
	}

	static Opportunity createOpportunity() {
		Account acc = createAccount();
		Campaign camp = createCampaign();
		Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestSBB() opp', AccountId = acc.Id,
											CloseDate = Date.today().addyears(1), 
											StageName = 'Active',
											Product_Interest__c='Central Heating Boiler',
											CampaignId = camp.Id);
		
		Database.insert(opp);
		
		opp = [select ID from Opportunity where ID = :opp.ID];
		return opp;
	}
	
	static Supplier__c createOwnSupplier() {
		Supplier__c supp = new Supplier__c(Name='TestSBB Own Supplier', Supplier_Num__c = '875411', 
											Type__c = 'Resource', Resource_Type__c='Own Labour');
		Database.insert(supp);
		
		return supp;
	}
	
	static Supplier__c createOtherSupplier() {
		Supplier__c supp = new Supplier__c(Name='TestSBB Other Supplier', Supplier_Num__c = '875412', 
											Type__c = 'Resource', Resource_Type__c='Contractor');
		Database.insert(supp);
		
		return supp;
	}
	
	static Employee__c createEmployee(Supplier__c supplier) {
		return null;
	}
	
	static List<Employee__c> insertEmployees(List<Employee__c> employees) {
		return null;
	}
	
	
	static Job__c insertJob(Job__c job) {
		Database.insert(job);
		job = [Select j.Water_Heating_Fixing_Status__c, j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Status__c, 
				j.Unvented_Hot_Water_Hours__c, j.Sub_Status__c, j.Status__c, j.Specialist_Building_Hours__c, j.Solar_Hours__c, 
				j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, j.Own_Labour__c, 
				j.Named_Employee__c, j.Name, j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Installation_Address__c, j.Id,
				j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c, j.Electrical_Hours__c, j.Double_Handed_Job__c, 
				j.District__c, j.Customer_Preferred_Date__c, j.Contractors__c, j.Contractor_Installation_Hours_del__c, 
				j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
				j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, j.CHI_Lead__r.Install_Postcode__c, 
				j.Named_Employee__r.Always_Works_With__c 
				From Job__c j Where j.Id = :job.Id];
		return job;
	}

    static List<Employee__c> setupScenario1() {
	    // Present DEs only (business best only)
	    Date startD = null;
	    //if(DateTimeHelper.DAYS_OF_WEEK.get(Datetime.now().format('E')) >= 3)
	    	startD = Date.today().addDays(7).toStartOfWeek();
	    //else
	    //	startD = Date.today().toStartOfWeek();
	    
	    Date endD = startD.addDays(4); 
	    
	    District__c district = createTestDistrict();
		Postcode_Sector__c pcs = createTestPostcodeSector(district);
		
		// Create Employees and skills
		Supplier__c ownSupplier = createOwnSupplier();
		Supplier__c otherSupplier = createOtherSupplier();
		
		List<List<String>> skills = new List<List<String>>{};
		List<List<Boolean>> ownJobsOnly = new List<List<Boolean>>{};
		
		// Own employees
		// Employee 1
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		// Employee 2
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'LPG INSTALLATION'});
		ownJobsOnly.add(new List<Boolean> {false, true, false});
		// Employee 3
		skills.add(new List<String> {'MECHANICAL', 'CONNECT SOLAR PANELS', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, true});
		
		// Other employees
		// Employee 4
		skills.add(new List<String> {'ELECTRICAL'});
		ownJobsOnly.add(new List<Boolean> {false});
		// Employee 5
		skills.add(new List<String> {'POWERFLUSH', 'CONNECT SOLAR PANELS'});
		ownJobsOnly.add(new List<Boolean> {false, false});
		// Employee 6
		skills.add(new List<String> {'FIRE WALL HEATER FIXING', 'LPG INSTALLATION', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		
		List<SBBTestEmployee> emps = new List<SBBTestEmployee>();
		List<Employee__c> empSObjects = new List<Employee__c>();
		
		// Named employee CR - Starts
		   empList = empSObjects;
		// Named employee CR - Ends
		
		for(Integer i = 0 ; i < 3; i++) {
			
			
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), ownSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		for(Integer i = 3 ; i < 6; i++) {
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), otherSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		Database.insert(empSObjects);
		
		Set<ID> empIDs = new Set<ID>();
		
		for(Employee__c e : empSObjects) {
			System.debug('e.ID: ' + e.ID);
			empIDs.add(e.ID);
		}
		
		Job_Named_Skill_Resource__c jNamedEmpSkill = new Job_Named_Skill_Resource__c();
		
		
		List<Employee_Skills__c> empSkillsSObjects = new List<Employee_Skills__c>();
		for(SBBTestEmployee e : emps) {
			empSkillsSObjects.addAll(e.createEmployeeSkillsSObjects());
		}
		
		Database.insert(empSkillsSObjects);
		
		// Create Shift Pattern
		Shift_Pattern__c shiftPattern = createShiftPattern();
		
		// Create Weeks - present only, availability only
		List<Week__c> weeks = new List<Week__c>();
		for(Employee__c emp : empSObjects) {
			Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = shiftPattern.ID, Week_Commencing__c = startD,
								Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
								Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
			weeks.add(w);
		}
		
		Database.insert(weeks);
		
		// Create Diary Entries - present only, availability only
		List<Diary_Entry__c> des = new List<Diary_Entry__c>();
		Integer iDay=0;
		for(Week__c w : weeks) {
			DateTime startDT = DateTime.newInstance(startD, Time.newInstance(8,0,0,0));
			DateTime endDT = DateTime.newInstance(startD.addDays(4), Time.newInstance(17,0,0,0));
			Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 45,
													RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));


			System.debug('de.Start__c: ' + de.Start__c);
			System.debug('de.End__c: ' + de.End__c);
			
			des.add(de);
			
			/*endDT = startDT.addDays(iDay);
			endDT = startDT.addHours(4);
			System.debug('startDT: ' + startDT);
			System.debug('endDT: ' + endDT);
			iDay++;
			de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 4,
					RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
			
			
			
			des.add(de);
			
			if(des.size() != 2){
			endDT = startDT.addDays(iDay);
			endDT = startDT.addHours(4);
			System.debug('startDT: ' + startDT);
			System.debug('endDT: ' + endDT);
			  de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 4,
					RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));
			  des.add(de);
			}*/
		}
		
		Database.insert(des);
		//
		// add employee postcode sectors
		List<Employee_Postcode_Sectors__c> empPSs = new List<Employee_Postcode_Sectors__c>();
		for(Employee__c emp : empSObjects) {
			String sType='Priamry';
			if(empPSs.size() == 1)sType='Away';
			
			Employee_Postcode_Sectors__c empPS = new Employee_Postcode_Sectors__c
					(Employee__c = emp.ID, 
					 Type__c=sType,
					 Postcode_Sector__c=pcs.id,
					 Start_Date__c=startD,
					 End_Date__c=endD);

			empPSs.add(empPS);
		}
		
		Database.insert(empPSs);
	
		
		
		// Create Search Parameter object
		Search_Parameter__c searchParameters = setupSearchParameter();
		
		List<Employee__c> employeesToReturn = new List<Employee__c>();
		employeesToReturn = [select ID, Always_Works_With__c from Employee__c where ID IN :empIDs];
		return employeesToReturn;
    }

    static List<Employee__c> setupScenario2() {
	    Date startD = Date.today().addDays(1);
	    /*if(DateTimeHelper.DAYS_OF_WEEK.get(Datetime.now().format('E')) >= 3)
	    	startD = Date.today().addDays(7).toStartOfWeek();
	    else
	    	startD = Date.today().toStartOfWeek();*/
	    
	    Date endD = startD.addDays(4); 
	    
	    District__c district = createTestDistrict();
		Postcode_Sector__c pcs = createTestPostcodeSector(district);
		
		// Create Employees and skills
		Supplier__c ownSupplier = createOwnSupplier();
		Supplier__c otherSupplier = createOtherSupplier();
		
		List<List<String>> skills = new List<List<String>>{};
		List<List<Boolean>> ownJobsOnly = new List<List<Boolean>>{};
		
		// Own employees
		// Employee 1
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		// Employee 2
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'LPG INSTALLATION'});
		ownJobsOnly.add(new List<Boolean> {false, true, false});
		// Employee 3
		skills.add(new List<String> {'MECHANICAL', 'CONNECT SOLAR PANELS', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, true});
		
		// Other employees
		// Employee 4
		skills.add(new List<String> {'ELECTRICAL'});
		ownJobsOnly.add(new List<Boolean> {false});
		// Employee 5
		skills.add(new List<String> {'POWERFLUSH', 'CONNECT SOLAR PANELS'});
		ownJobsOnly.add(new List<Boolean> {false, false});
		// Employee 6
		skills.add(new List<String> {'FIRE WALL HEATER FIXING', 'LPG INSTALLATION', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		
		List<SBBTestEmployee> emps = new List<SBBTestEmployee>();
		List<Employee__c> empSObjects = new List<Employee__c>();
		
		for(Integer i = 0 ; i < 3; i++) {
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), ownSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		for(Integer i = 3 ; i < 6; i++) {
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), otherSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		Database.insert(empSObjects);
		
		Set<ID> empIDs = new Set<ID>();
		
		for(Employee__c e : empSObjects) {
			System.debug('e.ID: ' + e.ID);
			empIDs.add(e.ID);
		}
		
		List<Employee_Skills__c> empSkillsSObjects = new List<Employee_Skills__c>();
		for(SBBTestEmployee e : emps) {
			empSkillsSObjects.addAll(e.createEmployeeSkillsSObjects());
		}
		
		Database.insert(empSkillsSObjects);
		
		// Create Shift Pattern
		Shift_Pattern__c shiftPattern = createShiftPattern();
		
		// Create Weeks - present only, availability only
		List<Week__c> weeks = new List<Week__c>();
		for(Employee__c emp : empSObjects) {
			Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = shiftPattern.ID, Week_Commencing__c = startD,
								Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
								Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
			weeks.add(w);
		}
		
		Database.insert(weeks);
		
		// Create Diary Entries - present only, availability only
		List<Diary_Entry__c> des = new List<Diary_Entry__c>();

		for(Week__c w : weeks) {
			DateTime startDT = DateTime.newInstance(startD, Time.newInstance(8,0,0,0));
			DateTime endDT = DateTime.newInstance(startD, Time.newInstance(17,0,0,0));
			Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 9,
													RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

			System.debug('de.Start__c: ' + de.Start__c);
			System.debug('de.End__c: ' + de.End__c);
			
			des.add(de);
		}
		
		Database.insert(des);
		
		//
		// add employee postcode sectors
		List<Employee_Postcode_Sectors__c> empPSs = new List<Employee_Postcode_Sectors__c>();
		for(Employee__c emp : empSObjects) {
			String sType='Priamry';
			if(empPSs.size() == 1)sType='Away';
			
			Employee_Postcode_Sectors__c empPS = new Employee_Postcode_Sectors__c
					(Employee__c = emp.ID, 
					 Type__c=sType,
					 Postcode_Sector__c=pcs.id,
					 Start_Date__c=startD,
					 End_Date__c=endD);

			empPSs.add(empPS);
		}
		
		Database.insert(empPSs);
	
		
		
		// Create Search Parameter object
		Search_Parameter__c searchParameters = setupSearchParameter();
		
		List<Employee__c> employeesToReturn = new List<Employee__c>();
		employeesToReturn = [select ID, Always_Works_With__c from Employee__c where ID IN :empIDs];
		return employeesToReturn;
    }
    
    static testmethod void searchBlackBoxTest1() {
    	// Present DEs only (business best only) - Single Handed
    	setupScenario1();
    	Opportunity opp = createOpportunity();
		Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = false,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 2);
								
		job = insertJob(job);
		
		// Named Skill CR - Starts
		   
		   List<Job_Named_Skill_Resource__c> jNamedResourceList = new List<Job_Named_Skill_Resource__c>();
		   Job_Named_Skill_Resource__c jNamedResource;
		   for(Employee__c e : empList){
		   	  jNamedResource = new Job_Named_Skill_Resource__c();
		   	  jNamedResource.Employee__c = e.Id;
		   	  jNamedResource.Skill_Name__c = 'MECHANICAL';
		   	  jNamedResource.Job__c = job.Id;
		   }
		   
		// Named skill CR - ends

		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		try{
			searchIF.startSearch(job.ID);
	    }
		catch(Exception ex)
		{
			
		} 
    }
    
    static testmethod void searchBlackBoxTest2() {
    	// Present DEs only (business best only) - Double Handed
    	setupScenario1();
    	Opportunity opp = createOpportunity();
		Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = true,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 2);
								
		job = insertJob(job);
		
		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		try{
			searchIF.startSearch(job.ID); 
		}
		catch(Exception ex)
		{
			
		}
    }
        
    // Named Employee
    static testmethod void searchBlackBoxTest3() {
    	List<Employee__c> employees = setupScenario1();
    	Employee__c named = employees[0];
    	Opportunity opp = createOpportunity();
    	Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = false,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 2,
								Named_Employee__c = named.ID);
								
		job = insertJob(job);
		
		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		try{
			searchIF.startSearch(job.ID);
		}
		catch(Exception ex)
		{
			
		}
    }
    
    // Always work together - single handed option
    static testmethod void searchBlackBoxTest4() {
    	List<Employee__c> employees = setupScenario1();
    	System.debug('employees[0]: ' + employees[0].ID);
    	System.debug('employees[1]: ' + employees[1].ID);
    	employees[0].Always_Works_With__c = employees[1].ID;
    	System.debug('employees[0]:' + employees[0]);
    	Database.update(employees[0]);
    	
    	Opportunity opp = createOpportunity();
    	Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = false,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 2);
								
		job = insertJob(job);
		
		// Named Skill CR - Starts
		   
		   List<Job_Named_Skill_Resource__c> jNamedResourceList = new List<Job_Named_Skill_Resource__c>();
		   Job_Named_Skill_Resource__c jNamedResource;
		   for(Employee__c e : employees){
		   	  jNamedResource = new Job_Named_Skill_Resource__c();
		   	  jNamedResource.Employee__c = e.Id;
		   	  jNamedResource.Skill_Name__c = 'MECHANICAL';
		   	  jNamedResource.Job__c = job.Id;
		   }
		   
		// Named skill CR - ends
		
		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		try{
			searchIF.startSearch(job.ID);
		}
		catch(Exception ex)
		{
			
		}
    }
    
    // Always work together - double handed option
    static testmethod void searchBlackBoxTest5() {
    	List<Employee__c> employees = setupScenario1();
    	employees[0].Always_Works_With__c = employees[1].ID;
    	Database.update(employees[0]);
    	
    	Opportunity opp = createOpportunity();
    	Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = true,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 2);
								
		job = insertJob(job);
		
		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		try{
			searchIF.startSearch(job.ID);
		}
		catch(Exception ex)
		{
			
		}
    }

    /*static testmethod void searchBlackBoxTest6() {
    	// Present DEs only (business best only) - Single Handed
    	setupScenario2();
    	Opportunity opp = createOpportunity();
		Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', Double_Handed_Job__c = false,
								Customer_Preferred_Date__c = Date.today().addDays(30), Contractors__c=true, Own_Labour__c=true,  
								Mechanical_Hours__c=5, PowerFlush_Hours__c = 3, Electrical_Hours__c = 3, LPG_Installation_Hours__c = 5);
								
		job = insertJob(job);

		IPSFromSearchObject searchIF = new IPSFromSearchObject();
		List<List<JobResourcingOption>> results = searchIF.startSearch(job.ID);
		System.debug('number of results: ' + results.size());
		System.debug('number of results[0]: ' + results[0].size());
		System.debug('number of results[1]: ' + results[1].size()); 
    }*/
    
     static testMethod void testDiaryDisplay() {
    	
    	List<Employee__c> employees = setupScenario1();
    	//
    	// test all the controller classes
    	
    	String stDistrict = [select district__c from Employee__c where id = :employees[0].id].District__c;
    	
        Date startD = null;
	    if(DateTimeHelper.DAYS_OF_WEEK.get(Datetime.now().format('E')) >= 3)
	    	startD = Date.today().addDays(7).toStartOfWeek();
	    else
	    	startD = Date.today().toStartOfWeek();
	    
	    String sDay = '';
	    if(StartD.day() < 10)
	    	sDay = '0' + StartD.day();
	    else
	    	sDay = String.valueoF(StartD.day());

	    String sMonth = '';
	    if(StartD.month() < 10)
	    	sMonth = '0' + StartD.month();
	    else
	    	sMonth = String.valueoF(StartD.month());
	    		    	
    	String stWeek = sDay + '/' + sMonth + '/' + startD.year();
    	
    	
    	PageReference pageRef = new PageReference('/apex/DiaryDisplay?week=' + stWeek + '&area=' + stDistrict);
    	Test.setCurrentPage(pageRef);	    
	    DiaryDisplayController ddC = new DiaryDisplayController();
	    
	    List<SelectOption> districts = ddC.getAreaItems();
        String week = ddC.getWeeks();
        String areaName = ddC.getAreaName();
        ddC.setAreaName(stDistrict);
 		ddC.setWeeks(stWeek);
 		String area = ddC.getArea();
 		ddC.setArea(stDistrict);
   	    String sendRange = ddC.getSendRange();
        ddC.setSendRange(sendRange);
        ddC.getDHM();
        ddC.LoadDistricts();
        ddC.setInitialDHM();
        ddC.getShow();
		List<SelectOption> weeks = ddC.getWeekItems();
		ddC.refreshdiary();
		ddC.getEmpData();

	    PageReference pageRef2 = new PageReference('/apex/DiaryDisplay');
    	Test.setCurrentPage(pageRef2);	    
	    DiaryDisplayController ddC2 = new DiaryDisplayController();
	    ddC2.Districts=null;
	    ddC2.getAreaItems();
	    
	    //test the diarydisplaywork class
	    Double num=12.0;
	    DiaryDisplayWorker.formatDouble(num,2);
	    num=12.333333333333;
	    DiaryDisplayWorker.formatDouble(num,2);
	    num=12.1;
	    DiaryDisplayWorker.formatDouble(num,2);
	    DiaryDisplayWorker ddw = new DiaryDisplayWorker();
		ddw.getEmployeesForDiary(stDistrict,Date.today().addDays(7).toStartOfWeek(),Date.today().addDays(14).toStartOfWeek(), null);
		ddw.getDiaryEntry(Date.today().addDays(7).toStartOfWeek(),Date.today().addDays(14).toStartOfWeek(), stDistrict);
		//ddw.addPoolDayEntry(2.0,3.0,4.0,'test');
		DiaryDisplayWorker.NoAvailabilityLine nw = new DiaryDisplayWorker.NoAvailabilityLine();
		Diary_Entry__c d = new Diary_Entry__c();
		
	   
	    for(DiaryDisplayWorker.Employee thisEmp : ddC.getEmpData().getEmployees() ){
	      thisEmp.getAllCols();
	      thisEmp.getNoAvailLines();
	      thisEmp.getdebugsegment();
	      thisEmp.getSegments();
	      thisEmp.getEmployeeName(); 
		  thisEmp.getEmployeeURL();
		  thisEmp.getavailabilityhours();
		  thisEmp.getdiaryEntries();
		  thisEmp.getStr_PostCode();
		  thisEmp.getStr_Role();
	
		  for(DiaryDisplayWorker.GraphicDisplay thisBar :thisEmp.getGraphicDisplay()){
			thisbar.getcolour();
			thisbar.getbgcolour();
			thisbar.getlength();
			thisbar.getwidth();
			thisbar.getURL();
			thisbar.getJobCode();
			thisbar.getoutputstring();
		  } 
		  
		  for(DiaryDisplayWorker.NoAvailabilityLine thisNoAvLine :thisEmp.getNoAvailLines()){
		  // next to add
		  	thisNoAvLine.getGraphicNoAvailabilityLines();
		  }
		  
	    }
		
		
     }
     
     Static testmethod void testpoolscenario()
     {
     	
    	
    	List<Employee__c> employees = setupScenariopool();
    	//
    	// test all the controller classes
    	
    	String stDistrict = [select district__c from Employee__c where id = :employees[0].id].District__c;
    	
        Date startD = null;
	    if(DateTimeHelper.DAYS_OF_WEEK.get(Datetime.now().format('E')) >= 3)
	    	startD = Date.today().addDays(7).toStartOfWeek();
	    else
	    	startD = Date.today().toStartOfWeek();
	    
	    String sDay = '';
	    if(StartD.day() < 10)
	    	sDay = '0' + StartD.day();
	    else
	    	sDay = String.valueoF(StartD.day());

	    String sMonth = '';
	    if(StartD.month() < 10)
	    	sMonth = '0' + StartD.month();
	    else
	    	sMonth = String.valueoF(StartD.month());
	    		    	
    	String stWeek = sDay + '/' + sMonth + '/' + startD.year();
    	
    	
    	PageReference pageRef = new PageReference('/apex/DiaryDisplay?week=' + stWeek + '&area=' + stDistrict);
    	Test.setCurrentPage(pageRef);	    
	    DiaryDisplayController ddC = new DiaryDisplayController();
	    
	    List<SelectOption> districts = ddC.getAreaItems();
        String week = ddC.getWeeks();
        String areaName = ddC.getAreaName();
        ddC.setAreaName(stDistrict);
 		ddC.setWeeks(stWeek);
 		String area = ddC.getArea();
 		ddC.setArea(stDistrict);
   	    String sendRange = ddC.getSendRange();
        ddC.setSendRange(sendRange);
        ddC.getDHM();
        ddC.LoadDistricts();
        ddC.setInitialDHM();
        ddC.getShow();
		List<SelectOption> weeks = ddC.getWeekItems();
		ddC.refreshdiary();
		ddC.getEmpData();

	    PageReference pageRef2 = new PageReference('/apex/DiaryDisplay');
    	Test.setCurrentPage(pageRef2);	    
	    DiaryDisplayController ddC2 = new DiaryDisplayController();
	    ddC2.Districts=null;
	    ddC2.getAreaItems();
	    
	    //test the diarydisplaywork class
	    Double num=12.0;
	    DiaryDisplayWorker.formatDouble(num,2);
	    num=12.333333333333;
	    DiaryDisplayWorker.formatDouble(num,2);
	    num=12.1;
	    DiaryDisplayWorker.formatDouble(num,2);
	    DiaryDisplayWorker ddw = new DiaryDisplayWorker();
		ddw.getEmployeesForDiary(stDistrict,Date.today().addDays(7).toStartOfWeek(),Date.today().addDays(14).toStartOfWeek(), null);
		ddw.getDiaryEntry(Date.today().addDays(7).toStartOfWeek(),Date.today().addDays(14).toStartOfWeek(), stDistrict);
		
		DiaryDisplayWorker.NoAvailabilityLine nw = new DiaryDisplayWorker.NoAvailabilityLine();
		nw.getGraphicNoAvailabilityLines();
		Diary_Entry__c d = new Diary_Entry__c();
		   
	    for(DiaryDisplayWorker.Employee thisEmp : ddC.getEmpData().getEmployees() ){
	      thisEmp.getAllCols();
	      thisEmp.getNoAvailLines();
	      thisEmp.getdebugsegment();
	      thisEmp.getSegments();
	      thisEmp.getEmployeeName(); 
		  thisEmp.getEmployeeURL();
		  thisEmp.getavailabilityhours();
		  thisEmp.getdiaryEntries();
		  thisEmp.getStr_PostCode();
		  thisEmp.getStr_Role();
		  //thisEmp.addToEndOfDayNW(nw,system.today().format());
	
		  for(DiaryDisplayWorker.GraphicDisplay thisBar :thisEmp.getGraphicDisplay()){
			thisbar.getcolour();
			thisbar.getbgcolour();
			thisbar.getlength();
			thisbar.getwidth();
			thisbar.getURL();
			thisbar.getJobCode();
			thisbar.getoutputstring();
		  } 
		  
		  for(DiaryDisplayWorker.NoAvailabilityLine thisNoAvLine :thisEmp.getNoAvailLines()){
		  // next to add
		  	thisNoAvLine.getGraphicNoAvailabilityLines();
		  }
		  
	    }
		DiaryDisplayWorker.GraphicDisplay thisBar = new DiaryDisplayWorker.GraphicDisplay();
		thisbar.getcolour();
		thisbar.getbgcolour();
	//	thisbar.getlength();
		thisbar.getwidth();
		thisbar.getURL();
		thisbar.getJobCode();
		thisbar.getoutputstring();
		thisbar.getShowInformation();
		thisbar.getInformation();
		thisbar.getBorderLeft();
		thisbar.getBorderRight();
		thisbar.getoutputstring();
		thisbar.getSubType();
	}
    
     
     static List<Employee__c> setupScenariopool() {
	    // Present DEs only (business best only)
	    Date startD = null;
	    //if(DateTimeHelper.DAYS_OF_WEEK.get(Datetime.now().format('E')) >= 3)
	    	startD = Date.today().addDays(7).toStartOfWeek();
	    //else
	    //	startD = Date.today().toStartOfWeek();
	    
	    Date endD = startD.addDays(4); 
	    
	    District__c district = createTestDistrict();
		Postcode_Sector__c pcs = createTestPostcodeSector(district);
		
		// Create Employees and skills
		Supplier__c ownSupplier = createOwnSupplier();
		Supplier__c otherSupplier = createOtherSupplier();
		
		List<List<String>> skills = new List<List<String>>{};
		List<List<Boolean>> ownJobsOnly = new List<List<Boolean>>{};
		
		// Own employees
		// Employee 1
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		// Employee 2
		skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'LPG INSTALLATION'});
		ownJobsOnly.add(new List<Boolean> {false, true, false});
		// Employee 3
		skills.add(new List<String> {'MECHANICAL', 'CONNECT SOLAR PANELS', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, true});
		
		// Other employees
		// Employee 4
		skills.add(new List<String> {'ELECTRICAL'});
		ownJobsOnly.add(new List<Boolean> {false});
		// Employee 5
		skills.add(new List<String> {'POWERFLUSH', 'CONNECT SOLAR PANELS'});
		ownJobsOnly.add(new List<Boolean> {false, false});
		// Employee 6
		skills.add(new List<String> {'FIRE WALL HEATER FIXING', 'LPG INSTALLATION', 'PAYMENT COLLECTION'});
		ownJobsOnly.add(new List<Boolean> {false, false, false});
		
		List<SBBTestEmployee> emps = new List<SBBTestEmployee>();
		List<Employee__c> empSObjects = new List<Employee__c>();
		
		for(Integer i = 0 ; i < 3; i++) {
			
			
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), ownSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		for(Integer i = 3 ; i < 6; i++) {
			SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
														'000299' + i.format(), otherSupplier.ID, district.ID);
			emps.add(emp);
			empSObjects.add(emp.createEmployeeSObject());
		}
		
		Database.insert(empSObjects);
		
		Set<ID> empIDs = new Set<ID>();
		
		for(Employee__c e : empSObjects) {
			System.debug('e.ID: ' + e.ID);
			e.Pool_Diary__c = true;
			empIDs.add(e.ID);
		}
		update empSObjects;
		
		List<Employee_Skills__c> empSkillsSObjects = new List<Employee_Skills__c>();
		for(SBBTestEmployee e : emps) {
			empSkillsSObjects.addAll(e.createEmployeeSkillsSObjects());
		}
		
		Database.insert(empSkillsSObjects);
		
		// Create Shift Pattern
		Shift_Pattern__c shiftPattern = createpoolShiftPattern();
		
		// Create Weeks - present only, availability only
		List<Week__c> weeks = new List<Week__c>();
		for(Employee__c emp : empSObjects) {
			Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = shiftPattern.ID, Week_Commencing__c = startD,
								Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
								Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
			weeks.add(w);
		}
		
		Database.insert(weeks);
		
		// Create Diary Entries - present only, availability only
		List<Diary_Entry__c> des = new List<Diary_Entry__c>();
		Integer iDay=0;
		for(Week__c w : weeks) {
			DateTime startDT = DateTime.newInstance(startD, Time.newInstance(8,0,0,0));
			DateTime endDT = DateTime.newInstance(startD.addDays(4), Time.newInstance(17,0,0,0));
			Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 45,
													RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

			Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 45,
													RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'));
													
			Diary_Entry__c de3 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 45,
													RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));										
			System.debug('de.Start__c: ' + de.Start__c);
			System.debug('de.End__c: ' + de.End__c);
			
			des.add(de);
			des.add(de1);
			des.add(de3);
			
		}
		
		Database.insert(des);
		//
		// add employee postcode sectors
		List<Employee_Postcode_Sectors__c> empPSs = new List<Employee_Postcode_Sectors__c>();
		for(Employee__c emp : empSObjects) {
			String sType='Priamry';
			if(empPSs.size() == 1)sType='Away';
			
			Employee_Postcode_Sectors__c empPS = new Employee_Postcode_Sectors__c
					(Employee__c = emp.ID, 
					 Type__c=sType,
					 Postcode_Sector__c=pcs.id,
					 Start_Date__c=startD,
					 End_Date__c=endD);

			empPSs.add(empPS);
		}
		
		Database.insert(empPSs);
	
		
		
		// Create Search Parameter object
		Search_Parameter__c searchParameters = setupSearchParameter();
		
		List<Employee__c> employeesToReturn = new List<Employee__c>();
		employeesToReturn = [select ID, Always_Works_With__c from Employee__c where ID IN :empIDs];
		return employeesToReturn;
    }

    static Shift_Pattern__c createpoolShiftPattern() {
	Shift_Pattern__c sp1 = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = true, Total_Hours__c = '45',
													Monday_Max_Hours__c = 80.00, Monday_End_Time__c = '17:00',
													Tuesday_Max_Hours__c = 80.00, Tuesday_End_Time__c = '17:00',
													Wednesday_Max_Hours__c = 80.00, Wednesday_End_Time__c = '17:00',
													Thursday_Max_Hours__c = 80.00, Thursday_End_Time__c = '17:00',
													Friday_Max_Hours__c = 80.00, Friday_End_Time__c = '17:00',
													Saturday_Max_Hours__c = 80.00, Saturday_End_Time__c = null,
													Sunday_Max_Hours__c =80.00, Sunday_End_Time__c = null);
		Database.insert(sp1);
		
		return sp1;
	} 
    // Customer preferred DEs only (Customer preferred)
    
    // Employees with Postcode Sectors versus Anywhere in District/Area
    
}