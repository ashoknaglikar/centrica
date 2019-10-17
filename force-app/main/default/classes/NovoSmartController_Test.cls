@isTest
private class NovoSmartController_Test{
 static Supplier__c supplier;
 static Employee__c emp;
 static Employee_NOVO_Log__c  novoLog;
 static NOVO_Activities__c novoAct;
 static testmethod void testMethod1(){
  Test.startTest();
     
     supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
     insert emp;
     novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal1');
     insert novoLog;
     novoAct=new NOVO_Activities__c(Action_activity__c ='Test NovoAction 1',Owner__c=emp.id,Action_Completion_Date__c=Date.Today(),Status__c='In Progress',Employee_NOVO_Log__c=novoLog.id);
     insert novoAct;
     
     Attachment attach=new Attachment(Name='Test Attach',parentId=novoAct.id,OwnerId=UserInfo.getUserId(),IsPrivate = false,body=Blob.valueOf('Some Text'));
     insert attach;
     
     PageReference pageRef = Page.Smart_Novo;
     Test.setCurrentPage(pageRef);

    
     pageRef.getParameters().put('signSuccess','2');
    // pageRef.getParameters().put('signSuccess','0');
     // pageRef.getParameters().put('signSuccess','1');
     pageRef.getParameters().put('headerID',novoLog.id);
     //pageRef.getParameters().put('eId',emp.id);
     ApexPages.StandardController sc = new ApexPages.StandardController(novoLog);
     NovoSmartController testAccPlan = new NovoSmartController(sc);
     
     testAccPlan.viewPdf=true; 
     testAccPlan.reqFrom='NP';
     testAccPlan.val=1; 
     
     testAccPlan.emailHeader1=novoAct;
     testAccPlan.numberOfRowToRemove=1; 
     testAccPlan.email='test.testeml@test.com';
    // NovoSmartController.NovoWrapper novoWrapList=new NovoSmartController.NovoWrapper(novoAct);
     //novoWrapList.NovoFields=new list<Schema.FieldSetMember>();
     testAccPlan.NovoAction();
     testAccPlan.createNovoActivity();
     testAccPlan.RemoveAction();
     //system.assertEquals(testAccPlan.theQuestions.size(),0);
     testAccPlan.saveAction();
     testAccPlan.generatePdf();
   //  testAccPlan.AttachPdf();
     testAccPlan.reqFrom='NG';
    // testAccPlan.AttachPdf();
     
     testAccPlan.upload();
     testAccPlan.goBack();
   //  testAccPlan.sendpdfAction();
     testAccPlan.deleteNovo();
     testAccPlan.sendEmail(attach);
     
   
    
     
     

  Test.stopTest();
 }
 static testmethod void testMethod2(){
  Test.startTest();
  
   supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
     insert emp;
     novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal1');
     insert novoLog;
  
  
  
   PageReference pageRef = Page.Smart_Novo;
   Test.setCurrentPage(pageRef);
   
   
   pageRef.getParameters().put('signSuccess','1');
   pageRef.getParameters().put('headerID',null);
   pageRef.getParameters().put('email',Null);
   
   ApexPages.StandardController sc = new ApexPages.StandardController(novoLog);
   NovoSmartController testAccPlan = new NovoSmartController(sc);
   
   testAccPlan.emailHeader1=new NOVO_Activities__c();
   testAccPlan.reqFrom='NG';
    testAccPlan.viewPdf=false; 
  // testAccPlan.AttachPdf();
   testAccPlan.saveAction();
   pageRef =testAccPlan.generatePdf();
   testAccPlan.goBack();
   system.assertEquals(testAccPlan.emailHeader1.Owner__c,null);

   
   
   Test.stopTest();
 }
 
 static testmethod void testMethod3()
 
 {
  Test.startTest();
  novoLog=new Employee_NOVO_Log__c();
 
   PageReference pageRef = Page.Smart_Novo;
   Test.setCurrentPage(pageRef);
   
   pageRef.getParameters().put('signSuccess','0');
   ApexPages.StandardController sc = new ApexPages.StandardController(novoLog);
   NovoSmartController testAccPlan = new NovoSmartController(sc);
   testAccPlan.theQuestions=new List<NovoSmartController.NovoWrapper>();
   testAccPlan.goBack();
   testAccPlan.errorMsg='Test Error Msg';
    Attachment attach=new Attachment();
   testAccPlan.sendEmail(attach);
   testAccPlan.saveAction();
   testAccPlan.setErrorMsg();
   //testAccPlan.AttachPdf();
  
  Test.stopTest();
 }
 static testmethod void testMethod4()
 
 {
  Test.startTest();
   supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
     insert emp;
     novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal1');
     insert novoLog;
     novoAct=new NOVO_Activities__c(Action_activity__c ='Test NovoAction 1',Owner__c=emp.id,Action_Completion_Date__c=Date.Today(),Status__c='In Progress',Employee_NOVO_Log__c=novoLog.id);
     insert novoAct;
 
   PageReference pageRef = Page.Smart_Novo;
   Test.setCurrentPage(pageRef);
   
   pageRef.getParameters().put('signSuccess','2');
   ApexPages.StandardController sc = new ApexPages.StandardController(novoLog);
   NovoSmartController testAccPlan = new NovoSmartController(sc);
   
   testAccPlan.theQuestions=new List<NovoSmartController.NovoWrapper>();
   
   testAccPlan.viewPdf=true; 
   testAccPlan.viewPdf=false; 
   
  // testAccPlan.NovoFormPdf=new Attachment(Name='Test Attach',parentId=novoAct.id,OwnerId=UserInfo.getUserId(),IsPrivate = false,body=Blob.valueOf('Some Text'),contenttype='.pdf');
  // insert  testAccPlan.NovoFormPdf;
   
   pageRef =testAccPlan.generatePdf();
   
   testAccPlan.goBack();
   //testAccPlan.setErrorMsg();
  
  Test.stopTest();
 }
 
 static testmethod void testMethod5()
 {
 Test.startTest();
  supplier = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1274',Resource_Type__c='Resource');
     insert supplier;
     emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Primary_Role__c='HSA');
     insert emp;
     novoLog=new Employee_NOVO_Log__c(Employee__c=emp.id,Number_of_Actions__c='1',Status__c='In Progress',Reason__c='Health, Safety, Environment Review',Related_Strategic_Priority__c='Safety compliance and conduct',Note_on_Outcome__c='TestNotes',Goal_Target_Date__c=Date.Today(),How_will_you_measure_prog__c='TestMeasure',Where_Are_U_Now__c='TestWhereRU',Goal_novo__c='TestGoal1');
     insert novoLog;
     novoAct=new NOVO_Activities__c(Action_activity__c ='Test NovoAction 1',Owner__c=emp.id,Action_Completion_Date__c=Date.Today(),Status__c='In Progress',Employee_NOVO_Log__c=novoLog.id);
     insert novoAct;
  PageReference pdfPage = page.NovoSmartPdf;
  Test.setCurrentPage(pdfPage);
   
   pdfPage.getParameters().put('signSuccess','2');
   ApexPages.StandardController sc = new ApexPages.StandardController(novoLog);
   NovoSmartController testAccPlan = new NovoSmartController(sc);
   
   testAccPlan.viewPdf=false; 
   Blob pdfBlob = blob.valueOf('UNIT.TEST');
   //testAccPlan.NovoFormPdf=new Attachment(Name='Test Attach',parentId=novoAct.id,OwnerId=UserInfo.getUserId(),IsPrivate = false,body=pdfBlob,contenttype='.pdf');
   //insert  testAccPlan.NovoFormPdf;
   testAccPlan.reqFrom='NP';
   testAccPlan.generatePdf();
   testAccPlan.CallSendPdf(novoLog.id);
    NovoSmartController.EmailWrapper novoWrapper=new NovoSmartController.EmailWrapper(true,novoAct,'test.test@test.com');
    testAccPlan.emailWrapList.add(novoWrapper);
    testAccPlan.ProcessSelected();
    testAccPlan.AttachPdf('test.test@test.com',novoAct);
    testAccPlan.emailWrapList.clear();
    NovoSmartController.EmailWrapper novoWrapper1=new NovoSmartController.EmailWrapper(false,novoAct,'test.test@test.com');
    testAccPlan.emailWrapList.add(novoWrapper1);
    testAccPlan.ProcessSelected();
    testAccPlan.AttachPdf('test.test@test.com',novoAct);
   Test.stopTest();
 }

}