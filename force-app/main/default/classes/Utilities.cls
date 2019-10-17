/* Utilities class

    A class to hold: 
        - methods that retrieve information useful or 
        - useful data/information
    across many classes.
    
    These are all static so can be accessed via Utilties.methodName or
    Utilities.variableName
    
    Some methods retrieve information from the database. We use booleans to 
    see if the method has been called before - if it hasn't, we query the
    database for the necessary information. This way, the database is only
    queried the first time a method is called, but the user can use the
    method without worrying if the query has taken place or not

*/

public class Utilities {
    
    // A Set of Profile IDs that are allowed to delete booked Appointments (System Admin and Dataloader users)
    //Public static Set<String> profilesAllowedToDeleteList = new Set<String> (system.label.systemadminId.split(','));
    Public static Set<id> profilesAllowedToDelete = getProfileIDs(system.label.systemadminId.split(','));
    
    
    // A Map to hold RecordTypeIDs, and a boolean to see if the Map has been populated
    public static Map<ID, RecordType> recordTypes = new Map<ID, RecordType>();
    private static boolean isSetup = false;
    
    // A Map to hold Offers (and a boolean to see if it's been populated
    public static Map<ID, Offer__c> offers = new Map<ID, Offer__c>();
    private static boolean offersIsSetup = false;
    //public static Set<String> profileNames = new Set<String> {'CHI Installation Lead Engineer','CHI Installation - DHM' ,'System Administrator'};

    // String to hold RecordTypeIDs of Available Appointments and booked Appointments.
    // This was a temporary fix during data migration to reduce the number of 
    // statements executed, but works and makes sense, so it was left in
    public static String appRTID  = getRecordTypeId('Appointment', 'Appointment__c');
    public static String avRTID  = getRecordTypeId('Available', 'Appointment__c');
    
    // Map to hold values of parameters passed via URLs in the Postcode Anywhere
    // and Appointment Call Centre Booking Screens
    //public static Map<String, String> urlParameters = new Map<String, String>();
    
    Public Static set<ID> getProfileIDs(List<String> profileList)
    {
       set<id> profileIdset = new set<Id>();
       for(String s:profileList)
       { 
         id profileId = (ID)s;
         profileIdset.add(profileId);   
        } 
        return profileIdset;
    }
    
    // IntegratedScript changes
    public static String buildParameterString(PageReference pageRef, String ffNavigation) {
        Map<String, String> urlParameters = pageRef.getParameters();
        
        String url = '?';
        for(String parameter : urlParameters.keySet()) {
            if(!parameter.startsWith('var_') && parameter != 'FIREFLY_NAVIGATION')
                url += parameter + '=' + urlParameters.get(parameter) + '&';
        }
        
        // Strip the extra & off
        if(url.endsWith('&'))
            url = url.subString(0,url.length()-1);
        
        // Populate the Firefly Navigation parameter
        if(ffNavigation != null)
            url += '&FIREFLY_NAVIGATION=' + ffNavigation;
        
        System.debug('Built URL: ' + url);
        
        return url;
    } 
    // end IntegratedScript changes
    /* setup()
        Queries the database for RecordTypes and puts them in a map. 
        
        This was the first use of the Utilities class, hence the slightly confusing
        name for the method (setupRTIDs() would make more sense). At present, we are
        unable to change this because of some old classes no longer used.
        
        Simiarly, originally this had to be called from the calling class, hence the 
        "public" access. Because of legacy classes, we are unable to change this.
        However, this situation should change shortly.
    */
    public static void setup() {
        if(recordTypes.isEmpty()) {
            for(RecordType rt : [Select r.Id, r.Name, r.SobjectType From RecordType r]) {
                recordTypes.put(rt.Id, rt);
            }
        }
        isSetup = true;
    }

    /* getRecordTypeId(String, String)
        Checks if setup() has been run/if the RecordTypeID Map has been populated.
        
        It then proceeds to get the Salesforce ID of the RecordType given by the first
        argument (i.e. "Available") of the Object of the second argument (i.e. "Event").
    */
    
    public static String getRecordTypeId(String recordType, String obj) {
        if(!isSetup)
            setup();

        for(RecordType rt : recordTypes.values()) {
            if(rt.Name == recordType && rt.sObjectType == obj)
                return rt.Id;
        }
        return null;
    }
    
    /* getRecordTypeName(ID rtid)
        Checks if setup() has been run/if the RecordTypeID Map has been populated.
        
        It then loops over the entries in the map and returns the Name of the Record
        Type passed in to the method.
        
        If no matching RecordType is found, this method returns null. 
    */
    public static String getRecordTypeName(ID rtid) {
        if(!isSetup)
            setup();
        for(RecordType rt : recordTypes.values()) {
            if(rt.Id == rtid)
                return rt.Name;
        }
        return null;
    }
    
    /* offersSetup()
        Queries the database for all Offers and stores them in a map.
        
        Currently there are not many offers; if this situation changes, it
        may be wise to retrieve offers with something in the WHERE clause
        to restrict retrieving redundant offers.
    
    public static void offersSetup() {
        if(offers.isEmpty()) {
            for(Offer__c offer : [SELECT o.Id, o.Start_Date__c, o.End_Date__c, o.Description__c FROM Offer__c o]) {
                offers.put(offer.Id, offer);
            }
        }
        offersIsSetup = true;
    }
    
    /* getOfferDescription(Datetime)
    
        Returns a string containing the description of the Offer that the Datetime
        argument falls in.
    
    public static String getOfferDescription(Datetime startDT) {
        if(!offersIsSetup)
            offersSetup();

        for(Offer__c offer : offers.values()) {
            if(startDT.dayOfYear() >= offer.Start_Date__c.dayOfYear() && 
                startDT.dayOfYear() <= offer.End_Date__c.dayOfYear())
                return offer.Description__c;
        }
        System.debug('Did not find Offer');
        return null;
    }
    */
   // CR For Diary Start & End Time Changes Starts
   /*
   Commented as this code is not used anymore and will be help in code improvement efficiency.
   
   public static void convertAppointmentsFromOldWorldToNewWorld(List<Appointment__c> newApptsFromCancellations){
    
    List<Sales_Diary_Conversion__c> sdcList = [Select Old_Start_Time__c,Old_End_Time__c,New_Start_Time__c,New_End_Time__c from Sales_Diary_Conversion__c];
    String oldStartTime;
    String oldEndTime;
    
    for(Appointment__c app:newApptsFromCancellations){
        
    // Convert start time to string representation in the HH:MM format from datetime datatype
        
        if(app.Start__c.hour() < 10 && app.Start__c.minute() < 30)
                oldStartTime = '0' + app.Start__c.hour().format() + ':00';
            else if(app.Start__c.hour() < 10 && app.Start__c.minute() == 30)
                oldStartTime = '0' + app.Start__c.hour().format() + ':30';
           
            if(app.Start__c.hour() >= 10 && app.Start__c.minute() < 30)
                oldStartTime = app.Start__c.hour().format() + ':00';
            else if(app.Start__c.hour() >= 10 && app.Start__c.minute() == 30)
                oldStartTime = app.Start__c.hour().format() + ':30';
                
    // Convert end time to string representation in the HH:MM format from datetime datatype
            
            if(app.End__c.hour() < 10 && app.End__c.minute() < 30)
                oldEndTime = '0' + app.End__c.hour().format() + ':00';
            else if(app.End__c.hour() < 10 && app.End__c.minute() == 30)
                oldEndTime = '0' + app.End__c.hour().format() + ':30';
           
            if(app.End__c.hour() >= 10 && app.End__c.minute() < 30)
                oldEndTime = app.End__c.hour().format() + ':00';
            else if(app.End__c.hour() >= 10 && app.End__c.minute() == 30)
                oldEndTime = app.End__c.hour().format() + ':30';
                
    // Now populate the corresponding new appt start and end time according to conversions
    
          for(Sales_Diary_Conversion__c sdc:sdcList){
            
                System.debug(LoggingLevel.INFO, 'oldStartTime On Appt: ' + oldStartTime);
                System.debug(LoggingLevel.INFO, 'oldEndTime On Appt: ' + oldEndTime);
                System.debug(LoggingLevel.INFO, 'oldStartTime On conversion table: ' + sdc.Old_Start_Time__c.trim());
                System.debug(LoggingLevel.INFO, 'oldEndTime On conversion table: ' + sdc.Old_End_Time__c.trim());
                System.debug(LoggingLevel.INFO, 'newStartTime On conversion table: ' + sdc.New_Start_Time__c.trim());
                System.debug(LoggingLevel.INFO, 'newEndTime On conversion table: ' + sdc.New_End_Time__c.trim());
            
                if(oldStartTime == sdc.Old_Start_Time__c.trim() && oldEndTime == sdc.Old_End_Time__c.trim()){
                    
                    Time newStartTime = Time.newInstance(Integer.valueOf((sdc.New_Start_Time__c.trim()).subString(0, (sdc.New_Start_Time__c.trim()).indexOf(':'))), 
                                            Integer.valueOf((sdc.New_Start_Time__c.trim()).subString((sdc.New_Start_Time__c.trim()).indexOf(':')+1, (sdc.New_Start_Time__c.trim()).length())), 
                                            0, 0);
                    Time newEndTime = Time.newInstance(Integer.valueOf((sdc.New_End_Time__c.trim()).subString(0, (sdc.New_End_Time__c.trim()).indexOf(':'))), 
                                            Integer.valueOf((sdc.New_End_Time__c.trim()).subString((sdc.New_End_Time__c.trim()).indexOf(':')+1, (sdc.New_End_Time__c.trim()).length())), 
                                            0, 0);
                    app.Start__c = Datetime.newInstance((app.Start__c).date(), newStartTime); 
                    app.End__c = Datetime.newInstance((app.End__c).date(), newEndTime); 
                                        
                }
            
          }
        
    }
    
  }
   
   // CR For Diary Start & End Time Changes Ends
   */
    //Find distance between two postcodes
    //use the following links for more info on how to generate signatures using Unique Client Id and Crypto Key.
    // https://developers.google.com/maps/documentation/business/webservices#digital_signatures
    static integer check = 1;
    static list<Google_Reporting__c> glist = new list<Google_Reporting__c>();
    public static List<List<String>> findDistanceBetweenPostcodes(String origin, String destination,Date jobStartDate){
      if(system.label.Google_Switch=='on') 
      {
          
          
          List<List<String>> distancesAndTimesForAll = new List<List<String>>();
          List<String> distanceAndTimeForOne = new List<String>();
          // Google Base Url
          string GoogleBaseUrl = 'http://maps.googleapis.com';  
          // Actual API Domain URL. 
          string domain = '/maps/api/distancematrix/json?sensor=false&units=imperial';
            
          // Google Unique Client Id for CHI 
          string clientid = system.label.Google_Client_Id;
          DateTime dt = DateTime.newInstance(jobStartDate.year(), jobStartDate.month(), jobStartDate.day(), 08, 0, 0);
          Long departure_time = dt.getTime();
       //  String  departure_time=date.getTime() / 1000;
          String traffic_model ='best_guess';
          String mode='driving';
         // This part contains Source and Destination Poscodes, Get rid of spaces and replace them with +. or else request fails.
         string query = '&origins='+origin.replaceall(' ', '')+'&destinations='+destination.replaceall(' ', '')+'&departure_time='+departure_time+'&traffic_model='+traffic_model.replaceall(' ', '')+'&mode='+mode.replaceall(' ', '')+'&client='+clientid;
          //  string query = '&origins='+origin.replaceall(' ', '')+'&destinations='+destination.replaceall(' ', '')+'&client='+clientid;
          system.debug('Query---->'+query);
          
          // Google Unique Crypto Private Key this is used to Generate the Signature but not sent on Requesting API.
          string privateKey = system.label.Google_Crypto_Key;
          
          //Decoding Process of cryptoKey
          privateKey = privateKey.replace('-', '+');
          privateKey = privateKey.replace('_', '/');
          Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey);
        
          // Add Domain + CLient Id to create the signing URL
          string Requeststring = domain+query;
          //HMAC-SHA1 algorithm
          String algorithmName = 'hmacSHA1';
          //Generate Singaute using private key and Signing URL using HMAC-SHA1 algorithm.
          Blob signatureBlob = Crypto.generateMac(algorithmName,  Blob.valueOf(Requeststring), privateKeyBlob);
         
          // Encode signature to base64
          String signature =EncodingUtil.base64Encode(signatureBlob);
          signature = signature.replace('+', '-');
          signature = signature.replace('/', '_');
          
          //Add the signature to the requesting URL.
          string finalUrl = GoogleBaseUrl + Requeststring + '&signature='+signature;
          
          system.debug('Final Url-->'+finalUrl);
          Http obj_Http = new Http();
            
          HttpRequest http_Req = new HttpRequest();
          http_Req.setEndpoint(finalUrl);
          http_Req.setMethod('GET');
    
          http_Req.setTimeout(60000);  
          string responseBody;
          if(!Test.isRunningTest()){
          // Methods defined as TestMethod do not support Web service callouts
              HttpResponse http_Res = obj_Http.send(http_Req);
              responseBody = http_Res.getBody();
              system.debug(responseBody);
          }
         else {
          // default response for the test class..Dummy data
           responseBody = '{"destination_addresses" : [ "Neville Cl, Bolton BL1 2XR, UK" ],"origin_addresses" : [ "Caistor St, Stockport SK1 2LG, UK" ],"rows" : [{"elements" : [{"distance" : { "text" : "22.8 mi","value" : 36753 },"duration" : {"text" : "32 mins","value" : 1924},"duration_in_traffic" : {"text" : "36 mins","value" : 2178},"status" : "OK"}]}],"status" : "OK"}';
         }
          //system.debug('##debug http_res body'+http_Res.getBody());
          JSONParser parser = JSON.createParser(responseBody);
          system.debug('responseBody='+responseBody);
          while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'status'))
                {
                     parser.nextToken();
                     if(parser.getText() != 'OK')
                     {
                        distancesAndTimesForAll.add(new list<string>{'PC Error', ' PC Error', 'PC Error', 'PC Error'});
                     }
                }
              
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'distance')) {
                       for(Integer i = 0; i <= 15; i++ ){
                          if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'text' || parser.getText() == 'value') ) {
                                 parser.nextToken();
                                 distanceAndTimeForOne.add(parser.getText());
                                 if(distanceAndTimeForOne.size() == 6){
                                       distancesAndTimesForAll.add(distanceAndTimeForOne);
                                       distanceAndTimeForOne = new List<String>();
                                 }
                          }
                          parser.nextToken();
                       }
                 }
            }
          system.debug('@@@@--->'+distancesAndTimesForAll);
          
          glist.add(new Google_Reporting__c(Post_Code_Elements__c = origin.countMatches('+')*destination.countMatches('+')));
         
          if(check == 3)
          insert glist;
          else
          check ++;
          return distancesAndTimesForAll;
      }else
      return null;  
    }
   public void setErrorMsg(boolean flag, string message)
    {
        ApexPages.Message msg;
        if(flag)
        msg = new ApexPages.Message(Apexpages.Severity.error, message);
        else
        msg = new ApexPages.Message(Apexpages.Severity.info, message);
        ApexPages.addMessage(msg);
    }
    
    public static map<double, string> categoryMap = new map<double, string>{1=>'1-Vulnerable', 2=>'2-Emergency Non-op',3=>'3-Non-op',4=>'4-Operational',99=>''};
    // ++ Added for Dialler CR start
    public static set<String> defaultStatusReasonValues = new set<String> {'Gathering other quotes' , 'Planning to purchase elsewhere' , 'Price' , 'Still considering' , 'Affordability'};
    public static string defaultPreCallStatus = 'Pre-Call Dialler';
   // public static Set<String> profileNames = new Set<String> {'CHI Installation Lead Engineer','CHI Installation - DHM' ,'System Administrator','CHI Customer Manager'};
    // -- Added for Dialler CR end
    public static string nonOpCategory = 'Priority';
    
    
    
    public static set<string> fetchprofilenames(string names){
    
    set<string> pNames = new Set<String>();
    for(string name:names.split(',',0))
    {
        pNames.add(name);
        
    }
    return pNames;
    }
    
    public static map<string, list<string>> calcluateIndayJobTime(list<Search_Result__c> SearchList, string JobPostCode, string WeekId)
    {
        try{
        //try to find any Job bookings with those start date and end times
        map<string , decimal> PostCodeTimeMap = new map<string , decimal>();
        map<string, list<string>> jobEngineerTravelMap = new map<string ,list <string>>();
        map<string, set<Diary_Entry__c>> PostCodeEngineerMap = new map<string, set<Diary_Entry__c>>();
        map<string, Search_Result__c> diarySearchResult = new map <string, Search_Result__c>();
        
        system.debug('@@JobPostCode'+JobPostCode);
        string Destination ='';
        string sorucePc = JobPostCode.replaceall(' ', '');
        date jobStartDate;
        for(Search_Result__c s : SearchList)
        {
            
            Shift_Pattern__c sf = new Shift_Pattern__c(Monday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Monday_Start_Time__c, Monday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Monday_End_Time__c,
                                                        Tuesday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Tuesday_Start_Time__c, Tuesday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Tuesday_End_Time__c,
                                                        Wednesday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Wednesday_Start_Time__c, Wednesday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Wednesday_End_Time__c,
                                                        Thursday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Thursday_Start_Time__c, Thursday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Thursday_End_Time__c,
                                                        Friday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Friday_Start_Time__c, Friday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Friday_End_Time__c,
                                                        Saturday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Saturday_Start_Time__c, Saturday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Saturday_End_Time__c,
                                                        Sunday_Start_Time__c= s.Diary_Entry_ID__r.Week__r.Sunday_Start_Time__c, Sunday_End_Time__c = s.Diary_Entry_ID__r.Week__r.Sunday_End_Time__c);
            map<string, list<time>> ShiftTimeMap = DateTimeHelper.ShiftTimeMap(sf);
            
            list<Date> StartEndDates = DateTimeHelper.calcualteDateTimesForTravel(s.Start_Date_Time__c, s.End_Date_Time__c, ShiftTimeMap);
            
            system.debug('Start Date--->'+StartEndDates);
            
            date inday =  StartEndDates[0];
            date nextday = inday.adddays(1);
            
            Date EndDay = StartEndDates[1];
            Date nextEndDay = EndDay.addDays(1);
            system.debug('inday--->'+inday);
            system.debug('inday--->'+nextday);
            system.debug('End Day--->'+EndDay + '  '+nextEndDay);
            string week = s.Diary_Entry_ID__r.Week__c;
            
            
            if( WeekId!=null)
            week = WeekId;
            
            Diary_Entry__c prevEntry = new  Diary_Entry__c();
            
            map<string, set<Diary_Entry__c>> individualPostCodeEngineerMap = new map<string, set<Diary_Entry__c>>(); 
            
            for(Diary_Entry__c de : [select id,Start__c,End__c,Job__c, Job__r.Install_Postcode__c,Week__r.Employee__r.Name, Job__r.Installation_date__c from Diary_Entry__c where Week__c = :week and RecordTypeId = '012200000009ipQ' and ((Start__c< : nextday and End__c >= : inday) or (Start__c< : nextEndDay and End__c >= : EndDay)) order by Start__c])
            {
                
                jobStartDate = de.Job__r.Installation_date__c;
                individualPostCodeEngineerMap = new map<string, set<Diary_Entry__c>>();
                system.debug('In Day Job-->'+de);
                system.debug('IN day Job-->'+de.Job__r.Install_Postcode__c);
                system.debug('jobStartDate=='+jobStartDate);
                string destinationPc = de.Job__r.Install_Postcode__c.replaceall(' ', '');
               
                
                if(destinationPc==sorucePc)
                {   
                    if(prevEntry.Id != null)
                    individualPostCodeEngineerMap.put(prevEntry.Job__r.Install_Postcode__c.replaceall(' ', ''),new set<Diary_Entry__c> {prevEntry});
                    continue;
                    
                }   
                
                diarySearchResult.put(de.Id, s);
                
                if(de.Start__c>=s.End_Date_Time__c)
                {
                    system.debug('I am here----> 1');
                    set<Diary_Entry__c> prevoiusEntries = new set<Diary_Entry__c>();
                    // PRB00030533
                    if(prevEntry.Id!=null){
                    string prevent_despc = prevEntry.Job__r.Install_Postcode__c.replaceAll(' ','');
                    if(prevent_despc != destinationPc)
                    individualPostCodeEngineerMap.put(prevent_despc,new set<Diary_Entry__c> {prevEntry});
                    else{
                    prevoiusEntries.add(prevEntry);
                    }
                    }
                    // PRB00030533
                    
                    prevoiusEntries.add(de);
                    individualPostCodeEngineerMap.put(destinationPc, prevoiusEntries);
                    break;
                }else
                {
                        system.debug('I am here----> 3');
                    individualPostCodeEngineerMap.put(destinationPc, new set<Diary_Entry__c>{de});
                    prevEntry = de;
                }
           }
           
            if(individualPostCodeEngineerMap!=null) 
            for(string postcode: individualPostCodeEngineerMap.keyset())
            {
                set<Diary_Entry__c> furtherAddition = new set<Diary_Entry__c> ();
                if(PostCodeEngineerMap.containskey(postcode))
                {
                        system.debug('I am here----> 4');
                    furtherAddition = PostCodeEngineerMap.get(postcode);
                    furtherAddition.addall(individualPostCodeEngineerMap.get(postcode));
                    PostCodeEngineerMap.put(postcode,furtherAddition);
                    
                }else
                {
                        system.debug('I am here----> 5');
                    PostCodeEngineerMap.put(postcode,individualPostCodeEngineerMap.get(postcode));
                }
            }
            
        }
        system.debug('PostCodeEngineerMap-->'+PostCodeEngineerMap);
        list<string> postcodeList =  new list<string> ();
        Destination= '';
        
        for(string s: PostCodeEngineerMap.keyset())
        {
            Destination+=s+'|';
            postcodeList.add(s);
            
        }
        
        Destination = Destination.trim();
        system.debug('Job Address--->'+sorucePc);
        
        
        system.debug('  '+Destination);
        if(Destination !='' && sorucePc != ''&& jobStartDate!=null)
        {
        List<List<String>> distanceTime = Utilities.findDistanceBetweenPostcodes(sorucePc,Destination,jobStartDate);
        system.debug('distanceTime-->'+distanceTime);
       
        system.debug('postcodeList---->'+postcodeList);
        for(Integer i = 0; i < postcodeList.size(); i++){
        {
            decimal hrs =0.0;
            string timeString = distanceTime[i][2];
            string hrString, minString;
            if(timeString.contains('hours'))
            hrString = 'hours';
            else if(timeString.contains('hour'))
            hrString= 'hour';
            
            if(timeString.contains('mins'))
            minString = 'mins';
            else if(timeString.contains('min'))
            minString= 'min';
            //hrs = 0;
            if(hrString!=null)
            hrs = timeString.contains(hrString)? decimal.valueof(timeString.split(hrString)[0].trim()): 0.00;
            system.debug(hrString +' ' +hrs+''+minString +' '+timeString);
            
            decimal min;
            string secString;
            if(hrString !=null && timeString.contains(hrString))
            {
                secString = timeString.split(hrString)[1].trim();
                
            }else  if(minString!= null && timeString.contains(minString))
            {
                secString = timeString;
            }
            system.debug('secString--->'+secString);
            //min = 0;
            
            if(secString!=null)
            min = secString.contains(minString)? decimal.valueof(secString.split(minString)[0].trim()): 0.00;
            system.debug(minString +' ' +min);
            decimal totaltime = hrs+ (min/60);
            
            if(totaltime>0.1)
            PostCodeTimeMap.put(postcodeList[i],totaltime.setscale(2));
            else
            PostCodeTimeMap.put(postcodeList[i],0.1);
        }
                
        }
        system.debug('PostCodeTimeMap-->'+PostCodeTimeMap);
        for(string s : PostCodeTimeMap.keyset())
        {
            
            for(Diary_Entry__c de: PostCodeEngineerMap.get(s))
            {
                list<string> tempList = new list<string>();
                string direction;
                
                if(jobEngineerTravelMap.containskey(de.Week__r.Employee__r.Name))
                {
                    tempList= jobEngineerTravelMap.get(de.Week__r.Employee__r.Name);
                    
                }
                if(diarySearchResult.get(de.id).Start_Date_Time__c > de.Start__c)
                direction = 'Front';
                else
                direction = 'Back';
                
                
                tempList.add(de.Job__c +'/'+string.valueof(PostCodeTimeMap.get(s))+'/'+direction);
                
                jobEngineerTravelMap.put(de.Week__r.Employee__r.Name, tempList);
            }
            
        }
        
        }
        system.debug('jobEngineerTravelMap--->'+jobEngineerTravelMap);
        return jobEngineerTravelMap;    
        }catch(exception e)
        {
            system.debug('Exception while calculating the travel Time : '+e.getMessage() + ' Line number:'+e.getLineNumber());
            CreateEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'}, JSON.serializePretty(e) +'\n\n\n'+JSON.serializePretty(SearchList), 'Exception while calculating Travel time');
            
        }
        return null;
    }
    
    public static list<string> getLatLang (string Address, string pcode)
    {
        
         // Google Base Url
          string GoogleBaseUrl = 'http://maps.googleapis.com';  
          // Actual API Domain URL. 
          string domain = '/maps/api/geocode/xml?sensor=false&units=imperial';
            
          // Google Unique Client Id for CHI 
          string clientid = system.label.Google_Client_Id;
          
         // This part contains Source and Destination Poscodes, Get rid of spaces and replace them with +. or else request fails.
          string query = '&address='+Address+'&client='+clientid;
          system.debug('Query---->'+query);
          
          // Google Unique Crypto Private Key this is used to Generate the Signature but not sent on Requesting API.
          string privateKey = system.label.Google_Crypto_Key;
          
          //Decoding Process of cryptoKey
          privateKey = privateKey.replace('-', '+');
          privateKey = privateKey.replace('_', '/');
          Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey);
        
          // Add Domain + CLient Id to create the signing URL
          string Requeststring = domain+query;
          //HMAC-SHA1 algorithm
          String algorithmName = 'hmacSHA1';
          //Generate Singaute using private key and Signing URL using HMAC-SHA1 algorithm.
          Blob signatureBlob = Crypto.generateMac(algorithmName,  Blob.valueOf(Requeststring), privateKeyBlob);
         
          // Encode signature to base64
          String signature =EncodingUtil.base64Encode(signatureBlob);
          signature = signature.replace('+', '-');
          signature = signature.replace('/', '_');
          
          //Add the signature to the requesting URL.
          string finalUrl = GoogleBaseUrl + Requeststring + '&signature='+signature;
          
          system.debug('Final Url-->'+finalUrl);
          Http obj_Http = new Http();
            
          HttpRequest http_Req = new HttpRequest();
          http_Req.setEndpoint(finalUrl);
          http_Req.setMethod('GET');
    
          http_Req.setTimeout(60000);  
          HttpResponse http_Res = obj_Http.send(http_Req);
          System.debug('Response --->'+http_Res.getBody());
          string lat = BGProductHoldingServiceHelper.readXMLtemp(http_Res, 'lat', pcode);
          string lng = BGProductHoldingServiceHelper.readXMLtemp(http_Res, 'lng', pcode);
         
         return (new string[]{lat,lng});
        
    }
    
     // ++ CSI00003709 - Send consumable batch should not run on bank holidays changes starts
    public boolean isTodayBankHoliday(date holidayDate)
    {
        List<Holiday> holiday = [Select ActivityDate from Holiday where ActivityDate = :holidayDate];
        System.debug('********* holiday '+holiday);
        boolean returnFlag = false; 
        if(holiday.size() == 1)
        {
            returnFlag = true;
        }
        System.debug('********* returnFlag '+returnFlag);
        return returnFlag;
    }
    // -- CSI00003709 - Send consumable batch should not run on bank holidays changes ends
    
    public void handleExceptions(Exception e)
    {
        if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
        {
            list<string> error = e.getmessage().split(',');
            
            setErrorMsg(true, error[1]);
            
        }else
        {   
            setErrorMsg(true, e.getmessage());
        }  
    }
    
    public static String mogrifyJSON(String data,  Map<String, String> replacements) {
    // Regex to match the start of the line and the key
    // surrounded by quotes and ending with a colon
    String regexFormat = '(?m)^\\s*"{0}"\\s*:';
    
    // Replacement format of the new key surrounded by
    // quotes and ending with a colon
    String replacementFormat = '"{0}" :';
    
    /* A map of existing key to replacement key
    Map<String, String> replacements = new Map<String, String> {
        'date' => 'case_x'
    };*/
    
    // Since our JSON can come in formatted however the
    // endpoint wants, we need to format it to a standard
    // we know and can handle
    String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
    
    // Iterate over all the keys we want to replace
    for (String key : replacements.keySet()) {
        // Generate our regex based on the key
        String regex = String.format(
            regexFormat,
            new List<String> {key}
        );
        
        // Generate our replacement
        String replacement = String.format(
            replacementFormat,
            new List<String> {replacements.get(key)}
        );
        
        // Find all and replace
        formattedJSON = formattedJSON.replaceAll(regex, replacement);
    }
    
    return formattedJSON;
}
    Public static String popluateExternalId(OFS_Quota_Data__c newRec){
        String externalId ;
        system.debug('newRec='+newRec);
        if(newRec.External_ID__c==NULL){
                externalId=newRec.Activity_End_Time__c+'-'+
                newRec.Activity_Id__c+'-'+
                newRec.Activity_Start_Time__c+'-'+
                newRec.Activity_Status__c+'-'+
                newRec.Activity_Type__c+'-'+
                newRec.Activity_Work_Type__c+'-'+
                (newRec.AM_All_day_unavailabilities_hours__c != 0 ? String.ValueOf(newRec.AM_All_day_unavailabilities_hours__c) : '') +'-'+  
                newRec.RecordTypeId+'-'+
                (newRec.AM_Booked_activities__c != 0 ? String.ValueOf(newRec.AM_Booked_activities__c) : '') +'-'+  
                newRec.Bucket_Name__c+'-'+
                (newRec.AM_Capacity_Available_Hrs__c != 0 ? String.ValueOf(newRec.AM_Capacity_Available_Hrs__c) : '') +'-'+  
                newRec.Capacity_Category__c+'-'+
                (newRec.AM_Category_Booked_Time_Hrs__c != 0 ? String.ValueOf(newRec.AM_Category_Booked_Time_Hrs__c) : '') +'-'+  
                newRec.Closed_At_Category__c +'-' +
                newRec.Close_Time_Category__c +'-'+
                newRec.Category_status__c+'-'+
                //newRec.Date__c.year()+'-'+newRec.Date__c.month()+'-'+newRec.Date__c.day()+'-'+
                (newRec.Date__c != NULL ? String.valueOf(newRec.Date__c).substringBefore(' ') : '')+'-'+  
                newRec.Duration_Final__c+'-'+
                newRec.Employee_s_bucket__c+'-'+
                (newRec.AM_Internal_activities_hrs__c != 0 ? String.ValueOf(newRec.AM_Internal_activities_hrs__c) : '') +'-'+  
                (newRec.AM_Quota__c != 0 ? String.ValueOf(newRec.AM_Quota__c) : '') +'-'+  
                newRec.Quota_Percent__c+'-'+
                newRec.Slot_Type__c+'-'+
                newRec.Time_of_assignment__c+'-'+
                newRec.Time_of_booking__c+'-'+
                newRec.Time_Slot_label__c+'-'+
                (newRec.AM_Total_Available_Hrs__c != 0 ? String.ValueOf(newRec.AM_Total_Available_Hrs__c) : '') +'-'+  
                (newRec.AM_Total_Booked_Time_hrs__c != 0 ? String.ValueOf(newRec.AM_Total_Booked_Time_hrs__c) : '') +'-'+  
                (newRec.AM_Total_Quota__c != 0 ? String.ValueOf(newRec.AM_Total_Quota__c) : '') +'-'+  
                newRec.Work_Time_End_Text__c + '-' +
                newRec.Work_Time_End__c+'-'+
                newRec.Work_Time_Start_Text__c + '-' + 
                newRec.Work_Time_Start__c+'-'+
                newRec.Work_Zone__c+'-'+
                newRec.Work_Zone_Closed_At__c+'-'+
                newRec.Work_Zone_Close_Time__c ;
                }
     externalId=externalId.replaceALL('null', '');
        return externalId;
    }
    
    
    public static string makeQueryWithAllFields(string objectName, string whereCriteria){
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                //if (fd.isCreateable())
                { // field is creatable
                    selectFields.add(fd.getName()); 
                }
            }
        }
        
        String selects = '';
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}         
            
        }
        
        string finalQuery  = 'Select '+selects+' from '+objectName +' '+whereCriteria;
        return finalQuery;
    }
}