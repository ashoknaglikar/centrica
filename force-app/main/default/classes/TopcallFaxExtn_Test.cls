@isTest
private class TopcallFaxExtn_Test {
    
	static Order__c ord;    
	static Order__c ord1;
	static Employee__c emp;
	 
    static void createTestData() {
        
        // Craeting Order
        
                Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
               insert account;
        
               Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
               insert contact;
        
               Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
               insert supplier;
         
               emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '8798',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
               emp.Phone_No__c='9089001234';
               insert emp;
               
               
               Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
               User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
               insert UInstal1;
               
               
               Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
               BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c='Stephen Spence - 80641',
                                                            createdDate_quote__c = System.today(), submittedDate_quote__c = System.today(),
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
              //quote.createdDate_quote__c.format();
               insert quote;
               
        
               Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
               Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


              insert product;
              insert quoteProduct;

        
               District__c district = [Select id from District__c limit 1];
               
               
        
        
        
              Job__c job = new Job__c();

              job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true,Status__c='Planned', Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
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
        
        Supplier_Branch__c SBranch = new Supplier_Branch__c();
        SBranch.Fax_Number__c = '123';
        SBranch.Branch_Email__c = 'teat@test.com';
        SBranch.Branch_Num__c='786';
        SBranch.Supplier__c=supplier.Id;
        //SBranch.Supplier_Num__c='A1234';
        insert SBranch;       
        
        
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.SupplierBranchNum__c='786';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        string str = '80641';
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
       // ord.Sales_By__c=
       
        // ord.Order_Date__c.format();
        insert ord;
        
        
        ord1 = new Order__c();
        ord1.Job__c= job.Id;
        ord1.SAP_Number__c='12';
        ord1.Status__c='Active';
        ord1.Sync__c=true;
        ord1.SAP_Number__c='1234';
        
        ord1.Supplier__c=supplier.Id;
        ord1.Order_Value__c=456; 
        ord1.Amendment_Number__c=678;
        ord1.Type__c='Material';
        ord1.Order_Date__c=System.today();
        ord1.Fax_Setup__c=true;
        
        insert ord1;
        
       ord1.SupplierBranchNum__c='786';
       update ord1;
       
        List<Order__c> ordlst = new List<Order__c>();
        ordlst.add(ord);
     /*          
       Employee__c emp1 = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = str,Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
               emp1.Phone_No__c='9089001234';
               insert emp1;*/
      
       
       system.debug('-----------ord-------->>>>>'+ord);
      
       //String sale = ord.Sales_By__c;
       //emp.Employee_Number__c =sale;
       //update emp;
       
    }
    
    static testmethod void testwithWorkOrder()
    {
    	createTestData();
    	
		PageReference pageRef = new PageReference('/apex/TopcallFaxExtn?pageType=' + ord.id + '&resourceId=' + emp.Employee_Number__c);
       	Test.setCurrentPage(pageRef);
       
       //Passing Controller to the Constructer
       
       
		ApexPages.standardController controller1 = new ApexPages.standardController(ord);
       	TopcallFaxExtn poi1=new TopcallFaxExtn(controller1);
       	poi1.strSalesBy=emp.Name;
       	poi1.strSalesBy=emp.Employee_Number__c;
       	poi1.strSalesBy=emp.Phone_No__c;
       	poi1.strSalesBy=emp.Last_Name__c;
       	poi1.strSalesBy=emp.First_Name__c;
       
      	/* PageReference pageRef1 = new PageReference('/apex/TopcallFaxExtn?pageType=' + 'IO');
       	Test.setCurrentPage(pageRef1);
       
       	ApexPages.standardController controller = new ApexPages.standardController(ord);
       	TopcallFaxExtn poi=new TopcallFaxExtn(controller);
       	poi.strSalesBy=emp.Name;
       	poi.strSalesBy=emp.Employee_Number__c;
       	poi.strSalesBy=emp.Phone_No__c;
       	poi.strSalesBy=emp.Last_Name__c;
       	poi.strSalesBy=emp.First_Name__c;*/
       	//TopcallFaxExtn.RateItemDetails ratedet= new TopcallFaxExtn.RateItemDetails();
       	TopcallFaxExtn.RateItemDetails RIT=new TopcallFaxExtn.RateItemDetails();
       	TopcallFaxExtn.QuoteProduct QP=new TopcallFaxExtn.QuoteProduct();
       	TopcallFaxExtn.QuoteProductType QPT = new TopcallFaxExtn.QuoteProductType();
       	List<TopcallFaxExtn.QuoteProduct> Listqp= new List<TopcallFaxExtn.QuoteProduct>();
       	QPT.setQuoteProductLst(Listqp);
        TopcallFaxExtn.EventDetails ED= new TopcallFaxExtn.EventDetails();
        ED.sResponsible='objEmployee.First_Name__c '+ ' objEmployee.Last_Name__c';
    }
    
    static testmethod void testwithMaterialOrder()
    {
    	createTestData();
    	
		PageReference pageRef = new PageReference('/apex/TopcallFaxExtn?pageType=' + ord1.id + '&resourceId=' + emp.Employee_Number__c);
       	Test.setCurrentPage(pageRef);
       
       //Passing Controller to the Constructer
       
       
		ApexPages.standardController controller1 = new ApexPages.standardController(ord1);
       	TopcallFaxExtn poi1=new TopcallFaxExtn(controller1);
       	poi1.strSalesBy=emp.Name;
       	poi1.strSalesBy=emp.Employee_Number__c;
       	poi1.strSalesBy=emp.Phone_No__c;
       	poi1.strSalesBy=emp.Last_Name__c;
       	poi1.strSalesBy=emp.First_Name__c;
       
      	/* PageReference pageRef1 = new PageReference('/apex/TopcallFaxExtn?pageType=' + 'IO');
       	Test.setCurrentPage(pageRef1);
       
       	ApexPages.standardController controller = new ApexPages.standardController(ord);
       	TopcallFaxExtn poi=new TopcallFaxExtn(controller);
       	poi.strSalesBy=emp.Name;
       	poi.strSalesBy=emp.Employee_Number__c;
       	poi.strSalesBy=emp.Phone_No__c;
       	poi.strSalesBy=emp.Last_Name__c;
       	poi.strSalesBy=emp.First_Name__c;*/
       	//TopcallFaxExtn.RateItemDetails ratedet= new TopcallFaxExtn.RateItemDetails();
       	TopcallFaxExtn.RateItemDetails RIT=new TopcallFaxExtn.RateItemDetails();
       	TopcallFaxExtn.QuoteProduct QP=new TopcallFaxExtn.QuoteProduct();
       	TopcallFaxExtn.QuoteProductType QPT = new TopcallFaxExtn.QuoteProductType();
       	List<TopcallFaxExtn.QuoteProduct> Listqp= new List<TopcallFaxExtn.QuoteProduct>();
       	QPT.setQuoteProductLst(Listqp);
        TopcallFaxExtn.EventDetails ED= new TopcallFaxExtn.EventDetails();
        ED.sResponsible='objEmployee.First_Name__c '+ ' objEmployee.Last_Name__c';
    }
}