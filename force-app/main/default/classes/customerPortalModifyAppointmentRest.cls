@RestResource(urlMapping='/completeAppointmentBooking/*')
global with sharing class customerPortalModifyAppointmentRest{
    
    @HttpPost    
    global static getAppointmentsJSON.createAppointmentDataResponse completeBooking(string opportunityId, string appointmentId)
    {
     
      getAppointmentsJSON.createAppointmentDataResponse reply = CustomerPortalAppointmentHelper.manageAppointmentBooking(opportunityId,appointmentId);
      
      return reply;
    }


   
    
}