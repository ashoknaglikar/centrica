/* Appointment History Before Insert and Before Update Trigger
    
    This trigger does a number of things before an Appointment History is
    inserted or updated. Notably it does the following (in this order):
        - populates the extract flag which enables record to be extracted via interface
        - switch off the extract flag once record is modified by Salesforce to Premier batch;
        
*/

trigger UpdateExtractFlag on Appointment_History__c (before insert,before update) {

  
  System.debug('Entered AppointmentHistory BeforeInsert and BeforeUpdate trigger');


  for(Appointment_History__c newAppHist : Trigger.new) {
        
        
        // CR - Create App History For Survey + Unavailable Appts Created As Part Of Phase IV
			
			if(newAppHist.History_Type__c == 'Survey unv appointment created'){
			  continue;
			}
			
        
        // Check the criteria for an Appointment History record for SA extraction        
        
        if(
             newAppHist.Sent_To_Premier__c == false  &&
        
               ( newAppHist.Type__c == 'Sales' || newAppHist.Type__c == 'Survey'  || 
               
                    newAppHist.Type__c == 'Joint' || newAppHist.Type__c == 'Technical' ) &&
            
                      newAppHist.Do_Not_Send_To_Premier__c == false &&
                      
                        newAppHist.Pool_Appointment__c == 'FALSE' &&
                      
                          newAppHist.Not_Created_By_Dataloader__c == true
                          
           ) {
          
              newAppHist.SA_Extract_Flag__c = true;
         
             }
             
      // Update the SA extract flag when record is sent to Premier
             
     
            else {
            
              newAppHist.SA_Extract_Flag__c = false;
            
            }
            
      // Logic for updating ST Extract Flag. It is kept seperated from SA Extract logic just to avoid any confusion.
     
      // Check the criteria for an Appointment History record for ST extraction        
        
        if(
             newAppHist.Sent_To_Premier__c == false  &&
        
               ( newAppHist.Type__c == 'Sales' || newAppHist.Type__c == 'Technical' ) &&
            
                      newAppHist.Do_Not_Send_To_Premier__c == false &&
                      
                        newAppHist.Pool_Appointment__c == 'FALSE' &&
                      
                          newAppHist.Not_Created_By_Dataloader__c == true
                          
           ) {
          
              newAppHist.ST_Extract_Flag__c = true;
         
             }
             
      // Update the ST extract flag when record is sent to Premier
             
     
            else {
            
              newAppHist.ST_Extract_Flag__c = false;
            
            }
           
     }
     
     System.debug('Exiting AppointmentHistory BeforeInsert and BeforeUpdate trigger');


}