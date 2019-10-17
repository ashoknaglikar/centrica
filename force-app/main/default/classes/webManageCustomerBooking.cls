//webManageCustomerBooking Datamig code

public class webManageCustomerBooking {

    public list<Attachment> attachmentList  = new list<Attachment>();
    
    public webservice_CHI_Online.ManageCustomerBookingResponse webManageCustomerBookingFunc(webservice_CHI_Online.ManageCustomerBooking objManageCustomerBooking)
    {
        
        
        Savepoint sp = Database.setSavepoint();
        webservice_CHI_Online.ManageCustomerBookingResponse reply = new webservice_CHI_Online.ManageCustomerBookingResponse();
        string postcode;
        string NameNumber;
        LeadCreateHelper helper = new LeadCreateHelper();
        
        if(objManageCustomerBooking.CreateCustomerData.Address.PostCode!=null && objManageCustomerBooking.CreateCustomerData.Address.PostCode != '')
        {
            postcode = objManageCustomerBooking.CreateCustomerData.Address.PostCode;
        }else
        {
            reply.Error.Code = 1;
            reply.Error.Message = ' Create account failed. Postcode is Blank.' ;
            system.debug(reply.Error.Message);
            return reply;
        }
        
        if(objManageCustomerBooking.CreateCustomerData.Address.NameNumber!=null && objManageCustomerBooking.CreateCustomerData.Address.NameNumber != '')
        {
            NameNumber = objManageCustomerBooking.CreateCustomerData.Address.NameNumber;
        }else
        {
            reply.Error.Code = 1;
            reply.Error.Message = ' Create account failed. NameNumber in Address is null.' ;
            system.debug(reply.Error.Message);
            return reply;
        }
        List<Employee__c> engineerList = new list<Employee__c>();
        system.debug('EmployeePayrollNumber-->'+objManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber);
        if(objManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber != null && objManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber != '')
        {
            engineerList = [Select Id from Employee__c where Employee_Number__c = :objManageCustomerBooking.CreateCustomerData.EmployeePayrollNumber];
            if(engineerList.size()<=0)
            {
                reply.Error.Code = 10;
                reply.Error.Message = 'Referral Employee Payroll id is Invalid' ;
                system.debug(reply.Error.Message);
                return reply;
            }
            
        }
        
        Web_Enquiry__c enquiry = new Web_Enquiry__c();
        Contact new_contact = new Contact();
        Account chi_account = new Account();
        Opportunity chi_lead = new Opportunity();
        
        boolean existAccount = false, existLead = false;
       
        
        // format postcode correctly
        string trimmed_code;
        string first_part;
        string second_part;
        string reformatted_code;
        string post_code_sector;
        
        trimmed_code    = objManageCustomerBooking.CreateCustomerData.Address.Postcode.replace(' ', '');
        system.debug('trimmed_code = ' + trimmed_code);
        
        second_part     = trimmed_code.substring(trimmed_code.length()-3, trimmed_code.length());
        system.debug('second_part = ' + second_part);
        
        first_part      = trimmed_code.substring(0, trimmed_code.length()-second_part.length());
        system.debug('first_part = ' + first_part);
        
        reformatted_code = first_part + ' ' + second_part;
        system.debug('reformatted_code = ' + reformatted_code);
     
        
        try {
            
            
            string billingStreet = objManageCustomerBooking.CreateCustomerData.Address.NameNumber + ' ' +objManageCustomerBooking.CreateCustomerData.Address.Street;
            
            string test_acc_name = reformatted_code.trim() + ' ' + (billingStreet.length()>29 ? billingStreet.substring(0,29): billingStreet);
            system.debug('Searching for Account with Account_Id__c of: ' + test_acc_name);
            
            List<Account> existing_accs = [SELECT  Id,BillingStreet,BillingCity,BillingPostalCode,BillingState  FROM Account WHERE Account_Id__c = :test_acc_name ]; // use this field as it is indexed
            
            if(existing_accs.size()>0)
            {   
                system.debug('I am inside existing Lead');
                existAccount =true;
                chi_account = existing_accs[0];
                List<Opportunity> existing_leads = [SELECT Id, CloseDate, StageName, CHI_Lead_Id1__c,Product_Interest__c, AccountId ,LeadSource, (select id from Bigmachines_Quotes__r),(Select id, Status__c,Visit_Date__c from Appointments__r where Status__c = 'Appointed')
                                            FROM Opportunity
                                            WHERE AccountId = :existing_accs[0].id
                                            AND CloseDate >= :Date.Today() order by StageName limit 1];
       
                
                
                if (existing_leads.size() > 0 ) { 
                     
                    for(Opportunity o : existing_leads)
                    {
                        system.debug('--Oppo--'+o);
                        
                        if( o.Bigmachines_Quotes__r.size()>0)
                        {
                            reply.Error.Code = 8;
                            reply.Error.Message = 'ERROR: Account still has active lead, new lead not allowed';
                            system.debug(reply.Error.Message);
                            return reply;
                        }
                        
                        if(o.StageName =='Appointed' || o.StageName =='Active')
                        {
                            for(Appointment__c a: o.Appointments__r)
                            {
                                system.debug('--Appointent--'+a);
                                if(a.Visit_Date__c>=system.today())
                                {
                                    reply.Error.Code = 8;
                                    reply.Error.Message = 'ERROR: Account still has active lead, new lead not allowed';
                                    system.debug(reply.Error.Message);
                                    return reply;
                                }
                            }
                            if((objManageCustomerBooking.CreateCustomerData.ProductInterest == null && o.Product_Interest__c != system.label.CHB) || (objManageCustomerBooking.CreateCustomerData.ProductInterest != null &&  o.Product_Interest__c != objManageCustomerBooking.CreateCustomerData.ProductInterest)|| (objManageCustomerBooking.CreateCustomerData.extraInfo!=null && objManageCustomerBooking.CreateCustomerData.extraInfo.ProductInterest!= null && objManageCustomerBooking.CreateCustomerData.extraInfo.ProductInterest != o.Product_Interest__c))
                            {
                                o.Product_Interest__c = 'Central Heating Boiler';
                                if(objManageCustomerBooking.CreateCustomerData.ProductInterest != null )
                                o.Product_Interest__c = objManageCustomerBooking.CreateCustomerData.ProductInterest;
                                if(objManageCustomerBooking.CreateCustomerData.extraInfo!= null && objManageCustomerBooking.CreateCustomerData.extraInfo.ProductInterest!= null)
                                o.Product_Interest__c = objManageCustomerBooking.CreateCustomerData.extraInfo.ProductInterest;
                                
                                helper = createUpdateLead(objManageCustomerBooking.CreateCustomerData, chi_account.Id,existAccount, engineerList, true, o);
                            } 
                            chi_lead = o;
                            reply.ChiLeadId = o.Id;
                            reply.ChiLeadCustRef = o.CHI_Lead_Id1__c;
                            existLead = true;

                        }
                        
                    }
                    
                    
                    if(reply.ChiLeadId==null )
                    {
                        helper = createUpdateLead(objManageCustomerBooking.CreateCustomerData, chi_account.Id,existAccount, engineerList, false, null);
                        
                        if(helper.Code!=0)
                        {
                            reply.Error.Code = helper.Code;
                            reply.Error.Message = helper.Message;
                            system.debug(reply.Error.Message);
                            Database.rollback( sp );
                            return reply;
                        }else
                        {
                            chi_lead = helper.Opp;
                            reply.ChiLeadId = chi_lead.Id;
                            reply.ChiLeadCustRef = chi_lead.CHI_Lead_Id1__c;
                        }
                    }
                    
                    
                }else
                {
                   
                    helper = createUpdateLead(objManageCustomerBooking.CreateCustomerData, chi_account.Id,existAccount, engineerList, false, null);
                    
                    if(helper.Code!=0)
                    {
                        reply.Error.Code = helper.Code;
                        reply.Error.Message = helper.Message;
                        system.debug(reply.Error.Message);
                        Database.rollback( sp );
                        return reply;
                    }else
                    {
                        chi_lead = helper.Opp;
                        reply.ChiLeadId = chi_lead.Id;
                        reply.ChiLeadCustRef = chi_lead.CHI_Lead_Id1__c;
                    }
                } 
                
                
                
               
            }else
            {
                
                chi_account.Primary_Contact__c          = new_contact.Id;
                chi_account.BillingPostalCode           = objManageCustomerBooking.CreateCustomerData.Address.PostCode;
                chi_account.BillingStreet               = objManageCustomerBooking.CreateCustomerData.Address.NameNumber+' '+objManageCustomerBooking.CreateCustomerData.Address.Street;
                chi_account.BillingCity                 = objManageCustomerBooking.CreateCustomerData.Address.TownCity;
                chi_account.BillingState                = objManageCustomerBooking.CreateCustomerData.Address.CountyProvince;
                chi_account.Name                        = 'unused name';
                
                if(engineerList.size()>0 && objManageCustomerBooking.CreateCustomerData.extraInfo!=null)
                {
                    chi_account.Gas_Supply_At_Address1__c = objManageCustomerBooking.CreateCustomerData.extraInfo.gasAtProperty;
                    chi_account.Asbestos_found__c = objManageCustomerBooking.CreateCustomerData.extraInfo.asbestosIdentified;
                    if(chi_account.Asbestos_found__c  == 'Yes' || chi_account.Asbestos_found__c  == 'Suspected' )
                    chi_account.Asbestos_Found_Date_New__c = system.today();
                    chi_account.Number_of_Bedrooms__c = objManageCustomerBooking.CreateCustomerData.extraInfo.bedrooms;
                    
                }
                try{
                //CODE ADDED - Keerthi  -----------------------------------------------------
                //DATE:- June 8, 2018
                //DESCRIPTION:- To populate the latitude and longitude values on the account page for leads created online
               
                string street = chi_account.BillingStreet!=null?chi_account.BillingStreet.normalizeSpace().replaceall(' ','+').trim():'';
                string city = chi_account.BillingCity!=null ? chi_account.BillingCity.normalizeSpace().replaceall(' ','+').trim():'';
                string pcode = chi_account.BillingPostalCode!=null?chi_account.BillingPostalCode.normalizeSpace().replaceall(' ','+').trim():'';
                string Address = street + '+'+city+ '+' +pcode;
                System.debug('address string send to utility-->'+Address);
                try{
                    list<string> Latlang = Utilities.getLatLang(Address,pcode);
                    if(Latlang.size()==2)
                    {
                        chi_account.Latitude__Latitude__s = double.valueof(Latlang[0]);
                        chi_account.Latitude__Longitude__s = double.valueof(Latlang[1]);
                       
                        
                    }   
                }catch (Exception e)
                {
                    
                }
                System.debug('Latitude--> '+chi_account.Latitude__Latitude__s);
                System.debug('Longitude-->'+chi_account.Latitude__Longitude__s);
                    
                //Keerthi - Code ends
                insert chi_account;
                    
                }catch (exception e)
                {
                    reply.Error.Code = 1;
                    reply.Error.Message = 'ERROR: Create account failed with name.';
                    system.debug(reply.Error.Message);
                    Database.rollback( sp );
                    return reply;
                }
                
                 // CHI Lead creaion.
                
                helper = createUpdateLead(objManageCustomerBooking.CreateCustomerData, chi_account.Id, false, engineerList, false, null);
                
                if(helper.Code!=0)
                {
                    reply.Error.Code = helper.Code;
                    reply.Error.Message = helper.Message;
                    system.debug(reply.Error.Message);
                    Database.rollback( sp );
                    return reply;
                }else
                {
                    chi_lead = helper.Opp;
                    reply.ChiLeadId = chi_lead.Id;
                    reply.ChiLeadCustRef = chi_lead.CHI_Lead_Id1__c;
                    /*
                    if(chi_lead.LeadSource == 'Engineer')
                    {
                        string engineerjson = JSON.serialize(objManageCustomerBooking);
                        blob JSONBody = blob.valueof(engineerjson);
                        Attachment att = new Attachment(Name = chi_lead.CHI_Lead_Id1__c+' JSON.text', Body = JSONBody, ParentId = chi_Lead.Id);
                        insert att; 
                    }*/
                }   
                
                
            }
            string engineerjson = JSON.serialize(objManageCustomerBooking);
            blob JSONBody = blob.valueof(engineerjson);
            Attachment att = new Attachment(Name = chi_lead.CHI_Lead_Id1__c+' JSON.text', Body = JSONBody, ParentId = chi_Lead.Id);
            attachmentList.add(att);
            
            if(attachmentList.size()>0)
            insert attachmentList;
            
            new_contact.Salutation          = objManageCustomerBooking.CreateCustomerData.Name_x.Salutation;
            new_contact.FirstName           = objManageCustomerBooking.CreateCustomerData.Name_x.FirstName;
            new_contact.LastName            = objManageCustomerBooking.CreateCustomerData.Name_x.LastName;
            string mobile;
            string homephone;

            
            if(objManageCustomerBooking.CreateCustomerData.Contact_x.MobilePhone!=null && objManageCustomerBooking.CreateCustomerData.Contact_x.MobilePhone.startsWith('07'))
            mobile = objManageCustomerBooking.CreateCustomerData.Contact_x.MobilePhone;
            else
            homephone = objManageCustomerBooking.CreateCustomerData.Contact_x.MobilePhone;
             system.debug('mobile'+mobile);
             system.debug('HomePhone'+homephone );
            
            if(objManageCustomerBooking.CreateCustomerData.Contact_x.HomePhone!=null && objManageCustomerBooking.CreateCustomerData.Contact_x.HomePhone.startsWith('07'))
            mobile =objManageCustomerBooking.CreateCustomerData.Contact_x.HomePhone;
            else if(homephone == null)
            homephone = objManageCustomerBooking.CreateCustomerData.Contact_x.HomePhone;
            
              system.debug('mobile'+mobile);
              system.debug('HomePhone'+homephone );
            
            new_contact.MobilePhone         = mobile;
            new_contact.HomePhone           = homephone;
            new_contact.OtherPhone          = objManageCustomerBooking.CreateCustomerData.Contact_x.WorkPhone;
            new_contact.Phone               = objManageCustomerBooking.CreateCustomerData.Contact_x.AltPhone;
            new_contact.Email__c            = objManageCustomerBooking.CreateCustomerData.Contact_x.Email;
            new_contact.Contact_Type__c     = objManageCustomerBooking.CreateCustomerData.ResStatus;
            new_contact.MailingCity         = objManageCustomerBooking.CreateCustomerData.Address.TownCity;
            new_contact.MailingPostalCode   = reformatted_code;
            new_contact.MailingState        = objManageCustomerBooking.CreateCustomerData.Address.CountyProvince;
            
            new_contact.MailingStreet       = objManageCustomerBooking.CreateCustomerData.Address.NameNumber + ' ' + objManageCustomerBooking.CreateCustomerData.Address.Street;
            new_contact.IsActive__c         = True;
            
            new_contact.Primary_Contact__c  = True;
            
            new_contact.AccountId           = chi_account.Id;
            
            enquiry.Name                    = new_contact.LastName + ' ' + chi_account.BillingPostalCode + ' ' + datetime.now();
            enquiry.Boiler_Age__c           = objManageCustomerBooking.CreateCustomerData.BoilerAge ;
            enquiry.Boiler_Operational__c   = objManageCustomerBooking.CreateCustomerData.BoilerOp == 'Yes'?true:false;
            enquiry.County_Province__c      = new_contact.MailingState;
            enquiry.Fuel_Type__c            = objManageCustomerBooking.CreateCustomerData.FuelType;
            enquiry.Email__c                = new_contact.Email__c;
            enquiry.First_Name__c           = new_contact.FirstName;
            enquiry.Home_Phone__c           = new_contact.HomePhone;
            enquiry.Work_Phone__c           = new_contact.OtherPhone;
            enquiry.Mobile_Phone__c         = new_contact.MobilePhone;
            enquiry.Alt_Phone__c            = new_contact.Phone;
            enquiry.Last_Name__c            = new_contact.LastName;
            enquiry.Postcode__c             = chi_account.BillingPostalCode;
            enquiry.Residential_Status__c   = objManageCustomerBooking.CreateCustomerData.ResStatus;
            enquiry.Salutation__c           = new_contact.Salutation;
            enquiry.CHI_Lead__c             = chi_lead.id;
            string temp_str = '';
            temp_str = objManageCustomerBooking.CreateCustomerData.Address.NameNumber + ' ' + objManageCustomerBooking.CreateCustomerData.Address.Street;
            system.debug('chi_account.BillingStreet-- >'+chi_account.BillingStreet + '  '+temp_str);
            system.debug('chi_account.BillingStreet.length() = ' + temp_str.length());
            
            if (temp_str.length() > 45) {
            
                system.debug('Trimming chi_account.BillingStreet....');
                enquiry.Street__c = temp_str.substring(0, 45);
                system.debug('enquiry.Street__c ' + enquiry.Street__c); 
            }
            else {
            
                enquiry.Street__c = temp_str;   
            }
        
            temp_str = '';
            temp_str = objManageCustomerBooking.CreateCustomerData.Address.TownCity;
            
            //system.debug('chi_account.BillingCity.length() = ' + temp_str.length());
            
            if (temp_str.length() > 30) {
            
                system.debug('Trimming chi_account.BillingCity....');
                enquiry.Town_City__c = temp_str.substring(0, 30);
                system.debug('enquiry.Town_City__c ' + enquiry.Town_City__c);   
            }
            else {
            
                enquiry.Town_City__c = temp_str;    
            }
        
            
            try{
                system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%'+new_contact);
                insert new_contact;
                insert enquiry;
                
                
                // CHG00009065: fix to create relationship record to relate Contat and CHI Lead
                // as is done in the call centre booking system
                // So, now add opportunity contact role....
                OpportunityContactRole opp_contact_role = new OpportunityContactRole();
                    
                opp_contact_role.ContactId      = new_contact.Id;
                opp_contact_role.OpportunityId  = chi_lead.Id;
                opp_contact_role.Role           = 'Decision Maker';
                
                try {
                    
                    insert opp_contact_role;
                    
                    system.debug('opp_contact_role id =' + opp_contact_role.id);
                }             
                catch (exception e) {
                    // OCP insert failed, set warning (no error code)
                    reply.Error.Code = 0;
                    reply.Error.Message = 'WARNING: Opportunity contact role insert failed';
                    system.debug(reply.Error.Message);
                    Database.rollback( sp );
                    createEmail(JSON.serialize(objManageCustomerBooking));   
                }   
                
                //update Account with CHI Lead
                
                chi_account.Primary_Contact__c = new_contact.Id;
                
                update chi_account;
                
            }catch (exception e)
            {
                reply.Error.Code = 2;
                reply.Error.Message = 'ERROR: Create contact failed with name.';
                system.debug(reply.Error.Message);
                Database.rollback( sp );
                    
                if (null != chi_account.Id && !existAccount) // only need to delete account as this triggers a delete of everything else
                    delete chi_account;
                else if(!existLead)
                    delete chi_lead;
               
                return reply; 

                createEmail(JSON.serialize(objManageCustomerBooking));    
            }
                
            
            if(reply.ChiLeadId!=null && objManageCustomerBooking.CreateAppointmentData.Appointment.Appid!=null)
            {
                try{
                    boolean bringFrwVisit = objManageCustomerBooking.CreateAppointmentData.BringForwardVisit!=null ?objManageCustomerBooking.CreateAppointmentData.BringForwardVisit : false;
                    Appointment__c bookedAppointment = bookedAppointment(objManageCustomerBooking.CreateAppointmentData, reply.ChiLeadId,bringFrwVisit );
                    if(bookedAppointment.id!=null)
                    {
                        reply.Appointment.AppId = bookedAppointment.Id;
                        reply.Appointment.AppStart = bookedAppointment.Start__c;
                        reply.Appointment.AppEnd = bookedAppointment.End__c;
                        reply.ProductInterest = 'HSA';
                        if(chi_lead.Product_Interest__c == 'Guided Sale' || chi_lead.Product_Interest__c== 'Straight Swap' || chi_lead.Product_Interest__c== 'TeleSales Conv')
                        reply.ProductInterest = chi_lead.Product_Interest__c;
                    }else
                    {
                        reply.Error.Code = 7;
                        reply.Error.Message = 'ERROR:  Appointmet is not available anymore';
                        Database.rollback( sp );
                        return reply;
                    }
                }catch (Exception e)
                {
                    reply.Error.Code = 4;
                    reply.Error.Message = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c;
                    Database.rollback( sp );
                    CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','),e.getmessage()+' Occured in webManageCustomerBooking while reserving appointment at line NO: '+e.getLineNumber()+' '+JSON.serialize(objManageCustomerBooking), 'Exception in Online Booking webManageCustomerBooking class'+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c);
                    return reply;
                }
                
                
               /*  
                string available_rt_id = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
                string Appt_ID = objManageCustomerBooking.CreateAppointmentData.Appointment.Appid;
                Schema.DescribeSObjectResult r = Appointment__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                if(!Appt_ID.startswith(keyPrefix)){
                    post_code_sector = objManageCustomerBooking.CreateCustomerData.Address.PostCode.substring(0,objManageCustomerBooking.CreateCustomerData.Address.PostCode.length()-2);
                    //system.debug('Postcode sector = ' + post_code_sector); 
                    
                    system.debug('Appointemtn Info-->'+objManageCustomerBooking.CreateAppointmentData.Appointment);
                    
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
                    system.debug(year);
                    system.debug(month);
                    system.debug(day);
                    system.debug(GetTimeslot);
                   
                    map<string , SalesAppointment__c> customSettingMap = new map <string, SalesAppointment__c>();
                    for(SalesAppointment__c c : SalesAppointment__c.getAll().values())
                    {
                        customSettingMap.put(c.Online_Code__c, c);
                    }
                    
                    SalesAppointment__c s = customSettingMap.get(GetTimeslot);
                    
                    datetime slotStartTime = datetime.newInstance(year, month, day, integer.valueof(s.Start_Time__c.split(':')[0]), integer.valueof(s.Start_Time__c.split(':')[1]), 0);
                    datetime slotEndTime = datetime.newInstance(year, month, day, integer.valueof(s.End_Time__c.split(':')[0]), integer.valueof(s.End_Time__c.split(':')[1]), 0);
                    datetime SLAStartTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_Start__c.split(':')[0]), integer.valueof(s.SLA_Start__c.split(':')[1]), 0);
                    datetime SLAEndTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_End__c.split(':')[0]), integer.valueof(s.SLA_End__c.split(':')[1]), 0);
                    
                    dateTime End_Date = objManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd;
               
                
                   
                
                   //string GetTimeslot= string.valueof(Appt_ID).substring(string.valueof(Appt_ID).length()-5,string.valueof(Appt_ID).length()-3);
                   TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(prodInterest);
                   Appointment__c newAppt = new Appointment__c();
                   newAppt.Assigned_To__c = ofsBuckname;
                   newAppt.Opportunity__c = chi_lead.Id;
                   newAppt.Who__c = new_contact.Id;
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
                   
                   newAppt.Time_Band__c = s.Name;
                   newAppt.OFS_Appointment__c = true;
                   newAppt.Bring_forward_visit__c = objManageCustomerBooking.CreateAppointmentData.BringForwardVisit!=null ?objManageCustomerBooking.CreateAppointmentData.BringForwardVisit : false;
                   system.debug('*************^^^^'+newAppt);
                   try{
                        
                        insert newAppt;
                       
                        reply.Appointment.AppId = newAppt.id;
                        reply.Appointment.AppStart = newAppt.start__c;
                        reply.Appointment.AppEnd = newAppt.End__c;
                        
                        
                    }catch (Exception e)
                    {
                        
                        reply.Error.Code = 4;
                        reply.Error.Message = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c;
                        Database.rollback( sp );
                        CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','),e.getmessage()+' Occured in webManageCustomerBooking while reserving appointment at line NO: '+e.getLineNumber()+' '+JSON.serialize(objManageCustomerBooking), 'Exception in Online Booking webManageCustomerBooking class'+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c);
                        return reply;
                        
                    } 
                    
                }//Ashok Change End
                else{
                    
                 Appointment__c appRec = [Select id, Status__c, Start__c, End__c,  Online_Reservation_Id__c from Appointment__c where Id = :objManageCustomerBooking.CreateAppointmentData.Appointment.Appid];
                 
                 //Remote Quote Changes  
                 if(Remote_Quote_Product__c.getInstance(chi_lead.Product_Interest__c) != null)
                 {
                     //system.debug('I am here -->'+reformatted_code.substring(0,reformatted_code.length()-2));
                     appRec = ChooseBestAppointment(reformatted_code.substring(0,reformatted_code.length()-2),appRec,chi_lead,objManageCustomerBooking);
                 }
                    
                 if((appRec.Status__c == 'Reserved' || appRec.Status__c == 'New')  && (appRec.Online_Reservation_Id__c == null || appRec.Online_Reservation_Id__c==objManageCustomerBooking.CreateAppointmentData.ReservationId))
                 { 
                        //appRec.Status__c = 'Appointed';
                        appRec.Opportunity__c= chi_lead.Id;
                        appRec.Who__c = new_contact.Id;
                        //appRec.Show_Time_As__c = 'Busy';
                        appRec.Visit_Type__c = 'First Visit';
                        appRec.Bring_forward_visit__c = objManageCustomerBooking.CreateAppointmentData.BringForwardVisit!=null ?objManageCustomerBooking.CreateAppointmentData.BringForwardVisit : false;
                        try{
                            
                            update appRec;
                            reply.Appointment.AppId = appRec.Id;
                            reply.Appointment.AppStart = appRec.Start__c;
                            reply.Appointment.AppEnd = appRec.End__c;
                            reply.ProductInterest = 'HSA';
                            if(chi_lead.Product_Interest__c == 'Guided Sale' || chi_lead.Product_Interest__c== 'Stright Swap' || chi_lead.Product_Interest__c== 'TeleSales Conv')
                            reply.ProductInterest = chi_lead.Product_Interest__c;
                            
                        }catch (Exception e)
                        {
                            reply.Error.Code = 4;
                            reply.Error.Message = 'ERROR: Appointmnet booking failed. '+e.getmessage()+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c;
                            CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','),e.getmessage()+' Occured in webManageCustomerBooking while reserving appointment at line NO: '+e.getLineNumber()+' '+JSON.serialize(objManageCustomerBooking), 'Exception in Online Booking webManageCustomerBooking class'+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c);
                            Database.rollback( sp );
                            return reply;
                        }
                    }else
                    {
                        
                        Appointment__c newReplacement = reSearchAppointment(appRec.Start__c , appRec.End__c, reformatted_code, objManageCustomerBooking.CreateCustomerData.BoilerOp, chi_lead.Product_Interest__c);
                        //Remote Quote Changes  
                        if(Remote_Quote_Product__c.getInstance(chi_lead.Product_Interest__c) != null)
                        {
                           system.debug('I am here -->'+reformatted_code.substring(0,reformatted_code.length()-2));
                           newReplacement = ChooseBestAppointment(reformatted_code.substring(0,reformatted_code.length()-2),appRec,chi_lead,objManageCustomerBooking);
                        }
                        
                        if(newReplacement.Id == null)
                        {
                            reply.Error.Code = 7;
                            reply.Error.Message = 'ERROR:  Appointmet is not available anymore';
                            Database.rollback( sp );
                            return reply;
                            
                        }else
                        {
                            //newReplacement.Status__c = 'Appointed';
                            newReplacement.Opportunity__c= chi_lead.Id;
                            newReplacement.Who__c = new_contact.Id;
                            //newReplacement.Show_Time_As__c = 'Busy';
                            newReplacement.Bring_forward_visit__c = objManageCustomerBooking.CreateAppointmentData.BringForwardVisit!=null ?objManageCustomerBooking.CreateAppointmentData.BringForwardVisit : false;
                            
                            try{
                                
                                update newReplacement;
                                reply.Appointment.AppId = newReplacement.Id;
                                reply.Appointment.AppStart = newReplacement.Start__c;
                                reply.Appointment.AppEnd = newReplacement.End__c;
                                reply.ProductInterest = 'HSA';
                                if(chi_lead.Product_Interest__c == 'Guided Sale' || chi_lead.Product_Interest__c== 'Straight Swap' || chi_lead.Product_Interest__c== 'TeleSales Conv')
                                reply.ProductInterest = chi_lead.Product_Interest__c;
                            
                                
                                
                            }catch (Exception e)
                            {
                                
                                reply.Error.Code = 4;
                                reply.Error.Message = 'ERROR: Appointmnet booking failed. '+e.getmessage();
                                Database.rollback( sp );
                                CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','),e.getmessage()+' Occured in webManageCustomerBooking while reserving appointment at line NO: '+e.getLineNumber()+' '+JSON.serialize(objManageCustomerBooking), 'Exception in Online Booking webManageCustomerBooking class'+' For CHI Lead : '+chi_lead.Id +' Number :'+chi_lead.CHI_Lead_Id1__c);
                                return reply;
                                
                            }
                            
                        }
                    }
                  } */
                  
                } 
                /*else
                {
                    reply.Error.Code = 9;
                    reply.Error.Message = 'ERROR: Something went wrong. CHI Lead Id is NUll';
                    Database.rollback( sp );
                    return reply;
                    
                } */
            
        }catch(Exception e)
        {
            reply.Error.Code = 9;
            reply.Error.Message = 'ERROR: Something went wrong. '+e.getmessage();
            CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','),e.getmessage()+' Occured in webManageCustomerBooking while reserving appointment at line NO: '+e.getLineNumber()+' '+JSON.serialize(objManageCustomerBooking), 'Exception in Online Booking webManageCustomerBooking class');
            Database.rollback( sp );
            
            return reply; 
        }
                                           
        return reply;
    }
    
    
    public Appointment__c reSearchAppointment(Datetime start , Datetime EndTime, String postCode , string boilerOp, string productInterest)
    {
        
        Date startDate= start.Date().adddays(-2);
        Date endDate =  EndTime.Date().adddays(2);
        
        webservice_CHI_Online.GetAppointmentsByPostcode appointmentObj = new webservice_CHI_Online.GetAppointmentsByPostcode();
        appointmentObj.Address.Postcode = postCode;
        appointmentObj.GetAppointmentDate.BracketStart = startDate;
        appointmentObj.GetAppointmentDate.BracketEnd = endDate;
        appointmentObj.BoilerOp = boilerOp;
        appointmentObj.CHILeadChannel = productInterest !='Central Heating Boiler' ? 'Straight Swap':productInterest;
        webservice_CHI_Online.GetAppointmentsByPostcodeResponse response= new webservice_CHI_Online.GetAppointmentsByPostcodeResponse();
        
        
        
        response = webservice_CHI_Online.fGetAppointmentsByPostcode(appointmentObj);
        
        if(response.AppointmentSlots.size()>0)
        {
            //Map<String,List<Appointment__c>> PreferenceMap = new Map<String,List<Appointment__c>>{'Primary'=>new List<Appointment__c>(), 'Secondary'=>new List<Appointment__c>()};
                
            for(webservice_CHI_Online.cAppointment app :response.AppointmentSlots )
            {
                
                if(app.AppStart == start && app.AppEnd == EndTime) 
                {   
                    string APPT_ID = string.valueof(app.AppId);
                    string OFSID = APPT_ID.substring(APPT_ID.length()-3,APPT_ID.length());
                    
                    if(OFSID.equalsIgnoreCase('OFS')){
                       system.debug('-------I am Inside OFS');
                      
                      Appointment__c newApp = new Appointment__c();
                      newApp.id = app.AppID;
                      newApp.start__c = start;
                      newApp.End__c = EndTime;
                      newApp.Online_Reservation_Id__c = app.AppID;
                      
                      return newApp;
                    }
                    else{
                       Appointment__c newApp = [Select id, Status__c, Start__c, End__c,  Online_Reservation_Id__c from Appointment__c where Id = :app.AppId];
                       return newApp;
                    }
                }
            }
            
        }else 
        {
            return new Appointment__c();
        }
        return new Appointment__c();
        
    }
    
    private LeadCreateHelper createUpdateLead (webservice_CHI_Online.cCreateCustomerData CreateCustomerData, Id chi_accountId, boolean existAccount, list<Employee__c> refferralEmp, boolean updateFlag, Opportunity opp)
    {
        Opportunity chi_lead = new Opportunity();
        
        // update the existing lead
       
        
        LeadCreateHelper reply = new LeadCreateHelper();
        
        if(updateFlag)
            chi_lead = opp;
        else
        {
            string temp_str = CreateCustomerData.Address.NameNumber;
    
            if (temp_str.length() > 10) {
                
               
                chi_lead.Address_Number__c = temp_str.substring(0, 10);
                  
            }
            else {
            
                chi_lead.Address_Number__c = temp_str;  
            }
            
            chi_lead.Alternative_Number__c  = CreateCustomerData.Contact_x.AltPhone;
            chi_lead.Boiler_Age__c          = CreateCustomerData.BoilerAge;
            
            if ('No' == CreateCustomerData.BoilerOp) 
            {
                chi_lead.Boiler_Working__c              = 'No';
                chi_lead.Latest_customer_category__c    = 3;
            }
            else 
                chi_lead.Boiler_Working__c = 'Yes';
            
             
          
            
             chi_lead.Contact_Number__c = CreateCustomerData.Contact_x.AltPhone;
                
             if (null != CreateCustomerData.Contact_x.WorkPhone)
                chi_lead.Contact_Number__c =  CreateCustomerData.Contact_x.WorkPhone;
                
             if (null != CreateCustomerData.Contact_x.HomePhone)
                chi_lead.Contact_Number__c = CreateCustomerData.Contact_x.HomePhone;
                
             if (null != CreateCustomerData.Contact_x.MobilePhone) 
                chi_lead.Contact_Number__c = CreateCustomerData.Contact_x.MobilePhone;     
          
            
            chi_lead.Name                   = 'unused name';
            chi_lead.StageName              = 'Active';
            chi_lead.CloseDate              = Date.today().addmonths(3);
            system.debug('chi_lead.CloseDate = ' + chi_lead.CloseDate);
            
            chi_lead.AccountId              = chi_accountId;
            chi_lead.Urgency__c             = 'Standard';
            chi_lead.Home_improvement__c    = 'No';
            chi_lead.Visit_Type__c          = 'Sales';
            chi_lead.SC_Type__c             =  CreateCustomerData.ResStatus;
            chi_lead.Enquiry_Type__c        = 'Sales Appointment';
            chi_lead.Product_Interest__c = 'Central Heating Boiler';
            chi_lead.LeadSource             = 'CHI Online';
            
        }    
        //chi_lead.Product_Interest__c = CreateCustomerData.CHIMarketing;
        //chi_lead.ES_Product_Interest__c = CreateCustomerData.ProductInterest!=null ?CreateCustomerData.ProductInterest:false ;
        chi_lead.ES_Product_Interest__c = CreateCustomerData.ProductInterest!=null ?true:false ;
        
        chi_lead.Bill_Title__c =        CreateCustomerData.Name_x.Salutation;
        chi_lead.Bill_FirstName__c =    CreateCustomerData.Name_x.FirstName;
        chi_lead.Bill_LastName__c =     CreateCustomerData.Name_x.LastName;
        chi_lead.Bill_Street__c =       CreateCustomerData.Address.NameNumber+' '+CreateCustomerData.Address.Street;
        chi_lead.Bill_Post_Code__c =    CreateCustomerData.Address.PostCode;
        chi_lead.Bill_City__c =         CreateCustomerData.Address.TownCity;
        chi_lead.Bill_State__c =        CreateCustomerData.Address.CountyProvince;
        
        chi_lead.Customer_Marketing_Consent__c =        CreateCustomerData.MarketingConsent;
        
        //Remote Quote 
        if(CreateCustomerData.ProductInterest!=null)		
        chi_lead.Product_Interest__c = CreateCustomerData.ProductInterest;
        if(CreateCustomerData.SocialContactType!=null && CreateCustomerData.SocialContactDetails!=null)	
        {
            chi_lead.Ta_notes__c = 'Contact Method TYPE: '+CreateCustomerData.SocialContactType +' CONTACT: '+CreateCustomerData.SocialContactDetails;
            chi_lead.Social_Contact_type__c = CreateCustomerData.SocialContactType;
            chi_lead.Social_Contact_Details__c = CreateCustomerData.SocialContactDetails;
        }
        //ends
        
        if(CreateCustomerData.MarketingPreference!=null)
        chi_lead.Marketing_Preferences__c =        CreateCustomerData.MarketingPreference.replaceAll('Post', 'PAPER').replaceAll('Text Message', 'SMS').replaceAll('Landline', 'PHONE');
        
        chi_lead.Bill_Country__c =      'United Kingdom';
            
        
        
        system.debug('Searching for "web" campaign....');
        
        string campignName = 'Web';
        
        if(refferralEmp.size()>0 )
        {
            chi_lead.Referral_Employee__c = refferralEmp[0].id;
            campignName                     = 'Engineer';
            chi_lead.LeadSource             = 'Engineer';
            // populate the customer category for engineer lead
            system.debug('   --->'+CreateCustomerData.heating);
            chi_lead.Is_the_customers_boiler_working__c  = CreateCustomerData.heating;
            chi_lead.Does_the_customer_have_hot_water__c = CreateCustomerData.HotWaterOp;
            chi_lead.Customer_have_any_other_form_of_HEAT__c = CreateCustomerData.OtherHeatingOp;
            chi_lead.Is_the_customer_vulnerable__c = CreateCustomerData.Vulnerable;
            chi_lead.Vulnerable_category__c = CreateCustomerData.VulnerableReason;
            chi_lead.Vulnerable_reason__c   = CreateCustomerData.vulnerableSubReason;

           
            
            category_Indicator__c[] category = [Select id, Category__c from category_Indicator__c where Heating__c = :CreateCustomerData.heating
                                                                                             and Hot_Water__c = :CreateCustomerData.HotWaterOp
                                                                                             and Other_Heat__c = :CreateCustomerData.OtherHeatingOp
                                                                                             and Vunerable__c = :CreateCustomerData.Vulnerable
                                                                                             and Reason__c = :CreateCustomerData.VulnerableReason
                                                                                             and Sub_Reason__c = : CreateCustomerData.vulnerableSubReason
                                                                                             and Customer_Category_Logic__c = '1'];
                                                                                             
            if(category.size()>0)
            {
                chi_lead.Latest_customer_category__c = category[0].category__c;
            }else
            {
                reply.Code = 14;
                reply.Message = 'ERROR: Customer Category can not be derived.';
                if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                                 delete new Account(Id =chi_accountId);
                return reply;
                
            }
                
            chi_lead.Home_care__c = CreateCustomerData.extraInfo.HomeCare;
            chi_lead.Boiler_type__c = CreateCustomerData.extraInfo.existingBoiler;
            chi_lead.Gas_Council_Number__c = CreateCustomerData.extraInfo.boilerGCNumber;
            chi_lead.SM_discount_given__c = CreateCustomerData.extraInfo.discountType;
            chi_lead.Enquiry_Reason__c = CreateCustomerData.extraInfo.reasonForQuote;
            chi_lead.Unsafe_Appliance_Reason__c = CreateCustomerData.extraInfo.unsafeAppReason;
            chi_lead.Product_Interest__c = CreateCustomerData.extraInfo.ProductInterest;
            chi_lead.TA_Notes__c  +=CreateCustomerData.extraInfo.haNotes;
            //chi_lead.                                                                          
        }
        
        List<Campaign> campaign_sources = [SELECT Id 
                                           FROM Campaign 
                                           WHERE Name = :campignName];
        
        system.debug('campaign_sources.size() = ' + campaign_sources.size());
        
        if (campaign_sources.size() == 1) {
            
            system.debug('Campaign id =' + campaign_sources[0].id);
            chi_lead.CampaignId             = campaign_sources[0].id;
           
        }
        else {
            
            // chi lead insert failed, return blank app query reply and error code;
            reply.Code = 9;
            reply.Message = 'ERROR: Cannot assign Campaign to CHI Lead';
            system.debug(reply.Message);
            
            if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                delete new Account(Id =chi_accountId);
            
            return reply;      
        
                
                
            }
            
            try{
                    if(!updateFlag)
                    insert chi_lead;
                    
                    // Update the CHI Lead;
                    update chi_lead;
                    chi_lead = [SELECT AccountId, Id, Account.BillingPostalCode, CHI_Lead_Id1__c , LeadSource, CHI_Lead_Id__c, Visit_Type__c, Product_Interest__c, ES_Product_Interest__c
                        FROM Opportunity where id =:chi_lead.Id];
                        
                    //reply.ChiLeadId = chi_lead.Id;
                    //reply.ChiLeadCustRef = chi_lead.CHI_Lead_Id1__c;
                    reply.Opp =chi_lead;
                    
                    if(campignName == 'Engineer' )
                    {
                        //list<attachment> attachmentList = new list<attachment>();
                        if(CreateCustomerData.extraInfo!=null )
                        {
                            if(CreateCustomerData.extraInfo.signature!=null)
                            {
                                Attachment custSignature = new Attachment();
                                custSignature.Body = EncodingUtil.base64Decode(CreateCustomerData.extraInfo.signature);
                                custSignature.Name = 'Customer Agreed Appointment.png';
                                custSignature.ParentId = chi_lead.Id;
                                //try{
                                attachmentList.add(custSignature);
                            }    
                           /* }catch (Exception e)
                            {
                                reply.Code = 13;
                                reply.Message = 'ERROR: Create custmer signaure on Lead failed.'+e.getMessage()+' At line number'+e.getLineNumber();
                                
                            }*/
                            if(CreateCustomerData.extraInfo.attachmentList!=null && CreateCustomerData.extraInfo.attachmentList.size()>0)
                            {
                                
                                for(webservice_CHI_Online.attachementObj obj : CreateCustomerData.extraInfo.attachmentList)
                                {
                                    Attachment image = new Attachment();
                                    image.Body = EncodingUtil.base64Decode(obj.base64JPEG);
                                    image.Name = 'Grow_'+obj.title+'.jpeg';
                                    image.ParentId = chi_lead.Id;
                                    image.Description = obj.description;
                                    image.contentType = 'image/jpeg';
                                    attachmentList.add(image);
                                }
                            }
                            /*
                            if(attachmentList.size()>0)
                            {
                                try{
                                    insert attachmentList;
                                }catch (exception e)
                                {
                                    reply.Code = 13;
                                    reply.Message = 'ERROR: Error while inserting images/signature. '+e.getMessage()+' At line number'+e.getLineNumber();
                                    
                                }
                            }*/
                        }
                        
                        
                        
                        //Straight Swap
                        //if(chi_lead.Product_Interest__c == 'Straight Swap' || chi_lead.Product_Interest__c == 'Telesales Conv')
                        {
                            CombiSwapQuestion__c csQuestion = new CombiSwapQuestion__c();
                            csQuestion.Type__c = chi_lead.Product_Interest__c == 'Straight Swap' ? 'Combi':'Conv';
                            
                            if(csQuestion.Type__c != 'Combi')
                            csQuestion.Type__c = chi_lead.Product_Interest__c == 'Telesales Conv' ? 'Conv':'Other';
                            
                            csQuestion.Opportunity__c = chi_lead.Id;
                            
                            if(CreateCustomerData.extraInfo.fuelType!=null)
                            {
                                csQuestion.S_S_C1__c = csQuestion.S_S_Q1__c = CreateCustomerData.extraInfo.fuelType == 'LPG'?'Yes':'No';
                                csQuestion.C_S_C5__c = csQuestion.What_fuel_type_is_the_boiler__c = CreateCustomerData.extraInfo.fuelType;
                            }
                            
                            if(CreateCustomerData.extraInfo.fuseSpurReq!=null)
                            {
                                csQuestion.S_S_C2__c = csQuestion.S_S_Q2__c = CreateCustomerData.extraInfo.fuseSpurReq;
                                csQuestion.Is_a_fused_spurr_fitted__c = csQuestion.Is_a_fused_spur_fitted__c = (CreateCustomerData.extraInfo.fuseSpurReq == 'Yes'?'No':'Yes');

                            }
                            
                            if(CreateCustomerData.extraInfo.PEBInstalled!=null)

                            csQuestion.S_S_C16__c= csQuestion.Is_there_a_visiblee_main_earth__c = csQuestion.S_S_C3__c = csQuestion.S_S_Q3__c = CreateCustomerData.extraInfo.PEBInstalled!='No'?'Yes':'No';
                            
                            if(CreateCustomerData.extraInfo.plumeKitReq !=null)
                            csQuestion.Is_a_Plume_Kit_Requiredd__c = csQuestion.Is_a_Plume_Kit_Required__c= csQuestion.S_S_C4__c =  csQuestion.S_S_Q4__c = CreateCustomerData.extraInfo.plumeKitReq;
                            
                            if(CreateCustomerData.extraInfo.hnztlFlueExtReq !=null)
                            csQuestion.Horizontal_flue_extensions_required__c = csQuestion.Any_horizontal_flue_extensions_required__c = csQuestion.S_S_C6__c=csQuestion.S_S_Q6__c = CreateCustomerData.extraInfo.hnztlFlueExtReq;
                            
                            
                            if(CreateCustomerData.extraInfo.hnztlFlueBendReq !=null)
                            csQuestion.Are_any_flue_bends_required__c = csQuestion.Are_any_flue_bend_required__c = csQuestion.S_S_C7__c= csQuestion.S_S_Q7__c =CreateCustomerData.extraInfo.hnztlFlueBendReq;
                            
                            if(CreateCustomerData.extraInfo.balFlueBrickReq!=null)
                            csQuestion.Is_balanced_flue_brick_up_required__c = csQuestion.Is_a_balanced_flue_brick_up_required__c = csQuestion.S_S_TC9__c=csQuestion.S_S_CN9__c = CreateCustomerData.extraInfo.balFlueBrickReq;
                            
                            if(CreateCustomerData.extraInfo.terminalGuardReq!=null)
                            csQuestion.S_S_C13__c = csQuestion.C_S_C4__c = csQuestion.S_S_C9__c = csQuestion.S_S_Q9__c =CreateCustomerData.extraInfo.terminalGuardReq;
                            
                            if(CreateCustomerData.extraInfo.systemFilterFitted!=null)
                            csQuestion.Already_has_magnetic_filter__c = csQuestion.S_S_Q10__c =csQuestion.S_S_C10__c = CreateCustomerData.extraInfo.systemFilterFitted;
                            
                            if(CreateCustomerData.extraInfo.scaleReducerFitted!=null)
                            csQuestion.Already_have_a_scale_reducer__c = csQuestion.S_S_Q10__c =csQuestion.S_S_Q11__c = CreateCustomerData.extraInfo.scaleReducerFitted;
                            
                            if(CreateCustomerData.extraInfo.boilerBelow18kw!=null)
                            csQuestion.Is_the_current_boiler_18KW_or_less__c =  csQuestion.S_S_TC16__c = CreateCustomerData.extraInfo.boilerBelow18kw=='No'? 'Yes' : 'No' ;

                            if(CreateCustomerData.extraInfo.flueType!=null)
                            csQuestion.Vertical_Flue__c=csQuestion.S_S_TC5__c = CreateCustomerData.extraInfo.flueType;
                            
                            if(CreateCustomerData.extraInfo.flueSubType!=null)
                            csQuestion.S_S_TC12__c = CreateCustomerData.extraInfo.flueSubType;
                            
                            if(CreateCustomerData.extraInfo.frostProtectionReq!=null)
                            csQuestion.S_S_TC3__c = CreateCustomerData.extraInfo.frostProtectionReq;
                            
                            if(CreateCustomerData.extraInfo.termostateReq!=null)
                            csQuestion.S_S_TC14__c = CreateCustomerData.extraInfo.termostateReq;
                            
                            if(CreateCustomerData.extraInfo.heatingControlsReq!=null)
                            csQuestion.C_S_C7__c = csQuestion.S_S_CON__c= CreateCustomerData.extraInfo.heatingControlsReq;
                            
                            if(CreateCustomerData.extraInfo.condensateRun!=null)
                            csQuestion.S_S_TC6__c= CreateCustomerData.extraInfo.condensateRun;
                            
                            if(CreateCustomerData.extraInfo.powerflushReq!=null)
                            csQuestion.Is_a_powerflushh_required__c = csQuestion.S_S_TC4__c= CreateCustomerData.extraInfo.powerflushReq;
                            
                            if(CreateCustomerData.extraInfo.boilerLocation!=null)
                            csQuestion.Boiler_Location__c = CreateCustomerData.extraInfo.boilerLocation;
                            
                            if(CreateCustomerData.extraInfo.furtherWorkRqd!=null)
                            csQuestion.furtherWorkRqd__c = CreateCustomerData.extraInfo.furtherWorkRqd;
                            
                            if(CreateCustomerData.extraInfo.foulDrain!=null)
                            csQuestion.Foul_Drain__c = CreateCustomerData.extraInfo.foulDrain;
                            
                            try{
                            insert csQuestion;
                            } catch(exception e)
                            {
                                 reply.Code = 12;
                                 reply.Message = 'ERROR: Create Stright swap record on Lead failed.'+e.getMessage()+' At line number'+e.getLineNumber();
                                 if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                                 delete new Account(Id =chi_accountId);
                                
                            }
                            
                        }
                        
                    }
                }catch(Exception e)
                {
                    system.debug(e.getMessage()+e.getLineNumber());
                    reply.Code = 3;
                    reply.Message = 'ERROR: Create CHI Lead failed.';
                    system.debug(reply.Message);
                    
                    if (null != chi_accountId && !existAccount) // only need to delete account as this triggers a delete of everything else
                        delete new Account(Id =chi_accountId);
                   
                    return reply;    
                } 
       return reply;                
    }
    
    
    private class LeadCreateHelper {
        integer  Code = 0;
        string   Message = null;
        Opportunity  opp = new Opportunity();
        
    }

    public void createEmail (string body)
    {
        CreateEmail.CretaeSendTextEmail(system.label.supportOnline.split(','), body,'issue in webmangecustomer booking');
    }
    
    //Remote Quote Chnages 
    public static Appointment__c ChooseBestAppointment(String reformatted_code,appointment__c appRec,opportunity chi_lead,string boilerOp)
    {
               system.debug('reformatted_code --?>'+reformatted_code);
               Postcode_Sector__c[] post_code_info = [SELECT Name, p.Sub_Patch__c, p.Sub_Patch__r.District__c ,p.sub_Patch__r.Appointment_Source__c,p.sub_patch__r.OFS_Start_Date__c,p.sub_Patch__r.OFS_Bucket_Name__c, p.Sub_Patch__r.District__r.NA_Online__c
                                                         FROM Postcode_Sector__c p
                                                         WHERE name = :reformatted_code
                                                         AND type__c = :'Sales'];
               String post_code_district = post_code_info[0].Sub_Patch__r.District__c;
                        
               map<String,map<Id, List<List<Date>>>> preferenceMap = new map<string, map<Id, List<List<Date>>>>();
                    
               List<Role_District__c> rle_Districts = new list<Role_District__c>();
               rle_Districts= [SELECT Role__r.Employee__c, start_date__c,end_date__c,Role__r.Employee__r.Primary_Role__c,Preference__c FROM Role_District__c 
                              WHERE District__c = :post_code_district
                              AND Type__c = 'Availability'      
                              AND start_date__c <=:appRec.Start__c.date()
                              AND end_date__c >= :appRec.End__c.date()
                              AND Role__r.Employee__r.Pool_Type__c = null
                              AND Role__r.Employee__r.Primary_Role__c != 'Pool'
                              ORDER BY Role__r.Employee__c];
                      map<Id, List<List<Date>>> cEmpAvailMapPrimary = new map<Id, List<List<Date>>>();
                      map<Id, List<List<Date>>> cEmpAvailMapSecondary = new map<Id, List<List<Date>>>();
                      set<id> finalEmplist = new set<id>();
                     
                      for(role_District__c rd: rle_Districts)
                      {
                          if(rd.preference__c=='Primary')
                          {
                                  
                                  list<list<date>> shiftSartEndDates = new list<list<date>>();
                                  if(rd.End_Date__c >=rd.start_date__c)
                                  {
                                      if(rd.Role__r.Employee__c!=null && cEmpAvailMapPrimary.containsKey(rd.Role__r.Employee__c)) 
                                      {
                                          shiftSartEndDates  = cEmpAvailMapPrimary.get(rd.Role__r.Employee__c);
                                      }
                                      shiftSartEndDates.add(new list<Date>{rd.Start_Date__c, rd.End_Date__c});
                                      cEmpAvailMapPrimary.put(rd.Role__r.Employee__c,shiftSartEndDates);
                                     
                                  }
                                 
                              
                          }
                          else
                          {
                                 
                                  list<list<date>> shiftSartEndDates = new list<list<date>>();
                                  if(rd.End_Date__c >=rd.start_date__c)
                                  {
                                      if(rd.Role__r.Employee__c!=null && cEmpAvailMapSecondary.containsKey(rd.Role__r.Employee__c)) 
                                      {
                                          shiftSartEndDates  = cEmpAvailMapSecondary.get(rd.Role__r.Employee__c);
                                      }
                                      shiftSartEndDates.add(new list<Date>{rd.Start_Date__c, rd.End_Date__c});
                                      cEmpAvailMapSecondary.put(rd.Role__r.Employee__c,shiftSartEndDates);
                                  }
                                  //set<id> filteredList = webGetAppointmentsByPostcode.getEmployeeWithSkills(cEmpAvailMapSecondary.keyset(), chi_lead.Product_Interest__c);		
                                  
                              
                          }
                          finalEmplist.add(rd.Role__r.Employee__c);
                     }
                     
                    
                     
                     set<id> filteredList = webGetAppointmentsByPostcode.getEmployeeWithSkills(finalEmplist, chi_lead.Product_Interest__c);		
                     for(id i : cEmpAvailMapPrimary.keyset())		
                     {	
                         if(!filteredList.contains(i))	
                         cEmpAvailMapPrimary.remove(i);		
                     }
                     preferenceMap.put('Primary',cEmpAvailMapPrimary);
                     for(id i : cEmpAvailMapSecondary.keyset())		
                     {	
                         if(!filteredList.contains(i))	
                         cEmpAvailMapSecondary.remove(i);		
                     }
                    preferenceMap.put('Secondary',cEmpAvailMapSecondary);
                     
                     system.debug('@@preferenceMap'+preferenceMap);
                     
                           string avaiRecordType = system.label.AppointmentAvailability;
                           list <String> visit_type = new list<String>();
                           visit_type.add('Sales');
                              
                           if(boilerOp !=null && boilerOp == 'No')
                           {
                               visit_type.add('Priority');
                           }
                         
                           List<Appointment__c> apps = [SELECT Id, Start__c, End__c, Assigned_To__c, Start_Time__c, Type__c,Valid_Slot__c,Online_Reservation_Id__c,status__c,Opportunity__c,Who__c,Visit_Type__c 
                                           FROM Appointment__c
                                           WHERE (Assigned_To__c in :preferenceMap.get('Primary').keyset() OR Assigned_To__c in :preferenceMap.get('Secondary').keyset())
                                           AND RecordTypeId = :avaiRecordType
                                           AND Start__c = :appRec.start__c
                                           AND End__c = :appRec.end__c
                                           AND Type__c in :visit_type
                                           AND Opportunity__c = null
                                           AND Status__c ='New'
                                           ORDER BY Start__c ASC 
                                           LIMIT 1500];
                                           
                            system.debug('@@appointments '+apps);
                              
                            List<Appointment__c> appListPrimary = new List<Appointment__c>();             
                            for(Appointment__c a: apps){
                              if(a.Valid_Slot__c == 'Yes' && a.Start__c>= system.now() && preferenceMap.get('Primary').containsKey(a.Assigned_To__c))
                               {
                                    for(List<DateTime> startEndTime : preferenceMap.get('Primary').get(a.Assigned_To__c))
                                    {
                                          if(a.Start__c.date() <= startEndTime[1] && a.End__c.date() >= startEndTime[0])
                                          {
                                              appListPrimary.add(a);
                                              //return a;
                                          }
                                    }
                               }
                            } 
                            if(appListPrimary.size()>0)
                            {
                                Integer rand = (Math.random() * appListPrimary.size()).intValue();
                                if(rand >= appListPrimary.size())
                                rand = appListPrimary.size()-1;
                                return appListPrimary[rand];
                            }
                        
                            List<Appointment__c> appListSecondary = new List<Appointment__c>();
                            for(Appointment__c a: apps){
                             if(a.Valid_Slot__c == 'Yes' && a.Start__c>= system.now()&& preferenceMap.get('Secondary').containsKey(a.Assigned_To__c))
                              {
                                   for(List<DateTime> startEndTime : preferenceMap.get('Secondary').get(a.Assigned_To__c))
                                    {  
                                        system.debug('@@appointments startEndTime '+startEndTime);
                                        if(a.Start__c.date() <= startEndTime[1] && a.End__c.date() >= startEndTime[0])
                                        {     
                                              appListSecondary.add(a);
                                              //return a;
                                        }
                                    }
                              }
                            }
                            if(appListSecondary.size()>0)
                            {
                                Integer rand = (Math.random() * appListSecondary.size()).intValue();
                                if(rand >= appListSecondary.size())
                                rand = appListSecondary.size()-1;
                                return appListSecondary[rand];
                            }
                            
                return appRec;
    }
    
    
    public Appointment__c bookedAppointment(webservice_CHI_Online.cCreateAppointmentData obj, id oppId, boolean BringForwardVisit)
    {
        Appointment__c returnApp = new Appointment__c();
         
        string available_rt_id = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        string Appt_ID = obj.Appointment.AppId;
        Schema.DescribeSObjectResult r = Appointment__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        Opportunity Opp = [SELECT Id, CloseDate, StageName, Product_Interest__c, CHI_Lead_Id1__c, AccountId ,Account.Primary_Contact__c, Install_Postcode__c,Boiler_Working__c
                                            FROM Opportunity
                                            WHERE id=:oppId
                                            LIMIT 1];
        string post_code_sector = Opp.Install_Postcode__c.substring(0,Opp.Install_Postcode__c.length()-2);
        
        if(!Appt_ID.startswith(keyPrefix)){
            
            //system.debug('Postcode sector = ' + post_code_sector); 
            
            //system.debug('Appointemtn Info-->'+objManageCustomerBooking.CreateAppointmentData.Appointment);
            
            string prodInterest = Opp.Product_Interest__c;
                
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
            system.debug(year);
            system.debug(month);
            system.debug(day);
            system.debug(GetTimeslot);
           
            map<string , SalesAppointment__c> customSettingMap = new map <string, SalesAppointment__c>();
            for(SalesAppointment__c c : SalesAppointment__c.getAll().values())
            {
                customSettingMap.put(c.Online_Code__c, c);
            }
            
            SalesAppointment__c s = customSettingMap.get(GetTimeslot);
            
            datetime slotStartTime = datetime.newInstance(year, month, day, integer.valueof(s.Start_Time__c.split(':')[0]), integer.valueof(s.Start_Time__c.split(':')[1]), 0);
            datetime slotEndTime = datetime.newInstance(year, month, day, integer.valueof(s.End_Time__c.split(':')[0]), integer.valueof(s.End_Time__c.split(':')[1]), 0);
            datetime SLAStartTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_Start__c.split(':')[0]), integer.valueof(s.SLA_Start__c.split(':')[1]), 0);
            datetime SLAEndTime = datetime.newInstance(year, month, day, integer.valueof(s.SLA_End__c.split(':')[0]), integer.valueof(s.SLA_End__c.split(':')[1]), 0);
            
            //dateTime End_Date = objManageCustomerBooking.CreateAppointmentData.Appointment.AppEnd;
       
        
           
        
           //string GetTimeslot= string.valueof(Appt_ID).substring(string.valueof(Appt_ID).length()-5,string.valueof(Appt_ID).length()-3);
           TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(prodInterest);
           Appointment__c newAppt = new Appointment__c();
           newAppt.Assigned_To__c = ofsBuckname;
           newAppt.Opportunity__c = Opp.Id;
           newAppt.Who__c = Opp.Account.Primary_Contact__c;
           newAppt.Status__c = 'Appointed';
           newAppt.start__c = slotStartTime;
           newAppt.End__c = slotEndTime;
           newAppt.Visit_Type__c = 'First Visit';
           newAppt.Show_Time_As__c = 'Busy';
           newAppt.RecordTypeId = available_rt_id;
           newAppt.SLA_Start__c = SLAStartTime;
           newAppt.SLA_End__c = SLAEndTime;
           //newAppt.Customer_Happy__c = obj.happyWithAppointment;
           newAppt.Customer_Feedback__c = obj.appointmentFeedback;
           if(toaPI != null)
           newAppt.TOA_Duration__c = toaPI.Duration__c;
           
           newAppt.Time_Band__c = s.Name;
           newAppt.OFS_Appointment__c = true;
           newAppt.Bring_forward_visit__c = BringForwardVisit;
           system.debug('*************^^^^'+newAppt);
           insert newAppt;
           returnApp =  newAppt;
            
        }//Ashok Change End
        else
        {
            
         Appointment__c appRec = [Select id, Status__c, Start__c, End__c,  Online_Reservation_Id__c from Appointment__c where Id = :Appt_ID];
         
         //Remote Quote Changes 
         system.debug('I am here -->'+opp.Product_Interest__c);
         if(Remote_Quote_Product__c.getInstance(opp.Product_Interest__c) != null)
         {
             system.debug('I am here -->'+post_code_sector);
             appRec = ChooseBestAppointment(post_code_sector,appRec,opp,opp.Boiler_Working__c);
         }
            
         if((appRec.Status__c == 'Reserved' || appRec.Status__c == 'New') )
         { 
                //appRec.Status__c = 'Appointed';
                appRec.Opportunity__c= opp.Id;
                appRec.Who__c = opp.Account.Primary_Contact__c;
                //appRec.Show_Time_As__c = 'Busy';
                appRec.Visit_Type__c = 'First Visit';
                appRec.Bring_forward_visit__c = BringForwardVisit;
                //appRec.Customer_Happy__c = obj.happyWithAppointment;
                appRec.Customer_Feedback__c = obj.appointmentFeedback;
                update appRec;
                returnApp =  appRec;   
                
          }else
        {
            
            Appointment__c newReplacement = reSearchAppointment(appRec.Start__c , appRec.End__c, post_code_sector, opp.Boiler_Working__c, opp.Product_Interest__c);
            //Remote Quote Changes  
            if(Remote_Quote_Product__c.getInstance(opp.Product_Interest__c) != null)
            {
               //system.debug('I am here -->'+reformatted_code.substring(0,reformatted_code.length()-2));
               newReplacement = ChooseBestAppointment(post_code_sector,appRec,opp,opp.Boiler_Working__c);
            }
            
            if(newReplacement.Id != null)
            {
                newReplacement.Opportunity__c= opp.Id;
                newReplacement.Who__c = opp.Account.Primary_Contact__c;
                newReplacement.Bring_forward_visit__c = BringForwardVisit;
                //newReplacement.Customer_Happy__c = obj.happyWithAppointment;
                newReplacement.Customer_Feedback__c = obj.appointmentFeedback;
                update newReplacement;
                returnApp =  newReplacement;
            }
        }
      } 
      system.debug('new replacement'+returnApp);    
      return returnApp;
           
    }
    
    
    
    
}