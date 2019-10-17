public class ssDirectUpdate{
   string oppId = ApexPages.currentPage().getParameters().get('oppId');
   public boolean newInbound{get;set;}
   public opportunity opp{get;set;}
   public boolean tenant{get;set;}
   public boolean Landlord{get;set;}
   public ssDirectUpdate(){
      newInbound = ApexPages.currentPage().getParameters().get('new')=='true'?true:false;
      tenant = false;
      Landlord = false;
      opp = [select id,name,AccountId,Account.Primary_Contact__c,Product_Interest__c,Contact_Type__c from opportunity where id=:oppId];
      if(opp.Contact_Type__c == 'Tenant')
      tenant = true;
      else if(opp.Contact_Type__c == 'Landlord' || opp.Contact_Type__c == 'Agent' || opp.Contact_Type__c == 'Multi-premise')
      {
      Landlord = true;
      }
   }
   
   public void confirm(){
    //pageReference returnUrl ;
    
    opp.Product_Interest__c = 'Straight Swap - Direct';
    update Opp;
    
    
    /*returnUrl =  new pageReference('/apex/availability?var_OpptyId='+  
                        oppId+'&var_Source=ICL&view=null&var_date=null&var_contactId='
                        +opp.Account.Primary_Contact__c+'&gDeal=3'+'&new='+newInbound);
                        
    return returnUrl;*/
   }
   
     
   public pageReference cancel(){
           return ( new pagereference ('/apex/new_Wrapupscreenpage?chiLeadId='+opp.Id+'&accId='+opp.AccountId+'&new='+newInbound));

   }
   
}