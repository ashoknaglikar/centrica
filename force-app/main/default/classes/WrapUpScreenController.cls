public class WrapUpScreenController 
{
    Account newAcc;  
    //Opportunity opportunity= new Opportunity ();
    public Opportunity opportunity{ get; set; }
    public CAM_Waste_Call__c wastecall{ get; set; }
    Contact contact = new Contact();
    List<Contact> contactList= new List<Contact>(); 
    public List<Opportunity> oppList=new List<Opportunity>();
    public List<CAM_Waste_Call__c> wastecallList=new List<CAM_Waste_Call__c>();
     
    public Task newTask{ get; set; }
    public Appointment__c Appointment{ get; set; }
    // Ashok CR:001 CHI CP start
    public boolean Shw_callbackdetails{get;set;}
    integer count_app =0;
    integer count_inbound_call = 0;
    integer count_cancelled_app = 0;
    public boolean showtaskbtn {get; set;}
    //Ashok  CR:001 End
    // Landlord lead changes
    public boolean isLanlordNotesRequired {get; set;}
    //public Inbound_Call__c inCall{get;set;}
    Inbound_Call__c inCall = new Inbound_Call__c();
    String callId;
    
    public CallMode CallMode{get; set;}
    public DisplayMode DisplayMode{get; set;}
    public Boolean DisplaySuccessMessage{get; set;}
    public Boolean DisplayRedUnAppLeadReason{get; set;}
    public Boolean AppointmentStatus{get; set;}
    private MessageConstants errorMsg; 
    public String leadCommentsAppend {get; set;} 
    public String leadTaNotesAppend {get; set;} 
    public boolean var{get;set;}
    
    String errMsg; 
    public String CallModeStringValue{get; set;}
    public Workflow.WorkflowInfo info = new Workflow.WorkflowInfo(); //changes for wrap up screen seperation.
    Utilities util = new Utilities();
    
    //Change By Ashok G starts
    public String LeadExists{get;set;}
    public Boolean existingLead{get;set;}
    public integer mode{get;set;}
    boolean newInbound=System.currentPageReference().getParameters().get('new')== 'true'?true:false;
    //Change End
    public WrapUpScreenController ()
    {
        //callModeVal=info.callModeIntValue;//changes for wrap up screen seperation.
        
        leadCommentsAppend = '';
        leadTaNotesAppend = '';
        DisplaySuccessMessage = false;
        AppointmentStatus = false;
        DisplayRedUnAppLeadReason = false;
        // Landlord lead changes
        isLanlordNotesRequired = false;
        errorMsg = new MessageConstants();
        errMsg = '';
        CallMode = new CallMode();
        DisplayMode = new DisplayMode();
        existingLead = false;
        LeadExists = System.currentPageReference().getParameters().get('existingLead'); //to know lead exists or not By Ashok G
        system.debug('######existingLead'+LeadExists);
        if(LeadExists == 'True'){
          existingLead = True;
        }
       // wastecall.Opportunity__c=opportunity.id;
        //System.debug('@@@@wastecall.Opportunity__c'+wastecall.Opportunity__c);
        newTask = new Task();
        wastecall = new CAM_Waste_Call__c();
        
        callId = ApexPages.currentPage().getParameters().get('c');
        string accountId , chiLeadId;
        
        if(callId==null)
        {
            accountId = ApexPages.currentPage().getParameters().get('accId');
            chiLeadId = ApexPages.currentPage().getParameters().get('chiLeadId');
            //set default value of mode incase of CallId ==NULL; 
            mode=0;
        }
        
        System.debug('###***------leadCommentsAppend----- '+leadCommentsAppend);
        if(callId != null || accountId!=null)
        {
            if(callId != null)
            {
                inCall = [Select  i.CHI_Lead__r.AccountId,i.CHI_Lead__c ,i.Related_To__c, i.Enquiry__c, i.End_Date_Time__c,i.Id, i.Billing_Zip__c,i.Workflow_Type__c, i.Billing_Street__c, i.Billing_State__c, i.Billing_City__c, i.Billilng_Country__c From Inbound_Call__c i where i.Id =:callId];
                accountId = inCall.CHI_Lead__r.AccountId;
                chiLeadId =inCall.CHI_Lead__c;
                if(inCall.Workflow_Type__c!=null)
                mode = inCall.Workflow_Type__c.intValue();
            }
            
            
            if(inCall != null && accountId != null)
            {
                // Landlord lead changes - starts
                newAcc = [Select a.Number_of_Bedrooms__c, a.Id, a.Landlord_Account__c, a.Gas_Supply_At_Address__c,a.Gas_Supply_At_Address1__c, a.Current_Heating_System__c, a.Current_Heating_System1__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity,GAS_Supply_Confirmation__c,a.Number_of_Bathrooms__c,a.Property_type__c,a.Property_age__c,a.Asbestos_found__c From Account a where a.Id =:accountId];
                if(newAcc!=null)
                {
                        if(newAcc.Landlord_Account__c)
                        {
                                isLanlordNotesRequired = true;
                        }
                }
               // Landlord lead changes - ends 
            }
        
            System.debug('------callid-----> '+callId);
            System.debug('------incall-----> '+inCall);
            if(newAcc == null)
            {
                newAcc = new Account();
                newAcc.BillingStreet = inCall.Billing_Street__c;
                newAcc.BillingCity = inCall.Billing_City__c;
                newAcc.BillingState = inCall.Billing_State__c;
                newAcc.BillingCountry = inCall.Billilng_Country__c;
                newAcc.BillingPostalCode = inCall.Billing_Zip__c;
            }
            contactList = new List<Contact>([Select  c.Account.BillingCountry, c.Account.BillingPostalCode, c.Account.BillingState, c.Account.BillingCity,c.Account.BillingStreet,c.Title, c.SystemModstamp, c.Suppress_Mail_Date__c, c.Suppress_Call_Date__c, c.Stop_Reason__c, c.Stop_Reason_Date__c, c.Siebel_Created_Date__c, c.Salutation, c.ReportsToId, c.Primary_Contact__c, c.Premier_Mobile_Phone__c, c.Prem_Work__c, c.Prem_Mobile__c, c.Prem_Home__c, c.Preferred_Phone_Type__c, c.Preferred_Contact_Method__c, c.Phone, c.OwnerId, c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, c.Name, c.MobilePhone, c.Middle_Name__c, c.MasterRecordId, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, c.LastModifiedDate, c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.IsDeleted, c.Id, c.HomePhone, c.Gender__c, c.FirstName, c.Fax, c.Email__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, c.CreatedDate, c.CreatedById, c.Contact_Num__c, c.Contact_Num_2__c, c.Contact_Num_1__c, c.Circumstance__c, c.Birthdate, c.Best_Time_to_Contact__c, c.Best_Phone__c, c.AssistantPhone, c.AssistantName, c.Alternative_Form_of_Literature__c, c.AccountId,c.Contact_Type__c From Contact c where c.Account.Id=:newAcc.Id and IsActive__c = true]);
            contact = [select c.Id from Contact c where c.Primary_Contact__c = true and c.AccountId=: newAcc.Id];
            // Ashok CR : 001 CHI CP added o.Unappointed_Lead_Reason__c in the query
            // MGM Change
            // Landlord lead changes
            
            oppList=[Select Account.Landlord_Account__c,Landlords_permission__c, o.Name,o.Location_of_Current_Boiler__c,o.Location_of_new_Boiler__c,o.Unappointed_Other_Reason__c,
                    o.Override_Call_Back_Date__c,o.Call_Back_Date__c,o.CHI_Lead_Id__c , o.Campaign_Name__c, o.Landlord_lead_details__c,o.MGM_Source_Opp__c , o.MGM_Ref_Emp__c , 
                    o.Sales_Appointment_Date_an_Time__c,o.AccountId,o.With_Customer__c, o.Referral_Employee__c,o.Referral_Employee__r.Group__c, o.Product_Interest__c, o.Id, 
                    o.Homecare__c, o.CampaignId,o.CreatedDate,o.StageName,o.Preferred_appointment_day__c,o.Preferred_Visit_Date_Time__c,o.Preferred_appointment_time__c,o.Lead_Comments__c,
                    o.Preferred_call_back_time_slot__c,o.ta_notes__c,o.Status__c, o.Non_Op__c,o.Enquiry_Reason__c,o.Boiler_Age__c,o.Type,o.Enquiry_Type__c,o.Home_improvement__c,
                    o.HomeImprovementCheckbox__c,o.Urgency__c,o.Boiler_Working__c,o.Unsafe_Appliance_Reason__c,o.Unappointed_Lead_Reason__c,o.Unappointed_Lead_Sub_Reason__c ,o.Preferred_Date__c,
                    o.Reason_Code__c,o.Do_Not_Call_Back__c,o.Opt_Out__c,o.Prospect_Notes__c,o.Fusion_Store__c,o.Fusion_UCRN__c,o.GDCashBack__c,o.WithCustomer__c,o.isMGM__c,o.Boiler_type__c,
                    o.Why_is_your_customer_considering_a_new_b__c,o.Customer_agreed_to_appointment__c,o.Current_annual_gas_spend_over_1500__c,o.Nectar_Number__c,o.Missing_product_holdings_reason__c,
                    o.Home_care__c,o.Keeping_current_boiler_in_same_place__c,Prospect__c, SM_discount_given__c,Referral_Employee__r.Service_Manager_Name__c, Customer_marketing_consent__c,
                    Marketing_Preferences__c From Opportunity o where o.ID=:chiLeadId];
                        // AShok CR:001 CHI CP End      
            //id, Name, Status__c, Non_Op__c, Homecare__c, StageName, CreatedDate, Days_Since_Created__c, Sales_Appointment_Date_an_Time__c, Product_Interest__c, CampaignId, Referral_Employee__c, Preferred_appointment_day__c, Preferred_Visit_Date_Time__c, Preferred_appointment_time__c, With_Customer__c, CHI_Lead_Id__c, Referral_Employee__r.Group__c,Enquiry_Reason__c, Boiler_Age__c, Lead_Comments__c,Type,Enquiry_Type__c,Home_improvement__c,HomeImprovementCheckbox__c,Urgency__c,Boiler_Working__c   
            if(oppList.size()>0)
            {
                
                system.debug('@@@@@oppList.size()'+oppList.size());
                opportunity = oppList.get(0);
                system.debug('@@@opportunity'+opportunity);
                
                
                if(opportunity.Referral_Employee__c != null && opportunity.Referral_Employee__r.Group__c == 'SMRT')
                {
                    var = true;
                }
                
                
                if(opportunity.Lead_Comments__c!=null)
                {
                        if(opportunity.Lead_Comments__c.length()>0)
                        {
                                leadCommentsAppend = opportunity.Lead_Comments__c + '\n'+ UserInfo.getName() + ';';
                        }else
                        {
                            leadCommentsAppend = UserInfo.getName() + ';';
                        }
                } else
                {
                            leadCommentsAppend = UserInfo.getName() + ';';
                }
                
                if(opportunity.SM_discount_given__c && opportunity.Referral_Employee__r.Service_Manager_Name__c!= null && (opportunity.ta_notes__c == null || (opportunity.ta_notes__c!=null &&   !opportunity.ta_notes__c.contains(system.label.SM_Discount_2))))
                {
                    leadTaNotesAppend +=system.label.SM_Discount_1.replace('{createddate}', string.valueof(opportunity.createdDate.date())).replace('{smmanager}', 	opportunity.Referral_Employee__r.Service_Manager_Name__c);
                }
                
                if(opportunity.ta_notes__c != null)
                {
                        if(opportunity.ta_notes__c.length()>0)
                        {
                                    leadTaNotesAppend +=  opportunity.ta_notes__c;
                                   
                        }
                }
                
                
                
            }
            // CR - Add bring forward visit checkbox on wrap up screen
            appList = [select a.BM_Salesperson__c,a.Opportunity__c,a.Visit_Date__c, a.Time_Band__c,Type__c, a.Status__c, a.Name, a.Id, a.Assigned_To__r.Primary_Role__c, a.Assigned_To__c,a.Call_Notes__c,a.Start_Time__c,a.End_Time__c, a.Bring_forward_visit__c  From Appointment__c a where a.Status__c=:'Appointed' AND a.Opportunity__c=:opportunity.Id];
            if(appList.size()>0)
            {
                AppointmentStatus = true;
            }
            //Ashok CR:001 CHI CP start
            count_app = [select count()  From Appointment__c a where (a.Status__c=:'Appointed' OR a.Status__c=:'Happened') AND a.Opportunity__c=:opportunity.Id AND a.Type__c ='Sales'];
            if(count_app == 0)
            Shw_callbackdetails =true;
            count_inbound_call = [Select count() From Inbound_Call__c where CHI_Lead__r.Id = :opportunity.Id];
            count_cancelled_app = [select count()  From Appointment__c a where a.Status__c=:'Cancelled' AND a.Opportunity__c=:opportunity.Id AND a.Type__c ='Sales'];
            // Ashok CR:001 End
            
            if(!AppointmentStatus && opportunity.Account.Landlord_Account__c)
              util.setErrorMsg(false, 'Sales Appointment has not been booked as Landlord requirements are not met.');
              
        }
        System.debug('----appList size----'+appList.size());
        
                    
    }
    
    public Account getAccountInfo()
    {
        return newAcc;
    } 

    public List<ContactInfo> getConList()
    {
        List<ContactInfo> conInfoList = new List<ContactInfo>();
        for(Contact c : contactList)
        {
            ContactInfo conInf = new ContactInfo();
            conInf.contact = c;
            conInfoList.add(conInf);             
        }
        return conInfoList;
    }

    public List<Opportunity> getOpportunities() 
    {
        return oppList;
    }
    
    List<Appointment__c> appList=new List<Appointment__c>();
    
    public List<Appointment__c> getAppointments(){
        System.debug('-----AppointmentStatus before-----'+AppointmentStatus);
        if(appList.size()>0)
        {
            System.debug('------appList.size()------'+appList.size());
            Appointment = appList.get(0);
            //AppointmentStatus = true;
            System.debug('-----AppointmentStatus-----'+AppointmentStatus);
        }
        return appList;
    }  
    
    public void seterror(exception e)
    {
        system.debug('Exception-->'+e.getmessage());
        if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
        {
            list<string> error = e.getmessage().split(',');
            
            util.setErrorMsg(true, error[1]);
            
        }else
        {   
            util.setErrorMsg(true, e.getmessage());
        }  
    }

    public PageReference closeCall() 
    {
        System.debug('------inside closecall----- ');
        System.debug('------callid----- '+callId);
        System.debug('------incall----- '+inCall);
      
        
        try
        {   
            System.debug('###***------Opp ta notes----- '+opportunity.ta_notes__c);
            System.debug('###***------leadTaNotesAppend----- '+leadTaNotesAppend);
            if(oppList.size() > 0)
            {
              
                    
            try {
               
                       if(wastecall.id==null)
                       {
                         system.debug('@entering in try block'+wastecall.id);
                         wastecall.Opportunity__c=opportunity.id;
                         system.debug('@wastecall.Opportunity__c'+wastecall.Opportunity__c);
                         system.debug('@opportunity.id'+opportunity.id);
                         insert wastecall;
                         system.debug('@insert wastecall'+wastecall);
                         //return null;
                       
                       }
                    
                 }
                 
           catch (exception e)
          {
            
            system.debug('@@@@entering in catch block'+e);
            seterror(e); 
            return null;
            
          } 
               
                  
                if(leadTaNotesAppend!=null && leadTaNotesAppend.trim().length()>0)
                {
                            if(leadTaNotesAppend.length()>=999)
                            leadTaNotesAppend = leadTaNotesAppend.substring(0, 999);
                            opportunity.ta_notes__c = leadTaNotesAppend;
                }
            
                if(leadCommentsAppend!=null && leadCommentsAppend.trim().length()>0 )
                {
                          if(leadCommentsAppend.length()>=254)
                          leadCommentsAppend = leadCommentsAppend.substring(0, 254);
                      opportunity.Lead_Comments__c = leadCommentsAppend;
                }
                //Amit:- Start:---Added for Reason code and Call Back time
                 if(opportunity.Opt_Out__c == false && opportunity.Unappointed_Lead_Reason__c == 'Prospect')
                 {
                                        if((opportunity.Reason_Code__c == null && opportunity.Call_Back_Date__c == null)&& opportunity.Do_Not_Call_Back__c == false) 
                                {
                                        errMsg = errorMsg.ERR_REASONCALLBACKCODE;
                                        setErrorMsg();
                                        return null;
                                }
                                if((opportunity.Reason_Code__c == null &&  opportunity.Call_Back_Date__c != null )&& opportunity.Do_Not_Call_Back__c == false)
                                {
                                        errMsg = errorMsg.ERR_REASON;
                                        setErrorMsg();
                                        return null;
                                }
                                if((opportunity.Reason_Code__c != null &&  opportunity.Call_Back_Date__c == null )&& opportunity.Do_Not_Call_Back__c == false)
                                {
                                        errMsg = errorMsg.ERR_CALLBACKTIMES;
                                        setErrorMsg();
                                        return null;
                                }
                                if((opportunity.Call_Back_Date__c == 'Over Ride Call Back Date' && opportunity.Override_Call_Back_Date__c ==  null)&& opportunity.Do_Not_Call_Back__c == false)
                                {
                                        errMsg = errorMsg.ERR_OVERRIDECALLDATE;
                                        setErrorMsg();
                                        return null;
                                }
                                if((opportunity.Call_Back_Date__c != 'Over Ride Call Back Date' && opportunity.Override_Call_Back_Date__c !=  null)&& opportunity.Do_Not_Call_Back__c == false)
                                {
                                        errMsg = errorMsg.ERR_DELOVERRIDECALLDATE;
                                        setErrorMsg();
                                        return null;
                                }
                                if(opportunity.Override_Call_Back_Date__c !=  null && opportunity.Reason_Code__c == null && opportunity.Do_Not_Call_Back__c == false)
                                    {   
                                        
                                        errMsg = errorMsg.ERR_REASON;
                                        setErrorMsg();
                                        return null;
                                            
                                    }
                                    
                            if(opportunity.Do_Not_Call_Back__c == false)
                            {
                                if((opportunity.Reason_Code__c != null ) && (opportunity.Call_Back_Date__c != null) || opportunity.Unappointed_Lead_Reason__c == 'Prospect')
                                {
                                        opportunity.StageName = 'Prospect';
                                        opportunity.Prospect__c = true;
                                }
                            }
                 }
                 
               
               
                
               
               
                    //End
                System.debug('------before opportunity update----- '+opportunity.Call_Back_Date__c);
                update opportunity;
                System.debug('-------after opportunity update----- '+opportunity.Call_Back_Date__c);
            } 
            //system.debug('opportunity.Unappointed_Lead_Reason__c---->'+opportunity.Unappointed_Lead_Reason__c);
            system.debug('count_app---->'+count_app);    
            if(appList.size() > 0)
            {
                // CR - Add bring forward visit checkbox on wrap up screen
                // Update entire list instead of updating only single appointment
                update appList;
            }
          
             //ashok : CR 001 CHI Conversion start
            
            else if( count_app == 0 )
            {
                if((opportunity.Unappointed_Lead_Reason__c == '') || (opportunity.Unappointed_Lead_Reason__c == null))
                {
                    
                    if(DisplaySuccessMessage ==true)
                    showtaskbtn = true;
                    DisplaySuccessMessage = false;
                    errMsg = errorMsg.ERR_UNBOOKEDAPPOINTMENT;
                    setErrorMsg();
                    DisplayRedUnAppLeadReason = true;
                    return null;
                    
                  
                }
                /*if(opportunity.Unappointed_Lead_Sub_Reason__c == null || opportunity.Unappointed_Lead_Sub_Reason__c=='' )
                {
                   errMsg = errorMsg.ERR_WITH_unappointedleadsubreason;
                   setErrorMsg();
                   return null;
                
                } 
                
               if((opportunity.Preferred_appointment_day__c == null  || opportunity.Preferred_appointment_time__c == null ) || (opportunity.Preferred_appointment_day__c ==''  || opportunity.Preferred_appointment_time__c ==''))
               {
                  errMsg = errorMsg.ERR_PREFERRED_OPTIONS;
                  setErrorMsg();
                  return null;
                
               } */
            }
            
           //ashok : CR 001 CHI Conversion end
        
            if(inCall != null)
            {
                inCall.End_Date_Time__c = system.now();
                update inCall;
            }
           
            System.debug('### Appointment: '+appointment.Id);
        }
        catch(Exception e)
        {
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            //seterror(e);
            System.debug('### Exception occurred during closeCall i. e, appointment update'+e);
        }
        
        PageReference pageRef;
        if(!newInbound)
        pageRef = new PageReference('/apex/inboundcall');
        else
        pageRef = new PageReference('/apex/MiniInboundCall?sfdc.tabName='+system.label.newInboundTabId);
        
        pageRef.setRedirect(true);
        return pageRef;
    }


    public PageReference createTask() {
        newTask.WhatId = opportunity.Id;
        newTask.WhoId = contact.Id;
        
                
        try{
            if(newTask.Wrap_Up_Call_Type__c != null && newTask.OwnerId != null){
                newTask.Status__c = 'Completed';
                insert newTask;
                DisplaySuccessMessage = true;
                showtaskbtn = true;
            }
            else{
                errMsg = errorMsg.ERR_ENTERTASKINFO;
            setErrorMsg();
            }
            
        }catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            System.debug('### Exception occurred during createTask'+e);
        }
        return null;
    }
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }  
    
    public String methodForTest(){
        String testString='This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';        
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        return testString;
    }  
}