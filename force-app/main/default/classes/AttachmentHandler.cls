public with sharing class AttachmentHandler extends TriggerHandler 
    implements TriggerHandler.ITrigger
{
    private static Map<Id, BigMachines_Quote__c> s_quotes = new Map<Id, BigMachines_Quote__c>();
    private static final String MIME_TYPE_PDF = 'application/pdf';
    public static final String QUOTE_ATTACHMENT_ERROR = 'You cannot modify or delete attachments belonging to Big Machines Quotes.';
    private static Map<Id, BigMachines_Quote__c> chiId_quotes = new Map<Id, BigMachines_Quote__c>();

    public AttachmentHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList)
    {
        super(oldMap, newMap, oldList, newList);
    }
    
    public void bulkBefore()
    {
        // Only do this if the attachement is being modified or deleted
        if (this.operation ==  TriggerOperation.IS_UPDATE ||
            this.operation == TriggerOperation.IS_DELETE )
        {
            Set<Id> parentIds = new Set<Id>();
            
            // loop through and gather up the parent ids for all the records being passed to the trigger
            for (SObject so : this.oldList)
            {
                Attachment att = (Attachment)so;
                parentIds.add(att.ParentId);
            }
            
            // get a list of all quotes related to the attchment
            s_quotes = BMQuoteMapper.getQuotesByIds(parentIds);
        }else if(this.operation ==  TriggerOperation.IS_INSERT )
        {
            
            Set<Id> parentIds = new Set<Id>();
            
            // loop through and gather up the parent ids for all the records being passed to the trigger
            for (SObject so : this.newList)
            {
                Attachment att = (Attachment)so;
                parentIds.add(att.ParentId);
                
                
            }
            
            // get a list of all quotes related to the attchment
            s_quotes = BMQuoteMapper.getQuotesByIds(parentIds);
            
        }
    }
    map<Id,integer> jobCountMap = new map<Id,integer>();
    public void bulkAfter()
    {
             // Update the count of variation order count on the Jobs.
            if(this.operation ==  TriggerOperation.IS_INSERT )
            {
            for (SObject so : this.newlist)
            {
                string jobKeyPrefix = Job__c.sobjecttype.getDescribe().getKeyPrefix();
                Attachment att = (Attachment)so;
                if(att.Name!=null && att.Name.touppercase().contains(System.label.Variation_Order) && att.ParentId != null && String.valueof(att.ParentId).startswith(jobKeyPrefix))
                {
                    if(jobCountMap.containskey(att.ParentId))
                    {
                         jobCountMap.put(att.ParentId , jobCountMap.get(att.ParentId)+1);
                    }else
                    {
                        jobCountMap.put(att.ParentId , 1);
                    }
                }
                
            }
            list<Job__c> updatingJobList = [Select Id,Count_of_VO_Order__c From Job__c where Id in : jobCountMap.keyset()];
            for(Job__c  j : updatingJobList){
                
                if(j.Count_of_VO_Order__c==null)
                {
                    j.Count_of_VO_Order__c = jobCountMap.get(j.Id);
                }else
                {
                    j.Count_of_VO_Order__c += jobCountMap.get(j.Id);
                }
            }
            if(updatingJobList.size()>0)
            update updatingJobList;
            }
    }
            
    public void beforeInsert(SObject so)
    {
        // ++ Added the condition for PDF Recieved change - Nitish
        if(system.label.AutoPRDSwitch== 'on')
        {
            checkPDF_Format(so);
        }
        // -- Added the condition for PDF Recieved change - Nitish
    }
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        // prevent modification/deletion of Quote Attachments
        checkQuoteAttachments(oldSo, so);
    }
    
    public void beforeDelete(SObject so)
    {
        // prevent modification/deletion of Quote Attachments
        string jobKeyPrefix = Job__c.sobjecttype.getDescribe().getKeyPrefix();
        Attachment att = (Attachment)so;
        if(att.Name!=null && att.Name.touppercase().contains(System.label.Variation_Order) && att.ParentId != null && String.valueof(att.ParentId).startswith(jobKeyPrefix) && !system.label.SystemAdminId.contains(userinfo.getProfileId()))
        {
            so.adderror('You cannot delete this Attachment.');
        }
        checkQuoteAttachments(so, so);
    }
    
    public void afterInsert(SObject so)
    {   
          Attachment att = (Attachment)so;
          String parentObjId = att.ParentId;
          String parentKeyPrefix = parentObjId.substring(0, 3);
          Schema.DescribeSObjectResult r = case.sObjectType.getDescribe();
          String keyPrefix = r.getKeyPrefix();


        if((keyPrefix==parentKeyPrefix  && att.Name.toUpperCase().contains(system.label.Complaints_Acknowledgement)) && system.label.casechangeswitch=='on')
         {
		   case cs= new case(id=parentObjId);
           cs.Date_acknowledgement_letter_sent__c=system.Today();
           update cs;

         }
     }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {   
            
    }
    
    public void afterDelete(SObject so)
    {       
    }
    
    public void postProcessing()
    {   
        
        
    }

    // private methods
    
    private void checkQuoteAttachments(SObject so, SObject errorObj)
    {
        Attachment att = (Attachment)so;
        
        // check if the attachment belongs to a Quote
        if (s_quotes.containsKey(att.ParentId) && att.ContentType == MIME_TYPE_PDF)
        {
            errorObj.addError(QUOTE_ATTACHMENT_ERROR);
        }
    }   
    
    private void checkPDF_Format(SObject so)
    {
        Attachment att = (Attachment)so;
        
        // ++ Variable created for PDF Recieved change - Nitish
        List<BigMachines_Quote__c> quotesToUpdate = new List<BigMachines_Quote__c>();
        // -- Variable created for PDF Recieved change - Nitish
        if(s_quotes.containsKey(att.ParentId) && att.Name.startsWith(s_quotes.get(att.ParentId).BigMachines_Transaction_Id__c))
        {
            if(!(att.Name.endsWith('.pdf')))
            {
                quotesToUpdate.add(new BigMachines_Quote__c(id= att.ParentId, FaultPDF__c = true)); 
            }
            /*
            // ++ Added for PDF Recieved change - Nitish
            else
            {
                quotesToUpdate.add(new BigMachines_Quote__c(id= att.ParentId, PDF_Received__c = true));
            }
            // -- Added for PDF Recieved change - Nitish
            */
            
        }
        // ++ Added for PDF Recieved change - Nitish
        if(quotesToUpdate.size() > 0)
        {
            update quotesToUpdate;
        }
        // -- Added for PDF Recieved change - Nitish
    }
    
    
    
}