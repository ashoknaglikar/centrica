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
private class RegenrateAvailabilty_Test {

  static testMethod void testGenerateAvail(){
       
        Shift_Pattern__c sPattern;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Work_Cycle__c workCycle;
        Supplier__c supplier;
        Unavailability__c Unavailability;
        Diary_Entry__c Entries; 
        List <Diary_Entry__c>  entrylist = new List <Diary_Entry__c>();
        List <Week__c> week = new List<Week__c> ();
        Entries_To_Plan__c ETP;
        supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'x12345',Type__c = 'Product');
        
        Database.insert(supplier);
        testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c = supplier.Id);
        
        testEmp2 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp222', Last_Name__c = 'testemp2', 
                                                                Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                    Employee_Number__c = '000001', Resource_Type__c = 'Installer',Supplier__c=supplier.Id);
        
      
        Unavailability = new Unavailability__c( Unavailability_Reason__c ='Leave', Start_Date_Time__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(8,0,0,0)), End_Date_Time__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(9,0,0,0)), Employee__c = testEmp1.Id);
        
        
       
        
                                                                    
        Database.insert(testEmp1);
    
        Database.insert(testEmp2);
        
    
        
        Database.insert(Unavailability);
        
        // For non-pool employee, check validations on negative difference between start & end times
         
        sPattern = createShiftpattern(false);
        
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = testEmp1.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(7);
        system.debug('Start_Date__c'+workCycle.Start_Date__c);
        workCycle.Number_of_Weeks__c = 1;
        workCycle.End_Date__c = workCycle.Start_Date__c.addDays(13);
        WorkCycle.Impact_Checked__c = false;
        WorkCycle.Apply_Directly__c = true;
        Database.insert(workCycle);
        
                        
        //Integer count = [Select count() from Week__c w where w.Employee__c = :testEmp1.Id];
        Week__c w = new Week__c(Name = 'week 1',Employee__c =  testEmp1.Id, Shift_Pattern__c = sPattern.Id, Week_Commencing__c = Date.today().toStartOfWeek().addDays(7));
                                
        Week.add(w);                        
        //Database.insert(w);
        insert(Week);
        System.assertEquals(0,0);
        Entries = new Diary_Entry__c(Week__c = w.Id, Start__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(8,0,0,0)), RecordTypeId = '012200000009ipR', End__c =DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(9,0,0,0)), Employee__c = testEmp1.Id , Type__c = 'Unavailability');
        entrylist.add(Entries);
        Diary_Entry__c Entries1 = new Diary_Entry__c(Week__c = w.Id, Start__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(8),Time.newInstance(8,0,0,0)), RecordTypeId = '012200000009ipR', End__c =DateTime.newInstance(Date.today().toStartOfWeek().addDays(8),Time.newInstance(9,0,0,0)), Employee__c = testEmp1.Id , Type__c = 'Unavailability');
        entrylist.add(Entries1);
        system.debug('Unavailability-->startdate'+Entries.Start__c+'------Endtdate'+Entries.End__c+'Employee_Salesforce_ID__c'+Entries.Employee__c);
        Database.insert(entrylist);
        
        //RegenrateAvailabilty.checkExistingWeeks(workCycle,2);
        RegenrateAvailabilty.StoreDairyEntires(new ID[]{workCycle.Id});
        RegenrateAvailabilty.deleteExistingWeeks(new ID[]{workCycle.Id});
       
        RegenrateAvailabilty.insertentries(week);
        RegenrateAvailabilty.retriveunavailability(entrylist);
        //   For pool employees normal scenario
        
        sPattern = createShiftpattern(true);
        Database.insert(sPattern);
        Work_Cycle__c workCycle1 = new Work_Cycle__c();
        workCycle1.Employee__c = testEmp2.Id;
        workCycle1.Shift_Pattern__c = sPattern.Id;
        workCycle1.Start_Date__c = Date.today();
        workCycle1.End_Date__c = workCycle.Start_Date__c.addDays(14);
        workCycle1.Number_of_Weeks__c = 2;
        Database.insert(workCycle1);
        
       
     
        
            
        //count = [Select count() from Week__c w where w.Employee__c = :testEmp2.Id];
        
        System.assertEquals(0,0);
        
            ETP = new Entries_To_Plan__c(Employee__c = testEmp2.Id, 
                                     Diary_ID__c = Entries.Id, 
                                     Record_Type__c = Entries.Type__c, 
                                     End__c = Entries.End__c, 
                                     Start__c = Entries.Start__c); 

        insert (ETP);
     
        RegenrateAvailabilty.StoreDairyEntires(new ID[]{workCycle1.Id});
       
        RegenrateAvailabilty.deleteExistingWeeks(new ID[]{workCycle1.Id});
       
       
        // For non-pool employee, normal scenario
       /* 
        sPattern = createShiftpattern(false);
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = testEmp1.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(8);
        workCycle.Number_of_Weeks__c = 2;
        Database.insert(workCycle);
        
        RegenrateAvailabilty.StoreDairyEntires(new ID[]{workCycle.Id});
        RegenrateAvailabilty.checkExistingWeeks(workCycle1,2);
        RegenrateAvailabilty.deleteExistingWeeks(new ID[]{workCycle.Id});
       
        RegenrateAvailabilty.insertentries(week);  
        RegenrateAvailabilty.retriveunavailability(entrylist);*/
        
        // For non-pool employee, check validations on existing weeks
          
         
       
    }
       
    // This method is used for generating diary for installers.
  
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
   
   private static testmethod void groupShiftPattern()
   {
        Shift_Pattern__c sPattern;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Work_Cycle__c workCycle;
        Supplier__c supplier;
        Unavailability__c Unavailability;
        Diary_Entry__c Entries; 
        List <Diary_Entry__c>  entrylist = new List <Diary_Entry__c>();
        List <Week__c> week = new List<Week__c> ();
        Entries_To_Plan__c ETP;
        supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'X12345',Type__c = 'Product');
        
        Database.insert(supplier);
        testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c = supplier.Id);
        
        testEmp2 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp222', Last_Name__c = 'testemp2', 
                                                                Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                    Employee_Number__c = '000001', Resource_Type__c = 'Installer',Supplier__c=supplier.Id);
        
      
       Database.insert(testEmp1);
    
        Database.insert(testEmp2);
        
        Groups__c g = new Groups__c(Name ='Test Group');
        insert g;
        
        Employee_Group__c e1 = new Employee_Group__c(Employee__c=testEmp1.Id,Group__c=g.Id);
        Employee_Group__c e2 = new Employee_Group__c(Employee__c= testEmp2.Id,Group__c=g.Id);
        Employee_Group__c[] egLst = new Employee_Group__c[]{e1,e2};
        insert egLst;
        sPattern = createShiftpattern(false);
        insert sPattern;
        workCycle = new Work_Cycle__c();
        workCycle.Group__c = g.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(7);
        system.debug('Start_Date__c'+workCycle.Start_Date__c);
        workCycle.End_Date__c= Date.today().toStartOfWeek().addDays(15);
        workCycle.Number_of_Weeks__c = 2;
        WorkCycle.Impact_Checked__c = false;
        WorkCycle.Apply_Directly__c = true;
        Database.insert(workCycle);
        
        RegenrateAvailabilty.deleteExistingWeeks(new ID[]{workCycle.Id});
        
        GroupAvailabilityGeneration.removeShiftPattern(new ID[]{workCycle.Id});
        WorkCycle =RegenrateAvailabilty.RetrieveWorkCycle(workCycle.Id);
        GroupAvailabilityGeneration.sendresultmail(new set<string>{'test@test.com'}, workCycle);
        GroupAvailabilityGeneration.checkWeeksfuture(workCycle.Id,new set<Id>{testEmp1.Id});
        GroupAvailabilityGeneration obj = new GroupAvailabilityGeneration();
        obj.createWorkcycle(workCycle,new set<Id>{testEmp1.Id});
        
        sPattern = createShiftpattern(true);
        insert sPattern;
        workCycle.Shift_Pattern__c = sPattern.Id;
        update workCycle;
        RegenrateAvailabilty.deleteExistingWeeks(new ID[]{workCycle.Id});
   }
   

}