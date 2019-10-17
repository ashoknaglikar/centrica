public class webGetAppointmentsByPostcode {
    
    private string post_code            = null;
    private string post_code_sub_patch  = null;
    private string post_code_district   = null;
    private string Appt_Source = null;
    private Date OFS_Start_Date;
    
    
    private map<Id, List<List<Date>>> cEmpAvailMap = new map<Id, List<List<Date>>>();
    
    WebAvailability objWeb  = new WebAvailability(null, null, null);
    

    public webservice_CHI_Online.GetAppointmentsByPostcodeResponse getAppointmentsByPostcodeFunc(webservice_CHI_Online.GetAppointmentsByPostcode objGetAppointmentsByPostcode)
    { 
        system.debug(objGetAppointmentsByPostcode);
        datetime process_start_time = system.now();
        datetime process_end_time ;
        integer appsres = 0;
        webservice_CHI_Online.GetAppointmentsByPostcodeResponse result= new  webservice_CHI_Online.GetAppointmentsByPostcodeResponse();
        
      try{
          
          system.debug('Postcode--->'+objGetAppointmentsByPostcode.Address.PostCode);
          if(objGetAppointmentsByPostcode.Address.PostCode!='' && objGetAppointmentsByPostcode.Address.PostCode!= null)
          {
              
              // Guided Sale Changes	
             if(objGetAppointmentsByPostcode.CHILeadChannel==null) 
             objGetAppointmentsByPostcode.CHILeadChannel = 'Central Heating Boiler';		
             if(objGetAppointmentsByPostcode.ProductInterest!=null)		
             objGetAppointmentsByPostcode.CHILeadChannel = objGetAppointmentsByPostcode.productInterest;
             //end
             
             post_code = objGetAppointmentsByPostcode.Address.PostCode;
             string post_code_sector = post_code.substring(0,post_code.length()-2);
              
              
              Datetime latest = system.today().adddays(1);
              DateTime earliest = system.today().adddays(integer.valueof(system.label.OnlineQueryingWindow));
              earliest = earliest.date().toStartOfWeek().adddays(7);
              
              if(objGetAppointmentsByPostcode.GetAppointmentDate.BracketStart!=null )
              {
                latest = objGetAppointmentsByPostcode.GetAppointmentDate.BracketStart;
              }
              if(objGetAppointmentsByPostcode.GetAppointmentDate.BracketEnd!=null )
              {
                earliest = objGetAppointmentsByPostcode.GetAppointmentDate.BracketEnd;
              }   
              system.debug('latest--- >'+latest);
              system.debug('earliest--- >'+earliest);
              
              /*
                Added logic to cater to customer category if information exists
              */
              
              category_Indicator__c[] category = [Select id, Category__c from category_Indicator__c where Heating__c = :objGetAppointmentsByPostcode.BoilerOp
                                                                                             and Hot_Water__c = :objGetAppointmentsByPostcode.HotWaterOp
                                                                                             and Other_Heat__c = :objGetAppointmentsByPostcode.OtherHeatingOp
                                                                                             and Vunerable__c = :objGetAppointmentsByPostcode.Vulnerable
                                                                                             and Reason__c = :objGetAppointmentsByPostcode.VulnerableReason
                                                                                             and Sub_Reason__c = : objGetAppointmentsByPostcode.vulnerableSubReason
                                                                                             and Customer_Category_Logic__c = '1'];
                                                                                             
             integer customerCategory = 99;
             if(category!=null && category.size()>0)
             {
                 customerCategory = integer.valueof(category[0].Category__c);
             }
             system.debug('-->'+customerCategory);
              
               //This select gets the sub-patch and district for the post code sector, of the same type as the CHI Lead (sales/survey)                               
              Postcode_Sector__c[] post_code_info = [SELECT Name, p.Sub_Patch__c, p.Sub_Patch__r.District__c ,p.sub_Patch__r.Appointment_Source__c,p.sub_patch__r.OFS_Start_Date__c,p.sub_Patch__r.OFS_Bucket_Name__c, p.Sub_Patch__r.District__r.NA_Online__c
                                                     FROM Postcode_Sector__c p
                                                     WHERE name = :post_code_sector
                                                     AND type__c = :'Sales'];
                                                     
                                                      
              // no postcode? exit
              if(post_code_info.size() == 0) {
                  
                  result.Error.Code = 5;
                  result.Error.Message = 'ERROR: Postcode sector not found. ' + post_code_sector;
                  system.debug(result.Error.Message);
                  Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
                  //insert o;
                  return result;  
              }else if(post_code_info[0].Sub_Patch__r.District__r.NA_Online__c)
              {
                  result.Error.Code = 6;
                  result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_sector;
                  system.debug('This District id not availalble for online booking.');
                  system.debug(result.Error.Message);
                  //Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
                  //insert o;
                  return result;
                  
              }else
              {
                   post_code_sub_patch = post_code_info[0].Sub_Patch__c;
                   post_code_district = post_code_info[0].Sub_Patch__r.District__c;
                  
                   //Change By Ashok G
                   Appt_Source = post_code_info[0].sub_Patch__r.Appointment_Source__c;
                   OFS_Start_Date = post_code_info[0].sub_Patch__r.OFS_Start_Date__c;
                
                //Guided Sale Changes   
                if(objGetAppointmentsByPostcode.CHILeadChannel != null  && Remote_Quote_Product__c.getInstance(objGetAppointmentsByPostcode.CHILeadChannel) !=null)
                {
                   result = callSalesforce(post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  latest , earliest, objGetAppointmentsByPostcode.CHILeadChannel);
                   return result;
                }
                //end

                if(objGetAppointmentsByPostcode.CHILeadChannel != null  && objGetAppointmentsByPostcode.CHILeadChannel == 'Straight Swap')
                {
                  result = callSalesforce(post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  latest , earliest, objGetAppointmentsByPostcode.CHILeadChannel);
                  return result;

                }else if(post_code_info[0].Sub_Patch__r.Appointment_Source__c == 'OFS' && OFS_Start_Date != null && latest < OFS_Start_Date  && earliest > OFS_Start_Date)
                {
                  /*************** Code when OFS Start Date is in middle of Latest and earliest ******************/
                  /**************** Both OFS & SFDC************************************************/
                  datetime sfdcStart = latest;
                  datetime sfdcEnd = OFS_Start_Date.adddays(-1);
          
                  webservice_CHI_Online.GetAppointmentsByPostcodeResponse sfdcResult = callSalesforce( post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  sfdcStart , sfdcEnd, null);
          
                  datetime ofsStartDate = OFS_Start_Date;
                  datetime ofsEnddate= earliest;
                  
                  webservice_CHI_Online.GetAppointmentsByPostcodeResponse ofsResult = callOFS( post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  ofsStartDate , ofsEnddate, customerCategory);
          
                  for(webservice_CHI_Online.cAppointment temp: sfdcResult.AppointmentSlots)
                  {
                    result.AppointmentSlots.add(temp);
                  }
                  for(webservice_CHI_Online.cAppointment temp: ofsResult.AppointmentSlots)
                  {
                    result.AppointmentSlots.add(temp);
                  }
                  if(result.AppointmentSlots.size() == 0)
                  {
                        result.Error.Code = 6;
                        result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info[0].Name;
                        return result;
                  } else
                  {
                    return result;
                  }  
              
                      
                }else if(OFS_Start_Date != null && latest >=OFS_Start_Date  && post_code_info[0].Sub_Patch__r.Appointment_Source__c == 'OFS')
                { 
                  
                  /*****************ONLY IN OFS********************/
                  system.debug('******************I am INside ');
                   
                  result = callOFS(post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  latest , earliest, customerCategory);
                  return result;
                   
                }       
                //Change End   
                else{
               /*****************ONLY IN SALESFORCE********************/
                  result = callSalesforce(post_code_info[0],  objGetAppointmentsByPostcode.BoilerOp,  process_start_time,  process_end_time , appsres,  latest , earliest, null);
                  return result;
                }
            }  
          }else
          {
              result.Error.Code = 9;
              result.Error.Message = 'ERROR: Something went wrong. POSTCODE is blank or null.';
          }
      process_end_time = system.now();    
      }catch (exception e)
      {
        result.Error.Code = 9;
        result.Error.Message = 'ERROR: Something went wrong. '+e.Getmessage();
        system.debug('Exception while querying Appointments'+e.getmessage());
        CreateEmail.CretaeSendTextEmail(new list<string>{system.label.supportOnline},e.getmessage()+' Occured in webGetAppointmentsByPostcode at line NO: '+e.getLineNumber(), 'Exception in Online Booking webGetAppointmentsByPostcode class');
        Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Journey__c = 'New', Exception__c =e.getmessage() );
        //insert o;
        return result;
      }
      
      return result;
        
    }
    
    private webservice_CHI_Online.cAppointment[] fRemoveDupApps(webservice_CHI_Online.cAppointment[] inArray) {
        integer array_size = inArray.size();
        
        for (integer counter = 1; counter <= (array_size-1); counter++) {
            
            if (inArray[counter-1].AppStart == inArray[counter].AppStart
                &&
                inArray[counter-1].AppEnd == inArray[counter].AppEnd) { // same start/end time, remove duplicate
                    
                inArray.remove(counter); 
                array_size--;
                counter--; // if have just removed an app, decrement counter so original app is compared to new adjacent one    
            }
        }
        
        return inArray;
    }
    
    
    public webservice_CHI_Online.GetAppointmentsByPostcodeResponse callOFS(Postcode_Sector__c post_code_info, string BoilerOp, datetime process_start_time, datetime process_end_time , integer appsres, datetime latest , datetime earliest, integer customerCategory)
    {
         webservice_CHI_Online.GetAppointmentsByPostcodeResponse  result  = new webservice_CHI_Online.GetAppointmentsByPostcodeResponse();    
         string BucketName = post_code_info.Sub_Patch__r.OFS_Bucket_Name__c;
         
         Employee__c emp = [Select id,name,Slots_To_Reserve__c,Customer_Category_To_Reseve__c, Release_Day__c, Release_Time__c from employee__c where id = :BucketName];
           
           
           Map<string, SalesAppointment__c> mcs = SalesAppointment__c.getAll();
           list<string> title = new list<string>{};
           title.addall(mcs.keyset());
           
          //Send OFS API Request
           list<string> location = new list<string>{BucketName};
           List<Date> appointmentWindow = new list<Date>();
           date ofsStartDate  = latest.date();
           date ofsEndDate = earliest.date();
           system.debug('******************ofsStartDate'+ofsStartDate+' '+ofsEndDate);
           while(ofsStartDate<=ofsEndDate)
           {
              appointmentWindow.add(ofsStartDate);
              ofsStartDate = ofsStartDate.adddays(1);
           }
           toaCapacity.capacity_response_element response  = getCapacityRes.getCapacity(location, appointmentWindow, post_code_info.Name,post_code,'Central Heating Boiler');
           system.debug('&&&&&&&&&&&Response'+Response.capacity);
           system.debug('&&&&&&&&&&&window'+appointmentWindow);
           system.debug('***********'+response.capacity.size());
           
           // fix for duplicate slotStartTime start 
           
           set<datetime> startTimeSet = new set<datetime>();
           
           // fix for duplicate slot start time 

           map<string, list<webservice_CHI_Online.cAppointment>> bucketHours = new map<string, list<webservice_CHI_Online.cAppointment>>();
           
           if(response!=null)
           {
              TOA_Product_Interest__c tp = TOA_Product_Interest__c.getInstance('Central Heating Boiler');
              integer minAvailable = integer.valueof(response.activity_travel_time)+integer.valueof(tp.Duration__c);
             for(toaCapacity.capacity_element cap : response.capacity)
             {
               
                 if(/*cap.available >= minAvailable &&*/ (cap.work_skill == 'standard_cc' || cap.work_skill == 'Commercial' ) )//&& title[lp] == cap.time_slot && date.newInstance(latest.date().year(), latest.date().month(), latest.date().day()+cp) == cap.date_x )
                 {
                     system.debug('-------------'+cap.work_skill +' --'+ cap.time_slot+'  '+cap.available+' '+cap.date_x);
                     dateTime now = system.now();
                     datetime slotStartTime = datetime.newInstance(cap.date_x.year(), cap.date_x.month(), cap.date_x.day(), integer.valueof(mcs.get( cap.time_slot).Start_Time__c.split(':')[0]), integer.valueof(mcs.get( cap.time_slot).Start_Time__c.split(':')[1]), 0);
                     list<string> ignoreSlots = system.label.Online_Slots_to_Ignore.split(',');
                     boolean skip = false;
                     if(userinfo.getUserName().contains('chi_online'))
                     for(string s : ignoreSlots)
                     {
                        if(cap.time_slot == s )
                        {
                         skip = true;   
                        }
                     }
                     
                     if(customerCategory != null  && emp.Slots_To_Reserve__c !=null && emp.Customer_Category_To_Reseve__c != null && 
                     !emp.Customer_Category_To_Reseve__c.contains(string.valueof(customerCategory)) && emp.Slots_To_Reserve__c.contains(cap.time_slot))
                    {
                        integer numberOfDaysBefore = integer.valueof(emp.Release_Day__c);
                        integer timeElement = integer.valueof(emp.Release_Time__c);
                        time timeVar = Time.newInstance(timeElement, 0, 0, 0);
                        datetime releaseDateTime = datetime.newinstance(cap.date_x.adddays(-(numberOfDaysBefore)), timeVar);
                        if(releaseDateTime>system.now())
                        {
                        	skip = true;
                        }
                        
                    }

                     if(skip)
                     continue;

                     if(now < slotStartTime || cap.time_slot== 'AT' )
                     {
                         
                          string timeslot = mcs.get( cap.time_slot).Online_Code__c;
                         
                          datetime slotEndTime = datetime.newInstance(cap.date_x.year(), cap.date_x.month(), cap.date_x.day(), integer.valueof(mcs.get( cap.time_slot).End_Time__c.split(':')[0]), integer.valueof(mcs.get( cap.time_slot).End_Time__c.split(':')[1]), 0);
                       
                          webservice_CHI_Online.cAppointment app_at_to_add = new webservice_CHI_Online.cAppointment();
                          app_at_to_add.AppId     = BucketName.substring(0,BucketName.length()-(timeslot+'XXXXXXXX').length())+timeslot+ correctData(cap.date_x.day())+correctData(cap.date_x.month())+string.valueof(cap.date_x.year());  
                          app_at_to_add.AppStart  = slotStartTime;
                          app_at_to_add.AppEnd    = slotEndTime;
                          app_at_to_add.minutes = cap.available;
                          // Added as a part of Guided Sale to identify the PI.
                          app_at_to_add.productInterest = 'HSA';
                          result.AppointmentSlots.add(app_at_to_add); 
                          startTimeSet.add(slotStartTime);
                          if(bucketHours.containskey(string.valueof(slotStartTime)+timeslot))
                          bucketHours.get(string.valueof(slotStartTime)+timeslot).add(app_at_to_add);
                          else{
                            bucketHours.put(string.valueof(slotStartTime)+timeslot, new list<webservice_CHI_Online.cAppointment>{app_at_to_add});
                          }

                    }
                      

                   
                  }
                    
             }
             
             system.debug(bucketHours);

             result.AppointmentSlots = new list<webservice_CHI_Online.cAppointment>();

             for(string d: bucketHours.keyset())
             {
                decimal total =0;
                list<webservice_CHI_Online.cAppointment> tempList = bucketHours.get(d);
                for(webservice_CHI_Online.cAppointment app : tempList)
                {
                  total+=app.minutes;
                  
                }

                if(total>=minAvailable)
                {
                  tempList[0].minutes =total;
                  result.AppointmentSlots.add(tempList[0]);
                }
                
             } 
           }                     
           
           process_end_time = system.now();
           
           if(result.AppointmentSlots.size() == 0)
           {
                result.Error.Code = 6;
                result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.Name;
                system.debug(result.Error.Message);
                Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
                //insert o;
                return result;
           }else if(result.AppointmentSlots.size()>0)
            {
                result.AppointmentSlots = objWeb.fBubbleSortApps(result.AppointmentSlots);
                appsres = result.AppointmentSlots.size();
                system.debug('Appointment size after Geo--->'+result.AppointmentSlots.size()+' Last Slot time'+result.AppointmentSlots[result.AppointmentSlots.size()-1].AppStart);
            }
 
          
          
         return result;
    }
    
    public string correctData(integer i)
    {
        string s = string.valueof(i);
        
        return(s.length() == 1 ? '0'+s:s);
    }
    
    public  webservice_CHI_Online.GetAppointmentsByPostcodeResponse callSalesforce(Postcode_Sector__c post_code_info, string BoilerOp, datetime process_start_time, datetime process_end_time , integer appsres, datetime latest , datetime earliest, string productInterest)
    {
         
           webservice_CHI_Online.GetAppointmentsByPostcodeResponse  result  = new webservice_CHI_Online.GetAppointmentsByPostcodeResponse();  
           string avaiRecordType = system.label.AppointmentAvailability;
           list <String> visit_type = new list<String>();
           visit_type.add('Sales');
              
           if(BoilerOp!=null && BoilerOp == 'No')
           {
               visit_type.add('Priority');
           }
           
           
           List<Role_Sub_Patch__c> rle_sub_patches = new list<Role_Sub_Patch__c>();
           List<Role_District__c> rle_Districts = new list<Role_District__c>();
             
      if(Remote_Quote_Product__c.getInstance(productInterest) != null)
      {
          rle_Districts= [SELECT r.Role__r.Employee__c, r.start_date__c,r.end_date__c,Role__r.Employee__r.Primary_Role__c,Preference__c FROM Role_District__c r
                              WHERE District__c = :post_code_district
                              AND Type__c = 'Availability'      
                              AND start_date__c <= :earliest.date() 
                              AND end_date__c >= :latest.date()
                              AND r.Role__r.Employee__r.Pool_Type__c = null
                              AND r.Role__r.Employee__r.Primary_Role__c != 'Pool'
                              ORDER BY r.Role__r.Employee__c];
          
             if(rle_Districts.size()==0 )
             {
              result.Error.Code = 6;
              result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.Name;
              system.debug(result.Error.Message);
              Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
              return result;
             }
             else
             {
                 for(role_District__c r: rle_Districts)
                 {
                      list<list<date>> shiftSartEndDates = new list<list<date>>();
                      if(r.End_Date__c >=r.start_date__c)
                      {
                          if(r.Role__r.Employee__c!=null && cEmpAvailMap.containsKey(r.Role__r.Employee__c)) 
                          {
                              shiftSartEndDates  = cEmpAvailMap.get(r.Role__r.Employee__c);
                          }
                          shiftSartEndDates.add(new list<Date>{r.Start_Date__c, r.End_Date__c});
                          cEmpAvailMap.put(r.Role__r.Employee__c,shiftSartEndDates);
                      }
                 }
             }
       }else
       {
           rle_sub_patches = [SELECT r.Role__r.Employee__c, r.start_date__c,r.end_date__c,Role__r.Employee__r.Primary_Role__c FROM Role_Sub_Patch__c r
                              WHERE sub_patch__c = :post_code_sub_patch
                              AND Type__c = 'Availability'      
                              AND start_date__c <= :earliest.date() 
                              AND end_date__c >= :latest.date()
                              AND r.Role__r.Employee__r.Pool_Type__c = null
                              AND r.Role__r.Employee__r.Primary_Role__c != 'Pool'
                              ORDER BY r.Role__r.Employee__c];
            system.debug('rle_sub_patches--- >'+rle_sub_patches);
     
          if(rle_sub_patches.size()==0 )
          {
              result.Error.Code = 6;
              result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.Name;
              system.debug(result.Error.Message);
              Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
              return result;
          }else
          {
              for(Role_Sub_Patch__c r: rle_sub_patches)
              {
                      list<list<date>> shiftSartEndDates = new list<list<date>>();
                      
                      if(r.End_Date__c >=r.start_date__c)
                      {
                          if(r.Role__r.Employee__c!=null && cEmpAvailMap.containsKey(r.Role__r.Employee__c)) 
                          {
                              shiftSartEndDates  = cEmpAvailMap.get(r.Role__r.Employee__c);
                          }
                          
                          shiftSartEndDates.add(new list<Date>{r.Start_Date__c, r.End_Date__c});
                          
                          cEmpAvailMap.put(r.Role__r.Employee__c,shiftSartEndDates);
                      }
              }
          } 
       }
       
             system.debug('BeforecEmpAvailMap---->'+cEmpAvailMap);
             //Guided Sale Change
             set<id> filteredList = getEmployeeWithSkills(cEmpAvailMap.keyset(), productInterest);		
             for(id i : cEmpAvailMap.keyset())		
             {	if(!filteredList.contains(i))	
                cEmpAvailMap.remove(i);		
             }
             //ends
              
              system.debug('cEmpAvailMap---->'+cEmpAvailMap);
              //Query Appointments
              system.debug('avaiRecordType--->'+avaiRecordType);
              system.debug('Visit Type--->'+visit_type);
              system.debug('earliest-->'+earliest);
              system.debug('latest--->'+latest);
              
              
              
              
             List<Appointment__c> apps = [SELECT Id, Start__c, End__c, Assigned_To__c, Start_Time__c, Type__c,Valid_Slot__c 
                               FROM Appointment__c
                                           WHERE Assigned_To__c in :cEmpAvailMap.keyset()
                                           AND RecordTypeId = :avaiRecordType
                                           AND Start__c <= :earliest
                                           AND End__c >= :latest
                                           AND Type__c in :visit_type
                                           AND Opportunity__c = null
                                           AND Status__c ='New'
                                           ORDER BY Start__c ASC 
                                           LIMIT 1500];
                                        
                             
              system.debug('All Appointment Slots-->'+apps.Size());                   
              if(apps.size()==0)
              {
                  result.Error.Code = 6;
                  result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.name;
                  system.debug(result.Error.Message);
                  Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
                  //insert o;
                  return result;
                  
              }else
              {
                 Date dt=Date.today();                            
                 Time ti=Time.newInstance(12,00,00,00);          
                 DateTime datetimeconverted=DateTime.newInstanceGMT(dt,ti);
                 
                  for(Appointment__c a: apps)
                  {  
                  //system.debug(a);
                  // Dont allow inday appointment to be booked after 12:00 PM 
                  if(productInterest == 'Central Heating Boiler' && datetimeconverted > system.now() && a.Start__c.date() < system.today().adddays(1))
                  {
                      continue;
                  }
                    //system.debug('I am here1');
                    if((a.Valid_Slot__c == 'Yes' || productInterest == 'Straight Swap' || (productInterest == 'Guided Sale' && a.Start__c> system.now().addMinutes(integer.valueof(label.GuidedSaleBuffer))))&& a.Start__c>= system.now())
                    {
                      //system.debug('I am here2');
                      If(cEmpAvailMap.containsKey(a.Assigned_To__c))
                      {
                        for(List<DateTime> startEndTime : cEmpAvailMap.get(a.Assigned_To__c))
                        {
                          if(a.Start__c.date() >= startEndTime[0] && a.End__c.date() <= startEndTime[1])
                          {
                            webservice_CHI_Online.cAppointment app_at_to_add = new webservice_CHI_Online.cAppointment();
                              app_at_to_add.AppId     = a.Id;
                              app_at_to_add.AppStart  = a.Start__c;
                              app_at_to_add.AppEnd    = a.End__c;
                              
                              app_at_to_add.ProductInterest = productInterest;
                              if(productInterest == 'Central Heating Boiler')
                              app_at_to_add.ProductInterest = 'HSA';
                              
                              result.AppointmentSlots.add(app_at_to_add); 
                          }
                        }
                      }
                    }
                    
                    /*
                    else{
                    if((a.Valid_Slot__c == 'Yes' || productInterest == 'Straight Swap')&& a.Start__c.date() > system.now())
                    {
                      If(cEmpAvailMap.containsKey(a.Assigned_To__c))
                      {
                        for(List<DateTime> startEndTime : cEmpAvailMap.get(a.Assigned_To__c))
                        {
                          if(a.Start__c.date() >= startEndTime[0] && a.End__c.date() <= startEndTime[1])
                          {
                            webservice_CHI_Online.cAppointment app_at_to_add = new webservice_CHI_Online.cAppointment();
                              app_at_to_add.AppId     = a.Id;
                              app_at_to_add.AppStart  = a.Start__c;
                              app_at_to_add.AppEnd    = a.End__c;
                              result.AppointmentSlots.add(app_at_to_add); 
                          }
                        }
                      }
                    }
                    }*/
                  }
                  process_end_time = system.now();
                  if(result.AppointmentSlots.size() == 0)
                  {
                    result.Error.Code = 6;
                    result.Error.Message = 'ERROR: No Available Appoinmnent Slots. ' + post_code_info.name;
                    system.debug(result.Error.Message);
                    Online_Timing__c o = new Online_Timing__c(Postcode__c = post_code , Start__c = string.valueof(process_Start_time), End__c = string.valueof(process_end_time), appointments__c = string.valueof(appsres), Journey__c = 'New');
                    //insert o;
                    return result;
                  }else if(result.AppointmentSlots.size()>0)
                    {
                        result.AppointmentSlots = fRemoveDupApps(result.AppointmentSlots);
                        result.AppointmentSlots = objWeb.fBubbleSortApps(result.AppointmentSlots);
                        appsres = result.AppointmentSlots.size();
                        system.debug('Appointment size after Geo--->'+result.AppointmentSlots.size()+' Last Slot time'+result.AppointmentSlots[result.AppointmentSlots.size()-1].AppStart);
                        return result;
                    }
                    return result;
                  
              }                    
              
              
          }                                            
               
    
    
    //Guided Sale changes
    public Static set<Id> getEmployeeWithSkills(set<id> employeeIdList , string productInterest)		
    {		
        set<Id> filteredList = new set<Id>();
        for(Employee_Sales_Skill__c es :[Select Id , Sales_Skill_Name__c,  Employee__c From Employee_Sales_Skill__c where  Is_Active__c = 'true' and Employee__c in : employeeIdList and Sales_Skill_Name__c = : productInterest])		
        {		
          filteredList.add(es.Employee__c);		
        }
        return filteredList;
   }
   //ends
        
    
}