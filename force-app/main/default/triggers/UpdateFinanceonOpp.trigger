trigger UpdateFinanceonOpp on Contact(after insert,after update){
    
        Set<String> set_OppId=new Set<String>{};
        set<string> set_AccId=new set<string>{};
        boolean blnapproved = false;
		//Billing Address changed by HSA
		boolean addressChanged = false;
        List<Opportunity> lst_opportunity=new List<Opportunity>{};
        integer iCount=0;
        
        // CHI Lanlord Changes starts
        List<Account> landLordAccountsToUpdate = new List<Account>();
        Map<Id, string> landLordAccountIds = new  Map<Id, string>();
        for(Contact c : Trigger.new){
        	if(c.Contact_Type__c!=null)
        	if(c.Contact_Type__c=='Landlord' || c.Contact_Type__c=='Agent' || c.Contact_Type__c == 'Multi-Premise'){
        		landLordAccountIds.put(c.AccountId, c.Contact_Type__c);
        	}
         }
        if(landLordAccountIds.size()>0){
        	landLordAccountsToUpdate = [Select ID,Landlord_Account__c from Account where (Landlord_Account__c!=true OR Type__c = '') and ID in :landLordAccountIds.keyset()];
        	if(landLordAccountsToUpdate.size()>0){
        		for(Account tmpAcc : landLordAccountsToUpdate){
        	    	tmpAcc.Landlord_Account__c = true;
        	    	tmpAcc.Type__c = landLordAccountIds.get(tmpAcc.Id);
        	    }
        	    update landLordAccountsToUpdate;
        	}
          }
       // CHI Lanlord Changes Ends
        
       if (System.Trigger.isInsert)
        {
            for(Contact c: Trigger.New)    
            {
             if( c.bm_fFinancialProduct__c == 'Green Deal Finance' || (c.Primary_Contact__c ==True && c.bm_fAmountOfCredit__c!= Null && c.bm_fApplicationStatus__c == 'Approved'))   
             {
                  String tempId=c.AccountId;
                  set_AccId.add(tempId);  
                     
             }
            }
            lst_opportunity=[select Id,isSystem__c,Finance_Amount__c,AccountId,StageName  from Opportunity where AccountId IN:set_AccId and StageName != 'Expired' and StageName != 'Closed Lost'];
           System.debug('#####----insert----####'+lst_opportunity);
           for(Contact c: Trigger.New) {
           for(Opportunity obj_opportunity:lst_opportunity) {
           //Cognizant :- 05/08/2010    Removed because we are putting this condition in Query.
               //if(obj_opportunity.StageName != 'Expired' && obj_opportunity.StageName != 'Closed Lost'){
                    obj_opportunity.Finance_Amount__c = c.bm_fAmountOfCredit__c;
                    obj_opportunity.isSystem__c =true;
               // }
             }    
         }
         update lst_opportunity;
         }
         else if(System.Trigger.isupdate){
        for(Contact c: Trigger.New)    
            {
             if(c.Primary_Contact__c ==True)    
             {
              if( c.bm_fFinancialProduct__c == 'Green Deal Finance' || (c.bm_fApplicationStatus__c == 'Approved' && Trigger.old[iCount].bm_fApplicationStatus__c != 'Approved' && c.bm_fAmountOfCredit__c != null)|| (c.bm_fApplicationStatus__c != 'Approved' && Trigger.old[iCount].bm_fApplicationStatus__c == 'Approved')||(c.bm_fApplicationStatus__c == 'Approved' && Trigger.old[iCount].bm_fApplicationStatus__c == 'Approved' && Trigger.old[iCount].bm_fAmountOfCredit__c != c.bm_fAmountOfCredit__c) )
              {
                  //String tempId=c.AccountId;
                  set_AccId.add(c.AccountId);  
                  if(c.bm_fFinancialProduct__c == 'Green Deal Finance' || c.bm_fApplicationStatus__c == 'Approved' )
                  {
                  	blnapproved = true;
                  }
             }
             contact oldCon = trigger.oldMap.get(c.id);
             if(c.MailingStreet !=oldCon.MailingStreet || c.MailingCity !=oldCon.MailingCity || c.MailingPostalCode !=oldCon.MailingPostalCode || c.Email__c != oldCon.Email__c)
             {
    			 set_AccId.add(c.AccountId); 
    			 addressChanged = true;  
             }
          	}
         	}
         lst_opportunity=[select Id,isSystem__c,Finance_Amount__c,AccountId,StageName  from Opportunity where AccountId IN:set_AccId and StageName != 'Expired' and StageName != 'Closed Lost'];       
         System.debug('#####----update----####'+lst_opportunity);
         for(Contact c: Trigger.New) {
           for(Opportunity obj_opportunity:lst_opportunity) {
           if(blnapproved)
           {       
           		obj_opportunity.Finance_Amount__c = c.bm_fAmountOfCredit__c;
                obj_opportunity.isSystem__c =true;
           }
           else
           {
               	obj_opportunity.Finance_Amount__c = 0.00;
           	    obj_opportunity.isSystem__c =true;
           } 
		   if(addressChanged)
		   {
			   obj_opportunity.Bill_Street__c = c.MailingStreet;
			   obj_opportunity.Bill_City__c = c.MailingCity;
			   obj_opportunity.Bill_Post_Code__c = c.MailingPostalCode;
			   obj_opportunity.Bill_State__c = c.MailingState;
           }    
         }
         }
         
         
          
         update lst_opportunity;
         if(addressChanged)
         {
             list<Job__c> updateJobList = [select id from Job__c where CHI_Lead__r.AccountId in : set_AccId];
             if(updateJobList.size()>0)
             update updateJobList;
         }
      }
      }