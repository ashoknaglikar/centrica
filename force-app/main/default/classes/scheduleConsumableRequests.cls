/*
	Author: Cognizant 01/12/2011
	Description: This is used to schedule the sendConsumableRequests batch class. 
	
	TestClass for this class is present in : sendConsumableRequests_Test
*/
global class scheduleConsumableRequests implements Schedulable{
    
     global void execute(SchedulableContext SC) {
     	sendConsumableRequests sCR = new sendConsumableRequests();
     	sCR.createConReqBatch();
     }

}