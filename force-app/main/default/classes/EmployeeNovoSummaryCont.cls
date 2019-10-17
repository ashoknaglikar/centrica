public with sharing class EmployeeNovoSummaryCont {
    
    public list<NovoWrapper> novoWrapperList{get;set;}
    public List<EmailWrapper> emailWrapList{get;set;}
    public NovoWrapper SelectedNovoWrapper{get;set;}
    public NovoWrapper myselectedGoal{get;set;}
    public string selectListType{get;set;}
    public List<SelectOption> EmpNovoTypeList{get{
        EmpNovoTypeList= new List<SelectOption>();
        EmpNovoTypeList.add(new SelectOption('My People','My People'));
        EmpNovoTypeList.add(new SelectOption('My Goals','My Goals'));
        
        if(novoAdmin)
        EmpNovoTypeList.add(new SelectOption('Admin','Admin'));
        return EmpNovoTypeList;
        }
        set;
    }
    public string selectSuppType{get;set;}
    public List<SelectOption> suppTypeList{get; set;}
    public Employee_NOVO_Log__c pageObj {get; set;}
    
    public NOVO_Activities__c emailHeader1 {get;set;}
    
    public boolean novoAdmin {get;set;}
    public Set<string> suppList;
    public List<Employee_NOVO_Log__c> empList{get;set;}
    public boolean showLink{get;set;}
    
    public integer pageSize {get;set;}
    
    public integer OpenGoals{get;set;}
    public integer closedGoals{get;set;}
    Public Integer AllGoals{get;set;}
    public list<uList> usrWrapper{get;set;}
    public map<id,integer> UserOpenGoals{get;set;}
    public boolean empIndiGoals;
    id userID = userinfo.getuserId();
    
    string query = 'Select id,Status__c,Name,Employee__c,Employee__r.Salesforce_User__c,Employee__r.Supplier__r.Supplier_Num__c,employee__r.name,Reason__c,Related_Strategic_Priority__c,'+
                    'Job_CHI_Lead_Number__c,Goal_Target_Date__c,Goal_novo__c,Where_Are_U_Now__c,How_will_you_measure_prog__c,'+
                    'Note_on_Outcome__c,Manager__c,Number_of_Actions__c,CreatedDate,'+
                    '('+'select id,name,Action_activity__c,Owner__c,owner__r.name,Action_Completion_Date__c,Status__c from NOVO_Activities__r'+')'+
                    ' from Employee_NOVO_Log__c '+
                    'Where ';
                    
    
    string whereApproval = 'Employee__r.Salesforce_User__c = :userId';        
    
    string myPeople = 'Manager__c = :userId';
    
    string orderBy = ' ORDER BY CreatedDate DESC';          
    
    string offset= ' OFFSET :counter';
    
    string LimitString = ' LIMIT : pageSize'; 
    
    string status = ' AND Status__c =:goalStatus';
    string goalStatus='';
        
    string finalQuery ;
    string baseQuery;
    
    public string title{get;set;}
    public string HoldEmployeeUserId{get;set;}
    Utilities util  = new Utilities();
    string selectedGoal;
    public boolean edit{get;set;}
    public boolean gedit{get;set;}
    public string Title2{get;set;}
    public boolean signSucessRender{get;set;}
    public string email{get;set;}
    string mode = '';
   public EmployeeNovoSummaryCont(){
      emailHeader1 = new NOVO_Activities__c();
      pageObj  = new Employee_NOVO_Log__c();
      novoAdmin = false;
      emailWrapList=new List<EmailWrapper>();
      NOVO_Goal_Admins__c admin = NOVO_Goal_Admins__c.getInstance(userinfo.getuserId());
      if(admin !=null && admin.Active__c)
      {
          novoAdmin = true;
      }
      suppList=new set<string>();
      suppList.addAll(System.label.Supplier_not_to_show_on_novo_screen.split(','));
      system.debug('*suppList'+suppList);
      HoldEmployeeUserId = apexpages.currentpage().getparameters().get('sfUser');
      mode = apexpages.currentpage().getparameters().get('mode');
      system.debug(LoggingLevel.INFO,'@@@@'+HoldEmployeeUserId);
      selectedGoal = apexpages.currentpage().getparameters().get('goalId');
      edit = apexPages.currentPage().getParameters().get('e')=='1'?True:False;
      gedit = apexPages.currentPage().getParameters().get('e')=='1'?True:False;
      //edit = false;
      empIndiGoals = false;
      signSucessRender = false;
      selectListType = apexpages.currentPage().getParameters().get('view');
      usrWrapper = new list<uList>();
      suppTypeList = new List<SelectOption>();
        
      Schema.DescribeFieldResult fieldResult = Supplier__c.Resource_Type__c.getDescribe();
      List<Schema.PicklistEntry> plEntry = fieldResult.getPicklistValues();
      suppTypeList.add(new SelectOption('All','All'));  
      selectSuppType='All';
      for( Schema.PicklistEntry f : plEntry)
           {
              suppTypeList.add(new SelectOption(f.getLabel(), f.getValue()));
           }       
  
      boolean emailSuccess = ApexPages.currentPage().getParameters().get('sent')=='1'?True:False;
      if(emailSuccess){
        util.setErrorMsg(false ,'Email successfully sent.');
      }
      
      userId = userInfo.getUserId();
      if(pageObj.User__c !=null)
      {
          userID = pageObj.User__c;
          //empIndiGoals = true
      }
      
      
      if(HoldEmployeeUserId != null && holdEmployeeUserId!=''){
      userID = Id.valueof(HoldEmployeeUserId);
      empIndiGoals = True;
      }
      
     
      system.debug(LoggingLevel.INFO,''+holdEmployeeUserId+' '+selectListType+' '+edit);
      novoWrapperList = new list<NovoWrapper>();
      pagesize = Integer.valueof(system.label.displayListNovoGoals);
      counter = 0;
      AllGoals = 0;
      selectListType = 'My People';
      reRunQuery();
      if(edit)
      selectedGoalEdit();
      
      if(gedit)
      myGoalEdit();
      
     
      
      
      //finalQuery = baseQuery + orderBy + LimitString + offset;
      //reRunQuery();
      
   }
   
   public pagereference newNovoRec(){
     string uId = apexpages.currentpage().getparameters().get('sfUser')!=null?apexpages.currentpage().getparameters().get('sfUser'):userInfo.getUserId();
     employee__c e = [select id,salesforce_User__c from Employee__c where salesforce_user__c=:uId LIMIT 1];
     pagereference p = new pagereference('/apex/Smart_Novo?eId='+e.id);
     p.setRedirect(true);
     return p;
   }
   
   public void getReportees(){
      
     userId = userinfo.getuserid();  
     if(novoAdmin && selectListType == 'Admin')
     {
           
        userId = pageObj.user__c;
     }
     
     
     list<user> userList = [select id,name,ManagerId ,(select id,Supplier_Branch_Num__c,Supplier__r.name,Supplier__r.Resource_Type__c from Employees__r ) from user where ManagerId=:userId AND IsActive=:True];
     if(userList.size()==0){
       util.setErrorMsg(false , 'No users Reporting...');
     }else{
       set<id> uids = new set<id>();
       for(user u:userList){
         uids.add(u.id);
       }
       string whereApproval1 = 'Employee__r.Salesforce_User__c = :uids';
       string goalStatus1 = 'In Progress';
       string status = ' AND Status__c =:goalStatus1'; 
       string fQuery = query+whereApproval1+status;
       //List<Employee_NOVO_Log__c> novoList = database.query(fQuery);
       
       list<aggregateresult> aggreResult= database.query('Select COUNT(Employee__c) cont, Status__c, Employee__r.Salesforce_User__c from Employee_NOVO_Log__c where Employee__r.Salesforce_User__c in :uids  group By ROLLUP(Status__c,Employee__r.Salesforce_User__c)');
       UserOpenGoals = new map<id,integer>(); 
       map<id,integer> UserClosedGoals = new map<id,integer>();
       for(aggregateresult ag:aggreResult){
         if(string.valueof(ag.get('Status__c')) == 'In Progress')  
         {
             
              UserOpenGoals.put(string.valueof(ag.get('Salesforce_User__c')),integer.valueof(ag.get('cont')));
             
         }else 
         {
             UserClosedGoals.put(string.valueof(ag.get('Salesforce_User__c')),integer.valueof(ag.get('cont')));
         }
        
       }
       
       for(id ids:uids){
        if(!UserOpenGoals.containskey(ids))
        UserOpenGoals.put(ids,0);
       }
       usrWrapper = new list<uList>();
     
       for(user u2:UserList){
          ulist ul= new uList();
         if(u2.Employees__r.size()>0 ){
            if(!suppList.contains(u2.Employees__r[0].Supplier_Branch_Num__c)){
               if(u2.Employees__r[0].Supplier__r.Resource_Type__c== selectSuppType || selectSuppType=='All'){
                  ul.usr = u2;
                  ul.suppName=u2.Employees__r[0].Supplier__r.name;
                  if(UserOpenGoals.containskey(u2.id)){
                    ul.oGoals = UserOpenGoals.get(u2.id);
                  }else
                  ul.oGoals =0;
                  
                  if(UserClosedGoals.containskey(u2.id))
                  ul.cGoals = UserClosedGoals.get(u2.id);
                  else
                  ul.cGoals = 0;
                  
                  usrWrapper.add(ul);
              
               }
             
            }
          }
                   
       }
       
       if(usrWrapper.size()>1){
         for(integer i=0;i<usrWrapper.size();i++){
            
            for(integer j=i+1;j<usrWrapper.size();j++){
              if(usrWrapper[i].oGoals<usrWrapper[j].oGoals){
                ulist temp = usrWrapper[i];
                usrWrapper[i] = usrWrapper[j];
                usrWrapper[j] = temp;
              }
              
            }
           
         }
       }
       system.debug(LoggingLevel.INFO,'-=--==user List sort:'+usrWrapper);
       
     }
   }
   
    public void reRunQuery()
    {
        baseQuery = query +whereApproval;
        system.debug(LoggingLevel.INFO,'@@@@@@@@:'+selectListType+' '+userId+' '+HoldEmployeeUserId+' '+empIndiGoals);
          
         if(novoAdmin && selectListType == 'Admin')
         {
             showLink = false;
             if(pageObj.user__c == null && HoldEmployeeUserId == null)
             {
                 util.setErrorMsg(true,'Please enter a user to view NOVO goals');
                return;
             }
            userId = pageObj.user__c;
         }
        
        
        if(selectListType == 'My Goals' || selectListType == null)
        {
            title = 'My Goals';
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +orderBy+LimitString+offset;
            total_size = database.query(baseQuery).size();
            goalStatus = 'In Progress';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
            goalstatus = 'Closed';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            showLink = true;
            
            goalStatus = '';
            AllGoals = OpenGoals + closedGoals;
            
        }else if(selectListType != 'My Goals' && empIndiGoals)
        {   
            title = 'My People Goals';
            userId = Id.valueof(HoldEmployeeUserId);
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +orderBy+LimitString+offset;
            total_size = database.query(baseQuery).size();
            goalStatus = 'In Progress';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
            goalstatus = 'Closed';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            showLink = true;
            goalStatus = '';
            AllGoals = OpenGoals + closedGoals;
        }else if(selectListType != 'My Goals')
        {   
            empList = new list<Employee_NOVO_Log__c>();
            title = 'My People Goals';
            baseQuery = query +myPeople;
            finalQuery = baseQuery +orderBy+LimitString+offset;
            total_size = database.query(baseQuery).size();
            goalStatus = 'In Progress';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
            goalstatus = 'Closed';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            
            showLink = false;
            goalStatus = '';
            AllGoals = OpenGoals + closedGoals;
            getReportees();
        }
        
        system.debug('Final Query -->'+status);
        system.debug('pageSize -->'+pageSize);
        system.debug('counter -->'+counter);
        system.debug('useriD -->'+useriD);
        
        system.debug('Final Query -->'+finalQuery);
        List<Employee_NOVO_Log__c> novoList = database.query(finalQuery);
        
        novoWrapperList.clear();
        if(novoList.size()==0)
        {
            util.setErrorMsg(false , 'No records to display.');
        }else{
          set<id> eids = new set<id>();
          set<id> ActIds = new set<id>();
          for(Employee_NOVO_Log__c env: novoList){
              
              if(selectListType == 'My People' && !empIndiGoals){
                 system.debug(loggingLevel.INFO,'@@@@@@@@'+eids+' '+env.Employee__c);
                 if(!eids.contains(env.Employee__c)){
                 empList.add(env);
                 eids.add(env.Employee__c);
                 }
              }
              
              NovoWrapper nv = new NovoWrapper();
              nv.empNov = env;
              nv.ActionList = env.NOVO_Activities__r;
              
              list<NovoActions> AllActivities = new list<NovoActions>();
              for(NOVO_Activities__c nas: env.NOVO_Activities__r){
                 NovoActions na = new NovoActions();
                 na.novAct = nas;
                 Actids.add(nas.id);
                 AllActivities.add(na);
                  
              }
              nv.ActionList1 = AllActivities;
              novoWrapperList.add(nv);
          }
          List<Attachment> attQuery = [select id,body,parentId,name from Attachment where parentid=:Actids order by CreatedDate desc];
          Map<id,decimal> m= new Map<id,decimal>();
          for(Attachment a: attQuery){
            if(!m.containskey(a.parentId))
            m.put(a.parentId,1);
            else{
             decimal k=m.get(a.parentId)+1;
             m.put(a.parentId,k);  
            }
            
          }
          for(NovoWrapper nwra: novoWrapperList){
             for(novoActions nact: nwra.ActionList1){
               if(m.containskey(nact.novAct.id)){
               nact.attsize = m.get(nact.novAct.id);
               
               }
             }
          }
        }
        userId = userInfo.getuserId();
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-102:'+novoList);
      
    }
    
    public void save(){
       
       
       string status = '';
       if(SelectedNovoWrapper!=null){
          List<Employee_NOVO_Log__c> uEmpGoalList = new List<Employee_NOVO_Log__c>();
          List<NOVO_Activities__c> uNAlist = new List<NOVO_Activities__c>();
          //list<Attachment> atchList = new List<Attachment>();
          if(selectedNovoWrapper.ActionList1.size()>0 && selectedNovoWrapper.ActionList1!=null){
          for(NovoActions na: SelectedNovoWrapper.ActionList1)
                uNAlist.add(na.novAct);
          }
          
          
          
          
          
          if(uNAList.size()>0)
          update uNAList;
          
          if(SelectedNovoWrapper.empNov.id!=null)
          {
          update SelectedNovoWrapper.empNov;
           
         
           }

        Employee_NOVO_Log__c tempvar  = [Select Status__c, Goal_novo__c ,How_will_you_measure_prog__c,Where_Are_U_Now__c from Employee_NOVO_Log__c where Id = :SelectedNovoWrapper.empNov.id];
        status = SelectedNovoWrapper.empNov.Status__c = tempvar.Status__c;
        SelectedNovoWrapper.empNov.Goal_novo__c = tempvar.Goal_novo__c ;
        SelectedNovoWrapper.empNov.How_will_you_measure_prog__c = tempvar.How_will_you_measure_prog__c;
        SelectedNovoWrapper.empNov.Where_Are_U_Now__c = tempvar.Where_Are_U_Now__c;
        
        for(novoWrapper n: novoWrapperList){
          if(n.empnov.id == SelectedNovoWrapper.empNov.id){
            
            
             n.empNov.Status__c = SelectedNovoWrapper.empNov.Status__c;
             n.empNov.Goal_novo__c = SelectedNovoWrapper.empNov.Goal_novo__c;
             n.empNov.How_will_you_measure_prog__c = SelectedNovoWrapper.empNov.How_will_you_measure_prog__c;
             n.empNov.Where_Are_U_Now__c = SelectedNovoWrapper.empNov.Where_Are_U_Now__c;
            break;
          }
        }  
         
       }
       
       if(myselectedGoal!=null){
          try{
          List<NOVO_Activities__c> uNAlist = new List<NOVO_Activities__c>();
          if(myselectedGoal.ActionList1.size()>0 && myselectedGoal.ActionList1!=null){
          for(NovoActions na: myselectedGoal.ActionList1)
                uNAlist.add(na.novAct);
          }
          
          
         
          
          if(uNAList.size()>0)
          update uNAList;
          
          if(mySelectedGoal.empNov.id!=null)
          update myselectedGoal.empNov;
          
          
          Employee_NOVO_Log__c tempvar  = [Select  Status__c, Goal_novo__c,How_will_you_measure_prog__c,Where_Are_U_Now__c from Employee_NOVO_Log__c where Id = :myselectedGoal.empNov.id];
          status = myselectedGoal.empNov.Status__c = tempvar.Status__c;
          myselectedGoal.empNov.Goal_novo__c = tempvar.Goal_novo__c;
          myselectedGoal.empNov.How_will_you_measure_prog__c = tempvar.How_will_you_measure_prog__c;
          myselectedGoal.empNov.Where_Are_U_Now__c = tempvar.Where_Are_U_Now__c;
         }catch(Exception e){
          util.setErrorMsg(true, 'Error in saving record:'+e.getMessage()); 
          return;
         }
         for(novoWrapper n: novoWrapperList){
          if(n.empnov.id == myselectedGoal.empNov.id){
            
            
             n.empNov.Status__c = myselectedGoal.empNov.Status__c;
             n.empNov.Goal_novo__c = myselectedGoal.empNov.Goal_novo__c;
             n.empNov.How_will_you_measure_prog__c = myselectedGoal.empNov.How_will_you_measure_prog__c;
             n.empNov.Where_Are_U_Now__c = myselectedGoal.empNov.Where_Are_U_Now__c;
            break;
          }
        }
       }
       
       
        
        util.setErrorMsg(false , 'Record Successfully Saved.');
      
     //return null;   
    } 
    
    public void oGoals(){
       counter = 0;
       if(selectListType == 'My Goals')
        {
            title = 'My Goals';
            //counter = 0;
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalStatus = 'In Progress';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
           // goalStatus = '';
            
        }else if(selectListType == 'My People' && empIndiGoals)
        {
            title = 'My People Goals';
            userId = Id.valueof(HoldEmployeeUserId);
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalStatus = 'In Progress';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            //closedGoals = database.query(baseQuery+status).size();
            //goalStatus = '';
            showLink = true;
        }else if(selectListType == 'My People')
        {
            title = 'My People Goals';
            //counter = 0;
            baseQuery = query +myPeople;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalStatus = 'In Progress';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
            //goalStatus = '';
            showLink = true;
        }
        
        
        system.debug('Final Query -->'+finalQuery);
        List<Employee_NOVO_Log__c> novoList = database.query(finalQuery);
        system.debug(LoggingLevel.INFO,'-=-=-==-size>'+novoList.size());
        novoWrapperList.clear();
        if(novoList.size()==0)
        {
            util.setErrorMsg(false , 'No records to display.');
        }else{
          set<id> ActIds = new set<id>();
          for(Employee_NOVO_Log__c env: novoList){
              
              NovoWrapper nv = new NovoWrapper();
              nv.empNov = env;
              nv.ActionList = env.NOVO_Activities__r;
              
              list<NovoActions> AllActivities = new list<NovoActions>();
              for(NOVO_Activities__c nas: env.NOVO_Activities__r){
                 NovoActions na = new NovoActions();
                 na.novAct = nas;
                 Actids.add(nas.id);
                 AllActivities.add(na);
                  
              }
              nv.ActionList1 = AllActivities;
              novoWrapperList.add(nv);
          }
          List<Attachment> attQuery = [select id,body,parentId,name from Attachment where parentid=:Actids order by CreatedDate desc];
          Map<id,decimal> m= new Map<id,decimal>();
          for(Attachment a: attQuery){
            if(!m.containskey(a.parentId))
            m.put(a.parentId,1);
            else{
             decimal k=m.get(a.parentId)+1;
             m.put(a.parentId,k);  
            }
            
          }
          for(NovoWrapper nwra: novoWrapperList){
             for(novoActions nact: nwra.ActionList1){
               if(m.containskey(nact.novAct.id)){
               nact.attsize = m.get(nact.novAct.id);
               
               }
             }
          }
        }
        goalStatus = '';
        userId = userInfo.getUserId();
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-102:'+novoList);
    }
    
    public void cGoals(){
      system.debug(LoggingLevel.INFO,'-=-=-=CGOALS:'+selectListType);
      counter = 0;
      if(selectListType == 'My Goals')
        {
            title = 'My Goals';
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalstatus = 'Closed';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            //goalStatus = '';
            
        }else if(selectListType == 'My People' && empIndiGoals)
        {
            title = 'My People Goals';
            userId = Id.valueof(HoldEmployeeUserId);
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalStatus = 'Closed';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            //closedGoals = database.query(baseQuery+status).size();
            //goalStatus = '';
            showLink = true;
        }else if(selectListType == 'My People')
        {
            title = 'My People Goals';
            baseQuery = query +myPeople;
            finalQuery = baseQuery +status+orderBy+LimitString+offset;
            goalStatus = 'Closed';
            total_size = database.query(baseQuery+status).size();
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            //goalStatus = '';
            showLink = true;
        }
        
        
        system.debug(Logginglevel.iNFO,'Final Query -->'+finalQuery);
        List<Employee_NOVO_Log__c> novoList = database.query(finalQuery);
        
        novoWrapperList.clear();
        if(novoList.size()==0)
        {
            util.setErrorMsg(false , 'No records to display.');
        }else{
          set<id> ActIds = new set<id>();
          for(Employee_NOVO_Log__c env: novoList){
              
              NovoWrapper nv = new NovoWrapper();
              nv.empNov = env;
              nv.ActionList = env.NOVO_Activities__r;
              
              list<NovoActions> AllActivities = new list<NovoActions>();
              for(NOVO_Activities__c nas: env.NOVO_Activities__r){
                 NovoActions na = new NovoActions();
                 na.novAct = nas;
                 Actids.add(nas.id);
                 AllActivities.add(na);
                  
              }
              nv.ActionList1 = AllActivities;
              novoWrapperList.add(nv);
          }
          List<Attachment> attQuery = [select id,body,parentId,name from Attachment where parentid=:Actids order by CreatedDate desc];
          Map<id,decimal> m= new Map<id,decimal>();
          for(Attachment a: attQuery){
            if(!m.containskey(a.parentId))
            m.put(a.parentId,1);
            else{
             decimal k=m.get(a.parentId)+1;
             m.put(a.parentId,k);  
            }
            
          }
          for(NovoWrapper nwra: novoWrapperList){
             for(novoActions nact: nwra.ActionList1){
               if(m.containskey(nact.novAct.id)){
               nact.attsize = m.get(nact.novAct.id);
               
               }
             }
          }
        }
        goalStatus='';
        userId = userInfo.getUserId();
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-102:'+novoList);
    }
    
    public void ReporteeRecords(){
       HoldEmployeeUserId = apexpages.currentpage().getparameters().get('sfUser');
       if(HoldEmployeeUserId!=null)
       userId = Id.valueof(HoldEmployeeUserId);
       
       user u1=[select id,name from user where id=:userId];
       title2=u1.name+' Goals';
       if(selectListType == 'My People')
        {   
            empIndiGoals = True;
            title = 'My People Goals';
            baseQuery = query +whereApproval;
            finalQuery = baseQuery +orderBy+LimitString+offset;
            total_size = database.query(baseQuery).size();
            showLink = True;
            goalStatus = 'In Progress';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            OpenGoals = database.query(baseQuery+status).size();
            goalstatus = 'Closed';
            system.debug(LoggingLevel.INFO,'final Query:'+basequery+status);
            closedGoals = database.query(baseQuery+status).size();
            goalStatus = '';
            AllGoals = OpenGoals + closedGoals;
           
        }
        
        system.debug('Final Query -->'+status);
        system.debug('pageSize -->'+pageSize);
        system.debug('counter -->'+counter);
        system.debug('useriD -->'+useriD);
        
        system.debug('Final Query -->'+finalQuery);
        List<Employee_NOVO_Log__c> novoList = database.query(finalQuery);
        
        novoWrapperList.clear();
        if(novoList.size()==0)
        {
            util.setErrorMsg(false , 'No records to display.');
        }else{
          set<id> ActIds = new set<id>();
          for(Employee_NOVO_Log__c env: novoList){
              
              NovoWrapper nv = new NovoWrapper();
              nv.empNov = env;
              nv.ActionList = env.NOVO_Activities__r;
              
              list<NovoActions> AllActivities = new list<NovoActions>();
              for(NOVO_Activities__c nas: env.NOVO_Activities__r){
                 NovoActions na = new NovoActions();
                 na.novAct = nas;
                 Actids.add(nas.id);
                 AllActivities.add(na);
                  
              }
              nv.ActionList1 = AllActivities;
              novoWrapperList.add(nv);
          }
          List<Attachment> attQuery = [select id,body,parentId,name from Attachment where parentid=:Actids order by CreatedDate desc];
          Map<id,decimal> m= new Map<id,decimal>();
          for(Attachment a: attQuery){
            if(!m.containskey(a.parentId))
            m.put(a.parentId,1);
            else{
             decimal k=m.get(a.parentId)+1;
             m.put(a.parentId,k);  
            }
            
          }
          for(NovoWrapper nwra: novoWrapperList){
             for(novoActions nact: nwra.ActionList1){
               if(m.containskey(nact.novAct.id)){
               nact.attsize = m.get(nact.novAct.id);
               
               }
             }
          }
        }
      userID = userInfo.getUserId();
    }
    
    public void selectedGoalEdit(){
        
      string stemp = apexpages.currentpage().getparameters().get('novoIdNew');
      if(stemp!=null)
      selectedGoal = stemp;
      system.debug('----->'+selectedGoal);
      edit = false;
      selectedNovoWrapper = new NovoWrapper();
      if(selectedGoal != null){
        
        for(novoWrapper n: novoWrapperList){
          if(n.empnov.id == selectedGoal){
            edit = true;
            
            SelectedNovoWrapper = n;
            break;
          }
        }
        
      }
    }
    
    public void myGoalEdit(){
      selectedGoal = apexpages.currentpage().getparameters().get('goalId');
      gedit = false;
      myselectedGoal = new NovoWrapper();
      if(selectedGoal != null){
        
        for(novoWrapper n: novoWrapperList){
          if(n.empnov.id == selectedGoal){
            gedit = true;
            
            myselectedGoal= n;
            break;
          }
        }
        
      }
    }
    
    public void generatePdf(){
      signSucessRender = True;
      Set<id> empList= new set<id>();
      if(myselectedGoal!=null && myselectedGoal.empNov!=null &&  myselectedGoal.empNov.Id!=null){
      empList.add([select id,Salesforce_User__c from Employee__c where id=:  myselectedGoal.empNov.employee__c ].Salesforce_User__c);
       List<User> userList=new List<User>([select id,email,managerid,manager.email from User where id in :empList]);
      if(userList.size()>0){
      List<Employee__c> novoLog=new List<Employee__c>([select id,Salesforce_User__c from Employee__c where Salesforce_User__c=: userList[0].managerid]);
     
      for(User u : userList){
      emailWrapList.add(new EmailWrapper(true,new NOVO_Activities__c(owner__c=myselectedGoal.empNov.employee__c),string.valueOf(u.Email)));
      emailWrapList.add(new EmailWrapper(true,new NOVO_Activities__c(owner__c=novoLog[0].id),string.valueOf(u.manager.email)));
      emailWrapList.add(new EmailWrapper(false,new NOVO_Activities__c(),null));
      }
      }
          
      }
      else if(SelectedNovoWrapper!= null && SelectedNovoWrapper.empNov!=null &&  SelectedNovoWrapper.empNov.Id!=null){
        empList.add([select id,Salesforce_User__c from Employee__c where id=:  SelectedNovoWrapper.empNov.employee__c ].Salesforce_User__c);
         List<User> userList=new List<User>([select id,email,managerid,manager.email from User where id in :empList]);
      if(userList.size()>0){
      List<Employee__c> novoLog=new List<Employee__c>([select id,Salesforce_User__c from Employee__c where Salesforce_User__c=: userList[0].managerid]);
     
      for(User u : userList){
      emailWrapList.add(new EmailWrapper(true,new NOVO_Activities__c(owner__c=SelectedNovoWrapper.empNov.employee__c),string.valueOf(u.Email)));
      emailWrapList.add(new EmailWrapper(true,new NOVO_Activities__c(owner__c=novoLog[0].id),string.valueOf(u.manager.email)));
      emailWrapList.add(new EmailWrapper(false,new NOVO_Activities__c(),null));
      }
      }  
      }
     
       //return null;
    }
    
    public pageReference ProcessSelected(){
    boolean check=false;  
    pageReference p;
    for(EmailWrapper eWrap :emailWrapList){
        
         if(eWrap.checked){
          check=true;
          p=  AttachPdf(eWrap.emailWrap,eWrap.emailHead);
           
         }
        
        
    } 


    if(!check){
    
        util.setErrorMsg(true, 'Please select atleast one checkbox to send pdf.'); 
        return null;
    } 
    return p;   
      
  }
   public pageReference attachPdf(string email,NOVO_Activities__c emailHeader){
     string reqFrom = Apexpages.currentPage().getParameters().get('req');
     
     if((email== null && emailHeader.Owner__c == null) || (email== null && emailHeader==null )  )
     {
        util.setErrorMsg(true, 'Please enter atleast one; Email or Employee to send pdf.'); 
        return null;
          
     }
     
     if(emailHeader.Owner__c == null && (email== null || email== '' || !email.contains('@') || !(email.indexOf('@')<email.lastIndexOf('.')) 
                  || !(email.lastIndexOf('.')>email.indexOf('@')+2)) )
     {
        util.setErrorMsg(true, 'Invalid email Id.'); 
        return null;
     } 
     
     /*List<Employee__c> empEmail=new  List<Employee__c>();
     if(emailHeader.Owner__c != null )
     {
        // email = [Select Id, Salesforce_User__r.Email from Employee__c where Id = : emailHeader.Owner__c].Salesforce_User__r.Email;
         empEmail= [Select Id, Salesforce_User__r.Email from Employee__c where Id = : emailHeader.Owner__c];
                     
         if(empEmail.size()>0){            
            email= empEmail[0].Salesforce_User__r.Email;
                     
         }
     }*/
     
     
     pageReference p;
     string emailId ;
    
     system.debug('---->'+reqFrom);
    if(myselectedGoal!=null && myselectedGoal.empNov!=null &&  myselectedGoal.empNov.Id!=null) {
       p = new pageReference('/apex/Smart_Novo?headerId='+myselectedGoal.empNov.Id+'&signsuccess=2'+'&email='+email+'&view=My Goals&e=1&req=NG');
       emailId = myselectedGoal.empNov.Id;
     } else if(SelectedNovoWrapper!= null && SelectedNovoWrapper.empNov!=null &&  SelectedNovoWrapper.empNov.Id!=null){
       p = new pageReference('/apex/Smart_Novo?headerId='+SelectedNovoWrapper.empNov.id+'&signsuccess=2'+'&email='+email+'&view=My People&sfUser='+HoldEmployeeUserId+'&e=1&req=NP');
        emailId = SelectedNovoWrapper.empNov.Id;
     }
     
     p.setRedirect(true);
     
     Employee_NOVO_Log__c obj = new Employee_NOVO_Log__c(id =emailId , Last_Email_Sent__c = system.now());
     update obj;
     
     return p;
    }
    
    public class NovoWrapper{
       public Employee_NOVO_Log__c empNov{get;set;}
       public List<NOVO_Activities__c> ActionList{get;set;}
       public list<NovoActions> ActionList1{get;set;}
       public NovoWrapper(){
         this.empNov = new Employee_NOVO_Log__c();
         this.ActionList = new List<NOVO_Activities__c>();
         this.ActionList1 = new List<NovoActions>();
         
       }
    } 
   
   public class NovoActions{
     public NOVO_Activities__c novAct{get;set;}
     //public Attachment attachment {get;set;}
     public string filename{get;set;} 
     public decimal attSize{get;set;}
     public NovoActions(){
      this.novAct = new Novo_Activities__c();
      //this.attachment = new attachment();
      this.filename = '';
      this.attSize = 0;
     }
   } 
    
   public class uList{
     public user usr{get;set;}
     public decimal oGoals{get;set;}
     public decimal cGoals{get;set;}
     public string suppName{get;set;}
     
   }
   
   private integer counter=0;  //keeps track of the offset
   
   public integer total_size; //used to show user the total size of the list
   
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      reRunQuery();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      //save();
      reRunQuery();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += pageSize;
      //save();
      reRunQuery();
      return null;
   }
 
   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, pageSize);
      reRunQuery();
      return null;
   }
 
   public Boolean getDisablePrevious() {
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + pageSize < total_size) return false; else return true;
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
   public Integer getPageNumber() {
      return counter/pageSize + 1;
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, pageSize) > 0) {
         return total_size/pageSize + 1;
      } else {
         return (total_size/pageSize);
      }
   }
   
   public pagereference goBack()
   {
       pagereference p  = new pagereference('/apex/Novo_Logs_View?mode='+string.valueof(mode));
       p.setredirect(true);
       return p;
   }
   
   public void getPeople()
   {
        reRunQuery();
   }
    public class EmailWrapper {

    public Boolean checked{ get; set; }
    public NOVO_Activities__c emailHead{ get; set; }
    public string emailWrap{ get; set; }

    public EmailWrapper(boolean checked,NOVO_Activities__c emailHead,string emailWrap){
        this.checked=checked;
        this.emailHead=emailHead;
        this.emailWrap=emailWrap;
    }
  } 
}