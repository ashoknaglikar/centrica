@isTest
private class workdayReportHelper_Test{
   
   static Employee__c e;
   static void createTestData(){
      e = Phase3TestHelper.createEmployee();
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
      Week__c w = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
      Database.insert(w);
      
      /*DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
      DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
      Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='NWD - Working',
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
      Database.insert(de);*/
      string extId = w.Id+string.valueof(Date.Today());
      workdayReport__c wd = new workdayReport__c(Week__c=w.id,ExternalId__c=extId,Available_Hours__c=8.00,Date__c=Date.today(),Day__c='Monday',NWD__c=0.00,Unavailability_Hours__c=0.00);
      Database.insert(wd);
      
      Job_Hour__c jh = new Job_Hour__c(Job_Number__c='Job-123456',Overbooked_Hours__c=0.00,Premier_Hours__c=8.00,Workday_Report__c=wd.id,ExternalId__c=extId);
      Database.insert(jh);
   
   }
   static testmethod void testMethod1(){
      Test.setMock(HttpCalloutMock.class, new HttpMockup());
      
      CreateTestData();
      PageReference pageRef = new PageReference('/apex/workdayReport');
      Test.setCurrentPage(pageRef);
      Test.startTest();
      WorkdayReportHelper wrh = new WorkdayReportHelper();
      wrh.populateData();
      wrh.previousWeek();
      wrh.nextWeek();
      Test.stopTest();
   }
   
   static testmethod void testMethod2(){
      Test.setMock(HttpCalloutMock.class, new HttpMockup());
      CreateTestData();
      user usr = TestClassHelper.createUser();
      insert usr;
      e.Salesforce_user__c = usr.id;
      update e;
      Date dt= Date.Today().adddays(7).toStartOfWeek();
      String dt1 = dt.format();
      PageReference pageRef = new PageReference('/apex/workdayReport?w='+dt1);
      Test.setCurrentPage(pageRef);
      
      system.RunAs(usr){
        Test.startTest();
        WorkdayReportHelper wrh = new WorkdayReportHelper();
        Test.stopTest();
      }
   }
   
   static testmethod void testMethod3(){
      Test.setMock(HttpCalloutMock.class, new HttpMockup());
      CreateTestData();
      PageReference pageRef = new PageReference('/apex/workdayReport');
      Test.setCurrentPage(pageRef);
      Test.startTest();
      WorkdayReportHelper wrh = new WorkdayReportHelper();
      wrh.week.Employee__c=e.id;
      wrh.populateData();
      wrh.previousWeek();
      wrh.nextWeek();
      wrh.getcalTotHours();
      Test.stopTest();
   }
}