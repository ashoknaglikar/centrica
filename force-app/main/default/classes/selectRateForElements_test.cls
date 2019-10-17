@isTest
private class selectRateForElements_test {
    static Rate_Card__c Rate_card;
    static Rate_Card__c Rate_card1;
    static Post_Code_Rate_Card__c Post_Rate_Card;
    //static Supplier_Fixed_Rate_Card__c Supplier_Rate_Card;
    static Job_Element__c Job_Element;
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
    static SFPO7523_Batch__c objBatch;
    static SFPO7523_Order_Header__c objHeader;
    static Order__c ord;
    static List<order__c> ordlst;
    static Rate_Card_Items__c Ratecarditems;
    static Rate_Card_Items__c Ratecarditems1;
    static Post_Code_Rate_Card__c PostcodeRC;
    static Postcode_Sector__c Postcodesector;
    static Sub_Patch__c  subpatch;
    static Supplier_Custom_Material_Code__c Supplier_CMC;
    static Supplier_Custom_Material_Code__c Supplier_CMC1;
	static Post_Code_Supplier_Branch__c PC_supp_branch;
	static Supplier_Branch__c Supp_branch;
	static Supplier_Region_Supplier_Branch__c supp_Reg_branch;
    
    
    static testMethod void RatecardsMethod() {
       selectRateForElements Ratelements = new selectRateForElements();    
       // Ratelements.fetchElementRate(suppIds, lstJE, postCodeSec, Region);
        //Job_Element=new Job_Element__c(Type__c='Work');
        //insert Job_Element;
            account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
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
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,Material_Labour_Charges__c=123);
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

        Region__c Regionc= new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation',Geography_Code__c ='09');
         insert Regionc;
         
        District__c district = new District__c (Code__c = 'I12M',Region__c=Regionc.id,Type__c='Installation',Name = 'Greenwich');
          insert   district;    
      
       
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
        ord.Order_Value__c=1100;
        ord.Prior_Order_Value__c=0; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        ord.Approved__c=true;
        // ord.Order_Date__c.format();
        insert ord;
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
        Job_Element__c JE = new Job_Element__c(Type__c ='Work',Skill__c='Asbestos Removal',Code__c = 'code');
        JE.Job__c = job.Id;
        insert JE;
        List<Job_Element__c> JEList =new List<Job_Element__c>();
        JEList.add(JE);
        //String s1='2';
        //insert s1;
         List<String> supplier1=new List<String>();
         String s1 = supplier.Supplier_Num__c;
         
        Set<String> suppNumSet =new Set<String>();
        suppNumSet.add(s1);
        
                
        Product_Materials__c ProductMaterial = new Product_Materials__c(Quantity__c=12, Material_Code__c='12');    
        insert ProductMaterial;
        
        Product_Order__c productOrder=new Product_Order__c(Van_Stock__c=true,ORDER_FLAG__c='N', Product_Number__c = 'code', Van_Stock_Value__c =1 ); 
        
        List<Product_Order__c> productOrderLst =new List<Product_Order__c>();
        insert productOrder;
        
        productOrderLst.add(productOrder);
        
        Supplier_Region__c supplier_Region= new Supplier_Region__c(Supplier_Region_External_ID__c='123');
        supplier_Region.Supplier__c=supplier.Id;
        supplier_Region.Region__c=Regionc.id;
        insert supplier_Region;
        
        
        Product_Work_Code__c productworkcode =new Product_Work_Code__c(Work_Code__c='123',Work_Code_Description__c='test');
        insert productworkcode;
        
        Rate_card=new Rate_Card__c();
        Rate_card.P5_Supplier__c=supplier.Id;
        
        //Rate_card.Product_Order__c=productOrder.Id;
        //Rate_card.Supplier_Region__c=supplier_Region.Id;
        //Rate_card.Product_Work_Code__c=productworkcode.Id;
       // Rate_card.Id=Rate_card.Id;
        //Rate_card.Rate_Card_Type__c= 0;
        
//        Rate_card.Supplier_Num__c=supplier.Id;
        s1=Rate_card.Supplier_Num__c;
        supplier1.add(s1);
        
        insert Rate_card;
        List<Rate_Card__c> Ratecardlst = new List<Rate_Card__c>();
        
        Ratecardlst.add(Rate_card);
        
        
        Rate_card1=new Rate_Card__c();
        Rate_card1.P5_Supplier__c=supplier.Id;
        
        //Rate_card.Product_Order__c=productOrder.Id;
        //Rate_card.Supplier_Region__c=supplier_Region.Id;
        //Rate_card.Product_Work_Code__c=productworkcode.Id;
       // Rate_card.Id=Rate_card.Id;
        //Rate_card.Rate_Card_Type__c= 0;
        
//        Rate_card.Supplier_Num__c=supplier.Id;
		String s2;
        s2=Rate_card1.Supplier_Num__c;
        supplier1.add(s2);
        
        insert Rate_card1;
        List<Rate_Card__c> Ratecardlst1 = new List<Rate_Card__c>();
        
        Ratecardlst1.add(Rate_card1);
        
        
        Supplier_CMC = new Supplier_Custom_Material_Code__c ();
        Supplier_CMC.Supplier__c=supplier.Id;
        Supplier_CMC.Region__c = Regionc.id;
        Supplier_CMC.District__c = district.Id;
        Supplier_CMC.Custom_Material_Code__c = '12';
 	    //Supplier_CMC.Supplier_Num__c=Rate_card.Supplier_Num__c;
 		Supplier_CMC.Material_Code__c = '12';
 		insert Supplier_CMC;
 		Supplier_CMC1 = new Supplier_Custom_Material_Code__c ();
        Supplier_CMC1.Supplier__c=supplier.Id;
        Supplier_CMC1.Region__c = null;
        Supplier_CMC1.District__c = null;
        Supplier_CMC1.Custom_Material_Code__c = '12';
 	    //Supplier_CMC.Supplier_Num__c=Rate_card.Supplier_Num__c;
 		Supplier_CMC1.Material_Code__c = '12';
 		insert Supplier_CMC1;
        String s3;
        s3 = Supplier_CMC.Supplier_Num__c;
        supplier1.add(s3);
        subpatch = new Sub_Patch__c(Code__c='code' );
        insert subpatch;
        Postcodesector = new Postcode_Sector__c();
        Postcodesector.Sub_Patch__c=subpatch.Id;
       // Postcodesector.Postcode_Sector__c=
        insert Postcodesector;
        
         
        
        PostcodeRC = new Post_Code_Rate_Card__c(Post_Code_Rate_Card_Ext_Id__c='12');
        PostcodeRC.Rate_Card__c=Rate_card.Id;
        PostcodeRC.Region__c=Regionc.id;
        PostcodeRC.Postcode_Sector__c=Postcodesector.Id;
        
        //supplier1=PostcodeRC .Supplier_Num__c;
        insert PostcodeRC;
        List<Post_Code_Rate_Card__c> PostcodeRCLst = new List<Post_Code_Rate_Card__c>();
        PostcodeRCLst.add(PostcodeRC);
        
        Post_Code_Skill_Rate__c rateCardSkill = new Post_Code_Skill_Rate__c();
         
         rateCardSkill.Post_Code_Rate_Card__c=PostcodeRC.Id;
         rateCardSkill.Skill__c='Powerflush';
         rateCardSkill.Cost__c=100; 
         rateCardSkill.Preference__c='Active';
         
         insert  rateCardSkill;
         
	    List<Post_Code_Skill_Rate__c> rateCardSkillLst=new List<Post_Code_Skill_Rate__c>();
	    rateCardSkillLst.add(rateCardSkill);
	    update PostcodeRC;         
        Ratecarditems=new Rate_Card_Items__c(Cost__c=100,Skill__c='Solar');
        Ratecarditems.Rate_Card__c=Rate_card.Id;
        //Ratecarditems.Rate_Card_Type__c=0;
        Ratecarditems.Material__c=productOrder.Id;
        Ratecarditems.Start_Date__c= System.TODAY();
        Ratecarditems.End_Date__c=System.TODAY()+3;
        Ratecarditems.Material__c=productOrder.Id;
        system.debug('-----------status'+ Ratecarditems.Status__c);
        insert Ratecarditems;
        
        List<Rate_Card_Items__c> Ratecarditemslst = new  List<Rate_Card_Items__c>();
        Ratecarditemslst.add(Ratecarditems);
        
        
        
        Ratecarditems1=new Rate_Card_Items__c(Cost__c=100,Skill__c='Solar');
        Ratecarditems1.Rate_Card__c=Rate_card1.Id;
        Ratecarditems1.Start_Date__c= System.TODAY();
        Ratecarditems1.End_Date__c=System.TODAY()+3;
        Ratecarditems1.Material__c=productOrder.Id;
        system.debug('-----------status'+ Ratecarditems.Status__c);
        insert Ratecarditems1;
        
        List<Rate_Card_Items__c> Ratecarditemslst1 = new  List<Rate_Card_Items__c>();
        Ratecarditemslst1.add(Ratecarditems1);
        
        Product_Materials__c Pro_mat = new Product_Materials__c(Product_Code__c='23',Material_Code__c = '12',Quantity__c = 13);
        insert Pro_mat;
        
        
        Map<String,Rate_Card_Items__c> Submap= new Map<String,Rate_Card_Items__c>();
        String s4 = 'rateitems';
        Submap.put(s4,Ratecarditems1);
        String s5=Pro_mat.Product_Code__c;
        Map<String,Map<String,Rate_Card_Items__c>> SupplierRateCardItemMap= new Map<String,Map<String,Rate_Card_Items__c>>();
        SupplierRateCardItemMap.put(s5,Submap);
        
        
        //List<String> supplier1=new List<String>();
        //Set<String> suppNumSet =new Set<String>();
        Supp_branch = new Supplier_Branch__c(Branch_Num__c='123',Supplier__c= supplier.Id);
        insert Supp_branch;
        PC_supp_branch= new Post_Code_Supplier_Branch__c(Postcode_Sector__c=Postcodesector.Id,Supplier_Branch__c=Supp_branch.Id);
        insert PC_supp_branch;
        
        supp_Reg_branch = new Supplier_Region_Supplier_Branch__c(Supplier_Branch__c=Supp_branch.Id,Region__c=Regionc.id);       
        insert supp_Reg_branch;
        
        Map<String,List<Job_Element__c>> m_JobElementMap = new  Map<String,List<Job_Element__c>>();
        Map<String,Map<String,List<Job_Element__c>>> w_JobElementMap = new Map<String,Map<String,List<Job_Element__c>>>();
        productOrder= [select Product_Code__c,Van_Stock__c,ORDER_FLAG__c, Product_Number__c, Van_Stock_Value__c from Product_Order__c where id= :productOrder.Id];
        string pcode= productOrder.Product_Code__c;
       // pcode='C123';
        string pstatus =Ratecarditems.Status__c;
        //pstatus='Active';
        m_JobElementMap.put(pcode,JEList);   
       	w_JobElementMap.put(pstatus,m_JobElementMap);
        //pMap
        //w_JobElementMap.pput(pString, pMap))
        String Region1=Regionc.id;
        String dist=district.Id;
                  
       // supplier1.add(supplier);
      
         String PCsector1=Postcodesector.Id;
         Ratelements.getVanStockElementMap();
         Ratelements.setVanStockElementMap(m_JobElementMap);
         Ratelements.setNotVanStockElementMap(m_JobElementMap);
         Ratelements.getNotVanStockElementMap();
         Ratelements.findBranchNum(supplier1,PCsector1,Region1);
         Ratelements.fetchMaterialSupplierRate(suppNumSet,m_JobElementMap,PCsector1,Region1,dist);
         
         Ratelements.fetchWorkSupplierRate(suppNumSet,w_JobElementMap,PCsector1,Region1,dist);
         
         //f(productOrderLst.Product_Code__c=='c')
         
         
         //Ratelements.segregateVanstockElements(m_JobElementMap, true);
         Supplier_Region_Van_Stock_Value__c srvc = new Supplier_Region_Van_Stock_Value__c(Supplier__c = supplier.Id, Region__c = Region1, Van_Stock_Value__c = 1);
         insert srvc;
         
	     decimal num = Ratelements.fetchMaxVanstockvalue(suppNumSet,Region1);
	     
	    
	     
	     system.debug('Elements--->'+m_JobElementMap+'Num---->'+ num +productOrder);
	     Ratelements.segregateVanstockElementsByRegion(m_JobElementMap, num);
	     
	     system.debug('Elements--->'+m_JobElementMap+'Num---->'+ num +productOrder);
         Ratelements.segregateNonOrderableComponent(m_JobElementMap);
         Ratelements.getNonOrderableElementMap();
         Ratelements.setNonOrderableElementMap(m_JobElementMap);
         Ratelements.getOrderableElementMap();
         Ratelements.setOrderableElementMap(m_JobElementMap);
         //Ratelements.materialandLabourcharges(ordlst);
         
         // update job;
        //List<Rate_Card_Items__c> RateCardItemLst
        //Ratelements.fetchJobElementRate(null,null,null,null);
        
       
       ord.Order_Value__c = -10;
       update ord;
       
       //Ratelements.materialandLabourcharges(new List<order__c>{ ord});
       
       
        Rate_Card__c Rate_cardObj=[Select Id,Supplier_Num__c,P5_Supplier__c,Rate_Card_Type__c from Rate_Card__c where Id=:Rate_card.Id]; 
      	system.debug('Rate_card2Obj--------------->>>>>>'+Rate_cardObj);
      	List<Rate_Card__c> rateCardLst4 = new List<Rate_Card__c>();
      	rateCardLst.add(Rate_cardObj);
        
    }
}