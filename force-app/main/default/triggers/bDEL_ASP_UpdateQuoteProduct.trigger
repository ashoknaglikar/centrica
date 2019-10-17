/*
Type Name: bDEL_ASP_UpdateQuoteProduct
Author: Cognizant
Change Date: 23/04/2010
Reason: This trigger updates the associted quote products with the ASP when the ASP is deleted.
		Also, it prevents the user from deleting the Submitted ASP.
*/
trigger bDEL_ASP_UpdateQuoteProduct on ASP__c(before delete) {
	
	List<Id> aspIdList = new List<ID>();
	List<ASP__c> aspList = new List<ASP__c>();
	List<Quote_Product__c> quoteProductsToDeleteList = new List<Quote_Product__c>();
	List<Quote_Product__c> quoteProductsToUpdateList = new List<Quote_Product__c>();
	
	System.debug('&&& STEP 1 ASP TRIGGER: ENTERED IN ASP TRIGGER');
	System.debug('&&& STEP 1.5 ASP TRIGGER: Trigger.Old'+ Trigger.Old);
	
	//POPULATE ASP LIST.
	for(integer i=0; i < Trigger.Old.size(); i++){
		aspIdList.add(Trigger.Old[i].Id);		
	}
	System.debug('&&& STEP 2 ASP TRIGGER: aspIdList'+aspIdList);
	
	aspList = [Select a.Submitted_Value__c, a.Status__c, a.Quote__c, a.Quote_ASP_Unsubmitted_Total__c,
	 		   a.Name, a.Approved_By__c, a.ASP_Date__c, 
	 		   (Select Id, IsDeleted, Name, BigMachines_Quote__c, Quantity__c, Sales_Price__c, 
	 		   Total_Price__c, EAN__c, Parent_Sequence_Number__c,Part_Number__c, Product_Code__c,
	 		   sequence_number__c, ASP_Action__c, ASP_Date__c,ASP_Impact__c, ASP_Number__c, ASP_Reason__c,
	 		   ASP_Removed__c, ASP_Require_Decompile__c, ASP_Status__c, ASP__c, Authorisation_Reason__c, 
	 		   Authorised_By__c From Quote_Products__r) From ASP__c a where a.Id in : aspIdList];
	
	System.debug('&&& STEP 3 ASP TRIGGER: aspList'+aspList);
	
	for(integer i=0; i < Trigger.Old.size(); i++){
		if(Trigger.Old[i].Status__c == 'Submitted'){
			Trigger.Old[i].addError('Submitted ASP cannot be deleted.');
		}		
	}
	
	for(ASP__c asp : aspList){
		System.debug('&&& STEP 4 ASP TRIGGER: INSIDE LAST LOOP: asp.Status__c: '+asp.Status__c);
		
		if(asp.Status__c == 'Entered'){
			System.debug('&&& STEP 5 ASP TRIGGER: asp.Quote_Products__r: '+asp.Quote_Products__r);
			for(Quote_Product__c quoteProduct : asp.Quote_Products__r){
				System.debug('&&& STEP 6 ASP TRIGGER: quoteProduct.ASP_Reason__c: '+quoteProduct.ASP_Reason__c);
				if(quoteProduct.ASP_Reason__c == 'Added'){
					quoteProductsToDeleteList.add(quoteProduct);
				}
				if(quoteProduct.ASP_Reason__c == 'Removed'){
					quoteProduct.ASP_Action__c = null;
					quoteProduct.ASP_Date__c = null;
					quoteProduct.ASP_Impact__c = 0;
					quoteProduct.ASP_Number__c = 0;
					quoteProduct.ASP_Reason__c = null;				
	 		   		quoteProduct.ASP_Removed__c = null;
	 		   		quoteProduct.ASP_Require_Decompile__c = false;
	 		   		quoteProduct.ASP_Status__c = null;
	 		   		quoteProduct.ASP__c = null;
					quoteProductsToUpdateList.add(quoteProduct);
				}				
			}						
		}		
	}
	
	System.debug('&&& STEP 7 ASP TRIGGER: quoteProductsToDeleteList: '+quoteProductsToDeleteList);
	System.debug('&&& STEP 8 ASP TRIGGER: quoteProductsToUpdateList: '+quoteProductsToUpdateList);
	
	if(quoteProductsToDeleteList.size() > 0){
		try{
			System.debug('&&& STEP 9 ASP TRIGGER: INSIDE DELETE');
			Database.delete(quoteProductsToDeleteList);
			
		}catch(Exception ex){
			System.debug('Exception: Error during delete quoteproduct: '+ex);
		}		
	}
	
	if(quoteProductsToUpdateList.size() > 0){
		try{
			System.debug('&&& STEP 10 ASP TRIGGER: INSIDE UPDATE');
			Database.update(quoteProductsToUpdateList);
		}catch(Exception ex){
			System.debug('Exception: Error during update quoteproduct: '+ex);
		}		
	}
}