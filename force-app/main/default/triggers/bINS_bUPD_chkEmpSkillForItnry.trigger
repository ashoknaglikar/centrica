/*
*    This trigger is responsible for checking the skills required to carry out the itinerary appointment
*    i.e Scaffold/Asbestos/Survey or Waste collection and then checks the ckills that the assigned to employee already have
*    If the employee skill does not list the skill required to carry the appointment then, error is thrown back to the user.
*/
trigger bINS_bUPD_chkEmpSkillForItnry on Appointment__c (before insert,before update) {
	
	if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_bINS_bUPD_chkEmpSkillForItnry)
    {
    	return;
    }
	
    //Variable to store appointment's Assigned to employee references
    Set<String> employeeIds = new Set<String>();
    //Variable to store the record type id for itinerary appointment    
    String itineraryId = RecordTypeIdHelper.getRecordTypeId('Appointment__c','Itinerary');
    //Looping through the incoming appointments to populate the set variable with assigned to employee id
    for(appointment__c app : Trigger.new){
        System.debug('----1 --- '+app.id+'-- 2 --'+app.RecordTypeId+'--3 --'+app.Assigned_to__c);
        if(app.RecordTypeId == itineraryId ){
            employeeIds.add(app.Assigned_to__c);
        }    
    }
    if(employeeIds.size() > 0){
        //Retrieve the skills related to the employees assigned to appoiintments
        Employee_Skills__c[] skills = [Select Skill_Name__c,Employee__c From Employee_Skills__c where employee__c in :employeeIds];
        if(skills.size() > 0){
            //Variable to store skills per employee basis
            Map<String,List<Employee_Skills__c>> empSkillMap = new Map<String,List<Employee_Skills__c>>();
            //Variable to store list of skills for a particular employee .Will be reset for every new employee
            List<Employee_Skills__c> tempSkillList= new List<Employee_Skills__c>();
            //Looping to put all the skills goruped by their respective employees in a map
            for(String empId : employeeIds){
                tempSkillList.clear();
                for(Employee_Skills__c skill : skills){
                    if(skill.Employee__c == empId){
                        tempSkillList.add(skill);
                    }
                }
                empSkillMap.put(empId,tempSkillList);
            }
            //Looping through check if the skills listed against employee matched the the skill required for the appointment
            for(Appointment__c app : Trigger.new){
                String appSkillRequired = app.Type__c;
                boolean entered = false;
                for(Employee_Skills__c skill : empSkillMap.get(app.Assigned_to__c)){
                    if(skill.Skill_name__c == appSkillRequired){
                        entered = true;
                    }
                }
                //the variable entered will only be false if no match is found between the skills present and skills required
                if(entered == false){
                    app.addError('Employee selected in the Assigned To field does not have required skill');    
                }
            }
        }
        // Will come here if no skill is defined for any employee assigned
        else{
            for(Appointment__c app : Trigger.new){
                app.addError('Employee selected in the Assigned To field does not have any skill required for the appointment');
            }
        }
    }
}