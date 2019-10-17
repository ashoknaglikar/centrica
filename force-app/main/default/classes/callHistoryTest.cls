@isTest
private class callHistoryTest {

   private static testMethod void testRestAPI() {
        
        //
        createCallHistoryRESTAPI.post(null , null, 'call Type', '90', 'nagaleea', '23/11/2015 15:27', '23/11/2015 15:33', '568552', 'consultMade' , 'consult Recieved');
        
        
        createCallHistoryRESTAPI.post(null , 'Incoming', 'call Type', '90', 'nagaleea', '23/11/2015t15:27', '23/11/2015 15:33', '568552', 'consultMade' , 'consult Recieved');
        
        
        createCallHistoryRESTAPI.post(null , 'Incoming', 'call Type', '90', 'nagaleea', '23/11/2015 15:27', '23/11/2015 15:33', '568552', 'consultMade' , 'consult Recieved');

    }
    
     static testMethod void testEmployeeUpdateScenario() {
        
        List<Employee__c> empList = [select id,name,Lan_Id__c,Phone_No__c from Employee__c];
        Lock.clearAll();
        Id [] fixedSearchResults = new Id[]{empList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        Call_History__c newCH1 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Emp_LAN_Id__c = 'Tagaleea', Phone_Num__c = '00000000002',Call_Direction__c = 'incoming');
        Call_History__c newCH2 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Emp_LAN_Id__c = 'Tagaleea', Phone_Num__c = '00000000001',Call_Direction__c = 'incoming');
        Call_History__c newCH3 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Emp_LAN_Id__c = 'Tagaleea', Phone_Num__c = '00000000003',Call_Direction__c = 'incoming');
        Call_History__c newCH4 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Call_Direction__c = 'incoming');

        insert new list<Call_History__c>{newCH1, newCH2, newCH3, newCH4};
        
        
    }
    
    static testMethod void testContactUpdateScenario() {
        
        List<Contact> conList = [select id,name,HomePhone,MobilePhone,OtherPhone from Contact];
        
        Lock.clearAll();
        Id [] fixedSearchResults = new Id[]{};
        for(contact c: conList){
         fixedSearchResults.add(c.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        
        Call_History__c newCH1 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Phone_Num__c = '00000000000',Call_Direction__c = 'incoming');
        Call_History__c newCH2 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Phone_Num__c = '00000000001',Call_Direction__c = 'incoming');
        Call_History__c newCH3 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Phone_Num__c = '00000000003',Call_Direction__c = 'incoming');
        Call_History__c newCH4 = new Call_History__c(Start__c = system.now(), End__c = System.now(), Duration__c = 200.60, Phone_Num__c = '00000000002',Call_Direction__c = 'incoming');
        insert new list<Call_History__c>{newCH1, newCH2, newCH3, newCH4};
        
        
    }
    
          
    //testing data setup for all methods in this class
    @testSetup
    static void allTheDataForThisTestClass() {
        Test.startTest();
        //Create an Account
        List<Account> accList = new list<Account>();
        Account acc = TestclassHelper.createAccout();
        acc.name='Test1';
        accList.add(acc);
        Account acc1 = TestclassHelper.createAccout();
        acc1.name='Test2';
        accList.add(acc1);
        Account acc2 = TestclassHelper.createAccout();
        acc2.name='Test3';
        accList.add(acc2);
        Database.Insert(accList,false);
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        Contact c = TestClassHelper.createContact(acc);
        c.HomePhone = '00000000000';
        c.MobilePhone = '00000000000';
        c.OtherPhone = '00000000000';
        contacts.add(c);
        Contact c1 = TestClassHelper.createContact(acc1);
        c1.HomePhone = '00000000001';
        contacts.add(c1);
        Contact c2 = TestClassHelper.createContact(acc2);
        c2.OtherPhone = '00000000002';
        contacts.add(c2);
        insert contacts;
        //create some Employees
        List<Employee__c> employees = new List<Employee__c>();
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Phone_No__c = '00000000001';
        emp.Lan_Id__c = 'Tagaleea';
        employees.add(emp);
        insert employees;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opp = testClassHelper.createCHILead(acc);
        opportunities.add(opp);
        Opportunity opp1 = testClassHelper.createCHILead(acc1);
        opportunities.add(opp1);
        Opportunity opp2 = testClassHelper.createCHILead(acc2);
        opportunities.add(opp2);
        insert opportunities;
        BigMachines_Quote__c  quote = TestclassHelper.createBMQuote(opp);
        insert quote;
        
        Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;    
       // Appointment__c App = TestClassHelper.createAppointment(opp2,emp.id,userInfo.getUserId(),availableRecordTypeId,c.id);
        //insert App;
         date pageDate = date.today().addYears(100);
         datetime AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);    
         datetime AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
         Lock.Lock = True;
         Appointment__c TestAppointment1 = new Appointment__c(Type__c='Sales', Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime0900am, Assigned_To__c=emp.Id,Opportunity__c =opp2.id,who__c=c2.id);
        insert TestAppointment1;
        District__c d = TestclassHelper.createDistrict();
        insert d;
        
        Job__c j = TestClassHelper.createJob('Pending','Pending',opp2.Id,d.id);
        j.Customer_manager_email_address__c  = 'Test@Test.com';
        insert j;
        Test.stopTest();
    }

    

}