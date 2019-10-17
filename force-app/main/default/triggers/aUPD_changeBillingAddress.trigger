/*
* CLASS - aUPD_changeBillingAddress
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to 
*           1.  Chnage the related order status to 'Good-Receipted' whenever quote status is changed to 'Awaiting Billing' 
Modified Date: 24/09/2010
Reason: BRS- 34 and BRS-35 has been removed. We are not changing the status of Quote. We are just checking the Billed checkbox from false to true. 
*/
trigger aUPD_changeBillingAddress on BigMachines_Quote__c (after update) {

   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
	  if(cls_IsRun.dontFireTriggers || cls_IsRun.bigMachineSwitch || cls_IsRun.istrg_aUPD_changeBillingAddress){
	      return;
	  }
	  
    Integer iCnt = 0;
    List<String> awaitBillquoteList = new List<String>();
    Set<String> oppIdsASP = new Set<String>();
    List<String> formattedQuoteList = new List<String>();
    Set<String> oppIds = new Set<String>();
    Double chargetocustomer =0.0;
    list<Contact> gdContact = new list<Contact>();
    for(BigMachines_Quote__c bigQuote : Trigger.new){
        BigMachines_Quote__c objOldBigQuote = Trigger.old[iCnt];
        if(objOldBigQuote.Billed__c != true  && bigQuote.Billed__c == true ){
            awaitBillquoteList.add(bigQuote.id);   
            oppIds.add(bigQuote.opportunity__c);
        }  
        if(bigQuote.Billed__c == true && bigQuote.ASP_after_Billed__c ==true){
            oppIdsASP.add(bigQuote.opportunity__c);  
            chargetocustomer = bigQuote.Charge_to_Cutomer_after_Billed__c; 
        } 
        if(bigQuote.Finance_Acceptance_Number__c != objOldBigQuote.Finance_Acceptance_Number__c) 
        gdContact.add(new Contact(Id= bigQuote.Contact_Id__c, bm_fAcceptanceNumber__c = bigQuote.Finance_Acceptance_Number__c ));
    }
    /* Start: ---Change the Opportunity to Billed and populate the Billed Date on Opportunity
    */
    if(oppIds.size() > 0){
        List<Opportunity> oppList = [select id,Billed_Status__c, ASP_after_Billed__c,isSystem__c,Billed_Date__c from Opportunity where id in :oppIds and Billed_Status__c != true];
        if(oppList.size() > 0){
            for(Opportunity opp : oppList){
                opp.Billed_Status__c = true;
                opp.Billed_Date__c = System.today();
                opp.isSystem__c=true;
            }try{
                update oppList;
            }catch(Exception e){
                System.debug('@ exception @'+e);
            }
        }
    }
    /*
    End Here 
    Start:-- Populate a field in Opportunity which will show that ASP has been applied after the Billing
    */
    
    if(oppIdsASP.size() > 0){
        List<Opportunity> oppListASP = [select id,Billed_Status__c, ASP_after_Billed__c from Opportunity where id in :oppIdsASP and Billed_Status__c = true];
        if(oppListASP.size() > 0){
            for(Opportunity opp : oppListASP){
                opp.ASP_after_Billed__c = true;
                opp.Charge_to_Cutomer_after_Billed__c = chargetocustomer;
                
            }try{
                update oppListASP ;
            }catch(Exception e){
                System.debug('@ exception @'+e);
            }
        }
    }
    /*
    End Here
    Start:-- Good receipt the order when the billing is completed
    */
    system.debug('Testing quote-->'+awaitBillquoteList);
    
    // Fix for additional unwanted orders getting goods reciepted
    
    Map<String,String> quoteIdMap = new Map<String,String>();
    
    if(awaitBillquoteList.size() > 0){
        for(String qStr : awaitBillquoteList){
            formattedQuoteList.add(qStr.substring(0,qStr.length() - 3));
             // Fix for additional unwanted orders getting goods reciepted
            quoteIdMap.put(qStr.substring(0,qStr.length() - 3),qStr.substring(0,qStr.length() - 3));
        }
             // Fix for additional unwanted orders getting goods reciepted
        system.debug('Testing quote2-->'+formattedQuoteList);    
        List<Order__c> ordersList = [select id,status__c,Quote_ID_Indexed__c from order__c where Quote_ID_Indexed__c in :formattedQuoteList];
        String quoteIdonJob;
        if(orderSList.size() > 0){
            for(Order__c order : ordersList){
            	 // Fix for additional unwanted orders getting goods reciepted
            	if(!quoteIdMap.containsKey(order.Quote_ID_Indexed__c)){
            	   continue;	
            	}
            	 // Fix for additional unwanted orders getting goods reciepted
                if(order.Status__c == 'Active' || order.Status__c == 'Amended' || order.Status__c == 'Approved')
                order.status__c = 'Goods Receipted';
            }
            try{
                update ordersList;
            }catch(DMLException e){
                System.debug('@ EXCEPTION IN UPDATING ORDER STATUS @  '+e.getMessage());
            }

        }
    }
    /*
    Good Receipt end here
    */
    
    if(gdContact.size()>0)
    {
	    cls_IsRun.dontFireTriggers =true;
	    cls_IsRun.generalTriggerSwitch =true;
	    update gdContact;
    }
}