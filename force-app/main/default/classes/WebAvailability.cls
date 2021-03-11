public class WebAvailability {
    
    private class cEmpAvail {
            
        id              empId           = null;
        List<datetime>  shift_starts    = new List<datetime>();
        List<datetime>  shift_ends      = new List<datetime>();
        
    }
    
    Opportunity chi_lead = null;
    
    string post_code            = null;
    string post_code_sub_patch  = null;
    string post_code_district   = null;
    
    string chi_lead_id  = null;
    string visit_type   = null;
    
    datetime    earliest    = null;
    datetime    latest      = null;
    
    // constructor
    public WebAvailability(id           ChiLeadId,
                           datetime     EarliestDateTime,
                           datetime     LatestDateTime) {
    
        
        
        chi_lead_id = ChiLeadId;
        earliest    = EarliestDateTime;
        latest      = LatestDateTime;
        /*
        system.debug('CHI Lead ID = ' + chi_lead_id);
        system.debug('Earliest = ' + earliest.format());
        system.debug('Latest = ' + latest.format());*/
    } 
    
    public webservice_CHI_Online.cGetAppointmentsReply fGetAvailability() {
        datetime process_start_time = system.now();
        datetime process_end_time ;
        integer appsres = 0;
        
        try{
        
        
        
        webservice_CHI_Online.cGetAppointmentsReply result = new webservice_CHI_Online.cGetAppointmentsReply();
        
        result.ChiLeadId = chi_lead_id;
        
        try {
            
            chi_lead = [SELECT AccountID, Account.BillingPostalCode, Visit_Type__c, WebAvailSearchStatement__c 
                        FROM Opportunity  
                        WHERE Id = :chi_lead_id];
                        
            visit_type  = chi_lead.Visit_Type__c;
            system.debug('Visit type = ' + visit_type);
        
            post_code   = chi_lead.Account.BillingPostalCode;
            system.debug('Postcode = ' + post_code);
        }
        catch (exception e) {
            
            result.Error.Code = 2;
            result.Error.Message = 'ERROR: No CHI Lead info found with ID ' + chi_lead_id;
            system.debug(result.Error.Message);
            
            return result;      
        }
        
        // check there are no existing sales appointments for this customer
        Appointment__c[] relatedApps = [SELECT Id, Type__c, Status__c 
                                        FROM Appointment__c 
                                        WHERE Opportunity__c = :chi_lead_id
                                        AND Start__c >= :Datetime.now()
                                        AND Type__c = 'Sales'
                                        AND Status__c = 'Appointed'];
                                        
        System.debug('Number of related appointments: ' + relatedApps.size());
        
        if (relatedApps.size() > 0) { // already appointment booked, don't let book another
            result.Error.Code = 3;
            result.Error.Message = 'ERROR: ' + relatedApps.size() + ' Sales appointment(s) already booked for CHI Lead ' + chi_lead_id;
            system.debug(result.Error.Message);
            
            return result;          
        } 
 
        //Calculate postcode sector of the postcode by taking off the last 2 characters
        string post_code_sector = chi_lead.Account.BillingPostalCode.substring(0,chi_lead.Account.BillingPostalCode.length()-2);
        system.debug('Postcode sector = ' + post_code_sector);                
        
        //This select gets the sub-patch and district for the post code sector, of the same type as the CHI Lead (sales/survey)                               
        Postcode_Sector__c[] post_code_info = [SELECT p.name,p.Sub_Patch__c, p.Sub_Patch__r.District__c ,p.sub_Patch__r.Appointment_Source__c,p.sub_patch__r.OFS_Start_Date__c,p.sub_Patch__r.OFS_Bucket_Name__c, p.Sub_Patch__r.District__r.NA_Online__c
                                               FROM Postcode_Sector__c p
                                               WHERE name = :post_code_sector
                                               AND type__c = :visit_type];
                                                
        // no postcode? exit
        if(post_code_info.size() == 0) {
            
            result.Error.Code = 1;
            result.Error.Message = 'ERROR: No post code info found where Postcode Sector is: ' + post_code_sector;
            system.debug(result.Error.Message);
            
            return result;  
        }
        else{
        post_code_sub_patch = post_code_info[0].Sub_Patch__c;
        system.debug('Postcode subpatch = ' + post_code_sub_patch);
        
        post_code_district  = post_code_info[0].Sub_Patch__r.District__c;
        system.debug('Postcode district = ' + post_code_district);             
        
        //Change By Ashok G
        Date OFS_start_Date = post_code_info[0].sub_patch__r.OFS_Start_Date__c;
        system.debug('Postcode OFS Trial Date = '+ OFS_start_Date);
        
        if(post_code_info[0].Sub_Patch__r.Appointment_Source__c == 'OFS' && OFS_Start_Date != null && earliest < OFS_Start_Date  && latest > OFS_Start_Date)
         {
                  /*************** Code when OFS Start Date is in middle of Latest and earliest ******************/
                  /**************** Both OFS & SFDC************************************************/
          list<webservice_CHI_Online.cGetAppointmentsReply> reply = new list<webservice_CHI_Online.cGetAppointmentsReply>();
          list<webservice_CHI_Online.cAppointment> appList = new list<webservice_CHI_Online.cAppointment>();
          
          datetime ofsStartDate = datetime.newInstance(OFS_start_Date.year(),OFS_start_Date.month(),OFS_start_Date.day(),0,0,0);      
          //need to work on logic
          
          
          reply.add(callSalesforce(post_code_info[0],null,process_start_time,process_end_time,appsres,earliest,ofsStartDate));
          
          reply.add(callOFS(post_code_info[0],null,process_start_time,process_end_time,appsres,OFS_Start_Date,latest));
          
          
          
          if(reply.size()>0){
              for(webservice_CHI_Online.cGetAppointmentsReply res: reply){
                for(webservice_CHI_Online.cAppointment app : res.AppointmentSlots){
                  appList.add(app);
                 }
                 if(res.Error.message != NULL){
                   result.Error = res.Error; //over rides the Error
                 } 
              }
              
          }
          
          result.AppointmentSlots = appList;
          if(result.AppointmentSlots.size() == 0)
          {
                result.Error.Code = 6;
                result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info[0].Name;
                system.debug(result.Error.Message);
                return result;
          }else
          {
          	return result;
          }            
                  
         }else if(OFS_Start_Date != null && latest >=OFS_Start_Date  && post_code_info[0].Sub_Patch__r.Appointment_Source__c == 'OFS')
         { 
              
              /*****************ONLY IN OFS********************/
              system.debug('******************I am INside ');
              
              result = callOFS(post_code_info[0],null,process_start_time,process_end_time,appsres,latest,earliest);
              return result;                   
         }   
         else{
           /*****************ONLY IN SALESFORCE********************/
               result = callSalesforce(post_code_info[0],null,process_start_time,process_end_time,appsres,latest,earliest);
               return result;
            }
          }  
           
        
        }
        catch (Exception e){
            process_end_time = system.now();
            return null;
        }
    }
    
     public webservice_CHI_Online.cGetAppointmentsReply callOFS(Postcode_Sector__c post_code_info, string BoilerOp, datetime process_start_time, datetime process_end_time , integer appsres, datetime latest , datetime earliest)
    {
           webservice_CHI_Online.cGetAppointmentsReply result = new webservice_CHI_Online.cGetAppointmentsReply();
            string BucketName = post_code_info.Sub_Patch__r.OFS_Bucket_Name__c;
           //string BktName = BucketName.substring(0,BucketName.length()-13);
           
           Map<string, SalesAppointment__c> mcs = SalesAppointment__c.getAll();
           
          //Send OFS API Request
           list<string> location = new list<string>{BucketName};
           date ofsStartDate;
           date ofsEndDate;
           List<Date> appointmentWindow = new list<Date>();
           if(latest<earliest)
           {
            ofsStartDate  = latest.date();
            ofsEndDate = earliest.date();
           }else
           {
               ofsStartDate  = earliest.date();
               ofsEndDate = latest.date();
           }
           system.debug('******************ofsStartDate'+ofsStartDate+' '+ofsEndDate);
           while(ofsStartDate<=ofsEndDate)
           {
              appointmentWindow.add(ofsStartDate);
              ofsStartDate = ofsStartDate.adddays(1);
           }
           if(appointmentWindow.size()>0)
           {
           toaCapacity.capacity_response_element response  = getCapacityRes.getCapacity(location, appointmentWindow, post_code_info.Name,post_code,'Central Heating Boiler');
           //system.debug('&&&&&&&&&&&Response'+Response.capacity);
           //system.debug('&&&&&&&&&&&window'+appointmentWindow);
           //system.debug('***********'+response.capacity.size());
           
     	 
     	  if(response!=null)
     	  {
     	  TOA_Product_Interest__c tp = TOA_Product_Interest__c.getInstance('Central Heating Boiler');
     	  integer minAvailable = integer.valueof(response.activity_travel_time)+integer.valueof(tp.Duration__c);
     	  
           for(toaCapacity.capacity_element cap : response.capacity){
           		
	            if(cap.available >= minAvailable && cap.time_slot!= 'AT')
	            {
	               //system.debug('-------------');
	               dateTime now = system.now();
	               datetime slotStartTime = datetime.newInstance(cap.date_x.year(), cap.date_x.month(), cap.date_x.day(), integer.valueof(mcs.get(cap.time_slot).Start_Time__c.split(':')[0]), integer.valueof(mcs.get(cap.time_slot).Start_Time__c.split(':')[1]), 0);
	               
	               if(now < slotStartTime){
	                    
	                        datetime slotEndTime = datetime.newInstance(cap.date_x.year(), cap.date_x.month(), cap.date_x.day(), integer.valueof(mcs.get( cap.time_slot).End_Time__c.split(':')[0]), integer.valueof(mcs.get(cap.time_slot).End_Time__c.split(':')[1]), 0);
	                         
	                        if(BoilerOp == 'No' && cap.time_slot == 'AT'){
	                                continue;
	                         
	                        }
	                        webservice_CHI_Online.cAppointment app_at_to_add = new webservice_CHI_Online.cAppointment();
	                        app_at_to_add.AppId     = BucketName.substring(0,BucketName.length()-(cap.time_slot+'XXXXXXXX').length())+cap.time_slot+ correctData(cap.date_x.day())+correctData(cap.date_x.month())+string.valueof(cap.date_x.year()); 
	                        system.debug('%%%%%%%%'+app_at_to_add.AppId);
	                        app_at_to_add.AppStart  = slotStartTime;
	                        app_at_to_add.AppEnd    = slotEndTime;
	                        result.AppointmentSlots.add(app_at_to_add);
	                  }
	           }
            }   
     	  }          
           if(result.AppointmentSlots.size() == 0)
           {
                result.Error.Code = 6;
                result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.Name;
                system.debug(result.Error.Message);
                return result;
           }else if(result.AppointmentSlots.size()>0)
            {
                result.AppointmentSlots = fBubbleSortApps(result.AppointmentSlots);
                appsres = result.AppointmentSlots.size();
                system.debug('Appointment size after Geo--->'+result.AppointmentSlots.size()+' Last Slot time'+result.AppointmentSlots[result.AppointmentSlots.size()-1].AppStart);
            }
 
          
           } 
           system.debug('Appointments Returned--->'+result);
         return result;
    }
   
   public string correctData(integer i)
    {
        string s = string.valueof(i);
        
        return(s.length() == 1 ? '0'+s:s);
    }    
    
    
   public  webservice_CHI_Online.cGetAppointmentsReply callSalesforce(Postcode_Sector__c post_code_info, string BoilerOp, datetime process_start_time, datetime process_end_time , integer appsres, datetime latest , datetime earliest)
   {
        webservice_CHI_Online.cGetAppointmentsReply result = new webservice_CHI_Online.cGetAppointmentsReply();
        List<cEmpAvail> emps_avail = new List<cEmpAvail>();
        list <String> visit_type = new list<String>();
        visit_type.add('Sales');
              
           if(BoilerOp!=null && BoilerOp == 'No')
           {
               visit_type.add('Priority');
           }
        
        List<Role_Sub_Patch__c> rle_sub_patches = [SELECT r.Role__r.Employee__c, r.start_date__c,r.end_date__c 
                                                FROM Role_Sub_Patch__c r
                                                WHERE sub_patch__c = :post_code_sub_patch
                                                AND Type__c = 'Availability'      
                                                AND start_date__c <= :latest.date() 
                                                AND end_date__c >= :earliest.date()
                                                ORDER BY r.Role__r.Employee__c];
        
        
         if(rle_sub_patches.size()==0 )//&& rle_Districts.size()==0)
          {
              result.Error.Code = 6;
              result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.Name;
              system.debug(result.Error.Message);
              return result;
          }
          else
          {
            for (integer patch_counter = 1; patch_counter <= rle_sub_patches.size(); patch_counter++) {
            
                // stop duff dates coming through
                // CHANGE REQUEST: CHG00008187 - '>' to '>=' such that single day Role Sub Patches are not filtered out
                if (rle_sub_patches[patch_counter-1].end_date__c >= rle_sub_patches[patch_counter-1].start_date__c) {
                    
                    boolean have_emp = false;
                    integer emp_idx  = -1;
                     
                    //check if have employee already
                    for (integer emp_counter = 1; emp_counter <= emps_avail.size(); emp_counter++) {
                        
                        if (rle_sub_patches[patch_counter-1].Role__r.Employee__c == emps_avail[emp_counter-1].empId) {
                            have_emp = true;
                            emp_idx  = emp_counter - 1;
                        }
                    }
                    
                    if (have_emp) {
                        
                        system.debug('Emp found, index ' + emp_idx);
                       
                        emps_avail[emp_idx].shift_ends.add(rle_sub_patches[patch_counter-1].end_date__c);
                        emps_avail[emp_idx].shift_starts.add(rle_sub_patches[patch_counter-1].start_date__c);   
                    }
                    else {
                        
                        system.debug('Emp not found, create new Emp record');
                         system.debug(rle_sub_patches);
                        cEmpAvail blank_rec = new cEmpAvail();
                        emps_avail.add(blank_rec);
                        emps_avail[emps_avail.size()-1].EmpId = rle_sub_patches[patch_counter-1].Role__r.Employee__c;
                        
                        emps_avail[emps_avail.size()-1].shift_ends.add(rle_sub_patches[patch_counter-1].end_date__c);
                        emps_avail[emps_avail.size()-1].shift_starts.add(rle_sub_patches[patch_counter-1].start_date__c);       
                    }
                    
                }
                else {
                    
                    system.debug('Bad data: Sub patch start date, ' + rle_sub_patches[patch_counter-1].start_date__c +  ', equal to or after end date ' + rle_sub_patches[patch_counter-1].end_date__c);    
                }   
                
            }
       
        
        
        integer emp_no = 1;
        
        system.debug('emps_avail.Size() =' + emps_avail.Size()); 
        
        integer max_statements = Limits.getLimitCpuTime();
        integer state_num = 0;
        integer max_state = integer.valueOf(system.label.CHIOnlineAvailMaxStatement);       
        string OnlineFilterApp =  system.label.CHIOnlineAvailAppFilter;
        while (emp_no <= emps_avail.Size()
               &&
               state_num < max_state ) { // CHANGE REQUEST: CHG00008187 - bubble sort, filter and query below are "statement-heavy", so cut off  
                                     // at 9k here to prevent governor limit overload later
            
            
            // DO NOT CHANGE THIS QUERY, IT HAS BEEN OPTIMISED BY SALESFORCE TO WORK AROUND BUGS IN THEIR SYSTEM
            // AND ANY ALTERATION WILL RESULT IN MASSIVELY DEGRADED OPERATION OF THE QUERY E.G. 15 SECS RATHER 
            // THAN ~1 SEC TO RETURN RECORDS
            List<Appointment__c> apps = [SELECT Id, Start__c, End__c, Assigned_To__c, Start_Time__c, Type__c, Valid_Slot__c 
                                       FROM Appointment__c
                                       WHERE Assigned_To__c = :emps_avail[emp_no-1].EmpId
                                       AND Start__c >= :earliest
                                       AND End__c >= :earliest
                                       AND End__c <= :latest
                                       AND Type__c = :visit_type
                                       AND Show_Time_As__c = 'Out of Office'
                                       AND IsDeleted = False
                                       ORDER BY Start__c ASC
                                       LIMIT 1500];
            
            for (integer app_counter = 1; app_counter <= apps.size(); app_counter++) {
        
                // check if the employee has role availability set which covers the date of the appointment  
                date app_date = date.newInstance(apps[app_counter-1].Start__c.Year(), apps[app_counter-1].Start__c.Month(), apps[app_counter-1].Start__c.Day());
                
                datetime temp_start = apps[app_counter-1].Start__c;
                datetime temp_end   = apps[app_counter-1].End__c;
                string visit_type1   = apps[app_counter-1].Type__c;
                
                boolean is_available = false;
        
                // now check shifts
                integer shift_counter = 1;
                
                while (shift_counter <= emps_avail[emp_no-1].shift_starts.size()
                       &&
                       false == is_available) {
                    
                    
                    if(temp_start >= earliest
                       &&
                       emps_avail[emp_no-1].shift_starts[shift_counter-1] <= app_date 
                       && 
                       emps_avail[emp_no-1].shift_ends[shift_counter-1] >= app_date) {  
                       
                        // it is available 
                        is_available = true;
                        system.debug('Appointment ' + apps[app_counter-1].Id + ' matched to shift/employee');
                        
                        // ------ COMMENTED DATE:- 4/12/2011
                        //DESC:- TO REMOVE DATETIME ISSUE BETWEEN CHI ONLINE AND SFDC
                        /*datetime app_start = Datetime.newInstance(apps[app_counter-1].Start__c.Year(), 
                                                                 apps[app_counter-1].Start__c.Month(), 
                                                                 apps[app_counter-1].Start__c.Day(),
                                                                 apps[app_counter-1].Start__c.hour(),
                                                                 apps[app_counter-1].Start__c.Minute(),
                                                                 apps[app_counter-1].Start__c.Second());
                        
                        datetime app_end = Datetime.newInstance(apps[app_counter-1].End__c.Year(), 
                                                                 apps[app_counter-1].End__c.Month(), 
                                                                 apps[app_counter-1].End__c.Day(),
                                                                 apps[app_counter-1].End__c.hour(),
                                                                 apps[app_counter-1].End__c.Minute(),
                                                                 apps[app_counter-1].End__c.Second());
                        */
                      datetime app_start = apps[app_counter-1].Start__c;
                      datetime app_end = apps[app_counter-1].End__c;
                      boolean app_valid = false;
                      if (OnlineFilterApp=='Yes' ) {

                        //--------------------------------
                        integer duration_mins = ((app_end.hour() - app_start.hour()) * 60) + (app_end.minute() - app_start.minute());
                        
                      
                        
                        // filter apps
                        // firstly 2 hour slots beginning at 7am, 9am, 11am
                        if ( duration_mins == 120
                             &&
                             (temp_start.hour() == 7 || temp_start.hour() == 9 || temp_start.hour() == 11) 
                             &&
                             temp_start.minute() == 0) {
                       
                            app_valid = true;       
                        }
                        else if (duration_mins == 120 // 2hour 3.30pm slot
                                 &&
                                 temp_start.hour() == 15
                                 &&
                                 temp_start.minute() == 30) {
                            
                            app_valid = true;
                        }
                        else if (duration_mins == 150 // 2.5 hour 1pm slot
                                 &&
                                 temp_start.hour() == 13
                                 &&
                                 temp_start.minute() == 0) {
                        
                            app_valid = true;   
                        }
                        else if (duration_mins == 90 // 1.5 hour 5.30pm slot
                                 &&
                                 temp_start.hour() == 17
                                 &&
                                 temp_start.minute() == 30) {
                        
                            app_valid = true;   
                        }
                        else if (duration_mins == 90 // 1.5 hour 7pm slot
                                 &&
                                 temp_start.hour() == 19
                                 &&
                                 temp_start.minute() == 0) {
                            
                            app_valid = true;
                        } 
                        else if (duration_mins == 90 // 1.5 hour 8.30pm slot
                                 &&
                                 temp_start.hour() == 20
                                 &&
                                 temp_start.minute() == 30) {
                            
                            app_valid = true;
                        } 
                      }else if ( apps[app_counter-1].Valid_Slot__c =='Yes') {
                            app_valid = true;
                      }
                        
                        if (app_valid) {
                        
                            webservice_CHI_Online.cAppointment app_at_to_add = new webservice_CHI_Online.cAppointment();
                        
                            app_at_to_add.AppId     = apps[app_counter-1].Id;
                            
                            // ------ COMMENTED DATE:- 4/12/2011
                            //DESC:- TO REMOVE DATETIME ISSUE BETWEEN CHI ONLINE AND SFDC
                            //app_at_to_add.AppStart  = datetime.newInstanceGmt(app_start.date(), app_start.time());
                            //app_at_to_add.AppEnd    = datetime.newInstanceGmt(app_end.date(), app_end.time());
                            
                            app_at_to_add.AppStart  = app_start;
                            app_at_to_add.AppEnd    = app_end;
                            //----------------------------
                            
                            result.AppointmentSlots.add(app_at_to_add); 
                            
                            
                            system.debug('Appointment from ' + app_start + ' to ' + app_end );
                            system.debug('Appointment SF ID = ' + apps[app_counter-1].Id);
                            system.debug('Appointment STORED'); 
                        }
                        
                    }
                    
                    shift_counter++;
                }
                
            }   
            
            emp_no++;
            
            state_num = Limits.getCpuTime();
            system.debug('Statements executed = ' +  state_num + ' out of ' + max_statements);      
        }
        
        // change to update num of statements executed to find the availabilities
        chi_lead.WebAvailSearchStatement__c = state_num;
        //update chi_lead;
        
        system.debug('Number of unfiltered/unsorted apps: ' + result.AppointmentSlots.size());
        
        result.AppointmentSlots = fBubbleSortApps(result.AppointmentSlots);
        result.AppointmentSlots = fRemoveDupApps(result.AppointmentSlots);
        appsres = result.AppointmentSlots.size();
        state_num = Limits.getScriptStatements();
        system.debug('Statements executed = ' +  state_num + ' out of ' + max_statements);
        
        system.debug('Number of unique appointments returned: ' + result.AppointmentSlots.size());
        process_end_time = system.now();
        
        
        return result;
       }
   }
    
    public webservice_CHI_Online.cAppointment[] fBubbleSortApps(webservice_CHI_Online.cAppointment[] inArray) {
        
        boolean swapped = false;
        integer max_state = integer.valueOf(system.label.CHIOnlineAvailMaxStatement);       
        // CHANGE REQUEST: CHG00008187 - 'array_size' added so 'inArray.size()' is not calced every loop using up statements
        integer array_size = inArray.size();
        
        integer max_statements = Limits.getLimitCpuTime();
        integer state_num = Limits.getCpuTime();    
       
        do {
            swapped = false;
            
            for (integer counter = 1; counter < array_size; counter++) {
                
                if (inArray[counter-1].AppStart > inArray[counter].AppStart && state_num < max_state) {
                    
                    webservice_CHI_Online.cAppointment temp_app_1 = inArray[counter-1];
                    webservice_CHI_Online.cAppointment temp_app_2 = inArray[counter];
                    
                    inArray[counter-1]  = temp_app_2;
                    inArray[counter]    = temp_app_1;
                    
                    swapped = true;
                } 
            }
            
            state_num = Limits.getCpuTime();
            system.debug('Statements executed = ' +  state_num + ' out of ' + max_statements);
           
        } while (swapped == true);
        
        system.debug('inArray = ' + inArray);
        
        return inArray;
    }
    
    private webservice_CHI_Online.cAppointment[] fRemoveDupApps(webservice_CHI_Online.cAppointment[] inArray) {
        
        // REQUIRES BUBBLE SORT TO BE PERFORMED FIRST
        
        // CHANGE REQUEST: CHG00008187 - 'array_size' added so 'inArray.size()' is not calced every loop using up statements
        integer array_size = inArray.size();
        
        integer max_statements = Limits.getLimitCpuTime();
            
        for (integer counter = 1; counter <= (array_size-1); counter++) {
            
            if (inArray[counter-1].AppStart == inArray[counter].AppStart
                &&
                inArray[counter-1].AppEnd == inArray[counter].AppEnd) { // same start/end time, remove duplicate
                    
                inArray.remove(counter); 
                array_size--;
                counter--; // if have just removed an app, decrement counter so original app is compared to new adjacent one    
            }
            
            integer state_num = Limits.getCpuTime();
            system.debug('Statements executed = ' +  state_num + ' out of ' + max_statements);  
        }
        
        return inArray;
    }
    
    public webservice_CHI_Online.cAppointment[] fRandomApps(webservice_CHI_Online.cAppointment[] inArray,set<id> secondaryAppt) {
        
        // REQUIRES BUBBLE SORT TO BE PERFORMED FIRST
        
        // CHANGE REQUEST: CHG00008187 - 'array_size' added so 'inArray.size()' is not calced every loop using up statements
        integer array_size = inArray.size();
        
        map<string, webservice_CHI_Online.cAppointment[]> timeslotMap = new map<string,webservice_CHI_Online.cAppointment[]>();
        
        integer max_statements = Limits.getLimitCpuTime();
            
        for (integer counter = 0; counter <= (array_size-1); counter++) {
            
            if(timeslotMap.containsKey(String.valueof(inArray[counter].appStart)+string.valueof(inArray[counter].appEnd)))
            {
                webservice_CHI_Online.cAppointment[] applist= timeslotMap.get(String.valueof(inArray[counter].appStart)+string.valueof(inArray[counter].appEnd));
                applist.add(inArray[counter]);
                timeslotMap.put(String.valueof(inArray[counter].appStart)+string.valueof(inArray[counter].appEnd),applist);
            }
            else
            {
               timeslotMap.put(String.valueof(inArray[counter].appStart)+string.valueof(inArray[counter].appEnd),new webservice_CHI_Online.cAppointment[]{inArray[counter]});  
            }
            
            integer state_num = Limits.getCpuTime();
            system.debug('Statements executed = ' +  state_num + ' out of ' + max_statements);  
        }
        
        inArray.clear();
        
        /*for(String key: timeslotMap.keyset())
        {
            webservice_CHI_Online.cAppointment[] tempAppList = timeslotMap.get(key);
            Integer rand = (Math.random() * tempAppList.size()).intValue();
            if(rand >= tempAppList.size())
               rand = tempAppList.size()-1;
               inArray.add(tempAppList[rand]);
        }*/
        for(String key: timeslotmap.keyset())
        {
            webservice_CHI_Online.cAppointment[] tempAppList = timeslotMap.get(key);
            webservice_CHI_Online.cAppointment[] secondarytempAppList = new webservice_CHI_Online.cAppointment[]{};
            webservice_CHI_Online.cAppointment[] primarytempAppList = new webservice_CHI_Online.cAppointment[]{};
            
            for(webservice_CHI_Online.cAppointment appt: tempAppList)
            {
              if(secondaryAppt.contains(appt.AppId))
              secondarytempAppList.add(appt);
              else
              primarytempAppList.add(appt);
            }
            
            if(!primarytempAppList.isEmpty())
            {
                 integer rand = (Math.random() * primarytempAppList.size()).intValue();
                 if(rand >= primarytempAppList.size())
                 rand = primarytempAppList.size()-1;
                 inArray.add(primarytempAppList[rand]);
            }
            else if(!secondarytempAppList.isEmpty())
            {
                 integer rand = (Math.random() * secondarytempAppList.size()).intValue();
                 if(rand >= secondarytempAppList.size())
                 rand = secondarytempAppList.size()-1;
                 inArray.add(secondarytempAppList[rand]);
            }
        }
        return inArray;
    }
    
}