@isTest
private class diaryEntryTriggerHelper_Test{
   @Testsetup
   static void createTestData(){
      
      Account acc = TestclassHelper.createAccout();
       Database.insert(acc);
       
       Opportunity opp = TestclassHelper.createCHILead(acc);
       database.insert(opp);
       
       
       Job__c j = new Job__c();
        j.CHI_Lead__c = opp.Id;
        j.Status__c = 'Planned';
        j.Mechanical_Hours__c = 12;
      insert j;
      
      Employee__c e = Phase3TestHelper.createEmployee();
      e.salesforce_User__c = userInfo.getuserId();
      update e;
      Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
      Database.insert(sp);
      Week__c wk = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
      Database.insert(wk);
      DateTime dt;
      dt = DateTime.parse(wk.Week_Commencing__c.format()+' '+ sp.Monday_Start_Time__c);
      Diary_Entry__c[] diaryEntries= new list<Diary_Entry__c>();
        diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Mechanical',
        Job__c = j.Id,
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 27),//adding a bit more to allow move overnight
        Hours__c = 12,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'),
        Overbooked_Hours__c=0.00
        ));
        
        dt = DateTimeHelper.addHoursToDT(dt, 27);
       double d = 1.5;
       diaryEntries.add(new Diary_Entry__c(
            Week__c = wk.Id,
            Sub_Type__c = 'Availability',
            Start__c = DateTimeHelper.addHoursToDT(dt, 0) ,
            End__c = DateTimeHelper.addHoursToDT(dt, d),
            Hours__c = 1.5,
            RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'),
            Overbooked_Hours__c=0.00
        ));
       
       dt = DateTimeHelper.addHoursToDT(dt, d);
       d = 0.5;
       diaryEntries.add(new Diary_Entry__c(
            Week__c = wk.Id,
            Sub_Type__c = 'Unavailability',
            Start__c = dt ,
            End__c = DateTimeHelper.addHoursToDT(dt, d),
            Hours__c = 0.5,
            RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'),
            Overbooked_Hours__c=0.00
        ));
       
       dt = DateTimeHelper.addHoursToDT(dt, d);
       
       diaryEntries.add(new Diary_Entry__c(
            Week__c = wk.Id,
            Sub_Type__c = 'Availability',
            Start__c = dt ,
            End__c = DateTimeHelper.addHoursToDT(dt, 2),
            Hours__c = 2.0,
            RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'),
            Overbooked_Hours__c=0.00
        ));
       
          
       insert diaryEntries;
     
   
   }
   
   static testmethod void Testcase1(){
      
      week__c we = [select id,name,employee__c,week_commencing__c,shift_pattern__c from week__c];
      List<Diary_entry__c> des = [select id,name,start__c,job__c,Job__r.name,end__c,Overbooked_Hours__c,hours__c,week__c,week__r.employee__c,sub_type__c,recordtypeId from Diary_Entry__c];
      Map<string,list<Diary_Entry__c>> m = new map<string,list<Diary_Entry__c>>();
      for(Diary_Entry__c d: des){
         if(m.containskey(d.week__c)){
           list<diary_Entry__c> de1 = new list<Diary_Entry__c>();
           de1.addAll(m.get(d.week__c));
           de1.add(d);
           m.put(d.week__c,de1);
           
         }else{
            m.put(d.week__c,new list<Diary_Entry__c>{d});
         }
      }
      system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=->atest:'+m);
      Test.StartTest();
        diaryEntryTriggerHelper.processDiaryEntry(m);
      Test.stopTest();
      
   }
 }