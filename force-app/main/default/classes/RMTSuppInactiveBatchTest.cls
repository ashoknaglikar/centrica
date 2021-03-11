@isTest
private class RMTSuppInactiveBatchTest{
    static Employee__c emp;
    static Employee__c empWorksWith;
    static Employee_Postcode_Sectors__c  emppost;
    static district__c dist;
    static Region__c  testregion;
    static Sub_Patch__c subpatch;
    static Postcode_Sector__c pcode;
    static Datetime weekStart;
    static String postCode;
    static String endTime;
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Opportunity opp;
    static BigMachines_Quote__c quote;
    static Job__c job;
    static Week__c week;
    static Diary_Entry__c DEntry;
    static double length;
    static String avType;
    static String URL;
    static String jobCode;
    static Double jobHours;
    static DateTime startDate;
    static DateTime endDate;
    static string subType;
    static string unAvailRecTypeId;
    
    static void createData()
    {
        cls_IsRun.dontFireTriggers = true;
        cls_IsRun.generalTriggerSwitch = true;
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;

        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
   

        insert contact;  
     
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //prepare workswith employee data
        empWorksWith = new Employee__c(Name = 'testEmp1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'testJI12', Last_Name__c = 'Test1',
                                      Employee_Number__c = '9929913' , Emp_type__c = 'E' , Primary_Role__c = 'HSA', supplier__c = supplier.id);
        insert empWorksWith;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0992991' , Emp_type__c = 'E' , Primary_Role__c = 'HSA' , Always_Works_With__c = empWorksWith.id, Resource_Id__c= '123456b');
        insert emp;
        
        testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        dist = new district__c(name='Kent & East Surrey',Code__c = 'TN92',Type__c='Installation',Region__c=testRegion.id);
        insert dist;
        
        subpatch = new Sub_Patch__c(name='Kent & East Surrey S06',code__c='test_S06', district__c=dist.id,type__c='Installation');
        insert subpatch;
        
        pcode = new Postcode_Sector__c(Type__c='Installation', Sub_Patch__c=subpatch.id,name='TN9 2');
        insert pcode;
        
        emppost = new Employee_Postcode_Sectors__c (Employee__c=emp.id,Postcode_Sector__c=pcode.id,Start_Date__c=Date.today(),End_Date__c=date.today().adddays(5), Type__c = 'Primary');
        insert emppost;
         //inserting opportunity with different employee
         opp = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addyears(1),                                                 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                        
         insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                        POC_Payment_Method__c = 'Finance',
                                         Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                         is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                         Job_Type__c = '13' , Product_Type_ID__c = 'ECH');
        insert quote;
        
        job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                        Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5,previous_resources__c = ' ',
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today().adddays(integer.valueof(system.label.No_of_Days)),Installer__c=UserInfo.getUserId());
   
            
        job.Status__c='Planned';
        job.Is_Remedial_Job__c = true;
        insert job;
        
        week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today().adddays(-2));
        insert week;
        
        DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id , Job__c = job.id , Start__c = system.now() , End__c = system.now().adddays(7) , Type__c = 'Job Booking');
        insert DEntry;
                
        
    }
   
   static testmethod void Testcase1(){
     createData();
        RMT_Supplier__c RMT = TestClassHelper.createRMTSupplier();
        RMT.GasSafe_Expiry_Date__c = Date.today();
        RMT.Supplier_Status__c = 'Active';
        insert RMT;
        
        P5_RMT_Contractors__c cont = TestClassHelper.createContractor();
        cont.Supplier__c = RMT.id;
        cont.P5_Status__c = 'Active';
        insert cont;
     RMTSuppInActiveBatch M = new RMTSuppInActiveBatch();
     Database.executeBatch(M);
       
   }
   
   static testmethod void TestCase2(){
     createData();
        RMT_Supplier__c RMT = TestClassHelper.createRMTSupplier();
        RMT.GasSafe_Expiry_Date__c = Date.today();
        RMT.Supplier_Status__c = 'Active';
        insert RMT;
        
        P5_RMT_Contractors__c cont = TestClassHelper.createContractor();
        cont.Supplier__c = RMT.id;
        cont.P5_Status__c = 'Active';
        cont.License_Expiry_Date__c =date.today();
        insert cont;
        
        P5_RMT_Contractors__c cont1 = TestClassHelper.createContractor();
        cont1.Supplier__c = RMT.id;
        cont1.P5_Status__c = 'InActive';
        cont1.License_Expiry_Date__c = Date.today();
        insert cont1;
        
     /*ContSuppInActiveBatch M = new ContSuppInActiveBatch();
     Database.executeBatch(M);*/
     String cronExpr = '0 0 0 15 3 ? *';
     ContDataScheduler abs= new ContDataScheduler();
     String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
     abs.execute(null);
   }

}