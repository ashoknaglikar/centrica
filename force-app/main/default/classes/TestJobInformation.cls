@isTest
private class TestJobInformation {

	@istest
	public static void testJobInformation1() {
		Job__c j = createJob1();
		JobInformation ji = new JobInformation(j.ID);
	}

	@istest
	public static void testJobInformation2() {
		Job__c j = createJob2();
		JobInformation ji = new JobInformation(j.ID);
	}

	@isTest
	public static Employee__c[] createEmployees() {
		Supplier__c supp = Phase3TestHelper.createSupplier();
		Employee__c emp1 = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
											Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false);
		Database.insert(emp1);
		Employee__c emp2 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2', Supplier__c = supp.ID,
											Employee_Number__c = '0002992', Resource_Type__c= 'Installer', Inactive__c = false, 
											Always_Works_With__c = emp1.ID);
		Database.insert(emp2);
		emp1.Always_Works_With__c = emp2.ID;
		Database.update(emp1);
		return new Employee__c[] {emp1, emp2}; 
	}
	
	@isTest
	public static Job__c createJob1(){
		Phase3TestHelper.createTestGeography();
		Employee__c[] emps = createEmployees();
		Employee__c emp1 = emps[0];
		
		Opportunity opp = Phase3TestHelper.createOpportunity();
		Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
								Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
								Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
								Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
								Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
								Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
								Customer_Preferred_Date__c = Date.today(), Named_Employee__c = emp1.ID,
								Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
								
		Database.insert(job);
		job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
						j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
						j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
						j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
						j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
						j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
						j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job.ID];
		
        // Named skills - CR - Starts
		Job_Named_Skill_Resource__c jNamedResource = new Job_Named_Skill_Resource__c();
		jNamedResource.Employee__c = emp1.Id;
		jNamedResource.Job__c = job.Id;
		jNamedResource.Skill_Name__c = 'Mechanical';
		Database.insert(jNamedResource);
		system.assertequals(jNamedResource.Skill_Name__c,'Mechanical');
		// Named skills - CR - Ends
		
		return job;
	}
	
	@isTest
	public static Job__c createJob2(){
		Phase3TestHelper.createTestGeography();
		Employee__c[] emps = createEmployees();
		Employee__c emp1 = emps[0];
		
		Opportunity opp = Phase3TestHelper.createOpportunity();
		Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
								PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
								Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
								Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
								Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
								Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =	5, 
								Customer_Preferred_Date__c = Date.today(), Named_Employee__c = emp1.ID,
								Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
								
		Database.insert(job);
		job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
						j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
						j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
						j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
						j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
						j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
						j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job.ID];
		
		 // Named skills - CR - Starts
		Job_Named_Skill_Resource__c jNamedResource = new Job_Named_Skill_Resource__c();
		jNamedResource.Employee__c = emp1.Id;
		jNamedResource.Job__c = job.Id;
		jNamedResource.Skill_Name__c = 'Mechanical';
		Database.insert(jNamedResource);
		// Named skills - CR - Ends
		system.assertnotequals(jNamedResource.Skill_Name__c,'Mchanical');
		return job;
	}

}