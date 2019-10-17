trigger UpdateEmployyeRecordAfterInsert on Employee_Skills__c (after insert) {
    update_Employee_Skills_Helper.updateEmployeeRecordsAfterInsert(trigger.new);
}