/*
* Author : Cognizant technology Solutions
* This class contains different helper methods for Priority install related CR.
*/
public class PriorityInstallHelper{
    /*
    public Customer_category_history__c createVersions(Customer_category__c newCust){
        
        Customer_category_history__c histObj = new Customer_category_history__c();
        
        histObj.Name = newCust.Lead_number__c + '_' + newCust.Type__c + '_' + newCust.Version__c;
        histObj.Customer_category_master_record__c = newCust.Id;
        histObj.Customer_category__c = newCust.Customer_category__c;
        
        histObj.Is_the_customer_s_boiler_working__c = newCust.Is_the_customer_s_boiler_working__c;
        histObj.Does_the_customer_have_hot_water__c = newCust.Does_the_customer_have_hot_water__c;
        histObj.Customer_have_any_other_form_of_HEAT__c = newCust.Customer_have_any_other_form_of_HEAT__c;
        histObj.Is_the_customer_vulnerable__c = newCust.Is_the_customer_vulnerable__c;
        histObj.Vulnerable_reason__c = newCust.Vulnerable_reason__c;
        
        histObj.Stage_object_type__c = newCust.Stage_object_type__c;
        histObj.Stage_object_id__c = newCust.Stage_object_id__c;

        histObj.Record_Status__c = newCust.Record_Status__c;
        
        histObj.Timeline_Options__c = newCust.Timeline_Options__c;
        histObj.Timeline_Reason__c = newCust.Timeline_Reason__c;
        
        histObj.History_Record_Version_Created_Datetime__c = newCust.Master_Record_Version_Created_Datetime__c;
        histObj.History_Record_Version_Created_By__c = newCust.Master_Record_Version_Created_By__c;

        histObj.Date_and_time_job_planned__c = newCust.Date_and_time_job_planned__c;
        histObj.BM_Quote_Download_into_SFDC_datetime__c = newCu\\
		histObj.Milestone_start__c = newCust.Milestone_start__c;
		
        return histObj ;
        
    }
    
    /*
    Method maps values from CHI Lead to create/update Customer Category record.
    */
    /*
    public void createOrUpdateCustomerCategory(Map<Id,Customer_category__c> customerCatMap , Map<Id,Opportunity> oppMap)
	{
	    Customer_category__c tempCust;
		Opportunity tempOpp;
		Utilities.setup();
		for(Id oppId : customerCatMap.keySet())
		{
			
			tempCust = customerCatMap.get(oppId);
			tempOpp = oppMap.get(oppId);
			if(customerCatMap.get(oppId).Opportunity__c == null){
				tempCust.Opportunity__c = oppId;
			}
			tempCust.Is_the_customer_s_boiler_working__c = tempOpp.Is_the_customers_boiler_working__c;
			tempCust.Does_the_customer_have_hot_water__c = tempOpp.Does_the_customer_have_hot_water__c;
			tempCust.Customer_have_any_other_form_of_HEAT__c = tempOpp.Customer_have_any_other_form_of_HEAT__c;
			tempCust.Is_the_customer_vulnerable__c = tempOpp.Is_the_customer_vulnerable__c;
			tempCust.Vulnerable_reason__c = tempOpp.Vulnerable_reason__c;
			tempCust.Customer_category__c = tempOpp.Latest_customer_category__c;
			tempCust.Record_Status__c = 'Active';
			
			if(tempOpp.Last_customer_cat_info_update_source__c == 'Sales')
			{
				tempCust.Timeline_Options__c = tempOpp.Timeline_Options__c;
				tempCust.Timeline_Reason__c = tempOpp.Timeline_Reason__c;
				if(tempCust.RecordTypeId == null)
				{
					tempCust.RecordTypeId = Utilities.getRecordTypeId('Sales', 'Customer_category__c');
				}
				if(tempOpp.Stage_object_type__c == 'Bigmachines quote')
				{
					tempCust.Stage_object_type__c = tempOpp.Stage_object_type__c;
					tempCust.Stage_object_id__c = tempOpp.Stage_object_id__c;
				}
			}
			else if(tempOpp.Last_customer_cat_info_update_source__c == 'Installation')
			{
				tempCust.Timeline_Reason__c = tempOpp.Installation_opt_out_reason__c;
				tempCust.Timeline_Options__c = tempOpp.Installation_Opt_Out_Type__c;
				if(tempCust.RecordTypeId == null)
				{
					tempCust.RecordTypeId = Utilities.getRecordTypeId('Installation', 'Customer_category__c');
				}
				if(tempOpp.Stage_object_type__c == 'Job')
				{
					tempCust.Stage_object_type__c = tempOpp.Stage_object_type__c;
					tempCust.Stage_object_id__c = tempOpp.Stage_object_id__c;
				}
			}
			else if(tempOpp.Last_customer_cat_info_update_source__c == 'SGC')
			{
				tempCust.Timeline_Options__c = tempOpp.Timeline_Options__c;
				tempCust.Timeline_Reason__c = tempOpp.Timeline_Reason__c;
				if(tempCust.RecordTypeId == null)
				{
					tempCust.RecordTypeId = Utilities.getRecordTypeId('SGC', 'Customer_category__c');
				}
				if(tempOpp.Stage_object_type__c == 'Appointment')
				{
					tempCust.Stage_object_type__c = tempOpp.Stage_object_type__c;
					tempCust.Stage_object_id__c = tempOpp.Stage_object_id__c;
				}
			}
			tempCust.BM_Quote_Download_into_SFDC_datetime__c = tempOpp.BM_Quote_Download_into_SFDC_datetime__c;
			tempCust.Date_and_time_job_planned__c = tempOpp.Date_and_time_job_planned__c;
			tempCust.Master_Record_Version_Created_By__c = tempOpp.Customer_Category_Record_Modified_By__c;
			tempCust.Master_Record_Version_Created_Datetime__c = tempOpp.Customer_Category_Modified_Datetime__c;
			tempCust.Stage_object_type__c = tempOpp.Stage_object_type__c;
			tempCust.Stage_object_id__c = tempOpp.Stage_object_id__c;
			
		}
	}
	*/
}