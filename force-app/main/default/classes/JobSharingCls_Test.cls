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
private class JobSharingCls_Test {
    
    static String accid;
    static String cId;
    static String opptyId;
    static Job__c job;
     static testmethod void createJobSharingTest(){
        // Creating the instance variable
        JobSharingCls obj = new JobSharingCls();
        // Create a new Account
        accId = getAccount();
        // Create a new Campaign
        cId = getCampaign();
        // Create a new Opportuntiy
        opptyId = getOpportunity();
        // Create a Quote and retrieve the job created
        job = getQuote();
        // Create a Diary entry for the job
        createDiaryEntry();
        
        
        try{
            job.Status__c='Planned';
            update job;
        }catch(DmlException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        // Calls the method to test
        test.starttest();
        String result = JobSharingCls.createJobSharing(new List<String>{job.Id});   
        test.stoptest();    
    }
    // This method is responsible for creating a Campaign o be used in ceation of opportunity
    // Output is the inserted records ID
     static testmethod String getCampaign(){
        Campaign cmp = new Campaign();
        cmp.Status = 'Completed';
        cmp.IsActive = true;
        cmp.Name = 'Test Campaign';
        cmp.Group_Code__c='MEDA';
        cmp.Media_Cost_Code__c='test';
        cmp.Source__c='TM';
        try{
            insert cmp;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return cmp.Id;
    }
    // This method is responsible for creating a Account to be used in ceation of opportunity
    // Output is the inserted records ID
     static testmethod String getAccount(){
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='84,Range Road';
        account.BillingState='Cheshire';
        account.BillingPostalCode='SK3 8EE';
        account.BillingCountry='United Kingdom';
        account.BillingCity='Stockport';
        account.Water_Hardness__c=0;
        try{
            insert account;
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return account.Id;
    }
    // This method is responsible for creating an Oppoetunity to be used in ceation of job
    // Output is the inserted records ID
      static testmethod String getOpportunity(){
        // Create new opportunity
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opportunity';
        opportunity.Product_Interest__c = 'XYZ';
        opportunity.CampaignId = cId;
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.AccountId=accid;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        opportunity.Lead_Comments__c = 'Lead Comments';
        try{
            insert opportunity;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return opportunity.Id;
    }
    // This method is responsible for creating a Quote to be used in ceation of Job
    // Output is the automatically inserted job records ID
      static testmethod job__c getQuote(){
        BigMachines_Quote__c qt = new BigMachines_Quote__c();
        qt.Opportunity__c=opptyId;
        qT.bmStatusReason__c='Sales';
        qt.stage__c='Quote Finalised - Accepted';
        qt.quoteNumber_quote__c = '12234';
        qt.installationDate__c = System.today();
        qt.deliveryDate__c = System.today();
        qt.Frozen_BM_Gross__c  = 12340;
        try{
            insert qt;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        
        // Cognizant - CHI Phase III CR-002 implementation... START
        
        //AddNewSkill ObjNewSkill = new AddNewSkill();
        //job = ObjNewSkill.fetchJobforSharing(qt.Id);         
        
        job = [select id,name,CHI_Lead__c,Status__c,Mechanical_Hours__c,PowerFlush_Hours__c,Building_Work_Hours__c,Installation_Date__c,Customer_Preferred_Date__c from Job__c where Quote__c =: qt.Id limit 1];
        
        // Cognizant - CHI Phase III CR-002 implementation... END        
        
       return job;
    }
 
    
    // This method is responsible for creating a Diary Entry for the job
     static testmethod void createDiaryEntry() {
        try{       
            Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
            Database.insert(testRegion);
            
            District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
            Database.insert(testDistrict);
            
            Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                        Type__c='Installation', District__c = testDistrict.ID);
            Database.insert(testSubPatch);
            
            Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'XX99 9', Description__c = 'Test Postcode Sector', 
                                                                            Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                            Sub_Patch__c = testSubPatch.ID);
            Database.insert(testPostcodeSector);
            Supplier__c supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                                Resource_Type__c='Own Labour');
            Database.insert(supp);
            User tUser = [select id from User where Phase_4_Ready__c=true limit 1];
            
                               
            Profile PInstal = [select id from Profile where name = 'CHI Contractor'];
            User uContractor = new User(profileid=PInstal.Id,alias = 'contra', email='contractor@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testContractor@testorg.com');
            insert uContractor;
            Employee__c empCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                                Employee_Number__c = '0002994', Resource_Type__c= 'Installer', Inactive__c = false,
                                                Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                                Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                                District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=uContractor.Id);
            Database.insert(empCon);
            
           
            Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                                Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                                Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                                Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                                District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=tUser.id);
            Database.insert(emp);
            Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                        Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                        Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                        Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                        Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                        Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                        Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                        Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
            Database.insert(sp);
            
            
            Week__c w = new Week__c(Employee__c = emp.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
            Database.insert(w);
            DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
            DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
            Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,
                                                    job__c = job.Id,RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
            Database.insert(de);
            
            Week__c w1 = new Week__c(Employee__c = empCon.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
            Database.insert(w1);
            DateTime startDT1 = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
            DateTime endDT1 = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
            Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT1, End__c = endDT1, Hours__c = 40, Week__c = w1.ID,
                                                    job__c = job.Id,RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
            Database.insert(de1);
          
        }catch(Exception e){
            System.debug('Exception occured: '+e);
        }        
    }
}