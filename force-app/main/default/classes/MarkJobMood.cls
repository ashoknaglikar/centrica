global with sharing class MarkJobMood {
    // AUTHOR: Ernest Frimpong SFDC
    // Quickwin: Mood setting for job responses of the day
    // Date: December 2013
    public MarkJobMood(ApexPages.StandardSetController controller) { }

    @RemoteAction
    // Find and Mark Job's geolocation and Mark mood
    global static List<Job__c> getMarkJobMood(Double lat, Double lon) {
      
        // SOQL query to get the today's mood marked jobs
        String queryString = 
            'SELECT Latitude__Latitude__s , Longitude__Longitude__s, Mood_Value__c, Name, Address__c, CHI_Lead_Name__c ' +
            'FROM Job__c WHERE Mood_Set_Date__c = TODAY LIMIT 3000';

        // Run and return the query results
        return(database.Query(queryString));
    }
}