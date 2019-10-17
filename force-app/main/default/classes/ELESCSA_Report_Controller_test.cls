/*
        Author          : Cognizant
        Functionality   : This is a Test class for the ELESCSA Controller Class
        Create Date     : 26 July 2010
        Change History  :
        Modified Date   :
    */
@isTest
private class ELESCSA_Report_Controller_test {

    static Account account;
    static Contact contact;
    static Employee__c employee ;
    static Opportunity opportunity;
    static Job__c job;
    static List<ELESCSA__c> lst_ele = new List<ELESCSA__c>();
    static testMethod void ElescaReportMethod()
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
       
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',salesforce_user__c = UInstal1.id);
  		emp.End_Date__c=system.today();
  		emp.Start_Date__c=system.today();
  		emp.Postcode__c='12';
  		//emp.X1st_Assessment__c = system.today();
  		emp.Reason_for_Leaving__c = 'Leaving';
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
                         
        
        job.Named_Employee__c=emp.Id;                
        insert job; 
       //Adding minor electrical report
    String minorID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Minor Electrical Installation');
    
    Commissioning_Report__c commissionreport1 = new Commissioning_Report__c(RecordtypeId=minorID,Report_Name__c= 'Minor Electrical Installation',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Installation_Notes__c = job.Job_Notes__c,Job_Special_ID__c = job.Id +'M1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c, Line_Neutral_earth__c = 'test');
    cls_IsRun.isJobCompletion=false;
    insert commissionreport1;
    
    cls_IsRun.isJobCompletion=false;
    commissionreport1.Status__c = 'Completed';
    update commissionreport1;
    //inserting new record
           
        ELESCSA__c elesca = new ELESCSA__c();
        elesca.Employee__c =emp.id;
        elesca.YourJobReference__c=opportunity.id; 
        elesca.Job__c=job.id;
        insert elesca;
        lst_ele.add(elesca);
        
        
        Test.startTest(); 
            
        /*List<ELESCSA__c> lstDelElecsa = new List<ELESCSA__c>();
        for(List<ELESCSA__c> lstElecsa : [Select Name,YourNotes__c,YourJobReference__c,YourCertificateNumber__c,PostalPostcode__c,Job__c,YourJobReference__r.Name,Job__r.Name,Employee__c,Employee__r.Name,
                                    DwellingTown__c,DwellingPostcode__c,DwellingHouseNumberOrName__c,DwellingCounty__c,ContractorAmount__c,ContractStartDate__c,
                                    ContractEndDate__c,CertificateRecipientLastName__c,CertificateRecipientFirstName__c From ELESCSA__c where CreatedDate = Last_N_Days:7])
        {
            lstDelElecsa.addAll(lstElecsa);
        }
        
        
        
        
        if(lstDelElecsa.size() > 0) lstDelElecsa.remove(0);
        
        if(lstDelElecsa.size() > 0) delete lstDelElecsa;
        */
        //Product_Materials__c promaterial = new Product_Materials__c();
        Compliance_Report__c compliance_report = new Compliance_Report__c();
     	compliance_report.Start_Date__c=System.today().Adddays(-1);
     	system.debug('compliance_report.Start_Date__c------'+compliance_report.Start_Date__c);
     	compliance_report.End_Date__c=System.today();
     	system.debug('compliance_report.Start_Date__c------'+compliance_report.End_Date__c);
     	
     	
     	//insert promaterial;
        
        //Test.setCurrentPage(new PageReference(PageReference.ELESCSA_Report));
        PageReference pageRef = new PageReference('/apex/ELESCSA_Report');
        Test.setCurrentPage(pageRef);
        ELESCSA_Report_Controller elescareport = new ELESCSA_Report_Controller();
       
        elescareport.dateObj = compliance_report;
        elescareport.CreateReport();
        elescareport.IsGenerate = true;
        elescareport.dateObj = compliance_report;
        Test.stopTest();
    }
    
    
    static testMethod void ElescaReportwithoutdata()
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
       
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',salesforce_user__c = UInstal1.id);
  		emp.End_Date__c=system.today();
  		emp.Start_Date__c=system.today();
  		emp.Postcode__c='12';
  		//emp.X1st_Assessment__c = system.today();
  		emp.Reason_for_Leaving__c = 'Leaving';
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
                         
        
        job.Named_Employee__c=emp.Id;                
        insert job; 
       //Adding minor electrical report
    	String minorID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Minor Electrical Installation');
    
   	 	Commissioning_Report__c commissionreport1 = new Commissioning_Report__c(RecordtypeId=minorID,Report_Name__c= 'Minor Electrical Installation',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Installation_Notes__c = job.Job_Notes__c,Job_Special_ID__c = job.Id +'M1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c, Line_Neutral_earth__c = 'test');
   		cls_IsRun.isJobCompletion=false;
   	 	insert commissionreport1;
    
	    cls_IsRun.isJobCompletion=false;
	    commissionreport1.Status__c = 'Completed';
	    update commissionreport1;
   		 //inserting new record
           
        ELESCSA__c elesca = new ELESCSA__c();
        //elesca.Employee__c =emp.id;
        //elesca.YourJobReference__c=opportunity.id; 
        //elesca.Job__c=job.id;
        insert elesca;
        //lst_ele.add(elesca);
        
        
        Test.startTest(); 
            
        /*List<ELESCSA__c> lstDelElecsa = new List<ELESCSA__c>();
        for(List<ELESCSA__c> lstElecsa : [Select Name,YourNotes__c,YourJobReference__c,YourCertificateNumber__c,PostalPostcode__c,Job__c,YourJobReference__r.Name,Job__r.Name,Employee__c,Employee__r.Name,
                                    DwellingTown__c,DwellingPostcode__c,DwellingHouseNumberOrName__c,DwellingCounty__c,ContractorAmount__c,ContractStartDate__c,
                                    ContractEndDate__c,CertificateRecipientLastName__c,CertificateRecipientFirstName__c From ELESCSA__c where CreatedDate = Last_N_Days:7])
        {
            lstDelElecsa.addAll(lstElecsa);
        }
        
        
        
        
        if(lstDelElecsa.size() > 0) lstDelElecsa.remove(0);
        
        if(lstDelElecsa.size() > 0) delete lstDelElecsa;
        */
        //Product_Materials__c promaterial = new Product_Materials__c();
        Compliance_Report__c compliance_report = new Compliance_Report__c();
     	compliance_report.Start_Date__c=System.today().Adddays(-1);
     	system.debug('compliance_report.Start_Date__c------'+compliance_report.Start_Date__c);
     	compliance_report.End_Date__c=System.today();
     	system.debug('compliance_report.Start_Date__c------'+compliance_report.End_Date__c);
     	
     	
     	//insert promaterial;
        
        //Test.setCurrentPage(new PageReference(PageReference.ELESCSA_Report));
        PageReference pageRef = new PageReference('/apex/ELESCSA_Report');
        Test.setCurrentPage(pageRef);
        ELESCSA_Report_Controller elescareport = new ELESCSA_Report_Controller();
       
        elescareport.dateObj = compliance_report;
        elescareport.CreateReport();
        elescareport.IsGenerate = true;
        elescareport.dateObj = compliance_report;
        Test.stopTest();
    }
    
    
    
}
     	
     	/*ELESCSA__c elesca = new ELESCSA__c();
     	elesca.CreatedDate=System.today();
     	system.debug('promaterial.Start_Date__c------'+elesca.CreatedDate);
     	//elesca.CreatedDate=System.today();
     	//elesca.ContractStartDate__c=System.today();
     	//elesca.ContractEndDate__c=System.today()+1;
     	//elesca.PostalPostcode__c='12';
     	elesca.Employee__c=emp.Id;
     	elesca.Job__c=job.Id;
     	insert elesca;
     	
     	
     	
     	
     	Product_Materials__c promaterial = new Product_Materials__c();
     	promaterial.Start_Date__c=System.today().Adddays(-1);
     	system.debug('promaterial.Start_Date__c------'+promaterial.Start_Date__c);
     	promaterial.End_Date__c=System.today()+7;
     	system.debug('promaterial.Start_Date__c------'+promaterial.End_Date__c);
     	promaterial.Material_Code__c='1';
     	promaterial.Quantity__c=1.0;
     	//insert promaterial;
     	
     	
        ELESCSA_Report_Controller elescareport = new ELESCSA_Report_Controller();
        elescareport.dateObj = promaterial;
        elescareport.CreateReport();
        elescareport.IsGenerate = true;
        
        
    }
}*/