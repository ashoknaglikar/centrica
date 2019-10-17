public with sharing class DiaryDisplayController {


 private transient DiaryDisplayWorker empData = null;
    public Job__c job {get;set;}
    //Added by GS 17/11/09
     //Date[] Weeks;
     String Weeks;
     district__c DHM = null;
     String area;
     Boolean showtable;
     
     
     public People_Hirearchy__c  ph {get;set;}
     public boolean peopleView {get;set;}
     
     // gjb 2010-02-11 Temporary fix to stop the null pointer exception happening on the Diary View page
     // This boolean can be used to determine whether the error should be supressed or not
     public static Boolean suppressNPE = false;
     public static Boolean npeMessage = false;
     public List<District__c> Districts {get;set;}
     //public Boolean districthidden{get; set;}
     //User currentUser {get; set;}
     
     
     public String mondayDate {get;set;}
     public String tuesdayDate {get;set;}
     public String wednesdayDate {get;set;}
     public String thursdayDate {get;set;}
     public String fridayDate {get;set;}
     public String saturdayDate {get;set;}
     public String sundayDate {get;set;}
     
     public list<SelectOption> peoples {get;set;}
     
     public string peopleName {get;set;}
     
     
     public List<SelectOption> getAreaItems() {
            List<SelectOption> options = new List<SelectOption>();
            
            if(Districts == null)loadDistricts();

            for (Integer i = 0; i < Districts.size(); i++)
            {                             
                options.add(new SelectOption(Districts[i].Id,Districts[i].Name));
            }                                               
            return options;
      }
     
     public Boolean getNpeMessage() {
        return npeMessage;
     }
      
     public String getWeeks() {
            return weeks;
     } 
     
     public String getAreaName(){
         return(area);
     } 
     
     public void setAreaName(String areaId) {
        area = areaId;
     }
     
     public void setWeeks(String weeks) {
            this.weeks = weeks;
     } 
    
     public String getArea() {
            return area;
     }
                   
     public void setArea(String area) {
            this.area = area;
     }
     
     public String getSendRange() {
            return 'Test';
     }
     public void setSendRange(String temp) {
//            system.debug('GSSendrange:' + weeks);
            
     }
   
     public district__c getDHM() {
            return DHM;
     }
     
     public void loadDistricts() {
        List<Employee__c> empList = new List<Employee__c>();
     
       empList = [select  Salesforce_User__r.Profile.Name,ID, District__c, District__r.Name, Pool_Diary__c, Works_Anywhere_In_District__c, Name,Role__c,Postcode__c,
                      Phone_No__c , Always_Works_With__r.Name,Employee_Skills__c from Employee__c where Salesforce_User__c=: Userinfo.getUserId()];  
       if(empList.size()>0 && Utilities.fetchprofilenames(system.label.Diary_View_Profile_Individual).contains(empList[0].Salesforce_User__r.Profile.Name))
      {
        Districts = new list<District__c>();
        Districts.add(new District__c(Id = empList[0].District__c,Name=empList[0].District__r.Name));
      }
      else
     {  
        Districts = [Select d.Name, d.Id,dhmname__c ,dhmphone__c, district_notes__c From District__c d where d.Type__c = 'Installation' order by d.Name]; 
     } 
        
     }
        
     public void setInitialDHM() {
        
        if(Districts == null)loadDistricts();
        
        for (district__c dis :Districts){
            if (dis.id == area){
                DHM = dis;
            }
        }
     }
     
     public Boolean getShow() {
            return showtable;
     }
     
     
    public List<SelectOption> getWeekItems() {
            List<SelectOption> options = new List<SelectOption>();
           
            //generate a list of weeks based on the current week.
            date today = date.today();
            Integer daycount = 365;
            date weekStart = today.toStartofWeek();
            //take off 4 weeks
            date displayWeek = weekStart.addDays(-56);
            displayWeek = displayWeek.toStartofWeek();
            daycount = daycount / 7;
            //Create testing element we have good data for
            // DateTime startDateTime = DateTime.newInstance(2009,11,23,8,0,0);
            // options.add(new SelectOption(startDateTime.format(),startDateTime.format()));
      
            for (Integer i = 0; i < 52; i++)
            {    
                displayWeek = displayWeek.addDays(7);                              
                options.add(new SelectOption(displayWeek.format(),displayWeek.format()));
            }
           
            displayWeek = weekStart;                                                           
            options.add(new SelectOption(weekStart.format(),weekStart.format()));                       
            
            //for (Integer i = 0; i < 52; i++)
            //{    
            //    displayWeek = displayWeek.addDays(7);                              
            //    options.add(new SelectOption(displayWeek.format(),displayWeek.format()));
            //}
           

            return options;
        }
        
    public PageReference refreshdiary () {

      try {
        
        if(ApexPages.currentPage().getParameters().get('stopNull') != null) {
            System.debug('stopNull is: ' + ApexPages.currentPage().getParameters().get('stopNull'));
            if(ApexPages.currentPage().getParameters().get('stopNull') == 'true') {
                System.debug('setting suppressNPE');
                suppressNPE = true;
            } else {
                suppressNPE = false;
            }
        }
      } catch(Exception exc) {
        System.debug('Exception');
      }
      
      weeks = job.Delivery_Date__c.toStartofWeek().format();
      //DateTime startDateTime = DateTime.newInstance(2009,11,23,0,0,0);
      /*
      DateTime startDateTime;
      DateTime endDateTime;
      Date tempDate;
      //Get day month year from date
      showtable = true;
      
      system.debug('$$ ' + weeks + ' $$ ' + integer.valueof(weeks.substring(0,2)));
      
      
      If(weeks == null){
        startDateTime = DateTime.now();
        endDateTime = datetime.newinstance(StartDateTime.year(),StartDateTime.month(),StartDateTime.day()+6,18,0,0);
     
      }
      else{
        //Construct datetime object from ints above
        Integer theday = integer.valueof(weeks.substring(0,2));
        Integer themonth = integer.valueof(weeks.substring(3,5));
        Integer theyear = integer.valueof(weeks.substring(6,10));
        startDateTime=datetime.newinstance(theyear,themonth,theday,8,0,0);
        endDateTime = datetime.newinstance(theyear,themonth,theday+6,18,0,0);  
      }
            
      empData = new DiaryDisplayWorker();      
      empData.getEmployeesForDiary(area, startDateTime, endDateTime);
      setInitialDHM();
      */
      String newURL='/apex/DiaryDisplay?week=' + weeks ;
      
      system.debug('I am here -->'+ph);
      if(peopleName != '' && peopleName!=null)
      {
          ph.Employee__c = peopleName;
      }else if(ph.manager__c != null)
      {
          
          ph = [Select name, Id, Employee__c from People_Hirearchy__c where id = :ph.manager__c ];
      }
      
      if(ph.Employee__c !=null)
      newURL += '&sfdc.tabName='+label.PeopleViewTab+'&ph='+ph.Employee__c; 
      else 
      newURL+= '&area=' + area ;
      
      if(suppressNPE) {
        newURL += '&stopNull=true';
      }
      PageReference retRef = new PageReference(newURL);
      ApexPages.currentPage().getParameters().put('week', weeks);
      ApexPages.currentPage().getParameters().put('area', area);
      if(ph.Employee__c !=null)
      {
      ApexPages.currentPage().getParameters().put('sfdc.tabName', label.PeopleViewTab);
      ApexPages.currentPage().getParameters().put('ph', ph.Employee__c);
      }
      if(suppressNPE) {
        ApexPages.currentPage().getParameters().put('stopNull', 'true');
      }
      
      retRef.setRedirect(true);
          
      return retRef;
    }
    
    public DiaryDisplayController() {
     
      system.debug('I am in Controller');
      ph = new People_Hirearchy__c();
      peopleView = ApexPages.currentPage().getParameters().get('sfdc.tabName') == label.PeopleViewTab ;
     // districthidden=true;
      //Set the wc default to this week
      job = new Job__c();
      job.Delivery_Date__c = system.today();
      weeks = ApexPages.currentPage().getParameters().get('week');
      area = ApexPages.currentPage().getParameters().get('area');
      ph.Employee__c = ApexPages.currentPage().getParameters().get('ph');
      peopleName = ph.Employee__c ;
      
      try {
        if(ApexPages.currentPage().getParameters().get('stopNull') != null) {
            System.debug('stopNull is: ' + ApexPages.currentPage().getParameters().get('stopNull'));
            if(ApexPages.currentPage().getParameters().get('stopNull') == 'true') {
                System.debug('setting suppressNPE');
                suppressNPE = true;
                //districthidden=false;
            } else {
                suppressNPE = false;
            }
        }
      } catch(Exception exc) {
        System.debug('Exception');
      }
      
      if(peopleView)
      {
          // peoples 
          peoples = new list<SelectOption>();
          peoples.add(new SelectOption('', '-- Select One --'));
          for(People_Hirearchy__c p : [Select name, Id, Employee__c from People_Hirearchy__c where Level__c<= '7' order by Name]  )
          {
              peoples.add(new SelectOption(p.Employee__c, p.Name));
          }
          
      }

      if(weeks == null){
        date today = date.today();
        date weekStart = today.toStartofWeek();
        weeks = weekStart.format();
      }
      
      if(weeks != null && ( area != null || ph.Employee__c !=null)){
        job.Delivery_Date__c = date.parse(weeks);
        showtable=true;
        empData = new DiaryDisplayWorker();      
        
        Integer theday = integer.valueof(weeks.substring(0,2));
        Integer themonth = integer.valueof(weeks.substring(3,5));
        Integer theyear = integer.valueof(weeks.substring(6,10));
        DateTime startDateTime=datetime.newinstance(theyear,themonth,theday,8,0,0); 
        DateTime endDateTime = datetime.newinstance(theyear,themonth,theday+6,18,0,0);
        
        Date weekStartDate = startDateTime.date();
        mondayDate = weekStartDate.format();
        tuesdayDate = weekStartDate.addDays(1).format();
        wednesdayDate = weekStartDate.addDays(2).format();
        thursdayDate = weekStartDate.addDays(3).format();
        fridayDate = weekStartDate.addDays(4).format();
        saturdayDate = weekStartDate.addDays(5).format();
        sundayDate = weekStartDate.addDays(6).format();
        
        try {
            System.debug('area'+area);
            System.debug('startDateTime'+startDateTime);
            System.debug('endDateTime'+endDateTime);
            empData.getEmployeesForDiary(area, startDateTime, endDateTime, ph );
            if(ph.Employee__c == null)
            setInitialDHM();
        } catch(Exception exc) {
            System.debug('Problem in diary view: ' + exc.getMessage());
            showtable = false;
            empData = null;
            npeMessage = true;
              
            
        }
      }
      else {    
       showtable =false;
    
        
      
      }
    }
    
    public DiaryDisplayWorker getEmpData() {
        return empData;
    }
    
    public pagereference openWeekReserver()
    {
        return (new pagereference('/apex/WeekReserver?area='+area+'&wkComm='+weeks));
    }



}