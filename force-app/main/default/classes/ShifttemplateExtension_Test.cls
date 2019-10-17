@isTest
public class ShifttemplateExtension_Test {
    
    public static Employee__c emp;
    public  static User user;   
    public  static Diary_Change__c deReq;
    public static Shift_template__c shiTemp;
    public static Id avRec =  [Select Name from RecordType where  SObjectType ='Diary_Change__c' AND Name='Availability'].id;
    public static ApexPages.StandardController controller; 
    public static ShifttemplateExtension ext;
    public static availabilityWrapper availabilityWrapIns = new availabilityWrapper();
    public static Time startTime = Time.newInstance(18,30,2,20);
    public static Time endTime = Time.newInstance(19,30,2,20);

    
    static void createData(){
        user = TestClassHelper.createUser();
        insert user; 
        emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c=user.id;       
        insert emp;
        deReq = new Diary_Change__c(Appointment_Types__c='Sales',RecordTypeId=avRec,Employee__c=emp.id,Start__c=Date.valueOf('2014-12-01'),StartDT__c=Datetime.newInstance(2014,12,1,8,0,0),No_Of_Weeks__c=10,Week_1__c=true,Week_2__c=true,Week_3__c=true,Week_4__c=true,Unavailability_Reason__c='Not Applicable');     
        shiTemp = new Shift_template__c (Name='Test',Description__c='Test',Week_1__c=true,Week_2__c=true,Week_3__c=true,Week_4__c=true);  
        //insert shiTemp;
        controller = new ApexPages.StandardController(shiTemp);
        ext  = new ShifttemplateExtension(controller);
        ext.shiftTemplate = shiTemp;
        
    }
    
    //Values present in all 4 weeks
    static availabilityWrapper createData1(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        tesins2.appointments = 2;
        tesins2.type = 'Sales';
        tesins2.startTime = startTime;
        tesins2.endTime = endTime;
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest2;
        test.week2TemplateTuesdayList = listtest2;
        test.week2TemplateWednesdayList = listtest2;
        test.week2TemplateThursdayList = listtest2;
        test.week2TemplateFridayList = listtest2;
        test.week2TemplateSaturdayList = listtest2;
        test.week2TemplateSundayList = listtest2;
        
        test.week3TemplateMondayList = listtest2;
        test.week3TemplateTuesdayList = listtest2;
        test.week3TemplateWednesdayList = listtest2;
        test.week3TemplateThursdayList = listtest2;
        test.week3TemplateFridayList = listtest2;
        test.week3TemplateSaturdayList = listtest2;
        test.week3TemplateSundayList = listtest2;
        
        test.week4TemplateMondayList = listtest2;
        test.week4TemplateTuesdayList = listtest2;
        test.week4TemplateWednesdayList = listtest2;
        test.week4TemplateThursdayList = listtest2;
        test.week4TemplateFridayList = listtest2;
        test.week4TemplateSaturdayList = listtest2;
        test.week4TemplateSundayList = listtest2;
        
        return test;
 
    }

     //Values present only in week1
     static availabilityWrapper createData2(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        //tesins2.appointments = 2;
        //tesins2.type = 'Sales';
        //tesins2.startTime = startTime;
        //tesins2.endTime = endTime;
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest2;
        test.week2TemplateTuesdayList = listtest2;
        test.week2TemplateWednesdayList = listtest2;
        test.week2TemplateThursdayList = listtest2;
        test.week2TemplateFridayList = listtest2;
        test.week2TemplateSaturdayList = listtest2;
        test.week2TemplateSundayList = listtest2;
        
        test.week3TemplateMondayList = listtest2;
        test.week3TemplateTuesdayList = listtest2;
        test.week3TemplateWednesdayList = listtest2;
        test.week3TemplateThursdayList = listtest2;
        test.week3TemplateFridayList = listtest2;
        test.week3TemplateSaturdayList = listtest2;
        test.week3TemplateSundayList = listtest2;
        
        test.week4TemplateMondayList = listtest2;
        test.week4TemplateTuesdayList = listtest2;
        test.week4TemplateWednesdayList = listtest2;
        test.week4TemplateThursdayList = listtest2;
        test.week4TemplateFridayList = listtest2;
        test.week4TemplateSaturdayList = listtest2;
        test.week4TemplateSundayList = listtest2;
        
        return test;
        
     }
    
    //Values present in week 1, week 2, week 3
     static availabilityWrapper createData3(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        //tesins2.appointments = 2;
        //tesins2.type = 'Sales';
        //tesins2.startTime = startTime;
        //tesins2.endTime = endTime;
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest;
        test.week2TemplateTuesdayList = listtest;
        test.week2TemplateWednesdayList = listtest;
        test.week2TemplateThursdayList = listtest;
        test.week2TemplateFridayList = listtest;
        test.week2TemplateSaturdayList = listtest;
        test.week2TemplateSundayList = listtest;
        
        test.week3TemplateMondayList = listtest;
        test.week3TemplateTuesdayList = listtest;
        test.week3TemplateWednesdayList = listtest;
        test.week3TemplateThursdayList = listtest;
        test.week3TemplateFridayList = listtest;
        test.week3TemplateSaturdayList = listtest;
        test.week3TemplateSundayList = listtest;
        
        test.week4TemplateMondayList = listtest2;
        test.week4TemplateTuesdayList = listtest2;
        test.week4TemplateWednesdayList = listtest2;
        test.week4TemplateThursdayList = listtest2;
        test.week4TemplateFridayList = listtest2;
        test.week4TemplateSaturdayList = listtest2;
        test.week4TemplateSundayList = listtest2;
        
        return test;
        
     }
    
    //Values present in week 1 and week 2
    static availabilityWrapper createData4(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        //tesins2.appointments = 2;
        //tesins2.type = 'Sales';
        //tesins2.startTime = startTime;
        //tesins2.endTime = endTime;
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest;
        test.week2TemplateTuesdayList = listtest;
        test.week2TemplateWednesdayList = listtest;
        test.week2TemplateThursdayList = listtest;
        test.week2TemplateFridayList = listtest;
        test.week2TemplateSaturdayList = listtest;
        test.week2TemplateSundayList = listtest;
        
        test.week3TemplateMondayList = listtest2;
        test.week3TemplateTuesdayList = listtest2;
        test.week3TemplateWednesdayList = listtest2;
        test.week3TemplateThursdayList = listtest2;
        test.week3TemplateFridayList = listtest2;
        test.week3TemplateSaturdayList = listtest2;
        test.week3TemplateSundayList = listtest2;
        
        test.week4TemplateMondayList = listtest2;
        test.week4TemplateTuesdayList = listtest2;
        test.week4TemplateWednesdayList = listtest2;
        test.week4TemplateThursdayList = listtest2;
        test.week4TemplateFridayList = listtest2;
        test.week4TemplateSaturdayList = listtest2;
        test.week4TemplateSundayList = listtest2;
        
        return test;
        
     }
    
    //Values present only in week 1 and week 3
    static availabilityWrapper createData5(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        //tesins2.appointments = 2;
        //tesins2.type = 'Sales';
        //tesins2.startTime = startTime;
        //tesins2.endTime = endTime;
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest2;
        test.week2TemplateTuesdayList = listtest2;
        test.week2TemplateWednesdayList = listtest2;
        test.week2TemplateThursdayList = listtest2;
        test.week2TemplateFridayList = listtest2;
        test.week2TemplateSaturdayList = listtest2;
        test.week2TemplateSundayList = listtest2;
        
        test.week3TemplateMondayList = listtest;
        test.week3TemplateTuesdayList = listtest;
        test.week3TemplateWednesdayList = listtest;
        test.week3TemplateThursdayList = listtest;
        test.week3TemplateFridayList = listtest;
        test.week3TemplateSaturdayList = listtest;
        test.week3TemplateSundayList = listtest;
        
        test.week4TemplateMondayList = listtest2;
        test.week4TemplateTuesdayList = listtest2;
        test.week4TemplateWednesdayList = listtest2;
        test.week4TemplateThursdayList = listtest2;
        test.week4TemplateFridayList = listtest2;
        test.week4TemplateSaturdayList = listtest2;
        test.week4TemplateSundayList = listtest2;
        
        return test;
        
     }
  //Values present only in week 1 and week 4
    static availabilityWrapper createData6(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest2;
        test.week2TemplateTuesdayList = listtest2;
        test.week2TemplateWednesdayList = listtest2;
        test.week2TemplateThursdayList = listtest2;
        test.week2TemplateFridayList = listtest2;
        test.week2TemplateSaturdayList = listtest2;
        test.week2TemplateSundayList = listtest2;
        
        test.week3TemplateMondayList = listtest2;
        test.week3TemplateTuesdayList = listtest2;
        test.week3TemplateWednesdayList = listtest2;
        test.week3TemplateThursdayList = listtest2;
        test.week3TemplateFridayList = listtest2;
        test.week3TemplateSaturdayList = listtest2;
        test.week3TemplateSundayList = listtest2;
        
        test.week4TemplateMondayList = listtest;
        test.week4TemplateTuesdayList = listtest;
        test.week4TemplateWednesdayList = listtest;
        test.week4TemplateThursdayList = listtest;
        test.week4TemplateFridayList = listtest;
        test.week4TemplateSaturdayList = listtest;
        test.week4TemplateSundayList = listtest;
        
        return test;
        
     }
  //Values present  in week 1,week 3 and week 4
    static availabilityWrapper createData7(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest2;
        test.week2TemplateTuesdayList = listtest2;
        test.week2TemplateWednesdayList = listtest2;
        test.week2TemplateThursdayList = listtest2;
        test.week2TemplateFridayList = listtest2;
        test.week2TemplateSaturdayList = listtest2;
        test.week2TemplateSundayList = listtest2;
        
        test.week3TemplateMondayList = listtest;
        test.week3TemplateTuesdayList = listtest;
        test.week3TemplateWednesdayList = listtest;
        test.week3TemplateThursdayList = listtest;
        test.week3TemplateFridayList = listtest;
        test.week3TemplateSaturdayList = listtest;
        test.week3TemplateSundayList = listtest;
        
        test.week4TemplateMondayList = listtest;
        test.week4TemplateTuesdayList = listtest;
        test.week4TemplateWednesdayList = listtest;
        test.week4TemplateThursdayList = listtest;
        test.week4TemplateFridayList = listtest;
        test.week4TemplateSaturdayList = listtest;
        test.week4TemplateSundayList = listtest;
        
        return test;
        
     }
    //Values present  in week 1,week 2 and week 4 
    static availabilityWrapper createData8(){
        availabilityWrapper test = new availabilityWrapper();
        
        List<availabilityWrapper.weekTemplateWrapper> listtest = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins = new availabilityWrapper.weekTemplateWrapper();
        tesins.appointments = 2;
        tesins.type = 'Sales';
        tesins.startTime = startTime;
        tesins.endTime = endTime;
        listtest.add(tesins);
        
        List<availabilityWrapper.weekTemplateWrapper> listtest2 = new List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapper.weekTemplateWrapper tesins2 = new availabilityWrapper.weekTemplateWrapper();
        listtest2.add(tesins2);
        
        
        test.weekTemplateMondayList = listtest;
        test.weekTemplateTuesdayList = listtest2;
        test.weekTemplateWednesdayList = listtest;
        test.weekTemplateThursdayList = listtest;
        test.weekTemplateFridayList = listtest;
        test.weekTemplateSaturdayList = listtest;
        test.weekTemplateSundayList = listtest;
        
        test.week2TemplateMondayList = listtest;
        test.week2TemplateTuesdayList = listtest;
        test.week2TemplateWednesdayList = listtest;
        test.week2TemplateThursdayList = listtest;
        test.week2TemplateFridayList = listtest;
        test.week2TemplateSaturdayList = listtest;
        test.week2TemplateSundayList = listtest;
        
        test.week3TemplateMondayList = listtest2;
        test.week3TemplateTuesdayList = listtest2;
        test.week3TemplateWednesdayList = listtest2;
        test.week3TemplateThursdayList = listtest2;
        test.week3TemplateFridayList = listtest2;
        test.week3TemplateSaturdayList = listtest2;
        test.week3TemplateSundayList = listtest2;
        
        test.week4TemplateMondayList = listtest;
        test.week4TemplateTuesdayList = listtest;
        test.week4TemplateWednesdayList = listtest;
        test.week4TemplateThursdayList = listtest;
        test.week4TemplateFridayList = listtest;
        test.week4TemplateSaturdayList = listtest;
        test.week4TemplateSundayList = listtest;
        
        return test;
        
     }
  
    static testmethod void testmethod1(){
        createData(); 
        ext.availabilityWrapIns = createData1();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        ext.mondayCheck = true;
        ext.tuesdayCheck = true;
        ext.wednesdayCheck = true;
        ext.thursdayCheck = true;
        ext.fridayCheck = true;
        ext.saturdayCheck = true;
        ext.sundayCheck = true;
        ext.startTime = time.newInstance(8,0,0,0);
        ext.endTime = time.newInstance(14,0,0,0);
        ext.slotDurationHour = 1 ;
        ext.slotDurationMin =0;
        ext.lunchDurationHour =0;
        ext.clickGenerate();
        System.debug('============1'+ApexPages.getMessages());         
    }  

     static testmethod void testmethod2(){
        createData();  
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData4();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        ext.startTime = null;
        ext.endTime = null;
        ext.slotDurationHour = 0;
        ext.slotDurationMin =0;
        ext.lunchDurationHour =0;
        ext.clickGenerate();
        System.debug('============2'+ApexPages.getMessages());         
    }  
 
    static testmethod void testmethod3(){
        createData();
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData5();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
         ext.mondayCheck = false;
        ext.tuesdayCheck = false;
        ext.wednesdayCheck = false;
        ext.thursdayCheck = false;
        ext.fridayCheck = false;
        ext.saturdayCheck = false;
        ext.sundayCheck = false;
        ext.startTime = time.newInstance(8,0,0,0);
        ext.endTime = time.newInstance(14,0,0,0);
        ext.slotDurationHour = 1;
        ext.slotDurationMin =0;
        ext.lunchDurationHour =0;
        ext.clickGenerate();
        System.debug('============3'+ApexPages.getMessages());         
    }  
    
       static testmethod void testmethod4(){
        createData();  
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData6();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============4'+ApexPages.getMessages());         
    } 
    
    static testmethod void testmethod5(){
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData3();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============5'+ApexPages.getMessages());         
    } 
    
static testmethod void testmethod6(){
        createData();
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData7();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============6'+ApexPages.getMessages());         
    }     
    
    static testmethod void testmethod7(){
        createData();
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData8();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============7'+ApexPages.getMessages());         
    }     
    
     static testmethod void testmethod8(){
        createData(); 
        shiTemp.Week_2__c=false;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData8();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============8'+ApexPages.getMessages());         
    }   
    
    static testmethod void testmethod9(){
        createData(); 
        shiTemp.Week_2__c=false;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData4();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============8'+ApexPages.getMessages());         
    }   
    
     static testmethod void testmethod10(){
        System.debug('Inside method 10');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
        System.debug('============8'+ApexPages.getMessages());         
    }   
    
  static testmethod void testmethod11(){
        System.debug('Inside method 11');
        createData(); 
        shiTemp.Week_2__c=false;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData3();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    }  
 
      static testmethod void testmethod12(){
        System.debug('Inside method 12');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=false;
        ext.availabilityWrapIns = createData4();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
      
        static testmethod void testmethod13(){
        System.debug('Inside method 13');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=false;
        ext.availabilityWrapIns = createData7();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
   
     static testmethod void testmethod14(){
        System.debug('Inside method 14');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=false;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData3();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
    static testmethod void testmethod15(){
        System.debug('Inside method 15');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=false;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData7();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
    
      static testmethod void testmethod16(){
        System.debug('Inside method 16');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=false;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData5();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    }
    
    static testmethod void testmethod17(){
        System.debug('Inside method 17');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=false;
        ext.availabilityWrapIns = createData6();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
    
    static testmethod void testmethod18(){
        System.debug('Inside method 18');
        createData(); 
        shiTemp.Week_2__c=false;
        shiTemp.Week_3__c=false;
        shiTemp.Week_4__c=true;
        ext.availabilityWrapIns = createData3();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
    
    static testmethod void testmethod19(){
        System.debug('Inside method 19');
        createData(); 
        shiTemp.Week_2__c=true;
        shiTemp.Week_3__c=false;
        shiTemp.Week_4__c=false;
        ext.availabilityWrapIns = createData2();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
    
    static testmethod void testmethod20(){
        System.debug('Inside method 20');
        createData(); 
        shiTemp.Week_2__c=false;
        shiTemp.Week_3__c=true;
        shiTemp.Week_4__c=false;
        ext.availabilityWrapIns = createData2();
        ext.saveAvailability();
        ext.populateWeekRecordsAvailable();
        ext.doNothing();
        ext.displayWeek1();
        ext.displayWeek2();
        ext.displayWeek3();
        ext.displayWeek4();
                 
    } 
}