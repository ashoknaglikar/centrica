public with sharing class PMToolKitTestDataCreator {

    public static void dataCreator() {
        
        RecordType MyRT;
        
        //Creating test program
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Program' AND SobjectType = 'Project_Overview__c'];
        Project_Overview__c TestProgram = new Project_Overview__c();
        TestProgram.Name = 'Unit Test Program';
        TestProgram.Project_Stage__c = 'Open';
        TestProgram.RecordTypeId = MyRT.Id;
        system.debug('MANUAL INSERT: PROGRAM');
        insert TestProgram;
       
        //Creating test project
        //Tarren 10/7/2013 Changed Name = 'Project' to Name = 'Agile Project'
        
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Agile Project' AND SobjectType = 'Project_Overview__c']; 
        Project_Overview__c TestProject = new Project_Overview__c();
        TestProject.Name = 'Unit Test Project';
        TestProject.Project_Stage__c = 'Open';
        TestProject.RecordTypeId = MyRT.Id;
        //TestProject.Program__c = TestProgram.Id;
        system.debug('MANUAL INSERT: PROJECT');
        insert TestProject;

        
        //Creating test release
        SS_Release__c TestRelease = new SS_Release__c();
        TestRelease.Name = 'Unit Test Release';
        TestRelease.State__c = 'Active';
        TestRelease.Start_date__c = date.newInstance(2013,5,30);
        TestRelease.Release_date__c = date.newInstance(2014,5,30);
        TestRelease.Project_Overview__c = TestProject.Id;
        system.debug('MANUAL INSERT: SS RELEASE');
        insert TestRelease;
        
        //Creating test iteration #1
        Iteration__c TestIteration = new Iteration__c();
        TestIteration.Name = 'Unit Test Iteration';
        TestIteration.State__c = 'Active';
        TestIteration.Start_date__c = date.newInstance(2013,5,30);
        TestIteration.End_date__c = date.newInstance(2014,6,30);
        TestIteration.Project_Overview__c = TestProject.Id;
        system.debug('MANUAL INSERT: ITERATION');
        insert TestIteration;
        
        //Creating test iteration #2
        Iteration__c TestIteration2 = new Iteration__c();
        TestIteration2.Name = 'Unit Test Iteration 2';
        TestIteration2.State__c = 'Active';
        TestIteration2.Start_date__c = date.newInstance(2013,5,30);
        TestIteration2.End_date__c = date.newInstance(2013,6,30);
        TestIteration2.Project_Overview__c = TestProject.Id;
        system.debug('MANUAL INSERT: ITERATION 2');
        insert TestIteration2;
        
        //Creating test parent work product
        myRT = [SELECT Id, Name FROM RecordType WHERE Name = 'User Story' AND SobjectType = 'Work_Product__c'];
        Work_Product__c TestParentWP = new Work_Product__c();
        TestParentWP.name = 'Test User Story Parent';
        TestParentWP.RecordTypeID = myRT.Id;
        TestParentWP.Project_Overview__c = TestProject.Id;
        system.debug('MANUAL INSERT: PARENT WP');
        insert TestParentWP;
        
      //Creating test work product #1
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'User Story' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_US1 = new Work_Product__c();
        Test_US1.Name = 'Test User Story 1';
        Test_US1.RecordTypeId = MyRT.Id;
        Test_US1.Project_Overview__c = TestProject.Id;  
        Test_US1.Iteration__c = TestIteration.Id;
        Test_US1.SS_release__c = TestRelease.Id;   
        Test_US1.rank__c = 0;
        system.debug('MANUAL INSERT: USER STORY');
        insert Test_US1;  
        
        //Creating test work product #2
        Work_Product__c Test_US2 = new Work_Product__c();
        Test_US2.Name = 'Test User Story 2';
        Test_US2.RecordTypeId = MyRT.Id;
        Test_US2.Project_Overview__c = TestProject.Id;
        Test_US2.Iteration__c = TestIteration.Id;
        Test_US2.SS_release__c = TestRelease.Id;  
        Test_US2.rank__c = 1;
        system.debug('MANUAL INSERT: USER STORY 2');
        insert Test_US2;
        
        //Creating test work product #3
        Work_Product__c Test_US3 = new Work_Product__c();
        Test_US3.Name = 'Test User Story 3';
        Test_US3.RecordTypeId = MyRT.Id;
        Test_US3.Project_Overview__c = TestProject.Id;
        Test_US3.Iteration__c = TestIteration.Id;
        Test_US3.SS_release__c = TestRelease.Id;  
        Test_US3.rank__c = 2;
        system.debug('MANUAL INSERT: USER STORY 3');
        insert Test_US3;
        
        //Creating test work product #4
        Work_Product__c Test_US4 = new Work_Product__c();
        Test_US4.Name = 'Test User Story 4';
        Test_US4.RecordTypeId = MyRT.Id;
        Test_US4.Project_Overview__c = TestProject.Id;
        Test_US4.Iteration__c = TestIteration.Id;
        Test_US4.SS_release__c = TestRelease.Id;
        Test_US4.rank__c = 3;
        system.debug('MANUAL INSERT: USER STORY 4');
        insert Test_US4;
      
        //Creating test defect
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Defect' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_Defect1 = new Work_Product__c();
        Test_Defect1.Name = 'Test Defect 1';
        Test_Defect1.RecordTypeId = MyRT.Id;
        Test_Defect1.Project_Overview__c = TestProject.Id;
        Test_Defect1.Description__c = 'Terrible Defect.';
        Test_Defect1.Priority__c = '4 - Low';
        Test_Defect1.Severity__c = '4 - Cosmetic';
        Test_Defect1.Type__c = 'Bug';
        Test_Defect1.Defect_State__c = 'Open';
        Test_Defect1.Steps_to_Reproduce__c = 'Steps to reproduce.';
        system.debug('MANUAL INSERT: USER STORY 5 - Defect');
        insert Test_Defect1;

        PMToolkitTriggerRunOnce.resetAlreadyDone();
    }


}