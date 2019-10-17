/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestCont_Unavailability {

    static testMethod void testUnavailabilityEntries() {
        
        Work_Cycle__c workCycle;
        Work_Cycle__c workCycle1;
        Shift_Pattern__c sPattern;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Entries_To_Plan__c ETP;
        Entries_To_Plan__c ETP1;
        Supplier__c supplier;
        Unavailability__c Unavailability1;
        Unavailability__c Unavailability2;
        Diary_Entry__c Entries; 
        Diary_Entry__c Entries1; 
        List <Week__c> week = new List<Week__c> ();
        
        supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'x12345',Type__c = 'Product');
        
        Database.insert(supplier);
        testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c = supplier.Id);
        
        testEmp2 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp222', Last_Name__c = 'testemp2', 
                                                                Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                    Employee_Number__c = '000001', Resource_Type__c = 'Installer',Supplier__c=supplier.Id);
        
        Database.insert(testEmp1);
    
        Database.insert(testEmp2);
        
          
        sPattern = createShiftpattern(false);
        sPattern.Monday_End_Time__c = '00:00';
        sPattern.Tuesday_End_Time__c = '00:00';
        sPattern.Wednesday_End_Time__c = '00:00';
        sPattern.Thursday_End_Time__c = '00:00';
        sPattern.Friday_End_Time__c = '00:00';
        sPattern.Saturday_End_Time__c = '00:00';
        sPattern.Sunday_End_Time__c = '00:00';
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = testEmp1.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today();
        workCycle.End_Date__c = Date.today().addDays(8);
        workCycle.Number_of_Weeks__c = 2;
        
        workCycle1 = new Work_Cycle__c();
        workCycle1.Employee__c = testEmp2.Id;
        workCycle1.Shift_Pattern__c = sPattern.Id;
        workCycle1.Start_Date__c = Date.today();
        workCycle1.End_Date__c = Date.today().addDays(8);
        workCycle1.Number_of_Weeks__c = 2;
    
        Database.insert(workCycle);
        
        Database.insert(workCycle1);
        
        Integer count = [Select count() from Week__c w where w.Employee__c = :testEmp1.Id];
        Week__c w = new Week__c(Employee__c =  testEmp1.Id, Shift_Pattern__c = sPattern.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
                                Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
                                Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
                                
        Week.add(w);                        
        Database.insert(w);
        System.assertEquals(0, count);
        Entries = new Diary_Entry__c(Week__c = w.Id, Start__c = system.today(), RecordTypeId = '012200000009ipR', End__c =system.today() + 2 , Employee__c = testEmp1.Id , Type__c = 'Unavailability');
        Entries1 = new Diary_Entry__c(Week__c = w.Id, Start__c = system.today(), RecordTypeId = '012200000009ipR', End__c =system.today() + 2 , Employee__c = testEmp1.Id , Type__c = 'Unavailability');
        Database.insert(Entries);
        insert(Entries1);
        ETP = new Entries_To_Plan__c(Employee__c = testEmp1.Id, 
                                     Diary_ID__c = Entries.Id, 
                                     Record_Type__c ='Unavailability', 
                                     End__c = system.today() + 2, 
                                     Start__c = system.today());
        ETP1 = new Entries_To_Plan__c(Employee__c = testEmp1.Id, 
                                     Diary_ID__c = Entries1.Id, 
                                     Record_Type__c = 'Unavailability', 
                                     End__c = system.today() + 2, 
                                     Start__c = system.today());
        insert(ETP);
        insert(ETP1);
        Unavailability1 = new Unavailability__c( Unavailability_Reason__c ='Leave', Start_Date_Time__c = system.today(), End_Date_Time__c = system.today() + 2, Employee__c = testEmp1.Id);
        Unavailability2 = new Unavailability__c( Unavailability_Reason__c ='Leave', Start_Date_Time__c = system.today(), End_Date_Time__c = system.today() + 2, Employee__c = testEmp1.Id);
        Database.insert(Unavailability1);
        insert(Unavailability2);
                                     
        PageReference pageRef = new PageReference('apex/UnavailabilityEntries?s='+ workCycle.Id); 
        
        Test.setCurrentPage(pageRef);
        Cont_UnavailabilityEntriesPage controller = new Cont_UnavailabilityEntriesPage();
        controller.getEntries();
        controller.RemoveUnavilabilities();
        controller.deleterecords();
        
        PageReference pageRef1 = new PageReference('apex/UnavailabilityEntries?s='+ workCycle1.Id); 
        
        Test.setCurrentPage(pageRef1);
        Cont_UnavailabilityEntriesPage controller1 = new Cont_UnavailabilityEntriesPage();
        controller1.getEntries();
        controller1.RemoveUnavilabilities();
        controller1.deleterecords();
            }
 public static Shift_Pattern__c createShiftpattern(Boolean isPoolShiftPattern){
    
    Shift_Pattern__c shp = new Shift_Pattern__c();
    
    shp.Pool_Shift_Pattern__c = isPoolShiftPattern;
    
    shp.Monday_Start_Time__c = '08:00';
    shp.Tuesday_Start_Time__c = '08:00';
    shp.Wednesday_Start_Time__c = '08:00';
    shp.Thursday_Start_Time__c = '08:00';
    shp.Friday_Start_Time__c = '08:00';
    shp.Saturday_Start_Time__c = '08:00';
    shp.Sunday_Start_Time__c = '08:00';
    
    shp.Monday_End_Time__c = '18:00';
    shp.Tuesday_End_Time__c = '18:00';
    shp.Wednesday_End_Time__c = '18:00';
    shp.Thursday_End_Time__c = '18:00';
    shp.Friday_End_Time__c = '18:00';
    shp.Saturday_End_Time__c = '18:00';
    shp.Sunday_End_Time__c = '18:00';
    
    if(isPoolShiftPattern){
        
        shp.Name = 'Sample pool shift pattern';
        shp.Monday_Max_Hours__c = 50;
        shp.Tuesday_Max_Hours__c = 50;
        shp.Wednesday_Max_Hours__c = 50;
        shp.Thursday_Max_Hours__c = 50;
        shp.Friday_Max_Hours__c = 50;
        shp.Saturday_Max_Hours__c = 50;
        shp.Sunday_Max_Hours__c = 50;
        
    }else {
        
        shp.Name = 'Sample non-pool shift pattern';
        
    }
    
    return shp;
    
   }
        // TO DO: implement unit test
    }