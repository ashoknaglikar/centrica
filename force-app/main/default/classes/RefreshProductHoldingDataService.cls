global class RefreshProductHoldingDataService 
{
    /*Web service method called on Button "Refresh product holding data"
      Aurguments : Customer UCRN , Customer UCRNAgencyCode ,  Account object
      Result : Updates the recent information of Product holding related to account
      */
       
    //webService static ProductHolding__c refreshProductHoldingData(String CustomerUCRN , String CustomerUCRNAgencyCode , Account accountObj)
    //webService static ProductHolding__c refreshProductHoldingData(String CustomerUCRN , String CustomerUCRNAgencyCode , Account accountObj)
     
    webService static ProductHoldingData refreshProductHoldingData(String CustomerUCRN , String CustomerUCRNAgencyCode , Account accountObj)
    {
    	Workflow.WorkflowInfo WorkflowInfo = new Workflow.WorkflowInfo();
    	WorkflowInfo.CustomerUCRN = CustomerUCRN;
    	
    	Account relatedAccount = [select id , HouseName__c, BuildingNo__c, POBoxNumber__c, BillingPostalCode, ProductHoldingLastUpdated__c  from Account where id =: accountObj.Id];
    	
    	WorkflowInfo.Call = new Inbound_Call__c();
    	WorkflowInfo.Call.Billing_Zip__c = relatedAccount.BillingPostalCode;
    	
    	WorkflowInfo.HouseName = relatedAccount.HouseName__c;
        WorkflowInfo.HouseNumber = relatedAccount.BuildingNo__c;
        WorkflowInfo.PoBoxNumber = relatedAccount.POBoxNumber__c;
        
        System.debug('------------------------ refreshProductHoldingData:WorkflowInfo = ' + WorkflowInfo);
        
        return refreshProductHoldingData(WorkflowInfo, relatedAccount);
    }
    
    public static ProductHoldingData refreshProductHoldingData(Workflow.WorkflowInfo WorkflowInfo , Account accountObj)
    {
    	//System.SavePoint savPoint = Database.setSavepoint();
    	
    	//try
    	{
    		System.debug('-------------1 dml exhausted : '  + Limits.getDmlStatements());
	        //Workflow.WorkflowInfo WorkflowInfo = new Workflow.WorkflowInfo();
	        if(WorkflowInfo.ProductHoldingInfo == null)
	        {
	        	WorkflowInfo.ProductHoldingInfo = new ProductHolding__c();
	        	WorkflowInfo.ProductHoldingInfo.Status__c = 'Current';
	        }
	        WorkflowInfo.CurrentAccount = accountObj;
	        List<ProductHolding__c> productHolding = new List<ProductHolding__c>();
	        //get Product holding record by Account Id
	        if(accountObj != null && accountObj.id != null)
	        {
	        	productHolding = [Select p.QuoteDetails__c, ServiceCover__c, p.NumberOfPreviousQuotes__c, p.NumberOfExistingProperties__c, 
	                          p.ModelOfBoiler__c, p.MakeOfBoiler__c, p.LengthOfTimeProductHeld__c, p.Id, p.GasPaymentMethod__c, 
	                          p.GasMonthlySpend__c, p.GasIsCurrentCustomer__c, p.GasAnnualSpend__c, p.ExistingFinanceProducts__c, 
	                          p.ElectricityPaymentMethod__c, p.ElectricityMonthlySpend__c, p.ElectricityIsCurrentCustomer__c, 
	                          p.ElectricityAnnualSpend__c, p.DateOfLastCertification__c , p.BestTimeToCall__c , 
	                          p.IsPartTimeOrNightWorker__c , p.DateOfInstallation__c , p.IsParent__c , p.IsVulnerableCustomer__c , 
	                          p.IsExistingPropertiesHaveCentralHeating__c, p.IsCustomerHasLoftInsulation__c , 
	                          p.IsCustomerHasCavityWallInsulation__c , p.IsCurrentCustomerOfAnyProduct__c , p.DateOfPreviousQuotes__c , 
	                          p.CreditRating__c , p.CustomerTypeOrMarketingCode__c, p.BoilerBreakdownHistory__c, p.Account__c
	                          , p.Account__r.ProductHoldingLastUpdated__c, IsPetOwner__c,
	                          p.Account__r.BuildingNo__c, p.Account__r.HouseName__c, p.Account__r.POBoxNumber__c,
	                          p.GasAccount__c, p.ElectricityAccount__c, p.ServiceProducts__c,Status__c,
	                          (select id, Type__c, Name, MonthlySpend__c, ProductHolding__c, PaymentMethod__c from ProductHoldingAccounts__r)
	                          From ProductHolding__c p 
	                          
	                          where p.Account__c = :accountObj.Id and Status__c = 'Current'
	                          and  p.Account__r.CustomerUCRN__c = :WorkflowInfo.CustomerUCRN
	                          limit 1];
	            if(productHolding.size()>0) 
		        {
		            WorkflowInfo.ProductHoldingInfo = productHolding[0];
				}
				else
		        {
		            //create a new product holding against account if not available
		            //WorkflowInfo.ProductHoldingInfo = new ProductHolding__c();
		            //WorkflowInfo.ProductHoldingInfo.Status__c = 'Current';
		            WorkflowInfo.ProductHoldingInfo.Account__c = accountObj.id;
		        }
		         
	        }
    	
	        //Calling webservice to fetch the product holding updated data
	        //WorkflowInfo.ProductHoldingInfo = BGProductHoldingServiceHelper.getCustomerProductHoldingInformation(WorkflowInfo.ProductHoldingInfo, WorkflowInfo.CustomerUCRN, WorkflowInfo.CustomerUCRNAgencyCode);
	        
	        System.debug('-------------2 dml exhausted : '  + Limits.getDmlStatements());
	        
	        ProductHoldingData productData = BGProductHoldingServiceHelper.getCustomerProductHoldingInformation(WorkflowInfo);
	        system.debug('----------- refresh service productData = ' + productData);
	        WorkflowInfo.ProductHoldingInfo = productData.ProductHolding;
	        
	        if(WorkflowInfo.ProductHoldingInfo != null && accountObj != null && accountObj.id != null)
	        {
	            system.debug('----------- WorkflowInfo.CurrentAccount.Id---' +WorkflowInfo.CurrentAccount.Id);
	            //updating the Product holding to new data 
	            if(WorkflowInfo.ProductHoldingInfo.Account__c == null)
	            {
	            	WorkflowInfo.ProductHoldingInfo.Account__c = WorkflowInfo.CurrentAccount.Id;
	            }
	            upsert WorkflowInfo.ProductHoldingInfo;
	            system.debug('----------- WorkflowInfo.ProductHoldingInfo.Id---' +WorkflowInfo.ProductHoldingInfo);
	            
	            system.debug('----------- refresh service productData = ' + productData);
	            //delete old product holding account records
	            delete WorkflowInfo.ProductHoldingInfo.ProductHoldingAccounts__r;
	            
	            //populate parent id for new account records
	            for(ProductHoldingAccount__c accountData :productData.ProductHoldingAccounts)
	            {
	            	if(accountData.ProductHolding__c == null)
	            	{
	            		accountData.ProductHolding__c = WorkflowInfo.ProductHoldingInfo.id;
	            	}
	            }
	            
	            //upsert product holding account records 
	            upsert productData.ProductHoldingAccounts;
	                
	            
	            //Updating the Account ProductHoldingLastUpdated__c field to todays date
	            //Account relatedAccount = [select id , ProductHoldingLastUpdated__c from Account where id =: accountObj.Id];
	            accountObj.ProductHoldingLastUpdated__c = system.today();
	            update accountObj;
	            //WorkflowInfo.ShowProductHoldingInfo = true;
	            system.debug('----------- WorkflowInfo.ShowProductHoldingInfo = ' + WorkflowInfo.ShowProductHoldingInfo);
	            
	        }
	        
	        return productData;
    	}
    	//catch(Exception ex)
    	//{
    		//Database.rollback(savPoint);
    		//throw ex;
    	//}
    }
}