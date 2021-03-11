/*
* Author : Cognizant technology Solutions
* This trigger is to create/update a copy of the  
* customer category everytime the 
* master CHI Lead record is 
* changed...
*/
trigger instUpdateCustCategoaryMasterRecord on Opportunity (after insert, before update) {
  if(cls_IsRun.generalTriggerSwitch)
  {
		return;
  }
  if(cls_IsRun.isinstUpdCustCatMasRec)
  return;
  /*
  List<Id> oppIds = new List<Id>();
  List<Customer_category__c> allCustomerCategories = new List<Customer_category__c>();
  Map<Id,Customer_category__c> oppsToCreateMasterCustCategoryMap = new Map<Id,Customer_category__c>();
  PriorityInstallHelper prioHelper = new PriorityInstallHelper();
  List<Customer_category__c> customerCategoriesToBeLocked = new List<Customer_category__c>();
  Map<Id,Customer_category__c> allExistingSGCCustomerCategoriesMap = new Map<Id,Customer_category__c>();
  Map<Id,Customer_category__c> allExistingSalesCustomerCategoriesMap = new Map<Id,Customer_category__c>();
  Map<Id,Customer_category__c> allExistingInstallCustomerCategoriesMap = new Map<Id,Customer_category__c>();
  */
  // Collect all Account Ids
  Map<Id, Opportunity> accountIdList = new Map<Id, Opportunity>();
  
   
  if(Trigger.isInsert){
  	  //Customer_category__c custCatTemp;
  	  for(Opportunity opp : Trigger.new){
  	  	/*if(opp.isLocked__c)
  	  	{
  	  		return; 
  	  	}
  	 	if(!opp.isLocked__c && opp.CreatedDate.date() >= Date.valueOf(System.Label.Priority_Install_Release_Date) && opp.Last_customer_cat_info_update_source__c != null){
  	 		custCatTemp = new Customer_category__c();
  	 		oppsToCreateMasterCustCategoryMap.put(opp.Id,custCatTemp);
  	 	}*/
  	 	
  	 	accountIdList.put(opp.AccountId, opp);
      }
      /*
      prioHelper.createOrUpdateCustomerCategory(oppsToCreateMasterCustCategoryMap,Trigger.newMap);
      allCustomerCategories.addAll(oppsToCreateMasterCustCategoryMap.values());
      */
   }
   /*else{
		Opportunity tmpNewOpp;
  	    Opportunity tmpOldOpp;
  	  for(Opportunity opp : Trigger.new){
  	  	if(opp.isLocked__c)
  	  	{
  	  		return;
  	  	}
  	 	if(!opp.isLocked__c && opp.CreatedDate.date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)){
  	 		tmpOldOpp = Trigger.oldMap.get(opp.Id);
	  	 	tmpNewOpp = Trigger.newMap.get(opp.Id);
  	 		System.debug('---->'+tmpOldOpp);
  	 		System.debug('---->'+tmpNewOpp);
  	 		if((tmpOldOpp.Is_the_customers_boiler_working__c != tmpNewOpp.Is_the_customers_boiler_working__c ||
		           tmpOldOpp.Does_the_customer_have_hot_water__c != tmpNewOpp.Does_the_customer_have_hot_water__c ||
		           tmpOldOpp.Customer_have_any_other_form_of_HEAT__c != tmpNewOpp.Customer_have_any_other_form_of_HEAT__c ||
		           tmpOldOpp.Is_the_customer_vulnerable__c != tmpNewOpp.Is_the_customer_vulnerable__c ||
		           tmpOldOpp.Vulnerable_reason__c != tmpNewOpp.Vulnerable_reason__c ||
		           tmpOldOpp.Latest_customer_category__c != tmpNewOpp.Latest_customer_category__c ||
		           tmpOldOpp.Timeline_Options__c != tmpNewOpp.Timeline_Options__c ||
		           tmpOldOpp.Timeline_Reason__c != tmpNewOpp.Timeline_Reason__c ||
		           tmpOldOpp.Installation_opt_out_reason__c != tmpNewOpp.Installation_opt_out_reason__c ||
		           tmpOldOpp.Stage_object_type__c != tmpNewOpp.Stage_object_type__c ||
		           tmpOldOpp.Stage_object_id__c != tmpNewOpp.Stage_object_id__c ||
		           tmpOldOpp.Date_time_appointment_booked__c != tmpNewOpp.Date_time_appointment_booked__c || 
		           tmpOldOpp.Sales_visit_date_time__c != tmpNewOpp.Sales_visit_date_time__c ||
		           tmpOldOpp.BM_Quote_Download_into_SFDC_datetime__c != tmpNewOpp.BM_Quote_Download_into_SFDC_datetime__c ||
		           tmpOldOpp.Date_and_time_job_planned__c != tmpNewOpp.Date_and_time_job_planned__c || 
		           tmpOldOpp.Installation_Date_Time__c != tmpNewOpp.Installation_Date_Time__c ||
		           tmpOldOpp.Was_the_customer_s_boiler_working__c != tmpNewOpp.Was_the_customer_s_boiler_working__c )){
	           	
	           	    
	           
  	 		
  	 		oppIds.add(opp.Id);
  	 		} 
  	 	}
      }
  	
  	 Map<Id,Customer_category__c> sgcCustomerCategoryMap = new Map<Id,Customer_category__c>();
  	 Map<Id,Customer_category__c> salesCustomerCategoryMap = new Map<Id,Customer_category__c>();
  	 Map<Id,Customer_category__c> installationCustomerCategoryMap = new Map<Id,Customer_category__c>();
  	 
  	 
  	 System.debug('---->'+oppIds.size());
  	 
  	 if(oppIds.size()>0)
  	 {
  	 List<Customer_category__c> custCategories = [Select c.Vulnerable_reason__c, c.Type__c, c.Stage_object_type__c, c.Stage_object_id__c, 
  	                                                     c.Record_Status__c, c.RecordTypeId, c.Timeline_Options__c , c.Timeline_Reason__c , 
  	                                                     c.Opportunity__r.Id, c.Name, c.Milestone_start__c, c.Milestone_End__c, 
  	                                                     c.Master_Record_Version_Created_Datetime__c, c.Master_Record_Version_Created_By__c, 
  	                                                     c.Is_the_customer_vulnerable__c, c.Is_the_customer_s_boiler_working__c, 
  	                                                     c.IsDeleted, c.Id, c.Does_the_customer_have_hot_water__c, 
  	                                                     c.Date_and_time_job_planned__c, c.Customer_have_any_other_form_of_HEAT__c, 
  	                                                     c.Customer_category__c, c.BM_Quote_Download_into_SFDC_datetime__c , c.Opportunity__r.StageName  
  	                                                     From Customer_category__c c where c.Opportunity__c in :oppIds and c.isLocked__c = false];
  	                                                     
  	 for(Customer_category__c custCategory : custCategories){
  	 	
	  	 	
	  	 	
	  	 	   if(custCategory.Type__c == 'SGC'){
	  	 	   	  allExistingSGCCustomerCategoriesMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   	  
	  	 	   }else if(custCategory.Type__c == 'Sales'){
	  	 	   	  allExistingSalesCustomerCategoriesMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   	  
	  	 	   }else if(custCategory.Type__c == 'Installation'){
	  	 	   	  allExistingInstallCustomerCategoriesMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   }
	  	 	
	  	 	if(custCategory.Opportunity__r.StageName == 'Expired' || custCategory.Opportunity__r.StageName == 'Closed Lost' || custCategory.Opportunity__r.StageName == 'Closed Won'){
	  	 		custCategory.isLocked__c = true;
	  	 		custCategory.Record_Status__c = 'Closed';
	  	 		customerCategoriesToBeLocked.add(custCategory);
	  	 		tmpNewOpp.isLocked__c = true;
	  	 		continue;
  	 		}
	  	 	
	  	 	if(tmpNewOpp.pending_update_to_customer_category__c != true)
	  	 	 continue;
	  	 	    	  
	  	 	
	  	 	
	  	 	   if(custCategory.Type__c == 'SGC' && !sgcCustomerCategoryMap.containsKey(custCategory.Opportunity__r.Id) && (custCategory.Type__c == tmpNewOpp.Last_customer_cat_info_update_source__c)){
	  	 	   	  sgcCustomerCategoryMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   	  
	  	 	   }
	  	 	   
	  	 	   if(custCategory.Type__c == 'Sales' && !salesCustomerCategoryMap.containsKey(custCategory.Opportunity__r.Id) && (custCategory.Type__c == tmpNewOpp.Last_customer_cat_info_update_source__c)){
	  	 	   	  salesCustomerCategoryMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   	  
	  	 	   }
	  	 	   
	  	 	   if(custCategory.Type__c == 'Installation' && !installationCustomerCategoryMap.containsKey(custCategory.Opportunity__r.Id)&& (custCategory.Type__c == tmpNewOpp.Last_customer_cat_info_update_source__c)){
	  	 	   	  installationCustomerCategoryMap.put(custCategory.Opportunity__r.Id,custCategory);
	  	 	   	 
	  	 	   }
  	 	
  	 	
  	 }                                                    
  	
  	Customer_category__c tmpCustCat;
  	oppsToCreateMasterCustCategoryMap = new Map<Id,Customer_category__c>();
  	                                                     
  	for(Opportunity opp : Trigger.new){
  	 	if(opp.CreatedDate.date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)&& (opp.pending_update_to_customer_category__c == true)){
  	 		if(opp.Last_customer_cat_info_update_source__c == 'SGC' && !allExistingSGCCustomerCategoriesMap.containsKey(opp.Id)){
  	 			tmpCustCat = new Customer_category__c();
  	 			tmpCustCat.Version__c = 1;
  	 			oppsToCreateMasterCustCategoryMap.put(opp.id , tmpCustCat);
  	 		}else if(opp.Last_customer_cat_info_update_source__c == 'Sales' && !allExistingSalesCustomerCategoriesMap.containsKey(opp.Id)){
  	 			tmpCustCat = new Customer_category__c();
  	 			tmpCustCat.Version__c = 1;
  	 			oppsToCreateMasterCustCategoryMap.put(opp.id , tmpCustCat);
  	 		}else if(opp.Last_customer_cat_info_update_source__c == 'Installation' && !allExistingInstallCustomerCategoriesMap.containsKey(opp.Id)){
  	 			tmpCustCat = new Customer_category__c();
  	 			tmpCustCat.Version__c = 1;
  	 			oppsToCreateMasterCustCategoryMap.put(opp.id , tmpCustCat);
  	 		}
  	 	}
  	 }  
  	 prioHelper.createOrUpdateCustomerCategory(sgcCustomerCategoryMap , Trigger.newMap);
  	 prioHelper.createOrUpdateCustomerCategory(salesCustomerCategoryMap , Trigger.newMap);
  	 prioHelper.createOrUpdateCustomerCategory(installationCustomerCategoryMap , Trigger.newMap);
  	 prioHelper.createOrUpdateCustomerCategory(oppsToCreateMasterCustCategoryMap , Trigger.newMap);
  	 allCustomerCategories.addAll(sgcCustomerCategoryMap.values());
  	 allCustomerCategories.addAll(salesCustomerCategoryMap.values());
  	 allCustomerCategories.addAll(installationCustomerCategoryMap.values());
  	 allCustomerCategories.addAll(oppsToCreateMasterCustCategoryMap.values());
  	 for(Opportunity opp : Trigger.new){
  	   opp.pending_update_to_customer_category__c = false;
  	 }
  }
   
  	 try
  	 {
  	 	if(allCustomerCategories.size() > 0)
	  	 {
	  	 	upsert allCustomerCategories;
	  	 }
	  	if(customerCategoriesToBeLocked.size() > 0)
	  	{
	  		update customerCategoriesToBeLocked;
	  	}
	  	  
  	 }  
  	 catch(Exception ex)
  	 {
  	 	system.debug('----exception---'+ex.getMessage());
  	 }
  	 
  }	 */
  	 // Create landlord records
  	 
  	 if(accountIdList.size()>0)
  	 {
  	 	list<Opportunity> landlordLeadList = new list<Opportunity>();
  	 	for(Account a: [Select id , Landlord_Account__c from Account where id in:accountIdList.keyset()])
  	 	{
  	 		if(a.Landlord_Account__c)
  	 		landlordLeadList.add(accountIdList.get(a.Id));
  	 	}
  	 	
  	 	if(landlordLeadList.size()>0)
  	 	{
  	 		landlordHelper.createLandlordRecords(landlordLeadList);
  	 	}
  	 }                                               

}