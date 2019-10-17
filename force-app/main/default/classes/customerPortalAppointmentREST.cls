@RestResource(urlMapping='/rearrangeAppointment/*')
global with sharing class customerPortalAppointmentREST {
    
    @HttpPost    
    global static getAppointmentsJSON.getAppointmentsResponse post(string opportunityId,DateTime StartTime,DateTime EndTime)
    {
      
      getAppointmentsJSON.getAppointmentsResponse reply = CustomerPortalAppointmentHelper.getAppointmentsByPostcodeFunc(opportunityId,StartTime,EndTime);
      system.debug('Response --->'+reply);
      return reply;
    }
    /*
    @HttpGet    
    global static getAppointmentsJSON.ManageAppointmentResponse getMethod()
    {
      String oppId = RestContext.request.params.get('Sf_Id');
      String PostCode = RestContext.request.params.get('postcode');
      String AppId = RestContext.request.params.get('AppId');
      String AppDate = Restcontext.request.params.get('AppDate');
      String starttime = RestContext.request.params.get('AppStart');
      String Endtime = RestContext.request.params.get('AppEnd');
      getAppointmentsJSON.ManageAppointmentResponse reply = new getAppointmentsJSON.ManageAppointmentResponse();
      
      getAppointmentsJSON.ManageAppointment req = new getAppointmentsJSON.ManageAppointment();
      
      if(AppId!=null){
        req.Appoinment.AppId = AppId;
      }else{
        reply.Err.ErrorCode = 200;
        reply.Err.ErrorMessage = 'No Appoinment Id';
        return reply;
      }
      
      if((AppDate!=null && AppDate!='') && (Starttime != null && Starttime!='') && (Endtime != null && Endtime!='')){
          Integer Year = Integer.valueof(AppDate.substring(0,4));
          Integer Month = Integer.valueof(AppDate.substring(5,7));
          Integer day = Integer.valueof(AppDate.substring(8,10));
          req.Appoinment.AppStart  =Datetime.newInstance(year,Month,day,integer.valueof(starttime),0,0);
          req.Appoinment.AppEnd = Datetime.newInstance(year,Month,day,integer.valueof(Endtime),0,0);
          
      }else{
         reply.err.ErrorCode = 201;
         reply.err.ErrorMessage = 'Please Check Date,StartTime & EndTime';
         return reply;
      }
     
      reply = CustomerPortalAppointmentHelper.ManageReservation(oppId,req);
      
      return reply;
    }
    */
    
}