trigger UpdateEmployyeRecordAfterDelete on Employee_Skills__c (after delete) {
    update_Employee_Skills_Helper.updateEmployeeRecordsAfterDelete(trigger.old); 
}