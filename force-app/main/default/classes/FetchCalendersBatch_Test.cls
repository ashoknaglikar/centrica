@isTest
private class FetchCalendersBatch_Test{

 static Supplier__c supplier;
 static Employee__c emp;
 string priRole='HSA';
 static  Date workStartTime;
 static  Date workEndTime;
 
 static testmethod void InvokeGetCalenders()
 {
 
     Test.startTest();
     workStartTime = Date.newInstance(2016,06,06);
     workEndTime = Date.Today();
     supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
     insert emp;
     
     
    List<Employee__c> empIdNList=[Select id,name from Employee__c where id =:emp.Id];
     map<id,string> mapEmpIdName=new map<id,string>();
     
     for(Employee__c emp1 : empIdNList){
     mapEmpIdName.put(emp1.id,emp1.name);
     
     }
     
     string jsonResponse = '{"items":[{"date":"2020-07-22","resourceId":"'+emp.Id+'","regular":{"recordType":"working","workTimeStart":"09:00","workTimeEnd":"19:00","shiftLabel":"09:00 - 19:00"}}],"links":[{"rel":"canonical","href":"https://api.etadirect.com/rest/ofscCore/v1/calendars?resources=a0Aw000002PGZF4EAP&dateFrom=2020-07-22&dateTo=2020-07-22"}]}';
     getCalendersResponseCalss.GetCalendersResponse  objResonse  = getCalendersResponseCalss.parse(jsonResponse);
     string recTypeName='HSA Calendar';    
     Id recordTypeId=   [SELECT id,Name from RecordType where Name =:recTypeName].Id;   
     List<OFS_Quota_Data__c> listQuotaData=new List<OFS_Quota_Data__c>();
     for(getCalendersResponseCalss.Item itemVar : objResonse.items)
     {
         if(itemVar.regular!=null && itemVar.regular.workTimeEnd != null && itemVar.regular.workTimeStart != null)
         {
           OFS_Quota_Data__c calendarVar = new OFS_Quota_Data__c(recordtypeid = recordTypeId,
                                                                 Date__c = Date.valueOf(itemVar.date_x),
                                                                 Record_Type__c = itemVar.regular.recordType,
                                                                 Work_Time_End_Text__c = itemVar.regular.workTimeEnd,
                                                                 Work_Time_Start_Text__c = itemVar.regular.workTimeStart,
                                                                 Bucket_Name__c = mapEmpIdName.get(itemVar.resourceId));
            calendarVar.External_ID__c=Utilities.popluateExternalId(calendarVar);
             
            listQuotaData.add(calendarVar);
         }
     }
     
     insert listQuotaData;
     //String query = 'Select id, Employee_ID18__c  from Employee__c where Primary_role__c=:priRole and Inactive__c = false';
     SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               jsonResponse, null);
     Test.setMock(HttpCalloutMock.class, fakeResp); 
    
     FetchCalendersBatch fetchCalenders=new FetchCalendersBatch(workStartTime ,workEndTime);
     Database.executeBatch(fetchCalenders,1);
     Test.stopTest();
 }
 
}