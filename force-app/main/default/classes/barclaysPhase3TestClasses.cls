@isTest
public class barclaysPhase3TestClasses {

Public static Finance_Application__c testApp;
Public static  List<Finance_Data_Mappings__c> fmapList;
Public static Account acc;
Public static opportunity testOpp;
Public static Finance_Product__c testProd;
Public static Finance_Product__c testProd1;
Public static Employee__c testEmp;


public static void createTestData(){
	
	    acc=TestClassHelper.createAccout();
        insert acc;
        
        testOpp= TestClassHelper.createCHILead(acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        
        testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1024IFC000';
        insert testProd;
        
        testProd1= new Finance_Product__c();
        testProd1.Name='2 Years';
        testProd1.Code__c='BPF1024IFC001';
        testProd1.X2nd_Lender_Product__c = testProd.id;
        insert testProd1;
        
        testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Finance_Product__c=testProd.id;
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        testApp.Payment_Options__c = '24 - 2 Years';
        testApp.Marital_Status__c ='widowed';
        testApp.Occupancy_Status1__c ='homeowner';
        testApp.Employment_Status__c='employed';
        testApp.Building_Number1__c='2';
        testApp.Building_Name1__c='2';
        testApp.Street1__c='street';
        testApp.City1__c='city';
        testApp.State1__c='state';
        testApp.Post_Code1__c='test';
        testApp.Date_From1__c =system.today()-45;
        testApp.Add_Logging__c= true;
        testApp.rent__c=150;
        Insert testApp;
        
        /*String Query = utilities.makeQueryWithAllFields('Finance_Application__c', 'Where id =\''+testApp.id+'\'');
        String query1 = Query.substring(0, Query.indexOf('from')) + ',Finance_Product__r.Product_Code__c '+ Query.substring(Query.indexOf('from'), Query.length());
        
        testApp = database.query(query1);*/
      
        fmapList = new List<Finance_Data_Mappings__c>();
        Finance_Data_Mappings__c fmap1 = new Finance_Data_Mappings__c(name='map1', Field__c='TypeOfProof (Signature)',Barclays_2019__c='CREDIT_CARD',PicklistOption__c='CREDIT_CARD');
        Finance_Data_Mappings__c fmap2= new Finance_Data_Mappings__c(name='map2',Field__c='Title',Barclays_2019__c='MR',PicklistOption__c='MR');
        Finance_Data_Mappings__c fmap3 = new Finance_Data_Mappings__c(name='map3',Field__c='Gender',Barclays_2019__c='Male',PicklistOption__c='Male');
        Finance_Data_Mappings__c fmap4 = new Finance_Data_Mappings__c(name='map4',Field__c='MaritalStatus',Barclays_2019__c='SINGLE',PicklistOption__c='SINGLE');
        Finance_Data_Mappings__c fmap5 = new Finance_Data_Mappings__c(name='map5',Field__c='Country',Barclays_2019__c='UK',PicklistOption__c='UK');
        Finance_Data_Mappings__c fmap6 = new Finance_Data_Mappings__c(name='map6',Field__c='ResidentialStatus',Barclays_2019__c='OTHER',PicklistOption__c='OTHER');
        Finance_Data_Mappings__c fmap7 = new Finance_Data_Mappings__c(name='map7',Field__c='EmploymentStatus',Barclays_2019__c='employed',PicklistOption__c='employed');
        
        fmapList.add(fmap1);
        fmapList.add(fmap2);
        fmapList.add(fmap3);
        fmapList.add(fmap4);
        fmapList.add(fmap5);
        fmapList.add(fmap6);
        fmapList.add(fmap7);
        insert fmapList;
	}
	
public static testmethod void testmethod1(){
        createTestData();
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
		try{
		barclaysPhase3Helper.submitBarclaysApplication(testApp);
		barclaysPhase3Helper.cloneAndResubmitToNextLender(testApp);
		}catch(Exception e){}
		Test.stopTest();
    
}

public static testmethod void testmethod2(){
        createTestData();
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
	    try{
		barclaysPhase3Helper.getBarclaysApplicationStatus(testApp);
	    }catch(Exception e){}
		Test.stopTest();
}

public static testmethod void testmethod3(){
        createTestData();
        testApp.Finance_Product__c=testProd1.id;
        update testApp;
    	Test.startTest();
    	try{
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
		barclaysPhase3Helper.updateFinanceStatus(testApp);
        }catch(Exception e){}
		Test.stopTest();
    
}

public static testmethod void testmethod4(){
        createTestData();
        testApp.Lender_Text__c ='Test';
        update testApp;
    	Test.startTest();
    	
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
		try{
		barclaysPhase3Helper.submitFinanceApplication(testApp);
    	}catch(Exception e){}
		Test.stopTest();
}


public static testmethod void testmethod5(){
        createTestData();
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqError());
		try{
		barclaysPhase3Helper.submitBarclaysApplication(testApp);
		barclaysPhase3Helper.cloneAndResubmitToNextLender(testApp);
        }catch(Exception e){}
		Test.stopTest();
    
}

public static testmethod void testmethod6(){
        createTestData();
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqError());
	    try{
		barclaysPhase3Helper.getBarclaysApplicationStatus(testApp);
	    }catch(Exception e){}
		Test.stopTest();
    
}

public static testmethod void testmethod7(){
        createTestData();
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqError());
		try{
		barclaysPhase3Helper.updateFinanceStatus(testApp);
        }catch(Exception e){}
		Test.stopTest();
}



	
}