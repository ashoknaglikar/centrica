@isTest
Private class NIASCodeHelper_Test
{
	static List<BigMachines_Quote__c> quoteList=new List<BigMachines_Quote__c>();
	static void CreateTestData()
    {
             Account account; 
             List<String> oppResourceTypeMap = new List<String>();      
             Contact contact;    
             Employee__c emp ;         
             Opportunity opportunity,opportunity1 ;
             List<ID> CHILeadList = new List<ID>();
             List<String> quoteIDList = new List<String>(); 
             String region_code;
            
            account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');        
            insert account;        // Insert mandatory fields in the Account                          
            
            contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',FirstName='First name',Email='test@gmail.com',AccountId=account.Id);             
            insert contact;        // Insert mandatory fields in the Contact                        
            
            emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0002991');        
            insert emp;
            emp.Emp_type__c='S';
            emp.Resource_Type__c ='SA';
            emp.Group__c='INST';
            update emp;        // Insert mandatory fields in the Employee custom object                  
            Employee__c emp1 = [select id,Name,Emp_type__c,Group__c,Resource_Type__c,Last_Name__c,Employee_Number__c,First_Name__c from Employee__c where name != null and Emp_type__c != null and Group__c=: 'INST' limit 1];        //Retrive details of employee to insert new opportunity                    
            System.debug(' the emp1 is '+emp1);
            opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id, Payment_Method__c = 'Cash');          
            insert (opportunity); 
            
           //  NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];
            
             //insert Nias;
          
                                
           
            BigMachines_Quote__c quote1= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,POC_Payment_Method__c = 'Finance',App_Assigned_To__c= 'test - ' + emp1.Employee_Number__c,Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000, Pricebook_Id__c='123');
            //quote1.App_Assigned_To__c=emp.Id;
            insert quote1;
            
            
            
            quote1 = [select id, name, createdDate_quote__c, 
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
	        id = :quote1.ID];
            
            
            quoteList.add(quote1);
            List<String> oppResourceTypeMap2 = new List<String>();
            
            Region__c region = new Region__c(Code__c='2',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
            insert region;
            District__c district = new District__c();
            district.Code__c='4411';
            district.Name='sambroun';
            district.Region__c=region.Id;
            insert district;
            system.debug(district.Region__c+'%%%');
            
			Job__c job = new Job__c();        
			job = new Job__c(CHI_Lead__c = opportunity.ID, Quote__c=quote1.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
			                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
			                Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
			                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
			                Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
			                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
			
			job.District__c=district.Id;
			 
			
			insert job; 
            
             
             job = [select CHI_Lead__c ,Quote__c,PowerFlush_Hours__c, Building_Work_Hours__c,
                            Connect_Solar_Panel_Hours__c, Contractor_Installation_Hours__c,Electrical_Hours__c,Is_Remedial_Job__c, 
                            Fire_Wall_Heater_Fixing_Hours__c, LPG_Installation_Hours__c,Is_Downtime_Job__c ,
                            Payment_Collection_Hours__c, Roof_Work_Hours__c,Specialist_Building_Hours__c, Unvented_Hot_Water_Hours__c,
                            Water_Heating_Fixing_Hours__c,Customer_Preferred_Date__c, Contractors__c, Own_Labour__c,
                            District__c,
                            Double_Handed_Job__c, Region_Code__c, Delivery_Date__c,Installation_Date__c from Job__c where id =:job.Id]; 
            
            
            System.debug('------------------- job = ' + job);
             
             
            NIAS_Code__c Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c=job.Region_Code__c, WRK_TYPE__c=quote1.Pricebook_Id__c,
                       INCOME_CODE__c=323, INSTALLER__c='R', OTH_CODE__c=123, PYMT_CODE__c='Finance', RESOURCE_TYPE__c=emp.Emp_type__c, 
                       WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                       
            NIAS_Code__c Nias2 = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c=job.Region_Code__c, WRK_TYPE__c=quote1.Pricebook_Id__c,
                       INCOME_CODE__c=323, INSTALLER__c='R', OTH_CODE__c=123, PYMT_CODE__c='Cash', RESOURCE_TYPE__c=emp.Emp_type__c, 
                       WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                       
            System.debug('quote1.Pricebook_Id__c');
            insert Nias;
            BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);        
            insert payment; 
            BGS_Payment__c payment1 = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);        
            insert payment1;  
          
            payment.Payment_Date__c=system.today();
            update payment;
            payment1.Payment_Date__c=system.today();
            update payment1;  
             
            for(BigMachines_Quote__c quote: quoteList)
            {
                oppResourceTypeMap2.Add(quote.App_Assigned_Payroll__c);
            } 
            System.debug('oppResourceTypeMap2 = ' + oppResourceTypeMap2);
            
            Employee__c empObj = [select id, Name, Emp_type__c, Employee_Number__c from employee__c where Employee_Number__c in : oppResourceTypeMap2];
            System.debug('empObj = ' + empObj);
            
            emp1 = [select id, Name, Emp_type__c, Employee_Number__c from employee__c where id =:emp1.ID];
            System.debug('emp1 = ' + emp1);       
            
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
         
            Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);        
            insert week;  
         
            Diary_Entry__c DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id);
            DEntry.Job__c=job.Id;
            insert DEntry; 
            
            List<Job__c> JobList = new List<Job__c>([Select j.Status__c, j.CHI_Lead__c, j.Quote__c,j.Is_Downtime_Job__c,j.Is_Remedial_Job__c, 
                      (Select Week__r.Employee__r.Group__c From Diary_Entries__r where Week__r.Employee__r.Group__c = 'INST') 
                      From Job__c j where j.Quote__c  =:quote1.Id and j.Is_Downtime_Job__c = false and j.Is_Remedial_Job__c = false]);
            system.debug('list of job'+ JobList); 
            
            
            quoteList = [select id, name, createdDate_quote__c, 
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
        id = :quote1.ID]; 
            
            
    }
	static testMethod void TestPostive_Non_FinanceCase()
    {
    	CreateTestData();
    	
    	NIASCodeHelper.GetNIASCodeMapByOpportunity(quoteList);
    }
            
	static testMethod void FinanceTestMethod()
	{
           /* 
            List<BigMachines_Quote__c> quoteList=new List<BigMachines_Quote__c>();
             Account account; 
             List<String> oppResourceTypeMap = new List<String>();      
             Contact contact;    
             Employee__c emp ;         
             Opportunity opportunity,opportunity1 ;
             List<ID> CHILeadList = new List<ID>();
             List<String> quoteIDList = new List<String>();
             String region_code; 
            
            account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');        
            insert account;        // Insert mandatory fields in the Account                          
            
            contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',FirstName='First name',Email='test@gmail.com',AccountId=account.Id);             
            insert contact;        // Insert mandatory fields in the Contact                        
            
            emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0002991');        
            insert emp;
            emp.Emp_type__c='S';
            emp.Resource_Type__c ='SA';
            emp.Group__c='INST';
            update emp;        // Insert mandatory fields in the Employee custom object                  
            //emp = [select id from Employee__c where id=:emp.Id];        //Retrive details of employee to insert new opportunity                    
            
            opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id, Payment_Method__c = 'Cash');          
            insert (opportunity); 

            BigMachines_Quote__c quote1= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000, Pricebook_Id__c='123');
            quote1.App_Assigned_To__c=emp.Id;
            //quote1.POC_Payment_Method__c='Finance';
            insert quote1;
            quoteList.add(quote1);
  
            Region__c region = new Region__c(Code__c='2',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
            insert region;
            District__c district = new District__c();
            district.Code__c='4411';
            district.Name='sambroun';
            district.Region__c=region.Id;
            insert district;
            system.debug(district.Region__c+'%%%');
            
            Job__c job = new Job__c();        
            job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote1.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                            Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
                            Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
                            Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
                            Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                            Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
            
            job.District__c=district.Id;
            insert job;
            
            job = [select CHI_Lead__c ,Quote__c,PowerFlush_Hours__c, Building_Work_Hours__c,
                            Connect_Solar_Panel_Hours__c, Contractor_Installation_Hours__c,Electrical_Hours__c,Is_Remedial_Job__c, 
                            Fire_Wall_Heater_Fixing_Hours__c, LPG_Installation_Hours__c,Is_Downtime_Job__c ,
                            Payment_Collection_Hours__c, Roof_Work_Hours__c,Specialist_Building_Hours__c, Unvented_Hot_Water_Hours__c,
                            Water_Heating_Fixing_Hours__c,Customer_Preferred_Date__c, Contractors__c, Own_Labour__c,
                            District__c,
                            Double_Handed_Job__c, Region_Code__c, Delivery_Date__c,Installation_Date__c from Job__c where id =:job.Id]; 
            
            
            System.debug('------------------- job = ' + job);
            system.debug(job.Quote__c+'^^^');
             //system.debug(job.District__r.Name+'*****:******'+job.District_Name__c+'4908908493480'+job.District__c);
            
            
			NIAS_Code__c Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c=region_code, WRK_TYPE__c=quote1.Pricebook_Id__c,
			           INCOME_CODE__c=323, INSTALLER__c='1', OTH_CODE__c=123, PYMT_CODE__c='123', RESOURCE_TYPE__c=emp.Emp_type__c, 
			           WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
			           
			BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);        
            insert payment; 
            BGS_Payment__c payment1 = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);        
            insert payment1;  
            payment.Payment_Date__c=system.today();
            update payment;
            payment1.Payment_Date__c=system.today()+1;
            update payment1;             
     
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

            Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);        
            insert week;  

            
            List<Job__c> JobList = new List<Job__c>([Select j.Status__c, j.CHI_Lead__c, j.Quote__c,j.Is_Downtime_Job__c,j.Is_Remedial_Job__c, 
                      (Select Week__r.Employee__r.Group__c From Diary_Entries__r where Week__r.Employee__r.Group__c = 'INST') 
                      From Job__c j where j.Quote__c  =:quote1.Id and j.Is_Downtime_Job__c = false and j.Is_Remedial_Job__c = false]);
           system.debug('list of job'+ JobList); 
       */
       
       CreateTestData();
       
       NIASCodeHelper.GetNIASCodeMapByOpportunity(quoteList);
       NIASCodeHelper.NIASCode Naiscode = new NIASCodeHelper.NIASCode();
       Naiscode.getBlCompleted();
       Naiscode.setBlCompleted(true);
       
	}
}