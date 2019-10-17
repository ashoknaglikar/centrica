@isTest
private class TestAvailable_SapNumbers  {
static List<SAP_Number__c> listOfSapnumObj;
static void createTestData() 
    {
SAP_Number__c sapnumObj= new SAP_Number__c();
        sapnumObj.Active__c=true;
        sapnumObj.in_Use__c=false;
        sapnumObj.SAP_Number__c='0987654';
        
        insert sapnumObj;
        listOfSapnumObj= new List<SAP_Number__c>();
        listOfSapnumObj.add(sapnumObj);
    }
    static testmethod void test_avail_SAP()
    {
         
            Available_SapNumbers avail_sap=new Available_SapNumbers();
            Database.BatchableContext BC;
            createTestData();
            Test.startTest();
            database.executeBatch(avail_sap);
                        
            avail_sap.finish(BC);
            Test.stopTest();
    }
                
}