@isTest
private class readParametersTest{

  static testmethod void testMethod1(){
    Account acc = TestClassHelper.createAccout(); 
    Opportunity opp = TestClassHelper.createCHILead(acc);
    PageReference pageRef = Page.ReadParametersfromURL;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('lead','45941490/M=5.5/PF=1/B=1.02/RHC=1.50/R=1.56');
    Test.StartTest();
    readParameters rp = new readParameters();
    PageRef.getParameters().put('lead',opp.CHI_Lead_Id__c+'/M=5.5/PF=1/B=1.02/RHC=1.50/R=1.56');
    //pageRef.getParameters().put('lead','');
    rp.CreateJob();
    rp.runSearch();
    Test.StopTest();
  }
  
  static testMethod void testMethod2(){
    Account acc = TestClassHelper.createAccout(); 
    insert acc;
    Opportunity opp = TestClassHelper.createCHILead(acc);
    insert opp;
    District__c dist = TestClassHelper.createDistrict();
    insert dist;
    Job__c job = TestClassHelper.createJob('Allocated', 'Awaiting Quote', opp.id, dist.id);
    job.Customer_Preferred_Date__c=system.today();
    insert job;
    Opportunity opp1 = [select id,name,Chi_Lead_Id__c from opportunity where id=:opp.id];
    PageReference pageRef = Page.ReadParametersfromURL;
    Test.setCurrentPage(pageRef);
    Test.StartTest();
    PageRef.getParameters().put('lead',opp1.CHI_Lead_Id__c+'/M=5.5/PF=1/B=1.02/RHC=1.50/R=1.56');
    readParameters rp = new readParameters();
    rp.CreateJob();
    //rp.runSearch();
    Test.StopTest();
  }
  
  static testMethod void testMethod3(){
    Account acc = TestClassHelper.createAccout(); 
    insert acc;
    Opportunity opp = TestClassHelper.createCHILead(acc);
    insert opp;
    District__c dist = TestClassHelper.createDistrict();
    insert dist;
    Job__c job = TestClassHelper.createJob('Pending', 'Install Date required', opp.id, dist.id);
    job.Customer_Preferred_Date__c=system.today();
    insert job;
    Opportunity opp1 = [select id,name,Chi_Lead_Id__c from opportunity where id=:opp.id];
    PageReference pageRef = Page.ReadParametersfromURL;
    Test.setCurrentPage(pageRef);
    Test.StartTest();
    PageRef.getParameters().put('lead',opp1.CHI_Lead_Id__c+'/M=5.5/PF=1/B=1.02/RHC=1.50/R=1.56');
    readParameters rp = new readParameters();
    rp.CreateJob();
    //rp.runSearch();
    Test.StopTest();
  }
}