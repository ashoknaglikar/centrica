/**
Type Name:UpdateBalanceinPayment_test
Author: Cognizant
Created Date: 24/06/2010
Reason: This is Test class for UpdateBalanceinPayment
Change History
 */
@isTest
private class UpdateBalanceinPayment_Test {
    

    static testMethod void Test_UpdateBalanceinPayment() 
    {
        Double netAmount,netAmount1;      
        
       
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        cls_IsRun.isOppoRun=true;
        Opportunity opportunity = new Opportunity(Name = 'Test3 Opp', StageName ='Active',CloseDate=System.today(),Finance_Amount__c = 120,Amount = 0,
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true,
                                                discountsTotalOnPricing__c=null,Payment_Reference_Number__c='21');
       
        insert opportunity;
        
       
        System.debug('Old_opportunity StageName---'+ opportunity.StageName);
        opportunity.StageName ='Settled';
        System.debug('Old_opportunity Amount---'+ opportunity.Amount);
        opportunity.Amount = 100;
         
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                          POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted',
                                          bmstatusreason__c='Quote Finalised - Accepted',is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;       

        Job__c job = new Job__c(CHI_Lead__c = opportunity.Id,Quote__c=quote.Id, 
                        PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,Status__c='Pending',Sub_Status__c ='Awaiting Planning',
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                        Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());

        //Code Fix done as a part of PRB00008739 by BGSAMS Support on 08/08/2012 - Starts 
        
        Payment_Collection__c PaymntColltn = new Payment_Collection__c(Opportunity__c = opportunity.Id,Job__c = job.Id,Were_there_any_changes_to_the_Job__c='No',Was_Job_completed_to_specification__c='No',Is_the_customer_satisfied__c='Yes',
                                                                      Have_you_demod_the_system_controls__c='Yes',Have_you_arranged_a_call_back_time__c='Yes',Has_NPS_been_explained_to_Customer__c='Yes',Payment_Collection_Status__c = 'Pending',Balance_Outstanding__c=123,Changes_to_Specification__c='testDescription',Job_Special_ID__c = job.Id + 'PC' );
        //Code Fix done as a part of PRB00008739 by BGSAMS Support on 08/08/2012 - Ends                                                               
        insert PaymntColltn; 
        
        System.debug('Payment_Collection_Status__c-----------' +PaymntColltn.Payment_Collection_Status__c);
        List<Payment_Collection__c> paymentcollectionlst = new List<Payment_Collection__c>();
        paymentcollectionlst.add(PaymntColltn);
         
        Payments__c Paymnt = new Payments__c();
        Paymnt.Payment_Collection_Notice__c = PaymntColltn.ID;
        Paymnt.IsSynced__c = false;
        Paymnt.Amount_Collected__c = 100;
        insert Paymnt; 
        
        //BGS Payment
        BGS_Payment__c bgsPayments = new BGS_Payment__c();
        bgsPayments.Amount__c =2000 ;
        bgsPayments.Amount_Refunded__c = 100;
        bgsPayments.Opportunity__c = opportunity.id;
        bgsPayments.depositOnPricing__c = 12;
        bgsPayments.Payment_Type__c = 'Deposit';
        bgsPayments.Payment_Method__c = 'Cash';
        insert bgsPayments;
        
        cls_IsRun.isOppoRun=false;
        update opportunity;     
        
    }
}