/*
        Author          : Cognizant
        Functionality   : This is a Test class for the GasSafeController Class
        Create Date     : 26 July 2010
        Change History  :
        Modified Date   :
    */
@isTest
private class GasSafeController_test {

    static Account account;
    static Contact contact;
    static Employee__c employee ;
    static Opportunity opportunity;
    static Job__c job;
    static List<GasSafe_Report__c> lst_gas = new List<GasSafe_Report__c>();
    static testMethod void GasSafeReportMethod()
     {
        
        Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
        Database.insert(testDistrict);
        
        Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                    Type__c='Installation', District__c = testDistrict.ID);
        Database.insert(testSubPatch);
        
        Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'SK3 8', Description__c = 'Test Postcode Sector', 
                                                                        Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                        Sub_Patch__c = testSubPatch.ID);
        Database.insert(testPostcodeSector);
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='SK3 8EE',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
       contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='SK3 8EE',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id); 
        
        insert contact;
        account.Primary_Contact__c = contact.id;
        update account;
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
       
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1Electrician', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',salesforce_user__c = UInstal1.id,Role_Type__c='Electrician');
  
        insert emp;
        
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addyears(1),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                                    
                                                                
        insert opportunity;
        
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted',POC_Payment_Method__c = 'Cash',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,skillTotalWaterHeatingFixing__c=2.6,
                                                             skillTotalUnventedHotWater__c=2.6,skillTotalSpecialistBuilding__c=2.6,skillTotalScaffolder__c=2.6,skillTotalRoofWork__c=2.6,
                                                             skillTotalPaymentCollection__c=2.6,skillTotalMechanical__c=2.6,skillTotalLPGInstallation__c=2.6,skillTotalFireWallHeaterFixing__c=2.6,
                                                             skillTotalElectrical__c=2.6,skillTotalContractorInstallation__c=2.6,skillTotalConnectSolarPanels__c=2.6,skillTotalBuildingWork__c=2.6,
                                                             skillTotalPowerFlush__c=2.6,SkillTotalElectricalWorkASP__c=2.6,skillTotalAsbestosRemoval__c=2.6,skillTotalAsbestosRemovalFixedRate__c=2.6,
                                                             skillTotalSolar__c=2.6);
        insert quote;
        
        
        
        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id,District__c = testDistrict.id,
                                PowerFlush_Hours__c = 2.6, Building_Work_Hours__c = 2.6,Asbestos_Removal_Hours__c=2.6,Asbestos_Removal_Fixed_Rate_Hours__c=2.6,
                                Connect_Solar_Panel_Hours__c = 2.6, Contractor_Installation_Hours__c = 2.6,
                                Electrical_Hours__c = 2.6, Fire_Wall_Heater_Fixing_Hours__c = 2.6, LPG_Installation_Hours__c = 2.6,
                                Payment_Collection_Hours__c = 2.6, Roof_Work_Hours__c = 2.6,Mechanical_Hours__c=2.6,Electrical_Work_ASP_Hours__c=2.6,
                                Specialist_Building_Hours__c = 2.6, Unvented_Hot_Water_Hours__c = 2.6, Water_Heating_Fixing_Hours__c =  2.6, 
                                Customer_Preferred_Date__c = Date.today().adddays(-2), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),Type__c = 'Central Heating Installation');
                         
        
                        
        insert job;
        
        RMT_Supplier__c testSup = new RMT_Supplier__c();
        testSup.name = 'testSupplier';
        insert testSup;
        
        P5_RMT_Contractors__c con = new P5_RMT_Contractors__c();
        con.Supplier__c = testSup.Id;
        con.Name = 'test';
        insert con;
     
    //Adding Gas completion report
        String GasID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
    
        Commissioning_Report__c commissionreport1 = new Commissioning_Report__c(RecordtypeId=GasID,Report_Name__c= 'Gas Installation Works',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Installation_Notes__c = job.Job_Notes__c,Job_Special_ID__c = job.Id +'G1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c,Electrical_Employee__c=emp.Id,Electrical_Supplier__c=supplier.Id);
        cls_IsRun.isJobCompletion=false;
     insert commissionreport1;
    
     Appliance_at_Risk__c add1 = new Appliance_at_Risk__c(Gas_Inlet_Pressure_mbar__c = 2.3,Gas_Rate_kwh__c=1.2,Notes__c='testinf app..',
                                         Visual_Checks_Satisfaction__c= 'yes',Appliance_Type__c = 'Boiler',Manufacturer__c ='test',
                                         Location__c='bathroom',Work_Description__c ='Visual Check Only',Installation__c ='Visual Check Satisfactory',
                                         Ventilation__c ='yes',Flue__c = 'open',Current_Status__c='new',Compliance_Report__c =commissionreport1.id, COCO2_SingleHigh__c='TEST', CO2_SingleHigh__c='TEST',CO_ppm_SingleHigh__c= 'TEST'
                                         , Model__c = 'test', Serial_No__c= 'test' , GC_Number__c = 'test'); 
     insert add1;
    cls_IsRun.isJobCompletion=false;
    commissionreport1.Status__c = 'Completed';
    commissionreport1.Number_of_gas_appliances__c = 1;
    commissionreport1.Electrical_Resource__c = con.Id;
    update commissionreport1;
    //inserting new record
     GasSafe_Report__c  gassafereport = new GasSafe_Report__c(Serial_Number_6__c='12', Serial_Number_5__c='32',Serial_Number_4__c='34',
                                        Serial_Number_3__c='42',Serial_Number_2__c='14',Serial_Number_1__c='15',Location_6__c='location6',
                                        Location_5__c='location5',Location_4__c='location4',Location_3__c='location3',Location_2__c='location2',
                                        Location_1__c='location1',Job_Reference1__c=opportunity.Id ,GC_Number_6__c='GCNum6',GC_Number_5__c='GCNum5',
                                        GC_Number_4__c='GCNum4',GC_Number_3__c='GCNum3', GC_Number_2__c='GCNum2',GC_Number_1__c='GCNum1',
                                        Employee__c=emp.Id,Job__c=job.Id,Appliance__c = add1.id);
    
      insert  gassafereport;
      //adding to the List   
      lst_gas.add(gassafereport);
      //inserting another record
      GasSafe_Report__c  gassafereport1 = new GasSafe_Report__c(Serial_Number_6__c='12', Serial_Number_5__c='32',Serial_Number_4__c='34',
                                        Serial_Number_3__c='42',Serial_Number_2__c='14',Serial_Number_1__c='15',Location_6__c='location6',
                                        Location_5__c='location5',Location_4__c='location4',Location_3__c='location3',Location_2__c='location2',
                                        Location_1__c='location1',Job_Reference1__c=opportunity.Id ,GC_Number_6__c='GCNum6',GC_Number_5__c='GCNum5',
                                        GC_Number_4__c='GCNum4',GC_Number_3__c='GCNum3', GC_Number_2__c='GCNum2',GC_Number_1__c='GCNum1',
                                        Employee__c= null,Job__c=job.Id);
    
        insert  gassafereport1;
        lst_gas.add(gassafereport1);   
        GasSafe_Report__c  gassafereport2 = new GasSafe_Report__c(Job_Reference1__c=opportunity.Id ,Employee__c=emp.Id,Job__c=job.Id);
            
        gassafereport2.CreatedDate=System.today();
        insert  gassafereport2; 
        
        
                
        Test.startTest();    
      
      /*List<GasSafe_Report__c> lstDelGas = new List<GasSafe_Report__c>();
      for(List<GasSafe_Report__c> lstGasSafe :[Select Name,Title__c, Surname__c,Serial_Number_6__c, Serial_Number_5__c,Serial_Number_4__c,Serial_Number_3__c,Serial_Number_2__c,Serial_Number_1__c,Location_6__c,Location_5__c,Location_4__c,Location_3__c,Location_2__c,Location_1__c,Job_Reference1__c,
                                        GSLicense__c,GC_Number_6__c,GC_Number_5__c,GC_Number_4__c,GC_Number_3__c, GC_Number_2__c,GC_Number_1__c,Fix_Date__c,First_Name__c,Employee__c,Job__c,Delivery_Address_Reason__c,Del_Post_code__c,Post_Code__c,Del_Cust_Addr4__c,Del_Cust_Addr3__c,
                                        Del_Cust_Addr2__c,Del_Cust_Addr1__c,Business_ID__c, Appliance__c,Appliance_6__c,Appliance_5__c,Appliance_4__c,Appliance_3__c,Appliance_2__c,Addr_4__c,Addr_3__c,Addr_2__c,Addr_1__c,Employee__r.Name,Appliance_2__r.Name,Appliance_3__r.Name,Appliance_4__r.Name,Appliance_5__r.Name,Appliance_6__r.Name,Appliance__r.Name,Job_Reference1__r.Name,Job__r.Name From GasSafe_Report__c where CreatedDate = Last_N_Days:7])
      {   
        lstDelGas.addAll(lstGasSafe);
      }               
      
       if(lstDelGas.size() > 0) lstDelGas.remove(0);
        
       if(lstDelGas.size() > 0) delete lstDelGas;*/
       
        PageReference pageRef = new PageReference('/apex/GasSafeReport');
        Test.setCurrentPage(pageRef);     
        Compliance_Report__c compliance_report = new Compliance_Report__c();   
        //Product_Materials__c promaterial = new Product_Materials__c();
        compliance_report.Start_Date__c=System.today().Adddays(-1);
        system.debug('compliance_report.Start_Date__c------'+compliance_report.Start_Date__c);
        compliance_report.End_Date__c=System.today();
        system.debug('compliance_report.Start_Date__c------'+compliance_report.End_Date__c);
        //compliance_report.Material_Code__c='1';
        //promaterial.Quantity__c=1.0;                             
        GasSafeConroller gassafe = new GasSafeConroller();
        gassafe.dateObj = compliance_report;
        gassafe.CreateReport();
        gassafe.IsGenerate = true; 
        gassafe.dateObj = compliance_report;
           
      Test.stopTest();
     }
     
     
}