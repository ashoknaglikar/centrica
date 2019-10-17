public with sharing class deleteAttachments implements Database.Batchable<sObject>{
	
	public static void deleteStart(){
        deleteAttachments delAtt = new deleteAttachments();
        ID batchprocessid = Database.executeBatch(delAtt,200);  
    }
	
	public Database.QueryLocator start(Database.BatchableContext BC){
	    datetime endDate  = DateTime.now().addDays(-180);
        datetime startDate = endDate.addDays(-360);
        
        Delete_Product_Configurations_Setting__c sd = Delete_Product_Configurations_Setting__c.getInstance('Attachment Start Date');
        Delete_Product_Configurations_Setting__c ed = Delete_Product_Configurations_Setting__c.getInstance('Attachment End Date');
        
        
        if(null != sd && null != ed){
            startDate = Datetime.valueOf(sd.Value__c + ' 00:00:00');
            endDate = Date.valueOf(ed.Value__c + ' 00:00:00');
        }
	    return Database.getQueryLocator('Select Id , (Select id, Name,ParentId, ContentType From Attachments), (Select id, CreatedDate from Bigmachines_quotes__r) from Opportunity '+ 
                           ' Where '+system.label.AttachmentDeleteCriteria +' CreatedDate >= :startDate and CreatedDate <= :enddate and closeDate__c = null');
		
	}
	

	
	public void execute(Database.BatchableContext BC, List<sObject> lstRecords){
	    datetime endDateFinal = system.today();
	    Delete_Product_Configurations_Setting__c sd = Delete_Product_Configurations_Setting__c.getInstance('Attachment Final Date');
	    if(null != sd)
	    {
	        endDateFinal = Datetime.valueOf(sd.Value__c + ' 00:00:00');
	    }
	    
		
		List<Attachment> deleteList = new list<Attachment>();
		
        for(sObject rec : lstRecords)   
        {
            Opportunity opp = (Opportunity) rec;
            
            if(opp.Bigmachines_quotes__r.size() == 0)
            {
                for(Attachment a : opp.Attachments)
                {
                    if(a.ContentType == 'image/jpeg' && a.Name.contains('_'+a.ParentId))
                    {
                        deleteList.add(a);
                    }
                }
                
            }else
            {
                
                boolean comeOut = false;
                for(Bigmachines_quote__c b: opp.Bigmachines_quotes__r)
                {
                    if(b.CreatedDate> endDateFinal)
                    comeOut = true;
                    break;
                    
                }
                
                if(comeOut)
                {
                   continue;
                }else
                {
                    for(Attachment a : opp.Attachments)
                    {
                        if(a.ContentType == 'image/jpeg' && a.Name.contains('_'+a.ParentId))
                        {
                            deleteList.add(a);
                        }
                    }
                    
                }
            }
            if(deleteList.size()>990)
            break;
            opp.Attachment_Delete_Date_Time__c = system.now();
            
        }
        
        cls_IsRun.generalTriggerSwitch = true;
        system.debug('Delete List ---->'+deleteList.size());
        database.delete (deleteList, false);
        system.debug('Update List ---->'+lstRecords.size());
        database.update (lstRecords, false);  

      
      
		
	}
	
	
	
	public void finish(Database.BatchableContext BC){
		
	}
	

}