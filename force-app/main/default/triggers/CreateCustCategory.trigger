/*
Author : Cognizant
Purpose : Purpose of this trigger is to create SGC customer category when appointment
		  is booked for CHI lead via appointment record itself.
		  Created this for Priority Installations CR.
*/
trigger CreateCustCategory on Appointment__c (before update) {
	
	if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_CreateCustCategory)
    {
    	return;
    }
	
	Map<ID,Appointment__c> oppIdApptMap = new Map<ID,Appointment__c>(); // Map of CHI lead Id & Appointment record
    List<Opportunity> opportunities = new List<Opportunity>(); // List of opportunities for which customer categories are going to be created
    
    for(Appointment__c newAppt : Trigger.new)
    {
    	if(newAppt.Opportunity__c != trigger.oldmap.get(newAppt.Id).Opportunity__c)
    	oppIdApptMap.put(newAppt.Opportunity__c, newAppt);
    }
    
    for(Opportunity opp : [select id,CreatedDate from Opportunity where id in: oppIdApptMap.keySet()])
    {
    	// Check for static variable to avoid recursive trigger functionality
    	if(cls_IsRun.istrg_CustAppt)
    	{
    		return;
    	}
    	Appointment__c relatedAppt = oppIdApptMap.get(opp.id);
    	if((opp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)&& (trigger.isUpdate))
       	{
       		if(relatedAppt.Big_Machines_Quote_Number__c == null && relatedAppt.Status__c != 'Cancelled')
       		{
       			// Update priority installations field on CHI lead
       			opp.Timeline_Options__c = relatedAppt.Timeline_Options__c;
	        	opp.Timeline_Reason__c = relatedAppt.Timeline_Reason__c;
	        	opp.Pending_update_to_customer_category__c = true;
	        	opp.Last_customer_cat_info_update_source__c = 'SGC';
	        	opp.Customer_Category_Modified_Datetime__c = Datetime.now();
		    	opp.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
		    	opp.Stage_object_type__c = 'Appointment';
		    	opp.Stage_object_id__c = relatedAppt.Id;
		    	opp.Sales_visit_date_time__c = relatedAppt.Start__c;
		    	opp.Date_time_appointment_booked__c = Datetime.now();
		    	opportunities.add(opp);
       		}
       		   		
       	}
    }
    if(opportunities.size() > 0)
    {
    	try{
    		cls_IsRun.setistrg_CustAppt();
    		update opportunities;
    		
    	}
    	catch(Exception ex)
    	{
    		system.debug('-----exception-----'+ex);
    	}
    }
    

}