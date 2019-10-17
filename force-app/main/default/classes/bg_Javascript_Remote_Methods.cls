global with sharing class bg_Javascript_Remote_Methods {
    public bg_Javascript_Remote_Methods(ApexPages.StandardController controller) {
    }
	
	global static Opportunity getOpportunity(String OpportunityId) {
		List<Opportunity> Opportunity = [Select O.Id, O.Name from Opportunity O Where O.Id = :OpportunityId];
        if(Opportunity.size() == 1) {
			return Opportunity.get(0);
		}
		return new Opportunity();
    }
	
	@RemoteAction
    global static Set<Job__c> getJobs(String QuoteId) {
		List<Job__c> jobs = [select Id, Name From Job__c Where Quote__c = :QuoteId And Is_Remedial_Job__c = false And Is_Downtime_Job__c = false And Split_Job__c = false limit 1];
		Set<Job__c> jobIds = new Set<Job__c>();
		for(Job__c job : jobs) {
			if(!jobIds.contains(job)) {
				jobIds.add(job);
			}
		}
        return jobIds;
    }
	
	@RemoteAction
    global static Set<Payment_Collection__c> getPaymentCollections(String QuoteId) {
		List<Job__c> jobs = [select Id, Name From Job__c Where Quote__c = :QuoteId And Is_Remedial_Job__c = false And Is_Downtime_Job__c = false And Split_Job__c = false limit 1];
		Set<Id> jobIds = new Set<Id>();
		for(Job__c job : jobs) {
			if(!jobIds.contains(job.Id)) {
				jobIds.add(job.Id);
			}
		}
		List<Payment_Collection__c> paymentCollections = [Select Id, Name From Payment_Collection__c Where Job__c in :jobIds];
		Set<Payment_Collection__c> paymentCollectionIds = new Set<Payment_Collection__c>();
		for(Payment_Collection__c paymentCollection : paymentCollections) {
			if(!paymentCollectionIds.contains(paymentCollection)) {
				paymentCollectionIds.add(paymentCollection);
			}
		}
        return paymentCollectionIds;
    }
	
	@RemoteAction
    global static Job__c getJob(String QuoteId) {
		List<Job__c> jobs = [select Id, Name From Job__c Where Quote__c = :QuoteId And Is_Remedial_Job__c = false And Is_Downtime_Job__c = false And Split_Job__c = false limit 1];
		if(jobs.size() == 1) {
			return jobs.get(0);
		}
        return new Job__c();
    }
	
	@RemoteAction
    global static Set<Payment_Collection__c> getPaymentCollectionsUpdate(String JobId) {
		List<Payment_Collection__c> paymentCollections = [Select Id, Name From Payment_Collection__c Where Job__c = :JobId];
		Set<Payment_Collection__c> paymentCollectionIds = new Set<Payment_Collection__c>();
		for(Payment_Collection__c paymentCollection : paymentCollections) {
			if(!paymentCollectionIds.contains(paymentCollection)) {
				paymentCollectionIds.add(paymentCollection);
			}
		}
		if(paymentCollectionIds.size() != 0) {
			return paymentCollectionIds;
		}
		return paymentCollectionIds;
    }
	
	@RemoteAction
    global static ASP__c getASP(String QuoteId) {
		List<ASP__c> ASPs = [select Id, Name From ASP__c Where Quote__c = :QuoteId limit 1];
		if(ASPs.size() == 1) {
			return ASPs.get(0);
		}
        return new ASP__c();
    }
	
	@RemoteAction
    global static bg_Javascript_Remote_Methods.ReferenceData getCHILeadReferenceData(String CHILeadId) {
		ReferenceData referenceData = new ReferenceData();
		referenceData.CHILead = [Select O.Id, O.Name, ( Select Name from BigMachines_Quotes__r) from Opportunity O Where O.Id = :CHILeadId];
			
		referenceData.Quote = referenceData.CHILead.BigMachines_Quotes__r.size() != 0? referenceData.CHILead.BigMachines_Quotes__r.get(0):new BigMachines_Quote__c();
		
		referenceData.Job = referenceData.Quote.Id != null?bg_Javascript_Remote_Methods.getJob(referenceData.Quote.Id): new Job__c();
		referenceData.JobPayment = referenceData.Job.Id != null?bg_Javascript_Remote_Methods.getPaymentCollectionsUpdate(referenceData.Job.Id): new Set<Payment_Collection__c>();
		referenceData.ASP = referenceData.Quote.Id != null?bg_Javascript_Remote_Methods.getASP(referenceData.Quote.Id): new ASP__c();
		return referenceData;
	}
	
	@RemoteAction
    global static bg_Javascript_Remote_Methods.ReferenceData getQuoteReferenceData(String QuoteId) {
		ReferenceData referenceData = new ReferenceData();
		referenceData.Quote = [Select Id, Opportunity__c From BigMachines_Quote__c Where Id =:QuoteId];
		referenceData.Job = referenceData.Quote.Id != null?bg_Javascript_Remote_Methods.getJob(referenceData.Quote.Id): new Job__c();
		referenceData.JobPayment = referenceData.Job.Id != null?bg_Javascript_Remote_Methods.getPaymentCollectionsUpdate(referenceData.Job.Id):new Set<Payment_Collection__c>();
		referenceData.ASP = referenceData.Quote.Id != null?bg_Javascript_Remote_Methods.getASP(referenceData.Quote.Id): new ASP__c();
		referenceData.CHILead = referenceData.Quote.Opportunity__c != null?bg_Javascript_Remote_Methods.getOpportunity(referenceData.Quote.Opportunity__c): new Opportunity();
		return referenceData;
	}
	
	@RemoteAction
    global static bg_Javascript_Remote_Methods.ReferenceData getASPReferenceData(String ASPId) {
		ReferenceData referenceData = new ReferenceData();
		referenceData.ASP = [Select Id, Name, Quote__c from ASP__c Where Id = :ASPId];
		referenceData.Quote = referenceData.ASP.Quote__c != null?bg_Javascript_Remote_Methods.getQuote(referenceData.ASP.Quote__c): new BigMachines_Quote__c();
		referenceData.Job = referenceData.Quote.Id != null?bg_Javascript_Remote_Methods.getJob(referenceData.Quote.Id): new Job__c();
		referenceData.JobPayment = referenceData.Job.Id != null?bg_Javascript_Remote_Methods.getPaymentCollectionsUpdate(referenceData.Job.Id):new Set<Payment_Collection__c>();
		referenceData.CHILead = referenceData.Quote.Opportunity__c != null?bg_Javascript_Remote_Methods.getOpportunity(referenceData.Quote.Opportunity__c): new Opportunity();
		return referenceData;
	}
	
	global static BigMachines_Quote__c getQuote(String QuoteId) {
		List<BigMachines_Quote__c> Quote = [Select B.Id, B.Name, B.Opportunity__c from BigMachines_Quote__c B Where B.Id = :QuoteId AND B.Is_Primary__c = true];
        if(Quote.size() == 1) {
			return Quote.get(0);
		}
		return new BigMachines_Quote__c();
    }
	
	global class ReferenceData {
		BigMachines_Quote__c Quote {get; Set;}
		Job__c Job {get; Set;}
		Set<Payment_Collection__c> JobPayment {get; Set;}
		ASP__c ASP {get; Set;}
		Opportunity CHILead {get; Set;}
	}
}