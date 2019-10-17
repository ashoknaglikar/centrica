/**
 * Test class created for MerchantView Screen
 * Created by Phil Denniosn 19/07/2011
 */
@isTest
private class MerchantViewController_Test {
    
    static Account account;  
    static Contact contact;
    static Employee__c Employee ;
    static Opportunity opportunity ;
    static BigMachines_Quote__c Quote;
    static Job__c JobDetails;
    static Job_Element__c JobElement;
    static Supplier__c Supplier;
    static Supplier__c Supplier2NotPTS;
    static order__c[] PODetails;
    static order__c PODetailsNotPTS;
    static Order_Line_Item__c OrderLine;
    static Shift_Pattern__c Shift;
    static Week__c Week;
    static Diary_Entry__c DiaryEntry;
    
    static void createTestData() {
        
        cls_IsRun.generalTriggerSwitch = true;
        cls_IsRun.dontFireTriggers = true;
        
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
                        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;   
        
        //Supplier = new Supplier__c (Name='Test Merchant', Supplier_num__c = '1002');
        //insert Supplier; 
           
        
        Employee = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert Employee;  
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employee.id);                                  
        insert opportunity;
        
        Quote = new BigMachines_Quote__c(Name = 'Test Quote', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=Employee.id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
        JobDetails = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Status__c='Planned', Sub_Status__c = 'Planned', Delivery_Date__c =Date.today(),
                                Installation_Date__c=Date.today());                            
        insert JobDetails;
        
        Order__c PODetails1 = new Order__c(job__c = JobDetails.id, SAP_Number__c = '3700000000', Supplier__c = 'a0920000006Q4RQ');
        Order__c PODetails2 = new Order__c(job__c = JobDetails.id, SAP_Number__c = '3700000001', Supplier__c = 'a0920000006Q4RQ');
        PODetails = new order__c[]{PODetails1,PODetails2};
        insert PODetails;
        
        Supplier2NotPTS = testclasshelper.createSupplier();
        insert Supplier2NotPTS;
        
        PODetailsNotPTS = new Order__c(job__c = JobDetails.id, SAP_Number__c = '3700000002', Supplier__c = Supplier2NotPTS.id);
        insert PODetailsNotPTS;        
    
        
        JobElement = new Job_Element__c (Order__c = PODetails[0].id, job__c = JobDetails.id, Type__c = 'Material', Product_ID__c = 'P1992', Units__c = 1);
        insert JobElement;
        
        OrderLine = new Order_Line_Item__c (Order_Line_Item_Number__c=714,P5_Job_Element__c=JobElement.Id, P5_Purchase_Order__c = PODetails[0].Id,
                    P5_Status_c__c='Active', Units__c=10, P5_Type__c='Material', Description__c='testMatLine',
                    Code__c='MAT1051', P5_Unit_Price_c__c=100, Supplier__c= 'a0920000006Q4RQ');
        insert OrderLine;
        
        Shift = new Shift_Pattern__c(Name = 'Test Shift', Pool_Shift_Pattern__c = true, Shift_Pattern_ID__c = 'TS1',
                    Total_Hours__c = '1',Monday_Start_Time__c = '08:00',Monday_End_Time__c = '09:00' );
        insert Shift;
        
        Week = new Week__c(Employee__c = Employee.id, Shift_Pattern__c = Shift.id, Week_Commencing__c = date.today());
        insert Week;
        
        DiaryEntry = new Diary_Entry__c(Week__c = Week.id, Sub_Type__c = 'Mechanical', Job__c = JobDetails.id, 
                    Start__c = Datetime.now() , End__c = Datetime.now(), Hours__c = 1);
        insert DiaryEntry;  
        
    }
    
    static testmethod void PostiveTestCase(){
       createTestData();
       MerchantViewController controller1 = new MerchantViewController();
        /*controller1.search(); 
        system.assertequals(controller1.PONumber,null);
        system.assertnotequals(controller1.showDetail,true);
        system.assert(controller1.errorMsg=='This is not a valid SAP or you do not have permissions on this record');*/
        controller1.PONumber = PODetails[0].SAP_Number__c;
        controller1.search();  
        system.assertequals(controller1.PONumber,'3700000000');
        system.assertnotequals(controller1.showDetail,false);
        controller1.errorMsg = 'Exception occurred';
        controller1.setErrorMsg();
    }
    /*
    static testmethod void PostiveTestCase2(){
        createTestData();
        MerchantViewController controller3 = new MerchantViewController();
        controller3.PONumber = PODetails[0].job__r.Name;
        controller3.search();  
    
    }*/
    
    static testmethod void negativeTestcase(){
        createTestData();
        // Test exception
        MerchantViewController controller2 = new MerchantViewController();
        controller2.PONumber = 'ABCD';
        controller2.search();  
        //system.assertequals(controller2.PONumber,'3700000002');
        //system.assertequals(controller2.showDetail,false);
        controller2.errorMsg = 'Exception occurred';
        controller2.setErrorMsg();
    
    }
    
    
}