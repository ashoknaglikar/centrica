@isTest
public class AllocatedSurveyTriggerTest
{
    
    @isTest static void testEmployeeAllocation()
    {
        Development_Survey__c survey = DevelopmentSurveyTestHelper.createSurvey();

        User userA = DevelopmentSurveyTestHelper.createUserWithProfile('Standard User', 'userA');
        Employee__c employeeA = DevelopmentSurveyTestHelper.createEmployee('Andy', 'Another', 'CO5192AB', userA);

        Allocated_Survey__c allocatedSurvey = new Allocated_Survey__c();
        allocatedSurvey.Name = 'test allocated survey';
        allocatedSurvey.Development_Survey__c = survey.Id;
        allocatedSurvey.Employee__c = employeeA.Id;


        Test.startTest();

        insert allocatedSurvey;

        Test.stopTest();
    }
    
    @isTest static void testGroupAllocation()
    {
        Development_Survey__c survey = DevelopmentSurveyTestHelper.createSurvey();

        User userA = DevelopmentSurveyTestHelper.createUserWithProfile('Standard User', 'userA');
        Employee__c employeeA = DevelopmentSurveyTestHelper.createEmployee('Andy', 'Another', 'CO5192AB', userA);

        User userB = DevelopmentSurveyTestHelper.createUserWithProfile('Standard User', 'userB');
        Employee__c employeeB = DevelopmentSurveyTestHelper.createEmployee('Bob', 'Barnes', 'CO5182AB', userB);

        List<Employee__c> employeesToPutInGroup = new List<Employee__c>();
        employeesToPutInGroup.add(employeeA);
        employeesToPutInGroup.add(employeeB);

        Groups__c groupToAllocateTo = DevelopmentSurveyTestHelper.createGroup(employeesToPutInGroup);

        Allocated_Survey__c allocatedSurvey = new Allocated_Survey__c();
        allocatedSurvey.Name = 'test allocated survey';
        allocatedSurvey.Development_Survey__c = survey.Id;
        allocatedSurvey.Group__c = groupToAllocateTo.Id;


        Test.startTest();

        insert allocatedSurvey;

        Test.stopTest();
    }


    
}