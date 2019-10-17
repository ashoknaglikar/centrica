public class WorkflowHelper  
{
    //private MessageConstants msgConstants; 
    Utilities util = new Utilities();   
    
    //Fetch information for Account and related contacts and opportunities
    public static Workflow.WorkflowInfo fetchCallData(Workflow.WorkflowInfo info)
    {
        System.debug('----------------- 1'); 
        //Check if data is valid
        if(info != null && info.Call != null && info.Call.CHI_Lead__c != null)
        {
            System.debug('----------------- 2');
            //Search for Opportunity related to the call object
            Opportunity tempOpp = [Select o.id, o.AccountId From Opportunity o where o.id =: info.Call.CHI_Lead__c];
            
            //Check if opportunity object is null
            if(tempOpp != null && tempOpp.AccountId != null)
            {
                //Retrieve account information
                //Added one new field on Opportunity named as customer agreed for appointment.
                // MGM Change 
                Account tempAcc = [Select a.Id , a.ProductHoldingRefresh__c ,a.CustomerUCRN__c, Landlord_Account__c ,a.CustomerUCRNCode__c,a.ShippingStreet,a.Asbestos_found__c,healthSafety_Notes__c ,a.Asbestos_Found_Date_New__c, a.Name, a.Status__c, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.Primary_Contact__c, a.Number_of_Bedrooms__c, a.Gas_Supply_At_Address__c,a.Gas_Supply_At_Address1__c, a.Current_Heating_System__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.CreatedDate,  a.Account_Id__c,GAS_Supply_Confirmation__c, 
                                        a.Sales_Region__c,a.Sales_District__c,a.Sales_Subpatch__r.District__r.Message_1_Area__c,a.Sales_Subpatch__r.District__r.Message1_Active__c,a.Sales_Subpatch__r.District__r.Message_2_Area__c,a.Sales_Subpatch__r.District__r.Message2_Active__c,a.Number_of_Bathrooms__c,a.Property_age__c,a.Property_type__c,a.Current_Heating_System1__c,a.Sales_Subpatch__r.District__r.Region__r.Customer_Category__c,
                                        (Select id, LastName,Description, FirstName, Email,Email__c, Title, Birthdate, Circumstance__c, Primary_Contact__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, HomePhone, MobilePhone, OtherPhone, IsActive__c,Contact_Type__c,Salutation,Preferred_Contact_Method__c From Contacts where IsActive__c = true) ,
                                        (Select id, Commercial_Indicator__c, Name,AccountId, isMGM__c,Status__c, Campaign_Name__c, MGM_Source_Opp__c, MGM_Ref_Emp__c,  Non_Op__c, Homecare__c, StageName, CreatedDate, Days_Since_Created__c, Sales_Appointment_Date_an_Time__c, Product_Interest__c, CampaignId, Referral_Employee__c, Preferred_appointment_day__c, Preferred_Visit_Date_Time__c, Preferred_appointment_time__c, With_Customer__c, CHI_Lead_Id__c, Referral_Employee__r.Group__c,Enquiry_Reason__c, Boiler_Age__c, Lead_Comments__c,Type,Enquiry_Type__c,
                                        Home_improvement__c,HomeImprovementCheckbox__c,Urgency__c,Boiler_Working__c,Unsafe_Appliance_Reason__c,Customer_agreed_to_appointment__c,Reason_code__c,Call_Back_Date__c,Override_Call_Back_Date__c,Do_Not_Call_Back__c, Opt_Out__c,Ecogen_Propostioned__c,Customer_Interested_In_Ecogen__c,Contact_Centre_Fast_Track__c,Fusion_Store__c,Fusion_UCRN__c,Boiler_type__c,Why_is_your_customer_considering_a_new_b__c,Current_annual_gas_spend_over_1500__c,
                                        Is_the_customers_boiler_working__c,Does_the_customer_have_hot_water__c,Customer_have_any_other_form_of_HEAT__c,Location_of_Current_Boiler__c,Location_of_new_Boiler__c,
                                        Is_the_customer_vulnerable__c,Vulnerable_reason__c,Latest_customer_category_indicator__c,No_Shower_Rooms__c,Cureent_Boiler_Location__c,
                                        Latest_customer_category__c,GDCashBack__c , Gas_Council_Number__c,WithCustomer__c, Nectar_Number__c,WithCustReasons__c,Missing_product_holdings_reason__c,Home_Care__c,Keeping_current_boiler_in_same_place__c,Customer_Marketing_Consent__c ,Marketing_Preferences__c from Opportunities)
                                        From Account a where a.Id=:tempOpp.AccountId];
                                        
                
                //Set Accout, Contacts and Opportunities                        
                info.CurrentAccount = tempAcc;
                
                //code to add region and district to account
                info.district = tempAcc.Sales_District__c;
                info.region = tempAcc.Sales_Region__c;
                info.messageStr1 = tempAcc.Sales_Subpatch__r.District__r.Message_1_Area__c;
                info.messageStr2 = tempAcc.Sales_Subpatch__r.District__r.Message_2_Area__c;
                info.messageBool1 = tempAcc.Sales_Subpatch__r.District__r.Message1_Active__c;
                info.messageBool2 = tempAcc.Sales_Subpatch__r.District__r.Message2_Active__c;
                info.customerCateogryType = (tempAcc.Sales_Subpatch__r.District__r.region__r.Customer_Category__c!=null)?tempAcc.Sales_Subpatch__r.District__r.region__r.Customer_Category__c:'0' ;

                
                List<Contact> lstContacts = tempAcc.Contacts; 
                List<Opportunity> lstOpportunities = tempAcc.Opportunities; 
                info.Contacts = lstContacts;
                info = SetContacts(info);
                
                info.Opportunities = lstOpportunities;
                //Set OppSelectClass list
                if(lstOpportunities != null)
                {
                    List<OppSelectClass> lstOppInfo = new List<OppSelectClass>();
                    OppSelectClass objOppInfo;
                    for(Opportunity o :lstOpportunities)
                    {
                        objOppInfo = new OppSelectClass();
                        objOppInfo.setOpp(o);
                        objOppInfo.oppSelected = false;
                        lstOppInfo.Add(objOppInfo);
                    }
                    info.SelectedOpportunities = lstOppInfo;
                    /*if(lstOppInfo[0].Opp.Product_Interest__c == 'Combi Replacement')
                    {
                      list<CombiSwapQuestion__c> c = [Select c.SystemModstamp, c.Question_9__c, c.Question_8__c, c.Question_7__c, c.Question_6__c, c.Question_5__c, c.Question_5_Notes__c, c.Question_4__c, c.Question_3__c, c.Question_2__c, c.Question_1__c, c.Question_11__c, c.Question_10__c, c.OutputSize__c, c.Opportunity__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.GCNumber__c, c.CreatedDate, c.CreatedById From CombiSwapQuestion__c c where Opportunity__c = :lstOppInfo[0].Opp.Id];
                      if(c.size()>0)
                      info.combiSwap = c[0];
                      info.showCombiswap = true;
                    }
                    */
                    //Added By Ashok G
                    /*
                    if(lstOppInfo[0].Opp.Product_Interest__c!= null && (lstOppInfo[0].Opp.Product_Interest__c.contains('Telesales Conv') || lstOppInfo[0].Opp.Product_Interest__c.contains('Straight Swap')))
                    {
                    
                      System.debug('kanitha combi swap ');
                      list<CombiSwapQuestion__c> c = [Select c.SystemModstamp,c.Type__c,c.S_S_C1__c,c.S_S_C2__c,c.S_S_C3__c,c.S_S_C4__c,c.S_S_C6__c,c.S_S_C7__c,c.S_S_C9__c,c.S_S_C10__c,c.S_S_C14__c,c.S_S_CN9__c,c.S_S_Q1__c ,c.S_S_CON__c,c.S_S_Q2__c ,c.S_S_Q3__c,c.S_S_Q4__c,c.S_S_Q6__c,c.S_S_Q7__c,c.S_S_Q8__c,c.S_S_Q9__c,c.S_S_Q10__c,c.S_S_Q11__c,c.S_S_Q12__c,c.S_S_Q13__c,c.S_S_Q14__c,c.S_S_TC16__c,c.S_S_TC12__c,c.S_S_TC3__c,c.S_S_TC14__c,c.S_S_TC6__c,c.S_S_TC15__c,c.S_S_TC4__c,c.S_M_Authorisation_Number__c,
                                                             c.S_S_TC9__c,c.Question_9__c, c.Question_8__c, c.Question_7__c, c.Question_6__c, c.Question_5__c, c.Question_5_Notes__c, c.Question_4__c, c.Question_3__c, c.Question_2__c, c.Question_1__c, c.Question_11__c, c.Question_10__c, c.OutputSize__c, c.Opportunity__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.GCNumber__c, c.CreatedDate, c.CreatedById,
                                                             c.SSD1__c,c.SSD2__c,c.SSD3__c,c.SSD4__c,c.SSD5__c,c.SSD6__c,c.SSD7__c,c.SSD8__c, Vertical_Flue__c,S_S_TC5__c,Socket_C_Q__c,S_S_C__c,S_S1__c,S_S2__c,S_S_C11__c,C_S_C3__c,S_S_CC1__c,C_S_C2__c,C_S_C5__c,C_S_C1__c,C_S_C7__c,S_S_C13__c,S_S_C16__c,S_S_C12__c,C_S_C4__c,S_S_C15__c,C_S_C6__c  From CombiSwapQuestion__c c where Opportunity__c = :lstOppInfo[0].Opp.Id];
                      if(c.size()>0)
                      info.combiSwap = c[0];
                      info.showCombiswap = true;
                    }*/
                    
                }
            }
        }
        return info;
    }
    
    public static Workflow.WorkflowInfo GetAppointments(Workflow.WorkflowInfo info)
    {
        
        //fetch appointments
        List<Appointment__c> lstAppointments = new List<Appointment__c>(); 
        if(info.Call.CHI_Lead__c != null)
        {
            lstAppointments.addAll([Select a.Name, a.Status__c,Type__c, a.Visit_Date__c, a.Time_Band__c, a.Start_Time__c, a.End_Time__c, a.BM_Salesperson__c, a.Assigned_To__r.Primary_Role__c, a.Assigned_To__c,a.TA_Notes_All__c,a.Status_Reason__c, a.Primary_Cancellation_Reason__c,a.Secondary_Cancellation_Reason__c From Appointment__c a where a.Opportunity__c =:info.Call.CHI_Lead__c]);
        }
        //set appointments in appoinemts list
        info.Appointments = lstAppointments;
        
        //set appointments in select appointments list
        List<SelectedAppointment> lstSelectAppointments = new List<SelectedAppointment>();
        SelectedAppointment lstSelectApp;
        for(Appointment__c appoint:lstAppointments)
        {
            lstSelectApp = new SelectedAppointment();
            lstSelectApp.appointment = appoint;
            lstSelectApp.appoinSelected = false;
            // ++ GD Chnage
            if(appoint.Status__c == 'Appointed')
            {
                lstSelectApp.showIsSelct = true;
                
                if(appoint.Type__c == 'Green Deal')
                {
                    lstSelectApp.GreenDeal = true;
                    
                    if(info.isGDAEnabled!=null && !info.isGDAEnabled)
                    lstSelectApp.showIsSelct = false;
                }
                else
                lstSelectApp.GreenDeal = false;     
            }
            else
            lstSelectApp.showIsSelct = false;  
            // -- GD Change
            lstSelectAppointments.Add(lstSelectApp);
          
        } 
        info.SelectedAppointments = lstSelectAppointments;
        return info;
    }
      
    
    public static Workflow.WorkflowInfo newCallData(Workflow.WorkflowInfo info){
        if(info != null && info.Call != null){
            info.Opportunities = new List<Opportunity>();
            info.ContactInfos = new List<ContactInfo>();
            info.NewContactInfos = new List<ContactInfo>();
            //List<ContactInfo> tempConInfo = new List<ContactInfo>();
            Account tempAcc = new Account();    
            Inbound_Call__c inCall = info.Call;
            system.debug(' incall '+incall);
            tempAcc.BillingStreet = inCall.Billing_Street__c;
            tempAcc.BillingCity = inCall.Billing_City__c;
            tempAcc.BillingState = inCall.Billing_State__c;
            tempAcc.BillingCountry = inCall.Billilng_Country__c;
            tempAcc.BillingPostalCode = inCall.Billing_Zip__c;
            
            //CODE ADDED ------------------------------------------------------------
            //DATE:- May 10, 2012
            //DESCRIPTION:- Code to handle SAP PI calls and data processing
            tempAcc.CustomerUCRN__c = info.CustomerUCRN;
            tempAcc.ProductHoldingLastUpdated__c = Date.today();
            //CODE ADDITION ENDS ----------------------------------------------------
            
            //code to add region and district
            if(inCall.Billing_Zip__c != null)
            {
            String postCodeSector = inCall.Billing_Zip__c.substring(0,inCall.Billing_Zip__c.length()-2);
            system.debug('====post code sector==='+postCodeSector );
            Postcode_Sector__c pcs = [select id,Sub_Patch__c,Sub_Patch__r.District__r.name,Sub_Patch__r.District__r.region__r.name,
                                    Sub_Patch__r.District__r.Message_1_Area__c,Sub_Patch__r.District__r.Message_2_Area__c,
                                    Sub_Patch__r.District__r.Message1_Active__c,Sub_Patch__r.District__r.Message2_Active__c, Sub_Patch__r.Appointment_Source__c,
                                    Sub_Patch__r.District__r.region__r.Customer_Category__c from Postcode_Sector__c where name=:postCodeSector and type__c='Sales'];
            
            if(pcs!=null)
            {
                info.district = pcs.Sub_Patch__r.District__r.name;
                info.region = pcs.Sub_Patch__r.District__r.region__r.name;
                info.messageStr1 = pcs.Sub_Patch__r.District__r.Message_1_Area__c;
                info.messageStr2 = pcs.Sub_Patch__r.District__r.Message_2_Area__c;
                info.messageBool1 = pcs.Sub_Patch__r.District__r.Message1_Active__c;
                info.messageBool2 = pcs.Sub_Patch__r.District__r.Message2_Active__c;
                info.customerCateogryType = (pcs.Sub_Patch__r.District__r.region__r.Customer_Category__c!=null)?pcs.Sub_Patch__r.District__r.region__r.Customer_Category__c:'0' ;
                System.debug('===messageBool==='+pcs.Sub_Patch__r.District__r.Message1_Active__c);
                
                if(pcs.Sub_Patch__r.Appointment_Source__c=='OFS')
                {  
                    Utilities util = new Utilities();                      
                    util.setErrorMsg(false, 'This district is set to go live for OFS');             
                    
                }
            }
            }
            tempAcc.Name = 'TestAccount';
            system.debug('-------------and the adress issssss  '+inCall.Billing_Street__c+','+inCall.Billing_City__c+','+inCall.Billing_State__c);
            info.CurrentAccount = tempAcc;
            System.debug('  --------------info.CurrentAccount------------'+info.CurrentAccount);
            info.Contacts = new List<Contact>();
            for(Integer i=0;i<2;i++){
                Contact tempCon = new Contact();
                
                tempCon.Description = '' + i; 
                if(i==0 && info.newInbound)
                tempCon.Primary_Contact__c = true;
                
                info.Contacts.add(tempCon);
                ContactInfo tempConInfo = new ContactInfo();
                tempConInfo.contact = tempCon;
                
                info.NewContactInfos.add(tempConInfo);
            }
            Opportunity tempOpp = new Opportunity();
              if(info.prospect!= null)
                {
                    tempOpp.Product_Interest__c = info.prospect.Product_Interest__c;
                } 
            //tempOpp.Firefly_Script_Complete__c = true;
            //tempOpp.Firefly_Id__c = 'firefly';
            info.Opportunities.add(tempOpp);
        }
        return info;
    }
    
    public static Workflow.WorkflowInfo ValidateCSwap(Workflow.WorkflowInfo info){
       
       CombiSwapQuestion__c cSwap = info.combiSwap;
        /*
        system.debug('inside validate Cswap');
        system.debug(cSwap.C_S_C1__c);
        system.debug(cSwap.Is_the_current_boiler_18KW_or_less__c);
        system.debug(cSwap.Horizontal_flue_be_installed_to__c);
        system.debug(cSwap.C_S_C3__c);
        system.debug(cSwap.Is_a_top_or_rear_flue_required__c);
        system.debug(cSwap.Any_horizontal_flue_extensions_required__c);
        system.debug(cSwap.Are_any_flue_bend_required__c);
        system.debug(cSwap.Is_a_Plume_Kit_Requiredd__c);
        system.debug(cSwap.Is_balanced_flue_brick_up_required__c);
        system.debug(cSwap.C_S_C4__c);
                     system.debug(cSwap.C_S_C5__c);
                      system.debug(cSwap.Is_a_fused_spurr_fitted__c);
                       system.debug(cSwap.C_S_C6__c);
                        system.debug(cSwap.Is_there_a_visiblee_main_earth__c);
                         system.debug(cSwap.C_S_C7__c);
                          system.debug(cSwap.Is_a_powerflushh_required__c);
        */                  
       
       List<Opportunity> lstOpp = info.Opportunities;
       if((lstOpp.get(0).Product_Interest__c == 'Straight Swap' ||  lstOpp.get(0).Product_Interest__c == 'Straight Swaps e-quote')&& cSwap!= null){
       system.debug('===============================in Validate'+info.combiSwap +cSwap.S_S_Q6__c );
     
           if((cSwap.S_S_CC1__c == null || cSwap.New_Horizontal_flue_installed_to_current__c == null || cSwap.S_S_C12__c == null ||cSwap.Horizontal_flue_extensions_required__c == null || cSwap.Are_any_flue_bends_required__c==null || cSwap.Is_a_Plume_Kit_Required__c==null || cSwap.Is_a_balanced_flue_brick_up_required__c==null || cSwap.S_S_C13__c==null || cSwap.What_fuel_type_is_the_boiler__c==null || cSwap.Is_a_fused_spur_fitted__c==null
             || cSwap.S_S_C15__c==null ||cSwap.S_S_C16__c==null ||cSwap.Already_has_magnetic_filter__c==null || cSwap.Already_have_a_scale_reducer__c==null || /*cSwap.S_S_Q14__c==null || cSwap.S_S_TC9__c==null || cSwap.S_S_Q15__c==null || */ cSwap.Type__c != 'Combi')){
               system.debug('---Inside Validation--');
               info = SetError(info,'Please fill All the Straight Swap combi Questions or You have tried to complete the wrong questions for the product interest you have chosen. If you have chosen product interest of ‘Straight Swap’ please choose ‘Combi’ questions. If the product interest is ‘Telesales Conv’ then please choose ‘Conv’ straight swaps questions.');
           }
       }
        system.debug(lstOpp);
       if((lstOpp.get(0).Product_Interest__c.contains('Telesales Conv') ||  lstOpp.get(0).Product_Interest__c == 'Telesales Conv e-quote') && cSwap!= null){
        if((cSwap.C_S_C1__c==null ||cSwap.Is_the_current_boiler_18KW_or_less__c==null || cSwap.C_S_C2__c==null || cSwap.Horizontal_flue_be_installed_to__c==null || cSwap.C_S_C3__c==null ||  cSwap.Is_a_top_or_rear_flue_required__c==null
         || cSwap.Any_horizontal_flue_extensions_required__c==null || cSwap.Are_any_flue_bend_required__c==null || cSwap.Is_a_Plume_Kit_Requiredd__c==null || cSwap.Is_balanced_flue_brick_up_required__c==null || cSwap.C_S_C4__c==null ||
        cSwap.C_S_C5__c==null||cSwap.Is_a_fused_spurr_fitted__c==null||cSwap.C_S_C6__c==null || cSwap.Is_there_a_visiblee_main_earth__c==null || cSwap.C_S_C7__c==null || cSwap.Is_a_powerflushh_required__c==null || cSwap.Type__c != 'Conv')){
           system.debug('---Inside Validation--');
           info = SetError(info,'Please fill All the Straight Swap Conventional Questions or You have tried to complete the wrong questions for the product interest you have chosen. If you have chosen product interest of ‘Straight Swap’ please choose ‘Combi’ questions. If the product interest is ‘Telesales Conv’ then please choose ‘Conv’ straight swaps questions.');
        }
       }
       return info;
    }
    
    
    
    public static Workflow.WorkflowInfo ValidateContact(Workflow.WorkflowInfo info)
    {
        // validation - Only one contact can be primary 
        Integer PrimaryCount = 0;
        List<ContactInfo> lstcontacts = info.NewContactInfos;
        List<ContactInfo> lstcontactInfo = info.ContactInfos;
        MessageConstants msgConstants = new MessageConstants();
        Boolean isExistingPrimary = false;
        Boolean existingContactSelected=false;
        //check if any of the selected contacts of existing ones is primary contact
        system.debug('inside ValidateContact:::: lstcontactInfo = ' + lstcontactInfo);
        system.debug('inside ValidateContact:::: lstcontacts = ' + lstcontacts);
        system.debug('new Inbound validate Contact:::'+info.newInbound);
        //CASE: New/Existing contacts are present
        //check if primary contact is selected in existing contacts
        Integer selectedExistingContacts = 0; 
        Integer totalContacts = 0;
        Integer totalNewContacts = 0;
        if(info.CurrentAccount.Number_Of_Bedrooms__c == null && !info.newInbound)
        info = SetError(info, msgConstants.ERR_ENTERBEDROOMS);
        
        for(ContactInfo c :lstcontactInfo)
        {
            if(c.ConSlct == true)
            {
                existingContactSelected=true;
                totalContacts++;
                if(c.Contact.Primary_Contact__c == true)
                {
                    System.debug('--------------- contactinfo = '+ c);
                    isExistingPrimary = true;
                    break;
                }
            }
        }
        System.debug('--------------- validatecontact info.IsError 0= '+ info.IsError);
        //Validation for New Contact's Salutation,Firstname and Lastname field : it should be mandatory
        for(ContactInfo c : lstcontacts){
            if((c.contact.Salutation != null && c.contact.Salutation != '' && c.contact.Salutation.trim().length()>0) || (c.contact.FirstName != null && c.contact.FirstName != '' && c.contact.FirstName.trim().length()>0) || (c.contact.LastName != null && c.contact.LastName != '' && c.contact.LastName.trim().length()>0) || (c.Contact.Contact_Type__c != null && c.Contact.Contact_Type__c != '' && c.Contact.Contact_Type__c.trim().length()>0) || (c.Contact.Primary_Contact__c == true))
            {
                if((c.Contact.Salutation == null || c.Contact.Salutation == '' || c.Contact.Salutation.trim().length()==0)){
                    info = SetError(info, msgConstants.ERR_CONTACTSALUTATIONREQUIRED);
                }
                if(c.Contact.FirstName == null || c.Contact.FirstName == '' || c.Contact.FirstName.trim().length()==0){
                    info = SetError(info, msgConstants.ERR_CONTACTFIRSTNAMEREQUIRED);
                }
                if(c.Contact.LastName == null || c.Contact.LastName == '' || c.Contact.LastName.trim().length()==0){
                    info = SetError(info, msgConstants.ERR_CONTACTLASTNAMEREQUIRED);
                } 
                if(c.Contact.Contact_Type__c == null || c.Contact.Contact_Type__c == '' || c.Contact.Contact_Type__c.trim().length()==0){
                    info = SetError(info, msgConstants.ERR_CONTACTTYPEREQUIRED);
                } 
                
                //code added to validate contact numbers
                /*System.debug('===contact=='+c.Contact);
                System.debug('======Contact Numbers'+c.Contact.HomePhone+'=='+c.Contact.HomePhone.isNumeric()+'=='+c.Contact.HomePhone.length()+'=='+c.Contact.HomePhone.startsWith('0'));
               
                if(c.Contact.HomePhone == NULL || c.Contact.HomePhone.isNumeric() != true || c.Contact.HomePhone.length() != 11 || c.Contact.HomePhone.startsWith('0') != true){
                    info = SetError(info, 'This is not a valid phone number format. Please re-enter.');
                }
                
                if(c.Contact.MobilePhone== NULL || c.Contact.MobilePhone.isNumeric() != true || c.Contact.MobilePhone.length() < 11 || c.Contact.MobilePhone.startsWith('0') != true){
                    info = SetError(info, 'This is not a valid mobile number format. Please re-enter.');
                }
                
                if(c.Contact.OtherPhone== NULL || c.Contact.OtherPhone.isNumeric() != true || c.Contact.OtherPhone.length() < 11 || c.Contact.OtherPhone.startsWith('0') != true){
                    info = SetError(info, 'This is not a valid other phone number format. Please re-enter.');
                }*/
                
               if(System.Label.Inbound_Call_Change_Switch == 'Yes'){
                    if(c.contact.Preferred_Contact_Method__c == NULL || c.contact.Preferred_Contact_Method__c == '--None--' || c.contact.Preferred_Contact_Method__c == ''){
                        info = SetError(info, 'Please select preferred contact method');
                    }
                    else{
                        if(c.contact.Preferred_Contact_Method__c == 'Phone' && c.contact.HomePhone == NULL && c.contact.MobilePhone == NULL){
                            info = SetError(info, 'Home/Mobile Phone number is mandatory');
                        }
                        
                        if(c.contact.Preferred_Contact_Method__c == 'Text (SMS)' && c.contact.MobilePhone == NULL){
                            info = SetError(info, 'Mobile Phone number is mandatory');
                        }    
                        
                        if(c.contact.Preferred_Contact_Method__c == 'Email' && c.contact.Email__c == NULL){
                            info = SetError(info, 'Email is mandatory');
                        }
                    } 
                }   
            } 
            
            
            //system.debug(c.Contact.Id+ c.Contact.Contact_Type__c + c.Contact.Email__c +c.Contact.MobilePhone+c.Contact.HomePhone +c.Contact.Otherphone );
            if(c.Contact.Id == null && (c.Contact.Contact_Type__c == 'Landlord' || c.Contact.Contact_Type__c == 'Agent' || c.Contact.Contact_Type__c == 'Multi Premise' )&& 
              (c.Contact.Email__c == null && c.Contact.MobilePhone==null && c.Contact.HomePhone == null && c.Contact.Otherphone == null))
            {
                info = SetError(info, msgConstants.Err_No_Contact_Leads);
            }
            
        }  
        System.debug('--------------- validatecontact info.IsError 1= '+ info.IsError);
        //check if any of the new contacts are set to be primary
        for(ContactInfo c :lstcontacts) 
        {
            if((c.contact.Salutation != null && c.contact.Salutation != '' && c.contact.Salutation.trim().length()>0) && (c.contact.FirstName != null && c.contact.FirstName != '' && c.contact.FirstName.trim().length()>0) && (c.contact.LastName != null && c.contact.LastName != '' && c.contact.LastName.trim().length()>0) && (c.Contact.Contact_Type__c != null && c.Contact.Contact_Type__c != '' && c.Contact.Contact_Type__c.trim().length()>0))
            {
                if(c.Contact.Primary_Contact__c == true)
                {
                    PrimaryCount++; 
                }
                totalNewContacts++; //counts new contact entered
            }else if(c.Contact.Primary_Contact__c == true){
                PrimaryCount++;
                totalNewContacts++; //counts new contact entered
            }
        }
        System.debug('--------------- validatecontact info.IsError 2= '+ info.IsError);    
        System.debug('------------------- totalContacts = ' + totalContacts);
        if(totalContacts > 0 || totalNewContacts > 0)
        {
            if((isExistingPrimary == true && PrimaryCount > 0) || (isExistingPrimary == false && PrimaryCount > 1))
            {
                //Case when there are multiple primary contacts amongst the new and existing contacts
                info = SetError(info, msgConstants.ERR_PRIMARYCONTACT);            
                System.debug('-------------------------if  PrimaryCount = ' + PrimaryCount);
                System.debug('--------------- validatecontact info.IsError 3= '+ info.IsError);
            }
            else if(isExistingPrimary == false && PrimaryCount == 0)
            {
                //###########################################
                //Case when user has not selected any primary contact from existing contacts
                System.debug('-------------------------else  PrimaryCount = ' + PrimaryCount);
                info = SetError(info, msgConstants.ERR_ONEPRIMARYCONTACT);
                System.debug('--------------- validatecontact info.IsError 4= '+ info.IsError);
                //if any of existing records is selected
            }
        }
        else
        {
            info = SetError(info, msgConstants.ERR_NOCONTACT);
        }     
        System.debug('--------------- validatecontact info.IsError 5= '+ info.IsError);
        
        return info;        
    }
    //*************************************************************
    public static Workflow.WorkflowInfo ValidateOpportunity(Workflow.WorkflowInfo info)
    {
        //Product_Interest__c, CampaignId, Referral_Employee__c,
        CallMode objcallMode= new CallMode();
        MessageConstants msgConstants = new MessageConstants();
        List<Opportunity> lstOpp = info.Opportunities;
        
        for(Opportunity o :lstOpp)
        {
            if(info.WorkflowType == objcallMode.EMPLOYEECALLEXISTCUST || info.WorkflowType == objcallMode.EMPLOYEECALLNEWCUST){
                  if(o.CampaignId != null)
                  {
                    Campaign c = [Select Fusion_Campaign__c from Campaign where Id = :o.CampaignId];
                    if(c.Fusion_Campaign__c == false)
                    info = SetError(info, msgConstants.ERR_ENTERFUSIONCAMP);
                  }  
                      
                }
                
             
            
            if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST || info.WorkflowType == objcallMode.EMPLOYEECALLNEWCUST || info.WorkflowType == objcallMode.EMPLOYEECALLEXISTCUST)
            {
                if(o.Referral_Employee__c == null )
                {
                    info = SetError(info, msgConstants.ERR_NOREFERRALEMPLOYEE);
                }
                
            }
            System.debug('--------------- validatecontact info.IsError 6= '+ info.IsError);
            if(info.WorkflowType == objcallMode.CUSTOMERCALLNEWCUST || info.WorkflowType == objcallMode.CUSTOMERCALLEXISTCUST)
            {                   
                if(o.CampaignId == null)
                {
                    info = SetError(info, msgConstants.ERR_ENTERCAMPAIGN);
                }
            }
            System.debug('--------------- validatecontact info.IsError 7= '+ info.IsError);
            if(o.Product_Interest__c == null){
                info = SetError(info, msgConstants.ERR_ENTERPRODUCTINTEREST);
            }  
            
            if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST)
            {
                if(o.Enquiry_Reason__c=='Unsafe appliance')
                {
                    if(o.Unsafe_Appliance_Reason__c==null || o.Unsafe_Appliance_Reason__c=='')
                    {
                            //errorMsg = msgConstants.ERR_ENGINEERREASON;
                            info = setError(info,msgConstants.ERR_ENGINEERREASON);
                    }
                }
            } 
            
            // This validation is added for new field added to Opportunity object.
            // This field is named as 'Customer agreed to appointment.
            // This field needs to be mandatory for engineer call.
            
              if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST)
            {                   
                if(o.Customer_agreed_to_appointment__c != 'Yes' && o.Customer_agreed_to_appointment__c != 'No')
                {
                    info = SetError(info, msgConstants.ERR_ENGINEERCUSTAGDAPP);
                }
                if(o.WithCustomer__c =='No' && o.WithCustReasons__c == null)
                {
                    info = SetError(info, msgConstants.ERR_WITH_CUST);
                }
            }
            
            String str='';
            For(PicklistWrapper wrapper:info.picklistValues){
                if(wrapper.isSelected==True){
                    str += wrapper.value + ';';
                    
                }
                
                
            }
            if(str!='')
            o.Marketing_Preferences__c=str;
            
            if(system.label.CCHSwitch == 'on' && (o.Customer_Marketing_Consent__c == '' || o.Customer_Marketing_Consent__c ==  null || 
            (o.Customer_Marketing_Consent__c == 'Yes' && (o.Marketing_Preferences__c ==  null || o.Marketing_Preferences__c ==  ''))))
            {
                info = SetError(info, msgConstants.ERR_MarketingConsent);
            }
            
            
            // ++ Added for Priority Installations CR start
               if(o.Latest_customer_category__c != 1 && 
                  o.Latest_customer_category__c != 2 && 
                  o.Latest_customer_category__c != 3 && 
                  o.Latest_customer_category__c != 4 &&
                  info.include_priority_install){
                    info = SetError(info, msgConstants.ERR_DERIVE_CUSTOMER_CATEGORY);
               } 
               if(info.include_priority_install && o.Is_the_customer_vulnerable__c == 'Yes' && (o.Vulnerable_reason__c == null || o.Vulnerable_reason__c == '' || o.Vulnerable_reason__c == 'Not applicable')){
                    info = SetError(info, msgConstants.ERR_ENTER_VULNERABLE_REASON);
               }
            // -- Added for Priority Installations CR end
            
            if(o.Nectar_Number__c != null)
            {
                string nectarNumber = o.Nectar_Number__c.replaceall(' ', '').trim();
                 
                if(!WorkflowHelper.CCValidation(nectarNumber))
                info = SetError(info, 'Invalid Nectar Number.');
                else
                o.Nectar_Number__c =  nectarNumber;
            }
            
            
            System.debug('--------------- validatecontact info.IsError 8.1= '+ info.IsError+info.warning);   
            
            if(!info.warning && o.Product_Interest__c == 'Straight Swap' && info.gasCouncil1!=null && !info.gasCouncil1.startsWith('47'))
            {
                
                info.warning =true;
                info = SetError(info, 'The Gas Council number for the majority of combi boilers should begin with 47. Please double check this before proceeding with a ‘Straight Swap’ product interest');
                
            }else if(info.warning)
            info.IsError = false;
            
            if(!info.warning && o.Product_Interest__c == 'Telesales Conv' && info.gasCouncil1!=null && !info.gasCouncil1.startsWith('41') )
            {
                info.warning =true;
                info = SetError(info, 'The Gas Council number for the majority of conventional boilers should begin with 41. Please double check this before proceeding with a ‘Telesales Conv’ product interest.');
                
            }else if(info.warning)
            info.IsError = false;
            
            
            try//if(o.Product_Interest__c == 'Telesales Combi' || o.Product_Interest__c == 'Telesales Conventional')
            {
                string post_code = info.CurrentAccount.BillingPostalCode.trim();
                string postCodeSector = post_code.substring(0,post_code.length()-2);
                Postcode_Sector__c p = [select id,NotAvailableFor__c from Postcode_Sector__c where Name = : postCodeSector and type__c = 'Sales'];
                if(p.NotAvailableFor__c!=null && (p.NotAvailableFor__c.contains(o.Product_Interest__c)))
                {
                    info = SetError(info, o.Product_Interest__c+' is not available in this Post code');
                }
                
                
            }catch(exception e){}
            
        }         
        System.debug('--------------- validatecontact info.IsError 8= '+ info.IsError+info.warning);     
        
        return info;        
    }
    
    //*************************************************************
    public static Workflow.WorkflowInfo CreateLeadAccountOpp(Workflow.WorkflowInfo info)
    {          
             //CODE ADDED - Keerthi -----------------------------------------------------
            //DATE:- June 8, 2018
            //DESCRIPTION:- To fetch the latitude and longitude details of the accounts
           
        system.debug('@@'+info.combiSwap);
        Account acct = info.CurrentAccount;
        
        string street = acct.BillingStreet!=null?acct.BillingStreet.normalizeSpace().replaceall(' ','+').trim():'';
        string city = acct.BillingCity!=null ? acct.BillingCity.normalizeSpace().replaceall(' ','+').trim():'';
        string pcode = acct.BillingPostalCode!=null?acct.BillingPostalCode.normalizeSpace().replaceall(' ','+').trim():'';
        string Address = street + '+'+city+ '+' +pcode;
        System.debug('address string send to utility-->'+Address);
        try{
            list<string> Latlang = Utilities.getLatLang(Address,pcode);
            if(Latlang.size()==2)
            {
                acct.Latitude__Latitude__s = double.valueof(Latlang[0]);
                acct.Latitude__Longitude__s = double.valueof(Latlang[1]);
            }   
            System.debug('Latitude--> '+acct.Latitude__Latitude__s);
            System.debug('Longitude-->'+acct.Latitude__Longitude__s);
        }catch (Exception e)
        {
            
        }
        
        
        
        //Keerthi
        System.Savepoint sp = Database.setSavepoint();
        System.debug('=======priti Info===='+info.CurrentAccount);
        try
        {   String errorMsg='';
            MessageConstants msgConstants = new MessageConstants();
            List<ContactInfo> lstcontacts = info.NewContactInfos;
            List<ContactInfo> exlstCon = info.ContactInfos;
            List<Contact> validcontacts = new List<Contact>(); 
            List<Opportunity> lstOpp = info.Opportunities;
            CombiSwapQuestion__c cSwap = info.combiSwap;
            system.debug('Combi swap --->'+cSwap);
            CallMode objcallMode = new CallMode();
            string multiPremise ;
            //data validation
            info = ValidateContact(info);
            info = ValidateOpportunity(info);
            info = ValidateCSwap(info);
            
            System.debug('-----## info.IsError-----' +info.IsError + info.CurrentAccount);
            //in case of error return back
            if(info.IsError) return info;
            
            System.debug('-----## before upsert account-----');
            //Create/update account -------------------
            //Account tempAcc = info.CurrentAccount;
            
            
            // check if there are any previous accounts already added as prospect change
            String AccountName = info.CurrentAccount.BillingPostalCode.trim() + ' ';
            String str2 = info.CurrentAccount.BillingStreet.trim(); // 2 space in between
            //Modified the length for PRB00016664
            /*if( str2.length() > 8)
                AccountName += str2.substring(0,8).trim(); // 2 space in between*/ 
            if( str2.length() > 29) 
                AccountName += str2.substring(0,29).trim(); // 2 space in between
            else
                AccountName += str2;
            System.debug('-------------- AccountName = ' + AccountName);
            
            integer count = [select count() from Account where Name=:AccountName];
            Account tempAcc = new Account();
            
            Boolean isExistingAccount = false;
            System.debug('======Count====='+count);
            if(count > 0)
            {
                
                tempAcc = [Select Id, ShippingStreet, Name, Status__c, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity, Primary_Contact__c, Number_of_Bedrooms__c, Gas_Supply_At_Address__c,Gas_Supply_At_Address1__c, Current_Heating_System__c, Current_Heating_System1__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, CreatedDate,  Account_Id__c, Sales_Region__c,Sales_District__c,Number_of_Bathrooms__c from Account where Name=:AccountName limit 1];
                
                //PRB00033560 starts
                if(tempAcc.Number_of_Bathrooms__c != info.CurrentAccount.Number_of_Bathrooms__c)
                tempAcc.Number_of_Bathrooms__c = info.CurrentAccount.Number_of_Bathrooms__c;
                
                if(tempAcc.Number_of_Bedrooms__c != info.CurrentAccount.Number_of_Bedrooms__c)
                tempAcc.Number_of_Bedrooms__c = info.CurrentAccount.Number_of_Bedrooms__c;
                
                if(tempAcc.Gas_Supply_At_Address1__c != info.CurrentAccount.Gas_Supply_At_Address1__c)
                tempAcc.Gas_Supply_At_Address1__c = info.CurrentAccount.Gas_Supply_At_Address1__c;                
                
                //PRB00033560 ends
                
                isExistingAccount = true;
            }
            else
            {
                
                tempAcc = info.CurrentAccount;
                //tempAcc.Id = NULL;
            }
            // asbestos change : Whenever Astebestos found is Yes then we populate with todays date.
            
            System.debug('===accountWhileUpserting==='+tempAcc);            
            if( info.CurrentAccount.Asbestos_found__c == 'Yes')
              tempAcc.Asbestos_Found_Date_New__c = system.today();
            upsert tempAcc;
            system.debug('-----CallingProInfo----');
            
            //CODE ADDED - PRODUCT HOLDING -----------------------------------------------------
            //DATE:- May 10, 2012
            //DESCRIPTION:- Create/ update product holding record
            //if product holding is not null
            
            //----------------------------------------
           
            
            
            //Create Contact -------------------
            //set account field for contacts
            boolean tenant = false, Landlord = false;
            for(ContactInfo c :lstcontacts)
            {
                if((c.contact.Salutation != null && c.contact.Salutation != '' && c.contact.Salutation.trim().length()>0)&& (c.contact.FirstName != null && c.contact.FirstName != '' && c.contact.FirstName.trim().length()>0) && (c.contact.LastName != null && c.contact.LastName != '' && c.contact.LastName.trim().length()>0) && (c.Contact.Contact_Type__c != null && c.Contact.Contact_Type__c != '' && c.Contact.Contact_Type__c.trim().length()>0))
                {
                    c.contact.AccountId = tempAcc.ID;
                    c.contact.Description = '';
                    
                    if(c.AddSlct == true){
                        //If true set account address
                        c.contact.MailingStreet = tempAcc.BillingStreet;
                        c.contact.MailingCity = tempAcc.BillingCity; 
                        c.contact.MailingState = tempAcc.BillingState;
                        c.contact.MailingCountry = tempAcc.BillingCountry;
                        c.contact.MailingPostalCode = tempAcc.BillingPostalCode;
                        
                        
                        //validcontacts.Add(c.contact);
                    }
                    
                    if(c.contact.Contact_Type__c == 'Tenant')
                        tenant = true;
                    else if(c.contact.Contact_Type__c == 'Landlord' || c.contact.Contact_Type__c == 'Agent'
                     || c.contact.Contact_Type__c == 'Multi-premise')
                     {
                        Landlord = true;
                        if(c.contact.Contact_Type__c == 'Multi-premise' && c.contact.Multi_Premise__c!=null)
                        multiPremise = c.contact.Multi_Premise__c;
                     }    
                     if(c.contact.Primary_Contact__c )
                     {
                         c.contact.Marketing_Preference__c = lstOpp[0].Marketing_Preferences__c;
                         c.contact.Marketing_Consent__c = lstOpp[0].Customer_Marketing_Consent__c;
                     }
                        
                    validcontacts.Add(c.contact);
                    System.debug('-------the contact address is-------------'+c.contact.MailingStreet+','+c.contact.MailingCity+','+c.contact.MailingState+','+c.contact.MailingCountry);   
                } 
            }
            
            System.debug('-----validcontacts-----' +validcontacts);
            System.debug('-----validcontacts size-----' +validcontacts.size());
            
            if(validcontacts.size() > 0)
            {
                upsert validcontacts;
            }
            
             System.debug('-----after upsert validcontacts-----');
            //-------------------------------------------------
            //code for marking unselected contacts in info.ContactInfos as Inactive (set isactive=false)
            List<Contact> unslcCon = new List<Contact>();
            //CR:FOR FUNCTIONALITY: CREATE OPPORTUNITY CONTACT ROLE RECORD FOR ONLY SELECTED CONTACT AMONGST EXISTING CONTACTS: START 
            List<Contact> contactForOppContactRole = new List<Contact>();
            //CR:FOR FUNCTIONALITY: CREATE OPPORTUNITY CONTACT ROLE RECORD FOR ONLY SELECTED CONTACT AMONGST EXISTING CONTACTS: END
            for(ContactInfo c :exlstCon)
            {
                if(c.contact.id != null && c.ConSlct == false)
                {
                    c.contact.IsActive__c = false;
                    c.Contact.Primary_Contact__c = false; //marking all inactive contacts as non-primary
                    unslcCon.add(c.contact);
                }
                //IMP:ADDED THIS COMMENT TO SPECIALLY HANDLE THE OPPORTUNITYCONTACTROLE THING-IN CASE OF SELECTED EXISTING CHI LEAD:13/01/2010:START
                else if(c.contact.id != null && c.ConSlct == true){
                  contactForOppContactRole.add(c.contact);
                } 
                //IMP:ADDED THIS COMMENT TO SPECIALLY HANDLE THE OPPORTUNITYCONTACTROLE THING-IN CASE OF SELECTED EXISTING CHI LEAD:13/01/2010:END  
            }
            if(unslcCon.size()>0){
                System.debug('----- before upsert done-------- unslcCon = ' + unslcCon);
                upsert unslcCon;
                System.debug('----- after upsert done-------- unslcCon = ' + unslcCon);
            }
            //-------------------------------------------------
            
            System.debug('-----upsert done--------');
           
            System.debug('--------lstOpp-->'+lstOpp.size());
            
            //CR26: FWA settings :START
            for(Integer i=0; i< lstOpp.size(); i++)
            {
                if(lstOpp[i].Product_Interest__c=='Fanned Warm Air'){
                    info.ShowFWAMessage = true;
                }
            }
            System.debug('--------info.ShowFWAMessage-->'+info.ShowFWAMessage);
            //CR26: FWA settings :END
            
            
            //Create Opportunity -----------------------------
            String ContactType = '';
            Contact conType = [select Contact_Type__c,FirstName,LastName,Salutation, MailingPostalCode,MailingStreet, MailingCity,  MailingState, MailingCountry  from Contact where Primary_Contact__c = true and AccountId =:tempAcc.ID];
            if(conType != null)
            {
                ContactType = conType.Contact_Type__c;
            }
                      
            
            System.debug('--------ContactType-->'+ContactType);
            for(Integer i=0; i< lstOpp.size(); i++)
            {
                /*if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST){
                    if(lstOpp[i].Enquiry_Reason__c=='Unsafe appliance'){
                        if(lstOpp[i].Unsafe_Appliance_Reason__c==null || lstOpp[i].Unsafe_Appliance_Reason__c==''){
                                errorMsg=msgConstants.ERR_ENGINEERREASON;
                                info=setError(info,errorMsg);
                                
                        }
                    }
                }*/
                
                // set the campaign value in case of Engineer call or Employee Call
                if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST)
                {
                    System.debug('--------engineer call-->');
                    
                    // set the value only if it is engineer call
                    //lstOpp[i].Validation_Question_1__c = 'Yes';
                    //lstOpp[i].Validation_Question_2__c = 'Yes';
                    //lstOpp[i].Validated_Date__c = System.today();
                                        
                    Campaign c = [Select c.Id From Campaign c where c.Name='Engineer'];
                    lstOpp[i].CampaignId = c.Id; 
                }
                else if(info.WorkflowType == objcallMode.EMPLOYEECALLNEWCUST || info.WorkflowType == objcallMode.EMPLOYEECALLEXISTCUST)
                {
                    System.debug('--------employee call-->'+lstOpp[i].CampaignId);
                    
                    if(lstOpp[i].CampaignId != null)
                    {
                      
                    }else
                    {
                      Campaign c = [Select c.Id From Campaign c where c.Name='Employee'];
                      lstOpp[i].CampaignId = c.Id;
                    }     
                } 
                System.debug('--------lstOpp[i].CampaignId-->'+lstOpp[i].CampaignId);
                
                // set the value for Boiler Working and Priority field based on Non Op value
                if(lstOpp[i].Non_Op__c==true)
                {
                    lstOpp[i].Urgency__c='Urgent';
                    lstOpp[i].Boiler_Working__c='No';
                }
                else
                {
                    lstOpp[i].Urgency__c='Standard';
                    lstOpp[i].Boiler_Working__c='Yes';
                }
                
                //set the value of Home Improvement
                if(lstOpp[i].HomeImprovementCheckbox__c==true){
                    lstOpp[i].Home_improvement__c='Yes';
                }else{
                    lstOpp[i].Home_improvement__c='No';
                }
                // ++ Added for Gas Council change start
                if(info.gasCouncil1 != null && info.gasCouncil2 != null && info.gasCouncil3 != null && info.gasCouncil1 != '' && info.gasCouncil2 != '' && info.gasCouncil3 != '' && system.label.GasCouncilNumber == 'on')
                {
                    lstOpp[i].Gas_Council_Number__c = info.gasCouncil1 + '-' + info.gasCouncil2 + '-' + info.gasCouncil3;
                }
                // -- Added for Gas Council change end
                
                lstOpp[i].AccountId = tempAcc.Id;
                lstOpp[i].Name = 'Test';
                lstOpp[i].CloseDate = System.today().addMonths(3);
                lstOpp[i].StageName = 'Active';
                lstOpp[i].Visit_Type__c = 'Sales';
                lstOpp[i].SC_Type__c = ContactType;
                lstOpp[i].Bill_Title__c = conType.Salutation;
                lstOpp[i].Bill_FirstName__c = conType.FirstName;
                lstOpp[i].Bill_LastName__c = conType.LastName;
                lstOpp[i].Bill_Street__c = conType.MailingStreet;
                lstOpp[i].Bill_Post_Code__c =conType.MailingPostalCode;
                lstOpp[i].Bill_City__c =conType.MailingCity;
                lstOpp[i].Bill_State__c =conType.MailingState;
                lstOpp[i].Bill_Country__c =conType.MailingCountry;
                lstOpp[i].Multi_Premise__c = multiPremise;
                // error if Ecogenis set Ashok 4th set CR
                if(lstOpp[i].Ecogen_Propostioned__c == true && lstOpp[i].Customer_Interested_In_Ecogen__c == null)
                {
                  info = SetError(info, msgConstants.ERR_ENTERCUSTINTRESTINECO);
                  return info;
                }
                if(lstOpp[i].Ecogen_Propostioned__c == false && lstOpp[i].Customer_Interested_In_Ecogen__c != null)
                {
                  info = SetError(info, msgConstants.ERR_ENTERPROPOSCHECK);
                  return info;
                }
                //  Enquiry source calculation: (LeadSource)
                // if Referral employee null               
                if(lstOpp[i].Referral_Employee__c == null)
                {
                        System.debug('--------Referral_Employee blank ----------');
                        // Referral Employee should not be blank in case of Employee call or Engineer call
                        if(info.WorkflowType == objcallMode.ENGINEERCALLNEWCUST || info.WorkflowType == objcallMode.ENGINEERCALLEXISTCUST || info.WorkflowType == objcallMode.EMPLOYEECALLNEWCUST || info.WorkflowType == objcallMode.EMPLOYEECALLEXISTCUST)
                        {
                            //info = SetError(info, msgConstants.ERR_NOREFERRALEMPLOYEE);
                        }
                        else
                        {
                            System.debug('--------set Marcomms ----------');
                            lstOpp[i].LeadSource = 'Marcomms';
                        }
                }
                else // if not null
                {
                    System.debug('--------Referral_Employee not blank ----------');
                    System.debug('--------Referral_Employee__c----------'+lstOpp[i].Referral_Employee__c);
                                        
                    // Assumption : This will execute only once to get the group code of selected Referral Employee
                    Employee__c emp = [select Group__c from Employee__c where Id =:lstOpp[i].Referral_Employee__c limit 1];
                    System.debug('---------emp---------'+emp);
                    
                    if(emp != null)
                    {
                        if(emp.Group__c!=null &&  system.label.EngineerEmployeeGroup.contains(','+emp.Group__c+','))
                        {
                            lstOpp[i].LeadSource = 'Engineer';
                        }
                        else
                        {
                            lstOpp[i].LeadSource = 'Other Employee';
                        }
                    }
                }                                                
            }
            
            //save accounts and opportunities
            if(lstOpp.size() > 0)
            {
                System.debug(lstOpp+'-------------- validcontacts = ' + validcontacts.size());
                
                upsert lstOpp;
                
                //load Opportunity from database to retrieve autogenerated values 
                //Added one new field on Opportunity named as customer agreed for appointment.
                // MGM Change
                lstOpp = [Select id,Name, Status__c, Campaign_Name__c, MGM_Source_Opp__c, MGM_Ref_Emp__c,  Non_Op__c, Homecare__c, StageName, CreatedDate, Days_Since_Created__c, Sales_Appointment_Date_an_Time__c, Product_Interest__c, CampaignId, Referral_Employee__c, Preferred_appointment_day__c, Preferred_Visit_Date_Time__c,isMGM__c, Preferred_appointment_time__c, With_Customer__c, CHI_Lead_Id__c, Referral_Employee__r.Group__c, Enquiry_Reason__c, Boiler_Age__c, Lead_Comments__c,Type,Enquiry_Type__c,Home_improvement__c,HomeImprovementCheckbox__c,Urgency__c,Boiler_Working__c,Unsafe_Appliance_Reason__c,Customer_agreed_to_appointment__c,Reason_Code__c,Call_Back_Date__c,Ecogen_Propostioned__c,Customer_Interested_In_Ecogen__c,Contact_Centre_Fast_Track__c,Fusion_Store__c,Fusion_UCRN__c,Is_the_customers_boiler_working__c,Does_the_customer_have_hot_water__c,Customer_have_any_other_form_of_HEAT__c,
                                 Is_the_customer_vulnerable__c,Vulnerable_reason__c,Latest_customer_category_indicator__c,GDCashBack__c,Boiler_type__c,
                                 Latest_customer_category__c,WithCustomer__c,Nectar_Number__c,WithCustReasons__c,Location_of_Current_Boiler__c,Location_of_new_Boiler__c,Missing_product_holdings_reason__c,Home_Care__c,Keeping_current_boiler_in_same_place__c,Marketing_Preferences__c,Customer_Marketing_Consent__c
                                 from Opportunity where id=:lstOpp.get(0).Id];
                
                //set values for account, contact and opportunity --------------------------
                info.Call.CHI_Lead__c = lstOpp.get(0).Id;
                info.Opportunities = lstOpp;
                
                //update call with CHI Lead
                update info.Call;
                
                /*if(lstOpp.get(0).Product_Interest__c=='Combi Replacement' && cSwap!= null)
                {
                  cSwap.Opportunity__c = lstOpp[0].Id;
                  insert cSwap;
                }*/
                
                //Added By Ashok G
                if(cSwap!= null && (cSwap.Is_a_fused_spur_fitted__c != null || cSwap.Is_the_current_boiler_18KW_or_less__c != null )) //&& (cSwap.S_S_Q1__c!=null || cSwap.S_S_C1__c!=null)
                {
                  system.debug(LoggingLevel.INFO, 'Entered cswap kp');
                  system.debug(LoggingLevel.INFO, 'cSwap.Opportunity__c+lstOpp[0].Id '+cSwap.Opportunity__c+lstOpp[0].Id);
                  CombiSwapQuestion__c cSwap_new = cSwap.clone(false);
                  cSwap_new.Opportunity__c = lstOpp[0].Id;
                  upsert cSwap_new;
                  
                }
            }
            
            if(system.label.switchOnPHCreation == 'on' && info.ProductHoldingInfo != null)
            {
                if(isExistingAccount)
                {
                    markOldProductHoldingRecords(tempAcc.Id, info.ProductHoldingInfo.id);
                }
            
                //info.ShowProductHoldingInfo = true;
                info.ProductHoldingInfo.Status__c = 'Current';
                if(info.ProductHoldingInfo.Account__c == null)
                {
                    info.ProductHoldingInfo.Account__c = tempAcc.id;
                    info.ProductHoldingInfo.CHI_Lead__c = lstOpp[0].Id;
                }
                
                System.debug('====ProductHoldingInfo==='+info.ProductHoldingInfo);
                upsert info.ProductHoldingInfo;
                
                //populate parent id for new account records
                if(info.ProductHoldingAccounts != null)
                {
                    Boolean isupsertrequired = false;
                    for(ProductHoldingAccount__c accountData :info.ProductHoldingAccounts)
                    {
                        if(accountData.ProductHolding__c == null)
                        {
                            accountData.ProductHolding__c = info.ProductHoldingInfo.id;
                            isupsertrequired = true;
                        }
                    }
                     System.debug('====ProductHoldingAccounts==='+info.ProductHoldingAccounts);
                    if(isupsertrequired==true) 
                    {
                        upsert info.ProductHoldingAccounts; //insert product holding account records
                    }
                }
            }    
             // CR Lead Prospect Change Start
             
            /*if(info.prospect != null)
            {   
                list<Lead> Leadlst = [Select Status,Prospect_Action_Required__c, Name From Lead where Account_Key_Calc__c =:info.prospect.Account_Key_Calc__c and Status = 'Open' order by CreatedDate ];
                
                for(Lead l :Leadlst)
                {
                    l.status = 'Closed';
                    l.Prospect_Action_Required__c = 'No';
                    l.Reason_Code__c = '';
                    l.Call_Back_Date__c = '';
                    l.Overridden_Call_Back_Date__c = null;
                }
                if(Leadlst.size() > 0)
                update Leadlst;
                Lead clonedRecord = info.prospect.clone(false,true);
                clonedRecord.Status = 'Qualified';
                clonedRecord.prospect__c = false;
                clonedRecord.Reason_Code__c = '';
                clonedRecord.Call_Back_Date__c = '';
                clonedRecord.Overridden_Call_Back_Date__c = null;
                system.debug('info.ContactInfos[0].contact.Salutation'+info.ContactInfos[0].contact.Salutation+'info.ContactInfos[0].contact.Salutation'+info.ContactInfos[0].contact.Salutation+'info.ContactInfos[0].contact.LastName;'+info.ContactInfos[0].contact.LastName);
                system.debug('Ashok"s----nfo.ContactInfos'+info.ContactInfos);
                clonedRecord.Salutation = conType.Salutation;
              clonedRecord.FirstName = conType.Firstname;
              clonedRecord.LastName = conType.LastName;
              clonedRecord.Prospect_Action_Required__c = 'No';
                if(clonedRecord != null)
                insert clonedRecord;
            }*/
            // CR 
            //CR:Opportunity Contact Role:12/01/2010: START

            List<OpportunityContactRole> oppContactRoleList=new List<OpportunityContactRole>();

            for(Contact c : validcontacts){
              OpportunityContactRole oppContactRole=new OpportunityContactRole();
              oppContactRole.ContactId=c.Id;
              oppContactRole.OpportunityId=lstOpp[0].Id;
              oppContactRole.Role='Decision Maker';
              oppContactRoleList.add(oppContactRole);
            }

           System.debug('::::-----oppContactRoleList size:' +oppContactRoleList.size());

      if(oppContactRoleList.size() > 0){
           System.debug('::::-----inside contact role insert');
           upsert oppContactRoleList;  
      }
      
      /*List<OpportunityContactRole> oppExistingContactRoleList=new List<OpportunityContactRole>();
            for(Contact c : unslcCon){
              OpportunityContactRole oppContactRole=new OpportunityContactRole();
              oppContactRole.ContactId=c.Id;
              oppContactRole.OpportunityId=lstOpp[0].Id;
              oppContactRole.Role='Decision Maker';
              oppExistingContactRoleList.add(oppContactRole);
            }
           System.debug('::::-----oppExistingContactRoleList size:' +oppExistingContactRoleList.size());
      if(oppExistingContactRoleList.size() > 0){
           System.debug('::::-----inside contact role insert for existing contacts.');
           upsert oppExistingContactRoleList;  
      }*/
      
      List<OpportunityContactRole> oppExistingContactRoleList=new List<OpportunityContactRole>();
            for(Contact c : contactForOppContactRole){
              OpportunityContactRole oppContactRole=new OpportunityContactRole();
              oppContactRole.ContactId=c.Id;
              oppContactRole.OpportunityId=lstOpp[0].Id;
              oppContactRole.Role='Decision Maker';
              oppExistingContactRoleList.add(oppContactRole);
            }
           System.debug('::::-----oppExistingContactRoleList size:' +oppExistingContactRoleList.size());
      if(oppExistingContactRoleList.size() > 0){
           System.debug('::::-----inside contact role insert for existing contacts.');
           upsert oppExistingContactRoleList;  
      }
      
            //CR:Opportunity Contact Role:12/01/2010: END
            
            info.CurrentAccount = tempAcc; 
            info.Contacts = validcontacts;
            info = SetContacts(info);
            if(tenant || landlord)
            info.showApp = true;
            
        } 
        catch(Exception ex)
        {
            System.debug('## Exception in CreateLeadAccountOpp: '+ex);
            Database.rollback(sp);
            if(ex.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                System.debug('========first Exception in createLead======'+ex);
               
                List<Account> tempAcc = new List<Account>();
                tempAcc.add(info.CurrentAccount);
                List<Account> acc = tempAcc.deepclone();
                info.CurrentAccount = new Account();
                System.debug('====Accoutns==='+info.CurrentAccount);
                info.CurrentAccount.Name = acc[0].Name;
                info.CurrentAccount.BillingCountry= acc[0].BillingCountry;
                info.CurrentAccount.Gas_Supply_Confirmation__c= acc[0].Gas_Supply_Confirmation__c;
                info.CurrentAccount.BillingCity= acc[0].BillingCity;
                info.CurrentAccount.BillingPostalCode= acc[0].BillingPostalCode;
                info.CurrentAccount.Current_Heating_System__c= acc[0].Current_Heating_System__c;
                //Added by Ashok G
                info.CurrentAccount.Current_Heating_System1__c= acc[0].Current_Heating_System1__c;
                info.CurrentAccount.BillingStreet= acc[0].BillingStreet;
                info.CurrentAccount.CustomerUCRN__c= acc[0].CustomerUCRN__c;
                info.CurrentAccount.ProductHoldingLastUpdated__c= acc[0].ProductHoldingLastUpdated__c;
                info.CurrentAccount.BillingState= acc[0].BillingState;
                info.CurrentAccount.Number_of_Bedrooms__c= acc[0].Number_of_Bedrooms__c;
                System.debug('====Accoutns==='+info.CurrentAccount);
                /*
                list<ProductHolding__c> tempPH = new list<ProductHolding__c>();
                tempPH.add(info.ProductHoldingInfo);
                list<ProductHolding__c> ph = tempPH.deepclone();
                info.ProductHoldingInfo = new ProductHolding__c();
                System.debug('====ProductHoldingInfo==='+info.CurrentAccount);
                info.ProductHoldingInfo.IsCurrentCustomerOfAnyProduct__c = ph[0].IsCurrentCustomerOfAnyProduct__c;
                info.ProductHoldingInfo.ServiceCover__c = ph[0].ServiceCover__c;
                info.ProductHoldingInfo.Status__c = ph[0].Status__c;
                System.debug('====ProductHoldingInfo==='+info.CurrentAccount);
                
                if(info.ProductHoldingAccounts!=NULL)
                for(ProductHoldingAccount__c pha : info.ProductHoldingAccounts)
                pha.ProductHolding__c = NULL;
                */
                list<string> error = ex.getmessage().split(',');
                info = WorkflowHelper.SetError(info, error[1].substring(0, error[1].length()-4));
                return info;
            }
            else{
                //reset contact account
                List<Contact> lstContacts = info.Contacts;
                for(Contact c: lstContacts)
                {
                    c.AccountId = null;
                } 
                info.Contacts = lstContacts;
                info = SetContacts(info);
                
                //reset Opportunity Account
                List<Opportunity> lstOpp = info.Opportunities;
                for(Opportunity o: lstOpp)
                {
                    o.AccountId = null;
                } 
                info.Opportunities = lstOpp;
                
                throw ex;
            }
        }
        
       
         
        return info;
    }
    
    //retrieves Call object by id
    public static Inbound_Call__c getCallByCallID(String callID)
    {
        Inbound_Call__c callObj = null;
        List<Inbound_Call__c> lstCalls = [Select i.Start_Date_Time__c, i.CreatedBy.Name, i.CreatedById, i.Related_To__c, i.Id, i.Enquiry__c, i.End_Date_Time__c, i.Call_Duration__c, i.CHI_Lead__c, i.Billing_Zip__c, i.Billing_Street__c, i.Billing_State__c, i.Billing_City__c, i.Billilng_Country__c, i.Assigned_To__c, i.Workflow_Type__c, i.Workflow_Step__c From Inbound_Call__c i where i.ID =:callID];
        if(lstCalls != null && lstCalls.size() > 0)
        {
            callObj = lstCalls[0]; 
        }
        return callObj;
    }
    
    //retrieves Call object by id
    public static List<Inbound_Call__c> getAllCallsByOpportunityID(String oppID)
    {        
      // Fix cognizant support - display call start & end datetime using current users local timezone. -- Starts
        List<Inbound_Call__c> lstCalls = [Select i.Start_Date_Time_Formatted__c, i.End_Date_Time_Formatted__c, i.Start_Date_Time__c, i.CreatedBy.Name, i.CreatedById, i.Related_To__c, i.Id, i.Enquiry__c, i.End_Date_Time__c, i.Call_Duration__c, i.CHI_Lead__c, i.Billing_Zip__c, i.Billing_Street__c, i.Billing_State__c, i.Billing_City__c, i.Billilng_Country__c, i.Assigned_To__c, i.Workflow_Type__c, i.Workflow_Step__c From Inbound_Call__c i where i.CHI_Lead__c =:oppID];
        for(Inbound_Call__c lstCall:lstCalls){
          lstCall.Start_Date_Time_Formatted__c = '';
          lstCall.End_Date_Time_Formatted__c = '';
          if(lstCall.Start_Date_Time__c != null)
          lstCall.Start_Date_Time_Formatted__c = lstCall.Start_Date_Time__c.format('dd MMM yyyy HH:mm');
          if(lstCall.End_Date_Time__c != null)
          lstCall.End_Date_Time_Formatted__c = lstCall.End_Date_Time__c.format('dd MMM yyyy HH:mm');
        }
        return lstCalls;
       // Fix cognizant support - display call start & end datetime using current users local timezone. -- Ends
    }
    
    //Sets error
    public static Workflow.WorkflowInfo SetError(Workflow.WorkflowInfo info, String errMessage)
    {
        info.IsError = true;
        if(info.Messages  == null) info.Messages = new List<String>();
        info.Messages.add(errMessage); 
        return info;
    }
    
    public static Workflow.WorkflowInfo SetContacts(Workflow.WorkflowInfo info)
    {
        //Set ContactInfo list
        
        List<Contact> lstContacts = info.Contacts;
        //set new contacts
        System.debug('------- setting contactinfos start');
        List<ContactInfo> lstContactInfo = new List<ContactInfo>();
        if(lstContacts != null)
        {
            System.debug('------- setting contactinfos');
            ContactInfo objContactInfo;
            for(Contact c :lstContacts)
            {
                objContactInfo = new ContactInfo();
                objContactInfo.contact = c;
                objContactInfo.ConSlct = false;
                lstContactInfo.Add(objContactInfo);
            }
            System.debug('------- lstContactInfo' + lstContactInfo);
        }
        //set selected contacts from existing contacts
        List<ContactInfo> lstContactInfos = info.ContactInfos;
        System.debug('------- info.ContactInfos' + info.ContactInfos);
        if(lstContactInfos != null)
        {
            ContactInfo objContactInfo;
            for(ContactInfo c :lstContactInfos)
            {
                if(c.ConSlct != null && c.ConSlct == true)
                {
                    c.ConSlct = false;
                    lstContactInfo.Add(c);
                }
            }
        }
        
        info.ContactInfos = lstContactInfo;
        System.debug('------- info.ContactInfos' + lstContactInfo);
        
        //reset new contacts list
        info.NewContactInfos = new List<ContactInfo>();
        
        Contact newContact1 = new Contact();
        Contact newContact2 = new Contact();
        ContactInfo newcontactInfo1 = new ContactInfo(); 
        ContactInfo newcontactInfo2 = new ContactInfo();
        newContact1.Description = 'newContact1';
        newContact2.Description = 'newContact2';
        
        newcontactInfo1.contact = newContact1;
        newcontactInfo2.contact = newContact2;
        if(info.prospect!= null)
                {
                    newcontactInfo1.contact.Salutation = info.prospect.salutation;
                    newcontactInfo1.contact.FirstName = info.prospect.FirstName;
                    newcontactInfo1.contact.HomePhone = info.prospect.Phone;
                    newcontactInfo1.contact.LastName = info.prospect.LastName;
                }    
        newcontactInfo1.ConSlct = false;
        newcontactInfo2.ConSlct = false;
        
        info.NewContactInfos.Add(newcontactInfo1);
        info.NewContactInfos.Add(newcontactInfo2); 
        
        return info;
    }
    
    
     public static Workflow.WorkflowInfo RemoveNonCallOpportunities(Workflow.WorkflowInfo info)
    {
        Inbound_Call__c call = info.Call;
        List<Opportunity> lstOpps = info.Opportunities;
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ lstOpps '+lstOpps);
        if(lstOpps != null && lstOpps.size() > 1)
        {
            Opportunity callOpportunity;
            for(Opportunity opp:lstOpps)
            {
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ opp.id '+opp.id);
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ call.CHI_Lead__c'+call.CHI_Lead__c);
                if(opp.id == call.CHI_Lead__c)
                {
                    callOpportunity = opp;
                    break;
                }
            }
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ callOpportunity '+callOpportunity);
            if(callOpportunity != null)
            {
                info.Opportunities = new List<Opportunity> {callOpportunity};
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ info.Opportunities '+info.Opportunities);
                OppSelectClass newOppSelect = new OppSelectClass();
                newOppSelect.setOppSelected(false);
                newOppSelect.setOpp(callOpportunity);
                info.SelectedOpportunities = new List<OppSelectClass>{ newOppSelect };
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ info.SelectedOpportunities  '+info.SelectedOpportunities );
            }
        }
        return info;
    } 
    
    public static Workflow.WorkflowInfo closeAppointmentsOfClosedLead(Workflow.WorkflowInfo info){
        List<Appointment__c> appList = new List<Appointment__c>();
        List<Appointment__c> appListUpdate = new List<Appointment__c>();
        List<Opportunity> opportunityList = info.NonClosedOpportunityList;
        if(info.NonClosedOpportunityList!=null || info.NonClosedOpportunityList.size()!=0){
            appList=[Select a.Name, a.Status__c, a.Visit_Date__c, a.Time_Band__c, a.Start_Time__c, a.End_Time__c, a.BM_Salesperson__c, a.Assigned_To__r.Primary_Role__c, a.Assigned_To__c,a.TA_Notes_All__c,a.Status_Reason__c From Appointment__c a where a.Opportunity__c in : opportunityList]; 
        }
        for(Appointment__c a : appList){
            a.Status__c = 'Cancelled';
           // Ashok Cr : 12  
           // a.Status_Reason__c = 'TA - Customer Request';
            a.Primary_Cancellation_Reason__c = 'Cancelled - Automatic Rearange';
            a.Secondary_Cancellation_Reason__c ='Cancelled - Automatic Rearange';
           // Ashok End 
            appListUpdate.add(a);
        }
        
        if(appListUpdate != null && appListUpdate.size()!=0){
            try{
                update appListUpdate;
            }catch(Exception e){
                System.debug('## Exception Appointment update:'+e);
            }
        }       
        //info.Appointments = appListUpdate;
        return info;
    }
    
    public static void markOldProductHoldingRecords(String accountId, String productHoldingRecId)
    {
        //update all existing current product holding records to set them as "Old"
        List<ProductHolding__c> lstProductHoldings = new List<ProductHolding__c>();
         
        for(ProductHolding__c productHoldingRec : [Select p.id, p.Status__c From ProductHolding__c p 
            where p.Account__c = :accountId and Status__c != 'Old' 
            and id <> :productHoldingRecId])
        {
            productHoldingRec.Status__c = 'Old'; //set status as OLD
            lstProductHoldings.add(productHoldingRec);
        }
        update lstProductHoldings;
    }
    
    public static boolean CCValidation(String CCNumber){
        Integer sum = 0;
        Integer len = CCNumber.length();
        for(Integer i=len-1;i>=0;i--){
        Integer num = Integer.ValueOf(CCNumber.substring(i,i+1));
        if ( math.mod(i , 2) == math.mod(len, 2) )
        {
        Integer n = num * 2;
        sum += (n / 10) + ( math.mod(n, 10));
        }
        else{
        sum += num;
        }
        }
        return ( math.mod( sum, 10) == 0 );
    }
    
}