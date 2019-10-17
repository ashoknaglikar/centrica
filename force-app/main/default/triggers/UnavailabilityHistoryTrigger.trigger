trigger UnavailabilityHistoryTrigger on Unavailability_History_Tracker__c (after update, before update,after insert) {
    //UnavailabilityHistoryHelper uht = new UnavailabilityHistoryHelper();
    list<Unavailability_History_Child_Record__c> childrecordList= new list<Unavailability_History_Child_Record__c> ();
   
          if(trigger.isafter)
        {
          
          	if(trigger.isinsert)
          	
    	{
    		for(Unavailability_History_Tracker__c uht :trigger.new)
    		
    		{
    			system.debug('Newly Created****'+uht);
    		childrecordList.add(new Unavailability_History_Child_Record__c(
            							
            						    Start__c = uht.Start__c, 
            							End__c = uht.End__c,
            							Unavailability_History_Tracker__c = uht.Id,
            							Unavailability_Notes__c = uht.Unavailability_Notes__c,
            							Type__c = uht.Type__c,
            							Sub_Type__c = uht.Sub_Type__c,
            						    Hours__c = uht.Hours__c,
            						 //Amendment_Reason__c =  uht.Amendment_Reason__c,
            							Mode__c='Created'
            					  
            					  	));
    		
    		
    		}
    		
   	}
    		
        if(trigger.isupdate)
        {
            
            for(Unavailability_History_Tracker__c uht :trigger.new)
            {
            	Unavailability_History_Tracker__c oldUht = trigger.oldmap.get(uht.id);
            	system.debug('New Record****'+oldUht);
            	if(uht.Removed__c != oldUht.Removed__c)
            	 
            	{
            		system.debug('***** Inside Childrecord****');
            	 
            	 childrecordList.add(new Unavailability_History_Child_Record__c(
            							CHI_Lead_Number__c = uht.CHI_Lead_Number__c, 
            							Unavailability_History_Tracker__c = uht.Id,
            							Start__c = uht.Start__c,
            							End__c = uht.End__c,
            							Unavailability_Notes__c = uht.Unavailability_Notes__c,
            							Type__c = uht.Type__c,
            							Sub_Type__c = uht.Sub_Type__c,
            							Hours__c = uht.Hours__c,
            							Amendment_Reason__c =  uht.Amendment_Reason__c,
            							Mode__c='Removed',
            							Old_CHI_Lead_Number__c=oldUht.CHI_Lead_Number__c,
            						    Old_Start__c=oldUht.Start__c, 
            							Old_End__c=oldUht.End__c,
            							Old_Unavailability_Notes__c=oldUht.Unavailability_Notes__c,
            							Old_Type__c=oldUht.Type__c,
            							Old_Subtype__c=oldUht.Sub_Type__c,
            							Old_Hours__c=oldUht.Hours__c,
            							Old_Ammendment_Reason__c=oldUht.Amendment_Reason__c,
            							Removed__c=true
            							
            				  	));
            	}
            	
            	else if(uht.CHI_Lead_Number__c != oldUht.CHI_Lead_Number__c || uht.End__c != oldUht.End__c || uht.Start__c != oldUht.Start__c 
            	|| uht.Sub_Type__c != oldUht.Sub_Type__c || uht.Type__c != oldUht.Type__c || uht.Unavailability_Notes__c != oldUht.Unavailability_Notes__c)
            	{
            		system.debug('***** Inside Child Creation****');
            		childrecordList.add(new Unavailability_History_Child_Record__c(
            							CHI_Lead_Number__c = uht.CHI_Lead_Number__c, 
            							Unavailability_History_Tracker__c = uht.Id,
            							Start__c = uht.Start__c,
            							End__c = uht.End__c,
            							Unavailability_Notes__c = uht.Unavailability_Notes__c,
            							Type__c = uht.Type__c,
            							Sub_Type__c = uht.Sub_Type__c,
            							Hours__c = uht.Hours__c,
            							Amendment_Reason__c =  uht.Amendment_Reason__c,
            							Mode__c='Amended',
            							Old_CHI_Lead_Number__c=oldUht.CHI_Lead_Number__c,
            						    Old_Start__c=oldUht.Start__c, 
            							Old_End__c=oldUht.End__c,
            							Old_Unavailability_Notes__c=oldUht.Unavailability_Notes__c,
            							Old_Type__c=oldUht.Type__c,
            							Old_Subtype__c=oldUht.Sub_Type__c,
            							Old_Hours__c=oldUht.Hours__c,
            							Old_Ammendment_Reason__c=oldUht.Amendment_Reason__c
            							
            				  	));
            	 
            	 }
            	
            	
            	
        
            }
        }
        
    	} 
    
    if(trigger.isBefore)
        {
        	if(trigger.isUpdate)
        	{
        		for(Unavailability_History_Tracker__c uht :trigger.new)
	            {
	            	system.debug('New Record****'+uht);
	            	
	            	Unavailability_History_Tracker__c oldUht = trigger.oldmap.get(uht.id);
	            	system.debug('New Record****'+oldUht);
	            	if(uht.Old_Type__c == null   && (uht.End__c != oldUht.End__c || uht.Start__c != oldUht.Start__c 
            	|| uht.Sub_Type__c != oldUht.Sub_Type__c || uht.Type__c != oldUht.Type__c || uht.Unavailability_Notes__c != oldUht.Unavailability_Notes__c ))
	            	{
	            		//childrecordList.add(new Unavailability_History_Child_Record__c(Mode__c='Removed',Removed__c=true));
	            		 uht.Old_Type__c=  oldUht.Type__c;
				         uht.Old_Start_Date__c = oldUht.Start__c;
				         uht.Old_Sub_Type__c = oldUht.Sub_Type__c;
				         uht.Old_End_Date__c = oldUht.End__c;
				         uht.Old_Hours__c  = oldUht.Hours__c;
	            	}
	          
	            }
        	}
        	
        }
    
    if(childrecordList.size()>0)
    {
    	insert childrecordList;
    }

}