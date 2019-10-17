@isTest
Private class WeekLockChangeTest{
   static testMethod void WeekLockMethod() {
     Employee__c emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA' ,Resource_Id__c= '123456b');
     insert emp;
     
     Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today().adddays(-2));
     insert week;
      
      PageReference p = Page.WeekLock;
      p.getParameters().put('Id',Week.id);
      p.getParameters().put('Lock','false');
      
      Test.setCurrentPage(p);
      ApexPages.StandardController stdController = new ApexPages.StandardController(week);
      WeekLockChange WLC= new WeekLockChange(stdController);
      
      WLC.lockandUnlock();
      
      PageReference p1 = Page.WeekLock;
      p1.getParameters().put('Id',Week.id);
      p1.getParameters().put('Lock','True');
      
      Test.setCurrentPage(p1);
      ApexPages.StandardController stdController1= new ApexPages.StandardController(week);
      WeekLockChange WLC1= new WeekLockChange(stdController1);
      
      WLC1.lockandUnlock();
      
      
   }

}