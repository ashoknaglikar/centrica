@RestResource(urlMapping='/cancelAppointment/*')
global with sharing class customerPortalCancelAppointment{
    
    @HttpPost    
    global static getAppointmentsJSON.cancelAppointmentResponse cancelAppointment(String opportunityId, String PrimaryCancellationReason, string SecondaryCancellationReason)
    {
     
      return CustomerPortalAppointmentHelper.cancelAppointment(opportunityId, PrimaryCancellationReason,SecondaryCancellationReason);
      
      
    }


}