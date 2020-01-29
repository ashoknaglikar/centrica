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
private class AmalgamateNotesController_Test {
    static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
   

    static testMethod void Createtestdata() {
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        // Insert mandatory fields in the Contact        
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
         emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        
        Note CHINote = new Note(ParentId =opportunity.Id, Body = 'Test', title ='test');
        insert CHINote;
        
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                           
        insert quote;
        
        Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='CBLRAS', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='CBLRAS',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4', installationNotes__c= 'test notes');
                                                            
       insert product;
       insert quoteProduct;
       system.debug('quoteProduct----->'+quoteProduct);
        
        Job__c job = new Job__c(Quote__c=quote.Id, Pending_Reason__c='test',Status__c='Test', Type__c = 'Central Heating Installation', CHI_Lead__c=opportunity.Id, Water_Heating_Fixing_Hours__c=1,Unvented_Hot_Water_Hours__c=1,Specialist_Building_Hours__c=1,Scaffolder_Hours__c=1,Roof_Work_Hours__c=1,Payment_Collection_Hours__c=1,Mechanical_Hours__c=1,LPG_Installation_Hours__c=1,Fire_Wall_Heater_Fixing_Hours__c=1,Electrical_Hours__c=1,Contractor_Installation_Hours__c=1,Connect_Solar_Panel_Hours__c=1,Building_Work_Hours__c=1,PowerFlush_Hours__c=1,Electrical_Work_ASP_Hours__c=1,Asbestos_Removal_Hours__c=1,Asbestos_Removal_Fixed_Rate_Hours__c=1,Solar_Hours__c=1,Ecogen_Electrical_Hours__c=1,Ecogen_Mechanical_Hours__c=1);              
        insert job; 
        
        Note JobNote = new Note(ParentId =job.Id, Body = 'Test', title ='test');
        insert JobNote;
        
       RecordType RcdTypId = [Select r.Id From RecordType r where r.Name='Dispute'and sObjectType = 'Case']; 
        
        Case caseObj = new Case();
        caseObj.RecordTypeId=RcdTypId.Id;
        caseObj.AccountId=account.Id;
        caseObj.ContactId=contact.Id;
        caseObj.Opportunity__c = opportunity.Id;
        caseObj.Subject='Test Case';
        caseObj.Description='Test Desc';
        caseObj.Disputed_Amount__c=100;
        caseObj.Communication_status__c='Awaiting Office';
        caseObj.Case_Source__c='Customer';
        caseObj.Priority='High';
        caseObj.Issued_To__c=emp.Id;
        caseObj.Classification__c='Sales';
        caseObj.Status='New';
        insert caseObj;
        
        CaseComment TestCasecoment = new CaseComment(ParentId =caseObj.Id, CommentBody = 'Test');
        insert TestCasecoment;
        
        Payment_Collection__c p = new Payment_Collection__c();
        p.Name = 'Payment';
        p.Was_Job_completed_to_specification__c = 'Yes';
        p.Were_there_any_changes_to_the_Job__c = 'Yes (see notes)';
        p.Have_you_demod_the_system_controls__c = 'Yes';
        p.Payment_Collection_Status__c ='Pending'; 
        p.Has_NPS_been_explained_to_Customer__c = 'Yes';
        p.Have_you_arranged_a_call_back_time__c = 'Yes';
        p.Reason_for_Discrepancy__c='Dispute';
        p.Opportunity__c = opportunity.Id; 
        p.Payment_Notes__c = 'test notes';
        p.Job__c= job.Id;
        Insert p;
        
        Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c(Opportunity__c=opportunity.Id);
        insert gd;
        
        
        Smart_Meter__c smartMeter = new Smart_Meter__c(Name = 'testSM' , Quote__c = quote.Id , CHI_Lead__c = opportunity.Id);
        insert smartMeter;
        
        PageReference pageRef = new PageReference('/apex/Amalgamatenotes?OppId='+opportunity.Id);
        Test.setCurrentPage(pageRef);
        
        AmalgamateNotesController controller = new AmalgamateNotesController();
        controller.generatePDF();
        
        Note PCNNote = new Note(ParentId =p.Id, Body = 'Test', title ='test');
        insert PCNNote;
        
        Test.startTest();
        PageReference pageRef1 = new PageReference('/apex/Amalgamatenotes?OppId='+opportunity.Id);
        Test.setCurrentPage(pageRef1);
        
        AmalgamateNotesController controller1 = new AmalgamateNotesController();
        controller1.generatePDF();
        ActivityHistory activit=new ActivityHistory();
        AmalgamateNotesController.NotesInnerclass notInner=new AmalgamateNotesController.NotesInnerclass(activit);
        WIP_Header__c Qvisit=new  WIP_Header__c();
        AmalgamateNotesController.NotesInnerclass notInner1=new AmalgamateNotesController.NotesInnerclass(Qvisit);
        test.stopTest();
        
       
        // TO DO: implement unit test
    }
}