global class SendAppointment implements Database.Batchable<sObject>{
    
   String str = '';    
    
       public static void sendAppListLink(){
        SendAppointment sendApp = new SendAppointment();
        ID batchprocessid = Database.executeBatch(sendApp);
    }
    
    /*
    *   Input - Current Btch Context
    *   Output - Query Set
    *   Purpose - retrieves the query set to be processed by the current & future batches 
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        
       integer offset = decimal.valueof(system.label.X7DayDairyOffset).intValue();
        Date startdt = System.today().addDays(1);
        Date endDt = (System.today()).addDays(offset);
       
        //Code fix done by BGSAMS Support Team on 21/03/2012 for PRB00007119 - Starts
        Date currentDt = System.today();
        //Code fix done by BGSAMS Support Team on 21/03/2012 for PRB00007119 - Starts
        // Fix for seven days diaries
        Integer startdtDayOfYear = startdt.dayOfYear();
        Integer enddtDayOfYear = endDt.dayOfYear();
        String Sales = 'Sales';
        // Landlord change
        // Add product of interest, media cost code and campaign description on 7 days diary emails.
        // Fix for seven days diaries
        //Code fix done by BGSAMS Support Team on 21/03/2012 for PRB00007119 - Starts
        // code fix for year end problem - Ashok 04/01/2013
        string query = 'SELECT a.assigned_to__r.primary_role__c,Opportunity__r.SMStatus__c,Appointment_Attendee__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,HSAOfficePrecalled__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE  (Type__c = \'Sales\' OR Type__c = \'Green Deal\')';
        if(startdtDayOfYear<enddtDayOfYear)
        {
            system.debug('*********IN OLD YEAR**********');
            query += ' and Visit_Day_Of_Year__c >= :startdtDayOfYear and Visit_Day_Of_Year__c <= :enddtDayOfYear and Start__c >: currentDt order by Assigned_To__r.Name,Visit_Date__c,Start_Time__c';
            //return Database.getQueryLocator('SELECT a.assigned_to__r.primary_role__c,Opportunity__r.SMStatus__c,Appointment_Attendee__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,HSAOfficePrecalled__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE  (Type__c = \'Sales\' OR Type__c = \'Green Deal\') and Visit_Day_Of_Year__c >= :startdtDayOfYear and Visit_Day_Of_Year__c <= :enddtDayOfYear and Start__c >: currentDt order by Assigned_To__r.Name,Visit_Date__c,Start_Time__c');
        }
        
        else
        {
            system.debug('*********IN NEW YEAR**********');
            integer lastDayOfYear;
            integer startNewYear =1;
            if(date.isLeapYear(startdt.year()))
            lastDayOfYear=366;
            else
            lastDayOfYear = 365;
            integer LastDayfromNextYear = offset -(lastDayOfYear -startdtDayOfYear);
            Date lastDate = date.newinstance(startdt.year()+1,01,01);
            query += ' and ((Visit_Day_Of_Year__c >= :startdtDayOfYear and Visit_Day_Of_Year__c <= :lastDayOfYear and Start__c <=:lastDate) OR ((Visit_Day_Of_Year__c >= :startNewYear and Visit_Day_Of_Year__c <= :LastDayfromNextYear))) and Start__c >: currentDt order by Assigned_To__r.Name,Visit_Date__c,Start_Time__c';
            //return Database.getQueryLocator('SELECT a.assigned_to__r.primary_role__c,Opportunity__r.SMStatus__c,Appointment_Attendee__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,HSAOfficePrecalled__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE  (Type__c = \'Sales\' OR Type__c = \'Green Deal\') and ((Visit_Day_Of_Year__c >= :startdtDayOfYear and Visit_Day_Of_Year__c <= :lastDayOfYear and Start__c <=:lastDate) OR ((Visit_Day_Of_Year__c >= :startNewYear and Visit_Day_Of_Year__c <= :LastDayfromNextYear))) and Start__c >: currentDt order by Assigned_To__r.Name,Visit_Date__c,Start_Time__c');
        }
       //query = 'SELECT a.assigned_to__r.primary_role__c,Appointment_Attendee__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,Opportunity__r.SMStatus__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,HSAOfficePrecalled__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE id = \'a0BW0000006tRqM\'';
       return Database.getQueryLocator(query);
       //return Database.getQueryLocator('SELECT a.assigned_to__r.primary_role__c,Appointment_Attendee__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,Opportunity__r.SMStatus__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,HSAOfficePrecalled__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE (Type__c = \'Sales\' OR Type__c = \'Green Deal\') and id = \'a0BW0000006tRqM\'' );
         
       
    }


    /*
    *   Input - current batch context and list of records to process
    *   Output - None
    *   Purpose - retrives the related opportunities whose reconcilliation data is fecthed form the 'Outstanding Deposits' object
    *               matches the Amount in the deposits object and that on the opportunity and updates the CHI Lead Amount Settled Field 
    */ 
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
        integer offset = decimal.valueof(system.label.X7DayDairyOffset).intValue();
        Date startdt = System.today().addDays(1);
        Date endDt = (System.today()).addDays(offset);
        Integer count =0;
        // ++ Added logic to send the email from OrgWide Email address irrespective of the user who is running the batch
        
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'British Gas (DO NOT REPLY)' limit 1];
        
        // -- Added logic to send the email from OrgWide Email address irrespective of the user who is running the batch
        
        if(lstRecords.size() > 0){
      
            Map<String,List<Appointment__C>> appMap = new Map<String,List<Appointment__C>>();
            List<Appointment__C > tempLstApp = new List<Appointment__C>();
            list<Id> apptIdLst = new list<Id>();
            list<Id> gDLeadIds = new list<Id>();
            system.debug('@@@@@--->'+lstRecords);
            for(sObject sObj : lstRecords){
                
                Appointment__c app  = (Appointment__C)sObj;
                // Added extra checks to verify that we have HSA email on user record to send this data to
                if(app.Assigned_To__c!=null){
                    
                 if(app.Assigned_To__r.Salesforce_User__c!=null){
                     
                  if(app.Assigned_To__r.Salesforce_User__r.Email!=null){
                  	   if(app.Type__c == 'Green Deal')
                          gDLeadIds.add(app.Opportunity__c);
                                  
                       if(appMap.get(app.Assigned_To__c)== null){
                         
                          appMap.put(app.Assigned_To__c,new List<Appointment__C>{app});
                       }else{
                         
                           tempLstApp = appMap.get(app.Assigned_To__c);
                           tempLstApp.add(app);
                           appMap.put(app.Assigned_To__c,tempLstApp);
                       }
                   }
                 }
               }
               apptIdLst.add(app.Opportunity__r.AccountId);
            }
             Map<Id, BigMachines_Quote__c> chiBMMap = new Map<Id, BigMachines_Quote__c>();
            if(gDLeadIds.size()>0)
            {
	            for( BigMachines_Quote__c soldGdQuote : [Select id,Opportunity__c, ECO_Value__c, Non_ECO_Value__c,Green_Value__c,Quote_Net_Value__c from BigMachines_Quote__c where Opportunity__c in : gDLeadIds and 	Is_Primary__c = true and Stage__c= 'Quote Finalised - Accepted'])
	            {
	            	chiBMMap.put(soldGdQuote.Opportunity__c, soldGdQuote);
	            }
            }    
            
            Map<id, ProductHolding__c> appProductMap = new map<id, ProductHolding__c>();
            for(ProductHolding__c p : [select id, Account__c, CreditRating__c,ElectricityIsCurrentCustomer__c,ServiceProducts__c, ElectricityAnnualSpend__c, ElectricityPaymentMethod__c, GasIsCurrentCustomer__c,GasAnnualSpend__c, GasPaymentMethod__c, IsCurrentCustomerOfAnyProduct__c, ServiceCover__c, (Select Type__c, MonthlySpend__c, PaymentMethod__c From ProductHoldingAccounts__r limit 5) from ProductHolding__c where Account__c in:apptIdLst and Status__c = 'Current'])
            {
                if(!appProductMap.containskey(p.Account__c))
                {
                    appProductMap.put(p.Account__c, p);
                }
            }
            
            // Iterating through the Appointmenst against each HSAs
            Set<String> hsaSet = appMap.keySet();
            String ta_Notes_All = '';
            String lead_comments = '';
            String landlordDetails = '';
            String asbestosFound = '';
            String asbestosFoundDate = '';
            
            for(String hsa : hsaSet){
            
                List<Appointment__c> lstApp = appMap.get(hsa);
                count=1;
                // If employee's user is having Phil's email address then exclude it.
                // Fix for seven days diaries
                if(lstApp[0].assigned_to__r.Is_app_email_ready__c != true || lstApp[0].Assigned_To__r.Salesforce_User__r.Email.toLowerCase().contains('phil.dennison') || lstApp[0].Assigned_To__r.Salesforce_User__c == null){
                   continue;
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.setToAddresses(new String[] {'ashoknaglikar@yahoo.com', 'ashokkumar.nagaleekar@centrica.com' , 'rohit.panchhi2@gmail.com' });
                mail.setToAddresses(new String[] {lstApp[0].Assigned_To__r.Salesforce_User__r.Email});
                String str_header = 'Appointments for '+lstApp[0].Assigned_to_Name__c+' From '+startdt.day()+'-'+startdt.month() +'-'+startdt.year()+ ' to '+ endDt.day()+'-'+endDt.month() +'-'+endDt.year();
                mail.setSubject(str_header);
                mail.setSaveAsActivity(false);
                
                // ++ Added logic to send the email from OrgWide Email address irrespective of the user who is running the batch 
                mail.setOrgWideEmailAddressId(owa.Id); 
                // -- Added logic to send the email from OrgWide Email address irrespective of the user who is running the batch
                
                String str_emailBody = '<font face=\'calibri\' size=\'4\' color=\'#990000\' ><b>'+str_header+'</b></font>'+'<table cellpadding=\'5\' width=\'100%\'><tr ><td></td></tr>';  
               
                for(Appointment__c apnt : lstApp ){
                    
                        string custCategory = (apnt.Opportunity__r.Latest_customer_category__c == null || apnt.Opportunity__r.Latest_customer_category__c == 99) ? '':Utilities.categoryMap.get(apnt.Opportunity__r.Latest_customer_category__c);            
                        if(apnt.TA_Notes_All__c!=null){ 
                            
                        ta_Notes_All = ((apnt.TA_Notes_All__c.replace('<','{')).replace('>','}')).replace('|','');
                        if(apnt.Appointment_Attendee__c != null)
                        {
                            ta_Notes_All = ta_Notes_All+ ' {Appointment Attendee: '+apnt.Appointment_Attendee__c+'}';
                        }
                        if(apnt.Opportunity__r.ta_notes__c != null)
                        {
                            ta_Notes_All = ta_Notes_All + '{'+apnt.Opportunity__r.ta_notes__c+'}';
                        }
                        
                        } else{
                            
                            ta_Notes_All = '';
                            
                        }
                         
                        if(apnt.Opportunity__r.Lead_Comments__c!=null){ 
                            
                        lead_comments = ((apnt.Opportunity__r.Lead_Comments__c.replace('<','{')).replace('>','}')).replace('|','');
                        
                        } else{
                            
                            lead_comments = '';
                            
                        }
                        
                        // Landlord change - Starts
                        if(apnt.opportunity__r.Account.Landlord_Account__c==true){ 
                            
                        landlordDetails = apnt.Opportunity__r.Landlord_Lead_Details__c!=null ? ((apnt.Opportunity__r.Landlord_Lead_Details__c.replace('<','{')).replace('>','}')).replace('|',''): '';
                        landlordDetails = '<tr>'+'<td colspan=\'3\'>'
                        +'<font face=\'calibri\' size=\'3\' color=\'#990000\'><b>Landlord / Agent / Tenant Lead Notes : </b></font><font face=\'calibri\' size=\'2\'>'+landlordDetails+'</font>'
                        +'</td>'
                        +'</tr>';
                        
                        } else{
                            
                            landlordDetails = '';
                            
                        }
                        // Landlord change - Ends 
                        
                        // Product Holding Change
                        string smartEligible  = apnt.opportunity__r.SMStatus__c != null ? apnt.opportunity__r.SMStatus__c : '';
                        string creditRating = '';
                        string serviceCover = '';
                        string curntCust = '';
                        string ProHoldingAccntString='';
                        string serviceProduct ='';
                        /*string gas ='<tr>'
                                    +'</tr>'
                                    +'<tr>'
                                    +'<td>'
                                    +'<font face=\'calibri\' size=\'2\' color=\'#0000FF\'><h3>Gas : </h3></font><font face=\'calibri\' size=\'2\'></font>'
                                    +'</td>'
                                    +'</tr>';
                        string electricity = '<tr>'
                                    +'</tr>'
                                    +'<tr>'
                                    +'<td>'
                                    +'<font face=\'calibri\' size=\'2\' color=\'#0000FF\'><h3>Electricity : </h3></font><font face=\'calibri\' size=\'2\'></font>'
                                    +'</td>'
                                    +'</tr>';*/
                        
                        if(appProductMap.containskey(apnt.opportunity__r.AccountId))
                        {
                            ProductHolding__c pHolding= appProductMap.get(apnt.opportunity__r.AccountId);
                            // ++ Commented the part for not sending CreditRatings to 7 day diary as per business request start
                            //creditRating = pHolding.CreditRating__c!=null ? pHolding.CreditRating__c : '';
                            // -- Commented the part for not sending CreditRatings to 7 day diary as per business request end 
                            serviceCover = pHolding.ServiceCover__c!=null ? pHolding.ServiceCover__c : '';
                            curntCust = pHolding.IsCurrentCustomerOfAnyProduct__c!=null ? pHolding.IsCurrentCustomerOfAnyProduct__c : '';
                            serviceProduct = pHolding.ServiceProducts__c!=null?pHolding.ServiceProducts__c:'';
                            list<ProductHoldingAccount__c> phAccnts = pHolding.ProductHoldingAccounts__r;
                             
                            for(ProductHoldingAccount__c pa : phAccnts)
                            {
                                string montSpend ='Unknown';
                                string payMethod = 'Unknown';
                                if(pa.MonthlySpend__c!=null)
                                montSpend = pa.MonthlySpend__c.format();
                                if(pa.PaymentMethod__c != null)
                                payMethod =pa.PaymentMethod__c;
                                
                                ProHoldingAccntString +='<tr>'
                                                +'</tr>'
                                                +'<tr>'
                                                +'<td>'
                                                +'<font face=\'calibri\' size=\'2\' color=\'#0000FF\'><b>'+pa.Type__c+' : </b></font>'
                                                +'</td>'
                                                +'</tr>'
                                                +'<tr>'
                                                +'<td>'
                                                +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Customer : </b></font><font face=\'calibri\' size=\'2\'>Yes</font>'
                                                +'</td>'
                                                +'<td>'
                                                +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Monthly Spend : </b></font><font face=\'calibri\' size=\'2\'>'+montSpend+'</font>'
                                                +'</td>'
                                                +'</tr>'
                                                +'<tr>'
                                                +'<td>'
                                                +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Payment Method : </b></font><font face=\'calibri\' size=\'2\'>'+payMethod+'</font>'
                                                +'</td>'
                                                +'</tr>';
                            }
                            
                            
                        }
                        
                        // Product Holding Change
                        
                        str_emailBody = str_emailBody +'<tr><td colspan=\'3\'><hr/></td></tr><tr><td><font face=\'calibri\' size=\'3\'>Appointment :</font>'+count+' <b>of </b> '+lstApp.size()+'</td></tr><tr><td colspan=\'4\'><hr/></td></tr>'
                            +'<tr><td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Visit Date :</b> </font><font face=\'calibri\' size=\'2\'>'+(apnt.Visit_Date__c).day()+'-'+(apnt.Visit_Date__c).month()+'-'+(apnt.Visit_Date__c).year()+'</font>'
                            +'</td>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Appointment Start Time : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.Start_Time__c+'</font>'
                            +'</td>'
                            +'</tr>'
                            +'<tr>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Subject : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.Subject__c+'</font>'
                            +'</td>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Status : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.Status__c+'</font>'
                            +'</td>'
                            +'</tr>'                                    
                            +'<tr>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Customer Name : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.Who__r.salutation + ' ' +apnt.Who__r.Name+'</font>'
                            +'</td>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Contact Tel : </b></font><font face=\'calibri\' size=\'2\'>';
                        String phone = '';
                       
                        if(apnt.Contact_Home_Phone__c != null){
                            phone = apnt.Contact_Home_Phone__c;
                        }if(apnt.Contact_Work_Phone__c != null){
                            if(phone == '')
                                phone = apnt.Contact_Work_Phone__c;
                            else
                                phone = phone+' / '+apnt.Contact_Work_Phone__c;
                        }if(apnt.Contact_Phone__c != null){
                            if(phone == '')
                                phone = apnt.Contact_Phone__c;
                            else
                                phone = phone+' / '+apnt.Contact_Phone__c;
                        }if(apnt.Contact_Mobile__c != null){
                            if(phone == '')
                                phone = apnt.Contact_Mobile__c;
                            else
                                phone = phone+' / '+apnt.Contact_Mobile__c;
                        }if(apnt.Contact_Best_Phone__c != null){
                            if(phone == '')
                                phone = apnt.Contact_Best_Phone__c;
                            else
                                phone = phone+' / '+apnt.Contact_Best_Phone__c;
                        }if(phone== ''){
                            phone = 'Not specified';
                        }
                        
                        if(apnt.opportunity__r.Account.Asbestos_found__c == 'Yes')
                        {
                            asbestosFound = 'Yes';
                            
                        }else if(apnt.opportunity__r.Account.Asbestos_found__c == 'No')
                        {
                            asbestosFound = 'No';
                        }else
                        {
                            asbestosFound = 'No Answer';
                        }
                         if(apnt.opportunity__r.Account.Asbestos_Found_Date_New__c != null)
                        {
                            asbestosFoundDate = '<td>'
                                                 +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Asbestos Found Date : </b> </font><font face=\'calibri\' size=\'2\'>'+apnt.opportunity__r.Account.Asbestos_Found_Date_New__c+'</font>'
                                                 +'</td>';
                            
                        }
                        
                        
                        str_emailBody = str_emailBody+phone+'</font></td></tr>'
                        +'<tr>'
                        +'<td >'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Customer Address  : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.opportunity__r.Account.BillingStreet+
                        ','+apnt.opportunity__r.Account.BillingCity+', '+
                        apnt.opportunity__r.Account.BillingState+', '+
                        apnt.opportunity__r.Account.BillingCountry+', '+
                        apnt.opportunity__r.Account.BillingPostalCode                       
                        +'</font>'
                        +'</td>';
                        if(system.label.PreCallSwitch == 'yes')
                        {
                        str_emailBody+='<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Pre-Call Made : </b> </font><font face=\'calibri\' size=\'2\'>'+apnt.HSAOfficePrecalled__c+'</font>'
                        +'</td>';
                        }
        str_emailBody+= '</tr>'
                        +'<tr>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Product of interest : </b> </font><font face=\'calibri\' size=\'2\'>'+apnt.Opportunity__r.Product_Interest__c+'</font>'
                            +'</td>';
                            if(system.label.PriorityInst == 'yes')
                            {
                            str_emailBody+='<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Customer Category : </b></font><font face=\'calibri\' size=\'2\'>'+custCategory+'</font>'
                            +'</td>';
                            }
           str_emailBody+='</tr>'
                        +'<tr>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Campaign media code : </b> </font><font face=\'calibri\' size=\'2\'>'+apnt.Opportunity__r.Campaign.Media_Cost_Code__c+'</font>'
                            +'</td>'
                            +'<td>'
                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Campaign description : </b> </font><font face=\'calibri\' size=\'2\'>'+apnt.Opportunity__r.Campaign.Description+'</font>'
                            +'</td>'
                        +'</tr>'
                        
                        +'<tr>'
                        +'<td colspan=\'3\'>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>TA Notes : </b></font><font face=\'calibri\' size=\'2\'>'+ta_Notes_All+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        +'<td colspan=\'3\'>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Lead Comments : </b></font><font face=\'calibri\' size=\'2\'>'+lead_comments+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Asbestos Found : </b></font><font face=\'calibri\' size=\'2\'>'+asbestosFound+'</font>'
                        +'</td>'+asbestosFoundDate;
                        if(system.label.GD_Switch == 'on')
                        {
                        str_emailBody+=+'<td>'
                             +'<font face=\'calibri\' size=\'2\' color=\'Green\'><b>Interested in Green Deal Cash Back : </b> </font><font face=\'calibri\' size=\'2\'>'+(apnt.opportunity__r.GDCashBack__c?'Yes':'')+'</font>'
                             +'</td>'
                        +'</tr>';
                        }
                        str_emailBody+=landlordDetails;
                        if(system.label.Free_Insulation_Switch == 'on')
			            {
			            	str_emailBody+='<tr>'
			                        	+'<td>'
			                        	+'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Free Insulation Eligible : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.opportunity__r.Free_Insulation_Eligible__c+'</font>'
			                        	+'</td>'
			                        	+'<tr>';
			            }
                        if(system.label.PDswitch == 'yes')
                        {
                        	
         str_emailBody+='<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Service Cover : </b></font><font face=\'calibri\' size=\'2\'>'+serviceCover+'</font>'
                        +'</td>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Customer : </b></font><font face=\'calibri\' size=\'2\'>'+curntCust+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        // ++ Commented the part for not sending CreditRatings to 7 day diary as per business request start
                        //+'<td>'
                        //+'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Credit Rating : </b></font><font face=\'calibri\' size=\'2\'>'+creditRating+'</font>'
                        //+'</td>'
                        // -- Commented the part for not sending CreditRatings to 7 day diary as per business request end
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Service Products : </b></font><font face=\'calibri\' size=\'2\'>'+serviceProduct+'</font>'
                        +'</td>'
                        +'</tr>'
                        +ProHoldingAccntString
                        +'<tr>'
                        +'</tr>';
                        }
                         
          str_emailBody+='<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#0000FF\'><b>Smart Meter Status : </b></font><font face=\'calibri\' size=\'2\'>'+smartEligible+'</font>'
                        +'</td>';
          // ++ Sending Appointment Type to HSA for Green Deal and Sales type start
          if(apnt.Type__c == 'Green Deal')
          {
          	BigMachines_Quote__c gdBm= chiBMMap.get(apnt.Opportunity__c);
          	string total = '';
          	string eco ='';
          	string nonEco = '';
          	if(gdBm!=null)
          	{
	          	total = string.valueof(gdBm.Quote_Net_Value__c);
	          	eco= string.valueof(gdBm.Green_Value__c);
	          	nonEco= string.valueof(gdBm.Non_ECO_Value__c);
          	}  	
            str_emailBody+='<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Type : </b></font><font face=\'calibri\' size=\'2\' color=\'#008000\'>'+apnt.Type__c+' Assessment'+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Total Quote Price: </b></font><font face=\'calibri\' size=\'2\'>'+total+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>GD Green Price : </b></font><font face=\'calibri\' size=\'2\' color=\'#008000\'>'+eco+'</font>'
                        +'</td>'
                        +'</tr>'
                        +'<tr>'
                        +'<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>GD Red Price : </b></font><font face=\'calibri\' size=\'2\' color=\'red\'>'+nonEco+'</font>'
                        +'</td>'
                        +'</tr>'
                        ;
          }
          else
          {
            str_emailBody+='<td>'
                        +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Type : </b></font><font face=\'calibri\' size=\'2\'>'+apnt.Type__c+'</font>'
                        +'</td>'
                        +'</tr>';
          }
          // -- Sending Appointment Type to HSA for Green Deal and Sales type end
                 
                        count++;                            
                    }
                
                    str_emailBody = str_emailBody + '</table>';
                    mail.setHtmlBody(str_emailBody); 
                    mails.add(mail);
            }
            try{
                Messaging.sendEmail(mails);                
            }catch(Exception e){
                
                //Code fix done by BGSAMS Support Team on 21/03/2012 for PRB00007119 - Starts
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); 
                String[] toAddresses1 = system.label.Exception_emails_for_batches.split(',');            
                mail1.setToAddresses(toAddresses1);
                mail1.setSubject('Exception ocurred in sending appointments email');
                mail1.setPlainTextBody('Exception ocurred in sending appointments email : ' + e.getMessage()+' Error in line number : '+ e.getLineNumber());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                //Code fix done by BGSAMS Support Team on 21/03/2012 for PRB00007119 - Ends
                System.debug('---EXC  ----   '+e.getMessage());
            }  
        }else{
            str = str+'No Appointments.';
        }       
    }

    global void finish(Database.BatchableContext BC){
       // Get the ID of the AsyncApexJob representing this batch job 
       // from Database.BatchableContext. 
       // Query the AsyncApexJob object to retrieve the current job's information.  
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Send app Result ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    // BEGIN - TEST METHODS
   /* Moved to seprate class : SendAppointment_Test
    @isTest
    public static void AppReport(){
        
        //Appointment__c insertApp = new Appointment__c();
        RecordType recType = [select id from recordtype where sObjectType ='Appointment__c' and Name='Appointment'];
        
        Account acc = new Account(name = 'test  account', BillingStreet='8 Merten', 
                                  BillingPostalCode='SW19 6DE', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        
        Database.insert(acc);
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        Contact contact = new Contact(AccountId=acc.Id,Best_Phone__c='2321738', LastName='updateContact Test');
        Database.insert(contact);
        
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'test extract flag lead', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Appointed', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);      
        Database.insert(opp);
        Employee__c emp = new Employee__c(Employee_Number__c='98750496',Name='Emp Name',primary_role__C = 'HSA',Is_app_email_ready__c=true,SalesForce_User__c = UserInfo.getUserId());
        Database.insert(emp);
        
        Datetime startdt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour(),00,00);
        Datetime enddt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour()+ 13,30,00);
        
        Appointment__c insertApp = new Appointment__c(Assigned_To__c= emp.id,RecordTypeId = recType.id,Who__c = contact.Id,
                                                Start__c = startdt, End__c = enddt,Subject__c = 'test appointment report',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',Type__c='Sales');
        Database.insert(insertApp);
        List<Appointment__c> lstapp= new List<Appointment__c>();
        lstapp.add(insertApp);
        Database.BatchableContext BC;
        Test.StartTest();
        SendAppointment Sendapp=new SendAppointment();       
        Sendapp.execute(BC,lstapp); 
        Test.StopTest();

    }*/
    
}