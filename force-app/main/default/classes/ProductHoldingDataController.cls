//Controller class for the inline VF page on Account 
//to show the Product holding data on account detail page
public with sharing class ProductHoldingDataController {
	
    public ProductHolding__c  productHolding {get; set;}
    public Boolean IsError {get; set;}
    public Boolean ProductHoldingEnabled {get; set;}
    public List<ProductHoldingAccount__c> ProductHoldingAccounts {get; set;} 
    
    public ProductHoldingDataController(ApexPages.StandardController controller) 
    {
		String accountId = ApexPages.currentPage().getParameters().get('Id');
		productHolding = new ProductHolding__c();
		ProductHoldingAccounts = new List<ProductHoldingAccount__c>();
		
		ProductHoldingEnabled = false;
		
		//get Product holding record by Account Id
		IsError = false;
		try
		{
			User usr = [select id, EnabledForProductHolding__c from User where id = :USerInfo.getUserID() limit 1];
	        if(usr.EnabledForProductHolding__c == true)
	        {
	        	ProductHoldingEnabled = true;
	        }
	        
			productHolding = [Select p.QuoteDetails__c, ServiceCover__c,p.NumberOfPreviousQuotes__c, p.NumberOfExistingProperties__c, 
						  p.ModelOfBoiler__c, p.MakeOfBoiler__c, p.LengthOfTimeProductHeld__c, p.Id, p.GasPaymentMethod__c, 
						  p.GasMonthlySpend__c, p.GasIsCurrentCustomer__c, p.GasAnnualSpend__c, p.ExistingFinanceProducts__c, 
						  p.ElectricityPaymentMethod__c, p.ElectricityMonthlySpend__c, p.ElectricityIsCurrentCustomer__c, 
						  p.ElectricityAnnualSpend__c, p.DateOfLastCertification__c , p.BestTimeToCall__c , 
						  p.IsPartTimeOrNightWorker__c , p.DateOfInstallation__c , p.IsParent__c , p.IsVulnerableCustomer__c , 
						  p.IsExistingPropertiesHaveCentralHeating__c, p.IsCustomerHasLoftInsulation__c , 
						  p.IsCustomerHasCavityWallInsulation__c , p.IsCurrentCustomerOfAnyProduct__c , 
						  p.DateOfPreviousQuotes__c , p.CreditRating__c , p.CustomerTypeOrMarketingCode__c, 
						  p.BoilerBreakdownHistory__c, p.Account__c, IsPetOwner__c , Status__c,
						  p.GasAccount__c, p.ElectricityAccount__c, p.ServiceProducts__c,
						  (select id, Type__c, Name, MonthlySpend__c, ProductHolding__c, PaymentMethod__c from ProductHoldingAccounts__r)
						  From ProductHolding__c p where p.Account__c = :accountId and Status__c = 'Current' limit 1];
			if(productHolding == null)
			{
				IsError = true;
			}
			else
			{
				ProductHoldingAccounts = productHolding.ProductHoldingAccounts__r;
			}
		}
		catch(Exception ex)
		{
			IsError = true;
		}
    }
    
    static testMethod void test_ProductHoldingDataController() 
    {
    	List<Opportunity> opportunityList=new List<Opportunity>();
        List<Contact> contactList = new List<Contact>();
        List<Appointment__c> appointmentList=new List<Appointment__c>();
        //NewCustomerWorkflow controller= new NewCustomerWorkflow();
        
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c limit 1];

        Account account=new Account();
            account.Name='Test Account';
            account.Number_of_Bedrooms__c=1;
            account.Gas_Supply_At_Address__c=true;
            account.Current_Heating_System__c=true;
            account.BillingStreet='Test Street';
            account.BillingState='Test State';
            account.BillingPostalCode='441111'; 
            account.BillingCountry='Test Country';
            account.BillingCity='Test City';
            account.Water_Hardness__c=0;
        insert account;
        
        ProductHolding__c p = new ProductHolding__c(ServiceCover__c = 'test', Account__c = account.id);
        insert p;
        
		PageReference pageRef = Page.ProductHoldingData;
		pageRef.getParameters().put('id',p.id);
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(p);
		ProductHoldingDataController pController = new ProductHoldingDataController(stdController);
    }
    
}