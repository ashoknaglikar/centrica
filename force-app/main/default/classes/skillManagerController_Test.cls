@isTest
private class skillManagerController_Test{
    static testMethod void myUnitTest() {
        // Create new employee__c object
         Supplier__c testSup = TestClassHelper.createSupplier();
         insert testSup;
          Employee__c testEmp = new Employee__c();
            // Setup details to use when creating test employee
            testEmp.First_Name__c = 'TestFirstName';
            testEmp.Last_Name__c = 'TestLastName';
            testEmp.Employee_Number__c = 'T1111T';
            testEmp.Name = 'TestFirstName TestLastName - T1111T';
            testemp.Resource_Type__c = 'Installer';
            testemp.Supplier__c = testSup.Id;
            insert testEmp;
         Employee_Skills__c skill = new Employee_Skills__c(Skill_Name__c = 'Test Skill',Employee__c=testEmp.Id);   
         insert skill;
            
            //Create new employee__c record    
            system.debug('----testEmp----'+testEmp);
                   
            // Pass the new id created through to the page being tested.          
            PageReference pageRef = page.skillManager;
            pageRef.getParameters().put('empid',testEmp.Id);
            Test.setCurrentPage(pageRef);
            
            skillManagerController controller1 = new skillManagerController();
             controller1.addSkills();
           for(integer i=0;i<controller1.skillClassLst.size();i++)
            {
                controller1.skillClassLst[i].isSelect = true;
            }
            controller1.addSkills();
            
            controller1.goBack();
            controller1 = new skillManagerController();
            
            testEmp.Resource_Type__c = 'changed';
            update testEmp;
            controller1 = new skillManagerController();
    }
}