public with sharing class BookJobOptionController {

    public String optionID {get; set;}
    public List<Search_Result__c> results {get; set;}
    public List<SearchResult> WResults{get;set;}
     public List<SearchResult> WResultsSJR{get;set;}
    public List<Diary_Entry__c> booked {get; set;}
    public Boolean error {get; set;}
    public Boolean buttonClicked {get; set;}
    public Boolean platformCheck {get;set;} 
    public Date currentInstallDate {get;set;}
    public job__c ASPRequestItems{get;set;} 
    
    // ++ variable created for Smart Meter CR
    public Date currentInstallEndDate {get; set;}
    // -- variable created for Smart Meter CR
    public Decimal TotOBHours;//Calculate Total Over Book HOurs
    public String TotOBHors{get;private Set;}
    Public Boolean isOverbook{get;set;}
    public list<Search_result__c> Updres {get;set;}
    public Static string Msg1{get;set;}
    Public Map<Id,DateTime> EntMap;
    public boolean sucess{get;set;}
    //Added 10-08-2010
    //Parallel Run Enabled boolean value for Custom Label Parallel run switch
    public Boolean parallelRunEnabled {get;set;}
    public Static Final string electJob='electrical';
    public Static Final  string ttJob='travel time';
    public Boolean bookedRetrieved {get; set;}
    public String errorMsg {get; set;}
    public String bookingStatus {get; set;}
    //public ID jobID {get; set;}
    public ID jobID {get; set;}
    public Job__c job {get; set;}
     // Ashok : CR-001 4oct2010
    public string rerenderblocks {get; set;} 
    private Opportunity opp; 
    private Account DummyAcc; 
    public boolean DummyFlag {get; set;}
    public boolean ShowSPDetails {get; set;}
    // CR-001 Ends
    public List<String> strings {get; set;}
    public String strPlatform;
    public String labelValue = '';
    public  String USerid;
    public List<User> lst_user = new List<User>();
    //List<Opportunity> opp = new List<Opportunity>();
    public Opportunity oppObj = new Opportunity();
    
    // Send re-plan email CR starts
    public Date priorDeliveryDate {get;set;} 
    public Date priorInstallDate {get;set;} 
    public String priorDeliverySlot {get;set;}
    // Send re-plan email CR ends 
    public boolean overRideSMVal{get;set;}
    public boolean smValSwitch{get;set;}
    //SM PH II change start
    public boolean smFlag {get;set;}
    public boolean reason{get;set;}
    //SM Chnage end
    
    //Change CR 1410
    public string BookingDate{get;set;}
    public boolean reason1{get;set;}
    // End
    
    public boolean gdJob{get;set;}
    //google distacne finder change
    public string trav_Dist{get;set;}
    public string trav_Time{get;set;}
    public Job_Planning_History__c JPH {get;set;}
    public String oldStatus;
    public String oldSubStatus;
    public date originaldate;
    public date newdate;
   //GeoCoding
    public string instAdd{get;set;}
    public string customerAdd{get;set;}
    
    public boolean overBook {get;set;}
    public boolean inputOverbook {get;set;}
    boolean dontCaltrav;
    
    //code added to auto update service level
    public string serviceLevel{get;set;}
    public string serviceLevelReason{get;set;}
    public boolean withinStandard{get;set;}
    public List<SelectOption> SL{get;set;}
    public List<SelectOption> SLR{get;set;}  
    
     
    //code added for failed install on day
    public boolean showFailedInstallDetails{get;set;}    
    public Failed_Install__c failedInstall{get;set;}
    public List<Diary_Entry__c> TravelDE{get;set;}
    
    Public static DateTime startTimeOfJob;
    public boolean pgb{get;set;}
    public boolean confrm{get;set;}
    public string title{get;set;}
    public string isplan{get;set;}
    public boolean plan{get;set;}
    public boolean jDone{get;private set;}
    Date NewInstallationDate;
    public string cstDate{get;set;}
    //public string custdate{get;set;}
    // NWD Change
    public List<Diary_Entry__c> NonWorkingDiaryEntries;
    //Wrapper Class to store The Search Results
    public class searchResult{
       Public Search_Result__c result{get;set;}
       public string EmpName{get;set;}
       public string DEName{get;set;}
       public Decimal DEHours{get;set;}
       public Id WeekID;
       public searchResult(Search_result__c sr,string empName1,string DEName1,Decimal DEHours1,string WID){
         
         result=sr;
         EmpName= empName1;
         DEName= DEName1;
         DEHours= DEHours1;
         WeekID = WID;
       } 
    
    }
        
    boolean ownLabourJob =false;

    string gapNames;// {get;set;}
    string gapHours;// {get;set;}
    list<string> gapEngNames;// {get;set;}
    list<decimal> gapEngHours;//{get;set;}
    map<string, decimal> engGapMap;//{get;set;}

    public BookJobOptionController() {
        gapNames = ApexPages.currentPage().getParameters().get('gapname');
        gapHours = ApexPages.currentPage().getParameters().get('gaphours');

        if(gapNames!=null )
        {
          gapEngNames = new list<string>();
          if(gapNames.contains('/'))
          {
            for(string s: gapNames.split('/'))
            gapEngNames.add(s.contains(' *SR*')? s.substring(0, s.length()-4).trim():s.trim());
          }else{
            gapEngNames.add(gapNames.contains(' *SR*')? gapNames.substring(0, gapNames.length()-4).trim():gapNames.trim());
          }

        }

        if(gapHours!=null )
        {
          gapEngHours = new list<decimal>();
          if(gapHours.contains('/'))
          {
            for(string s : gapHours.split('/'))
            gapEngHours.add(decimal.valueof(s.trim()));
          }else 
          {
            gapEngHours.add(decimal.valueof(gapHours.trim()));
          }

        }
        if(gapEngNames!=null && gapEngHours!=null && gapEngNames.size() == gapEngHours.size())
        {
          engGapMap = new map<string, decimal>();
          for( integer i =0;i< gapEngNames.size();i++)
          {
            engGapMap.put(gapEngNames[i], gapEngHours[i]);
          }
        }

        cstDate = '12/07/2016';
        showFailedInstallDetails = false;
        withinStandard = false;
        overRideSMVal = false;
        smValSwitch = false;
        error = false;
        buttonClicked = false;
        bookedRetrieved = false;
        DummyFlag = false;
        inputOverbook = false;
        pgb=True;
        confrm= False;
        jDone = FALSE;
        Title = 'Book Job Details';
        cstDate = '';
        sucess = false;
        optionID = ApexPages.currentPage().getParameters().get('optionId');
        isplan = ApexPages.currentPage().getParameters().get('p');
       
        // jobID = ApexPages.currentPage().getParameters().get('jobId');
        //system.debug('optionID: ' + optionID);
        BookingDate = ApexPages.currentPage().getParameters().get('date'); // CR 1379
        WResultsSJR=new List<SearchResult>(); 
        job = new Job__c(Delivery_Date__c = Date.today());
        strings = new List<String>{'one', 'two', 'three'};
        //google distacne finder change
        trav_Dist = ApexPages.currentPage().getParameters().get('dist');
        trav_Time = ApexPages.currentPage().getParameters().get('time');
        JPH = new Job_Planning_History__c();        
        overBook = false;    
        string ts = ApexPages.currentPage().getParameters().get('ts');
        dontCaltrav = false;
        if(ts=='true')
        dontCaltrav = true;
        SL = new List<selectOption>();
        SLR = new List<selectOption>(); 
        WResults = new List<SearchResult>();  
          
    }
    
 // Added by Prashant June 2012 for Priority Installations CR start
    public boolean include_priority_install {get; set;}
    // Added by Prashant June 2012 for Priority Installations CR end  
    
    Utilities utilClass = new Utilities();
   
    //code added for failed install on day
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Failed_Install__c.FieldSets.FailedInstallDetails.getFields();
    }
    
    public list<Schema.FieldSetMember> jobFields {get {return sObjectType.Job__c.FieldSets.HSAfields.getFields();}}
    
   
    /*public Failed_Install__c getFailedInstall() {
        Failed_Install__c f = new Failed_Install__c();
        return f;      
    }
    
    public Failed_Install__c setFailedInstall() {
        Failed_Install__c f = new Failed_Install__c();
        return f;      
    }*/

        
    public void populateResults() {
             map<string, list<decimal>> engineerHours = new map<string, list<decimal>>();
             map<string, dateTime> engineerStart = new map<string, datetime>();
             boolean travelTimeMoreThan_1 = false;

              reason=false;
              reason1=false;
              parallelRunEnabled=false;
              platformCheck = false;
               Decimal engOne=0,engOneDEhours,engTwoDEhours,engTwo=0,engDefault;
               string engOneStartTime;
               string engTwoStartTime;
              
              //TravelDE = new list<Diary_Entry__c>();
                if(optionID == null) {
                    error = true;
                    errorMsg = 'No optionID found';
                    //system.debug('No optionID found');
                } else {
                 jobID = ApexPages.currentPage().getParameters().get('jobId');
                   job = [select ID,PTS_Rollout__c, name,DPA_Done__c, CHI_Lead__r.Install_Postcode__c,Install_Street__c, Install_City__c, Installation_Date__c, Needs_Re_Planing__c,Sent_text_to_customer__c, Latest_customer_category_indicator__c,Latest_customer_category__c,
                          Customer_journey_status_index__c, CHI_Lead__c,Split_Job__c, Is_Remedial_Job__c, Is_Downtime_Job__c,Refused_Earlier_Date__c,skip_8_12_Rule__c,Squeeze_Job__c,Exception_reason__c,Exception_Required__c,Reason__c,Who_in_Field_Engaged__c,Start_Data_Time__c,S_P_Hours__c,Named_Employee__c,Named_Employee_2__c,
                          CHI_Lead__r.Account.Dummy_Data__c, Delivery_Slot__c, Delivery_Date__c,CHI_Lead__r.isSystem__c,Delivery_Notes__c,customer_name__c,CHI_Lead_Number_Text__c,Address__c,CHI_Lead_Name__c,
                          CRD_Code__c,Job_Reason__c,SMInstalltionTime__c,Created_By_Profile__c,Quote__r.Product_Type_ID__c,Engineer_Spoken_To__c,
                          Mechanical_Hours__c,PowerFlush_Hours__c,Electrical_Hours__c,Building_Work_Hours__c,Remote_Heating__c ,Roof_Work_Hours__c,ECO_Hours__c ,Specialist_Building_Hours__c, Connect_Solar_Panel_Hours__c ,
                          Contractor_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,LPG_Installation_Hours__c,Payment_Collection_Hours__c,Ecogen_Mechanical_Hours__c, 
                          Scaffolder_Hours__c ,Unvented_Hot_Water_Hours__c ,Water_Heating_Fixing_Hours__c ,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,
                          Ecogen_Electrical_Hours__c,Landlord_Check_Hours__c,Boiler_Location__c,Installation_Type__c,CHI_Lead__r.CHI_Lead_ID__c,
                          CHI_Lead__r.Installation_opt_out_reason__c,CHI_Lead__r.Installation_Opt_Out_Type__c,CHI_Lead__r.Createddate,
                          CHI_Lead__r.Latest_customer_category__c,CHI_Lead__r.Customer_have_any_other_form_of_HEAT__c,CHI_Lead__r.Date_and_time_job_planned__c,
                          CHI_Lead__r.Does_the_customer_have_hot_water__c,CHI_Lead__r.Is_the_customers_boiler_working__c,CHI_Lead__r.Is_the_customer_vulnerable__c,
                          CHI_Lead__r.Vulnerable_reason__c,Green_Deal__c,GDA_Date__c,GDMIDASRefNumber__c,Status__c,Sub_Status__c,not_booked__c,Job__c.Multiple_Re_Plans__c,
                          (Select s.Start_Date_Time__c, s.Skill__c, s.Option_Identifier__c, s.Name, s.Job_ID__c, s.Id, 
                           s.Hours__c, s.End_Date_Time__c, s.Diary_Entry_ID__c, s.Diary_Entry_ID__r.Week__r.Employee__r.Name,
                           s.Diary_Entry_ID__r.Hours__c, Own_Labour__c,s.Diary_Entry_ID__r.End__c,s.Diary_Entry_ID__r.Name, s.Diary_Entry_ID__r.Week__r.Employee__r.Postcode__c
                           ,s.Diary_Entry_ID__r.Week__r.Employee__r.Supplier_Branch_Num__c,s.Diary_Entry_ID__r.Type__c,s.Diary_Entry_ID__r.Week__r.Employee__r.Id,
                           s.Diary_Entry_ID__r.Week__r.Monday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Monday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Tuesday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Tuesday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Wednesday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Wednesday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Thursday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Thursday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Friday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Friday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Saturday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Saturday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Sunday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Sunday_End_Time__c,s.Diary_Entry_ID__r.Week__c
                           From SearchResults__r s where Option_Identifier__c = :optionID 
                           order by s.Start_Date_Time__c ASC,s.Diary_Entry_ID__r.Week__r.Employee__c, s.Skill__c),                     
                          Engineer_Working_NWD__c, CreatedDate,quote__r.closeDate__c, Bring_Forward_Job__c
                          from Job__c where ID = :jobID];
                                 oldStatus = job.Status__c;
                    oldSubStatus=job.Sub_Status__c;
                    /*
                    job.Exception_reason__c='';
                    job.Exception_Required__c='';
                    job.Rule_Broken_By__c='';
                   
                    update job;
                    */
                    //getting old installation date 
                    originaldate=job.Installation_Date__c;
                    //system.debug('----##previous Installation date:'+originaldate);
                                        
                    if(oldStatus!='Pending')
                    {
                    reason=true;
                    }
                   //system.debug('-=-=-=-=-=-=-=-=-=-=DeliverYDate:'+job.Delivery_Date__c); //2016-04-03 00:00:00
                   if(job.Delivery_Date__c != null)
                   cstDate = job.Delivery_Date__c.format();
 
                     //CR 1379 start - by Ashok G
                   if(originaldate!=NULL){
                        NewInstallationDate = (Date)date.valueof(Bookingdate.substring(6,10) + '-' + Bookingdate.substring(3,5) + '-' +Bookingdate.substring(0,2));
                        //system.debug('----##New Installation date:'+ NewInstallationDate);
                        if(NewInstallationDate > originaldate)
                            JPH.Direction2__c = 'Future';
                        else if (NewInstallationDate == originaldate)
                        JPH.Direction2__c = 'Same Day';
                        else
                            JPH.Direction2__c = 'Past';
                            
                    }
                    //CR 1379 END
                  
                    if(isplan == 'N')
                    plan=TRUE;
                    else
                    plan = False;
                    
                    customerAdd = Job.CHI_Lead__r.Install_Postcode__c;
                     string postcode = job.SearchResults__r[0].Diary_Entry_ID__r.Week__r.Employee__r.Postcode__c;
                     instAdd = (postcode!=null ? postcode:'');   

                    string street = job.Install_Street__c!=null?job.Install_Street__c.normalizeSpace().replaceall(' ','+').trim():'';
                    string city = job.Install_City__c!=null ? job.Install_City__c.normalizeSpace().replaceall(' ','+').trim():'';
                    string pcode = job.CHI_Lead__r.Install_Postcode__c!=null?job.CHI_Lead__r.Install_Postcode__c.normalizeSpace().replaceall(' ','+').trim():'';
          
                    string Address = street + '+'+city+ '+' +pcode;
                    try{
                        list<string> Latlang = Utilities.getLatLang(Address,pcode);
                        if(Latlang.size()==2)
                        {
                            job.Latitude__Latitude__s = double.valueof(Latlang[0]);
                            job.Latitude__Longitude__s = double.valueof(Latlang[1]);
                            job.Longitude__Latitude__s = double.valueof(Latlang[0]);
                            job.Longitude__Longitude__s =  double.valueof(Latlang[1]);
                        }   
                    }catch (Exception e)
                    {
                        
                    }

                     // Green Deal Change : Start  
                     gdJob=false;
                     if(job.Green_Deal__c != 'None')
                     gdJob = true;   
                    // Green Deal Change : End
                    // Storing Results in Wrapper Class
                    //system.debug(LoggingLevel.INFO+'--------delivery-->'+job.delivery_date__c);
                  
                    for(Search_Result__c sr: job.SearchResults__r){
                       //system.debug(LoggingLevel.INFO,'-----results.size()------'+job.SearchResults__r[0].Diary_Entry_ID__r.Week__r.Employee__r.Name);
                       //system.debug(LoggingLevel.INFO,'-----results.size()------'+sr.Diary_Entry_ID__r.Hours__c);

                       searchResult sr1 = new searchResult(sr,sr.Diary_Entry_ID__r.Week__r.Employee__r.Name,sr.Diary_Entry_ID__r.Name,sr.Diary_Entry_ID__r.Hours__c,sr.Diary_Entry_ID__r.Week__c);
                       WResults.add(sr1);
                        //
                        if(sr.Skill__c == 'MECHANICAL' ){
                            startTimeOfJob=sr.Start_Date_Time__c;
                            if(sr.Diary_Entry_ID__r.Week__r.Employee__r.Supplier_Branch_Num__c=='2017')
                            ownLabourJob = true;
                        }
                       
                    }
                    //results = job.SearchResults__r;
                    
                    //system.debug(LoggingLevel.INFO,'-----results------'+Wresults);
                    //system.debug(LoggingLevel.INFO,'-----results.size()------'+Wresults.size());
                    ////system.debug(LoggingLevel.INFO,'-----results.size()------'+job.SearchResults__r[0].Diary_Entry_ID__r.Week__r.Employee__r.Name);
                    map<string, Search_Result__c> engSearhResultMap = new  map<string, Search_Result__c>();
                     
                   
                    if(Wresults != null && Wresults.size()>0)
                    { 
                       //system.debug('--'+Wresults[0].result.Start_Date_Time__c+'--'+Wresults[0].result.End_Date_Time__c);
                       DateTime lowestStartDateTime = Wresults[0].result.Start_Date_Time__c;
                       // ++ Added for Smart Meter CR
                       DateTime lowestEndDateTime = Wresults[0].result.End_Date_Time__c;
                       // -- Added for Smart Meter CR
                       Double mechMaxHours = Wresults[0].result.Hours__c;
                       //***************** NWD Change Start *****************
                       List<Id> weekId = new list<Id>();
                       NonWorkingDiaryEntries= new List<Diary_Entry__c>();
                       
                       //***************** NWD Change End *****************
                      
                       for(SearchResult s : Wresults){
                           
                              weekId.add(s.result.Diary_Entry_ID__r.Week__c);
                              
                              if(s.result.Start_Date_Time__c < lowestStartDateTime){
                                   lowestStartDateTime = s.result.Start_Date_Time__c;
                              }
                              // ++ Added for Smart Meter CR
                              if(s.result.End_Date_Time__c > lowestEndDateTime)
                              {
                                lowestEndDateTime = s.result.End_Date_Time__c;
                              }
                              // -- Added for Smart Meter CR
                              if(s.result.Skill__c.equalsIgnoreCase('MECHANICAL') && s.result.Hours__c >= mechMaxHours){
                                 mechMaxHours = s.result.Hours__c;
                              }
                              
                              if(s.result.Skill__c=='ELECTRICAL')
                          {
                            job.Named_Electritian__c=s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id;
                            

                          }
                              // in case of refresh of page. Where we already calculated Travel then dont do it one more time.
                              if(s.result.Skill__c.equalsIgnoreCase('Travel Time'))
                              dontCaltrav = true;
                              
                              if(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Supplier_Branch_Num__c=='2017')
                              {
                                string EngName = s.result.Diary_Entry_ID__r.Week__r.Employee__r.Name;
                                if(engSearhResultMap.containskey(EngName))
                                {
                                  if(engSearhResultMap.get(EngName).Diary_Entry_ID__r.End__c <s.result.Diary_Entry_ID__r.End__c)
                                   engSearhResultMap.put(EngName, s.result);
                                }else
                                engSearhResultMap.put(EngName, s.result);
                                
                              


                              /*
                                Logic to find rule breaks.
                              */
                              if(!(s.result.Skill__c.equalsIgnoreCase('Electrical') || s.result.Skill__c.equalsIgnoreCase('Travel Time') || 
                                   s.result.Skill__c.equalsIgnoreCase('Specialist Building') ||  s.result.Skill__c.equalsIgnoreCase('Roof Work')))
                              {
                                decimal totalHours =s.result.Hours__c;
                                decimal totalAvailableHrs = s.DEhours;
                                system.debug('s.result.Diary_Entry_ID__r.Week__r.Employee__r.Name-->'+s.result.Diary_Entry_ID__r.Week__r.Employee__r.Name);
                                if(engGapMap!=null && engGapMap.containsKey(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Name))
                                {
                                  totalAvailableHrs = engGapMap.get(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Name);
                                }

                                if(engineerHours.containskey(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id))
                                {

                                  totalHours += engineerHours.get(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id)[0];
                                }
                                engineerHours.put(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id, new list<decimal>{totalHours,totalAvailableHrs});

                                if(!engineerStart.containskey(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id))
                                engineerStart.put(s.result.Diary_Entry_ID__r.Week__r.Employee__r.Id, s.result.Start_Date_Time__c);
                              }
                          }

                       }
              system.debug('SP Change -->'+engineerHours);         
                       
              NonWorkingDiaryEntries = [Select id,Start__c, End__c,Week__c  from Diary_Entry__c where Week__c in:weekId And  Sub_Type__c = 'NWD - Working' ];
              //system.debug('@@NonWorkingDiaryEntries'+NonWorkingDiaryEntries);
                       
                       
                       
               //system.debug('-----engSearhResultMap-------'+engSearhResultMap);
               currentInstallDate = lowestStartDateTime.Date();
               // ++ Added for Smart Meter CR
               currentInstallEndDate = lowestEndDateTime.Date();
                       // -- Added for Smart Meter CR
                       
                  //code added for failed install on day
                  //system.debug('###FieldSet###'+job.Status__c+job.Installation_Date__c+currentInstallDate+job.Sub_Status__c);                  
                  if(job.Installation_Date__c!= NULL && job.Status__c!= NULL && currentInstallDate!= NULL && job.Sub_Status__c!=NULL)
                  if(job.Installation_Date__c <= system.today() && job.Installation_Date__c < currentInstallDate  && ((job.Status__c=='Pending' && job.Sub_Status__c=='ASP Added' )|| job.Status__c=='Planned' )){
                      //system.debug('###FieldSet###');
                      showFailedInstallDetails = true;   
                      failedInstall = new Failed_Install__c(Job__c=job.id,date_failed__c = System.today());
                  }                  
                  
                  //code to Auto update 'Service Level'
                   Job_Category__c jc = Job_Category__c.getInstance('StandardTimeToPlanJob');
                   
                   SL = new List<selectOption>();
                   SL.add(new selectOption('-NONE-','-NONE-'));
                   SL.add(new selectOption(Label.Not_Within_Standard,Label.Not_Within_Standard));
                   SL.add(new selectOption(Label.Customer_Requested,Label.Customer_Requested));
                   SL.add(new selectOption(Label.Green_Deal,Label.Green_Deal));
                   serviceLevel  = job.Job_Reason__c ;
                   fetchSLR();
                   serviceLevelReason  = job.CRD_Code__c ;
                   
                   
                   /*//system.debug('###category###'+job.Latest_customer_category__c);
                   //system.debug('###category 1###'+job.quote__r.closeDate__c.daysBetween(currentInstallDate)<=jc.Category_1__c.format());  
                   //system.debug('###category 2###'+job.quote__r.closeDate__c.daysBetween(currentInstallDate)<=jc.Category_2__c.format());  
                   //system.debug('###category 3###'+job.quote__r.closeDate__c.daysBetween(currentInstallDate)<=jc.Category_3__c.format());  
                   //system.debug('###category 4###'+job.quote__r.closeDate__c.daysBetween(currentInstallDate)<=jc.Category_4__c.format());  */
                   
                   Date sellDate;
                        if(job.quote__r.closeDate__c!=NULL)
                            sellDate = job.quote__r.closeDate__c;
                        else
                            sellDate = System.today();
                       //system.debug('####sellDate###'+sellDate ); 
                       if(currentInstallDate!=Null){
                           //system.debug(job.Installation_Date__c+ ' ' +currentInstallDate);
                          if(job.Installation_Date__c!=null && job.Installation_Date__c == currentInstallDate){
                               //withinStandard = true;
                               serviceLevel  = job.Job_Reason__c ;
                               withinStandard = true;
                               serviceLevelReason  = job.CRD_Code__c ;
                           }else  if((job.Latest_customer_category__c == '1' && sellDate.daysBetween(currentInstallDate)<=jc.Category_1__c)
                           || (job.Latest_customer_category__c == '2' && sellDate.daysBetween(currentInstallDate)<=jc.Category_2__c)
                           || (job.Latest_customer_category__c == '3' && sellDate.daysBetween(currentInstallDate)<=jc.Category_3__c)
                           || (job.Latest_customer_category__c == '4' && sellDate.daysBetween(currentInstallDate)<=jc.Category_4__c)){
                               //system.debug('###INIF###');
                               withinStandard = true;
                               serviceLevel = 'Within Standard';
                               serviceLevelReason = 'Within Standard';
                               job.Job_Reason__c = 'Within Standard';
                               job.CRD_Code__c = 'Within Standard'; 
                           }
                       }
                     
                   //system.debug(Logginglevel.INFO,'===debugPriti2==='+dontCaltrav+withinStandard+serviceLevel+serviceLevelReason+SL+SLR); 
                    
                    
                       // Inday Engineer Travel Code
                       if(system.label.JobPlan_Eng_Travel == 'on' && !dontCaltrav)
                       {  
                        //system.debug(Logginglevel.INFO,'I am INSIDE');
                         Set<string> TravelJob = new set<string>();
                         try{
                         map<string, Search_Result__c> RecalengSearhResultMap = new  map<string, Search_Result__c>();  
                         map<string, list<string>> indayJobTime = Utilities.calcluateIndayJobTime(engSearhResultMap.values(),job.CHI_Lead__r.Install_Postcode__c,null);
                         //system.debug(Logginglevel.INFO,'Engineer in Day Travel -->'+indayJobTime);
                         /*
                               Map formet for indayJobTime:
                               
                               Employee Name----> connecting JOB ID/Travel Time/Direction
                               
                         */
                         list<SearchResult> travelTimeSr = new list<SearchResult>();
                         map<string, datetime> engEndNew  = new map<string, datetime>();
                         //system.debug(Logginglevel.INFO,'indayJobTime--->'+indayJobTime);
                         datetime endNew;
                         for(string s : indayJobTime.keyset())
                         {
                             //system.debug('For Engoneer-->'+s);
                             endNew = null;
                             datetime potentialEnd;
                             //Diary_Entry__c Avail = new Diary_Entry__c();
                             Datetime BlackBoxEndtime = engSearhResultMap.get(s).End_Date_Time__c;
                             
                             potentialEnd =BlackBoxEndtime;
                             try{
                              for(Diary_Entry__c Avail  : [Select id, End__c, Start__c,Record_Type__c,Job__c from Diary_Entry__c where Week__c = : engSearhResultMap.get(s).Diary_Entry_ID__r.Week__c and End__c >= :engSearhResultMap.get(s).End_Date_Time__c order by End__c])
                              {
                                //system.debug('Fecthed Avail--- >'+Avail);
                                if(Avail.Record_Type__c == 'Non Productive Job Booking')
                                continue;
                                if(Avail.Record_Type__c == 'Availability' || (Avail.Record_Type__c=='Job Booking' && Avail.Job__c == job.Id))
                                potentialEnd = Avail.End__c;
                                else
                                break;
                               }
                              }catch (Exception e)
                             {
                               
                             }
                              
                             Search_Result__c src = engSearhResultMap.get(s);
                              Diary_Entry__c de = [select id , Week__r.Monday_Start_Time__c,
                              Week__r.Monday_End_Time__c,Week__r.Tuesday_Start_Time__c,
                              Week__r.Tuesday_End_Time__c,Week__r.Wednesday_Start_Time__c,
                              Week__r.Wednesday_End_Time__c,Week__r.Thursday_Start_Time__c,
                              Week__r.Thursday_End_Time__c,Week__r.Friday_Start_Time__c,
                              Week__r.Friday_End_Time__c,Week__r.Saturday_Start_Time__c,
                              Week__r.Saturday_End_Time__c,Week__r.Sunday_Start_Time__c,
                              Week__r.Sunday_End_Time__c from Diary_Entry__c where id = :src.Diary_Entry_ID__c];
                                      
                                    
                             decimal overBk =0.0;
                             boolean needRec = false;
                              for(string r: indayJobTime.get(s))
                              {
                                      
                                      //system.debug('For Job-->'+r);
                                      string[] infoList = r.split('/');
                                      
                                      decimal ttime = decimal.valueof(infoList[1]).setscale(2);
                                      
                                      // Calculate new End time for the Employee after TT
                                      //system.debug('Before -->'+BlackBoxEndtime+'  '+ttime+ '  '+ potentialEnd);
                                      ttime = ttime.setscale(2);
                                      
                                      
                                      dateTime TravelEnd = DateTimeHelper.addWorkingHoursToDateTime(engSearhResultMap.get(s).Start_Date_Time__c, double.valueof(ttime), de);
                                      
                                      //system.debug(LoggingLevel.INFO,'Before End NEw-->'+endNew+' '+travelEnd);
                                      if(endNew==null)
                                      {
                                        TravelEnd.date();
                                        //system.debug('TravelEnd-->'+Date.valueof(TravelEnd)+'  '+TravelEnd.date()+'engSearhResultMap.get(s).Start_Date_Time__c'+engSearhResultMap.get(s).Start_Date_Time__c.date()+'   '+TravelEnd.date().daysBetween(engSearhResultMap.get(s).Start_Date_Time__c.date()));
                                        if(engSearhResultMap.get(s).Start_Date_Time__c.date().daysBetween(TravelEnd.date())>0)
                                        {
                                          utilClass.setErrorMsg(true, 'Job Start time including travel is too late. Booking not allowed.');
                                          buttonClicked = true;
                                          smFlag = false;
                                        }
                                        //system.debug('**********in if*******************');
                                        //system.debug(LoggingLevel.INFO,'===========>'+BlackBoxEndtime +'   '+ttime+'   '+de);
                                        
                                        endNew = DateTimeHelper.addWorkingHoursToDateTime(BlackBoxEndtime, double.valueof(ttime), de);
                                        
                                      }
                                      else
                                      {
                                        //system.debug('**********in else*******************');
                                        //system.debug(endNew +''+ttime+''+de);
                                        endNew = DateTimeHelper.addWorkingHoursToDateTime(endNew, double.valueof(ttime), de);
                                      }
                                      //system.debug('------endNew-------'+endNew);
                                     
                                     // engEndNew.put(src.Diary_Entry_ID__r.Week__r.Employee__r.Name, endNew);
                                      
                                      //system.debug('****'+engEndNew);
                                      /*
                                        *****************OVER BOOKING in TT*********************
                                        Availability fetched from black box search might not be sufficient after calcuation TT. 
                                        So compare the new End time with the diary entry End time and calcualte the over booking accordingly.
                                        
                                      */
                                      //system.debug('@@@@'+endNew+'@@@'+potentialEnd);
                                      
                                      /*
                                        Check due to travel time our end is moving in to next day.. due to which we might have to re 
                                        check the inday jobs for next day.
                                      
                                      if(BlackBoxEndtime.date().daysbetween(endNew.date())>0)
                                      {
                                        //system.debug('***in Recalculate*******');
                                        needRec = true;
                                      }*/
                                      
                                      if(endNew > potentialEnd)
                                      {
                                        overBk += DateTimeHelper.calculateHours(potentialEnd,endNew, de);
                                          overBk = overBk.setscale(2);
                                          endNew = potentialEnd;
                                          engEndNew.put(src.Diary_Entry_ID__r.Week__r.Employee__r.Name, endNew);
                                          //system.debug('Overbook----'+overBk +'---'+endNew);
                                      }else
                                      {
                                        if(BlackBoxEndtime.date().daysbetween(endNew.date())>0)
                                        {
                                          //system.debug('***in Recalculate*******');
                                          needRec = true;
                                        }
                                      }
                                      
                                      
                                      //system.debug('Final End New---->'+endNew);
                                      if(!TravelJob.contains(infoList[0]+s+infoList[2]))
                                      {
                                        //Change BY ASHOK G
                                        /*Diary_Entry__c TravDE = new Diary_Entry__c();
                                        TravDE.End__c=endNew;
                                        TravDE.Start__c = engSearhResultMap.get(s).Start_Date_Time__c;
                                        TravDE.Week__c = engSearhResultMap.get(s).Diary_Entry_ID__r.Week__c;
                                        TravDE.Travel_Job__c = infoList[0];
                                        TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                                        TravDE.Sub_Type__c = 'Travel Time';
                                        TravDE.Job__c = engSearhResultMap.get(s).Job_ID__c;
                                        TravDE.Hours__c = decimal.valueof(infoList[1]);
                                        TravelDE.add(TravDE);
                                        //system.debug(LoggingLevel.INFO,'------->'+TravDE);
                                     */
                                     
                                      Search_Result__c sr = new Search_Result__c();
                                      sr.Start_Date_Time__c = src.Start_Date_Time__c;
                                      sr.Skill__c = 'Travel Time';
                                      sr.Option_Identifier__c = src.Option_Identifier__c;
                                      sr.Job_ID__c= src.Job_ID__c;
                                      sr.Hours__c= decimal.valueof(infoList[1]);
                                      sr.End_Date_Time__c= endNew;
                                      sr.Diary_Entry_ID__c= src.Diary_Entry_ID__c;
                                      sr.order__c = infoList[2];
                                      sr.Travel_Job__c = infoList[0];
                                      travelTimeSr.add(new searchResult(sr,null,null,0.0,null));
                                      //system.debug(LoggingLevel.INFO,'============>'+sr.Diary_Entry_ID__c);

                                      if(sr.Hours__c>Decimal.valueof(system.label.SJR_Travel_Time_Tolerance))
                                      travelTimeMoreThan_1 = true;
                                      /*if(needRec)
                                      {
                                        string EngName = src.Diary_Entry_ID__r.Week__r.Employee__r.Name;
                                      if(RecalengSearhResultMap.containskey(EngName))
                                      {
                                        if(RecalengSearhResultMap.get(EngName).End_Date_Time__c <sr.End_Date_Time__c)
                                         RecalengSearhResultMap.put(EngName, sr);
                                      }else
                                      RecalengSearhResultMap.put(EngName,sr);
                                      }*/
                                      TravelJob.add(infoList[0]+s+infoList[2]);
                                      }
                              }
                              // Add overbooking error message for every employee where overbooking is calculated.
                             /* if(overBk>0 && !buttonClicked) 
                              {
                                utilClass.setErrorMsg(true, 'Needs Over Overbooking for '+s+' due to Travel by: '+overBk+' Hours');
                                overBook = true;
                              }  
                              */
                         }
                        /* if(RecalengSearhResultMap.size()>0)
                         {
                           //system.debug(LoggingLevel.INFO,'************IN RECACULATE**********************');
                           for(string engname : RecalengSearhResultMap.keyset() )
                           
                             indayJobTime = Utilities.calcluateIndayJobTime(RecalengSearhResultMap.values(),job.CHI_Lead__r.Install_Postcode__c,engSearhResultMap.get(engname).Diary_Entry_ID__r.Week__c );
                             for(string s : indayJobTime.keyset())
                             {
                               endNew = null;
                               datetime potentialEnd;
                               Diary_Entry__c Avail = new Diary_Entry__c();
                               Datetime BlackBoxEndtime = engSearhResultMap.get(s).End_Date_Time__c;
                               
                               try{
                                Avail  = [Select id, End__c, Start__c from Diary_Entry__c where Week__c = : engSearhResultMap.get(s).Diary_Entry_ID__r.Week__c and 
                                ((Type__c = 'Availability' and Start__c <= :BlackBoxEndtime and End__c > :engSearhResultMap.get(s).Start_Date_Time__c) OR 
                                ((Job__c = : job.Id or Travel_Job__c =: job.Id) and Start__c = :BlackBoxEndtime )) order by End__c Desc limit 1];
                                
                                //system.debug('Fecthed Avail--- >'+Avail);
                                
                                
                                
                                if(Avail!=null && Avail.End__c > =BlackBoxEndtime )
                                potentialEnd = Avail.End__c;
                                else
                                potentialEnd =BlackBoxEndtime;
                                
                                }catch (Exception e)
                               {
                                 
                               }
                                
                               Search_Result__c src = engSearhResultMap.get(s);
                                        Diary_Entry__c de = [select id , Week__r.Monday_Start_Time__c,
                                        Week__r.Monday_End_Time__c,Week__r.Tuesday_Start_Time__c,
                                        Week__r.Tuesday_End_Time__c,Week__r.Wednesday_Start_Time__c,
                                        Week__r.Wednesday_End_Time__c,Week__r.Thursday_Start_Time__c,
                                       Week__r.Thursday_End_Time__c,Week__r.Friday_Start_Time__c,
                                        Week__r.Friday_End_Time__c,Week__r.Saturday_Start_Time__c,
                                        Week__r.Saturday_End_Time__c,Week__r.Sunday_Start_Time__c,
                                        Week__r.Sunday_End_Time__c from Diary_Entry__c where id = :src.Diary_Entry_ID__c];
                                        
                                      
                               decimal overBk =0.0;
                               
                               for(string r: indayJobTime.get(s))
                                {
                                        
                                        string[] infoList = r.split('/');
                                        if(!TravelJob.contains(infoList[0]+s+infoList[2]))
                                        {
                                        decimal ttime = decimal.valueof(infoList[1]).setscale(2);
                                        
                                        // Calculate new End time for the Employee after TT
                                        //system.debug('Before -->'+BlackBoxEndtime+'  '+ttime+ '  '+ potentialEnd);
                                        ttime = ttime.setscale(2);
                                        
                                        
                                        dateTime TravelEnd = DateTimeHelper.addWorkingHoursToDateTime(engSearhResultMap.get(s).Start_Date_Time__c, double.valueof(ttime), de);
                                        
                                        
                                        //system.debug('Before End NEw-->'+endNew);
                                        if(endNew==null)
                                        {
                                          TravelEnd.date();
                                          //system.debug('TravelEnd-->'+Date.valueof(TravelEnd)+'  '+TravelEnd.date()+'engSearhResultMap.get(s).Start_Date_Time__c'+engSearhResultMap.get(s).Start_Date_Time__c.date()+'   '+TravelEnd.date().daysBetween(engSearhResultMap.get(s).Start_Date_Time__c.date()));
                                          if(engSearhResultMap.get(s).Start_Date_Time__c.date().daysBetween(TravelEnd.date())>0)
                                          {
                                            utilClass.setErrorMsg(true, 'Travel Time extends into a second day, booking not allowed. Please make a different selection.');
                                            buttonClicked = true;
                                            smFlag = false;
                                          }
                                          //system.debug('**********in if*******************');
                                          //system.debug(BlackBoxEndtime +'   '+ttime+'   '+de);
                                          
                                          endNew = DateTimeHelper.addWorkingHoursToDateTime(BlackBoxEndtime, double.valueof(ttime), de);
                                          
                                        }
                                        else
                                        {
                                          //system.debug('**********in else*******************');
                                          //system.debug(endNew +''+ttime+''+de);
                                          endNew = DateTimeHelper.addWorkingHoursToDateTime(endNew, double.valueof(ttime), de);
                                        }
                                        //system.debug('------endNew-------'+endNew);
                                       
                                        engEndNew.put(src.Diary_Entry_ID__r.Week__r.Employee__r.Name, endNew);
                                        
                                        //system.debug('****'+engEndNew);
                                        /*
                                          *****************OVER BOOKING in TT*********************
                                          Availability fetched from black box search might not be sufficient after calcuation TT. 
                                          So compare the new End time with the diary entry End time and calcualte the over booking accordingly.
                                          
                                        */
                                        ////system.debug('@@@@'+endNew+'@@@'+potentialEnd);
                                        
                                        /*
                                          Check due to travel time our end is moving in to next day.. due to which we might have to re 
                                          check the inday jobs for next day.
                                        */
                                       
                                        
                                       /* if(endNew > potentialEnd)
                                        {
                                          overBk += DateTimeHelper.calculateHours(potentialEnd,endNew, de);
                                            overBk = overBk.setscale(2);
                                            endNew = potentialEnd;
                                            engEndNew.put(src.Diary_Entry_ID__r.Week__r.Employee__r.Name, endNew);
                                            //system.debug('Overbook----'+overBk +'---'+endNew);
                                        }
                                        
                                        
                                        //system.debug('Final End New---->'+endNew);
                                        Search_Result__c sr = new Search_Result__c();
                                        sr.Start_Date_Time__c = src.Start_Date_Time__c;
                                        sr.Skill__c = 'Travel Time';
                                        sr.Option_Identifier__c = src.Option_Identifier__c;
                                        sr.Job_ID__c= src.Job_ID__c;
                                        sr.Hours__c= decimal.valueof(infoList[1]);
                                        sr.End_Date_Time__c= endNew;
                                        sr.Diary_Entry_ID__c= src.Diary_Entry_ID__c;
                                        sr.order__c = infoList[2];
                                        sr.Travel_Job__c = infoList[0];
                                        travelTimeSr.add(sr);
                                        TravelJob.add(infoList[0]+s+infoList[2]);
                                      
                                }
                               }
                           }
                             
                         }
                         */
                         Set<Id> TDE = new Set<Id>();
                         list<Search_Result__c > rUpd = new List<Search_Result__c >();
                         if(travelTimeSr.size()>0)
                         {
                             map<id, datetime> diaryEndTime = new map<id, datetime>();
                              for(SearchResult sr :Wresults)
                              {
                                  //if(engEndNew.containskey(sr.result.Diary_Entry_ID__r.Week__r.Employee__r.Name))
                                  //{
                                    //endNew = engEndNew.get(sr.result.Diary_Entry_ID__r.Week__r.Employee__r.Name);
                                    //sr.result.End_Date_Time__c = endNew;
                                    diaryEndTime.put(sr.result.Diary_Entry_ID__c, sr.result.End_Date_Time__c);
                                 // }  
                                  rUpd.add(sr.result);  
                              }    
                              for(SearchResult sr:travelTimeSr)
                             {
                               sr.result.End_Date_Time__c = diaryEndTime.get(sr.result.Diary_Entry_ID__c); 
                               TDE.add(sr.result.Diary_Entry_ID__c);                            
                             }   
                              
                              //insert travelTimeSr;
                              update rUpd; //Update the Search Results.
                         }        
                         /*travelTimeSr  = [Select s.Start_Date_Time__c, s.Skill__c, s.Option_Identifier__c, s.Name, s.Job_ID__c, s.Id, 
                                            s.Hours__c, s.End_Date_Time__c, s.Diary_Entry_ID__c, s.Diary_Entry_ID__r.Week__r.Employee__r.Name,
                                            s.Diary_Entry_ID__r.Hours__c, Own_Labour__c,order__c,Diary_Entry_ID__r.End__c,Diary_Entry_ID__r.Name,Diary_Entry_ID__r.Week__c
                                            From Search_Result__c s where id in  :travelTimeSr
                                                   order by s.Diary_Entry_ID__r.Week__r.Employee__c, s.Skill__c];*/
                        
                        //Query the DiaryEntry to Get the get the EMPLOYEE NAME AND ENTRY NAME AND HOURS to get populated into new Travel Entries 
                        List<Diary_Entry__c> DEQ;
                        if(TDE.size()>0 && TDE!=null)
                        DEQ = [select id,name,Hours__c,Week__c,Week__r.Employee__c,Week__r.Employee__r.Name from Diary_Entry__c where id=:TDE];
                        
                        map<ID,string> MTDE = new Map<ID,String>(); //Holds String seperated with ':'-EMPName+':'+DEName+':'+DEHours;
                        if(DEQ.size()>0 && DEQ!=null){
                           for(Diary_Entry__c De:DEQ){
                              MTDE.put(De.id,De.Week__r.EMployee__r.Name+':'+De.Name+':'+De.hours__c+':'+De.Week__c);
                           }
                        
                        }
                        if(TravelTimeSr.size()>0) //Update the Travel Entry Details
                        for(SearchResult sr2: travelTimeSr){
                           if(MTDE.containskey(sr2.result.Diary_Entry_ID__c)){
                             string[] EDN = MTDE.get(sr2.result.Diary_Entry_ID__c).split(':');
                             sr2.EmpName = EDN[0];
                             sr2.DEName = EDN[1];
                             sr2.DEhours = EDN[2]!=null?Decimal.valueof(EDN[2]):0.0;
                             sr2.WeekId = EDN[3];
                           }
                        }
                        
                        list<SearchResult> finalList = new list<SearchResult>();
                        list<SearchResult> frontList = new list<SearchResult>();
                        list<SearchResult> backList = new list<SearchResult>();
                        for(SearchResult s : travelTimeSr)
                        {
                          if(s.result.Order__c == 'Front')
                          {
                                  frontList.add(s);
                          }else
                          {
                                  backList.add(s);
                          }
                          
                        }
                        finalList.addall(frontList);
                        finalList.addall(Wresults);
                        finalList.addall(backList);
                        Wresults = finalList;
                      }catch (Exception e)
                      {
                        //system.debug('Exception in engineer Travel '+e.getmessage() );
                      }
                       }
                    }
                    
                    if(Wresults == null || Wresults.isEmpty()) {
                        error = true;
                        errorMsg = 'No results found for ID: ' + optionID;
                        //system.debug('No results found for ID: ' + optionID);
                    } else {
                        //system.debug('jobID: ' + jobID);
                        //Added By Ashok CR- 001 start
                        // Send re-plan email CR starts
                        priorDeliveryDate = job.Delivery_Date__c;
                        priorDeliverySlot = job.Delivery_Slot__c;
                        priorInstallDate = job.Installation_Date__c;
                        // Send re-plan email CR ends
                         // This is a fix to send out correst email to customer on job planning. First update used to send 
                         // previously the alerts but there was a bug it used to send old Insatllation date. So from this change 
                         // This bug will be fixed. And this is used in Workflow
                        if(job.Sent_text_to_customer__c)
                        {
                            job.Sent_text_to_customer__c= false;
                            try{
                            update job;
                            }catch(exception e)
                            {
                                //system.debug(e);
                            }
                        }

                        DummyFlag = job.CHI_Lead__r.Account.Dummy_Data__c;
                        
                        if(DummyFlag == true)
                        {
                            GetAvailableResources objGetAvailableResources = new GetAvailableResources();
                            boolean deleted = objGetAvailableResources.deleteDummyRecords();
                        }
                        
                        if(!buttonClicked && NonWorkingDiaryEntries.size()>0 )
                         {
                            for(Diary_Entry__c d: NonWorkingDiaryEntries )
                            {
                                for(SearchResult s : Wresults)
                                {
                                    if(d.Week__c == s.result.Diary_Entry_ID__r.Week__c && ((s.result.End_Date_Time__c>d.Start__c && s.result.Start_Date_Time__c<d.End__c) || (S.result.Start_Date_Time__c <= d.Start__c && s.result.End_Date_Time__c >= d.End__c )))
                                    {
                                        utilClass.setErrorMsg(false, 'You are Booking JOB On NON WORKING DAY');
                                        break;
                                    }
                                }
                            }
                          }
                 
               
                    //Added By Ashok CR- 001 :End
                        
                        //Added by: Cognizant
                      //Added on: 23/06/2010
                      //Comment: Added for Parallel Run functionality. This allows to select the platform in 
                      //       Job Planning only if the Platform field in CHI Lead is null    
                        //strPlatform = job.CHI_Lead__r.Platform__c;
                      /* //system.debug('--strPlatform' +strPlatform);
                          if(strPlatform == null)
                          {
                            platformCheck = true;  
                          }
                          //system.debug('System.Label.Default_Platform' +System.Label.Default_Platform);
                           /*new condition to handle the below scenario:
                              If there is a TYPO error in the Label for the platform, then default should go for Premier, not SFDC
                           */ 
                           /*
                          if(System.Label.Default_Platform != 'SFDC') 
                            labelValue = 'Premier';
                          else labelValue = 'SFDC';
                          
                          if(job.CHI_Lead__r.Platform__c == null) 
                          {
                            job.CHI_Lead__r.Platform__c = labelValue; 
                          }
                          */
                       }
                }
                ////system.debug('2-job.CHI_Lead__r.Platform__c' +job.CHI_Lead__r.Platform__c);
                //Added 10-08-2010
                //If  “Parallel run switch” = ON then Display the Input field
               /*if(System.Label.Parallel_run_switch == 'ON')
                {
                    parallelRunEnabled=true;
                }
                else
                {
                    parallelRunEnabled=false;
                } */
                 //Added On : 19:08:2010
                //Added Reason: Parallel run implementation for the specific profile
            /* USerid = UserInfo.getUserId();
               lst_user = [Select ID,Parallel_Run_Enable__c from User where id =: USerid  limit 1];
               for(User obj_user :lst_user){
                   if(obj_user.Parallel_Run_Enable__c == false)
                    {
                    parallelRunEnabled = false;
                    }*/

                  
                // Added Prashant June 2012 for Priority Installations CR start
                if((job.CHI_Lead__r.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date)){
                     this.include_priority_install = true;
                }else{
                    this.include_priority_install = false;
                }
                // Added Prashant June 2012 for Priority Installations CR end
                /*
                if(!buttonClicked && ((!job.Decouple_Smart_Meter_Install_Date__c && !job.Split_Job__c && !job.Is_Remedial_Job__c && !job.Is_Downtime_Job__c) && (job.CHI_Lead__r.SMStatus__c =='Eligible' || job.CHI_Lead__r.SMStatus__c == 'Eligible EnergySmart' || 
                 job.CHI_Lead__r.SMStatus__c == 'Eligible Not Dual Fuel'  ||(job.CHI_Lead__r.SMStatus__c!= null && job.CHI_Lead__r.SMStatus__c.contains('Unknown')))))
                 {
                    smFlag = true;
                    utilClass.setErrorMsg(false, 'Please confirm if Smart Meter is present on Job. If yes arrange appropriate Installation date for meter.');
                    
                    
                 }else
                    smFlag = false;
                    */


                if(ownLabourJob)
                {
                    List<string> sjrList=new List<string>();
                     //Upgrade job without a boiler
                    if(job.Quote__r.Product_Type_ID__c==system.label.Product_Type_For_Quote){
                      sjrList.add(system.label.SJR_Upgrade_job);  
                        
                    }
                    //Job start time not 8am or 12noon 
                     if(startTimeOfJob!=null){
                         if(startTimeOfJob.hour()!=decimal.valueOf(system.label.SJR_startTime) && startTimeOfJob.hour()!=decimal.valueOf(system.label.SJR_End_time_for_Job) ){
                          sjrList.add(system.label.SJR_Job_start_time);  
                             //system.debug('>>>>>>>>>>>sjrList'+sjrList);
                         }  
                     }
                    
                    //8 hour job starting at 12noon  
                     if(startTimeOfJob!=null){
                         if(job.S_P_Hours__c==decimal.valueOf(system.label.SJR_startTime) && startTimeOfJob.hour()==decimal.valueOf(system.label.SJR_End_time_for_Job) ){
                         sjrList.add(system.label.SJR_8_hour_job);  
                         }   
                    }
                    //Job under 20 hours planned to 2 engineers 
                    Integer engExist=0;
                   
                    if(job.S_P_Hours__c<=Integer.valueOf(system.label.SJR_S_P_hours) && engineerHours.size()>=2)
                    {
                       sjrList.add(system.label.SJR_Job_under_20_hours); 
                    }

                    // Job over 24 hours not planned to 2 engineers
                    if(job.S_P_Hours__c>=Integer.valueOf(system.label.SP_Job_Uppler_Limit) && engineerHours.size()<2)
                    {
                       sjrList.add(system.label.Job_over_24_hours_not_planned_to_2_engineers  ); 
                    }

                    // job not split evenly between 2 engineers.
                    if(engineerHours.size()>=2)
                    {
                        if(engineerHours.values()[0][0]-engineerHours.values()[1][0]>2)
                        {
                        sjrList.add(system.label.SJR_Job_hours_not_split_evenly);   
                        // 2 man team dont start and end at same time.
                        if((engineerStart.values()[0]!=engineerStart.values()[1] )|| (engineerHours.values()[0][0]!=engineerHours.values()[1][0]))
                        sjrList.add(system.label.SJR_2_man_team);  
                        }
                    }

                    // 2 man team dont start and end at same time.
                    /*
                    if(engineerStart.size()>=2)
                    {
                      if((engineerStart.values()[0]!=engineerStart.values()[1] )|| (engineerHours.values()[0][0]!=engineerHours.values()[1][0]))
                       sjrList.add(system.label.SJR_2_man_team); 
                    }
                    */
                    // over booking
                    if(engineerHours.size()>0)
                    {
                      for(list<decimal> d: engineerHours.values())
                         if(d[0] > d[1] &&  math.abs(d[0]-d[1])> decimal.valueof(system.label.SJR_Overbooking_Tolerance) )
                        {
                        sjrList.add(system.label.SJR_Overbooking_a_diary_gap);   
                        break;
                        } 
                    }

                    // travel time more than 1
                    if(travelTimeMoreThan_1==true){
                       sjrList.add(system.label.SJR_In_day_travel_over_1_hour);   
                        
                    }
                    
                     
      
     job.Exception_Required__c= null;             
     job.Exception_reason__c = null;
     job.Engineer_Spoken_To__c = null;
     if(sjrList.size()>0)
    {
      job.Exception_Required__c=formatSJobReason(sjrList);
      ShowSPDetails=True; 
    }
  }else
  {
     ShowSPDetails=false; 
     job.Exception_Required__c= null;             
     job.Exception_reason__c = null;
     job.Engineer_Spoken_To__c = null;
  }
    //system.debug('===debugPriti2==='+withinStandard+serviceLevel+serviceLevelReason);
    }
   

    public PageReference bookOption() {
         //system.debug('**bookoption');
      if(job.Exception_Required__c!=null && (job.Exception_reason__c==null ||  job.Engineer_Spoken_To__c==null))
      {
              //system.debug('**bookoption1');
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Exception reason,Engineer Spoken To are mandatory when Exception Required is populated');
                  ApexPages.addMessage(msg);  
                   rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                   buttonClicked = false;
            return null;
        }
        cls_IsRun.setisinstUpdCustCatMasRec();
        System.Savepoint rollbackPoint = Database.setSavepoint();  
        //try {
            buttonClicked = true;
           
           //change 1379 by Ashok G
           //system.debug('@@Direction2:'+JPH.Direction2__c);
           
           if(oldStatus!='Pending')
           {  
          // //system.debug('=====Priti===='+oldStatus +job.Multiple_Re_Plans__c+ JPH.Re_Plan_Reason__c+currentInstallDate+priorInstallDate );
          //Job replan Multiple replan checkbox change
             
             if(JPH.Re_Plan_Reason__c==null ||JPH.Re_Plan_Reason__c=='' )
              
                 {
                 
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please select the Re-Plan reason');
                  ApexPages.addMessage(msg);
                  rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                   buttonClicked = false;
                   return null;
                } 
                            
                //Priya coding starts
                String customValues = system.label.Replan_Sub_Reason;
                //system.debug('$$$$$$$$$$$$$$$$ customValues'+customValues);
                String[] customeLabel = customValues.split(':');
                //system.debug('$$$$$$$$$$$$$$$$ customeLabel'+customeLabel);
                for(String str : customeLabel)
                {
                    //system.debug('$$$$$$$$$$$$$$$$  str'+str);
                    if(JPH.Re_Plan_Reason__c == str && (JPH.Re_Plan_Sub_Reason__c==null ||JPH.Re_Plan_Sub_Reason__c=='' ))
                    {
                      //system.debug('$$$$$$$$$$$$$$$$  inside if ');
                      ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please select the Re-Plan sub reason');
                      ApexPages.addMessage(msg);
                      rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                      buttonClicked = false;
                      return null;
                    } 
                }
               
           } 
             
      
            //Change to auto POpulate service level and service level reason 
            //system.debug('####error###'+serviceLevel+serviceLevelReason);
            if(serviceLevel == '-NONE-' || serviceLevelReason == '-NONE-'){
              //system.debug('####error###'+serviceLevel+serviceLevelReason);
              ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please enter Service Level or Service Level Reason.');
              ApexPages.addMessage(msg);
              rerenderblocks = 'bookingForm,cnfBooking,errormsg';
              buttonClicked = false;
              return null;
            }             
                     
             if(job.DPA_Done__c==null ||job.DPA_Done__c=='' )
          
             {
             
              ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please select DPA Done to proceed');
              ApexPages.addMessage(msg);
              rerenderblocks = 'bookingForm,cnfBooking,errormsg';
               buttonClicked = false;
               return null;
            }
             
             if(job.Delivery_Date__c > currentInstallDate)
            {
                
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please Select a past Delivery date as Installation date is :'+currentInstallDate.format());
                ApexPages.addMessage(msg);
                rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                buttonClicked = false;
                return null;
            }
            
            if(job.not_booked__c == false)
            { 
            
            
            //system.debug('job.not_booked__c'+job.not_booked__c);
            /* 
            if(smFlag == true && !smValSwitch && job.Smart_Meter_Required_Flag__c == null)
            {
                rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                buttonClicked = false;
                
                
                if(system.label.SmartSwitch == 'yes' && job.Installation_Date__c !=null )
                {
                        overRideSMVal = true;
                        utilClass.setErrorMsg(true, 'Please update Smart Meter Required Flag, else override the Validation rules.');
                }else
                 utilClass.setErrorMsg(true, 'Please update Smart Meter Required Flag.');        
                return null;
            }
            // ++ Updated for Smart Meter CR
            integer noOfdays = integer.valueOf(system.label.SM_SLA);
            if(smFlag == true && !smValSwitch && job.Smart_Meter_Required_Flag__c == 'Yes' && (job.Delivery_Date__c == currentInstallDate || job.Delivery_Date__c < System.today().addDays(noOfdays) || job.Smart_meter_installation_date__c <= System.today().addDays(noOfdays)) && (job.Smart_meter_installation_date__c <= currentInstallEndDate.addDays(noOfdays)|| job.Smart_meter_installation_date__c == null))
            {
                
                rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                buttonClicked = false;
                if(system.label.SmartSwitch == 'yes' && job.Installation_Date__c !=null)
                {
                        overRideSMVal = true;
                        utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Date greater than '+ currentInstallEndDate.addDays(noOfdays).format()+', else override the Validation rules.');
                }else
                {
                        utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Date greater than '+ currentInstallEndDate.addDays(noOfdays).format());
                }       
                return null;
            }
            // Change for Smart Meter Slot.
            //Date 15th Aug 2012
            //Cognizant
            if(smFlag == true && !smValSwitch && job.Smart_Meter_Required_Flag__c == 'Yes' && job.SMInstalltionTime__c == null  && job.Smart_meter_installation_date__c!=null)
            {
                
                rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                                buttonClicked = false;
                                if(system.label.SmartSwitch == 'yes' && job.Installation_Date__c !=null)
                                {
                                        overRideSMVal = true;
                                        utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Time Slot,else override Validation rules.');
                                }else
                                utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Time Slot');       
                return null;
            }
            
            if(smFlag == true && !smValSwitch && job.Smart_Meter_Required_Flag__c == 'Yes' && job.Smart_meter_installation_date__c == currentInstallDate)
            {
                
                rerenderblocks = 'bookingForm,cnfBooking,errormsg';
                buttonClicked = false;
                
                if(system.label.SmartSwitch == 'yes' && job.Installation_Date__c !=null)
                {
                        overRideSMVal = true;
                        utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Date greater than '+ currentInstallEndDate.addDays(noOfdays).format()+', else override the Validation rules.');
                }
                else
                        utilClass.setErrorMsg(true, 'Please enter a Smart Meter Installation Date greater than '+ currentInstallEndDate.addDays(noOfdays).format());
                return null;
            }*/
            
        }
        
            //code added for failed install on day 
            if(showFailedInstallDetails == true && (failedInstall.Job__c==NULL || failedInstall.Date_Failed__c == NULL || failedInstall.Cause__c == NULL
               || failedInstall.Reason__c == NULL)){
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please enter all the details in failed install section');
                  ApexPages.addMessage(msg);
                  rerenderblocks = 'bookingForm,cnfBooking,errormsg,failedInstall';
                  buttonClicked = false;
                  return null;

            }               
            try{
                if(showFailedInstallDetails==true && failedInstall!=NULL)
                  insert failedInstall;
            }catch(Exception e){
                  //system.debug('####error In Failed Install###');
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
                  ApexPages.addMessage(msg);
                  rerenderblocks = 'bookingForm,cnfBooking,errormsg,failedInstall';
                  buttonClicked = false;
                  return null;
            }
       
            // -- Updated for Smart Meter CR
            /*
            Commented to Improve the efficiency of Job Planning.
            if(smFlag == true && job.Smart_Meter_Required_Flag__c == 'Yes' && job.Delivery_Date__c == currentInstallDate && job.Delivery_Date__c < job.Smart_meter_installation_date__c)
            {
                Lock.setsmInstDateLock();
                job.Smart_meter_installation_sub_status__c = 'Unacknowledged';
                job.Reason_for_acknowledgement__c = 'Delivery and Install Date were on same Day';
            }else if(smValSwitch)
            {
                Lock.setsmInstDateLock();
            }   
            */
                
            
                
            if(overBook ==true  && inputOverbook == false)
            {
              rerenderblocks = 'bookingForm,errormsg';
              //system.debug('inputOverbook--- >'+inputOverbook+'----------'+overBook);
                utilClass.setErrorMsg(true, 'Please confirm that you want to over book this job.');
                buttonClicked = false;
                return null;
            }    
            //Added by: Cognizant
            //Added on: 23/06/2010
            //Comment: Update opportunity(CHI Lead) for updated platform value
              /*
              
              if(job.CHI_Lead__r != null && platformCheck == true)
              { 
                job.CHI_Lead__r.isSystem__c = true;          
                Database.update(job.CHI_Lead__r);
              */
              /*
              if(smValSwitch)
                job.SMOverridedUser__c = userinfo.getname();
              */
              if(JPH.Re_Plan_Reason__c!='Customer postponed' && currentInstallDate > priorInstallDate )         
               {
                   job.Multiple_Re_Plans__c=+1;
               }    
              
              job.Job_Reason__c = serviceLevel ;
              job.CRD_Code__c = serviceLevelReason ;
              job.Travel_Distance__c =  trav_Dist;
              job.Travel_Time__c = trav_Time;
              job.Needs_Re_Planing__c = false;
              
              lock.jobTriggerSwitch = true;
              Database.update(job);
              lock.jobTriggerSwitch = false;
              //system.debug(LoggingLevel.INFO,'----------->'+travelDe);
              // Call the method to Pkan the Job.
              //if(job.Squeeze_Job__c)
              //CalcOverBookedHours();
              if(Updres !=null)
              Update Updres;
              
              JobBookingManager.planOrReplanJob(optionID);
              bookingStatus = 'Options were booked!';
              
                          
             // Retrieve job again to avoid overriden data 
            // updated query fields June 2012 : Prashant 

            job = [select ID,DPA_Done__c, Installation_Date__c, Needs_Re_Planing__c,Sent_text_to_customer__c, Customer_journey_status_index__c,squeeze_Job__c,Exception_reason__c, Exception_Required__c,Rule_Broken_By__c, 
                  CHI_Lead__c, CHI_Lead__r.Account.Dummy_Data__c, Delivery_Slot__c, Delivery_Date__c, CHI_Lead__r.isSystem__c,
                  Delivery_Notes__c, CRD_Code__c,Bring_Forward_Job__c,Refused_Earlier_Date__c,
                  CHI_Lead__r.Installation_opt_out_reason__c,CHI_Lead__r.Installation_Opt_Out_Type__c,CHI_Lead__r.Createddate,CHI_Lead__r.Latest_customer_category__c,
                  CHI_Lead__r.Customer_have_any_other_form_of_HEAT__c,CHI_Lead__r.Date_and_time_job_planned__c,
                  CHI_Lead__r.Does_the_customer_have_hot_water__c,CHI_Lead__r.Is_the_customers_boiler_working__c,
                  CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c,Engineer_Spoken_To__c,
                  Split_Job__c, Is_Remedial_Job__c, Is_Downtime_Job__c,Job_Reason__c,Status__c,Sub_Status__c,Job__c.Multiple_Re_Plans__c,
                  (Select Id,Pre_installation_call_date__c from Customer_history_cards__r),
                  (Select Id, Prior_Delivery_Slot__c, Type__c, Status__c, Delivery_Date_Changed__c, Send_via_email__c, 
                    CreatedDate, Order_Value_Text__c,Prior_Order_Value__c, Customer_best_phone__c, Supplier_Name__c, Job_Delivery_Date__c, Prior_Delivery_date__c, 
                    Delivery_Slot__c, Enquiry_Number__c, Job__r.Name, Job__r.PlannerName__c, Job__r.CHI_Lead__r.CHI_Lead_Id__c, 
                    Job__r.Customer_Name__c, SAP_Number__c, Job__r.CHI_Lead__r.Account.BillingStreet, Order_Value__c, 
                    Job__r.CHI_Lead__r.Account.BillingCity, Job__r.Id, Job__r.CHI_Lead__r.Account.BillingState, 
                    Job__r.CHI_Lead__r.Account.BillingCountry, Job__r.CHI_Lead__r.Account.BillingPostalCode From Purchase_Orders__r),
                   (Select Name, Start__c, End__c, Hours__c, Sub_Type__c, ID,Week__c, Week__r.Employee__r.Name,Week__r.Employee__c,
                   Week__r.Monday_Start_Time__c,Week__r.Monday_End_Time__c,Week__r.Tuesday_Start_Time__c,Week__r.Tuesday_End_Time__c,
                   Week__r.Wednesday_Start_Time__c,Week__r.Wednesday_End_Time__c,Week__r.Thursday_Start_Time__c,Week__r.Thursday_End_Time__c,
                   Week__r.Friday_Start_Time__c,Week__r.Friday_End_Time__c,Week__r.Saturday_Start_Time__c,Week__r.Saturday_End_Time__c,
                   Week__r.Sunday_Start_Time__c,Week__r.Sunday_End_Time__c,Overbooked_Hours__c
                   from Diary_Entries__r order by End__c desc), 
                   (Select id from NWD_Detail__r)          
                  from Job__c where ID = :jobID];
             
             //Change By ASHOK G To create Diary Entries for Travel Time with Record Type 'NON PRODUCTIVE JOB BOOKING' Type
             //system.debug(LoggingLevel.INFO,'----Entreis:'+job.Diary_Entries__r);
             //system.debug(LoggingLevel.INFO,'---Wresults--->'+WResults);
             
             //system.debug(LoggingLevel.INFO,'----------->1'+travelDe);
             map<Id,List<DateTime>> wstartEndMap = new Map<Id,List<DateTime>>();
             Map<Id,List<Diary_Entry__c>> WDemap = new Map<Id,list<Diary_Entry__c>>();
              for(Diary_Entry__c bo: job.Diary_Entries__r){
                   
                   if(wStartEndMap.containskey(bo.week__c)){
                      Datetime[] strtEnd = wStartEndMap.get(bo.Week__c);
                      if(bo.start__c < strtEnd[0])
                      strtEnd[0] = bo.start__c;
                      
                      if(bo.End__c > strtEnd[1])
                      strtEnd[1] = bo.End__c;
                      
                      wStartEndMap.put(bo.Week__c,strtEnd);
                   }else{
                      List<DateTime> startEnd = new list<DateTime>();
                      startEnd.add(bo.start__c);
                      startEnd.add(bo.End__c);
                      wStartEndMap.put(bo.Week__c,startEnd);
                      
                   }
                   
                   if(WDemap.containskey(bo.Week__c)){
                   list<Diary_Entry__c> tempList = new list<Diary_Entry__c>();
                   tempList.addall(WDemap.get(bo.Week__c));
                   tempList.add(bo); 
                     WDemap.put(bo.Week__c,tempList);
                     
                   }else{
                     list<Diary_Entry__c> diaries = new list<Diary_Entry__c>();
                     diaries.add(bo);
                     WDemap.put(bo.Week__c,diaries);
                   }
                   
               }
              //TravelDE.clear();
              TravelDE = new list<Diary_Entry__c>();
              //system.debug(LoggingLevel.INFO,'===========>wdemap:'+WDemap+' '+WstartEndMap); 
              for(SearchResult sr: WResults){
                  
                  if(sr.result.Skill__c == 'Travel Time' && wstartEndMap.containskey(sr.WeekId))
                  {     
                        //system.debug(LoggingLevel.INFO,'======>Inside Travel'+sr+sr.result.Hours__c);
                        Diary_Entry__c de = WDemap.get(sr.WeekId)[0];
                        //system.debug(LoggingLevel.INFO,'========caslc:'+de+' '+DateTimeHelper.addWorkingHoursToDateTime(sr.result.Start_Date_Time__c,Double.valueof(sr.result.Hours__c),de));
                        if(sr.result.Order__c == 'Front'){
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(sr.result.Start_Date_Time__c,Double.valueof(sr.result.Hours__c),de);
                          TravDE.Start__c = wstartEndMap.get(sr.WeekId)[0];
                          TravDE.Week__c = sr.WeekId;
                          TravDE.Travel_Job__c = sr.result.Travel_Job__c;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c =sr.result.Job_ID__c;
                          TravDE.Hours__c = sr.result.Hours__c;
                          TravelDE.add(TravDE);
                        
                        }else{
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.Start__c = wstartEndMap.get(sr.WeekId)[1];
                          TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(TravDE.Start__c,Double.valueof(sr.result.Hours__c),de);
                          TravDE.Week__c = sr.WeekId;
                          TravDE.Travel_Job__c = sr.result.Travel_Job__c;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c =sr.result.Job_ID__c;
                          TravDE.Hours__c = sr.result.Hours__c;
                          TravelDE.add(TravDE);
                        }
                    }  
                     
                   
                   }
             
             if(TravelDE.size()>0)
             insert TravelDE;
             
             //getting new installation date upon clicking make these button on plan job on Job Planning History custom object.
             
             newdate=job.Installation_Date__c;
             
             // calling JobReplanning() once the query on updated job finish to populate values defined in JobReplanning()method
             JobReplanning();
             //SM PH II Change End
             // Added as part of customer history card change request.
              
              booked = job.Diary_Entries__r;
              
              if(booked != null && booked.size()>0){
                
                bookedRetrieved = true;   
                            
              }
              
              DateTime installDatetime = datetime.newInstance(2090, 12, 1, 12, 30, 2);
              Map<Id, double> NWDEgnineerIdTimeMap = new Map<Id, double> ();
              
              if(job.NWD_Detail__r.size()>0)
              {
                  delete job.NWD_Detail__r;
              }
              
              for(Diary_Entry__c de : booked){
                  
                   if(de.Start__c <= installDatetime){
                            installDatetime = de.Start__c;
                        }
                
                if(System.Label.Customer_Journey_Flag == 'TRUE' && de.Sub_Type__c == 'Mechanical'){
                    
                    job.Mechanical_Skill_End_Date__c = de.End__c.date();
                }
                
                // Delete existing Non working Details.
                
                
                // try to find if there are any new NWD to be created?
    
                for(Diary_Entry__c nwd : NonWorkingDiaryEntries)
                {
                    
                     dateTime startNWDTime;
                     dateTime endNWDTime;
                     double NWDHours =0;
                if((de.Week__c == nwd.Week__c) && ((de.Start__c< nwd.End__c && de.End__c> nwd.Start__c) || (de.Start__c<= nwd.Start__c && de.End__c>= nwd.End__c)))        
                    //if((de.Week__c == nwd.Week__c) && ((de.Start__c< nwd.End__c && de.End__c> nwd.Start__c) || (de.Start__c>= nwd.Start__c && de.End__c>= nwd.End__c)))
                    {
                        //system.debug('--->inside<--');
                        //system.debug('--->inside<--'+de.Start__c+'-----'+de.End__c);
                        //system.debug('--->inside<--'+nwd.Start__c+'-----'+nwd.End__c);
                        if(de.Start__c>= nwd.Start__c)
                        {
                            startNWDTime = de.Start__c;
                        }else{
                            startNWDTime = nwd.Start__c;
                            
                        }
                        
                        if(de.End__c >= nwd.End__c)
                        {
                            endNWDTime = nwd.End__c;
                        }else
                        {
                            endNWDTime = de.End__c;
                        }
                        
                        NWDHours = DateTimeHelper.calculateHours(startNWDTime, endNWDTime, de);
                        //overbooked hours calculation on NWD
                        if(de.Overbooked_Hours__c!=NULL && nwd.End__c>=de.End__c)
                        NWDHours +=de.Overbooked_Hours__c;
                        
                        //system.debug('NWD Hours--->'+NWDHours);
                        if(NWDHours>0)
                        {
                        if(NWDEgnineerIdTimeMap.containsKey(de.Week__r.Employee__c))
                        {
                            NWDHours+= NWDEgnineerIdTimeMap.get(de.Week__r.Employee__c);
                        }
                        NWDEgnineerIdTimeMap.put(de.Week__r.Employee__c, NWDHours);
                        }
                        
                        //system.debug('---->'+NWDEgnineerIdTimeMap);
                        
                    }
                }
                
                
              }
              
            lock.jobTriggerSwitch = true;
            if(job.squeeze_Job__c) //squeeze Job Uncheck
            job.squeeze_Job__c=false;
            
            //if(job.skip_8_12_Rule__c)//Skip Rule unchek
            job.skip_8_12_Rule__c=false;
            
            update job;
            lock.jobTriggerSwitch = false;
            list<NWD_Detail__c> insertNewList = new list<NWD_Detail__c>();  
            for(id empid : NWDEgnineerIdTimeMap.keyset())
            {
               insertNewList.add( new NWD_Detail__c(Employee_Name__c = empid, Job_Number__c = job.Id, Hours__c = NWDEgnineerIdTimeMap.get(empid)));
            }
            
            if(insertNewList.size()>0)
            insert insertNewList;
            
               
                // Added Prashant June 2012 Priority Installations CR
                if(include_priority_install && cls_IsRun.isUpdateServiceLevelValues == false){
                              job.CHI_Lead__r.Last_customer_cat_info_update_source__c = 'Installation';
                              job.CHI_Lead__r.Pending_update_to_customer_category__c = True;
                              job.CHI_Lead__r.Customer_Category_Modified_Datetime__c = Datetime.Now();
                              job.CHI_Lead__r.Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
                              job.CHI_Lead__r.Stage_object_Type__c = 'Job';
                              job.CHI_Lead__r.Stage_object_Id__c = job.Id;
                              job.CHI_Lead__r.Installation_Date_Time__c = installDatetime;
                              job.CHI_Lead__r.Date_and_time_job_planned__c = Datetime.Now();
                              job.CHI_Lead__r.Installation_opt_out_reason__c = job.CRD_Code__c;
                              job.CHI_Lead__r.Installation_Opt_Out_Type__c = job.Job_Reason__c;
                              cls_IsRun.setisUpdateServiceLevelValues();
                              update job.CHI_Lead__r;
                              
                              
                }
                /*
            Commented As the customer History Card is not being Used Any more. 
            
            This will improve the effieciency of the Job Planning. 
            try{
                
                // Added this line for overlapping unavailability CR
                // Added as part of customer history card change request.
                job.Needs_Re_Planing__c = false;
                if(System.Label.Customer_Journey_Flag == 'TRUE' && currentInstallDate == null){
                    currentInstallDate = Date.today();
                }
                if(job.Customer_journey_status_index__c > 2 && System.Label.Customer_Journey_Flag == 'TRUE' && (Date.today()).daysBetween(currentInstallDate) <= 7 && (currentInstallDate >= Date.today())){
                  job.Customer_Journey__c = 'Welcome call made - 28 day call required';
                  job.Mid_call_date__c = null;
                }else if(job.Customer_journey_status_index__c > 2 && System.Label.Customer_Journey_Flag == 'TRUE' && currentInstallDate >= Date.today()){
                  job.Customer_Journey__c = 'Welcome call made - mid call required';
                  job.Mid_call_date__c = currentInstallDate - 7;    
                }
                //google distacne finder change
                                
                Database.update(job);
                
                 // Added as part of customer history card change request.
                 
                     try{
                        
                        Customer_history_card__c c = null;
                        
                        if(job.Customer_history_cards__r != null && job.Customer_history_cards__r.size()>0){
                         
                          c = job.Customer_history_cards__r[0];
                         
                        }
                        
                        if(c != null && currentInstallDate != null && priorInstallDate != null && priorInstallDate != currentInstallDate){
                            
                            c.Pre_installation_call_date__c  = (currentInstallDate - 1);
                            Database.update(c);
                            
                        }else if(c != null && priorInstallDate == null && currentInstallDate != null){
                            
                            c.Pre_installation_call_date__c  = (currentInstallDate - 1);
                            Database.update(c);
                            
                        } 
                        
                     }catch(Exception exc){
                        
                          //system.debug('Error in setting pre-install date on customer history card '+exc.getMessage());
                         
                     }
                
              }catch(System.DmlException Dbexc){
                
               error = true;
              
             } */
             
            // Send re-plan email CR starts
            
            try{
           
               boolean generateReplanNotice = false;
              
               if(job.Delivery_Date__c != null && this.priorDeliveryDate != null && job.Delivery_Date__c != this.priorDeliveryDate){
                 generateReplanNotice = true;
               }
               
               if(job.Delivery_Slot__c != null && this.priorDeliverySlot != null && job.Delivery_Slot__c != this.priorDeliverySlot){
                 generateReplanNotice = true;
               }
               
               if(generateReplanNotice){

                          List<Order__c> orderLst = new List<Order__c>();
                              
                          for(Order__c ord : job.Purchase_Orders__r){
                            
                             if(ord.Delivery_Date_Changed__c && ord.Type__c == 'Material' && ord.Status__c != 'Cancelled' && ord.Status__c != 'Rejected' && ord.Status__c != 'Inactive'){
                               
                               ord.Send_via_email__c = true;
                               orderLst.add(ord);

                             }
                             
                          }
                          
                          if(orderLst != null && orderLst.size() > 0){
                                
                              Database.Update(orderLst,true);
                              SendReplanPDFViaEmail s = new SendReplanPDFViaEmail();
                              s.sendEmail(orderLst);
                              
                          }
                          
              }
               
           
         }catch(Exception excp){
         
               //system.debug('Exception Type 1 In Replan '+excp.getMessage()); 
               ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
               ApexPages.addMessage(msg);
               rerenderblocks = 'bookingForm,cnfBooking,errormsg';
               buttonClicked = false;
               return null;
           
         } 
         
         // Send re-plan email CR Ends
             
            // Auto-generate purchase orders as part of planning process if no order is yet generated on this job.
             Pagereference p;  
             Integer numberOfOrders = 0;
              
             String autoGenerateOrders = System.Label.Auto_Generate_Purchase_Orders;  
              
             try{
                
                 if(autoGenerateOrders.equalsIgnoreCase('TRUE')){
                 
                    if(job.Purchase_Orders__r != null && job.Purchase_Orders__r.size() > 0){
                        
                       numberOfOrders = job.Purchase_Orders__r.size();
                  
                    }
                    
                    if(numberOfOrders==0){
                 
                       /*  AutoGeneratePurchaseOrders autoGen = new AutoGeneratePurchaseOrders();
                         autoGen.autoGenerateOrders(job);
                         //update job;
                         p=new PageReference('/'+job.id); */
                         p=new PageReference(System.Label.autogenerate_PO+job.id); // PRB00029071
                 
                    } else if(numberOfOrders!=0 ){
                    
                        
                        p=new PageReference(System.Label.AutoRegeneration+job.id);
                        
                        
                      }
                 }
                 
                 List<Id> jobIdList = new List<Id>{jobID};
              
                 JobSharingCls.createJobSharing(jobIdList);
                 
              } catch(Exception ex){
  
                //system.debug('An exception occured in auto-generating the orders :  '+ex.getMessage()+' Error in line number : '+ex.getLineNumber());         
                Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
                email1.setSubject('Exception thrown while auto generating purchase orders');      
                String[] toAddresses = new String[] {'BGSAMS.Support@centrica.com'};       
                email1.setToAddresses(toAddresses);      
                email1.setPlainTextBody('An exception occured in auto-generating the orders :  '+ex.getMessage()+' Error in line number : '+ex.getLineNumber());      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});       
                    }
                    
            return p;
           
    }
    
    
     public PageReference goback()
    {
        return new PageReference('/apex/AvailableResources');
    }
    
     public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public void JobReplanning() 

   {
    
        JPH.Planned_By__c=UserInfo.getUserId();
        JPH.Job__c=job.id;
        JPH.Original_Installation_Date__c=originaldate;
        JPH.New_Installation_Date__c=newdate;
        JPH.Exception_reason__c=job.Exception_reason__c;
        JPH.Exception_Required__c=job.Exception_Required__c;
        JPH.Principle_Broken_By__c=job.Rule_Broken_By__c;
        JPH.engineer_spoken_to__c=job.engineer_spoken_to__c;
        if(oldStatus =='Pending' && oldSubStatus!='ASP Added')
          
           {
                JPH.Type__c='First Plan';
                JPH.RecordTypeId =System.label.Replan_First;
           
           }
        else if(oldStatus!='Pending')
        
           {
                JPH.Type__c='Re Plan';
           }
        else if(oldStatus=='Pending' && oldSubStatus=='ASP Added')
           {
                JPH.Type__c='ASP Added';
                JPH.RecordTypeId =System.label.Replan_First;
           }
           
        try
            {
               insert JPH;
             }
             
        catch(Exception E)
        {
            
        } 
    }
  //method to Calculate OVER BOOKED HOURS  --SqueeZe JOb Change BY ASHOK G
  Private class overBookedCls{
        public Id week_id;
        public Datetime mainStartTime;
        public Datetime mainEndTime;
        private Diary_Entry__c relatedEntry; //related entry to use for shift pattern
        List<Search_Result__c> resultOptions = new List<Search_Result__c>();
        //public map<string,DateTime> resultOptions = new Map<String,DateTime>();
        public Decimal OBHours{get;set;}
        public overBookedCls(Id week_id, Datetime startTime, Datetime endTime, Diary_Entry__c relatedEntry)
        {
            this.week_id = week_id;
            this.mainStartTime = startTime;
            this.mainEndTime = endTime;
            this.relatedEntry = relatedEntry;
            //system.debug('In the Inner Class -->'+endTime+' '+mainEndTime);
        }
        
        public void addResult(Search_Result__c ser)
        {
            resultOptions.add(ser);
        }
        //This method Helps in Calculating Total overBook Hours. 
        public void calOBHours(){
           If(resultOptions.size()>=1){
             Double totalHoursToBook = 0.0;
             //system.debug(LoggingLevel.INFO,'Innere class #3------>'+resultOptions.size()+' '+resultOptions);
             if(OBHours == null)
             OBHours = 0.0;
             
             for(Search_Result__c resultOpt: resultOptions){
                 //string[] r1 = resultOpt.split(':');
                 //totalHoursToBook += Double.valueof(r1[1]);
                 totalHoursToBook += resultOpt.hours__c; // calc. total Hours of Employee.
             }
             //system.debug(LoggingLevel.INFO,'))))TOT: '+totalHoursToBook);
             double rounddown = (integer.valueof(totalHoursToBook) / 4) * 4;//Rounddown the Total hours to Nearest 4 Multiple
             //system.debug(LoggingLevel.INFO,':RoundDown"--->'+roundDown);
             If(totalHoursToBook != rounddown){ //Compare TotalHoursToBook with the Round down Value if those are Equal meaning OBHours is 0
              for(Search_Result__c resultOpt: resultOptions){
               
                if(resultOpt.Skill__c == 'MECHANICAL'){ //As per Business only Mechanical Hours to be Overbooked.
                ////system.debug(LoggingLevel.INFO,'===============>'+resultOpt.Diary_Entry_ID__r.Week__r.Employee__r.Name);
                //Remove the Over booking Hours from the Search result to calculate the new END TIME
                //system.debug(LoggingLevel.INFO,'Inside Mech:'+resultOpt.End_Date_Time__c+' '+(totalHoursToBook-rounddown));
                resultOpt.End_Date_Time__c = DateTimeHelper.removeHoursFromDT(resultOpt.End_Date_Time__c,totalHoursToBook-rounddown);
                //system.debug(LoggingLevel.INFO,'Inside Mech-1:'+resultOpt.End_Date_Time__c+mainStartTime+relatedEntry);
                //calculate the OBHours for the new END TIME. calculating outside would change the End time
                OBHours = totalHoursToBook - DateTimeHelper.calculateHours(mainStartTime, resultOpt.End_Date_Time__c, relatedEntry);
                If(OBHours>0) 
                BookJobOptionController.Msg1 +='Needs Over Overbooking for '+resultOpt.Diary_Entry_ID__r.Week__r.Employee__r.Name+' by: '+OBHours.setScale(2)+' Hours ('+(OBHours*60).setScale(2)+' Min'+')'+' <br/>';
                } //squeezing Electrical hours calc. OB hours in Job Booking Manager Class with the New END DATE TIME.
                  // so its better not to squeeze the Electrical Hours/not to cal. new end date.
                else If(resultOpt.Skill__c!='ELECTRICAL'){  
                  resultOpt.End_Date_Time__c = DateTimeHelper.removeHoursFromDT(resultOpt.End_Date_Time__c,totalHoursToBook-rounddown);
                }
                
                mainEndTime = resultOpt.End_Date_Time__c;
                
              
              }
             //system.debug(loggingLevel.INFO,'======>'+resultOptions);
            } 
            //system.debug(LoggingLevel.INFO,'OBHOURS------>'+OBHours);

           }
        }
  
  }
  //Method to calculate OVER Booking Hours when Squeeze is checked
   public void CalcOverBookedHours(){
      TotOBHours = 0.0;
      isOverbook = false;
      Msg1 ='';
      TotOBHors = '';
      if(EntMap != null){ //Map to update the Result Enddate when Squeeze Job is Unchecked
        for(SearchResult UpdRes: Wresults){
          if(EntMap.containskey(UpdRes.result.Diary_Entry_ID__c))
          UpdRes.result.End_Date_Time__c = EntMap.get(UpdRes.result.Diary_Entry_ID__c);
        }
      }
      Updres=null; // if squeeze Job is uncheck clear the list.
      if(job.Squeeze_Job__c){
      
      isOverbook= True;
      //system.debug(LoggingLevel.INFO,'===========WR:'+WResults);
      List<Search_result__c> Uresult;
      EntMap = new Map<Id,datetime>();
      List<Search_Result__c> ClonedResults = new List<Search_Result__c>(); //Store the Cloned Search Result to process 
      
      Set<Id> diaryEntIdSet = new Set<Id>();
         for(SearchResult sr11: WResults){ 
         //Wresult Holds All Search results of Skills: TT/Mech/ELE,etc., 
         //we dont want to include Travel Time Skill in calculating OverBook Hours
             if(sr11.result.Skill__c != 'Travel Time'){
                 diaryEntIdSet.add(sr11.result.Diary_Entry_ID__c); //Get Diary Entry ID to get the week ID.
                 Search_Result__c CSR = new Search_Result__c();
                 CSR = sr11.result.clone(True); 
                 ClonedResults.add(CSR);
             }
             EntMap.put(sr11.result.Diary_Entry_ID__c,sr11.result.End_Date_Time__c);
         }
          Map<Id, Diary_Entry__c> diaryEntIdToDiaryEntMap = new Map<Id, Diary_Entry__c>(
            [Select d.Week__r.Sunday_End_Time__c, d.Week__r.Saturday_End_Time__c, 
            d.Week__r.Friday_End_Time__c, d.Week__r.Thursday_End_Time__c, 
            d.Week__r.Wednesday_End_Time__c, d.Week__r.Tuesday_End_Time__c,
             d.Week__r.Monday_End_Time__c, d.Week__r.Sunday_Start_Time__c, 
             d.Week__r.Saturday_Start_Time__c, d.Week__r.Friday_Start_Time__c, 
             d.Week__r.Thursday_Start_Time__c, d.Week__r.Wednesday_Start_Time__c, 
             d.Week__r.Tuesday_Start_Time__c, d.Week__r.Monday_Start_Time__c, 
             d.Week__c, d.Week__r.Employee__c , record_Type__c, Start__c, End__c         
             From Diary_Entry__c d where Id in :diaryEntIdSet]);
          Map<Id, overBookedCls> weekIdToEmpData1 = new Map<Id, overBookedCls>();//Store Week Id and the Results to process in that week(Easy in calc. overbooking hours if any in that week)     
          //double rounddown = (integer.valueof(totalHoursToBook) / 4) * 4;
           // If(totalHoursToBook != rounddown){
              Uresult = new List<Search_Result__c>();
              for(Search_Result__c sr111: ClonedResults){
                Id WeekID = diaryEntIdToDiaryEntMap.get(sr111.Diary_Entry_ID__c).week__c;
                if(weekIdToEmpData1.containsKey(WeekID)){
                   //system.debug(LoggingLevel.INFO,'======EMP DATA:'+WeekIdToEmpData1);
                   weekIdToEmpData1.get(weekid).addResult(sr111);
                   weekIdToEmpData1.get(weekid).mainEndTime = sr111.End_Date_Time__c;
                   ////system.debug(LoggingLevel.INFO,'======EMP DATA1:'+WeekIdToEmpData);
                }else{
                //system.debug(LoggingLevel.INFO,'=========>before:'+sr111.End_Date_Time__c);
                overBookedCls obc = new overBookedCls(WeekID,sr111.Start_Date_Time__c, sr111.End_Date_Time__c,diaryEntIdToDiaryEntMap.get(sr111.Diary_Entry_ID__c));
                obc.addResult(sr111);
                weekIdToEmpData1.put(WeekID,obc);
                }
                 
              }
              
              for(Id weekId1 : weekIdToEmpData1.keySet())
              {
                    weekIdToEmpData1.get(weekId1).calOBHours();
                    TotOBHours +=WeekIdToEmpData1.get(weekId1).OBHours.setScale(2); //Add Each weeks Over Booking Hours to get the Total.
                    //TotOBHours.setScale(2);
                    Uresult.addAll(WeekIdToEmpData1.get(WeekId1).resultOptions); //Add it to update the Search Results after clicking Make these Booking button.
                    //system.debug(LoggingLevel.INFO,'================>TOT:'+TotOBHours+' '+WeekIdToEmpData1.get(WeekId1).resultOptions);
              }
              weekIdToEmpData1.clear();
              
            //}  
       TotOBHors = TotOBHours+' ('+(TotOBHours*60)+' Min)';
       //system.debug(LoggingLevel.INFO,'URESULT:'+Uresult);     
       if(Uresult.size()>0 && Uresult!=null){
       Updres = Uresult; //Copy the Update Result to get it updated by after click on Book button on VF Page
       Map<Id,datetime> UReMap = new Map<Id,DateTime>();//Update result Map(UReMap) holds the Diary Entry Id and End date Time.
           for(Search_result__c Usre: Uresult){
              UReMap.put(Usre.Diary_Entry_ID__c,Usre.End_Date_Time__c); //
           }
           for(searchResult Wsr : Wresults){
             if(UReMap.containskey(Wsr.result.Diary_Entry_ID__c)) //Check it to update the result End time.
             Wsr.result.End_Date_Time__c = UReMap.get(Wsr.result.Diary_Entry_ID__c);
           }
       }
       //system.debug(LoggingLevel.INFO,'URESULT:'+Updres);
       //system.debug(LoggingLevel.INFO,'Wresult:'+Wresults);  
      }
        
   }  

 //method added to populate serviceLevelReason
    public void fetchSLR(){
        //system.debug('####InFunction###');
        if(serviceLevel == Label.Not_Within_Standard){
            SLR = new List<selectOption>();
            SLR.add(new selectOption('-NONE-','-NONE-'));
            List<String> str = Label.Not_Within_Standard_Reason.split(';');
            for(String s:str)
              SLR.add(new selectOption(s,s));
        }
        else if(serviceLevel==Label.Customer_Requested){
            SLR = new List<selectOption>();
            SLR.add(new selectOption('-NONE-','-NONE-'));
            List<String> str = Label.Customer_Requested_Reason.split(';');
            for(String s:str)
              SLR.add(new selectOption(s,s));
        }
        else if(serviceLevel==Label.Green_Deal){
            SLR = new List<selectOption>();
            SLR.add(new selectOption('-NONE-','-NONE-'));
            List<String> str = Label.Green_Deal_Reason.split(';');
            for(String s:str)
              SLR.add(new selectOption(s,s));
        }
        else if(serviceLevel=='Within Standard'){
            
            withinStandard = true;
            serviceLevelReason = 'Within Standard';
            
        }
        //system.debug('####debug###'+SLR);
        //system.debug('####debug###'+serviceLevel);
        //system.debug('####debug###'+serviceLevelReason);
    }
    public void confirm(){
      
      if(system.label.TestSite == '1')
      {
          Job__c jobVar = [Select Delivery_Date__c from Job__c where Id = :job.Id];
          if(jobVar.Delivery_Date__c==null)
          {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Delivery Date: Please enter the value');
            ApexPages.addMessage(msg);
           
            return;
            
          }else
          {
              job.Delivery_Date__c = jobVar.Delivery_Date__c;
              if(job.Delivery_Date__c > currentInstallDate)
              {
                        
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please Select a past Delivery date as Installation date is :'+currentInstallDate.format());
                    ApexPages.addMessage(msg);
                    return;
                        
              }
        }
      
      }
      
      
      confrm=TRUE;
      pgb=FALSE;
      title = 'Confirm Booking';
      getASPRequestedItems();
      
    
    }
    
    public pageReference back(){
      string rparameters = 'lead='+job.CHI_Lead__r.CHI_Lead_Id__c+'/'+'M='+job.Mechanical_Hours__c+'/'+'PF='+job.PowerFlush_Hours__c+'/'+'E='+job.Electrical_Hours__c+'/'+'B='+job.Building_Work_Hours__c+'/'+'RHC='+job.Remote_Heating__c+'/'+'R='+job.Roof_Work_Hours__c+'/'+'ECO='+job.ECO_Hours__c+'/'+'SB='+job.Specialist_Building_Hours__c+'/'+'MSL='+job.Connect_Solar_Panel_Hours__c+'/'+'CI='+job.Contractor_Installation_Hours__c+'/'+
                              'FF='+job.Fire_Wall_Heater_Fixing_Hours__c+'/'+'LP='+job.LPG_Installation_Hours__c+'/'+'PC='+job.Payment_Collection_Hours__c+'/'+'MEG='+job.Ecogen_Mechanical_Hours__c+'/'+'S='+job.Scaffolder_Hours__c+'/'+'UV='+job.Unvented_Hot_Water_Hours__c+'/'+'WF='+job.Water_Heating_Fixing_Hours__c+'/'+'EA='+job.Electrical_Work_ASP_Hours__c+'/'+'A='+job.Asbestos_Removal_Hours__c+'/'+'AF='+job.Asbestos_Removal_Fixed_Rate_Hours__c+'/'+
                              'EG='+job.Ecogen_Electrical_Hours__c+'/'+'LC='+job.Landlord_Check_Hours__c;
      if(job.Boiler_Location__c!=null)
      rparameters = rparameters+'/'+'Bloc='+job.Boiler_Location__c;
                
      if(job.Installation_Type__c!=null)
      rparameters = rparameters+'/'+'InstType='+job.Installation_Type__c;
      
       pageReference pageRef = new pageReference('/apex/ReadParametersfromURL?'+rparameters);
       pageref.setRedirect(true);
       return pageref;
    }
    
    public pageReference backToPlan(){
        
        pagereference pageref = new pagereference('/apex/SearchResultsHSA?jobid='+job.id+'&p=N&custDate='+Bookingdate.substring(0,2) + '/' + Bookingdate.substring(3,5) + '/' +Bookingdate.substring(6,10));
        pageref.setRedirect(true);
        return pageref; 
      
    }
    
    public void bookOptionHSA() {
        cls_IsRun.setisinstUpdCustCatMasRec();
        if(serviceLevel == '-NONE-' || serviceLevelReason == '-NONE-'){
              //system.debug('####error###'+serviceLevel+serviceLevelReason);
              ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please enter Service Level and Service Level Reason.');
              ApexPages.addMessage(msg);
              return;
              
            } 
        System.Savepoint rollbackPoint = Database.setSavepoint();  
        //try {
            //buttonClicked = true;
           
           //change 1379 by Ashok G
           ////system.debug('@@Direction2:'+JPH.Direction2__c);
           
             
            
                
             if(JPH.Re_Plan_Reason__c!='Customer postponed' && currentInstallDate > priorInstallDate )         
               {
                   job.Multiple_Re_Plans__c=+1;
               }    
              
              job.Job_Reason__c = serviceLevel ;
              job.CRD_Code__c = serviceLevelReason ;
              
              job.Travel_Distance__c =  trav_Dist;
              job.Travel_Time__c = trav_Time;
              job.Needs_Re_Planing__c = false;
              
              lock.jobTriggerSwitch = true;
              Database.update(job);
              lock.jobTriggerSwitch = false;
              
              JobBookingManager.planOrReplanJob(optionID);
              bookingStatus = 'Options were booked!';
                     
             // Retrieve job again to avoid overriden data 
            // updated query fields June 2012 : Prashant 

            job = [select ID,DPA_Done__c, Installation_Date__c, Needs_Re_Planing__c,Sent_text_to_customer__c, Customer_journey_status_index__c,squeeze_Job__c,Exception_reason__c,Exception_Required__c,Rule_Broken_By__c,  
                  CHI_Lead__c, CHI_Lead__r.Account.Dummy_Data__c,PTS_Rollout__c, Delivery_Slot__c, Delivery_Date__c, CHI_Lead__r.isSystem__c,
                  Delivery_Notes__c, CRD_Code__c,Bring_Forward_Job__c,Refused_Earlier_Date__c,
                  CHI_Lead__r.Installation_opt_out_reason__c,CHI_Lead__r.Installation_Opt_Out_Type__c,CHI_Lead__r.Createddate,CHI_Lead__r.Latest_customer_category__c,
                  CHI_Lead__r.Customer_have_any_other_form_of_HEAT__c,CHI_Lead__r.Date_and_time_job_planned__c,
                  CHI_Lead__r.Does_the_customer_have_hot_water__c,CHI_Lead__r.Is_the_customers_boiler_working__c,
                  CHI_Lead__r.Is_the_customer_vulnerable__c,CHI_Lead__r.Vulnerable_reason__c, Engineer_Spoken_To__c,
                  Split_Job__c, Is_Remedial_Job__c, Is_Downtime_Job__c,Job_Reason__c,Status__c,Sub_Status__c,Job__c.Multiple_Re_Plans__c,
                  (Select Id,Pre_installation_call_date__c from Customer_history_cards__r),
                  (Select Id, Prior_Delivery_Slot__c, Type__c, Status__c, Delivery_Date_Changed__c, Send_via_email__c, 
                    CreatedDate, Order_Value_Text__c,Prior_Order_Value__c, Customer_best_phone__c, Supplier_Name__c, Job_Delivery_Date__c, Prior_Delivery_date__c, 
                    Delivery_Slot__c, Enquiry_Number__c, Job__r.Name, Job__r.PlannerName__c, Job__r.CHI_Lead__r.CHI_Lead_Id__c, 
                    Job__r.Customer_Name__c, SAP_Number__c, Job__r.CHI_Lead__r.Account.BillingStreet, Order_Value__c, 
                    Job__r.CHI_Lead__r.Account.BillingCity, Job__r.Id, Job__r.CHI_Lead__r.Account.BillingState, 
                    Job__r.CHI_Lead__r.Account.BillingCountry, Job__r.CHI_Lead__r.Account.BillingPostalCode From Purchase_Orders__r),
                   (Select Name, Start__c, End__c, Hours__c, Sub_Type__c, ID,Week__c, Week__r.Employee__r.Name,Week__r.Employee__c,
                   Week__r.Monday_Start_Time__c,Week__r.Monday_End_Time__c,Week__r.Tuesday_Start_Time__c,Week__r.Tuesday_End_Time__c,
                   Week__r.Wednesday_Start_Time__c,Week__r.Wednesday_End_Time__c,Week__r.Thursday_Start_Time__c,Week__r.Thursday_End_Time__c,
                   Week__r.Friday_Start_Time__c,Week__r.Friday_End_Time__c,Week__r.Saturday_Start_Time__c,Week__r.Saturday_End_Time__c,
                   Week__r.Sunday_Start_Time__c,Week__r.Sunday_End_Time__c,Overbooked_Hours__c
                   from Diary_Entries__r order by End__c desc), 
                   (Select id from NWD_Detail__r)          
                  from Job__c where ID = :jobID];
             
             //Change By ASHOK G To create Diary Entries for Travel Time with Record Type 'NON PRODUCTIVE JOB BOOKING' Type
             //system.debug(LoggingLevel.INFO,'----Entreis:'+job.Diary_Entries__r);
             //system.debug(LoggingLevel.INFO,'---Wresults--->'+WResults);
             
             //system.debug(LoggingLevel.INFO,'----------->1'+travelDe);
             map<Id,List<DateTime>> wstartEndMap = new Map<Id,List<DateTime>>();
             Map<Id,List<Diary_Entry__c>> WDemap = new Map<Id,list<Diary_Entry__c>>();
              for(Diary_Entry__c bo: job.Diary_Entries__r){
                   
                   if(wStartEndMap.containskey(bo.week__c)){
                      Datetime[] strtEnd = wStartEndMap.get(bo.Week__c);
                      if(bo.start__c < strtEnd[0])
                      strtEnd[0] = bo.start__c;
                      
                      if(bo.End__c > strtEnd[1])
                      strtEnd[1] = bo.End__c;
                      
                      wStartEndMap.put(bo.Week__c,strtEnd);
                   }else{
                      List<DateTime> startEnd = new list<DateTime>();
                      startEnd.add(bo.start__c);
                      startEnd.add(bo.End__c);
                      wStartEndMap.put(bo.Week__c,startEnd);
                      
                   }
                   
                   if(WDemap.containskey(bo.Week__c)){
                   list<Diary_Entry__c> tempList = new list<Diary_Entry__c>();
                   tempList.addall(WDemap.get(bo.Week__c));
                   tempList.add(bo); 
                     WDemap.put(bo.Week__c,tempList);
                     
                   }else{
                     list<Diary_Entry__c> diaries = new list<Diary_Entry__c>();
                     diaries.add(bo);
                     WDemap.put(bo.Week__c,diaries);
                   }
                   
               }
              //TravelDE.clear();
              TravelDE = new list<Diary_Entry__c>();
              //system.debug(LoggingLevel.INFO,'===========>wdemap:'+WDemap+' '+WstartEndMap); 
              for(SearchResult sr: WResults){
                  
                  if(sr.result.Skill__c == 'Travel Time' && wstartEndMap.containskey(sr.WeekId))
                  {     
                        //system.debug(LoggingLevel.INFO,'======>Inside Travel'+sr+sr.result.Hours__c);
                        Diary_Entry__c de = WDemap.get(sr.WeekId)[0];
                        //system.debug(LoggingLevel.INFO,'========caslc:'+de+' '+DateTimeHelper.addWorkingHoursToDateTime(sr.result.Start_Date_Time__c,Double.valueof(sr.result.Hours__c),de));
                        if(sr.result.Order__c == 'Front'){
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(sr.result.Start_Date_Time__c,Double.valueof(sr.result.Hours__c),de);
                          TravDE.Start__c = wstartEndMap.get(sr.WeekId)[0];
                          TravDE.Week__c = sr.WeekId;
                          TravDE.Travel_Job__c = sr.result.Travel_Job__c;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c =sr.result.Job_ID__c;
                          TravDE.Hours__c = sr.result.Hours__c;
                          TravelDE.add(TravDE);
                        
                        }else{
                          Diary_Entry__c TravDE = new Diary_Entry__c();
                          TravDE.Start__c = wstartEndMap.get(sr.WeekId)[1];
                          TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(TravDE.Start__c,Double.valueof(sr.result.Hours__c),de);
                          TravDE.Week__c = sr.WeekId;
                          TravDE.Travel_Job__c = sr.result.Travel_Job__c;
                          TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                          TravDE.Sub_Type__c = 'Travel Time';
                          TravDE.Job__c =sr.result.Job_ID__c;
                          TravDE.Hours__c = sr.result.Hours__c;
                          TravelDE.add(TravDE);
                        }
                    }  
                     
                   
                   }
             
             if(TravelDE.size()>0)
             insert TravelDE;
             
             //getting new installation date upon clicking make these button on plan job on Job Planning History custom object.
             
             newdate=job.Installation_Date__c;
             
             // calling JobReplanning() once the query on updated job finish to populate values defined in JobReplanning()method
             JobReplanning();
             //SM PH II Change End
             // Added as part of customer history card change request.
              
              booked = job.Diary_Entries__r;
              
              if(booked != null && booked.size()>0){
                
                bookedRetrieved = true;   
                            
              }
              
              DateTime installDatetime = datetime.newInstance(2090, 12, 1, 12, 30, 2);
              Map<Id, double> NWDEgnineerIdTimeMap = new Map<Id, double> ();
              
              if(job.NWD_Detail__r.size()>0)
              {
                  delete job.NWD_Detail__r;
              }
              
              for(Diary_Entry__c de : booked){
                  
                   if(de.Start__c <= installDatetime){
                            installDatetime = de.Start__c;
                        }
                
                if(System.Label.Customer_Journey_Flag == 'TRUE' && de.Sub_Type__c == 'Mechanical'){
                    
                    job.Mechanical_Skill_End_Date__c = de.End__c.date();
                }
                
                // Delete existing Non working Details.
                
                
                // try to find if there are any new NWD to be created?
    
                for(Diary_Entry__c nwd : NonWorkingDiaryEntries)
                {
                    
                     dateTime startNWDTime;
                     dateTime endNWDTime;
                     double NWDHours =0;
                if((de.Week__c == nwd.Week__c) && ((de.Start__c< nwd.End__c && de.End__c> nwd.Start__c) || (de.Start__c<= nwd.Start__c && de.End__c>= nwd.End__c)))        
                    //if((de.Week__c == nwd.Week__c) && ((de.Start__c< nwd.End__c && de.End__c> nwd.Start__c) || (de.Start__c>= nwd.Start__c && de.End__c>= nwd.End__c)))
                    {
                        //system.debug('--->inside<--');
                        //system.debug('--->inside<--'+de.Start__c+'-----'+de.End__c);
                        //system.debug('--->inside<--'+nwd.Start__c+'-----'+nwd.End__c);
                        if(de.Start__c>= nwd.Start__c)
                        {
                            startNWDTime = de.Start__c;
                        }else{
                            startNWDTime = nwd.Start__c;
                            
                        }
                        
                        if(de.End__c >= nwd.End__c)
                        {
                            endNWDTime = nwd.End__c;
                        }else
                        {
                            endNWDTime = de.End__c;
                        }
                        
                        NWDHours = DateTimeHelper.calculateHours(startNWDTime, endNWDTime, de);
                        //overbooked hours calculation on NWD
                        if(de.Overbooked_Hours__c!=NULL && nwd.End__c>=de.End__c)
                        NWDHours +=de.Overbooked_Hours__c;
                        
                        //system.debug('NWD Hours--->'+NWDHours);
                        if(NWDHours>0)
                        {
                        if(NWDEgnineerIdTimeMap.containsKey(de.Week__r.Employee__c))
                        {
                            NWDHours+= NWDEgnineerIdTimeMap.get(de.Week__r.Employee__c);
                        }
                        NWDEgnineerIdTimeMap.put(de.Week__r.Employee__c, NWDHours);
                        }
                        
                        //system.debug('---->'+NWDEgnineerIdTimeMap);
                        
                    }
                }
                
                
              }
              
            lock.jobTriggerSwitch = true;
            update job;
            lock.jobTriggerSwitch = false;
            list<NWD_Detail__c> insertNewList = new list<NWD_Detail__c>();  
            for(id empid : NWDEgnineerIdTimeMap.keyset())
            {
               insertNewList.add( new NWD_Detail__c(Employee_Name__c = empid, Job_Number__c = job.Id, Hours__c = NWDEgnineerIdTimeMap.get(empid)));
            }
            
            if(insertNewList.size()>0)
            insert insertNewList;
            
               
                // Added Prashant June 2012 Priority Installations CR
                if(include_priority_install && cls_IsRun.isUpdateServiceLevelValues == false){
                              job.CHI_Lead__r.Last_customer_cat_info_update_source__c = 'Installation';
                              job.CHI_Lead__r.Pending_update_to_customer_category__c = True;
                              job.CHI_Lead__r.Customer_Category_Modified_Datetime__c = Datetime.Now();
                              job.CHI_Lead__r.Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
                              job.CHI_Lead__r.Stage_object_Type__c = 'Job';
                              job.CHI_Lead__r.Stage_object_Id__c = job.Id;
                              job.CHI_Lead__r.Installation_Date_Time__c = installDatetime;
                              job.CHI_Lead__r.Date_and_time_job_planned__c = Datetime.Now();
                              job.CHI_Lead__r.Installation_opt_out_reason__c = job.CRD_Code__c;
                              job.CHI_Lead__r.Installation_Opt_Out_Type__c = job.Job_Reason__c;
                              cls_IsRun.setisUpdateServiceLevelValues();
                              update job.CHI_Lead__r;
                              
                              
                }
               
             
            // Send re-plan email CR starts
            
            try{
           
               boolean generateReplanNotice = false;
              
               if(job.Delivery_Date__c != null && this.priorDeliveryDate != null && job.Delivery_Date__c != this.priorDeliveryDate){
                 generateReplanNotice = true;
               }
               
               if(job.Delivery_Slot__c != null && this.priorDeliverySlot != null && job.Delivery_Slot__c != this.priorDeliverySlot){
                 generateReplanNotice = true;
               }
               
               if(generateReplanNotice){

                          List<Order__c> orderLst = new List<Order__c>();
                              
                          for(Order__c ord : job.Purchase_Orders__r){
                            
                             if(ord.Delivery_Date_Changed__c && ord.Type__c == 'Material' && ord.Status__c != 'Cancelled' && ord.Status__c != 'Rejected' && ord.Status__c != 'Inactive'){
                               
                               ord.Send_via_email__c = true;
                               orderLst.add(ord);

                             }
                             
                          }
                          
                          if(orderLst != null && orderLst.size() > 0){
                                
                              Database.Update(orderLst,true);
                              SendReplanPDFViaEmail s = new SendReplanPDFViaEmail();
                              s.sendEmail(orderLst);
                              
                          }
                          
              }
               
           
         }catch(Exception excp){
         
               //system.debug('Exception Type 1 In Replan '+excp.getMessage()); 
               ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
               ApexPages.addMessage(msg);
               Error = TRUE;
               errorMsg = excp.getMessage();
               
           
         } 
         
         // Send re-plan email CR Ends
             
            // Auto-generate purchase orders as part of planning process if no order is yet generated on this job.
             Pagereference p;  
             Integer numberOfOrders = 0;
              
             String autoGenerateOrders = System.Label.Auto_Generate_Purchase_Orders;  
              
             try{
                
                 if(autoGenerateOrders.equalsIgnoreCase('TRUE')){
                 
                    if(job.Purchase_Orders__r != null && job.Purchase_Orders__r.size() > 0){
                        
                       numberOfOrders = job.Purchase_Orders__r.size();
                  
                    }
                    
                    if(numberOfOrders==0){
                 
                         
                         
                         if(plan){
                            
                            sucess=true;
                            //system.debug(LoggingLevel.INFO,'ErrorMSG:'+rerenderblocks+sucess);
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Planning Successful – please remember to enter the dates in quote tool.');
                            ApexPages.addMessage(msg);
                            
                         }
                 
                    } 
                 }
                 
                 List<Id> jobIdList = new List<Id>{jobID};
              
                 JobSharingCls.createJobSharing(jobIdList);
                 
              } catch(Exception ex){
  
                //system.debug('An exception occured in auto-generating the orders :  '+ex.getMessage()+' Error in line number : '+ex.getLineNumber());         
                Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
                email1.setSubject('Exception thrown while auto generating purchase orders');      
                String[] toAddresses = new String[] {'BGSAMS.Support@centrica.com'};       
                email1.setToAddresses(toAddresses);      
                email1.setPlainTextBody('An exception occured in auto-generating the orders :  '+ex.getMessage()+' Error in line number : '+ex.getLineNumber());      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});       
              }
                    
           
          // return null;
           
    }
    
    public Job__c getASPRequestedItems()
    {
      
                    String query = 'SELECT ';
                        Set<String> fieldsList = new Set<String>();
                        for(Schema.FieldSetMember f : jobfields) {
                                fieldsList.add(f.getFieldPath());
                        }
                        /*
                         * Make sure required fields are present
                         */
                        if(!fieldsList.contains('Id')) {
                                fieldsList.add('Id');
                        }
                        if(!fieldsList.contains('Name')) {
                                fieldsList.add('Name');
                        }
                        query += String.join(new List<String>(fieldsList), ',');
                        query += ' FROM Job__c Where id= \'' + job.Id + '\'';
                        ASPRequestItems = Database.query(query);
       
                           
       return ASPRequestItems;
    }
    public String formatSJobReason(List<String> values) {
        if (values == null)
        {
            return null;
        }
        return String.join(values, ';');
    }
}