@isTest
private class TestEmployeeInformation {

    @isTest
    public static void testEmployeeInformationPCS() {
        
        job__c job = Phase3TestHelper.createjob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        Employee__c emp = Phase3TestHelper.createEmployeeAndPostcodeSectors();
        EmployeeInformation ei = new EmployeeInformation(emp);
    }

    @isTest
    public static void testEmployeeInformationDistrict() {
        Job__c job = Phase3TestHelper.createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        Employee__c emp = Phase3TestHelper.createEmployeeCoversDistrict();
        EmployeeInformation ei = new EmployeeInformation(emp);
    }

    @isTest
    public static void testEmployeeInformationArea() {
        Job__c job = Phase3TestHelper.createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        Employee__c emp = Phase3TestHelper.createEmployeeCoversArea();
        EmployeeInformation ei = new EmployeeInformation(emp);
    }

    @isTest
    public static void testEmployeeInformationMethods() {
        Phase3TestHelper.createSearchParameters();
        Job__c job = Phase3TestHelper.createJob1();
        JobInformation ji = new JobInformation(job.ID);
        SearchBlackBox sbb = new SearchBlackBox(job.ID);
        sbb.setJobInfo(ji);
        BlackBoxOptions bbo = new BlackBoxOptions();
        sbb.setOptions(bbo);
        Employee__c emp = Phase3TestHelper.createEmployeeCoversArea();
        EmployeeInformation ei = new EmployeeInformation(emp);
        ei.skills.add('Mechanical');
        ei.skillsAndHours.put('Mechanical', 2.0);
        ei.skillsAndODOMJ.put('Mechanical', false);
        Set<String> testSkills = new Set<String>{'Mechanical'};
        Double result = ei.getHoursForSkills(testSkills);
        System.assertEquals(result, 2.0);
        Set<String> skillResults = ei.getSkills(testSkills);
        System.assertEquals(skillResults.size(), 1);
        System.assertEquals(skillResults.remove('Mechanical'), true);
        skillResults = ei.getSkillsNotODOMJ(testSkills);
        System.assertEquals(skillResults.size(), 1);
        System.assertEquals(skillResults.remove('Mechanical'), true);
        System.assertEquals(ei.isRightResourceTypeForPrimary(), true);
        System.assertNotEquals(skillResults.size(), 3);
        Employee__c emp2 = Phase3TestHelper.createContractorEmployee();
        System.debug('emp2 own labour? ' + emp2.Own_Labour__c);
        EmployeeInformation ei2 = new EmployeeInformation(emp2);
        System.assertEquals(ei2.isRightResourceTypeForPrimary(), true);
        SearchBlackBox.optsAndParms.contractors = false;
        System.assertEquals(ei2.isRightResourceTypeForPrimary(), false);
    }

    public static TestMethod void GroupMembershipTester(){
        
        Supplier__c sup = TestClassHelper.createSupplier();
        
        insert sup;
        
        
        Employee__c e = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc123', 
        Resource_Type__c='Installer',
        Pool_Diary__c = false, 
        Supplier__c = sup.Id);
        insert e;
        
        Groups__c g = new Groups__c(Name='test');
        insert g;
        
        Employee_Group__c eg = new Employee_Group__c(Employee__c=e.Id, Group__c=g.Id);
        insert eg;
        
    }

/*  @istest
    public static void testEmployeeInformation() {
        ID avRTID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
        Employee__c emp = new Employee__c(Name = 'testEmployeeInformation', 
                                            Last_Name__c = 'EmployeeInformation',
                                            First_Name__c = 'test',
                                            Employee_Number__c = '00029991');
        Database.insert(emp);
        
        Week__c week = new Week__c(Employee__c = emp.ID, Week_Commencing__c = Date.newInstance(2009, 10, 12));
        Database.insert(week);
        
        Diary_Entry__c de = new Diary_Entry__c(Start__c = Datetime.newInstance(2009, 10, 12, 9, 0, 0),
                                                End__c = Datetime.newInstance(2009, 10, 15, 18, 0, 0),
                                                Hours__c = 36.0, RecordTypeId = avRTID, Employee__c = emp.ID, Week__c = week.ID);
        Database.insert(de);
        
        EmployeeInformation ei = new EmployeeInformation(emp);
        
        List<String> times = new List<String>{'09:00', '09:00', '09:00', '09:00', '09:00', '09:00', '09:00'};
        ei.dayStartTimes = new Map<ID, List<String>>{de.ID => times};

        times = new List<String>{'18:00', '18:00', '18:00', '18:00', '18:00', '18:00', '18:00'};
        ei.dayEndTimes = new Map<ID, List<String>>{de.ID => times};
        
        Datetime result = ei.calculateEndDT(de, 15.0);
        
        System.debug('RESULT: ' + result);
        
        result = ei.calculateEndDT(de, 25);
        
        System.debug('RESULT: ' + result);
    }*/
}