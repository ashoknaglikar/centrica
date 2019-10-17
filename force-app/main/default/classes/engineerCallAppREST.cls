@RestResource(urlMapping='/engineerGetAppointments/*')
global with sharing class engineerCallAppREST {
    
    @HttpPost    
    global static getAppointmentsJSON.getAppointmentsResponse post(string postCode,DateTime startDateTime,DateTime endDateTime,string appointmentType, 
                                                                   string heating, string hotWaterOp, string otherHeatingOp, string vulnerable, string vulnerableReason, string vulnerableSubReason)
    {
        system.debug(postCode);
        system.debug(startDateTime);
        system.debug(endDateTime);
        system.debug(appointmentType);
      
      getAppointmentsJSON.getAppointmentsResponse reply = engineerCallAppRESTHelper.getAppointmentsByPostcodeFunc(postCode,startDateTime,endDateTime,appointmentType,
                                                                                                                 heating, hotWaterOp, otherHeatingOp,vulnerable, vulnerableReason,vulnerableSubReason   );
      system.debug('Response --->'+reply);
      return reply;
    }
}