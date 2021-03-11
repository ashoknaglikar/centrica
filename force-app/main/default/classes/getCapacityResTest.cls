@isTest
private class getCapacityResTest{
    /*
    static Account account;
    static Contact contact;
    static Opportunity opp;
    */
    static Supplier__c supplier;
    static Employee__c emp;
    static Employee_Sales_Skill__c skill;
   
    @testSetup
    static void createData()
    {
        /*
        
        //Prepare account data
        date pageDate = date.today().addYears(100);
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='XXX XXX',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='XXX XXX',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        */
        
        //prepare supplier data
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='HSA',Primary_Role__c='HSA');
        insert emp;
        
        Employee__c emp2 = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991e',Resource_Id__c='7fejs2e',Resource_Type__c='HSA',Primary_Role__c='OFS Bucket',Inactive__c=False);
        insert emp2;
        
        /*
        //Prepare opportunity data
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                LeadSource='Engineer', Referral_Employee__c =emp.id,
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId());
        
        insert opp;
        
        Skill = new Employee_Sales_Skill__c(Employee__c = emp.Id, Sales_Skill_Name__c = 'Central Heating Boiler', Start_Date__c = system.today(), End_Date__c = pageDate, Sales_Efficiency__c = 1);
        insert skill;
        
         
       
        Role__c TestRole1 = new Role__c(Type__c='HSA', Start_Date__c=date.today(), End_Date__c=pageDate.addYears(1), Employee__c=emp.Id);
        insert TestRole1;
        
        District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
        insert TestSalesDistrict;
        
        Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx');
        insert TestsalesSubPatch;      
        
        Postcode_Sector__c TestSalesSector = new Postcode_Sector__c(Type__c='Sales',Name='XXX X', Sub_Patch__c=TestSalesSubPatch.Id);
        insert TestsalesSector;
        */
       
    }
 
 static testmethod void InvokeCapacityandQuotaData(){
   //CreateData();
   emp = [select id from Employee__c][0];
   string[] loc = new string[]{emp.id};
   Date x = Date.today();
   Date y = Date.today().adddays(1);
   Date[] date_x = new date[]{x,y};
   List<Id> empIdList=new list<Id>{emp.id};
   Test.startTest();
   
   getCapacityRes.getCapacity(loc,date_x,'XXX XXX','XXX X',null);
   getCapacityRes.getQuotaData(date_x,loc);
  
   Test.stopTest();
 
 }
 
  static testmethod void InvokeWebServices(){
   //CreateData();
   emp = [select id from Employee__c][0];
   string[] loc = new string[]{emp.id};
   Date x = Date.today()-100;
   Date y = Date.today().adddays(1);
   
   List<Id> empIdList=new list<Id>{emp.id};
   Test.startTest();
   //Test.setMock(WebServiceMock.class, new getCapacityRes());
    getCapacityRes.getBuckClosure(empIdList,x,y);
    //getCapacityRes.getInternalActivity(x,y);
    Test.setMock(WebServiceMock.class, new toaCapacityMockImpl());
    
    //getCapacityRes.getCalendersResp(empIdList,x,y);
    
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"totalResults":326,"limit":100,"offset":300,"items":[{"date":"2020-07-22","activityType":"Training","status":"cancelled","activityId":2077593,"timeZone":"Western Europe","timeOfBooking":"2020-06-19 08:09:37","timeOfAssignment":"2020-06-19 08:09:37","XA_duration":"600","resourceId":"a0A2X00002qwW7JUAU"},{"date":"2020-07-22","activityType":"NFT Down Time","status":"pending","startTime":"2020-07-22 09:00:00","endTime":"2020-07-22 19:00:00","activityId":2097439,"duration":600,"timeZone":"Western Europe","timeOfBooking":"2020-07-07 16:56:59","timeOfAssignment":"2020-07-07 16:56:59","XA_duration":"600","resourceId":"a0A20000002RwMEEA0"}],"links":[{"rel":"canonical","href":"https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=XA_internal&searchForValue=Internal&dateFrom=2020-07-22&dateTo=2020-07-22&fields=activityId%2CresourceId%2CactivityType%2Cstatus%2CstartTime%2CendTime%2Cduration%2CXA_duration%2CtimeZone%2CtimeOfAssignment%2CtimeOfBooking%2Cworktype%2Cdate&limit=100&offset=300"},{"rel":"prev","href":"https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=XA_internal&searchForValue=Internal&dateFrom=2020-07-22&dateTo=2020-07-22&fields=activityId%2CresourceId%2CactivityType%2Cstatus%2CstartTime%2CendTime%2Cduration%2CXA_duration%2CtimeZone%2CtimeOfAssignment%2CtimeOfBooking%2Cworktype%2Cdate&limit=100&offset=200"},{"rel":"describedby","href":"https://api.etadirect.com/rest/ofscCore/v1/metadata-catalog/activities"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
    getCapacityRes.getInternalActivity(x,y);
   //toatechResourcemanagement10.GetResourcesCalendarsResponseElement calElement=getCapacityRes.getCalendersResp(empIdList,x,y);
   Test.stopTest();
 
 }
  static testmethod void InvokeCalWebServices(){
   //CreateData();
   emp = [select id from Employee__c][0];
   string[] loc = new string[]{emp.id};
   Date x = Date.today()-100;
   Date y = Date.today().adddays(1);
   
   List<Id> empIdList=new list<Id>{emp.id};
   Test.startTest();
    Test.setMock(WebServiceMock.class, new toatechResMMockImpl());
    //getCapacityRes.getCalendersResp(empIdList,x,y);
   Test.stopTest();
 
 }
 static testmethod void InvokeActWebServices(){
   //CreateData();
   emp = [select id from Employee__c][0];
   string[] loc = new string[]{emp.id};
   Date x = Date.today()-100;
   Date y = Date.today().adddays(1);
   
   List<Id> empIdList=new list<Id>{emp.id};
   Test.startTest();
   //getCapacityRes.getCalendersResp(empIdList,x,y);
    
   SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"totalResults":326,"limit":100,"offset":300,"items":[{"date":"2020-07-22","activityType":"Training","status":"cancelled","activityId":2077593,"timeZone":"Western Europe","timeOfBooking":"2020-06-19 08:09:37","timeOfAssignment":"2020-06-19 08:09:37","XA_duration":"600","resourceId":"a0A2X00002qwW7JUAU"},{"date":"2020-07-22","activityType":"NFT Down Time","status":"pending","startTime":"2020-07-22 09:00:00","endTime":"2020-07-22 19:00:00","activityId":2097439,"duration":600,"timeZone":"Western Europe","timeOfBooking":"2020-07-07 16:56:59","timeOfAssignment":"2020-07-07 16:56:59","XA_duration":"600","resourceId":"a0A20000002RwMEEA0"}],"links":[{"rel":"canonical","href":"https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=XA_internal&searchForValue=Internal&dateFrom=2020-07-22&dateTo=2020-07-22&fields=activityId%2CresourceId%2CactivityType%2Cstatus%2CstartTime%2CendTime%2Cduration%2CXA_duration%2CtimeZone%2CtimeOfAssignment%2CtimeOfBooking%2Cworktype%2Cdate&limit=100&offset=300"},{"rel":"prev","href":"https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=XA_internal&searchForValue=Internal&dateFrom=2020-07-22&dateTo=2020-07-22&fields=activityId%2CresourceId%2CactivityType%2Cstatus%2CstartTime%2CendTime%2Cduration%2CXA_duration%2CtimeZone%2CtimeOfAssignment%2CtimeOfBooking%2Cworktype%2Cdate&limit=100&offset=200"},{"rel":"describedby","href":"https://api.etadirect.com/rest/ofscCore/v1/metadata-catalog/activities"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    getCapacityRes.getInternalActivity(x,y);
   Test.stopTest();
 
 }
     static testmethod void getEmployeeIDandNameMapTest (){
        
        
        
        test.startTest();
        getCapacityRes.getEmployeeIDandNameMap();   
        Test.stopTest();
        
    }
 

}