@isTest
private class CancelOrderLineItemsCntrl_test {
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
    static Job_Element__c JE;
    static Order__c ord; 
    static Order_Line_Item__c OrdLine;
    static List<Order_Line_Item__c> Ordlinelst;
    static List<CancelOrderLineItemsCntrl.innerLineItem> CinLineitems;
    static Order_Line_Item__c OrdLine1;
    static void PrepareData() 
    {
        
        // Create an account and insert
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        // Create a contact and insert
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
       // Create a supplier and insert
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A2017',Resource_Type__c='Resource');
        insert supplier;
        
        // Create employee(s) and insert
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with  employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 
                
       // Create a quote and insert
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
                
        // Create dummy product,quote product correspomding to it and insert
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        //with some district already stored create a job status planned
        District__c district = [Select id from District__c limit 1];
    
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                                
        job.Status__c='Planned';
        insert job;
        
        ord = new Order__c();
        ord.Job__c= job.Id;
        insert ord;
        
        JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.code__c = '190909';
        JE.Current_Supplier__c = supplier.ID;
        JE.Type__c = 'Work';
        JE.Order__c = ord.id;
        insert JE;
        
        //update job;
        
        list<Order_Line_Item__c> newList = new list<Order_Line_Item__c>();

        OrdLine = new Order_Line_Item__c();
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        ordline.P5_Product__c=product.Id;
        OrdLine.P5_Status_c__c='Active';
        OrdLine.Units__c=10;
        OrdLine.Quantity_Returned__c=100;
        OrdLine.Skill__c='Roof Work';
        OrdLine.P5_Type__c='Work';
        OrdLine.Description__c='testdescription';
        OrdLine.Code__c='190910'; 
        //OrdLine.Name; 
        Ordline.P5_Unit_Price_c__c=100;
        Ordline.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        //insert OrdLine;
        /*OrdLine.P5_Status_c__c='Cancelled';
        update OrdLine;*/
        Ordlinelst =new List<Order_Line_Item__c>();
        Ordlinelst.add(Ordline);
        newList.add(Ordline);


        OrdLine1 = new Order_Line_Item__c();
        OrdLine1.Order_Line_Item_Number__c=714;
        OrdLine1.P5_Job_Element__c=JE.Id;
        OrdLine1.P5_Purchase_Order__c=ord.Id;
        ordline1.P5_Product__c=product.Id;
        OrdLine1.P5_Status_c__c='Active';
        OrdLine1.Units__c=10;
        OrdLine1.Quantity_Returned__c=100;
        OrdLine1.Skill__c='Roof Work';
        OrdLine1.P5_Type__c='Work';
        OrdLine1.Description__c='testdescription1';
        OrdLine1.Code__c='190909';
        Ordline1.P5_Unit_Price_c__c=100;
        Ordline1.Supplier__c=supplier.Id;
        newList.add(Ordline1);
        insert newList;      

        List<Order_Line_Item__c> OrdLinelst1 = new List<Order_Line_Item__c>();
        OrdLinelst1.add(OrdLine1);
        
        TopcallOrderGenerationPDF topcall = new TopcallOrderGenerationPDF();
        Pagereference pgRef=topcall.GeneratePDF();
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(ord);
        CancelOrderLineItemsCntrl COLIcntrl = new CancelOrderLineItemsCntrl(stdCancelController);
        
        
        
        //Ordlinelst.size=0;
        
        
        newList = [select Order_Line_Item_Number__c, Total_Amount__c, P5_Job_Element__c, P5_Purchase_Order__c, P5_Product__c,
                    P5_Status_c__c, Units__c, Quantity_Returned__c,Skill__c,P5_Type__c,Description__c, 
                    Code__c, P5_Unit_Price_c__c, Supplier__c from Order_Line_Item__c where id in : newList ];
        OrdLine = newList[0];
        OrdLine1 = newList[1]; 
        /*
        OrdLine = [select Order_Line_Item_Number__c, Total_Amount__c, P5_Job_Element__c, P5_Purchase_Order__c, P5_Product__c,
                    P5_Status_c__c, Units__c, Quantity_Returned__c,Skill__c,P5_Type__c,Description__c, 
                    Code__c, P5_Unit_Price_c__c, Supplier__c from Order_Line_Item__c where id =: OrdLine.ID  ];*/

    }
     static testMethod void Dataforcancelorder() 
     {
        PrepareData();
        test.startTest();
        Pagereference pageRef = Page.Cancel_Order_Line_Items;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('jid',job.Id);
        
        System.debug('--------------- jid = ' +  System.currentPageReference().getParameters().get('jid'));
        
        
        
        
        CancelOrderLineItemsCntrl.innerLineItem inLineitems = new CancelOrderLineItemsCntrl.innerLineItem();
        
        inLineitems.setOrdLineItm(OrdLine1);
        inLineitems.setIsSelected(true);
        inLineitems.getIsSelected();
       
        //inLineitems.setOrdLineItm(OrdLine);
        inLineitems.getOrdLineItm();
        CinLineitems = new List<CancelOrderLineItemsCntrl.innerLineItem>();
        CinLineitems.add(inLineitems);
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(ord);
        CancelOrderLineItemsCntrl COLIcntrl = new CancelOrderLineItemsCntrl(stdCancelController);
        COLIcntrl.lineItemList = CinLineitems; 
         
        COLIcntrl.getLineItems();
        COLIcntrl.setShowDetails(false);
        COLIcntrl.cancelOLI();
        for(Supplier__c supplr : [Select s.id from Supplier__c s where s.Supplier_Num__c =:'2017'])
        {
        if(supplr != null)
        {
        ord.Supplier__c=supplr.id;
        ord.P5_Good_Receipting_Status__c = 'Awaiting Integration';
        update ord;
        }
        else if(supplier == null)
        {
        supplier = new supplier__c(Name='Tsupplier',Type__c='Resource',Supplier_Num__c='2017',Resource_Type__c='Resource');
        insert supplier; 
        }
        }
        
        COLIcntrl.setOrderStat(ord);
        
        COLIcntrl.getLineItems();
        COLIcntrl.getCancelAll(); //**
        COLIcntrl.cancelOLI();
        COLIcntrl.goBack();
        COLIcntrl.selectAll();
        COLIcntrl.getShowDetails();
        COLIcntrl.setShowDetails(true);
        
        COLIcntrl.getSelectAll();
        COLIcntrl.setSelectAll(true);
        COLIcntrl.getResult();
        COLIcntrl.setResult('abc');
        COLIcntrl.setCancelAll(false);
        COLIcntrl.getCancelAll();   
        COLIcntrl.getLineItems();
        COLIcntrl.setShowDetails(true);
        
        System.debug('--------- starting my test');
        getSelectedLines(CinLineitems);
        //Ordlinelst =new List<Order_Line_Item__c>();
        //Ordlinelst.add(null); 
        test.stopTest();
     }
     
     private static void getSelectedLines(List<CancelOrderLineItemsCntrl.innerLineItem> lineItemList)
     {
        boolean entered =false;
        boolean cancelAll = false;
        List<Order_Line_Item__c> ordrLinesList = new List<Order_Line_Item__c>();
        
        List<CancelOrderLineItemsCntrl.innerLineItem> tempInrList = new List<CancelOrderLineItemsCntrl.innerLineItem>();
        
        for(CancelOrderLineItemsCntrl.innerLineItem iOLI : lineItemList){
            if(iOLI.isSelected != null && iOLI.isSelected){
                ordrLinesList.add(iOLI.ordLineItm);                    
                entered = true;
            }else if(iOLI.isSelected != null && iOLI.isSelected == false){
                tempInrList.add(iOLI);
            }
        }    
        System.debug('-------------- ordrLinesList = ' + ordrLinesList);    
        if(entered){
            if(ordrLinesList.size() == lineItemList.size())
                System.debug('--------------1 setCancelAll = true');
            else
                System.debug('--------------1 setCancelAll = false');
                
            
            lineItemList.clear();
            if(tempInrList.size() > 0)
                lineItemList.addAll(tempInrList);
            System.debug('--------------2 ordrLinesList = ' + ordrLinesList);
        }
        else{
            System.debug('--------------2 setCancelAll = true');
            
        }
    }
    
    static testmethod void testPTSChange()
    {
    	PrepareData();
    	ord.Type__c = 'Material';
    	update ord;
    	Pagereference pageRef = Page.Cancel_Order_Line_Items;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('jid',job.Id);
        
        System.debug('--------------- jid = ' +  System.currentPageReference().getParameters().get('jid'));
        
        
        
        
        CancelOrderLineItemsCntrl.innerLineItem inLineitems = new CancelOrderLineItemsCntrl.innerLineItem();
        
        inLineitems.setOrdLineItm(OrdLine1);
        inLineitems.setIsSelected(true);
        inLineitems.getIsSelected();
       
        //inLineitems.setOrdLineItm(OrdLine);
        inLineitems.getOrdLineItm();
        CinLineitems = new List<CancelOrderLineItemsCntrl.innerLineItem>();
        CinLineitems.add(inLineitems);
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(ord);
        CancelOrderLineItemsCntrl COLIcntrl = new CancelOrderLineItemsCntrl(stdCancelController);
        COLIcntrl.lineItemList = CinLineitems; 
         
        COLIcntrl.getLineItems();
        COLIcntrl.setShowDetails(false);
        job.DeliveryID__c = 'testId';
    	update job;
    	
        COLIcntrl.cancelOLI();
        for(Supplier__c supplr : [Select s.id from Supplier__c s where s.Supplier_Num__c =:'2017'])
        {
        if(supplr != null)
        {
        ord.Supplier__c=supplr.id;
        ord.P5_Good_Receipting_Status__c = 'Awaiting Integration';
        update ord;
        }
        else if(supplier == null)
        {
        supplier = new supplier__c(Name='Tsupplier',Type__c='Resource',Supplier_Num__c='2017',Resource_Type__c='Resource');
        insert supplier; 
        }
        }
        COLIcntrl.setOrderStat(ord);
        
        COLIcntrl.getLineItems();
        COLIcntrl.getCancelAll(); //**
        COLIcntrl.cancelOLI();
    }
}