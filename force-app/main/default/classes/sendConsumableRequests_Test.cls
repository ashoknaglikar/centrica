/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class sendConsumableRequests_Test {
    
    static testMethod void testMehodForBatchClass() {
        
        User u = TestClassHelper.createUser();
        insert u;
        
        District__c dist = TestClassHelper.createDistrict();
        dist.Callidus_Patch_Id__c = 'CHI00';
        insert dist;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        emp.Pay_Number__c = '0123454';
        emp.District__c = dist.Id;
        insert emp;
        
        Consumables__c cosumable = TestClassHelper.createCosumable();
        insert cosumable;
        
        Consumables_Requests__c c = TestClassHelper.createCosumableRequest( emp.Id);
        insert c;
        
        Consumable_Items__c item = TestClassHelper.createCosumableItem(cosumable.Id, c.Id );
        insert item;
        
        c.Status__c = 'Submitted';
        update c;
        
        Test.startTest();
         try{
        sendConsumableRequests newObj = new sendConsumableRequests();
        newObj.createConReqBatch();
        string s = newObj.padChar('test', 10, '0', false);
        scheduleConsumableRequests sCR = new scheduleConsumableRequests();
        SchedulableContext sc;
        sCR.execute(sc);
        }catch(Exception e){}
        Test.stopTest();
        // TO DO: implement unit test
    }
    
    /*static testMethod void testMehodForSendConsumablesCont() {
        User u = TestClassHelper.createUser();
        insert u;
        
        District__c dist = TestClassHelper.createDistrict();
        dist.Callidus_Patch_Id__c = 'CHI00';
        insert dist;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        emp.Pay_Number__c = '0123454';
        emp.District__c = dist.Id;
        insert emp;
        
        Consumables__c cosumable = TestClassHelper.createCosumable();
        insert cosumable;
        
        Consumables_Requests__c c = TestClassHelper.createCosumableRequest( emp.Id);
        insert c;
        
        Consumable_Items__c item = TestClassHelper.createCosumableItem(cosumable.Id, c.Id );
        insert item;
        c.Picked_Up_by_Email__c = true;
        c.Status__c = 'Submitted';
        update c;
        
        Test.startTest();
        SendConsumablesCont newobj = new SendConsumablesCont();
        newobj.FieldType = 'Created Date';
        newobj.cReq1.Submitted_DateTime__c = system.now()-1;
        newobj.cReq2.Submitted_DateTime__c = system.now()+1;
        newobj.fetchRequests();
        for (SendConsumablesCont.conReqInner cInner:  newobj.cReqInnrList)
        {
            cInner.isSelected = true;
        }
        newobj.updateConsumables();
        newobj.message = 'test error';
        newObj.setErrorMsg(true);
        newObj.setErrorMsg(false);
        newObj.getFieldTypeOptions();
        newObj.EmailConsumables();
        newObj.FieldType = 'File Name';
        newobj.fetchRequests();
        Test.stopTest();
    }*/
}