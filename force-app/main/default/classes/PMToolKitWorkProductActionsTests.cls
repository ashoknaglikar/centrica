/**

 */


@isTest(SeeAllData=false)
private class PMToolKitWorkProductActionsTests {

    static testMethod void preventClosedDefectsChangingTester(){
        PMToolkitTestDataCreator.dataCreator();

        RecordType MyDefectRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Defect' AND SobjectType = 'Work_Product__c'];
        RecordType MyUserStoryRT = [SELECT Id, Name FROM RecordType WHERE Name = 'User Story' AND SobjectType = 'Work_Product__c']; 
        
        Project_Overview__c Project1 = [SELECT Id FROM Project_Overview__c WHERE Name = 'Unit Test Project'];
        Work_Product__c Defect1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test Defect 1' AND Project_Overview__c =: Project1.Id];

        Defect1.Defect_State__c = 'Closed';
        Defect1.Resolution__c = 'Code Change';
        update Defect1;
        
        test.startTest();
        
        Defect1 = [SELECT Id, State__c, RecordTypeId, Defect_State__c FROM Work_Product__c WHERE Name = 'Test Defect 1' AND Project_Overview__c =: Project1.Id];
        //System.assertEquals(Defect1.RecordTypeId, MyDefectRT.Id );  
        //System.assertEquals(Defect1.Defect_State__c, 'Closed' );
        
        Defect1.RecordTypeId = MyUserStoryRT.Id;
        try {
            update Defect1;
        }       
        catch (DmlException e)
        {
            //System.assert(e.getMessage().contains('A Defect cannot be changed to a User Story once it has been Closed.'));
        }
        
        test.stopTest();
    }

    static testMethod void testBulkifiedDelete()
    {
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c Project1 = [SELECT Id FROM Project_Overview__c WHERE Name = 'Unit Test Project'];
        Work_Product__c UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        Work_Product__c UserStory2 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 2' AND Project_Overview__c =: Project1.Id];
        List<Work_Product_Task__c> wptList = new List<Work_Product_Task__c>();

        Work_Product_Task__c T1 = new Work_Product_Task__c();
        T1.Name = 'Task 1';
        T1.State__c = 'Defined';
        T1.Work_Product__c = UserStory1.Id;
        wptList.add(T1);

        Work_Product_Task__c T2 = new Work_Product_Task__c();
        T2.Name = 'Task 2';
        T2.State__c = 'Defined';
        T2.Work_Product__c = UserStory1.Id;
        wptList.add(T2);

        Work_Product_Task__c T3 = new Work_Product_Task__c();
        T3.Name = 'Task 3';
        T3.State__c = 'In-Progress';
        T3.Work_Product__c = UserStory1.Id;
        //Estimate added by Tarren - required for validation rule
        T3.Estimate__c = 1;
        wptList.add(T3);

        system.debug('Insert wptLIST ***** Number of SOQL');
        insert wptList;
        system.debug('FINISH Insert T1 ***** Number of SOQL');
    }

   
    
    /**
    * @author       Kim Roth
    * @date         07/23/2013
    * @description  Test coverage for sumTaskEstimatesToDos
    
    static testMethod void sumTaskEstimatesToDosTester() {
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c project1 = [SELECT Id FROM Project_Overview__c WHERE Name = 'Unit Test Project'];
        Work_Product__c parentUserStory = [SELECT id FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        Work_Product__c userStory1 = [SELECT Id, name, iteration__r.name FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        Iteration__c iteration1 = new Iteration__c();
        SS_Release__c release1 = new SS_Release__c();
        
        userStory1.parent__c = parentUserStory.id;
        system.debug('++++ - UPDATE PARENT USER STORY');
        update userStory1;
        
        
               
        //Testing insert of tasks
        Work_Product_Task__c T1 = new Work_Product_Task__c();
        T1.name = 'Task 1';
        T1.state__c = 'In-Progress';
        T1.Work_Product__c = userStory1.Id;
        T1.estimate__c = 1;
        T1.to_do__c = 1;
        system.debug('++++ - INSERTING WP TASK');
        insert T1; 
        PMToolkitTriggerRunOnce.resetAlreadyDone();
        test.startTest();
        //Testing iteration update
        iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id];    
        //System.assertEquals(Iteration1.To_do__c, T1.To_do__c);        
        //Testing release update
        release1 = [SELECT id, to_do__c, task_estimate__c FROM SS_Release__c WHERE Name = 'Unit Test Release' AND Project_Overview__c =: project1.id];
        //System.assertEquals(release1.to_do__c, T1.to_do__c);
        //Testing parent update
        parentUserStory = [SELECT to_do_parent__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        //System.assertEquals(parentUserStory.to_do_parent__c, T1.to_do__c);
        
        Work_Product_Task__c T2 = new Work_Product_Task__c();
        T2.name = 'Task 2';
        T2.state__c = 'In-Progress';
        T2.Work_Product__c = userStory1.Id;
        T2.estimate__c = 1;
        T2.to_do__c = 1;
        system.debug('++++ - INSERTING WP TASK');
        insert T2; 
        //Testing iteration update
        iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id];
        Double sumToDo = T1.to_do__c + T2.to_do__c;
        //System.assertEquals(Iteration1.to_do__c, sumToDo);
        //Testing release update
        release1 = [SELECT id, to_do__c, task_estimate__c FROM SS_Release__c WHERE Name = 'Unit Test Release' AND Project_Overview__c =: project1.id];
        //System.assertEquals(release1.to_do__c, sumToDo);
        //Testing parent update
        parentUserStory = [SELECT to_do_parent__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        //System.assertEquals(parentUserStory.to_do_parent__c, sumToDo);
        
        
        //Testing update of tasks
        T1.to_do__c = 2;
        system.debug('++++ - UPDATING WP TASK');
        update T1;     
        sumToDo = T1.to_do__c + T2.to_do__c;
        //Test iteration update
        iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id];
        //Testing release update
        release1 = [SELECT id, to_do__c, task_estimate__c FROM SS_Release__c WHERE Name = 'Unit Test Release' AND Project_Overview__c =: project1.id];
        //System.assertEquals(release1.to_do__c, sumToDo);
        //Testing parent update
        parentUserStory = [SELECT to_do_parent__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        //System.assertEquals(parentUserStory.to_do_parent__c, sumToDo);
        
        
        //Testing delete of tasks
        system.debug('++++ - DELETING WP TASK');
        delete T1;
        //Testing iteration update
        iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id];
        //system.assertEquals(Iteration1.to_do__c, T2.to_do__c);
        //testing release update
        release1 = [SELECT id, to_do__c, task_estimate__c FROM SS_Release__c WHERE Name = 'Unit Test Release' AND Project_Overview__c =: project1.id];
        //System.assertEquals(release1.to_do__c, T2.to_do__c);
        //Testing parent update
        //parentUserStory = [SELECT to_do_parent__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        //System.assertEquals(parentUserStory.to_do_parent__c, T2.to_do__c);
        system.debug('++++ - DELETING WP TASK');
        delete T2;
        //Testing iteration update
        iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id];
        //system.assertEquals(Iteration1.to_do__c, 0);
        //Testing release update
        release1 = [SELECT id, to_do__c, task_estimate__c FROM SS_Release__c WHERE Name = 'Unit Test Release' AND Project_Overview__c =: project1.id];
        //System.assertEquals(release1.to_do__c, 0);
        //Testing parent update
        //parentUserStory = [SELECT to_do_parent__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        //System.assertEquals(parentUserStory.to_do_parent__c, 0);
    
        test.stopTest();
        
        
    }*/
   

    /**
    * @author       Kim Roth
    * @date         07/23/2013
    * @description  Test coverage for updateIterationFromWorkProduct
    */    

    static testMethod void updateIterationAndReleaseFromWorkProductTester() {
        //Create data
        system.debug('Inside updateIterationAndReleaseFromWorkProductTester');
        PMToolkitTestDataCreator.dataCreator();
        system.debug('Data Created');
        
        Iteration__c iteration1 = [SELECT id, name FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];
        SS_Release__c release1 = [SELECT id FROM SS_Release__c WHERE name = 'Unit Test Release'];
        Project_Overview__c project1 = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];
        Work_Product__c parentUserStory = [SELECT id FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];

        //Create workproduct for test
        Work_Product__c workProduct1 = new Work_Product__c();
        workProduct1.name = 'Test WP 1';
        workProduct1.plan_estimate__c = '3';
        workProduct1.iteration__c = iteration1.id;
        workProduct1.ss_release__c = release1.id;
        workProduct1.Project_Overview__c = project1.id;
        //workProduct1.parent__c = parentUserStory.id;
        system.debug('WorkProduct1 to be inserted');
        insert workProduct1;
        system.debug('WorkProduct1 inserted');
        
        Work_Product__c workProduct2 = new Work_Product__c();
        workProduct2.name = 'Test WP 2';
        workProduct2.iteration__c = iteration1.id;
        workProduct2.ss_release__c = release1.id;
        workProduct2.Project_Overview__c = project1.id;
        //workProduct2.parent__c = parentUserStory.id;
        system.debug('WorkProduct2 to be inserted');
        insert workProduct2;
        system.debug('WorkProduct2 inserted');
        
        iteration1 = [SELECT id, name, plan_estimate__c, accepted__c FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];
        release1 = [SELECT id, plan_estimate__c, accepted__c FROM SS_Release__c WHERE name = 'Unit Test Release'];
        parentUserStory = [SELECT plan_estimate__c, accepted__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        
        system.debug('workProduct1 plan estimate, iteration 1 plan estimate = '+workProduct1.plan_estimate__c+', '+iteration1.plan_estimate__c);
        
        //Clear Trigger Memory List start of test.
        PMToolkitTriggerRunOnce.resetAlreadyDone();
        test.startTest();
        //Testing inserting work products
        /*
        system.assertEquals(integer.valueOf(workProduct1.plan_estimate__c), iteration1.plan_estimate__c);
        system.assertEquals(0,iteration1.accepted__c);
        system.assertEquals(integer.valueOf(workProduct1.plan_estimate__c), release1.plan_estimate__c);
        system.assertEquals(0,release1.accepted__c);
        system.assertEquals(workProduct1.plan_estimate__c, parentUserStory.plan_estimate__c);
        system.assertEquals(0,parentUserStory.accepted__c);
        */
        //Testing updating work products
        workProduct1.Accepted_Date_Time__c = datetime.now();
        workProduct1.State__c = 'Accepted';
        workProduct1.plan_estimate__c = '1';
        update workProduct1;

        workProduct2.plan_estimate__c = '3';
        update workProduct2;
        
        iteration1 = [SELECT id, name, plan_estimate__c, accepted__c FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];
        release1 = [SELECT id, plan_estimate__c, accepted__c FROM SS_Release__c WHERE name = 'Unit Test Release'];
        parentUserStory = [SELECT plan_estimate__c, accepted__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        integer planEstimateTotal = integer.valueOf(workProduct1.plan_estimate__c) + integer.valueOf(workProduct2.plan_estimate__c);
        /*
        system.assertEquals(integer.valueOf(workProduct1.plan_estimate__c),iteration1.accepted__c);
        system.assertEquals(planEstimateTotal, iteration1.plan_estimate__c);
        system.assertEquals(integer.valueOf(workProduct1.plan_estimate__c),release1.accepted__c);
        system.assertEquals(planEstimateTotal, release1.plan_estimate__c);
        system.assertEquals(integer.valueOf(workProduct1.plan_estimate__c),integer.valueOf(parentUserStory.accepted__c));
        system.assertEquals(planEstimateTotal, integer.valueOf(parentUserStory.plan_estimate__c));
        */
        //Testing deleting work products

        delete workProduct1;
        
        iteration1 = [SELECT id, name, plan_estimate__c, accepted__c FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];
        release1 = [SELECT id, plan_estimate__c, accepted__c FROM SS_Release__c WHERE name = 'Unit Test Release'];
        parentUserStory = [SELECT plan_estimate__c, accepted__c FROM Work_Product__c WHERE name = 'Test User Story Parent' AND Project_Overview__c =: Project1.id];
        planEstimateTotal = integer.valueOf(workProduct2.plan_estimate__c);
        
        //system.assertEquals(0,iteration1.accepted__c);
        /*
        system.assertEquals(planEstimateTotal, iteration1.plan_estimate__c);
        system.assertEquals(0,release1.accepted__c);
        system.assertEquals(planEstimateTotal, release1.plan_estimate__c);
        system.assertEquals(0,parentUserStory.accepted__c);
        system.assertEquals(planEstimateTotal, integer.valueOf(parentUserStory.plan_estimate__c));
        */
        test.stopTest();    
        
    }
    
    /**
    * @author       Kim Roth
    * @date         09/10/2013
    * @description  Test coverage for updateRank
    */    
    
    static testMethod void updateRankFromWorkProductTester() {
        //Create data
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c project1 = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];
        Work_Product__c workProduct1 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct2 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct3 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 3' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct4 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 4' AND Project_Overview__c =: Project1.id];
        PMToolkitTriggerRunOnce.resetAlreadyDone();
        
        workProduct1.rank__c = 0;
        workProduct2.rank__c = 1;
        workProduct3.rank__c = 2;
        workProduct4.rank__c = 3;
        update workProduct1;
        update workProduct2;
        update workProduct3;
        update workProduct4;
        

        delete workProduct1;

        Work_Product__c workProduct5 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        
        test.startTest();
        //system.assertEquals(0, workProduct5.rank__c);
        test.stopTest();
         
    }
    static testMethod void duplicateRankIterationTester() {
        //Create data
        PMToolkitTestDataCreator.dataCreator();
        Project_Overview__c project1 = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];

        //testing TestUtil createWorkProduct method
        Work_product__c workProduct5 = TestUtil.createWorkProduct('Test User Story 5', project1.id);

        Work_Product__c workProduct1 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct2 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct3 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 3' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct4 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 4' AND Project_Overview__c =: Project1.id];
        List<Work_Product__c> wpList = new List<Work_Product__c>();



        Iteration__c iteration1 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration' AND Project_Overview__c =: project1.id]; 
        Iteration__c iteration2 = [SELECT id, to_do__c, task_estimate__c, name FROM Iteration__c WHERE Name = 'Unit Test Iteration 2' AND Project_Overview__c =: project1.id];   


        test.startTest();
        //Set Duplicate Ranks, new iteration
        workProduct1.rank__c = 1;
        workProduct1.iteration__c = iteration2.id;
        workProduct2.rank__c = 1;
        workProduct2.iteration__c = iteration2.id;
        workProduct3.rank__c = 9999;
        workProduct3.iteration__c = iteration2.id;
        workProduct4.rank__c = 9999;
        workProduct4.iteration__c = iteration2.id;
        workProduct5.rank__c = 9999;
        workProduct5.iteration__c = iteration2.id;



        wpList.add(workProduct1);
        wpList.add(workProduct2);
        wpList.add(workProduct3);
        wpList.add(workProduct4);
        wpList.add(workProduct5);
        update wpList;

        /*
        workProduct1 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1' AND Project_Overview__c =: Project1.id];
        workProduct2 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        workProduct3 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 3' AND Project_Overview__c =: Project1.id];
        workProduct4 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 4' AND Project_Overview__c =: Project1.id];
        workProduct5 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 5' AND Project_Overview__c =: Project1.id];

        //assert items have been ordered properly
        system.assertEquals(0, workProduct1.rank__c);
        system.assertEquals(1, workProduct2.rank__c);
        system.assertEquals(2, workProduct3.rank__c);
        system.assertEquals(3, workProduct4.rank__c);
        system.assertEquals(4, workProduct5.rank__c);
        */
        test.stopTest();      
    }

    static testMethod void duplicateRankReleaseTester() {
        //Create data
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c project1 = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];

        Work_Product__c workProduct1 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct2 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct3 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 3' AND Project_Overview__c =: Project1.id];
        Work_Product__c workProduct4 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 4' AND Project_Overview__c =: Project1.id];
        List<Work_Product__c> wpList = new List<Work_Product__c>();
      

        SS_Release__c release1 = [SELECT id FROM SS_Release__c WHERE name = 'Unit Test Release'];
        SS_Release__c release2 = TestUtil.createRelease('Unit Test Release 2', project1.id, 5, 5);

        test.startTest();
        //Set Duplicate Ranks, new release, no iteration
        workProduct1.rank__c = 1;
        workProduct1.ss_release__c = release2.id;
        workProduct1.iteration__c = null;
        workProduct2.rank__c = 1;
        workProduct2.ss_release__c = release2.id;
        workProduct2.iteration__c = null;

        //Set Duplicate Ranks, no release, no iteration
        workProduct3.rank__c = 9999;
        workProduct3.ss_release__c = null;
        workProduct3.iteration__c = null;
        workProduct4.rank__c = 9999;
        workProduct4.ss_release__c = null;
        workProduct4.iteration__c = null;

        wpList.add(workProduct1);
        wpList.add(workProduct2);
        wpList.add(workProduct3);
        wpList.add(workProduct4);
        update wpList;
        /*
        workProduct1 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1' AND Project_Overview__c =: Project1.id];
        workProduct2 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 2' AND Project_Overview__c =: Project1.id];
        workProduct3 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 3' AND Project_Overview__c =: Project1.id];
        workProduct4 = [SELECT id, rank__c FROM Work_Product__c WHERE name = 'Test User Story 4' AND Project_Overview__c =: Project1.id];

        //assert items have been ordered properly
        system.assertEquals(0, workProduct1.rank__c);
        system.assertEquals(1, workProduct2.rank__c);
        system.assertEquals(0, workProduct3.rank__c);
        system.assertEquals(1, workProduct4.rank__c);
        */
        test.stopTest();      
    }
/*
    static testMethod void setWorkProductStateTester() {
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c Project1 = [SELECT Id FROM Project_Overview__c WHERE Name = 'Unit Test Project'];
        Work_Product__c UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        Work_Product__c UserStory2 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 2' AND Project_Overview__c =: Project1.Id];
        
        
        Work_Product_Task__c T1 = new Work_Product_Task__c();
        T1.Name = 'Task 1';
        T1.State__c = 'Defined';
        T1.Work_Product__c = UserStory1.Id;
        system.debug('Insert T1 ***** Number of SOQL');
        insert T1;
        
        test.startTest();
        
        T1.State__c = 'In-Progress';
        //Estimate added by Tarren - required for validation rule
        T1.Estimate__c = 1;
        system.debug('UPDATE T1 - 1 of 2 ***** Number of SOQL');
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        update T1;
        
        T1.State__c = 'Completed';
        system.debug('UPDATE T1 - 2 of 2 ***** Number of SOQL');
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        update T1;
        UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        //System.assertEquals(UserStory1.State__c, 'Completed');
        
        Work_Product_Task__c T2 = new Work_Product_Task__c();
        T2.Name = 'Task 2';
        T2.State__c = 'Defined';
        T2.Work_Product__c = UserStory1.Id;
        system.debug('INSERT T2 ***** Number of SOQL' );
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        insert T2;
        UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
       // System.assertEquals(UserStory1.State__c, 'In-Progress');
        
        T2.State__c = 'In-Progress';
        //Estimate added by Tarren - required for validation rule
        T2.Estimate__c = 1;
        system.debug('UPDATE T2 - 1 of 2 ***** Number of SOQL' );
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        update T2;
        
        T2.State__c = 'Completed';
        system.debug('UPDATE T2 - 2 of 2 ***** Number of SOQL');
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        update T2;
        //UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        //System.assertEquals(UserStory1.State__c, 'Completed');
        
        Work_Product_Task__c T3 = new Work_Product_Task__c();
        T3.Name = 'Task 3';
        T3.State__c = 'In-Progress';
        T3.Work_Product__c = UserStory1.Id;
        //Estimate added by Tarren - required for validation rule
        T3.Estimate__c = 1;
        system.debug('INSERT T3 ***** Number of SOQL');
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        insert T3;
        
        Work_Product_Task__c T4 = new Work_Product_Task__c();
        T4.Name = 'Task 4';
        T4.State__c = 'In-Progress';
        T4.Work_Product__c = UserStory1.Id;
        //Estimate added by Tarren - required for validation rule
        T4.Estimate__c = 1;
        system.debug('****************** ************ INSERT T4 ***** Number of SOQL');
        PMToolkitTriggerRunOnce.resetAlreadyDone(); //Tarren to remove
        insert T4;
        //UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        //System.assertEquals(UserStory1.State__c, 'In-Progress');
    }*/
    
}