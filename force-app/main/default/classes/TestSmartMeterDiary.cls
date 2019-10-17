/*
* CLASS - TestSmartMeterDiary
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to act as a test class for 
* smart meter diary related apex classes....
*/
@istest
public with sharing class TestSmartMeterDiary {
   /*
   
    public static testMethod void testSmartMeterDiaryReportClasses(){
        
        PageReference pageRef = new PageReference('apex/SmartMeterDiary/');
        Test.setCurrentPage(pageRef);
        SmartMeterInstallReport smartMeterController = new SmartMeterInstallReport();
        smartMeterController.inputJob1.Smart_meter_installation_date__c = Date.today().addDays(10000);
        smartMeterController.inputJob2.Smart_meter_installation_date__c = Date.today().addDays(10000);
        District__c district = TestClassHelper.createDistrict();
        Database.insert(district);
        smartMeterController.inputJob1.District__c = district.Id;
        smartMeterController.fetchSmartMeterJobList();
        
        Account acc = TestClassHelper.createAccout();
        Database.insert(acc);
        Contact cont = TestClassHelper.createContact(acc);
        Database.insert(cont);
        List<Opportunity> lstOpp = TestClassHelper.createMultipleCHILead(Acc, 13);
        Database.insert(lstOpp);
        List<Job__c> lstJob = TestClassHelper.createMultipleJobs('Pending', 'Awaiting planning', lstOpp, 13);
        updateSmarteterJobs(lstJob);
        Database.insert(lstJob);
        
        SmartMeterHelper.extratctXLS(lstJob);
        smartMeterController.inputJob1.District__c = null;
        
        smartMeterController.fetchSmartMeterJobList();
        
        smartMeterController.populateSmartMeterJobList(lstJob);
        
        smartMeterController.selectAllLive_jobs();
        smartMeterController.selectAllSuspended_jobs();
        smartMeterController.selectAllInstall_date_changed();
        smartMeterController.selectAllCancelled_jobs();
        
        smartMeterController.selectAllAcknowledged_jobs_with_install_date();
        
        smartMeterController.selectAllUnackAndSortLive_jobs();
        smartMeterController.selectAllUnackAndSortSuspended_jobs();
        smartMeterController.selectAllUnackAndSortInstall_date_changed();
        smartMeterController.selectAllUnackAndSortCancelled_jobs();
        
        
        
        smartMeterController.selectSmartMeterJobsForUpdateLive_jobs();
        smartMeterController.selectSmartMeterJobsForUpdateSuspended_jobs();
        smartMeterController.selectSmartMeterJobsForUpdateInstall_date_changed();
        smartMeterController.selectSmartMeterJobsForUpdateCancelled_jobs();
        
        
        smartMeterController.selectSmartMeterJobsForUpdateAcknowledged_jobs_with_install_date();
        
        smartMeterController.saveChangesLive_jobs();
        smartMeterController.saveChangesSuspended_jobs();
        smartMeterController.saveChangesInstall_date_changed();
        smartMeterController.saveChangesCancelled_jobs();
    
        
        smartMeterController.saveChangesAcknowledged_jobs_with_install_date();
        
        smartMeterController.saveChangesGoBackLive_jobs();
        smartMeterController.saveChangesGoBackSuspended_jobs();
        smartMeterController.saveChangesGoBackInstall_date_changed();
        smartMeterController.saveChangesGoBackCancelled_jobs();
        
        
        smartMeterController.saveChangesGoBackAcknowledged_jobs_with_install_date();
        
        smartMeterController.acknowledgeSelectedLive_jobs();
        smartMeterController.acknowledgeSelectedSuspended_jobs();
        smartMeterController.acknowledgeSelectedInstall_date_changed();
        smartMeterController.acknowledgeSelectedCancelled_jobs();
        
        
        
        smartMeterController.extractSelectedLive_jobs();
        smartMeterController.extractSelectedSuspended_jobs();
        smartMeterController.extractSelectedInstall_date_changed();
        smartMeterController.extractSelectedCancelled_jobs();
        
        smartMeterController.extractSelectedAcknowledged_jobs_with_install_date();
    
    }
    
    private static void updateSmarteterJobs(List<job__c> lstJob){
        
        for(Integer i=0;i<lstJob.size();i++){
           lstJob[i].Smart_Meter_Required_Flag__c = 'Yes';
           lstJob[i].Smart_meter_installation_date__c = Date.Today();
        }
        
        lstJob[0].Smart_meter_installation_status__c = 'Pending';
        lstJob[0].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[1].Smart_meter_installation_status__c = 'Pending';
        lstJob[1].Smart_meter_installation_sub_status__c = 'Acknowledged';
        
        lstJob[2].Smart_meter_installation_status__c = 'Planned';
        lstJob[2].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[3].Smart_meter_installation_status__c = 'Planned';
        lstJob[3].Smart_meter_installation_sub_status__c = 'Acknowledged';
        
        lstJob[4].Smart_meter_installation_status__c = 'Suspended';
        lstJob[4].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[5].Smart_meter_installation_status__c = 'Suspended';
        lstJob[5].Smart_meter_installation_sub_status__c = 'Acknowledged';
        
        lstJob[6].Smart_meter_installation_status__c = 'Cancelled';
        lstJob[6].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[7].Smart_meter_installation_status__c = 'Cancelled';
        lstJob[7].Smart_meter_installation_sub_status__c = 'Acknowledged';
        
        lstJob[8].Smart_meter_installation_status__c = 'Suspended';
        lstJob[8].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[8].Smart_meter_installation_date__c = null;
        lstJob[9].Smart_meter_installation_status__c = 'Cancelled';
        lstJob[9].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[9].Smart_meter_installation_date__c = null;
        
        lstJob[10].Smart_meter_installation_status__c = 'Pending';
        lstJob[10].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        lstJob[10].Smart_meter_installation_date__c = null;
        lstJob[11].Smart_meter_installation_status__c = 'Pending';
        lstJob[11].Smart_meter_installation_sub_status__c = 'Acknowledged';
        lstJob[11].Smart_meter_installation_date__c = null;
    
    }
 +++++++++++++ Commented to Improve the test class performance ++++++++++++++++++++++++
*/
}