@isTest

private class Weeklock_Trigger_Test {
  
   static Employee__c emp;
 
   static Employee_Week_Lock__c EmployeeweekLock; 
    static Employee_Week_Lock__c EmployeeweekLock2;
   static Week_Lock__c WeekLock;

  static void createData()

  {

Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'lock', email='Weeklock@testorg.com',
emailencodingkey='UTF-8', lastname='week', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='Weeklockr@testorg.com');

    //prepare employee data
    emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
    insert emp;
    

 WeekLock = new Week_Lock__c(End_Date__c=Date.today()+5 ,Locking_User__c = user.id ,Start_Date__c=Date.today()-10);
       insert WeekLock;

      EmployeeweekLock = new Employee_Week_Lock__c (Employee__c = emp.Id ,Week_Lock__c = WeekLock.id );
        Insert EmployeeweekLock;
     
      EmployeeweekLock2 = new Employee_Week_Lock__c ();
       try{
        Insert EmployeeweekLock2;
        }
        catch(exception e){
        } 
        
  }

static testMethod void checkforEmployee() {
        createData();


}
}