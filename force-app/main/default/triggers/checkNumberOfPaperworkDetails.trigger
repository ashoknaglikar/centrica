/*
This trigger is used for checking number of sales paperwork details on a BM quote object. 
As per the request from SITEL we are restricting users from creating new paperwork record
if one already exists. This was requested by Catherine Kelsall.
*/

trigger checkNumberOfPaperworkDetails on Paperwork_Recieved_Details__c (before insert) {

   for(Paperwork_Recieved_Details__c newSalesPaperwork : Trigger.new) {
    
           BigMachines_Quote__c bmQuote = [select Number_of_paperworks_recieved__c,Stage__c from BigMachines_Quote__c 
                                                                                 where id=:newSalesPaperwork.Big_Machines_Quote__c limit 1];
                                                                                 
           Paperwork_Recieved_Details__c[] saPaperWorks = [Select Sales_Paperwork_Returned_Date__c,
                                                                          Sales_Paperwork_Return_Reason__c 
                                                                            from Paperwork_Recieved_Details__c
                                                                              where Big_Machines_Quote__c = :newSalesPaperwork.Big_Machines_Quote__c
                                                                                                          order by CreatedDate];
                                                                                                             
           Paperwork_Recieved_Details__c lastSAPaperWork;
           
           if(saPaperWorks.size()>0){
           	
             lastSAPaperWork	= saPaperWorks[saPaperWorks.size()-1];
           	
           } 
                                                                   
           if(Trigger.isInsert && bmQuote.Number_of_paperworks_recieved__c >= 1 && 
               (lastSAPaperWork.Sales_Paperwork_Returned_Date__c == null && lastSAPaperWork.Sales_Paperwork_Return_Reason__c == null)){
            
              newSalesPaperwork.addError('There is an existing sales paperwork details record related with this quote.'+
                                               ' There is no sales paprework return date or reason mentioned on last sales paperwork details of'+ 
                                                   ' this Quote.'+' You can go back to Big Machines Quote record & modify'+
                                                   ' the last sales paperwork details on it with respect to return date & reason.');   
                                                                            
           } else if(bmQuote.stage__c != 'Quote Finalised - Accepted'){
            
               newSalesPaperwork.addError('This quote is not Finalised - Accepted. We can not add sales paperwork details on this quote.');   
            
           }                                                             
                                      
    }

}