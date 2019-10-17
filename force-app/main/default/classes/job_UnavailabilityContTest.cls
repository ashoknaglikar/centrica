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
private class job_UnavailabilityContTest {
    
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    static testMethod void preparetestdata() {
        
           Supplier__c supplier = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12CC21', Name='British Gas CC');
           insert supplier;
           
           Employee__c employee = new Employee__c(Supplier__c=supplier.Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
           insert Employee;
           
           Week__c week = new Week__c(Employee__c=employee.Id);
           insert week;
           
           Diary_Entry__c de1 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de2 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de3 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de4 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(3), End__c = datetime.now().addhours(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de5 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(4), End__c = datetime.now().addhours(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c[] diaryEntries1 = new Diary_Entry__c[]{de1,de2,de3,de4,de5};
           UnavailabilityManager.createUnavailability(diaryEntries1);
           UnavailabilityManager.removeUnavailability(diaryEntries1);
     
           Diary_Entry__c de6 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de7 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de8 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de9 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(3), End__c = datetime.now().addhours(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de10 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(4), End__c = datetime.now().addhours(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de6,de7,de8,de9,de10};
           insert diaryEntries;
           id[] idLst= new id[]{de6.ID,de7.ID,de8.ID,de9.Id,de10.Id};
           
           diaryEntries=[Select Week__c, Start__c, Id, End__c,Record_Type__c,IsStackable__c,Stackable__c From Diary_Entry__c where id in:idLst];
           system.debug('diaryEntries--->'+diaryEntries);
           
           UnavailabilityManager.markStackableUnavailability(diaryEntries);
           UnavailabilityManager.StackUnavailability(diaryEntries);
           Diary_Entry__c de = new Diary_Entry__c();
           for(integer i=0; i<diaryEntries.size();i++)
           {
            if(diaryEntries[i].IsStackable__c)
            {
                de = diaryEntries[i];
                diaryEntries.remove(i);
                break;
            }   
           }
           
           UnavailabilityManager.StackUnavailability(diaryEntries);
           delete de;
        // TO DO: implement unit test
    }
    
    static testMethod void Method1_Stacakble() {
            
           //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc);
            Job__c[] Job = TestScenarioCreateJob('Allocated','',opty.Id);     
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                            
            quote[0].stage__c = 'Quote Finalised - Accepted';  
            quote[0].bmStatusReason__c =  'Quote Finalised - Accepted';  
            quote[0].Transferred_to_Premier__c = null;
            quote[0].Line_Items_Decompiled__c = true;
            quote[0].BM_Completed__c = true;
            quote[0].quote_reconciled__c =true; 
            update quote[0];                     
            Job[0].Quote__c=quote[0].Id;        
            update Job;     
        
           Supplier__c supplier = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12CC21', Name='British Gas CC');
           insert supplier;
           
           Employee__c employee = new Employee__c(Supplier__c=supplier.Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
           insert Employee;
           
           Week__c week = new Week__c(Employee__c=employee.Id,Week_Commencing__c = system.today().toStartOfWeek());
           insert week;
           
           Unavailability__c unavail = new Unavailability__c(Employee__c = employee.Id, Start_Date_Time__c=datetime.now(),End_Date_Time__c= datetime.now().addHours(6),Unavailability_Reason__c='Survey Duties',Generated_Unavailability__c=true);  
           insert unavail;
           
            Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
            User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
           
           Installer__c installer1= new Installer__c(User__c=UInstal1.Id,Job__c=Job[0].Id,Installer_Status__c='Active',Start_Date__c = system.now(),End_Date__c=datetime.now().addhours(5));
           Installer__c installer2= new Installer__c(User__c=UInstal1.Id,Job__c=Job[0].Id,Installer_Status__c='Active',Start_Date__c = system.now().addhours(6),End_Date__c=datetime.now().addhours(7));
           Installer__c[] lstinstaller =  new Installer__c[]{installer1,installer2};
           insert lstinstaller;
          
           Job = TestgetJob(Job[0].Id);      
           
            PageReference pageRef = new PageReference('apex/Job_Unavailabilitydisplay?s='+ unavail.Id); 
        
            Test.setCurrentPage(pageRef);
            job_UnavailabilityCont controller = new job_UnavailabilityCont();
           
           
           Diary_Entry__c de6 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de7 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties',IsStackable__c =true);
           Diary_Entry__c de8 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de9 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(3), End__c = datetime.now().addhours(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de10 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(4), End__c = datetime.now().addhours(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de1 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(5),Sub_Type__c ='Mechanical',Job__c=Job[0].ID,RecordtypeId=ENTRY_RECTYPE_BOOKING);
           Diary_Entry__c de2 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(6), End__c = datetime.now().addhours(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID,RecordtypeId=ENTRY_RECTYPE_BOOKING);
           Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de6,de7,de8,de9,de10,de1,de2};
           insert diaryEntries;
           id[] idLst= new id[]{de6.ID,de7.ID,de8.ID,de9.Id,de10.Id,de1.Id,de2.Id};
           
           diaryEntries=[Select ID,Name ,Job__c,Week__c,Start__c,End__c,Record_Type__c,Sub_Type__c,Stackable__c,Employee_ID_18__c,IsStackable__c,Employee_Name__c From Diary_Entry__c where id in:idLst];
           system.debug('diaryEntries--->'+diaryEntries);
            
            unavail.Generated_Unavailability__c = false;
            //unavail.Unavailability_Reason__c = 'Test';
            update unavail;
            
            
            
            PageReference pageRef1 = new PageReference('apex/Job_Unavailabilitydisplay?s='+ unavail.Id); 
        
            Test.setCurrentPage(pageRef1);
            job_UnavailabilityCont controller1 = new job_UnavailabilityCont();
            controller1.RemoveUnavilabilities();
            
            for(integer i=0;i<controller1.unavaila_Records.size();i++)
            {
                controller1.unavaila_Records[i].isSelected = true;
            }
            controller1.RemoveUnavilabilities();    
            controller1.generateUnavailability();
            Diary_Entry__c[] JobsEntrylst = new Diary_Entry__c[]{de1,de2};
            controller1.markJobsForReporting(Job, JobsEntrylst);
            controller1.setErrorMsg();
            controller1.selectAll = true;
            controller1.selectAll();
            
            
     
         
        // TO DO: implement unit test
    }
    static testMethod void Method2_NonStacakble() {
            
           //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc);
            Job__c[] Job = TestScenarioCreateJob('Allocated','',opty.Id);   
              
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                            
            quote[0].stage__c = 'Quote Finalised - Accepted';  
            quote[0].bmStatusReason__c =  'Quote Finalised - Accepted';  
            quote[0].Transferred_to_Premier__c = null;
            quote[0].Line_Items_Decompiled__c = true;
            quote[0].BM_Completed__c = true;
            quote[0].quote_reconciled__c =true; 
            update quote[0];                     
            Job[0].Quote__c=quote[0].Id;        
            update Job;  
            
             Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
             User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');     
            
           Installer__c installer1= new Installer__c(User__c=UInstal1.Id,Job__c=Job[0].Id,Installer_Status__c='Active',Start_Date__c = system.now(),End_Date__c=datetime.now().addhours(5));
           Installer__c installer2= new Installer__c(User__c=UInstal1.Id,Job__c=Job[0].Id,Installer_Status__c='Active',Start_Date__c = system.now().addhours(6),End_Date__c=datetime.now().addhours(7));
           Installer__c[] lstinstaller =  new Installer__c[]{installer1,installer2};
           insert lstinstaller;
           
           Job = TestgetJob(Job[0].Id);      
           
           Supplier__c supplier = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12CC21', Name='British Gas CC');
           insert supplier;
           
           Employee__c employee = new Employee__c(Supplier__c=supplier.Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
           insert Employee;
           
           Unavailability__c unavail = new Unavailability__c(Employee__c = employee.Id, Start_Date_Time__c=datetime.now(),End_Date_Time__c= datetime.now().addHours(6),Unavailability_Reason__c='test');  
           insert unavail;
           
           PageReference pageRef = new PageReference('apex/Job_Unavailabilitydisplay?s='+ unavail.Id); 
        
           Test.setCurrentPage(pageRef);
           job_UnavailabilityCont controller = new job_UnavailabilityCont();
           controller.generateUnavailability();
           
           Week__c week = new Week__c(Employee__c=employee.Id,Week_Commencing__c = system.today().toStartOfWeek());
           insert week;
           
           
           
           Diary_Entry__c de6 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de7 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(2),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties',IsStackable__c =true);
           Diary_Entry__c de8 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de9 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(3), End__c = datetime.now().addhours(4),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='Survey Duties');
           Diary_Entry__c de10 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(4), End__c = datetime.now().addhours(5),RecordtypeId=ENTRY_RECTYPE_UNAVAIL,Sub_Type__c='test');
           Diary_Entry__c de1 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(5),Sub_Type__c ='Mechanical',Job__c=Job[0].ID,RecordtypeId=ENTRY_RECTYPE_BOOKING);
           Diary_Entry__c de2 = new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now().addhours(6), End__c = datetime.now().addhours(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID,RecordtypeId=ENTRY_RECTYPE_BOOKING);
           Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de6,de7,de8,de9,de10,de1,de2};
           insert diaryEntries;
           id[] idLst= new id[]{de6.ID,de7.ID,de8.ID,de9.Id,de10.Id,de1.Id,de2.Id};
           
           diaryEntries=[Select ID,Name ,Job__c,Week__c,Start__c,End__c,Record_Type__c,Sub_Type__c,Stackable__c,Employee_ID_18__c,IsStackable__c,Employee_Name__c From Diary_Entry__c where id in:idLst];
           system.debug('diaryEntries--->'+diaryEntries);
            
            PageReference pageRef1 = new PageReference('apex/Job_Unavailabilitydisplay?s='+ unavail.Id); 
        
            Test.setCurrentPage(pageRef1);
            job_UnavailabilityCont controller1 = new job_UnavailabilityCont();
            controller1.RemoveUnavilabilities();
            
            for(integer i=0;i<controller1.unavaila_Records.size();i++)
            {
                controller1.unavaila_Records[i].isSelected = true;
            }
            controller1.RemoveUnavilabilities();    
            controller1.unavailabiltyRecord.Start_Date_Time__c.adddays(4);
            update controller1.unavailabiltyRecord;
            controller1.generateUnavailability();
            controller1.unavailabiltyRecord.Start_Date_Time__c= system.today();
            controller1.unavailabiltyRecord.Generated_Unavailability__c = true;
            update controller1.unavailabiltyRecord;
            controller1.generateUnavailability();
            Diary_Entry__c[] JobsEntrylst = new Diary_Entry__c[]{de1,de2};
        }
         
        // TO DO: implement unit test
    
    
     @isTest
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Calculate District', Code__c='ccccccccc');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='CCC C', District__c=district.Id, Code__c='ccccccccc');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='CCC C', Sub_Patch__c=subPatch.Id, Code__c='ccccccccc');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account calculate net price', BillingStreet='Test Calculate', BillingPostalCode = 'CCC CCC');                       
        insert Acc;        
        return Acc;
    }
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign Calc', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Calculate Price', StageName = 'Prospecting', Platform__c = 'SFDC',CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
        
    }
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty,integer num){
        
        BigMachines_Quote__c quote;
        if(num==1)
            quote = new BigMachines_Quote__c(Name = 'Test for Calc Price', Opportunity__c = opty.id, quote_reconciled__c=true);           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Calc Price', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                   
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist; 
    }
    
    //test method     
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId){
        
        Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0,Installation_Date__c= system.today());              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return joblist;
    }
    
     public static Job__c[] TestgetJob( ID jobId){
        
        Job__c job1 = [Select Id, Start_Data_Time__c,Maximum_End_Date__c,Installation_Date__c,Pending_Reason__c,Needs_Re_Planing__c,Type__c,CHI_Lead__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c From Job__c j where id =:jobId];              
        Job__c[] joblist = new Job__c[]{job1};       
        system.debug('Job--->'+job1);   
        return joblist;
    }
    
  
}