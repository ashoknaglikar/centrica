@isTest (SeeAllData=true)

private class DiaryChangeHelperMethods_Test{
    static Account acc;
    static Contact contact;
    static User user;
    static Opportunity oppo; 
    static Employee__c emp;
    static Role__c role; 
    static District__c dist;
    static Sub_Patch__c sb;
    static Role_Sub_Patch__c rsbp;
    static Appointment__c avApp,unavApp,app; 
    static Diary_Change__c diaryChng;
    static Diary_Change_Request__c week;
    static Diary_Change_Request__c week1;
    static id avRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Available'].id; 
    static id unavRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Unavailable'].id;
    static id appRec = [Select id from RecordType where SObjectType = 'Appointment__c' AND Name= 'Appointment'].id;
    static set<Id> RoleId =new set<Id>(); 
    static list<boolean> weeks = new list<boolean>();
    static set<Id> empIdSet = new set<Id>();
    static DiaryChangeHelperMethods helper = new DiaryChangeHelperMethods();    
     
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
        /*unavApp = TestClassHelper.createAppointment(oppo,emp.id,user.id,unavRec,contact.id);
        insert unavApp;              
        app = TestClassHelper.createAppointment(oppo,emp.id,user.id,appRec,contact.id); 
        insert app;*/         
        role = new Role__c(Employee__c=emp.id,Start_Date__c=Date.valueOf('2000-01-01'),End_Date__c=Date.valueOf('2999-01-01'));       
        insert role;
        dist = TestClassHelper.createdistrict();
        insert dist;
        sb = new Sub_Patch__c(Name='Sales_Dist_UNALLOC_P99',Code__c='HT99Test',Country_Differentiator__c='England',District__c=dist.id,Type__c='Sales',Upsert_Reference__c='HT99_P99_Inactive_OldSales');
        insert sb;
        rsbp = new Role_Sub_Patch__c(Role__c=role.id,Type__c='Availability',Sub_Patch__c=sb.id,Start_Date__c=Date.valueOf('2014-12-01'),End_Date__c=Date.valueOf('2014-12-30'));
        insert rsbp;     
        id avail = RecordTypeIdHelper.getRecordTypeId('Diary_Change__c', 'Availability & Geography');  
        
        Shift_template__c s = new Shift_template__c(Name= 'Test 1', Week_1__c = true, Week_2__c = true, Week_3__c = true, Week_4__c = true) ;
        insert s; 
        
        Week_template__c wt1 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 1', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        Week_template__c wt2 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 2', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        Week_template__c wt3 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 3', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        Week_template__c wt4 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 4', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        
        insert new list<Week_template__c>{wt1, wt2, wt3, wt4};
        
        diaryChng = new Diary_Change__c(Shift_template__c = s.id, RecordTypeId = avail,Employee__c=emp.id,Start__c=Date.valueOf('2014-12-01'),StartDT__c=Datetime.newInstance(2014,12,1,8,0,0),No_Of_Weeks__c=11,Week_1__c=true,Unavailability_Reason__c='Not Applicable');
        insert diaryChng;
        week = new Diary_Change_Request__c(Diary_Change_Master__c=diaryChng.id,Week_Number__c=1,
                           Mon_AM_RoleWK1__c='HT03_S07',Mon_Any_ApptWK1__c=1,Mon_EV_ApptWK1__c=1,Mon_PM_RoleWk1__c='HT03_S07',Mon_AM_ApptWk1__c=1,Mon_GD_AMWK1__c=1,Mon_GD_PMWK1__c=1,Mon_Non_Op_AM_ApptWK1__c=1,
                           Mon_Non_Op_Any_ApptWK1__c=1,Mon_Non_Op_PM_ApptWK1__c=1,Mon_07_09WK1__c=1,Mon_09_11WK1__c=1,Mon_11_13WK1__c=1,Mon_13_15WK1__c=1,Mon_15_17WK1__c=1,Mon_17_19WK1__c=1,Mon_19_20WK1__c=1,
                           Tue_AM_RoleWK1__c='HT03_S07',Tue_Any_ApptWK1__c=1,Tue_EV_ApptWK1__c=1,Tue_PM_RoleWk1__c='HT03_S07',Tue_AM_ApptWk1__c=1,Tue_GD_AMWK1__c=1,Tue_GD_PMWK1__c=1,Tue_Non_Op_AM_ApptWK1__c=1,
                           Tue_Non_Op_Any_ApptWK1__c=1,Tue_Non_Op_PM_ApptWK1__c=1,Tue_07_09WK1__c=1,Tue_09_11WK1__c=1,Tue_11_13WK1__c=1,Tue_13_15WK1__c=1,Tue_15_17WK1__c=1,Tue_17_19WK1__c=1,Tue_19_20WK1__c=1,
                           Wed_AM_RoleWK1__c='HT03_S07',Wed_Any_ApptWK1__c=1,Wed_EV_ApptWK1__c=1,Wed_PM_RoleWk1__c='HT03_S07',Wed_AM_ApptWk1__c=1,Wed_GD_AMWK1__c=1,Wed_GD_PMWK1__c=1,Wed_Non_Op_AM_ApptWK1__c=1,
                           Wed_Non_Op_Any_ApptWK1__c=1,Wed_Non_Op_PM_ApptWK1__c=1,Wed_07_09WK1__c=1,Wed_09_11WK1__c=1,Wed_11_13WK1__c=1,Wed_13_15WK1__c=1,Wed_15_17WK1__c=1,Wed_17_19WK1__c=1,Wed_19_20WK1__c=1,
                           Thu_AM_RoleWK1__c='HT03_S07',Thu_Any_ApptWK1__c=1,Thu_EV_ApptWK1__c=1,Thu_PM_RoleWk1__c='HT03_S07',Thu_AM_ApptWk1__c=1,Thu_GD_AMWK1__c=1,Thu_GD_PMWK1__c=1,Thu_Non_Op_AM_ApptWK1__c=1,
                           Thu_Non_Op_Any_ApptWK1__c=1,Thu_Non_Op_PM_ApptWK1__c=1,Thu_07_09WK1__c=1,Thu_09_11WK1__c=1,Thu_11_13WK1__c=1,Thu_13_15WK1__c=1,Thu_15_17WK1__c=1,Thu_17_19WK1__c=1,Thu_19_20WK1__c=1,
                           Fri_AM_RoleWK1__c='HT03_S07',Fri_Any_ApptWK1__c=1,Fri_EV_ApptWK1__c=1,Fri_PM_RoleWk1__c='HT03_S07',Fri_AM_ApptWk1__c=1,Fri_GD_AMWK1__c=1,Fri_GD_PMWK1__c=1,Fri_Non_Op_AM_ApptWK1__c=1,
                           Fri_Non_Op_Any_ApptWK1__c=1,Fri_Non_Op_PM_ApptWK1__c=1,Fri_07_09WK1__c=1,Fri_09_11WK1__c=1,Fri_11_13WK1__c=1,Fri_13_15WK1__c=1,Fri_15_17WK1__c=1,Fri_17_19WK1__c=1,Fri_19_20WK1__c=1,
                           Sat_AM_RoleWK1__c='HT03_S07',Sat_Any_ApptWK1__c=1,Sat_EV_ApptWK1__c=1,Sat_PM_RoleWk1__c='HT03_S07',Sat_AM_ApptWk1__c=1,Sat_GD_AMWK1__c=1,Sat_GD_PMWK1__c=1,Sat_Non_Op_AM_ApptWK1__c=1,
                           Sat_Non_Op_Any_ApptWK1__c=1,Sat_Non_Op_PM_ApptWK1__c=1,Sat_07_09WK1__c=1,Sat_09_11WK1__c=1,Sat_11_13WK1__c=1,Sat_13_15WK1__c=1,Sat_15_17WK1__c=1,Sat_17_19WK1__c=1,Sat_19_20WK1__c=1,
                           Sun_AM_RoleWK1__c='HT03_S07',Sun_Any_ApptWK1__c=1,Sun_EV_ApptWK1__c=1,Sun_PM_RoleWk1__c='HT03_S07',Sun_AM_ApptWk1__c=1,Sun_GD_AMWK1__c=1,Sun_GD_PMWK1__c=1,Sun_Non_Op_AM_ApptWK1__c=1,
                           Sun_Non_Op_Any_ApptWK1__c=1,Sun_Non_Op_PM_ApptWK1__c=1,Sun_07_09WK1__c=1,Sun_09_11WK1__c=1,Sun_11_13WK1__c=1,Sun_13_15WK1__c=1,Sun_15_17WK1__c=1,Sun_17_19WK1__c=1,Sun_19_20WK1__c=1);
        insert week;
        
        
        RoleId.add(role.id); 
        weeks.add(true);weeks.add(false);weeks.add(false);weeks.add(false);
        empIdSet.add(emp.id);                   
    } 
    

    static testmethod void testmethod1(){
        createData();
        PageReference page = new PageReference('/apex/GeographyChangeReqPage?var_DCId='+diaryChng.id); 
        Test.setCurrentPage(page);           
        DiaryChangeHelperMethods.massDeleteRole(RoleId , Date.valueOf('2000-01-01'), Date.valueOf('2999-01-01'), weeks, diaryChng.id);
        DiaryChangeHelperMethods.massDeleteAppts(empIdSet , Date.valueOf('2000-01-01'), Date.valueOf('2999-01-01'),  avRec, diaryChng.id);
        DiaryChangeHelperMethods.insertUnavailabilties(diaryChng.id,empIdSet,Date.valueOf('2000-01-01'), Date.valueOf('2000-01-30'), unavRec, diaryChng.Unavailability_Reason__c, 'notes', 'subject');        
        Map<string , list<list<List<Date>>>>  tempMap = helper.populateStartEndDates( week, diaryChng.Start__c , diaryChng.Start__c.addDays(8));
        helper.createRoleSubPacth(tempMap,role.id,10);
        DiaryChangeHelperMethods.insertRoleSubpatches(diaryChng.id, RoleId);        
        DiaryChangeHelperMethods.inserAppointments(empIdSet,diaryChng.id);
        //helper.populateApp(week, 10, diaryChng.StartDT__c,emp.id);             
    }  
    
    static testmethod void testmethod2(){
        createData();
        Shift_template__c s = new Shift_template__c(Name= 'Test 1', Week_1__c = true, Week_2__c = true, Week_3__c = true, Week_4__c = true) ;
        insert s; 
        
        Week_template__c wt1 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 1', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        Week_template__c wt2 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 2', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        Week_template__c wt3 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 3', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        //Week_template__c wt4 = new Week_template__c(Shift_template__c = s.id,	Week_Name__c = 'Week 4', Day_name__c = 'Monday', 	Start_time__c = time.newInstance(10, 00, 00, 00), End_Time__c = time.newInstance(11, 00, 00, 00), Number_of_Appointments__c	= 1,  Type__c = 'Sales');
        
        insert new list<Week_template__c>{wt1, wt2, wt3};
        diaryChng.Team__c = 'Straight Swap';
        diaryChng.Cycle__c = '3 Week';
        diaryChng.Shift_template__c = s.Id;
        update diaryChng;
        week.Mon_09_00_09_40__c =1;week.Mon_09_40_10_20__c =1;week.Mon_10_20_11_00__c =1;week.Mon_11_00_11_40__c =1;week.Mon_11_40_12_20__c =1;week.Mon_12_20_13_00__c =1;week.Mon_13_00_13_40__c =1;
                            week.Mon_13_40_14_20__c =1;week.Mon_14_20_15_00__c =1;week.Mon_15_00_15_40__c =1;week.Mon_15_40_16_20__c =1;week.Mon_16_20_17_00__c =1;week.Mon_17_00_17_40__c =1;week.Mon_17_40_18_20__c =1;
                            week.Mon_18_20_19_00__c =1;week.Mon_19_00_19_40__c =1;week.Tue_09_00_09_40__c =1;week.Tue_09_40_10_20__c =1;week.Tue_10_20_11_00__c =1;week.Tue_11_00_11_40__c =1;week.Tue_11_40_12_20__c =1;
                            week.Tue_12_20_13_00__c =1;week.Tue_13_00_13_40__c =1;week.Tue_13_40_14_20__c =1;week.Tue_14_20_15_00__c =1;week.Tue_15_00_15_40__c =1;week.Tue_15_40_16_20__c =1;week.Tue_16_20_17_00__c =1;
                            week.Tue_17_00_17_40__c =1;week.Tue_17_40_18_20__c =1;week.Tue_18_20_19_00__c =1;week.Tue_19_00_19_40__c =1;week.Wed_09_00_09_40__c =1;week.Wed_09_40_10_20__c =1;week.Wed_10_20_11_00__c =1;
                            week.Wed_11_00_11_40__c =1;week.Wed_11_40_12_20__c =1;week.Wed_12_20_13_00__c =1;week.Wed_13_00_13_40__c =1;week.Wed_13_40_14_20__c =1;week.Wed_14_20_15_00__c =1;week.Wed_15_00_15_40__c =1;
                            week.Wed_15_40_16_20__c =1;week.Wed_16_20_17_00__c =1;week.Wed_17_00_17_40__c =1;week.Wed_17_40_18_20__c =1;week.Wed_18_20_19_00__c =1;week.Wed_19_00_19_40__c =1;week.Thu_09_00_09_40__c =1;
                            week.Thu_09_40_10_20__c =1;week.Thu_10_20_11_00__c =1;week.Thu_11_00_11_40__c =1;week.Thu_11_40_12_20__c =1;week.Thu_12_20_13_00__c =1;week.Thu_13_00_13_40__c =1;week.Thu_13_40_14_20__c =1;
                            week.Thu_14_20_15_00__c =1;week.Thu_15_00_15_40__c =1;week.Thu_15_40_16_20__c =1;week.Thurs_16_20_17_00__c =1;week.Thurs_17_00_17_40__c =1;week.Thurs_17_40_18_20__c =1;week.Thurs_18_20_19_00__c =1;
                            week.Thurs_19_00_19_40__c =1;week.Fri_09_00_09_40__c =1;week.Fri_09_40_10_20__c =1;week.Fri_10_20_11_00__c =1;week.Fri_11_00_11_40__c =1;week.Fri_11_40_12_20__c =1;week.Fri_12_20_13_00__c =1;week.Fri_13_00_13_40__c =1;
                            week.Fri_13_40_14_20__c =1;week.Fri_14_20_15_00__c =1;week.Fri_15_00_15_40__c =1;week.Fri_15_40_16_20__c =1;week.Fri_16_20_17_00__c =1;week.Fri_17_00_17_40__c =1;week.Fri_17_40_18_20__c =1;week.Fri_18_20_19_00__c =1;
                            week.Fri_19_00_19_40__c =1;week.Sat_09_00_09_40__c =1;week.Sat_09_40_10_20__c =1;week.Sat_10_20_11_00__c =1;week.Sat_11_00_11_40__c =1;week.Sat_11_40_12_20__c =1;week.Sat_12_20_13_00__c =1;week.Sat_13_00_13_40__c =1;
                            week.Sat_13_40_14_20__c =1;week.Sat_14_20_15_00__c =1;week.Sat_15_00_15_40__c =1;week.Sat_15_40_16_20__c =1;week.Sat_16_20_17_00__c =1;week.Sat_17_00_17_40__c =1;week.Sat_17_40_18_20__c =1;week.Sat_18_20_19_00__c =1;
                            week.Sat_19_00_19_40__c =1;week.Sun_09_00_09_40__c =1;week.Sun_09_40_10_20__c =1;week.Sun_10_20_11_00__c =1;week.Sun_11_00_11_40__c =1;week.Sun_11_40_12_20__c =1;week.Sun_12_20_13_00__c =1;week.Sun_13_00_13_40__c =1;
                            week.Sun_13_40_14_20__c =1;week.Sun_14_20_15_00__c =1;week.Sun_15_00_15_40__c =1;week.Sun_15_40_16_20__c =1;week.Sun_16_20_17_00__c =1;week.Sun_17_00_17_40__c =1;week.Sun_17_40_18_20__c =1;week.Sun_18_20_19_00__c =1;
                            week.Sun_19_00_19_40__c=1;week.Mon_AM_RoleWK1__c='HT03_S07';week.Tue_AM_RoleWK1__c='HT03_S07';week.Wed_AM_RoleWK1__c='HT03_S07';week.Thu_AM_RoleWK1__c='HT03_S07';week.Fri_AM_RoleWK1__c='HT03_S07';week.Sat_AM_RoleWK1__c='HT03_S07';
                            week.Sun_AM_RoleWK1__c='HT03_S07';
        update week; 
        PageReference page = new PageReference('/apex/GeographyChangeReqPage?var_DCId='+diaryChng.id); 
        Test.setCurrentPage(page);           
        DiaryChangeHelperMethods.massDeleteRole(RoleId , Date.valueOf('2000-01-01'), Date.valueOf('2999-01-01'), weeks, diaryChng.id);
        DiaryChangeHelperMethods.massDeleteAppts(empIdSet , Date.valueOf('2000-01-01'), Date.valueOf('2999-01-01'),  avRec, diaryChng.id);
        DiaryChangeHelperMethods.insertUnavailabilties(diaryChng.id,empIdSet,Date.valueOf('2000-01-01'), Date.valueOf('2000-01-30'), unavRec, diaryChng.Unavailability_Reason__c, 'notes', 'subject');        
        Map<string , list<list<List<Date>>>>  tempMap = helper.populateStartEndDates( week, diaryChng.Start__c , diaryChng.Start__c.addDays(8));
        helper.createRoleSubPacth(tempMap,role.id,10);
        DiaryChangeHelperMethods.insertRoleSubpatches(diaryChng.id, RoleId);        
        DiaryChangeHelperMethods.inserAppointments(empIdSet,diaryChng.id);
        //helper.populateApp(week, 10, diaryChng.StartDT__c,emp.id);             
    } 
}