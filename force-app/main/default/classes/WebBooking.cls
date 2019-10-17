public class WebBooking {
    
    string  app_id      = null;
    string year = null;
    string month = null;
    string day = null;
    string GetTimeSlot = null;
    id  chi_lead_id = null; 
    id  acc_id      = null;
    string apptId = null;
    
    List<Appointment__c>    apps        = new List<Appointment__c>();
    Opportunity             chi_lead    = new Opportunity();
    Account                 chi_acc     = new Account();    
    
    public webservice_CHI_Online.cMakeBookingReply fMakeBooking(string      AppID,
                                                                id      CHILeadId,
                                                                boolean IsAnytime,
                                                                boolean CHIMarketingInterest,
                                                                boolean ESProductInterest) {
                                            
        webservice_CHI_Online.cMakeBookingReply result = new webservice_CHI_Online.cMakeBookingReply();
        
        Opportunity chi_lead = new Opportunity();
        
        chi_lead_id = CHILeadId;
        system.debug('chi_lead_id: ' + chi_lead_id);
        app_id      = AppID;
        if(app_id != null){
        apptId = string.valueof(app_id).substring(string.valueof(app_id).length()-13,string.valueof(app_id).length());
        
        year = apptId.substring(0,4);
        month = apptId.substring(4,6);
        day = apptId.substring(6,8);
        
        GetTimeSlot = apptId.substring(8,10);
        }
        //string OFS = apptId.substring(10,13);
        Schema.DescribeSObjectResult r = Appointment__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        system.debug('app_id: ' + app_id);
        
        result.ChiLeadId = chi_lead_id;
        
        // first check there are no existing sales appointments for this lead 
        Appointment__c[] relatedApps = [SELECT Id, Type__c, Status__c 
                                        FROM Appointment__c 
                                        WHERE Opportunity__c = :chi_lead_id
                                        AND Start__c >= :Datetime.now()
                                        AND Type__c = 'Sales'
                                        AND Status__c = 'Appointed'];
                                        
        System.debug('Number of relted appointments: ' + relatedApps.size());
        
        if (relatedApps.size() > 0) { // already appointment booked, don't let book another
            result.Error.Code = 1;
            result.Error.Message = 'ERROR: Sales appointment already booked for CHI Lead ' + chi_lead_id;
            system.debug(result.Error.Message);
            
            return result;          
        }
        
        
        
        try {
            
            chi_lead = [SELECT AccountId, Id, Account.BillingPostalCode, CHI_Lead_Id__c, Visit_Type__c, Product_Interest__c, ES_Product_Interest__c
                        FROM Opportunity 
                        WHERE Id = :chi_lead_id];
            
            acc_id                  = chi_lead.AccountId;
            result.ChiLeadCustRef   = chi_lead.CHI_Lead_Id__c;
        }
        catch (exception e) {
        
            result.Error.Code = 2;
            result.Error.Message = 'ERROR: CHI Lead retrieval failed, ID ' + chi_lead_id;
            system.debug(result.Error.Message);
            
            return result;
        }
                                
        
        try {
            
            chi_acc = [SELECT a.Primary_Contact__c, a.Sales_Subpatch__r.Name
                       FROM Account a
                       WHERE a.Id = :acc_id];
        }
        catch (exception e) {
            
            result.Error.Code = 3;
            result.Error.Message = 'ERROR: CHI Account retrieval failed, ID ' + acc_id;
            system.debug(result.Error.Message);
            
            return result;
        }
        
        // code copied from AvailabilityP2Controller
        // I'm not exactl certain why this is here, but it appears to be required in case record types change, so it is included here
        Utilities.setup();
                   
        id available_rt_id = null;
                    
        for(RecordType rt : Utilities.recordTypes.values()) {
            
            if(rt.Name == 'Appointment' 
               && 
               rt.SobjectType == 'Appointment__c') {
                
                available_rt_id = rt.Id;  
            }            
        }
        
        boolean app_booked      = false;
        boolean booking_fail    = false;
        boolean ApptOFS = false;
        integer attempt_counter  = 0;
        
        string post_code_sector = chi_lead.Account.BillingPostalCode.substring(0,chi_lead.Account.BillingPostalCode.length()-2);
        system.debug('Postcode sector = ' + post_code_sector); 
        
        string visit_type =  chi_lead.Visit_Type__c;
        system.debug('visit type = '+visit_type);
        
        string prodInterest = chi_lead.Product_Interest__c;
        
        //This select gets the sub-patch and district for the post code sector, of the same type as the CHI Lead (sales/survey)                               
        Postcode_Sector__c[] post_code_info = [SELECT p.Sub_Patch__c, p.Sub_Patch__r.District__c ,p.sub_Patch__r.Appointment_Source__c,p.sub_patch__r.OFS_Start_Date__c,p.sub_Patch__r.OFS_Bucket_Name__c, p.Sub_Patch__r.District__r.NA_Online__c
                                               FROM Postcode_Sector__c p
                                               WHERE name = :post_code_sector
                                               AND type__c = :visit_type];
                                               
        string ofsBuckname;
        if(post_code_info.size()>0){
           ofsBuckname = post_code_info[0].sub_Patch__r.OFS_Bucket_Name__c;
        }
        //Change By Ashok G
        
        if(!app_id.StartsWith(keyPrefix)){
               //string GetTimeSlot = apptId.subString(apptId.length()-2,apptId.length());
               //Date GetDate = Date.valueof(apptId.subString(apptId.length()-12,apptId.length()-2));
               
               TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(prodInterest);
               Map<string, SalesAppointment__c> mcs = SalesAppointment__c.getAll();
                               
                integer year =  integer.valueof(app_id.substring(14,18));
                integer month = integer.valueof(app_id.substring(12,14));
                integer day = integer.valueof(app_id.substring(10,12));
                string GetTimeslot= app_id.substring(08,10);
                system.debug(year);
                system.debug(month);
                system.debug(day);
                system.debug(GetTimeslot);
                SalesAppointment__c s = SalesAppointment__c.getInstance(GetTimeslot);
                
                datetime slotStartTime = datetime.newInstance(year, month, day, integer.valueof(s.Start_Time__c.split(':')[0]), integer.valueof(s.Start_Time__c.split(':')[1]), 0);
                datetime slotEndTime = datetime.newInstance(year, month, day, integer.valueof(s.End_Time__c.split(':')[0]), integer.valueof(s.End_Time__c.split(':')[1]), 0);
                datetime SLAStartTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_Start__c.split(':')[0]), integer.valueof(s.SLA_Start__c.split(':')[1]), 0);
                datetime SLAEndTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_End__c.split(':')[0]), integer.valueof(s.SLA_End__c.split(':')[1]), 0);
                    
                system.debug('start_Date-->'+slotStartTime);
                system.debug('End_Date-->'+slotEndTime);
               
               Appointment__c newAppt = new Appointment__c();
               newAppt.Assigned_To__c = ofsBuckname;
               newAppt.Opportunity__c = chi_lead_id;
               newAppt.Who__c = chi_acc.Primary_Contact__c;
               newAppt.Status__c = 'Appointed';
               newAppt.start__c = slotStartTime;
               newAppt.End__c = SLAEndTime;
               newAppt.Show_Time_As__c = 'Busy';
               newAppt.Visit_Type__c = 'First Visit';
               newAppt.RecordTypeId = available_rt_id;
               newAppt.SLA_Start__c = SLAStartTime;
               newAppt.SLA_End__c = SLAEndTime;
               if(toaPI!=null)
               newAppt.TOA_Duration__c = toaPI.Duration__c;
               
               newAppt.Time_Band__c = GetTimeSlot;
               newAppt.OFS_Appointment__c = true;
               system.debug('%%%%%%%%%%^^^'+newAppt);
               
               try{
                insert newAppt;
               
                app_booked = true;
                ApptOFS = true;
                result.Error.Message = ''; // overwrite any previous error messages as we have success now
                //result.AppId = newAppt.id;
                result.AppStart = newAppt.start__c;
                result.AppEnd = newAppt.End__c;
                }catch (exception e) {
                    
                    system.debug('App booking failed, writing error msg'); 
                    
                    result.Error.Code = 4;
                    result.Error.Message = 'ERROR: Desired appointment update failed, ID ' + app_id;
                    system.debug(result.Error.Message);
                }
        } //End
        else{
        
        // WHILE app_booked etc......
        while (false == app_booked
               &&
               false == booking_fail) {
            
            system.debug('Trying to get requested app to book....');
            
            apps.clear();
            
            apps = [SELECT id, Opportunity__c, Who__c, Visit_Type__c, Type__c, Show_Time_As__c, Status__c, RecordTypeId, Assigned_To__c, Start__c, End__c
                    FROM Appointment__c
                    WHERE Id = :app_id
                    AND Show_Time_As__c = 'Out of Office'
                    AND Status__c = 'New'
                    AND Type__c = 'Sales'];
            
            if (apps.size() > 0) { // have the app and it is still valid to be booked
                
                system.debug('App retrieved');
                
                apps[0].Opportunity__c = chi_lead_id;                                                     
                apps[0].Who__c = chi_acc.Primary_Contact__c;
                apps[0].Visit_Type__c = 'First Visit';
                apps[0].Show_Time_As__c = 'Busy';
                apps[0].Status__c = 'Appointed';
                apps[0].RecordTypeId = available_rt_id;
                
                system.debug('Trying to book app....');
                
                
                try {
                    
                    system.debug('Trying to book app....');
                    
                    update apps[0];
                    app_booked = true;
                    result.Error.Message = ''; // overwrite any previous error messages as we have success now
                    
                    result.AppEnd   = apps[0].End__c;
                    result.AppStart = apps[0].Start__c;
                    
                    system.debug('App booked, success flag raised'); 
                }
                catch (exception e) {
                    
                    system.debug('App booking failed, writing error msg'); 
                    
                    result.Error.Code = 4;
                    result.Error.Message = 'ERROR: Desired appointment update failed, ID ' + app_id;
                    system.debug(result.Error.Message);
                }
            
            }
            else { // okay, someone has booked before we could, or is deleted, so....
                
                system.debug('App NOT retrieved, no longer available');
                system.debug('Get the booked app to get alt app critria...');
                
            
                // pull up originally requested app to get timings to search for
                apps = [SELECT Start__c, End__c
                        FROM Appointment__c
                        WHERE Id = :app_id];
                    
                    
                
                
                webservice_CHI_Online.cGetAppointmentsReply alt_apps = new webservice_CHI_Online.cGetAppointmentsReply();
                
                if (apps.size() > 0) {
                    
                    system.debug('Got booked app');
                    system.debug('Searching for new apps on old app criteria....');
                    
                    // if it is an Anytime app, amend the search datetimes to be the whole day
                    if (IsAnytime) {
                        
                        system.debug('Setting for anytime search....');
                        
                        datetime temp_datetime = apps[0].Start__c;
                        temp_datetime = datetime.newInstance(temp_datetime.year(), 
                                                              temp_datetime.month(), 
                                                              temp_datetime.day(), 
                                                              1,
                                                              0, 
                                                              0);
                                                                      
                        apps[0].Start__c = temp_datetime;
                            
                        temp_datetime = datetime.newInstance(temp_datetime.year(), 
                                                              temp_datetime.month(), 
                                                              temp_datetime.day(), 
                                                              23,
                                                              0, 
                                                              0);
                                                              
                        apps[0].End__c = temp_datetime;
                        
                    }
                    
                    system.debug('Search start time: ' + apps[0].Start__c);
                    system.debug('Search end time: ' + apps[0].End__c);
                    
                    system.debug('Searching for new apps on old app criteria....');
                    
                    WebAvailability app_search = new WebAvailability(chi_lead_id,
                                                                         apps[0].Start__c,
                                                                         apps[0].End__c);
                                                                         
                    alt_apps = app_search.fGetAvailability();
                    
                }
                else {
                
                    system.debug('Booked app has been deleted');
                    
                    system.debug('App booking failed'); 
                                
                    result.Error.Code = 5;
                    result.Error.Message = 'ERROR: Initial desired appointment ' + app_id + ' could not be found, unable to continue';
                    system.debug(result.Error.Message);
                }
                    
                // are there any equivalent apps to the one the customer requested?
                if (alt_apps.AppointmentSlots.size() > 0) {
                    
                    system.debug('Alt app found in new search, attempting to retrieve details....');
                    
                    // now get the alternae app found in the search just now
                    apps = [SELECT id, Opportunity__c, Who__c, Visit_Type__c, Type__c, Show_Time_As__c, Status__c, RecordTypeId, Assigned_To__c, Start__c, End__c
                            FROM Appointment__c
                            WHERE Id = :alt_apps.AppointmentSlots[0].AppId
                            AND Show_Time_As__c = 'Out of Office'
                            AND Status__c = 'New'
                            AND Type__c = 'Sales'];
                    
                    if (apps.size() > 0) {
                        
                        system.debug('Alt app details retrieved, attempting to book it....');
                        
                        apps[0].Opportunity__c  = chi_lead_id;                                                     
                        apps[0].Who__c          = chi_acc.Primary_Contact__c;
                        apps[0].Visit_Type__c   = 'First Visit';
                        apps[0].Show_Time_As__c = 'Busy';
                        apps[0].Status__c       = 'Appointed';
                        apps[0].RecordTypeId    = available_rt_id; 
                        
                        try {
                            
                            system.debug('Trying to book alternative app....');
                        
                            update apps[0];
                            app_booked = true;
                            result.Error.Message = ''; // overwrite any previous error messages as we have success now
                            
                            result.AppEnd   = apps[0].End__c;
                            result.AppStart = apps[0].Start__c;
                    
                            system.debug('App booked, success flag raised'); 
                        }
                        catch (exception e) {
                            
                            system.debug('App booking failed, writing error msg'); 
                            
                            result.Error.Code = 6;
                            result.Error.Message = 'ERROR: Desired appointment update failed, ID ' + app_id;
                            system.debug(result.Error.Message);
                        }
                   
                        
                    }
                    else {
                    
                        system.debug('Could not retrieve alt app after search');
                            
                        // didn't work as someone else was booking at the same time, so return error
                        result.Error.Code = 7;
                        result.Error.Message = 'ERROR: Could not retrieve alternative appointment after search';
                        system.debug(result.Error.Message); 
                    }
                        
                        
                        
                }   
                else { // no equivalent apps available
                    
                    result.Error.Code = 8;
                    result.Error.Message = 'ERROR: No equivalent apps, booking failed';
                    system.debug(result.Error.Message); 
                    booking_fail = true;
                }
            }
           
        
            if (!app_booked) // no successful booking, increment the counter
                attempt_counter++;
        
            if (5 <= attempt_counter) { // if no successful booking after 5 attempts, fail gracefully
                
                booking_fail = true;
                system.debug('5th attempt reached, booking failed');
            }
        }
        }
        if (app_booked) { // if the app has ben successfuly booked
           string Assigned_To;
            // now populate the data to return
            try {
                if(ApptOFS){
                 Assigned_To = ofsBuckname;
                }else{
                 Assigned_To = apps[0].Assigned_To__c;
                }
                Employee__c hsa = [SELECT First_Name__c, Last_Name__c, Employee_Record_ID__c, Region__c 
                                   FROM Employee__c
                                   WHERE Employee__c.Id = :Assigned_To];
                
                result.Error.Code       = 0;
                result.PicIdentifier    = chi_acc.Sales_Subpatch__r.Name;//hsa.Employee_Record_ID__c;
                result.Region           = hsa.Region__c;
            }
            catch (exception e) {
                
                // do nothing, just leave HSA details as "unavailable"
                result.Error.Code = 0;
                result.Error.Message = 'WARNING: HSA details unavailable, ID ' + apps[0].Assigned_To__c;
                system.debug(result.Error.Message);
                
                result.PicIdentifier    = 'Information currently not available';
                result.Region           = 'Information currently not available';
            }
            
            try {
                
                chi_lead.Enquiry_Type__c = 'Sales Appointment';
                
                if (CHIMarketingInterest) 
                    chi_lead.Product_Interest__c = 'All';
                else
                    chi_lead.Product_Interest__c = 'None'; 
                
                chi_lead.ES_Product_Interest__c = ESProductInterest;
                
                update chi_lead;
                result.Error.Message = ''; // overwrite any previous error messages as we have success now
            }
            catch(Exception e) {
                
                result.Error.Code = 0;
                result.Error.Message = 'WARNING: Unable to update CHI Lead, ID ' + chi_lead.Id;
                system.debug(result.Error.Message);
                
                return result;      
            }
        }
        
        return result;   
    }
    
}