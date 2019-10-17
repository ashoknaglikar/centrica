@isTest(seealldata=true)
private class FinanceApplicationDetail_Test{
  
  static Account acc;
  static contact con;
  static opportunity opp;
  static List<Finance_Product__c> fpList;
  
  static void createData(){
    acc = TestclassHelper.createAccout();
    insert acc;
    
    con = TestclassHelper.createContact(acc);
    insert con;
    
    opp = TestclassHelper.createCHILead(acc);
    insert opp;
   }
 
  public static finance_Product__c createFproduct(){
    Finance_Product__c fp= new Finance_Product__c(Name='Barclays Finance Ex',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp;
    
    Finance_Product__c fp1 = [SELECT Name,Id,Interest_Rate__c, Payment_Options__c, Selling_Type__c,Asset_Type__c,Asset_Type_Description__c,Product_Code__c,Promotional_period__c,lender__c,new_product__c,ApplicationPer__c,Finance_Options__c FROM Finance_Product__c where id=:fp.id LIMIT 1];
    return fp1;                                           
  }
  
  public static finance_Product__c createFreedomFinanceProduct(){
    Finance_Product__c fp= new Finance_Product__c(Name=system.label.X2ndLender,Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='HoneyComb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp;
    
    Finance_Product__c fp1 = [SELECT Name,Id,Interest_Rate__c, Payment_Options__c, Selling_Type__c,Asset_Type__c,Asset_Type_Description__c,Product_Code__c,Promotional_period__c,lender__c,new_product__c,ApplicationPer__c,Finance_Options__c FROM Finance_Product__c where id=:fp.id LIMIT 1];
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
        fa.CONFIRM_EMAIL__C='aaaa@aaaa.com'; fa.TYPE_OF_FINANCE__C='e-Finance'; fa.SECURITY_ANSWER__C='12333';
        fa.TITLE__C='Mr'; fa.EMPLOYMENT_CATEGORY__C='Skilled'; fa.GENDER__C='Male';    
        fa.MARITAL_STATUS__C='Married'; fa.OCCUPANCY_STATUS1__C='Owner Occupier'; fa.REPAYMENT_METHOD__C='Direct Debit';  
        fa.BUILDING_NUMBER1__C='1'; fa.INPUT_SPURCE__C='WEB (*option to be used with BPF Webservice)';  
        fa.EMPLOYER_PHONE__C='07444444444';  fa.YEAR1__C=10; fa.PAYMENT_OPTIONS__C='36 - 3 Years';
        fa.MONTH1__C=0;fa.YEARE__C=10; fa.MONTHE__C=0; fa.EMPLOYMENT_STATUS__C='Employed';
        fa.YEARB__C=10; fa.MONTHB__C=0; fa.Application_ID__c = '0000000';fa.JOB_TOTAL__C = 1400; fa.STREET2__C='Apartment 1 2 Lloyd Road';
        fa.CITY2__C='Manchester';  fa.POST_CODE2__C='M19 2QB'; fa.STATE2__C='Greater Manchester';  fa.COUNTRY2__C='UNITED KINGDOM';
        fa.STREET3__C='Apartment 1 2 Lloyd Road';
        fa.CITY3__C='Manchester';  fa.POST_CODE3__C='M19 2QB'; fa.STATE3__C='Greater Manchester';  fa.COUNTRY3__C='UNITED KINGDOM';
        fa.Partner_Income__c = 200; fa.Applicant_Other_Income__c = 100; fa.Building_Number1__c = '1';   fa.Building_Number2__c = '2';   fa.Building_Number3__c = '3';
        
        return fa;
     
  }
  
  
  @isTest
  Private static void testmethod1(){
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='0% IFC 2 years HoneyComb',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='0% IFC 2 years Barclays',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
    
    //Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp2.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '36 - 3 Years';
    fa.Lender_Text__c= 'Barclays';
    fa.Do_Not_Derive_Product__c=true;
    fa.Application_Status__c = 'Declined';
    fa.X2nd_Lended_Soft_Search__c = 'Accepted';
    fa.Type_of_Finance__c ='HSA';
    insert fa;
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
    Test.setCurrentPage(pageRef);
    FinanceApplicationDetail obj = new FinanceApplicationDetail();
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.LoadApplication();
    obj.ApplicationEnquiry();
    obj.edit();
    obj.cancel();
    obj.exit();
    obj.doFFSoftSearch();
    Test.stopTest(); 
  } 
  
   @isTest
  Private static void testmethod5(){
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='0% IFC 2 years HoneyComb',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='0% IFC 2 years Barclays',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
    
    //Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp2.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '36 - 3 Years';
    fa.Lender_Text__c= 'Barclays';
    fa.Do_Not_Derive_Product__c=true;
    fa.Sent_to_2nd_Lender__c = system.now();
    insert fa;
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
    Test.setCurrentPage(pageRef);
    FinanceApplicationDetail obj = new FinanceApplicationDetail();
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.LoadApplication();
    obj.ApplicationEnquiry();
    obj.doFFSoftSearch();
    Test.stopTest(); 
  } 
  
  
  @isTest
  Private static void testmethod2(){
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='0% IFC 2 years HoneyComb',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='0% IFC 2 years Barclays',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
    
    //Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp2.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '36 - 3 Years';
    fa.Lender_Text__c= 'Barclays';
    insert fa;
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
    Test.setCurrentPage(pageRef);
    FinanceApplicationDetail obj = new FinanceApplicationDetail();
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.LoadApplication();
    obj.ApplicationEnquiry();
    obj.doFFSoftSearch();
    obj.applyForFFApplication();
    Test.stopTest(); 
  } 
  
   @isTest
    Private static void testmethod3(){
    createData();
    opp.ExternalRef__c='12365-1';
    update opp;
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
    
    //Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp2.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '36 - 3 Years';
    fa.Lender_Text__c= 'Barclays';
    fa.X2nd_Lended_Soft_Search__c ='Declined';
    fa.Do_Not_Derive_Product__c=true;
    insert fa;
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
    Test.setCurrentPage(pageRef);
    /*FinanceApplicationDetail obj = new FinanceApplicationDetail();
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.LoadApplication();
    obj.ApplicationEnquiry();
    obj.doFFSoftSearch();
    obj.applyForFFApplication();
    Test.stopTest(); */
    
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"submissions":{"actualApr":14.9,"dateCreated":"2016-09-02T09:13:36Z","id":1258,"lenderCode":"hcb","lenderName":"Honeycomb Finance","lenderReference":"572","notes":"Bank statements are required - dated within the last month 30 days worth unless customer is self employed then 90 days worth","submissionStatus":"REFER"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);                                           
      obj.LoadApplication();
      obj.doFFSoftSearch();
      Test.Stoptest();
  } 
  
  @isTest
  Private static void testmethod4(){
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='0% IFC 2 years HoneyComb',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='0% IFC 2 years Barclays',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
    
   
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp2.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '36 - 3 Years';
    fa.Lender_Text__c= 'Barclays';
    fa.Do_Not_Derive_Product__c=false;
    fa.Application_Status__c = 'Awaiting Decision';
    insert fa;
    
    Test.startTest();
    PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
    Test.setCurrentPage(pageRef);
    FinanceApplicationDetail obj = new FinanceApplicationDetail();
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.ApplicationEnquiry();
    Test.stopTest();
  } 
  
  public static testmethod void FreedomFinanceSoftSearchRefer()
  {
     createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.Partner_Income__c = null;
        fa.Lead_Ext_Ref_No__c = '123456';
        fa.Do_Not_Derive_Product__c=true;
        insert fa;
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"submissions":{"actualApr":14.9,"dateCreated":"2016-09-02T09:13:36Z","id":1258,"lenderCode":"hcb","lenderName":"Honeycomb Finance","lenderReference":"572","notes":"Bank statements are required - dated within the last month 30 days worth unless customer is self employed then 90 days worth","submissionStatus":"REFER"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);                                           
      obj.LoadApplication();
      Test.Stoptest();
      
      SingleRequestMock fakeResponse2 = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"DecisionUpdateResponse":{"proposalNo":"46222866-20-2","appSubstatus":"Quotation","appStatus":"Referred","status":"REFER"}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse2); 
      obj.ApplicationEnquiry();
      
      //obj.ApplicationEnquiryBtn();
      
      
  }
  
  public static testmethod void FreedomFinanceSoftSearchDeclined()
  {
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.Partner_Income__c = null;
        fa.Lead_Ext_Ref_No__c = '123456';
        fa.Do_Not_Derive_Product__c=true;
        insert fa;
      
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"submissions":{"actualApr":14.9,"dateCreated":"2016-09-02T09:13:36Z","id":1258,"lenderCode":"hcb","lenderName":"Honeycomb Finance","lenderReference":"572","notes":"Bank statements are required - dated within the last month 30 days worth unless customer is self employed then 90 days worth","submissionStatus":"Declined"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);                                           
      obj.LoadApplication();
      Test.Stoptest();
  }
  
  public static testmethod void FreedomFinanceSoftSearchAccepted()
  {
       
    createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.Partner_Income__c = null;
        fa.Lead_Ext_Ref_No__c = '123456';
        fa.Do_Not_Derive_Product__c=true;
        insert fa;
        
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"submissions":{"actualApr":14.9,"dateCreated":"2016-09-02T09:13:36Z","id":1258,"lenderCode":"hcb","lenderName":"Honeycomb Finance","lenderReference":"572","notes":"Bank statements are required - dated within the last month 30 days worth unless customer is self employed then 90 days worth","submissionStatus":"ACCEPT"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);                                           
      obj.LoadApplication();
      Test.Stoptest();
  }
  
  public static testmethod void FreedomFinanceSoftSearchError()
  { createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.Partner_Income__c = null;
        fa.Lead_Ext_Ref_No__c = '123456';
        fa.Do_Not_Derive_Product__c=true;
        insert fa;
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"Error": {"errorCode": "002","message": "Invalid Request"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);                                           
      obj.LoadApplication();
      Test.Stoptest();
  }
  
  Public static testmethod void FreedomFinanceApplyForAcceptedNegtive()
  {
       createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.Partner_Income__c = null;
        fa.Lead_Ext_Ref_No__c = '123456';
         fa.Do_Not_Derive_Product__c=true;
        insert fa;
      
      
     
     
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      obj.applyForFFApplication();
      
      
      Test.Stoptest();
  }
  
  Public static testmethod void FreedomFinanceApplyForAcceptedError()
  {
     createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.X2nd_Lended_Soft_Search__c = 'Accepted';
      fa.Lender_Code__c = 'hcb';
      fa.X2nd_Lender_Name__c = 'Honeycomb';
       fa.Do_Not_Derive_Product__c=true;
      insert fa;
      
      
      
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"Error": {"errorCode": "002","message": "Invalid Request"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse); 
      obj.applyForFFApplication();
      
      
      Test.Stoptest();
  }
  
  Public static testmethod void FreedomFinanceApplyForAcceptedSucess()
  {
       createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.X2nd_Lended_Soft_Search__c = 'Accepted';
      fa.Lender_Code__c = 'hcb';
      fa.X2nd_Lender_Name__c = 'Honeycomb';
       fa.Do_Not_Derive_Product__c=true;
      insert fa;
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"ApplyResponse": {"URL1": "http://www.freedomfinance.co.uk/loanDocs1"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse); 
      obj.applyForFFApplication();
      
      
      Test.Stoptest();
  }
  
  public static testmethod void FreedomFinanceAppliEnquiryError()
  {
      createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.X2nd_Lended_Soft_Search__c = 'Accepted';
      fa.Lender_Code__c = 'hcb';
      fa.X2nd_Lender_Name__c = 'Honeycomb';
       fa.Do_Not_Derive_Product__c=true;
      insert fa;
     
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"Error": {"errorCode": "002","message": "Invalid Request"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse); 
      obj.ApplicationEnquiry();
      
      
      Test.Stoptest();
  }
  
  public static testmethod void FreedomFinanceAppliEnquirySuccess()
  {
       createData();
    
    Finance_Product__c fp1= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',lender__c='Honeycomb',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
    insert fp1;
    
    Finance_Product__c fp2= new Finance_Product__c(Name='Freedom Finance',Interest_Rate__c=15.9,Selling_Type__c='Off Trade',lender__c='Barclays',new_product__c=true,ApplicationPer__c=100,Finance_Options__c='36 - 3 Years',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',X2nd_Lender_Payment_Option__c='36 - 3 Years',X2nd_Lender_Product__c=fp1.id);
    insert fp2;
      
      //Finance_Product__c fp = createFreedomFinanceProduct();
      
       Finance_Application__c fa=createFApplication();
        fa.Finance_Product__c = fp2.id;
        fa.CHI_Lead__c = opp.id;
        fa.Finance_Options__c = '36 - 3 Years';
        fa.Lender_Text__c= 'Barclays';
        fa.X2nd_Lended_Soft_Search__c = 'Accepted';
        fa.Lender_Code__c = 'hcb';
        fa.X2nd_Lender_Name__c = 'Honeycomb';
       fa.Do_Not_Derive_Product__c=true;
      insert fa;
      
      Test.startTest();
      PageReference pageRef = new PageReference('/apex/FinanceDetailPage?FId='+fa.id+'&fpId='+fp2.id+'&oppId='+opp.id);
      Test.setCurrentPage(pageRef);
      FinanceApplicationDetail obj = new FinanceApplicationDetail();
      SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"DecisionUpdateResponse": {"proposalNo": "123456","status": "REFER","notes": "Please send proof of address","appStatus": "Referred","appSubStatus": "Quotation"}}',
                                                 null);
      Test.setMock(HttpCalloutMock.class, fakeResponse); 
      obj.ApplicationEnquiry();
      
      
      Test.Stoptest();
  }
  

}