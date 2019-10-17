@isTest
private class SalesAdvisorInstallerBatch_Test {
   static id appRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Appointment'].id; 
   static id jobBooking = [select id from RecordType where SObjectType ='Diary_Entry__c' AND name='Job booking'].id;
   static job__c job;
   static void createTestData(){
        Account acc = TestClassHelper.createAccout();
        acc.BillingPostalCode = 'AB1 1QL';
        insert acc;
        
        Contact c = TestClassHelper.createContact(acc);
        insert c;
        
        Opportunity opty = TestClassHelper.createCHILead(acc);
        insert opty;
        
        District__c dist = TestClassHelper.createDistrict();
        insert dist;
        
        BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opty);
        insert bm;
        
        job = TestClassHelper.createJob('Pending', 'Pending', opty.Id, dist.Id);
        job.Quote__c = bm.Id;
        insert job;
        
        job=[select id,CHI_lead__c,Install_Postcode__c,Named_Employee__c from job__c where id=:job.id];
        
        User use = TestClassHelper.createUser();
        insert use; 
       
        Employee__c emp1 = TestClassHelper.createEmployee();
        emp1.Salesforce_User__c=use.id;
        emp1.Area_Group__c = 'test';
        Employee__c emp2 = TestClassHelper.createEmployee();
        emp2.Salesforce_User__c=use.id; 
        emp2.Employee_Number__c = (''+ '1992');
        emp1.Area_Group__c = 'test';
        List<Employee__c> emp= new List<Employee__c>{emp1,emp2};
        insert emp;  
        
        People_Hirearchy__c ph1 = new People_Hirearchy__c(Pay_Number__c=emp[0].Employee_Number__c,Employee__c=emp[0].id); 
        People_Hirearchy__c ph2 = new People_Hirearchy__c(Pay_Number__c=emp[1].Employee_Number__c,Employee__c=emp[1].id);
        List<People_Hirearchy__c> ph= new List<People_Hirearchy__c>{ph1,ph2};
        insert ph;
        
        Appointment__c app = TestClassHelper.createAppointment(opty,emp[0].id,use.id,appRec,c.id);
        insert app;
        
        Sub_Patch__c subPatch = TestClassHelper.createSubPatch(dist.id);
        insert subPatch;
        
        PostCode_Sector__c postCode1 = TestClassHelper.createPostCode(subPatch.id);
        //postCode1.L6_Sales_Manager__c= ph[0].id;
        postCode1.Area_group__c='test';
        PostCode_Sector__c postCode2 = TestClassHelper.createPostCode(subPatch.id);
        postCode2.Type__c='Installation';
        //postCode2.L6_Install_Manager__c = ph[1].id;
        postCode2.Area_group__c= 'test';
        List<PostCode_Sector__c> postCode = new List<PostCode_Sector__c>{postCode1,postCode2};
        insert postCode;
        
        Week__c week = TestClassHelper.createWeek(emp[0].id);
        insert week;
        
        
        Diary_Entry__c de1= new Diary_Entry__c(Week__c=week.id,RecordTypeId=jobBooking,Overbooked_Hours__c=2.00,employee__c=emp[0].id,job__c=job.id,Sub_Type__c='Mechanical',hours__c=4.00);
        Diary_Entry__c de2= new Diary_Entry__c(Week__c=week.id,RecordTypeId=jobBooking,Overbooked_Hours__c=0.00,employee__c=emp[1].id,job__c=job.id,Sub_Type__c='Mechanical',hours__c=6.00);
        List<Diary_Entry__c> de= new List<Diary_Entry__c>{de1,de2};
        insert de;
    }

    private static testMethod void SalesAdvisorTest() {
        createTestData();
        Test.startTest();
        SalesAdvisorUpdateBatch  newObj = new SalesAdvisorUpdateBatch();
        Database.executeBatch(newObj);
        Test.stopTest();
    }
    
    private static testMethod void InstallerTest() {
        createTestData();
        Test.startTest();
        InstallerUpdateBatch  newObj = new InstallerUpdateBatch();
        Database.executeBatch(newObj); 
        newObj.updateL6Manager(new list<Job__c>{job});
        newObj.updateInstaller(new list<Job__c>{job});
        Test.stopTest();
    }
   

}