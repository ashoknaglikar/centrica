@isTest
private class newConstumerController_Test{
  static testmethod void testcase1(){
    
    Test.startTest();
    categoryMap__c c = new categoryMap__c();
    c.name = 'Rec - 1';
    c.Reason__c = 'Age';
    c.subReason__c = '75 and over';
    insert c;
    
    categoryMap__c c1 = new categoryMap__c();
    c1.name = 'Rec - 2';
    c1.Reason__c = 'Age';
    c1.subReason__c = 'family';
    insert c1;
    
    Map<string,CategoryMap__c> mcs = new Map<string,CategoryMap__c>();
    mcs.put(c.id,c);
    mcs.put(c1.id,c1);
    
    Account acc = TestclassHelper.createAccout();
    insert acc;
    
    contact con = TestclassHelper.createContact(acc);
    contact con1 = TestclassHelper.createContact(acc);
    
    opportunity opp = TestclassHelper.createCHILead(acc);
    List<opportunity> opps = new list<opportunity>{opp};
    insert opps;
    
    contactInfo conI = new contactInfo();
    conI.contact = con;
    
    contactInfo conI1 = new contactInfo();
    conI1.contact = con1;
    list<contactInfo> conInf = new List<contactInfo>{conI,conI1};
    Test.stopTest();
       
    newConstomerController cont = new newConstomerController();
    cont.account = acc;
    cont.Opportunities = opps;
    cont.indicator();
    cont.showSecCon();
    cont.setConInfoList(conInf);
    cont.getConInfoList();
    cont.setMcs(mcs);
    cont.getMcs();
    cont.ContactAddress = 'xxxxxxx';
   
    /*Gas_Council__c gasC=new Gas_Council__c();
    gasC.name='41-311-38';
    gasC.message__c='Test One';
    insert gasC; */
    cont.gasCMsg='Test 1';
    cont.gcNoMatch=true;
    cont.verifyGCNumber();
  }
}