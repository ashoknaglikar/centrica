@IsTest
public class engineerCallAppPayRollCheck_Test {
    
    public static TestMethod void engineerPayrollcheckTest(){
        Employee__c emp=TestClassHelper.createEmployee();
        emp.Group__c='ENGI';
        insert emp;
        test.startTest();
        engineerCallAppPayRollCheck.engineerPayrollcheck(emp.Employee_Number__c);
        test.stopTest();
        
    }
    
}