public class CustomerPortalAppointmentHelper{

   public static getAppointmentsJSON.getAppointmentsResponse getAppointmentsByPostcodeFunc(string sf_id,DateTime startTime,DateTime EndTime){
      
      getAppointmentsJSON.getAppointmentsResponse returnResponse = new getAppointmentsJSON.getAppointmentsResponse();
      
      
      list<Opportunity> result = [SELECT Id, Name, StageName,AccountId, CHI_Lead_Id__c,Customer_Name__c, Install_Address_Street__c, Install_Address_County__c, Install_Address_City__c, Install_Postcode__c, Product_Interest__c  FROM Opportunity WHERE Id = :Sf_id];
      if(result.size()>0){
        
        if(result[0].accountId !=null){
            Account acc = [Select id,name,Primary_Contact__c from Account where id=:result[0].accountId];
            if(acc==null){
              returnResponse.Errorcode = 110;
              returnResponse.ErrorMessage = 'No Account Exist with the id:'+result[0].accountId;
            }
        }else{
          returnResponse.Errorcode = 120;
          returnResponse.ErrorMessage = 'No Account Exists for the Opportunity';
        }
        webservice_CHI_Online.cAddress cAddr = new webservice_CHI_Online.cAddress();
        //cAddr.NameNumber = ;
        cAddr.PostCode = result[0].Install_Postcode__c;
        cAddr.Street = result[0].Install_Address_Street__c;
        cAddr.TownCity = result[0].Install_Address_City__c;
        cAddr.CountyProvince = result[0].Install_Address_County__c;
        
        webservice_CHI_Online.cGetAppointmentsRequest cGetApptData = new webservice_CHI_Online.cGetAppointmentsRequest();
        cGetApptData.ChiLeadId = result[0].Id;
        cGetApptData.BracketStart = StartTime;
        cGetApptData.BracketEnd = EndTime;
        
        webservice_CHI_Online.GetAppointmentsByPostcode req = new webservice_CHI_Online.GetAppointmentsByPostcode();
        req.Address = cAddr;
        req.GetAppointmentDate = cGetApptData;
        req.ProductInterest = result[0].Product_Interest__c == 'Straight Swap' || result[0].Product_Interest__c == 'Telesales Conv' ? 'Straight Swap':result[0].Product_Interest__c;
        webGetAppointmentsByPostcode avail = new webGetAppointmentsByPostcode();
        webservice_CHI_Online.GetAppointmentsByPostcodeResponse response = avail.getAppointmentsByPostcodeFunc(req);
        
        if(response!=null){
          returnResponse.errorCode = response.Error.code;
          returnResponse.ErrorMessage = response.Error.Message;
          if(response.AppointmentSlots.size()>0){
            list<getAppointmentsJSON.cAppointment> ApptList = new list<getAppointmentsJSON.cAppointment>();
            for(webservice_CHI_Online.cAppointment Appslots: response.AppointmentSlots){
               getAppointmentsJSON.cAppointment a = new getAppointmentsJSON.cAppointment();
               a.AppId = AppSlots.AppId;
               integer offset = DiaryChangeHelperMethods.getTZOffset(AppSlots.AppStart.date())== 0?1:0;
               a.AppStart = AppSlots.AppStart.addHours(offset);
               a.AppEnd = AppSlots.AppEnd.addHours(offset);
               ApptList.add(a);
            }
            
            returnResponse.AppList = ApptList;
           
          }
          
        }
        return returnResponse;
      }else{
        
      }
      return null;
   }
   
   
   Public static getAppointmentsJSON.ManageAppointmentResponse ManageReservation(string PostCode, getAppointmentsJSON.ManageAppointment reservedAppt){
   
       getAppointmentsJSON.ManageAppointmentResponse returnResponse = new getAppointmentsJSON.ManageAppointmentResponse();
       
       webservice_CHI_Online.ReserveUnreserveAppointment Appt = new webservice_CHI_Online.ReserveUnreserveAppointment();
       if(reservedAppt!=null){
           Appt.Appointment.AppId = reservedAppt.Appoinment.AppId;
           Appt.Appointment.AppStart = reservedAppt.Appoinment.AppStart;
           Appt.Appointment.AppEnd = reservedAppt.Appoinment.AppEnd;
          
          
       }else{
          //Error: select An appointement to book
          returnResponse.err.ErrorCode = 100;
          returnResponse.err.ErrorMessage = 'Select an appointment to book';
          return returnResponse;
       }
       Appt.ReservationId = 'Testing'; //Change it later;
         
       webservice_CHI_Online.ManageReservation res = new webservice_CHI_Online.ManageReservation();
       res.PostCode = PostCode;
       res.ReserveAppointment = Appt;
       
       webManageReservation mResv = new webManageReservation();    
       webservice_CHI_Online.ManageReservationResponse response = mResv.ManageReservationFunc(res);
       if(response!=null){
          getAppointmentsJSON.cAppointment a = new getAppointmentsJSON.cAppointment();
          a.AppId = response.Appointment.AppId;
          a.AppStart = response.Appointment.AppStart;
          a.AppEnd = response.Appointment.AppEnd;
          
          
          returnResponse.err.errorCode = response.Error.code;
          returnResponse.err.ErrorMessage = response.Error.Message;
          returnResponse.appointment = a;
      
      
          return returnResponse;
        
       }
   
    return null;
   }
   
   
   public static getAppointmentsJSON.createAppointmentDataResponse manageAppointmentBooking(string oppId,string Appt_ID){
       
         CustomerPortalAppointmentHelper.cancelAppointment(oppId, 'Customer Rearranged via Portal', 'Customer Rearranged via Portal');
          
         getAppointmentsJSON.createAppointmentDataResponse reply = new getAppointmentsJSON.createAppointmentDataResponse();
         
         Opportunity Opp = [SELECT Id, CloseDate, StageName,Product_Interest__c, CHI_Lead_Id1__c, AccountId ,Account.Primary_Contact__c, Install_Postcode__c,(Select id, Status__c,Visit_Date__c from Appointments__r)
                                        FROM Opportunity
                                        WHERE id=:oppId
                                        LIMIT 1];
         try{
                 webservice_CHI_Online.cCreateAppointmentData obj = new webservice_CHI_Online.cCreateAppointmentData();
                 obj.Appointment = new webservice_CHI_Online.cAppointment();
                 obj.Appointment.AppId = Appt_ID;
                 
                 Appointment__c bookedAppointment = new webManageCustomerBooking().bookedAppointment(obj, oppId,false );
                 
                 if(bookedAppointment.id!=null)
                {
                    reply.Appointment.AppId = bookedAppointment.Id;
                    reply.Appointment.AppStart = bookedAppointment.Start__c;
                    reply.Appointment.AppEnd = bookedAppointment.End__c;
                    
                }else
                {
                    reply.err.ErrorCode = 7;
                    reply.err.ErrorMessage = 'ERROR:  Appointmet is not available anymore';
                    return reply;
                }
            
            }
            catch(exception e)
            {
                reply.err.ErrorCode = 4;
                reply.err.ErrorMessage = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+opp.Id +' Number :'+opp.CHI_Lead_Id1__c;
                return reply;
            }
             
             /*
              
              
                string available_rt_id = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
                
                Schema.DescribeSObjectResult r = Appointment__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                if(!Appt_ID.startswith(keyPrefix)){
                    string post_code_sector = opp.Install_Postcode__c.substring(0,opp.Install_Postcode__c.length()-2);
                    //system.debug('Postcode sector = ' + post_code_sector); 
                    
                    system.debug('Appointemtn Info-->'+Appt_ID);
                    
                    string prodInterest = 'Central Heating Boiler';
                        
                    //This select gets the sub-patch and district for the post code sector, of the same type as the CHI Lead (sales/survey)                               
                    Postcode_Sector__c[] post_code_info = [SELECT p.Sub_Patch__c, p.Sub_Patch__r.District__c ,p.sub_Patch__r.Appointment_Source__c,p.sub_patch__r.OFS_Start_Date__c,p.sub_Patch__r.OFS_Bucket_Name__c, p.Sub_Patch__r.District__r.NA_Online__c
                                                       FROM Postcode_Sector__c p
                                                       WHERE name = :post_code_sector
                                                       AND type__c = 'Sales'];
                                                       
                    string ofsBuckname = post_code_info[0].sub_Patch__r.OFS_Bucket_Name__c;  
                    
                    
                    
                    integer year =  integer.valueof(Appt_ID.substring(14,18));
                    integer month = integer.valueof(Appt_ID.substring(12,14));
                    integer day = integer.valueof(Appt_ID.substring(10,12));
                    string GetTimeslot= Appt_ID.substring(08,10);
                    system.debug(LoggingLevel.INFO,' '+year);
                    system.debug(LoggingLevel.INFO,' '+month);
                    system.debug(LoggingLevel.INFO,' '+day);
                    system.debug(LoggingLevel.INFO,' '+GetTimeslot);
                    SalesAppointment__c s = SalesAppointment__c.getInstance(GetTimeslot);
                    
                    datetime slotStartTime = datetime.newInstance(year, month, day, integer.valueof(s.Start_Time__c.split(':')[0]), integer.valueof(s.Start_Time__c.split(':')[1]), 0);
                    datetime slotEndTime = datetime.newInstance(year, month, day, integer.valueof(s.End_Time__c.split(':')[0]), integer.valueof(s.End_Time__c.split(':')[1]), 0);
                    datetime SLAStartTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_Start__c.split(':')[0]), integer.valueof(s.SLA_Start__c.split(':')[1]), 0);
                    datetime SLAEndTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_End__c.split(':')[0]), integer.valueof(s.SLA_End__c.split(':')[1]), 0);
                    
                    //dateTime End_Date = custAppt.Appointment.AppEnd;
               
                
                   //string GetTimeslot= string.valueof(Appt_ID).substring(string.valueof(Appt_ID).length()-5,string.valueof(Appt_ID).length()-3);
                   TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(prodInterest);
                   Appointment__c newAppt = new Appointment__c();
                   newAppt.Assigned_To__c = ofsBuckname;
                   newAppt.Opportunity__c = oppId;
                   newAppt.Who__c = opp.Account.Primary_Contact__c;
                   newAppt.Status__c = 'Appointed';
                   newAppt.start__c = slotStartTime;
                   newAppt.End__c = slotEndTime;
                   newAppt.Visit_Type__c = 'First Visit';
                   newAppt.Show_Time_As__c = 'Busy';
                   newAppt.RecordTypeId = available_rt_id;
                   newAppt.SLA_Start__c = SLAStartTime;
                   newAppt.SLA_End__c = SLAEndTime;
                   if(toaPI != null)
                   newAppt.TOA_Duration__c = toaPI.Duration__c;
                   
                   newAppt.Time_Band__c = GetTimeSlot;
                   newAppt.OFS_Appointment__c = true;
                   //newAppt.Bring_forward_visit__c = custData.BringForwardVisit!=null ?objManageCustomerBooking.CreateAppointmentData.BringForwardVisit : false;
                   system.debug('*************^^^^'+newAppt);
                   try{
                        
                        insert newAppt;
                       
                        reply.Appointment.AppId = newAppt.id;
                        reply.Appointment.AppStart = newAppt.start__c;
                        reply.Appointment.AppEnd = newAppt.End__c;
                        
                        
                    }catch (Exception e)
                    {
                        
                        reply.err.ErrorCode = 4;
                        reply.err.ErrorMessage = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+opp.Id +' Number :'+opp.CHI_Lead_Id1__c;
                        return reply;
                        
                    } 
    
                }else{
                    Appointment__c appRec = [Select id, Status__c, Start__c, End__c,  Online_Reservation_Id__c from Appointment__c where Id = :Appt_ID];
                    appRec.Opportunity__c= oppId;
                    appRec.Who__c = opp.Account.Primary_Contact__c;
                    appRec.Visit_Type__c = 'First Visit';
                    
                     try{
                            
                            update appRec;
                            reply.Appointment.AppId = appRec.Id;
                            reply.Appointment.AppStart = appRec.Start__c;
                            reply.Appointment.AppEnd = appRec.End__c;
                            
                            
                        }catch (Exception e)
                        {
                            
                            reply.err.ErrorCode = 4;
                            reply.err.ErrorMessage = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+opp.Id +' Number :'+opp.CHI_Lead_Id1__c;
                            return reply;
                            
                        }
                }
            */    
         return reply;
    }
    
    public static getAppointmentsJSON.cancelAppointmentResponse cancelAppointment(String OppId, String PrimaryCancellationReason, string SecondaryCancellationReason){
        
        getAppointmentsJSON.cancelAppointmentResponse returnResponse = new getAppointmentsJSON.cancelAppointmentResponse();
        map<string, string> reasonMapping = new map<string, string>();
        
        for(PortalCancelReasons__c p :  PortalCancelReasons__c.getAll().values())
        {
            reasonMapping.put(p.Portal_Reason__c, p.Salesforce_Reason__c);
        }
        
        if(OppId!=null){
         
           
           Appointment__c a = [select id,name,Primary_Cancellation_Reason__c,Secondary_Cancellation_Reason__c from Appointment__c where Opportunity__c=:OppId and Status__c = 'Appointed' and Type__c = 'Sales' ];
           a.Status__c = 'Cancelled';
          
           a.Primary_Cancellation_Reason__c = PrimaryCancellationReason;
           if(reasonMapping.containskey(SecondaryCancellationReason))
           a.Secondary_Cancellation_Reason__c= reasonMapping.get(SecondaryCancellationReason);
           else if(SecondaryCancellationReason!=null)
           {
               a.Secondary_Cancellation_Reason__c = SecondaryCancellationReason;
           }
           
           else{
           returnResponse.Status = 'Error';
           returnResponse.err.ErrorCode = 205;
           returnResponse.err.ErrorMessage = 'Secondary cancellation reason is missing. Or this reason is not present in Salesforce. ';
           return returnResponse;
           }
           
          try{
                             
             Update a;
             returnResponse.Status = 'Success';
             return returnResponse;
           }catch(Exception e){
             returnResponse.Status = 'Error';
             returnResponse.err.ErrorCode = 203;
             returnResponse.err.ErrorMessage = e.getMessage();
             return returnResponse;
           }
         
        }else{
          returnResponse.Status = 'Error';
          returnResponse.err.ErrorCode = 202;
          returnResponse.err.ErrorMessage = 'Cancellation Appointment Id is missing.';
          return returnResponse;
        }
    
      return null;
    }
    
    
    public List<opportunity> getOpportunity(string oppId){
     
     List<opportunity> result = [SELECT Id, Name, StageName,AccountId, CloseDate,CHI_Lead_Id__c,CHI_Lead_Id1__c,Customer_Name__c, Install_Address_Street__c, Install_Address_County__c, Install_Address_City__c, Install_Postcode__c,
                                 Product_Interest__c,(select id,name,visit_date__c,Status__c,Primary_Cancellation_reason__c,Secondary_Cancellation_reason__c from Appointments__r)  FROM Opportunity 
                                 WHERE Id = :oppId];
                                 
     return result;

    
    }
}