public class AvailabilityChangeReqController{
     public Diary_Change__c diaryChng{get;set;}
     public boolean isSelected{get;set;}
     public List<AppointmentWrap> avListWrap{get;set;}
     public List<AppointmentWrap> apListWrap{get;set;}
     public List<AppointmentWrap> unavListWrap{get;set;}
     public boolean delSals {get;set;}
     public boolean delUnav {get;set;}
     public boolean appointmentMOde{get;set;}
     public string FJStatus{get;set;}
     Public boolean inserAvail{get;set;}
    static list<Appointment__c> appointmentsToInsert = new list<Appointment__c>();
    list<Diary_Change_Request__c> weekDetails = new list<Diary_Change_Request__c>();      
    Integer ret=0;
    private MessageConstants errorMsg = new MessageConstants();
    String errMsg;
    Diary_Change_Request__c week1 = new Diary_Change_Request__c();
    Diary_Change_Request__c week2 = new Diary_Change_Request__c();
    Diary_Change_Request__c week3 = new Diary_Change_Request__c();
    Diary_Change_Request__c week4 = new Diary_Change_Request__c(); 
    
    
    Utilities util = new Utilities();
    
    private integer counter1=0;
    private integer counter2=0;
    private integer counter3=0;
    
    string LimitString = ' LIMIT : pageSize';
    public   integer pageSize{get;set;}  
    string Offset1= ' OFFSET :counter1';
    string Offset2= ' OFFSET :counter2';
    string Offset3= ' OFFSET :counter3';
    string orderby = ' ORDER BY Start__c';
    date  startDate;
    date  EndDate;
    
    Id rec1 ;
    Id rec2 ;
    ID rec3 ;
    
    string basicAppointment = 'Select id,Name,Opportunity__c,Opportunity__r.Name,Account_Address__c,Start__c,End__c,Assigned_To__c,Assigned_To__r.Name,Unavailability_Reason__c from Appointment__c where Assigned_To__c IN :empIdSet '+
                                               +'AND Start__c >= :startDate AND End__c <= :EndDate' ;
    string avaRecodtype = ' AND RecordTypeId =: rec1';
    
    string appRecodtype = ' And RecordTypeId =: rec2 and Status__c =\'Appointed\'';
    
    string UnRecodType   = ' And RecordTypeId =: rec3';                                                                                       
                                               
    public integer total_size1{get;set;}
    public integer total_size2{get;set;}
    public integer total_size3{get;set;}
    
    string finalQuery1 = basicAppointment + avaRecodtype + orderby +LimitString + Offset1;
    string finalQuery2 = basicAppointment + appRecodtype +orderby+ LimitString + Offset2;
    String finalQuery3 = basicAppointment + UnRecodType +orderby +LimitString + Offset3;
    // Availabilty 
    
      public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }
    String diaryChngID ;//= System.currentPageReference().getParameters().get('var_DCId');    
     public class AppointmentWrap{  
        public boolean isSelected{get;set;} 
        public Appointment__c appointment{get;set;}
        
        //wrapper class to bind checkbox and appointment object together
        public AppointmentWrap(boolean isSelected,Appointment__c appointment)
        {
           this.isSelected = isSelected;
           this.appointment = appointment;             
        }
     }
     
     public AvailabilityChangeReqController(){
        System.debug('==================='+diaryChngID);    
        try{
        diaryChngID = System.currentPageReference().getParameters().get('var_DCId');
        }catch(Exception e){}
        System.debug('==================='+diaryChngID);    
        pageSize = 50; 
        inserAvail = false;
        rec1 = [Select id,Name from RecordType where SObjectType = 'Appointment__c' AND Name='Available'].id;
        rec2 = [Select id,Name from RecordType where SObjectType = 'Appointment__c' AND Name='Appointment'].id;
        rec3 = [Select id,Name from RecordType where SObjectType = 'Appointment__c' AND Name='Unavailable'].id;
        if(diaryChngID!=null)
        getAppointments();                                       
                            
     } 
     
     
     
     public void onSelect(){
         isSelected = true;   
     }
     
     public PageReference onClickRefresh(){
        //getAppointments();
        PageReference page = new PageReference('/apex/AvailabilityChangeReqPage'+'?var_DCId='+diaryChng.id);
        return page;
     }
     
    public pagereference onClickBack(){
        return new pagereference('/'+diaryChng.id);
    }
    
    List<Appointment__c> avAppointments = new List<Appointment__c>();
    List<Appointment__c> apAppointments = new List<Appointment__c>();
    List<Appointment__c> unavAppointments = new List<Appointment__c>();
    Set<id> empIdSet = new Set<id>(); 
    Set<id> Inactive_empIdSet = new Set<id>();         
     public void getAppointments(){
        if(diaryChngID!=null)
        {
        
        diaryChng = [Select id,Request_Type__c,StartDT__c, EndDT__c, RecordTypeId,RecordType.Name,Employee__c,Employee__r.Is_Active_Salesforce_User__c,Employee_Group__c,Start__c,End__c,No_Of_Weeks__c,Week_1__c,Week_2__c,Week_3__c,Week_4__c,Employee__r.Name,Employee_Group__r.Name,Employee__r.Role__c,Unavailability_Reason__c, Unavailability_Notes__c,Subject__c, Shift_template__r.Week_1__c,  Shift_template__r.Week_2__c, Shift_template__r.Week_3__c, Shift_template__r.Week_4__c from Diary_Change__c where id = :diaryChngID];
       
       if(diaryChng.RecordType.Name.Contains('Unavailability') )
       {
            appointmentMOde = false;
       }else
       {
            appointmentMOde = true; 
       }        
        startDate = diaryChng.Start__c;
        EndDate = diaryChng.End__c.adddays(1);
        if(startDate == EndDate)
        {
            EndDate = startDate.adddays(1);
        }
        
         System.debug('====diaryChange==='+diaryChng);
         System.debug('====RecordIds==='+rec1+rec2+rec3);
        
         Employee__c emptemp = new Employee__c();
         //if change request is for employee group, adds all employees in one set else only one employee
         if(diaryChng.Employee_Group__c!=null){ 
             For(Employee_Group__c e : [Select Employee__c, Employee__r.Is_Active_Salesforce_User__c  from Employee_Group__c where Group__c =: diaryChng.Employee_Group__c]){
               //PRB00021719 fix to ignore inactive employees in the group
               if(e.Employee__r.Is_Active_Salesforce_User__c.equals('true'))
                empIdSet.add(e.Employee__c);
                else
                Inactive_empIdSet.add(e.Employee__c);
             }
         }         
         else if(diaryChng.Employee__c!=null){ 
            if(diaryChng.Employee__r.Is_Active_Salesforce_User__c.equals('true')) //PRB00021719 fix - to ignore inactive employee
                  empIdSet.add(diaryChng.Employee__c);
            else if (diaryChng.Employee__r.Is_Active_Salesforce_User__c.equals('false'))
                  Inactive_empIdSet.add(diaryChng.Employee__c);
         }
        System.debug('====EmpIdSet===='+empIdSet);
        //Querry appointment details for given record type and in the given time duration(i.e. start and end date) 
        total_size1 = [select count() from Appointment__c where Assigned_To__c IN :empIdSet AND Start__c >= :startDate AND End__c <= :EndDate AND RecordTypeId =: rec1];
        /*avAppointments = [Select id,Name,Opportunity__c,Opportunity__r.Name,Account_Address__c,Start__c,End__c,Assigned_To__c,Assigned_To__r.Name from Appointment__c 
                                                where Assigned_To__c IN :empIdSet
                                                AND( (Start__c >= :diaryChng.Start__c AND Start__c <= :diaryChng.End__c)
                                                OR (End__c >= :diaryChng.Start__c AND End__c <= :diaryChng.End__c) )                                              
                                                AND RecordTypeId =: rec1 limit 10];*/
                                                
                                              
                                                
        total_size2 = [select count() from Appointment__c where Assigned_To__c IN :empIdSet AND Start__c >= :startDate AND End__c <= :EndDate AND RecordTypeId =: rec2];                                        
        /*apAppointments = [Select id,Name,Opportunity__c,Opportunity__r.Name,Account_Address__c,Start__c,End__c,Assigned_To__c,Assigned_To__r.Name from Appointment__c 
                                                where Assigned_To__c IN :empIdSet
                                               AND( (Start__c >= :diaryChng.Start__c AND Start__c <= :diaryChng.End__c)
                                                OR (End__c >= :diaryChng.Start__c AND End__c <= :diaryChng.End__c) ) 
                                                AND RecordTypeId =: rec2 limit 10];*/
        
        
        //apAppointments = database.query(finalQuery2);
        
                       
        total_size3 = [select count() from Appointment__c where Assigned_To__c IN :empIdSet AND Start__c >= :startDate AND End__c <= :EndDate AND RecordTypeId =: rec3];                                        
        /*unavAppointments = [Select id,Name,Opportunity__c,Opportunity__r.Name,Account_Address__c,Start__c,End__c,Assigned_To__c,Assigned_To__r.Name from Appointment__c 
                                                where Assigned_To__c IN :empIdSet
                                              AND( (Start__c >= :diaryChng.Start__c AND Start__c <= :diaryChng.End__c)
                                                OR (End__c >= :diaryChng.Start__c AND End__c <= :diaryChng.End__c) ) 
                                                AND RecordTypeId =: rec3 limit 10];*/
                                                
        //unavAppointments = database.query(finalQuery3);
        
        System.debug('====available==='+avAppointments);
        System.debug('====Unavailable==='+unavAppointments );
        System.debug('====appointment==='+apAppointments );                                             
                                                
        //WrapLists has set get set property and we are adding appointment details to these lists
        avListWrap = new List<AppointmentWrap>();
        apListWrap = new List<AppointmentWrap>();
        unavListWrap = new List<AppointmentWrap>(); 
        
        runQuery1();
        runQuery2();
        runQuery3();
        
        System.debug('====avListWrap1==='+avListWrap);
        System.debug('====apListWrap1==='+apListWrap);
        System.debug('====unavListWrap1==='+unavListWrap); 
                
        if(empIdSet.isEmpty())
       {
       System.debug('====is this working?===');
       errMsg = errorMsg.ERR_InactiveEmp_inList;
       setErrorMsg();
       }
      }
     }
     
     public pagereference onClickAvailability(){
     
        if(!Inactive_empIdSet.isEmpty())
        {
        util.setErrorMsg(true, 'Diary change cannot be submitted since one or more employees are inactive. Please check the employees' +Inactive_empIdSet);
        return null;
        }
       
        else if(!empIdSet.isEmpty() && empIdSet.size() >= 1) //PRB00021719 fix
        {
              inserAvail = TRUE;
              DiaryChangeHelperMethods.inserAppointments(empIdSet, diaryChng.Id);
              AsyncApexJob Async1 = AsyncJob();
              if(Async1!=null){
              diaryChng.FutureJobId__c = Async1.Id;
              FJStatus = Async1.Status;
              }
           if(diaryChng.Request_Type__c == 'Appointment & Geography Change')
           diaryChng.Appointment_Complete__c = true;
           else
           diaryChng.Status__c = 'Completed';
           update  diaryChng; 
           
           util.setErrorMsg(false,system.label.DiaryChangeMessage);          
           return null;//new pagereference('/'+diaryChng.id);         
         } 
         else 
         {
            util.setErrorMsg(true, 'Diary change cannot be submitted since the Employee and Employee Group field is empty');
            return null;
         }    
         
     }      

      //Populates data for given number of weeks by cycling data of 4 weeks
     
     
     public void onClickDeleteAvailable(){
        list<Appointment__c> avAppointments = new list<Appointment__c>();
        if(!delSals)
        {
            for(AppointmentWrap wrapObj : avListwrap){
               if(wrapObj.isSelected==true)
               avAppointments.add(wrapObj.appointment);
            }
            if(avAppointments.size()>0)
            try{
                delete avAppointments;
                avListwrap = new list<AppointmentWrap>();
            }catch (exception e){}
                
            runQuery1();
                
        }    
        else
        {
            
            if(total_size1<2000)
            {
                avAppointments = database.query(basicAppointment+avaRecodtype);
                try{
                    delete avAppointments;
                    avListwrap = new list<AppointmentWrap>();
                }catch (exception e){}
                
            }else
            {
            if(!empIdSet.isEmpty())
            {
                DiaryChangeHelperMethods.massDeleteAppts(empIdSet,startDate,EndDate,rec1,diaryChng.Id);
            }
            else
            {
               System.debug('====is this working?===');
               errMsg = errorMsg.ERR_InactiveEmp_inList;
               setErrorMsg();
            }   
            }
            avListwrap = new list<AppointmentWrap>();
            total_size1 = 0;
            //util.setErrorMsg(false, 'Please refresh the Page, before applying.');
        }
        //return new pagereference('/apex/AvailabilityChangeReqPage?var_DCId=a'+diaryChng.id);
     }
     

    public pagereference onClickDeleteUnavailable(){
        list<Appointment__c> unavAppointments = new list<Appointment__c>();
        if(!delUnav)
        {
            for(AppointmentWrap wrapObj : unavListwrap){
               if(wrapObj.isSelected==true)
               unavAppointments.add(wrapObj.appointment);
            }
            
            if(unavAppointments.size()>0)
                delete unavAppointments;
                
            runQuery3();      
        }else
        {
            if(total_size3<2000)
            {
                unavAppointments= database.query(basicAppointment+UnRecodType);
                
                try{
                delete unavAppointments;
                }catch(Exception e){}
            }
            

                
            else
            {
            if(empIdset != null)
                DiaryChangeHelperMethods.massDeleteAppts(empIdSet,startDate,EndDate,rec3, diaryChng.Id);
            else
               {
               System.debug('====is this working?===');
               errMsg = errorMsg.ERR_InactiveEmp_inList;
               setErrorMsg();
               }                   
            }
            unavListwrap  = new list<AppointmentWrap>();
            total_size3 = 0;
        }   
        return new pagereference('/apex/AvailabilityChangeReqPage?var_DCId='+diaryChng.id);
    }  
    
    
    
    
    public pagereference onClickUnAvailability()
    {
    
       if(!Inactive_empIdSet.isEmpty())
        {
        util.setErrorMsg(true, 'Diary change cannot be submitted since one or more employees are inactive. Please check the employees' +Inactive_empIdSet);
        return null;
        }
        
        else if(!empIdSet.isEmpty() && empIdSet.size() >= 1) //PRB00021719 fix
        {
            //System.debug('====chitra==='+empIdSet);
            //System.debug('====chitra==='+empIdSet.size());
            DiaryChangeHelperMethods.insertUnavailabilties(diaryChng.Id,empIdSet,diaryChng.StartDT__c,diaryChng.EndDT__c, rec3, diaryChng.Unavailability_Reason__c, diaryChng.Unavailability_Notes__c,diaryChng.Subject__c );
            AsyncApexJob Async1 = AsyncJob();
            if(Async1 != null){
            diaryChng.FutureJobId__c = Async1.Id;
            FJStatus = Async1.Status;
            }
            diaryChng.Status__c = 'Completed';
        
            update diaryChng;
            
            util.setErrorMsg(false,system.label.DiaryChangeMessage);
            return null;   //new pagereference('/'+diaryChng.Id);
        }
        else 
         {
            util.setErrorMsg(true, 'Diary change cannot be submitted since the Employee and Employee Group field is empty');
            return null;
         } 
    
        }
    
  /*
        Available Appointment Pagination.
  
  */
    
   //used to show user the total size of the list
   
   public PageReference Previous1() { //user clicked previous button
      counter1 -= pageSize;
      runQuery1();
      return null;
   }
 
   public PageReference Next1() { //user clicked next button
      counter1 += pageSize;
      runQuery1();
      return null;
   }
 
   
 
   public Boolean getDisablePrevious1() {
      //this will disable the previous and beginning buttons
      if (counter1>0) return false; else return true;
   }
 
   public Boolean getDisableNext1() { //this will disable the next and end buttons
      if (counter1 + pageSize < total_size1) return false; else return true;
   }
 
   
 
   public Integer getPageNumber1() {
      return counter1/pageSize + 1;
   }
 
   public Integer getTotalPages1() {
      if (math.mod(total_size1, pageSize) > 0) {
         return total_size1/pageSize + 1;
      } else {
         return (total_size1/pageSize);
      }
   }
   
   private void runQuery1()
   {
        avListWrap = new list<AppointmentWrap>();
        avAppointments = database.query(finalQuery1);
        if(!avAppointments.isEmpty())
        for(Appointment__c objAv : avAppointments ){
            if(checkIfNeeds(objAv))
            {
                AppointmentWrap wrapObj = new AppointmentWrap(false,objAv);
                avListWrap.add(wrapObj);  
            }          
        }
        system.debug('--->'+avListWrap);
   }
    ///////////////////////////////////////////////////////////////////////////////////
    //                                                                              //
    //          Appointment Pagination                                              //
    //////////////////////////////////////////////////////////////////////////////////
    
    /*
        Available Appointment Pagination.
  
  */
    
   //used to show user the total size of the list
   
   public PageReference Previous2() { //user clicked previous button
      counter2 -= pageSize;
      runQuery2();
      return null;
   }
 
   public PageReference Next2() { //user clicked next button
      counter2 += pageSize;
      runQuery2();
      return null;
   }
 
   
 
   public Boolean getDisablePrevious2() {
      //this will disable the previous and beginning buttons
      if (counter2>0) return false; else return true;
   }
 
   public Boolean getDisableNext2() { //this will disable the next and end buttons
      if (counter2 + pageSize < total_size2) return false; else return true;
   }
 
   
 
   public Integer getPageNumber2() {
      return counter2/pageSize + 1;
   }
 
   public Integer getTotalPages2() {
      if (math.mod(total_size1, pageSize) > 0) {
         return total_size2/pageSize + 1;
      } else {
         return (total_size2/pageSize);
      }
   }
   
   private void runQuery2()
   {
        apListWrap = new list<AppointmentWrap>();
        apAppointments = database.Query(finalQuery2);
        if(!apAppointments.isEmpty())
        for(Appointment__c objAp : apAppointments ){
            if(checkIfNeeds(objAp))
            {
                AppointmentWrap wrapObj = new AppointmentWrap(false,objAp);
                apListWrap.add(wrapObj);           
            } 
        } 
         System.debug('====avListWrap==='+avListWrap); 
   }
   
   
   ///////////////////////////////////////////////////////////////////////////////////
    //                                                                              //
    //          Unavailble Pagination                                               //
    //////////////////////////////////////////////////////////////////////////////////
    
    
   //used to show user the total size of the list
   
   public PageReference Previous3() { //user clicked previous button
      counter3 -= pageSize;
      runQuery3();
      return null;
   }
 
   public PageReference Next3() { //user clicked next button
      counter3 += pageSize;
      runQuery3();
      return null;
   }
 
   
 
   public Boolean getDisablePrevious3() {
      //this will disable the previous and beginning buttons
      if (counter3>0) return false; else return true;
   }
 
   public Boolean getDisableNext3() { //this will disable the next and end buttons
      if (counter3 + pageSize < total_size3) return false; else return true;
   }
 
   
 
   public Integer getPageNumber3() {
      return counter3/pageSize + 1;
   }
 
   public Integer getTotalPages3() {
      if (math.mod(total_size1, pageSize) > 0) {
         return total_size3/pageSize + 1;
      } else {
         return (total_size3/pageSize);
      }
   }
   
   private void runQuery3()
   {
        unavListWrap = new list<AppointmentWrap>();
        unavAppointments= database.query(finalQuery3);
        if(!unavAppointments.isEmpty())
        for(Appointment__c objUnav : unavAppointments ){
            if(checkIfNeeds(objUnav))
            {
                AppointmentWrap wrapObj = new AppointmentWrap(false,objUnav);
                unavListWrap.add(wrapObj);   
            }         
        }
   }
   
   
   
   public boolean checkIfNeeds(Appointment__c app )
   {
        system.debug('Record Type'+diaryChng.RecordType.Name);
        if(diaryChng.RecordType.Name!=null && diaryChng.RecordType.Name.contains( 'Unavailability') )
        return true;
        
        date stDatWk = app.Start__c.Date().toStartOfWeek();
        boolean include = false;
        integer daysBetween = diaryChng.Start__c.toStartOfWeek().daysbetween(stDatWk);
        integer weekIdentifier = math.mod(daysBetween,28);
        
        if(diaryChng.Shift_template__r.Week_1__c && diaryChng.Shift_template__r.Week_2__c && diaryChng.Shift_template__r.Week_3__c && diaryChng.Shift_template__r.Week_4__c)
        {
            return true;
        }
        
        if(weekIdentifier==0 && diaryChng.Shift_template__r.Week_1__c)
        {
             include = true;
        }else if(weekIdentifier ==7 && diaryChng.Shift_template__r.Week_2__c)
        {
            include = true;
        }   
        else if(weekIdentifier ==14 && diaryChng.Shift_template__r.Week_3__c)
        {
            include = true;
        } 
        else if(weekIdentifier== 21 && diaryChng.Shift_template__r.Week_4__c)
        {
            include = true;
        }
        
        return   include; 
   }
   
   public AsyncApexJob AsyncJob(){
      List<AsyncApexJob> futureCalls = [Select Id, CreatedById, CreatedBy.Name, ApexClassId,ApexClass.Name,MethodName,Status from AsyncApexJob where JobType = 'future' AND ApexClass.Name='DiaryChangeHelperMethods' AND CreatedById=:userInfo.getUserID() order by CreatedDate DESC LIMIT 1];
      if(futureCalls.size()>0)
      return futureCalls[0];
            
     return null;
   }
   
   
   
   public pageReference futureJobStatus(){
      AsyncApexJob futureCalls = [Select Id, CreatedById, CreatedBy.Name, ApexClassId,ApexClass.Name,MethodName,Status from AsyncApexJob where id=:diaryChng.futureJobId__c];
      if(futureCalls!=null){
        FJStatus = futureCalls.Status;
        
      }
      if(FJStatus == 'Completed'){
       inserAvail = False;
       return new pagereference('/'+diaryChng.id); 
      }
     return null;
   }
      
}