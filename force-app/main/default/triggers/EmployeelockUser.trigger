trigger EmployeelockUser on Week_Lock__c (before Insert, before Update) {

    Id empId = UserInfo.getUserId();

    for(Week_Lock__c wL :trigger.new){
    
        if(string.valueof(wL.Locking_User__c) == null)
           wL.Locking_User__c = empId;
        /*else if(wL.Locking_User__c !=empId)
             wL.addError('Please enter the current user');*/
    }
}