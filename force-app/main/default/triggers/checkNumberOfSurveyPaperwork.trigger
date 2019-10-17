/*
 As confirmed by CHI Dev team, we do not use survey paperwork details object right now in live.
 Thats why we are removing everything from below trigger which frees up one space for creating roll 
 up summary field on big machines quote object for customer net price calculation change.
 We can delete the number of survey paperwork details roll up summary field which was used in this trigger.
 We also need to remove all the page layout references to this object from live so that no one will be able to use it.
*/

trigger checkNumberOfSurveyPaperwork on Surveyor_Paperwork_Received_Details__c (before insert) {

      return;
 
}