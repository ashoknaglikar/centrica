@isTest
private class NBBSInterfaceController_Test 
{
    static Installation_Billing__c inst_bill;
    static SFNB7521_Batch__c SFNBbatch;
    static Job_Description_Record__c Jobdesc;
    static List<Job_Description_Record__c> Jobdesclst;
    static List<Installation_Billing__c> inst_bill_Lst;
    static Account account;
    static Contact contact;
    static Opportunity opportunity, opportunity1;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Job__c job;
    static Quote_Product__c quoteProduct;
    static List<BigMachines_Quote__c> quoteList;
    static user BM = [Select Id from User where Id =:system.label.BM_UserId];
    //static NIAS_Code__c Nias;
    static void setTestData() 
    {
    	System.runAs(BM)
    	{
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
                                    
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
        
        insert contact;
          
        Supplier__c supplier = new Supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer', Emp_type__c = 'S');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',Emp_type__c='S',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        //NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];
        /*Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c='12', WRK_TYPE__c='123',
                   INCOME_CODE__c=323, INSTALLER__c='1', OTH_CODE__c=123, PYMT_CODE__c='123', RESOURCE_TYPE__c=emp.Emp_type__c, 
                   WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                   insert Nias;*/
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), Payment_Reference_Number__c = '845088998899',
                                                  AccountId=account.Id,Platform__c='SFDC', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false, Payment_Method__c = 'Cash',Bill_Period__c ='After  04/01',Installation_Date_Billing__c = '2010-12-31');
                                                    
        opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), Payment_Reference_Number__c = '853088998899',
                                                AccountId=account.Id, Platform__c = 'SFDC', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true, Payment_Method__c = 'Cash',Bill_Period__c ='Before  04/01',Installation_Date_Billing__c ='2011-01-04');
        opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c='test - ' + emp.Employee_Number__c, createdDate_quote__c = System.today(),
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                                             priceMatchDifference__c = -45, ISpec_Difference__c = 45, Pricebook_Id__c='CHX');
                                                                     
        insert quote;
        quote.Pricebook_Id__c='CHX';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;
        
        quoteList = new List<BigMachines_Quote__c>();
        quoteList.add(quote);
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =1.00, GrossSingle__c = 15.5,  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='1');
                                                            
        Quote_Product__c quoteProduct1 = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =4.00, GrossSingle__c = 20.5,
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=200,Quantity__c=10,VAT_Code__c='4');                                                
                                                            
        Quote_Product__c quoteProduct2 = new Quote_Product__c(Product__c=product.Id, FirstVATCode__c =1.00, GrossSingle__c = 15.73,
                                                            Part_Number__c='ABC124', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123', Sales_Price__c=200, Quantity__c=10,VAT_Code__c='1');
                                                                                                                        
        insert product;
        insert new List<Quote_Product__c>{quoteProduct, quoteProduct1, quoteProduct2};
        
        
        Region__c region = new Region__c(Code__c='25',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
            insert region;
            
            
            District__c district = new District__c();
            district.Code__c='4411';
            district.Name='sambroun';
            district.Region__c=region.Id;
            insert district;
            system.debug(district.Region__c+'%%%');
            
            Sub_Patch__c SubPatch = new Sub_Patch__c();
            SubPatch.Name='4411';
            SubPatch.Code__c='441111';
            SubPatch.District__c=district.Id;
            SubPatch.Type__c='Installation';
            insert SubPatch;
            system.debug('postdistrict'+SubPatch.District__c);
             
             Postcode_Sector__c PtCodeSect =  new Postcode_Sector__c();
             PtCodeSect.Name='4411';
             PtCodeSect.Code__c='441111';
             PtCodeSect.Sub_Patch__c=SubPatch.Id;
             PtCodeSect.Type__c='Installation';
             insert PtCodeSect;
            system.debug('postsector'+PtCodeSect.Sub_Patch__c);
            
            job = new Job__c(CHI_Lead__c = opportunity.ID, Quote__c=quote.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                            Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
                            Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
                            Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
                            Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                            Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
            
                
        insert job;
        Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        Diary_Entry__c DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id);
        insert DEntry;
        Week__c week1 = new Week__c(Employee__c=emp1.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week1;
        Diary_Entry__c DEntry1 = new Diary_Entry__c(Employee__c=emp1.Id,Week__c=week1.Id);
        insert DEntry1;

        SFNBbatch = new SFNB7521_Batch__c();
        insert SFNBbatch;
        
        inst_bill = new Installation_Billing__c();
        inst_bill.Job_Completion_Date__c=system.today();
        inst_bill.SFNB7521_Batch__c=SFNBbatch.Id;
        inst_bill.Big_Machine_Quote__c=quote.Id;
        insert inst_bill;
        
        inst_bill_Lst= new List<Installation_Billing__c>();
        inst_bill_Lst.add(inst_bill);
        
        Jobdesc = new Job_Description_Record__c();
        Jobdesc.Name='testjobdesc';
        Jobdesc.Installation_Billing__c=inst_bill.Id;
        Jobdesc.Vat_Code__c='D';
        insert Jobdesc;
        
        Jobdesclst = new List<Job_Description_Record__c>();
        Jobdesclst.add(Jobdesc);
        
        job = [select CHI_Lead__c ,Quote__c,PowerFlush_Hours__c, Building_Work_Hours__c,
                            Connect_Solar_Panel_Hours__c, Contractor_Installation_Hours__c,Electrical_Hours__c,Is_Remedial_Job__c, 
                            Fire_Wall_Heater_Fixing_Hours__c, LPG_Installation_Hours__c,Is_Downtime_Job__c ,
                            Payment_Collection_Hours__c, Roof_Work_Hours__c,Specialist_Building_Hours__c, Unvented_Hot_Water_Hours__c,
                            Water_Heating_Fixing_Hours__c,Customer_Preferred_Date__c, Contractors__c, Own_Labour__c,
                            District__c,
                            Double_Handed_Job__c, Region_Code__c, Delivery_Date__c,Installation_Date__c from Job__c where id =:job.Id]; 
            
        
        NIAS_Code__c Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c=job.Region_Code__c, WRK_TYPE__c=quote.Pricebook_Id__c,
                       INCOME_CODE__c=323, INSTALLER__c='C', OTH_CODE__c=123, PYMT_CODE__c='Finance', RESOURCE_TYPE__c=emp.Emp_type__c, 
                       WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                       
        NIAS_Code__c Nias2 = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c=job.Region_Code__c, WRK_TYPE__c=quote.Pricebook_Id__c,
                   INCOME_CODE__c=323, INSTALLER__c='C', OTH_CODE__c=123, PYMT_CODE__c='Cash', RESOURCE_TYPE__c=emp.Emp_type__c, 
                   WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                   
        System.debug('quote.Pricebook_Id__c');
        List<NIAS_Code__c> lstNias  = new List<NIAS_Code__c>{Nias, Nias2};
        insert lstNias ;
        System.debug('--------------- lstNias ' + lstNias);
        
        List<VAT_Codes__c> lstVats = new List<VAT_Codes__c>();
        
        VAT_Codes__c vat1 = new VAT_Codes__c (End_Date__c = system.today().adddays(500),Start_Date__c = system.today().adddays(101),VAT_Code_1__c ='1',
        VAT_Code_1_Rate__c = 20.0,VAT_Code_4__c = '4',VAT_Code_4_Rate__c = 5.0,Status__c = 'Active' ); 
		lstvats.add(vat1);
		VAT_Codes__c vat2 = new VAT_Codes__c (End_Date__c = system.today().adddays(100),Start_Date__c = system.today(),VAT_Code_1__c ='1',
        VAT_Code_1_Rate__c = 17.5,VAT_Code_4__c = '4',VAT_Code_4_Rate__c = 5.0,Status__c = 'Active' ); 
        lstvats.add(vat2);
        
        insert lstVats;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;
    	}
        
    }
    
    
    static testMethod void Test_Installation_BillingWithPaperwork()
    {
        setTestData();              
        //delete quoteProduct;
        System.debug('-------------- test Test_Installation_BillingWithPaperwork');
        List<BigMachines_Quote__c> lstQuote = [select id, name, createdDate_quote__c, 
        Number_of_paperworks_recieved__c,
        Opportunity__r.Platform__c,
        Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
        Opportunity__r.Account.Primary_Contact__r.Salutation,
        Opportunity__r.Account.Primary_Contact__r.FirstName,
        Opportunity__r.Account.Primary_Contact__r.LastName,
        Opportunity__r.Account.BillingStreet,
        Opportunity__r.Account.BillingCity,
        Opportunity__r.Account.BillingState,
        Opportunity__r.Account.BillingPostalCode,
        Opportunity__r.Account.Primary_Contact__r.MailingCity,
        Opportunity__r.Account.Primary_Contact__r.MailingState,
        Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
        Opportunity__r.Account.Primary_Contact__r.MailingStreet,
        Opportunity__r.Payment_Reference_Number__c,
        Opportunity__r.Override_Billing_checks__c,
        Opportunity__r.discountsTotalOnPricing__c,
        Opportunity__r.Manual_Bill__c,
        Opportunity__r.Bill_to_Office__c,
        VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
        VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
        Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
        priceMatchDifference__c,ISpec_Difference__c, 
        (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
        (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
        (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
        from  BigMachines_Quote__c where 
        id = :quote.ID and quote_reconciled__c =: True]; 
        
        System.debug('------------- test quote = ' + lstQuote);
        
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        
        //instantiate the controller class
        NBBSInterfaceController nbbsInterface = new NBBSInterfaceController();
        nbbsInterface.blMultiple = false;
        nbbsInterface.InsertData();
        
        //nbbsInterface.getServiceLineInformation();
    
    }
    
        static testMethod void QuoteNIASCode()
    {
        setTestData();              
        //Quote having paperwork
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        Pagereference pageRef1 = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('s',opportunity1.Id);
         
        NBBSInterfaceController nbbsInterface1 = new NBBSInterfaceController(opp);
        nbbsInterface1.BillType='Yes';
        nbbsInterface1.blMultiple = true;
        nbbsInterface1.InsertData();
         //nbbsInterface1.getQuoteNIASCode();       
    }
    
    static testMethod void Test_Bulk_Installation_Billing()
    {
        setTestData();              
        //Quote having paperwork
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        Pagereference pageRef1 = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('s',opportunity1.Id);
         
        NBBSInterfaceController nbbsInterface1 = new NBBSInterfaceController(opp);
        nbbsInterface1.blMultiple = true;
       
        nbbsInterface1.insertMultipleData();       
    }
    
    static testMethod void View_Check_True_No_Paperwork()
    {
        setTestData();
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
    }

    static testMethod void View_Check_True_With_Paperwork()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
    }
    
    static testMethod void Check_Finance_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'Finance';
        update quote;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
    }
    
    static testMethod void Check_Hitachi_Finance_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'Finance';
        quote.POC_Payment_Option__c = 'Hitachi';        
        update quote;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
    }
    
    static testMethod void Check_Barclays_Finance_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
               
        quote.POC_Payment_Method__c = 'Finance';
        quote.POC_Payment_Option__c = 'Barclays';
        quote.newPriceMatchDifference__c = null;
        quote.PriceMatchDifference__c = 1;        
        update quote;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
    }
    
    static testMethod void Check_GreenDeal_Finance_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'Finance';
        quote.POC_Payment_Option__c = 'GreenDeal';        
        update quote;
        
        Jobdesc.Vat_Code__c='D';
        update Jobdesc;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
        nbbsInterface7.getQuoteNIASCode();
        nbbsInterface7.getServiceLineInformation();
    }
     static testMethod void Check_LinkFinance_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'Finance';
        quote.POC_Payment_Option__c = System.Label.LinkFinance_Name;        
        update quote;
        
        Jobdesc.Vat_Code__c='D';
        update Jobdesc;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface8 = new NBBSInterfaceController();   
        nbbsInterface8.getlstJobDescriptionRecord();
        
        nbbsInterface8.InsertData();
        nbbsInterface8.getQuoteNIASCode();
        nbbsInterface8.getServiceLineInformation();
    }
    static testMethod void Check_BillToOffice_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'test';
        update quote;
        
        opportunity.Bill_to_Office__c = true;
        update opportunity;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
        nbbsInterface7.getQuoteNIASCode();
    }
    
     static testMethod void Check_BillToContact_Payment_for_Billing()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'test';
        update quote;
        
        opportunity.StageName = 'Expired';
        opportunity.Stage_Reason__c = 'test';
        opportunity.Stage_Reason_CHICR__c = 'test';
        update opportunity;
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
        nbbsInterface7.getQuoteNIASCode();
    }
    
    static testMethod void Check_Hitachi_Finance_Payment_Bill_to_Office()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        opportunity.Bill_to_Office__c = true;
        opportunity1.Bill_to_Office__c = true;
        opportunity.Bill_Period__c ='Before 04/01';
        opportunity.Installation_Date_Billing__c = '2010-12-31';
        update opportunity; 
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController(opp);   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
        
        //nbbsInterface7.getQuoteNIASCode();
        nbbsInterface7.getnewInstallationBilling();
    }
    
    static testMethod void Check_Billing_Job_in_Premier()
    {
        setTestData();
        Paperwork_Recieved_Details__c paperWork = new  Paperwork_Recieved_Details__c(Big_Machines_Quote__c = quote.Id, Sales_Paperwork_Validated_Date__c = System.today(),Additional_Information__c = 'Test Data');
        insert paperWork;
        
        quote.POC_Payment_Method__c = 'Finance';
        update quote;
        
        opportunity.Platform__c = 'Premier';
        update opportunity; 
        
        Pagereference pageRef = Page.NBBSInterfacePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('s',opportunity.Id);
        ApexPages.currentPage().getParameters().put('t','1');
        
        NBBSInterfaceController nbbsInterface7 = new NBBSInterfaceController();   
        nbbsInterface7.getlstJobDescriptionRecord();
        
        nbbsInterface7.InsertData();
        
        //nbbsInterface7.getQuoteNIASCode();
        nbbsInterface7.getnewInstallationBilling();
    }
    
    
    
}