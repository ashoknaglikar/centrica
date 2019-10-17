@isTest

private class WeekLockWebService_Test {

  
    static Week__c week;
    static Week_Lock__c WeekLock;
    static Employee_Week_Lock__c EmployeeweekLock; 
    static Groups__c grp;
  

    
   
    
      static testMethod void WeekLockWebServiceTestMethod(){
      
      
      Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'lock', email='LockUser@testorg.com',
emailencodingkey='UTF-8', lastname='locking', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='lockuser@testorg.com');

insert User;
      Employee__c emp = Phase3TestHelper.createEmployee();
      week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5,Locking_User__c = user.id);
        
        insert week;
        
         WeekLock = new Week_Lock__c(End_Date__c=Date.today()+5 ,Locking_User__c = user.id ,Start_Date__c=Date.today()-10);
       insert WeekLock;
      
grp = new Groups__c(name= 'test2');
insert grp;

       EmployeeweekLock = new Employee_Week_Lock__c (Employee__c = emp.Id ,Week_Lock__c = WeekLock.id,group__c = grp.id );
        Insert EmployeeweekLock;
        
       WeekLockWebService wb = new WeekLockWebService();
       WeekLockWebService.WeekLock(WeekLock.id);
       
   
       
        
        }
        
        static testMethod void WeekunLockWebServiceTestMethod(){
        
        Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'unlock', email='UnLockuser@testorg.com',
emailencodingkey='UTF-8', lastname='Unlocking', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='Unlockuser@testorg.com');

insert User;

Employee__c emp = Phase3TestHelper.createEmployee();
      week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        
        insert week;
        
        WeekLock = new Week_Lock__c(End_Date__c=Date.today()+5 ,Locking_User__c = user.id ,Start_Date__c=Date.today()-10);
       insert WeekLock;
grp = new Groups__c(name= 'test2');
insert grp;

       EmployeeweekLock = new Employee_Week_Lock__c (Employee__c = emp.Id ,Week_Lock__c = WeekLock.id , group__c = grp.id );
        Insert EmployeeweekLock;
        
        WeekLockWebService wb = new WeekLockWebService();
       WeekLockWebService.WeekunLock(WeekLock.id);
       
    }
    
    
    
    static testMethod void EmployeeWeekunLockWebServiceTestMethod(){
    
            Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'Wekunlk', email='WeekunLockuser@testorg.com',
emailencodingkey='UTF-8', lastname='Weekunlock', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='WeekunLockuser@testorg.com');

insert User;
 Employee__c emp = Phase3TestHelper.createEmployee();
    
    week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        
        insert week;
    
   
    
    WeekLock = new Week_Lock__c(End_Date__c=Date.today()+5 ,Locking_User__c = user.id ,Start_Date__c=Date.today()-10);
       insert WeekLock;
      
grp = new Groups__c(name= 'test2');
insert grp;  
    EmployeeweekLock = new Employee_Week_Lock__c (Employee__c = emp.Id ,Week_Lock__c = WeekLock.id , group__c = grp.id);
        Insert EmployeeweekLock;
        
    WeekLockWebService wb = new WeekLockWebService();
   WeekLockWebService.EmployeeWeekunLock(EmployeeWeekLock.id);
    }
   

   static testMethod void WeekLockWebServiceTestMethod1(){
      
      
      Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'lock12', email='LockUser12@testorg.com',
emailencodingkey='UTF-8', lastname='locking12', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='lockuser12@testorg.com');

insert User;
      Employee__c emp = Phase3TestHelper.createEmployee();
      week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today(),Locking_User__c = user.id);
        
        insert week;
        
         WeekLock = new Week_Lock__c(End_Date__c=Date.today()+5 ,Locking_User__c = user.id ,Start_Date__c=Date.today()-10);
       insert WeekLock;
      
grp = new Groups__c(name= 'test2');
insert grp;

       EmployeeweekLock = new Employee_Week_Lock__c (Employee__c = emp.Id ,Week_Lock__c = WeekLock.id );
        Insert EmployeeweekLock;
        
       WeekLockWebService wb = new WeekLockWebService();
       WeekLockWebService.WeekLock(WeekLock.id);
       
   
       
        
        }

   }