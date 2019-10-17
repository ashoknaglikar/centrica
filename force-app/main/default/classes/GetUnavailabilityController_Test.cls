//This is test class for GetUnavailabilityController apex class
@isTest
public class GetUnavailabilityController_Test{

static HSA_Unavailability__c hsaUnavailRecord;
static Groups__c grp;
static Employee__c emp;
static supplier__c supplier;

 static void createData()
    {
    
    
    grp=new Groups__c(name='testGroup');
    insert grp;
    
    hsaUnavailRecord=new HSA_Unavailability__c( Employee_Group__c=grp.id, Work_Time_Start__c=system.today(),Work_Time_End__c=system.today()+1,Activity_Type__c='AM');  
    insert  hsaUnavailRecord;
    
    }
    
   static void createDataOne()  
    {
    supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
    emp = new Employee__c(Name = 'test Unavail', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'Test', Last_Name__c = 'UnavailOne',Supplier__c=supplier.Id,Employee_Number__c = '0004444',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
    insert emp;
    grp=new Groups__c(name='testGroup');
    insert grp;
    Employee_Group__c tempEmp = new Employee_Group__c(Group__c = grp.Id, Employee__c = emp.Id);
    
    insert tempEmp;
    
     hsaUnavailRecord=new HSA_Unavailability__c(Employee__c=emp.id, Work_Time_Start__c=system.today(),Work_Time_End__c=system.today()+1,Activity_Type__c='AM');  
    insert  hsaUnavailRecord;
    
    }
 static testmethod void InvokeEmpSearch()
 {
    
    Test.startTest();
    createData();
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
  
    getUnavail.buildEmpoloyeeGroupsForSearch('search');
    getUnavail.buildEmpoloyeeGroupsForSearch('remove');
    
    GetUnavailabilityController.UnavailWrapper  unavailWrap=new GetUnavailabilityController.UnavailWrapper(true,'AM',system.today(),system.today()+5,1234,'In Progress','a0A20000007ZZZjEAO');
    Integer intComp=unavailWrap.compareTo(unavailWrap);
    GetUnavailabilityController.UnavailWrap unWrap=new  GetUnavailabilityController.UnavailWrap('Aooo96r7gfg','01-01-2017','01-02-2017',48,'12:23:40','14:23:40','01-01-2017','AM','123356fjbo','notes', 'front');
    GetUnavailabilityController.UnavailWrapResp unAvailResp=new GetUnavailabilityController.UnavailWrapResp();
    unAvailResp.totalResults=2;
    unAvailResp.offset=1;
    getUnavail.extractUnavailabilities();
    GetUnavailabilityController.unavailRestresponseObj respObj=new GetUnavailabilityController.unavailRestresponseObj();
    respObj.type='testType';
    respObj.status='In Progress';
    respObj.title='title';
    respObj.detail='test detail';
    getUnavail.empList=new list<Employee__c>();
    getUnavail.unavailOFSList=new List<HSA_Unavailability__c>();
    Test.stopTest();
 }
 static testmethod void InvokeEmpSearchOne()
 {
    createDataOne();
    hsaUnavailRecord.Work_Time_Start__c=datetime.newInstance(2017,11,19,1,0,0);
     hsaUnavailRecord.Work_Time_End__c=datetime.newInstance(2017,11,20,1,0,0);
    update hsaUnavailRecord;
    Test.startTest();
   
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
    string empId=string.valueOf(emp.id);
    getUnavail.empIdList=new List<string>{empId};
    getUnavail.hsaUnavailRecord =hsaUnavailRecord;
     GetUnavailabilityController.UnavailWrapper  unavailWrap=new GetUnavailabilityController.UnavailWrapper(true,'AM',system.today(),system.today()+5,1234,'In Progress','a0A20000007ZZZjEAO');
   
    getUnavail.unavailWrapList=new list<GetUnavailabilityController.UnavailWrapper>();
    getUnavail.unavailWrapList.add(unavailWrap);
    
    
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"2017-11-19": {"regular": {"recordType": "working","workTimeStart": "09:00","workTimeEnd": "19:00"}}}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    getUnavail.dateStrings.add('2017-11-19');
    getUnavail.calanderMap = getUnavail.createCalanderMap('{"2017-11-19": {"regular": {"recordType": "working","workTimeStart": "09:00","workTimeEnd": "19:00"}}}');
    getUnavail.createUnavailability();
  
    Test.stopTest();
 }
 static testmethod void InvokeRemoveUnavail()
 {
    createDataOne();
    Test.startTest();
   
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
    string empId=string.valueOf(emp.id);
    getUnavail.empIdList=new List<string>{empId};
    getUnavail.hsaUnavailRecord =hsaUnavailRecord;
     GetUnavailabilityController.UnavailWrapper  unavailWrap=new GetUnavailabilityController.UnavailWrapper(true,'AM',system.today(),system.today()+5,1234,'In Progress','a0A20000007ZZZjEAO');
   
    getUnavail.unavailWrapList=new list<GetUnavailabilityController.UnavailWrapper>();
    getUnavail.unavailWrapList.add(unavailWrap);
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-11-19","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
    getUnavail.RemoveUnavail();
    Test.stopTest();
 }
 static testmethod void InvokeBuildEmpSearch()
 {
    createDataOne();
    Test.startTest();
   
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
    string empId=string.valueOf(emp.id);
    getUnavail.empIdList=new List<string>{empId};
    getUnavail.hsaUnavailRecord =hsaUnavailRecord;
     GetUnavailabilityController.UnavailWrapper  unavailWrap=new GetUnavailabilityController.UnavailWrapper(true,'AM',system.today(),system.today()+5,1234,'In Progress','a0A20000007ZZZjEAO');
   
    getUnavail.unavailWrapList=new list<GetUnavailabilityController.UnavailWrapper>();
    getUnavail.unavailWrapList.add(unavailWrap);
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-11-19","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
   
    getUnavail.buildEmpoloyeeGroupsForSearch('search');
  
    Test.stopTest();
 }
 static testmethod void InvokeSearchUnavail()
 {
    createDataOne();
    Test.startTest();
   
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
    string empId=string.valueOf(emp.id);
    getUnavail.empIdList=new List<string>{empId};
    getUnavail.hsaUnavailRecord =hsaUnavailRecord;
    GetUnavailabilityController.UnavailWrapper  unavailWrap=new GetUnavailabilityController.UnavailWrapper(true,'AM',system.today(),system.today()+5,1234,'In Progress','a0A20000007ZZZjEAO');
   
    getUnavail.unavailWrapList=new list<GetUnavailabilityController.UnavailWrapper>();
    getUnavail.unavailWrapList.add(unavailWrap);
    
    
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-01-01","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00","status":"pending","startTime":"01-01-2017 11:0:0:0","endTime":"01-02-2017 11:0:0:0"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
   
    getUnavail.searchUnavailability('a0A20000007ZZZjEAO',hsaUnavailRecord,'');
    getUnavail.dateStrings.add('2017-10-03');
    getUnavail.createCalanderMap('{"2017-10-03": {"regular": {"recordType": "working","workTimeStart": "09:00","workTimeEnd": "19:00"}}}');
    
    Test.stopTest();
 }
 
 
 static testmethod void InvokeRemoveMods()
 {
    createDataOne();
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/GetUnavailability?mode=remove&id='+hsaUnavailRecord.Id);
		
	Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-01-01","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00","status":"pending","startTime":"01-01-2017 11:0:0:0","endTime":"01-02-2017 11:0:0:0"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
   
    
 }
 
  static testmethod void InvokeRecurringMore()
 {
    createDataOne();
    
    hsaUnavailRecord.Type__c= 'Recurring';
    hsaUnavailRecord.Day__c = 'Mon';
    hsaUnavailRecord.Weeks_Between_Occurences__c = 1;
    update hsaUnavailRecord;
    
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/GetUnavailability?mode=remove&id='+hsaUnavailRecord.Id);
    		
	Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(hsaUnavailRecord);
    
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-01-01","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00","status":"pending","startTime":"01-01-2017 11:0:0:0","endTime":"01-02-2017 11:0:0:0"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    
    GetUnavailabilityController getUnavail = new GetUnavailabilityController(sc);
   
    
 }
 
}