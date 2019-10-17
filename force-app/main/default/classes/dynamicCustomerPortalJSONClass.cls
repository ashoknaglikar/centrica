global class dynamicCustomerPortalJSONClass {
    public String CHILeadId;
	public String CustomerName;
	public string title;
	public string firstName;
	public string lastName;
	
	public string street;
	public string city;
	public string postCode;
	public string county;


	public String CHILeadNumber;
	public String Address;
	public String Email;
	public string productInterest;
	public list<string> customerSpecificMessage;
	public integer errorCode;
	public string errorDiscription;
	
	public String StageId;
	public String StageDecription;
	public integer journey;
	public string recordId ;
	
	Public boolean complexJob;
	Public integer minimumDay;
	public integer maximumDay;
	Public String quoteId;
	
	Public boolean showVoucherCode;
	
	public boolean aprChange;
	
	public list<customerPortalEventClass> evenList;
	
	public list<keyValue> keyInformationList; 
	
	public list<financeClass> financeRecords ;
    public list<customerPortalQuoteJson.offer>  leadOffers = new List<customerPortalQuoteJson.offer>();
	public list<ContentVersion> customerDocs ;
	
	public class keyValue{
	    public string key;
	    public string value;
	    
	    public keyValue(string key, string value)
	    {
	        this.key = key;
	        this.value = value;
	    }
	}
    /*
	public class attachementClass{
		public string docName;
		public attachment attachementRecord;
		public string docType;
	}*/
	
	public class financeClass {
	    public decimal quoteValue;
	    public decimal loan;
	    public decimal deposit;
	    public decimal rate;
	    public decimal monthly;
	    public decimal totalRepayable;
	    public decimal duration;
	    public decimal interest;
	    public string status;
	    public  financeClass ( Finance_Application__c f, Opportunity o)
	    {
	        try{
	        this.quoteValue = 	f.Job_Total__c;
	        this.loan = f.Cash_Price__c;
	        this.deposit = o.Portal_Deposit__c;
	        this.rate = f.Interest_Rate__c;
	        
	        this.monthly= f.Monthly_Repayments__c;
	      
	        this.duration = decimal.valueof(f.Payment_Options__c.split('-')[0].trim());
	        if(f.Interest_Rate__c != 0)
	        this.totalRepayable = monthly*duration;
	        else
	        this.totalRepayable  = f.Cash_Price__c;
	        
            this.interest  = totalRepayable - loan;
            
            this.status = CustomerPortalFinanceRestHelper.statusHelper(f);
            
	        }catch (Exception e)
	        {
    	            system.debug('Excetion while adding fiannce Record'+e.getMessage());
	        }
	        
	    }
	        
    }
	

}