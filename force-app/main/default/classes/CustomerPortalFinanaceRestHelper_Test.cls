@IsTest
public class CustomerPortalFinanaceRestHelper_Test {
    Public static TestMethod void financeApplicationCreation_Test(){
        Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1024IFC000';
        insert testProd;
        
        Employee__c testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Finance_Product__c=testProd.id;
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        Insert testApp;
        
        
      
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceApplication/'; 
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        
        
       // String jsondata= '["workPhone":"020369865","typeOfFinance":"e-finance","title":"Mr","timeAtBank":"2.5","sortCode":"0123","securityQuestion":"pet\'s Name","securityAnswer":"oscar","numberOfDependents":0,"nationality":"United KingDom","mobile":"7028050153","middleName":"Kumar","maritalStatus":"single","lastName":"Bhatt","jobDescription":"IT","homePhone":"020215350","grossAnnualSalary":60000,"gender":"Male","firstName":"Dheeraj","financeAmount":500,"employmentStatus":"Employed","employerAddress":{"timeatEmployerYear":5,"timeatEmployerMonth":10,"timeatAddressYear":null,"timeatAddressMonth":null,"street":"51 Caistor Street","state":"Greater Manchester","postcode":"SK1 2LG","occupancyStatus":null,"employerPhone":"123456789","employerName":"Cognizant","dateFrom":null,"country":"UK","city":"Stockport","buildingHouseNumber":null,"buildingHouseName":"DLF"},"email":"DheerajKumar.bhatt@cognizant.com","depositAmount":5000,"dateOfBirth":"1992-12-15","customerAddress":[{"timeatEmployerYear":null,"timeatEmployerMonth":null,"timeatAddressYear":1,"timeatAddressMonth":0,"street":"51 Caistor Street","state":"Greater Manchester","postcode":"SK1 2LG","occupancyStatus":"Rent","employerPhone":null,"employerName":null,"dateFrom":"2014-01-01","country":"UK","city":"Stockport","buildingHouseNumber":"51","buildingHouseName":"Test"}],"bankAccountNumber":"1234"]';
        string encryptedJson= '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';
        Test.startTest();
        CustomerPortalFinanceRestHelper.financeApplicationCreation(oppList[0].Opp_Id_Encrypted__c,  encryptedJson);
        Test.stopTest();
        
    }
    
    
    Public static TestMethod void ApplicationStatusSuccessResponse_Test(){
        Account acc=TestClassHelper.createAccout();
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        testopp.ExternalRef__c=CustomerPortalHelper.getExternalReference(testOpp.Id);
        insert testOpp;
        
        Finance_Product__c testProd1= new Finance_Product__c();
        testProd1.Name='3 Years';
        testProd1.Code__c='BPF1060IBC149';
        insert testProd1;
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1060IBC149';
        testProd.X2nd_Lender_Product__c =testProd1.id;
        insert testProd;
        
         Employee__c testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Finance_Product__c=testProd.id;
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        Insert testApp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceApplication/'+testApp.id; 
        req.httpMethod = 'get';
        
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
         try{
        Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
        CustomerPortalFinanceRestHelper.ApplicationStatus();
         }catch(Exception e){}
        Test.stopTest();
    }
    
    Public static TestMethod void ApplicationStatusErrorResponse_Test(){
        Account acc=TestClassHelper.createAccout();
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        testopp.ExternalRef__c=CustomerPortalHelper.getExternalReference(testOpp.Id);
        insert testOpp;
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1060IBC149';
        insert testProd;
        
         Employee__c testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Finance_Product__c=testProd.id;
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        Insert testApp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceApplication/'+testApp.id; 
        req.httpMethod = 'get';
        
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
         try{
        Test.setMock(WebServiceMock.class, new CustomerPortalFinanaceRestHelper_Mock());
        CustomerPortalFinanceRestHelper.ApplicationStatus();
        }catch(Exception e){}
        Test.stopTest();
    }
    
     Public static TestMethod void ApplicationStatusCatchException(){
        Account acc=TestClassHelper.createAccout();
        opportunity testOpp= TestClassHelper.createCHILead(Acc);
        testopp.ExternalRef__c=CustomerPortalHelper.getExternalReference(testOpp.Id);
        insert testOpp;
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1060IBC149';
        insert testProd;
        
         Employee__c testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Finance_Product__c=testProd.id;
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        Insert testApp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerPortalFinanceApplication/'+testApp.id; 
        req.httpMethod = 'get';
        
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
         try{
        CustomerPortalFinanceRestHelper.ApplicationStatus();
         }catch(Exception e){}
        Test.stopTest();
    }
    
    
   @testSetup
    private static void setUpdata(){
        IV_Vectors__c keyRec1= new IV_Vectors__c();
        keyRec1.Name='Customer Portal Finance Key';
        keyRec1.Key__c='ynNM07vDqlW5G7wHIuAL75NqgE9Cf799Lm+oNd0dyFI=';
        insert keyRec1;
        
        IV_Vectors__c keyRec2= new IV_Vectors__c();
        keyRec2.Name='Customer Portal Finance Vector';
        keyRec2.Key__c='qATWgq6+MBDUCoEzt5y1yA==';
        insert keyRec2;
        
        IV_Vectors__c keyRec3= new IV_Vectors__c();
        keyRec3.Name='Customer Portal';
        keyRec3.Key__c='380db410e8b11fa9';
        insert keyRec3;
        
        IV_Vectors__c keyRec4= new IV_Vectors__c();
        keyRec4.Name='Finance_Accepted_Statuses';
        keyRec4.Key__c=',Accepted,Awaiting eSignature,';
        insert keyRec4;
        
        IV_Vectors__c keyRec5= new IV_Vectors__c();
        keyRec5.Name='Finance_Reffered_Statuses';
        keyRec5.Key__c=',Referred,';
        insert keyRec5;
        
        IV_Vectors__c keyRec6= new IV_Vectors__c();
        keyRec6.Name='Finance_Declined_Statuses';
        keyRec6.Key__c=',Declined,';
        insert keyRec6;
        
        IV_Vectors__c keyRec7= new IV_Vectors__c();
        keyRec7.Name='Finance_Parked_Status';
        keyRec7.Key__c=',Parked,';
        insert keyRec7;
        
        list<IV_Vectors__c > vectorList = new list<IV_Vectors__c>();
        
        vectorList.add(new IV_Vectors__c(Name = 'Quote_Expiry_Days', Key__c = '90') );
        vectorList.add(new IV_Vectors__c(Name = 'Portal Key Length', Key__c = '8') );
        

        insert vectorList;
        
    }

    
    
}