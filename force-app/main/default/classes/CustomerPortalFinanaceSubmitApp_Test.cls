@IsTest(SeeAllData=False)
public class CustomerPortalFinanaceSubmitApp_Test {
    Public static TestMethod void financeApplicationSubmitionSuccess_Test(){
        
        Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        
        
        
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        insert testProd;
        
        Finance_Data_Mappings__c fd = new Finance_Data_Mappings__c (Name='Map 1',Code__c='1',field__c='Country',PicklistOption__c='UNITED KINGDOM');
        Finance_Data_Mappings__c fd1 = new Finance_Data_Mappings__c (Name='Map 2',Code__c='1',field__c='MaritalStatus',PicklistOption__c='Married');
        Finance_Data_Mappings__c fd2 = new Finance_Data_Mappings__c (Name='Map 3',Code__c='1',field__c='EmploymentStatus',PicklistOption__c='Employed');
        Finance_Data_Mappings__c fd3 = new Finance_Data_Mappings__c (Name='Map 4',Code__c='4',field__c='EmploymentCategory',PicklistOption__c='Skilled');
        Finance_Data_Mappings__c fd4 = new Finance_Data_Mappings__c (Name='Map 5',Code__c='1',field__c='ResidentialStatus',PicklistOption__c='Owner Occupier');
        Finance_Data_Mappings__c fd5 = new Finance_Data_Mappings__c (Name='Map 6',Code__c='M',field__c='Gender',PicklistOption__c='Male');
        Finance_Data_Mappings__c fd6 = new Finance_Data_Mappings__c (Name='Map 7',Code__c='3',field__c='SecurityQuestion',PicklistOption__c='Mothers maiden name');
        
        list<Finance_Data_Mappings__c> FDM = new list<Finance_Data_Mappings__c>{fd,fd1,fd2,fd3,fd4,fd5,fd6};
            insert FDM; 
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.payment_Options__c='36 - 3 Years';
        testApp.Deposit__c=500;
        testApp.Cash_Price__c=5000;
        testApp.Finance_Product__c=testProd.id;
        testApp.Email__c='abc@test.com';
        testApp.Lead_Ext_Ref_No__c=CustomerPortalHelper.getExternalReference(testOpp.Id);
        
        Insert testApp;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceSubmitApplication/'; 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
        CustomerPortalFinanceSubmitApplication.loadFinanceApplication( testApp.id,oppList[0].Opp_Id_Encrypted__c);
        Test.stopTest();
    }
    
    Public static TestMethod void financeApplicationSubmitionError_Test(){
        
        Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        insert testProd;
        
        Finance_Data_Mappings__c fd = new Finance_Data_Mappings__c (Name='Map 1',Code__c='1',field__c='Country',PicklistOption__c='UNITED KINGDOM');
        Finance_Data_Mappings__c fd1 = new Finance_Data_Mappings__c (Name='Map 2',Code__c='1',field__c='MaritalStatus',PicklistOption__c='Married');
        Finance_Data_Mappings__c fd2 = new Finance_Data_Mappings__c (Name='Map 3',Code__c='1',field__c='EmploymentStatus',PicklistOption__c='Employed');
        Finance_Data_Mappings__c fd3 = new Finance_Data_Mappings__c (Name='Map 4',Code__c='4',field__c='EmploymentCategory',PicklistOption__c='Skilled');
        Finance_Data_Mappings__c fd4 = new Finance_Data_Mappings__c (Name='Map 5',Code__c='1',field__c='ResidentialStatus',PicklistOption__c='Owner Occupier');
        Finance_Data_Mappings__c fd5 = new Finance_Data_Mappings__c (Name='Map 6',Code__c='M',field__c='Gender',PicklistOption__c='Male');
        Finance_Data_Mappings__c fd6 = new Finance_Data_Mappings__c (Name='Map 7',Code__c='3',field__c='SecurityQuestion',PicklistOption__c='Mothers maiden name');
        
        list<Finance_Data_Mappings__c> FDM = new list<Finance_Data_Mappings__c>{fd,fd1,fd2,fd3,fd4,fd5,fd6};
            insert FDM; 
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.payment_Options__c='36 - 3 Years';
        testApp.Deposit__c=500;
        testApp.Cash_Price__c=5000;
        testApp.Finance_Product__c=testProd.id;
        testapp.Email__c='abc@test.com';
        
        Insert testApp;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceSubmitApplication/'; 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CustomerPortalFinanaceSubmitAppErr_Mock());
        CustomerPortalFinanceSubmitApplication.loadFinanceApplication( testApp.id,oppList[0].Opp_Id_Encrypted__c);
        Test.stopTest();
    }
    Public static TestMethod void financeApplicationSubmitionException_Test(){
        
        Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testapp.Email__c='abc@test.com';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceSubmitApplication/'; 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CustomerPortalFinanceSubmitApplication.loadFinanceApplication( testApp.id,oppList[0].Opp_Id_Encrypted__c);
        Test.stopTest();
    }    
    @testSetup
    Private Static void setupdata(){
        IV_Vectors__c keyRec= new IV_Vectors__c();
        keyRec.Name='Customer Portal';
        keyRec.Key__c='380db410e8b11fa9';
        insert keyRec;   
        
    }
}