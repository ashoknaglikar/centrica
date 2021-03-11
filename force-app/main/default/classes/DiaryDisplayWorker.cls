public with sharing class DiaryDisplayWorker {

    public List<Employee> employees = new list<Employee>();
    transient List<Employee> empSortedList = new list<Employee>();
    private static String Normal = 'Normal';
    private static String Away = 'Away';
    private static String OnLoan = 'On Loan';
    private static String WorksAnywhereInDistrict = 'Anywhere In District';
   // Set<String> profileNames = new Set<String> {'CHI Installation Lead Engineer','CHI Installation - DHM' ,'System Administrator'};
    private static Integer NoCols = 140;            // Number of columns the diary is split into
    private static Double lengthperhour = 15;       // number of pixcels per hour
    //User currentUser {get; set;}
    private DateTime dtWeekStart;
    public string area{get;set;}
    //public map<id,boolean> WeekLock = new map<id,boolean>{null=>false};
    //public string districtId {get;set;}
    
    
    public static String formatDouble(Double num, Integer decimalplaces) {
//          System.debug('num: ' + num + 'decimalplaces: ' + decimalplaces);
            Double multiplier = Math.pow(10, decimalplaces);
            num = num*multiplier;
//              System.debug('multiplier: ' + multiplier + ' num: ' + num + 'decimalplaces: ' + decimalplaces);
            Long rounded = Math.roundToLong(num);
            num = rounded/multiplier;
            String formated = Decimal.valueOf(num).format();

            //add zeros if needed
            Integer dotIndex = formated.indexOf('.');
        
            if(dotIndex < 0) {
                formated += '.';
                for(Integer i=0; i<decimalplaces; i++) {
                    formated += '0';    
                }
            } else {
            Integer needed = decimalplaces - formated.substring(dotIndex+1).length();
            for(Integer i=0; i <needed; i++) {
                formated += '0';
            }
        }
          return formated;
    }   
    
    
    
   public List<Employee> getEmployees() {
      return employees;
   }
   
   
    public void getEmployeesForDiary(ID districtID, DateTime startDT, DateTime endDT, People_Hirearchy__c ph) {
        dtWeekStart = startDT;
        transient List<Employee> empOwnLabour = new list<Employee>();
        transient  List<Employee> empsAway= new list<Employee>();
        transient  List<Employee> empsOnLoan= new list<Employee>();
        transient  List<Employee> empsCP= new list<Employee>();
        transient  List<Employee> empsCNP= new list<Employee>();
        transient List<Employee__c> empList = new List<Employee__c>();
        
    if(ph!=null && ph.Employee__c != null)
    {
        list<id> pEmpIds = new list<Id>();
        list<id> pEmployeesIds = new list<Id>();
        ph = [Select id, Employee__c, Level__c from People_Hirearchy__c where Employee__c =: ph.Employee__c];
        if(ph.Level__c == '6')
        {
            for(People_Hirearchy__c P :  [Select Id   from People_Hirearchy__c where Manager__c = :ph.Id])
            {
                pEmpIds.add(p.Id);
            }
            
        } else
        pEmpIds.add(ph.Id);
        system.debug(pEmpIds.size());
        for(People_Hirearchy__c P :  [Select  Employee__c from People_Hirearchy__c where Manager__c in : pEmpIds])
        {
            pEmployeesIds.add(p.Employee__c);
        }
        
        system.debug(pEmployeesIds.size());
        
       for( Employee__c e :  [Select ID, District__c, District__r.Name, Pool_Diary__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                      Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c,  Salesforce_User__r.Profile.Name, Inactive__c From Employee__c where id in :pEmployeesIds and Role__c like '%Installer%' order by sortemployee__c ])
       {
           empList.add(e);
           Employee emp = new Employee(e.Name, Normal, e, dtWeekStart,e.Role__c,e.Postcode__c);
           employees.add(emp);
       }
        
    }else
    {
    
      //user currentUser = [Select Profile.Name, Id From User u where id =: Userinfo.getUserId()];
       empList = [select ID, District__c, District__r.Name, Pool_Diary__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                      Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c,  Salesforce_User__r.Profile.Name, Inactive__c from Employee__c where Salesforce_User__c=: Userinfo.getUserId()];  
       
     if(empList.size()>0 && Utilities.fetchprofilenames(system.label.Diary_View_Profile_Individual).contains(empList[0].Salesforce_User__r.Profile.Name))
      {
       system.debug('@@@@Emplist'+empList[0]);
       system.debug('@@@@Emplist'+empList[0].Salesforce_User__c);
       system.debug('@@@@Emplist'+empList[0].Salesforce_User__r.Profile.Name);
        /*
         empList = [select  ID, District__c, District__r.Name, Pool_Diary__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                      Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c from Employee__c where Salesforce_User__c=: Userinfo.getUserId()];*/
         for(Employee__c e: empList)
         {
            Employee emp = new Employee(e.Name, Normal, e, dtWeekStart,e.Role__c,e.Postcode__c);
            employees.add(emp);
            system.debug('@@@employees'+employees);
         }
         
     }
     else
     {
       
        
        /*//This Code breaks if the query returns more than 1000 rows
        Employee_Postcode_Sectors__c[] empPCSForThisDistrict = [Select ID, Employee__c 
                                                            from Employee_Postcode_Sectors__c 
                                                            where Postcode_Sector__r.Sub_Patch__r.District__c = :districtID
                                                                    and Start_Date__c < :endDT.date()
                                                                    and End_Date__c > :startDT.date()];
        
        Set<ID> empsIDsWithPCS = new Set<ID>();
        
        for(Employee_Postcode_Sectors__c epcs : empPCSForThisDistrict) {
            empsIDsWithPCS.add(epcs.Employee__c);
        }
        */
        set<id> empsIdWithAwayPc = new Set<ID>();
        
        Set<ID> empsIDsWithPCS = new Set<ID>();
        for(Employee_Postcode_Sectors__c epcs : [Select ID, Employee__c, Type__c 
                                                            from Employee_Postcode_Sectors__c 
                                                            where Postcode_Sector__r.Sub_Patch__r.District__c = :districtID
                                                                    and Start_Date__c < :endDT.date()
                                                                  and End_Date__c > :startDT.date()]) {
                
            if(epcs.Type__c == 'Away')
            {
                empsIdWithAwayPc.add(epcs.Employee__c);
                
           }
            empsIDsWithPCS.add(epcs.Employee__c);
                        system.debug('@@@@empsIDswithPC'+empsIDsWithPCS);
        }   
                
        Employee_Postcode_Sectors__c[] empPCSForOtherDistricts = new List<Employee_Postcode_Sectors__c>();
        //Employee_Postcode_Sectors__c[] 
        empPCSForOtherDistricts = [Select ID, Employee__c 
                                from Employee_Postcode_Sectors__c 
                                where Postcode_Sector__r.Sub_Patch__r.District__c != :districtID
                                        and Start_Date__c < :endDT.date()
                                        and End_Date__c > :startDT.date()
                                        and Employee__c IN :empsIDsWithPCS
                                        and Type__c = 'Away'];
        
        Set<ID> empIDsInOtherAreas = new Set<ID>();
        
        for(Employee_Postcode_Sectors__c epcs : empPCSForOtherDistricts) {
            empIDsInOtherAreas.add(epcs.Employee__c);
        }
        
        /////////////////////////////////
        //Rjd - TODO: remove these lines
               
      
      /*  Employee__c[] emps = [select ID, District__c, Pool_Diary__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                                Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c,Inactive__c
                                from Employee__c 
                                where ID in :empsIDsWithPCS or (District__c = :districtID and Works_Anywhere_In_District__c = true) order by sortemployee__c]; */
           Employee__c[] emps = [select ID, District__c, Pool_Diary__c,Own_Labour__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                                Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c,Inactive__c,District__r.Away__c,
                                District__r.Contractor_Pool__c,District__r.On_Loan__c,District__r.Own_labour_Employee__c,
                                District__r.Contractor_Non_Pool__c, (Select Id, SKill__c from Optout_Skills__r), End_Date__c
                                from Employee__c 
                                where ID in :empsIDsWithPCS or (District__c = :districtID and Works_Anywhere_In_District__c = true) order by sortemployee__c ];
             
           District__c[] listDistrict = [select id,Away__c,Contractor_Pool__c,On_Loan__c,Own_labour_Employee__c,Contractor_Non_Pool__c from District__c where id=:districtID ];   
           for(Employee__c e : emps) {
                if(e.End_Date__c!=null && e.End_Date__c<system.today())
                continue;
                if(e.District__c == districtID && empsIDsWithPCS.contains(e.ID) && !empIDsInOtherAreas.contains(e.ID)) {
                 // This employee is assigned to this district, and is covering postcode sectors in this district, 
                // and does not have postcode sectors in other areas 
                Employee emp = new Employee(e.Name, Normal, e, dtWeekStart,e.Role__c,e.Postcode__c);
                if(e.Own_Labour__c==1){
                empOwnLabour.add(emp);
                }
                 else if(e.Pool_Diary__c==true){
                     empsCP.add(emp);
                 }
                 else if(e.Pool_Diary__c==false){
                     empsCNP.add(emp);
                    }
                  // employees.add(emp);
                } else if(e.District__c == districtID && e.Works_Anywhere_In_District__c == true && !empIDsInOtherAreas.contains(e.ID)) {
                    // This employee is assigned to this district and covers anywhere in the district, 
                    // and does not have any postcode sectors in other districts 
                    // (i.e. he has no Postcode Sectors for the area, but this is still his district)
                    Employee emp = new Employee(e.Name, WorksAnywhereInDistrict, e, dtWeekStart,e.Role__c,e.Postcode__c);
                   // employees.add(emp);
                   if(e.Own_Labour__c==1){
                empOwnLabour.add(emp);
                }
                 else if(e.Pool_Diary__c==true){
                     empsCP.add(emp);
                 }
                 else if(e.Pool_Diary__c==false){
                     empsCNP.add(emp);
                    }
                  // empOwnLabour.add(emp); 
                } else if(e.District__c != districtID && empsIdWithAwayPc.contains(e.ID)) {
                    // Employee doesn't cover this district but has Employee Postcode Sectors for this district
                    // This employee is on loan _to_ this distirct
                    Employee emp = new Employee(e.Name, Away, e, dtWeekStart,e.Role__c,e.Postcode__c);
                    empsAway.add(emp);
                   // employees.add(emp);
                } else if(e.District__c != districtID && empsIDsWithPCS.contains(e.ID)) {
                    // This employee covers this district, but has no postcode sectors and he doesn't work anywhere in the district
                    // This employee is on loan to _another_ district
                    Employee emp = new Employee(e.Name, OnLoan, e, dtWeekStart,e.Role__c,e.Postcode__c);
                    empsOnLoan.add(emp); 
                   //employees.add(emp); 
                }
              
            
            }
              map<integer,List<Employee>> mapOrderEmp= new  map<integer,List<Employee>>() ;
            if(listDistrict.size()>0){
                 if(listDistrict[0].Own_labour_Employee__c>=0 || listDistrict[0].Own_labour_Employee__c==null ){
                 mapOrderEmp.put(Integer.valueOf(listDistrict[0].Own_labour_Employee__c),empOwnLabour);
                 }
                   if(listDistrict[0].Away__c>=0|| listDistrict[0].Away__c==null){
                 mapOrderEmp.put(Integer.valueOf(listDistrict[0].Away__c),empsAway);
                 }
                 if(listDistrict[0].On_Loan__c>=0 || listDistrict[0].On_Loan__c==null){
                 mapOrderEmp.put(Integer.valueOf(listDistrict[0].On_Loan__c),empsOnLoan);
                 }
                  if(listDistrict[0].Contractor_Non_Pool__c >=0 || listDistrict[0].Contractor_Non_Pool__c==null ){
                 mapOrderEmp.put(Integer.valueOf(listDistrict[0].Contractor_Non_Pool__c),empsCNP);
                 }
                   if(listDistrict[0].Contractor_Pool__c>=0 || listDistrict[0].Contractor_Pool__c==null){
                 mapOrderEmp.put(Integer.valueOf(listDistrict[0].Contractor_Pool__c),empsCP);
                 }
                   
            }
             system.debug('**mapOrderEmp'+mapOrderEmp);
             Set<integer> keySet = mapOrderEmp.keySet();
             List<integer> keyList = new List<integer>();
             keyList.addAll(keySet);
             keyList.sort();
             
             if((listDistrict[0].Own_labour_Employee__c==0 || listDistrict[0].Own_labour_Employee__c==null) && (listDistrict[0].Away__c==0|| listDistrict[0].Away__c==null) && (listDistrict[0].On_Loan__c==0|| listDistrict[0].On_Loan__c==null) && (listDistrict[0].Contractor_Non_Pool__c ==0 ||listDistrict[0].Contractor_Non_Pool__c==null) && (listDistrict[0].Contractor_Pool__c==0 ||listDistrict[0].Contractor_Pool__c==null ) ){
                employees.addAll(empOwnLabour);
                employees.addAll(empsAway);
                employees.addAll(empsOnLoan);
                employees.addAll(empsCNP);
                employees.addAll(empsCP);
               
                
             }
             else{
             for (Integer i = 0; i < keyList.size(); i++){
             
           
                 if(keyList[i]!=null){
                 employees.addAll(mapOrderEmp.get(keyList[i]));
                 }
                 else{
                 empSortedList.addAll(mapOrderEmp.get(keyList[i]));
                 
                 }
              }
             }
             if(empSortedList.size()>0){
             employees.addAll(empSortedList);
             
             }
             system.debug('@@employees'+employees);

           /* employees.addAll(empOwnLabour);
            
            employees.addAll(empsCP);
            employees.addAll(empsCNP);
            employees.addAll(empsAway);
            employees.addAll(empsOnLoan); */
            ////////////////////////////
            //RJD: TODO remove this
            //break;
        }
    }
        getDiaryEntry(startDT, endDT,districtID);
    }
    
    public void getDiaryEntry(DateTime startDT, DateTime endDT,Id districtID) {
      
      // GB 2010-02-07 Changing to Set of IDs
      //List <String> empId = new List<String>{}; 
      List <ID> empId = new List<ID>{};
      
//    system.debug('getDiaryEntries START');

      // GB 2010-02-07 "only15" is used as part of the later logic to process
      // Diary Entries retrieved. Rather than reverse engineer and rework code
      // at the last minute (I'm convinved this can be done in some other way)
      // I'm recreating an ID version of the variable that can then be used. 
      //String only15;
      ID theEmpID = null;
      
      for(Employee thisEmployee : getEmployees()){
        // GB 2010-02-07 Use full ID rather than 15 character
          //only15 = thisEmployee.employeeObject.Id;
          //only15 = only15.substring(0,15);
          //empId.add( only15 );
          empId.add( thisEmployee.employeeObject.ID );
          theEmpID = thisEmployee.employeeObject.ID;
      }
      
//    system.debug('getDiaryEntries EMP id:' + empId);
//    system.debug('getDiaryEntries start date:' + startDT);
//    system.debug('getDiaryEntries end date:' + endDT);
      
      DateTime theLastEntry;
      boolean shiftset = false;  //PRB00021183          
      Employee thisEmployee = null; //PRB00021183
      for(Diary_Entry__c[] diaryEntries :
        // Add postcode on planner diary view
        [Select Record_Type__c, Sub_Type__c, Start__c, Id, Hours__c, End__c, Employee_name__c,Employee_id__c, Type__c,Product_Id__c,
        
        Week__r.Sunday_End_Time__c, Week__r.Saturday_End_Time__c, Week__r.Friday_End_Time__c,
        Week__r.Thursday_End_Time__c, Week__r.Wednesday_End_Time__c, Week__r.Tuesday_End_Time__c, Week__r.Monday_End_Time__c, 
        Week__r.Sunday_Start_Time__c, Week__r.Saturday_Start_Time__c, Week__r.Friday_Start_Time__c,
        Week__r.Thursday_Start_Time__c, Week__r.Wednesday_Start_Time__c, Week__r.Tuesday_Start_Time__c, Week__r.Monday_Start_Time__c,
        Week__r.availability_hours__c,Week__r.Availability_Calc__c,Job__r.Name,Week__c,Job__r.CHI_Lead__r.CHI_Lead_Id__c, Job__r.CHI_Lead__r.Non_Op__c,
        Week__r.Monday_Unavailable_Hours__c, Week__r.Monday_Booked_Hours__c,Week__r.Monday_Max_Hours__c,
        Week__r.Tuesday_Unavailable_Hours__c, Week__r.Tuesday_Booked_Hours__c,Week__r.Tuesday_Max_Hours__c,
        Week__r.Wednesday_Unavailable_Hours__c, Week__r.Wednesday_Booked_Hours__c,Week__r.Wednesday_Max_Hours__c,
        Week__r.Thursday_Unavailable_Hours__c, Week__r.Thursday_Booked_Hours__c,Week__r.Thursday_Max_Hours__c,
        Week__r.Friday_Unavailable_Hours__c, Week__r.Friday_Booked_Hours__c,Week__r.Friday_Max_Hours__c,
        Week__r.Saturday_Unavailable_Hours__c, Week__r.Saturday_Booked_Hours__c,Week__r.Saturday_Max_Hours__c,
        Week__r.Sunday_Unavailable_Hours__c, Week__r.Sunday_Booked_Hours__c,Week__r.Sunday_Max_Hours__c,
        Week__r.Week_Commencing__c, Week__r.Employee__c,Week__r.Shift_Pattern__r.Name, Week__r.Shift_Pattern__r.Wednesday_Start_Time__c,
        Week__r.Shift_Pattern__r.Wednesday_Max_Hours__c, Week__r.Shift_Pattern__r.Wednesday_End_Time__c, Week__r.Shift_Pattern__r.Tuesday_Start_Time__c,
        Week__r.Shift_Pattern__r.Tuesday_Max_Hours__c, Week__r.Shift_Pattern__r.Tuesday_End_Time__c, Week__r.Shift_Pattern__r.Thursday_Start_Time__c,
        Week__r.Shift_Pattern__r.Thursday_Max_Hours__c, Week__r.Shift_Pattern__r.Thursday_End_Time__c, Week__r.Shift_Pattern__r.Sunday_Start_Time__c,
        Week__r.Shift_Pattern__r.Sunday_Max_Hours__c, Week__r.Shift_Pattern__r.Sunday_End_Time__c, Week__r.Shift_Pattern__r.Saturday_Start_Time__c,
        Week__r.Shift_Pattern__r.Saturday_Max_Hours__c, Week__r.Shift_Pattern__r.Saturday_End_Time__c, Week__r.Shift_Pattern__r.Pool_Shift_Pattern__c,
        Week__r.Shift_Pattern__r.Monday_Start_Time__c, Week__r.Shift_Pattern__r.Monday_Max_Hours__c, Week__r.Shift_Pattern__r.Friday_Start_Time__c,
        Week__r.Shift_Pattern__r.Friday_Max_Hours__c, Week__r.Shift_Pattern__r.Friday_End_Time__c,Week__r.Shift_Pattern__r.Monday_End_Time__c,
        Week__r.Locking_User__c,Week__r.Locking_Category__c,Week__r.Release_Date__c,
        d.Job__r.Type__c, d.Job__r.Sub_Status__c, d.Job__r.Status__c, d.Job__r.Customer_Name__c, d.Job__c,d.Job__r.Installation_Address__c,     
        d.Job__r.Phone_Number__c,d.Job__r.Secondary_Job_Type_New__c, d.Job__r.Install_Postcode__c,Job__r.CHI_Lead__r.Latest_customer_category__c,Job__r.CHI_Lead__r.Product_Interest__c, Job__r.Is_Downtime_Job__c,Job__r.Is_Remedial_Job__c,
        d.Job__r.Green_Deal__c,d.Job__r.Job_Type__c, Job__r.Engineer_Working_NWD__c,d.Job__r.Quote__r.Job_Type__c,d.Job__r.Own_Labour__c,d.Job__r.Contractors__c,d.Job__r.Double_Handed_Job__c
        
            From Diary_Entry__c d
            
            // GB 2010-02-07 Use set of IDs instead!
            //where Employee_ID__c in :empid
            where d.Week__r.Employee__c in :empid
            and Start__c <= :endDT
            and End__c >= :startDT
            and hours__c > 0
            Order by employee_name__c, start__c] ) {
            
                for(Diary_Entry__c thisDiaryEntry : diaryEntries) {
                    system.debug('@@@@'+thisDiaryEntry);
                    //system.debug('@@@@'+thisDiaryEntry[0].Week__r.Employee__c);
                    system.debug('@@@@TheEMpID'+theEmpID); 
                    
                    // Changed second half of the logic from only15 != thisDiaryEntry.Employee_ID__c
                    if(thisEmployee == null || theEmpID != thisDiaryEntry.Week__r.Employee__c){//do this for a new employee
                        if(thisEmployee != null)
                            thisEmployee.addEntry(null, startDT, endDT,districtID);
                        //GB 2010-02-07 Changing call to findEmployee to use full ID
                        //thisEmployee = findEmployee(thisDiaryEntry.Employee_id__c);
                        thisEmployee = findEmployee(thisDiaryEntry.Week__r.Employee__c);
                        if(thisEmployee != null) {
                            //only15 = thisEmployee.employeeObject.Id;
                            //only15 = only15.substring(0,15);  
                            theEmpID= thisEmployee.employeeObject.Id;
                            if(thisDiaryEntry.Week__r.Locking_Category__c == 'Vulnerable')
                            {
                                thisEmployee.Category =1;
                                
                            }else if(thisDiaryEntry.Week__r.Locking_Category__c == 'Emergency Non-Op')
                            {
                                thisEmployee.Category =2;
                            }else if(thisDiaryEntry.Week__r.Locking_Category__c == 'Non-Op')
                            {
                                thisEmployee.Category =3;
                            }
                            if(thisDiaryEntry.Week__r.Release_Date__c!=null)
                            thisEmployee.WeekResrvedDate = 'Release Date:' +thisDiaryEntry.Week__r.Release_Date__c.format();
                            if(thisDiaryEntry.Week__r.Locking_User__c!=null)
                            {
                                thisEmployee.Locked = true;
                            }   
                        }
                        
                    }
                                       
                    
                    
//                  system.debug('getDiaryEntries emp:' + thisEmployee);
//                  system.debug('getDiaryEntries thisDiaryEntry:' + thisDiaryEntry);
//                  system.debug('GSadding entry for employee' + thisEmployee.employeeName);
                    
                    if(thisEmployee != null) {
                        //thisEmployee.addEntry(thisDiaryEntry, startDT, endDT); 
                        thisEmployee.addEntry(thisDiaryEntry, startDT, endDT,districtID);
                        //thisemployee.availabilityhours = thisDiaryEntry.week__r.availability_hours__c +'  /  '+thisDiaryEntry.week__r.Availability_Calc__c;
                        thisemployee.availabilityhours = thisDiaryEntry.week__r.Availability_Calc__c.format();
                    }
                    if(!shiftset)
                    {
                        if(thisDiaryEntry.Week__r.Shift_Pattern__r.Pool_Shift_Pattern__c)
                        {
                            
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_Max_Hours__c!= null)
                                thisemployee.mon =thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_Max_Hours__c.format() ;
                            else
                                thisemployee.mon ='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_Max_Hours__c!=null)
                                thisemployee.tue=thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_Max_Hours__c.format();
                            else
                                thisemployee.mon= '';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_Max_Hours__c!=null)
                                thisemployee.wed=thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_Max_Hours__c.format();
                            else
                                thisemployee.wed='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_Max_Hours__c!=null)
                                thisemployee.thu=thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_Max_Hours__c.format();
                            else
                                thisemployee.thu='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_Max_Hours__c!=null)
                                thisemployee.fri=thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_Max_Hours__c.format();
                            else
                                thisemployee.fri= '';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_Max_Hours__c!=null)
                                thisemployee.sat=thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_Max_Hours__c.format();
                            else
                                thisemployee.sat='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_Max_Hours__c!=null)
                                thisemployee.sun=thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_Max_Hours__c.format(); 
                            else
                                thisemployee.sun='';
                        }else if(!thisDiaryEntry.Week__r.Shift_Pattern__r.Pool_Shift_Pattern__c)
                        {
                            
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_End_Time__c!= null)
                                thisemployee.mon=thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Monday_End_Time__c;
                            else
                                thisemployee.mon ='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_End_Time__c!= null)
                                thisemployee.tue=thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Tuesday_End_Time__c;
                            else
                                thisemployee.tue='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_End_Time__c!= null)
                                thisemployee.wed=thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Wednesday_End_Time__c;
                            else
                                thisemployee.wed='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_End_Time__c!= null)
                                thisemployee.thu=thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Thursday_End_Time__c;
                            else
                                thisemployee.thu='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_End_Time__c!= null)
                                thisemployee.fri=thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Friday_End_Time__c;
                            else
                                thisemployee.fri='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_End_Time__c!= null)
                                thisemployee.sat=thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Saturday_End_Time__c;
                            else
                                thisemployee.sat='';
                            if(thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_Start_Time__c!= null || thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_End_Time__c!= null)
                                thisemployee.sun=thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_Start_Time__c + ' - '+thisDiaryEntry.Week__r.Shift_Pattern__r.Sunday_End_Time__c;
                            else
                                thisemployee.sun='';
                        }
                        
                    }
                }
              
            //    if(thisEmployee != null)//add an end entry for the last item in the list; Commented as part of PRB00021183
            //    thisEmployee.addEntry(null, startDT, endDT); //Commented as part of PRB00021183
            }
    }
    
    /* removed and replaced with version that takes full version of ID
    private Employee findEmployee(String empId) {
        Employee retEmp = null;
        String only15;
        
        for(Employee thisEmployee : getEmployees()){
          only15 = thisEmployee.employeeObject.Id;
          only15 = only15.substring(0,15);
          if(only15 == empId)retEmp=thisEmployee; 
        }
        
        return retEmp;
    }*/
    
    // GB 2010-02-07 - new version of above method to take full ID  
   @testvisible private Employee findEmployee(ID empId) {
        Employee retEmp = null;
        
        for(Employee thisEmployee : getEmployees()){
          if(thisEmployee.employeeObject.ID == empId)
            return thisEmployee; 
        }
        
        return null;
    }
    
    
    public class Employee {
        
        public string simpleSkills{get;set;} 
        
        private String employeeName = '';
        public String employeeType = '';
        public Employee__c employeeObject = null;
        public Week__c weekObject = null;
        public List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
        public List<GraphicDisplay> barChart = new List<GraphicDisplay>{};
        public NoAvailabilityLine thisnoAvLine = null;
        public List<NoAvailabilityLine> noAvLines = new List<NoAvailabilityLine>();
        // Non Productive chnage
        public List<NoAvailabilityLine> noPrdLines = new List<NoAvailabilityLine>();
        public NoAvailabilityLine thisnoPrdLine = null;
       
        public DateTime LastEndDate = null;
        public DateTime LastStartDate = null;
        public double segments = 0;
        public string debugsegment = '';
        public string availabilityhours;
        public Week__c thisWeek=null;
        private GraphicDisplay LatestBarChart = null;  
        private boolean isPoolEntryCreated = false;
        
        private DateTime startDiary = null;
        private DateTime endDiary = null;
   
        
        private DateTime weekStart;
        private DateTime dtWeekStart;
        //Added By Cognizant on 02032010 for displaying Role on Diary View
        private String str_Role;
        private String str_PostCode;
        //Code Ends Here
        public boolean locked{get;private set;}
        public string mon{get;set;}
        public string tue{get;set;}
        public string wed{get;set;}
        public string thu{get;set;}
        public string fri{get;set;}
        public string sat{get;set;}
        public string sun{get;set;}
        public integer category {get;set;}
        // ++ variable created for CR#897 start
        public string employeeHoverDetails {get; set;}
        public string alwaysWorksWithStyle {get; set;}
        public string WeekResrvedDate{get;set;}       
        // -- variable created for CR#897 end
        
        
        
        //--variables created to display employee skills
        //private string EmployeeSkills='';
        
        public List<Integer> getAllCols() {
            List<Integer> retIntList = new List<Integer>{};
            
            for(integer i=0; i < NoCols; i++){
                retIntList.add(i);
            }   
            return retIntList;
        }
        
        //Added By Cognizant on 02032010 for displaying Role on Diary View
        public String getStr_Role() {
            return str_Role;
        }
        public String getStr_PostCode(){
            return str_PostCode;
        }
        //Code Ends Here
       
        public Employee(String eName, String eType, Employee__c empObject, DateTime dtWeekStart,String emp_Role,String str_PostCode) {
            simpleSkills = system.label.optOutSkill;
            employeeHoverDetails = '';
            alwaysWorksWithStyle = '';
            WeekResrvedDate ='';
            employeeName = eName;
            employeeType = eType;
            employeeObject = empObject; 
            this.dtWeekStart = dtWeekStart;
            str_Role=emp_Role;
            
            
            //to display employee skills
            //EmployeeSkills = empObject.Employee_Skills__c;
            
            if (str_PostCode!=null) {/* Code change done by BGSAMS Support on 8-11-2011 as a part of PRB00005504 to display postcodes in the diary view if the length is less than 4 */
                if (str_PostCode.length()<5) { 
                    this.str_PostCode=str_PostCode; 
                } else{
                    this.str_PostCode=str_PostCode.subString(0,str_PostCode.length()-4);
                }
            } else {
                this.str_PostCode='';
            }
            // ++ variable created for CR#897 start
            employeeHoverDetails = employeeObject.Phone_No__c ; //'Phone No :'+employeeObject.Phone_No__c + '<br/>';
            if(employeeObject.Always_Works_With__r.Name != null)
            {
                employeeHoverDetails = employeeHoverDetails + 'Always Works With : ' + employeeObject.Always_Works_With__r.Name;
                alwaysWorksWithStyle = 'color:#2B21EB;';
            }
            // -- variable created for CR#897 end
            AddNewSkill add = new AddNewSkill();
            Map<String,String> skillCodeMap = add.setSkillMap();
            for(Optout_Skill__c o : empObject.Optout_Skills__r)
            {
                if(skillCodeMap.containsKey(o.Skill__c))
                this.simpleSkills = simpleSkills.replace(skillCodeMap.get(o.Skill__c), '');
            }
        }
        
        public Employee__c getemployeeObject() {
            return employeeObject;
        }
        
        public Week__c getthisWeek() {
           return thisWeek;
        }
        
        public List<NoAvailabilityLine> getNoAvailLines() {
            return(noAvLines);
        }
        
        public List<NoAvailabilityLine> getnoPrdLines() {
            return(noPrdLines);
        }
        public string getdebugsegment() {
            return debugsegment;
        }
        
        public double getSegments() {
            return segments;
        }
        
        public string getEmployeeName() {
            String retString=employeeName;
            
            if(employeeType == Away || employeeType == onLoan)retString = retString + ' ' + employeeType;
            
            return retString;
        }
        
        public string getEmployeeURL() {
            String empId = null;
            
            if(employeeObject != null)empId='/' + employeeObject.Id; 
            
            return empId;
        }
        
        public String getavailabilityhours() {
            //return DiaryDisplayWorker.formatDouble(availabilityhours,2);
             return availabilityhours;
        }
        
        public String getImageName(String avType){
            String retString = 'Available.gif';
            
            if(avType == 'Job Booking'){
                retString='JobBooking.gif';
            }
            else if(avType == 'Unavailability') {
                retString = 'Available.gif';
            }
            else if(avType == 'UnavailabilityB2') {
                retString = 'Unavailable.gif';
            }
            else if(avType == 'Start') {
                retString = 'NotWorking.gif';
            } 
            else if(avType == 'End'){
                retString = 'NotWorking.gif';
            }
            else if(avType == 'Non Productive')
            {
                retString = 'Non Productive.gif';
            }else if(avType == 'PriorityJobs')
            {
                retString = 'Priority.gif';
            }
                                
            return retString;
        }
        
        string lastEndDateTime = '';
        public void addBarAvailability(Double length, String avType, String URL, String jobCode, Double jobHours, Diary_Entry__c entry, DateTime startDate, DateTime endDate ) {
            GraphicDisplay bar = new GraphicDisplay();      
            
            if(entry!=null && (entry.record_Type__c == 'Unavailability' || entry.record_Type__c == 'Non Productive Job Booking' )) return;
            
            if(length > 0) {
                bar.bgcolour = getImageName(avType);
                bar.width  = String.valueOf(length * lengthperhour);
                bar.hours = length;     
                bar.jobcode = jobcode;
                // Add postcode on planner diary view
                if(entry != null && entry.Job__c != null && entry.Job__r.Install_Postcode__c != null){
                bar.installPostCode = entry.Job__r.Install_Postcode__c;
                }
                bar.avType = avType;
                bar.jobhours = jobhours;
                bar.URL =URL;
                bar.endDate = endDate;
                bar.startDate = startDate;
                //set the borders
                //bar.borderLeft = '1';
                //bar.borderRight = '1';
                
                if(avType=='Start' || avType=='End' && entry != null){
                    
                    lastEndDateTime = entry.End__c.format('dd-MM-yyyy HH:mm');
                    bar.avType='Availability';
                    bar.bgcolour = getImageName('Availability');
                }else if(entry != null){
                    bar.skill = entry.Sub_Type__c;
                    bar.information = 'Start: '+entry.Start__c.format('dd-MM-yyyy HH:mm');
                    bar.information += ' <br/>End: '+entry.End__c.format('dd-MM-yyyy HH:mm');
                    if(entry.Hours__c != null)
                        bar.information += ' <br/>Hours: '+((entry.Hours__c*100).round())/100.0;
                    bar.information += ' <br/>Type: '+entry.Type__c;
                    bar.information += ' <br/>Sub-Type: '+entry.Sub_Type__c;
                    lastEndDateTime = entry.End__c.format('dd-MM-yyyy HH:mm');
                    if(jobcode != null) bar.information += ' <br/>Lead Number: '+jobcode;
                    if(entry.Type__c == 'Job Booking' && entry.Job__r != null){
                        bar.information += ' <hr/>';
                        bar.information += 'Job: '+entry.Job__r.Name;
                        bar.information += ' <br/>Customer: '+entry.Job__r.Customer_Name__c;
                        bar.information += ' <br/>Status: '+entry.Job__r.Status__c;
                        bar.information += ' <br/>Sub-Status: '+entry.Job__r.Sub_Status__c;
                        bar.information += ' <br/>Address: '+entry.Job__r.Installation_Address__c;
                        bar.information += ' <br/>Phone Number: '+entry.Job__r.Phone_Number__c;
                        string Category = (entry.Job__r.CHI_Lead__r.Latest_customer_category__c == null || entry.Job__r.CHI_Lead__r.Latest_customer_category__c == 99)? '':Utilities.categoryMap.get(entry.Job__r.CHI_Lead__r.Latest_customer_category__c);
                        bar.information += ' <br/>Customer Category: '+Category;
                        bar.information += ' <br/>ASP Type: '+entry.Job__r.Secondary_Job_Type_New__c;
                        // change CR - 1344 starts -- By Ashok G
                        if(entry.Job__r.Own_Labour__c == true && entry.Job__r.Contractors__c == false){
                        bar.information += ' <br/>Own Labour ';
                        }
                        if(entry.Job__r.Double_Handed_Job__c == TRUE){
                        bar.information += ' <br/>Double Handed Job';
                        }
                        //change end
                        bar.subtype = entry.Sub_Type__c;
                        if (entry.Job__r.Engineer_Working_NWD__c == 'Yes')
                        {
                            bar.prdId = 'NWD';
                        }
                        /*
                        else if(entry.Job__r.Job_Type__c.contains('A W'))
                        bar.prdId = 'Affordable';
                        */
                        else if(entry.Job__r.Quote__r.Job_Type__c == '15')
                        bar.prdId = 'Straight Swap';
                        /*
                        else if(entry.Job__r.Green_Deal__c != 'No')
                        {
                            bar.prdId = 'GreenDeal';
                        }*/
                        else if(entry.Job__r.Is_Remedial_Job__c || entry.Job__r.Is_Downtime_Job__c)
                        {
                            bar.prdId = 'Green';
                        } 
                        else if(entry.Job__r.CHI_Lead__r.Non_Op__c)
                        {
                            bar.prdId = 'NONOP';
                        }
                        else
                        {
                            bar.prdId = entry.Job__r.CHI_Lead__r.Product_Interest__c;
                        }
                        /*
                        else if(entry.Product_Id__c == 'ECH')
                        {
                            bar.prdId = 'ECH';
                        }
                        */
                        bar.Priority = 99;
                        if(entry.Job__r.CHI_Lead__r.Latest_customer_category__c!=null)
                        bar.Priority = entry.Job__r.CHI_Lead__r.Latest_customer_category__c.intValue();
                    }
                }else{
                    
                    bar.avType='Availability';
                    bar.bgcolour = getImageName('Availability');
                }
                barChart.add(bar);
            
                LatestBarChart = bar;
            }
        }
        
        public void addBarNoAvailability(NoAvailabilityLine thisLine, Double length, String avType, String URL, String subType, double jobhours , Diary_Entry__c entry ) {
            system.debug(LoggingLevel.INFO,'Check------>'+thisLine+' '+length+' '+avType+' '+URL+' '+subtype+' '+jobhours+' '+entry); 
            GraphicDisplay bar;
            if(weekStart == null){
                weekStart = DateTime.newInstance(thisWeek.Week_Commencing__c, Time.newInstance(8,0,0,0));
//              System.Debug('week start: '+ weekStart+':'+thisWeek.Week_Commencing__c+' '+ thisWeek.Monday_Start_Time__c);
            }
            
            if(length > 0){
                
                //put in an entry to move start
                if((thisLine.barChart2.size() == 0 || thisLine.barChart3.size() ==  0)&& entry != null && entry.Start__c != weekStart){
//                  System.Debug('adding start entry');
                    double mylength = getDiaryHours(weekStart, entry.Start__c);
//                  System.Debug('adding start entry:' + mylength);
                    bar = new GraphicDisplay();
                    bar.bgcolour = getImageName('Unavailability');
                    bar.width  = String.valueOf(mylength * lengthperhour);
                    bar.hours= mylength;
                    bar.information = '';
                    bar.jobHours = mylength;
//                  System.Debug('adding start entry:' + bar);
                    if(entry.Record_Type__c == 'Unavailability')
                    thisLine.barChart2.add(bar);
                    else if(entry.Record_Type__c == 'Non Productive Job Booking')
                    thisLine.barChart3.add(bar);
//                    system.debug('When Adding --->'+thisLine.barChart2.size());
                }
                bar = new GraphicDisplay();
                
                bar.bgcolour = getImageName(avType);
                bar.width  = String.valueOf(length * lengthperhour);
                bar.hours= length;
                bar.subtype=subType;
                bar.jobhours = jobhours;
                bar.URL =URL;
                //bar.jobcode = jobcode;
               // if(jobcode != null) bar.information += ' <br/>Lead Number: '+jobcode;
                if(entry != null){
                    //if(jobcode != null) bar.information += ' <br/>Lead Number: '+jobcode;
                    bar.information = 'Start: '+entry.Start__c.format('dd-MM-yyyy HH:mm');
                    bar.information += ' <br/>End: '+entry.End__c.format('dd-MM-yyyy HH:mm');
                    if(entry.hours__c != null)
                        bar.information += ' <br/>Hours: '+((entry.Hours__c*100).round())/100.0;
                    bar.information += ' <br/>Type: '+entry.Type__c;
                    bar.information += ' <br/>Sub-Type: '+entry.Sub_Type__c;
                    bar.endDate = entry.End__c;
                    bar.startDate = entry.Start__c;
                    //string Category = (entry.Job__r.CHI_Lead__r.Latest_customer_category__c == null || entry.Job__r.CHI_Lead__r.Latest_customer_category__c == 99)? '':Utilities.categoryMap.get(entry.Job__r.CHI_Lead__r.Latest_customer_category__c);
                }
                //set the borders
                bar.borderLeft = '1';
                bar.borderRight = '1';
                //if(entry.Record_Type__c == 'Unavailability')
                thisLine.barChart2.add(bar);
                //else if(entry.Record_Type__c == 'Non Productive Job Booking')
                thisLine.barChart3.add(bar);
                system.debug('When Adding --->'+thisLine.barChart2.size());
            }

        }
        
                
        public void addEntry(Diary_Entry__c entry, DateTime StartDT, DateTime EndDT,Id districtID) {
          startDiary=StartDT;
          endDiary=EndDT;
          
        System.debug('addEntry: '+entry+','+startDiary+','+endDiary);
//        System.debug('LastEndDate: '+LastEndDate);
          
          
          if(entry == null) {
            //  this is the case where we need to tidy up the end of the charts
            //  first tidy the availability line
            If (LastEndDate !=null){
                Double endDiff = getDiaryHours(LastEndDate, endDiary);
                if(endDiff > 0){
                    segments = segments + endDiff;
//                  system.debug('Adding: '+endDiff+',End, null, null, null, '+entry);
                    addBarAvailability(endDiff, 'End', null, null, null, entry, StartDT, EndDT);                        
                } 
             }
             // now  lets tidy up the other lines
             // 
             if(thisnoAvLine == null){
                System.debug('GB: thisNoAvLine == null for ' + employeeName);
                thisnoAvLine = new NoAvailabilityLine();
                noAvLines.add(thisnoAvLine);
             }
             
             if(thisnoAvLine.barChart2.size() == 0 || thisnoAvLine.barChart3.size() == 0) {
                // no unavailablity then add all the shift patterns
                if(thisWeek != null ){
                    
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Monday_Start_Time__c,thisWeek.Monday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                  addDayDiaryEntry(thisnoAvLine,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }       
             }
             else {
                
               if(thisWeek != null) {
                // so we have an entry so we need to fill the rest so we need to go to the end of the day
                // and then we need to add the other days where required
                
                for(NoAvailabilityLine thisNoAv : noAvLines) {
                    
                    //rjd - 2010-01-24 - adding to try and stop null pointer exceptions.
                    if(thisNoAv.LastNoneAvailabilityEndDate == null) {
                        System.debug('GB: continued');
                        continue;
                    }
                //Double whichDay = thisNoAv.LastNoneAvailabilityEndDate.date().dayOfYear() - startDiary.date().dayOfYear();
                Double whichDay = startDiary.date().daysBetween(thisNoAv.LastNoneAvailabilityEndDate.date());
                if(whichDay == 0) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Monday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 1) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Tuesday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 2) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Wednesday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 3) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Thursday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 4) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Friday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 5) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Saturday_End_Time__c);
                    addDayDiaryEntry(thisNoAv,thisWeek.Sunday_Start_Time__c,thisWeek.Sunday_End_Time__c);
                }
                if(whichDay == 6) {
                    addToEndOfDayNW(thisNoAv,thisWeek.Sunday_End_Time__c);
                } 
               }
               }
                
             }
          } 
          else {
            //
            // now we are dealing with a diary entry
            diaryEntries.add(entry);
            thisWeek = entry.week__r;
            if(employeeObject.Pool_Diary__c){
                if(!isPoolEntryCreated){
                    isPoolEntryCreated=true;
                    addPoolDayEntry(entry.Week__r.Monday_Max_Hours__c, entry.Week__r.Monday_Unavailable_Hours__c,entry.Week__r.Monday_Booked_Hours__c,entry.week__c);
                    addPoolDayEntry(entry.Week__r.Tuesday_Max_Hours__c, entry.Week__r.Tuesday_Unavailable_Hours__c,entry.Week__r.Tuesday_Booked_Hours__c,entry.week__c);
                    addPoolDayEntry(entry.Week__r.Wednesday_Max_Hours__c, entry.Week__r.Wednesday_Unavailable_Hours__c,entry.Week__r.Wednesday_Booked_Hours__c,entry.week__c);
                    addPoolDayEntry(entry.Week__r.Thursday_Max_Hours__c, entry.Week__r.Thursday_Unavailable_Hours__c,entry.Week__r.Thursday_Booked_Hours__c,entry.week__c);
                    addPoolDayEntry(entry.Week__r.Friday_Max_Hours__c, entry.Week__r.Friday_Unavailable_Hours__c,entry.Week__r.Friday_Booked_Hours__c,entry.week__c);
                    addPoolDayEntry(entry.Week__r.Saturday_Max_Hours__c, entry.Week__r.Saturday_Unavailable_Hours__c,entry.Week__r.Saturday_Booked_Hours__c,entry.week__c);                 
                    addPoolDayEntry(entry.Week__r.Sunday_Max_Hours__c, entry.Week__r.Sunday_Unavailable_Hours__c,entry.Week__r.Sunday_Booked_Hours__c,entry.week__c);

                }
            }
            else {          
//          system.debug('GSCreate' + entry.employee_name__c);
        
                     
              if(LastEndDate == null){
                
                Double startDiff = getDiaryHours(StartDiary, entry.Start__c);
                if(startDiff > 0){
                    segments = segments + StartDiff;
                    Diary_Entry__c de = entry.clone(true);
                    de.Start__c = StartDiary;
                    de.End__c = entry.Start__c;
                    de.Hours__c = DateTimeHelper.subtractDate(de.End__c, de.Start__c);
                    if(de.Hours__c > 0 ){
                        addBarAvailability(startDiff, 'Start', null, null, null, de, StartDT, EndDT);
//                      system.debug('Adding: '+startDiff+',Start, null, null, null, '+de);
                    }
                }
              }
            
              
              //
              // so we my have overlapping times
              // this should only occur with job and none availability
              //
              DateTime useStart= null;
              /*
              system.debug('JB Check');
              if(LastEndDate != null && LastEndDate.getTime() > entry.start__c.getTime()){
                // so we have an overlap
                system.debug('JB We have an overlap');
                if(LastEndDate.getTime() > entry.start__c.getTime()) {
                    // this means that this is completely inside the last record
                    if(entry.Record_Type__c == 'Job Booking') {
                        
                        // reduce the size of the first as this is the job
                        
                        Double newdiff = getDiaryHours(LastStartDate, entry.start__c);
                        LatestBarChart.width = String.Valueof(newDiff*lengthperhour);
                        LatestBarChart.hours =  newDiff;
                    }
                    else {
                        useStart=LastEndDate;
                    }
                 }
              }
              */
                  
              // set for next time around this is a class variable
              LastEndDate = entry.end__c;
              LastStartDate = entry.start__c;
              if(useStart == null)useStart=entry.start__c;
              Double difference = getDiaryHours(useStart, entry.end__c);

              
              //addBarAvailability(difference, entry.Record_Type__c, '/' +  entry.id, entry.job__r.CHI_Lead__r.CHI_Lead_Id__c, entry.hours__c, entry, useStart, entry.end__c);
      		  string link  =  entry.Record_Type__c == 'Availability'  ? '/apex/DiaryEntryCreateUnavail?entryId='+entry.id+'&area='+districtID : '/' +  entry.id;
              
              addBarAvailability(difference, entry.Record_Type__c, link, entry.job__r.CHI_Lead__r.CHI_Lead_Id__c, entry.hours__c, entry, useStart, entry.end__c);          

              segments = segments + (difference);
              
              if(entry.Record_Type__c == 'Unavailability' ) {
                
                NoAvailabilityLine addToThis=null;
                for(NoAvailabilityLine thisNoAv : noAvLines){
                    // brm - 14-01-2010 - Time comparison now set to greater than or equal to - fixes bug with availabilities directly after one another
                  System.debug('GB: ' + entry.Start__c + ' and ' + thisNoAv.LastNoneAvailabilityEndDate);
                  System.debug('suppress: ' + DiaryDisplayController.suppressNPE);
                  if(DiaryDisplayController.suppressNPE == true && thisNoAv.LastNoneAvailabilityEndDate == null) {
                    // Do nothing
                  } else if( entry.Start__c.getTime() >= thisNoAv.LastNoneAvailabilityEndDate.getTime() && addToThis == null) {
                    addToThis=thisNoAv;
                  }
                }
              system.debug('------------------ addtothis: ' + addToThis);
                
                if(addToThis == null){
                    thisnoAvLine = new NoAvailabilityLine();
                   // thisnoPrdLine.isNonPrd = false;
                    noAvLines.add(thisnoAvLine);
                    //system.debug('------------------ addtothis1: ' + addToThis);
                    thisnoAvLine.LastNoneAvailabilityEndDate=entry.end__c;
                    if(thisWeek != null ){
                        //Double noDays = entry.Start__c.date().dayOfYear() - startDiary.date().dayOfYear(); 
                        Double noDays = startDiary.date().daysBetween(entry.Start__c.date()); 
//                        system.debug('noDays--->'+noDays);                 
                        if(noDays > 0)addDayDiaryEntry(thisnoAvLine,thisWeek.Monday_Start_Time__c,thisWeek.Monday_End_Time__c);
                        if(noDays > 1)addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                        if(noDays > 2)addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        if(noDays > 3)addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        if(noDays > 4)addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        if(noDays > 5)addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);                 
                    //
                    // we are in the day we need to add the entry
                    // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(thisnoAvLine,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(thisnoAvLine,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry); 
                    }
                }
                else {
                  //Double noDays = entry.Start__c.date().dayOfYear() - startDiary.date().dayOfYear();
                  //Double currentDay = addToThis.LastNoneAvailabilityEndDate.date().dayOfYear() - startDiary.date().dayOfYear();
                    Double noDays = startDiary.date().daysBetween(entry.Start__c.date());
                    Double currentDay = startDiary.date().daysBetween(addToThis.LastNoneAvailabilityEndDate.date());
                    
//                  system.debug('JBNAV:' + noDays);
//                  system.debug('JBNAV:' + currentDay);
                  if(noDays == 0){  // all hapens on monday
                    // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                     addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                     addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                  }
                  
                  if(noDays == 1){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 2){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 3){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 4){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                              
                  if(noDays == 5){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 3){
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Friday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                                                  
                  if(noDays == 6){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 3){
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 4){
                            addToEndOfDayNW(addToThis,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoAvLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Saturday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'UnavailabilityB2', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  addToThis.LastNoneAvailabilityEndDate=entry.end__c;
                } 
              }
              
              if(entry.Record_Type__c =='Non Productive Job Booking')
              {
                system.debug('*****************************');
                
                NoAvailabilityLine addToThis=null;
                for(NoAvailabilityLine thisNoAv : noPrdLines){
                    // brm - 14-01-2010 - Time comparison now set to greater than or equal to - fixes bug with availabilities directly after one another
                  System.debug('GB: ' + entry.Start__c + ' and ' + thisNoAv.LastNoneAvailabilityEndDate);
                  System.debug('suppress: ' + DiaryDisplayController.suppressNPE);
                  if(DiaryDisplayController.suppressNPE == true && thisNoAv.LastNoneAvailabilityEndDate == null) {
                    // Do nothing
                  } else if( entry.Start__c.getTime() >= thisNoAv.LastNoneAvailabilityEndDate.getTime() && addToThis == null) {
                    addToThis=thisNoAv;
                  }
                }
              system.debug('------------------ addtothis: ' + addToThis);
                
                if(addToThis == null){
                    thisnoPrdLine = new NoAvailabilityLine();
                    //thisnoPrdLine.isNonPrd = true;
                    noPrdLines.add(thisnoPrdLine);
                    thisnoPrdLine.LastNoneAvailabilityEndDate=entry.end__c;
                    if(thisWeek != null ){
                        //Double noDays = entry.Start__c.date().dayOfYear() - startDiary.date().dayOfYear();     
                        Double noDays = startDiary.date().daysBetween(entry.Start__c.date());     
                        system.debug('JBNAV NP:' + noDays);             
                        if(noDays > 0)addDayDiaryEntry(thisnoPrdLine,thisWeek.Monday_Start_Time__c,thisWeek.Monday_End_Time__c);
                        if(noDays > 1)addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                        if(noDays > 2)addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        if(noDays > 3)addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        if(noDays > 4)addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        if(noDays > 5)addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);                 
                    //
                    // we are in the day we need to add the entry
                    // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(thisnoPrdLine,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(thisnoPrdLine,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry); 
                    }
                }
              
                else {
                  //Double noDays = entry.Start__c.date().dayOfYear() - startDiary.date().dayOfYear();
                  //Double currentDay = addToThis.LastNoneAvailabilityEndDate.date().dayOfYear() - startDiary.date().dayOfYear();
                  Double noDays = startDiary.date().daysBetween(entry.Start__c.date());
                  Double currentDay = startDiary.date().daysBetween(addToThis.LastNoneAvailabilityEndDate.date());
                  
                  system.debug('JBNAV NP:' + noDays);
                  system.debug('JBNAV NP:' + currentDay);
                  if(noDays == 0){  // all hapens on monday
                    // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                     addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                     addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                  }
                  
                  if(noDays == 1){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 2){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 3){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                          addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                          addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  if(noDays == 4){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                              
                  if(noDays == 5){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else if(currentDay == 3){
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Friday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                                                  
                  if(noDays == 6){
                     if(noDays == currentDay) {  // the last noava and this av happen on Tuesday
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - addToThis.LastNoneAvailabilityEndDate.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                     else {
                        if(currentDay == 0){
                            addToEndOfDayNW(addToThis,thisWeek.Monday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Tuesday_Start_Time__c,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 1) {
                            addToEndOfDayNW(addToThis,thisWeek.Tuesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Wednesday_Start_Time__c,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 2){
                            addToEndOfDayNW(addToThis,thisWeek.Wednesday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Thursday_Start_Time__c,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 3){
                            addToEndOfDayNW(addToThis,thisWeek.Thursday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Friday_Start_Time__c,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else if(currentDay == 4){
                            addToEndOfDayNW(addToThis,thisWeek.Friday_End_Time__c);
                            addDayDiaryEntry(thisnoPrdLine,thisWeek.Saturday_Start_Time__c,thisWeek.Saturday_End_Time__c);
                        }
                        else {
                            addToEndOfDayNW(addToThis,thisWeek.Saturday_End_Time__c);
                        }
                        // brm - 14-01-2010 - Changed from End to Unavailability to get the correct colour and passed in a null diary entry so the tooltip isn't shown
                        addBarNoAvailability(addToThis,(entry.start__c.hour() - startDiary.hour()), 'Unavailability', null, null, null, null);
                        addBarNoAvailability(addToThis,getDiaryHours(entry.start__c, entry.end__c), 'Non Productive', '/' +  entry.id, entry.sub_type__c, entry.hours__c, entry);
                     }
                  }
                  
                  addToThis.LastNoneAvailabilityEndDate=entry.end__c;
                } 
              
              }
                
            }
          } 
        }
        
        public List<Diary_Entry__c> getdiaryEntries() {
           return(diaryEntries);        
        }
        
        public List<GraphicDisplay> getGraphicDisplay() {
        String currentJob = '';
        GraphicDisplay lastGD = null;
        //set the borders
        for(GraphicDisplay gd : barChart){
            //set both borders for the non-work items
            if(gd.bgcolour == 'Available.gif' || gd.bgcolour == 'NotWorking.gif' || gd.bgcolour == 'Unavailable.gif'){
                gd.borderLeft= gd.borderRight = '1';
            }else if(gd.bgcolour == 'JobBooking.gif'){
                
                //if we've found a new job...
                if(currentJob != gd.JobCode){
                    if(lastGD != null)
                        lastGD.borderRight = '1';
                        
                    gd.borderLeft = '1';
                }
                currentJob = gd.jobCode;
                
            }
            lastGD = gd;
        }
        //explicitly set the last items right border
        if(lastGD != null)
            lastGD.borderRight = '1';
        
        
        //look for any gaps in the start/end dates and fill as necessary
        List<GraphicDisplay> results = new List<GraphicDisplay>(); 
        GraphicDisplay prev = null;
        for(GraphicDisplay gd : barChart){
            if(prev == null){
                 
                if(dtWeekStart != gd.StartDate){
                    GraphicDisplay newGd = new GraphicDisplay();
                    newGd.startDate = dtWeekStart;
                    newGd.endDate = gd.StartDate;
                    newGd.bgcolour = 'Available.gif';
                    newGd.hours  = getDiaryHours(dtWeekStart,gd.StartDate);
                    results.add(newGd);
//                  System.debug('adding start gap: '+newGd);
                }
                
                
                prev = gd;
                results.add(gd);
//              System.debug(gd);
                continue;
            }
            if(prev.EndDate < gd.StartDate){
                GraphicDisplay newGd = new GraphicDisplay();
                newGd.startDate = prev.EndDate;
                newGd.endDate = gd.StartDate;
                newGd.bgcolour = 'Available.gif';
                newGd.hours  = getDiaryHours(newGd.StartDate,newGd.EndDate);
                results.add(newGd);
//              System.debug('adding gap: '+newGd);
            }
            prev = gd;
            results.add(gd);        
//          System.debug(gd);
        }
           return(results);     
        }
        
        public void addPoolDayEntry(Double MaxHours, Double UnavailableHours, Double BookedHours, String Id) {
            
            GraphicDisplay MomMbar = new GraphicDisplay();
                    
            Double AvailTime = 0;
            If(MaxHours == null)
                AvailTime=0;
            else If(UnavailableHours == null)
                AvailTime = MaxHours;
            else
                AvailTime = MaxHours - UnavailableHours;
                                
            MomMbar.bgcolour = 'Available.gif';
            MomMbar.avType = 'Pool';
            MomMBar.Text = String.valueof((BookedHours!=null ? BookedHours : 0.0)) +' / ' + string.valueof(AvailTime);
            MomMbar.Hours  = 10;
            MomMbar.URL = '/' + Id;
            //set the borders
            MomMbar.borderLeft = '1';
            MomMbar.borderRight = '1';
                  
            barChart.add(MomMbar);
        }


        public void addDayDiaryEntry(NoAvailabilityLine thisLine, string startTime, string endTime) {
 //              System.debug('no availability adding: '+thisLine+','+startTime+','+endTime);
                 String lstartTime = '08:00';
                 String lendTime = '08:00';
                 double startDiary = 8.0;
                 Time theStartTime = Time.newInstance(8,0,0,0);
                 double endDiary = 18.0;
                 Time theEndTime = Time.newInstance(18,0,0,0);
                 double hoursInDay = endDiary - startDiary;
                 
                 if(startTime != null)lstartTime = startTime;
                 if(endTime != null)lendTime = endTime;
            
            //rjd 17-12-2009
            //try these as doubles
                  double morn = DateTimeHelper.subtractTime(DateTimeHelper.stringToTime(lStartTime),theStartTime);
                  if(morn < 0)morn=0;
                  
                  double even = DateTimeHelper.subtractTime(theEndTime,DateTimeHelper.stringToTime(lEndTime));
                  if(even < 0)even = 0;
                  
                  double day = hoursInDay - morn - even;
//                System.debug('day, morn, even: '+day+','+morn+','+even);
                  if(morn > 0) {
                      GraphicDisplay MomMbar = new GraphicDisplay();
                      MomMbar.bgcolour = 'NotWorking.gif';
                      MomMbar.width  = String.valueOf((double)morn*lengthperhour);
                      MomMbar.Hours  = morn;
                     // if(!thisLine.isNonPrd)
                      thisLine.barChart2.add(MomMbar);
                      //else if(thisLine.isNonPrd)
                      thisLine.barChart3.add(MomMbar);
//                      system.debug('in morning');
                  }
                  
                  if(day > 0){
                      GraphicDisplay MomDbar = new GraphicDisplay();
                      MomDbar.bgcolour = 'Available.gif';
                      MomDbar.width  = String.valueOf((double)day*lengthperhour);
                      MomDbar.hours  = day;
                    //  if(!thisLine.isNonPrd)
                      thisLine.barChart2.add(MomDbar);
                     // else if(thisLine.isNonPrd)
                      thisLine.barChart3.add(MomDbar);
//                      system.debug('in day');
                  }
                  
                  if(even > 0){
                      GraphicDisplay MomEbar = new GraphicDisplay();
                      MomEbar.bgcolour = 'NotWorking.gif';
                      MomEbar.width  = String.valueOf((double)even*lengthperhour);
                      MomEbar.hours  = even;
                     // if(!thisLine.isNonPrd)
                      thisLine.barChart2.add(MomEbar);
                      //else if(thisLine.isNonPrd)
                      thisLine.barChart3.add(MomEbar);
//                      system.debug('in eve');
                  }
//          system.debug('size of graphics-->'+thisLine.barChart2.size());   
        }
        
        public void addToEndOfDayNW(NoAvailabilityLine thisLine, String endTime) {
                  
                  double endDiary = 18;
                  Time theEndTime = Time.newInstance(18,0,0,0);
                    
                  if(endTime != null) {
                      double toshftend = DateTimeHelper.subtractTime(DateTimeHelper.stringToTime(endTime),thisLine.LastNoneAvailabilityEndDate.Time());
                      if(toshftend < 0)toshftend=0;
                  
                      double even = DateTimeHelper.subtractTime(theEndTime, DateTimeHelper.stringToTime(endTime));
                      if(even < 0)even = 0;
                  
                      if(toshftend > 0){
                          GraphicDisplay aMomDbar = new GraphicDisplay();
                          aMomDbar.bgcolour = 'Available.gif';
                          aMomDbar.width  = String.valueOf((double)toshftend*lengthperhour); 
                          aMomDbar.hours  = toshftend;
//                System.debug('addNW1: '+aMomDbar);
                          //if(!thisLine.isNonPrd)
                          thisLine.barChart2.add(aMomDbar);
                         // else if(thisLine.isNonPrd)
                          thisLine.barChart3.add(aMomDbar);
                          system.debug('End In day');
                      }
                      
                      if(even > 0){
                          GraphicDisplay aMomEbar = new GraphicDisplay();
                          aMomEbar.bgcolour = 'NotWorking.gif';
                          aMomEbar.width  = String.valueOf((double)even*lengthperhour);                   
                          aMomEbar.hours  = even;
//                System.debug('addNW2: '+aMomEbar);
                         // if(!thisLine.isNonPrd)
                          thisLine.barChart2.add(aMomEbar);
                         // else if(thisLine.isNonPrd)
                          thisLine.barChart3.add(aMomEbar);
                          system.debug('End In eve');
                      }
                  }
//            system.debug('size of graphics-->'+thisLine.barChart2.size());
        }

        
        
        private double getDiaryHours(DateTime startTime, DateTime endTime) {
            Double retDiaryHours = 0;
            Double hoursInDiary = 10;
            
            
            
            if(startTime != null && endTime != null) {
                
                //System.Debug('startTime before ' + startTime);
                //if the start/end times are outside of what we need to consider then move to the correct place...
                //rjd - 2010-02-24
                if(startTime.time() < Time.newInstance(8,0,0,0))
                    startTime = DateTime.newInstance(startTime.date(), Time.newInstance(8,0,0,0));
                
                if(startTime.time() > Time.newInstance(18,0,0,0))
                    startTime = DateTime.newInstance(startTime.date().addDays(1), Time.newInstance(8,0,0,0));
                
                if(endTime.time() > Time.newInstance(18,0,0,0))
                    endTime = DateTime.newInstance(endTime.date(), Time.newInstance(18,0,0,0)); 
                
                if(endTime.time() < Time.newInstance(8,0,0,0))
                    endTime = DateTime.newInstance(endTime.date().addDays(-1), Time.newInstance(18,0,0,0)); 
                
                //System.Debug('startTime after ' + startTime);
                
                //Double noDays = endTime.date().dayOfYear() - startTime.date().dayOfYear();
                Double noDays = startTime.date().daysBetween(endTime.date());
                
                if(noDays == 0){
                    return DateTimeHelper.subtractDate(endTime, startTime);
                }
                
                //rjd - 17-12-2009 - changing to take into account half hours...
                Double nohours = (double) (endTime.hour() - startTime.hour()) + ((double)(endTime.minute() - startTime.minute())/60 );
                
//              System.debug('DiaryHours: '+startTime+','+endTime);
                
//              System.debug('No Hours: '+nohours);
                //Added by GS - If end time is greater than start time and hours = 0 we
                //need to set the hours to 1 so that it appears on the diary and isn't displayed
                //with a 0 length
                //If (nohours == 0){
                //  nohours=1;
                //}
                retDiaryHours = (noDays*hoursInDiary) + nohours;
            }
            
            
            return retDiaryHours;
        }
        
    }
    
    public class NoAvailabilityLine{
        public List<GraphicDisplay> barChart2 = new List<GraphicDisplay>{};
        public List<GraphicDisplay> barChart3 = new List<GraphicDisplay>{};
        public DateTime LastNoneAvailabilityEndDate = null;
       // boolean isNonPrd = false;
        public List<GraphicDisplay> getGraphicNoAvailabilityLines() {
           return(barChart2);       
        }
        
         public List<GraphicDisplay> getGraphicNonProdLines() {
           return(barChart3);       
        }
        
    }
   
  
    public class GraphicDisplay{
        public String colour;
        public String bgcolour;
        public String width;
        public String URL;
        public DateTime endDate;
        public DateTime startDate;
        public Double hours;
        public double StartCount;
        public double endCount;
        public String jobcode = '';
        // Add postcode on planner diary view
        public String installPostCode = '';
        public String subType;
        public String prdId;
        public Double jobhours;
        public String avType;
        public String Text;
        public String borderLeft = '0'; //width of the left border
        public String borderRight = '0'; //width of the right border
        public String information = '';
        public String skill = '';
        public integer Priority = 99;
        public boolean getShowInformation(){
            return information.length() > 0;
        }
        
        public String getcolour() {
            
            String retColour='White';
            if(bgColour == 'NotWorking.gif')retColour='gray';
            if(bgColour == 'JobBooking.gif')retColour='#00DCFF';
            if(bgColour == 'JobBooking.gif' && prdId=='Guided Sale')retColour='#53d80a;';
            // CH- 08/11/11 to display all the job bookings in violet color where we have got non_op flag
            if(bgColour == 'JobBooking.gif' && ((prdId!='Green' && Priority < 4)||prdId == 'NONOP'))retColour='Pink;';
            if(bgColour == 'JobBooking.gif' && prdId == 'ECH')retColour='blue;';
            //Green Deal Change
            //if(bgColour == 'JobBooking.gif' && prdId=='GreenDeal')retColour='#53d80a;';
            //Affordable Warmth change
            //if(bgColour == 'JobBooking.gif' && prdId=='Affordable')retColour='#8D38C9;';
            if(bgColour == 'JobBooking.gif' && prdId=='NWD')retColour='#CD96CD;';
            if(bgColour == 'JobBooking.gif' && subType == 'Travel Time')retColour='yellow;';
            if(bgColour == 'JobBooking.gif' && prdId=='Straight Swap')retColour='brown;';
            if(bgColour == 'Available.gif')retColour='white;';
            if(bgColour == 'Unavailable.gif' && subType != 'Survey Booking' )retColour='#F93F26;'; //modified by cognizant.
            if(bgColour == 'Unavailable.gif' && (subType == 'NWD - Working' || subType == 'NWD - Ring First Availability'))retColour='#663399';
            if(bgColour == 'Unavailable.gif' && subType == 'Survey Booking')retColour='#F9E04C;';  //added by cognizant for survey changes
            if(bgColour == 'Unavailable.gif' && subType == 'Service Upgrade Work')retColour='blue;';  //added by cognizant for survey changes
            if(bgColour == 'Unavailable.gif' && (subType=='Priority Labour Cat 1 - Vulnerable and Emergency Resource' || subType == 'Emergency Installation Resource'))retColour='Orange;';
            if(bgColour == 'Unavailable.gif' && (subType=='Contingency'))retColour='#66FFCC;';
            if(bgColour == 'Unavailable.gif' && subType == 'Survey Duties')retColour='#DC2BD0;';
            if(bgColour == 'Non Productive.gif' )retColour='yellow';//retColour='#FF3399;';
            return(retColour);
        }
        
        public String getbgcolour() {
            return(bgcolour);
        }
        public String getInformation() {
            return information;
        }
        
        public String getBorderLeft(){
            return borderLeft;
        }
        public String getBorderRight(){
            return borderRight;
        }
        public Long getLength() {
            Double retVal = hours*2;
            /*
            rjd - 17-12-2009 - this just looks wrong...
            if(hours > 0 && retVal < 1.0){
                system.debug('JBCOLSPAN:' + hours + ':retVal:' + retVal);
            
                retVal=1;
            }
            */
            return( retVal.round() );
        }

        
        public String getwidth() {
            return(width);
        }
        
        public String getURL() {
            return(URL);
        }   
        
        public String getJobCode() {
            return(jobcode);
        }
        // Add postcode on planner diary view
        public String getInstallPostCode() {
            return(installPostCode);
        }
         public String getSubType() {  //Added by cognizant for survey changes
            return(subType);                //Added by cognizant for survey changes
        }
        
        public String getoutputstring() {
            
            String retOutputstring = '';
            //don't add the job id if hours < 5
            If (jobhours <5){
                //if(bgColour == 'JobBooking.gif')retOutputstring = 'J'; //DiaryDisplayWorker.formatDouble(jobHours,2) ; // + '...';
                
                if(bgColour == 'Available.gif' && jobhours != null && avType != 'Unavailability')retOutputstring = 'A';//DiaryDisplayWorker.formatDouble(jobHours,2);
               //Next two lines is changed by Cognizant for Phase 4 enhancement
                if(bgColour == 'Unavailable.gif' && subType != 'Survey Booking' )retOutputstring = 'U'; // DiaryDisplayWorker.formatDouble(jobHours,2) + '...';
                if(bgColour == 'Unavailable.gif' && subType == 'Survey Booking' )retOutputstring = 'SU';
                if(bgColour == 'Unavailable.gif' && subType == 'Service Upgrade Work' )retOutputstring = 'SUW';
              //changes end here
                if(bgColour == 'Non Productive.gif')retOutputstring = 'TT';
                if(bgColour == 'NotWorking.gif')retOutputstring = '';
                
                if(avType == 'Pool')retOutputstring = Text;
            }else{
                //if(bgColour == 'JobBooking.gif')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2) + ' ' + jobcode;
                
                if(bgColour == 'Available.gif' && jobhours != null && avType != 'Unavailability')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2);
                if(bgColour == 'Unavailable.gif'&& subType != 'Survey Booking')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2) + ' ' + (subType!=null ? subType : '');
                if(bgColour == 'Unavailable.gif'&& subType == 'Survey Booking')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2) + ' ' + (subType!=null ? subType : '');
                if(bgColour == 'Unavailable.gif'&& subType == 'Survey Upgrade Work')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2) + ' ' + (subType!=null ? subType : ''); // Added by cognizant for survey changes
                if(bgColour == 'Non Productive.gif')retOutputstring = DiaryDisplayWorker.formatDouble(jobHours,2) + ' NPRW'; // Added by cognizant for survey changes
                if(bgColour == 'NotWorking.gif')retOutputstring = '';
                if(avType == 'Pool')retOutputstring = Text; 
            }
            
          if(bgColour == 'JobBooking.gif'){
            
                // Add postcode on planner diary view
                
                if(skill != null && skill.length() > 1){
                    
                    if(jobHours >= 6 && skill.equalsIgnoreCase('Mechanical')){
                        
                        return skill.substring(0,1) + ((installPostCode != null) ? '( '+installPostCode+')' : '');
                        
                    }else if(jobHours >= 2 && skill.equalsIgnoreCase('Mechanical')){
                        
                        if(installPostCode.trim().replaceAll(' ','').length() >= 7)
                            return skill.substring(0,1) + ((installPostCode != null) ? '( '+installPostCode.subString(0,4)+')' : '');
                        else if(installPostCode.trim().replaceAll(' ','').length() == 6)
                            return skill.substring(0,1) + ((installPostCode != null) ? '( '+installPostCode.subString(0,3)+')' : '');
                        else if(installPostCode.trim().replaceAll(' ','').length() <= 5)
                            return skill.substring(0,1) + ((installPostCode != null) ? '( '+installPostCode.subString(0,2)+')' : '');
                        
                    }else  if(skill.equalsIgnoreCase('Remote Heating'))
                    {
                        return ('RH');
                    }
                    else{
                        
                        return skill.substring(0,1);
                        
                    }
                    
                }else{
                    
                    return 'J';
                
                  } 
            
           }
            
            return (retOutputString );
            
        }
        
    }
}