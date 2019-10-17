global class getAppointmentsJSON {
  
    global class getAppointmentsResponse{
        public integer errorCode;
        public String ErrorMessage;
        public list<cAppointment> AppList = new List<cAppointment>();
    }
    
    global class cAppointment {
      public string AppId;
      public datetime AppStart;
      public datetime AppEnd;
     // public string contId;
     }
     
    global class ManageAppointment{

       //public error err = new error();
       public cAppointment Appoinment = new cAppointment();
       
    }
    
    global class ManageAppointmentResponse{
         public cAppointment appointment = new cAppointment();
         public error err = new error();
    }
    
    global class Error{
      public integer Errorcode;
      public String ErrorMessage;
    }
    
    global class createAppoinmentData{
      //public string postcode;
      public cAppointment Appointment = new cAppointment();
      
    }
    
    global class createAppointmentDataResponse{
      public error err = new error();
      public cAppointment Appointment = new cAppointment();
      
    }
    
    global class cancelAppointment{
    
       public string currentAppId;
       public string PrimaryCancellationReason;
       public string SecondaryCancellationReason;
    }
    
    global class cancelAppointmentResponse{
    
       public string Status;
       public error err = new error();
    }
    
  
   
}