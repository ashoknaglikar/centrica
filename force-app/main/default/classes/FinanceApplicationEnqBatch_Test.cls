@isTest
Private class FinanceApplicationEnqBatch_Test{

 static Account acc;
  static contact con;
  static opportunity opp;
  
  static void createData(){
    acc = TestclassHelper.createAccout();
    insert acc;
    
    con = TestclassHelper.createContact(acc);
    insert con;
    
    opp = TestclassHelper.createCHILead(acc);
    opp.ExternalRef__c = '11111111-1';
    insert opp;
   }
   
   @isTest
   public static void testmethod1(){
       
    createData();
    Finance_Product__c fp = createFProduct();
    
    opportunity opp1=[SELECT Id, Install_Postcode__c,ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Accountid, Account.Primary_Contact__c,Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : opp.Id];
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp1.id;
    fa.Application_Status__c = 'Referred';
    fa.Lead_Ext_Ref_No__c = opp1.ExternalRef__c;
    insert fa;
    Test.startTest();
        Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
        FinanceApplicationEnqBatch.createEnqBatch();
        FinanceApplicationEnqBatch objAutoPrd = new FinanceApplicationEnqBatch();
        database.executeBatch(objAutoPrd,integer.valueof(system.label.FinanceApplicationBatchSize));
    Test.stopTest();
   
    
   }
   
    @isTest
   public static void testmethod2(){
       
    createData();
    Finance_Product__c fp= new Finance_Product__c(Name=system.label.X2ndLender,Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp;
   
    opportunity opp1=[SELECT Id, Install_Postcode__c,ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Accountid, Account.Primary_Contact__c,Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : opp.Id];
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp1.id;
    fa.Application_Status__c = 'Accepted';
    fa.Lead_Ext_Ref_No__c = opp1.ExternalRef__c;
    insert fa;
    Test.startTest();
         Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
         FinanceApplicationEnqBatch.createEnqBatch();
    Test.stopTest();
   
    
   }
   
   @isTest
   public static void testmethod3(){
       
    createData();
    Finance_Product__c fp= new Finance_Product__c(Name=system.label.X2ndLender,Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp;
   
    opportunity opp1=[SELECT Id, Install_Postcode__c,ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                 Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Accountid, Account.Primary_Contact__c,Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                 CHI_Lead_Id__c FROM Opportunity where Id = : opp.Id];
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp1.id;
    fa.Application_Status__c = 'Accepted';
    fa.Lead_Ext_Ref_No__c = opp1.ExternalRef__c;
    insert fa;
    Test.startTest();
          SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"DecisionUpdateResponse": {"proposalNo": "123456","status": "REFER","notes": "Please send proof of address","appStatus": "Referred","appSubStatus": "Quotation"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse); 
         FinanceApplicationEnqBatch.createEnqBatch();
    Test.stopTest();
   
    
   }
   
    public static finance_Product__c createFproduct(){
    Finance_Product__c fp= new Finance_Product__c(Name='Barclays Finance Ex',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp;
    
    Finance_Product__c fp1 = [SELECT Name,Id,Interest_Rate__c, Payment_Options__c, Selling_Type__c,Asset_Type__c,Asset_Type_Description__c,Product_Code__c,Promotional_period__c FROM Finance_Product__c where id=:fp.id LIMIT 1];
    return fp1;                                           
  }
  
  
  public static Finance_Application__c createFApplication(){
        Date myDate = Date.newInstance(1990, 2, 17);

        Finance_Application__c fa = new Finance_Application__c ();
        //fa.CHI_LEAD__C = ;
        fa.FIRST_NAME__C='XXXX'; fa.LAST_NAME__C='YYYY'; fa.ALIAS__C='NO'; fa.MOBILE__C='07444444444'; fa.DATE_OF_BIRTH__C=myDate;
        fa.NATIONALITY__C='UNITED KINGDOM';  fa.NUMBER_OF_DEPENDENTS__C=2;   fa.STREET1__C='Apartment 1 2 Lloyd Road';
        fa.CITY1__C='Manchester';  fa.POST_CODE1__C='M19 2QB'; fa.STATE1__C='Greater Manchester';  fa.COUNTRY1__C='UNITED KINGDOM';
        fa.DATE_FROM1__C=Date.today().addyears(-10); fa.EMPLOYER_NAME__C='XXXXX'; fa.JOB_DESCRIPTION__C='Manager'; fa.POST_CODE_E__C='M19 2QB';
        fa.STREET_E__C='Apartment 1 2 Lloyd Road' ; fa.CITY_E__C='Manchester'; fa.STATE_E__C='Greater Manchester';
        fa.COUNTRY_E__C='UNITED KINGDOM'; fa.GROSS_ANNUAL_INCOME__C=60000; fa.NUMBER_OF_CREDIT_CARDS__C=1;
        fa.BANK_ACCOUNT_NAME__C='Test XXXXX';fa.BANK_ACCOUNT_NUMBER__C='30000000'; fa.SORT_CODE__C='145787';
        fa.TIME_AT_BANK__C='10'; fa.CASH_PRICE__C=1200; fa.DEPOSIT__C=200; fa.EMAIL__C='aaaa@aaaa.com';
        fa.CONFIRM_EMAIL__C='aaaa@aaaa.com'; fa.TYPE_OF_FINANCE__C='e-Finance'; fa.SECURITY_ANSWER__C='12333'; fa.security_Question__c = 'Mothers maiden name';
        fa.TITLE__C='Mr'; fa.EMPLOYMENT_CATEGORY__C='Skilled'; fa.GENDER__C='Male';    
        fa.MARITAL_STATUS__C='Married'; fa.OCCUPANCY_STATUS1__C='Owner Occupier'; fa.REPAYMENT_METHOD__C='Direct Debit';  
        fa.BUILDING_NUMBER1__C='1'; fa.INPUT_SPURCE__C='WEB (*option to be used with BPF Webservice)';  
        fa.EMPLOYER_PHONE__C='07444444444';  fa.YEAR1__C=10; fa.PAYMENT_OPTIONS__C='36 - 3 Years';
        fa.MONTH1__C=0;fa.YEARE__C=10; fa.MONTHE__C=0; fa.EMPLOYMENT_STATUS__C='Employed';
        fa.YEARB__C=10; fa.MONTHB__C=0; fa.Application_Id__c='1023451'; fa.JOB_TOTAL__C = 1400;

        
        return fa;
     
  }
   
}