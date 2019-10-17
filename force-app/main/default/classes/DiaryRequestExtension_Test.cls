@isTest (SeeAllData=true)

private class DiaryRequestExtension_Test{
    static District__c dist;
    static Employee__c emp;
    static User user;   
    static Diary_Change__c deReq;
    static Id avRec =  [Select Name from RecordType where  SObjectType ='Diary_Change__c' AND Name='Availability'].id;
    static Id geoRec =  [Select Name from RecordType where  SObjectType ='Diary_Change__c' AND Name='Geography'].id; 
    static Id bothRec =  [Select Name from RecordType where  SObjectType ='Diary_Change__c' AND Name='Availability & Geography'].id; 
    static Id unavRec =  [Select Name from RecordType where  SObjectType ='Diary_Change__c' AND Name='Unavailability'].id; 
    static ApexPages.StandardController controller; 
    static DiaryRequestExtension ext;
    
    static void createData(){
        user = TestClassHelper.createUser();
        insert user; 
        emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c=user.id;       
        insert emp;
        deReq = new Diary_Change__c(Appointment_Types__c='Sales',RecordTypeId=avRec,Employee__c=emp.id,Start__c=Date.valueOf('2014-12-01'),StartDT__c=Datetime.newInstance(2014,12,1,8,0,0),No_Of_Weeks__c=10,Week_1__c=true,Week_2__c=true,Week_3__c=true,Week_4__c=true,Unavailability_Reason__c='Not Applicable');     
        controller = new ApexPages.StandardController(deReq);       
        ext  = new DiaryRequestExtension(controller);  
        ext.monAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.monPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.tueAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.tuePMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.wedAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.wedPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.thuAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.thuPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.friAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.friPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.satAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.satPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        ext.sunAMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.sunPMWeek1.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
            
        ext.monAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.monPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.tueAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.tuePMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.wedAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.wedPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.thuAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.thuPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.friAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.friPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.satAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.satPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        ext.sunAMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.sunPMWeek2.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));         
           
        ext.monAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.monPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.tueAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.tuePMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.wedAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.wedPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.thuAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.thuPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.friAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.friPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.satAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.satPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        ext.sunAMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.sunPMWeek3.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));           
        
        ext.monAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.monPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.tueAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.tuePMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.wedAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.wedPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.thuAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.thuPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.friAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        //ext.friPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));
        ext.satAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.satPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        ext.sunAMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07'));    
        //ext.sunPMWeek4.add(new SelectOption('HT03_S07;HT03_S07','HT03_S07;HT03_S07')); 
         
        ext.week1Details = new Diary_Change_Request__c(Diary_Change_Master__c=deReq.id,Week_Number__c=1,
                           Mon_Any_ApptWK1__c=1,Mon_EV_ApptWK1__c=1,Mon_AM_ApptWk1__c=1,Mon_GD_AMWK1__c=1,Mon_GD_PMWK1__c=1,Mon_Non_Op_AM_ApptWK1__c=1,
                           Mon_Non_Op_Any_ApptWK1__c=1,Mon_Non_Op_PM_ApptWK1__c=1,Mon_07_09WK1__c=1,Mon_09_11WK1__c=1,Mon_11_13WK1__c=1,Mon_13_15WK1__c=1,Mon_15_17WK1__c=1,Mon_17_19WK1__c=1,Mon_19_20WK1__c=1,
                           Tue_Any_ApptWK1__c=1,Tue_EV_ApptWK1__c=1,Tue_AM_ApptWk1__c=1,Tue_GD_AMWK1__c=1,Tue_GD_PMWK1__c=1,Tue_Non_Op_AM_ApptWK1__c=1,
                           Tue_Non_Op_Any_ApptWK1__c=1,Tue_Non_Op_PM_ApptWK1__c=1,Tue_07_09WK1__c=1,Tue_09_11WK1__c=1,Tue_11_13WK1__c=1,Tue_13_15WK1__c=1,Tue_15_17WK1__c=1,Tue_17_19WK1__c=1,Tue_19_20WK1__c=1,
                           Wed_Any_ApptWK1__c=1,Wed_EV_ApptWK1__c=1,Wed_AM_ApptWk1__c=1,Wed_GD_AMWK1__c=1,Wed_GD_PMWK1__c=1,Wed_Non_Op_AM_ApptWK1__c=1,
                           Wed_Non_Op_Any_ApptWK1__c=1,Wed_Non_Op_PM_ApptWK1__c=1,Wed_07_09WK1__c=1,Wed_09_11WK1__c=1,Wed_11_13WK1__c=1,Wed_13_15WK1__c=1,Wed_15_17WK1__c=1,Wed_17_19WK1__c=1,Wed_19_20WK1__c=1,
                           Thu_Any_ApptWK1__c=1,Thu_EV_ApptWK1__c=1,Thu_AM_ApptWk1__c=1,Thu_GD_AMWK1__c=1,Thu_GD_PMWK1__c=1,Thu_Non_Op_AM_ApptWK1__c=1,
                           Thu_Non_Op_Any_ApptWK1__c=1,Thu_Non_Op_PM_ApptWK1__c=1,Thu_07_09WK1__c=1,Thu_09_11WK1__c=1,Thu_11_13WK1__c=1,Thu_13_15WK1__c=1,Thu_15_17WK1__c=1,Thu_17_19WK1__c=1,Thu_19_20WK1__c=1,
                           Fri_Any_ApptWK1__c=1,Fri_EV_ApptWK1__c=1,Fri_AM_ApptWk1__c=1,Fri_GD_AMWK1__c=1,Fri_GD_PMWK1__c=1,Fri_Non_Op_AM_ApptWK1__c=1,
                           Fri_Non_Op_Any_ApptWK1__c=1,Fri_Non_Op_PM_ApptWK1__c=1,Fri_07_09WK1__c=1,Fri_09_11WK1__c=1,Fri_11_13WK1__c=1,Fri_13_15WK1__c=1,Fri_15_17WK1__c=1,Fri_17_19WK1__c=1,Fri_19_20WK1__c=1,
                           Sat_Any_ApptWK1__c=1,Sat_EV_ApptWK1__c=1,Sat_AM_ApptWk1__c=1,Sat_GD_AMWK1__c=1,Sat_GD_PMWK1__c=1,Sat_Non_Op_AM_ApptWK1__c=1,
                           Sat_Non_Op_Any_ApptWK1__c=1,Sat_Non_Op_PM_ApptWK1__c=1,Sat_07_09WK1__c=1,Sat_09_11WK1__c=1,Sat_11_13WK1__c=1,Sat_13_15WK1__c=1,Sat_15_17WK1__c=1,Sat_17_19WK1__c=1,Sat_19_20WK1__c=1,
                           Sun_Any_ApptWK1__c=1,Sun_EV_ApptWK1__c=1,Sun_AM_ApptWk1__c=1,Sun_GD_AMWK1__c=1,Sun_GD_PMWK1__c=1,Sun_Non_Op_AM_ApptWK1__c=1,
                           Sun_Non_Op_Any_ApptWK1__c=1,Sun_Non_Op_PM_ApptWK1__c=1,Sun_07_09WK1__c=1,Sun_09_11WK1__c=1,Sun_11_13WK1__c=1,Sun_13_15WK1__c=1,Sun_15_17WK1__c=1,Sun_17_19WK1__c=1,Sun_19_20WK1__c=1);
                           

        ext.week2Details = new Diary_Change_Request__c(Diary_Change_Master__c=deReq.id,Week_Number__c=2,
                           Mon_Any_ApptWK1__c=1,Mon_EV_ApptWK1__c=1,Mon_AM_ApptWk1__c=1,Mon_GD_AMWK1__c=1,Mon_GD_PMWK1__c=1,Mon_Non_Op_AM_ApptWK1__c=1,
                           Mon_Non_Op_Any_ApptWK1__c=1,Mon_Non_Op_PM_ApptWK1__c=1,Mon_07_09WK1__c=1,Mon_09_11WK1__c=1,Mon_11_13WK1__c=1,Mon_13_15WK1__c=1,Mon_15_17WK1__c=1,Mon_17_19WK1__c=1,Mon_19_20WK1__c=1,
                           Tue_Any_ApptWK1__c=1,Tue_EV_ApptWK1__c=1,Tue_AM_ApptWk1__c=1,Tue_GD_AMWK1__c=1,Tue_GD_PMWK1__c=1,Tue_Non_Op_AM_ApptWK1__c=1,
                           Tue_Non_Op_Any_ApptWK1__c=1,Tue_Non_Op_PM_ApptWK1__c=1,Tue_07_09WK1__c=1,Tue_09_11WK1__c=1,Tue_11_13WK1__c=1,Tue_13_15WK1__c=1,Tue_15_17WK1__c=1,Tue_17_19WK1__c=1,Tue_19_20WK1__c=1,
                           Wed_Any_ApptWK1__c=1,Wed_EV_ApptWK1__c=1,Wed_AM_ApptWk1__c=1,Wed_GD_AMWK1__c=1,Wed_GD_PMWK1__c=1,Wed_Non_Op_AM_ApptWK1__c=1,
                           Wed_Non_Op_Any_ApptWK1__c=1,Wed_Non_Op_PM_ApptWK1__c=1,Wed_07_09WK1__c=1,Wed_09_11WK1__c=1,Wed_11_13WK1__c=1,Wed_13_15WK1__c=1,Wed_15_17WK1__c=1,Wed_17_19WK1__c=1,Wed_19_20WK1__c=1,
                           Thu_Any_ApptWK1__c=1,Thu_EV_ApptWK1__c=1,Thu_AM_ApptWk1__c=1,Thu_GD_AMWK1__c=1,Thu_GD_PMWK1__c=1,Thu_Non_Op_AM_ApptWK1__c=1,
                           Thu_Non_Op_Any_ApptWK1__c=1,Thu_Non_Op_PM_ApptWK1__c=1,Thu_07_09WK1__c=1,Thu_09_11WK1__c=1,Thu_11_13WK1__c=1,Thu_13_15WK1__c=1,Thu_15_17WK1__c=1,Thu_17_19WK1__c=1,Thu_19_20WK1__c=1,
                           Fri_Any_ApptWK1__c=1,Fri_EV_ApptWK1__c=1,Fri_AM_ApptWk1__c=1,Fri_GD_AMWK1__c=1,Fri_GD_PMWK1__c=1,Fri_Non_Op_AM_ApptWK1__c=1,
                           Fri_Non_Op_Any_ApptWK1__c=1,Fri_Non_Op_PM_ApptWK1__c=1,Fri_07_09WK1__c=1,Fri_09_11WK1__c=1,Fri_11_13WK1__c=1,Fri_13_15WK1__c=1,Fri_15_17WK1__c=1,Fri_17_19WK1__c=1,Fri_19_20WK1__c=1,
                           Sat_Any_ApptWK1__c=1,Sat_EV_ApptWK1__c=1,Sat_AM_ApptWk1__c=1,Sat_GD_AMWK1__c=1,Sat_GD_PMWK1__c=1,Sat_Non_Op_AM_ApptWK1__c=1,
                           Sat_Non_Op_Any_ApptWK1__c=1,Sat_Non_Op_PM_ApptWK1__c=1,Sat_07_09WK1__c=1,Sat_09_11WK1__c=1,Sat_11_13WK1__c=1,Sat_13_15WK1__c=1,Sat_15_17WK1__c=1,Sat_17_19WK1__c=1,Sat_19_20WK1__c=1,
                           Sun_Any_ApptWK1__c=1,Sun_EV_ApptWK1__c=1,Sun_AM_ApptWk1__c=1,Sun_GD_AMWK1__c=1,Sun_GD_PMWK1__c=1,Sun_Non_Op_AM_ApptWK1__c=1,
                           Sun_Non_Op_Any_ApptWK1__c=1,Sun_Non_Op_PM_ApptWK1__c=1,Sun_07_09WK1__c=1,Sun_09_11WK1__c=1,Sun_11_13WK1__c=1,Sun_13_15WK1__c=1,Sun_15_17WK1__c=1,Sun_17_19WK1__c=1,Sun_19_20WK1__c=1);

        ext.week3Details = new Diary_Change_Request__c(Diary_Change_Master__c=deReq.id,Week_Number__c=3,
                           Mon_Any_ApptWK1__c=1,Mon_EV_ApptWK1__c=1,Mon_AM_ApptWk1__c=1,Mon_GD_AMWK1__c=1,Mon_GD_PMWK1__c=1,Mon_Non_Op_AM_ApptWK1__c=1,
                           Mon_Non_Op_Any_ApptWK1__c=1,Mon_Non_Op_PM_ApptWK1__c=1,Mon_07_09WK1__c=1,Mon_09_11WK1__c=1,Mon_11_13WK1__c=1,Mon_13_15WK1__c=1,Mon_15_17WK1__c=1,Mon_17_19WK1__c=1,Mon_19_20WK1__c=1,
                           Tue_Any_ApptWK1__c=1,Tue_EV_ApptWK1__c=1,Tue_AM_ApptWk1__c=1,Tue_GD_AMWK1__c=1,Tue_GD_PMWK1__c=1,Tue_Non_Op_AM_ApptWK1__c=1,
                           Tue_Non_Op_Any_ApptWK1__c=1,Tue_Non_Op_PM_ApptWK1__c=1,Tue_07_09WK1__c=1,Tue_09_11WK1__c=1,Tue_11_13WK1__c=1,Tue_13_15WK1__c=1,Tue_15_17WK1__c=1,Tue_17_19WK1__c=1,Tue_19_20WK1__c=1,
                           Wed_Any_ApptWK1__c=1,Wed_EV_ApptWK1__c=1,Wed_AM_ApptWk1__c=1,Wed_GD_AMWK1__c=1,Wed_GD_PMWK1__c=1,Wed_Non_Op_AM_ApptWK1__c=1,
                           Wed_Non_Op_Any_ApptWK1__c=1,Wed_Non_Op_PM_ApptWK1__c=1,Wed_07_09WK1__c=1,Wed_09_11WK1__c=1,Wed_11_13WK1__c=1,Wed_13_15WK1__c=1,Wed_15_17WK1__c=1,Wed_17_19WK1__c=1,Wed_19_20WK1__c=1,
                           Thu_Any_ApptWK1__c=1,Thu_EV_ApptWK1__c=1,Thu_AM_ApptWk1__c=1,Thu_GD_AMWK1__c=1,Thu_GD_PMWK1__c=1,Thu_Non_Op_AM_ApptWK1__c=1,
                           Thu_Non_Op_Any_ApptWK1__c=1,Thu_Non_Op_PM_ApptWK1__c=1,Thu_07_09WK1__c=1,Thu_09_11WK1__c=1,Thu_11_13WK1__c=1,Thu_13_15WK1__c=1,Thu_15_17WK1__c=1,Thu_17_19WK1__c=1,Thu_19_20WK1__c=1,
                           Fri_Any_ApptWK1__c=1,Fri_EV_ApptWK1__c=1,Fri_AM_ApptWk1__c=1,Fri_GD_AMWK1__c=1,Fri_GD_PMWK1__c=1,Fri_Non_Op_AM_ApptWK1__c=1,
                           Fri_Non_Op_Any_ApptWK1__c=1,Fri_Non_Op_PM_ApptWK1__c=1,Fri_07_09WK1__c=1,Fri_09_11WK1__c=1,Fri_11_13WK1__c=1,Fri_13_15WK1__c=1,Fri_15_17WK1__c=1,Fri_17_19WK1__c=1,Fri_19_20WK1__c=1,
                           Sat_Any_ApptWK1__c=1,Sat_EV_ApptWK1__c=1,Sat_AM_ApptWk1__c=1,Sat_GD_AMWK1__c=1,Sat_GD_PMWK1__c=1,Sat_Non_Op_AM_ApptWK1__c=1,
                           Sat_Non_Op_Any_ApptWK1__c=1,Sat_Non_Op_PM_ApptWK1__c=1,Sat_07_09WK1__c=1,Sat_09_11WK1__c=1,Sat_11_13WK1__c=1,Sat_13_15WK1__c=1,Sat_15_17WK1__c=1,Sat_17_19WK1__c=1,Sat_19_20WK1__c=1,
                           Sun_Any_ApptWK1__c=1,Sun_EV_ApptWK1__c=1,Sun_AM_ApptWk1__c=1,Sun_GD_AMWK1__c=1,Sun_GD_PMWK1__c=1,Sun_Non_Op_AM_ApptWK1__c=1,
                           Sun_Non_Op_Any_ApptWK1__c=1,Sun_Non_Op_PM_ApptWK1__c=1,Sun_07_09WK1__c=1,Sun_09_11WK1__c=1,Sun_11_13WK1__c=1,Sun_13_15WK1__c=1,Sun_15_17WK1__c=1,Sun_17_19WK1__c=1,Sun_19_20WK1__c=1);
        
        ext.week4Details = new Diary_Change_Request__c(Diary_Change_Master__c=deReq.id,Week_Number__c=4,
                           Mon_Any_ApptWK1__c=1,Mon_EV_ApptWK1__c=1,Mon_AM_ApptWk1__c=1,Mon_GD_AMWK1__c=1,Mon_GD_PMWK1__c=1,Mon_Non_Op_AM_ApptWK1__c=1,
                           Mon_Non_Op_Any_ApptWK1__c=1,Mon_Non_Op_PM_ApptWK1__c=1,Mon_07_09WK1__c=1,Mon_09_11WK1__c=1,Mon_11_13WK1__c=1,Mon_13_15WK1__c=1,Mon_15_17WK1__c=1,Mon_17_19WK1__c=1,Mon_19_20WK1__c=1,
                           Tue_Any_ApptWK1__c=1,Tue_EV_ApptWK1__c=1,Tue_AM_ApptWk1__c=1,Tue_GD_AMWK1__c=1,Tue_GD_PMWK1__c=1,Tue_Non_Op_AM_ApptWK1__c=1,
                           Tue_Non_Op_Any_ApptWK1__c=1,Tue_Non_Op_PM_ApptWK1__c=1,Tue_07_09WK1__c=1,Tue_09_11WK1__c=1,Tue_11_13WK1__c=1,Tue_13_15WK1__c=1,Tue_15_17WK1__c=1,Tue_17_19WK1__c=1,Tue_19_20WK1__c=1,
                           Wed_Any_ApptWK1__c=1,Wed_EV_ApptWK1__c=1,Wed_AM_ApptWk1__c=1,Wed_GD_AMWK1__c=1,Wed_GD_PMWK1__c=1,Wed_Non_Op_AM_ApptWK1__c=1,
                           Wed_Non_Op_Any_ApptWK1__c=1,Wed_Non_Op_PM_ApptWK1__c=1,Wed_07_09WK1__c=1,Wed_09_11WK1__c=1,Wed_11_13WK1__c=1,Wed_13_15WK1__c=1,Wed_15_17WK1__c=1,Wed_17_19WK1__c=1,Wed_19_20WK1__c=1,
                           Thu_Any_ApptWK1__c=1,Thu_EV_ApptWK1__c=1,Thu_AM_ApptWk1__c=1,Thu_GD_AMWK1__c=1,Thu_GD_PMWK1__c=1,Thu_Non_Op_AM_ApptWK1__c=1,
                           Thu_Non_Op_Any_ApptWK1__c=1,Thu_Non_Op_PM_ApptWK1__c=1,Thu_07_09WK1__c=1,Thu_09_11WK1__c=1,Thu_11_13WK1__c=1,Thu_13_15WK1__c=1,Thu_15_17WK1__c=1,Thu_17_19WK1__c=1,Thu_19_20WK1__c=1,
                           Fri_Any_ApptWK1__c=1,Fri_EV_ApptWK1__c=1,Fri_AM_ApptWk1__c=1,Fri_GD_AMWK1__c=1,Fri_GD_PMWK1__c=1,Fri_Non_Op_AM_ApptWK1__c=1,
                           Fri_Non_Op_Any_ApptWK1__c=1,Fri_Non_Op_PM_ApptWK1__c=1,Fri_07_09WK1__c=1,Fri_09_11WK1__c=1,Fri_11_13WK1__c=1,Fri_13_15WK1__c=1,Fri_15_17WK1__c=1,Fri_17_19WK1__c=1,Fri_19_20WK1__c=1,
                           Sat_Any_ApptWK1__c=1,Sat_EV_ApptWK1__c=1,Sat_AM_ApptWk1__c=1,Sat_GD_AMWK1__c=1,Sat_GD_PMWK1__c=1,Sat_Non_Op_AM_ApptWK1__c=1,
                           Sat_Non_Op_Any_ApptWK1__c=1,Sat_Non_Op_PM_ApptWK1__c=1,Sat_07_09WK1__c=1,Sat_09_11WK1__c=1,Sat_11_13WK1__c=1,Sat_13_15WK1__c=1,Sat_15_17WK1__c=1,Sat_17_19WK1__c=1,Sat_19_20WK1__c=1,
                           Sun_Any_ApptWK1__c=1,Sun_EV_ApptWK1__c=1,Sun_AM_ApptWk1__c=1,Sun_GD_AMWK1__c=1,Sun_GD_PMWK1__c=1,Sun_Non_Op_AM_ApptWK1__c=1,
                           Sun_Non_Op_Any_ApptWK1__c=1,Sun_Non_Op_PM_ApptWK1__c=1,Sun_07_09WK1__c=1,Sun_09_11WK1__c=1,Sun_11_13WK1__c=1,Sun_13_15WK1__c=1,Sun_15_17WK1__c=1,Sun_17_19WK1__c=1,Sun_19_20WK1__c=1);
        
        ext.selectedDist='North Scotland';
        
        ext.masterPicklistSelected2 = 'Sales';
        ext.masterPicklistSelected3 = 'Sales';
        ext.masterPicklistSelected4 = 'Sales';
        
        ext.AnyTimeApptTypes.add(new selectoption('Sales','Sales'));
        ext.AnyTimeApptTypes.add(new selectoption('Priority','Priority'));
        ext.AnyTimeApptTypes.add(new selectoption('Green Deal','Green Deal'));
        
        ext.twoHrApptTypes.add(new selectoption('Sales','Sales'));
        ext.twoHrApptTypes.add(new selectoption('Priority','Priority'));
        
        ext.masterPicklist2.add(new selectoption('Sales','Sales'));
        ext.masterPicklist2.add(new selectoption('Priority','Priority'));
        ext.masterPicklist2.add(new selectoption('Green Deal','Green Deal'));
        
        ext.masterPicklist3.add(new selectoption('Sales','Sales'));
        ext.masterPicklist3.add(new selectoption('Priority','Priority'));
        ext.masterPicklist3.add(new selectoption('Green Deal','Green Deal'));
        
        ext.masterPicklist4.add(new selectoption('Sales','Sales'));
        ext.masterPicklist4.add(new selectoption('Priority','Priority'));
        ext.masterPicklist4.add(new selectoption('Green Deal','Green Deal'));
               
        PageReference page = new PageReference('/apex/createDairyEditRequest'); 
        Test.setCurrentPage(page);                  
    }
     
    static testmethod void testmethod1(){
        createData();   
        ext.continueMethod();
        ext.saveAllDetails();
        System.debug('============1'+ApexPages.getMessages());         
    }  
    
    static testmethod void testmethod2(){
        createData(); 
        deReq.Week_2__c=false;
        deReq.Week_3__c=true;
        deReq.Week_4__c=true;
        ext.continueMethod();
        ext.saveAllDetails();        
    } 
    
    static testmethod void testmethod3(){
        createData(); 
        deReq.Week_2__c=true;
        deReq.Week_3__c=false;
        deReq.Week_4__c=true;
        ext.continueMethod();
        ext.saveAllDetails();        
    }  
    
    static testmethod void testmethod4(){
        createData(); 
        deReq.Week_2__c=true;
        deReq.Week_3__c=true;
        deReq.Week_4__c=false;
        ext.continueMethod();
        ext.saveAllDetails();         
    } 
    
    static testmethod void testmethod5(){
        createData(); 
        deReq.Week_2__c=false;
        deReq.Week_3__c=false;
        deReq.Week_4__c=true;
        ext.continueMethod();
        ext.saveAllDetails();         
    }          
       
    static testmethod void testmethod6(){
        createData(); 
        deReq.Week_2__c=false;
        deReq.Week_3__c=true;
        deReq.Week_4__c=false;
        ext.continueMethod();
        ext.saveAllDetails();        
    } 
    
    static testmethod void testmethod7(){
        createData(); 
        deReq.Week_2__c=true;
        deReq.Week_3__c=false;
        deReq.Week_4__c=false;
        ext.continueMethod();
        ext.saveAllDetails();        
    } 
    
    static testmethod void testmethod8(){
        createData(); 
        ext.continueMethod();
        ext.saveAllDetails(); 
        ext.saveAllDetails();       
    } 
    
    static testmethod void testmethod9(){
        createData(); 
        deReq.RecordTypeId=unavRec;
        ext.continueMethod();
        ext.saveUnavailDetails();         
    } 
    
    static testmethod void testmethod10(){
        createData(); 
        deReq.RecordTypeId=geoRec;
        ext.continueMethod();
        ext.saveAllDetails();        
    } 
    
    static testmethod void testmethod11(){
        createData(); 
        deReq.RecordTypeId=bothRec;
        ext.continueMethod();
        ext.saveAllDetails();        
    }   
    
    static testmethod void testmethod12(){
        createData(); 
        ext.continueMethod();
        ext.saveAllDetails();
        Test.setCurrentPage(new PageReference('/apex/createDairyEditRequest?var_DCId='+deReq.id+'&var_isClone=true'));
        ext.diaryChangeIDString = deReq.id;
        ext.isClone = true;
        ext.cloneObjects();
        ext.saveAllDetails();       
    } 
    
    static testmethod void testmethod13(){
        createData(); 
        deReq.Request_Type__c = 'Geography Change';
        ext.continueMethod();
        ext.saveAllDetails();
        Test.setCurrentPage(new PageReference('/apex/createDairyEditRequest?var_DCId='+deReq.id+'&var_isClone=true'));
        ext.diaryChangeIDString = deReq.id;
        ext.isClone = true;
        ext.cloneObjects();
        ext.saveAllDetails();       
    } 
    
    static testmethod void testmethod14(){
        createData(); 
        deReq.Request_Type__c = 'Unavailability';
        ext.continueMethod();
        ext.saveAllDetails();
        Test.setCurrentPage(new PageReference('/apex/createDairyEditRequest?var_DCId='+deReq.id+'&var_isClone=true'));
        ext.diaryChangeIDString = deReq.id;
        ext.isClone = true;
        ext.cloneObjects();
        ext.saveAllDetails();       
    } 
    
    static testmethod void testmethod15(){
        createData(); 
        deReq.Request_Type__c = 'Appointment & Geography Change';
        ext.continueMethod();
        ext.saveAllDetails();
        Test.setCurrentPage(new PageReference('/apex/createDairyEditRequest?var_DCId='+deReq.id+'&var_isClone=true'));
        ext.diaryChangeIDString = deReq.id;
        ext.isClone = true;
        ext.cloneObjects();
        ext.saveAllDetails();       
    } 
    
     static testmethod void testmethod16(){
        createData(); 
        deReq.Request_Type__c = 'Appointment & Geography Change';
        ext.continueMethod();
        ext.saveAllDetails();
        Test.setCurrentPage(new PageReference('/apex/createDairyEditRequest?var_DCId='+deReq.id+'&var_isClone=true'));
        ext.diaryChangeIDString = deReq.id;
        ext.isClone = true;
        ext.back();
        ext.isClone = false;
        ext.back();  
    } 
    
    static testmethod void testmethod17(){
        createData(); 
        ext.continueMethod();
        ext.back();
        ext.continueMethod();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        ext.saveAllDetails();        
    }
    
    static testmethod void testmethod18(){
        createData(); 
        ext.continueMethod();
        ext.PopulateAppointmentTypes1();
        ext.PopulateAppointmentTypes2();
        ext.PopulateAppointmentTypes3();
        ext.PopulateAppointmentTypes4();
        ext.saveAllDetails();        
    }   
    
    static testmethod void testmethod19(){
        createData(); 
        ext.continueMethod();
        ext.masterPicklistSelected2 = 'Green Deal';
        ext.masterPicklistSelected3 = 'Green Deal';
        ext.masterPicklistSelected4 = 'Green Deal';
        deReq.Appointment_Types__c='Green Deal';
        ext.PopulateAppointmentTypes1();
        ext.PopulateAppointmentTypes2();
        ext.PopulateAppointmentTypes3();
        ext.PopulateAppointmentTypes4();
        ext.saveAllDetails();        
    }         
     
         
}