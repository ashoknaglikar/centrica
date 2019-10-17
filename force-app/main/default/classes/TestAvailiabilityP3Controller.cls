public class TestAvailiabilityP3Controller {

	public static testMethod void testAvailiabilityP2Controller(){
	
		//Set page URL for the test method		
	    PageReference pageRef = new PageReference('apex/availability3?var_date=2008-09-24&var_period=AM&var_bookedAppId=006R0000002B5b4&var_cancelledAppId=006R0000002B5b4&var_result=4&var_OpptyId=006R0000002B5b4&var_Source=SF');
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController  std  = new ApexPages.StandardController(new Appointment__c());
		
		AvailabilityP3Controller p3 = new AvailabilityP3Controller(std);
		
		system.assertEquals('24-9-2008',p3.getdate());
		system.assertEquals('AM',p3.getperiod());
		system.assertEquals('006R0000002B5b4',p3.getbookedAppId());
		system.assertEquals('006R0000002B5b4',p3.getcancelledApp()); 
		system.assertEquals(true,p3.getshowCancelled1());
		system.assertEquals(false,p3.getshowCancelled2());
		system.assertEquals(true,p3.getshowSuccess());
		system.assertEquals(true,p3.getshowButton());
		system.assertEquals(false,p3.getshowFailure1());
		system.assertEquals(false,p3.getshowFailure2());
		system.assertEquals(false,p3.getshowFailure3());
		system.assertEquals(false,p3.getshowFailure4());	
		String nextPage = p3.onClickReturnCHILead().getUrl(); 
		System.assertEquals('/006R0000002B5b4', nextpage);
		
	
	}
}