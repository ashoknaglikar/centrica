@isTest
private class TestSearchResultCleaner {

    static testMethod void searchResultCleanerTest() {
        SearchResultCleaner src = new SearchResultCleaner();
        
        List<Search_Result__c> srs = new List<Search_Result__c>(); 
        for(Integer i = 0; i < 200 ; i++) {
	        Search_Result__c sr = new Search_Result__c(Name = 'Test Search Result ' + i.format());
        	srs.add(sr);
        }
        
        Database.insert(srs);
        
        Set<ID> srIDs = new Set<ID>();
        for(Search_Result__c sr : srs) {
        	srIDs.add(sr.ID);
        }
        
        Search_Result__c[] fromDB = [Select ID from Search_Result__c where ID IN :srIDs];
        
        System.assertEquals(fromDB.size(), 200);
        
        src = new SearchResultCleaner('Select ID from Search_Result__c where Name like \'Test Search Result%\' limit 200');
        
        Test.StartTest();
        Database.executeBatch(src);
        Test.StopTest();
        
        fromDB = [Select ID from Search_Result__c where Name like 'Test Search Result%'];
        System.assertEquals(fromDB.size(), 0);
    }
}