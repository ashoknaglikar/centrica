trigger bUPD_LinkASPwithOpportunity on ASP__c (before update) {

    /*
        Author             : Cognizant
        Functionality     : This is trigger which link the ASP with Opportunity  
                            when the ASP is submitted.
        Create Date      : 18 May 2010
        Change History  :
        Modified Date    :
    
    
     for (ASP__c objAsp:Trigger.new){
       if(objAsp.Status__c =='Submitted')
       {
          objAsp.Related_CHI_Lead__c = objAsp.CHI_Lead_ID__c;
          objAsp.Submitted__c = true;
          objAsp.Submitted_Date__c = Date.Today();
                 }
    }*/
  }