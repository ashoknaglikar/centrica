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
private class TestJobSuspension {
    static Employee__c[] createEmployees() {
        Supplier__c supp = Phase3TestHelper.createSupplier();
        Employee__c emp1 = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false);
        Database.insert(emp1);
        Employee__c emp2 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002992', Resource_Type__c= 'Installer', Inactive__c = false, 
                                            Always_Works_With__c = emp1.ID);
        Database.insert(emp2);
        emp1.Always_Works_With__c = emp2.ID;
        Database.update(emp1);
        return new Employee__c[] {emp1, emp2}; 
    }
    
    static List<Job__c> createJobs() {        
        Phase3TestHelper.createTestGeography();
        Employee__c[] emps = createEmployees();
        Employee__c emp1 = emps[0];
        List<Job__c> jobs = new List<Job__c>();
        Opportunity opp = Phase3TestHelper.createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(), Named_Employee__c = emp1.ID,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
                                
        Database.insert(job);
        job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job.ID];
        
        //create another new job
        
        ID districtID = TestScenarioCreateDistrict();
    Account Acc = TestScenarioCreateAccount(districtID);
    Opportunity opp1 = TestScenarioCreateOppty(Acc);
    
        Job__c job1 = new Job__c(CHI_Lead__c = opp1.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(), Named_Employee__c = emp1.ID,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
                                
        Database.insert(job1);
        job1 = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job1.ID];
                        
        return new List<Job__c> {job, job1};
    }       
    
    static void attachJobElements(List<Job__c> jobs) {
        Job__c job = jobs[0];
        Job__c job1 = jobs[1];
        //insert job elements
        List<Job_Element__c> jes = new List<Job_Element__c>();
        jes.add(new Job_Element__c(Job__c=job.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Material'));
        jes.add(new Job_Element__c(Job__c=job.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Work'));
        jes.add(new Job_Element__c(Job__c=job1.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Material'));
        jes.add(new Job_Element__c(Job__c=job1.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Work'));
        insert jes;
    }
    
    static testMethod void test1() {
        List<Job__c> jobs = createJobs();
        attachJobElements(jobs);
        Job__c job = jobs[0];
        Job__c job1 = jobs[1];
        
        //suspend the job
        job.Suspend_Job__c = true;
        job.Cancel_Merchant_Orders__c = 'Yes';
        job.Suspension_Reason__c = 'SAVE';
        job.Suspension_Reason_List__c = 'SAVE';
        update job;
        
        Test.startTest();
        
        job.Status__c = 'Suspended';
        update job;
        
        // Should render job locked error message.
        PageReference pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        SuspendJobController susJobController = new SuspendJobController();  
        susJobController.suspendJob(); 
        susJobController.getJobId();
        
        // Happy path test scenario
        job.Status__c = 'Pending';
        update job;
        pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        susJobController = new SuspendJobController();  
        susJobController.suspendJob(); 
        susJobController.getJobId();
        
        // Call again to get the error message for code coverage.
        pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        susJobController.suspendJob(); 
        susJobController.getJobId();
        
        Test.stopTest();
    }
    
    static testMethod void test2() {
        List<Job__c> jobs = createJobs();
        Job__c job = jobs[0];
        Job__c job1 = jobs[1];
        
        job.Suspend_Job__c = true;
        job.Cancel_Merchant_Orders__c = 'Yes';
        job.Suspension_Reason__c = 'SAVE';
        job.Suspension_Reason_List__c = 'SAVE';
        update job;     
        PageReference pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        SuspendJobController susJobController = new SuspendJobController();  
        susJobController.suspendJob(); 

        attachJobElements(jobs);
        job = [select Status__c, Sub_Status__c, Unsuspend_Job__c, Suspend_Job__c, Cancel_Job__c, Suspension_Reason__c from Job__c where id=:job.id];
        //unsuspend job
        job.Unsuspend_Job__c = true;
        Test.startTest();
        update job;
        Test.stopTest();
    }
        
    static testMethod void test3() {
        List<Job__c> jobs = createJobs();
        Job__c job = jobs[0];
        Job__c job1 = jobs[1];

        //suspend the job
        job = [select Status__c, Sub_Status__c, Unsuspend_Job__c, Suspend_Job__c, Cancel_Job__c, Suspension_Reason__c from Job__c where id=:job.id];
        job.Suspend_Job__c = true;
        job.Cancel_Merchant_Orders__c = 'Yes';
        job.Suspension_Reason__c = 'SAVE';
        job.Suspension_Reason_List__c = 'TEST SAVE';
        update job;
        PageReference pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        SuspendJobController susJobController = new SuspendJobController();  
        susJobController.suspendJob(); 
        
        attachJobElements(jobs);
        
        //cancel job
        job = [select Status__c, Sub_Status__c, Unsuspend_Job__c, Suspend_Job__c, Cancel_Job__c, Suspension_Reason__c from Job__c where id=:job.id];
        job.Cancel_Job__c = true;
        job.Cancellation_Reason__c = 'TEST';
        Test.StartTest();
        update job;
        Test.StopTest();
    }
    
    static testMethod void test4() {
        List<Job__c> jobs = createJobs();
        Job__c job = jobs[0];
        Job__c job1 = jobs[1];
    
        /*job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(), Named_Employee__c = emp1.ID,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
                                
        Database.insert(job);
        job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job.ID];*/
        
        /*jes = new List<Job_Element__c>();
        jes.add(new Job_Element__c(Job__c=job.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Material'));
        jes.add(new Job_Element__c(Job__c=job.id, Status__c='Active', Sub_Status__c='Awaiting Order', type__c='Work'));
        insert jes;*/
        
        //suspend the jobs
        job.Suspend_Job__c = true;
        job.Cancel_Merchant_Orders__c = 'Yes';
        job.Suspension_Reason__c = 'SAVE';
        job.Suspension_Reason_List__c = 'TEST SAVE';
        update job;
        //jobs.add(job);
        
        job1.Suspend_Job__c = true;
        job1.Cancel_Merchant_Orders__c = 'Yes';
        job1.Suspension_Reason__c = 'SAVE';
        job1.Suspension_Reason_List__c = 'TEST SAVE';
        update job1;
        //jobs.add(job1);
        
        Test.StartTest(); 
        PageReference pageRef = new PageReference('/apex/Suspend_Job?jobId='+job.Id);       
        Test.setCurrentPage(pageRef);                
        SuspendJobController susJobController = new SuspendJobController();  
        susJobController.suspendJob(); 
        PageReference pageRef1 = new PageReference('/apex/Suspend_Job?jobId='+job1.Id);       
        Test.setCurrentPage(pageRef1);                
        SuspendJobController susJobController1 = new SuspendJobController();  
        susJobController1.suspendJob(); 
        Test.stopTest();
        
        delete [select id from Job_Booking_History__c where job__c =: job.id or job__c=: job1.id];
        try{
            Database.Saveresult[] srs = database.update(new List<Job__c>{job, job1});
            for(Database.Saveresult sr : srs) {
             //   system.assert(sr.getErrors().size() == 1);
            }
        }catch(System.Exception ex){
            
        }
        delete [select id from Job_Booking_History__c where job__c =: job.id or job__c=: job1.id];
        // update individually so jobs are in "Suspended" state for unsuspend to run
        
        delete [select id from Job_Booking_History__c where job__c =: job.id or job__c=: job1.id];
        
        //unsuspend job

        job = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job.ID];
                        
        job1 = [select j.ID, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c from Job__c j where ID = :job1.ID];

        job.Unsuspend_Job__c = true;
        job1.Unsuspend_Job__c = true;
        
        try{
            Database.Saveresult[] srs = database.update(new List<Job__c>{job, job1});
            for(Database.Saveresult sr : srs) {
                system.assert(sr.getErrors().size() == 1);
            }
        }catch(System.Exception ex){
            System.debug('Exception: ' + ex);
        }
        
        //cancel job
        job.Cancel_Job__c = true;
        job.Cancellation_Reason__c = 'TEST';
        job1.Cancel_Job__c = true;
        job1.Cancellation_Reason__c = 'TEST';
        
        try{
            Database.Saveresult[] srs = database.update(new List<Job__c>{job, job1});
            for(Database.Saveresult sr : srs) {
                system.assert(sr.getErrors().size() == 1);
            }
        }catch(System.Exception ex){
            System.debug('Exception: ' + ex);
        }
        
        
        
        //delete any JBH items to allow unsuspend
        /*delete [select id from Job_Booking_History__c where job__c =: job.id or job__c=: job1.id];
        
        job = [select Status__c, Sub_Status__c, Unsuspend_Job__c, Suspend_Job__c, Cancel_Job__c, Suspension_Reason__c from Job__c where id=:job.id];
        job1 = [select Status__c, Sub_Status__c, Unsuspend_Job__c, Suspend_Job__c, Cancel_Job__c, Suspension_Reason__c from Job__c where id=:job1.id];
        //unsuspend job
        job.Unsuspend_Job__c = true;
        job1.Unsuspend_Job__c = true;
        
        jobs.clear();
        jobs.add(job);
        jobs.add(job1);
        
        try{
            Database.Saveresult[] srs = database.update(jobs);
            for(Database.Saveresult sr : srs) {
                system.assert(sr.getErrors().size() == 1);
            }
        }catch(System.Exception ex){
            
        }*/
    }
    
    static ID TestScenarioCreateDistrict(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        return district.ID;
    }
    
    static Account TestScenarioCreateAccount(Id districtID){
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=districtID, Code__c='yyyyyyyy');             
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
    static Opportunity TestScenarioCreateOppty(Account Acc){
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }            
}