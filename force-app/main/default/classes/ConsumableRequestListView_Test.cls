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
private class ConsumableRequestListView_Test {

    static testMethod void Installer_TestScenario() {
        user u = TestClassHelper.createUser();
        u.EmployeeNumber = '1234321';
        insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        insert emp;
        
        
        system.runas(u){
        Consumables_Requests__c cReq1 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq1.Status__c = 'In Progress';
        cReq1.IsShoppingBasket__c = true;
        Consumables_Requests__c cReq2 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq2.Status__c = 'Submitted';
        cReq2.IsShoppingBasket__c = true;
        insert (new list<Consumables_Requests__c>{cReq1,cReq2}); 
        
        ConsumableRequestListView obj = new ConsumableRequestListView();
        obj.pageSize=1;
        obj.next();
        obj.previous();
        pagereference p =obj.newmethod();
        obj.contMethod();
        system.assertEquals(p.getUrl(), '/apex/ConsumableSearch');
        obj.hasNext=true;
        obj.hasPrevious=true;
        obj.pageNumber=2;
        
        
        }
        // TO DO: implement unit test
        
        
    }
    static testMethod void DHM_TestScenario() {
        Id DHMProfileId = [Select id from Profile where Name = 'CHI Installation - DHM'].Id;
        user u = TestClassHelper.createUser();
        u.EmployeeNumber = '1234321';
        u.ProfileId = DHMProfileId;
        insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        insert emp;
        
        
        District__c dist = TestClassHelper.createDistrict();
        dist.Type__c = 'Installation';
        dist.DHMName__c = emp.Id;
        insert dist;
        emp.District__c = dist.Id;
        update emp;
        
        Consumables_Requests__c cReq1 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq1.Status__c = 'In Progress';
        cReq1.IsShoppingBasket__c = true;
        Consumables_Requests__c cReq2 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq2.Status__c = 'Submitted';
        cReq2.IsShoppingBasket__c = true;
        insert (new list<Consumables_Requests__c>{cReq1,cReq2}); 
        
         
        system.runas(u){
        
        ConsumableRequestListView obj = new ConsumableRequestListView();
        system.assert(obj.isDHM);
        }
        
        
        
        // TO DO: implement unit test
    }
}