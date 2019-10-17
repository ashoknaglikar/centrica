@isTest
private with sharing class TestJobNamedResourceController {
   static testMethod void testJobNamedResourceController(){
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        //Test Class for JobNamedResourceController:                                                       //
        //Setup the environment for the test class to operate on. This requires a Campaign and Account to  //
        //associate with a CHI Lead. Create a job to test.                            //
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        Account acc = new Account(Name = 'Test JobNamedResource', BillingStreet='20 Display', 
                                        BillingPostalCode='TW18 3HT', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test J');
        Database.insert(camp);
        Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestNamedEmp() opp', AccountId = acc.Id,
                                           CloseDate = Date.today().addyears(1), 
                                           StageName = 'Active',
                                           Product_Interest__c='Central Heating Boiler',
                                           CampaignId = camp.Id);
        Database.insert(opp);
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = null,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = false);
        Database.insert(job);
        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        PageReference pageRef = new PageReference('/apex/Named_Job_Skill_Field_Set?id='+job.id);
        JobNamedResourceController controller1 = new JobNamedResourceController(sc);
        Test.setCurrentPage(pageRef);
        List<Job_Named_Skill_Resource__c> jNamedResourceList = new List<Job_Named_Skill_Resource__c>();
        Supplier__c supplier = new supplier__c(Name='Test supplier Named',Type__c='Resource',Supplier_Num__c='NA1234',Resource_Type__c='Resource');
        insert supplier;
        Employee__c emp1 = new Employee__c(Name = 'test named 1', First_Name__c = 'Named 1', Last_Name__c = 'Employee 1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '00110011',Resource_Id__c='Named1',Resource_Type__c='Installer');
        Employee__c emp2 = new Employee__c(Name = 'test named 2', First_Name__c = 'Named 2', Last_Name__c = 'Employee 2',Supplier__c=supplier.Id,
                                         Employee_Number__c = '00220022',Resource_Id__c='Named2',Resource_Type__c='Installer');
        Employee__c[] employees = new Employee__c[]{emp1,emp2};    
        insert employees;
        for(Integer i=1;i<=2;i++){
            if(i==1){
                jNamedResourceList.add(new Job_Named_Skill_Resource__c());
                jNamedResourceList.get(0).Employee__c = emp1.Id;
                jNamedResourceList.get(0).Skill_Name__c = 'Mechanical';
                jNamedResourceList.get(0).Job__c = job.id;
            }else if(i==2){
                jNamedResourceList.add(new Job_Named_Skill_Resource__c());
                jNamedResourceList.get(1).Employee__c = emp2.Id;
                jNamedResourceList.get(1).Skill_Name__c = 'Building Work';
                jNamedResourceList.get(1).Job__c = job.id;
            }
        }
        controller1.jobNewNamedResourceRecordList = jNamedResourceList;
        controller1.save();
        jNamedResourceList = [Select Id, Employee__c, Skill_Name__c, Job__c from Job_Named_Skill_Resource__c where job__c  = :job.Id];
        System.assertEquals(2,jNamedResourceList.size()); 
        Job_Named_Skill_Resource__c jDuplicate = new Job_Named_Skill_Resource__c();
        jDuplicate.Skill_Name__c = 'Mechanical';
        jDuplicate.Job__c = job.id;
        controller1.jobExistingNamedResourceRecordList = jNamedResourceList;
        controller1.jobNewNamedResourceRecordList = new List<Job_Named_Skill_Resource__c>();
        controller1.jobNewNamedResourceRecordList.add(jDuplicate);
        jDuplicate.Employee__c = emp2.Id;
        controller1.save();
        controller1.returnToJob();
        jNamedResourceList = [Select Id, Employee__c, Skill_Name__c, Job__c from Job_Named_Skill_Resource__c where job__c  = :job.Id];
        System.assertEquals(2,jNamedResourceList.size());
        controller1.clearAll();
        
    
   }

}