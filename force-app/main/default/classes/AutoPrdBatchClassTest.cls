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
@isTest
private class AutoPrdBatchClassTest {
    static Account acc;
    static Contact con;
    static List<opportunity> oppList;
    static  Finance_Product__c fp;
    static Finance_Application__c fa;
    static List<BigMachines_Quote__c> bmlist;
    static BGS_Payment__c bPayment;
    static List<job__c> joblist;
    static List<Attachment> attlist;
    
    static void createdata()
    {
        acc = TestclassHelper.createAccout();
        insert acc;
    
        con = TestclassHelper.createContact(acc);
        insert con;
    
        opportunity opp = TestclassHelper.createCHILead(acc);
        opportunity opp1 = TestclassHelper.createCHILead(acc);
        opportunity opp2 = TestclassHelper.createCHILead(acc);
        oppList = new List<opportunity>{opp,opp1,opp2};
        insert opplist;
         
        fp = financeApplicationController_Test.createFProduct();
        fa= financeApplicationController_Test.createFApplication();
        fa.Finance_Product__c = fp.id;
        fa.CHI_Lead__c = opp.id;
        fa.application_status__c = 'Parked';
        fa.Finance_Options__c = '0% - 2 Years';
        insert fa;
         
        BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opplist[0]);
        bmQuote.BigMachines_Transaction_Id__c = '1234554321';
        bmQuote.POC_Payment_Method__c = 'Finance';
        bmQuote.Is_Electronically_Signed__c = true;
        bmQuote.Is_Primary__c = true;
        
        BigMachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opplist[1]);
        bmQuote1.Job_Type__c ='13';
        bmQuote1.Is_Primary__c = true;
        
        BigMachines_Quote__c bmQuoteCash = TestClassHelper.createBMQuote(opplist[2]);
        bmQuoteCash.BigMachines_Transaction_Id__c = '1234554322';
        bmQuoteCash.POC_Payment_Method__c = 'Cash';
        bmQuoteCash.Is_Electronically_Signed__c = true;
        bmQuoteCash.Is_Primary__c = true;
        bmQuoteCash.FaultPDF__c=false;
        
        insert bmQuote;
        insert bmQuote1;
        insert bmQuoteCash;
        
       /* bmlist= new List<BigMachines_Quote__c>{bmQuote,bmQuote1,bmQuoteCash};
        insert bmlist;*/
        
        bPayment = TestClassHelper.createBGSPayment(opplist[2].Id, 'Credit Card', null);
        bPayment.Payment_Type__c = 'Deposit';
        bPayment.Payment_Method__c = 'Debit Card';
        insert bPayment;
        
        District__c district=testclassHelper.createDistrict();
        insert district;
        
        job__c job= testclassHelper.createJob('Pending','Awaiting Finance Paperwork',opplist[0].id,district.id);
        job.Quote__c=bmQuote.id;
        job.Pre_Electrical_Required__c=true;
        
        
        job__c job1= testclassHelper.createJob('Planned','Planned',opplist[1].id,district.id);
        job1.Quote__c=bmQuote1.id;
        
        job__c job2= testclassHelper.createJob('Planned','Planned',opplist[2].id,district.id);
        job2.Quote__c=bmQuoteCash.id;
        
        joblist= new List<job__c>{job,job1,job2};
        insert joblist;
        
        attachment attcash = TestClassHelper.createAttachemnt(bmQuoteCash.Id);
        attcash.name=bmQuote.BigMachines_Transaction_Id__c+'_quote.pdf';
        
        Attachment att = TestClassHelper.createAttachemnt(bmQuote.Id);
        att.name=bmQuote.BigMachines_Transaction_Id__c+'_quote.pdf';
        attlist= new List<attachment>{attcash,att};
        insert att;
    }
    
    static testmethod void unittestFinance()
    {
        createdata();
        String CRON_EXP = '0 0 0 15 3 ? *';
        System.schedule('ScheduleApexClassTest',  CRON_EXP, new AutoPrdScheduler());
        Test.startTest();
        AutoPrdBatchClass.createAutoPrdBatch();
        Test.stopTest();
    }
}