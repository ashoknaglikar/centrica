@isTest
private class TestRankOptions {

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

    private static Account createAccount() {
        Account acc = new Account(Name = 'Test SBB', BillingStreet='18 Roundacre', 
                                        BillingPostalCode='XX99 9TS', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        acc = [Select a.Type, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, 
                a.ShippingCity, a.Sales_Subpatch__c, a.Sales_Region__c, a.Sales_District__c, a.Primary_Contact__c, 
                a.Name, a.Id, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity
                From Account a where a.Id = :acc.Id];
        return acc;
    }
    
    private static Campaign createCampaign() {
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        camp = [Select c.Type, c.Status, c.StartDate, c.Source__c, c.Name, c.IsActive, c.Id, c.EndDate
                From Campaign c Where c.Id = :camp.Id];
        return camp;
    }
    
    private static Opportunity createOpportunity() {
        Account acc = createAccount();
        Campaign camp = createCampaign();
        Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestSBB() opp', AccountId = acc.Id,
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        
        Database.insert(opp);
        opp = [Select o.ID From Opportunity o Where o.Id = :opp.Id];
        return opp;
    }
    
    private static Job__c createJob1() {
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Contractors__c=true, Own_Labour__c=true, 
                                Customer_Preferred_Date__c = Date.today().addDays(7).toStartOfWeek(), Double_Handed_Job__c = false);
                                
        Database.insert(job);
        
        job = [Select j.Water_Heating_Fixing_Hours__c, 
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id, 
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c,Finance_Expiry_Date__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }


    static Employee__c createEmployee(String firstName, String secondName, String empNum, ID districtID, ID supplierID) {
        
        Employee__c emp = new Employee__c(Name = firstName + ' ' + secondName, First_Name__c = firstName, Last_Name__c = secondName,
                                            Employee_Number__c = empNum, Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = districtId, Net_Promoter_Score__c = 10, Supplier__c = supplierID, Postcode__c ='ab1 cd1');
        
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
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c, d.Hours__c,  Week__r.Morning_Start_Time__c, Week__r.Mid_day_Start_Time__c
                from Diary_Entry__c d where d.Id IN :deIDs];
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
        Job__c job = createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions(job);
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

        return new List<ResourceOption>{ro1, ro2};
    }


    // For each criteria, need a WIN, a LOSE and a DRAW
    // DRAW will cause next rule to be fired.

    static testMethod void meetCustomerPreferenceTest() {
        Phase3TestHelper.createSearchParameters();
        Job__c job = createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions(job);
        sbb.setOptions(bbo);

        JobResourcingOption jro1 = new JobResourcingOption();
        JobResourcingOption jro2 = new JobResourcingOption();
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek().addDays(1), Time.newInstance(8,0,0,0));
        
        RankOptions rank = new RankOptions();
        //rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        //rank.rankOptions(new List<JobResourcingOption>{jro2, jro1});
    }
    
    static testMethod void largeEnoughGapTest() {
    	Phase3TestHelper.createSearchParameters();
        Job__c job = createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions();
        sbb.setOptions(bbo);

        JobResourcingOption jro1 = new JobResourcingOption();
        JobResourcingOption jro2 = new JobResourcingOption();
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = false;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1});
    }
    
    static testMethod void geographyTypeTest() {
    	Phase3TestHelper.createSearchParameters();
        Job__c job = createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions();
        sbb.setOptions(bbo);

        JobResourcingOption jro1 = new JobResourcingOption();
        JobResourcingOption jro2 = new JobResourcingOption();
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Secondary';
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1});
    }
    
    static testMethod void numberOfSkillsTest() {
    	Phase3TestHelper.createSearchParameters();
        Job__c job = createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions();
        sbb.setOptions(bbo);

        JobResourcingOption jro1 = new JobResourcingOption();
        JobResourcingOption jro2 = new JobResourcingOption();
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 0;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1});        
    }
    
    static testMethod void resourceTypeTest1() {
    	Phase3TestHelper.createSearchParameters();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].resourceType = SearchBlackBox.CONTRACTOR;
        ROs[1].resourceType = SearchBlackBox.OWN_LABOUR;
        
        JobResourcingOption jro1 = new JobResourcingOption();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption();
        jro2.addPrimaryOptions(new List<ResourceOption> {ROs[1]});
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 1;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1}); 
    }

    static testMethod void resourceTypeTest2() {
    	Phase3TestHelper.createSearchParameters();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].resourceType = SearchBlackBox.CONTRACTOR + ' Band 1';
        ROs[1].resourceType = SearchBlackBox.CONTRACTOR + ' Band 2';
        
        JobResourcingOption jro1 = new JobResourcingOption();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption();
        jro2.addPrimaryOptions(new List<ResourceOption> {ROs[1]});
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 1;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1}); 
    }
    
    static testMethod void resourceTypeTest3() {
    	Phase3TestHelper.createSearchParameters();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].resourceType = SearchBlackBox.CONTRACTOR + ' Band 1';
        ROs[1].resourceType = SearchBlackBox.CONTRACTOR + ' Band 1';
        
        JobResourcingOption jro1 = new JobResourcingOption();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption();
        jro2.addPrimaryOptions(new List<ResourceOption> {ROs[1]});
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 1;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
    }
    
    static testMethod void remainingGapTest1() {
    	Phase3TestHelper.createSearchParameters();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].resourceType = SearchBlackBox.OWN_LABOUR;
        ROs[1].resourceType = SearchBlackBox.OWN_LABOUR;
        ROs[0].hoursRemainingInGap = 0;
        ROs[1].hoursRemainingInGap = 9;
        
        JobResourcingOption jro1 = new JobResourcingOption();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption();
        jro2.addPrimaryOptions(new List<ResourceOption> {ROs[1]});
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 1;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1}); 
    }
    
    static testMethod void remainingGapTest2() {
    	Phase3TestHelper.createSearchParameters();
        List<ResourceOption> ROs = createResourceOptions1();
        ROs[0].resourceType = SearchBlackBox.OWN_LABOUR;
        ROs[1].resourceType = SearchBlackBox.OWN_LABOUR;
        ROs[0].hoursRemainingInGap = 2;
        ROs[1].hoursRemainingInGap = -1;
        
        JobResourcingOption jro1 = new JobResourcingOption();
        jro1.addPrimaryOptions(new List<ResourceOption> {ROs[0]});
        
        JobResourcingOption jro2 = new JobResourcingOption();
        jro2.addPrimaryOptions(new List<ResourceOption> {ROs[1]});
        
        jro1.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro2.primaryStartDT = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(8,0,0,0));
        jro1.primaryHasSkillsRemoved = true;
        jro2.primaryHasSkillsRemoved = true;
        jro1.lowestGeography = 'Primary';
        jro2.lowestGeography = 'Primary';
        jro1.primarySkillsCount = 1;
        jro2.primarySkillsCount = 1;
        
        RankOptions rank = new RankOptions();
        rank.rankOptions(new List<JobResourcingOption>{jro1, jro2});
        rank.rankOptions(new List<JobResourcingOption>{jro2, jro1}); 
    }
}