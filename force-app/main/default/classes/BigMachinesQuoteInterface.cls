global class BigMachinesQuoteInterface {
    
    ///
    //SFDC to Big Machines Interface: Class to send SFDC appointment data to Big Machines to generate quotes for appointments happening 
    //in the next two days. 
    /// 
    
    //Big Machines login credentials.
    //Endpoint URL set to 'http://testcentrica1.bigmachines.com/v1_0/receiver' to send data to the BM test environment
    //Use 'https://centrica.bigmachines.com/v1_0/receiver' URL to send data to the BM Production environment  
    /*
    public static final String URL = 'http'+((BigMachinesParameters.usesSSL) ? 's' : '')+'://'+BigMachinesParameters.bm_site+'.bigmachines.com/v1_0/receiver';
    public static final String username = EncodingUtil.base64Decode(BigMachinesParameters.username).toString();    
    public static final String password = EncodingUtil.base64Decode(BigMachinesParameters.password).toString();
     public static final String[] toAddresses1 = new String[] {'CHI-Salesforce.support@centrica.com','BGSAMS.Support@Centrica.com','phil.dennison@britishgas.co.uk'};
    ///
    //Query SFDC for appointments requiring to be sent to Big Machines. Put into batches of 4 apps at a
    //time and pass to future method to insert in BM. 
    ///                
    */
    public static void batchUpdateBigMachines(){
        /*
        try{
            
            List<ID> appsToSendToBigMachines = new List<ID>();
            datetime retrieveAppTimeLimit;
            datetime dateTimeNow = datetime.now();
            //If its after 4pm then query for appointments occuring 4 days in advance. Else, just today and tomorrow. 
            datetime timeToExtendQueryTo2DaysInAdvance = datetime.newInstance(dateTimeNow.year(), dateTimeNow.month(), dateTimeNow.day(), 16, 0, 0);  
            datetime timeTodayMorning = datetime.newInstance(dateTimeNow.year(), dateTimeNow.month(), dateTimeNow.day(), 0, 0, 1);

            //Fix for year end appointments starts here
            Integer lastDayOfTheYear;
            Integer startDayOfTheNextYear = 1;
            if(date.isLeapYear(timeTodayMorning.year()))
                lastDayOfTheYear = 366;
            else
                lastDayOfTheYear = 365;
                
            //Fix for year end appointments ends here 
            
            //chnaged on 29th feb 2012. To allow 4 days advance appointment                  
            integer offset = decimal.valueof(system.label.Cronkit_Offset).intValue();
            //Check if it is after 4pm
            if(datetime.now()>=timeToExtendQueryTo2DaysInAdvance){
                retrieveAppTimeLimit = datetime.newInstance(dateTimeNow.year(), dateTimeNow.month(), dateTimeNow.day(), 23, 59, 59);
                retrieveAppTimeLimit = retrieveAppTimeLimit.addDays(offset+1);
            }
            else{      
                retrieveAppTimeLimit = datetime.newInstance(dateTimeNow.year(), dateTimeNow.month(), dateTimeNow.day(), 23, 59, 59);
                retrieveAppTimeLimit = retrieveAppTimeLimit.addDays(offset);
            }
            //Query to see how many appointments in SFDC need sending to Big Machines, used in result parameter in CronKit dislay
            // Made fix for CHI IV so that we should not consider installation type of appointments
            //Fix for year end appointments starts here 
            //integer s1 =  timeTodayMorning.dayOfYear();
            //integer s2 = retrieveAppTimeLimit.dayOfYear();
            //Integer countOfApps = [Select count() From Appointment__c a where status__c='Appointed' AND RecordType.Name != 'Installation' AND Type__c = 'Sales' AND a.Assigned_To__r.UsesBM__c=true AND Visit_Day_Of_Year__c<=:s2 AND Visit_Day_Of_Year__c >=:s1 AND Start__c<:retrieveAppTimeLimit AND Start__c>:timeTodayMorning AND SentToBM__c=false AND LoadedInBM__c=false limit 500];            
            
            String queryCount = 'Select count() From Appointment__c a where status__c=\'Appointed\' AND RecordType.Name != \'Installation\' AND Type__c = \'Sales\' AND a.Assigned_To__r.UsesBM__c=true AND Start__c<:retrieveAppTimeLimit AND Start__c>:timeTodayMorning AND SentToBM__c=false AND LoadedInBM__c=false ';
            String query = 'Select Name,Start__c,Opportunity__r.SMStatus__c,Opportunity__r.SMStatUpdByBGMO__c,Visit_Date__c, ID From Appointment__c a where status__c=\'Appointed\' AND RecordType.Name != \'Installation\' AND Type__c = \'Sales\' AND a.Assigned_To__r.UsesBM__c=true AND Start__c<:retrieveAppTimeLimit AND Start__c>:timeTodayMorning AND SentToBM__c=false AND LoadedInBM__c=false ';
            Integer startDayOfTheAppointment = timeTodayMorning.dayofyear();
            Integer endDayOfTheAppointment = retrieveAppTimeLimit.dayofyear();
            //if within the same year
            if (startDayOfTheAppointment <= endDayOfTheAppointment)
            {
                query+= ' AND Visit_Day_Of_Year__c<=:endDayOfTheAppointment AND Visit_Day_Of_Year__c >=:startDayOfTheAppointment Order By a.Start__c limit 40';
                queryCount+= ' AND Visit_Day_Of_Year__c<=:endDayOfTheAppointment AND Visit_Day_Of_Year__c >=:startDayOfTheAppointment LIMIT 500';
            }
            //else end day of the appointment falls on the next year
            else
            {
                Integer lastDayOfTheNextYear = offset - (lastDayOfTheYear - startDayOfTheAppointment);
                query+= ' AND ((Visit_Day_Of_Year__c>=:startDayOfTheAppointment AND Visit_Day_Of_Year__c<=:lastDayOfTheYear) OR (Visit_Day_Of_Year__c>=:startDayOfTheNextYear AND Visit_Day_Of_Year__c<=:lastDayOfTheNextYear)) Order By a.Start__c limit 40';
                queryCount+= ' AND ((Visit_Day_Of_Year__c>=:startDayOfTheAppointment AND Visit_Day_Of_Year__c<=:lastDayOfTheYear) OR (Visit_Day_Of_Year__c>=:startDayOfTheNextYear AND Visit_Day_Of_Year__c<=:lastDayOfTheNextYear)) LIMIT 500';
            }
            
            Integer countOfApps = Database.countQuery(queryCount);      
            //Fix for year end appointments ends here 
            
            list<string> smartCriteria = system.label.SmartMeterDayLabel.split(',');
            map<string, integer> smartCriteriaMap = new map<string, integer>();
            
            for(String s: smartCriteria)
            {
              string [] temp = s.split(':');
              if(temp.size()>0 && !smartCriteriaMap.containskey(temp[0]))
              {
                smartCriteriaMap.put(temp[0],integer.valueof(temp[1]));
              }
            }
            system.debug('smartCriteriaMap-->'+smartCriteriaMap);
            //Query SFDC for appropriate appointments. Most the batch can process is 40 due to govenor limits on the number of future calls and http callouts
            // Made fix for CHI IV so that we should not consider installation type of appointments
            
            //Fix for year end appointments starts here 
            //List<Appointment__c> apps = new List<Appointment__c>([Select Name,Start__c,Opportunity__r.SMStatus__c,Opportunity__r.SMStatUpdByBGMO__c,Visit_Date__c, ID From Appointment__c a where status__c='Appointed' AND RecordType.Name != 'Installation' AND Type__c = 'Sales' AND a.Assigned_To__r.UsesBM__c=true AND Visit_Day_Of_Year__c<=:s2 AND Visit_Day_Of_Year__c >=:s1 AND Start__c<:retrieveAppTimeLimit AND Start__c>:timeTodayMorning AND SentToBM__c=false AND LoadedInBM__c=false Order By a.Start__c limit 40]);
            List<Appointment__c> apps = new List<Appointment__c>();
            apps = Database.query(query);
            //Fix for year end appointments ends here 
            
            set<Appointment__c> refinedApps = new set<Appointment__c> ();   
            datetime secondStartTime;
            if(apps.size()>0){
                //Set sentToBM to true so future queries will not retrieve the same apps to send to BM. As batch is run every 15mins. If Apex future jobs have not completed by 15mins then LoadedInBM will stil be false and next run could return the same records.
                for(Appointment__c app : apps) {
                    //system.debug('------');
                  system.debug('-----'+smartCriteriaMap.ContainsKey(app.Opportunity__r.SMStatus__c)+ ' '+math.ABS(system.today().daysBetween(app.Visit_Date__c))+app);
                  
                  if(app.Opportunity__r.SMStatUpdByBGMO__c == false && smartCriteriaMap.ContainsKey(app.Opportunity__r.SMStatus__c) && math.ABS(system.today().daysBetween(app.Visit_Date__c)) > smartCriteriaMap.get(app.Opportunity__r.SMStatus__c))
                  {
                        continue;
                  }
                  app.SentToBM__c=true;  
                  secondStartTime = app.Start__c;
                  //Fix for year end appointments starts here 
                  //s1 =  secondStartTime.dayOfYear();
                  startDayOfTheAppointment  = secondStartTime.dayOfYear();
                  //Fix for year end appointments ends here 
                  refinedApps.add(app);      
                  
                }
                /*
                  This change was implemented to prevent "bottle neck" problem that was created as a part of smart meter status. 
                  This batch will try to send next recent appointments, so as a result of which if the next 40+ appointments didnt had any SM status
                  all the other appointments were also held back till recent 40 are sent to BM. 
                  This change will now first check how many appointments are eligible to go in first query then if its less than 40 then it will try
                  fetch next remaining amount of appointments which are eligible to go.  
                */
                /*
                if(system.label.appbatch == 'on')
                {
                  integer nextlimit = 0;
                  nextlimit = (apps.size()==40 && refinedApps.size()<40)? 40-refinedApps.size(): 0;
                  
                    
                  if(nextlimit>0)
                  {
                       //Fix for year end appointments starts here 
                       String appsQuery = 'Select Name,Opportunity__r.SMStatus__c,Opportunity__r.SMStatUpdByBGMO__c,Visit_Date__c, ID From Appointment__c a where status__c=\'Appointed\' AND RecordType.Name != \'Installation\' AND a.Assigned_To__r.UsesBM__c=true AND Start__c>:secondStartTime AND SentToBM__c=false AND LoadedInBM__c=false AND Opportunity__r.SMStatUpdByBGMO__c= true ';
                       if (startDayOfTheAppointment <= endDayOfTheAppointment)
                            appsQuery+= ' AND Visit_Day_Of_Year__c<=:endDayOfTheAppointment AND Visit_Day_Of_Year__c >=:startDayOfTheAppointment Order By a.Start__c limit :nextlimit';
                       else
                       {
                            Integer lastDayOfTheNextYear = offset - (lastDayOfTheYear - startDayOfTheAppointment);
                            appsQuery+= ' AND ((Visit_Day_Of_Year__c>=:startDayOfTheAppointment AND Visit_Day_Of_Year__c<=:lastDayOfTheYear) OR (Visit_Day_Of_Year__c>=:startDayOfTheNextYear AND Visit_Day_Of_Year__c<=:lastDayOfTheNextYear)) Order By a.Start__c limit :nextlimit';
                       }
                       //apps = new List<Appointment__c>([Select Name,Opportunity__r.SMStatus__c,Opportunity__r.SMStatUpdByBGMO__c,Visit_Date__c, ID From Appointment__c a where status__c='Appointed' AND RecordType.Name != 'Installation' AND a.Assigned_To__r.UsesBM__c=true AND Visit_Day_Of_Year__c<=:s2 AND Visit_Day_Of_Year__c >=:s1  AND Start__c>:secondStartTime AND SentToBM__c=false AND LoadedInBM__c=false AND Opportunity__r.SMStatUpdByBGMO__c= true Order By a.Start__c limit :nextlimit]);
                       apps = new List<Appointment__c>();
                       apps = Database.query(appsQuery);
                       //Fix for year end appointments ends here 
                  }
                  
                  for(Appointment__c app : apps) {
                        //system.debug('------');
                    app.SentToBM__c=true;    
                    refinedApps.add(app);      
                  }
                }
                apps = new List<Appointment__c>();
                apps.addall(refinedApps);
                update(apps);
                
                for(Appointment__c app : apps) {
                    appsToSendToBigMachines.add(app.ID);            
                }       
                                        
                Integer numberOfAppsRetrieved = appsToSendToBigMachines.size();
                //Due to SFDC callout limit = 10 per transaction each future call can process 4 appointments only.          
                Integer batchSizeLimit = 4;
                //SFDC allows ten future calls max per trigger, so ten batches maximum can be initialised 
                Integer numberOfBatchesLimit = 10;
                boolean allAppsAddedToBatch = false;
                
                integer countOfAppsAddedToBatches = 0;
                List<ID> appsBatch = new List<ID>();    
                system.debug('appsToSendToBigMachines.size() is: '+appsToSendToBigMachines.size());
                //Split all returned appointments into batches containing 4 appointments maximum
                for(integer y=0; y<numberOfBatchesLimit; y++)
                {
                    appsBatch.clear();                  
                    for(integer z=0; z<batchSizeLimit; z++)
                    {                                   
                       if(countOfAppsAddedToBatches<numberOfAppsRetrieved)
                            appsBatch.add(appsToSendToBigMachines[countOfAppsAddedToBatches]);
                        else{
                            allAppsAddedToBatch = true;
                            break;
                        }                  
                        countOfAppsAddedToBatches++;
                    }
                    system.debug('appsBatch size is: '+appsBatch);
                    if(appsBatch.size()>0)                      
                        updateBigMachinesFuture(appsBatch);
                    if(allAppsAddedToBatch)
                        break;                                                                                              
                }                                                                            
            }
            //create a results string informing which apps have been sent by app name
            String appsSent='';
            for(integer g=0;g<apps.size();g++) {
                    appsSent=appsSent+' '+apps[g].Name;         
                }
            //return values to cronkit for error and result variables.          
            List<String> result = new List<String>{};       
            result.add('false');                
            result.add('Found: '+String.ValueOf(countOfApps)+', Sent: '+apps.size()+' '+appsSent);                              
            return result;
        }       
        catch(Exception e){
            System.debug('An exception occured: '+e);           
            List<String> result = new List<String>{};       
            result.add('true');
            result.add('Error:Exception Thrown');                  
                        
            // For Testing Only. Send an email to the SFDC admin to notify of failure.  
            CreateEmail.CretaeSendTextEmail(toAddresses1,e.getMessage(),'BM: Caught Exception: Apex Exception occurred in the SFDC to Big Machines Batch Interface');
            return result;          
        }      
        */
    }
    
    ///
    //Used by the 'Send To BM' custom button on the appointment record to manually send one-off apps to Big Machines
    /// 
    /*
    webservice static void sendToBMCustomButton(ID[] appointmentID){
    /*
        //Set sentToBM to true so cronKit will not retrieve the same app to send to BM. As batch is run every 15mins it could pick this app up before the Apex future job has completed and set loadedInBM to true for this app.            
        Appointment__c app = [Select SentToBM__c From Appointment__c a where Id=:appointmentID[0]];                                 
        app.SentToBM__c=true;                   
        update(app);
        
        //send app to BM in an asynchronous future call
        System.debug('SFDC AppointmentID is: ' + appointmentID);
        updateBigMachinesFuture(appointmentID); 
        
    }
    */
    
    ///
    //Calls the updateBigMachines method as an asynchronous Apex Future job
    /// 
    /*
    @future (callout=true)
    webservice static void updateBigMachinesFuture(ID[] appointmentID){
        /*
        updateBigMachines(appointmentID); 
        
    }
    */
    ///
    //Inserts a quote in BigMachines for each appointment contained in the list passed in
    ///   
    /*
    public static void updateBigMachines(ID[] appointmentID){
    /*
        System.debug('SFDC entered updateBigMachines method');
                
        Map<ID, String> appProcessed = new Map<ID, String>();
        Map<ID, String> quoteNumberArray = new Map<ID, String>();
        Map<ID, String> appNotProcessed = new Map<ID, String>();
        
        //initialise a list to determine later whether an appoinment has successfully created a quote or not.       
        for(integer b=0;b<appointmentID.size();b++){
            appProcessed.Put(appointmentID[b],'failure');
        } 
                            
        //Query to retrieve all appointments contained in the list
        Appointment__c[] allAppointments = getAppointment(appointmentID);
        
        Map<ID, Appointment__c> allAppointmentsMap = new Map<ID, Appointment__c>();     
        for(Appointment__c app:allAppointments)
            allAppointmentsMap.put(app.Id, app);    
                                    
        try{                            
            String errorMessage;                            
            
            //Login to Big Machines
            HttpRequest loginRequest = login();             
            HttpResponse loginResponse = sendHttpRequest(loginRequest); 
            
            //Check a http response was received successfully for login request
            if(loginResponse.getStatusCode() != 200)
                throw new MyException('Error: Failed to create/update a Big Machines quote for Appointment with ID '+appointmentID+'. The Big Machines Login request did not receive a successfull http response code of 200. The response received was: '+loginResponse.toString());                                               
            else{                                                                   
                //check login was reported back as successful by Big Machines
                if(readXML(loginResponse, 'success')!='true')
                    throw new MyException('Error: Failed to create/update a Big Machines quote for a new Appointment with ID '+appointmentID+'. The Big Machines Login request was not successful. The fault string reported from Big Machines was: "'+readXML(loginResponse, 'faultstring')+'"');                                                                                                  
                else{
                    //Obtain a Big Machines session ID              
                    String sessionId = readXML(loginResponse, 'sessionId');                                                 
                    system.debug('Seesion Id--->'+sessionId);
                    //For each appointment in the list provided create a quote in BM
                    for(integer x=0;x<appointmentID.size();x++){                        
                                                
                        //Create Quote request                              
                        HttpRequest createRequest = createQuote(sessionId);                                                                    
                        HttpResponse createResponse = sendHttpRequest(createRequest);                          
                                      
                        //Check a response was received successfully to create request
                        if(createResponse.getStatusCode() != 200)
                            throw new MyException('Error: Failed to create a Big Machines quote for a new Appointment with ID '+appointmentID+'. The create request did not receive a successfully http response code of 200. The response received was: '+createResponse.toString());                                                                          
                        else{                                           
                            //check create was reported back by BM as successfully created 
                            if(readXML(createResponse, 'success')!='true')                                                  
                                throw new MyException('Error: Failed to create a Big Machines quote for a new Appointment with ID '+appointmentID+'. The fault string reported from Big Machines was: "'+readXML(createResponse, 'faultstring')+'"');                                                                                                   
                            else{
                                //Obtain the unique Quote transaction ID and quote number for the quote created from the Big Machines response
                                String quoteID = readXML(createResponse, 'id'); 
                                String quoteNumber = readXML(createResponse, 'quoteNumber_quote');  
                                
                                //return from Map the required appointment details                                          
                                Appointment__c appointment = allAppointmentsMap.get(appointmentID[x]);
                                
                                //Query to obtain Salesforce CHI LEAD and Account data to send to Big Machines
                                Opportunity appointmentOpp = getCHILead(appointment.Opportunity__c);
                                List<String> associatedAppointments = getAssociatedApps(appointment.Opportunity__c, appointment.Start__c);
                                String previousAppointments = associatedAppointments[0];
                                String jointVisitAttendees = associatedAppointments[1];
                                Account appointmentAccount = getAccount(appointmentOpp.AccountId);
                                list<ProductHoldingAccount__c> prdAccs = new list<ProductHoldingAccount__c>();
                                if(appointmentAccount.ProductHoldings__r.size()>0)
                                prdAccs = getPrdAccs(appointmentAccount.ProductHoldings__r[0].Id);
                                String XMLUpdateMsg = createFullUpdateXMLString(previousAppointments,appointment,appointmentOpp,appointmentAccount,jointVisitAttendees,prdAccs);
                                system.debug('******____'+XMLUpdateMsg );                                
                                //Send an update SOAP call to BM with the SFDC data                 
                                HttpRequest updateRequest = updateQuote(sessionId,quoteID,XMLUpdateMsg,'save_quote');                                                                  
                                HttpResponse updateResponse = sendHttpRequest(updateRequest);                               
                                system.debug('request--->'+updateRequest); 
                                system.debug('Response--->'+updateResponse); 
                                //Check a response was received successfully to the update request
                                if(updateResponse.getStatusCode() != 200)
                                        throw new MyException('Error: Failed to copy updates from Appointment with ID '+appointmentID[x]+' to Big Machines quote number '+quoteNumber+' with transaction ID '+quoteID+'. The update request did not receive a successful http response code of 200. The response received was: '+updateResponse.toString());                                                                            
                                else{ 
                                    //check the update response Big Machines says update was successful 
                                    if(readXML(updateResponse, 'success')=='true'){                                                                             
                                        appProcessed.put(appointmentID[x],quoteID);     
                                        quoteNumberArray.put(appointmentID[x],quoteNumber); 
                                    }                       
                                    else{
                                        string faultmsg = readXML(updateResponse, 'faultstring');
                                        appNotProcessed.put(appointmentID[x],faultmsg);                                                                                                                 
                                    }                                                                                                                                                                                       
                                }                               
                            }
                        }           
                    }                                                               
                }       
            }
        }
        catch(MyException e){           
            system.debug('An error was encountered: '+e);
                                
            // Send an email to the SFDC admin to notify of failure. 
            CreateEmail.CretaeSendTextEmail(toAddresses1,e.getMessage(),'BM: Caught Exception: Apex Exception occurred in the SFDC to Big Machines Batch Interface');   
                    
        }
        catch(Exception e){
            system.debug('An Exception was thrown: '+e);
                    
            // Send an email to the SFDC admin to notify of failure.  
            CreateEmail.CretaeSendTextEmail(toAddresses1,e.getMessage(),'BM: Caught Exception: Apex Exception occurred in the SFDC to Big Machines Batch Interface');  
           
        }
        finally{
            //Cycle through the appProcessed list and update successfully processed apps with the BM quote ID
            //if it failed then untick sent to BM field so record gets picked up by next batch run
            for(integer x=0;x<allAppointments.size();x++){                                                                      
                if(appProcessed.get(allAppointments[x].Id)!='failure'){
                    allAppointments[x].Big_Machines_Quote_ID__c = appProcessed.get(allAppointments[x].Id);
                    allAppointments[x].Big_Machines_Quote_Number__c = quoteNumberArray.get(allAppointments[x].Id);
                    allAppointments[x].LoadedInBM__c=true;
                }   
                else
                    allAppointments[x].SentToBM__c=false;   
            }                                           
            update(allAppointments);  
            
            // Send an email to the SFDC admin to notify of any failures.   
            if(!appNotProcessed.isEmpty()){
                List<ID> ids = new List<ID>(appNotProcessed.keySet());
                String errorString ='';             
                for(integer x=0;x<ids.size();x++){                      
                    errorString += 'Appointment '+ids[x]+' received the following fault string from Big Machines "'+appNotProcessed.get(ids[x])+'". ';
                }
                CreateEmail.CretaeSendTextEmail(toAddresses1,errorString,'BM: Caught Exception: Apex Exception occurred in the SFDC to Big Machines Batch Interface');                                                                                                
                
            }                                                       
        }
        
    }                                      
     */     
    
    ///
    //Cancel appointment in BigMachines. Used by SFDC trigger on appointment
    //when app cancelled in SFDC attempt to update Big Machines quote to cancelled
    //else if call fails(as quote could be checked out) send a textmail to the employee 
    /// 
    /*
    @future (callout=true)  
    public static void updateBigMachinesWhenCancelled(ID[] appointmentID){
         /*           
        //Query to retrieve appointment contained in the list. Contains only one as trigger can only act on one app cancellation due to governor limits
        Appointment__c[] appointments = getAppointment(appointmentID); 
        Appointment__c appointment = appointments[0];          
        Date appDate = date.newInstance(appointment.start__c.year(), appointment.start__c.month(), appointment.start__c.day());
        
        try{                                
            appointment.Quote_Cancellation_Details__c = 'Starting Big Machines Quote Cancellation Process. ';                                       
            String errorMessage;                            
            
            //Login to Big Machines
            HttpRequest loginRequest = login();             
            HttpResponse loginResponse = sendHttpRequest(loginRequest); 
            
            //Check a http response was received successfully for login request
            if(loginResponse.getStatusCode() != 200)
                throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The Big Machines Login request did not receive a successfull http response code of 200. The response received was: '+loginResponse.toString());                                               
            else{                                                                   
                //check login was reported back as successful by Big Machines
                if(readXML(loginResponse, 'success')!='true')
                    throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The Big Machines Login request was not successful. The fault string reported from Big Machines was: "'+readXML(loginResponse, 'faultstring')+'"');                                                                                                    
                else{
                    //Obtain a Big Machines session ID              
                    String sessionId = readXML(loginResponse, 'sessionId');                                                 
                                                                                                                            
                    //Obtain the unique Quote reference ID for the quote created from the Big Machines response
                    String quoteID = appointment.Big_Machines_Quote_ID__c;                                      
                                    
                    String XMLCancelMsg = createCancelXMLString();
                                
                    //Send an update SOAP call to BM with the SFDC data                 
                    HttpRequest updateRequest = updateQuote(sessionId,quoteID,XMLCancelMsg,'sFDCCustomerCancellation');                                                                    
                    HttpResponse updateResponse = sendHttpRequest(updateRequest);
                                                                         
                    //Check a response was received successfully to the update request
                    if(updateResponse.getStatusCode() != 200)
                            throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The update request did not receive a successfully http response code of 200. The response received was: '+updateResponse.toString());                                                                         
                    else{ 
                        appointment.Quote_Cancellation_Details__c = 'Big Machines Quote Cancellation Successful.';  
                       //If update failed or its an in-day cancellation tag appointment so workflow sends textmail to BM employee/hsa to notify of cancellation
                      //   if(readXML(updateResponse, 'success')!='true' || appDate==date.today())                           
                     // This if condition is added as part of new call scripts project where we cancel all the appointments when we close the CHI lead.   
                            
                            if(appDate>=date.today()){   
                                                      
                            appointment.notify_employee_of_app_cancellation__c=true;                            
                            
                            }                            
                    } 
                }      
            }
        }
        catch(MyException e){           
            system.debug('An error was encountered: '+e);
            //As exception ocurred ensure employee is inform of app cancellation by text, workflow sends textmail                               
            if(appDate>=date.today()){                              
            appointment.notify_employee_of_app_cancellation__c=true;                                    
            appointment.Quote_Cancellation_Details__c = 'Error in cancelling Big Machines Quote.';                                      
        }
        }
        catch(Exception e){
            system.debug('An error was encountered: '+e);
            //As exception ocurred ensure employee is inform of app cancellation by text, workflow sends textmail                               
            if(appDate>=date.today()){                               
            appointment.notify_employee_of_app_cancellation__c=true;                
            appointment.Quote_Cancellation_Details__c = 'Error in cancelling Big Machines Quote.';              
            }           
            
            //Semd an email to notify of failure.
            CreateEmail.CretaeSendTextEmail(toAddresses1,e.getMessage(),'BM: Caught Exception: Apex Exception in SFDC to Big Machines trigger to cancel quote has occured');   
                
        }    
        finally{
                update appointment;
        }   
        
    }    
    */
              
    
    ///
    //Called by trigger on appointment history object insert. If an appointment history of type 'Appointment Reassignment' is inserted
    //then we are required to cancel the Big Machines (BM) quote associated with the appointment and the previous appointment owner. We must then
    //create a new Big Machines quote for the new appointment owner. If the call to cancel the original quote fails we flag the appointment 
    //and a textmail will be sent to the employees (old owner) to inform them of the cancellation. If the call to create a new quote for the new employee 
    //fails we untick the 'SentToBM__c' and 'LoadedInBM' fields on the appointment so that it gets re-attempted by the 15m batch interface to load apps into BM.
    /// 
    /*
    @future (callout=true)  
    public static void updateBigMachinesWhenAppReassigned(ID[] appointmentID, String oldTextMail){
        /*
                    
        //Query to retrieve appointment contained in the list. Contains only one as trigger can only act on one app cancellation due to governor limits
        Appointment__c[] appointments = getAppointment(appointmentID); 
        Appointment__c appointment = appointments[0];          
        
        try{                                
            String errorMessage;
            String sessionId;                       
            
            //Login to Big Machines
            HttpRequest loginRequest = login();             
            HttpResponse loginResponse = sendHttpRequest(loginRequest); 
            appointment.Quote_Cancellation_Details__c = 'Starting Big Machines Quote Cancellation Process (Reassignment).';                                         
                        
            //Check a http response was received successfully for login request
            if(loginResponse.getStatusCode() != 200)
                throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The Big Machines Login request did not receive a successfull http response code of 200. The response received was: '+loginResponse.toString());                                               
            else{                                                                   
                //check login was reported back as successful by Big Machines
                if(readXML(loginResponse, 'success')!='true')
                    throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The Big Machines Login request was not successful. The fault string reported from Big Machines was: "'+readXML(loginResponse, 'faultstring')+'"');                                                                                                    
                else{
                    //Obtain a Big Machines session ID              
                    sessionId = readXML(loginResponse, 'sessionId');                                                    
                                                                                                                            
                    //Obtain the unique Quote reference ID for the quote created from the Big Machines response
                    String quoteID = appointment.Big_Machines_Quote_ID__c;                                      
                                    
                    String XMLCancelMsg = createCancelXMLString();
                                
                    //Send an update SOAP call to BM with the SFDC data                 
                    HttpRequest updateRequest = updateQuote(sessionId,quoteID,XMLCancelMsg,'sFDCCustomerCancellation');                                                                    
                    HttpResponse updateResponse = sendHttpRequest(updateRequest);
                          
                    //Check a response was received successfully to the update request
                    if(updateResponse.getStatusCode() != 200)
                            throw new MyException('Error: Failed to update the Big Machines quote number '+appointment.Big_Machines_Quote_ID__c+' to cancelled for the newly cancelled Appointment with ID '+appointmentID+'. The update request did not receive a successfully http response code of 200. The response received was: '+updateResponse.toString());                                                                         
                    else{ 
                        appointment.Quote_Cancellation_Details__c = 'Big Machines Quote Cancellation Successful.(Reassignment)';    
                       //If update failed or its an in-day cancellation tag appointment so workflow sends textmail to BM employee/hsa to notify of cancellation
                      // date appDate = date.newInstance(appointment.start__c.year(), appointment.start__c.month(), appointment.start__c.day());
                     // if(readXML(updateResponse, 'success')!='true' || appDate==date.today())                                                 
                                appointment.notify_old_owner_of_cancellation__c=true;
                                appointment.PreviousAppOwnerTextMailAddress__c=oldTextMail;                         
                            }
                    } 
                            
                    //Create Quote request                              
                    HttpRequest createRequest = createQuote(sessionId);                                                                    
                    HttpResponse createResponse = sendHttpRequest(createRequest);                          
                   
                    //Check a response was received successfully to create request
                    if(createResponse.getStatusCode() != 200)
                        throw new My2Exception('Error: Failed to create a Big Machines quote for a reassigned Appointment with ID '+appointment.Big_Machines_Quote_ID__c+'. The create request did not receive a successfully http response code of 200. The response received was: '+createResponse.toString());                                                                           
                    else{                                           
                        //check create was reported back by BM as successfully created 
                        if(readXML(createResponse, 'success')!='true')                                                  
                                throw new My2Exception('Error: Failed to create a Big Machines quote for a reassigned Appointment with ID '+appointment.Big_Machines_Quote_ID__c+'. The fault string reported from Big Machines was: "'+readXML(createResponse, 'faultstring')+'"');                                                                                                    
                        else{
                            //Obtain the unique Quote transaction ID and quote number for the quote created from the Big Machines response
                            String quoteID = readXML(createResponse, 'id'); 
                            String quoteNumber = readXML(createResponse, 'quoteNumber_quote');  
                                                                                
                            //Query to obtain Salesforce CHI LEAD and Account data to send to Big Machines
                            Opportunity appointmentOpp = getCHILead(appointment.Opportunity__c);
                            List<String> associatedAppointments = getAssociatedApps(appointment.Opportunity__c, appointment.Start__c);
                            String previousAppointments = associatedAppointments[0];
                            String jointVisitAttendees = associatedAppointments[1];
                            Account appointmentAccount = getAccount(appointmentOpp.AccountId);
                            list<ProductHoldingAccount__c> prdAccs = new list<ProductHoldingAccount__c> ();
                            if(appointmentAccount.ProductHoldings__r.size()>0)
                            prdAccs = getPrdAccs(appointmentAccount.ProductHoldings__r[0].Id);
                            String XMLUpdateMsg = createFullUpdateXMLString(previousAppointments,appointment,appointmentOpp,appointmentAccount,jointVisitAttendees,prdAccs);                                                        
                             
                            //Send an update SOAP call to BM with the SFDC data                 
                            HttpRequest updateRequest = updateQuote(sessionId,quoteID,XMLUpdateMsg,'save_quote');                                                                  
                            HttpResponse updateResponse = sendHttpRequest(updateRequest); 
                             
                            //Check a response was received successfully to the update request
                            if(updateResponse.getStatusCode() != 200)
                                    throw new My2Exception('Error: Failed to copy updates from Appointment with ID '+appointment.Big_Machines_Quote_ID__c+' to Big Machines quote number '+quoteNumber+' with transaction ID '+quoteID+'. The update request did not receive a successful http response code of 200. The response received was: '+updateResponse.toString());                                                                           
                            else{ 
                                //check the update response Big Machines says update was successful 
                                if(readXML(updateResponse, 'success')=='true'){                                                 
                                    appointment.Big_Machines_Quote_ID__c = quoteID;
                                    appointment.Big_Machines_Quote_Number__c = quoteNumber;                                                                  
                                }
                                else                                                                                                                                                      
                                    throw new My2Exception('Error: Failed to copy updates from Appointment with ID '+appointment.Big_Machines_Quote_ID__c+' to Big Machines quote number '+quoteNumber+' with transaction ID '+quoteID+'. The update request did not receive a successful response from Big Machines. The response received was: '+updateResponse.toString());                                                                                                                                                                                                                                                                                                                            
                            }
                        }
                    }           
            }
        }       
        catch(MyException e){           
            system.debug('An error was encountered: '+e);
            //As exception ocurred ensure employee is informed of app cancellation by text, workflow sends textmail                                                     
            appointment.notify_old_owner_of_cancellation__c=true;
            appointment.PreviousAppOwnerTextMailAddress__c=oldTextMail; 
            //As exception occured ensure batch process loads the new appointment in BM                         
            appointment.LoadedInBM__c=False;
            appointment.SentToBM__c=False;                                  
            appointment.Quote_Cancellation_Details__c = 'Error in cancelling Big Machines Quote.(Reassignment)';                                        
        }
        catch(My2Exception e){          
            system.debug('An error was encountered: '+e); 
            //If here then cancellation update message completed successfully so do not need to text employee
            //As exception occured ensure batch process loads the new appointment in BM                                                                                             
            appointment.LoadedInBM__c=False;
            appointment.SentToBM__c=False;                                  
        }       
        catch(Exception e){
            system.debug('An error was encountered: '+e);                               
            //As exception ocurred ensure employee is informed of app cancellation by text, workflow sends textmail                                                                 
            appointment.notify_old_owner_of_cancellation__c=true;
            appointment.PreviousAppOwnerTextMailAddress__c=oldTextMail;                         
            //As exception occured ensure batch process loads the new appointment in BM                                     
            appointment.LoadedInBM__c=False;
            appointment.SentToBM__c=False;              
            appointment.Quote_Cancellation_Details__c = 'Error in cancelling Big Machines Quote.(Reassignment)';    
            //Send an email to notify of failure.   
            CreateEmail.CretaeSendTextEmail(toAddresses1,e.getMessage(),'BM: Caught Exception: Apex Exception in SFDC to Big Machines interface');
             
        }    
        finally{
            update appointment;
        }   
        
    } 
    */
                
    ///
    //Login to Big Machines
    /// 
    public static void login(){                                               
                /*
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest loginRequest = new HttpRequest();
        loginRequest.setEndpoint(URL);
        loginRequest.setMethod('GET');
        loginRequest.setTimeout(60000);
        
        //create login XML
        loginRequest.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                             '<soapenv:Header>'+
                              '<bm:category xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">Security</bm:category>'+
                              '<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">'+
                               '<bm:schemaLocation>http://centrica.bigmachines.com/bmfsweb/centrica/schema/v1_0/security/Security.xsd</bm:schemaLocation>'+
                              '</bm:xsdInfo>'+
                             '</soapenv:Header>'+
                             '<soapenv:Body>'+
                              '<bm:login xmlns:bm="urn:soap.bigmachines.com">'+
                               '<bm:userInfo>'+
                                '<bm:username>'+username+'</bm:username>'+
                                '<bm:password>'+password+'</bm:password>'+
                               '</bm:userInfo>'+
                              '</bm:login>'+
                             '</soapenv:Body>'+
                            '</soapenv:Envelope>');
                            
        System.debug('loginRequest: ' + loginRequest.getBody());                          
        return loginRequest;    
        */
    }
    
    
    ///
    //Create httpRequest that will create a new quote in BM
    ///            
    public static void createQuote(String sessionID){         
        /*
                    
        HttpRequest createRequest = new HttpRequest();
        createRequest.setEndpoint(URL);
        createRequest.setMethod('GET');
        createRequest.setTimeout(60000);
        createRequest.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                                 '<soapenv:Header>'+
                                  '<bm:userInfo xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">'+
                                   '<bm:sessionId>'+sessionID+'</bm:sessionId>'+
                                  '</bm:userInfo>'+
                                  '<bm:category xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">Commerce</bm:category>'+
                                  '<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">'+
                                   '<bm:schemaLocation>http://centrica.bigmachines.com/bmfsweb/centrica/schema/v1_0/commerce/quotes_process_bmClone_43.xsd</bm:schemaLocation>'+
                                  '</bm:xsdInfo>'+
                                 '</soapenv:Header>'+
                                 '<soapenv:Body>'+
                                  '<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com">'+
                                   '<bm:transaction>'+
                                    '<bm:process_var_name>quotes_process_bmClone_43</bm:process_var_name>'+
                                   '</bm:transaction>'+
                                  '</bm:createTransaction>'+
                                 '</soapenv:Body>'+
                                '</soapenv:Envelope>');
        
       System.debug('createRequest: ' + createRequest.getBody());
       return createRequest; 
       */
    }
            
    
    ///
    //Create httpRequest that will update a quote in BM with SFDC values and perform save
    ///
    public static void updateQuote(String sessionID, String quoteId, String XMLUpdateMsg, String BMAction){              
        /*                                                                
        HttpRequest updateRequest = new HttpRequest();
        updateRequest.setEndpoint(URL);
        updateRequest.setMethod('GET');
        updateRequest.setTimeout(60000);
        updateRequest.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                                 '<soapenv:Header>'+
                                  '<bm:userInfo xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">'+
                                   '<bm:sessionId>'+sessionId+'</bm:sessionId>'+
                                  '</bm:userInfo>'+
                                  '<bm:category xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">Commerce</bm:category>'+
                                  '<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">'+
                                   '<bm:schemaLocation>http://centrica.bigmachines.com/bmfsweb/centrica/schema/v1_0/commerce/quotes_process_bmClone_43.xsd</bm:schemaLocation>'+
                                  '</bm:xsdInfo>'+
                                 '</soapenv:Header>'+
                                 '<soapenv:Body>'+
                                  '<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com">'+
                                   '<bm:transaction>'+
                                    '<bm:id>'+quoteId+'</bm:id>'+
                                    '<bm:process_var_name>quotes_process_bmClone_43</bm:process_var_name>'+
                                    '<bm:data_xml>'+
                                     '<bm:quote_process bm:bs_id="'+quoteId+'" bm:buyer_company_name="Centrica" bm:buyer_user_name="'+username+'" bm:currency_pref="GBP" bm:data_type="0" bm:document_name="Quote" bm:document_number="1" bm:document_var_name="quote_process" bm:process_var_name="quotes_process_bmClone_43" bm:supplier_company_name="Centrica">'                                                                                                                                                                                        
                                        
                                        +XMLUpdateMsg+                                      
                                                                    
                                    '</bm:quote_process>'+
                                    '</bm:data_xml>'+
                                    '<bm:action_data>'+
                                     '<bm:action_var_name>'+BMAction+'</bm:action_var_name> The Variavble Name of the triggered action'+
                                     '<bm:performer_name/>'+
                                     '<bm:performer_type/>'+
                                     '<bm:performer_company_name/>'+
                                    '</bm:action_data>'+
                                    '<bm:sub_step_name/>'+                                 
                                    '<bm:currency_pref>GBP</bm:currency_pref>'+                                                                
                                    '<bm:language_pref>English</bm:language_pref>'+                                +
                                   '</bm:transaction>'+
                                  '</bm:updateTransaction>'+
                                 '</soapenv:Body>'+
                                '</soapenv:Envelope>');  
        
        // Send the request, and return a response      
        System.debug('HttpRequest: ' + updateRequest.getBody());                
        return updateRequest;
        */
    }
    
    ///
    //Send httpRequest
    ///
     /*
    public static void sendHttpRequest(HttpRequest request){
       
        
        //Send the request, and return a response       
        Http http = new Http();
        HttpResponse response = http.send(request);     
        System.debug('Result from URL call: ' + response.getBody());
        return response;
        
    }
     */
    ///
    //Create the part of the XML message used in the update quote http call that maps SFDC fields to BM fields
    ///
    public static void createFullUpdateXMLString(String previousApps, Appointment__c appointment, Opportunity appointmentOpp, Account appointmentAccount, String jointVisitAttendees, list<ProductHoldingAccount__c> phACClist){
    /*
        XmlStreamWriter w = new XmlStreamWriter();
        
        // Asbestos changes starts       
         
          String asbestosFoundDateString = null;
          
        // Asbestos changes Ends    
        // Visit date change start- 17/05/2011
        /* Commeneted on 07/11/2013 
        To send Lead Created date instead Appointment Booked Date. 
        Help to assignin correct campaigns based on created Date.
        Requestor: Tommmy Kwan
        
        if(appointment.ID!=null && appointment.Date_Visit_Booked__c!=null){
                    w.writeStartElement(null, 'bm:visit_booked_str' , null);
                    w.writeCharacters(string.valueof(appointment.Date_Visit_Booked__c));
                    w.writeEndElement();
        }*/
        /*
        if(appointmentOpp.ID!=null && appointmentOpp.CreatedDate!=null){
                    w.writeStartElement(null, 'bm:visit_booked_str' , null);
                    w.writeCharacters(string.valueof(appointmentOpp.CreatedDate.date()));
                    w.writeEndElement();
        }
        
        // Visit date change ends
            
        
        if(appointmentOpp.quoteIncrementer__c!=null){
            w.writeStartElement(null, 'bm:QuoteVersion', null);
            w.writeCharacters(appointmentOpp.quoteIncrementer__c);
            w.writeEndElement();
        }
        if(appointmentOpp.Campaign.Media_Cost_Code__c!=null){
            w.writeStartElement(null, 'bm:mediaCode' , null);
            w.writeCharacters(String.ValueOf(appointmentOpp.Campaign.Media_Cost_Code__c));
            w.writeEndElement();        
        }
        if(appointmentOpp.CampaignId!=null){                                
            w.writeStartElement(null, 'bm:campaign', null);
            w.writeCharacters(appointmentOpp.CampaignId);
            w.writeEndElement();
        }
        if(appointmentOpp.LeadSource!=null){
            w.writeStartElement(null, 'bm:leadSource' , null);
            w.writeCharacters(appointmentOpp.LeadSource);
            w.writeEndElement();
        }
        if(appointmentOpp.Product_Interest__c!=null){        
            w.writeStartElement(null, 'bm:productInterest', null);
            w.writeCharacters(appointmentOpp.Product_Interest__c);
            w.writeEndElement();
        }
        if(appointmentOpp.Enquiry_Type__c!=null){
            w.writeStartElement(null, 'bm:enquiryType' , null);
            w.writeCharacters(appointmentOpp.Enquiry_Type__c);
            w.writeEndElement();
        }
        if(appointmentOpp.CHI_Lead_Id__c!=null){
            w.writeStartElement(null, 'bm:cHILeadNumber', null);
            w.writeCharacters(appointmentOpp.CHI_Lead_Id__c);
            w.writeEndElement();
        }       
        if(appointmentOpp.Lead_Comments__c!=null){
            w.writeStartElement(null, 'bm:leadComments' , null);
            w.writeCharacters(appointmentOpp.Lead_Comments__c);
            w.writeEndElement();
        }   
        if(appointmentOpp.Campaign.ParentId!=null){                                         
            w.writeStartElement(null, 'bm:campaignParent' , null);
            w.writeCharacters(appointmentOpp.Campaign.ParentId);
            w.writeEndElement();
        }
        if(appointmentOpp.Name!=null){  
            w.writeStartElement(null, 'bm:opportunityName_quote', null);
            w.writeCharacters(appointmentOpp.Name);
            w.writeEndElement();
        }
                                        
        w.writeStartElement(null, 'bm:stage' , null);
        w.writeCharacters('Appointed');
        w.writeEndElement();
        
        if(appointmentOpp.Probability!=null){                                                   
            w.writeStartElement(null, 'bm:probability', null);
            w.writeCharacters(String.ValueOf(appointmentOpp.Probability));
            w.writeEndElement();
        }
        if(appointmentOpp.Visit_Type__c!=null){                                                 
            w.writeStartElement(null, 'bm:visitType' , null);
            w.writeCharacters(appointmentOpp.Visit_Type__c);
            w.writeEndElement();        
        }                               
        if(appointmentOpp.Comments__c!=null){
            w.writeStartElement(null, 'bm:sfdcComments', null);
            w.writeCharacters(appointmentOpp.Comments__c);
            w.writeEndElement();
        }
        if(appointmentOpp.ID!=null){            
            w.writeStartElement(null, 'bm:sfOpportunityId_quote' , null);
            w.writeCharacters(appointmentOpp.ID);
            w.writeEndElement();
        }
        if(appointment.TA_Notes_All__c!=null){    
          string taNotes = '';//appointment.TA_Notes_All__c ;
          w.writeStartElement(null, 'bm:taNotes' , null);
          if(appointment.TA_Notes_Group_1__c  !=null)
            {
              taNotes = ((appointment.TA_Notes_Group_1__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointment.TA_Notes_Scrappage__c  !=null)
            {
              taNotes = taNotes +((appointment.TA_Notes_Scrappage__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointment.TA_Notes_Group_4__c !=null)
            {
              taNotes = taNotes +((appointment.TA_Notes_Group_4__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointment.TA_Notes_Group_5__c !=null)
            {
              taNotes = taNotes +((appointment.TA_Notes_Group_5__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointment.TA_Notes_Group_6__c !=null)
            {
              taNotes = taNotes +((appointment.TA_Notes_Group_6__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointment.TA_Notes_Group_7__c !=null)
            {
              taNotes = taNotes +((appointment.TA_Notes_Group_7__c.replace('<','')).replace('>','')) + '<br/>';
            }
            if(appointmentOpp.ta_notes__c !=null)
            {
              taNotes = taNotes +((appointmentOpp.ta_notes__c.replace('<','')).replace('>',''))+ '<br/>';
            }
            w.writeCharacters(taNotes);
            w.writeEndElement();
        }       
        if(appointment.BM_Salesperson__c!=null){
            w.writeStartElement(null, 'bm:apptAssignedTo', null);
            w.writeCharacters(appointment.BM_Salesperson__c);
            w.writeEndElement();
        }
        if(appointment.Contact_Best_Phone__c!=null){            
            w.writeStartElement(null, 'bm:apptBestPhone' , null);
            w.writeCharacters(appointment.Contact_Best_Phone__c);
            w.writeEndElement();
        }
        if(appointment.Contact_Home_Phone__c!=null){                        
            w.writeStartElement(null, 'bm:apptPhoneHome' , null);
            w.writeCharacters(appointment.Contact_Home_Phone__c);
            w.writeEndElement();
        }
        if(appointment.Contact_Mobile__c!=null){
            w.writeStartElement(null, 'bm:apptPhoneMobile', null);
            w.writeCharacters(appointment.Contact_Mobile__c);
            w.writeEndElement();
        }
        if(appointment.Contact_Phone__c!=null){         
            w.writeStartElement(null, 'bm:apptPhone' , null);
            w.writeCharacters(appointment.Contact_Phone__c);
            w.writeEndElement();
        }
        if(appointment.Contact_Work_Phone__c!=null){                        
            w.writeStartElement(null, 'bm:apptPhoneWork' , null);
            w.writeCharacters(appointment.Contact_Work_Phone__c);
            w.writeEndElement();
        }
        if(appointment.Converted_Visit_Type__c!=null){
            w.writeStartElement(null, 'bm:apptConvertedVisitType', null);
            w.writeCharacters(String.ValueOf(appointment.Converted_Visit_Type__c));
            w.writeEndElement();
        }
        if(appointment.Description__c!=null){           
            w.writeStartElement(null, 'bm:apptDescription' , null);
            w.writeCharacters(appointment.Description__c);
            w.writeEndElement();
        }
        if(appointment.End_Time__c!=null){                      
            w.writeStartElement(null, 'bm:apptEndTime' , null);
            w.writeCharacters(appointment.End_Time__c);
            w.writeEndElement();
        }
        if(appointment.Mode__c!=null){
            w.writeStartElement(null, 'bm:mode', null);
            w.writeCharacters(appointment.Mode__c);
            w.writeEndElement();
        }
        if(appointment.Start_Time__c!=null){            
            w.writeStartElement(null, 'bm:apptStartTime' , null);
            w.writeCharacters(appointment.Start_Time__c);
            w.writeEndElement();
        }
        if(appointment.Time_Band__c!=null){                     
            w.writeStartElement(null, 'bm:apptTimeBand' , null);
            w.writeCharacters(appointment.Time_Band__c);
            w.writeEndElement();
        }
        if(appointment.Type__c!=null){
            w.writeStartElement(null, 'bm:apptType', null);
            w.writeCharacters(appointment.Type__c);
            w.writeEndElement();
        }
        if(appointment.Visit_Date__c!=null){            
            w.writeStartElement(null, 'bm:apptVisitDate' , null);
            w.writeCharacters(String.ValueOf(appointment.Visit_Date__c));
            w.writeEndElement();
        }
        if(appointment.Visit_Type__c!=null){                        
            w.writeStartElement(null, 'bm:apptVisitType' , null);
            w.writeCharacters(appointment.Visit_Type__c);
            w.writeEndElement();
        }
        if(appointment.Id!=null){                       
            w.writeStartElement(null, 'bm:sFDCAppointmentID' , null);
            w.writeCharacters(appointment.Id);
            w.writeEndElement();
        }
        if(appointment.Assigned_To__r.Default_Pricebook_ID__c!=null){                       
            w.writeStartElement(null, 'bm:defaultPricebookID' , null);
            w.writeCharacters(appointment.Assigned_To__r.Default_Pricebook_ID__c);
            w.writeEndElement();
        }       
        if(appointmentAccount.BillingStreet!=null){         
            w.writeStartElement(null, 'bm:_bill_to_address' , null);
            w.writeCharacters(appointmentAccount.BillingStreet);
            w.writeEndElement();
        }
        if(appointmentAccount.BillingCity!=null){                       
            w.writeStartElement(null, 'bm:_bill_to_city' , null);
            w.writeCharacters(appointmentAccount.BillingCity);
            w.writeEndElement();
        }
        if(appointmentAccount.BillingState!=null){                      
            w.writeStartElement(null, 'bm:_bill_to_state' , null);
            w.writeCharacters(appointmentAccount.BillingState);
            w.writeEndElement();
        }
        if(appointmentAccount.BillingPostalCode!=null){         
            w.writeStartElement(null, 'bm:_bill_to_zip' , null);
            w.writeCharacters(appointmentAccount.BillingPostalCode);
            w.writeEndElement();
        }
        if(appointmentAccount.BillingCountry!=null){                        
            w.writeStartElement(null, 'bm:_bill_to_country' , null);
            w.writeCharacters(appointmentAccount.BillingCountry);
            w.writeEndElement();
        }
        if(appointmentAccount.Sales_District__c!=null){                     
            w.writeStartElement(null, 'bm:salesDistrict' , null);
            w.writeCharacters(appointmentAccount.Sales_District__c);
            w.writeEndElement();
        }
        if(appointmentAccount.Sales_Region__c!=null){           
            w.writeStartElement(null, 'bm:salesRegion' , null);
            w.writeCharacters(appointmentAccount.Sales_Region__c);
            w.writeEndElement();
        }
        if(appointmentAccount.Sales_Subpatch__c!=null){                     
            w.writeStartElement(null, 'bm:salesSubpatch' , null);
            w.writeCharacters(appointmentAccount.Sales_Subpatch__c);
            w.writeEndElement();
        }
        if(appointmentAccount.Phone!=null){                     
            w.writeStartElement(null, 'bm:_bill_to_phone' , null);
            w.writeCharacters(appointmentAccount.Phone);
            w.writeEndElement();
        }
        if(appointmentAccount.Fax!=null){                       
            w.writeStartElement(null, 'bm:_bill_to_fax' , null);
            w.writeCharacters(appointmentAccount.Fax);
            w.writeEndElement();
        }
        if(appointmentAccount.Id!=null){                        
            w.writeStartElement(null, 'bm:sfAccountId_quote' , null);
            w.writeCharacters(appointmentAccount.Id);
            w.writeEndElement();
        }     
        if(appointmentAccount.Primary_Contact__r.Salutation!=null){                     
            w.writeStartElement(null, 'bm:c1Title' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.Salutation);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.FirstName!=null){                      
            w.writeStartElement(null, 'bm:_bill_to_first_name' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.FirstName);
            w.writeEndElement();
        }   
        if(appointmentAccount.Primary_Contact__r.LastName!=null){                       
            w.writeStartElement(null, 'bm:_bill_to_last_name' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.LastName);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.MailingStreet!=null){                      
            w.writeStartElement(null, 'bm:c2Street' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.MailingStreet);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.MailingCity!=null){                        
            w.writeStartElement(null, 'bm:c2City' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.MailingCity);
            w.writeEndElement();
        }   
        if(appointmentAccount.Primary_Contact__r.MailingState!=null){                       
            w.writeStartElement(null, 'bm:c2County' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.MailingState);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.MailingCountry!=null){                     
            w.writeStartElement(null, 'bm:c2Country' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.MailingCountry);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.MailingPostalCode!=null){                      
            w.writeStartElement(null, 'bm:c2Postcode' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.MailingPostalCode);
            w.writeEndElement();
        }   
        if(appointmentAccount.Primary_Contact__r.OtherStreet!=null){                        
            w.writeStartElement(null, 'bm:c3Street' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.OtherStreet);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.OtherCity!=null){                      
            w.writeStartElement(null, 'bm:c3City' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.OtherCity);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.OtherState!=null){                     
            w.writeStartElement(null, 'bm:c3County' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.OtherState);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.OtherCountry!=null){                       
            w.writeStartElement(null, 'bm:c3Country' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.OtherCountry);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.OtherPostalCode!=null){                        
            w.writeStartElement(null, 'bm:c3Postcode' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.OtherPostalCode);
            w.writeEndElement();
        }
        if(appointmentAccount.Primary_Contact__r.Id!=null){                     
            w.writeStartElement(null, 'bm:sfContactId_quote' , null);
            w.writeCharacters(appointmentAccount.Primary_Contact__r.Id);
            w.writeEndElement();
        }
        if(appointmentAccount.Water_Hardness__c!=null){                     
            w.writeStartElement(null, 'bm:waterHardness' , null);
            w.writeCharacters(String.ValueOf(appointmentAccount.Water_Hardness__c));
            w.writeEndElement();
        }
        if(appointmentAccount.Country_Differentiator__c !=null){                        
            w.writeStartElement(null, 'bm:countryDifferentiator' , null);
            w.writeCharacters(String.ValueOf(appointmentAccount.Country_Differentiator__c));
            w.writeEndElement();
        } 
        if(appointmentAccount.Patch_ID__c !=null){                        
            w.writeStartElement(null, 'bm:geographicRegion' , null);
            w.writeCharacters(String.ValueOf(appointmentAccount.Patch_ID__c));
            w.writeEndElement();
        }      
        if(previousApps!=null){                     
            w.writeStartElement(null, 'bm:relatedQuotes2' , null);
            w.writeCharacters(previousApps);
            w.writeEndElement();
        }   
        
        if(jointVisitAttendees!=null){                      
            w.writeStartElement(null, 'bm:jointVisitAttendees' , null);
            w.writeCharacters(jointVisitAttendees);
            w.writeEndElement();
        }
        /*
          change: 16/02/12
          This change was done as a part of RHC to send Priamry Contact's email Address.
        */
        /*
        if(appointment.Customer_Email_Address__c!=null){                      
            w.writeStartElement(null, 'bm:c1Email' , null);
            w.writeCharacters(appointment.Customer_Email_Address__c);
            w.writeEndElement();
        }
        
      if(appointmentOpp.SMStatus__c !=null){ 
           w.writeStartElement(null, 'bm:sfdc_smart_meter_eligible' , null);
           if(appointmentOpp.SMStatus__c != 'Unknown BGMO')                     
             w.writeCharacters(appointmentOpp.SMStatus__c);
             else
             w.writeCharacters('Unknown or Not BG');
             w.writeEndElement();
         }
         
      if(appointmentAccount.Number_of_Bedrooms__c!=null){                      
              w.writeStartElement(null, 'bm:sfdc_number_of_bedrooms' , null);
              w.writeCharacters(string.valueof(appointmentAccount.Number_of_Bedrooms__c));
              w.writeEndElement();
          }
      if(system.label.GD_Switch == 'on' && appointmentOpp.GDCashBack__c)
      {
        w.writeStartElement(null, 'bm:sfdc_green_deal_cashback_interest' , null);
            w.writeCharacters('Yes');
            w.writeEndElement();
      } 
        
        if(system.label.PriorityInst == 'yes')
        {
          if(appointmentOpp.Is_the_customers_boiler_working__c !=null){                      
          w.writeStartElement(null, 'bm:sfdc_is_the_customers_boiler_working' , null);
          w.writeCharacters(appointmentOpp.Is_the_customers_boiler_working__c);
          w.writeEndElement();
          } 
          if(appointmentOpp.Does_the_customer_have_hot_water__c !=null){                      
              w.writeStartElement(null, 'bm:sfdc_does_the_customer_have_hot_water' , null);
              w.writeCharacters(appointmentOpp.Does_the_customer_have_hot_water__c);
              w.writeEndElement();
          } 
          if(appointmentOpp.Customer_have_any_other_form_of_HEAT__c !=null){                      
              w.writeStartElement(null, 'bm:sfdc_any_other_form_of_heat' , null);
              w.writeCharacters(appointmentOpp.Customer_have_any_other_form_of_HEAT__c);
              w.writeEndElement();
          } 
          if(appointmentOpp.Is_the_customer_vulnerable__c !=null){                      
              w.writeStartElement(null, 'bm:sfdc_customer_vulnerable' , null);
              w.writeCharacters(appointmentOpp.Is_the_customer_vulnerable__c);
              w.writeEndElement();
          } 
          if(appointmentOpp.Vulnerable_reason__c !=null){                      
              w.writeStartElement(null, 'bm:sfdc_customer_vulnerable_reason' , null);
              w.writeCharacters(appointmentOpp.Vulnerable_reason__c);
              w.writeEndElement();
          } 
          if(appointmentOpp.Latest_customer_category__c !=null){                      
              w.writeStartElement(null, 'bm:sfdc_customer_category' , null);
              w.writeCharacters(String.ValueOf(appointmentOpp.Latest_customer_category__c));
              w.writeEndElement();
          } 
        }
        // ++ Added for Free Insulation change start
        if(system.label.Free_Insulation_Switch == 'on')
      {
        if(appointmentOpp.Free_Insulation_Eligible__c != null)
        {
          w.writeStartElement(null, 'bm:sfdc_free_insulation_eligible' , null);
              w.writeCharacters(String.ValueOf(appointmentOpp.Free_Insulation_Eligible__c));
              w.writeEndElement();
        }
      }
        // -- Added for Free Insulation change end
        if(system.label.BM_Switch == 'yes')
        {     
          if(appointmentAccount.ProductHoldings__r.size()>0)
          {
            ProductHolding__c productHolding = appointmentAccount.ProductHoldings__r[0];
            
            // ++ Commented the part for not sending CreditRatings to BM as per business request start
            /*
            if(productHolding.CreditRating__c !=null){                      
                w.writeStartElement(null, 'bm:sfdc_customer_credit_rating' , null);
                w.writeCharacters(productHolding.CreditRating__c);
                w.writeEndElement();
            }*/
            // -- Commented the part for not sending CreditRatings to BM as per business request end 
            /*
            if(productHolding.IsCurrentCustomerOfAnyProduct__c !=null){                      
                w.writeStartElement(null, 'bm:sfdc_is_product_customer' , null);
                w.writeCharacters(productHolding.IsCurrentCustomerOfAnyProduct__c);
                w.writeEndElement();
            } 
            if(productHolding.ServiceCover__c !=null){                      
                w.writeStartElement(null, 'bm:sfdc_service_cover' , null);
                w.writeCharacters(productHolding.ServiceCover__c);
                w.writeEndElement();
            }
            if(productHolding.ServiceProducts__c!=null)
            {
              w.writeStartElement(null, 'bm:sfdc_service_products' , null);
                w.writeCharacters(productHolding.ServiceProducts__c);
                w.writeEndElement();
            }
            boolean elecSet = false;
            boolean gasSet = false;
            if(phACClist.size()>0)
            {
              for(ProductHoldingAccount__c pha : phACClist)
              {
                if(pha.Type__c == 'Electricity' && pha.Type__c!='Gas' && !elecSet)
                {
                  w.writeStartElement(null, 'bm:sfdc_elec_customer' , null);
                  w.writeCharacters('Yes');
                    w.writeEndElement();
                  
                  if(pha.MonthlySpend__c !=null){            
                    w.writeStartElement(null, 'bm:sfdc_monthly_spend_elec' , null);
                      w.writeCharacters(string.valueof(pha.MonthlySpend__c));
                      w.writeEndElement();
                  } 
                  
                  if(pha.PaymentMethod__c !=null){                      
                      w.writeStartElement(null, 'bm:sfdc_payment_method_elec' , null);
                      w.writeCharacters(pha.PaymentMethod__c);
                      w.writeEndElement();
                  } 
                  elecSet = true;
                }
                else if(pha.Type__c=='Gas' && pha.Type__c != 'Electricity' && !gasSet){                      
                    w.writeStartElement(null, 'bm:sfdc_gas_customer' , null);
                    w.writeCharacters('Yes');
                    w.writeEndElement();
                    
                     if(pha.MonthlySpend__c  !=null){                      
                      w.writeStartElement(null, 'bm:sfdc_monthly_spend_gas' , null);
                      w.writeCharacters(string.valueof(pha.MonthlySpend__c ));
                      w.writeEndElement();
                  } 
                  
                  if(pha.PaymentMethod__c !=null){                      
                      w.writeStartElement(null, 'bm:sfdc_payment_method_gas' , null);
                      w.writeCharacters(pha.PaymentMethod__c);
                      w.writeEndElement();
                  } 
                    gasSet= true;
                }
                
              }
              if(!elecSet)
              {
                w.writeStartElement(null, 'bm:sfdc_elec_customer' , null);
                  w.writeCharacters('Unknown');
                  w.writeEndElement();
              }
              if(!gasSet)
              {
                  w.writeStartElement(null, 'bm:sfdc_gas_customer' , null);
                  w.writeCharacters('Unknown');
                  w.writeEndElement();
              }
            }
          
          }
        }
    
        
        
      
         
        // CR-000159  - Capture gas and electric meter read. - Starts
       
        /*if(appointmentAccount.Sales_Region__c ==  'West Midlands')
        {
          if(appointmentAccount.Gas_account_number__c!=null){                      
              w.writeStartElement(null, 'bm:gasAccountNumber' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Gas_account_number__c));
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Gas_meter_serial_number__c!=null){                      
              w.writeStartElement(null, 'bm:gasMeterSerialNumber' , null);
              w.writeCharacters(appointmentAccount.Gas_meter_serial_number__c);
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Gas_meter_reading__c!=null){                      
              w.writeStartElement(null, 'bm:gasMeterReading' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Gas_meter_reading__c));
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Gas_comments_field__c!=null){                      
              w.writeStartElement(null, 'bm:gasComments' , null);
              w.writeCharacters(appointmentAccount.Gas_comments_field__c);
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Gas_safety_comments__c!=null){                      
              w.writeStartElement(null, 'bm:gasSafetyComments' , null);
              w.writeCharacters(appointmentAccount.Gas_safety_comments__c);
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Gas_tamper_comments__c!=null){                      
              w.writeStartElement(null, 'bm:gasTamperComments' , null);
              w.writeCharacters(appointmentAccount.Gas_tamper_comments__c);
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Electric_account_number__c!=null){                      
              w.writeStartElement(null, 'bm:electricAccountNumber' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Electric_account_number__c));
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Electric_serial_number__c!=null){                      
              w.writeStartElement(null, 'bm:electricSerialNumber' , null);
              w.writeCharacters(appointmentAccount.Electric_serial_number__c);
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Electric_meter_reading_High__c!=null){                      
              w.writeStartElement(null, 'bm:electricMeterReadingHigh' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Electric_meter_reading_High__c));
              w.writeEndElement();
          }   
          
          if(appointmentAccount.Electric_meter_reading_Low__c!=null){                      
              w.writeStartElement(null, 'bm:electricMeterReadingLow' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Electric_meter_reading_Low__c));
              w.writeEndElement();
          } 
          
          if(appointmentAccount.Electric_comments__c!=null){                      
              w.writeStartElement(null, 'bm:electricComments' , null);
              w.writeCharacters(appointmentAccount.Electric_comments__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.Electric_safety_comments__c!=null){                      
              w.writeStartElement(null, 'bm:electricSafetyComments' , null);
              w.writeCharacters(appointmentAccount.Electric_safety_comments__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.Electric_tamper_comments__c!=null){                      
              w.writeStartElement(null, 'bm:electricTamperComments' , null);
              w.writeCharacters(appointmentAccount.Electric_tamper_comments__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.isGasMeterSafe__c!=null){                      
              w.writeStartElement(null, 'bm:isGasMeterSafe' , null);
              w.writeCharacters(appointmentAccount.isGasMeterSafe__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.isGasMeterTampered__c!=null){                      
              w.writeStartElement(null, 'bm:isGasMeterTampered' , null);
              w.writeCharacters(appointmentAccount.isGasMeterTampered__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.isElectricMeterSafe__c!=null){                      
              w.writeStartElement(null, 'bm:isElectricMeterSafe' , null);
              w.writeCharacters(appointmentAccount.isElectricMeterSafe__c);
              w.writeEndElement();
          } 
          
          if(appointmentAccount.isElectricMeterTampered__c!=null){                      
              w.writeStartElement(null, 'bm:isElectricMeterTampered' , null);
              w.writeCharacters(appointmentAccount.isElectricMeterTampered__c);
              w.writeEndElement();
          } 
        }*/
        // CR-000159  - Capture gas and electric meter read. - Ends

     // Asbestos changes starts
     /*
     String sendAsbestosDetailsToHeat = System.Label.Release_Asbestos_CR;  
     
     if(sendAsbestosDetailsToHeat!=null){
        
        System.debug('Value of system label Release_Asbestos_CR is : '+sendAsbestosDetailsToHeat);
        
        if(sendAsbestosDetailsToHeat.equalsIgnoreCase('True')){
          
          if(appointmentAccount.Asbestos_found__c!=null){                      
              w.writeStartElement(null, 'bm:asbestosFound' , null);
              w.writeCharacters(String.ValueOf(appointmentAccount.Asbestos_found__c));
              w.writeEndElement();
           }   
        
           if(appointmentAccount.Asbestos_Found_Date_New__c!=null){                      
              w.writeStartElement(null, 'bm:asbestosFoundDateTime' , null);
              asbestosFoundDateString = String.valueOf(appointmentAccount.Asbestos_Found_Date_New__c.year());
              asbestosFoundDateString = asbestosFoundDateString + '-' + String.valueOf(appointmentAccount.Asbestos_Found_Date_New__c.month());
              asbestosFoundDateString = asbestosFoundDateString + '-' + String.valueOf(appointmentAccount.Asbestos_Found_Date_New__c.day());
              asbestosFoundDateString = asbestosFoundDateString + ' ' + '00:00:00';
              w.writeCharacters(asbestosFoundDateString);
              w.writeEndElement();
           }   
     
          if(appointmentAccount.healthSafety_Notes__c!=null){                      
              w.writeStartElement(null, 'bm:healthSafetyNotes' , null);
              w.writeCharacters(appointmentAccount.healthSafety_Notes__c);
              w.writeEndElement();
           } 
         
         }
       
      }   
     
    // Asbestos changes ends

        w.writeEndDocument();
        String XMLUpdateMsg = w.getXmlString();
        w.close();
        system.debug('XML STRING------>'+XMLUpdateMsg);
        return XMLUpdateMsg;    
        */
    }
    
        
    ///
    //Create the part of the XML message used in the cancel quote http request
    ///
    public static void createCancelXMLString(){                                                           
        /*
        XmlStreamWriter w = new XmlStreamWriter();
             
        w.writeStartElement(null, 'bm:stage' , null);
        w.writeCharacters('Visited: Could Not Proceed');
        w.writeEndElement();   
        
        w.writeStartElement(null, 'bm:bmStatusReason' , null);
        w.writeCharacters('House Closed');
        w.writeEndElement();                     
        
        w.writeEndDocument();
        String XMLCancelMsg = w.getXmlString();
        w.close();
        
        return XMLCancelMsg;         
        */
    }       
    
    
    ///       
    //Read Http response XML message
    ///
    /*
    public static void readXML(HttpResponse response, String tag){
        /*
            
        String text;                            
        XmlStreamReader responseReader = new XmlStreamReader(response.getBody());
        
        while(responseReader.hasNext()) {               
            if (responseReader.getEventType() == XmlTag.START_ELEMENT){                         
                if (tag == responseReader.getLocalName()){                                      
                    while(responseReader.hasNext()) {
                        if (responseReader.getEventType() == XmlTag.END_ELEMENT)
                            break;
                        else if (responseReader.getEventType() == XmlTag.CHARACTERS)
                            text = responseReader.getText();                        
                        responseReader.next();  
                    }
                    break;                                                                                      
                }
            }                                           
            responseReader.next();
        }           
        system.debug(tag+' tag text is: '+text);
        return text;
        
    }
    */
    ///
    //Query for appointment fields
    ///
    public static void getAppointment(ID[] appointmentID){     
        /*
        Appointment__c[] appointments = [select date_visit_booked__c,notify_old_owner_of_cancellation__c, PreviousAppOwnerTextMailAddress__c, Id, Start__c, notify_employee_of_app_cancellation__c, BM_Salesperson__c, SentToBM__c, LoadedInBM__c, Big_Machines_Quote_ID__c, Type__c, Visit_Type__c, Description__c, Converted_Visit_Type__c, Opportunity__c, TA_Notes_All__c, Mode__c,Contact_Best_Phone__c, Contact_Home_Phone__c, Contact_Mobile__c, Contact_Phone__c, Contact_Work_Phone__c, Start_Time__c, End_Time__c, Time_Band__c, Visit_Date__c, Assigned_To__c, Assigned_To__r.Default_Pricebook_ID__c,TA_Notes_Group_1__c ,TA_Notes_Group_4__c ,TA_Notes_Group_5__c,TA_Notes_Group_6__c,TA_Notes_Group_7__c,TA_Notes_Scrappage__c,Customer_Email_Address__c  from Appointment__c where Type__c =: 'Sales' AND ID IN :appointmentID];                
        return appointments;   
        */
    }
    
    ///
    //Query for CHI Lead fields
    ///
    public static void getCHILead(Id appointmentOppID){     
        /*
        Opportunity appointmentOpp = [select Id, Campaign.ParentId, Campaign.Media_Cost_Code__c,LeadSource, campaignID, Media_Code__c, Name, AccountId, StageName, Probability, CHI_Lead_Id__c, Enquiry_Type__c, Product_Interest__c, Visit_Type__c, Lead_Comments__c, Comments__c, quoteIncrementer__c,ta_notes__c,
                        Is_the_customers_boiler_working__c,Does_the_customer_have_hot_water__c,Customer_have_any_other_form_of_HEAT__c,Is_the_customer_vulnerable__c,Vulnerable_reason__c,Latest_customer_category__c, SMStatus__c,GDCashBack__c, Free_Insulation_Eligible__c,CreatedDate from Opportunity where Id=:appointmentOppID limit 1];                               
        return appointmentOpp;      
        */
                                                                        
    }
    
    ///
    //Query for Account and Contact fields
    ///
    public static void getAccount(Id appointmentOppAccountId){      
        /*
        // CR-000159  - Capture gas and electric meter read.
        // Asbestos changes - starts
        Account appointmentAccount = [select Id, Number_of_Bedrooms__c,Water_Hardness__c, Asbestos_found__c, Asbestos_Found_Date_New__c, healthSafety_Notes__c, Primary_Contact__r.Id, Primary_Contact__r.Salutation, 
        Primary_Contact__r.LastName, Primary_Contact__r.FirstName, Primary_Contact__r.Best_Phone__c, Primary_Contact__r.MobilePhone, 
        Primary_Contact__r.MailingCountry, Primary_Contact__r.MailingPostalCode, Primary_Contact__r.MailingState, 
        Primary_Contact__r.MailingCity, Primary_Contact__r.MailingStreet, Primary_Contact__r.OtherCountry, 
        Primary_Contact__r.OtherPostalCode, Primary_Contact__r.OtherState, Primary_Contact__r.OtherCity, 
        Primary_Contact__r.OtherStreet, BillingStreet, BillingCity, BillingState, BillingCountry, 
        BillingpostalCode, Sales_Subpatch__c, Sales_Region__c, Sales_District__c, fax, phone, Country_Differentiator__c, 
        Patch_ID__c, Gas_account_number__c, Gas_meter_serial_number__c, Gas_meter_reading__c, Gas_comments_field__c, Gas_safety_comments__c, 
        Gas_tamper_comments__c, Electric_account_number__c, Electric_serial_number__c, Electric_meter_reading_High__c, 
        Electric_meter_reading_Low__c, Electric_comments__c, Electric_safety_comments__c, Electric_tamper_comments__c, 
        isGasMeterSafe__c, isGasMeterTampered__c, isElectricMeterSafe__c, isElectricMeterTampered__c,(Select CreditRating__c, 
        IsCurrentCustomerOfAnyProduct__c, ServiceCover__c, Id,ServiceProducts__c From ProductHoldings__r where Status__c = 'Current' limit 1)
        from Account where Id = :appointmentOppAccountId limit 1];                          
        return appointmentAccount;   
        // Asbestos changes - Ends          
        */
    }
    /*
    public static void getPrdAccs(Id PHParentId)
    {/*
      list<ProductHoldingAccount__c> phAcclist = [Select p.Type__c, p.ProductHolding__c, p.PaymentMethod__c, p.Name, p.MonthlySpend__c, p.Id From ProductHoldingAccount__c p where ProductHolding__c =:PHParentId order by CreatedDate Desc ];
      return phAcclist;
      
    }
    */
    ///
    //Query for associated appointments of this CHI Lead. For the following reasons
    //1 - obtain previous appointments happened in last 3 months and create a pipe delimited string to pass
    //to Big Machines of the quote transaction IDs (Primary Key). BM translates this to a link of previous quotes that exist in BM.
    //2 - obtain the name of any employees who also have an appointment for the same day as this will be a joint visit
    //used to show employees in BM who else is going to be visiting the customer for a joint visit. 
    ///
    public static void getAssociatedApps(Id appointmentOppId, dateTime appDateTime){       

        /*
        //Capgemini - 26th Aug 09
        New Functionality:
        If there is a Primary quote on the CHI Lead (i.e. one that has been Accepted) 
        this will be the related quote that is linked to. If there is no primary quote, 
        (i.e. none accepted) the related quotes should be those where the quote created 
        date is some time after 3 months before the date that the related quote links 
        are created. (I.e. get all of the transaction IDs from the quotes related to the 
        CHI lead rather than the appointments related to the CHI lead) 
        
        The Links to the related quotes have more meaningful names. As a minimum, the 
        name should be 'Quote Number, Product Type, Gross Value' E.g. 2345 CHB Â£2345.67. 
        */   
        /*
        // Made fix for CHI IV so that we should not consider installation type of appointments
        Appointment__c[] associatedAppointments = [select Assigned_To__r.Last_Name__c, Assigned_To__r.First_Name__c, Status__c, Start__c, Big_Machines_Quote_ID__c from Appointment__c where Opportunity__c = :appointmentOppId AND Start__c>:dateTime.now().addMonths(-3) AND (Status__c='Happened' Or Status__c='Appointed') AND RecordType.Name != 'Installation' AND Type__c = 'Sales' limit 1000];                             
        system.debug('associatedAppointments includes: '+associatedAppointments);
        String prevAppsPipeDelimtedString = '';
        String jointVisitAdditionalEmployees = '';

        //leave this code as it is because it works
        for(integer x=0;x<associatedAppointments.size();x++){
            if(associatedAppointments[x].Status__c == 'Happened' && associatedAppointments[x].Big_Machines_Quote_ID__c!=null)
                prevAppsPipeDelimtedString += associatedAppointments[x].Big_Machines_Quote_ID__c+'|';
            else{ 
                date appDate = date.newInstance(appDateTime.year(), appDateTime.month(), appDateTime.day());
                date associatedAppDate = date.newInstance(associatedAppointments[x].Start__c.year(), associatedAppointments[x].Start__c.month(), associatedAppointments[x].Start__c.day());             
                if(associatedAppDate==appDate)          
                    jointVisitAdditionalEmployees += associatedAppointments[x].Assigned_To__r.First_Name__c+' '+associatedAppointments[x].Assigned_To__r.Last_Name__c+', ';         
            }
        }  
        
        //create the prevAppsPipeDelimtedString again in the new way
        //will be a pipe delimeted list of BM transaction Ids that are associated to the
        //CHI lead via the quotes
        prevAppsPipeDelimtedString = '';
        String next_item = '';
        BigMachines_Quote__c[] related_quotes = [select Id, BigMachines_Transaction_Id__c, Is_Primary__c,
                                            grossPricingTotal__c, Pricebook_Id__c, Name  
                                            from BigMachines_Quote__c
                                            where Opportunity__c = :appointmentOppId
                                            AND createdDate>:dateTime.now().addMonths(-3) 
                                            limit 1000];
        for(integer x=0;x<related_quotes.size();x++)
        {

            if(related_quotes[x].BigMachines_Transaction_Id__c!=null)
            {
                next_item = related_quotes[x].BigMachines_Transaction_Id__c + '&&' + related_quotes[x].Name + ' ' + related_quotes[x].Pricebook_Id__c + ' Â£' + related_quotes[x].grossPricingTotal__c + '|';
                if(related_quotes[x].Is_Primary__c == true)
                {
                    //only want to link to one if there is a primary
                    prevAppsPipeDelimtedString = next_item;
                    break;
                }               
                prevAppsPipeDelimtedString += next_item;
            }           
        }                                           
            
        system.debug('prevAppsPipeDelimtedString includes: '+prevAppsPipeDelimtedString);
        system.debug('jointVisitAdditionalEmployees includes: '+jointVisitAdditionalEmployees);
        
        List<String> associatedAppsParams = new List<String>{};     
        associatedAppsParams.add(prevAppsPipeDelimtedString);
        associatedAppsParams.add(jointVisitAdditionalEmployees);
        
        return associatedAppsParams;     
        */
    }   
    
    ///
    //Custom exception classes need declaring as used in code above
    /// 
    /*
    public class MyException extends Exception {}
    public class My2Exception extends Exception {}   
*/
    
}