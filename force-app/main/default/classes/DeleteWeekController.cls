/*
    * brm - 12-01-2010
    
    * Attempts to delete a week record by first checking the diary entries related 
      to a week to make sure we don't accidentally delete job bookings. 
    
    * If there are no job bookings related to the week, delete week.
*/

public without sharing class DeleteWeekController {
    
    private Week__c weekEntry = null;
    
    private String retURL;
    private Boolean isException = false;
    private String exceptionMessage = '';
    
    public String userMessage {get; set;}
    
    public DeleteWeekController(ApexPages.StandardController controller)
    {
        try
        {
            // brm - 12-01-2010 - Setup retURL to use when redirecting back after successful delete
            retURL = ApexPages.currentPage().getParameters().get('retURL');
            if (retURL == null) retURL = ((Week__c)controller.getRecord()).Employee__c;
            
            // brm - 12-01-2010 - Create week entry to delete
            weekEntry = new Week__c(Id = controller.getId());
            
            // brm - 12-01-2010 - Loop through all related diary entries
            for (Diary_Entry__c entry : [Select Id, RecordType.Name, Sub_Type__c From Diary_Entry__c Where Week__c = :weekEntry.Id])
            {
               
                            // brm - 12-01-2010 - If the current diary entry does not have an availability record type or an availability sub type, throw exception
                   //if (entry.RecordType.Name != 'Availability' || entry.Sub_Type__c != 'Availability') throw new UnAvailException('Please make sure there are no Job Booking or Unavailability Diary Entries in this week.');
                //Included the condition entry.Sub_Type__c != 'Weekend unavailability') for the PR -PRB00014638
                if ((entry.RecordType.Name != 'Availability' || entry.Sub_Type__c != 'Availability') && !(entry.RecordType.Name == 'Unavailability' && entry.Sub_Type__c == 'Weekend unavailability')) throw new UnAvailException('Please make sure there are no Job Booking or Unavailability Diary Entries in this week.');
            }
        }
        catch (Exception e)
        {
            // brm - 12-01-2010 - flag as exception and store exception message
            isException = true;
            exceptionMessage = e.getMessage();
        }
    }
    
    public PageReference deleteWeek()
    {
        // brm - 12-01-2010 - If there was no exception and week entry has been set
        if (!isException && weekEntry != null)
        {
            // brm - 12-01-2010 - delete selected week
            delete weekEntry;
            
            userMessage = 'Week record successfully deleted.';
            return new PageReference(retURL);   
        }
        else
        {
            // brm - 12-01-2010 - output exception message to screen
            userMessage = 'Error deleting week record: ' + exceptionMessage;
        }
        
        return null;
    }
    
    public class UnAvailException extends Exception {}
}