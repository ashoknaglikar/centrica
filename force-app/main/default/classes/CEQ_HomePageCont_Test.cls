@istest(SeeAllData=true)
public class CEQ_HomePageCont_Test {

/* 
+++++++++++++++++ commented code to improve the performance ++++++++++++++++++++++++++

 static testmethod void method1()
 {
 	pagereference ceqhome = new pagereference('/apex/CEQ_HomePage');
 	test.setCurrentPage(ceqhome);
 	CEQ_HomePageCont CEQ_inst = new CEQ_HomePageCont();
 	CEQ_inst.getRegionList();
 	CEQ_inst.getdistrictList();
 	
 	
 	CEQ_inst.showCustomer_Large();
 	CEQ_inst.showInstallation_Large();
 	CEQ_inst.showSales_Large();
 	CEQ_inst.showASPS_Large();
 	CEQ_inst.showCases_Large();
 	CEQ_inst.showFailedJobs_Large();
 	
 
 	
 	test.starttest();
 	
 	CEQ_inst.fetchASPs();
 	CEQ_inst.fetchCases();
 	CEQ_inst.fetchFOD();
 	CEQ_inst.refreshData();
 	
 	CEQ_inst.job.Customer_Journey_First_Update__c = system.today().adddays(-20);
 	CEQ_inst.job.BGNE_Install_Date__c = system.today();
 	
 	CEQ_inst.region= [Select Name from Region__c where Type__c ='Installation' limit 1].Name;
 	CEQ_inst.fetchASPs();
 	CEQ_inst.fetchCases();
 	CEQ_inst.fetchFOD();
 	CEQ_inst.refreshData();
 	CEQ_inst.district= [Select id from District__c where Type__c ='Installation' limit 1].Id;
 	CEQ_inst.fetchASPs();
 	CEQ_inst.fetchCases();
 	CEQ_inst.fetchFOD();
 	CEQ_inst.refreshData();
 	
 	test.stoptest();
 	
 	CEQ_inst.job.Customer_Journey_First_Update__c =null;
 	CEQ_inst.checkDates();
 	CEQ_inst.job.Customer_Journey_First_Update__c =CEQ_inst.job.BGNE_Install_Date__c.adddays(1);
 	CEQ_inst.checkDates();
 	CEQ_inst.job.Customer_Journey_First_Update__c =CEQ_inst.job.BGNE_Install_Date__c.adddays(300);
 	CEQ_inst.checkDates();
 	//CEQ_inst.
 }	
 
 +++++++++++++++++ commented code to improve the performance ++++++++++++++++++++++++++
 */

}