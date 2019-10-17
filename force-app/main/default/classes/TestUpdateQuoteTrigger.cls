@isTest
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
private class TestUpdateQuoteTrigger{
  static Account account;  
  static Contact contact;
  static Employee__c emp ;
  static Opportunity opportunity ;
  static testmethod void CreateTestData(){
       
       account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        // Insert mandatory fields in the Contact        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='00011',Resource_Type__c='S');
        insert supplier;
         
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991',Supplier__c=supplier.Id);
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
         emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
                
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2,Billed__c=true);                           
        insert quote;
        
        Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='CBLRAS', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='CBLRAS',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4', installationNotes__c= 'test notes');
                                                            
       insert product;
       insert quoteProduct;
       system.debug('quoteProduct----->'+quoteProduct);
        
        District__c district = TestClassHelper.createDistrict();
        insert district;
        
        Job__c job = new Job__c(Quote__c=quote.Id, District__c=district.Id, Pending_Reason__c='test',Status__c='Test', Type__c = 'Central Heating Installation', CHI_Lead__c=opportunity.Id, Water_Heating_Fixing_Hours__c=1,Unvented_Hot_Water_Hours__c=1,Specialist_Building_Hours__c=1,Scaffolder_Hours__c=1,Roof_Work_Hours__c=1,Payment_Collection_Hours__c=1,Mechanical_Hours__c=1,LPG_Installation_Hours__c=1,Fire_Wall_Heater_Fixing_Hours__c=1,Electrical_Hours__c=1,Contractor_Installation_Hours__c=1,Connect_Solar_Panel_Hours__c=1,Building_Work_Hours__c=1,PowerFlush_Hours__c=1,Electrical_Work_ASP_Hours__c=1,Asbestos_Removal_Hours__c=1,Asbestos_Removal_Fixed_Rate_Hours__c=1,Solar_Hours__c=1,Ecogen_Electrical_Hours__c=1,Ecogen_Mechanical_Hours__c=1);              
        insert job; 
        
        Job__c job1 = new Job__c(Quote__c=quote.Id, District__c=district.Id, Pending_Reason__c='test',Status__c='Test', Type__c = 'Central Heating Installation', CHI_Lead__c=opportunity.Id, Water_Heating_Fixing_Hours__c=1,Unvented_Hot_Water_Hours__c=1,Specialist_Building_Hours__c=1,Scaffolder_Hours__c=1,Roof_Work_Hours__c=1,Payment_Collection_Hours__c=1,Mechanical_Hours__c=1,LPG_Installation_Hours__c=1,Fire_Wall_Heater_Fixing_Hours__c=1,Electrical_Hours__c=1,Contractor_Installation_Hours__c=1,Connect_Solar_Panel_Hours__c=1,Building_Work_Hours__c=1,PowerFlush_Hours__c=1,Electrical_Work_ASP_Hours__c=1,Asbestos_Removal_Hours__c=1,Asbestos_Removal_Fixed_Rate_Hours__c=1,Solar_Hours__c=1,Ecogen_Electrical_Hours__c=1,Ecogen_Mechanical_Hours__c=1);              
        insert job1; 
        
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        insert JE;
        update job;
        
        
        //creating order and inserting
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        ord.Supplier__c = supplier.id;
        ord.P5_Good_Receipting_Status__c='Confirmed Processing';
        ord.P5_SAP_Status__c = 'Confirmed Processing';
        ord.Type__c = 'Work';
        insert ord;
        ord.P5_Good_Receipting_Status__c='Confirmed Processing';
        update ord;
        
        Order__c ord1 = new Order__c();
        ord1.Job__c= job.Id;
        ord1.Supplier__c = supplier.id;
        ord1.P5_Good_Receipting_Status__c='Confirmed Processing';
        ord1.P5_SAP_Status__c = 'Confirmed Processing';
        ord1.Type__c = 'Work';
        insert ord1;
        
        Order__c ord2 = new Order__c();
        ord2.Job__c= job.Id;
        ord2.Supplier__c = supplier.id;
        ord2.P5_Good_Receipting_Status__c='Confirmed Processing';
        ord2.P5_SAP_Status__c = 'Confirmed Processing';
        ord2.Type__c = 'Material';
        insert ord2;
        
        Order_Line_Item__c ActivelineItem = new Order_Line_Item__c();
        ActivelineItem.Order_Line_Item_Number__c=714;
        ActivelineItem.P5_Job_Element__c=JE.Id;
        ActivelineItem.P5_Purchase_Order__c=ord.Id;
        ActivelineItem.P5_Product__c=product.Id;
        
        
        ActivelineItem.Quantity_Returned__c=100;
        ActivelineItem.P5_Status_c__c='Active';
        ActivelineItem.Skill__c='Roof Work';
        
        ActivelineItem.Units__c=5;
        ActivelineItem.P5_Unit_Price_c__c=100;
        ActivelineItem.Quantity_Returned__c=2;
        
        ActivelineItem.P5_Type__c='Work';
        ActivelineItem.Description__c='testdescription';
        ActivelineItem.Code__c='123'; 
        //OrdLine.Name; 
        
       
        
        ActivelineItem.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert ActivelineItem;
        
        Order_Line_Item__c ActivelineItem1 = new Order_Line_Item__c();
        ActivelineItem1.Order_Line_Item_Number__c=714;
        ActivelineItem1.P5_Job_Element__c=JE.Id;
        ActivelineItem1.P5_Purchase_Order__c=ord1.Id;
        ActivelineItem1.P5_Product__c=product.Id;
        
        
        ActivelineItem1.Quantity_Returned__c=100;
        ActivelineItem1.P5_Status_c__c='Active';
        ActivelineItem1.Skill__c='Electrical';
        
        ActivelineItem1.Units__c=5;
        ActivelineItem1.P5_Unit_Price_c__c=100;
        ActivelineItem1.Quantity_Returned__c=2;
        
        ActivelineItem1.P5_Type__c='Work';
        ActivelineItem1.Description__c='testdescription';
        ActivelineItem1.Code__c='123'; 
        //OrdLine.Name; 
        
       
        
        ActivelineItem1.Supplier__c=supplier.Id;
        //Ordline.Quantity_Returned__c=2;
        insert ActivelineItem1;
        
        
        //update job;
        job__c jobQ = [select id,name,Actual_Labour_charges__c,Actual_Material_charges__c,(select id,name from Purchase_orders__r) from Job__c where id=:job.id];
        //system.assertequals(jobQ.Actual_Labour_charges__c,600,'MISMATCH');
        
        //update Quote;
        BigMachines_Quote__c BGQ=[select id,name,Billed__c,Actual_Building_Work_Cost__c,Actual_Electrical_Cost__c,Actual_Labour_Cost__c,All_Other_skills_Actual_Cost__c,Actual_Material_Cost__c,Actual_Powerflush_Cost__c,Actual_Roof_Work_Cost__c,Acual_Mechanical_Cost__c,Average_Labour_Cost_Quote__c,Average_Material_Cost_Quote__c,Opportunity__c from BigMachines_Quote__c where id=:quote.id];
        //system.assertequals(BGQ.Actual_Electrical_Cost__c,300,'Electrical charges are not equal');
        //system.assertequals(BGQ.Actual_Roof_Work_Cost__c,300,'Roof work Charges are not equal');
        
        
  }

}