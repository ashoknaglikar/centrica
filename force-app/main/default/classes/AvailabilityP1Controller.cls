public class AvailabilityP1Controller {
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class for visualforce page 'availiability'. Logic to find and display available      //
    //appointments depending on app type (sales/survey), app urgency (urgent/standard), and Postcode  //
    //on Account of CHI Lead. Checks that employee Role Sub Patch availiability is entered for the    //
    //dates in view, and checks Role District availiability for the pool when it is included i.e. when// 
    //apointment urgency is 'Urgent'.                                                                 //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // ++ Updated opp variable for Priority Installation CR start
    public Opportunity thisOpp {get; set;}
    
    // -- Updated opp variable for Priority Installation CR end
    
    //++ Priority Installation CR start
    public boolean include_priority_install {get; set;}  
    public boolean customerCategoryMessage {get; set;}
    public boolean isFirstCategory {get; set;}
    public boolean isSecondCategory {get; set;}
    public boolean isThirdCategory {get; set;}
    public boolean isFourthCategory {get; set;}
    public boolean isUndefinedCategory {get; set;}
    public boolean isNoSuitableAppointment {get; set;}
    public Job__c job{get;set;}
    public boolean useOFS{get;set;}
    public boolean nonCommercial {get;set;}
    //Changes done to display both summary and 2hr view on the same screen by default
    public List<availDataSet> SummaryView {get; set;}
    public List<availDataSet> TwoHrView {get; set;}
    public boolean isHSA{get;set;}
    //Changes done for No suitable appointments
    boolean NoSuitable=null;
    
    // CR MC014
    boolean showCancelButton = null;
    // End CR MC014
    // CR MC011
    boolean showAvailability = true;
    // End CR MC011    
    String postCodeSubPatch = null;
    String postCodeDistrict = null;
    String displayMessage;
    String visitType;  
    //Get parameters from the page URL.
    // IntegratedScript changes
    String ffParameters = null;
   
    String chiLeadID = System.currentPageReference().getParameters().get('var_OpptyId');
    String contactId = System.currentPageReference().getParameters().get('var_contactId');
    String source = System.currentPageReference().getParameters().get('var_Source');
    
    String activeURLDate = System.currentPageReference().getParameters().get('var_date');
    String twoHrURLView = System.currentPageReference().getParameters().get('var_view');
    String currentApp = System.currentPageReference().getParameters().get('var_cancelledapp');
    String callID = System.currentPageReference().getParameters().get('var_CallId');
    string pcr = System.currentPageReference().getParameters().get('var_Pcr');
    string scr = System.currentPageReference().getParameters().get('var_Sec');
    String NoSuitaleStr = System.currentPageReference().getParameters().get('var_NoSuitable');
    // end IntegratedScript 
    boolean newInbound = System.currentPageReference().getParameters().get('new')=='true'?true:false;
    
    String productInt = System.currentPageReference().getParameters().get('productInt');
    boolean existingLead = System.currentPageReference().getParameters().get('existingLead')=='true'?true:false;
     
    Date activeDate;   
    Integer colNo;
    static Integer noDays=7;    
    //Define the appointment period start and end times for 2 hour time slots. Array positions must correspond.  
   
    // CR For Diary Start & End Time Changes Starts
    
    integer [] startHour2hr = new integer[]{7,9,11,13,15,17,19};
    integer [] endHour2hr =   new integer[]{9,11,13,15,17,19,20};
    
    // CR For Diary Start & End Time Changes Ends
    
   
    // CR For Diary Start & End Time Changes Starts
   integer [] startMinutes2hr = new integer[]{0,0,0,0,30,30,0};
   integer [] endMinutes2hr =   new integer[]{0,0,0,30,30,0,30};
    // CR For Diary Start & End Time Changes Ends
    
   //Define the appointment period start and end times for period appts. Array positions must correspond. 
   // CR For Diary Start & End Time Changes Starts
   integer [] startHourHlf = new integer[]{7, 13, 17, 7};
   integer [] endHourHlf =   new integer[]{13, 17, 19, 21};
   // CR For Diary Start & End Time Changes Starts
   
    // CR For Diary Start & End Time Changes Starts
   integer [] startMinutesHlf = new integer[]{0,0,30,0};
   integer [] endMinutesHlf =   new integer[]{0,30,30,0};
    // CR For Diary Start & End Time Changes Ends
    
    // CR for SS
   integer [] startHourSS = new integer[]{6, 12, 17, 6};
   integer [] endHourSS =   new integer[]{13, 18, 21, 21};
   integer [] startMinutesSS = new integer[]{0,0,0,0};
   integer [] endMinutesSS =   new integer[]{0,0,0,0}; 
   
    //Define the appointment period labels to display on the availability page for 2 hour appts and period appts 
  
    // CR For Diary Start & End Time Changes Starts
    String [] timeTitle2hr = new String[] {'07:00-09:00','09:00-11:00','11:00-13:00','13:00-15:30','15:30-17:30','17:30-19:00','19:00-20:30'};
    String [] timeTitlehlf = new String[] {'AM','PM','Evening','Any Time'};
    // CR For Diary Start & End Time Changes Ends
    
    //Define days of the week and months of year to display on availability page. Element 0 in array must be the 'start of week/year' element .
    String [] dayOfWk = new String [] {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};
    String [] monthOfyr = new String [] {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
    
    //Added on 14th June 2011, as a part of Salesforce HSA allocation CR .
    Double highestSalesOrTechnicalAbility = 0;
    
    // ++ GD change start.
    public  string gDeal {get;set;}
    
    public boolean greenDeal {get;set;}
    Utilities util  = new Utilities();
    // -- GD change start.
    
    string nonOpCategory; // added for Non operational type
    Integer currentHour = datetime.now().hour(); // get the current Hour value
    date weekEndDate {get; set;}
    boolean isNoBestApptFound {get; set;}
    string priorityType {get; set;}
    date bestApptDate {get; set;}
    map<string, list<string>> displayController; 
    map<string, list<string>> displayRestricter; 
    /////////////////////
    //Constructor class//
    /////////////////////
    
    public AvailabilityP1Controller() {
      isHSA=false;
      if(system.label.CHI_HSA_ProfileId.contains(userinfo.getProfileId()))
      {
          isHSA=true;
      }
      nonCommercial = source=='CS'?false:true;
      gDeal = System.currentPageReference().getParameters().get('gDeal');
      //System.debug('====Calling Controller====');
      // ++ GD change start.
      greenDeal = gDeal== '1'?true:false;
      useOFS = false;
      //Appointment Conversion Change: Start
      displayRestricter = new map<string, list<string>>();
      displayController = new map<string, list<string>>();
      if(system.label.AppointmentCont.contains('|'))
      {
        //system.debug('***in if***');
          for(string s: system.label.AppointmentCont.split('\\|'))
          {
            //system.debug('***2in if***');
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
      //system.debug('Disply---->'+displayController);
      //Appointment Conversion Change: End
      
      // -- GD change start.
      
        thisOpp = new Opportunity();
        //System.debug('Getting opportunity with ID: ' + chiLeadID);
        
        // HSA allocation CR - Starts
                
        highestSalesOrTechnicalAbility = 0;
        
        if(activeURLDate == 'null')
        {
            activeDate = date.today().toStartOfWeek();
            weekEndDate = (activeDate + integer.valueOf(system.label.AppointmentEndDateThreshold));
        }
            
        else{
            Integer diff = date.today().daysBetween(date.valueOf(activeURLDate));
            activeDate = date.valueOf(activeURLDate).toStartOfWeek();
            }
        
        thisOpp = [Select o.id , o.Name , o.AccountID, o.CHI_Lead_Type__c, o.Referral_Employee__r.Salesforce_User__c , o.Referral_Employee__r.Resource_Type__c , o.Account.BillingPostalCode, o.Account.Primary_Contact__r.Name , o.Account.Primary_Contact__c , o.Visit_Type__c, o.Urgency__c,Product_Interest__c , o.Timeline_Options__c , o.Timeline_Reason__c , 
                   CreatedDate , Latest_customer_category__c ,customer_category_controller__c, CHI_Lead_Id__c, Latest_customer_category_indicator__c,Secondary_Product_Interest__c, Account.Landlord_Account__c, Landlords_permission__c From Opportunity o where Id = :chiLeadID];
        
        if(productInt!=null)
        {
            thisOpp.product_interest__c = productInt;
        }
        
        if(thisOpp.Account.Landlord_Account__c )
        {
            if( thisOpp.Landlords_permission__c != 'Yes')
            {
                displayMessage = 'Landlord has not granted the permission for sales appointment.';
                return;
            }else
            {
                list<string> landlordTypes = new list<string>{'Landlord', 'Agent','Multi-premise'};
                boolean lanldLordExist = false;
                for(Contact c :[Select id , Contact_Type__c , MobilePhone, OtherPhone, HomePhone, Email from Contact where AccountId = :thisOpp.AccountId])
                {
                    if(c.MobilePhone!=null || c.OtherPhone!=null || c.HomePhone !=null || c.Email!=null )
                    {
                        lanldLordExist = true;
                        break;
                    }
                }
                
                if(!lanldLordExist)
                {
                    displayMessage = 'Landlord/Agent/Multi-premise contact details have not been captured.';
                    return;
                }
            }
            
        }
        
        // HSA allocation CR - Ends
        // ++ GD change start.
        if(gDeal=='1')
        {
            visitType = 'Green Deal';
            thisOpp.Secondary_Product_Interest__c='Green Deal';
        }
        else
            visitType = thisOpp.Visit_Type__c;
      
       if((thisOpp.Latest_customer_category__c == 1 || thisOpp.Latest_customer_category__c == 2 || thisOpp.Latest_customer_category__c == 3) && (gDeal == '0' || gDeal == '3'))
        {
            nonOpCategory = Utilities.nonOpCategory;
        }
      
         //Change By Ashok G --  WP10874 
         /*List<string> CAT = thisOpp.customer_category_controller__c.split(':');
         system.debug('=============================>CAT'+CAT);
         if(CAT.size()>0 ){
            for(string str: CAT){
              if(gDeal == '0' || gDeal == '3')
              nonOpCategory = Utilities.nonOpCategory;
              
              if(str == '1' && thisOpp.Latest_customer_category__c == 1){
                  isFirstCategory = true; 
              }else if(str == '2' && thisOpp.Latest_customer_category__c == 2){
                  isSecondCategory = true;
               }else if(str == '3' && thisOpp.Latest_customer_category__c == 3){
                  isThirdCategory = true;
               }else if(str == '4' && thisOpp.Latest_customer_category__c == 4){
                  isFourthCategory = true;
               }else{
                  isUndefinedCategory = true;
               }            
            }
         }*/
         //Change End
      
        // -- GD change start.
        //++ Priority Installation CR start  
        if(gDeal == '1')
          include_priority_install = false;
          
        else if((thisOpp.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date))
        {
          include_priority_install = true;
        }
        else
        {
          include_priority_install = false;
        }
        if(include_priority_install)
        {
          thisOpp.Timeline_Options__c = '';
          thisOpp.Timeline_Reason__c = '';
        }
        if(thisOpp.Latest_customer_category__c == 1)
        {
          isFirstCategory = true;
        }
        else if(thisOpp.Latest_customer_category__c == 2)
        {
          isSecondCategory = true;
        }
        else if(thisOpp.Latest_customer_category__c == 3)
        {
          isThirdCategory = true;
        }
        else if(thisOpp.Latest_customer_category__c == 4)
        {
          isFourthCategory = true;
        }
        else
        {
          isUndefinedCategory = true;
        }
        
        
        //-- Priority Installation CR end
        
        colNo=0;
        
        displayMessage = '';
                
        //Set the date of the first day to display availability for in the availability page. 
        
         job = new Job__c();
         if(activeURLDate!='null')
         job.Delivery_Date__c = date.valueOf(activeURLDate);       
        //Changes done for No Suitable Appointments
        if(NoSuitaleStr == 'true')
            NoSuitable=true;        
        else
            NoSuitable=false; 
        //System.debug('=======BooleanFlags====='+NoSuitaleStr+NoSuitable);      
                       
        // IntegratedScript changes
        ffParameters = Utilities.buildParameterString(System.currentPageReference(), null);
        if(ffParameters.length() > 1)
            ffParameters += '&';
        // end IntegratedScript
        
        // CR MC011
        // Select out any Sales Appointments relating to this Opportunity from the
        // database. 
        // ++ GD Change Start
        if(visitType== 'Sales' || gDeal!='0' || nonOpCategory != null) 
        {
          
          Appointment__c[] relatedApps = [SELECT a.Id, a.Type__c, a.Status__c 
                                          FROM Appointment__c a 
                                          WHERE a.Opportunity__c = :chiLeadID
                                          AND a.Start__c >= :Datetime.now()
                                          AND a.Type__c = :visitType
                                          AND a.Status__c = 'Appointed'];
          //System.debug('relatedApps.size(): ' + relatedApps.size());
          // Check if we were returned any Appointments, if we are trying to book a Sales Appointment 
          // and that we haven't been passed an Appointment ID to cancel
          if(!relatedApps.isEmpty()) {
              
              // A string to store the ID of any Appointed Sales Appointments
              List<String> activeSalesApps = new List<String>();
              
              // Loop over each of the related Appointments...
              for(Appointment__c app : relatedApps) {
                  // There's already an Appointed Sales Appointment against this Opportunity,
                  // store the ID of this Appointment in the string. We need to check that
                  // the ID of the current Appointment is not the same as the Appointment
                  // the user has asked to cancel... We do this with "startsWith" because we
                  // may be passed a 15 or 18 digit ID. This means using a temporary variable
                  // as startsWith does not work on an ID. 
                  String temp = app.Id;
                  if(!temp.startsWith(currentApp)) {
                      //System.debug('Adding active sales appointment');
                      activeSalesApps.add(app.Id);
                  }
              }
  
              if(!activeSalesApps.isEmpty()) {
                  if(activeSalesApps.size() > 1) {
                      //System.debug('activeSalesApps.size(): ' + activeSalesApps.size());
                      // There is more than one active Sales Appointment, therefore we warn that an Appointment
                      // should not be booked until other Appointments are cancelled. We do not prevent further
                      // progress in the Call Centre booking screen; however, if the user clicks "Book now",
                      // they will be presented with an error at that stage.
                      displayMessage = 'Warning: CHI Lead ' + thisOpp.CHI_Lead_Id__c + ' has more than one active '+visitType+' Appointment ' +
                                      'booked. You will not be able to book an Appointment until all, or all but one of ' +
                                      'the Appointments are cancelled.';
                      showAvailability = false;
                  } else if(currentApp == 'null') {
                      //System.debug('activeSalesApps.size() = 1 and currentApp == null');
                      // Must be just the one activeSalesApp, and we have not been asked to cancel an Appointment
                      // as the currentApp parameter is null. Therefore, we can populate the currentApp variable
                      // with the Appointment ID that we found. 
                      currentApp = activeSalesApps.get(0);
                      displayMessage = 'Warning: CHI Lead ' + thisOpp.CHI_Lead_Id__c + ' already has a '+visitType+' Appointment booked. ' +
                                      'Booking an Appointment here will cancel the existing Appointment.';                    
                  } else if(!(thisopp.CHI_Lead_Type__c == 'Technical Lead' || thisopp.CHI_Lead_Type__c == 'Conversion Lead')) {
                      displayMessage = 'CHI Lead Type is blank so can not fetch the availability.';
                      showAvailability = false;
                  } else {
                      //System.debug('activeSalesApps.size() = 1 and currentApp != null');
                      // currentApp is not null (i.e. we have been asked to cancel an Appointment) but we have
                      // found another active Appointment. Need to warn the user that they will not be able
                      // to book an Appointment.
                      displayMessage = 'Warning: CHI Lead ' + thisOpp.CHI_Lead_Id__c  + ' has a '+visitType+' Appointment booked other than ' +
                                      'the Appointment you are trying to cancel. You will not be able to book an ' + 
                                      'Appointment until all, or all but one of the Appointments are cancelled.';
                      showAvailability = false;
                  }
              }
          }
        }
        
        // End CR MC011
        // CR MC013
        /*
        else if(thisOpp.Visit_Type__c == 'Survey') {
            Appointment__c[] relatedApps = [SELECT a.Id, a.Type__c, a.Status__c 
                                            FROM Appointment__c a 
                                            WHERE a.Opportunity__c = :chiLeadID
                                            AND (a.Status__c = 'Happened' OR
                                                 a.Status__c = 'Appointed') 
                                            AND a.Type__c = 'Sales'];
            if(relatedApps.isEmpty()) {
                displayMessage = 'Warning: CHI Lead ' + chiLeadID + ' has not had a Sales Appointment. ' +
                                 'You are still able to book a Survey Appointment here if you are sure no Sales Appointment ' +
                                 'is needed.' ;
            }       
        }  */      
        // End CR MC013
        // CR MC014
        //Check URL parameter to see if we should be showing the Cancel Appointment button
        if(currentApp == 'null') {
            //System.debug('currentApp is null');
            showCancelButton = false;   
        } else {
            //System.debug('currentApp is not null');
            showCancelButton = true;
        }
        // End CR MC014 
        isNoBestApptFound = false;  
        
        //Changes done to display both summary and 2hr view on the same screen by default
        getAvailability();
    }
        
    //Evaluate if app status is urgent
    public String urgency(){     //thisOpp.Urgency__c == 'Urgent' Replaced with Customer_Category_Controller
     if(thisOpp.customer_category_controller__c == 'Priority')
            return 'urgent';
        else
            return 'standard';
    }
    
    /////////////////////////////////////////////////////////
    //Availability page button functionality defined below.//
    /////////////////////////////////////////////////////////
   
    //***FireFly URL Required*** Set availability page 'Exit' button URL redirect value depending on source being Salesforce or FireFly.     
    public PageReference onClickExit() {
        // IntegratedScript changes      
        //if SF
        if(source == 'SF' || source == 'CS') {
            PageReference pageRef = new PageReference('/' + chiLeadId);
            pageRef.setRedirect(true);
            return pageRef;
        }/* else if(source == 'FF') {
            PageReference pageRef = new PageReference('https://bgschi.sparkstudiosaas.com/webredirect'+ffParameters+'&FIREFLY_NAVIGATION=NEXT');
            pageRef.setRedirect(true);
            return pageRef;
        } else if(source == 'PF') {
            PageReference pageRef = new PageReference('/apex/AccountSearchResults?'+
                                                       'var_postcode='+thisOpp.Account.BillingPostalCode);
            pageRef.setRedirect(true);
            return pageRef;
        }*/
        else if(source == 'IC') //block to integrate apointment with Inbound call module 
        {   
            PageReference pageRef;
            if(!newInbound)
            pageRef = new PageReference('/apex/WorkflowPage?'+ 'a=1&c='+callID+'&e=1');
            else
            pageRef = new PageReference('/apex/new_Wrapupscreenpage?chiLeadId='+chiLeadId+'&accId='+thisOpp.AccountId+'&new='+newInbound);           
            
            pageRef.setRedirect(true);
            return pageRef;
        }else if(source == 'ICL') //block to integrate apointment with Inbound call module 
        {   
            PageReference pageRef;
            if(newInbound)
            pageRef = new PageReference('/apex/new_Wrapupscreenpage?chiLeadId='+chiLeadId+'&accId='+thisOpp.AccountId+'&new='+newInbound);
            else
            pageRef = new PageReference('/apex/Wrapupscreenpage?chiLeadId='+chiLeadId+'&accId='+thisOpp.AccountId);
                       
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        else {
            return null;
        }
        // end IntegratedScript changes 
    }
   
    //View availabilty for the next week (7 days forward)
    public PageReference onClickForward7() {
        // IntegratedScript changes
        PageReference pageRef = new PageReference('/apex/availability'+ffParameters+'var_OpptyId='+chiLeadID+'&var_view=null'+'&var_contactId='+contactId+'&var_Source='+source+'&var_date='+string.valueOf(activeDate.addDays(noDays))+'&var_cancelledapp='+currentApp+'&var_CallId=' + callID+'&gDeal='+gDeal+'&var_NoSuitable='+NoSuitable);                                                                                                   
        // end IntegratedScript changes
        pageRef.setRedirect(true);      
        return pageRef;                            
    }
    //View availabilty for the previous week (7 days backwards)
    public PageReference onClickBack7() {
        // IntegratedScript changes
        PageReference pageRef = new PageReference('/apex/availability'+ffParameters+'var_OpptyId='+CHIleadId+'&var_view=null'+'&var_contactId='+contactId+'&var_Source='+source+'&var_date='+string.valueOf(activeDate.addDays(-noDays))+'&var_cancelledapp='+currentApp+'&var_CallId=' + callID+'&gDeal='+gDeal+'&var_NoSuitable='+NoSuitable);                                                                                                 
        // end IntegratedScript changes
        pageRef.setRedirect(true);      
        return pageRef;                                   
    }
    
    // CR MC014
    // Cancel the existing Appointment without booking a new one.
    public PageReference onClickCancel() {
        // Cancel the appointment
        // ashok CR 2 Change Start 
       // Appointment__c cancelledApp = new Appointment__c(id=currentApp, Status__c='Cancelled', Status_Reason__c='Other');
       Appointment__c cancelledApp = new Appointment__c(id=currentApp, Status__c='Cancelled', Primary_Cancellation_Reason__c='Cancelled - Automatic Rearrange', Secondary_Cancellation_Reason__c='Cancelled - Automatic Rearrange');
       // Ashok CR 2 End
        Integer result;
        try {
            Database.SaveResult updateResult = Database.update(cancelledApp);
            if(!updateResult.isSuccess()) {
                Database.Error err = updateResult.getErrors()[0];
                cancelledApp.addError('Error cancelling appointment. Message received: ' + err.getMessage());
                result = 8;     
            } else
                result = 7;
        } catch (Exception exc) {
            cancelledApp.addError('Error cancelling appointment an exception was thrown');
            //System.debug('Exception thrown trying to cancel appointment: ' + exc);
            result = 9;         
        }
        
        // IntegratedScript changes
        PageReference pageRef = new PageReference('/apex/availability3'+ffParameters+'var_date=null&var_period=null&var_bookedAppId=null&var_cancelledAppId='+cancelledApp.Id+'&var_result='+result+'&var_OpptyID='+chileadId+'&var_Source='+source+'&var_CallId=' + callID+'&gDeal='+gDeal);
        // end IntegratedScript changes                                                                                                  
        pageRef.setRedirect(true);
        return pageRef;
    }
    // End CR MC014
    

    //Changes done to fetch no suitable appointments
    public void onClickNoSuitable(){
        NoSuitable = !NoSuitable; 
        getAvailability();     
        //PageReference pageRef = new PageReference('/apex/availability'+ffParameters+'var_OpptyId='+CHIleadId+'&var_contactId='+contactId+'&var_Source='+source+'&var_date='+string.valueOf(activeDate)+'&var_cancelledapp='+currentApp+'&var_CallId=' + callID+'&gDeal='+gDeal+'&var_NoSuitable='+NoSuitable);        
        //pageRef.setRedirect(true);
        //return pageRef;
    }
    
    public PageReference onClickGo(){
        if(job.Delivery_Date__c!=null){      
            PageReference pageRef = new PageReference('/apex/availability'+ffParameters+'var_OpptyId='+CHIleadId+'&var_view=null'+'&var_contactId='+contactId+'&var_Source='+source+'&var_date='+string.valueOf(job.Delivery_Date__c)+'&var_cancelledapp='+currentApp+'&var_CallId=' + callID+'&gDeal='+gDeal+'&var_NoSuitable='+NoSuitable);                                                                                                    
            pageRef.setRedirect(true);      
            return pageRef;
         } 
         else{
             displayMessage = 'Please select some date.';
             return null;
         } 
    }
    
    public pagereference onClickLLPage(){
        return new PageReference('/apex/captureLandlordDetails?edit='+1+'&chiLeadId='+CHIleadId+'&accId='+thisOpp.AccountId);    
    }   
    
    ///////////////////////////////////////////////////////////////////
    //Availability page 'getter' methods to display data to the user.//
    //All methods are called from the availability page itself.      //
    ///////////////////////////////////////////////////////////////////
   
    // CR MC014
    //Only show 'Cancel Current Appointment' button if current App exists
    public boolean getshowCancelButton() {
        return showCancelButton;
    }
    // End CR MC014
    
    //Added on 14th June 2011, as a part of Salesforce HSA allocation CR .
    
    public Double getHighestSalesOrTechnicalAbility() {
        return highestSalesOrTechnicalAbility;
    }
    
    //Only show 'Hand To Support' button on page if page was launched from FireFly, else hide.
    public boolean getshowButton(){      
        boolean showButton;
        if(source=='SF')
            showButton = true;
        else
            showButton = false;
        return showButton;
    }    
    //Set the label on the view button displayed to the user depending on current view
    /*public string gettwoHrLabel(){
        if(twoHourView)     
            return 'Summary View';
        else
            return '2 Hour View';
    } */
    
    //Set the label of the no suitable appointments button or normal appointments button
    public string getNoSuitableLabel(){
        if(NoSuitable==true)     
            return 'Normal Appointments';
        else
            return 'No Suitable Appointments';
    } 
    
    //calculate which date a user clicked on to book an appointment     
    public string getactiveDate0(){
        return selectedDate(0);
     }
     
    public string getactiveDate1(){             
        return selectedDate(1);
     }
     
    public string getactiveDate2(){             
        return selectedDate(2);
     }
     
    public string getactiveDate3(){             
    return selectedDate(3);
     }
     
    public string getactiveDate4(){             
        return selectedDate(4);
     }
     
    public string getactiveDate5(){             
        return selectedDate(5);
     }
     
    public string getactiveDate6(){             
        return selectedDate(6);
     }
    //Date URL parameter to pass to availability2 page, indicates which date user clicked one to book appointment for 
    public string selectedDate(integer days){
        string activeDateString = string.valueOf(activeDate.addDays(days));
        return activeDateString;
     }
    //getter method to set the URL parameter string which is passed to availability2 page from availability page
    public String getparameterString() {
        // IntegratedScript changes
        
        if(gDeal=='1')
        {
            visitType = 'Green Deal';
        }
        else if(nonOpCategory != null)
        {
            visitType = nonOpCategory;
        }
        else
        {
            visitType = 'Sales';
        }
       
        string parameterString = 'availability2' + ffParameters
                                    + 'var_OpptyId='+chiLeadID+'&var_Source='+source+'&var_type='+visitType+'&var_view=null'+'&var_postCode='
                                    +thisOpp.Account.BillingPostalCode+'&var_subPatch='+postCodeSubPatch
                                    +'&var_district='+postCodeDistrict+'&var_urgency='+urgency()+'&var_contactId='
                                    +contactId+'&var_cancelledapp='+currentApp + '&var_CallId=' + callID+'&var_Pcr='+pcr+
                                    '&var_Sec='+scr +'&var_Prio_Type='+priorityType+'&var_NoSuitable='+NoSuitable+'&var_OFS='+(useOFS?'t':'f'+'&productInt='+thisOpp.Product_Interest__c);
        // endIntegratedScript changes 
                                    
        return parameterString;
    }
    //Create title for the days column in availability page. Translates activedate to 'day - day number - month' text
    public String getdayTitle(integer day) {
        integer titleDayNum = activeDate.addDays(day).day();                    
        integer titleMonth = activeDate.addDays(day).month() - 1;
        integer noDaysAfterMon = activeDate.addDays(day).toStartOfWeek().daysBetween(activeDate.addDays(day));                      
        String title = dayOfwk[noDaysAfterMon] + ' ' + titleDayNum + ' ' + monthOfyr[titleMonth];
        return title;           
    }
        
    public String getday0Title() {
        return getDayTitle(0);
    }
        
    public String getday1Title() {
        return getDayTitle(1);
    }
        
    public String getday2Title() {
        return getDayTitle(2);
    }
        
    public String getday3Title() {
        return getDayTitle(3);
    }
        
    public String getday4Title() {
        return getDayTitle(4);
    }
        
    public String getday5Title() {
        return getDayTitle(5);
    }
        
    public String getday6Title() {
        return getDayTitle(6);
    }

    public Opportunity getOpportunity (){     
        return(thisOpp);
    }
    
    public Date getStartofWeek() {       
        return activeDate.toStartOfWeek();  
    }
    
    public String getdisplayMessage() {     
        return displayMessage;
    }   
       
    //////////////////////////////////////////////////////
    //Define properties of the dataset for the datatable//  
    //to iterate over in the availability page          //
    //////////////////////////////////////////////////////
    
    public class availDataSet {
          
        public String timeTitle;
        public Integer timeTitleStartHour;
        public Integer timeTitleEndHour;
        
       // CR For Diary Start & End Time Changes Starts. Added two additional parameters for storing minutes information.
       
        public Integer timeTitleStartMinute;
       
        public Integer timeTitleEndMinute;
       
        public void settimeTitleStartMinute(Integer tt) {
            timeTitleStartMinute = tt;
        }
        
        public void settimeTitleEndMinute(Integer tt) {
            timeTitleEndMinute = tt;
        }
        
       // CR For Diary Start & End Time Changes Ends.
                 
        public Boolean [] daysAvailable = new Boolean [noDays];
        public Boolean [] poolAvailable = new Boolean [noDays];
        public long [] availableminutes  = new long [noDays];
        public long [] commercialMinutes = new long [noDays];
        
        
        public long[] getcommercialMinutes()
        {
            return availableminutes;
        }
        
        public void setcommercialMinutes(long[] commercialMinutes)
        {
            commercialMinutes= commercialMinutes;
        }
        public long[] getavailableminutes()
        {
            return availableminutes;
        }
        public void setavailableminutes(long[] availableminutes)
        {
            availableminutes= availableminutes;
        }
        
        // HSA allocation CR - Starts
        public Boolean [] availabilityColor = new Boolean [noDays];
        // HSA allocation CR - Ends
        //Constructor - initially set availability to false for all days 
        public availDataSet(){          
            for(integer i=0; i<noDays; i++){
                daysAvailable[i]=false;
                poolAvailable[i]=false;
                // HSA allocation CR - Starts
                availabilityColor[i]=false;
                // HSA allocation CR - Ends
            }
        }
        //    
        //setter methods to set values
        //  
        public void settimeTitle(String tt) {
            timeTitle = tt;
            }
        
        public void settimeTitleStartHour(Integer tt) {
            timeTitleStartHour = tt;
        }
        
        public void settimeTitleEndHour(Integer tt) {
            timeTitleEndHour = tt;
        }
        //
        //getter methods called from availability page to display data in the visual force datatable
        //        
        public integer getnoDays(){
            return noDays;
            }
        
        // CR For Diary Time Start End Time Chnages
        // Added minutes information in URL formation
        
        public String gettimeInfo() {
            // IntegratedScript changes
            return '&var_period='+timeTitle+'&var_starttime='+timeTitleStartHour+'&var_endtime='+timeTitleEndHour
                   +'&var_start_min='+timeTitleStartMinute
                   +'&var_end_min='+timeTitleEndMinute;
            // end IntegratedScript changes
        }
        
         public String gettimeTitle() {
            return timeTitle;
        }
 
        public String getdayAvailable(integer day) {
            String retVal='';           
            //system.debug('JB poolAvailable:' + poolAvailable);
            //system.debug('JB daysAvailable:' + daysAvailable); 
            if(poolAvailable[day] && !daysAvailable[day])
                retVal='Pool Only';
            else if(daysAvailable[day])
            {
                retVal=(availableminutes[day] == null? 'Available':'Available ('+availableminutes[day]+')');
            }           
            return retVal;
        }
        
        
       public String getdayAvailableMinutes(integer day){
            string retVal = '';
            if(daysAvailable[day])
             retVal = (availableminutes[day] == null?'0':string.valueof(availableminutes[day]));
         
         return retVal;         
       }
        
        // HSA allocation CR - Starts

        public Boolean getAvailabilityColor(integer day) {
            return availabilityColor[day];
        }
        
        public Boolean getAvailability0Color() {
            return getAvailabilityColor(0);
        }
        
        public Boolean getAvailability1Color() {
            return getAvailabilityColor(1);
        }
        
        public Boolean getAvailability2Color() {
            return getAvailabilityColor(2);
        }
        
        public Boolean getAvailability3Color() {
            return getAvailabilityColor(3);
        }
        
        public Boolean getAvailability4Color() {
            return getAvailabilityColor(4);
        }
        
        public Boolean getAvailability5Color() {
            return getAvailabilityColor(5);
        }
        
        public Boolean getAvailability6Color() {
            return getAvailabilityColor(6);
        }
        
        // HSA allocation CR - Ends

        public String getday0Available() {
            return getdayAvailable(0);
        }
                
        public String getday1Available() {
            return getdayAvailable(1); 
        }
                        
        public String getday2Available() {
            return getdayAvailable(2);
        }
                
        public String getday3Available() {
            return getdayAvailable(3);
        }
                
        public String getday4Available() {
            return getdayAvailable(4);
        }
                
        public String getday5Available() {
            return getdayAvailable(5);
        }
                
        public String getday6Available() {
            return getdayAvailable(6);
        }  
        
        public String getday0availableminutes() {
            return getdayAvailableMinutes(0);
        }
                
        public String getday1availableminutes() {
            return getdayAvailableMinutes(1); 
        }
                        
        public String getday2availableminutes() {
            return getdayAvailableMinutes(2);
        }
                
        public String getday3availableminutes() {
            return getdayAvailableMinutes(3);
        }
                
        public String getday4availableminutes() {
            return getdayAvailableMinutes(4);
        }
                
        public String getday5availableminutes() {
            return getdayAvailableMinutes(5);
        }
                
        public String getday6availableminutes() {
            return getdayAvailableMinutes(6);
        }     
    }             
    
    //////////////////////////////////////////////////////////////////
    // Method to perform the logic to return available appointments.//
    //////////////////////////////////////////////////////////////////
        
    public void getAvailability() { 
        
                                                  
       
       //system.debug('Please This one ******');
        availDataSet [] retList1 = new availDataSet[]{};
        availDataSet [] retList2 = new availDataSet[]{};
        
        SummaryView = new List<availDataSet>(); 
        TwoHrView = new List<availDataSet>();      
        
         Map<Id,List<List<Date>>> Empmap = new Map<Id,List<List<Date>>>();
                    
                    
           if(gDeal == '3')
           {
              for(integer rs = 0; rs < timeTitlehlf.size(); rs++ ) {  
                availDataSet show = new availDataSet(); 
                show.settimeTitle(timeTitlehlf[rs]);
                show.settimeTitleStartHour(startHourSS[rs]);
                show.settimeTitleEndHour(endHourSS[rs]);
                show.settimeTitleStartMinute(startMinutesSS[rs]);
                show.settimeTitleEndMinute(endMinutesSS[rs]);
                retList1.add(show);
           }  
           }else{
               
           for(integer rs = 0; rs < timeTitle2hr.size(); rs++ ) {  
                availDataSet show = new availDataSet(); 
                show.settimeTitle(timeTitle2hr[rs]);
                show.settimeTitleStartHour(startHour2hr[rs]);
                show.settimeTitleEndHour(endHour2hr[rs]);
                // CR For Diary Start & End Time Changes. Added two additional parameters for storing minutes information.
                show.settimeTitleStartMinute(startMinutes2hr[rs]);
                show.settimeTitleEndMinute(endMinutes2hr[rs]);
                retList2.add(show);
           }
 
            for(integer rs = 0; rs < timeTitlehlf.size(); rs++ ) {  
                availDataSet show = new availDataSet(); 
                show.settimeTitle(timeTitlehlf[rs]);
                show.settimeTitleStartHour(startHourHlf[rs]);
                show.settimeTitleEndHour(endHourHlf[rs]);
                // CR For Diary Start & End Time Changes. Added two additional parameters for storing minutes information.
                show.settimeTitleStartMinute(startMinutesHlf[rs]);
                show.settimeTitleEndMinute(endMinutesHlf[rs]);
                retList1.add(show);
           } 
           }
        
        //Set SOQL availability query starttime. If the week in view is the current week, the start must be no earlier than the current time.
        //If viewing a future week, the start time to query appointments can be from 6am (first appointment time). 
        datetime queryStartTime;
        date queryStartDate;
        if(activeDate <= date.today()){
            //Change By ASHOK G
            if(Nosuitable){
                queryStartTime = datetime.now().adddays(integer.valueof(system.label.Nosuitable_Days));
                queryStartDate = date.today().adddays(integer.valueof(system.label.Nosuitable_Days));
            }//End
            else{
                queryStartTime = datetime.now();
                queryStartDate = date.today();
            }
        }
        else{
            // CR For Diary Start & End Time Changes Starts. Changed queryStartTime.
            if(Nosuitable){
              queryStartTime = datetime.newInstance(date.valueOf(activeURLDate).year(), date.valueOf(activeURLDate).month(), date.valueOf(activeURLDate).day(), 7, 0, 0).adddays(integer.valueof(system.label.Nosuitable_Days));        
              queryStartDate = date.newInstance(date.valueOf(activeURLDate).year(), date.valueOf(activeURLDate).month(), date.valueOf(activeURLDate).day()).adddays(integer.valueof(system.label.Nosuitable_Days));
              
    
            }
            else{
                queryStartTime = datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day(), 7, 0, 0);        
                queryStartDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day());
            }
          
        }
        //Set SOQL availability query end time to 10pm (last possible appointment).
        // CR For Diary Start & End Time Changes Starts. Changed queryEndTime.
        //datetime queryEndTime = datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+retList1[0].getnoDays()-1, 21, 00, 00);
        Integer endDaysLimit = integer.valueOf(system.label.AppointmentEndDateThreshold);
        datetime queryEndTime;
        date queryEndDate; 
        if(activeURLDate == 'null')
        {
            queryEndTime = datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+endDaysLimit, 21, 00, 00);
            queryEndDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+endDaysLimit); 
        }
        else
        {
            if(Nosuitable){
                queryEndTime = datetime.newInstance(date.valueOf(activeURLDate).year(), date.valueOf(activeURLDate).month(), date.valueOf(activeURLDate).day()+integer.valueof(system.label.nosuitable_Days)+retlist1[0].getnoDays()-1, 21, 00, 00);
                queryEndDate = date.newInstance(date.valueOf(activeURLDate).year(), date.valueOf(activeURLDate).month(), date.valueOf(activeURLDate).day()+integer.valueof(system.label.nosuitable_Days)+retlist1[0].getnoDays()-1);
                 //queryEndTime = datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+integer.valueof(system.label.nosuitable_Days), 21, 00, 00);
                 //queryEndDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+integer.valueof(system.label.nosuitable_Days));
            }
            else{
                  queryEndTime = datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+retList1[0].getnoDays()-1, 21, 00, 00);
                  queryEndDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+retList1[0].getnoDays()-1);
            }
        }
        /*
              Moved above to reuce If condition. 
        date queryEndDate;
      
        if(activeURLDate == 'null')
        {
          queryEndDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+endDaysLimit); 
        }
        else
        {
          queryEndDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+retList[0].getnoDays()-1);
        }*/
        //get account postcode for the CHI Lead
        String postCode = thisOpp.Account.BillingPostalCode;
 
        //Calculate postcode sector of the postcode by taking off the last 2 characters
        String postCodeSector = thisOpp.Account.BillingPostalCode.substring(0,thisOpp.Account.BillingPostalCode.length()-2);                
        
        // CR MC011
        // If showAvailability is false, return. This prevents availability being shown.
        // This is because the CHI Lead has more than one active Sales appointment. Note 
        // that we have set the displayMessage elsewhere.
        SummaryView=retList1;
        TwoHrView=retList2;
        system.debug(LoggingLevel.INFO,'-=-=-=-=-1036:'+showAvailability+''+visitType+' '+nonOpcategory);
        if(!showAvailability) {
            
            return;
        }
        // End CR MC011
        if(visitType != 'Sales' && visitType != 'Survey' && visitType!='Green Deal' && nonOpCategory == null){
            displayMessage = 'To book an appointment the CHI Lead “Call Centre Booking Appointment Type” field must have a value of either Sales or Survey.'; 
           
            return;
        }
        else if(contactId==''||contactId==null){
            displayMessage = 'To book an appointment the "Primary Contact" field on the Account of the CHI Lead must have a value.'; 
           
            return;
        }       
        else
        {
          // ++ GD Change.
          // Change the visitType = 'Sales' for GD, as we will be using Sales Geogrphy for booking CHI Lead.
          if(gDeal == '1' || nonOpCategory != null)
          visitType = 'Sales';
          // -- GD End.
                 
            //This select gets the sub-patch and district for the post code sector, of the same type as the CHI Lead (sales/survey)                               
            Postcode_Sector__c[] postCodeInfo = [Select p.Sub_Patch__c, p.Sub_Patch__r.District__c,Sub_Patch__r.OFS_Start_Date__c,  Sub_Patch__r.Appointment_Source__c, Sub_Patch__r.OFS_Bucket_Name__c From Postcode_Sector__c p
                                        where name =:postCodeSector
                                        and type__c = :visitType];         
            
            system.debug('@@@@@@@@@@'+postCodeSubPatch + '' + postCodeDistrict );
                system.debug('@@@@@@@@@@@@@@'+queryStartDate+' '+queryEndDate);
            
            //If select is empty there is no corresponding subpatch. Inform user.
            if(postCodeInfo.size()==0){
                displayMessage = 'No postcode sub-patch could be found for postcode ' + postCode + ' on Account ID: ' + thisOpp.AccountID 
                                   + ', when processing CHI Lead ID: ' + thisOpp.Id + '.';
                //return retList1;  
            }
            else{
                
                postCodeSubPatch = postCodeInfo[0].Sub_Patch__c;
                postCodeDistrict = postCodeInfo[0].Sub_Patch__r.District__c;      
                useOFS = false;
                
                if(postCodeInfo[0].Sub_Patch__r.OFS_Start_Date__c <=activeDate && postCodeInfo[0].Sub_Patch__r.Appointment_Source__c == 'OFS')
                {
                    useOFS = false;
                    TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(thisOpp.Product_Interest__c);
                    
                    if(toaPI != null && toaPI.Active__c == true)
                    {
                        useOFS = true;
                        //Call OFS API
                        if(useOFS)
                        {
                            string BucketName = postCodeInfo[0].Sub_Patch__r.OFS_Bucket_Name__c;
                            
                            list<Date> appointmentWindow = new list<Date>();
                            
                            date ofsStartDate  = queryStartDate.toStartOfWeek();
                            date ofsEndDate = queryStartDate.adddays(7);
                            
                            while(ofsStartDate<=ofsEndDate)
                            {
                            	//ofsStartDate =ofsStartDate.adddays(2);
                            	appointmentWindow.add(ofsStartDate);
                            	ofsStartDate =ofsStartDate.adddays(1);
                                //break;
                            }
                            //Send OFS API Request
                            system.debug('appointmentWindow-->'+appointmentWindow);
                            availDataSet[] tempList = availabiltyP1ControllerHelper.callOFSAPI(appointmentWindow,postCodeSector, BucketName,thisOpp,queryStartDate  );
                            SummaryView =tempList;
                            
                        }
                        
                    }
                }       
                if(!useOFS)  
                {              
                List<Id> Emps = new List<Id>{};
                List<Date> empSubRoleStDate = new List<Date>{};
                List<Date> empSubRoleEdDate = new List<Date>{};
               
                //
                //Now get the employees who have availability set to work this sub-patch. 
                //Their availability must cover at least one day of the week in view.
                //We validate the availability dates later in the code against the individual start 
                //and end dates of each available appointment found, to confirm the availability
                //period covers the date of the appointment.
                //
                
                Integer queryLimit = 1000;
                /*
                if(activeURLDate == 'null')
                {
                    queryLimit = 500; 
                }
                else
                {
                    queryLimit = 1000; 
                }*/
                
                //Guided Sale Changes
                if(Remote_Quote_Product__c.getInstance(thisOpp.product_interest__c) != null)
                {   
                   system.debug('@@into RQ role district');
                   system.debug('@@into RQ queryEndDate' +queryEndDate);
                   system.debug('@@into RQ queryStartDate' +queryStartDate);
                   for (Role_District__c rleDistrict : [Select r.Role__r.Employee__c, r.start_date__c,r.end_date__c,Role__r.Employee__r.Primary_Role__c,Preference__c From Role_District__c r
                        where District__c = :postCodeDistrict
                        and Type__c = 'Availability'
                        and start_date__c <= :queryEndDate 
                        and end_date__c >= :queryStartDate
                        and r.Role__r.Employee__r.Pool_Type__c = null
                        and r.Role__r.Employee__r.Primary_Role__c != 'Pool' 
                        ORDER BY r.Role__r.Employee__c
                        limit :queryLimit]){
                            Emps.add(rleDistrict.Role__r.Employee__c);
                            empSubRoleStDate.add(rleDistrict.start_date__c);
                            empSubRoleEdDate.add(rleDistrict.end_date__c);
                        }     
                       system.debug('@@into RQ role district emps' + Emps);          
                }
                //ends
                else
                {
                for (Role_Sub_Patch__c rleSubPtch : [Select r.Role__r.Employee__c, r.start_date__c,r.end_date__c From Role_Sub_Patch__c r
                        where sub_patch__c = :postCodeSubPatch
                        and Type__c = 'Availability'      
                        and start_date__c <= :queryEndDate 
                        and end_date__c >= :queryStartDate
                        limit :queryLimit]){
                          Emps.add(rleSubPtch.Role__r.Employee__c);
                          empSubRoleStDate.add(rleSubPtch.Start_Date__c);
                          empSubRoleEdDate.add(rleSubPtch.End_Date__c);
                          
                          
                        }
                //
                //If the enquiry urgency field is 'Urgent' we want to include the pool availability for 
                //the district which covers the postcode sector in the available appointment results screen 
                //so select as above but against district and for roles of type Pool only.
                //  
                
                //System.debug('Emps size: ' + emps.size()+queryEndDate+''+queryStartDate);
                //System.debug('Emps size: ' + emps +'sub patch-->'+postCodeSubPatch);
                
                //Ensure list sizes after urgency query does not exceed the maximum of 1000 elements
                queryLimit = (queryLimit - Emps.size());
                
                
                system.debug('--------->'+postCodeDistrict + '' +postCodeSubPatch);
                if(urgency()=='urgent'){    
                    for (Role_District__c rleDistrict : [Select r.Role__r.Employee__c, r.start_date__c,r.end_date__c From Role_District__c r
                        where District__c = :postCodeDistrict
                        and Type__c = 'Availability'
                        and start_date__c <= :queryEndDate 
                        and end_date__c >= :queryStartDate
                        and r.Role__r.Type__c = 'Pool'
                        limit :queryLimit]){
                            Emps.add(rleDistrict.Role__r.Employee__c);
                            empSubRoleStDate.add(rleDistrict.start_date__c);
                            empSubRoleEdDate.add(rleDistrict.end_date__c);
                          system.debug('rleDistrict.Role__r.Employee__c '+rleDistrict.Role__r.Employee__c);
                        }     
                                
                }
                }
                /*
                Added on 2 march 2011 by cognizant. For HSA Sales Skill introduction.
                We need to fetch only those Appointments from Appointment object where the corresponding HSA Employee has
                HSA SAles skill on him. i.e we see if they have Product of interest in his skills and we match this with CHI lead's 
                Product of interest. And we show only those Employees.
                
                So what we are doing is they fetch Appointments on list of employees they get from sub patc and distict etc. 
                Emps----> Employee list. So now i filter this employee by calling  method fetchAppropSalesSkillEmp(emplist, Skill(product of interest)).
                in this i will query on Employee_Sales_Skill__c object for appropriate Employees and i return a map caontaining Employee Id and Employee_Sales_Skill__c,
                this is because i am using same method in Availabiityp2controller for fetching the Sales Efficiency. 
                               
                */
                Map<Id,Employee_Sales_Skill__c> EmpSalesSkillMap;
                //if(visitType == 'Sales')
                {
                  EmpSalesSkillMap = new Map<Id,Employee_Sales_Skill__c>();
                  string skill;
                  // ++ GD Change.
                  // Change the skill to look at secondary Product of Interest instead of Product Interst in case of GD.
                  if(gDeal=='1')
                  skill= 'Green Deal';
                  else
                  skill = thisOpp.Product_Interest__c; 
                  // -- GD End.
                  //system.debug('CHI SKILL--->'+skill);
                  EmpSalesSkillMap = fetchAppropSalesSkillEmp(Emps,skill);
                  list<Id> tempemps= new list<Id>();
                  list<Date> tempempSubRoleStDate = new list<Date>();
                  list<Date> tempempSubRoleEdDate = new list<Date>();
                  
                  for(Id e: EmpSalesSkillMap.keyset())
                  {
                    for(integer i= 0 ; i< Emps.size();i++)
                    {
                      if(e == Emps[i])
                      {
                        tempemps.add(e);
                        tempempSubRoleStDate.add(empSubRoleStDate[i]);
                        tempempSubRoleEdDate.add(empSubRoleEdDate[i]);
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
                  Emps= new list<Id>();                    // Clear all the previous lists of employee and
                  empSubRoleStDate = new list<Date>();   // fill them with upadted values. there is unique mapping in
                  empSubRoleEdDate = new list<Date>();     // lists i.e. if 1st contains emp id -->A 
                  Emps = tempemps;                         // then 2nd list will have startdate--->A 
                  empSubRoleStDate =tempempSubRoleStDate;  //and 3rd will have enddate-----> A
                  empSubRoleEdDate = tempempSubRoleEdDate;
                  
                }
                                
                //
                //Now return all 'available' appointments for the active week being viewed, and only  
                //for the employees who were found to have availability set for that week. Return only
                //appointments with a matching type to that set on the CHI Lead (Sales or Survey).
                //       
                                      
                // Added type in below query as part of HSA allocation CR
                //++ GD Change
                // This is to change back the visitType = 'Green Deal' , to make sure only Green Deal Appointments are displayed on calnder.
                //if(gDeal!='0')
                //visitType = 'Green Deal';
                List<String> appType = new List<String>();
               
                if(gDeal=='1')
                {
                    visitType = 'Green Deal';
                    appType.add('Green Deal');
                }
                else if(visitType == 'Sales')
                {
                    appType.add('Sales');
                    if(nonOpCategory != null)
                    appType.add(nonOpCategory);
                }
                
                // -- GD End.
                
                /*System.debug('select Id, Start__c, End__c, Assigned_To__c, Assigned_To__r.Primary_Role__c from Appointment__c' + 
                           ' where Start__c >=' + queryStartTime + 
                           ' AND End__c <= ' + queryEndTime + 
                           ' AND Type__c = ' + appType + 
                           ' AND Show_Time_As__c = \'Out of Office\'' +
                           ' AND Assigned_To__c in '+Emps);*/
                
                List<Appointment__c> sevenDayAppts = new List<Appointment__c> ();
                
                List<String> tmpSet = new List<String>();
                tmpSet.addAll(system.label.PriorityAppointmentHour.split(';',0));
                //system.debug('tmpSet-->'+tmpSet);
                Integer hourValue;
                String isPrioritySwitchActive; 
                if(tmpSet != null && tmpSet.size() > 0)
                {
                    hourValue = Integer.valueOf(tmpSet[0]);
                    isPrioritySwitchActive = tmpSet[1].toLowerCase();
                }
                
                  /*
                  If current logged in time is greater than 3 PM , then consider both types of appointments (Sales & Priority).
                  This scenario does not work for "Green Deal" appointments.
                  */
                  if(gDeal == '0' || gDeal == '3' )
                  {
                    appType.clear();
                    appType.add('Sales');
                    //system.debug('==================Customer:'+thisOpp.customer_category_controller__c+' ' +nonOpCategory+' '+appType);
                    if((nonOpCategory != null || gDeal == '0') && thisOpp.customer_category_controller__c=='Priority')
                    appType.add(Utilities.nonOpCategory);
                                      
                  }
                  // Add all General Appointments in all the scenario unless thereis an exception in the label.
                  if(!system.label.Appointment_Exception.contains(visitType))
                  {
                    appType.add('General');
                  }
                  
                  // Appointment Conveterter Change : Start
                  date allowedDate;
                  integer hourParameter;
                  boolean entered = false;
                  list<string> newVisitToBeAdded = new list<string>();  
                  //system.debug('Display -->>'+displayController);
                  if(displayController.containskey(visitType))
                  {
                    newVisitToBeAdded = displayController.get(visitType);
                    allowedDate = System.today()+integer.valueof(newVisitToBeAdded[1]);
                    hourParameter = integer.valueof(newVisitToBeAdded[2]);
                     if(system.today().daysBetween(queryStartDate)<=integer.valueof(newVisitToBeAdded[1]))
                     {
                        appType.add(newVisitToBeAdded[0]);
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
                // appointment Converter Change : End                
                Integer appQueryLimit = integer.valueof(label.appointementQueryLimit);
                /*if(activeURLDate == 'null')
                {
                    //appQueryLimit = 500;
                        
                }
                else
                {
                    //appQueryLimit = 1000;
                }*/
                
                //Changes done to querry No suitable appointments
                string poolType;
                if(NoSuitable==true)
                {
                    poolType = 'No Suitable';
               
                }
                
                system.debug('----EMps'+Emps);
                sevenDayAppts = [select Id, Status__c , Start__c, End__c, Type__c, Assigned_To__c,Visit_Date__c, Assigned_To__r.Pool_Type__c, Assigned_To__r.Primary_Role__c, Start_Time__c, Assigned_To__r.Sales_Technical_Ability__c, Assigned_To__r.Diary_Controller__c  from Appointment__c
                                 where Start__c >= :queryStartTime 
                                 AND End__c <= :queryEndTime
                                 AND Type__c IN :appType
                                 AND Show_Time_As__c = 'Out of Office'
                                 AND Assigned_To__c in :Emps
                                 AND Status__c = 'New'
                                 AND Assigned_To__r.Pool_Type__c = :poolType
                                 ORDER BY Start__c limit : appQueryLimit
                                 ];
                
                
                system.debug('AppType-->'+appType);
                
                boolean displayMessageFlag1 = true;
                boolean displayMessageFlag2 = true;
                integer checkFirstBestAppt = 0;
                        
                //If appointments were found, continue. Else set flag to inform user.
                if(sevenDayAppts.size() != 0){
                    // CR MC011, MC013
                    // Added a check to see if displayMessage contains anything before setting it to empty
                    if(displayMessage.length() == 0)
                        displayMessage='';                     
                    // End CR MC011, MC013
                    
                   
                    //Cycle through each appointment found
                    for(integer i=0;i<sevenDayAppts.Size();i++){
                        
                        //integer checkFirstBestAppt = 0;
                        
                            /*
                            IF loop handles the logic for displaying the pool diary 48 hours in advance.
                            If Primary Role is "Pool" , it will check that the days between TODAY & appointment start is greater than 1.
                            If diffrence is greater than 1 , then and then only we are considering the appointments to be displayed on the page.
                            (In other worsds we are restricting the pool diary to be displayed for next 24 hours)
                            
                            If Primary Role is other than "Pool" , consider the apoointment for display without any restrictions
                            */
                            //system.debug('@@@@@@@@@'+sevenDayAppts[i].id);
                            Date todayDate = date.today();
                            if(sevenDayAppts[i].Assigned_To__r.Primary_Role__c == 'Pool')
                            {
                               
                                if(todayDate.daysBetween(date.valueOf(sevenDayAppts[i].Start__c)) <= 1)
                                {
                                    continue;
                                }
                            }
                            
                            
                            /* if(sevenDayAppts[i].Assigned_To__r.Pool_Type__c == 'No Suitable')
                           {
                             system.debug('sevenDayAppts[i].Assigned_To__r.Pool_Type__c'+sevenDayAppts[i].Assigned_To__r.Pool_Type__c);                     
                             continue;
                           }*/
                            /*
                            If current logged in time is greater than 3 PM , then display both types of appointments (Sales & Priority)for next day only.
                            If difference is more than one day then proceed with existing system that is display appointments as per the Type.
                            This scenario does not work for "Green Deal" appointments.
                            */
                            if(isPrioritySwitchActive == 'on' && thisOpp.Latest_Customer_Category__c > 3 && sevenDayAppts[i].Type__c == 'Priority' && visitType == 'Sales' && gDeal != '3')
                            {
                                integer noofdays = todayDate.daysBetween(date.valueOf(sevenDayAppts[i].Start__c));
                               
                               if(noofdays > 1 || noofdays ==1 && currentHour < hourValue)
                               {
                                    continue;
                               }
                               else
                               {
                                    priorityType = Utilities.nonOpCategory;
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
                            //system.debug('Allowed Date-->'+displayController+allowedDate);
                            if(displayController.containskey(visitType) && entered && displayController.get(visitType)[0] ==sevenDayAppts[i].Type__c)
                            {
                                
                                if((sevenDayAppts[i].Assigned_To__r.Diary_Controller__c)||(sevenDayAppts[i].Visit_Date__c > allowedDate)|| (allowedDate == sevenDayAppts[i].Visit_Date__c &&  currentHour < hourParameter))
                                {
                                    continue;
                                }
                                
                            }   
                            //system.debug('Allowed Date-->'+displayRestricter+allowedDate1);
                            if(!sevenDayAppts[i].Assigned_To__r.Diary_Controller__c && displayRestricter.containskey(visitType) && sevenDayAppts[i].Type__c ==visitType  && (sevenDayAppts[i].Visit_Date__c < allowedDate1 || (allowedDate1 == sevenDayAppts[i].Visit_Date__c &&  currentHour >= hourParameter1)))
                            {
                                continue;
                            }
                            /*
                                Appointment Conversion Changes End:
                            */
                       
                        //Check if the employee has role availability set which covers the date of the appointment  
                        Boolean isAvailable=false;
                        // HSA allocation CR - Starts
                        Boolean availabilityColor = false;
                        // HSA allocation CR - Ends
                        Date appDate = sevenDayAppts[i].Start__c.date();//Date.newInstance(sevenDayAppts[i].Start__c.Year(), sevenDayAppts[i].Start__c.Month(), sevenDayAppts[i].Start__c.Day());
                                        system.debug('$$$$$$$$$'+querystartTime+queryEndTime);

                        //cycle through all availability records found
                        if(Empmap.containsKey(sevenDayAppts[i].Assigned_To__c))
                        {
                            for(List<Date> d: Empmap.get(sevenDayAppts[i].Assigned_To__c))
                            {
                            //if(sevenDayAppts[i].Assigned_To__c==e)
                            if(d[0]<=appDate && d[1]>=appDate){
                           // for(integer j=0;j<Emps.Size();j++)
                              //if(sevenDayAppts[i].Assigned_To__c == Emps[j] && empSubRoleStDate[j]<= appDate && empSubRoleEdDate[j]>= appDate)
                              
                                isAvailable=true;
                                if(checkFirstBestAppt == 0)
                                {
                                    activeDate = date.valueOf(sevenDayAppts[i].Start__c).toStartOfWeek();
                                    checkFirstBestAppt++;
                                }
                                /*
                                Consider appointments in one week only.
                                Exit from for loop for next weeks.
                                */
                                if(i+1 < sevenDayAppts.size())
                                {
                                    if(activeDate.daysBetween(date.valueOf(sevenDayAppts[i+1].Start__c)) >= 7)
                                    {
                                        break;
                                    }
                                }
                              } 
                              
                            }
                        }else
                        {
                            continue;
                        }                           
                        /*         
                                  // HSA allocation CR - Starts
                                  if(thisOpp.CHI_Lead_Type__c=='Technical Lead' && highestSalesOrTechnicalAbility > 0){
                                     if(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c!=null){
                                       if(sevenDayAppts[i].Assigned_To__r.Sales_Technical_Ability__c<=highestSalesOrTechnicalAbility){
                                         availabilityColor = true;
                                       }
                                     }
                                  }else if(thisOpp.CHI_Lead_Type__c=='Conversion Lead' && highestSalesOrTechnicalAbility > 0){
                                     if(EmpSalesSkillMap.containsKey(sevenDayAppts[i].Assigned_To__c)){
                                       if((EmpSalesSkillMap.get(sevenDayAppts[i].Assigned_To__c)).Sales_Efficiency__c!=null)
                                         if((EmpSalesSkillMap.get(sevenDayAppts[i].Assigned_To__c)).Sales_Efficiency__c<=highestSalesOrTechnicalAbility){
                                           availabilityColor = true;
                                         }
                                     }
                                  
                                  }
                                  // HSA allocation CR - Ends
                        */
                        if(isAvailable)
                        {
                            //View determines evaluation criteria for timeslot start/end time to determine if available/unavailable
                                for(integer cp=0; cp < retList1[0].getnoDays(); cp++){
                                    for(integer lp=0; lp<startHourHlf.size(); lp++){
                                                    system.debug('$$$$$$$$$'+querystartTime+queryEndTime);

                                        //Find matching time slot of the appointment to set found availability against
                                       // CR For Diary Time Start End Time Chnages.
                                       // Added minutes limitations in if condition as per the new timings.
                                       if(sevenDayAppts[i].Start__c >= datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+cp, startHourHlf[lp], startMinutesHlf[lp], 0) &&
                                            sevenDayAppts[i].End__c <=  datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+cp, endHourHlf[lp], endMinutesHlf[lp], 0) ) {
                                            //Determine if the user is the 'Pool' (for urgent appts) and set availability flag
                                            displayMessageFlag1=false;
                                            if(sevenDayAppts[i].Assigned_To__r.Primary_Role__c == 'Pool')
                                                retList1[lp].poolAvailable[cp]=true;
                                            else{
                                                retList1[lp].daysAvailable[cp]=true;
                                                // HSA allocation CR - Starts
                                                if(availabilityColor)
                                                retList1[lp].availabilityColor[cp]=true;
                                                // HSA allocation CR - Ends
                                               }
                                            }
                                    }
                                }
                            SummaryView = retList1; 
                            //System.debug('===========debug========='+SummaryView);                                
                                                                                                                                                                                     
                        
                            //Do the same as above, but for 2hr timeslot start/end times
                            if(gDeal !='3')
                            {
                                for(integer cp=0; cp < retList2[0].getnoDays(); cp++) {
                                    for(integer lp=0; lp<startHour2hr.size(); lp++) {
                                       // CR For Diary Time Start End Time Chnages.
                                       // Added minutes limitations in if condition as per the new timings.
                                       if(sevenDayAppts[i].Start__c >= datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+cp, startHour2hr[lp], startMinutes2hr[lp], 0) &&
                                            sevenDayAppts[i].End__c <=  datetime.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+cp, endHour2hr[lp], endMinutes2hr[lp], 0) ) {
                                                displayMessageFlag2=false;    
                                                if(sevenDayAppts[i].Assigned_To__r.Primary_Role__c == 'Pool')
                                                    retList2[lp].poolAvailable[cp]=true;                                
                                                else{
                                                    retList2[lp].daysAvailable[cp]=true;
                                                    // HSA allocation CR - Starts
                                                    if(availabilityColor)
                                                    retList2[lp].availabilityColor[cp]=true;
                                                    // HSA allocation CR - Ends
                                                 }                                
                                            }
                                    }
                                }
                                TwoHrView = retList2;
                            }else{
                                displayMessageFlag2= false;
                            }
                            //System.debug('===========debug========='+TwoHrView);                               
                            
                        }
                    } 
                }
                //Inform the user if no appointments were found                   
                if(displayMessageFlag1&&displayMessageFlag2)
                {
                    if(activeURLDate == 'null')
                    {
                        isNoBestApptFound = true;
                        displayMessage = 'No best available appointments were found till ' + weekEndDate.format() +'.';
                        activeDate = weekEndDate.toStartOfWeek();
                    }
                    else
                    {
                        displayMessage = 'No available appointments were found.';
                    }
                }
                
                }
            }
        }
    }                                      
     
    /*
    Added on 2nd march 2011, as a part of Sales Skill CR.
    This method queries for appropriate employee depending upon Product of interest of CHI lead.
    and returns Map. Keyset is used in this class and Values are used in Availabilityp2contr class. 
    Explained clearly above
    */
    public Map<Id,Employee_Sales_Skill__c> fetchAppropSalesSkillEmp(list<Id> Emps, string Skill)
    {
           
      Map<Id,Employee_Sales_Skill__c> EmpSalesSkillMap = new Map<Id,Employee_Sales_Skill__c>();
      list<Employee_Sales_Skill__c> EmpSalesSkill= [Select e.Sales_Efficiency__c,e.Sales_Skill_Name__c, e.Id, e.Employee__c, e.Employee__r.Employee_Number__c From Employee_Sales_Skill__c e where Employee__c in :Emps and Sales_Skill_Name__c =:Skill and Is_Active__c = 'True' order by Employee__r.Employee_Number__c asc];
      for(Employee_Sales_Skill__c e:EmpSalesSkill)
      {
         
        if(!EmpSalesSkillMap.containskey(e.Employee__c))
        {
             system.debug('Order by number-->'+e.Employee__r.Employee_Number__c + '  '+e.Employee__c);
          EmpSalesSkillMap.put(e.Employee__c,e);
        }
      }
      //system.debug('EMp ID in method -->'+EmpSalesSkillMap);
      return EmpSalesSkillMap;
    }
    
    /*
    Added on 14th June 2011, as a part of Salesforce HSA allocation CR .
    This method returns highest technical ability or highest sales efficiency
    based on CHI Lead Type. In reality this is the minimum value but practically
    it is considered as highest ability for a salesman.
    */
   /*
    public Double fetchHighestSalesOrTechnicalAbility(List<Appointment__c> lstAppts)
   
    {
      
      Double highestSalesOrTechnicalAbility = 0;
      List<Appointment__c> appts = new List<Appointment__c>();
      List<Employee_Sales_Skill__c> EmpSalesSkill;
      
      for(Appointment__c app : lstAppts){
        
        if(app.Assigned_To__r.Primary_Role__c != 'Pool' && app.Type__c == 'Sales'){
          
          appts.add(app);
          
        }
        
      }
      
      if(appts.size()>0){
      
        if(thisOpp.CHI_Lead_Type__c == 'Technical Lead'){
          
          for(Appointment__c app : appts){
            
            if(app.Assigned_To__r.Sales_Technical_Ability__c != null){
              
              if(highestSalesOrTechnicalAbility == 0){
                
                  highestSalesOrTechnicalAbility = app.Assigned_To__r.Sales_Technical_Ability__c;
                  
                }
                
              if(app.Assigned_To__r.Sales_Technical_Ability__c <= highestSalesOrTechnicalAbility){
                
                highestSalesOrTechnicalAbility = app.Assigned_To__r.Sales_Technical_Ability__c;
                
              }
              
            }
          }
             
             //System.debug('Returning Sales Technical Ability Value : '+highestSalesOrTechnicalAbility);
             
             return highestSalesOrTechnicalAbility;
             
        }else if(thisOpp.CHI_Lead_Type__c == 'Conversion Lead'){
          
          List<Id> empIds = new List<Id>();
          
          for(Appointment__c app : appts){
            
              empIds.add(app.Assigned_To__c);
              
            }
            
            EmpSalesSkill= [Select e.Sales_Efficiency__c From Employee_Sales_Skill__c e where Employee__c in :empIds and Sales_Skill_Name__c =:thisOpp.Product_Interest__c and Is_Active__c = 'True' order by Sales_Efficiency__c];
            
             if(EmpSalesSkill.size()>0){
              
              //System.debug('Returning Sales Efficiency Value : '+EmpSalesSkill[0].Sales_Efficiency__c);
              
              return EmpSalesSkill[0].Sales_Efficiency__c;
              
            }
                    
        }
           
    }
      
      //System.debug('Returning No Value : '+highestSalesOrTechnicalAbility);
      
      return highestSalesOrTechnicalAbility;
      
  }
  */
  public pagereference nextpage()
  {
    if(thisOpp.Secondary_Product_Interest__c== null)
    {
      util.setErrorMsg(false, 'Please select one Secondary Product Interest.' );
      return null;
    }
    pagereference p =  new pagereference('/apex/availability?var_OpptyId='+chiLeadID+'&var_Source='+source+'&var_CallId='+callID+'&view=null&var_date=null&var_contactId='+contactId+'&var_cancelledapp=null&gDeal=2'+'&var_Pcr='+pcr+'&var_Sec='+scr);
    p.setRedirect(true);
    return p;
  }
  
  public pagereference getAvailabiltyOnProductInterest(){
      
      //update thisOpp;
      string productInt = thisOpp.Product_Interest__c;
      system.debug('productInt'+productInt);
      string gdeal = '0'; 
      if(productInt == 'Straight Swap' || productInt == 'Telesales Conv' || productInt == 'Straight Swap - Direct') 
      gdeal = '3';
       pagereference p =  new pagereference('/apex/availability?var_OpptyId='+chiLeadID+'&var_Source='+source+'&view=null&var_date=null&var_NoSuitable=0&var_contactId='+contactId+'&var_cancelledapp=null&view=null&&gDeal='+gdeal+'&ProductInt='+productInt+'&var_CallId='+callID+'&existingLead='+existingLead+'&new='+newInbound);
        p.setRedirect(true);
        //getAvailability();
        return p;
  }
 

}