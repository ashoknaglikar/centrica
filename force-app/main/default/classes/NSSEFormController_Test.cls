@isTest
private class NSSEFormController_Test {

    static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
    static NSSEForm__c nsserecord;
    

    static testMethod void Createtestdata() {
        // Insert mandatory fields in the Account (Non Scotland)  
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
                        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;  // Insert mandatory fields in the Contact        
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
         emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        
        system.debug('----testEmp----'+account);
        system.debug('----testEmp----'+contact);
        system.debug('----testEmp----'+emp);
        system.debug('----testEmp----'+opportunity);
            
        //Create URL to passs through to page with employee reference and opportunity reference            
        PageReference pageRef = new PageReference('/apex/NSSEForm?empid='+Emp.id+'&leadid='+opportunity.id); 
        Test.setCurrentPage(pageRef);
        
        NSSEFormController controller1 = new NSSEFormController();
        controller1.question7= 'test';
        controller1.saveNSSEForm();
        controller1.getQuestion2Items();
        
       /* NSSEForm__c NSSEObject = new NSSEForm__c();
        NSSEObject.Opportunity__c = opportunity.id;
        NSSEObject.Employee__c = emp.Id;
        NSSEObject.NSSEQ1__c = 1;
        NSSEObject.NSSEQ7__c = 'text';
        insert NSSEObject;*/
        
        account.BillingPostalCode = 'PH16 5JG';
        update account;
        
        //Create URL to passs through to page with employee reference and opportunity reference            
        PageReference pageRef2 = new PageReference('/apex/NSSEForm?empid='+Emp.id+'&leadid='+opportunity.id); 
        Test.setCurrentPage(pageRef2);
        NSSEFormController controller2 = new NSSEFormController();
        controller1.saveNSSEForm(); 
        ///Test passing no data through            
        PageReference pageRef3 = new PageReference('/apex/NSSEForm'); 
        Test.setCurrentPage(pageRef3);
        NSSEFormController controller3 = new NSSEFormController();
       
        
    }
}