@isTest
private class TestAppointmentHistoryCreator {
    static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static date todayDate;
    static Appointment__c TestAppointment1;
  static void createData()
    {
        todayDate = date.today();
        //Prepare account data
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='XXX XXX',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='XXX XXX',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        
        //prepare supplier data
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        insert emp;
        
        //Prepare opportunity data
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                LeadSource='Engineer', Referral_Employee__c =emp.id,
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId());
        
        insert opp;
        
        date pageDate = date.today().addYears(100);
        datetime AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);     
        datetime AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
        
        Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        

        TestAppointment1 = new Appointment__c(Type__c='Sales', Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime0900am, Assigned_To__c=emp.Id , Status__c = 'Appointed', Create_History__c = true,Opportunity__c=opp.id,who__c=contact.id);
        insert TestAppointment1;
        
        
    }
 static testmethod void InvokeBatchMethod(){
   
  test.startTest(); 
  CreateData(); 
  appointmentHistoryCreator.invokeBatch();
  Test.stopTest();
 
 }
 
 

}