@isTest
public class EmployeeNovoSummaryCont_Test
{

public static testMethod void testEmployeeNovo()
  {
  Test.startTest();
  
  EmployeeNovoSummaryCont empNoVoCount=new EmployeeNovoSummaryCont();
  empNoVoCount.novoAdmin=true;
  
  empNoVoCount.EmpNovoTypeList= new List<SelectOption>();
  empNoVoCount.EmpNovoTypeList.add(new SelectOption('My People','My People'));
  empNoVoCount.EmpNovoTypeList.add(new SelectOption('My Goals','My Goals'));
  
  Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
  User u = new User(Alias = 'standt', Email='sysAdmin@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='sys1212Admin@testorg.com');
      insert u;
  Employee__c emp=new Employee__c(name='Test Employee',salesforce_user__c=u.id,Employee_Number__c='1237656');
  insert emp; 
  Employee_NOVO_Log__c  novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_Novo__c ='TestGoal1');
  insert novoLog;
  NOVO_Activities__c novoAct=new NOVO_Activities__c(Action_activity__c  ='Test NovoAction 1',Owner__c=emp.id,Action_Completion_Date__c=Date.Today(),Status__c='In Progress',Employee_NOVO_Log__c=novoLog.id);
  insert novoAct;
      
  empNoVoCount.HoldEmployeeUserId=string.valueOf(u.id);
  system.assertEquals(true,  empNoVoCount.novoAdmin);
  empNoVoCount.UserOpenGoals=new map<id,integer>();
  empNoVoCount.getReportees();
  empNoVoCount.selectListType='My Goals';
   system.assertEquals('My Goals',  empNoVoCount.selectListType);
  empNoVoCount.reRunQuery();
 
  empNoVoCount.oGoals();
  empNoVoCount.cGoals();
  empNoVoCount.getPeople();
  empNoVoCount.ReporteeRecords();
 
  empNoVoCount.generatePdf();
   
  empNoVoCount.empIndiGoals=false;
  empNoVoCount.oGoals();
  empNoVoCount.cGoals();
  
   EmployeeNovoSummaryCont.NovoActions novoacts=new EmployeeNovoSummaryCont.NovoActions();
   novoacts.novAct=novoAct;
   
   EmployeeNovoSummaryCont.NovoWrapper novoWrap=new EmployeeNovoSummaryCont.NovoWrapper();
   novoWrap.empnov=novoLog;
   novoWrap.ActionList1.add(novoacts);
   
   EmployeeNovoSummaryCont.uList uList=new EmployeeNovoSummaryCont.uList();
   uList.usr=new User();
   uList.oGoals=12.22;
   uList.cGoals=12.00;
   
   PageReference pageRef = Page.Novo_Logs_View;
   Test.setCurrentPage(pageRef);
   Id userId=UserInfo.getUserId();
 
    pageRef.getParameters().put('sfUser',string.valueOf(u.id));
    pageRef.getParameters().put('novoIdNew',string.valueOf(novoLog.id));
    pageRef.getParameters().put('goalId',string.valueOf(novoLog.id));
    pageRef.getParameters().put('req','NG');
    pageRef.getParameters().put('view','Admin');
    
    empNoVoCount.novoWrapperList.add(novoWrap);
    empNoVoCount.SelectedNovoWrapper=novoWrap;
    empNoVoCount.myselectedGoal=novoWrap;
    empNoVoCount.save();
    empNoVoCount.selectedGoalEdit();
    empNoVoCount.myGoalEdit();
    empNoVoCount.newNovoRec();
  //  empNoVoCount.attachPdf(SelectedNovoWrapper);
    Boolean disPre=  empNoVoCount.getDisablePrevious();
    Boolean disNxt=empNoVoCount.getDisableNext();
    Integer total=  empNoVoCount.getTotal_size();
    Integer pgNumber=  empNoVoCount.getPageNumber();
    Integer totalPgs=  empNoVoCount.getTotalPages();
    empNoVoCount.goBack();
    empNoVoCount.selectListType='My People';
    empNoVoCount.oGoals();
    empNoVoCount.cGoals();
    Test.stopTest();
    
  }
 
 public static testMethod void testEmployeeNovo1()
  {
  Test.startTest();
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u = new User(Alias = 'standt', Email='sysAdmin@testorg.com', 
          EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/Los_Angeles', UserName='sysA657dmin@testorg.com');
          insert u;
       User userMnger = new User(Alias = 'standt1', Email='sysAdmin1@testorg1.com', 
          EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/Los_Angeles', UserName='sysAdmin1@testorg1.com', ManagerId=u.id);
          insert userMnger;   
      Employee__c emp=new Employee__c(name='Test Employee',salesforce_user__c=u.id,Employee_Number__c='1237656');
      insert emp; 
      Employee_NOVO_Log__c  novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal1');
      insert novoLog;
      Employee_NOVO_Log__c  novoLog1=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal2');
      insert novoLog1;
      Employee_NOVO_Log__c  novoLog2=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal3');
      insert novoLog2;
      NOVO_Activities__c novoAct=new NOVO_Activities__c(Action_activity__c='Test NovoAction 1',Owner__c=emp.id,Action_Completion_Date__c=Date.Today(),Status__c='In Progress',Employee_NOVO_Log__c=novoLog.id);
      insert novoAct;
      Attachment attach=new Attachment(Name='Test Attach',parentId=novoAct.id,OwnerId=UserInfo.getUserId(),IsPrivate = false,body=Blob.valueOf('Some Text'));
      insert attach;
      system.runAs(u){
      EmployeeNovoSummaryCont empNoVoCount=new EmployeeNovoSummaryCont();
      EmployeeNovoSummaryCont.NovoActions novoacts=new EmployeeNovoSummaryCont.NovoActions();
      novoacts.novAct=novoAct;
      EmployeeNovoSummaryCont.NovoWrapper novoWrap=new EmployeeNovoSummaryCont.NovoWrapper();
       novoWrap.empnov=novoLog;
       novoWrap.ActionList1.add(novoacts);
       EmployeeNovoSummaryCont.EmailWrapper novoWrapper=new EmployeeNovoSummaryCont.EmailWrapper(true,novoAct,'test.test@test.com');
       empNoVoCount.emailWrapList.add(novoWrapper);
      
      PageReference pageRef = Page.NovoReporteePage;
      Test.setCurrentPage(pageRef);
       //Id userId=UserInfo.getUserId();
     
      pageRef.getParameters().put('sfUser',string.valueOf(u.id));
      EmployeeNovoSummaryCont.uList uList=new EmployeeNovoSummaryCont.uList();
       uList.usr=new User();
       uList.oGoals=12.22;
       uList.cGoals=12.00;
      empNoVoCount.usrWrapper.add(uList);
      empNoVoCount.pageSize=5;
      empNoVoCount.showLink = true;
      empNoVoCount.selectListType='My People';
      pageRef.getParameters().put('req','NP');
      empNoVoCount.empIndiGoals=false;
      empNoVoCount.ReporteeRecords();
      empNoVoCount.oGoals();
      empNoVoCount.cGoals();
      empNoVoCount.empIndiGoals=true;
      empNoVoCount.reRunQuery();
      
      empNoVoCount.Beginning(); 
      empNoVoCount.Next();
      empNoVoCount.End();
      //empNoVoCount.Previous();
      empNoVoCount.emailHeader1=new NOVO_Activities__c();
      empNoVoCount.myselectedGoal=novoWrap;
      empNoVoCount.SelectedNovoWrapper=novoWrap;
      empNoVoCount.email='';
     // empNoVoCount.attachPdf();
    // empNoVoCount.generatePdf();
     empNoVoCount.ProcessSelected();
     empNoVoCount.attachPdf('test.test@test.com',novoAct);
      }
   Test.stopTest();
    
  }
  
 
}