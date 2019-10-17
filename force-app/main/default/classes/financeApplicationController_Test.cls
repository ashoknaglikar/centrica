@isTest
Private class financeApplicationController_Test{
  static Account acc;
  static contact con;
  static opportunity opp;
  
  static void createData(){
    acc = TestclassHelper.createAccout();
    insert acc;
    
    con = TestclassHelper.createContact(acc);
    insert con;
    
    opp = TestclassHelper.createCHILead(acc);
    insert opp;
   }
   
  static testmethod void testmethod1(){  
    createData();
    Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp.id;
    insert fa;
    
    Finance_Data_Mappings__c fd = new Finance_Data_Mappings__c (Name='Map 1',Code__c='1',field__c='Country',PicklistOption__c='UNITED KINGDOM');
    Finance_Data_Mappings__c fd1 = new Finance_Data_Mappings__c (Name='Map 2',Code__c='1',field__c='MaritalStatus',PicklistOption__c='Married');
    Finance_Data_Mappings__c fd2 = new Finance_Data_Mappings__c (Name='Map 3',Code__c='1',field__c='EmploymentStatus',PicklistOption__c='Employed');
    Finance_Data_Mappings__c fd3 = new Finance_Data_Mappings__c (Name='Map 4',Code__c='4',field__c='EmploymentCategory',PicklistOption__c='Skilled');
    Finance_Data_Mappings__c fd4 = new Finance_Data_Mappings__c (Name='Map 5',Code__c='1',field__c='ResidentialStatus',PicklistOption__c='Owner Occupier');

    list<Finance_Data_Mappings__c> FDM = new list<Finance_Data_Mappings__c>{fd,fd1,fd2,fd3,fd4};
    insert FDM;    
    Test.startTest();
    Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(fa);
    PageReference pageRef = new PageReference('/apex/newBarclaysFinance?retURL=%2F'+opp.id+'&FromDetail=T');
    Test.setCurrentPage(pageRef);
    financeApplicationController obj = new  financeApplicationController(stdCtr);
    obj.financeProductSel();
    obj.calculateFinance();
    obj.secondarySelection();
    obj.fp.Payment_Options__c = '36 - 3 Years';
    obj.startApplication();
    obj.checkAddress();
    obj.fa.DATE_FROM1__C=null;
    obj.year1='';
    obj.Month1='';
    obj.checkAddress();
    obj.Year1 = '10';
    obj.Month1 = '0';
    obj.address2=true;
    Obj.Year2='';
    obj.Month2='';
    obj.CheckAddress();
    obj.Year1 = '10';
    obj.Month1 = '0';
    Obj.Year2='10';
    obj.Month2='0'; 
    obj.address3=true;   
    Obj.Year3='';
    obj.Month3='';
    obj.CheckAddress();  
    obj.saveApp();
    //obj.getQuote();
    Test.stopTest();
  }
  
  static testmethod void testmethod2(){  
    createData();
    Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=new Finance_Application__c();
    
    Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(fa);
    PageReference pageRef = new PageReference('/apex/newBarclaysFinance?retURL=%2F'+opp.id);
    Test.setCurrentPage(pageRef);
    financeApplicationController obj = new  financeApplicationController(stdCtr);
    
    
    
  }
  
  static testmethod void testmethod3(){  
    createData();
    
    BigMachines_Quote__c bmQuote= new BigMachines_Quote__c();
    insert bmQuote;
    
     IV_Vectors__c keyRec= new IV_Vectors__c();
     keyRec.Name='0% - 2 Years';
     keyRec.Key__c='0';
     keyRec.Key2__c ='2';
     insert keyRec;
        
    Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '0% - 2 Years';
    //fa.Portal_Quote__c=bmQuote.id;
    insert fa;
    
    Finance_Data_Mappings__c fd = new Finance_Data_Mappings__c (Name='Map 1',Code__c='1',field__c='Country',PicklistOption__c='UNITED KINGDOM');
    Finance_Data_Mappings__c fd1 = new Finance_Data_Mappings__c (Name='Map 2',Code__c='1',field__c='MaritalStatus',PicklistOption__c='Married');
    Finance_Data_Mappings__c fd2 = new Finance_Data_Mappings__c (Name='Map 3',Code__c='1',field__c='EmploymentStatus',PicklistOption__c='Employed');
    Finance_Data_Mappings__c fd3 = new Finance_Data_Mappings__c (Name='Map 4',Code__c='4',field__c='EmploymentCategory',PicklistOption__c='Skilled');
    Finance_Data_Mappings__c fd4 = new Finance_Data_Mappings__c (Name='Map 5',Code__c='1',field__c='ResidentialStatus',PicklistOption__c='Owner Occupier');

    list<Finance_Data_Mappings__c> FDM = new list<Finance_Data_Mappings__c>{fd,fd1,fd2,fd3,fd4};
    insert FDM;    
    
    Test.startTest();
    Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(fa);
    PageReference pageRef = new PageReference('/apex/newBarclaysFinance?retURL=%2F'+opp.id+'&FromDetail=T');
    
    Test.setCurrentPage(pageRef);
    financeApplicationController obj = new  financeApplicationController(stdCtr);
   
    obj.fa=fa;
    obj.selPensionDetails='test';
    obj.selPensionF='test1';
    obj.financeProductSel();
    obj.calculateFinance();
    obj.fp = fp;
    obj.fp.Payment_Options__c = '36 - 3 Years';
    obj.fa.Job_Total__c = 3001.05;
    Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
    obj.getQuote();
    obj.validatePayment();
    obj.removeAddress();
    obj.financeTypeSel();
    obj.hideAlias();
    obj.goToOpp();
    obj.address3=true;
    obj.removeAddress();
    obj.CheckAddress();  
   
    Test.stopTest();
    
      
  }
  
 
  static testmethod void testmethod4(){  
    createData();
    
    BigMachines_Quote__c bmQuote= new BigMachines_Quote__c();
    bmQuote.finalNetQuoteTotal__c=1000;
    bmQuote.depositOnPricing__c=250;
    insert bmQuote;
    
     IV_Vectors__c keyRec= new IV_Vectors__c();
     keyRec.Name='0% - 2 Years';
     keyRec.Key__c='0';
     keyRec.Key2__c ='2';
     insert keyRec;
        
    Finance_Product__c fp = createFProduct();
    
    Finance_Application__c fa=createFApplication();
    fa.Finance_Product__c = fp.id;
    fa.CHI_Lead__c = opp.id;
    fa.Finance_Options__c = '0% - 2 Years';
    fa.Portal_Quote__c=bmQuote.id;
    fa.DATE_FROM2__C=Date.today().addyears(-11);
    fa.DATE_FROM3__C=Date.today().addyears(-15);
    fa.year2__c=1;
    fa.month2__c=0;
    fa.year3__c=4;
    fa.month3__c=0;
    insert fa;
    
    Finance_Data_Mappings__c fd = new Finance_Data_Mappings__c (Name='Map 1',Code__c='1',field__c='Country',PicklistOption__c='UNITED KINGDOM');
    Finance_Data_Mappings__c fd1 = new Finance_Data_Mappings__c (Name='Map 2',Code__c='1',field__c='MaritalStatus',PicklistOption__c='Married');
    Finance_Data_Mappings__c fd2 = new Finance_Data_Mappings__c (Name='Map 3',Code__c='1',field__c='EmploymentStatus',PicklistOption__c='Employed');
    Finance_Data_Mappings__c fd3 = new Finance_Data_Mappings__c (Name='Map 4',Code__c='4',field__c='EmploymentCategory',PicklistOption__c='Skilled');
    Finance_Data_Mappings__c fd4 = new Finance_Data_Mappings__c (Name='Map 5',Code__c='1',field__c='ResidentialStatus',PicklistOption__c='Owner Occupier');

    list<Finance_Data_Mappings__c> FDM = new list<Finance_Data_Mappings__c>{fd,fd1,fd2,fd3,fd4};
    insert FDM;  
    
    Test.startTest();
    Apexpages.standardcontroller stdCtr =new Apexpages.standardcontroller(fa);
    PageReference pageRef = new PageReference('/apex/newBarclaysFinance?retURL=%2F'+opp.id+'&FromDetail=T');
    Test.setCurrentPage(pageRef);
    financeApplicationController obj = new  financeApplicationController(stdCtr);
    obj.address2=false;
    obj.address3=false; 
    obj.Year2 = '1';
    obj.Month2 = '0';
    Obj.Year3='4';
    obj.Month3='0';
    obj.CheckAddress();  
    obj.financeProductSel();
    obj.calculateFinance();
    obj.secondarySelection();
    obj.startApplication();
    obj.saveApp();
    Test.stopTest();
  }
    
      
  
  
  public static Finance_Application__c createFApplication(){
        Date myDate = Date.newInstance(1990, 2, 17);

        Finance_Application__c fa = new Finance_Application__c ();
        //fa.CHI_LEAD__C = ;
        fa.FIRST_NAME__C='XXXX';
        fa.LAST_NAME__C='YYYY';
        fa.ALIAS__C='NO';
        fa.MOBILE__C='07444444444';
        fa.DATE_OF_BIRTH__C=myDate;
        fa.NATIONALITY__C='UNITED KINGDOM';
        fa.NUMBER_OF_DEPENDENTS__C=2;
        fa.STREET1__C='Apartment 1 2 Lloyd Road';
        fa.CITY1__C='Manchester';   
        fa.POST_CODE1__C='M19 2QB'; 
        fa.STATE1__C='Greater Manchester';  
        fa.COUNTRY1__C='UNITED KINGDOM';
        fa.DATE_FROM1__C=Date.today().addyears(-10);
        fa.EMPLOYER_NAME__C='XXXXX';
        fa.JOB_DESCRIPTION__C='Manager';
        fa.POST_CODE_E__C='M19 2QB';
        fa.STREET_E__C='Apartment 1 2 Lloyd Road' ; 
        fa.CITY_E__C='Manchester';
        fa.STATE_E__C='Greater Manchester';
        fa.COUNTRY_E__C='UNITED KINGDOM';   
        fa.GROSS_ANNUAL_INCOME__C=60000;
        fa.NUMBER_OF_CREDIT_CARDS__C=1;
        fa.BANK_ACCOUNT_NAME__C='Test XXXXX';
        fa.BANK_ACCOUNT_NUMBER__C='30000000';
        fa.SORT_CODE__C='145787';
        fa.TIME_AT_BANK__C='10';
        fa.CASH_PRICE__C=1200;
        fa.DEPOSIT__C=200;
        fa.EMAIL__C='aaaa@aaaa.com';
        fa.CONFIRM_EMAIL__C='aaaa@aaaa.com';
        fa.TYPE_OF_FINANCE__C='e-Finance';
        fa.SECURITY_ANSWER__C='12333';
        fa.TITLE__C='Mr'; 
        fa.EMPLOYMENT_CATEGORY__C='Skilled';
        fa.GENDER__C='Male';    
        fa.MARITAL_STATUS__C='Married'; 
        fa.OCCUPANCY_STATUS1__C='Owner Occupier';
        fa.REPAYMENT_METHOD__C='Direct Debit';  
        fa.BUILDING_NUMBER1__C='1';
        fa.INPUT_SPURCE__C='WEB (*option to be used with BPF Webservice)';  
        fa.EMPLOYER_PHONE__C='07444444444';  
        fa.YEAR1__C=10;
        fa.PAYMENT_OPTIONS__C='36 - 3 Years';
        fa.MONTH1__C=0;
        fa.YEARE__C=10;
        fa.MONTHE__C=0;
        fa.EMPLOYMENT_STATUS__C='Employed';
        fa.YEARB__C=10;
        fa.MONTHB__C=0; 
        fa.Applicant_Net_Monthly_income__c=6000;
        fa.Job_Total__c =600;
        
  
        return fa;
     
  }
  
  public static finance_Product__c createFproduct(){
    Finance_Product__c fp= new Finance_Product__c(Name='BarclaysIBCTerm',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',Selectable__c=true);
    insert fp;
                                                  
    Finance_Product__c fp1= new Finance_Product__c(Name='BarclaysIBCTerm',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler',Selectable__c=true,Min_Loan__c=1000,Max_Loan__c=1500,Parent_Product__c=fp.id);
    insert fp1;
    
    Finance_Product__c fp2 = [SELECT Name,Id,Interest_Rate__c, Payment_Options__c, Selling_Type__c,Asset_Type__c,Asset_Type_Description__c,Product_Code__c,Promotional_period__c FROM Finance_Product__c where id=:fp.id LIMIT 1];
    return fp2;                                           
  }
  
}