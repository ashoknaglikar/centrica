//This is test class for WorkZoneUpdateBatch apex class
@isTest
private class WorkZoneUpdateBatch_Test{

static Region__c testReg;
static District__c testDistrict;
static Sub_Patch__c testSubPatch;
static Postcode_Sector__c testSalesSector;

static void createData()
    {
    testReg=new Region__c(Name = 'Test northeast', Code__c = '001', Type__c = 'Sales');  
    insert  testReg;
    testDistrict = new District__c(Type__c='Sales', Name='SalesDistrict', Code__c='xxxxxxxx',region__c=testReg.id);
    insert TestDistrict;
    
    testSubPatch = new Sub_Patch__c(Type__c='Sales',Name='SalesSubpatch',OFS_WZ_Sub_Status__c='Created',OFS_WZ_Status__c='Ready To be Picked up', District__c=TestDistrict.Id, Code__c='xxxx');
    insert TestSubPatch;
   
    testSalesSector = new Postcode_Sector__c(Type__c='Sales',Name='ZTPCS 1',OFS_Keys_Status__c='Ready To Be Picked Up',OFS_Keys_Sub_Status__c='Created', Sub_Patch__c=TestSubPatch.Id);
    insert TestSalesSector;
    }
 static void createDeactData()
    {
    testReg=new Region__c(Name = 'Test northeast', Code__c = '001', Type__c = 'Sales');  
    insert  testReg;
    testDistrict = new District__c(Type__c='Sales', Name='SalesDistrict', Code__c='xxxxxxxx',region__c=testReg.id);
    insert TestDistrict;
    
    }
 static testmethod void InvokeCreateWZ()
 {
    createData();
    Test.startTest();
   
    
    SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 '200',
                                               '{"items": [{"workZoneLabel": "xxxx","workZoneName": "SalesSubpatch","status":"active","travelArea": "North","keys": ["ZTPCS 1"]}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    workzoneKeyBatch wzUpdate=new workzoneKeyBatch();
    Database.executeBatch(wzUpdate,1);
    Test.stopTest();
 }
 static testmethod void InvokeUpdateWZ()
 {
    
    createData();
    
    testSubPatch.name='SalesUpSubpatch1';
    update testSubPatch;
    Test.startTest();
    
    SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 '200',
                                               '{"items": [{"workZoneLabel": "xxxx","workZoneName": "SalesUpSubpatch1","status":"active","travelArea": "North","keys": ["ZTPCS 1"]}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    WorkZoneUpdateBatch wzUpdate=new WorkZoneUpdateBatch();
    
    Database.executeBatch(wzUpdate,1);
    WorkZoneUpdateBatch.SubPatchWrapper sWrapper=new WorkZoneUpdateBatch.SubPatchWrapper('testccc','tstWZ','active','North');
    WorkZoneUpdateBatch.SubPatchWrapResp respWrap= new WorkZoneUpdateBatch.SubPatchWrapResp();
    respWrap.hasMore=true;
    respWrap.totalResults=1;
    respWrap.offset=2;
    respWrap.items=new List<WorkZoneUpdateBatch.SubPatchWrapper>();
    WorkZoneUpdateBatch.Links respLink= new WorkZoneUpdateBatch.Links();
    respLink.rel='testRel';
    respLink.href='testHref';
    WorkZoneUpdateBatch.workzoneRestresponseObj respObj=new WorkZoneUpdateBatch.workzoneRestresponseObj();
    respObj.type='testType';
    Test.stopTest();
 }
  static testmethod void InUpdateWZKeys()
 {
    
    createData();
    
    Postcode_Sector__c testSalesSector1 = new Postcode_Sector__c(Type__c='Sales',Name='ZZX X',OFS_Keys_Status__c='Ready To Be Picked Up',OFS_Keys_Sub_Status__c='Created', Sub_Patch__c=testSubPatch.Id,Old_SubPatch__c=testSubPatch.id);
    insert testSalesSector1;
    Test.startTest();
    
    SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 '200',
                                               '{"items": [{"workZoneLabel": "xxxx","workZoneName": "SalesSubpatch","status":"active","travelArea": "North","keys": ["ZTPCS 1","ZZX X"]}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    workzoneKeyBatch wzUpdate=new workzoneKeyBatch();
    Database.executeBatch(wzUpdate,1);
    Test.stopTest();
 }
  static testmethod void DeactUpdateWZ()
 {
    createDeactData();
    Test.startTest();
    
    Sub_Patch__c testSubPatch2 = new Sub_Patch__c(OFS_WZ_Status__c='Ready To Be Picked Up',OFS_WZ_Sub_Status__c='Deactivated',Type__c='Sales',Name='SalesSubpatch2', District__c=TestDistrict.Id, Code__c='xxzz');
    insert TestSubPatch2;
    SubPatchUpInOFSRestMock fakeResp = new SubPatchUpInOFSRestMock(200,
                                                 'inactive',
                                               '{"items": [{"workZoneLabel": "xxzz","workZoneName": "SalesSubpatch2","status":"inactive","travelArea": "North","keys": ["ZTPCS 2"]}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    WorkZoneUpdateBatch wzUpdate=new WorkZoneUpdateBatch();
    Database.executeBatch(wzUpdate,1);
    WorkZoneUpdateBatch.SubPatchWrapper sWrapper=new WorkZoneUpdateBatch.SubPatchWrapper('xxzz','SalesSubpatch2','inactive','North');
   
    List<WorkZoneUpdateBatch.SubPatchWrapper> subPWrapList = new List<WorkZoneUpdateBatch.SubPatchWrapper>();
    subPWrapList.add(sWrapper);
    Sub_Patch__c tempRecord = WorkZoneUpdateBatch.deactivateWorkZones(testSubPatch2, subPWrapList);
   
    Test.stopTest();
 }
}