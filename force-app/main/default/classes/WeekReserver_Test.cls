@isTest
public class WeekReserver_Test {
	
	
	static testmethod void testScenarioWithBlank()
	{
		PageReference pageRef = Page.WeekReserver;
		WeekReserver wkRs = new WeekReserver();
		wkRs.refersh();
		wkRs.saveWeeks();
		wkRs.openDiary();
		wkRs.getAreaItems();
		
	}
	
	static testmethod void testScenarioWithNonBlank()
	{
		District__c  dist = TestClassHelper.createDistrict();
		insert dist;
		
		Employee__c em = TestClassHelper.createEmployee();
		em.District__c = dist.Id;
		em.Works_Anywhere_in_District__c =true;
		insert em;
		
		Week__c week1 = TestClassHelper.createWeek(em.Id);
		week1.Week_Commencing__c = System.today().toStartOfWeek();
		
				
		Week__c week2 = TestClassHelper.createWeek(em.Id);
		week2.Locking_Category__c = 'Vulnerable';
		week2.Release_Date__c = System.today().addDays(7);
		week2.Week_Commencing__c = System.today().toStartOfWeek();
		
		insert (new list <Week__c>{week1,week2});
		
		PageReference pageRef = Page.WeekReserver;
		pageRef.getParameters().put('area', dist.Id);
		pageRef.getParameters().put('wkComm', system.today().format());
    	
    	test.setCurrentPage(pageRef);
		WeekReserver wkRs = new WeekReserver();
		
		wkRs.saveWeeks();
		//wkRs.confirm =true;
		for(Week__c w : wkRs.unReservedWeeks)
		{
			//w.Release_Date__c = system.today().addDays(-3);
			w.Locking_Category__c = 'Vulnerable';
		}
		wkRs.saveWeeks();
		for(Week__c w : wkRs.unReservedWeeks)
		{
			w.Release_Date__c = system.today().addDays(-3);
			w.Locking_Category__c = 'Vulnerable';
		}
		wkRs.saveWeeks();
		for(Week__c w : wkRs.unReservedWeeks)
		{
			w.Release_Date__c = system.today().addDays(3);
			w.Locking_Category__c = 'Vulnerable';
		}
		wkRs.saveWeeks();
		for(Week__c w : wkRs.reserevedWeeks)
		{
			
			w.Release_Date__c=null;
		}
		wkRs.saveWeeks();
		
		for(Week__c w : wkRs.reserevedWeeks)
		{
			
			w.Release_Date__c=system.today().addDays(-3);
		}
		wkRs.saveWeeks();
		
		for(Week__c w : wkRs.reserevedWeeks)
		{
			w.Locking_Category__c =null;
			w.Release_Date__c=null;
		}
		wkRs.saveWeeks();
		
		wkRs.wk.Week_Commencing__c = system.today().addDays(7);
		wkRs.refersh();
		wkRs.openDiary();
		
		
	}
		
	

}