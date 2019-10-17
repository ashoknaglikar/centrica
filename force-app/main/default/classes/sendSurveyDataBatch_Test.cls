@isTest
public class sendSurveyDataBatch_Test {
  static Account acc;
  static contact con;
  static opportunity opp;
  static BigMachines_Quote__c quote;
  static District__c district;
  static job__c job;
  static Appointment__c appointment;
  static Employee__c emp;
  static List<NPS__c> npsList = new List<NPS__C>();
  static Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;  
    
    static void createTestData()
    {
        acc = TestclassHelper.createAccout();
        insert acc;
        
        con = TestclassHelper.createContact(acc);
        insert con;
        
        opp = TestclassHelper.createCHILead(acc);
        opp.Product_Interest__c='Central Heating Boiler';
        insert opp;
        
        quote = TestClassHelper.createBMQuote(opp);
        insert quote;
        
        district =TestClassHelper.createDistrict();
        insert district;
        
        job = TestClassHelper.createJob('Planned','Planned',opp.id,district.id);
        insert job;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        
        appointment = new Appointment__c(Type__c='Sales', Start__c =system.now(), Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=system.now().addhours(2), Assigned_To__c=emp.Id);
        insert appointment;
        
        
        NPS__c nps1 = new NPS__c(opportunity__c= opp.id,source__c= 'Sales Appointment', appointment__c=appointment.id,integration_Status__c='Ready to be Sent',Step1_Score_Dup__c=9,Step2_Score__c=8,Step1_Comments__c='test');
        NPS__c nps2 = new NPS__c(opportunity__c= opp.id,source__c= 'Job Installation', job__c=job.id,integration_Status__c='Ready to be Sent',Step1_Score_Dup__c=9,Step2_Score__c=8,Step1_Comments__c='test');
        npsList.add(nps1);
        npsList.add(nps2);
        insert npsList;
    }
    
    private static testMethod void method1() {
        createTestData();
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMockup());
        /*SendSurveyDataBatch newObj = new SendSurveyDataBatch();
        Database.executeBatch(newObj);*/
        System.schedule('ScheduleApexClassTest',  CRON_EXP, new sendSurveyDataSchedular());
        Test.stopTest();
    }
    
    private static testMethod void method2() {
        createTestData();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMockup());
        PageReference pageRef = Page.sendNPSDataPage;
        pageRef.getParameters().put('id', String.valueOf(npsList[0].Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(npsList[0]);
        sendNPSDataController controller1 = new sendNPSDataController(sc);
        controller1.sendNPSData();
        controller1.back();
        Test.stopTest();
    }
}