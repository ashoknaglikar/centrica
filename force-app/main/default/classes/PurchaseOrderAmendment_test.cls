@isTest
private class PurchaseOrderAmendment_test {
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
    static List<SAP_Number__c> listOfSapnumObj;
    
    
    static void createTestData() 
    {
              account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
       
        insert supplier;
        
        supplier1 = new supplier__c(Name='Test supplier1',ANA_Number__c='122',Type__c='Resource',Supplier_Num__c='B1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
        insert supplier1;
        
        supplier2 = new supplier__c(Name='Test supplier2',ANA_Number__c='123',Type__c='Product',Status_code__c='A',Supplier_Num__c='C1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='S');
        insert supplier2;
        
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
        
        
        SAP_Number__c sapnumObj= new SAP_Number__c();
        sapnumObj.Active__c=true;
        sapnumObj.in_Use__c=false;
        sapnumObj.SAP_Number__c='0987654';
        //sapnumObj.SAP_Num_Ord__c=1325;
        insert sapnumObj;
        listOfSapnumObj= new List<SAP_Number__c>();
        listOfSapnumObj.add(sapnumObj);
        system.debug('-------listOfSapnumObj----.....'+listOfSapnumObj);
        //sapnumObj=[select SAP_Number__c,Id from  SAP_Number__c where Id=:sapnumObj.Id];
        //Creating  Work Order with Active Status                         
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c=sapnumObj.SAP_Number__c;
        ord.Status__c='Active';
        ord.Sync__c=true;
        //sord.SAP_Number__c='1234';
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
        
        //Creating Work Element with WorkOrder,Itinerary is False and Status is Active
        Job_Element__c JE2 = new Job_Element__c();
        JE2.Job__c = job.Id;
        JE2.Type__c='Work';
        JE2.New_Supplier__c=null;
        //JE2.Order__c=ord.Id;
        JE2.Order__c=null;
        JE2.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        JE2.Current_Supplier__c='CSupplier1';
        JE2.Current_Supplier_Number__c='321';
        JE2.Code__c=supplier2.Supplier_Num__c;
        JE2.Supplier_Order_Number__c='1212';
        JE2.Status__c='Active';
        JE2.Sub_Status__c='Awaiting Order';
        JE2.Description__c='testDescription';
        JE2.Line_Item_ID__c='124';
        JE2.Skill__c='Scaffolder';
        JE2.Units__c=125;
        JE2.P5_IsItinerary__c=false;
        insert JE2;
        
        // Ashok 's Cr-005 UDP JE
        Job_Element__c UDPJE = new Job_Element__c();
        UDPJE.Job__c = job.Id;
        UDPJE.New_Supplier__c=null;
        UDPJE.Order__c=null;
        UDPJE.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        UDPJE.Current_Supplier__c=supplier2.Id;
        UDPJE.Current_Supplier_Number__c=supplier2.Supplier_Num__c;
        UDPJE.Code__c='UDPQP1';
        UDPJE.Supplier_Order_Number__c='1212';
        UDPJE.Status__c='Active';
        UDPJE.Sub_Status__c='Awaiting Order';
        UDPJE.Description__c='testDescription';
        UDPJE.Line_Item_ID__c='124';
        UDPJE.Skill__c='Scaffolder';
        UDPJE.Units__c=125;
        UDPJE.P5_IsItinerary__c=false;
        UDPJE.User_Defined_Product__c = true;
        UDPJE.Merchant_Price__c = 100;
        UDPJE.Type__c = 'Material';
        
        
        insert UDPJE;
        Job_Element__c UDPJE1 = new Job_Element__c();
        UDPJE1.Job__c = job.Id;
        UDPJE1.New_Supplier__c=null;
        UDPJE1.Order__c=null;
        UDPJE1.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        UDPJE1.Current_Supplier__c=supplier2.Id;
        UDPJE1.Current_Supplier_Number__c=supplier2.Supplier_Num__c;
        UDPJE1.Code__c='UDPQP2';
        UDPJE1.Supplier_Order_Number__c='1212';
        UDPJE1.Status__c='Active';
        UDPJE1.Sub_Status__c='Awaiting Order';
        UDPJE1.Description__c='testDescription';
        UDPJE1.Line_Item_ID__c='124124';
        UDPJE1.Skill__c='Scaffolder';
        UDPJE1.Units__c=125;
        UDPJE1.P5_IsItinerary__c=false;
        UDPJE1.User_Defined_Product__c = true;
        UDPJE1.Merchant_Price__c = 100;
        UDPJE1.Type__c = 'Material';
        
        insert UDPJE1;
        List<Job_Element__c> JEList_Work2 =new List<Job_Element__c>();
        JEList_Work2.add(JE2);
        JEList_Work2.add(UDPJE);
        JEList_Work2.add(UDPJE1);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine2 = new Order_Line_Item__c();
        OrdLine2.Order_Line_Item_Number__c=714;
        OrdLine2.P5_Job_Element__c=JE2.Id;
        OrdLine2.P5_Purchase_Order__c=ord.Id;
        Ordline2.P5_Product__c=product.Id;
        OrdLine2.P5_Status_c__c='Active';
        //OrdLine.P5_Sub_Status_c__c='Ordered';
        OrdLine2.Units__c=10;
        OrdLine2.Quantity_Returned__c=100;
        OrdLine2.Skill__c='Scaffolder';
        OrdLine2.P5_Type__c='Work';
        OrdLine2.Description__c='testdescription';
        OrdLine2.Line_Item_Value__c = 89.90;
        OrdLine2.Code__c='345'; 
        //OrdLine.Name; 
        Ordline2.P5_Unit_Price_c__c=100;
        Ordline2.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert OrdLine2;
         // Ashoks code CR-005 UDP order
        Order_Line_Item__c UDPOrdLine = new Order_Line_Item__c();
        UDPOrdLine.Order_Line_Item_Number__c=514;
        //UDPOrdLine.P5_Job_Element__c=UDPJE.Id;
        UDPOrdLine.P5_Purchase_Order__c=ord.Id;
        UDPOrdLine.P5_Product__c=product.Id;
        UDPOrdLine.P5_Status_c__c='Active';
        //OrdLine.P5_Sub_Status_c__c='Ordered';
        UDPOrdLine.Units__c=10;
        UDPOrdLine.Quantity_Returned__c=100;
        UDPOrdLine.Skill__c='Scaffolder';
        UDPOrdLine.P5_Type__c='Material';
        UDPOrdLine.Description__c='testdescription';
        UDPOrdLine.Line_Item_Value__c = 89.90;
        UDPOrdLine.Code__c='345'; 
        //OrdLine.Name; 
        UDPOrdLine.P5_Unit_Price_c__c=100;
        UDPOrdLine.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert UDPOrdLine;
        
        List<Order_Line_Item__c> Ordlinelst2 = new List<Order_Line_Item__c>();
        Ordlinelst2.add(OrdLine2);
        Ordlinelst2.add(UDPOrdLine);
        
        
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        update ord;
        
        Region__c Regionc= new Region__c(Name='Region',Geography_Code__c ='2',Code__c='3', Type__c = 'Installation');
        insert Regionc;
         
        Product_Materials__c ProductMaterial = new Product_Materials__c(Quantity__c=12, Material_Code__c='12');    
        insert ProductMaterial;
        
        Product_Order__c productOrder=new Product_Order__c(Van_Stock__c=true,ORDER_FLAG__c='N');
        List<Product_Order__c> productOrderLst =new List<Product_Order__c>();
        insert productOrder;
        productOrderLst.add(productOrder);
        
        Work_Order__c workorder = new Work_Order__c(Work_Code__c='10',Skill_Type__c='Electrical',Description__c='TestWorkOrder');
        insert workorder; 
        
        Product_Work_Code__c productworkcode =new Product_Work_Code__c(Work_Code__c='123',Work_Code_Description__c='test');
        insert productworkcode;
        
        //Creating Ratcard With Postcode Skill Rate
        Rate_card=new Rate_Card__c( Rate_Card_Ext_Id__c='12876');
        Rate_card.P5_Supplier__c=supplier1.Id;
        
        insert Rate_card;
        List<Rate_Card__c> Ratecardlst = new List<Rate_Card__c>();
        Ratecardlst.add(Rate_card);
        
        //Creating Rate Card without Postcode Skiil RateObject
        Rate_card1=new Rate_Card__c(Rate_Card_Ext_Id__c='228756');
        Rate_card1.P5_Supplier__c=supplier2.Id;
        
        insert Rate_card1;
        List<Rate_Card__c> Ratecardlst1 = new List<Rate_Card__c>();
        Ratecardlst1.add(Rate_card1);
        
        subpatch = new Sub_Patch__c(Name='subpatch',Code__c='Code123',District__c=district.Id,Type__c='Sales');
        insert subpatch;
        
        String sPostCode=account.BillingPostalCode;
        Postcodesector = new Postcode_Sector__c(Name='psectorname',Type__c='Installation',Code__c='4411');
        Postcodesector.Sub_Patch__c=subpatch.Id;
        Postcodesector.P5_Primary_Supplier__c=supplier.Id;
        Postcodesector.P5_Secondary_Supplier__c=supplier1.Id;
        insert Postcodesector;
        
        rateCardSkill = new Post_Code_Skill_Rate__c();
        rateCardSkill.Skill__c='Electrical';
        rateCardSkill.Cost__c=100; 
        rateCardSkill.Preference__c='Active';
        rateCardSkill.Skill_External_Id__c='1231212';
        insert  rateCardSkill;
        
        system.debug('rateCardSkill---'+rateCardSkill);
        
        Post_Code_Skill_Rate__c rateCardSkill1 = new Post_Code_Skill_Rate__c();
        //rateCardSkill1.Post_Code_Rate_Card__c=PostcodeRC.Id;
        rateCardSkill1.Skill__c='Electrical';
        rateCardSkill1.Cost__c=100; 
        rateCardSkill1.Preference__c='Active';
        rateCardSkill1.Skill_External_Id__c='1231211';
        insert  rateCardSkill1;
        
        system.debug('rateCardSkill---'+rateCardSkill1);
        
        List<Post_Code_Skill_Rate__c> rateCardSkillLst=new List<Post_Code_Skill_Rate__c>();
        rateCardSkillLst.add(rateCardSkill);
                   
        
        Ratecarditems=new Rate_Card_Items__c(Cost__c=100,Skill__c='Electrical');
        Ratecarditems.Rate_Card__c=Rate_card.Id;
        Ratecarditems.Rate_Card_Item_Ext_Id__c='1562';
        Ratecarditems.Material__c=productOrder.Id;
        Ratecarditems.Work_Order__c=workorder.Id;
        Ratecarditems.Start_Date__c= System.TODAY();
        Ratecarditems.End_Date__c=System.TODAY()+3;
        insert Ratecarditems;
        Ratecarditemslst = new  List<Rate_Card_Items__c>();
        Ratecarditemslst.add(Ratecarditems);
        
        w_JobElementIndividualMap=new Map<String,List<Job_Element__c>>();
        string s1job='abc';
        s9job='abc';
        string s10job='abc';
        
        w_JobElementIndividualMap.put(s9job,JEList_Work2);
        
        
        String S_mat;
        
        l_PostcodeSkillRate = new Map<String,Post_Code_Skill_Rate__c>();
        //l_PostcodeSkillRate.put(supplier2.Supplier_Num__c,rateCardSkill);
        //l_PostcodeSkillRate.put(supplier1.Supplier_Num__c,rateCardSkill1);
        l_PostcodeSkillRate.put(rateCardSkill1.Skill__c,rateCardSkill);
        l_PostcodeSkillRate.put(rateCardSkill.Skill__c,rateCardSkill);
        
        //l_PostcodeSkillRate.put(supplier1.Supplier_Num__c,rateCardSkill1);
        system.debug('Post code skill--------'+ l_PostcodeSkillRate);
        
        
        l_RateCardItems=new Map<String,Rate_Card_Items__c>();
        l_RateCardItems.put(supplier2.Supplier_Num__c,Ratecarditems);
        l_RateCardItems.put(supplier.Supplier_Num__c,Ratecarditems);
        
        system.debug('Rate Card Items--------'+ l_RateCardItems);
        w_SupplierTotalJobElementMap = new Map<String,Map<String,List<Job_Element__c>>>();
        String s1job_total='job1total';
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);  
        
        
        postCodeSkillRateMap = new Map<String,Map<String,Post_Code_Skill_Rate__c>>();
        
        //postCodeSkillRateMap.put(supplier2.Supplier_Num__c,l_PostcodeSkillRate);
        postCodeSkillRateMap.put(supplier2.Supplier_Num__c,l_PostcodeSkillRate);
        system.debug('postCodeSkillRateMap--------'+ postCodeSkillRateMap);
        
        rateCardItemMap = new Map<String,Map<String,Rate_Card_Items__c>>();
        String s3jon_total='job3total';
        //rateCardItemMap.put(s3jon_total,l_RateCardItems);
        //rateCardItemMap.put(JE2.Code__c,l_RateCardItems);
        rateCardItemMap.put(supplier2.Supplier_Num__c,l_RateCardItems);
        
        l_RateCardItems=rateCardItemMap.get(s3jon_total);
    }
    static Map<String,List<Job_Element__c>> m_SelectedJobElementMap;
    static Map<String,Post_Code_Skill_Rate__c> l_PostcodeSkillRate;
    static Map<String,Map<String,List<Job_Element__c>>> w_SupplierTotalJobElementMap;
    static Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap;
    static Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap;
    static supplier__c supplier2;
    static string s9job;
    static Map<String,List<Job_Element__c>> w_JobElementIndividualMap;
    static List<Rate_Card_Items__c> Ratecarditemslst;
    static Map<String,Rate_Card_Items__c> m_Rate;
    static Map<String,Rate_Card_Items__c> l_RateCardItems;
    static Post_Code_Skill_Rate__c rateCardSkill;
    static Rate_Card__c Rate_card1;
    
    static testmethod void test_for_work_orders()
    {
        createTestData();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        
        job=(Job__c)stdCancelController.getRecord();
        Test.startTest();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
       
        postCodeSkillRateMap.put(supplier2.Supplier_Num__c, l_PostcodeSkillRate);
        
        System.debug('------ postCodeSkillRateMap = ' + postCodeSkillRateMap.get(supplier2.Supplier_Num__c));
       
        try{
        POAmend.generateWorkOrder(w_SupplierTotalJobElementMap,postCodeSkillRateMap,rateCardItemMap,supplier2.Supplier_Num__c);
        POAmend.cancel();
        }catch (Exception e)
        {
            
        }
        Test.stopTest();
    }
    
    
    static testmethod void test_for_work_orders_withitinerary()
    {
        createTestData();
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Work';
        JE3.New_Supplier__c=null;
        JE3.Order__c=null;
        JE3.New_Supplier_Number__c= supplier.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=true;
        insert JE3;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Active';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Work';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier.Id;
        
        insert OrdLine3;
        
        supplier2.Type__c='Work-Itinery';
        update supplier2; 
        
        //postCodeSkillRateMap.put(OrdLine3.Skill__c,l_PostcodeSkillRate);
        postCodeSkillRateMap.put(supplier.Supplier_Num__c, l_PostcodeSkillRate);
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        Test.startTest();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
       
        w_SupplierTotalJobElementMap.clear();
        w_SupplierTotalJobElementMap.put(supplier.Supplier_Num__c,w_JobElementIndividualMap);
        
        System.debug('------ postCodeSkillRateMap = ' + postCodeSkillRateMap.get(supplier.Supplier_Num__c));
        
        try{
        POAmend.generateItineryWorkOrder(w_SupplierTotalJobElementMap,postCodeSkillRateMap,rateCardItemMap,supplier.Supplier_Num__c);
        
        POAmend.confirmOrder();
        POAmend.saveOrder();
        POAmend.back();
        }catch(Exception e)
        {
            
        }
        Test.stopTest();
        
    }
    
    static testmethod void test_for_material_orders()
    {
        createTestData();
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Material';
        JE3.New_Supplier__c=null;
        JE3.Order__c=null;
        JE3.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=false;
        insert JE3;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        ord.Type__c='Material';
        update ord;
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Active';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Material';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier2.Id;
        
        insert OrdLine3;
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        
        Test.startTest();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
        
        for(PurchaseOrderAmendment.underOrderedItem udp_UnOrder : POAmend.udp_UnOrderedItem){
            
            udp_UnOrder.sSupplierId = '1234';
            
        }
        
        
        String strCode = 'asd';
        
        m_SelectedJobElementMap=new Map<String,List<Job_Element__c>>(); 
        m_Rate = new Map<String,Rate_Card_Items__c>();
        
        System.debug('------ JEList_Work_9 = ' + JEList_Work_9);
        System.debug('------ Ratecarditems = ' + Ratecarditems);
        System.debug('------ m_SelectedJobElementMap = ' + m_SelectedJobElementMap);
        System.debug('------ m_Rate = ' + m_Rate);
        
        m_SelectedJobElementMap.put(strCode, JEList_Work_9);
        m_Rate.put(strCode, Ratecarditems);
        
        POAmend.generateMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c, m_Rate);
        
        //POAmend.back();
        POAmend.confirmOrder();
        POAmend.saveOrder();
               
        
        Test.stopTest();
    }
    
    static testmethod void test_for_work_orders_fixedratecard()
    {
        createTestData();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        Test.startTest();
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
        
        rateCardSkill.Preference__c = 'Fixed';
        l_PostcodeSkillRate.put(rateCardSkill.Skill__c,rateCardSkill);
        
       
        postCodeSkillRateMap.put(supplier2.Supplier_Num__c, l_PostcodeSkillRate);
        
        System.debug('------ postCodeSkillRateMap = ' + postCodeSkillRateMap.get(supplier2.Supplier_Num__c));
       
       try{
        POAmend.generateWorkOrder(w_SupplierTotalJobElementMap,postCodeSkillRateMap,rateCardItemMap,supplier2.Supplier_Num__c);
        //POAmend.back();
        POAmend.saveOrder();
        POAmend.confirmOrder();
       } catch(Exception e)
       {
           
       }
        Test.stopTest();
    }
    
    
    static testmethod void test_for_materialItinerary_orders()
    {
        createTestData();
        
        //supplier2.Type__c='Material-Itinery';
        //update supplier2;
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Material';
        JE3.New_Supplier__c=null;
        JE3.Order__c=ord.Id;
        JE3.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=true;
        insert JE3;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        
        ord.Type__c='Itinerary';
        update ord;
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Active';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Material';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier2.Id;
        
        insert OrdLine3;
        Test.startTest();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
        
        String strCode = 'asd';
        
        m_SelectedJobElementMap=new Map<String,List<Job_Element__c>>(); 
        m_Rate = new Map<String,Rate_Card_Items__c>();
        m_SelectedJobElementMap.put(strCode, JEList_Work_9);
        m_Rate.put(strCode, Ratecarditems);
        
        System.debug('------ JEList_Work_9 = ' + JEList_Work_9);
        System.debug('------ Ratecarditems = ' + Ratecarditems);
        System.debug('------ m_SelectedJobElementMap = ' + m_SelectedJobElementMap);
        System.debug('------ m_Rate = ' + m_Rate);
        
        
        
        List<Rate_Card__c> ratecards = [Select P5_Supplier__r.Type__c, P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Fax__c, 
                                            P5_Supplier__r.Status_code__c, P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c, Rate_Card_Type__c From Rate_Card__c Where P5_Supplier__r.id = :supplier2.id];
                                            
        System.debug('------ ratecards = ' + ratecards);
        System.debug('------ ratecards[0].P5_Supplier__r = ' + ratecards[0].P5_Supplier__r);
        
        
        POAmend.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c, m_Rate);
        //POGen.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c,l_RateCardItems );
        //POAmend.back();
        POAmend.saveOrder();
        POAmend.confirmOrder();
        Test.stopTest();
    }
    
    static testmethod void test_for_orders_with_cancelledlineitems()
    {
        createTestData();
        
        //supplier2.Type__c='Material-Itinery';
        //update supplier2;
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Material';
        JE3.New_Supplier__c=null;
        JE3.Order__c=ord.Id;
        JE3.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=true;
        insert JE3;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        
        ord.Type__c='Itinerary';
        update ord;
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Cancelled';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Material';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier2.Id;
        
        insert OrdLine3;
        Test.startTest();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
        
        String strCode = 'asd';
        
        m_SelectedJobElementMap=new Map<String,List<Job_Element__c>>(); 
        m_Rate = new Map<String,Rate_Card_Items__c>();
        m_SelectedJobElementMap.put(strCode, JEList_Work_9);
        m_Rate.put(strCode, Ratecarditems);
        
        System.debug('------ JEList_Work_9 = ' + JEList_Work_9);
        System.debug('------ Ratecarditems = ' + Ratecarditems);
        System.debug('------ m_SelectedJobElementMap = ' + m_SelectedJobElementMap);
        System.debug('------ m_Rate = ' + m_Rate);
        
        
        
        List<Rate_Card__c> ratecards = [Select P5_Supplier__r.Type__c, P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Fax__c, 
                                            P5_Supplier__r.Status_code__c, P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c, Rate_Card_Type__c From Rate_Card__c Where P5_Supplier__r.id = :supplier2.id];
                                            
        System.debug('------ ratecards = ' + ratecards);
        System.debug('------ ratecards[0].P5_Supplier__r = ' + ratecards[0].P5_Supplier__r);
        
        
        POAmend.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c, m_Rate);
        //POGen.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c,l_RateCardItems );
        //POAmend.back();
        POAmend.saveOrder();
        POAmend.confirmOrder();
        POAmend.getBlConfirm();
        POAmend.setBlConfirm(true);
        POAmend.getPurchaseOrderList();
        POAmend.setPurchaseOrderList(null);
        
            
        Test.stopTest();
    }
    
    static testmethod void test_for_orders_with_no_price()
    {
        createTestData();
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Work';
        JE3.New_Supplier__c=null;
        JE3.Order__c=ord.Id;
        JE3.New_Supplier_Number__c= supplier.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=true;
        insert JE3;
        //Ashok - test class
        Job_Element__c JE4 = new Job_Element__c();
        JE4.Job__c = job.Id;
        JE4.Type__c='Work';
        JE4.New_Supplier__c=null;
        JE4.Order__c=ord.Id;
        JE4.New_Supplier_Number__c= supplier.Supplier_Num__c;
        JE4.Current_Supplier__c='CSupplier1';
        JE4.Current_Supplier_Number__c='321';
        JE4.Code__c='345';
        JE4.Supplier_Order_Number__c='1212';
        JE4.Status__c='Active';
        JE4.Sub_Status__c='Awaiting Order';
        JE4.Description__c='testDescription';
        JE4.Line_Item_ID__c='124';
        JE4.Skill__c='Scaffolder';
        JE4.Units__c=125;
        JE4.P5_IsItinerary__c=true;
        insert JE4;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        JEList_Work_9.add(JE4);
        
        
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Active';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Work';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier.Id;
        
        insert OrdLine3;
        
        supplier2.Type__c='Work-Itinery';
        update supplier2; 
        
        //postCodeSkillRateMap.put(OrdLine3.Skill__c,l_PostcodeSkillRate);
        //postCodeSkillRateMap.put(supplier.Supplier_Num__c, l_PostcodeSkillRate);
        Test.startTest();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
       
        w_SupplierTotalJobElementMap.clear();
        w_SupplierTotalJobElementMap.put(supplier.Supplier_Num__c,w_JobElementIndividualMap);
        
        System.debug('------ postCodeSkillRateMap = ' + postCodeSkillRateMap.get(supplier.Supplier_Num__c));
        
       
        POAmend.generateItineryWorkOrder(w_SupplierTotalJobElementMap,postCodeSkillRateMap,rateCardItemMap,supplier.Supplier_Num__c);
        
        POAmend.confirmOrder();
        POAmend.saveOrder();
        //POAmend.back();
        PurchaseOrderAmendmentHelper POAmendHelper = new PurchaseOrderAmendmentHelper();
        Map<String,Supplier__c> udp_Supplier_Map = new Map<String,Supplier__c>();
        udp_Supplier_Map.put('asd',supplier2);
        //ADDED BY ARUNA: START
        POAmendHelper.setDummyString();
        //ADDED BY ARUNA: END
       //POAmendHelper.generateMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c, m_Rate);
        List<PurchaseOrderAmendment.underOrderedItem> lstPOUnorder = new List<PurchaseOrderAmendment.underOrderedItem>();
        POAmendHelper.stampSelectedSupplierOnJE(lstPOUnorder,job,udp_Supplier_Map);
        Test.stopTest();
    }
    
    /*
    static testmethod void test_for_orders_with_unordered_job_element()
    {
        createTestData();
        
        //supplier2.Type__c='Material-Itinery';
        //update supplier2;
        
        Job_Element__c JE3 = new Job_Element__c();
        JE3.Job__c = job.Id;
        JE3.Type__c='Material';
        JE3.New_Supplier__c=null;
        JE3.Order__c=ord.Id;
        JE3.New_Supplier_Number__c= supplier2.Supplier_Num__c;
        JE3.Current_Supplier__c='CSupplier1';
        JE3.Current_Supplier_Number__c='321';
        JE3.Code__c='345';
        JE3.Supplier_Order_Number__c='1212';
        JE3.Status__c='Active';
        JE3.Sub_Status__c='Awaiting Order';
        JE3.Description__c='testDescription';
        JE3.Line_Item_ID__c='124';
        JE3.Skill__c='Scaffolder';
        JE3.Units__c=125;
        JE3.P5_IsItinerary__c=true;
        insert JE3;
        List<Job_Element__c> JEList_Work_9 =new List<Job_Element__c>();
        JEList_Work_9.add(JE3);
        
        ord.Type__c='Itinerary';
        update ord;
        
        w_JobElementIndividualMap.put(s9job,JEList_Work_9);
        w_SupplierTotalJobElementMap.put(supplier2.Supplier_Num__c,w_JobElementIndividualMap);
        
        
        //Creating Order line Item with Active Status
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE3.Id;
        OrdLine3.P5_Purchase_Order__c=ord.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Status_c__c='Cancelled';
        OrdLine3.Units__c=10;
        OrdLine3.Quantity_Returned__c=100;
        OrdLine3.Skill__c='Scaffolder';
        OrdLine3.P5_Type__c='Material';
        OrdLine3.Description__c='testdescription';
        OrdLine3.Line_Item_Value__c = 89.90;
        OrdLine3.Code__c='345'; 
        OrdLine3.P5_Unit_Price_c__c=100;
        OrdLine3.Supplier__c=supplier2.Id;
        
        //insert OrdLine3;
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(job);
        job=(Job__c)stdCancelController.getRecord();
        //PurchaseOrderGenertion POGen =new PurchaseOrderGenertion(stdCancelController);
        PurchaseOrderAmendment POAmend = new PurchaseOrderAmendment(stdCancelController);
        
        String strCode = 'asd';
        
        m_SelectedJobElementMap=new Map<String,List<Job_Element__c>>(); 
        m_Rate = new Map<String,Rate_Card_Items__c>();
        m_SelectedJobElementMap.put(strCode, JEList_Work_9);
        //m_Rate.put(strCode, Ratecarditems);
        
        System.debug('------ JEList_Work_9 = ' + JEList_Work_9);
        System.debug('------ Ratecarditems = ' + Ratecarditems);
        System.debug('------ m_SelectedJobElementMap = ' + m_SelectedJobElementMap);
        System.debug('------ m_Rate = ' + m_Rate);
        
        
        
        List<Rate_Card__c> ratecards = [Select P5_Supplier__r.Type__c, P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Fax__c, 
                                            P5_Supplier__r.Status_code__c, P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c, Rate_Card_Type__c From Rate_Card__c Where P5_Supplier__r.id = :supplier2.id];
                                            
        System.debug('------ ratecards = ' + ratecards);
        System.debug('------ ratecards[0].P5_Supplier__r = ' + ratecards[0].P5_Supplier__r);
        
        
        POAmend.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c, m_Rate);
        //POGen.generateItineryMaterialOrder(m_SelectedJobElementMap, supplier2.Supplier_Num__c,l_RateCardItems );
        POAmend.back();
        POAmend.saveOrder();
        POAmend.confirmOrder();
                
    }*/  
    
    static testmethod void test_AutoPopulateSupplierChange(){
         createTestData(); 
         Test.startTest();
         ApexPages.StandardController controller = new ApexPages.StandardController(job);
        PurchaseOrderAmendment ext = new PurchaseOrderAmendment(controller);
        ext.onSelectAutoPopulateSupplier();
        Test.stopTest();
    }  
    
}