public with sharing class bg_Record_Builder{
	public static Case createCaseForCreatingASP(String Status, String Function, String Definition, String MaterialReturnInfo, String Reason, Decimal ChargeToCustomer, Id OpportunityId) {
		Case caseRecord = new Case();
		caseRecord.Status = Status;
		caseRecord.Function__c = Function;
		caseRecord.Definition__c = Definition;
		caseRecord.Material_Return_Info__c = MaterialReturnInfo;
		caseRecord.Reason__c = Reason;
		caseRecord.Charge_to_Customer__c = ChargeToCustomer;
		caseRecord.Opportunity__c = OpportunityId;
		return caseRecord;
	}
	
	public static void insertCaseForCreatingASP(String Status, String Function, String Definition, String MaterialReturnInfo, String Reason, Decimal ChargeToCustomer, Id OpportunityId) {
		insert createCaseForCreatingASP(Status, Function, Definition, MaterialReturnInfo, Reason, ChargeToCustomer, OpportunityId);
	}
	
	public static Employee__c createMinimumEmployee(String EmployeeNumber) {
		Employee__c employee = new Employee__c();
		employee.Employee_Number__c = EmployeeNumber;
		return employee;
	}
	
	public static void insertMinimumEmployee(String EmployeeNumber) {
		insert createMinimumEmployee(EmployeeNumber);
	}
	
	public static Opportunity createCaseAndQuoteRelatedOpportunity(String LeadSource, Id ReferalEmployee, String ProductInterest, String Name, String StageName, Date CloseDate) {
		Opportunity opportunity = new opportunity();
		opportunity.LeadSource = LeadSource; //custom validation
		opportunity.Referral_Employee__c = ReferalEmployee; //custom validation
		opportunity.Product_Interest__c = ProductInterest; //custom validation
		opportunity.Name = Name; //Required
		opportunity.StageName = StageName; //Required
		opportunity.CloseDate = CloseDate; //Required
		return opportunity;
	}
	
	public static void insertCaseAndQuoteRelatedOpportunity(String LeadSource, Id ReferalEmployee, String ProductInterest, String Name, String StageName, Date CloseDate) {
		insert createCaseAndQuoteRelatedOpportunity(LeadSource, ReferalEmployee, ProductInterest, Name, StageName, CloseDate);
	}
	
	public static BigMachines_Quote__c createMinimumBigMachinesQuote(String Name, Boolean isPrimary, Id OpportunityId) {
		BigMachines_Quote__c quote = new BigMachines_Quote__c();
		quote.Name = Name;
		quote.Is_Primary__c = isPrimary;
		quote.Opportunity__c = OpportunityId;
		return quote;
	}
	
	public static void insertMinimumBigMachinesQuote(String Name, Boolean isPrimary, Id OpportunityId) {
		insert createMinimumBigMachinesQuote(Name, isPrimary, OpportunityId);
	}
	
}