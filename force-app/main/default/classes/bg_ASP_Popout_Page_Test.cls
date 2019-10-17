@isTest
private class bg_ASP_Popout_Page_Test {
	public static Id SetUpTestData() {
		/*
		 * create opportunity
		 */
		Opportunity CHILead = new Opportunity();
		CHILead.Name = 'Test CHI Lead';
		CHILead.LeadSource = 'Test';
		CHILead.Product_Interest__c = 'Test product';
		CHILead.StageName = 'new';
		Date closeDate = Date.today();
		closeDate.addDays(10);
		CHILead.CloseDate = closeDate;
		List<Id> chiLeadId = new List<Id>(bg_Helper_Methods.insertRecords(new Opportunity[] {CHILead}));
		
		/*
		 * create Case
		 */
		Case caseRecord = new Case();
		caseRecord.Opportunity__c = chiLeadId.get(0);
		List<Id> CaseId = new List<Id>(bg_Helper_Methods.insertRecords(new Case[] {caseRecord}));
		
		/*
		 * Create quotes
		 */
		BigMachines_Quote__c quote = new BigMachines_Quote__c();
		quote.Opportunity__c = chiLeadId.get(0);
		List<Id> quoteId = new List<Id>(bg_Helper_Methods.insertRecords(new BigMachines_Quote__c[] {quote}));
		
		/*
		 * Create job
		 */
		Job__c job = new Job__c();
		job.Quote__c = quoteId.get(0);
		List<Id> jobId = new List<Id>(bg_Helper_Methods.insertRecords(new Job__c[] {job}));
		
		/*
		 * Create asp
		 */
		ASP__c asp = new ASP__c();
		asp.Quote__c = quoteId.get(0);
		List<Id> aspId = new List<Id>(bg_Helper_Methods.insertRecords(new ASP__c[] {asp}));
		
		return aspId.get(0);
	}
	
	static testMethod void TestIdCreation() {
		PageReference pageRef = Page.bg_ASP_Spawn;
		
		Test.setCurrentPage(pageRef);
		ASP__c asp = [select Id, Quote__c from ASP__c where Id = :SetUpTestData()];
		ApexPages.StandardController sc = new ApexPages.StandardController(asp);
		bg_Javascript_Remote_Methods jrm = new bg_Javascript_Remote_Methods(sc);
		bg_Javascript_Remote_Methods.getOpportunity(asp.Id);
		bg_Javascript_Remote_Methods.getJobs(asp.Quote__c);
		bg_Javascript_Remote_Methods.getPaymentCollections(asp.Quote__c);
		bg_Javascript_Remote_Methods.getASPReferenceData(asp.Id);
	}
	
	static testMethod void TestJobPop() {
		PageReference pageRef = Page.bg_Diary_Spawn;
		
		Test.setCurrentPage(pageRef);
		SetUpTestData();
		Job__c job = [select Id from Job__c];
		ApexPages.StandardController sc = new ApexPages.StandardController(job);
		bg_Diary_Spawn_Extension dse = new bg_Diary_Spawn_Extension(sc);
		dse.getWeekBegining();
		dse.getDistrict();
	}
	
	static testMethod void TestCHILeadPop() {
		PageReference pageRef = Page.bg_CHILead_Spawn;
		
		Test.setCurrentPage(pageRef);
		SetUpTestData();
		Opportunity CHILead = [select Id from Opportunity];
		ApexPages.StandardController sc = new ApexPages.StandardController(CHILead);
		bg_Javascript_Remote_Methods jrm = new bg_Javascript_Remote_Methods(sc);
		bg_Javascript_Remote_Methods.getCHILeadReferenceData(CHILead.Id);
	}
	
	static testMethod void TestQuotePop() {
		PageReference pageRef = Page.bg_Quote_Spawn;
		
		Test.setCurrentPage(pageRef);
		SetUpTestData();
		BigMachines_Quote__c Quote = [select Id from BigMachines_Quote__c];
		ApexPages.StandardController sc = new ApexPages.StandardController(Quote);
		bg_Javascript_Remote_Methods jrm = new bg_Javascript_Remote_Methods(sc);
		bg_Javascript_Remote_Methods.getQuoteReferenceData(Quote.Id);
	}
	
	static testMethod void TestCaseDetails() {
		PageReference pageRef = Page.bg_Case_Details;
		Test.setCurrentPage(pageRef);
		SetUpTestData();
		
		Case caseRecord = [Select Id From Case limit 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
		
		bg_Case_Details_Extension cde = new bg_Case_Details_Extension(sc);
		cde.newASPRequestedItem();
		cde.getSobject();
		cde.getCase();
		cde.getASPRequestedItems();
		cde.save();
		cde.saveAndExit();
		cde.deleteASPRequestedItem();
	}
	
	static testMethod void TestMyNotes() {
		PageReference pageRef = Page.My_Notes;
		Test.setCurrentPage(pageRef);
		MyNotesController mnc = new MyNotesController();
		mnc.init();
		mnc.setNotes();
	}
	
	static testMethod void TestCustomConsoleChatterMarquee() {
		PageReference pageRef = Page.Custom_Console_Chatter_Marquee;
		Test.setCurrentPage(pageRef);
		ChatterIdLookup cil = new ChatterIdLookup();
		cil.getGroups();
		cil.edit();
		cil.setSelectedId();
	}
	
	static testMethod void TestAgentStats() {
		PageReference pageRef = Page.Custom_Console_Dashboards;
		Test.setCurrentPage(pageRef);
		ConsoleDBLookup cdbl = new ConsoleDBLookup();
		cdbl.getDashboards();
		cdbl.setSelectedId();
		cdbl.edit();
	}
}