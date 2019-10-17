public class TestMyLeadExtension {

static testMethod void testMyLeadExtension () {
	
	PageReference pageRef = new PageReference('/apex/PCAnywhere?enquiryInterviewId=10800P');
	Test.setCurrentPage(pageRef);
	
	myLeadExtension leadExtend = new myLeadExtension();
	
	Lead lead = leadExtend.getLead();
	
	lead.LastName='Waters';
	lead.FirstName='Roger';
	
	lead.Street = '2 Talbot Crescent';
	lead.PostalCode = 'LS8 1AL';
	lead.City = 'Leeds';
	lead.State = 'West Yorkshire';
	lead.Country = 'UK';
	
	leadExtend.saveEnquiry();
	
	Lead updLead = [Select l.Firefly_Id__c from Lead l where id=:lead.id];
	
	System.assertEquals('10800P',updLead.Firefly_Id__c);
	
	
}
}