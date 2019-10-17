public class bg_Case_Details_Extension {
 
    private ApexPages.StandardController std;
    public List<ASP_Requested_Items__c> ASPRequestItems;
    public Id chosenChildId {get; set;}
    public Schema.FieldSet ASPItemFieldSet {get {return sObjectType.ASP_Requested_Items__c.FieldSets.ASPRequestedItemsDetails;}}
            
    public bg_Case_Details_Extension()
    {
    }
     
    public bg_Case_Details_Extension(ApexPages.StandardController stdCtrl)
    {
        std=stdCtrl;
        /*
         * Set default record type
         */
        Case c = (Case) std.getRecord();
        c.recordTypeId = [Select R.Id, R.Name, R.SobjectType from RecordType R WHERE R.SobjectType = 'Case' AND R.Name = 'Request For ASP'].Id;
        string oppId = ApexPages.currentPage().getParameters().get('CHILead');
        if (oppId != null && !oppId.equals('')) {
           c.Opportunity__c = oppId;
        }
    }
     
    public Case getCase()
    {
        if(std != null) {
            return (Case) std.getRecord();
        } else {
            return new Case();
        }
    }
 
    public SObject getSobject()
    {
        if(std != null) {
            return std.getRecord();
        } else {
            return new ApexPages.StandardController(new Case()).getRecord();
        }
    }
      
    private boolean updateASPRequestItem()
    {
        boolean result=true;
        if (null!=ASPRequestItems)
        {
           List<ASP_Requested_Items__c> updASPRequestItem=new List<ASP_Requested_Items__c>();
              try
              {
               update ASPRequestItems;
              }
              catch (Exception e)
              {
                 // if its field validation, this will be added to the messages by default
                 if (-1==(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')))
                 {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
                 }
                 result=false;
              }
        }
        return result;
    }
     
    public PageReference saveAndExit()
    {
        if(null!=getCase().id)
        {
	        //boolean result=true;
	        Case tempCase = (Case)std.getRecord();
	        tempCase.Status = 'Submitted';
	        update tempCase;
	        
	        boolean result=updateASPRequestItem();
	        if (result && std != null)
	        {
	            // call standard controller save
	          return std.save();
	        }
	        return null;
        }else
        {
        	std.save();
        	
        	return (saveAndExit());
        }
        
    }
     
    public PageReference save()
    {
     Boolean result=true;
     PageReference pr=Page.bg_Case_Details;
     if (null!=getCase().id)
     {
      result=updateASPRequestItem();
     }
     else
     {
      pr.setRedirect(true);
     }
      
     if (result && std != null)
     {
        // call standard controller save, but don't capture the return value which will redirect to view page
        PageReference tmppr = std.save();
         /*
          * Stay on the same page to catch errors
          */
         if(tmppr == null) {
                 return tmppr;
         }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Changes saved'));
     }
     pr.getParameters().put('id', getCase().id);
     return pr;
    }
 
    public void newASPRequestedItem()
    {
        String caseId;
        if (getCase() != new Case() && getCase().id == null) {
            insert getCase();
        }
        
       if (updateASPRequestItem() && getCase() != null  && getCase().id != null)
       {
          insert new ASP_Requested_Items__c(ASP_Request__c=getCase().id);
          ASPRequestItems=null;
       }
    } 
     
    public void deleteASPRequestedItem()
    {
       //if (updateASPRequestItem())
       {
          if (null!=chosenChildId)
          {
             delete new ASP_Requested_Items__c(Id=chosenChildId);
              ASPRequestItems=null;
              chosenChildId=null;
          }
       }
    }
     
   public List<ASP_Requested_Items__c> getASPRequestedItems()
    {
       if ( (null!=getCase().id) && (ASPRequestItems == null) )
       {
                    String query = 'SELECT ';
                        Set<String> fieldsList = new Set<String>();
                        for(Schema.FieldSetMember f : ASPItemFieldSet.getFields()) {
                                fieldsList.add(f.getFieldPath());
                        }
                        /*
                         * Make sure required fields are present
                         */
                        if(!fieldsList.contains('Id')) {
                                fieldsList.add('Id');
                        }
                        if(!fieldsList.contains('Name')) {
                                fieldsList.add('Name');
                        }
                        query += String.join(new List<String>(fieldsList), ',');
                        query += ' FROM ASP_Requested_Items__c Where ASP_Request__c = \'' + getCase().Id + '\'';
                        ASPRequestItems = Database.query(query);
       }
                           
       return ASPRequestItems;
    }
}