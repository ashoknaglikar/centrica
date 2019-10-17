/*
*    Trigger : bUPD_CheckCasesAndupdateAgeOver
*    This Trigger is responsible for calculating Case Age Over i.e. number of days a case remains unattended
*    based on the Active default business hour.
*    It also prevents owners to be chnaged after a case is closed
*/
trigger bUPD_CheckCasesAndupdateAgeOver on Case (before update) {
    Integer count=0;
    string dissatisfactionId = RecordTypeIdHelper.getRecordTypeId('Case', 'Dissatisfaction');
    // Added for the UAT Change that users are not allowed to close the case, if a pending task is present.
    set<id> set_caseid = new set<id>();
       for(Case obj_cases : Trigger.new){
        if (obj_cases.RecordTypeId != dissatisfactionId && (obj_cases.Status == 'Closed' ||obj_cases.Status == 'Resolved') )
        {
            set_caseid.add(obj_cases.id);
        }
     }
     system.debug('Set_caseid-->'+set_caseid);
     List<Task> lst_tasks = [Select Id,Whatid,OwnerId,ActivityDate,Status from Task where Whatid IN:set_caseid and Status != 'Completed'];
    // Iterating through the cases 
    for(Case cases : Trigger.new){  
        /*
        if(cases.Isclosed && cases.OwnerId != (Trigger.old[count]).ownerId )
             cases.addError('Cannot change Case after it is closed');
    
       */
        // retrieving the default and Active business hours
        BusinessHours P5_BusHours = [select id from businesshours where IsDefault=true and IsActive =  true];  
        // It Finds the number of business hours milliseconds between startTime and endTime as              
        // defined by the default business hours.  Will return a negative value if endTime is             
        // before startTime, 0 if equal, positive value otherwise. 
        Long lngdiff_ModToday = BusinessHours.diff(P5_BusHours.id, cases.CreatedDate, cases.LastModifiedDate);
        System.debug('lngdiff_ModToday--->'+lngdiff_ModToday);
        Long lngdiff_Mod1Today = (lngdiff_ModToday/(1000*60*60))/9;                 
        
        // Setting the case Age Over field in case      
        cases.Age_over__c = lngdiff_Mod1Today;
     }
     //Showing the error message.
    for(Case cases : Trigger.new){
     if (lst_tasks.size()>0)
        {
            cases.addError('Cannot close the case as it has an pending task.');
        }
    }
}