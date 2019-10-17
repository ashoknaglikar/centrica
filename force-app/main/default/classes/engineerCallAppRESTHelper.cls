public class engineerCallAppRESTHelper {
 public static getAppointmentsJSON.getAppointmentsResponse getAppointmentsByPostcodeFunc(string postCode,DateTime startTime,DateTime EndTime,String productInterest,
                                                                                         string heating, string hotWaterOp, string otherHeatingOp, string vulnerable, 
                                                                                         string vulnerableReason, string vulnerableSubReason){
      
      getAppointmentsJSON.getAppointmentsResponse returnResponse = new getAppointmentsJSON.getAppointmentsResponse();

      webservice_CHI_Online.GetAppointmentsByPostcode req = new webservice_CHI_Online.GetAppointmentsByPostcode();

      webservice_CHI_Online.cGetAppointmentsRequest cGetApptData = new webservice_CHI_Online.cGetAppointmentsRequest();
      cGetApptData.BracketStart = StartTime;
      cGetApptData.BracketEnd = EndTime;

      req.CHILeadChannel = productInterest;
      
      req.GetAppointmentDate = cGetApptData;
      req.Address = new webservice_CHI_Online.cAddress();
      req.Address.PostCode = postCode;
      
      // Adding Customer Category Details
      req.BoilerOp              =   heating;
      req.HotWaterOp            =   hotWaterOp;
      req.OtherHeatingOp        =   otherHeatingOp;
      req.Vulnerable            =   vulnerable;
      req.VulnerableReason      =   vulnerableReason;
      req.VulnerableSubReason   =   vulnerableSubReason;
      
      //
      webGetAppointmentsByPostcode objAppointment = new webGetAppointmentsByPostcode();
 
      webservice_CHI_Online.GetAppointmentsByPostcodeResponse response  = objAppointment.getAppointmentsByPostcodeFunc(req);


        if(response!=null){
          returnResponse.errorCode = response.Error.code;
          returnResponse.ErrorMessage = response.Error.Message;
          if(response.AppointmentSlots.size()>0){
            list<getAppointmentsJSON.cAppointment> ApptList = new list<getAppointmentsJSON.cAppointment>();
            for(webservice_CHI_Online.cAppointment Appslots: response.AppointmentSlots){
               getAppointmentsJSON.cAppointment a = new getAppointmentsJSON.cAppointment();
               a.AppId = AppSlots.AppId;
               integer offset = 0;//DiaryChangeHelperMethods.getTZOffset(AppSlots.AppStart.date())== 0?1:0;
               a.AppStart = AppSlots.AppStart.addHours(offset);
               a.AppEnd = AppSlots.AppEnd.addHours(offset);
               ApptList.add(a);
            }
            
            returnResponse.AppList = ApptList;
          }
        return returnResponse;
 }
     else{
        
      }
      return null;
}
   }