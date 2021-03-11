@isTest
public class GetCalendersController_Test{
  static testmethod void testcase1(){
  
  Date workStartTime = Date.Today()-10;
  Date workEndTime = Date.Today();
  
  Test.startTest();
  GetCalendersController getCalenders=new GetCalendersController();
  
  getCalenders.quotaData.Work_Time_Start__c=workStartTime ;
  getCalenders.quotaData.Work_Time_End__c=workEndTime ;
  getCalenders.validateDates();
  
  getCalenders.getShiftPattern();
  
  getCalenders.getbucketClosure();
  Test.stopTest();
  
  }
  static testmethod void testMethod2(){
  
  Date workStartTime = Date.Today()-10;
  Date workEndTime = Date.Today();
  
  Test.startTest();
  GetCalendersController getCalenders=new GetCalendersController();
  getCalenders.quotaData.Work_Time_Start__c=workStartTime ;
  getCalenders.quotaData.Work_Time_End__c=workEndTime ;
  getCalenders.validateDates();
  
  getCalenders.getInternalAct();
  
  getCalenders.quotaData.Work_Time_Start__c=Date.Today()-2 ;
  getCalenders.quotaData.Work_Time_End__c=workEndTime ;
  //Test.setMock(WebServiceMock.class, new toaCapacityMockImpl());
  SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-11-19","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00"}]}', null);
  Test.setMock(HttpCalloutMock.class, fakeResp); 
  getCalenders.getInternalAct();
  Test.stopTest();
  
  }
  static testmethod void testMethod3(){
   Date workStartTime1 = Date.Today();
  Date workEndTime2 = Date.Today()+250;
   Test.startTest();
    GetCalendersController getCalenders=new GetCalendersController();
 
  getCalenders.quotaData.Work_Time_Start__c=workStartTime1 ;
  getCalenders.quotaData.Work_Time_End__c=workEndTime2 ;
  getCalenders.validateDates();
  getCalenders.automateWorkZones();
   Test.stopTest();
  }
  static testmethod void testcase4(){
  OFS_Quota_Data__c newRec = new OFS_Quota_Data__c();
     newRec.Bucket_Name__c='test employee';
     newRec.Employee_s_bucket__c='test emp bucket';
     insert newRec;
  Test.startTest();
  
  SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 '200',
                                               '{"items": [{"name": "xxxx","parentResourceId": "a0Aw000002WDJ4T"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
  GetCalendersController getCalenders=new GetCalendersController();
  //GetCalendersController.BucketWrapResp wrapList=new GetCalendersController.BucketWrapResp(); 
  //GetCalendersController.EmpBucketWrapper wrapList1=new GetCalendersController.EmpBucketWrapper('testemployee','a0Aw000002WDJ4T'); 
  getCalenders.getbucketMapping();
  Test.stopTest();
  
  }
  
  static testmethod void testMethod4(){
      GetCalendersController getCalenders=new GetCalendersController();
      getCalenders.quotaData.Work_Time_Start__c = null;
      getCalenders.quotaData.Work_Time_End__c = null;
      getCalenders.getShiftPattern();
  }
  

}