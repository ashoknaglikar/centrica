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
private class VATchangecalculation_test {
    static Job__c job;
    static BigMachines_Quote__c quote;
    static Opportunity opportunity;
    static boolean vatoverride = false;
    static boolean vatsecondoverride = false;
    static boolean vatoverridethird = false;
    static void preparedata(){
    
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
        
        if(vatoverride){    
        
        opportunity = new Opportunity(Name = 'Test3 Opp', StageName ='Active',CloseDate=System.today().adddays(20),Finance_Amount__c = 120,Amount = 0,
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true,
                                                discountsTotalOnPricing__c=null,Payment_Reference_Number__c='21',Bill_Period__c = 'Before 04/01',Installation_Date_Billing__c = '2010-12-31');  
        
        }
        else{
        opportunity = new Opportunity(Name = 'Test3 Opp', StageName ='Active',CloseDate=System.today().adddays(20),Finance_Amount__c = 120,Amount = 0,
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true,
                                                discountsTotalOnPricing__c=null,Payment_Reference_Number__c='21');
        }
        insert opportunity;
         if(vatsecondoverride){
         quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                          POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted',Frozen_BM_Gross__c = 1000,newGrossPricingTotal__c =1100,
                                          bmstatusreason__c='Quote Finalised - Accepted',closeDate__c = system.today().addDays(150),newTotalNetPrice_quote__c = 1200,is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
         }else{
            quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                          POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted',Frozen_BM_Gross__c = 1000,newGrossPricingTotal__c =1100,
                                          bmstatusreason__c='Quote Finalised - Accepted',closeDate__c = date.newinstance(2011, 01, 01),newTotalNetPrice_quote__c = 1200,is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
         
            
         }
         insert quote;       
        Product2 product = new Product2(Name = 'P123456',First_VAT_Code__c = '1',First_VAT_Percent__c = 100);
        Quote_Product__c lineItem = new Quote_Product__c(Part_Number__c='P123456',Sales_Price__c=23.32,Product__c= product.id, Quantity__c=1.00,  BigMachines_Quote__c=quote.Id, Name='P123456');                              
        insert lineItem; 
        
        quote = [Select Name,Stage__c,newTotalNetPrice_quote__c,finalPriceVisibleToCustomer__c,newGrossPricingTotal__c,
                Frozen_BM_Gross__c,closeDate__c,VAT_17_5_Total_Amount__c,VAT_5_Total_Amount__c from BigMachines_Quote__c where id=:quote.id ];
                
        opportunity = [Select name,Finance_Amount__c,VAT1_Amount__c,VAT2_Amount__c,Bill_Period__c,Net_Contract_Price__c,New_Net_Contract_Price__c,
                        New_Net_Contract_Value__c,Price_Mismatch__c,Installation_Date_Billing__c from Opportunity where id=:opportunity.id];
       system.debug('Bill_Period__c-->'+opportunity.Bill_Period__c);
       system.debug('Installation_Date_Billing__c-->'+opportunity.Installation_Date_Billing__c);
       if(vatsecondoverride){       
         job = new Job__c(CHI_Lead__c = opportunity.Id,Quote__c=quote.Id, 
                        PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,Status__c='Pending',Sub_Status__c ='Awaiting Planning',
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                        Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today().addDays(200));
       }else{
        job = new Job__c(CHI_Lead__c = opportunity.Id,Quote__c=quote.Id, 
                        PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,Status__c='Pending',Sub_Status__c ='Awaiting Planning',
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                        Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());
       }
       insert job;
       
        job.Status__c = 'Planned';
        job.Sub_Status__c = 'Planned';
        update job;
        
       
        system.debug('Opportunity--->'+opportunity);
        system.debug('quote--->'+quote);
        job = [Select name,Original_Quote_Value__c,Address__c,Customer_Name__c,Primary_Contact__c,BalanceOutstanding__c,District_Name__c,
        Installation_Date__c,Sum_of_Payments__c,ASP_Addition__c,closeDate__c,ASP_Discount__c,ASP_Removal__c,Quote_Nett_Amount__c,InstallerName__c,
        Financed_Amount__c,VAT_Override_Period__c from Job__c where id=:job.id];
        system.debug('Job---->'+job);
        Payment_Collection__c obj_Payment= new Payment_Collection__c();
        obj_Payment=new Payment_Collection__c(Opportunity__c = opportunity.id, Account__c = account.id, ContactAddress__c = job.Address__c, 
                                              Job__c = job.id,ContactName__c=job.Customer_Name__c, Contact__c = job.Primary_Contact__c,
                                              Job_Special_ID__c = job.id + 'P1' , Balance_Outstanding__c = job.BalanceOutstanding__c, 
                                              District__c = job.District_Name__c, Job_Installation_Date__c = job.Installation_Date__c,
                                              Installer_Name__c = job.InstallerName__c, Sum_of_Payments__c = job.Sum_of_Payments__c,
                                              ASP_Addition__c = job.ASP_Addition__c, ASP_Discount__c = job.ASP_Discount__c,
                                              ASP_Removal__c = job.ASP_Removal__c, Original_Quote_Value__c = job.Original_Quote_Value__c,
                                              Quote_Nett_Amount__c = job.Quote_Nett_Amount__c, Payment_Collection_Status__c = 'Pending', 
                                              Financed_Amount__c = job.Financed_Amount__c);
        system.debug('cls_IsRun.isJobCompletion3' +cls_IsRun.isJobCompletion);
        insert obj_Payment;
        system.debug('cls_IsRun.isJobCompletion4' +cls_IsRun.isJobCompletion);
        cls_IsRun.isJobCompletion=false; 
        List<VAT_Codes__c> lstvat = new List<VAT_Codes__c>();
        VAT_Codes__c vat1 = new VAT_Codes__c (End_Date__c = system.today().adddays(500),Start_Date__c = system.today().adddays(101),VAT_Code_1__c ='1',
        VAT_Code_1_Rate__c = 20.0,VAT_Code_4__c = '4',VAT_Code_4_Rate__c = 5.0,Status__c = 'Active' ); 
        lstvat.add(vat1);
        VAT_Codes__c vat2 = new VAT_Codes__c (End_Date__c = system.today().adddays(100),Start_Date__c = system.today(),VAT_Code_1__c ='1',
        VAT_Code_1_Rate__c = 17.5,VAT_Code_4__c = '4',VAT_Code_4_Rate__c = 5.0,Status__c = 'Active' ); 
        lstvat.add(vat2);
        insert lstvat;
        lstvat = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,Status__c,start_date__c,
                                    end_date__c from VAT_Codes__c];
               
    }

    static testMethod void testfirsttest(){
        Test.startTest();
        preparedata();
        Test.stopTest();
        
    }
    static testMethod void testsecondtest(){
        Test.startTest();
        vatsecondoverride = false;
        vatoverride = false;
        vatoverridethird = true;
        preparedata();
        job.Installation_Date__c = system.today().adddays(100);
        update job;
        Test.stopTest();
        
    }
    static testMethod void testthirdtest(){
        Test.startTest();
        vatoverride = true;
        vatsecondoverride= false;
        vatoverridethird = false;
        preparedata();
        Test.stopTest();
        
    }
    static testMethod void testfourthtest(){
        Test.startTest();
        vatoverride = false;
        vatsecondoverride = true;
        vatoverridethird = false;
        preparedata();
        Test.stopTest();
        
    }
    
   static testMethod void newchange()
   {
     Account Acc = TestClassHelper.createAccout();
     insert Acc;
        
     Opportunity opp = TestClassHelper.createCHILead(Acc);
     opp.Amount=34.01;
     opp.closeDate__c=date.newInstance(2011, 01, 04);
     insert opp; 
     
     String overwrite='2011-01-04'; 
     
     BigMachines_Quote__c quote1 = TestClassHelper.createBMQuote(opp);
     quote1.POC_Payment_Option__c='Green Deal Finance';
     insert quote1 ; 
     
     District__c dist = TestClassHelper.createDistrict();
     insert dist;
        
    Job__c job1  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job1.Quote__c = quote1.Id;
    insert(job1);
    
    Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c(Opportunity__c=opp.Id);
    //gd.CC_Amount__c!=null
    //gd.LU_Amount_Payable__c=22.02;
    gd.CD_Amount__c=25.04;
    gd.Barclays_Amount__c=21.03;
    gd.GDF_Amount__c =24.01;
    gd.Eco_Funding__c=34.00;
    insert gd;
    
    Payment_Collection__c objpay=new Payment_Collection__c(Opportunity__c = opp.id, Account__c = Acc.id, ContactAddress__c = job1.Address__c, 
                                              Job__c = job1.id,ContactName__c=job1.Customer_Name__c, Contact__c = job1.Primary_Contact__c,
                                              Job_Special_ID__c = job1.id + 'P1' , Balance_Outstanding__c = job1.BalanceOutstanding__c, 
                                              District__c = job1.District_Name__c, Job_Installation_Date__c = job1.Installation_Date__c,
                                              Installer_Name__c = job1.InstallerName__c, Sum_of_Payments__c = job1.Sum_of_Payments__c,
                                              ASP_Addition__c = job1.ASP_Addition__c, ASP_Discount__c = job1.ASP_Discount__c,
                                              ASP_Removal__c = job1.ASP_Removal__c, Original_Quote_Value__c = job1.Original_Quote_Value__c,
                                              Quote_Nett_Amount__c = job1.Quote_Nett_Amount__c, Payment_Collection_Status__c = 'Pending', 
                                              Financed_Amount__c = job1.Financed_Amount__c);
        
     objpay.Customer_Contribution__c=gd.CC_Amount__c;
     objpay.Job_Installation_Date__c=date.newInstance(2010, 01, 04);
     insert objpay;
     
    VATchangecalculation.updatePCNASP(opp,objpay);

}  
    
      
}