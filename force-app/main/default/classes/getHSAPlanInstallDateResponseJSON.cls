global class getHSAPlanInstallDateResponseJSON {
    
    global class installdateResponse
    {
        public String jobId;
        public String leadId;
        public String quoteId;
        Public date customerPreferredDate;
        Public Boolean complexJob;
        public list<JobResourcingOptions> installOptions = new list<JobResourcingOptions>();
        public list<error> errorList = new list<error>();  
    } 
    
     global class Error
    {
      public String Errorcode;
      public String ErrorMessage;
    }
    
    global class JobResourcingOptions
    {
         Public String installDate;         
         public String optionID;
    }
    
}