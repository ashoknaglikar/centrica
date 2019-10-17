/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *  
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */ 

@isTest 
private class SplitJobController_Test {
    
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Supplier__c supplier1;
    static Supplier__c supplier2;
    static Employee__c emp;
    static Employee__c emp1;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    //static Opportunity opportunity1;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    //static Quote_Product__c quoteProduct;
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
    static ASP__c asp ;
    static ASP__c asp1 ;
    //static Product2 product;
    static Quote_Product__c quoteProduct; 
    static District__c district;
    //static Job__c job;
    static List<Job__c> Joblist; 
    static Job_Element__c jobelement;
    static Product_Work_code__c PWC;
    static Product_Work_code__c PWC1;
    static Product_Materials__c productMaterials;
    static Product_Materials__c productMaterials1;
    static List<Product_Work_code__c> workcodeList;
    static List<Product_Materials__c> productMaterialsList;
    static List<Job_Element__c> JobElemList;
    static List<Quote_Product__c> qplist;
    static List<Rate_Card__c> Ratecardlst;
    static List<Rate_Card__c> Ratecardlst1;
    static List<String> jobIdList;
    static Map<String,boolean> jobBMap;
    static List<Quote_Product__c> lstQPquery; 
    
    
    static void PrepareData() {
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        String postCodeSector1 = (account.BillingPostalCode).substring(0,(account.BillingPostalCode).length()-2);  
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;
          
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp',Platform__c = 'Premier', StageName ='Active',CloseDate=System.today().addYears(1),                                     
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
       /* opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
       opportunity.Platform__c='Premier'; */
        
        opp = new Opportunity[]{opportunity};                                                 
        insert opp;
        
        supplier2 = new supplier__c(Name='Test supplier2',ANA_Number__c='123',Type__c='Product',Status_code__c='A',Supplier_Num__c='C1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='S');
        insert supplier2;
        
        supplier1 = new supplier__c(Name='Test supplier1',ANA_Number__c='122',Type__c='Resource',Supplier_Num__c='B1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
        insert supplier1;
        
        
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
        quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        
        update quote;
         
        asp = new ASP__c(Function__c='Sales', Description__c='test', Definition__c='Addition', Approved_By__c=emp.Id,ASP_Date__c=System.today());      
        asp.Quote__c=quote.id;
        insert asp; 
        
        asp1 = new ASP__c(Function__c='Sales', Description__c='test', Definition__c='Addition', Approved_By__c=emp.Id,ASP_Date__c=System.today());      
        asp1.Quote__c=quote.id;
        insert asp1; 
        
       
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        insert product;
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',ASP__c=asp.Id,  
                                                            BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,Part_Number__c='ABC123',
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=1,VAT_Code__c='4');
        
        district = [Select id,type__c from District__c where type__c = 'Installation' limit 1];
         
        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id,Status__c='Pending', 
                                PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id);
                       
        insert job;
       
        job1 = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id,Status__c='Pending', 
                                PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id);
                       
        insert job1;
        
               
        Joblist = new List<Job__c>();
        Joblist.add(job);
                
        JE = new Job_Element__c();
        JE.Completion_Date__c=system.today();
        JE.Start_Date__c=system.today();
        JE.Job__c=job.id;     
        JE.Unit_Price__c=10;
        JE.Status__c='Active';
        JE.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE.Type__c='Work';
        JE.Product_ID__c='ABC123';
        
        
        JE1 = new Job_Element__c();
        JE1.Completion_Date__c=system.today();
        JE1.Start_Date__c=system.today();
        JE1.Job__c=job.id;     
        JE1.Unit_Price__c=10;
        JE1.Status__c='Active';
        JE1.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE1.Type__c='Work';
        JE1.Product_ID__c='ABC123';
        
        
        //create postcode sector
        
        //Creating Ratcard With Postcode Skill Rate
        Rate_card=new Rate_Card__c( Rate_Card_Ext_Id__c='12876');
        Rate_card.P5_Supplier__c=supplier2.Id;
        
        insert Rate_card;
        Ratecardlst = new List<Rate_Card__c>();
        Ratecardlst.add(Rate_card);
        
        //Creating Rate Card without Postcode Skiil RateObject
        Rate_card=new Rate_Card__c(Rate_Card_Ext_Id__c='228756');
        Rate_card.P5_Supplier__c=supplier2.Id;
        
        insert Rate_card;
        Ratecardlst1 = new List<Rate_Card__c>();
        Ratecardlst1.add(Rate_card);
        
        subpatch = new Sub_Patch__c(Name='subpatch',Code__c='Code123',District__c=district.Id,Type__c='Sales');
        insert subpatch;
        
        String sPostCode=account.BillingPostalCode;
        Postcodesector = new Postcode_Sector__c(Name=postCodeSector1,Type__c='Installation',Code__c='4411');
        Postcodesector.Sub_Patch__c=subpatch.Id;
        Postcodesector.P5_Primary_Supplier__c=supplier.Id;
        Postcodesector.P5_Secondary_Supplier__c=supplier1.Id;
        insert Postcodesector;
        
               
        jobIdList = new List<String>();
        jobIdList.add(job.Id);
        
        jobBMap  = new Map<String,boolean>();
        jobBMap.put(job.Id,true);
               
        //String selected = 'Selected';
        
        
      }
      
      
      static testMethod void SplitJobControl_work1()
      {
        PrepareData();
        
        quoteProduct.Part_Number__c='ABC123';
        quoteProduct.Quantity__c = 1;
        insert quoteProduct;
        
        qplist = new list<Quote_Product__c>();
        qplist.add(quoteProduct);
        
        JE.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE.Type__c='Work';
        JE.Product_ID__c='ABC123';
        insert JE;
        JE1.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE1.Type__c='Work';
        JE1.Product_ID__c='ABC123';
        insert JE1;
               
        PWC = new Product_Work_code__c();
        PWC.Active__c=true;
        PWC.End_Date__c=system.today()+2;
        PWC.Skill__c='Electrical';
        //PWC.Product_Code__c=quoteProduct.Part_Number__c;
        PWC.Start_Date__c=system.today()-1;
        PWC.Hours__c=10;
        PWC.Work_Code_Description__c ='Test description';
        PWC.Work_Code__c='100';
        PWC.Product_Code__c=JE.Product_ID__c;
        insert PWC;
        workcodeList = new List<Product_Work_code__c>();
        workcodeList.add(PWC);
        //String selected = 'Selected';
        
        PageReference pageRef2 = Page.SplitJob;
        Test.setCurrentPage(pageRef2); 
        ApexPages.currentPage().getParameters().put('oppId',opportunity.Id);      
        ApexPages.currentPage().getParameters().put('orgJobId',job.Id);      
       // SplitJobController.packDetails obj = new SplitJobController.packDetails();
        //Splitjob.pckDetList();
        //Splitjob.getPckDetList();
        boolean sel1;
        Job_Element__c[] JEList = new Job_Element__c[]{je,je1};
        SplitJobController.packDetails obj1 = new  SplitJobController.packDetails (JEList);
        obj1.getpackElement();
        obj1.getB_IsElementSelected();
        obj1.setB_IsElementSelected(sel1);
        SplitJobController Splitjob = new SplitJobController();
        Splitjob.sets_jobId(job.Id);  
        Splitjob.setJeJobId(job.id);   
        Splitjob.gets_jobId();
        Splitjob.getObjOpp(); 
        Splitjob.getJeJobId();      
        Splitjob.setErrorMsg('no error');
        Splitjob.getJobDetails();
        
        lstQPquery = [Select Name,id,q.Sales_Price__c, q.Quantity__c, q.Product_Description__c,
            q.BigMachines_Quote__c,  
            q.Part_Number__c,q.ASP__r.Name, q.ASP__c From Quote_Product__c q 
            where BigMachines_Quote__c=:Quote.Id and Part_Number__c = :JE   .Product_ID__c];
            
        System.debug('--------------- lstQP = ' + lstQPquery);
        Splitjob.actnFetchElements();
        //Splitjob.pckDetList[0].b_IsElementSelected = true;
        Splitjob.SplitJOB();  
        
        if(Splitjob.pckDetList.size()>0){
          Splitjob.pckDetList[0].b_IsElementSelected = true;
        }
        Splitjob.sets_jobId(job1.id);  
        Splitjob.SplitJOB();  
              
        Splitjob.actnCancel();
        //Splitjob.updateJob(qplist,jobIdList,jobBMap);
        boolean sel;
        SplitJobController.packDetails obj = new SplitJobController.packDetails (JEList);
        system.debug('--quoteProduct' +quoteProduct);
        obj.packElement = quoteProduct;
        obj.b_IsElementSelected = true;
        obj.getB_IsElementSelected();
        obj.setB_IsElementSelected(sel);
        //obj.setB_IsElementSelected = false;
        //obj.getB_IsElementSelected();
        obj.getpackElement();
        Splitjob.getPckDetList();       
        Splitjob.actnCloneJOb();
        Splitjob.getPckDetList();
        Splitjob.getErrorMsg();
        //Splitjob.setJeJobId('Some Job');
        Splitjob.getJeJobId();
      }
      
      static testmethod void Splitjobcontroller_material1(){
        
        PrepareData();
        quote.bmStatusReason__c = null;
        update quote;
        quoteProduct.Part_Number__c='ABC123';
        quoteProduct.Quantity__c = 1;
        insert quoteProduct;
        
        qplist = new list<Quote_Product__c>();
        qplist.add(quoteProduct);
        
        JE.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE.Type__c='Material';
        JE.Product_ID__c='ABC123';
        insert JE;
        
        productMaterials=new Product_Materials__c();
        productMaterials.Active__c=true;
        productMaterials.End_Date__c=system.today()+2;
        productMaterials.Start_Date__c=system.today()-1;
        productMaterials.Product_Code__c=JE.Product_ID__c; 
        productMaterials.Quantity__c=1;
        productMaterials.Material_Code__c='B';
        insert productMaterials;
        
        productMaterialsList=new List<Product_Materials__c>();
        productMaterialsList.add(productMaterials);
        
        PWC = new Product_Work_code__c();
        PWC.Active__c=true;
        PWC.End_Date__c=system.today()+2;
        PWC.Skill__c='Electrical';
        //PWC.Product_Code__c=quoteProduct.Part_Number__c;
        PWC.Start_Date__c=system.today()-1;
        PWC.Hours__c=10;
        PWC.Work_Code_Description__c ='Test description';
        PWC.Work_Code__c='100';
        PWC.Product_Code__c=JE.Product_ID__c;
        insert PWC;
        workcodeList = new List<Product_Work_code__c>();
        workcodeList.add(PWC);
        //String selected = 'Selected';
        
        PageReference pageRef2 = Page.SplitJob;
        Test.setCurrentPage(pageRef2); 
        ApexPages.currentPage().getParameters().put('oppId',opportunity.Id);      
        ApexPages.currentPage().getParameters().put('orgJobId',job.Id);      
       // SplitJobController.packDetails obj = new SplitJobController.packDetails();
        //Splitjob.pckDetList();
        //Splitjob.getPckDetList();
        boolean sel1;
        Job_Element__c[] JEList = new Job_Element__c[]{JE,JE1};
        SplitJobController.packDetails obj1 = new  SplitJobController.packDetails (JEList);
        obj1.getpackElement();
        obj1.getB_IsElementSelected();
        obj1.setB_IsElementSelected(sel1);
        SplitJobController Splitjob = new SplitJobController();
        Splitjob.sets_jobId(job.Id);  
        Splitjob.setJeJobId(job.id);   
        Splitjob.gets_jobId();
        Splitjob.getObjOpp(); 
        Splitjob.getJeJobId();      
        Splitjob.setErrorMsg('no error');
        Splitjob.getJobDetails();
        
        lstQPquery = [Select Name,id,q.Sales_Price__c, q.Quantity__c, q.Product_Description__c,
            q.BigMachines_Quote__c,  
            q.Part_Number__c,q.ASP__r.Name, q.ASP__c From Quote_Product__c q 
            where BigMachines_Quote__c=:Quote.Id and Part_Number__c = :JE   .Product_ID__c];
            
        System.debug('--------------- lstQP = ' + lstQPquery);
        Splitjob.actnFetchElements();
        //Splitjob.pckDetList[0].b_IsElementSelected = true;
        Splitjob.SplitJOB();
        Splitjob.actnCancel();
        //Splitjob.updateJob(qplist,jobIdList,jobBMap);
        boolean sel;
        SplitJobController.packDetails obj = new    SplitJobController.packDetails (JEList);
        system.debug('--quoteProduct' +quoteProduct);
        obj.packElement = quoteProduct;
        obj.b_IsElementSelected = true;
        obj.getB_IsElementSelected();
        obj.setB_IsElementSelected(sel);
        //obj.setB_IsElementSelected = false;
        //obj.getB_IsElementSelected();
        obj.getpackElement();
        Splitjob.getPckDetList();       
        Splitjob.actnCloneJOb();
        Splitjob.getPckDetList();
        Splitjob.getErrorMsg();
        //Splitjob.setJeJobId('Some Job');
        Splitjob.getJeJobId();
      }
      
      static testmethod void Splitjobcontroller_material2(){
        
        PrepareData();
        
        quoteProduct.Part_Number__c='ABC123';
        quoteProduct.Quantity__c = 2;
        insert quoteProduct;
        
        qplist = new list<Quote_Product__c>();
        qplist.add(quoteProduct);
        
        JE.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE.Type__c='Material';
        JE.Product_ID__c='ABC123';
        insert JE;
        JE1.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE1.Type__c='Material';
        JE1.Product_ID__c='ABC123';
        insert JE1;
        
        productMaterials=new Product_Materials__c();
        productMaterials.Active__c=true;
        productMaterials.End_Date__c=system.today()+2;
        productMaterials.Start_Date__c=system.today()-1;
        productMaterials.Product_Code__c=JE.Product_ID__c; 
        productMaterials.Quantity__c=2;
        productMaterials.Material_Code__c='B';
        insert productMaterials;
        
        productMaterials1=new Product_Materials__c();
        productMaterials1.Active__c=true;
        productMaterials1.End_Date__c=system.today()+2;
        productMaterials1.Start_Date__c=system.today()-1;
        productMaterials1.Product_Code__c=JE1.Product_ID__c; 
        productMaterials1.Quantity__c=2;
        productMaterials1.Material_Code__c='B';
        insert productMaterials1;
        
        productMaterialsList=new List<Product_Materials__c>();
        productMaterialsList.add(productMaterials);
        productMaterialsList.add(productMaterials1);
        
        system.debug('--productMaterialsList' +productMaterialsList);               
        PageReference pageRef2 = Page.SplitJob;
        Test.setCurrentPage(pageRef2); 
        ApexPages.currentPage().getParameters().put('oppId',opportunity.Id);      
        ApexPages.currentPage().getParameters().put('orgJobId',job.Id);      
       // SplitJobController.packDetails obj = new SplitJobController.packDetails();
        //Splitjob.pckDetList();
        //Splitjob.getPckDetList();
        boolean sel1;
        Job_Element__c[] JEList = new Job_Element__c[]{JE,JE1};
        SplitJobController.packDetails obj1 = new  SplitJobController.packDetails (JEList);
        obj1.getpackElement();
        obj1.getB_IsElementSelected();
        obj1.setB_IsElementSelected(sel1);
        SplitJobController Splitjob = new SplitJobController();
        Splitjob.sets_jobId(job.Id);  
        Splitjob.setJeJobId(job.id);   
        Splitjob.gets_jobId();
        Splitjob.getObjOpp(); 
        Splitjob.getJeJobId();      
        Splitjob.setErrorMsg('no error');
        Splitjob.getJobDetails();
        
        lstQPquery = [Select Name,id,q.Sales_Price__c, q.Quantity__c, q.Product_Description__c,
            q.BigMachines_Quote__c,  
            q.Part_Number__c,q.ASP__r.Name, q.ASP__c From Quote_Product__c q 
            where BigMachines_Quote__c=:Quote.Id and Part_Number__c = :JE   .Product_ID__c];
            
        System.debug('--------------- lstQP = ' + lstQPquery);
        Splitjob.actnFetchElements();
        //Splitjob.pckDetList[0].b_IsElementSelected = true;
        Splitjob.SplitJOB();        
        Splitjob.actnCancel();
        //Splitjob.updateJob(qplist,jobIdList,jobBMap);
        boolean sel;
        SplitJobController.packDetails obj = new    SplitJobController.packDetails (JEList);
        system.debug('--quoteProduct' +quoteProduct);
        obj.packElement = quoteProduct;
        obj.b_IsElementSelected = true;
        obj.getB_IsElementSelected();
        obj.setB_IsElementSelected(sel);
        //obj.setB_IsElementSelected = false;
        //obj.getB_IsElementSelected();
        obj.getpackElement();
        Splitjob.getPckDetList();       
        Splitjob.actnCloneJOb();
        Splitjob.getPckDetList();
        Splitjob.getErrorMsg();
        //Splitjob.setJeJobId('Some Job');
        Splitjob.getJeJobId();
      }
      
      
      static testMethod void SplitJobControl_work2()
      {
        PrepareData();
        
        quoteProduct.Part_Number__c='ABC123';
        quoteProduct.Quantity__c = 1;
        insert quoteProduct;
        
        qplist = new list<Quote_Product__c>();
        qplist.add(quoteProduct);
        
        JE.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE.Type__c='Work';
        JE.Product_ID__c='ABC123';
        JE.Skill__c = 'Electrical';
        JE.Units__c = 1;
        insert JE;
        JE1.Line_Item_ID__c= quoteProduct.ID;//'100';
        JE1.Type__c='Material';
        JE1.Product_ID__c='ABC123';
        JE1.Skill__c = 'Mechanical';
        JE1.Units__c = 2;
        insert JE1;
               
        PWC = new Product_Work_code__c();
        PWC.Active__c=true;
        PWC.End_Date__c=system.today()+2;
        PWC.Skill__c='Electrical';
        //PWC.Product_Code__c=quoteProduct.Part_Number__c;
        PWC.Start_Date__c=system.today()-1;
        PWC.Hours__c=10;
        PWC.Work_Code_Description__c ='Test description';
        PWC.Work_Code__c='100';
        PWC.Product_Code__c=JE.Product_ID__c;
        insert PWC;
        workcodeList = new List<Product_Work_code__c>();
        workcodeList.add(PWC);

        productMaterials=new Product_Materials__c();
        productMaterials.Active__c=true;
        productMaterials.End_Date__c=system.today()+2;
        productMaterials.Start_Date__c=system.today()-1;
        productMaterials.Product_Code__c=JE.Product_ID__c; 
        productMaterials.Quantity__c=1;
        productMaterials.Material_Code__c='B';
        insert productMaterials;
        
        //String selected = 'Selected';
        
        PageReference pageRef2 = Page.SplitJob;
        Test.setCurrentPage(pageRef2); 
        ApexPages.currentPage().getParameters().put('oppId',opportunity.Id);      
        ApexPages.currentPage().getParameters().put('orgJobId',job.Id);      
       // SplitJobController.packDetails obj = new SplitJobController.packDetails();
        //Splitjob.pckDetList();
        //Splitjob.getPckDetList();
        boolean sel1;
        Job_Element__c[] JEList = new Job_Element__c[]{JE,JE1}; 
        SplitJobController.packDetails obj1 = new  SplitJobController.packDetails (JEList);
        obj1.getpackElement();
        obj1.getB_IsElementSelected();
        obj1.setB_IsElementSelected(sel1);
        SplitJobController Splitjob = new SplitJobController();
        Splitjob.sets_jobId(job.Id);  
        Splitjob.setJeJobId(job.id);   
        Splitjob.gets_jobId();
        Splitjob.getObjOpp(); 
        Splitjob.getJeJobId();      
        Splitjob.setErrorMsg('no error');
        Splitjob.getJobDetails();
        
        lstQPquery = [Select Name,id,q.Sales_Price__c, q.Quantity__c, q.Product_Description__c,
            q.BigMachines_Quote__c,  
            q.Part_Number__c,q.ASP__r.Name, q.ASP__c From Quote_Product__c q 
            where BigMachines_Quote__c=:Quote.Id and Part_Number__c = :JE.Product_ID__c];
            
        System.debug('--------------- lstQP = ' + lstQPquery);
        Splitjob.actnFetchElements();
        //Splitjob.pckDetList[0].b_IsElementSelected = true;
        Splitjob.SplitJOB();  
        
        if(Splitjob.pckDetList.size()>0){
          Splitjob.pckDetList[0].b_IsElementSelected = true;
        }
        Splitjob.sets_jobId(job1.id);  
        Splitjob.SplitJOB();  
        Splitjob.calculateSelectedHours(); //Added by Ashok G    
        Splitjob.actnCancel();
        //Added By Ashok G
        if(Splitjob.pckDetList.size()>0){
          Splitjob.pckDetList[0].b_IsElementSelected = false;
        }
        Splitjob.calculateSelectedHours();
        //Splitjob.updateJob(qplist,jobIdList,jobBMap);
        boolean sel;
        SplitJobController.packDetails obj = new    SplitJobController.packDetails (JEList);
        system.debug('--quoteProduct' +quoteProduct);
        obj.packElement = quoteProduct;
        obj.b_IsElementSelected = true;
        obj.getB_IsElementSelected();
        obj.setB_IsElementSelected(sel);
        //obj.setB_IsElementSelected = false;
        //obj.getB_IsElementSelected();
        obj.getpackElement();
        Splitjob.getPckDetList();       
        Splitjob.actnCloneJOb();
        Splitjob.getPckDetList();
        Splitjob.getErrorMsg();
        //Splitjob.setJeJobId('Some Job');
        Splitjob.getJeJobId();
      }
     
}