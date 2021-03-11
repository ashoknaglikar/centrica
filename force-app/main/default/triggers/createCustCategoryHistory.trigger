/*
* Author : Cognizant technology Solutions
* This trigger is to create a copy of the  
* customer category history everytime the 
* master customer category record is 
* changed...
*/
trigger createCustCategoryHistory on Customer_category__c (after insert,before update) {
    /*
    List<Customer_category_history__c> custHistoryList = new List<Customer_category_history__c>();
    
    Integer i=0;
    
    for(Customer_category__c newCust : Trigger.new){
        
        if(Trigger.isInsert){
            
            custHistoryList.add(new PriorityInstallHelper().createVersions(newCust));
             
        }else if(newCust.Is_the_customer_s_boiler_working__c != Trigger.old[i].Is_the_customer_s_boiler_working__c ||
                newCust.Does_the_customer_have_hot_water__c != Trigger.old[i].Does_the_customer_have_hot_water__c ||
                newCust.Customer_have_any_other_form_of_HEAT__c != Trigger.old[i].Customer_have_any_other_form_of_HEAT__c ||
                newCust.Is_the_customer_vulnerable__c != Trigger.old[i].Is_the_customer_vulnerable__c ||
                newCust.Vulnerable_reason__c != Trigger.old[i].Vulnerable_reason__c ||
                newCust.Customer_category__c != Trigger.old[i].Customer_category__c ||
                newCust.Stage_object_type__c != Trigger.old[i].Stage_object_type__c ||
                newCust.Stage_object_id__c != Trigger.old[i].Stage_object_id__c ||
                newCust.Record_Status__c != Trigger.old[i].Record_Status__c ||
                newCust.Timeline_Options__c != Trigger.old[i].Timeline_Options__c ||
                newCust.Timeline_Reason__c != Trigger.old[i].Timeline_Reason__c ||
                newCust.Milestone_start__c != Trigger.old[i].Milestone_start__c ||
                newCust.Milestone_End__c != Trigger.old[i].Milestone_End__c ||
                newCust.Date_and_time_job_planned__c != Trigger.old[i].Date_and_time_job_planned__c || 
                newCust.BM_Quote_Download_into_SFDC_datetime__c != Trigger.old[i].BM_Quote_Download_into_SFDC_datetime__c){
                    
                newCust.Version__c = newCust.Version__c + 1;
                custHistoryList.add(new PriorityInstallHelper().createVersions(newCust));
                
        }
        
        i++;
        
    }
    
    if(custHistoryList.size() > 0){
        
        try{
            
            insert custHistoryList;
            
        }catch(Exception e){
            
            System.debug('-Exception-'+e.getMessage());
            
        }
        
    }
    */
}