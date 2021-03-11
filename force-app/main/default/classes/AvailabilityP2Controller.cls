global class AvailabilityP2Controller { 
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class for visualforce page 'availiability2'. Logic to find and display employees who have//
    //available appointments for the specific day and time period selected on the 'availability' page.    //
    //Return employee names and status' for those employees who have appointments of the same app type    //
    //(sales/survey) of the CHI Lead, covering the postcode supplied. Pool availability is included if CHI//
    //Lead urgency is 'Urgent'. Includes option to book appointment for each listed employee and logic    //
    //books the widest slot available for that employee. Page then redirects to Firefly or salesforce Opp //                                                  //                                                                      //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    boolean productInterestChanged = false;

    // ++ Updated opp variable for Priority Installation CR start
    public Opportunity opp {get; set;}
    // -- Updated opp variable for Priority Installation CR end
    public string existingLead{get;set;} //Added BY ASHOK G
    public boolean newInbound{get;set;}
    //Get parameter values from the page URL passed from availability page
    // IntegratedScript changes
    String postCode = ApexPages.currentPage().getParameters().get('var_postCode');
    String postCodeSubPatch = ApexPages.currentPage().getParameters().get('var_subPatch');
    String postCodeDistrict = ApexPages.currentPage().getParameters().get('var_district');
    String selectedDay = ApexPages.currentPage().getParameters().get('var_date');
    String selectedTimePeriod = ApexPages.currentPage().getParameters().get('var_period');
    Integer selectedStartTime = integer.valueOf(ApexPages.currentPage().getParameters().get('var_starttime'));
    Integer selectedEndTime = integer.valueOf(ApexPages.currentPage().getParameters().get('var_endtime'));
    String CHIleadId = ApexPages.currentPage().getParameters().get('var_OpptyId');
    string source = System.currentPageReference().getParameters().get('var_Source');
    String twoHrView = System.currentPageReference().getParameters().get('var_view');
    String urgency = System.currentPageReference().getParameters().get('var_urgency');
    String visitType = System.currentPageReference().getParameters().get('var_type');
    String contactId = System.currentPageReference().getParameters().get('var_contactId');
    String currentApp = System.currentPageReference().getParameters().get('var_cancelledapp');
    String callID = System.currentPageReference().getParameters().get('var_CallId'); 
    string pcr = System.currentPageReference().getParameters().get('var_Pcr');
    string scr = System.currentPageReference().getParameters().get('var_Sec');
    String NoSuitableStr = System.currentPageReference().getParameters().get('var_NoSuitable');
    String prioType = System.currentPageReference().getParameters().get('var_Prio_Type'); // varaible decides if we are considering Prioroty type in SOQL
    String availMins = System.currentPageReference().getParameters().get('var_min');
    String productInt = System.currentPageReference().getParameters().get('productInt');
    
    public boolean useOFS {get;set;}
    public boolean OfsApptNotBooked;
    public string TimeSlot{get;set;}
    public datetime ofsStartDate{get;set;}
    public datetime ofsEnddate{get;set;}
    public string AppointmentType{get;set;}
    public boolean hideStdValue{get;set;}
    public List<SelectOption> timeLineOptions{get;set;}
    String ffParameters = null;
    Map<Id,Employee_Sales_Skill__c> EmpSalesSkillMap;
    // CR For Diary Start & End Time Changes. Added two additional parameters for storing minutes information.
    Integer selectedAppStartMinute = Integer.valueOf(ApexPages.currentPage().getParameters().get('var_start_min'));
    Integer selectedAppEndMinute = Integer.valueOf(ApexPages.currentPage().getParameters().get('var_end_min'));  
    // HSA allocation CR - Starts
    Double highestAbility = Double.valueOf(ApexPages.currentPage().getParameters().get('highestAbility'));  
    // HSA allocation CR - Ends
    public string Visit_Type{get;set;}
    
    //++ Priority Installation CR start
    public boolean include_priority_install {get; set;}  
    public boolean customerCategoryMessage {get; set;}
    //-- Priority Installation CR end
    
    // cancellation reason
    public boolean cancellation{get;set;}
    public boolean isHSA{get;set;}
    
    //Changes done for no suitable appointments
    boolean NoSuitable=null;    
    public string gDeal {get;set;}
    public boolean followUp {get;set;}
    public Appointment__c appInst{get;set;}
    
    public List<selectoption> getApptAttendeOptions(){
        List<selectoption> options = new List<selectoption>();
        Options.add(new SelectOption('','--None--'));
        Options.add(new SelectOption('Tenant','Tenant'));
        Options.add(new SelectOption('Landlord','Landlord'));
        Options.add(new SelectOption('Agent','Agent'));
        Options.add(new SelectOption('Regulatory','Regulatory'));
        return options;
    }
    //++ GD Change
    
    Utilities util  = new Utilities();
    //-- GD Change
    map<string, list<string>> displayController;
    map<string, list<string>> displayRestricter;   
    Integer currentHour = datetime.now().hour(); // get the current Hour value
    
    public string apptAttendee{get;set;}
    
    string ofsBucket;
    Sub_Patch__c sub ;   
    public AvailabilityP2Controller() {
        
        isHSA=false;
        if(system.label.CHI_HSA_ProfileId.contains(userinfo.getProfileId()))
        {
           isHSA=true;
        }
        
        useOFS = System.currentPageReference().getParameters().get('var_OFS')=='t'?true:false;
        gDeal = System.currentPageReference().getParameters().get('gDeal');
        existingLead = System.currentPageReference().getParameters().get('existingLead');
        newInbound = System.currentPageReference().getParameters().get('new')== 'true'?true:false;
        OfsApptNotBooked = false;
        timeLineOptions= new List<SelectOption>();
        
        appInst = new Appointment__c ();
        appInst.Time_Band__c = selectedTimePeriod;
        
        SalesAppointment__c sp = SalesAppointment__c.getInstance(selectedTimePeriod);
        if(sp!=null)
            TimeSlot = sp.Start_Time__c +'-'+sp.End_Time__c;
        // Appointment Controller - Converter
        displayRestricter = new map<string, list<string>>();
        displayController = new map<string, list<string>>();
        if(system.label.AppointmentCont.contains('|'))
        {
            for(string s: system.label.AppointmentCont.split('\\|'))
            {
                list<string> typeDetails =s.split('>');
                if(typeDetails.size()>0)
                {
                    displayController.put(typeDetails[0], typeDetails[1].split('-'));
                }
                list<string> stringlist =typeDetails[1].split('-');
                if(stringlist[3]=='1')
                {
                    
                    displayRestricter.put(stringlist[0], new list<string>{stringlist[1],stringlist[2],stringlist[3]});
                }
            }
        }
        // Appointment Converter End
        hideStdValue=false;
        opp = new Opportunity();
        Visit_Type = visitType;
        ffParameters = Utilities.buildParameterString(System.currentPageReference(), null);
        if(ffParameters.length() > 1)
            ffParameters += '&';
        
        opp = [Select id,Account.Primary_Contact__c,Account.BillingPostalCode,Account.BillingStreet,Account.BillingCity,Account.Landlord_Account__c,Account.Latitude__longitude__s,Account.Latitude__latitude__s, Type,Enquiry_Type__c,Product_Interest__c, CHI_Lead_Type__c , Timeline_Options__c , Timeline_Reason__c , 
               CreatedDate , Latest_customer_category__c , Latest_customer_category_indicator__c,Secondary_Product_Interest__c, AccountId,Social_Contact_Details__c,Social_Contact_Type__c,Mobile_Phone__c,Customer_Email__c,TA_Notes__c,
               (Select id,Date_Visit_Booked__c from Appointments__r where Type__c = 'Sales') from Opportunity where id=: CHIleadId];
             
               
        if(productInt!=null&& productInt!=opp.product_interest__c)
        {
            productInterestChanged = true;
            opp.product_interest__c=productInt; 
        }
        
        if(opp.Social_Contact_Details__c==null &&opp.product_interest__c=='Guided Sale')
             {
                 opp.Social_Contact_Details__c = opp.Mobile_Phone__c!=null?opp.Mobile_Phone__c:opp.Customer_Email__c;
             }
        
        if(currentApp!='NULL')
            cancellation = true;
        else
            cancellation = false;
            
        if(cancellation&&isHSA)
        {
            appInst.Primary_Cancellation_Reason__c='Cancel – Guided sale not possible';
            appInst.Secondary_Cancellation_Reason__c ='Change to home visit';
        }
        
        followUp = false;       
        if(gDeal == '3' && opp.Appointments__r.size()>0)
            followUp = true;  
        if(opp.Product_Interest__c == 'Small Commercial'&& System.label.SmallCommercialTurnOff == 'Yes')     
            gDeal = '3';
        
        //++ Priority Installation CR start 
        if((opp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date) && opp.Product_Interest__c != 'Small Commercial')
        {
            include_priority_install = true;
        }
        else
        {
            include_priority_install = false;
        }
        if(include_priority_install && (opp.Latest_customer_category__c == 1 || opp.Latest_customer_category__c == 2 || opp.Latest_customer_category__c == 3))
        {
            customerCategoryMessage = true;
        }
        else
        {
            customerCategoryMessage = false;
        }
        if(include_priority_install)
        {
            opp.Timeline_Options__c = '';
            opp.Timeline_Reason__c = '';
        }
        
        
        
        if(system.today().daysBetween(date.valueOf(selectedDay))>integer.valueOf(system.label.availability_parameter)){
            
            hideStdValue=true;
            
        }    
        if(gDeal == '1') 
            include_priority_install = false;
        //-- Priority Installation CR end 
        
        //Changes done for No suitable appointments
        if(NoSuitableStr=='true')
            NoSuitable=true;
        else
            NoSuitable=false;     
        if(useOFS)
        {
            sub = [Select id, OFS_Bucket_Name__c, OFS_Bucket_Name__r.Name from Sub_Patch__c where Id = :postCodeSubPatch];
            ofsBucket = sub.OFS_Bucket_Name__c;
        }
        
    }
    
    // end IntegratedScript changes
    
    /////////////////////////////////////
    //Page Button Funtionality Defined //
    /////////////////////////////////////
    
    //Return user to previous availability page when button clicked
    public PageReference onClickBack() {
        // IntegratedScript changes        
        PageReference pageRef = new PageReference('/apex/availability'+ffParameters+'var_Source=' + source + '&var_OpptyId=' + CHIleadId + 
                                                  '&var_view=null' + '&var_date=' + selectedDay + '&var_contactId=' 
                                                  + contactId +'&var_cancelledapp='+currentApp  + '&var_CallId=' + callID+'&var_NoSuitable='+NoSuitable);                                               
        // end IntegratedScript changes
        pageRef.setRedirect(true);      
        return pageRef;
    }       
    
    //Action to book an appointment when the book link is clicked 
    public PageReference onClickBook() {
        
        if(isHSA&&(opp.Timeline_Options__c == '' || opp.Timeline_Options__c == null)&&include_priority_install)
        {
            opp.Timeline_Options__c= 'Customer Requested';
            opp.Timeline_Reason__c = 'Customer requested date';
        }
        //Calls utilities to lookup the RecordTypeID of the 'Appointed' record type.
        Utilities.setup();
        Id AvailableRTID = null;  
        MessageConstants msgConstants = new MessageConstants();
        if(include_priority_install){
            if((opp.Timeline_Options__c == 'Customer Requested' || opp.Timeline_Options__c == 'Not within Standard' || opp.Timeline_Options__c == 'Within Standard') && (opp.Timeline_Reason__c == null || opp.Timeline_Reason__c == ''))
            {
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, msgConstants.ERR_ENTER_OUT_OF_STANDARD_REASON);
                ApexPages.addMessage(msg);
                return null;
            }
            if(opp.Timeline_Options__c == '' || opp.Timeline_Options__c == null)
            {
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, msgConstants.ERR_ENTER_APPOINTMENT_REASON);
                ApexPages.addMessage(msg);
                return null;
            }
        }
        if(Cancellation){
            if(isHSA&&(appInst.Primary_Cancellation_Reason__c==null||appInst.Primary_Cancellation_Reason__c==''))
            {
                appInst.Primary_Cancellation_Reason__c='Cancel – Guided sale not possible';
                appInst.Secondary_Cancellation_Reason__c ='Change to home visit';
            }
            if(appInst.Primary_Cancellation_Reason__c!=null && appInst.Secondary_Cancellation_Reason__c == null){
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, msgConstants.ERR_CANCAPPOINTMENT);
                ApexPages.addMessage(msg);
                return null;
            }
            
            if(appInst.Primary_Cancellation_Reason__c == null && appInst.Secondary_Cancellation_Reason__c == null){
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, msgConstants.ERR_CANCAPPOINTMENT);
                ApexPages.addMessage(msg);
                return null;
            }
            
        }
        
        for(RecordType rt : Utilities.recordTypes.values())
        {
            if(rt.Name == 'Appointment' && rt.SobjectType == 'Appointment__c')
                AvailableRTID = rt.Id;              
        }
        
        system.debug('AvailableRTID is '+AvailableRTID);
        //Get the appointment and employee parameters specific to the book link clicked on availability2 page       
        String empId = System.currentPageReference().getParameters().get('selectedEmpId');
        Appointment__c bookedAppt; 
        datetime visitDatetime;
        if(useOFS)
        {  
            bookedAppt  = new Appointment__c();
            TOA_Product_Interest__c prdInt = TOA_Product_Interest__c.getinstance(opp.Product_Interest__c); 
            //Added By AshoK G
            
            if(availMins !=null){
                if(Integer.valueof(availMins)<Integer.valueOf(system.label.capacityAvailable)){
                    list<string> location = new list<string>{ofsBucket};
                        Date qStrtDate = ofsStartDate.Date();
                    list<Date> appointmentWindow = new list<Date>{qStrtDate};
                        String postCodeSector = Opp.Account.BillingPostalCode.substring(0,Opp.Account.BillingPostalCode.length()-2);   
                    OfsApptNotBooked = true;
                    
                    toaCapacity.capacity_response_element response  = getCapacityRes.getCapacity(location, appointmentWindow, postcodeSector,opp.Account.BillingPostalCode,opp.Product_Interest__c);
                    if(response!=null)
                    {
                        integer minAvailable = integer.valueof(response.activity_travel_time)+integer.valueof(prdInt.Duration__c);
                        system.debug('Minimum Needed -->'+minAvailable);
                        for(toaCapacity.capacity_element cap : response.capacity)
                        {
                            
                            if(selectedTimePeriod == cap.time_slot)
                            {
                                if(cap.available >= minAvailable )
                                {
                                    OfsApptNotBooked = false;
                                }else{
                                    OfsApptNotBooked = True;
                                    bookedAppt.addError('Capacity for this bucket is now full. Please retry for another date' ); 
                                    return null;
                                }
                                break;
                            }
                        }
                    }
                }
            } 
            if(!OfsApptNotBooked)
            {
                bookedAppt  = new Appointment__c(                                               
                    Assigned_To__c = ofsBucket,
                    Opportunity__c = opp.Id,                                                     
                    Who__c = opp.Account.Primary_Contact__c,
                    Type__c = 'Sales',
                    Visit_Type__c = 'First Visit',
                    Show_Time_As__c = 'Busy',
                    Status__c = 'Appointed',
                    RecordTypeId = AvailableRTID,
                    Appointment_Attendee__c= apptAttendee,
                    Follow_Up__c = appInst.Follow_Up__c,
                    Start__c = ofsStartDate,
                    End__c= ofsEndDate,
                    SLA_Start__c = ofsStartDate,
                    SLA_End__c = ofsEndDate,
                    TOA_Duration__c = prdInt.Duration__c,
                    Time_Band__c = selectedTimePeriod,
                    Time_Band_Reason__c = appInst.Time_Band_Reason__c,
                    OFS_Appointment__c = true,
                    Shorter_Time_Bands__c = appInst.Shorter_Time_Bands__c);
            }
            
            
            
            
            visitDatetime = ofsStartDate;
            system.debug('bookedAppt-- >'+bookedAppt);
        }
        else
        {
            String appId = System.currentPageReference().getParameters().get('selectedAppId');
            
            bookedAppt = new Appointment__c( id = appId,                                                     
                                            //Assigned_To__c = empId,
                                            // HSA allocation CR - Starts
                                            Opportunity__c = opp.Id,                                                     
                                            Who__c = opp.Account.Primary_Contact__c,
                                            // HSA allocation CR - Ends
                                            Type__c = visitType,
                                            Visit_Type__c = 'First Visit',
                                            Show_Time_As__c = 'Busy',
                                            Status__c = 'Appointed',
                                            RecordTypeId = AvailableRTID,
                                            Appointment_Attendee__c= apptAttendee,
                                            Follow_Up__c = appInst.Follow_Up__c
                                           );  
           // }                            
            Appointment__c tmpApp = [select id, Start__c , Type__c from Appointment__c where id =: appId];     
            visitDatetime =   tmpApp.Start__c;                                                                                           
        }                                               
        //System.debug('Appointment ID to book is ' + appId);
        System.debug('Employee ID to is ' + EmpId);
        integer result;
        System.debug('result start is '+result);
        //insert bookedAppt;
        pageReference pageRef;
        if(newInbound){
            pageRef = new PageReference('/apex/new_wrapupscreenpage?c='+callID+'&existingLead='+existingLead+'&new='+newInbound);
        }else        
            pageRef = new PageReference('/apex/wrapupscreenpage?c='+callID+'&existingLead='+existingLead); 
        
        if(source == 'SF' || source == 'CS')
            pageRef = new PageReference('/'+CHIleadId); 
        else if(source == 'ICL'){
            if(!newInbound)
                pageRef = new PageReference('/apex/wrapupscreenpage?chiLeadId='+CHIleadId+'&accId='+opp.AccountId+'&existingLead='+existingLead); 
            else
                pageRef = new PageReference('/apex/new_wrapupscreenpage?chiLeadId='+CHIleadId+'&accId='+opp.AccountId+'&existingLead='+existingLead+'&new='+newInbound); 
        }
        
        system.debug('Sugu before lat long' );
        updateLattitude();
        try {
            // CR MC011
            
            // Originally this was just the upsert call; however as part of CR MC011, an Appointment cannot be booked 
            // if the Opportunity it is booked against has an active Sales Appointment. The problem was that we book
            // a new Appointment here before we cancel an old one, so the new booking would be prevented from happening.   
            // Hence, here we set a static variable to override the Appointment booking prevention.
            // If we are at this point, we know there is, at most, one Appointment to cancel, therefore we can allow 
            // the booking to take place. 
            
            Lock.callCentreBooking = true;
            //++ Priority Installation CR start
            system.debug('Test Class Debug'+opp.Timeline_Options__c+' '+opp.Timeline_Reason__c );
            if(include_priority_install){
                
                opp.Pending_update_to_customer_category__c = true;
                opp.Last_customer_cat_info_update_source__c = 'SGC';
                opp.Customer_Category_Modified_Datetime__c = Datetime.now();
                opp.Customer_Category_Record_Modified_By__c = UserInfo.getUserId();
                opp.Stage_object_type__c = 'Appointment';
                opp.Sales_visit_date_time__c = visitDatetime;
                opp.Date_time_appointment_booked__c = Datetime.now();
                
                bookedAppt.Timeline_Options__c = opp.Timeline_Options__c;
                bookedAppt.Timeline_Reason__c = opp.Timeline_Reason__c;
                
            }
            
            if(opp.Product_Interest__c == 'Guided Sale')
            {
                string social =  ' Contact Method TYPE: '+opp.Social_contact_Type__c +' CONTACT: '+opp.Social_Contact_Details__c;
                if(opp.TA_Notes__c!=null && !opp.TA_Notes__c.contains('Contact Method TYPE:'))
                opp.TA_Notes__c += social;
                else if(opp.TA_Notes__c== null)
                opp.TA_Notes__c = social;
            }
        
            //++ Priority Installation CR end
            
            //Change for lanlord record
            if(gDeal != '3' && opp.Account.Landlord_Account__c==true && apptAttendee == null ){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Enter Appointment Attendee');
                ApexPages.addMessage(msg);
                return null;            
            }
            
            Database.UpsertResult lsr;
            //if(!ofsApptNotBooked)
            lsr = Database.upsert(bookedAppt, false);
            if(isHSA)
            {
               pageRef = new PageReference('/apex/availability3?var_Source='+source+'&var_OpptyId='+CHIleadId+'&var_view=null'+'&var_date='+selectedDay+'&var_CallId=' + callID+'&var_period='+selectedTimePeriod+'&id='+bookedAppt.Id);
            }
            
            
            // BGS_CTS : description: To intergrate Opportunity with Appointment and update Opportunity field on Appointment book functionality :START
            try{
                System.debug('###*** CHI LEAD ID: '+CHIleadId);
                System.debug('###*** opp: '+opp);
                opp.Enquiry_Type__c = 'Sales Appointment';
                //if(!ofsApptNotBooked)
                opp.Stage_object_id__c = bookedAppt.Id;
                
                if(gDeal!='0')
                opp.Secondary_Product_Interest__c = 'Green Deal';
                
                // updae the opportunity 
                upsert opp;
                System.debug('###*** opp after upsert: '+opp);

                if(productInterestChanged)
                update bookedAppt;
                
            }catch(Exception e){
                System.debug('###*** Exception: '+e);
                pageRef = null; 
            }
            // BGS_CTS : END
            Lock.callCentreBooking = false;
            // End CR MC011
            
            //if(!ofsApptNotBooked){                
            if(!lsr.isSuccess()){
                Database.Error err = lsr.getErrors()[0];
                bookedAppt.addError('Error booking appointment. Message received: ' + err.getMessage());
                result = 1;   
                pageRef = null; 
                
                // }
            }                        
            else{
                result = 2;
                if(currentApp!='null'){
                    try {
                        
                        // ashok CR 12 Change Start                    
                        //Appointment__c currentApp2Delete = new Appointment__c(Id=currentApp, Status__c = 'Cancelled', Status_Reason__c='APPOINTMENT RESET'); 
                        //Appointment__c currentApp2Delete = new Appointment__c(id=currentApp, Status__c='Cancelled', Primary_Cancellation_Reason__c='Cancelled - Automatic Rearrange', Secondary_Cancellation_Reason__c='Cancelled - Automatic Rearrange');
                        
                        //CR - 08/11/11 to populate the Primary and secondary Cancellation reason selected in inboundcall page.
                        /*if(pcr!='null')
currentApp2Delete.Primary_Cancellation_Reason__c = pcr;
if(scr!='null')
currentApp2Delete.Secondary_Cancellation_Reason__c= scr; // Ashok CR 12 End
*/
                        //Ashok CR 1407 change start
                        Appointment__c currentApp2Delete = new Appointment__c(id=currentApp, Status__c='Cancelled');
                        currentApp2Delete.Primary_Cancellation_Reason__c  = appInst.Primary_Cancellation_Reason__c ;
                        currentApp2Delete.Secondary_Cancellation_Reason__c = appInst.Secondary_Cancellation_Reason__c ;
                        // change end
                        Database.SaveResult upd = Database.update(currentApp2Delete, false);
                        if(!upd.isSuccess()){
                            result = 3;
                            Database.Error err = upd.getErrors()[0];
                            currentApp2Delete.addError('Error cancelling current appointment when booking replacement appointment. Message received: ' + err.getMessage());    
                            return null;                                                                                                                   
                        }
                        else
                            result = 4;   
                        pageRef.setRedirect(true);  
                        return pageRef;  
                        
                        
                    }
                    catch (Exception exc2) {                
                        bookedAppt.addError('Error cancelling current appointment when booking replacement appointment an exception was thrown');
                        System.debug('Exception thrown trying to cancel current appointment when booking replacement: ' + exc2);
                        result = 5;  
                        pageRef = null;      
                    }                   
                }
            }
        }
        catch (Exception exc1) {                
            bookedAppt.addError('Error booking appointment an exception was thrown');
            System.debug('Exception thrown trying to book appointment: ' + exc1 +exc1.getLineNumber());
            result = 6;      
            pageRef = null; 
        }                                           
        
        System.debug('bookedAppt  ' + bookedAppt ); 
        return pageRef;     
        
    }
    //CODE ADDED - Keerthi -----------------------------------------------------
    //DATE:- July 20, 2018
    //DESCRIPTION:- To fetch the latitude and longitude details of the old accounts
    
    public void updateLattitude(){
        
        Account acct = new account(Id=opp.AccountId);
        if(opp.Account.Latitude__latitude__s == null && opp.Account.Latitude__longitude__s == null)
        {
            string street = opp.Account.BillingStreet!=null?opp.Account.BillingStreet.normalizeSpace().replaceall(' ','+').trim():'';
            System.debug('Street****---->'+street);
            string city = opp.Account.BillingCity!=null ? opp.Account.BillingCity.normalizeSpace().replaceall(' ','+').trim():'';
            System.debug('city****---->'+city);
            string pcode = opp.Account.BillingPostalCode!=null?opp.Account.BillingPostalCode.normalizeSpace().replaceall(' ','+').trim():'';
            System.debug('pcode****---->'+pcode);
            string Address = street + '+'+city+ '+' +pcode;
            System.debug('address string send to utility-->'+Address);
            
            try{
                list<string> Latlang = Utilities.getLatLang(Address,pcode,street,city);
                //list<string> Latlang = Utilities.getLatLang(Address,pcode);
                if(Latlang!=null && Latlang.size()==2)
                {
                    acct.Latitude__Latitude__s = double.valueof(Latlang[0]);
                    acct.Latitude__Longitude__s = double.valueof(Latlang[1]);
                }  
                Update acct;
            }
            catch (Exception e)
            {
                System.debug(e);  
            }
            
            System.debug('Latitude--> '+acct.Latitude__Latitude__s);
            System.debug('Longitude-->'+acct.Latitude__Longitude__s);
        }
        
    }
    //Keerthi
    ////////////////////////////////////////////////////////////
    //Page getter methods to display info on availability page//
    ////////////////////////////////////////////////////////////
    
    public string getPostCode(){       
        return postCode;
    }
    
    public string getDate(){                            
        //return selectedDay;
        String[] d= selectedDay.split('-');
        String dt = DateTime.newInstance(integer.valueOf(d[0]),integer.valueOf(d[1]),integer.valueof(d[2])).format('dd-MM-YYYY');
        return dt;
    }
    
    public string getTime(){
        return selectedTimePeriod;
    }    
    
     public string getday(){
        String[] d= selectedDay.split('-');
        datetime dt = DateTime.newInstance(integer.valueOf(d[0]),integer.valueOf(d[1]),integer.valueof(d[2]));
        return dt.format('EEEE') ;
    }    
    
    /////////////////////////////////////////////////////////////////////////
    //Define available dataset to return to datatable on availability2 page//        
    /////////////////////////////////////////////////////////////////////////
    
    global class availDataSet implements Comparable{
        public appointment__c app {get;set;}
        public String empFirstName;
        public String empLastName;
        public String empStatus;
        public String empId;   
        public String appointmentId;
        public double duration; 
        public decimal TechnicalAbility;
        public String SalesEfficiency;
        public string Slot {get;set;}
        // HSA allocation CR - Starts
        public Boolean isBestResource;               
        // HSA allocation CR - Ends
        
        public String hsaEmployeeType;
        public decimal appointmentCount;
        
        public void setHsaEmployeeType(String value) {
            
            hsaEmployeeType = value;
            
        }
        
        public String getHsaEmployeeType() {
            
            return hsaEmployeeType;
            
        }
        
        
        //
        //Setter methods
        //
        
        // HSA allocation CR - Starts
        public void setIsBestResource(Boolean value) {
            isBestResource = value;
        }
        // HSA allocation CR - Ends
        
        public void setEmpFirstName(String name) {
            empFirstName = name;
        }
        
        public void setEmpLastName(String name) {
            empLastName = name;
        }
        
        public void setappointmentId(String name) {
            appointmentId = name;
        }
        
        public void setduration(double dur) {
            duration = dur;
        }                
        
        public void setEmpStatus(String status) {
            empStatus = status;
        }
        
        public void setEmpId(String emp) {
            System.debug('JB:Settng Id' + emp);
            empId = emp;
        }
        public void setTechnicalAbility(decimal ability) {
            
            TechnicalAbility = ability;
        }
        public void setSalesEfficiency(String Efficiency) {
            System.debug('SalesEfficiency--->' + SalesEfficiency);
            SalesEfficiency = Efficiency;
        }
        
        public void setAppointmentCount(decimal ac) {
            appointmentCount = ac.setscale(2);
        }  
        //
        //Getter methods
        //
        
        // HSA allocation CR - Starts
        public Boolean getIsBestResource() {
            return isBestResource; 
        }   
        // HSA allocation CR - Ends
        
        public String getappointmentId() {
            return(appointmentId);
        }
        
        public String getEmpId() {
            System.debug('JB:Gettng Id' + empId);
            return empId;
        }       
        
        public String getEmpStatus() {
            return empStatus; 
        }             
        
        public String getempName() {
            return empFirstName + ' ' + empLastName;
        }
        
        public decimal getTechnicalAbility() {
            return TechnicalAbility;
        } 
        
        public decimal getduration() {
            return duration;
        } 
        public String getSalesEfficiency() {
            system.debug('get-->'+SalesEfficiency);
            return SalesEfficiency;
        }  
        
        public decimal getAppointmentCount() {
            return appointmentCount;
        }  
        
        /*global Integer compareTo(Object ObjToCompare) {
            if(empStatus==null)
            empStatus='';
            if(((availDataSet)ObjToCompare).empStatus== null )
            ((availDataSet)ObjToCompare).empStatus='';
              return empStatus.CompareTo(((availDataSet)ObjToCompare).empStatus);
        }*/
        
        global Integer compareTo(Object ObjToCompare) {
            if(empStatus==null)
            empStatus='';
            if(((availDataSet)ObjToCompare).empStatus== null )
            ((availDataSet)ObjToCompare).empStatus='';
            
            if(system.label.Guided_Sale=='on')
            {
                     if(empStatus.CompareTo(((availDataSet)ObjToCompare).empStatus)!=0)
                       return empStatus.CompareTo(((availDataSet)ObjToCompare).empStatus);

                     else if(slot.CompareTo(((availDataSet)ObjToCompare).slot)!=0)
                       return slot.CompareTo(((availDataSet)ObjToCompare).slot);

                     else 
                       {
                           if(AppointmentCount>((availDataSet)ObjToCompare).AppointmentCount)
                           return -1;
                           if(AppointmentCount<((availDataSet)ObjToCompare).AppointmentCount)
                           return 1;
                           else
                           return 0;
                       }
            }
            else
               return empStatus.CompareTo(((availDataSet)ObjToCompare).empStatus);
            
        }



    }   
    
    ////////////////////////////////////////////////////////////////////////////////
    //Method containing logic to return available employees, their status, and the//
    //'widest' appointment they have available for that period.                   //
    ////////////////////////////////////////////////////////////////////////////////
    
    public List<availDataSet> getDetailedAvailability() {                                               
        //Set SOQL query start/end time to day and time selected from first availabilty page.
        // CR For Diary Start & End Time Changes. Added two additional parameters for storing minutes information.
        
        Datetime queryStartTime = Datetime.newInstance(Date.valueOf(selectedDay).year(),Date.valueOf(selectedDay).month(),Date.valueOf(selectedDay).day(),selectedStartTime,selectedAppStartMinute,0);
       
        if(opp.Product_Interest__c == 'Guided Sale' && Date.valueOf(selectedDay) == system.today())
        {
            queryStartTime = system.now().addminutes(integer.valueof(label.GuidedSaleBuffer));
        }
        
        Datetime queryEndTime = Datetime.newInstance(Date.valueOf(selectedDay).year(),Date.valueOf(selectedDay).month(),Date.valueOf(selectedDay).day(),selectedEndTime,selectedAppEndMinute,0);
        date queryDate = Date.newInstance(Date.valueOf(selectedDay).year(),Date.valueOf(selectedDay).month(),Date.valueOf(selectedDay).day());
        
        if(useOFS)
        {
            //*************** Just create Appointment*******************
            availDataSet temp = new availDataSet();
            temp.empFirstName = '';
            temp.empLastName  = sub.OFS_Bucket_Name__r.Name;
            temp.Slot = selectedTimePeriod;
            temp.hsaEmployeeType = 'TOA Bucket';
            ofsStartDate  = queryStartTime;
            ofsEndDate = queryEndTime;
            return new list<availDataSet>{temp};
        }else
                {
                    //Set lists to iterate over later
                    List<Id> Emps = new List<Id>{};        
                        List<Date> empSubRoleStDate = new List<Date>{};
                            List<Date> empSubRoleEdDate = new List<Date>{};
                                List<String> empSubRoleStatus = new List<String>{};
                                    List<String> empSubRoleType = new List<String>{};  
                                        Map<string, availDataSet> uniqueList = new Map<string, availDataSet>{}; 
                                            List<availDataSet> ListToHoldAllSlots = new List<availDataSet>();
                    Map<Id,List<List<Date>>> Empmap = new Map<Id,List<List<Date>>>();
                    //
                    //Get the employees who have availability set to work this sub-patch. Their availability 
                    //must cover the day selected. Return both types 'availability' and 'ongoing' as we will
                    //use the 'ongoing' type to determine the preffered/backup status later
                    //
                    
                    Integer queryLimit = 1000;
                //Remote Quote Changes
                    if(Remote_Quote_Product__c.getInstance(Opp.product_interest__c) != null)
                {          
                   for (Role_District__c rleDistrict : [Select r.Role__r.Employee__c,Type__c , r.start_date__c,r.end_date__c,Role__r.Employee__r.Primary_Role__c,r.Preference__c From Role_District__c r
                        where District__c = :postCodeDistrict
                        and Type__c = 'Availability'
                        and start_date__c <= :queryDate 
                        and end_date__c >= :queryDate
                        and r.Role__r.Employee__r.Pool_Type__c = null
                        and r.Role__r.Employee__r.Primary_Role__c != 'Pool' 
                        ORDER BY r.Role__r.Employee__c
                        limit :queryLimit]){
                            Emps.add(rleDistrict.Role__r.Employee__c);
                            empSubRoleStDate.add(rleDistrict.start_date__c);
                            empSubRoleEdDate.add(rleDistrict.end_date__c);
                            rleDistrict.Preference__c = (rleDistrict.Preference__c!=null)?rleDistrict.Preference__c:'Primary';
                            empSubRoleStatus.add(rleDistrict.Preference__c);
                            empSubRoleType.add(rleDistrict.Type__c);
                        }    
                        
                        system.debug('@@@emp Status'+empSubRoleStatus);
                                
                }
                //ends
                else
                {
                    for (Role_Sub_Patch__c rleSubPtch : [Select r.Type__c, r.Status__c, r.Role__r.Employee__c, r.start_date__c,r.end_date__c From Role_Sub_Patch__c r
                                                         where sub_patch__c = :postCodeSubPatch
                                                         and start_date__c <= :queryDate
                                                         and end_date__c >= :queryDate
                                                         limit :queryLimit]){                            
                                                             Emps.add(rleSubPtch.Role__r.Employee__c);                       
                                                             empSubRoleStDate.add(rleSubPtch.Start_Date__c);
                                                             empSubRoleEdDate.add(rleSubPtch.End_Date__c);
                                                             empSubRoleStatus.add(rleSubPtch.Status__c);
                                                             empSubRoleType.add(rleSubPtch.Type__c);
                                                         }
                    
                    //
                    //If the enquiry urgency field is 'Urgent' we want to display the pool availability for 
                    //the district which covers the postcode sector in question.  
                    //so select as above but against district and for roles of type 'Pool' only.
                    // 
                    queryLimit = (1000 - Emps.size());           
                    if(urgency == 'urgent'){
     
                        for (Role_District__c rleDistrict : [Select r.Type__c, r.Role__r.Employee__c, r.start_date__c,r.end_date__c From Role_District__c r
                                                             where District__c = :postCodeDistrict
                                                             and start_date__c <= :queryDate
                                                             and end_date__c >= :queryDate                        
                                                             and r.Role__r.Type__c = 'Pool'
                                                             limit :queryLimit]){               
                                                                 Emps.add(rleDistrict.Role__r.Employee__c);                            
                                                                 empSubRoleStDate.add(rleDistrict.Start_Date__c);
                                                                 empSubRoleEdDate.add(rleDistrict.End_Date__c);                         
                                                                 empSubRoleStatus.add('Pool');
                                                                 empSubRoleType.add(rleDistrict.Type__c);
                                                             }               
                    }
                }
                    AvailabilityP1Controller AvailabilityP1obj = new AvailabilityP1Controller();
                    if(visitType == 'Sales' || visitType == 'Green Deal' || visitType == Utilities.nonOpCategory)
                    {
                        EmpSalesSkillMap = new Map<Id,Employee_Sales_Skill__c>();
                        string skill;
                        if(gDeal=='1')
                            skill = 'Green Deal';
                        else
                            skill = opp.Product_Interest__c; 
                        system.debug('CHI SKILL--->'+skill);
                        EmpSalesSkillMap = AvailabilityP1obj.fetchAppropSalesSkillEmp(Emps,skill);
                        system.debug('Fecthed Emps-->'+EmpSalesSkillMap.keyset());
                        list<Id> tempemps= new list<Id>();
                        list<Date> tempempSubRoleStDate = new list<Date>();
                        list<Date> tempempSubRoleEdDate = new list<Date>();
                        List<String> tempempSubRoleStatus = new List<String>{};
                            List<String> tempempSubRoleType = new List<String>{};
                                for(Id e: EmpSalesSkillMap.keyset())
                            {
                                for(integer i= 0 ; i< Emps.size();i++)
                                {
                                    if(e == Emps[i])
                                    {
                                        tempemps.add(e);
                                        tempempSubRoleStDate.add(empSubRoleStDate[i]);
                                        tempempSubRoleEdDate.add(empSubRoleEdDate[i]);
                                        tempempSubRoleStatus.add(empSubRoleStatus[i]);
                                        tempempSubRoleType.add(empSubRoleType[i]);
                                        List<List<Date>> finalListdate = new List<List<Date>>();
                                        List<Date> tempListdate = new List<Date>();
                                        
                                        if(Empmap.ContainsKey(Emps[i]))
                                        {
                                            finalListdate = Empmap.get(Emps[i]);
                                        }
                                        tempListdate.add(empSubRoleStDate[i]);
                                        tempListdate.add(empSubRoleEdDate[i]);
                                        finalListdate.add(tempListdate);
                                        Empmap.put(Emps[i], finalListdate);                        
                                    }
                                }
                            }
                        Emps= new list<Id>();
                        empSubRoleStDate = new list<Date>();
                        empSubRoleEdDate = new list<Date>();
                        empSubRoleStatus =  new List<String>{};
                            empSubRoleType =  new List<String>{};
                                Emps = tempemps;
                        empSubRoleStDate = tempempSubRoleStDate;
                        empSubRoleEdDate = tempempSubRoleEdDate;
                        empSubRoleStatus = tempempSubRoleStatus;
                        empSubRoleType = tempempSubRoleType;
                        system.debug('@@@New empSubRoleStatus-->'+empSubRoleStatus);
                        system.debug('@@@New Emps-->'+Emps);
                        
                    }
                    //
                    //Now return all 'available' appointments for the date selected from availabilty page, and only  
                    //for the employees who were found to have availability set for that week. Return only
                    //appointments with a matching type to that set on the CHI Lead (Sales or Survey).
                    //
                    List<String> appTypes = new List<String>();
                    if(visitType == 'Green Deal')
                    {
                        appTypes.add('Green Deal');
                    }
                    else if(visitType == Utilities.nonOpCategory)
                    {
                        appTypes.add('Sales');
                        appTypes.add(Utilities.nonOpCategory);
                        if(displayController.containskey('Sales'))
                            displayController.put(visitType, displayController.get('Sales'));
                    }
                    else if(visitType == 'Sales')
                    {
                        appTypes.add('Sales');
                        // Consider Priorirty appointments if user is logged in after 3 PM
                        if(prioType == Utilities.nonOpCategory)
                        {
                            appTypes.add(Utilities.nonOpCategory);
                        }
                    } 
                    system.debug('****************');
                    if(gDeal == '3' & opp.Latest_Customer_Category__c <= 3)
                    {
                        system.debug('****************');
                        appTypes.add(Utilities.nonOpCategory);
                    }
                    // Appointment Conveterter Change : Start
                    date allowedDate;
                    integer hourParameter;
                    boolean entered = false;
                    list<string> newVisitToBeAdded = new list<string>();  
                    date queryStartDate = queryStartTime.date();
                    //system.debug('---->'+displayController+displayController.containskey(visitType)+visitType);
                    if(displayController.containskey(visitType))
                    {
                        newVisitToBeAdded = displayController.get(visitType);
                        allowedDate = System.today()+integer.valueof(newVisitToBeAdded[1]);
                        hourParameter = integer.valueof(newVisitToBeAdded[2]);
                        
                        if(system.today().daysBetween(queryStartDate)<=integer.valueof(newVisitToBeAdded[1]))
                        {
                            appTypes.add(newVisitToBeAdded[0]);
                            entered = true;
                        }
                    }
                    
                    date allowedDate1;
                    integer hourParameter1;
                    if(displayRestricter.containskey(visitType))
                    {
                        allowedDate1 = System.today()+integer.valueof(displayRestricter.get(visitType)[0]);
                        hourParameter1 = integer.valueof(displayRestricter.get(visitType)[1]);
                        
                    }
                    
                    // Add all General Appointments in all the scenario unless thereis an exception in the label.
                    if(!system.label.Appointment_Exception.contains(visitType))
                    {
                        appTypes.add('General');
                    }
                    // Appointment Converter Change : End
                    system.debug('**App Type**'+appTypes);  
                    Appointment__c[] sevenDayAppts;      
                    string No_Suitable;
                    if(NoSuitable==true)
                    {
                        No_Suitable = 'No Suitable';   
                    }
                    
                    Map<String,Decimal> numberofApptsMap = new Map<String,Decimal>();
                    Map<String,Decimal> totalnumberofApptsMap = new Map<String,Decimal>();
                    if(Emps.size()>0)
                    {
                        list<string> statuses = new list<string>{'Appointed', 'Happened'};
                            AggregateResult[]  alreadyBooked = [select count(id), Assigned_to__c  from Appointment__c where  Start__c >= :queryStartTime.date()
                                                                and End__c <= :queryStartTime.date().adddays(1)
                                                                and Assigned_To__c in :Emps 
                                                                and Status__c = :statuses 
                                                                and Assigned_To__r.Pool_Type__c = : No_Suitable
                                                                Group By Assigned_to__c ];
                            AggregateResult[]  numberofAppts = [select  count(id)cnt, Assigned_to__c assignTo  from Appointment__c where  Start__c >= :queryStartTime.date()
                                                                and End__c <= :queryStartTime.date().adddays(1)
                                                                and Assigned_To__c in :Emps 
                                                                and Status__c != :statuses 
                                                                and Assigned_To__r.Pool_Type__c = : No_Suitable
                                                                Group By Assigned_to__c ];       
                                                                
                            AggregateResult[]  totalnumberofAppts = [select  count(id)cnt, Assigned_to__c assignTo  from Appointment__c where  Start__c >= :queryStartTime.date()
                                                                and End__c <= :queryStartTime.date().adddays(1)
                                                                and Assigned_To__c in :Emps 
                                                                and Assigned_To__r.Pool_Type__c = : No_Suitable
                                                                Group By Assigned_to__c ];       
                                                
                        


                       for(AggregateResult aggResult : numberofAppts)
                       {
                          numberofApptsMap.put((String)aggResult.get('AssignTo'), (Decimal)aggResult.get('cnt'));
                       }
                       
                       for(AggregateResult aggResult : totalnumberofAppts)
                       {
                          totalnumberofApptsMap.put((String)aggResult.get('AssignTo'), (Decimal)aggResult.get('cnt'));
                       }
                                                                
                    }
                    //system.debug('-->'+queryStartTime);
                    sevenDayAppts = [select Id,Visit_Date__c, Assigned_To__c,Assigned_To__r.name,Assigned_To__r.Social_Contact_App__c, Assigned_To__r.Diary_Controller__c,Assigned_To__r.First_Name__c, Assigned_To__r.Primary_Role__c, Assigned_To__r.Last_Name__c, Start__c, End__c, Duration_Mins_Calc__c, Start_Time__c,Assigned_To__r.Sales_Technical_Ability__c, Assigned_To__r.HSA_Employment_Type__c , Type__c,End_Time__c  from Appointment__c
                                     where Start__c >= :queryStartTime
                                     and start__c >=:system.now() 
                                     and End__c <= :queryEndTime
                                     and Type__c IN :appTypes 
                                     and Show_Time_As__c = 'Out of Office'
                                     and Assigned_To__c in :Emps
                                     AND Assigned_To__r.Pool_Type__c = : No_Suitable Order by Start__c ASC limit 1000];                                               
                    //system.debug('@@@fetced app size'+sevenDayAppts.size());                                          
                    //system.debug('@@@AllAppts'+sevenDayAppts);
                    
                    availDataSet [] retList = new availDataSet[]{};
                        
                        //Cycle through each appointment found                      
                        for(integer i=0;i<sevenDayAppts.Size();i++){
                            
                            /*
IF loop handles the logic for displaying the pool diary 48 hours in advance.
If Primary Role is "Pool" , it will check that the days between TODAY & appointment start is greater than 1.
If diffrence is greater than 1 , then and then only we are considering the appointments to be displayed on the page.
(In other worsds we are restricting the pool diary to be displayed for next 24 hours)

If Primary Role is other than "Pool" , consider the apoointment for display without any restrictions
*/
                            
                            
                            Date todayDate = date.today();
                            if(sevenDayAppts[i].Assigned_To__r.Primary_Role__c == 'Pool')
                            {
                                if(todayDate.daysBetween(date.valueOf(sevenDayAppts[i].Start__c)) <= 1)
                                {
                                    continue;
                                }
                            }
                            
                            /*
If current logged in time is greater than 3 PM , then display both types of appointments (Sales & Priority)for next day only.
If difference is more than one day then proceed with existing system that is display appointments as per the Type.
This scenario does not work for "Green Deal" appointments.
*/
                            List<String> tmpSet = new List<String>();
                            tmpSet.addAll(system.label.PriorityAppointmentHour.split(';',0));
                            Integer hourValue;
                            String isPrioritySwitchActive; 
                            if(tmpSet != null && tmpSet.size() > 0)
                            {
                                hourValue = Integer.valueOf(tmpSet[0]);
                                isPrioritySwitchActive = tmpSet[1].toLowerCase();
                            }
                            integer noofdays = todayDate.daysBetween(date.valueOf(sevenDayAppts[i].Start__c));
                            if(isPrioritySwitchActive == 'on' && gDeal == '0'  && opp.Latest_Customer_Category__c > 3 && sevenDayAppts[i].Type__c == Utilities.nonOpCategory )
                            {
                                if(noofdays > 1 || (noofdays ==1 && currentHour < hourValue))
                                {
                                    continue;
                                }
                            }
                            
                            /*
Appointment Converstion Change: Start
Date: 05th Sept 2013

This code handles the display & hiding of different types of Appointmetns 
depending on parameter in System label  ApptCont. 

Map displayController is constructed using System label  ApptCont and it contains :
Key--> Visit Type where converision should happen.
Value ---> contains 5 Strings 
1 Value---> Visit Type which has to be converted
2 Value---> No of days before it should happen
3 valaue--> Hour Parameter 0-23 i.e after which the conversion should start
4 value --> Decides Visit Type is available only to the one its getting converted or to Both to itself and to the one getting converted.


****************************** Example 1*********************
System label  ApptCont will contain say - Sales>Green Deal-1-16-1|
then Map will be 
<Sales==> {Green Deal, 1, 16, 1}>
this means: Green Deal Appointment will be shown avaiable for Sales world only* & not to Green Deal world at 16:00 a day before.

****************************** Example 2*********************
System label  ApptCont will contain say - Green Deal>Sales-2-09-0|
then Map will be 
<Green Deal==> {Sales, 2, 16, 1}>
this means: Sales Appointment will be shown avaiable for Green Deal world at 9:00 2 days before but they still be available to sales world in this case.

*/
                            
                            if(displayController!=null && entered && displayController.get(visitType)[0] ==sevenDayAppts[i].Type__c)
                            {
                                system.debug('***inDiaryController');
                                if((sevenDayAppts[i].Assigned_To__r.Diary_Controller__c)||(sevenDayAppts[i].Visit_Date__c > allowedDate)|| (allowedDate == sevenDayAppts[i].Visit_Date__c &&  currentHour < hourParameter))
                                {
                                    continue;
                                }
                                
                            }   
                            
                            
                            
                            if(!sevenDayAppts[i].Assigned_To__r.Diary_Controller__c && displayRestricter.containskey(visitType) && sevenDayAppts[i].Type__c ==visitType  && (sevenDayAppts[i].Visit_Date__c < allowedDate1 || (allowedDate1 == sevenDayAppts[i].Visit_Date__c &&  currentHour > hourParameter1)))
                            {
                                //system.debug('***inDiaryResticter');
                                continue;
                            }
                            /*
Appointment Conversion Changes End:
*/
                            
                            //Check if the employee has role availability set of type 'Availability' covering the appointment date selected
                            Boolean isAvailable=false;
                            Date appDate = sevenDayAppts[i].Start__c.Date();//Date.newInstance(sevenDayAppts[i].Start__c.Year(), sevenDayAppts[i].Start__c.Month(), sevenDayAppts[i].Start__c.Day());
                            
                            if(Empmap.containsKey(sevenDayAppts[i].Assigned_To__c)){
                                for(List<Date> d: Empmap.get(sevenDayAppts[i].Assigned_To__c)){
                                    if(d[0]<=appDate && d[1]>=appDate)
                                        isAvailable=true;   
                                }           
                            }   
                            if(isAvailable){   
                                
                                string startEndString  = sevenDayAppts[i].Start_Time__c +' - '+sevenDayAppts[i].End_Time__c;
                                system.debug('CF: sevenDayAppts[i].Assigned_To__c' + sevenDayAppts[i].Assigned_To__c);
                                system.debug('CF: sevenDayAppts[i].Duration_Mins_Calc__c' + sevenDayAppts[i].Duration_Mins_Calc__c);
                                system.debug('CF: sevenDayAppts[i].Id' + sevenDayAppts[i].ID);
                                system.debug('CF: sevenDayAppts[i].Id' + startEndString);
                                //Create a unique list of appointment owners so each employees name is displayed only once on the page 
                                availDataSet show = new availDataSet();
                                string uniqueString;
                                if(gDeal == '3')
                                {   
                                    /*
system.debug('##@@862'+UniqueList+uniqueList.containskey(startEndString));
if(uniqueList.containskey(startEndString))
{
//continue;
show = uniqueList.get(startEndString);
uniqueString = startEndString;
if(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c > show.TechnicalAbility || sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c == 0  || sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c == null)
continue;

}*/
                                    
                                }  
                                
                                //Change By Ashok G - start 
                                // Display all the time slots for all the Employees.. 
                                /*
system.debug('##ListTo:' + ListToHoldAllSlots);
if(ListToHoldAllSlots.size()>0){
system.debug('**I am Inside**');
for(availDataSet avail: ListToHoldAllSlots){
system.debug('** I am Inside of For__'+avail.empId+' '+sevenDayAppts[i].Assigned_To__c);
if(avail.empId == sevenDayAppts[i].Assigned_To__c && avail.slot == startEndString){
show = avail;
uniqueString = startEndString;
//startEndString = sevenDayAppts[i].Assigned_To__c;
}else{
show = Null;
UniqueString = StartEndString;
//startEndString = sevenDayAppts[i].Assigned_To__c;
}
}
}
else{
show = Null;
UniqueString = StartEndString;
//startEndString = sevenDayAppts[i].Assigned_To__c;
}
// Change End */
                                
                                //If appointment owner is not in the list yet, or they are but this appointment is for a wider slot, then add/overwrite their details
                                //if(show == null || show.duration < sevenDayAppts[i].Duration_Mins_Calc__c){                                                             
                                show = new availDataSet();
                                show.app = sevenDayAppts[i];
                                // HSA allocation CR - Starts
                                
                                show.isBestResource = false;
                                /*
if(highestAbility > 0 && opp.CHI_Lead_Type__c == 'Technical Lead'){

if(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c != null)

if(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c <= highestAbility){

show.isBestResource = true;

}

}else if(highestAbility > 0 && opp.CHI_Lead_Type__c == 'Conversion Lead'){

if(EmpSalesSkillMap.get(sevenDayAppts[i].Assigned_To__c).Sales_Efficiency__c != null)

if(EmpSalesSkillMap.get(sevenDayAppts[i].Assigned_To__c).Sales_Efficiency__c <= highestAbility){

show.isBestResource = true;

}

}  */
                                
                                //HSA allocation CR - Ends
                                
                                show.setEmpFirstName(String.valueOf(sevenDayAppts[i].Assigned_To__r.First_Name__c));
                                show.setEmpLastName(String.valueOf(sevenDayAppts[i].Assigned_To__r.Last_Name__c));
                                show.setEmpId(String.valueOf(sevenDayAppts[i].Assigned_To__c));
                                show.setappointmentId(String.valueOf(sevenDayAppts[i].Id));
                                show.setduration(double.valueof(sevenDayAppts[i].Duration_Mins_Calc__c));
                                show.setAppointmentCount((numberofApptsMap.get(sevenDayAppts[i].Assigned_To__c)/totalnumberofApptsMap.get(sevenDayAppts[i].Assigned_To__c)));
                                //show.setduration(double.valueOf(totalnumberofApptsMap.get(sevenDayAppts[i].Assigned_To__c)));
                                //show.setAppointmentCount(double.valueOf(numberofApptsMap.get(sevenDayAppts[i].Assigned_To__c)));
                                show.Slot = startEndString;
                                show.setTechnicalAbility(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c!=null ?sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c:9999  );
                                show.setSalesEfficiency(String.valueOf(EmpSalesSkillMap.get(sevenDayAppts[i].Assigned_To__c).Sales_Efficiency__c));
                                if(sevenDayAppts[i].Assigned_To__r.HSA_Employment_Type__c != null){
                                    show.setHsaEmployeeType(String.valueOf(sevenDayAppts[i].Assigned_To__r.HSA_Employment_Type__c));
                                }else{
                                    show.setHsaEmployeeType('');
                                }
                                Date appDate2 = sevenDayAppts[i].Start__c.date();//Date.newInstance(sevenDayAppts[i].Start__c.Year(), sevenDayAppts[i].Start__c.Month(), sevenDayAppts[i].Start__c.Day());
                                //Determine the employees 'ongoing availability' status for this subpatch - preffered, backup or pool
                                for(integer k=0;k<Emps.Size();k++){
                                    if((Emps[k] == sevenDayAppts[i].Assigned_To__c && empSubRoleType[k] == 'Ongoing'
                                       && empSubRoleStDate[k]<= appDate2 && empSubRoleEdDate[k]>= appDate2) ||(Emps[k] == sevenDayAppts[i].Assigned_To__c&& Remote_Quote_Product__c.getInstance(Opp.product_interest__c) != null ))                        
                                       show.setEmpStatus(empSubRoleStatus[k]);                                                                                                                                     
                                }                                                                                    
                                //uniqueList.put(startEndString, show);  
                                ListToHoldAllSlots.add(show);
                                
                                system.debug('@@@New ListToHoldAllSlots-->'+ListToHoldAllSlots);
                                //}                                                                   
                            }                                                                 
                        }
                    //Return all the unique values to the datatable     
                    system.debug('--->'+ListToHoldAllSlots);    
                    /*if(gDeal == '3'){
for(availDataSet ads : uniqueList.values()) { 
retList.add(ads);
}
system.debug('retList contains '+retList);
}
else{*/
                    for(availDataSet ads : uniqueList.values()) { //uniqueList.values()
                        retList.add(ads);
                    }
                    
                    // }
                    ListToHoldAllSlots= randomAppointment(ListToHoldAllSlots);
                    ListToHoldAllSlots.sort();
                    return ListToHoldAllSlots;     
                }  
        //return null;  
        
    }
    
    // IntegratedScript changes
    public boolean getIsSF() {
        if(source == 'SF')
            return true;
        else
            return false;
    }
    
    
    // end IntegratedScript changes
    /*
private List<availDataSet> qSort(List<availDataSet> entriesTosort) {

System.debug('Entries to sort size : '+entriesTosort.size());

if(entriesTosort.isEmpty() || entriesTosort.size() == 1){

if(entriesTosort.size() == 1){

System.debug('Entries to sort of size one : '+entriesTosort[0].empLastName);

}  

return entriesTosort;

}

// Pick the entriesToPlan from the end of the list - this will act as the 
// "pivot". All other entriesToPlan will be compared to this one.
availDataSet middle = entriesTosort.remove(entriesTosort.size()-1);

// We create two lists, "left" and "right" - left holds entriesToPlan smaller
// than the pivot, right holds the ones the same or bigger than the pivot

List<availDataSet> left = new List<availDataSet>();
List<availDataSet> right = new List<availDataSet>();

// Loop over the remaining options and store each one in the appropriate list, left
// if it is "better than" the pivot, right if it is the same or worse. The 
// "betterThan" method is used to determine which list it should go into

for(availDataSet a : entriesTosort) {
if(betterThan(a,middle)) { // better = left, same or worse = right
left.add(a);
} else {
right.add(a);
}
}

// We now call this method again for each of the lists we have created above

left = qSort(left);
right = qSort(right);

// We now store all options in the one list (including the pivot), in order
left.add(middle);
left.addAll(right);
return left;
}
private Boolean betterThan(availDataSet first, availDataSet second) {

//  HSA availability CR Starts  

if(opp.CHI_Lead_Type__c == 'Conversion Lead'){

//  HSA availability CR Ends  

if(first.SalesEfficiency == null)
return false;
else if(second.SalesEfficiency == null)
return true;
else if(first.SalesEfficiency == null && second.SalesEfficiency == null)
return false;
else if(first.SalesEfficiency<second.SalesEfficiency)
return true;
else if(first.SalesEfficiency>second.SalesEfficiency)
return false;
else if(first.SalesEfficiency==second.SalesEfficiency)
return false;

} // HSA availability CR Starts  

else if(opp.CHI_Lead_Type__c == 'Technical Lead'){

if(first.TechnicalAbility == null)
return false;
else if(second.TechnicalAbility == null)
return true;
else if(first.TechnicalAbility == null && second.TechnicalAbility == null)
return false;
else if(first.TechnicalAbility < second.TechnicalAbility)
return true;
else if(first.TechnicalAbility > second.TechnicalAbility)
return false;
else if(first.TechnicalAbility == second.TechnicalAbility)
return false;

}

// HSA availability CR Ends 

return false;

} */
    
 private List<availDataSet> RandomAppointment(List<availDataSet> ListToHoldAllSlots){
      
        List<availDataSet> randomApps = new List<availDataSet>();
        map<String, List<availDataSet>> timeSlotMap = new map<String, List<availDataSet>>() ;
        for(availDataSet a:ListToHoldAllSlots)
        {
            if(timeSlotMap.containsKey(a.slot))
            {
                timeSlotMap.get(a.slot).add(a);
            }
            else
            {
                 timeSlotMap.put(a.slot,new List<availDataSet>{a});
            }
        }
        for(String key:timeSlotMap.keySet())
        {
            List<availDataSet> tempList = timeSlotMap.get(key);
            if(Remote_Quote_Product__c.getInstance(Opp.product_interest__c) != null)
            {
                List<availDataSet> tempPrimary = new List<availDataSet>();
                List<availDataSet> tempSecondary = new List<availDataSet>();
                    for(availDataSet ad: templist)
                    {
                        if(ad.empStatus=='Primary')
                           tempPrimary.add(ad); 
                        else
                           tempSecondary.add(ad);
                    }
                    tempList.clear();
                    if(tempPrimary.size()>0)
                    {
                        tempList.AddAll(tempPrimary);
                    }
                    else
                    {
                       tempList.AddAll(tempSecondary); 
                    }
            }
            
            if(system.label.Guided_Sale=='on')
            {
               map<String, List<availDataSet>> appCountMap = new map<String, List<availDataSet>>() ;
               for(availDataSet a:tempList)
               {
                      if(appCountMap.containsKey(String.valueOf(a.appointmentCount)))
                      {
                             appCountMap.get(String.valueOf(a.appointmentCount)).add(a);
                      }
                      else
                      {
                             appCountMap.put(string.valueOf(a.appointmentCount),new List<availDataSet>{a});
                      }
               }
               
               for(String k:appCountMap.keySet())
               {
                   if(appCountMap.get(k).size()>1)
                   {
                        Integer rand = (Math.random() * appCountMap.get(k).size()).intValue();
                        if(rand >= appCountMap.get(k).size())
                        rand = appCountMap.get(k).size()-1;
                        randomApps.add(appCountMap.get(k)[rand]);
                   }
                   else
                   {
                       randomApps.addAll(appCountMap.get(k));
                   }
               }
            
            }
            else
            {
            
               Integer rand = (Math.random() * tempList.size()).intValue();
               if(rand >= tempList.size())
               rand = tempList.size()-1;
               randomApps.add(tempList[rand]);
            }
        }
        
        return randomApps;
}
}