@isTest
private class TestCreateUnavailability {
  public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    
  static testMethod void testCreateUnavailability(){
       
        // Create shift pattern and insert it in database
        Shift_Pattern__c sPattern;
        sPattern = createShiftpattern(false);
        Database.insert(sPattern);
        
        Supplier__c Supplier = new Supplier__c (Supplier_Num__c = '111b');
        database.insert(supplier);
         
        // Generate employee and employee groups data
        
        Employee__c firstEmp  = new Employee__c(Name = 'Test111', First_Name__c = 'unavailable1', Last_Name__c = 'scenario1', 
                                                                              Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                              Employee_Number__c = '1234995', Resource_Type__c = 'Installer',Supplier__c=Supplier.id);
        Employee__c secondEmp = new Employee__c(Name = 'Test222', First_Name__c = 'unavailable2', Last_Name__c = 'scenario2', 
                                                                              Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                              Employee_Number__c = '456654', Resource_Type__c = 'Installer',Supplier__c=Supplier.id);
        Database.insert(firstEmp);
        Database.insert(secondEmp);
        Groups__c dummyGroup = new Groups__c(Name = 'Dummy Group');
        Database.insert(dummyGroup);
        Employee_Group__c empGroup1 = new Employee_Group__c(Group__c = dummyGroup.ID,Employee__c  = firstEmp.ID);
        Employee_Group__c empGroup2 = new Employee_Group__c(Group__c = dummyGroup.ID,Employee__c  = secondEmp.ID);
        Database.insert(empGroup1);
        Database.insert(empGroup2);

        // Create work cycle and generate diary for installers
        Work_Cycle__c workCycle = new Work_Cycle__c();
        workCycle.Employee__c = firstEmp.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek();
        workCycle.End_Date__c = Date.today().toStartOfWeek().addDays(28);
        workCycle.Number_of_Weeks__c = 5;
        Database.insert(workCycle);
        GenerateAvailability.createAvailability(new ID[]{workCycle.Id});
        workCycle.Employee__c = secondEmp.Id;
        Database.update(workCycle);     
        GenerateAvailability.createAvailability(new ID[]{workCycle.Id});

        // Create Unavailability record and start generating unavailability.
        Unavailability__c un = new Unavailability__c(Group__c=dummyGroup.ID,
                                                     Start_Date_Time__c = DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(8,0,0,0)),
                                                     End_Date_Time__c = DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(9,0,0,0)),
                                                     Unavailability_Reason__c = 'Deputising for DHM',
                                                     Unavailability_Notes__c = 'Test Notes');
        Database.insert(un);
        
        CreateUnavailability.generateUnavailability(new ID[]{un.Id},'mode');
        
        Integer unavailabilityCount = [Select count() from Diary_Entry__c where
                                             RecordTypeId = :(Utilities.getRecordTypeId('Unavailability', 'Diary_Entry__c')) and 
        
        Week__r.Employee__c in (:firstEmp.ID,:secondEmp.ID)];

        System.assertEquals(unavailabilityCount, 1);
        
        secondEmp.Pool_Diary__c = false;
        
        Database.Update(secondEmp);

        un.Generated_Unavailability__c = false;
        un.Start_Date_Time__c = DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(11,0,0,0));
        un.End_Date_Time__c =  DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(12,0,0,0));
        Database.update(un);
        CreateUnavailability.generateUnavailability(new ID[]{un.Id},'mode');
       
        Integer countDiaryEntries = [Select count() from Diary_Entry__c where Week__r.Employee__c in (:firstEmp.ID,:secondEmp.ID)];
        
        Week__c week = new Week__c(Employee__c=firstEmp.Id);
        insert week;
        Diary_Entry__c de1 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
        Diary_Entry__c de2 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
        Diary_Entry__c de3 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
        Diary_Entry__c de4 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(3), End__c = datetime.now().addhours(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
        Diary_Entry__c de5 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(4), End__c = datetime.now().addhours(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
        Diary_Entry__c[] diaryEntries1 = new Diary_Entry__c[]{de1,de2,de3,de4,de5};
        
        CreateUnavailability.groupEntries(diaryEntries1);
                                                                            
        //System.assertEquals(countDiaryEntries, 15);
       
  }

//This method is used for generating diary for installers
   
   public static Shift_Pattern__c createShiftpattern(Boolean isPoolShiftPattern){
    
    Shift_Pattern__c shp = new Shift_Pattern__c();
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
    shp.Name = 'Sample non-pool shift pattern';
    return shp;
    
   }
   
}