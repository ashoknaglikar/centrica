public class myLeadExtension {
   
      public Lead getLead() {
        if (lead == null)
        {
                lead = new Lead();
                System.debug('Created new Lead');
        }
        return lead;
    }


        public Lead lead;
        private String fireflyId;
        // IntegratedScript changes
        private String paramPostCode;
        private String redirectParams;
        // end IntegratedScript changes
        public myLeadExtension()
        {
             if (lead == null)
                lead = new Lead();
                
            fireflyId = ApexPages.currentPage().getParameters().get('enquiryInterviewId');
            // IntegratedScript changes
            paramPostCode = ApexPages.currentPage().getParameters().get('var_PostCode');
            lead.PostalCode = paramPostCode;
            redirectParams=Utilities.buildParameterString(System.currentPageReference(),null);
            // end IntegratedScript changes
            
            
        }    
   
        public PageReference saveEnquiry()
        {
            
            String postalCodeParam= ApexPages.currentPage().getParameters().get('ffLeadPostCode');
            System.debug('postal code param ' + postalCodeParam);
            
			// IntegratedScript changes
            lead.LastName= UserInfo.getLastName() + Datetime.now();
            lead.Company=lead.LastName + UserInfo.getFirstName() ;
            // end IntegratedScript changes
            lead.Firefly_Id__c= fireflyId;
            System.debug ('Details ' + lead.Street + ',' + lead.PostalCode + ',' + lead.City + ',' + lead.State + ',' + 
            lead.Country + ' , ' + lead.LastName + ' , ' + lead.Company); 
            Database.insert(lead);
            System.debug('Lead Id Created is ' + lead.Id);
            
            // IntegratedScript changes
            PageReference pageRef = new PageReference(''); 
            pageRef = new PageReference('https://bgschi.sparkstudiosaas.com/webredirect'+redirectParams+'&FIREFLY_NAVIGATION=NEXT');
            pageRef.setRedirect(true);
            return pageRef;
            // end IntegratedScript changes
        }
        

}