@isTest 

private class EmployeeUnavailable_Test {

static Employee__c emp;
static String endTime;
static Datetime weekStart;
static Account account;
static Contact contact;
static Week__c week;
static Diary_Entry__c DEntry;
static String URL;
static DateTime startDate;
static DateTime endDate;
static string unAvailRecTypeId;


static Testmethod void Employeeunavailability()

 {
     
      emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
          insert emp;
                               
                              
      Week = new Week__c(Week_Commencing__c = date.today(), Employee__c = emp.Id);
        insert Week;
        
        
        DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id , Start__c = system.now() , End__c = system.now().adddays(7) , Type__c = 'Job Booking');
        insert DEntry;
        
        weekStart = system.now();
        URL = 'www.google.com';
        startDate = system.now();
        endDate = system.now().adddays(5);
        
        unAvailRecTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Unavailability');
        
        
        
        PageReference pageRef = new PageReference('/apex/Employee_Unavailable?Id='+ DEntry.Id);
        Test.setCurrentPage(pageRef);
        
        EmployeeUnavailable eu = new EmployeeUnavailable();
        
        eu.mappingunavailable();
        eu.generateUnavail();
       eu.goBack();
      eu.cancel();
      
        
        }
      }