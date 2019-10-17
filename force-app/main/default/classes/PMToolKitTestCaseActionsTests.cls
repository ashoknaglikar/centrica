/**

 */
@isTest
private class PMToolKitTestCaseActionsTests {

    static testMethod void myUnitTest() {
    
        PMToolkitTestDataCreator.dataCreator();
        
        Project_Overview__c Project1 = [SELECT Id FROM Project_Overview__c WHERE Name = 'Unit Test Project'];
        Work_Product__c UserStory1 = [SELECT Id, State__c FROM Work_Product__c WHERE Name = 'Test User Story 1' AND Project_Overview__c =: Project1.Id];
        
        Test_Case__c TestCase1 = new Test_Case__c();
        TestCase1.Name = 'my test case';
        TestCase1.Method__c = 'manual';
        TestCase1.Type__c = 'acceptance';
        //TestCase1.Steps_Validation_Input__c = 'abcdefg';
        TestCase1.Steps_Validation_Expected_Results__c = 'abcdefg';
        TestCase1.Work_Product__c = UserStory1.Id;
        insert TestCase1;
        
        Test_Case__c TestCase2 = new Test_Case__c();
        TestCase2.Name = 'my second test case';
        TestCase2.Method__c = 'manual';
        TestCase2.Type__c = 'acceptance';
        //TestCase2.Steps_Validation_Input__c = 'zzzzzzzz';
        TestCase2.Steps_Validation_Expected_Results__c = 'zzzzzzzz';
        TestCase2.Work_Product__c = UserStory1.Id;
        insert TestCase2;
        
        Datetime myDate1 = datetime.newInstance(2013, 6, 23, 12, 30, 2);
        Datetime myDate2 = datetime.newInstance(2013, 6, 24, 8, 8, 0);
        Datetime myDate3 = datetime.newInstance(2013, 6, 5, 5, 5, 5);
        
        Test_Run__c TestRun1 = new Test_Run__c();
        TestRun1.Test_Case__c = TestCase1.Id; 
        TestRun1.Verdict__c = 'Block';
        TestRun1.Build__c = '124';
        TestRun1.Date__c = myDate1;
        insert TestRun1;
        
        TestCase1 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase1.Last_Verdict__c,'Block'); 
        System.assertEquals(TestCase1.Last_Run__c,myDate1);
        System.assertEquals(TestCase1.Last_Build__c,'124');
        
        TestRun1.Build__c = '1234'; 
        TestRun1.Verdict__c = 'Pass';
        TestRun1.Date__c = myDate3;
        update TestRun1;
        
        TestCase1 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase1.Last_Verdict__c,'Pass'); 
        System.assertEquals(TestCase1.Last_Run__c,myDate3);
        System.assertEquals(TestCase1.Last_Build__c,'1234');
        
        Test_Run__c TestRun2 = new Test_Run__c();
        TestRun2.Test_Case__c = TestCase1.Id; 
        TestRun2.Verdict__c = 'Fail';
        TestRun2.Build__c = 'v.1';
        TestRun2.Date__c = myDate2;
        insert TestRun2;

        TestCase1 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase1.Last_Verdict__c,'Fail'); 
        System.assertEquals(TestCase1.Last_Run__c,myDate2);
        System.assertEquals(TestCase1.Last_Build__c,'v.1');
        
        delete TestRun2;
        TestCase1 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase1.Last_Verdict__c,'Pass'); 
        System.assertEquals(TestCase1.Last_Run__c,myDate3);
        System.assertEquals(TestCase1.Last_Build__c,'1234');
        
        undelete TestRun2;
        TestCase1 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase1.Last_Verdict__c,'Fail'); 
        System.assertEquals(TestCase1.Last_Run__c,myDate2);
        System.assertEquals(TestCase1.Last_Build__c,'v.1');
        
        Test_Run__c TestRun3 = new Test_Run__c();
        TestRun3.Test_Case__c = TestCase2.Id; 
        TestRun3.Verdict__c = 'Block';
        TestRun3.Build__c = '5555';
        TestRun3.Date__c = myDate1;
        insert TestRun3;
        
        TestCase2 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my second test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase2.Last_Build__c,'5555');
        System.assertEquals(TestCase2.Last_Verdict__c,'Block'); 
        System.assertEquals(TestCase2.Last_Run__c,myDate1);

        
        delete TestRun3;
        TestCase2 = [SELECT Last_Verdict__c, Last_Run__c, Last_Build__c FROM Test_Case__c WHERE Name = 'my second test case' AND Work_Product__c = :UserStory1.Id ];
        System.assertEquals(TestCase2.Last_Verdict__c,NULL); 
        System.assertEquals(TestCase2.Last_Run__c,NULL);
        System.assertEquals(TestCase2.Last_Build__c,NULL);
    }
}