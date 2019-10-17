@isTest
private class FetchBuckClosureBatch_Test{

 static Supplier__c supplier;
 static Employee__c emp;
 string priRole='OFS Bucket';
 static  Date workStartTime;
 static  Date workEndTime;
 
 static testmethod void InvokeGetQuotaData()
 {
 
     Test.startTest();
     workStartTime = Date.newInstance(2016,06,06);
     workEndTime = Date.Today();
     supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='OFS Bucket');
     insert emp;
     String query = 'Select id, Employee_ID18__c  from Employee__c where Primary_role__c=:priRole and Inactive__c = false';
     FetchBuckClosureBatch buckClosure=new FetchBuckClosureBatch(workStartTime ,workEndTime);
     Database.executeBatch(buckClosure,1);
     Test.stopTest();
 }
 
}