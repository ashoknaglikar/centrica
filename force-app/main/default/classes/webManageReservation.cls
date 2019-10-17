public class webManageReservation {
    
    public webservice_CHI_Online.ManageReservationResponse ManageReservationFunc(webservice_CHI_Online.ManageReservation objManageReservation)
    {
        webservice_CHI_Online.ManageReservationResponse result = new webservice_CHI_Online.ManageReservationResponse();
        system.debug('objManageReservation-- >'+objManageReservation);
        try{
            string appId;
            Datetime start_Date;
            Datetime End_date;
            string reserveId ='';
            
            if(objManageReservation.ReserveAppointment.Appointment.AppId!=null)// && objManageReservation.ReserveAppointment.Appointment.AppId != '')
            {
                appId = objManageReservation.ReserveAppointment.Appointment.AppId;
                start_Date = objManageReservation.ReserveAppointment.Appointment.AppStart;
                End_Date = objManageReservation.ReserveAppointment.Appointment.AppEnd;
                
                
            }else
            {
                result.Error.Code = 9;
                result.Error.Message = 'ERROR: Something went wrong. Appointment Id is blank';
                return result;
            }
            
            if(objManageReservation.ReserveAppointment.ReservationId!=null && objManageReservation.ReserveAppointment.ReservationId != '')
            {
                reserveId = objManageReservation.ReserveAppointment.ReservationId;
            }else
            {
                result.Error.Code = 9;
                result.Error.Message = 'ERROR: Something went wrong. Reservartion Id is blank';
                return result;
            }
            //Change By Ashok G
            Schema.DescribeSObjectResult r = Appointment__c.sObjectType.getDescribe();
			String keyPrefix = r.getKeyPrefix();
            if(!appId.Startswith(keyPrefix)){
         		result.Appointment.AppId = appId;
                result.Appointment.AppStart = start_Date;
                result.Appointment.AppEnd = End_Date;
            }
            else
            {
                Appointment__c appRec = [Select id, Status__c, Start__c, End__c,  Online_Reservation_Id__c from Appointment__c where Id = :appId];
                
                if(appRec.Status__c == 'New' && appRec.Online_Reservation_Id__c==null)
                {
                    appRec.Online_Reservation_Id__c=reserveId;
                    appRec.Status__c = 'Reserved';
                    update appRec;
                    
                    result.Appointment.AppId = appRec.Id;
                    result.Appointment.AppStart = appRec.Start__c;
                    result.Appointment.AppEnd = appRec.End__c;
                }else if(appRec.Status__c != 'New' )
                {
                    // serach for similar appointmnet for another person. 
                    // this is when 2 cstuomers are trying to reserve same appointment.
                    
                    // format postcode correctly
                    string trimmed_code;
                    string first_part;
                    string second_part;
                    string reformatted_code;
                    
                    if(objManageReservation.Postcode!=null)
                    {
                        trimmed_code    = objManageReservation.Postcode.replace(' ', '');
                        system.debug('trimmed_code = ' + trimmed_code);
                        
                        second_part     = trimmed_code.substring(trimmed_code.length()-3, trimmed_code.length());
                        system.debug('second_part = ' + second_part);
                        
                        first_part      = trimmed_code.substring(0, trimmed_code.length()-second_part.length());
                        system.debug('first_part = ' + first_part);
                        
                        reformatted_code  = first_part + ' ' + second_part;
                        system.debug('reformatted_code = ' + reformatted_code);
                    }else
                    {
                        result.Error.Code = 7;
                        result.Error.Message = 'ERROR: Appointment was not reserved.';
                        return result;
                    }
                    webManageCustomerBooking web = new webManageCustomerBooking();
                    Appointment__c app = web.reSearchAppointment(appRec.Start__c , appRec.End__c, reformatted_code, objManageReservation.BoilerOp, 'Central Heating Boiler');
                    system.debug('New Appointment-- >'+app);
                    
                    if(app.Id!=null)
                    {
                        app.Online_Reservation_Id__c=reserveId;
                        app.Status__c = 'Reserved';
                        update app;
                        
                        result.Appointment.AppId = app.Id;
                        result.Appointment.AppStart = app.Start__c;
                        result.Appointment.AppEnd = app.End__c;
                    }
                    else{
                        result.Error.Code = 7;
                        result.Error.Message = 'ERROR: Appointment was not reserved.';
                        return result;
                    }
                    
                }
                
            }
            
            if(objManageReservation.UnReserveAppointment!=null && objManageReservation.UnReserveAppointment.Appointment.AppId!=null)
            {
                string anohterApp  = objManageReservation.UnReserveAppointment.Appointment.AppId;
                if( anohterApp.Startswith(keyPrefix))
                {
                    Appointment__c unreserveApp = new Appointment__c(Id =objManageReservation.UnReserveAppointment.Appointment.AppId , Status__c ='New', Online_Reservation_Id__c=null);
                    
                    update unreserveApp;
                
                }
            }
        }catch (Exception e )
        {
            result.Error.Code = 9;
            result.Error.Message = 'ERROR: Something went wrong. '+e.Getmessage();
            system.debug('Exception while Reserving Appointments'+e.getmessage());
            CreateEmail.CretaeSendTextEmail(new list<string>{system.label.supportOnline},e.getmessage()+' Occured in webManageReservation at line NO: '+e.getLineNumber(), 'Exception in Online Booking webGetAppointmentsByPostcode class');
            return result;
        }
        
        return result;
    }

}