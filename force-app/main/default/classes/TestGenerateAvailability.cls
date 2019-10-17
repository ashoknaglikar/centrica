@isTest
private class TestGenerateAvailability {
    
  static testMethod void testGenerateAvail(){
       
        Shift_Pattern__c sPattern;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Employee__c testEmp3;
        Employee__c testEmp4;
        Work_Cycle__c workCycle;
        
        Supplier__c Supplier = new Supplier__c (Supplier_Num__c = '111b');
        database.insert(supplier);
        testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c =Supplier.id );
        
        testEmp2 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp222', Last_Name__c = 'testemp2', 
                                                                Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                    Employee_Number__c = '000001', Resource_Type__c = 'Installer', Supplier__c =Supplier.id);
        testEmp3 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp223', Last_Name__c = 'testemp3', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222233', 
                                                                    Employee_Number__c = '000003', Resource_Type__c = 'Installer', Supplier__c =Supplier.id);
        testEmp4 = new Employee__c(Name = 'Test44', First_Name__c = 'testemp444', Last_Name__c = 'testemp4', 
                                                                Pool_Diary__c = false, Phone_No__c = '0744444444', 
                                                                    Employee_Number__c = '000004', Resource_Type__c = 'Installer', Supplier__c =Supplier.id);                                                                                                                                        
        Employee__c[] lstEmp = new Employee__c[]{testEmp1,testEmp2,testEmp3,testEmp4};
        Database.insert(lstEmp);
    
        //Database.insert(testEmp2);
        
        // For non-pool employee, check validations on negative difference between start & end times
         
        sPattern = createShiftpattern(false);
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = lstEmp[0].Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(2000);
        workCycle.End_Date__c = Date.today().toStartOfWeek().addDays(2008);
        workCycle.Number_of_Weeks__c = 2;
        Database.insert(workCycle);
        
        GenerateAvailability.createAvailability(new ID[]{workCycle.Id});
        
        Integer count = [Select count() from Week__c w where w.Employee__c = :lstEmp[0].Id];
        
        System.assertEquals(2, count);
      
        // For non-pool employee, check validations on negative difference between start & end times
        
        
        //   For pool employees normal scenario
        
        sPattern = createShiftpattern(true);
        Database.insert(sPattern);
        Work_Cycle__c workCycle1 = new Work_Cycle__c();
        workCycle1.Employee__c = lstEmp[1].Id;
        workCycle1.Shift_Pattern__c = sPattern.Id;
        workCycle1.Start_Date__c = Date.today();
        workCycle1.End_Date__c = Date.today().addDays(8);
        workCycle1.Number_of_Weeks__c = 2;
        Database.insert(workCycle1);
        
        GenerateAvailability.createAvailability(new ID[]{workCycle1.Id});
        
        count = [Select count() from Week__c w where w.Employee__c = :lstEmp[1].Id];
        
        //System.assertEquals(0, count);
        
    }
    
  static testmethod void UnavailHoursIsNull(){
        Work_Cycle__c workCycle;
        Supplier__c Supplier = new Supplier__c (Supplier_Num__c = '111b');
        database.insert(supplier);
        Employee__c testEmp1= new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c =Supplier.id );
        
        database.insert(testEmp1);
        Shift_Pattern__c sPattern = createShiftpattern(false);
        sPattern.Mon_Unav_End_Time__c = NULL;
        sPattern.Tue_Unav_End_Time__c = NULL;
        sPattern.Wed_Unav_End_Time__c = NULL;
        sPattern.Thu_Unav_End_Time__c = NULL;
        sPattern.Fri_Unav_End_Time__c = NULL;
        sPattern.Sat_Unav_End_Time__c = NULL;
        sPattern.Sun_Unav_End_Time__c = NULL;
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = testEmp1.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(2001);
        workCycle.End_Date__c = Date.today().toStartOfWeek().addDays(2009);
        workCycle.Number_of_Weeks__c = 2;
        Database.insert(workCycle);
        
        GenerateAvailability.createAvailability(new ID[]{workCycle.Id});
        
        Integer count = [Select count() from Week__c w where w.Employee__c = :testEmp1.Id];
        
        //System.assertEquals(2, count);
  
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
    
    shp.Mon_Unav_Start_Time__c = '08:00';
    shp.Tue_Unav_Start_Time__c = '08:00';
    shp.Wed_Unav_Start_Time__c = '08:00';
    shp.Thu_Unav_Start_Time__c = '08:00';
    shp.Fri_Unav_Start_Time__c = '08:00';
    shp.Sat_Unav_Start_Time__c = '08:00';
    shp.Sun_Unav_Start_Time__c = '08:00';
    
    shp.Mon_Unav_End_Time__c = '18:00';
    shp.Tue_Unav_End_Time__c = '18:00';
    shp.Wed_Unav_End_Time__c = '18:00';
    shp.Thu_Unav_End_Time__c = '18:00';
    shp.Fri_Unav_End_Time__c = '18:00';
    shp.Sat_Unav_End_Time__c = '18:00';
    shp.Sun_Unav_End_Time__c = '18:00';
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

}