public class WebCustomer {

    public webservice_CHI_Online.cCreateCustomerReply fCreateCustomer(webservice_CHI_Online.cCreateCustomerRequest CreateCustomerData) {
        
        webservice_CHI_Online.cCreateCustomerReply reply = new webservice_CHI_Online.cCreateCustomerReply();
        
        Web_Enquiry__c enquiry = new Web_Enquiry__c();
        Opportunity chi_lead = new Opportunity();
        Contact new_contact = new Contact();
        Account chi_account = new Account();
        List<Account> existing_accs = new List<Account>();
        
        new_contact.Salutation          = CreateCustomerData.Name_x.Salutation;
        new_contact.FirstName           = CreateCustomerData.Name_x.FirstName;
        new_contact.LastName            = CreateCustomerData.Name_x.LastName;
        new_contact.MobilePhone         = CreateCustomerData.Contact_x.MobilePhone;
        new_contact.HomePhone           = CreateCustomerData.Contact_x.HomePhone;
        new_contact.OtherPhone          = CreateCustomerData.Contact_x.WorkPhone;
        new_contact.Phone               = CreateCustomerData.Contact_x.AltPhone;
        new_contact.Email__c            = CreateCustomerData.Contact_x.Email;
        new_contact.Contact_Type__c     = CreateCustomerData.ResStatus;
        new_contact.MailingCity         = CreateCustomerData.Address.TownCity;
        
        // format postcode correctly
        string trimmed_code;
        string first_part;
        string second_part;
        string reformatted_code;
        string test_acc_name;
        system.debug('Untrimmed code = ' + CreateCustomerData.Address.Postcode);
        //trimmed_code    = CreateCustomerData.Address.Postcode.trim();
        trimmed_code    = CreateCustomerData.Address.Postcode.replace(' ', '');
        system.debug('trimmed_code = ' + trimmed_code);
        
        second_part     = trimmed_code.substring(trimmed_code.length()-3, trimmed_code.length());
        system.debug('second_part = ' + second_part);
        
        first_part      = trimmed_code.substring(0, trimmed_code.length()-second_part.length());
        system.debug('first_part = ' + first_part);
        
        reformatted_code = first_part + ' ' + second_part;
        system.debug('reformatted_code = ' + reformatted_code);
        
        new_contact.MailingPostalCode   = reformatted_code;
        new_contact.MailingState        = CreateCustomerData.Address.CountyProvince;
        
        new_contact.MailingStreet       = CreateCustomerData.Address.NameNumber + ' ' + CreateCustomerData.Address.Street;
        new_contact.IsActive__c         = True;
        
        // CR******: 25/01/2011 - ensure contact is set as primary. This change in conjunction with a change in PrimaryContactOnInsOrUpd trigger which was previously "undoing" this
        new_contact.Primary_Contact__c  = True;
        
        try {
            
            test_acc_name = new_contact.MailingPostalCode.trim() + ' ' + new_contact.MailingStreet; 
         
            system.debug('Searching for Account with Account_Id__c of: ' + test_acc_name);
            
            existing_accs = [SELECT  Id
                                           FROM Account
                                           WHERE Account_Id__c = :test_acc_name limit 1]; // use this field as it is indexed
                                           
            system.debug('existing_accs.size() ' + existing_accs.size());
                                           
            // was there an existing account?
            if (existing_accs.size() == 1) {
                // now have to check if there are existing leads on the account that are less than 90 days old
            system.debug('Searching for current leads on account ' + chi_account.Id);
        
            List<Opportunity> existing_leads = [SELECT Id, CloseDate, StageName
                                            FROM Opportunity
                                            WHERE AccountId = :existing_accs[0].id
                                            AND CloseDate >= :Date.Today() order by StageName limit 1];
       
            system.debug('existing_leads.size() = ' + existing_leads.size());
            // Vijay - allow customer to book appointment if active lead exist without appointment
            if (existing_leads.size() > 0 ) { 
                if (existing_leads[0].StageName=='Active') {             
                    reply.ChiLeadId = existing_leads[0].Id;
                }    
                else // return error
                {
                    reply.Error.Code = 6;
                    reply.Error.Message = 'ERROR: Account still has active lead, new lead not allowed';
                    system.debug(reply.Error.Message);
                }
                return reply; 
            }
            }
             insert new_contact;
             system.debug('New contact ID = ' + new_contact.id);  
        }             
        catch (exception e) {
            // contact insert failed, return blank app query reply and error code;
            reply.Error.Code = 1;
            reply.Error.Message = 'ERROR: New Contact insert failed';
            system.debug(reply.Error.Message);
            
            return reply;       
        }
        
        
        chi_account.Primary_Contact__c          = new_contact.Id;
        chi_account.BillingPostalCode           = new_contact.MailingPostalCode;
        chi_account.BillingStreet               = new_contact.MailingStreet;
        chi_account.BillingCity                 = new_contact.MailingCity;
        chi_account.BillingState                = new_contact.MailingState;
        chi_account.Name                        = 'unused name';
        
          
        try {
            
            system.debug('Trying to insert new account....');
            insert chi_account; 
            system.debug('Account insert successful ' + chi_account.Id);
        }              
        catch (exception e) {
            
            system.debug('Account insert FAILED,....');
       // was there an existing account?
            if (existing_accs.size() == 1) {
                
                system.debug('Existing account found: ' + existing_accs[0].Id);
                
                // update the existing account with "new" details
                id temp_id = existing_accs[0].Id;
                
                system.debug('Old acc ID ' + existing_accs[0].Id);
                
                system.debug('Cloning account....');
                // clone existing account data into new account record
                chi_account = existing_accs[0].clone(true, true);
                
                system.debug('Updating account fields....');
                // update the relevant fields
                chi_account.Primary_Contact__c          = new_contact.Id;
                chi_account.BillingPostalCode           = new_contact.MailingPostalCode;
                chi_account.BillingStreet               = new_contact.MailingStreet;
                chi_account.BillingCity                 = new_contact.MailingCity;
                chi_account.BillingState                = new_contact.MailingState;
                
                system.debug('New acc ID ' + chi_account.Id);
                
                
                try {
                    
                    system.debug('Trying to update account ' + chi_account);
                    // update existing account
                    update chi_account;
                    system.debug('Account update ' + chi_account.Id + ' successful');   
                }
                catch (exception e2) {
                
                    // chi account insert failed, return blank app query reply and error code;
                    reply.Error.Code = 5;
                    reply.Error.Message = 'ERROR: Account  ' + chi_account.id + ' update failed';
                    system.debug(reply.Error.Message);
                    
                    if (null != new_contact.Id)
                        delete new_contact;
                    
                    return reply;       
                }
                    
            } 
            else { // no there wasn't, return error, something wrong with info in account fields
                
                // chi account insert failed, return blank app query reply and error code;
                reply.Error.Code = 2;
                reply.Error.Message = 'ERROR: Existing account retrieval failed with name ' + test_acc_name;
                system.debug(reply.Error.Message);
                
                if (null != new_contact.Id)
                    delete new_contact;
                
                return reply;   
            }  
        }
        
        //now update contact to have new account details
        try {
            
            new_contact.AccountId = chi_account.Id;
            update new_contact;
        }
        catch (exception e) {
            
            reply.Error.Code = 7;
            reply.Error.Message = 'ERROR: Could not update new contact with account ID ' + chi_account.Id;
            system.debug(reply.Error.Message);
            
            if (null != new_contact.Id)
                delete new_contact;
            
            return reply;   
        }
           
        enquiry.Name                    = new_contact.LastName + ' ' + chi_account.BillingPostalCode + ' ' + datetime.now();
        enquiry.Boiler_Age__c           = CreateCustomerData.BoilerAge;
        enquiry.Boiler_Operational__c   = CreateCustomerData.BoilerOp;
        enquiry.County_Province__c      = new_contact.MailingState;
        enquiry.Fuel_Type__c            = CreateCustomerData.FuelType;
        enquiry.Email__c                = new_contact.Email__c;
        enquiry.First_Name__c           = new_contact.FirstName;
        enquiry.Home_Phone__c           = new_contact.HomePhone;
        enquiry.Work_Phone__c           = new_contact.OtherPhone;
        enquiry.Mobile_Phone__c         = new_contact.MobilePhone;
        enquiry.Alt_Phone__c            = new_contact.Phone;
        enquiry.Last_Name__c            = new_contact.LastName;
        enquiry.Postcode__c             = chi_account.BillingPostalCode;
        enquiry.Residential_Status__c   = CreateCustomerData.ResStatus;
        enquiry.Salutation__c           = new_contact.Salutation;
        
        string temp_str = '';
        temp_str = chi_account.BillingStreet;
        
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
        temp_str = chi_account.BillingCity;
        
        system.debug('chi_account.BillingCity.length() = ' + temp_str.length());
        
        if (temp_str.length() > 30) {
        
            system.debug('Trimming chi_account.BillingCity....');
            enquiry.Town_City__c = temp_str.substring(0, 45);
            system.debug('enquiry.Town_City__c ' + enquiry.Town_City__c);   
        }
        else {
        
            enquiry.Town_City__c = temp_str;    
        }
        
        temp_str = '';
        temp_str = enquiry.Street__c;
        
        system.debug('enquiry.Street__c.length() = ' + temp_str.length());
        
        if (temp_str.length() > 30) {
        
            system.debug('Trimming enquiry.Street__c....');
            chi_lead.Address_Line1__c = temp_str.substring(0, 30);
            system.debug('chi_lead.Address_Line1__c ' + chi_lead.Address_Line1__c); 
        }
        else {
        
            chi_lead.Address_Line1__c = temp_str;   
        }
        //chi_lead.Address_Line1__c       = enquiry.Street__c.substring(0, 31);
        
        
        temp_str = CreateCustomerData.Address.NameNumber;
        
        system.debug('CreateCustomerData.Address.NameNumber.length() = ' + temp_str.length());
        
        if (temp_str.length() > 10) {
            
            system.debug('CreateCustomerData.Address.NameNumber....');
            chi_lead.Address_Number__c = temp_str.substring(0, 10);
            system.debug('chi_lead.Address_Number__c ' + chi_lead.Address_Number__c);   
        }
        else {
        
            chi_lead.Address_Number__c = temp_str;  
        }
        
        chi_lead.Alternative_Number__c  = enquiry.Alt_Phone__c;
        chi_lead.Boiler_Age__c          = enquiry.Boiler_Age__c;
        
        if (enquiry.Boiler_Operational__c) 
            chi_lead.Boiler_Working__c = 'Yes';
        else 
            chi_lead.Boiler_Working__c = 'No';
        
        if (null != enquiry.Mobile_Phone__c) 
            chi_lead.Contact_Number__c = enquiry.Mobile_Phone__c;   
        else if (null != enquiry.Home_phone__c)
            chi_lead.Contact_Number__c = enquiry.Home_phone__c;
        else if (null != enquiry.Work_phone__c)
            chi_lead.Contact_Number__c = enquiry.Work_phone__c;
        else
            chi_lead.Contact_Number__c = enquiry.Alt_phone__c;
            
        chi_lead.LeadSource             = 'Internet';
        
        chi_lead.Name                   = 'unused name';
        chi_lead.StageName              = 'Active';
        chi_lead.CloseDate              = Date.today().addmonths(3);
        system.debug('chi_lead.CloseDate = ' + chi_lead.CloseDate);
        
        chi_lead.AccountId              = chi_account.Id;
        chi_lead.Urgency__c             = 'Standard';
        chi_lead.Home_improvement__c    = 'No';
        chi_lead.Visit_Type__c          = 'Sales';
        chi_lead.SC_Type__c             = new_contact.Contact_Type__c;
        
        chi_lead.Product_Interest__c    = 'None'; // temporary, can/will be amended during app booking webservice 
        
        system.debug('Searching for "web" campaign....');
        
        List<Campaign> campaign_sources = [SELECT Id 
                                           FROM Campaign 
                                           WHERE Name = 'Web'];
        
        system.debug('campaign_sources.size() = ' + campaign_sources.size());
        
        if (campaign_sources.size() == 1) {
            
            system.debug('Campaign id =' + campaign_sources[0].id);
            chi_lead.CampaignId             = campaign_sources[0].id;
            chi_lead.LeadSource             = 'CHI Online';
        }
        else {
            
            // chi lead insert failed, return blank app query reply and error code;
            reply.Error.Code = 4;
            reply.Error.Message = 'ERROR: Cannot assign Campaign to CHI Lead';
            system.debug(reply.Error.Message);
            
            if (null != chi_account.Id) // only need to delete account as this triggers a delete of everything else
                delete chi_account;
            
            return reply;      
        }
    //Vijay - double check for existing lead.
        List<Opportunity> existing_leads1 = [SELECT Id, CloseDate, StageName
                                            FROM Opportunity
                                            WHERE AccountId = :chi_account.Id
                                            AND CloseDate >= :Date.Today() order by StageName limit 1];
       
        system.debug('existing_leads1.size() = ' + existing_leads1.size());
        // Vijay - allow customer to book appointment if active lead exist without appointment
        if (existing_leads1.size() > 0 ) { 
             if (existing_leads1[0].StageName=='Active') {             
                   reply.ChiLeadId = existing_leads1[0].Id;
             }    
             else // return error
             {
                 reply.Error.Code = 6;
                 reply.Error.Message = 'ERROR: Account still has active lead, new lead not allowed';
                 system.debug(reply.Error.Message);
             }
             return reply; 
        }
        
        try {
            insert chi_lead;
            enquiry.CHI_Lead__c = chi_lead.id;
            insert enquiry;
            
            system.debug('Enquiry id =' + enquiry.id);
            system.debug('CHI Lead id =' + chi_lead.id);
        }             
        catch (exception e) {
            // chi lead insert failed, return blank app query reply and error code;
            reply.Error.Code = 3;
            reply.Error.Message = 'ERROR: New CHI Lead insert failed OR Enquiry insert failed';
            system.debug(reply.Error.Message);
            
            if (null != chi_account.Id) // only need to delete account as this triggers a delete of everything else
                delete chi_account;
            
            return reply;       
        }   
        
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
        }   
        
        // all good, so set CHI Lead ID and return
        reply.ChiLeadId = chi_lead.Id;
        return reply;   
    }
}