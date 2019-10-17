//This is test class for EmpBucketUpdateBatch and GetBucketUpdates_Rest  apex classes
@isTest
public class EmpBucketUpdateBatch_Test{
 static Supplier__c supplier;
 static Employee__c emp;
  static testmethod void testcase1(){
  
  supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A2017',Resource_Type__c='Resource');
  insert supplier;
        
  emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Primary_role__c='OFS Bucket',Inactive__c = false);
  insert emp;
  Test.startTest();
  SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 '200',
                                               '{"items": [{"name": "testJI1","parentResourceId": "a0Aw000002ZzAeD"}]}', null);
  Test.setMock(HttpCalloutMock.class, fakeResp); 
  EmpBucketUpdateBatch buckClosure=new EmpBucketUpdateBatch();
  Database.executeBatch(buckClosure,1);
  Test.stopTest();
  
  }
  
  }