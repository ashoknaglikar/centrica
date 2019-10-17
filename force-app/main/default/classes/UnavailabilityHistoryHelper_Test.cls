@isTest

private class UnavailabilityHistoryHelper_Test {
    
    
    static Employee__c emp;
    static Diary_Entry__c DEntry;
    static string unAvailRecTypeId;
    static Datetime weekStart;
    static DateTime startDate;
    static DateTime endDate;
    //static List<Diary_Entry__c> de_list;
    static Week__c week;
    static Unavailability_History_Tracker__c histrytracker;
    
    static void createData()
    
     {
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBI', Last_Name__c = 'PROD1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
        insert emp;
        
        week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        
        histrytracker = new Unavailability_History_Tracker__c (Employee__c=emp.Id,Start__c = system.now(),End__c = system.now().adddays(7),Unavailability_Notes__c = 'Test Notes1',Removal_Reason__c='DHM',
                             Amendment_Reason__c='ASP – Positive',Hours__c=3);
                             
                             insert histrytracker ;
        
        DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id,Start__c = system.now(),End__c = system.now().adddays(7));
        insert DEntry;
        
       Unavailability__c un = new Unavailability__c(Start_Date_Time__c = DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(8,0,0,0)),
                                                     End_Date_Time__c = DateTime.newInstance(Date.Today().toStartOfWeek(),Time.newInstance(9,0,0,0)),
                                                     Unavailability_Reason__c = 'Deputising for DHM',
                                                     Unavailability_Notes__c = 'Test Notes');
        Database.insert(un);
        
     
     }
     
  static Testmethod void Createhistoryrecords()

    {
      createData();
      UnavailabilityHistoryHelper ut = new UnavailabilityHistoryHelper();
      DEntry.Create_History__c= true;
      List<Diary_Entry__c> de_list = new List<Diary_Entry__c>();
      de_list.add(DEntry);
      ut.Createhistoryrecords(de_list);
       
       
  }
  
   static Testmethod void Createhistorychildrecords()
  
  {
      createData();
      UnavailabilityHistoryHelper ut = new UnavailabilityHistoryHelper();
     
      List<Diary_Entry__c> de_list = new List<Diary_Entry__c>();
      de_list.add(DEntry);
      
      list<Unavailability_History_Tracker__c> htlist;//= ut.Createhistoryrecords(de_list);
     
     // List<Unavailability_History_Tracker__c> historyRecord = [select id from Unavailability_History_Tracker__c where Diary_Entry__c =: DEntry.id].Id;
     
      List<Unavailability_History_Tracker__c> UnHistory = [Select id from Unavailability_History_Tracker__c where Diary_Entry__c = :DEntry.Id limit 1];
      //histrytracker.add(UnHistory);
       UnHistory.add(histrytracker);
      
      
      //ut.Createhistorychildrecords(de_list, htlist[0].id);
      ut.Createhistorychildrecords(de_list, UnHistory[0].id);
      
 }
 
    
}