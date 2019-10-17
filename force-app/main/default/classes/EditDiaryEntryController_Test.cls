/* This is the test class for the page DiaryViewEditPage which shows the different fields to be shown on a diary entry edit page and 

updates the diary entry*/

@isTest (SeeAllData=true)
private class EditDiaryEntryController_Test{
static Employee__c emp;
static Week__c  Week;
static Diary_Entry__c diary;
static Profile Psysadmin;
static User Usysadmin;
static string unAvailRecTypeId;
static DateTime newstart;
static DateTime newend;
static Unavailability__c Unavailable;
static Diary_Entry__c entry;
static String msg;


static  void createTestData(integer i) {

emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '00992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA');
if(i==1)
emp.Employee_Number__c = '00992992';

if(i==2)
emp.Employee_Number__c = '00992993';
          insert emp;
          
Week = new Week__c(Week_Commencing__c = date.today(), Employee__c= emp.Id);
        insert Week;

diary = new Diary_Entry__c (Employee__c=emp.Id,Start__c = System.now() ,End__c = System.now()+2, Sub_Type__c = 'Availability',Week__c = week.Id,
       Hours__c=0.01,Extra_Hours__c=0.00,Overbooked_Hours__c=0.00);
          
        insert diary;  
 
system.assertEquals('Availability', diary.Sub_Type__c); 
Psysadmin = [select id from Profile where name = 'System Administrator'];  
Usysadmin = new User(profileid=Psysadmin.Id,alias = 'stande', email='standarduser_de@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting1', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                                username='standardser_de@testorg.com',Migration_ID__c ='A763BHe324567',IsActive=true); 
system.assertEquals('standardser_de@testorg.com', Usysadmin.username);                                
}


static testmethod void Test_EditDiaryEntryController() 
{    
User user1 = [ select Id from User where Id = :UserInfo.getUserId() ];   
createTestData(0);
// update the diary entry and test the save functionality 
diary.Hours__c=1.00;
diary.Sub_Type__c='Ecogen Mechanical';
diary.Extra_Hours__c=2.00;


ApexPages.standardController controller_1 = new ApexPages.standardController(diary);
EditDiaryEntryController controller1 = new EditDiaryEntryController(controller_1);
PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id);
Test.setCurrentPage(pageRef);
controller1.Save();
 
// update the diary entry and test cancel functionality 
System.RunAs(User1)
{  
Test.StartTest();   
canceldiary();
Test.StopTest();    
}
// update the diary entry and test Save & New  functionality 
System.RunAs(Usysadmin)
{  
diary.Hours__c=3.00;
Save_New();
}
}

private static testmethod void canceldiary()
{
createTestData(1);
PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id);
Test.setCurrentPage(pageRef);
ApexPages.standardController controller_cancel = new ApexPages.standardController(diary);
EditDiaryEntryController controller_cancel1 = new EditDiaryEntryController(controller_cancel);
controller_cancel1.Cancel(); 
} 

private static testmethod void Save_New()  
{
createTestData(2);
PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id);
Test.setCurrentPage(pageRef);
ApexPages.standardController controller_savenew = new ApexPages.standardController(diary);
EditDiaryEntryController controller1_savenew = new EditDiaryEntryController(controller_savenew);
controller1_savenew.Save_New();
}

private static testmethod void Save_New1() 

{
    
    createTestData(0);
    unAvailRecTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Unavailability');
    diary.RecordTypeId = unAvailRecTypeId;
    diary.Type__c = 'Unavailability';
    diary.Sub_Type__c = 'Contingency';
    update diary;
    system.debug('********After Insert****'+diary);
    ApexPages.standardController controller_1 = new ApexPages.standardController(diary);
    PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id);
    Test.setCurrentPage(pageRef);
    EditDiaryEntryController controller1 = new EditDiaryEntryController(controller_1);
    
    controller1.Unavailable.Start_Date_Time__c = System.now() +1;
    controller1.Save();
    controller1.Unavailable.Type__c = 'Contingency';
    Controller1.Unavailable.Unavailability_Reason__c = 'Contingency';
    controller1.Save();   
     
    
    Controller1.Unavailable.Amendment_Reason__c = 'Contingency';
    controller1.Save();    
    

}
private static testmethod void TestRemoval() 

{
    createTestData(0);
    unAvailRecTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Unavailability');
    diary.RecordTypeId = unAvailRecTypeId;
    diary.Type__c = 'Unavailability';
    
    update diary;
    system.debug('********After Insert****'+diary);
    ApexPages.standardController controller_1 = new ApexPages.standardController(diary);
    PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id+'&r=r');
    Test.setCurrentPage(pageRef);
    EditDiaryEntryController controller1 = new EditDiaryEntryController(controller_1);
        controller1.entry.sub_type__c = 'Contingency';
        
        controller1.Unavailable.Start_Date_Time__c = System.now() +1;
        Controller1.Unavailable.Amendment_Reason__c = NULL;
        controller1.save();
        
        controller1.Unavailable.Labour_Type__c = 'Own Labour';
        controller1.Unavailable.Amendment_Reason__c = 'AMH';
        controller1.save();
        
        controller1.removeMode = false;
        controller1.save();
        
        controller1.Unavailable.Start_Date_Time__c = System.now().adddays(1) +1;
        controller1.Unavailable.End_Date_Time__c = System.now().adddays(2) +1;
        controller1.Unavailable.Type__c = 'Contingency';
        controller1.Unavailable.Unavailability_Reason__c = 'Contingency';
        controller1.removeMode = true;
        controller1.entry.Authoriser__c = 'AHM';
        controller1.Save();
    
    controller1.entry = null;
    controller1.Save_New();
} 

private static testmethod void TestRemoval1() 

{
    createTestData(0);
    unAvailRecTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c' , 'Unavailability');
    diary.RecordTypeId = unAvailRecTypeId;
    diary.Type__c = 'Unavailability';
    
    update diary;
    system.debug('********After Insert****'+diary);
    ApexPages.standardController controller_1 = new ApexPages.standardController(diary);
    PageReference pageRef = new PageReference('apex/DiaryEntryEditPage?id=' + diary.id + '&retURL=' + week.id+'&r=r');
    Test.setCurrentPage(pageRef);
    EditDiaryEntryController controller1 = new EditDiaryEntryController(controller_1);
     controller1.entry.sub_type__c = 'Training - Laptop/System';
     controller1.Unavailable.Start_Date_Time__c = System.now().adddays(1) +1;
     controller1.Unavailable.End_Date_Time__c = System.now().adddays(2) +1;
     controller1.Unavailable.Type__c = 'Non Working Day';
     controller1.Unavailable.Unavailability_Reason__c = 'NWD - Non Working';
     controller1.removeMode = true;
     controller1.Save();
    
} 

}