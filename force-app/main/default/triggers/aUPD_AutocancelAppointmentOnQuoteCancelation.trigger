trigger aUPD_AutocancelAppointmentOnQuoteCancelation on BigMachines_Quote__c (after insert,after update) {
    
   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
      if(cls_IsRun.dontFireTriggers || cls_IsRun.bigMachineSwitch || cls_IsRun.istrg_aUPD_AutocancelAppointmentOnQuoteCancelation){
          return;
      }
      
    BigMachines_Quote__c bmQuote = Trigger.new[0];
    
    if(cls_IsRun.isBMQuoteUpdateInsertAppRun){
        
        return;
        
    }
    
    cls_IsRun.setIsBMQuoteUpdateInsertAppRun();
    
    if(bmQuote.bmStatusReason__c == null){
        
        return;
        
    }

    if( ! bmQuote.bmStatusReason__c.equalsIgnoreCase('House Closed') ){
           
            return;
       }
       
    if(Trigger.new.size()>1){
        
        for(BigMachines_Quote__c bmq : trigger.new){
            
                bmq.addError('Big machines to Salesforce interface is not bulkified. Concequently only 1 record can be upserted at any one time.');
                
            }
       }
    
    // Added code fix to avoid exception when appointment is already cancelled in Salesforce and 
    // then big machines is again trying to send the house closed quote again back to salesforce.
    
    try{
    
       Appointment__c App = [Select Id, Visit_Date__c, Opportunity__c, Assigned_To__c,Primary_Cancellation_Reason__c,Secondary_Cancellation_Reason__c From Appointment__c 
                          where Opportunity__c = :bmQuote.Opportunity__c and Big_Machines_Quote_Number__c = :bmQuote.Name and Status__c != 'Cancelled' and Type__c = 'Sales' limit 1]; 
    
       if(App != null )
        
          { 
        
              App.status__c = 'House Closed';
              Database.update(App,true);
            
          }
         
    }catch(Exception excp){
        
        System.debug('An exception occured : '+excp.getMessage());
        
    }
    
}