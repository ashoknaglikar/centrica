/*
  Added as part of customer history card change request.
  This class is	used as	a helper class for different 
  triggers & classes written for customer history 
  card functionality.
*/
public with	sharing	class CustomerHistoryCardHelper	{

 // This method is called from job update trigger to update customer history card 
 // and insert customer event history record.	
 public	void updateCustHistCardOnJobbUpdate(Job__c oldJob, Job__c newJob){
 	   if(System.Label.Customer_Journey_Flag != 'TRUE'){
 	   	   return;
 	   }
	   try{
		   if(((oldJob.Customer_Journey__c != newJob.Customer_Journey__c) ||
				  (oldJob.Mid_call_date__c != newJob.Mid_call_date__c))	&& Trigger.size	== 1){
				   Customer_history_card__c	custHistoryCard	= [Select Id from Customer_history_card__c where Job__r.Id = :newJob.Id	limit 1];
				    if(custHistoryCard != null){
					  if(oldJob.Customer_Journey__c	!= newJob.Customer_Journey__c){
						newJob.Customer_Journey_Status_Change_Date__c =	Date.Today();
						if(newJob.Customer_Journey__c == 'Welcome call made - 28 day call required'){
							custHistoryCard.Mid_call_required__c = 'No';
							newJob.Mid_call_date__c = null;
						}else if(newJob.Customer_Journey__c	== 'Welcome call made - mid call required'){
							custHistoryCard.Mid_call_required__c = 'Yes';
						}
						
						this.populateCustomerJourneyStatusIndex(newJob);	
						
						if(newJob.Customer_journey_status_index__c <= 2){
							custHistoryCard.Mid_call_required__c = '';
							newJob.Mid_call_date__c = null;
						}
					  }
					  Customer_journey_event_history__c	custEventHist =	new	Customer_journey_event_history__c();
					  custEventHist.Customer_journey_status__c = newJob.Customer_Journey__c;
					  custEventHist.Mid_call_date__c = newJob.Mid_call_date__c;
					  custEventHist.Customer_Journey_Status_Change_Date__c = newJob.Customer_Journey_Status_Change_Date__c;
					  custEventHist.Customer_history_card__c = custHistoryCard.Id;
					  Database.update(custHistoryCard);
					  Database.insert(custEventHist);
				   }
			   }
			 if((oldJob.Customer_Journey__c	== newJob.Customer_Journey__c) &&
							 (oldJob.Customer_Journey_Status_Change_Date__c	!= newJob.Customer_Journey_Status_Change_Date__c) && Trigger.size == 1){
					 newJob.Customer_Journey_Status_Change_Date__c = oldJob.Customer_Journey_Status_Change_Date__c;
				}
		   }catch(Exception	excp){
			  System.debug('Exception in customer history card update in JobBeforeInsertUpdate trigger : '+excp.getMessage());
              this.populateCustomerJourneyStatusIndex(newJob);			  
		   } 
		   
	}
	
// End of this method

 public void populateCustomerJourneyStatusIndex(Job__c newJob){
 	
 	 		  if(newJob.Customer_Journey__c	== 'Pending welcome call'){	
			  newJob.Customer_journey_status_index__c =	1;
			  }else	if(newJob.Customer_Journey__c == 'Welcome call not made – unable to contact customer'){
			  newJob.Customer_journey_status_index__c =	2;
			  }else	if(newJob.Customer_Journey__c == 'Welcome call made - 28 day call required'){
			  newJob.Customer_journey_status_index__c =	3; 
			  }else	if(newJob.Customer_Journey__c == 'Welcome call made - mid call required'){
			  newJob.Customer_journey_status_index__c =	4; 
			  }else	if(newJob.Customer_Journey__c == 'Mid Call failed - 28 day call required'){
			  newJob.Customer_journey_status_index__c =	5; 
			  }else	if(newJob.Customer_Journey__c == 'Mid call completed - 28 day call required'){
			  newJob.Customer_journey_status_index__c =	6;
			  }else	if(newJob.Customer_Journey__c == 'Journey completion call failed - unable to contact customer'){
			  newJob.Customer_journey_status_index__c =	7; 
			  }else	if(newJob.Customer_Journey__c == 'Journey completion call not made - customer issues to be resolved'){
			  newJob.Customer_journey_status_index__c =	8; 
			  }else	if(newJob.Customer_Journey__c == 'Journey completion call made – customer issues to be resolved'){
			  newJob.Customer_journey_status_index__c =	9;
			  }else	if(newJob.Customer_Journey__c == 'Journey completed – 28 day handover'){
			  newJob.Customer_journey_status_index__c =	10;
			  }else{
			  newJob.Customer_journey_status_index__c =	0;
			  }
 	
 }

// End of this method

}