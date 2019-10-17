@isTest (SeeAllData=true)

private class AvailabilityChangeReqController_Test{
   static Account acc;
   static Contact contact;
   static User user;
   static Opportunity oppo; 
   static Employee__c emp;
   static Appointment__c avApp,unavApp,app;
   //static Id avRec,unavRec,appRec;
   static Diary_Change__c diaryChng;
   static Diary_Change_Request__c week;   
    
   static id avRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Available'].id; 
   static id unavRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Unavailable'].id;
   static id appRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Appointment'].id;  
   
   static void createData(){
       user = TestClassHelper.createUser();
       insert user;       
       acc = TestClassHelper.createAccout();
       insert acc;              
       contact = TestClassHelper.createContact(acc);
       insert contact;              
       oppo = TestClassHelper.createCHILead(acc);
       insert oppo;             
       emp = TestClassHelper.createEmployee();
       emp.Salesforce_User__c=user.id;       
       insert emp;              
       avApp = TestClassHelper.createAppointment(oppo,emp.id,user.id,avRec,contact.id);
       insert avApp;              
       //unavApp = TestClassHelper.createAppointment(oppo,emp.id,user.id,unavRec,contact.id);
       //insert unavApp;              
       //app = TestClassHelper.createAppointment(oppo,emp.id,user.id,appRec,contact.id); 
       //insert app; 
       Shift_template__c s = new Shift_template__c(Name= 'Test 1', Week_1__c = true, Week_2__c = true, Week_3__c = true, Week_4__c = true) ;
        insert s; 
        
        Week_template__c wt1 = new Week_template__c(Shift_template__c = s.id, Week_Name__c = 'Week 1', Day_name__c = 'Monday',  Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c = 1,  Type__c = 'Sales');
        Week_template__c wt2 = new Week_template__c(Shift_template__c = s.id, Week_Name__c = 'Week 2', Day_name__c = 'Monday',  Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c = 1,  Type__c = 'Sales');
        Week_template__c wt3 = new Week_template__c(Shift_template__c = s.id, Week_Name__c = 'Week 3', Day_name__c = 'Monday',  Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c = 1,  Type__c = 'Sales');
        Week_template__c wt4 = new Week_template__c(Shift_template__c = s.id, Week_Name__c = 'Week 4', Day_name__c = 'Monday',  Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c = 1,  Type__c = 'Sales');
        
        insert new list<Week_template__c>{wt1, wt2, wt3, wt4};
       id avail = RecordTypeIdHelper.getRecordTypeId('Diary_Change__c', 'Availability & Geography');        
       diaryChng = new Diary_Change__c(Shift_template__c = s.id , RecordTypeId = avail,Employee__c=emp.id,Start__c=Date.valueOf('2014-12-01'),StartDT__c=Datetime.newInstance(2014,12,1,8,0,0),No_Of_Weeks__c=1,Week_1__c=true,
                 Unavailability_Reason__c='Not Applicable',End__c=Date.valueOf('2014-12-10'),EndDT__c=Datetime.newInstance(2014,12,10,8,0,0));
       insert diaryChng;
       week = new Diary_Change_Request__c(Diary_Change_Master__c=diaryChng.id,Week_Number__c=1,Mon_AM_ApptWk1__c=1);
       insert week;      
       PageReference page = new PageReference('/apex/AvailabilityChangeReqPage?var_DCId='+diaryChng.id); 
       Test.setCurrentPage(page);           
   }
    
   static testmethod void testmethod1(){
       createData();
       AvailabilityChangeReqController controller = new AvailabilityChangeReqController();
       AvailabilityChangeReqController.AppointmentWrap controller1 =  new AvailabilityChangeReqController.AppointmentWrap(true,avApp);    
       controller.onSelect();
       controller.onClickRefresh();
       controller.onClickBack();         
   } 
    
    static testmethod void testmethod2(){
       createData();
       AvailabilityChangeReqController controller = new AvailabilityChangeReqController();
       controller.Next1();
       controller.Previous1();       
       controller.getDisablePrevious1();
       controller.getDisableNext1();
       controller.getPageNumber1();
       controller.getTotalPages1();
       
       controller.Next2();
       controller.Previous2();       
       controller.getDisablePrevious2();
       controller.getDisableNext2();
       controller.getPageNumber2();
       controller.getTotalPages2();
       
       controller.Next3();
       controller.Previous3();       
       controller.getDisablePrevious3();
       controller.getDisableNext3();
       controller.getPageNumber3();
       controller.getTotalPages3();
    } 
    
    static testmethod void testmethod3(){
       createData();
       AvailabilityChangeReqController controller = new AvailabilityChangeReqController();
       controller.getAppointments();
       controller.onClickAvailability();
       controller.delSals = false;       
       controller.onClickDeleteAvailable();
       controller.delSals = true;
       controller.onClickDeleteAvailable();       
       controller.delUnav = false;        
       controller.onClickDeleteUnavailable(); 
       controller.delUnav = true;        
       controller.onClickDeleteUnavailable();    
       controller.onClickUnAvailability(); 
       controller.checkIfNeeds(avApp);       
    }    
}