/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

/*
Updated complete test class for Priority Installation CR - 04/07/2012
*/

@isTest
private class updateIncompleteCommisionRptCount_Test {

    static Postcode_Sector__c testPostCode;
    static Account testAccount;
    static Opportunity testOpp;
    static Job__c testJob;
    static Commissioning_Report__c testReport;
    static Appliance_at_Risk__c testAppliance;
    
    static void createData()
    {
        String testDistrict = '';
        testPostCode = [Select Sub_Patch__r.District__c, name From Postcode_Sector__c where type__c = 'Installation' limit 1];
        
        Supplier__c supp=TestClassHelper.createSupplier();
        supp.Name='DK LECS LIMITED';
        insert supp;
         
        Employee__c emp = TestClassHelper.createEmployee();
       // emp.Salesforce_User__c=userinfo.getuserid();
        emp.Supplier__c=supp.id;
        emp.Role_Type__c='Electrician';
        emp.First_Name__c='Electrician';
        insert emp;
                 
        testAccount = new Account();
        testAccount.name = 'test1';
        testAccount.BillingPostalCode = testPostCode.name + '02';
        testAccount.BillingStreet = 'test address';
        insert testAccount;
        
        testOpp = new Opportunity();
        testOpp.Name = 'test2';
        testOpp.AccountID = testAccount.ID;
        testOpp.LeadSource = 'Engineer';
        testOpp.Referral_Employee__c = [select id from Employee__c limit 1].ID;
        testOpp.Product_Interest__c = 'Solar';
        testOpp.StageName = 'Active';
        testOpp.CloseDate = System.today().AddDays(1);      
        insert testOpp; 
        
        testJob = new Job__c();
        testJob.CHI_Lead__c = testOpp.ID;
        testJob.Suspend_Job__c = True;
        testJob.Suspension_Reason__c = 'Test';
        testJob.Suspension_Reason_List__c ='Test';
        testJob.Cancel_Merchant_Orders__c = 'Test';
        insert testJob;
        
        testJob = [Select id from Job__c where id =: testjob.id];
        testJob.Suspend_Job__c = False;
        //update testJob;
        
        testReport = new Commissioning_Report__c();
        String GasRecordTypeID = [select id from Recordtype where developername = 'Gas_Installation_Works'].ID;
        testReport.RecordTypeId = GasRecordTypeID;
        testReport.Job_Number__c = testJob.ID;
        testReport.Job_Special_ID__c =  'test'+system.today().year();
        testReport.Number_of_gas_appliances__c = 1;
        testReport.Electrical_Employee__c=emp.id;
        insert testReport;

        
        testAppliance = new Appliance_at_Risk__c();
        testAppliance.Appliance_Type__c = 'Fire';
        testAppliance.Compliance_Report__c = testReport.ID;
        testAppliance.Work_Description__c='Visual Check Only';
        insert testAppliance;
        testReport.GD_Claims_of_conformity__c='Completed- Electronically';
        update testAppliance;
 
  }
    
    static testmethod void testStatus()
    {
        createData();
        cls_IsRun.isJobCompletion = false;
        testReport.Status__c = 'Completed'; 
        testReport.PDSA_Do_you_find_it_useful__c='Yes';
        testReport.PDSA_Have_any_risks_been_missed__c='Yes';
        testReport.PDSA_completed_correctly_fully__c='Yes';
        testReport.PDSA_document_left_on_site__c='Yes';
        testReport.PDSA_Quality_Score__c='1';
        update testReport;
        
        
    }

}