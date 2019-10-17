trigger PMToolKitTestRunAfter on Test_Run__c (after delete, after insert, after undelete, 
after update) {
    if (Trigger.isDelete) {
        PMToolKitTestCaseActions.setTestCaseState(trigger.Old);
    }
    else {
        PMToolKitTestCaseActions.setTestCaseState(trigger.New); 
    }
}