@istest
public class customerPortalHSAPlanHelperTest {    
   public static List<Employee__c> empList = new List<Employee__c>(); 
    
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
    
    static District__c createTestDistrict() {
        Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation',Geography_Code__c ='09');
        
        Database.insert(testRegion);
        
        District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
        Database.insert(testDistrict);
        
        return testDistrict;
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
    
     static List<Employee__c> setupScenario1() {
        Date startD = Date.today(); 
        Date endD = startD.addDays(5); 
        
        District__c district = createTestDistrict();
        Postcode_Sector__c pcs = createTestPostcodeSector(district);
        
        Supplier__c ownSupplier = createOwnSupplier();
        Supplier__c otherSupplier = createOtherSupplier();
        
        List<List<String>> skills = new List<List<String>>{};
        List<List<Boolean>> ownJobsOnly = new List<List<Boolean>>{};
        
        
        skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'PAYMENT COLLECTION'});
        ownJobsOnly.add(new List<Boolean> {false, false, false});
        
        skills.add(new List<String> {'MECHANICAL', 'POWERFLUSH', 'LPG INSTALLATION'});
        ownJobsOnly.add(new List<Boolean> {false, false, false});
        
        skills.add(new List<String> {'MECHANICAL', 'CONNECT SOLAR PANELS', 'PAYMENT COLLECTION'});
        ownJobsOnly.add(new List<Boolean> {false, false, false});
         
        skills.add(new List<String> {'MECHANICAL'});
        ownJobsOnly.add(new List<Boolean> {false});
        
        skills.add(new List<String> {'MECHANICAL'});
        ownJobsOnly.add(new List<Boolean> {false});     
        
        skills.add(new List<String> {'ELECTRICAL'});
        ownJobsOnly.add(new List<Boolean> {false});
        
        skills.add(new List<String> {'MECHANICAL', 'CONNECT SOLAR PANELS'});
        ownJobsOnly.add(new List<Boolean> {false, false});
        
        skills.add(new List<String> {'MECHANICAL', 'LPG INSTALLATION', 'PAYMENT COLLECTION'});
        ownJobsOnly.add(new List<Boolean> {false, false, false});
        
        List<SBBTestEmployee> emps = new List<SBBTestEmployee>();
        List<Employee__c> empSObjects = new List<Employee__c>();
        
        for(Integer i = 0 ; i < 4; i++) {
            SBBTestEmployee emp = new SBBTestEmployee(skills[i], ownJobsOnly[i], 'test', 'SBB' + i.format(), 
                                                        '000299' + i.format(), ownSupplier.ID, district.ID);
            emps.add(emp);
            empSObjects.add(emp.createEmployeeSObject());
        }
        
        for(Integer i = 4 ; i < 8; i++) {
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
            DateTime endDT = DateTime.newInstance(startD.adddays(5), Time.newInstance(17,0,0,0));
            Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Week__c = w.ID, Hours__c = 9,
                                                    RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

            System.debug('de.Start__c: ' + de.Start__c);
            System.debug('de.End__c: ' + de.End__c);
            
            des.add(de);
        }
        
        Database.insert(des);
        
        
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
    
     static testmethod void HSAplanTest1() {
        List<Employee__c> employees = setupScenario1();
        Employee__c named = employees[0];
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', /*Double_Handed_Job__c = true,*/
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,  
                                Customer_PreElectric__c=false,Asbestos_Removal_Hours__c=0,Mechanical_Hours__c=7);
        job = insertJob(job);
        
        date customerPreferredDate = system.today();
        customerPortalPlanJobAPI.planJob(string.valueof(opp.id),string.valueof(quote.id),String.valueof(job.id),customerPreferredDate, 'Next'); 
         
        
    }
     static testmethod void HSAplanTest2() {
        List<Employee__c> employees = setupScenario1();
        Employee__c named = employees[0];
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c='Pending', Pending_Reason__c = 'Contact Customer', /*Double_Handed_Job__c = true,*/
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,  
                                Customer_PreElectric__c=false,Asbestos_Removal_Hours__c=0,Mechanical_Hours__c=7,PowerFlush_Hours__c = 4, Electrical_Hours__c = 3);
        job = insertJob(job);         
        
        date customerPreferredDate1;
        customerPortalPlanJobAPI.planJob(string.valueof(opp.id),string.valueof(quote.id),String.valueof(job.id),customerPreferredDate1, 'Previous'); 
    }
 }