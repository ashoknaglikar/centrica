/*
    CHI Conversion Project CR
    Used for creating cancellation job for to record the cancellation and 
    cancellation reason code for a Sale without a job in SFDC. 
    E.g. Sold in guided and no survey visit took place.
*/

global class CreateCancellationJob {
  
  public static Savepoint  sp;
  
  /*
       This method is invoked from java script on click of Create Cancellation Job button.
       This method is used for creating cancellation job for to record the cancellation and 
       cancellation reason code for a Sale without a job in SFDC. 
  */
    
    webservice static String createCancellationJobForOpp(ID[] oppID){
      
        Opportunity opp = [Select ID,AccountID from Opportunity where ID in :oppID limit 1];
        String textOppID = opp.ID;
        Job__c job;
        // Create a savepoint because the data should not be committed to the database in case of failure
        
        sp = Database.setSavepoint();

        try{              

                job = new Job__c();
                job.CHI_Lead__c = opp.ID;
                job.isCancellation_Job__c = true;
                job.Account__c = opp.AccountID;
                job.Status__c = 'Suspended';
                job.Sub_Status__c = 'Awaiting Cancellation';
                Database.insert(job);
              
           }catch(Exception excp){
                
              // Revert the database to the original state
              Database.rollback(sp);
              return textOppID;
                
           } 
           
           String textJobID = job.ID;
           return textJobID;
                 
     }
     
 }