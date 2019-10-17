/*
Type Name: aINS_aUPD_Case_SetAccountDisputed Trigger
Author: Cognizant
Created Date: 30/06/2010
Reason: To update Account's P5_Is_Dispute__c field when a case is inserted or update for all disputed cases.
Change History:
*/

trigger aINS_aUPD_Case_SetAccountDisputed on Case (after insert, after update) {
    List<string> RcdTypNameList = new List<string>{'Dispute','Complaint'};    
    List<RecordType> RcdTypId = [Select r.Id From RecordType r where r.Name in : RcdTypNameList and sObjectType = 'Case'];       
    Map<Id,Account> CaseAccMap = new Map<Id,Account>();
    Map<Id,Account> UpdateAccMap = new Map<Id,Account>();
    Map<Id,Account> AccountMap = new Map<Id,Account>();
    Map<Id ,RecordType> recordTypeMap = new Map<Id ,RecordType>();
    List<Id> AccIdList = new List<Id>();
    List<Account> AccList = new List<Account>();
    Double iCount=0;	
     
	try {
	//Create record type map
	for(RecordType recordTyp : RcdTypId)
	{        	    	
	    
	    recordTypeMap.put(recordTyp.Id, recordTyp); 	               
	}
	
	for(Case caseObj : Trigger.new)
	{        	    	
	    AccIdList.Add(caseObj.AccountId); 	               
	}
    
    AccList = [Select a.P5_Dispute_cases_Count__c, a.Id From Account a where a.Id in : AccIdList];
    
   //create AccountId-Account map for retrieved list
   
    for(Account account : AccList)
	{        	    	
	    AccountMap.put(account.Id, account); 	               
	}
	   
    
    //create MAP for CaseID-Account object
    for(Case caseObj : Trigger.new)
    {
        CaseAccMap.put(caseObj.Id,AccountMap.get(caseObj.AccountID));
        
       
    }
       
    
       
    //iterate through all cases
    for(Case caseObj : Trigger.new)
    
    {
    	System.debug('---------- caseObj.RecordTypeId = ' + caseObj.RecordTypeId);
        Account AccSetIsDisp = CaseAccMap.get(caseObj.Id);
        // if trigger is in insert mode, check if the account has any dispute case, if yes, then increment the count
        // if trigger is in update mode and case is closed then decrement the count
        if(AccSetIsDisp.P5_Dispute_cases_Count__c != null) 
        	iCount = AccSetIsDisp.P5_Dispute_cases_Count__c;
        else
        	iCount = 0;
        
        if(recordTypeMap.containsKey(caseObj.RecordTypeId))
        {
        	System.debug('---------- record type valid ');
        	Double newCount = iCount; 
        	System.debug('---------- caseObj.IsClosed = ' + caseObj.IsClosed);
            if(caseObj.IsClosed && Trigger.isUpdate)
            {
            	//Case is closed  
                newCount--;
            }
            else if(Trigger.isInsert)
            {
            	//Case is inserted
                newCount++;
            }
            
            //Add to update Map only if the value of count is changed, else skip1
            if(newCount != iCount)
            {
            	system.debug(newCount+'newCount----');
            	AccSetIsDisp.P5_Dispute_cases_Count__c = newCount;
				UpdateAccMap.put(AccSetIsDisp.ID, AccSetIsDisp);
            }
        }
    }
    
    //create another list of account for updation
    List<Account> AccUpdList = UpdateAccMap.Values();
    update AccUpdList;
	} catch(system.Exception e)
    {
    	system.debug('exception'+ e);
    }
    }