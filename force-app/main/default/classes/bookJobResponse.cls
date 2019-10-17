global class bookJobResponse{
    
        public String JobID;
        public String LeadID;
        public String quoteID;
        Public date installDate;
        Public String installTime;
        Public date deliveryDate;
        Public String deliverySlot;     
        public boolean callBack;
        public List<String> errorlist = new List<String>();
    
    /*public class Error
    {
      public String errorcode;
      public String errorMessage;       
    }*/
}