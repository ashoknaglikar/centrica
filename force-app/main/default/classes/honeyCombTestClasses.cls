@isTest
public class honeyCombTestClasses {
    

	
public static testmethod void testmethod1(){
	
	    Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        insert testOpp;
        List<opportunity>oppList= [select id,Opp_Id_Encrypted__c from opportunity where Id =:testOpp.id ];
        
        Finance_Product__c testProd= new Finance_Product__c();
        testProd.Name='3 Years';
        testProd.Code__c='BPF1024IFC000';
        insert testProd;
        /*Finance_Product__c testProd1= new Finance_Product__c();
        testProd1.Name='2 Years';
        testProd1.Code__c='BPF1024IFC001';
        insert testProd1;*/
        
        Employee__c testEmp= new Employee__c();
        testEmp.Barclays_Outlet__c='test';
        testEmp.Employee_Number__c='test123';
        insert testEmp;
        
        Finance_Application__c testApp=new Finance_Application__c();
        testApp.CHI_Lead__c=testOpp.id;
        testApp.Finance_Product__c=testProd.id;
        testApp.First_Name__c='Test';
        testApp.Last_Name__c='Test 1';
        testApp.Lead_Ext_Ref_No__c=testopp.ExternalRef__c;
        testApp.HSA__c=testEmp.id;
        testApp.Application_ID__c='12345';
        testApp.Payment_Options__c = '24 - 2 Years';
        testApp.Marital_Status__c ='widowed';
        testApp.Occupancy_Status1__c ='homeowner';
        testApp.Employment_Status__c='employed';
        testApp.Building_Number1__c='2';
        testApp.Building_Name1__c='2';
        testApp.Street1__c='test';
        testApp.City1__c='test';
        testApp.State1__c='test';
        testApp.Post_Code1__c='test';
        testApp.Date_From1__c =system.today()-45;
        testApp.Add_Logging__c= true;
        Insert testApp;
        
        String Query = utilities.makeQueryWithAllFields('Finance_Application__c', 'Where id =\''+testApp.id+'\'');
        String query1 = Query.substring(0, Query.indexOf('from')) + ',Finance_Product__r.Asset_Type_Description__c,Finance_Product__r.Product_Code__c '+ Query.substring(Query.indexOf('from'), Query.length());
        
        testApp = database.query(query1);
      
        List<Finance_Data_Mappings__c> fmapList = new List<Finance_Data_Mappings__c>();
        Finance_Data_Mappings__c fmap1 = new Finance_Data_Mappings__c(name='map1', Field__c='MaritalStatus',HoneyComb_2019__c='widowed',PicklistOption__c='widowed');
        Finance_Data_Mappings__c fmap2= new Finance_Data_Mappings__c(name='map2',Field__c='ResidentialStatus',HoneyComb_2019__c='homeowner',PicklistOption__c='homeowner');
        Finance_Data_Mappings__c fmap3 = new Finance_Data_Mappings__c(name='map3',Field__c='EmploymentStatus',HoneyComb_2019__c='employed',PicklistOption__c='employed');
        
        fmapList.add(fmap1);
        fmapList.add(fmap2);
        fmapList.add(fmap3);
        insert fmapList;
		
		
		Test.startTest();
		
		barclaysPhase3Helper.statusMap=new map<string, string>{ 'ACCEPTED' => 'Accepted','REFERRED' => 'Referred', 
                                                                            'DECLINEALL' => 'Declined',
                                                                            'DECLINED' => 'Declined',
                                                                            'Accepted' => 'Accepted'};
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
		honeyCombFinanceHelper.submitApplication(testApp,testProd);
		honeyCombFinanceHelper.getSigningLinkHoneyComb(testApp);
		honeyCombFinanceHelper.cancelApplicationHoneyComb(testApp);
		honeyCombFinanceHelper.notifyFulfilmentHoneyComb(testApp);
		Test.stopTest();
		
	}
	
	public static testmethod void testmethod2(){
	
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
        testApp.Payment_Options__c = '24 - 2 Years';
        testApp.Marital_Status__c ='widowed';
        testApp.Occupancy_Status1__c ='homeowner';
        testApp.Employment_Status__c='employed';
        testApp.Add_Logging__c= true;
        Insert testApp;
      
        List<Finance_Data_Mappings__c> fmapList = new List<Finance_Data_Mappings__c>();
        Finance_Data_Mappings__c fmap1 = new Finance_Data_Mappings__c(name='map1', Field__c='MaritalStatus',HoneyComb_2019__c='widowed',PicklistOption__c='widowed');
        Finance_Data_Mappings__c fmap2= new Finance_Data_Mappings__c(name='map2',Field__c='ResidentialStatus',HoneyComb_2019__c='homeowner',PicklistOption__c='homeowner');
        Finance_Data_Mappings__c fmap3 = new Finance_Data_Mappings__c(name='map3',Field__c='EmploymentStatus',HoneyComb_2019__c='employed',PicklistOption__c='employed');
        
        fmapList.add(fmap1);
        fmapList.add(fmap2);
        fmapList.add(fmap3);
        insert fmapList;
		
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqError());
		barclaysPhase3Helper.statusMap=new map<string, string>{ 'ACCEPTED' => 'Accepted','REFERRED' => 'Referred', 
                                                                            'DECLINEALL' => 'Declined',
                                                                            'DECLINED' => 'Declined',
                                                                            'Accepted' => 'Accepted'};
        
        try{
		honeyCombFinanceHelper.submitApplication(testApp,testProd);
		honeyCombFinanceHelper.getSigningLinkHoneyComb(testApp);
		honeyCombFinanceHelper.cancelApplicationHoneyComb(testApp);
		honeyCombFinanceHelper.notifyFulfilmentHoneyComb(testApp);
        }catch(Exception e){}
		Test.stopTest();
		
	}
	
	public static testmethod void testmethod3(){
	
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
        testApp.Payment_Options__c = '24 - 2 Years';
        testApp.Marital_Status__c ='widowed';
        testApp.Occupancy_Status1__c ='homeowner';
        testApp.Employment_Status__c='employed';
        testApp.Add_Logging__c= true;
        Insert testApp;
        
        List<Finance_Data_Mappings__c> fmapList = new List<Finance_Data_Mappings__c>();
        Finance_Data_Mappings__c fmap1 = new Finance_Data_Mappings__c(name='map1', Field__c='MaritalStatus',HoneyComb_2019__c='widowed',PicklistOption__c='widowed');
        Finance_Data_Mappings__c fmap2= new Finance_Data_Mappings__c(name='map2',Field__c='ResidentialStatus',HoneyComb_2019__c='homeowner',PicklistOption__c='homeowner');
        Finance_Data_Mappings__c fmap3 = new Finance_Data_Mappings__c(name='map3',Field__c='EmploymentStatus',HoneyComb_2019__c='employed',PicklistOption__c='employed');
        
        fmapList.add(fmap1);
        fmapList.add(fmap2);
        fmapList.add(fmap3);
        insert fmapList;
        
		Test.startTest();
		barclaysPhase3Helper.statusMap=new map<string, string>{ 'ACCEPTED' => 'Accepted','REFERRED' => 'Referred', 
                                                                            'DECLINEALL' => 'Declined',
                                                                            'DECLINED' => 'Declined',
                                                                            'Accepted' => 'Accepted'};
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqError());
		try{
		honeyCombFinanceHelper.getApplicationStatusHC(testApp);
	    }catch(Exception e){}
		Test.stopTest();
		
	}
	
        public static testmethod void testmethod4(){
	
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
        testApp.Payment_Options__c = '24 - 2 Years';
        testApp.Marital_Status__c ='widowed';
        testApp.Occupancy_Status1__c ='homeowner';
        testApp.Employment_Status__c='employed';
        testApp.Add_Logging__c= true;
        Insert testApp;
        
        List<Finance_Data_Mappings__c> fmapList = new List<Finance_Data_Mappings__c>();
        Finance_Data_Mappings__c fmap1 = new Finance_Data_Mappings__c(name='map1', Field__c='MaritalStatus',HoneyComb_2019__c='widowed',PicklistOption__c='widowed');
        Finance_Data_Mappings__c fmap2= new Finance_Data_Mappings__c(name='map2',Field__c='ResidentialStatus',HoneyComb_2019__c='homeowner',PicklistOption__c='homeowner');
        Finance_Data_Mappings__c fmap3 = new Finance_Data_Mappings__c(name='map3',Field__c='EmploymentStatus',HoneyComb_2019__c='employed',PicklistOption__c='employed');
        
        fmapList.add(fmap1);
        fmapList.add(fmap2);
        fmapList.add(fmap3);
        insert fmapList;
        
		Test.startTest();
		barclaysPhase3Helper.statusMap=new map<string, string>{ 'ACCEPTED' => 'Accepted','REFERRED' => 'Referred', 
                                                                            'DECLINEALL' => 'Declined',
                                                                            'DECLINED' => 'Declined',
                                                                            'Accepted' => 'Accepted'};
		Test.setMock(HttpCalloutMock.class, new honeyCombHTTPReqHelper());
		try{
		honeyCombFinanceHelper.getApplicationStatusHC(testApp);
		}catch(Exception e){}
		Test.stopTest();
		
	}
	
	

}