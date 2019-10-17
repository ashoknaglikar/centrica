trigger UpdateEmployyeRecordAfterUpdate on Employee_Skills__c (after update) {
    update_Employee_Skills_Helper.updateEmployeeRecordsAfterUpdate(trigger.old,trigger.new);
}