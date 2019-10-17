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
@isTest /*(seealldata = true)*/
private class GroupShiftPatternBatch_Test {

    static testMethod void myUnitTest() {
        
        Shift_Pattern__c sPattern1;
        Shift_Pattern__c sPattern2;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Work_Cycle__c workCycle1;
        Work_Cycle__c workCycle2;
        Supplier__c supplier;
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
        
        // For non-pool employee, check validations on negative difference between start & end times
         
        sPattern1 = createShiftpattern(false);
        sPattern2 = createShiftpattern(true);
        insert(sPattern1);
        insert(sPattern2);
        
        
        
        workCycle1 = new Work_Cycle__c(Employee__c = testEmp1.Id,Shift_Pattern__c = sPattern1.Id,Start_Date__c = Date.today().toStartOfWeek().addDays(7),End_date__c = Date.today().toStartOfWeek().addDays(13),Number_of_Weeks__c=1,Batch_Status__c = 'Process');
        workCycle2 = new Work_Cycle__c(Employee__c = testEmp2.Id,Shift_Pattern__c = sPattern2.Id,Start_Date__c = Date.today().toStartOfWeek().addDays(7),End_date__c = Date.today().toStartOfWeek().addDays(13),Number_of_Weeks__c=1,Batch_Status__c = 'Process');
        list<Work_Cycle__c> wcList = new list<Work_Cycle__c>();
        wcList.add(workCycle1);
        wcList.add(workCycle2);
        insert wcList;
        workCycle1.Work_Cycle__c = workCycle2.Id;
        workCycle2.Work_Cycle__c = workCycle1.Id;
        update wcList;
        
        //wcList = [Select Name,Error__c, Employee__c,Employee__r.Pool_Diary__c,Number_of_Weeks__c,Batch_Status__c, Shift_Pattern__c,Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,Shift_Pattern__r.Monday_Max_Hours__c,Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,Shift_Pattern__r.Tuesday_Max_Hours__c,Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,Shift_Pattern__r.Wednesday_Max_Hours__c,Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,Shift_Pattern__r.Thursday_Max_Hours__c,Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,Shift_Pattern__r.Friday_Max_Hours__c,Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,Shift_Pattern__r.Saturday_Max_Hours__c,Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,Shift_Pattern__r.Sunday_Max_Hours__c,Start_Date__c,Shift_Pattern__r.Pool_Shift_Pattern__c, Shift_Pattern__r.Sun_Unav_End_Time__c,Shift_Pattern__r.Sat_Unav_End_Time__c, Shift_Pattern__r.Fri_Unav_End_Time__c, Shift_Pattern__r.Thu_Unav_End_Time__c,Shift_Pattern__r.Wed_Unav_End_Time__c, Shift_Pattern__r.Tue_Unav_End_Time__c, Shift_Pattern__r.Mon_Unav_End_Time__c,Shift_Pattern__r.Sun_Unav_Start_Time__c, Shift_Pattern__r.Sat_Unav_Start_Time__c, Shift_Pattern__r.Fri_Unav_Start_Time__c,Shift_Pattern__r.Thu_Unav_Start_Time__c, Shift_Pattern__r.Wed_Unav_Start_Time__c, Shift_Pattern__r.Tue_Unav_Start_Time__c,Shift_Pattern__r.Mon_Unav_Start_Time__c,Shift_Pattern__r.Unavailability_Reason__c, CreatedBy.Email, Group__r.Name, Work_Cycle__c from Work_Cycle__c where id in: wcList];
        GroupShiftPatternBatch.createWrkCycleBatch();
        
        Database.BatchableContext BC;
        Test.startTest();
        GroupShiftPatternBatch gspr=new GroupShiftPatternBatch();       
        gspr.execute(BC,wcList); 
        gspr.finish(BC);
        system.assertequals(workCycle1.Batch_Status__c, 'Complete');
        
        
        workCycle1.Batch_Status__c = 'Process';
        update workCycle1;
        wcList = new list<Work_Cycle__c>();
        wcList = [Select Name,Error__c, Employee__c,Employee__r.Pool_Diary__c,Number_of_Weeks__c,Batch_Status__c, Shift_Pattern__c,Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,Shift_Pattern__r.Monday_Max_Hours__c,Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,Shift_Pattern__r.Tuesday_Max_Hours__c,Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,Shift_Pattern__r.Wednesday_Max_Hours__c,Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,Shift_Pattern__r.Thursday_Max_Hours__c,Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,Shift_Pattern__r.Friday_Max_Hours__c,Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,Shift_Pattern__r.Saturday_Max_Hours__c,Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,Shift_Pattern__r.Sunday_Max_Hours__c,Start_Date__c,Shift_Pattern__r.Pool_Shift_Pattern__c, Shift_Pattern__r.Sun_Unav_End_Time__c,Shift_Pattern__r.Sat_Unav_End_Time__c, Shift_Pattern__r.Fri_Unav_End_Time__c, Shift_Pattern__r.Thu_Unav_End_Time__c,Shift_Pattern__r.Wed_Unav_End_Time__c, Shift_Pattern__r.Tue_Unav_End_Time__c, Shift_Pattern__r.Mon_Unav_End_Time__c,Shift_Pattern__r.Sun_Unav_Start_Time__c, Shift_Pattern__r.Sat_Unav_Start_Time__c, Shift_Pattern__r.Fri_Unav_Start_Time__c,Shift_Pattern__r.Thu_Unav_Start_Time__c, Shift_Pattern__r.Wed_Unav_Start_Time__c, Shift_Pattern__r.Tue_Unav_Start_Time__c,Shift_Pattern__r.Mon_Unav_Start_Time__c,Shift_Pattern__r.Unavailability_Reason__c, CreatedBy.Email, Group__r.Name, Work_Cycle__c from Work_Cycle__c where id =: workCycle1.Id];
        wcList.add(workCycle1);
        
        gspr.execute(BC,wcList); 
        
        GroupShiftPattBatchScheduler obj = new GroupShiftPattBatchScheduler();
        SchedulableContext sc;
        obj.execute(sc);
        Test.stopTest();
        
        // TO DO: implement unit test
    }
    static Shift_Pattern__c createShiftpattern(Boolean isPoolShiftPattern){
    
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
}