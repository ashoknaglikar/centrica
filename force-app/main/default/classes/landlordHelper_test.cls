@ isTest

private class landlordHelper_test{
    static list<Opportunity> chiLead = new list<Opportunity>();
    static Account acc;
    static Contact con;
    static id[] oppIds = new id[10];    
    
    static void createData(){
         acc = TestClassHelper.createAccout();
         insert acc;
         con = TestClassHelper.createContact(acc);
         insert con;
         chiLead.add(TestClassHelper.createCHILead(acc));
         insert chiLead;
         System.debug('====debug===='+chiLead.size());         
         for(Integer i=0;i<chiLead.size();i++)
              oppIds[i] =  chiLead[i].id;      
    }  
    
    static testmethod void method1(){
         createData();
         landlordHelper.createLandlordRecords(chiLead);        
         landlordHelper.createForLLR(oppIds);
         
         con.Contact_Type__c = 'Tenant';
         update con;
         landlordHelper.createLandlordRecords(chiLead);        
         landlordHelper.createForLLR(oppIds);
          
         con.Contact_Type__c = 'Agent';
         update con;
         landlordHelper.createLandlordRecords(chiLead);        
         landlordHelper.createForLLR(oppIds);
    }    
}