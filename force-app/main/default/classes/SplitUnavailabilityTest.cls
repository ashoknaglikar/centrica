@isTest
private class SplitUnavailabilityTest {
  public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    
  static testMethod void splitUnavailability(){
        
        Shift_Pattern__c sPattern;
        sPattern = createShiftpattern(false);
        Database.insert(sPattern);
        Supplier__c Supplier = new Supplier__c (Supplier_Num__c = '111b');
        database.insert(supplier);
        
        Employee__c firstEmp  = new Employee__c(Name = 'Test111', First_Name__c = 'unavailable1', Last_Name__c = 'scenario1', 
                                                                              Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                              Employee_Number__c = '1234995', Resource_Type__c = 'Installer',Supplier__c=Supplier.id);
       
        Database.insert(firstEmp);
        
        Week__c week = new Week__c(Employee__c=firstEmp.Id,Shift_Pattern__c=sPattern.id);
        insert week;
        Diary_Entry__c de1 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de1.start__c,de1.end__c,de1);
        
        Diary_Entry__c de2 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de2.start__c,de2.end__c,de2 );
        
        Diary_Entry__c de3 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de3.start__c,de3.end__c,de3);
        
        Diary_Entry__c de4 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(3),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de4.start__c,de4.end__c,de4);
        
        Diary_Entry__c de5 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de5.start__c,de5.end__c,de5);
        
        Diary_Entry__c de6 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de6.start__c,de6.end__c,de6);
       
        Diary_Entry__c de7 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de7.start__c,de7.end__c,de7);
        
        Diary_Entry__c de21 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(1), End__c = datetime.now().adddays(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de21.start__c,de21.end__c,de21 );
        
        Diary_Entry__c de31 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(1), End__c = datetime.now().adddays(3),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de31.start__c,de31.end__c,de31);
        
        Diary_Entry__c de41 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(1), End__c = datetime.now().adddays(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de41.start__c,de41.end__c,de41);
        
        Diary_Entry__c de51 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(1), End__c = datetime.now().adddays(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de51.start__c,de51.end__c,de51);
        
        Diary_Entry__c de61 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(1), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de61.start__c,de61.end__c,de61);
        
        Diary_Entry__c de22 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(3),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de22.start__c,de22.end__c,de22 );
        
        Diary_Entry__c de32 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de32.start__c,de32.end__c,de32);
        
        Diary_Entry__c de42 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de42.start__c,de42.end__c,de42);
        
        Diary_Entry__c de52 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de52.start__c,de52.end__c,de52);
        
        Diary_Entry__c de62 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(7),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de62.start__c,de62.end__c,de62);
        
        Diary_Entry__c de72 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(2), End__c = datetime.now().adddays(8),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de72.start__c,de72.end__c,de72);
       
        Diary_Entry__c de33 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(3), End__c = datetime.now().adddays(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de33.start__c,de33.end__c,de33);
        
        Diary_Entry__c de43 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(3), End__c = datetime.now().adddays(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de43.start__c,de43.end__c,de43);
        
        Diary_Entry__c de53 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(3), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de53.start__c,de53.end__c,de53);
        
        Diary_Entry__c de63 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(3), End__c = datetime.now().adddays(7),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de63.start__c,de63.end__c,de63);
        
        Diary_Entry__c de73 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(3), End__c = datetime.now().adddays(8),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de73.start__c,de73.end__c,de73);
       
        Diary_Entry__c de44 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(4), End__c = datetime.now().adddays(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de44.start__c,de44.end__c,de44);
        
        Diary_Entry__c de54 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(4), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de54.start__c,de54.end__c,de54);
        
        Diary_Entry__c de64 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(4), End__c = datetime.now().adddays(7),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de64.start__c,de64.end__c,de64);
        
        Diary_Entry__c de74 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(4), End__c = datetime.now().adddays(8),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de74.start__c,de74.end__c,de74);
        
        Diary_Entry__c de55 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(6),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de55.start__c,de55.end__c,de55);
        
        Diary_Entry__c de65 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(7),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de65.start__c,de65.end__c,de65);
        
        Diary_Entry__c de75 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(8),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de75.start__c,de75.end__c,de75);
        
        Diary_Entry__c de85 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(9),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de85.start__c,de85.end__c,de85);
        
        Diary_Entry__c de95 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(10),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de95.start__c,de95.end__c,de95);
        
        Diary_Entry__c de105 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(5), End__c = datetime.now().adddays(11),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de105.start__c,de105.end__c,de105);
        
        Diary_Entry__c de66 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(6), End__c = datetime.now().adddays(7),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de66.start__c,de66.end__c,de66);
        
        Diary_Entry__c de76 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(6), End__c = datetime.now().adddays(8),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de76.start__c,de76.end__c,de76);
        
        Diary_Entry__c de86 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(6), End__c = datetime.now().adddays(9),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de86.start__c,de86.end__c,de86);
        
        Diary_Entry__c de96 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(6), End__c = datetime.now().adddays(10),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de96.start__c,de96.end__c,de96);
        
        Diary_Entry__c de106 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().adddays(6), End__c = datetime.now().adddays(11),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='NWD - Working');
        SplitUnavailableDiaryEntry.splitDiaryEntry(de106.start__c,de106.end__c,de106);
        
       
  }
 // method for creating shiftpattern
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