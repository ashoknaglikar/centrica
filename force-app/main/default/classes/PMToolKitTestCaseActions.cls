/**
* @author       Mark Baker      
* @date         06/23/2013
* @description  Class that sets values on a Test Case based on the most
*               recent Test Run.  Values are:
*               Test_Case__c.Last_Run__c => Test_Run__c.Date__c
*               Test_Case__c.Last_Build__c => Test_Run__c.Build__c
*               Test_Case__c.Last_Verdict__c => Test_Run__c.Verdict__c
*               If the action is from a delete of Test Runs and there are no
*               Test Runs under a Test Case, set those values on Test Case 
*               to Blank.
*
*    --------------------------------------------------------------------------
*    Developer                  Date                Description
*    --------------------------------------------------------------------------
*   
*    Mark Baker                 06/23/2013          Created
*/

public with sharing class PMToolKitTestCaseActions {

    //PR: Nice style improvements.  You're probably cursing my name about now
    //but I would suggest variable names be camel cased.  So for something like below it
    //would be List<Test_Run__c> triggerList.  Obviously changing this would have no effect
    //on how the code runs, but its ideal because then people can read just one word of code
    //and have some idea of the context of what they are looking at.
    public static void setTestCaseState(List<Test_Run__c> TriggerList) {
        
        //PR: Integer i; Map; Test_Case__c thisTestCase, etc
        integer I;
        map<Id, Test_Run__c> TestCasesMap = new map<Id, Test_Run__c>();
        List<Id> TcList = new List<Id>();
        List<Id> MapKeyList = new List<Id>();
        List<Test_Case__c> tcUpdateList = new List<Test_Case__c>();
        Test_Case__c ThisTestCase;
        Test_Run__c ThisTestRun;
        
        //get the list of Test Cases to examine
        //PR: This works fine but I would use the iterator-type loop instead e.g.
        //for(Test_Run__c tr : triggerList)
        for (I=0; I<triggerList.size(); I++) {
            TcList.add(TriggerList[i].Test_Case__c);
        }

        //query for test runs in Test Case List order by date desc - throw into a map -> test case number / test run object, 
        for (Test_Run__c QueryTR : [SELECT Verdict__c, Date__c, Build__c, Test_Case__c 
                               FROM Test_Run__c 
                               WHERE Test_Case__c 
                               IN :TcList 
                               ORDER BY Date__c DESC]) {
            //if it's already in the map don't add it.  This combined with the date desc sort
            //lets us know the one in the map is the most recent one.
            if (!(TestCasesMap.containsKey(QueryTR.Test_Case__c))) {
                TestCasesMap.put(QueryTR.Test_Case__c,QueryTR);
                
                //PR: You dont need this list, the map already has it.  
                //You can get at this list from the map by doing:
                //testCasesMap.keySet()
                MapKeyList.add(QueryTR.Test_Case__c);
            }
        }

        //iterate through the map, grab object details, throw into list of Test Cases to update
        //PR: Instead of mapKeyList, this should be iteration over testCaseMap.keySet, e.g.
        //for(Id key : testCasesMap.keySet())
        //and then your references to mapKeyList[i] just get replaced with the key variable.
        for (I=0; I<MapKeyList.size(); I++) {
            ThisTestRun = TestCasesMap.get(MapKeyList[i]);
            ThisTestCase = new Test_Case__c();
            ThisTestCase.Id = ThisTestRun.Test_Case__c;
            ThisTestCase.Last_Verdict__c = ThisTestRun.Verdict__c;
            ThisTestCase.Last_Run__c = ThisTestRun.Date__c;
            ThisTestCase.Last_Build__c = ThisTestRun.Build__c;
            tcUpdateList.add(ThisTestCase);
        }

        //find Test Cases from the trigger with no test runs, throw into list of objects to update
        //but with blank values for last run, last build and last verdict;
        //PR: Same comment this is a C-style loop and iterator loops are preferred in Apex
        for (I=0; I<TriggerList.size(); I++) {
            if (!(TestCasesMap.containsKey(TriggerList[i].Test_Case__c))) {
                ThisTestCase = new Test_Case__c();
                ThisTestCase.Id = TriggerList[i].Test_Case__c;
                ThisTestCase.Last_Verdict__c = NULL;
                ThisTestCase.Last_Run__c = NULL;
                ThisTestCase.Last_Build__c = NULL;
                TcUpdateList.add(ThisTestCase);
            }
        }

        //update objects
        //PR: Probably won't be an issue but there are governor limits around how much data you can update inside an after trigger.  
        //Like 10k rows or something.
        if (TcUpdateList.size() > 0) { 
        	update TcUpdateList; 
    	}
    }

}