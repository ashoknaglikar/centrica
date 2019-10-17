@isTest
private class aUPD_MIReports_test {
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Supplier__c supplier1;
    static Employee__c emp;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
    static Job__c job1;
    static Job_Element__c JE;
    static Job_Element__c JE1;
    static Order__c ord; 
    static Order__c ord1;
    static Order_Line_Item__c OrdLine;
    static Rate_Card__c Rate_card;
    static Post_Code_Rate_Card__c Post_Rate_Card;
    static Rate_Card_Items__c Ratecarditems;
    static Post_Code_Rate_Card__c PostcodeRC;
    static Postcode_Sector__c Postcodesector;
    static Sub_Patch__c  subpatch;
    static List<Order__c> ordlst;
    static List<Order__c>ordlst1;
    static List<Order_Line_Item__c> Ordlinelst;

    static testMethod void aUPD_MIReportsTestMethod() {
     
         account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Resource');
       
        insert supplier;
        
        supplier1 = new supplier__c(Name='Test supplier2',Type__c='Resource',Supplier_Num__c='B1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Resource');
        insert supplier1;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;*/
                
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
        insert job;
     
                
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        // ord.Order_Date__c.format();
        insert ord;
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
        
        Job_Element__c JE2 = new Job_Element__c();
        JE2.Job__c = job.Id;
        JE2.Type__c='Work';
        JE2.New_Supplier__c=null;
        JE2.Order__c=ord.Id;
        JE2.New_Supplier_Number__c= '1233';
        JE2.Current_Supplier__c='CSupplier1';
        JE2.Current_Supplier_Number__c='321';
        JE2.Code__c='345';
        JE2.Supplier_Order_Number__c='1212';
        JE2.Status__c='Removed';
        JE2.Sub_Status__c='Awaiting Order';
        JE2.Description__c='testDescription';
        JE2.Line_Item_ID__c='124';
        JE2.Skill__c='Scaffolder';
        JE2.Units__c=125;
        insert JE2;
        List<Job_Element__c> JEList_Work1 =new List<Job_Element__c>();
        JEList_Work1.add(JE2);
             
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        update ord; 
        
        RMT_Supplier__c testSup = new RMT_Supplier__c();
        testSup.name = 'testSupplier';
        insert testSup;
        
        P5_RMT_Contractors__c con = new P5_RMT_Contractors__c();
        con.Supplier__c = testSup.Id;
        con.Name = 'test';
        insert con;
      
      
        Id gasCommReportRecordTypeId = null;
        Id eleCommReportRecordTypeId = null;
        List<Id> IdList=new List<Id>(); 
        gasCommReportRecordTypeId = [Select r.Id From RecordType r where r.Name='Gas Installation Works' 
        							and SobjectType = 'Commissioning_Report__c' limit 1].Id; 
       
        
       //cls_IsRun.isJobCompletion = true;
     	system.debug('1-cls_IsRun.isJobCompletion' +cls_IsRun.isJobCompletion);
        Commissioning_Report__c comReport = new Commissioning_Report__c(Job_Number__c=job.Id,RecordTypeId = gasCommReportRecordTypeId ,Status__c ='Incomplete');
        insert comReport;
        //cls_IsRun.isJobCompletion = true;
        system.debug('1-cls_IsRun.isJobCompletion' +cls_IsRun.isJobCompletion);
        system.debug('--comReport' +comReport.Status__c);
        
        
        Appliance_at_Risk__c appliance1 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test8',Model__c = 'I87',Manufacturer__c ='90',Installation__c = 'At Risk', Gas_Rate_kwh__c = 12.00,
        								 Gas_Inlet_Pressure_mbar__c =1.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler', ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance1;
        Appliance_at_Risk__c appliance2 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test9',Model__c = 'I87',Manufacturer__c ='90',Installation__c = 'At Risk', Gas_Rate_kwh__c = 12.00,
        								 Gas_Inlet_Pressure_mbar__c =1.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance2;
        Appliance_at_Risk__c appliance3 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test5',Model__c = 'I87',Manufacturer__c ='90',Installation__c = 'At Risk', Gas_Rate_kwh__c = 12.00,
        								 Gas_Inlet_Pressure_mbar__c =1.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance3;
        Appliance_at_Risk__c appliance4 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'TEST#',Model__c = 'I87',Manufacturer__c ='90',Installation__c = 'At Risk', Gas_Rate_kwh__c = 12.00,
        								 Gas_Inlet_Pressure_mbar__c =1.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance4;
        Appliance_at_Risk__c appliance5 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test7',Model__c = 'I87',Manufacturer__c ='90',Installation__c = 'At Risk', Gas_Rate_kwh__c = 12.00,
        								 Gas_Inlet_Pressure_mbar__c =1.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance5;
        Appliance_at_Risk__c appliance6 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test1',Model__c = 'I87',Manufacturer__c ='PT',Installation__c = 'At Risk', Gas_Rate_kwh__c = 17.00,
        								 Gas_Inlet_Pressure_mbar__c =8.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance6;
        Appliance_at_Risk__c appliance7 = new Appliance_at_Risk__c(Working_Pressure_mbar__c = 1.00,Work_Description__c = 'Worked On & Tested',
        								 Location__c='location1', Serial_No__c='123', Ventilation__c = 'Yes',
        								 Notes__c = 'test4',Model__c = 'I87',Manufacturer__c ='LO',Installation__c = 'At Risk', Gas_Rate_kwh__c = 19.00,
        								 Gas_Inlet_Pressure_mbar__c =14.00 ,Flue__c='Open Flue',GC_Number__c = '1234',Current_Status__c = 'New',Compliance_Report__c =comReport.id,
        								 Appliance_Type__c = 'Boiler',ID_At_Risk_Procedure_Followed__c= TRUE, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST');        
        insert appliance7;
        
        cls_IsRun.isJobCompletion = false;
        system.debug('1-cls_IsRun.isJobCompletion' +cls_IsRun.isJobCompletion);
        comReport.Date__c = system.today();
        comReport.Have_You_Worked_on_the_Gas__c = 'No';
        comReport.Number_of_Installers__c = 1;
        comReport.Installer_Names__c = 'sant-test';            
        comReport.Status__c ='Completed';
        comReport.Number_of_gas_appliances__c= 25;
        comReport.Electrical_Resource__c = con.Id;
        comReport.Line_Neutral_earth__c = 'testLine';
        update comReport;
        
        system.debug('1-cls_IsRun.isJobCompletion' +cls_IsRun.isJobCompletion);
        system.debug('--comReport' +comReport.Status__c);
        
       /* ELESCSA__c ELESCSAobj=new ELESCSA__c();
        ELESCSAobj.Employee__c=emp.Id;
        ELESCSAobj.Job__c=comReport.Job_Number__c;
        insert ELESCSAobj;
        
        List<ELESCSA__c> ELESCSAlist = new List<ELESCSA__c>();
        ELESCSAlist.add(ELESCSAobj);
        
        GasSafe_Report__c gasSafeReportObj = new GasSafe_Report__c();
        gasSafeReportObj.Employee__c=emp.Id;
        gasSafeReportObj.Job__c=comReport.Job_Number__c;
        //
        insert gasSafeReportObj;
        
        List<GasSafe_Report__c> gasSafeList = new List<GasSafe_Report__c>();
        gasSafeList.add(gasSafeReportObj); */
        
        //ele
        //cls_IsRun.isJobCompletion = true;
        eleCommReportRecordTypeId = [Select r.Id From RecordType r where r.Name='Minor Electrical Installation' 
        							and SobjectType = 'Commissioning_Report__c' limit 1].Id; 
        							
        Commissioning_Report__c comReport1 = new Commissioning_Report__c(Job_Number__c=job.Id,RecordTypeId = eleCommReportRecordTypeId, Status__c='Incomplete',Line_Neutral_earth__c = 'testLine');
        //RecordTypeName__c='Gas Installation Works'
        insert comReport1;
        cls_IsRun.isJobCompletion = false;
        comReport1.Status__c = 'Completed';
        update comReport1;

        
    }
}