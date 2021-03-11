global class webservice_CHI_Online {


   global class cName {
        webservice string    Salutation;
        webservice string    FirstName;
        webservice string    LastName;        
    }
        
    global class cAddress {
        webservice string    NameNumber;
        webservice string    Street;
        webservice string    TownCity;
        webservice string    CountyProvince;
        webservice string    PostCode;    
    }
    
    global class cContact {
        webservice string MobilePhone;
        webservice string HomePhone;
        webservice string WorkPhone;
        webservice string AltPhone;
        webservice string Email;
        
    }
    
    global class cError {
        webservice integer  Code = 0;
        webservice string   Message = null;
    }
    
    global class cCreateCustomerReply {
        webservice cError   Error       = new cError();
        webservice id       ChiLeadId   = null; 
    }
    
    global class cCreateCustomerRequest {
        webservice cName        Name_x = new cName();
        webservice cAddress     Address = new cAddress();
        webservice cContact     Contact_x = new cContact();
        webservice string       ResStatus;
        webservice boolean      BoilerOp;
        webservice string       FuelType;
        webservice string       BoilerAge;
    }
    
    global class cAppointment {
        webservice string   AppId           = null;
        webservice datetime AppStart        = null;
        webservice datetime AppEnd          = null;
        webservice decimal minutes = null;
        webservice string ProductInterest   = null;
    }
    
    global class cGetAppointmentsReply {
        webservice cError           Error               = new cError();
        webservice id               ChiLeadId           = null;
        webservice cAppointment[]   AppointmentSlots    = new list<cAppointment>();
    }
    
    global class cGetAppointmentsRequest {
        webservice id       ChiLeadId       = null;
        webservice datetime BracketStart    = null;
        webservice datetime BracketEnd      = null;
    }
    
    global class cMakeBookingReply {
        webservice cError   Error           = new cError();
        webservice id       ChiLeadId       = null;
        webservice string   Region          = null;
        webservice string   PicIdentifier   = null;
        webservice string   ChiLeadCustRef  = null;
        // CHANGE REQUEST: CHG00008187 - app start/end times now passed back through interface to prevent mismatch between
        // booked app time and app time confirmed to customer
        webservice datetime AppStart        = null;
        webservice datetime AppEnd          = null;
    }
    
    global class cMakeBookingRequest {
        webservice id       ChiLeadId           = null;
        webservice string       AppointmentId       = null;
        webservice boolean  IsAnytimeApp        = False;
        webservice boolean  CHIMarketing        = False;
        webservice boolean  ProductInterest     = False;
    }
    
    webservice static cCreateCustomerReply fCreateCustomer(cCreateCustomerRequest CreateCustomerData) {
        
        
        cCreateCustomerReply reply = new cCreateCustomerReply();
        
        WebCustomer NewCustomer = new WebCustomer();
        
        reply = NewCustomer.fCreateCustomer(CreateCustomerData);
        
        
        
        return reply;
        
        
    }
    
    
    webservice static cGetAppointmentsReply fGetAppointments(cGetAppointmentsRequest GetAppointmentsData) {
        
        cGetAppointmentsReply                   reply   = new cGetAppointmentsReply();  
        
        WebAvailability GetSlots   = new WebAvailability(GetAppointmentsData.ChiLeadId,
                                                         GetAppointmentsData.BracketStart, 
                                                         GetAppointmentsData.BracketEnd);
        
        reply = GetSlots.fGetAvailability();
        
        
        return reply;
    }
    
    
    webservice static cMakeBookingReply fMakeBooking(cMakeBookingRequest MakeBookingData) {
        
        cMakeBookingReply reply = new cMakeBookingReply();
        
        WebBooking BookSlot = new WebBooking();
        
        reply   = BookSlot.fMakeBooking(MakeBookingData.AppointmentId,
                                        MakeBookingData.ChiLeadId,
                                        MakeBookingData.IsAnytimeApp,
                                        MakeBookingData.CHIMarketing,
                                        MakeBookingData.ProductInterest);
        
        return reply;
    }
    
    // CHI Lead Channel
    
     global class GetAppointmentsByPostcode {
        webservice string    CHILeadChannel = null;
        webservice cAddress     Address = new cAddress();       
        webservice string    BoilerOp = null;
        webservice string    HotWaterOp = null;
        webservice string    OtherHeatingOp = null;
        webservice string    Vulnerable = null;
        webservice string    VulnerableReason = null;
        webservice string    VulnerableSubReason = null;
        webservice cGetAppointmentsRequest GetAppointmentDate = new cGetAppointmentsRequest();
        //Remote Quote 
        webservice String ProductInterest = null;
    } 
    
    global class GetAppointmentsByPostcodeResponse
    {
        webservice cError           Error               = new cError();
        webservice cAppointment[]   AppointmentSlots    = new list<cAppointment>();
        
    }
    
    
    global class ReserveUnreserveAppointment{
        
         webservice cAppointment  Appointment  = new cAppointment();
         webservice string ReservationId = null;
    }
    
    
    global class ManageReservation{
        
        webservice string    CHILeadChannel = null;
        webservice string    PostCode = null;
        webservice string    BoilerOp = null;
        webservice ReserveUnreserveAppointment  ReserveAppointment     = new ReserveUnreserveAppointment();
        webservice ReserveUnreserveAppointment UnReserveAppointment  = new ReserveUnreserveAppointment();
        
    }
    
    global class ManageReservationResponse
    {
        webservice cAppointment  Appointment  = new cAppointment();
        webservice cError           Error     = new cError();
    }
    
    global class cCreateCustomerData{
        webservice string    CHIMarketing= null;
        webservice string    MarketingConsent = null;
        webservice string    MarketingPreference = null; 
        webservice string    EmployeePayrollNumber = null;
        webservice string    MediaCode = null;
        webservice string    BoilerOp = null;
        webservice string    heating = null;
        webservice string    BoilerAge = null;
        webservice string    HotWaterOp = null;
        webservice string    OtherHeatingOp = null;
        webservice string    Vulnerable = null;
        webservice string    VulnerableReason = null;
        webservice string    vulnerableSubReason = null;
        webservice string    ResStatus = null;
        webservice cContact  Contact_x = new cContact();
        webservice string    FuelType;
        webservice cName     Name_x = new cName();
        webservice cAddress  Address = new cAddress();
        webservice boolean   IsAnytimeApp = false;
        //webservice boolean   ProductInterest= false;
        webservice engineerAppLeadExtraInfo extraInfo = new  engineerAppLeadExtraInfo();
        //Remote Quote 
        
        webservice String SocialContactType;
        webservice string SocialContactDetails;
        webservice string ProductInterest;
        
        
    }
    
    global class cCreateAppointmentData{
        
        webservice boolean BringForwardVisit = false;
        webservice string ReservationId = null;
        webservice cAppointment  Appointment  = new cAppointment();
        webservice string happyWithAppointment;
        webservice string appointmentFeedback;
        
    }
    
    global class ManageCustomerBooking{
        webservice string    CHILeadChannel = null;
        webservice cCreateCustomerData CreateCustomerData= new cCreateCustomerData();
        webservice cCreateAppointmentData CreateAppointmentData = new cCreateAppointmentData();
    
    }
    
    global class ManageCustomerBookingResponse
    {
        webservice cAppointment  Appointment  = new cAppointment();
        webservice string ChiLeadCustRef = null;
        webservice string ChiLeadId = null;
        webservice string PicIdentifier = null;
        webservice string Region = null;
        webservice cError Error = new cError();
        webservice string ProductInterest = null;
    }
    
    
     webservice static GetAppointmentsByPostcodeResponse fGetAppointmentsByPostcode( GetAppointmentsByPostcode GetAppointmentsByPostcode)
     {
        GetAppointmentsByPostcodeResponse reply = new GetAppointmentsByPostcodeResponse();
        webGetAppointmentsByPostcode objwebGetAppointmentsByPostcode = new webGetAppointmentsByPostcode();
        reply = objwebGetAppointmentsByPostcode.getAppointmentsByPostcodeFunc(GetAppointmentsByPostcode);
        
        String PI='';
        if(GetAppointmentsByPostcode.Address.PostCode!='' && GetAppointmentsByPostcode.Address.PostCode!= null)
          {
             if(GetAppointmentsByPostcode.CHILeadChannel==null) 
             GetAppointmentsByPostcode.CHILeadChannel = 'Central Heating Boiler';		
             if(GetAppointmentsByPostcode.ProductInterest!=null)		
             GetAppointmentsByPostcode.CHILeadChannel = GetAppointmentsByPostcode.productInterest;
             if(GetAppointmentsByPostcode.CHILeadChannel=='Straight Swap')
             PI= 'SS';
             else if(GetAppointmentsByPostcode.CHILeadChannel=='Guided Sale')
             PI= 'GS';
             else 
             PI='FV';
          }
             
        if(reply!=null){
          if(reply.AppointmentSlots.size()>0){
            for(webservice_CHI_Online.cAppointment Appslots: reply.AppointmentSlots){
               AppSlots.AppId=AppSlots.AppId+PI;
            }
          }
        }
        system.debug('Sugu '+reply);
        return reply;
        
     }
     
     
     webservice static ManageReservationResponse fManageReservation( ManageReservation ManageReservation)
     {
        ManageReservationResponse reply = new ManageReservationResponse();
        webManageReservation objwebManageReservation = new webManageReservation();
        reply = objwebManageReservation.ManageReservationFunc(ManageReservation);
        return reply;
        
     }
     
     webservice static ManageCustomerBookingResponse fManageCustomerBooking( ManageCustomerBooking ManageCustomerBooking)
     {
        ManageCustomerBookingResponse reply = new ManageCustomerBookingResponse();
        webManageCustomerBooking objwebManageCustomerBooking = new webManageCustomerBooking();
        reply = objwebManageCustomerBooking.webManageCustomerBookingFunc(ManageCustomerBooking);
        system.debug('Sugu '+reply);
        return reply;
        
     }
     
     global class engineerAppLeadExtraInfo{
         
         //CHI lead Extra variables which are not present in online webservices. 
         public string homecare;
         public string existingBoiler;
         public string gasAtProperty;
         public string asbestosIdentified;
         public string boilerGCNumber;
         public string boilerBelow18kw;
         public boolean discountType;
         public string reasonForQuote;
         public string unsafeAppReason;
         public integer bedrooms;
         public string ProductInterest;
         public string fuelType;
         
         // stright swap variables
         public string fuseSpurReq;
         public string PEBInstalled;
         public string systemFilterFitted;
         public string powerflushReq;
         public string scaleReducerFitted;
         public string flueType;
         public string flueSubType;
         public string plumeKitReq;
         public string hnztlFlueExtReq;
         public string hnztlFlueBendReq;
         public string terminalGuardReq;
         public string balFlueBrickReq;
         public string heatingControlsReq;
         public string frostProtectionReq;
         public string condensateRun;
         public string termostateReq;
         public string socket;
         public string electricMeter;
         public string foulDrain;
         public string boilerLocation;
         public string furtherWorkRqd;
         
         // Customer signature in string  
         public string signature; 

         public string haNotes;
         public list<attachementObj> attachmentList = new list<attachementObj>();
         
     }
     /*
     global class engineerAppLeadCreateRequest{
        public string    CHILeadChannel = null;
        public cCreateCustomerData CreateCustomerData= new cCreateCustomerData();
        public cCreateAppointmentData CreateAppointmentData = new cCreateAppointmentData();
        public engineerAppLeadExtraInfo extraInfo = new  engineerAppLeadExtraInfo();
        
     }
     */
     
     global class attachementObj {
         public string title;
         public string base64JPEG;
         public string description;
     }
    
    
   
    
    
}