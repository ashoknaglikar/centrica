@isTest(SeeAllData=false)
private class dispatchOrdertoEDI_test 
{
    
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Job__c job;
    //static List<Order__c> ordlist;
    static List<SFED7542_Batch__c> batchlist;
    static SFED7542_Batch__c batch;
    static Map<String,String> batchSuppKeyMap;
    static Map<String,List<order__c>> batchSuppOrderMap;
    static SFED7542_Order__c batchOrderObj;
    static List<SFED7542_Order__c> InterfaceOrderlst;
    static SFPO7523_Batch__c objBatch;
    static List<SFED7542_Order_Details__c> SFED7542OrdDetailList;
    static Map<String,String> trancodeMap;
    static List<Order_Line_Item__c> ordItemList;
    static List<order__c> ordList;
    static List<order__c> ordList1;
    static order__c ord;
    static order__c ord1;
    static List<Business_Holiday__c> busObjList;
    static string orderid;
    static string brachname = '7864';
    static Order_Line_Item__c OrdLine1;
    static Product_Order__c prodOrder;
    static void PrepareData() 
    {
        cls_IsRun.generaltriggerswitch = true;
        cls_isrun.dontFireTriggers = true;
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();
        // TO DO: implement unit test
        
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation=null);
                                     
        insert contact;
        
        
        contact.Salutation = 'Mr';
        update contact;
        
        account.Primary_Contact__c=contact.Id;
        update account;
        
        supplier = new Supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource',P5_Order_Lead_Time__c=22);
        supplier.EDI_Tolerance_Value__c=3; 
        supplier.EDI_Setup_Type__c='0';
        
        
        insert supplier;
         
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
        
        insert emp;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id,LeadSource='Engineer', Premier_Address_Number__c=null, Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
        insert opportunity;
        System.debug('-----PriContactId--->>>>'+account.Primary_Contact__c);
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
        insert product;
        insert quoteProduct;

        district__c district= TestClassHelper.createDistrict();
        insert district;
       // district = [Select id from District__c limit 1];
        
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =System.today()-2,Installation_Date__c=System.today().adddays(20),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        job.Status__c='Pending';
        job.Delivery_Notes__c='test';
        insert job;

        
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.type__c = 'Material';
        JE.Status__c = 'Active'; 
        insert JE;
        job.Status__c='Planned';
        job.Delivery_Date__c = system.today().adddays(10);
        update job;
        
        Supplier_Branch__c SBranch = new Supplier_Branch__c();
        SBranch.Branch_Email__c = 'b@b.com';
        SBranch.Branch_Num__c = '7864';
        SBranch.Supplier__c = supplier.Id;
        SBranch.Fax_Number__c = '9909907';
        insert SBranch;
        
        //create order
        ord = new order__c();
        ord.SupplierBranchNum__c = '7864';
        ord.Supplier_Communication_Preference__c='E';       
        ord.Job__c= job.Id;
        ord.Supplier__c=supplier.Id;
        ord.EDI_Status__c='Awaiting Integration';
        ord.Amendment_Number__c=1;
        ord.Type__c = 'Material';
        ord.Supplier_Acceptance_Status__c='Ordered';
        ord.SupplierBranchNum__c = brachname;
        ord.Status__c = 'Active';
        ord.batch_created__c = false;
        ord.Amendment_Number_sent__c=12;
        
        
        insert ord;
        
        //create order with Cancelled status
        ord1 = new order__c();
        ord1.SupplierBranchNum__c = '7864';
        ord1.Supplier_Communication_Preference__c='E';       
        ord1.Job__c= job.Id;
        ord1.Supplier__c=supplier.Id;
        ord1.EDI_Status__c='Cancelled';
        ord1.Amendment_Number__c=1;
        ord1.Type__c = 'Material';
        ord1.Supplier_Acceptance_Status__c='Ordered';
        ord1.SupplierBranchNum__c = brachname;
        ord1.Status__c = 'Cancelled';
        ord1.batch_created__c = false;
        ord1.Amendment_Number_sent__c=12;
        
        
        
        insert ord1;
        
        Communication_Preference__c custPref = new Communication_Preference__c();
        custPref.Supplier_Branch__c = SBranch.id;
        custPref.Order_Type__c = 'I';
        custPref.Primary_Destination__c = 'E';
        insert custPref; 
                                
        List<Communication_Preference__c> lstPref = [Select order_type__c,Supplier_Branch__r.Branch_Num__c,c.Secondary_Destination__c, 
                c.Primary_Destination__c 
                From Communication_Preference__c c where 
                Supplier_Branch__r.Branch_Num__c =:brachname  and Order_Type__c = :ord.Type__c];
        
        orderid = ord.Id;
        //insert ordList;
        
        System.debug('-----ContactId--->>>>'+ord.Job__r.Primary_Contact__c);
        System.debug('-----lstPref--->>>>'+lstPref);
     
        Business_Holiday__c busObj= new Business_Holiday__c();
        busObj.Holiday_On__c = system.today()-2;
        busObj.Country_Code__c = 'ENG';
        busObj.Active__c = true;
        busObj.Description__c='xyz';
        insert busObj;
        busObjList =new List<Business_Holiday__c>();
        busObjList.add(busObj);
        
        system.debug('---------busObjList----->>>'+busObjList);
       
       Communication_Preference__c CPref = new Communication_Preference__c();
       CPref.Order_Type__c='I';
       CPref.Supplier_Branch__c=SBranch.Id;
       CPref.Primary_Destination__c='P';
       insert CPref;
           
        OrdLine1 = new Order_Line_Item__c();
        OrdLine1.Order_Line_Item_Number__c=714;
        Ordline1.Original_Units__c=2;
        Ordline1.Original_Value__c=243;
        //Ordline1.Total_Amount__c=234;
        OrdLine1.P5_Job_Element__c=JE.Id;
        OrdLine1.P5_Purchase_Order__c=ord.Id;
        ordline1.P5_Product__c=product.Id;
        OrdLine1.P5_Status_c__c='Active';
        OrdLine1.Units__c=10;
        OrdLine1.Quantity_Returned__c=3;
        //OrdLine1.Skill__c='Roof Work';
        OrdLine1.P5_Type__c='Material';
        OrdLine1.Description__c='testdescription1';
        OrdLine1.Code__c='C1234';
        Ordline1.P5_Unit_Price_c__c=100;
        Ordline1.Supplier__c=supplier.Id;
        ordItemList=new List<Order_Line_Item__c>();
        ordItemList.add(OrdLine1);
        insert OrdLine1;
        
        //insert ordItemList;
   
        
        
        system.debug('------------------OrderItem List1------------'+ordItemList);
        
        account = [select id, Primary_Contact__c from Account where id =:account.id];
        job = [select id, Primary_Contact__c, CHI_Lead__c, CHI_Lead__r.AccountID, CHI_Lead__r.Account.Primary_Contact__c, CHI_Lead__r.Account.Primary_Contact__r.Id,Account_Id__c from Job__c where id = :job.id];
              
            
        ordList = [select Delivery_Slot__c,batch_created__c,Amendment_Number__c,Job__r.CHI_Lead__r.Address_Number__c,Job__r.CHI_Lead__r.Address_Number_EDI__c,Synched_to_EDI__c,EDI_Setup__c,id,Delivery_Date_Changed__c,Topcall_Fax_Status__c,supplier__r.P5_Order_Lead_Time__c,supplier__r.EDI_Tolerance_Value__c,Supplier_Communication_Preference__c,Job_Delivery_Date__c,Job__r.Delivery_Date__c,CreatedDate,Returned_Items__c,Amendment_Synched__c,Amended__c,supplier__r.name,Status__c,EDI_Status__c,SupplierBranchNum__c,Supplier__r.Supplier_Num__c,name,Order_Note__c,SAP_Number__c,supplier__c,Sync__c,Job__r.Delivery_Notes__c,Job__r.Installation_date__c,Job__r.Primary_Contact__c,Supplier__r.ANA_Number__c,Amendment_Number_sent__c,LastModifiedBy.Name,LastModifiedBy.Phone,Job__r.Account_Id__c from Order__c where id=:ord.id];   
        ordList1 = [select Delivery_Slot__c,batch_created__c,Amendment_Number__c,Job__r.CHI_Lead__r.Address_Number__c,Job__r.CHI_Lead__r.Address_Number_EDI__c,Synched_to_EDI__c,EDI_Setup__c,id,Delivery_Date_Changed__c,Topcall_Fax_Status__c,supplier__r.P5_Order_Lead_Time__c,supplier__r.EDI_Tolerance_Value__c,Supplier_Communication_Preference__c,Job_Delivery_Date__c,Job__r.Delivery_Date__c,CreatedDate,Returned_Items__c,Amendment_Synched__c,Amended__c,supplier__r.name,Status__c,EDI_Status__c,SupplierBranchNum__c,Supplier__r.Supplier_Num__c,name,Order_Note__c,SAP_Number__c,supplier__c,Sync__c,Job__r.Delivery_Notes__c,Job__r.Installation_date__c,Job__r.Primary_Contact__c,Supplier__r.ANA_Number__c,Amendment_Number_sent__c,LastModifiedBy.Name,LastModifiedBy.Phone,Job__r.Account_Id__c from Order__c where id=:ord1.id];
        
        //create SFED7542_Batch__c record
        SFED7542_Batch__c SFEDBatchObj=new SFED7542_Batch__c();
        SFEDBatchObj.Supplier__c=supplier.id;
        System.debug('-----supplier--->>>>'+supplier.id);
        insert SFEDBatchObj; 
        
        List<SFED7542_Batch__c> listofSFEDBatch=new List<SFED7542_Batch__c>();
        listofSFEDBatch.add(SFEDBatchObj);
        System.debug('-----BatchId--->>>>'+SFEDBatchObj.ID);
        
        //create SFED7542_Order__c record
        batchOrderObj = new SFED7542_Order__c();
        batchOrderObj.SFED7542_Batch__c=SFEDBatchObj.id;
        batchOrderObj.Order__c=ord1.Id;
        batchOrderObj.Supplier__c=supplier.id;
        batchOrderObj.Customer_EAN_Location_Number__c = 'testEANNbr';
         
        batchOrderObj.Customer_Id_allocated_by_Supplier__c = 'testSupnr';
        
        batchOrderObj.Transanction_Code__c='0430';
        
        insert batchOrderObj;
        
        InterfaceOrderlst = new List<SFED7542_Order__c>();
        InterfaceOrderlst.add(batchOrderObj);
        
        //create SFED7542_Order_Details__c record
        SFED7542_Order_Details__c SFED7542OrdDetailObj=new SFED7542_Order_Details__c();
        SFED7542OrdDetailObj.Orders_Id__c=ord.Id;
        SFED7542OrdDetailObj.SFED7542_Order__c=batchOrderObj.Id;
        SFED7542OrdDetailObj.City__c=contact.MailingCity;
        SFED7542OrdDetailObj.Country__c=contact.MailingCountry;
        SFED7542OrdDetailObj.County__c=contact.MailingCountry;
        SFED7542OrdDetailObj.Post_Code__c=contact.MailingPostalCode;
        SFED7542OrdDetailObj.Street__c=contact.MailingStreet;
        SFED7542OrdDetailObj.Customer_Name__c=contact.FirstName +' '+contact.LastName;
        insert SFED7542OrdDetailObj;
        
        
        
        //create SFED7542_Order_Details__c record
        SFED7542_Order_Details__c SFED7542OrdDetailObj1=new SFED7542_Order_Details__c();
        SFED7542OrdDetailObj1.Orders_Id__c=ord1.Id;
        SFED7542OrdDetailObj1.SFED7542_Order__c=batchOrderObj.Id;
        SFED7542OrdDetailObj1.City__c=contact.MailingCity;
        SFED7542OrdDetailObj1.Country__c=contact.MailingCountry;
        SFED7542OrdDetailObj1.County__c=contact.MailingCountry;
        SFED7542OrdDetailObj1.Post_Code__c=contact.MailingPostalCode;
        SFED7542OrdDetailObj1.Street__c=contact.MailingStreet;
        SFED7542OrdDetailObj1.Customer_Name__c=contact.FirstName +' '+contact.LastName;
        insert SFED7542OrdDetailObj1;
        
        SFED7542OrdDetailList=new List<SFED7542_Order_Details__c>();
        SFED7542OrdDetailList.add(SFED7542OrdDetailObj);
        SFED7542OrdDetailList.add(SFED7542OrdDetailObj1);
        
        system.debug(orderid+'---orderid--');
        system.debug(ordList+'$$ordList$$');
        system.debug(SFED7542OrdDetailList+'$$SFED7542OrdDetailList$$') ; 
        batchSuppOrderMap = new Map<String,List<order__c>>();
        batchSuppOrderMap.put(orderid,ordList);     
        system.debug(batchSuppOrderMap+'$$batchSuppOrderMap$$');
        
        
        prodOrder = new Product_Order__c();
        prodOrder.Product_Number__c = '1234';
        prodOrder.order_flag__c = 'Y';
        prodOrder.Description__c = 'testingdesc';
        insert prodOrder; 
        
        String code = (OrdLine1.Code__c).subString(1);
        
        List<Product_Order__c> prodOrderList = [Select  p.quote_description__c, p.Product_Number__c, p.order_flag__c, p.Material_Type__c, 
            p.Manufactuer__c, p.lead_time__c, p.Id, p.EAN_code__c, p.Description__c, p.dw_ind__c, p.delmkr__c, p.Currency_Type__c, p.Brand__c, 
            p.bgc_number__c From Product_Order__c p where Product_Number__c =:code and order_flag__c !='N'];
        
        Map<String,Product_Order__c> prodOrderMap = new Map<String,Product_Order__c>();
        for(Product_Order__c pOrder : prodOrderList)
            prodOrderMap.put(pOrder.Product_Number__c ,pOrder);
        
        system.debug(orderid+'---prodOrderMap = '+ prodOrderMap); 
        
        trancodeMap = new Map<String,String>();
        trancodeMap.put('abc', 'abc');
        
        
            
        //ordList.add(ord);
        //ordList.add(ord1);
    }



    
     static testMethod void WithoutDataforOrders() 
     {
        
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();
        
        
         
        
        Test.startTest();        
        
        Database.BatchableContext BC;
        //DOE.createBatchOrder(trancodeMap,batchSuppOrderMap);
        //DOE.createOrderDetails(InterfaceOrderlst,batchSuppOrderMap,trancodeMap); 
        DOE.createOrderBatch();  
        DOE.finish(BC);
        Test.stopTest();
      }
      

    
      static testMethod void DataforOrders() 
      {
        cls_IsRun.dontFireTriggers=true;
        PrepareData();
        
        Test.startTest();
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();
        Database.BatchableContext BC; 
        //DOE.start(BC);
        //DOE.createOrderBatch();
        //DOE.populateComStatus(ordList);
        System.debug('-------------- ordList=' + ordList);
        
        DOE.execute(BC,ordList);
        //DOE.createOrderSubDetails(SFED7542OrdDetailList,batchSuppOrderMap);
        DOE.createOrderDetails(InterfaceOrderlst,batchSuppOrderMap,trancodeMap);
              
        DOE.finish(BC);
        Test.StopTest();
        
        
      }
      static testMethod void CancelOrd() 
      {
        cls_IsRun.dontFireTriggers=true;
        PrepareData();
        Test.startTest();
        system.debug(contact+'---contact--');
        ord.Status__c = 'Cancelled' ;
        ord.Amendment_Number__c=2;
        ord.Amendment_Number_sent__c=12;
        prodOrder.Description__c = 'prodOrder.Description__c Product Order description above 40 characters----------------------------';
        update prodOrder;
        Database.BatchableContext BC;
        try{
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();       
        DOE.execute(BC,ordList); 
        //Database.BatchableContext BC;
        //Database.executeBatch(DOE); 
        //DOE.createOrderBatch();    
        DOE.finish(BC);
        }catch(Exception e){}
        Test.stopTest();
        
        //DOE.createOrderSubDetails(SFED7542OrdDetailList,batchSuppOrderMap);
      
      }
      static testMethod void Amendement1() 
      {
        cls_IsRun.dontFireTriggers=true;
        PrepareData();
        Test.startTest();
        contact.Salutation = 'Mr';
        update contact;
        system.debug(contact+'---contact--');
        ord.Status__c = 'Amended' ;
        ord.Amendment_Number__c=2;
        update ord;
        ord.Amendment_Number__c=3;
        update ord;
        ord.Amendment_Number__c=4;
        update ord;
        Database.BatchableContext BC;
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();       
        DOE.execute(BC,ordList); 
        DOE.finish(BC);
        Test.stopTest();
     }
     static testMethod void Amendementcancelled1() 
      {
        cls_IsRun.dontFireTriggers=true;
        PrepareData();
        Test.startTest();
        contact.Salutation = 'Mr';
        update contact;
        system.debug(contact+'---contact--');
        ord.Status__c = 'Amended' ;
        ord.Amendment_Number__c=2;
        update ord;
        ord.Amendment_Number__c=3;
        update ord;
        ord.Amendment_Number__c=4;
        update ord;
        ord.Status__c = 'Cancelled' ;
        update ord;
        Database.BatchableContext BC;
        
       
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();       
        DOE.execute(BC,ordList); 
        DOE.finish(BC);
        Test.stopTest();
     }

      static testMethod void SettingValueofContact() 
      {
        
        cls_IsRun.dontFireTriggers=true;
        PrepareData();
        Test.startTest();
        contact.Salutation = '';
        contact.Title='';
        update contact;
        system.debug(contact+'---contact--');
        ord.Status__c = 'Cancelled' ;
        ord.Amendment_Number__c=2;
        ord.Supplier_Communication_Preference__c='L'; 
        update ord;
        Ordline1.Original_Units__c=null;
        update Ordline1;
        
        Database.BatchableContext BC;
        
        
        DispatchOrdertoEDI DOE=new DispatchOrdertoEDI();       
        DOE.execute(BC,ordList); 
        //Database.BatchableContext BC;
        //Database.executeBatch(DOE); 
        //DOE.createOrderBatch();    
        DOE.finish(BC);
        Test.stopTest();
        
        //DOE.createOrderSubDetails(SFED7542OrdDetailList,batchSuppOrderMap);
      
      }
      
}