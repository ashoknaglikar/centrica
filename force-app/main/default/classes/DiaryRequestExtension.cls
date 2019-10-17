public with sharing class DiaryRequestExtension 
{
            public boolean recordTypeSection{get;set;}
            public boolean availabilitySection{get;set;}
            public Diary_Change__c deReq{get;set;}
            public Diary_Change_Request__c week1Details{get;set;}
            public Diary_Change_Request__c week2Details{get;set;}
            public Diary_Change_Request__c week3Details{get;set;}
            public Diary_Change_Request__c week4Details{get;set;}
            public boolean week1{get;set;}
            public boolean week2{get;set;}
            public boolean week3{get;set;}
            public boolean week4{get;set;}
            public boolean recGeo{get;set;}
            public boolean recAvail{get;set;}
            public boolean recUnavail{get;set;}
            public boolean recAvailGeo{get;set;} 
            public list<selectOption> AnyTimeApptTypes{get;set;}
            public list<selectOption> twoHrApptTypes{get;set;}
            public list<selectOption> masterPicklist2{get;set;}
            public list<selectOption> masterPicklist3{get;set;}
            public list<selectOption> masterPicklist4{get;set;}
            public string masterPicklistSelected2{get;set;}
            public string masterPicklistSelected3{get;set;}
            public string masterPicklistSelected4{get;set;}
            private ApexPages.StandardController controller{get;set;}
            
            public list<selectOption> districtList{get;set;}
            public list<selectOption> subpatchDetails{get;set;}
            public string selectedDist {get;set;}
            public boolean isClone{get;set;}
            list<Diary_Change_Request__c> insertList = new list<Diary_Change_Request__c>();
            
            list<list<Selectoption>> RoleVlaues1 = new list<list<Selectoption>>();
            list<list<Selectoption>> RoleVlaues2 = new list<list<Selectoption>>();
            list<list<Selectoption>> RoleVlaues3 = new list<list<Selectoption>>();
            list<list<Selectoption>> RoleVlaues4 = new list<list<Selectoption>>();
            Utilities util = new Utilities();
            
             String strIsClone='';
             public String diaryChangeIDString{get;set;}
            
            
           
            //week1 Variables
            public list<selectOption> monAMWeek1{get;set;}
            //public list<selectOption> monPMWeek1{get;set;}
            public list<selectOption> tueAMWeek1{get;set;}
            //public list<selectOption> tuePMWeek1{get;set;}
            public list<selectOption> wedAMWeek1{get;set;}
           // public list<selectOption> wedPMWeek1{get;set;}
            public list<selectOption> thuAMWeek1{get;set;}
            //public list<selectOption> thuPMWeek1{get;set;}
            public list<selectOption> friAMWeek1{get;set;}
           // public list<selectOption> friPMWeek1{get;set;}
            public list<selectOption> satAMWeek1{get;set;}
           // public list<selectOption> satPMWeek1{get;set;}
            public list<selectOption> sunAMWeek1{get;set;}
           // public list<selectOption> sunPMWeek1{get;set;}
            
            
            
            //Week 2 Varibales
            
            public list<selectOption> monAMWeek2{get;set;}
           // public list<selectOption> monPMWeek2{get;set;}
            public list<selectOption> tueAMWeek2{get;set;}
           // public list<selectOption> tuePMWeek2{get;set;}
            public list<selectOption> wedAMWeek2{get;set;}
          //  public list<selectOption> wedPMWeek2{get;set;}
            public list<selectOption> thuAMWeek2{get;set;}
          //  public list<selectOption> thuPMWeek2{get;set;}
            public list<selectOption> friAMWeek2{get;set;}
          //  public list<selectOption> friPMWeek2{get;set;}
            public list<selectOption> satAMWeek2{get;set;}
         //   public list<selectOption> satPMWeek2{get;set;}
            public list<selectOption> sunAMWeek2{get;set;}
         //   public list<selectOption> sunPMWeek2{get;set;}
            
            
            // Week 3 Variable
            
            public list<selectOption> monAMWeek3{get;set;}
         //   public list<selectOption> monPMWeek3{get;set;}
            public list<selectOption> tueAMWeek3{get;set;}
         //   public list<selectOption> tuePMWeek3{get;set;}
            public list<selectOption> wedAMWeek3{get;set;}
         //   public list<selectOption> wedPMWeek3{get;set;}
            public list<selectOption> thuAMWeek3{get;set;}
         //   public list<selectOption> thuPMWeek3{get;set;}
            public list<selectOption> friAMWeek3{get;set;}
        //    public list<selectOption> friPMWeek3{get;set;}
            public list<selectOption> satAMWeek3{get;set;}
         //   public list<selectOption> satPMWeek3{get;set;}
            public list<selectOption> sunAMWeek3{get;set;}
        //    public list<selectOption> sunPMWeek3{get;set;}
            
            
            // Week 4 Variables
            
            public list<selectOption> monAMWeek4{get;set;}
         //   public list<selectOption> monPMWeek4{get;set;}
            public list<selectOption> tueAMWeek4{get;set;}
         //   public list<selectOption> tuePMWeek4{get;set;}
            public list<selectOption> wedAMWeek4{get;set;}
         //   public list<selectOption> wedPMWeek4{get;set;}
            public list<selectOption> thuAMWeek4{get;set;}
         //   public list<selectOption> thuPMWeek4{get;set;}
            public list<selectOption> friAMWeek4{get;set;}
        //    public list<selectOption> friPMWeek4{get;set;}
            public list<selectOption> satAMWeek4{get;set;}
         //   public list<selectOption> satPMWeek4{get;set;}
            public list<selectOption> sunAMWeek4{get;set;}
         //   public list<selectOption> sunPMWeek4{get;set;}
        
            
            boolean copy2  = false, copy3  = false, copy4 = false;
        //keerthi    
        public Shift_template__c shiftTemplate { get; set; } 
        //Keerthi
        public list<string> labelList {get;set;}
        
        list<string> normalSlot = new list<string>{'AM ( 07:00 – 13:00 )', 'PM ( 13:30 – 17:00 )', 'EV ( 17:30 – 19:30 )', 'Any ( 07:00 – 21:00 )', '7:00 - 9:00',
                                                        '9:00 - 11:00', '11:00 - 13:00', '13:00 - 15:30', '15:30 - 17:30', '17:30 - 19:00', '19:00 - 20:30', 'Don\'t Use', 'Don\'t Use',
                                                        'Don\'t Use','Don\'t Use','Don\'t Use'  };
        list<string> stringhtSwap = new list<string>{'09:00 - 09:40', '09:40 - 10:20', '10:20 - 11:00', '11:00 - 11:40', '11:40 - 12:20',
                                                    '12:20 - 13:00', '13:00 - 13:40', '13:40 - 14:20', '14:20 - 15:00', '15:00 - 15:40', '15:40 - 16:20', '16:20 - 17:00',
                                                    '17:00 - 17:40', ' 17:40 - 18:20', '18:20 - 19:00', '19:00 - 19:40'            };                                            
            
                    
        public DiaryRequestExtension(ApexPages.StandardController controller)
        { 
            
            //Keerthi
            shiftTemplate = new Shift_template__c ();
            //Keerthi
            system.debug('entering in constructor');
            deReq = (Diary_Change__c)controller.getrecord();
            
            system.debug('@@@@deReq'+deReq);
            
            recordTypeSection = true;
            instantiateValues(); 
            
            districtList.add(new selectOption('','-- None --'));
            for(District__c d: [Select id , name,Code__c from District__c where Type__c = 'Sales' order by Code__c])
            {
                districtList.add(new selectOption(d.Id,d.Name+' '+ d.Code__c));
            }
            
            Schema.DescribeFieldResult fieldResult = Diary_Change__c.Appointment_Types__c.getDescribe();
            for(Schema.PicklistEntry s: fieldResult.getPicklistValues()){
                if(s.getLabel().equals('Sales')){
                    masterPicklist2.add(new selectOption(s.getLabel(),s.getValue()));
                    masterPicklist3.add(new selectOption(s.getLabel(),s.getValue()));
                    masterPicklist4.add(new selectOption(s.getLabel(),s.getValue()));
                }
            }
            for(Schema.PicklistEntry s: fieldResult.getPicklistValues()){
                if(!s.getLabel().equals('Sales')){
                    masterPicklist2.add(new selectOption(s.getLabel(),s.getValue()));
                    masterPicklist3.add(new selectOption(s.getLabel(),s.getValue()));
                    masterPicklist4.add(new selectOption(s.getLabel(),s.getValue()));
                }
            }
            
            Schema.DescribeFieldResult fieldResult1 = Diary_Change__c.Any_Time_Appointment_Types__c.getDescribe();
            for(Schema.PicklistEntry s: fieldResult1.getPicklistValues()){
                if(s.getLabel().equals('Sales'))
                AnyTimeApptTypes.add(new selectOption(s.getLabel(),s.getValue()));
            }
            for(Schema.PicklistEntry s: fieldResult.getPicklistValues()){
                if(!s.getLabel().equals('Sales'))
                AnyTimeApptTypes.add(new selectOption(s.getLabel(),s.getValue()));
            }

            Schema.DescribeFieldResult fieldResult2 = Diary_Change__c.Two_Hour_Slots_Appointment_Types__c.getDescribe();
            for(Schema.PicklistEntry s: fieldResult2.getPicklistValues()){
                if(s.getLabel().equals('Sales'))
                twoHrApptTypes.add(new selectOption(s.getLabel(),s.getValue()));
            }
            for(Schema.PicklistEntry s: fieldResult2.getPicklistValues()){
                if(!s.getLabel().equals('Sales'))
                twoHrApptTypes.add(new selectOption(s.getLabel(),s.getValue()));
            }
            
            if(isClone != null && isClone == true){
                cloneObjects(); 
            }
        }
        
        public void cloneObjects(){
             deReq = [SELECT Employee__c,RecordTypeId,Appointment_Types__c,District__c,Employee_Group__c,EndDT__c,StartDT__c,Start__c,End__c,No_Of_Weeks__c,Week_1__c, Week_2__c, Week_3__c, Week_4__c,
                                                Unavailability_Notes__c,Unavailability_Reason__c,Subject__c ,Request_Type__c,Status__c,Sub_Status__c, Cycle__c, Team__c FROM Diary_Change__c where id =: diaryChangeIDString];
                
                list<Diary_Change_Request__c> weekDetails = [Select d.Mon_AM_RoleWK1__c,d.Mon_PM_RoleWK1__c,d.Tue_AM_RoleWK1__c,d.Tue_PM_RoleWK1__c,d.Week_Number__c,d.Wed_AM_RoleWK1__c,d.Wed_PM_RoleWK1__c, 
                            d.Wed_PM_ApptWk1__c, d.Wed_Non_Op_PM_ApptWK1__c, d.Wed_Non_Op_Any_ApptWK1__c, d.Wed_Non_Op_AM_ApptWK1__c, 
                            d.Wed_GD_PMWK1__c, d.Wed_GD_AMWK1__c, d.Wed_EV_ApptWK1__c, d.Wed_Any_ApptWk1__c, d.Wed_AM_ApptWk1__c, d.Wed_19_20WK1__c, 
                            d.Wed_17_19WK1__c, d.Wed_15_17WK1__c, d.Wed_13_15WK1__c, d.Wed_11_13WK1__c, d.Wed_09_11WK1__c, d.Wed_07_09WK1__c, 
                            d.Tue_PM_ApptWk1__c, d.Tue_Non_Op_PM_ApptWK1__c, d.Tue_Non_Op_Any_ApptWK1__c, d.Tue_Non_Op_AM_ApptWK1__c, d.Tue_GD_PMWK1__c,
                            d.Tue_GD_AMWK1__c, d.Tue_EV_ApptWK1__c, d.Tue_Any_ApptWK1__c, d.Tue_AM_ApptWk1__c, d.Tue_19_20WK1__c, d.Tue_17_19WK1__c, d.Tue_15_17WK1__c,
                            d.Tue_13_15WK1__c, d.Tue_11_13WK1__c, d.Tue_09_11WK1__c, d.Tue_07_09WK1__c, d.Thu_PM_ApptWk1__c, d.Thu_Non_Op_PM_ApptWK1__c, d.Thu_Non_Op_Any_ApptWK1__c, 
                            d.Thu_Non_Op_AM_ApptWK1__c, d.Thu_GD_PMWK1__c, d.Thu_GD_AMWK1__c, d.Thu_EV_ApptWK1__c, d.Thu_Any_ApptWk1__c, d.Thu_AM_RoleWK1__c,d.Thu_PM_RoleWK1__c, d.Thu_AM_ApptWk1__c,
                            d.Thu_19_20WK1__c, d.Thu_17_19WK1__c, d.Thu_15_17WK1__c, d.Thu_13_15WK1__c, d.Thu_11_13WK1__c, d.Thu_09_11WK1__c, d.Thu_07_09WK1__c, d.Sun_PM_ApptWk1__c,
                            d.Sun_Non_Op_PM_ApptWK1__c, d.Sun_Non_Op_Any_ApptWK1__c, d.Sun_Non_Op_AM_ApptWK1__c, d.Sun_GD_PMWK1__c, d.Sun_GD_AMWK1__c, d.Sun_EV_ApptWK1__c, d.Sun_Any_ApptWk1__c,
                            d.Fri_AM_RoleWK1__c,d.Fri_PM_RoleWK1__c,d.Sun_AM_RoleWK1__c,d.Sun_PM_RoleWK1__c, d.Sun_AM_ApptWk1__c, d.Sun_19_20WK1__c, d.Sun_17_19WK1__c, d.Sun_15_17WK1__c, d.Sun_13_15WK1__c, d.Sun_11_13WK1__c, d.Sun_09_11WK1__c, d.Sun_07_09WK1__c,
                            d.Sat_PM_RoleWK1__c, d.Sat_PM_ApptWk1__c, d.Sat_Non_Op_PM_ApptWK1__c, d.Sat_Non_Op_Any_ApptWK1__c, d.Sat_Non_Op_AM_ApptWK1__c, d.Sat_GD_PMWK1__c, d.Sat_GD_AMWK1__c, 
                            d.Sat_EV_ApptWK1__c, d.Sat_Any_ApptWk1__c, d.Sat_AM_RoleWK1__c, d.Sat_AM_ApptWk1__c, d.Sat_19_20WK1__c, d.Sat_17_19WK1__c, d.Sat_15_17WK1__c, d.Sat_13_15WK1__c, 
                            d.Sat_11_13WK1__c, d.Sat_09_11WK1__c, d.Sat_07_09WK1__c, d.Mon_PM_ApptWk1__c, d.Mon_Non_Op_PM_ApptWK1__c, d.Mon_Non_Op_Any_ApptWK1__c, 
                            d.Mon_Non_Op_AM_ApptWK1__c, d.Mon_GD_PMWK1__c, d.Mon_GD_AMWK1__c, d.Mon_EV_ApptWK1__c, d.Mon_Any_ApptWK1__c, d.Mon_AM_ApptWk1__c, d.Mon_19_20WK1__c, 
                            d.Mon_17_19WK1__c, d.Mon_15_17WK1__c, d.Mon_13_15WK1__c, d.Mon_11_13WK1__c, d.Mon_09_11WK1__c, d.Mon_07_09WK1__c, d.Fri_PM_ApptWk1__c, d.Fri_Non_Op_PM_ApptWK1__c,
                            d.Fri_Non_Op_Any_ApptWK1__c, d.Fri_Non_Op_AM_ApptWK1__c, d.Fri_GD_PMWK1__c, d.Fri_GD_AMWK1__c, d.Fri_EV_ApptWK1__c, d.Fri_Any_ApptWk1__c, d.Fri_AM_ApptWk1__c, 
                            d.Fri_19_20WK1__c, d.Fri_17_19WK1__c, d.Fri_15_17WK1__c, d.Fri_13_15WK1__c, d.Fri_11_13WK1__c, d.Fri_09_11WK1__c, d.Fri_07_09WK1__c,
                            d.Mon_AM_Appt_Type__c,d.Tue_AM_Appt_Type__c,d.Wed_AM_Appt_Type__c,d.Thu_AM_Appt_Type__c,d.Fri_AM_Appt_Type__c,d.Sat_AM_Appt_Type__c,d.Sun_AM_Appt_Type__c,
                            d.Mon_PM_Appt_Type__c,d.Tue_PM_Appt_Type__c,d.Wed_PM_Appt_Type__c,d.Thu_PM_Appt_Type__c,d.Fri_PM_Appt_Type__c,d.Sat_PM_Appt_Type__c,d.Sun_PM_Appt_Type__c,
                            d.Mon_EV_Appt_Type__c,d.Tue_EV_Appt_Type__c,d.Wed_EV_Appt_Type__c,d.Thu_EV_Appt_Type__c,d.Fri_EV_Appt_Type__c,d.Sat_EV_Appt_Type__c,d.Sun_EV_Appt_Type__c,
                            d.Mon_Any_Appt_Type__c,d.Tue_Any_Appt_Type__c,d.Wed_Any_Appt_Type__c,d.Thu_Any_Appt_Type__c,d.Fri_Any_Appt_Type__c,d.Sat_Any_Appt_Type__c,d.Sun_Any_Appt_Type__c,
                            d.Mon_7_00_to_9_00_Appt_Type__c,d.Tue_7_00_to_9_00_Appt_Type__c,d.Wed_7_00_to_9_00_Appt_Type__c,d.Thu_7_00_to_9_00_Appt_Type__c,d.Fri_7_00_to_9_00_Appt_Type__c,d.Sat_7_00_to_9_00_Appt_Type__c,d.Sun_7_00_to_9_00_Appt_Type__c,
                            d.Mon_9_00_to_11_00_Appt_Type__c,d.Tue_9_00_to_11_00_Appt_Type__c,d.Wed_9_00_to_11_00_Appt_Type__c,d.Thu_9_00_to_11_00_Appt_Type__c,d.Fri_9_00_to_11_00_Appt_Type__c,d.Sat_9_00_to_11_00_Appt_Type__c,d.Sun_9_00_to_11_00_Appt_Type__c,
                            d.Mon_11_00_to_13_00_Appt_Type__c,d.Tue_11_00_to_13_00_Appt_Type__c,d.Wed_11_00_to_13_00_Appt_Type__c,d.Thu_11_00_to_13_00_Appt_Type__c,d.Fri_11_00_to_13_00_Appt_Type__c,d.Sat_11_00_to_13_00_Appt_Type__c,d.Sun_11_00_to_13_00_Appt_Type__c,
                            d.Mon_13_00_to_15_30_Appt_Type__c,d.Tue_13_00_to_15_30_Appt_Type__c,d.Wed_13_00_to_15_30_Appt_Type__c,d.Thu_13_00_to_15_30_Appt_Type__c,d.Fri_13_00_to_15_30_Appt_Type__c,d.Sat_13_00_to_15_30_Appt_Type__c,d.Sun_13_00_to_15_30_Appt_Type__c,
                            d.Mon_15_30_to_17_30_Appt_Type__c,d.Tue_15_30_to_17_30_Appt_Type__c,d.Wed_15_30_to_17_30_Appt_Type__c,d.Thu_15_30_to_17_30_Appt_Type__c,d.Fri_15_30_to_17_30_Appt_Type__c,d.Sat_15_30_to_17_30_Appt_Type__c,d.Sun_15_30_to_17_30_Appt_Type__c,
                            d.Mon_17_30_to_19_00_Appt_Type__c,d.Tue_17_30_to_19_00_Appt_Type__c,d.Wed_17_30_to_19_00_Appt_Type__c,d.Thu_17_30_to_19_00_Appt_Type__c,d.Fri_17_30_to_19_00_Appt_Type__c,d.Sat_17_30_to_19_00_Appt_Type__c,d.Sun_17_30_to_19_00_Appt_Type__c,
                            d.Mon_19_00_to_20_30_Appt_Type__c,d.Tue_19_00_to_20_30_Appt_Type__c,d.Wed_19_00_to_20_30_Appt_Type__c,d.Thu_19_00_to_20_30_Appt_Type__c,d.Fri_19_00_to_20_30_Appt_Type__c,d.Sat_19_00_to_20_30_Appt_Type__c,d.Sun_19_00_to_20_30_Appt_Type__c,
                            d.Mon_09_00_09_40__c,d.Mon_09_40_10_20__c,d.Mon_10_20_11_00__c,d.Mon_11_00_11_40__c,d.Mon_11_40_12_20__c,d.Mon_12_20_13_00__c,d.Mon_13_00_13_40__c,
                            d.Mon_13_40_14_20__c,d.Mon_14_20_15_00__c,d.Mon_15_00_15_40__c,d.Mon_15_40_16_20__c,d.Mon_16_20_17_00__c,d.Mon_17_00_17_40__c,d.Mon_17_40_18_20__c,
                            d.Mon_18_20_19_00__c,d.Mon_19_00_19_40__c,d.Tue_09_00_09_40__c,d.Tue_09_40_10_20__c,d.Tue_10_20_11_00__c,d.Tue_11_00_11_40__c,d.Tue_11_40_12_20__c,
                            d.Tue_12_20_13_00__c,d.Tue_13_00_13_40__c,d.Tue_13_40_14_20__c,d.Tue_14_20_15_00__c,d.Tue_15_00_15_40__c,d.Tue_15_40_16_20__c,d.Tue_16_20_17_00__c,
                            d.Tue_17_00_17_40__c,d.Tue_17_40_18_20__c,d.Tue_18_20_19_00__c,d.Tue_19_00_19_40__c,d.Wed_09_00_09_40__c,d.Wed_09_40_10_20__c,d.Wed_10_20_11_00__c,
                            d.Wed_11_00_11_40__c,d.Wed_11_40_12_20__c,d.Wed_12_20_13_00__c,d.Wed_13_00_13_40__c,d.Wed_13_40_14_20__c,d.Wed_14_20_15_00__c,d.Wed_15_00_15_40__c,
                            d.Wed_15_40_16_20__c,d.Wed_16_20_17_00__c,d.Wed_17_00_17_40__c,d.Wed_17_40_18_20__c,d.Wed_18_20_19_00__c,d.Wed_19_00_19_40__c,d.Thu_09_00_09_40__c,
                            d.Thu_09_40_10_20__c,d.Thu_10_20_11_00__c,d.Thu_11_00_11_40__c,d.Thu_11_40_12_20__c,d.Thu_12_20_13_00__c,d.Thu_13_00_13_40__c,d.Thu_13_40_14_20__c,
                            d.Thu_14_20_15_00__c,d.Thu_15_00_15_40__c,d.Thu_15_40_16_20__c,d.Thurs_16_20_17_00__c,d.Thurs_17_00_17_40__c,d.Thurs_17_40_18_20__c,d.Thurs_18_20_19_00__c,
                            d.Thurs_19_00_19_40__c,d.Fri_09_00_09_40__c,d.Fri_09_40_10_20__c,d.Fri_10_20_11_00__c,d.Fri_11_00_11_40__c,d.Fri_11_40_12_20__c,d.Fri_12_20_13_00__c,d.Fri_13_00_13_40__c,
                            d.Fri_13_40_14_20__c,d.Fri_14_20_15_00__c,d.Fri_15_00_15_40__c,d.Fri_15_40_16_20__c,d.Fri_16_20_17_00__c,d.Fri_17_00_17_40__c,d.Fri_17_40_18_20__c,d.Fri_18_20_19_00__c,
                            d.Fri_19_00_19_40__c,d.Sat_09_00_09_40__c,d.Sat_09_40_10_20__c,d.Sat_10_20_11_00__c,d.Sat_11_00_11_40__c,d.Sat_11_40_12_20__c,d.Sat_12_20_13_00__c,d.Sat_13_00_13_40__c,
                            d.Sat_13_40_14_20__c,d.Sat_14_20_15_00__c,d.Sat_15_00_15_40__c,d.Sat_15_40_16_20__c,d.Sat_16_20_17_00__c,d.Sat_17_00_17_40__c,d.Sat_17_40_18_20__c,d.Sat_18_20_19_00__c,
                            d.Sat_19_00_19_40__c,d.Sun_09_00_09_40__c,d.Sun_09_40_10_20__c,d.Sun_10_20_11_00__c,d.Sun_11_00_11_40__c,d.Sun_11_40_12_20__c,d.Sun_12_20_13_00__c,d.Sun_13_00_13_40__c,
                            d.Sun_13_40_14_20__c,d.Sun_14_20_15_00__c,d.Sun_15_00_15_40__c,d.Sun_15_40_16_20__c,d.Sun_16_20_17_00__c,d.Sun_17_00_17_40__c,d.Sun_17_40_18_20__c,d.Sun_18_20_19_00__c,
                            d.Sun_19_00_19_40__c,d.Mon_09_00_09_40_App_Type__c,d.Mon_09_40_10_20_App_Type__c,d.Mon_10_20_11_00_App_Type__c,d.Mon_11_00_11_40_App_Type__c,d.Mon_11_40_12_20_App_Type__c,
                            d.Mon_12_20_13_00_App_Type__c,d.Mon_13_00_13_40_App_Type__c,d.Mon_13_40_14_20_App_Type__c,d.Mon_14_20_15_00_App_Type__c,d.Mon_15_00_15_40_App_Type__c,d.Mon_15_40_16_20_App_Type__c,
                            d.Mon_16_20_17_00_App_Type__c,d.Mon_17_00_17_40_Type__c,d.Mon_17_40_18_20_App_Type__c,d.Mon_18_20_19_00_App_Type__c,d.Mon_19_00_19_40_App_Type__c,d.Tue_09_00_09_40_App_Type__c,
                            d.Tue_09_40_10_20_App_Type__c,d.Tue_10_20_11_00_App_Type__c,d.Tue_11_00_11_40_App_Type__c,d.Tue_11_40_12_20_App_Type__c,d.Tue_12_20_13_00_App_Type__c,d.Tue_13_00_13_40_App_Type__c,
                            d.Tue_13_40_14_20_App_Type__c,d.Tue_14_20_15_00_App_Type__c,d.Tue_15_00_15_40_App_Type__c,d.Tue_15_40_16_20_App_Type__c,d.Tue_16_20_17_00_App_Type__c,d.Tue_17_00_17_40_App_Type__c,
                            d.Tue_17_40_18_20_App_Type__c,d.Tue_18_20_19_00_App_Type__c,d.Tue_19_00_19_40_App_Type__c,d.Wed_09_00_09_40_App_Type__c,d.Wed_09_40_10_20_App_Type__c,d.Wed_10_20_11_00_App_Type__c,
                            d.Wed_11_00_11_40_App_Type__c,d.Wed_11_40_12_20_App_Type__c,d.Wed_12_20_13_00_App_Type__c,d.Wed_13_00_13_40_App_Type__c,d.Wed_13_40_14_20_App_Type__c,d.Wed_14_20_15_00_App_Type__c,
                            d.Wed_15_00_15_40_App_Type__c,d.Wed_15_40_16_20_App_Type__c,d.Wed_16_20_17_00_App_Type__c,d.Wed_17_00_17_40_App_Type__c,d.Wed_17_40_18_20_App_Type__c,d.Wed_18_20_19_00_App_Type__c,d.Wed_19_00_19_40_App_Type__c,
                            d.Thu_09_00_09_40_App_Type__c,d.Thu_09_40_10_20_App_Type__c,d.Thu_10_20_11_00_App_Type__c,d.Thu_11_00_11_40_App_Type__c,d.Thu_11_40_12_20_App_Type__c,d.Thu_12_20_13_00_App_Type__c,
                            d.Thu_13_00_13_40_App_Type__c,d.Thu_13_40_14_20_App_Type__c,d.Thu_14_20_15_00_App_Type__c,d.Thu_15_00_15_40_App_Type__c,d.Thu_15_40_16_20_App_Type__c,d.Thurs_16_20_17_00_App_Type__c,
                            d.Thurs_17_00_17_40_App_Type__c,d.Thurs_17_40_18_20_App_Type__c,d.Thurs_18_20_19_00_App_Type__c,d.Thurs_19_00_19_40_App_Type__c,d.Fri_09_00_09_40_App_Type__c,d.Fri_09_40_10_20_App_Type__c,
                            d.Fri_10_20_11_00_App_Type__c,d.Fri_11_00_11_40_App_Type__c,d.Fri_11_40_12_20_App_Type__c,d.Fri_12_20_13_00_App_Type__c,d.Fri_13_00_13_40_App_Type__c,d.Fri_13_40_14_20_App_Type__c,d.Fri_14_20_15_00_App_Type__c,
                            d.Fri_15_00_15_40_App_Type__c,d.Fri_15_40_16_20_App_Type__c,d.Fri_16_20_17_00_App_Type__c,d.Fri_17_00_17_40_App_Type__c,d.Fri_17_40_18_20_App_Type__c,d.Fri_18_20_19_00_App_Type__c,d.Fri_19_00_19_40_App_Type__c,
                            d.Sat_09_00_09_40_App_Type__c,d.Sat_09_40_10_20_App_Type__c,d.Sat_10_20_11_00_App_Type__c,d.Sat_11_00_11_40_App_Type__c,d.Sat_11_40_12_20_App_Type__c,d.Sat_12_20_13_00_App_Type__c,d.Sat_13_00_13_40_App_Type__c,
                            d.Sat_13_40_14_20_App_Type__c,d.Sat_14_20_15_00_App_Type__c,d.Sat_15_00_15_40_App_Type__c,d.Sat_15_40_16_20_App_Type__c,d.Sat_16_20_17_00_App_Type__c,d.Sat_17_00_17_40_App_Type__c,d.Sat_17_40_18_20_App_Type__c,
                            d.Sat_18_20_19_00_App_Type__c,d.Sat_19_00_19_40_App_Type__c,d.Sun_09_00_09_40_App_Type__c,d.Sun_09_40_10_20_App_Type__c,d.Sun_10_20_11_00_App_Type__c,d.Sun_11_00_11_40_App_Type__c,d.Sun_11_40_12_20_App_Type__c,
                            d.Sun_12_20_13_00_App_Type__c,d.Sun_13_00_13_40_App_Type__c,d.Sun_13_40_14_20_App_Type__c,d.Sun_14_20_15_00_App_Type__c,d.Sun_15_00_15_40_App_Type__c,d.Sun_15_40_16_20_App_Type__c,d.Sun_16_20_17_00_App_Type__c,
                            d.Sun_17_00_17_40_App_Type__c,d.Sun_17_40_18_20_App_Type__c,d.Sun_18_20_19_00_App_Type__c,d.Sun_19_00_19_40_App_Type__c
                            From Diary_Change_Request__c d where Diary_Change_Master__c =: deReq.id order by Week_Number__c limit 4];
                
                System.debug('===CloneWeek====='+weekDetails);
                for(Diary_Change_Request__c d : weekDetails)
                if(d.Week_Number__c==1){
                    week1Details = d.clone(false);
                    }
                else if(d.Week_Number__c==2)
                    week2Details = d.clone(false);
                else if(d.Week_Number__c==3)
                    week3Details = d.clone(false);
                else if(d.Week_Number__c==4)
                    week4Details = d.clone(false);
                    
                    
               if(week1Details!=null){
                     list<list<selectOption>> ls = getSubpatchesForClone(week1Details);
                     System.debug('====size===='+ls.size());
                     if(ls!=null && ls.size()!=0){
                     monAMWeek1 = ls[0];
                     //monPMWeek1 = ls[1];
                     tueAMWeek1 = ls[2];
                    // tuePMWeek1 = ls[3];
                     wedAMWeek1 = ls[4];
                   //  wedPMWeek1 = ls[5];
                     thuAMWeek1 = ls[6];
                   //  thuPMWeek1 = ls[7];
                     friAMWeek1 = ls[8];
                    // friPMWeek1 = ls[9];
                     satAMWeek1 = ls[10];
                   //  satPMWeek1 = ls[11];
                     sunAMWeek1 = ls[12];
                   //  sunPMWeek1 = ls[13];
                     }
                        
                }
                
               if(week2Details!=null){
                     list<list<selectOption>> ls = getSubpatchesForClone(week2Details);
                     if(ls!=null && ls.size()!=0){
                     monAMWeek2 = ls[0];
                  //   monPMWeek2 = ls[1];
                     tueAMWeek2 = ls[2];
                    // tuePMWeek2 = ls[3];
                     wedAMWeek2 = ls[4];
                    // wedPMWeek2 = ls[5];
                     thuAMWeek2 = ls[6];
                   //  thuPMWeek2 = ls[7];
                     friAMWeek2 = ls[8];
                   //  friPMWeek2 = ls[9];
                     satAMWeek2 = ls[10];
                   //  satPMWeek2 = ls[11];
                     sunAMWeek2 = ls[12];
                   //  sunPMWeek2 = ls[13];
                     }      
                }
                
                if(week3Details!=null){
                     list<list<selectOption>> ls = getSubpatchesForClone(week3Details);
                      if(ls!=null && ls.size()!=0){
                     monAMWeek3 = ls[0];
                    // monPMWeek3 = ls[1];
                     tueAMWeek3 = ls[2];
                    // tuePMWeek3 = ls[3];
                     wedAMWeek3 = ls[4];
                    // wedPMWeek3 = ls[5];
                     thuAMWeek3 = ls[6];
                    // thuPMWeek3 = ls[7];
                     friAMWeek3 = ls[8];
                    // friPMWeek3 = ls[9];
                     satAMWeek3 = ls[10];
                    // satPMWeek3 = ls[11];
                     sunAMWeek3 = ls[12];
                    // sunPMWeek3 = ls[13];
                     }      
                }
                
                if(week4Details!=null){
                     list<list<selectOption>> ls = getSubpatchesForClone(week4Details);
                      if(ls!=null && ls.size()!=0){
                     monAMWeek4 = ls[0];
                   //  monPMWeek4 = ls[1];
                     tueAMWeek4 = ls[2];
                   ///  tuePMWeek4 = ls[3];
                     wedAMWeek4 = ls[4];
                   //  wedPMWeek4 = ls[5];
                     thuAMWeek4 = ls[6];
                   //  thuPMWeek4 = ls[7];
                     friAMWeek4 = ls[8];
                  //   friPMWeek4 = ls[9];
                     satAMWeek4 = ls[10];
                   //  satPMWeek4 = ls[11];
                     sunAMWeek4 = ls[12];
                   //  sunPMWeek4 = ls[13];
                     }
                        
                }
                
                selectedDist = deReq.District__c;
                continueMethod();  
                loadsubpatchDetails();     
        }
      
        
        public list<list<selectOption>> getSubpatchesForClone(Diary_Change_Request__c week){
            list<list<selectOption>> cloneSelectOptions = new list<list<selectOption>>();
            cloneSelectOptions.add(splitSubpatchString(week.Mon_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Mon_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Tue_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Tue_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Wed_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Wed_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Thu_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Thu_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Fri_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Fri_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Sat_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Sat_PM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Sun_AM_RoleWK1__c));
            cloneSelectOptions.add(splitSubpatchString(week.Sun_PM_RoleWK1__c));
            System.debug('=====cloneSelectOptions========='+cloneSelectOptions);

            return cloneSelectOptions;

        }
        
        private list<selectOption> splitSubpatchString(String str){
             list<selectOption> cloneSubpatch = new list<selectOption>();
             System.debug('=======debug====='+str);
             if(str!=null && str!='' && str.length()!=0){
             String[] splitStr = str.split(';');
             System.debug('=======debug====='+splitStr);
             for(String s : splitStr){
              SelectOption so = new SelectOption(s, s);
              cloneSubpatch.add(so);
             }
             }
             System.debug('======cloneSubpatch====='+cloneSubpatch);

             return cloneSubpatch;

        }
        
        public void loadsubpatchDetails()
        {
            system.debug('Selected Dist---->'+selectedDist);
            subpatchDetails = new list<selectOption>();
            if(selectedDist!=null)
            {
                for(Sub_Patch__c s: [select id, Name,Code__c from Sub_Patch__c where type__c = 'Sales' and District__c = :selectedDist order by code__c])
                {
                    subpatchDetails.add(new Selectoption(s.Id,  s.Code__c));
                }
                if(week1 == false)
                displayWeek1();
                displayWeek2();
                displayWeek3();
                displayWeek4();
            }   
        }
        
        public void PopulateAppointmentTypes(){}
        public void PopulateAppointmentTypes1(){
            if(deReq.Appointment_Types__c == 'Sales' || deReq.Appointment_Types__c == 'Priority')
            {
                week1Details.Mon_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;
              
                    
                week1Details.Tue_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Wed_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;

                week1Details.Thu_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;

                week1Details.Fri_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;

                week1Details.Sat_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;

                week1Details.Sun_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_Any_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_7_00_to_9_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_9_00_to_11_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_11_00_to_13_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_13_00_to_15_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_15_30_to_17_30_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_17_30_to_19_00_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_19_00_to_20_30_Appt_Type__c = deReq.Appointment_Types__c;
                
                // new straight swap
                week1Details.Mon_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_17_00_17_40_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Tue_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Wed_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Thu_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thurs_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thurs_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thurs_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thurs_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Thurs_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Fri_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Sat_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Sun_09_00_09_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_09_40_10_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_10_20_11_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_11_00_11_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_11_40_12_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_12_20_13_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_13_00_13_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_13_40_14_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_14_20_15_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_15_00_15_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_15_40_16_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_16_20_17_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_17_00_17_40_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_17_40_18_20_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_18_20_19_00_App_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_19_00_19_40_App_Type__c = deReq.Appointment_Types__c;
                

            }
            else if(deReq.Appointment_Types__c == 'Green Deal'){
                week1Details.Mon_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Mon_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Tue_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Tue_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Wed_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Wed_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Thu_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Thu_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Fri_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Fri_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Sat_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sat_Any_Appt_Type__c = deReq.Appointment_Types__c;
                
                week1Details.Sun_AM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_PM_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_EV_Appt_Type__c = deReq.Appointment_Types__c;
                week1Details.Sun_Any_Appt_Type__c = deReq.Appointment_Types__c;
            }
        
        }
        
        public void PopulateAppointmentTypes2(){
            if(masterPicklistSelected2 == 'Sales' || masterPicklistSelected2 == 'Priority')
            {
                week2Details.Mon_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Tue_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Wed_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;

                week2Details.Thu_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;

                week2Details.Fri_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;

                week2Details.Sat_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;

                week2Details.Sun_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_Any_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_7_00_to_9_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_9_00_to_11_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_11_00_to_13_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_13_00_to_15_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_15_30_to_17_30_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_17_30_to_19_00_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_19_00_to_20_30_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Mon_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_17_00_17_40_Type__c = masterPicklistSelected2;
                week2Details.Mon_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Mon_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Tue_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Tue_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Wed_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Wed_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Thu_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Thu_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Thurs_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Thurs_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Thurs_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Thurs_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Thurs_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Fri_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Fri_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Sat_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sat_19_00_19_40_App_Type__c = masterPicklistSelected2;
                
                week2Details.Sun_09_00_09_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_09_40_10_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_10_20_11_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_11_00_11_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_11_40_12_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_12_20_13_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_13_00_13_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_13_40_14_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_14_20_15_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_15_00_15_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_15_40_16_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_16_20_17_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_17_00_17_40_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_17_40_18_20_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_18_20_19_00_App_Type__c = masterPicklistSelected2;
                week2Details.Sun_19_00_19_40_App_Type__c = masterPicklistSelected2;

            }
            else if(masterPicklistSelected2 == 'Green Deal'){
                week2Details.Mon_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Mon_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Tue_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Tue_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Wed_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Wed_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Thu_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Thu_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Fri_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Fri_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Sat_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sat_Any_Appt_Type__c = masterPicklistSelected2;
                
                week2Details.Sun_AM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_PM_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_EV_Appt_Type__c = masterPicklistSelected2;
                week2Details.Sun_Any_Appt_Type__c = masterPicklistSelected2;
            }
        
        }


        
        public void PopulateAppointmentTypes3(){
            if(masterPicklistSelected3 == 'Sales' || masterPicklistSelected3 == 'Priority')
            {
                week3Details.Mon_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Tue_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Wed_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;

                week3Details.Thu_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;

                week3Details.Fri_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;

                week3Details.Sat_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;

                week3Details.Sun_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_Any_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_7_00_to_9_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_9_00_to_11_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_11_00_to_13_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_13_00_to_15_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_15_30_to_17_30_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_17_30_to_19_00_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_19_00_to_20_30_Appt_Type__c = masterPicklistSelected3;
                
                 week3Details.Mon_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_17_00_17_40_Type__c = masterPicklistSelected3;
                week3Details.Mon_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Mon_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Tue_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Tue_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Wed_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Wed_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Thu_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Thu_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Thurs_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Thurs_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Thurs_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Thurs_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Thurs_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Fri_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Fri_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Sat_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sat_19_00_19_40_App_Type__c = masterPicklistSelected3;
                
                week3Details.Sun_09_00_09_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_09_40_10_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_10_20_11_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_11_00_11_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_11_40_12_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_12_20_13_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_13_00_13_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_13_40_14_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_14_20_15_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_15_00_15_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_15_40_16_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_16_20_17_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_17_00_17_40_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_17_40_18_20_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_18_20_19_00_App_Type__c = masterPicklistSelected3;
                week3Details.Sun_19_00_19_40_App_Type__c = masterPicklistSelected3;

            }
            else if(masterPicklistSelected3 == 'Green Deal'){
                week3Details.Mon_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Mon_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Tue_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Tue_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Wed_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Wed_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Thu_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Thu_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Fri_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Fri_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Sat_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sat_Any_Appt_Type__c = masterPicklistSelected3;
                
                week3Details.Sun_AM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_PM_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_EV_Appt_Type__c = masterPicklistSelected3;
                week3Details.Sun_Any_Appt_Type__c = masterPicklistSelected3;
            }
        
        }



        
       public void PopulateAppointmentTypes4(){
            if(masterPicklistSelected4 == 'Sales' || masterPicklistSelected4 == 'Priority')
            {
                week4Details.Mon_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Tue_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Wed_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;

                week4Details.Thu_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;

                week4Details.Fri_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;

                week4Details.Sat_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;

                week4Details.Sun_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_Any_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_7_00_to_9_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_9_00_to_11_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_11_00_to_13_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_13_00_to_15_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_15_30_to_17_30_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_17_30_to_19_00_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_19_00_to_20_30_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Mon_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_17_00_17_40_Type__c = masterPicklistSelected4;
                week4Details.Mon_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Mon_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Tue_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Tue_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Wed_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Wed_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Thu_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Thu_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Thurs_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Thurs_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Thurs_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Thurs_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Thurs_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Fri_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Fri_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Sat_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sat_19_00_19_40_App_Type__c = masterPicklistSelected4;
                
                week4Details.Sun_09_00_09_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_09_40_10_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_10_20_11_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_11_00_11_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_11_40_12_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_12_20_13_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_13_00_13_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_13_40_14_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_14_20_15_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_15_00_15_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_15_40_16_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_16_20_17_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_17_00_17_40_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_17_40_18_20_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_18_20_19_00_App_Type__c = masterPicklistSelected4;
                week4Details.Sun_19_00_19_40_App_Type__c = masterPicklistSelected4;

            }
            else if(masterPicklistSelected4 == 'Green Deal'){
                week4Details.Mon_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Mon_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Tue_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Tue_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Wed_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Wed_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Thu_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Thu_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Fri_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Fri_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Sat_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sat_Any_Appt_Type__c = masterPicklistSelected4;
                
                week4Details.Sun_AM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_PM_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_EV_Appt_Type__c = masterPicklistSelected4;
                week4Details.Sun_Any_Appt_Type__c = masterPicklistSelected4;
            }
        
        }



        
        // sets boolean variables according to record type to render respective sections on page
        public void continueMethod()
        {
            if(isClone!=null){
                System.debug('=====isClone===='+isClone);
                if(isClone==true){
                    recordTypeSection = false;
                    availabilitySection = true;
                    //RecordType rec =  [Select Request_Type__c from Diary_Change__c where id=:deReq.id];
                    String recName = deReq.Request_Type__c;            
                    System.debug('===RequestType==='+recName);          
                     if(recName=='Appointment Change' )
                     {
                           resetValues();
                           recAvail = true;
                     }       
                     else if(recName=='Geography Change' )
                     { 
                            resetValues();
                           recGeo = true; 
                     }      
                     else if(recName=='Unavailability' )
                     { 
                            resetValues();
                            recUnavail = true;
                     }       
                     else if(recName=='Appointment & Geography Change' ) 
                     {
                            resetValues();
                            recAvailGeo = true;
                     }
                }
            }
            else{
                recordTypeSection = false;
                availabilitySection = true;   
                RecordType rec =  [Select Name from RecordType where id=:deReq.RecordTypeId];
                String recName = rec.Name;            
                System.debug('===RecordType==='+recName);          
                 if(recName=='Availability')
                 {
                       resetValues();
                       recAvail = true;
                 }       
                 else if(recName=='Geography')
                 { 
                        resetValues();
                       recGeo = true; 
                 }      
                 else if(recName=='Unavailability')
                 { 
                        resetValues();
                        recUnavail = true;
                 }       
                 else if(recName=='Availability & Geography') 
                 {
                        resetValues();
                        recAvailGeo = true;
                 }
             }
             System.debug('====booleans==='+recAvail + recGeo +recUnavail +recAvailGeo ); 
                            
        }
        
        public void resetValues()
        {
            recAvail = false;
            recGeo = false; 
            recUnavail = false;
            recAvailGeo = false;
        }
        
        public pageReference back()
        {
            
           if(isClone!=null){
               pageReference page;
               if(isClone==true){
                   //Id diaryId = (id) diaryChangeIDString;
                   page = new pagereference('/'+diaryChangeIDString); 
               }
               else{
                   page = null;
               }
               return page;
            }
            else{
                recordTypeSection = true;
                availabilitySection = false;
                recAvail=false;   
                recGeo=false;
                recAvailGeo=false;  
                recUnavail=false; 
                return null;
            }  
                   
        }
        
        public void displayWeek1()
        {
            //if(deReq.Week_1__c)
            week1 = true;
            //else
            //week1 = false;
            System.debug('====week1==='+week1);
            if(week1==false)
            loadsubpatchDetails();
        }

        public void displayWeek2()
        {
            if(deReq.Week_2__c)
            week2 = true;
            else
            week2=false;
            
        }
        
        public void displayWeek3()
        {
            if(deReq.Week_3__c)
            week3 = true;
            else
            week3=false;
            
        }
        
        public void displayWeek4()
        {
            if(deReq.Week_4__c)
            week4 = true;
            else
            week4=false;
            
        }
                         
        public pagereference saveAllDetails()
        {
              Savepoint  sp = database.setSavepoint();
              System.debug('======savePoint=====');
              try
              {
                  
                    if(checkAllvalidation())
                    {
                           System.debug('======checkAllvalidation=====');
                          deReq.Status__c = 'In Progress';
                          try{
                            if(deReq.id != null)
                            deReq.Id= null;
                            deReq.District__c = selectedDist;
                            System.debug('======beforeInsert=====');
                            insert deReq;
                            System.debug('======afterInsert=====');               
                          }catch (Exception e)
                          {
                            System.debug('======InnerCatch======');
                            string message = e.getmessage();
                            if(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                            message  = message.split(',')[1];
                            System.debug('========innserCatchError======'+message);
                            util.setErrorMsg(true, message);
                            return null;
                          }
             
                          System.debug('====week1Details===='+week1Details);
                          populateWeekRecords();                      
                          if(insertList.size()>0)
                          {
                            System.debug('======in2ndIf=====');
                            week1Details.Diary_Change_Master__c = deReq.Id;
                            week1Details.Week_Number__c = 1;
                            insert week1Details;
                            
                            if(deReq.Week_2__c!=null && deReq.Week_2__c)
                            {
                                if(week2Details.id !=null)
                                week2Details.Id = null;
                                week2Details.Diary_Change_Master__c = deReq.Id;
                                week2Details.Week_Number__c = 2;
                                insert week2Details;
                            }
                            
                            if(deReq.Week_3__c!=null && deReq.Week_3__c)
                            {
                                if(week3Details.id !=null)
                                week3Details.Id = null;
                                week3Details.Diary_Change_Master__c = deReq.Id;
                                week3Details.Week_Number__c = 3;
                                insert week3Details; 
                            }
                            
                            if(deReq.Week_4__c!=null && deReq.Week_4__c)
                            {
                                if(week4Details.id !=null)
                                week4Details.Id = null;
                                week4Details.Diary_Change_Master__c = deReq.Id;
                                week4Details.Week_Number__c = 4;                           
                                insert week4Details;
                            }
                          }
                          return new pagereference('/'+deReq.Id);
                    }
                    else
                    {
                      System.debug('======in2ndElse=====');
                      return null;  
                    }
              } 
              catch (exception e)
              {
                system.debug('Exception -->'+e);
                Database.rollback(sp);
                
                util.setErrorMsg(true, e.getmessage());
                return null;
              }
        } 
        
        public pagereference saveUnavailDetails(){
            Savepoint  sp = database.setSavepoint();
            try{
                if(deReq.Employee__c == null && deReq.Employee_Group__c == null)
                {
                    util.setErrorMsg(true, 'Please enter Employee details.');
                    return null;
                }else
                {
                deReq.id=null;
                insert deReq; 
                return new pagereference('/'+deReq.Id);
                }
            }       
            catch(Exception e){
                util.setErrorMsg(true, e.getmessage());
                system.debug('--- >'+e);
                Database.rollback(sp);
               
                return null;                
            }            
        } 
        
        //method binds multiple sub patches we select on page in one string        
        private string makedelimitedstring(list<selectoption> exisitngList)
        {
          string temp='';
          if(exisitngList!=null && exisitngList.size()>0)
          {
              System.debug('========exisitngList======'+exisitngList); 
              for(selectoption so: exisitngList)
              {
                if(so.getLabel().length()!=0)
                temp = temp + so.getLabel() + ';';
              }
              //System.debug('====tempStr==='+temp);
              if(temp!=''&& temp.length()!=0)
                  temp = temp.substring(0,temp.length()-1);
          }

          return temp;
        }        
        
        //Validates that we have entered week data on page
        private boolean checkAllvalidation()
        {
          boolean finalResult = true;
          if( recGeo || recAvailGeo)
          {
          if(deReq.Week_1__c  && monAMWeek1.size()==0  && tueAMWeek1.size()==0  && wedAMWeek1.size()==0
           && thuAMWeek1.size()==0   && friAMWeek1.size()==0  && satAMWeek1.size()==0  
           && sunAMWeek1.size()==0  )
           {
             util.setErrorMsg(true,'Please Enter Some Geography Details in Week 1' );
             finalResult =  false;
           }  
           
           if(deReq.Week_2__c && (recGeo || recAvailGeo) && monAMWeek2.size()==0 &&   tueAMWeek2.size()==0  && wedAMWeek2.size()==0
           && thuAMWeek2.size()==0  && friAMWeek2.size()==0  && satAMWeek2.size()==0 && 
            sunAMWeek2.size()==0 )
           {
             //util.setErrorMsg(true,'Please Enter Some Geography Details in Week 2 OR Do Not Check the Week 2 check box.' );
             //finalResult =  false;
             copy2=true;
           }
           
           if(deReq.Week_3__c && (recGeo || recAvailGeo) &&  monAMWeek3.size()==0 && tueAMWeek3.size()==0 && wedAMWeek3.size()==0
           && thuAMWeek3.size()==0   && friAMWeek3.size()==0 && satAMWeek3.size()==0  && sunAMWeek3.size()==0 )
           {
             //util.setErrorMsg(true,'Please Enter Some Geography Details in Week 3 OR Do Not Check the Week 3 check box.' );
             //finalResult =  false;
             copy3=true;
           }
           
           if(deReq.Week_4__c && (recGeo || recAvailGeo) && monAMWeek4.size()==0  && tueAMWeek4.size()==0  && wedAMWeek4.size()==0
           && thuAMWeek4.size()==0   && friAMWeek4.size()==0 && satAMWeek4.size()==0  && sunAMWeek4.size()==0 )
           {
             //util.setErrorMsg(true,'Please Enter Some Geography Details in Week 4 OR Do Not Check the Week 4 check box.' );
             //finalResult =  false;#
             copy4 = true;
           }
          }else if(recAvail || recAvailGeo)
          {
            
            if(deReq.Team__c != 'Straight Swap'){
            if(deReq.Week_1__c  && 
                            week1Details.Mon_AM_ApptWk1__c == null && week1Details.Mon_PM_ApptWk1__c==null && week1Details.Mon_EV_ApptWK1__c==null && week1Details.Mon_Any_ApptWK1__c==null && 
                            week1Details.Mon_07_09WK1__c==null && week1Details.Mon_09_11WK1__c==null &&  week1Details.Mon_11_13WK1__c==null &&
                            week1Details.Mon_13_15WK1__c==null && week1Details.Mon_15_17WK1__c==null  && week1Details.Mon_17_19WK1__c == null && week1Details.Mon_19_20WK1__c == null &&
                            
                            week1Details.Tue_AM_ApptWk1__c == null && week1Details.Tue_PM_ApptWk1__c==null && week1Details.Tue_EV_ApptWK1__c==null && week1Details.Tue_Any_ApptWK1__c==null && 
                            week1Details.Tue_07_09WK1__c==null && week1Details.Tue_09_11WK1__c==null &&  week1Details.Tue_11_13WK1__c==null &&
                            week1Details.Tue_13_15WK1__c==null && week1Details.Tue_15_17WK1__c==null  && week1Details.Tue_17_19WK1__c == null && week1Details.Tue_19_20WK1__c == null && 
                            
                            week1Details.Wed_AM_ApptWk1__c == null && week1Details.Wed_PM_ApptWk1__c==null && week1Details.Wed_EV_ApptWK1__c==null && week1Details.Wed_Any_ApptWK1__c==null && 
                            week1Details.Wed_07_09WK1__c==null && week1Details.Wed_09_11WK1__c==null &&  week1Details.Wed_11_13WK1__c==null &&
                            week1Details.Wed_13_15WK1__c==null && week1Details.Wed_15_17WK1__c==null  && week1Details.Wed_17_19WK1__c == null && week1Details.Wed_19_20WK1__c == null &&
                            
                            week1Details.Thu_AM_ApptWk1__c == null && week1Details.Thu_PM_ApptWk1__c==null && week1Details.Thu_EV_ApptWK1__c==null && week1Details.Thu_Any_ApptWK1__c==null && 
                            week1Details.Thu_09_11WK1__c==null &&  week1Details.Thu_11_13WK1__c==null &&
                            week1Details.Thu_13_15WK1__c==null && week1Details.Thu_15_17WK1__c==null  && week1Details.Thu_17_19WK1__c == null && week1Details.Thu_19_20WK1__c == null
                            &&
                            
                            week1Details.Fri_AM_ApptWk1__c == null && week1Details.Fri_PM_ApptWk1__c==null && week1Details.Fri_EV_ApptWK1__c==null && week1Details.Fri_Any_ApptWK1__c==null && 
                            week1Details.Fri_07_09WK1__c==null && week1Details.Fri_09_11WK1__c==null &&  week1Details.Fri_11_13WK1__c==null &&
                            week1Details.Fri_13_15WK1__c==null && week1Details.Fri_15_17WK1__c==null  && week1Details.Fri_17_19WK1__c == null && week1Details.Fri_19_20WK1__c == null && 
                            
                            week1Details.Sat_AM_ApptWk1__c == null && week1Details.Sat_PM_ApptWk1__c==null && week1Details.Sat_EV_ApptWK1__c==null && week1Details.Sat_Any_ApptWK1__c==null && 
                            week1Details.Sat_07_09WK1__c==null && week1Details.Sat_09_11WK1__c==null &&  week1Details.Sat_11_13WK1__c==null &&
                            week1Details.Sat_13_15WK1__c==null && week1Details.Sat_15_17WK1__c==null  && week1Details.Sat_17_19WK1__c == null && week1Details.Sat_19_20WK1__c == null &&
                            
                             
                            week1Details.Sun_AM_ApptWk1__c == null && week1Details.Sun_PM_ApptWk1__c==null && week1Details.Sun_EV_ApptWK1__c==null && week1Details.Sun_Any_ApptWK1__c==null && 
                            week1Details.Sun_07_09WK1__c==null && week1Details.Sun_09_11WK1__c==null &&  week1Details.Sun_11_13WK1__c==null &&
                            week1Details.Sun_13_15WK1__c==null && week1Details.Sun_15_17WK1__c==null  && week1Details.Sun_17_19WK1__c == null && week1Details.Sun_19_20WK1__c == null )
                                
                            {
                                util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 1 OR Do Not Check the Week 1 check box.' );
                                finalResult =  false;
                            } 
                            
                            
                            system.debug('week2Details--->'+week2Details);
                            if(deReq.Week_2__c  && 
                            week2Details.Mon_AM_ApptWk1__c== null && week2Details.Mon_PM_ApptWk1__c==null && week2Details.Mon_EV_ApptWK1__c==null && week2Details.Mon_Any_ApptWK1__c==null && 
                            week2Details.Mon_07_09WK1__c==null && week2Details.Mon_09_11WK1__c==null &&  week2Details.Mon_11_13WK1__c==null &&
                            week2Details.Mon_13_15WK1__c==null && week2Details.Mon_15_17WK1__c==null  && week2Details.Mon_17_19WK1__c == null && week2Details.Mon_19_20WK1__c == null &&
                            
                            week2Details.Tue_AM_ApptWk1__c == null && week2Details.Tue_PM_ApptWk1__c==null && week2Details.Tue_EV_ApptWK1__c==null && week2Details.Tue_Any_ApptWK1__c==null && 
                            week2Details.Tue_07_09WK1__c==null && week2Details.Tue_09_11WK1__c==null &&  week2Details.Tue_11_13WK1__c==null &&
                            week2Details.Tue_13_15WK1__c==null && week2Details.Tue_15_17WK1__c==null  && week2Details.Tue_17_19WK1__c == null && week2Details.Tue_19_20WK1__c == null && 
                            
                            week2Details.Wed_AM_ApptWk1__c == null && week2Details.Wed_PM_ApptWk1__c==null && week2Details.Wed_EV_ApptWK1__c==null && week2Details.Wed_Any_ApptWK1__c==null && 
                            week2Details.Wed_07_09WK1__c==null && week2Details.Wed_09_11WK1__c==null &&  week2Details.Wed_11_13WK1__c==null &&
                            week2Details.Wed_13_15WK1__c==null && week2Details.Wed_15_17WK1__c==null  && week2Details.Wed_17_19WK1__c == null && week2Details.Wed_19_20WK1__c == null &&
                            
                            week2Details.Thu_AM_ApptWk1__c == null && week2Details.Thu_PM_ApptWk1__c==null && week2Details.Thu_EV_ApptWK1__c==null && week2Details.Thu_Any_ApptWK1__c==null && 
                            week2Details.Thu_07_09WK1__c==null && week2Details.Thu_09_11WK1__c==null &&  week2Details.Thu_11_13WK1__c==null &&
                            week2Details.Thu_13_15WK1__c==null && week2Details.Thu_15_17WK1__c==null  && week2Details.Thu_17_19WK1__c == null && week2Details.Thu_19_20WK1__c == null
                            &&
                            
                            week2Details.Fri_AM_ApptWk1__c == null && week2Details.Fri_PM_ApptWk1__c==null && week2Details.Fri_EV_ApptWK1__c==null && week2Details.Fri_Any_ApptWK1__c==null && 
                            week2Details.Fri_07_09WK1__c==null && week2Details.Fri_09_11WK1__c==null &&  week2Details.Fri_11_13WK1__c==null &&
                            week2Details.Fri_13_15WK1__c==null && week2Details.Fri_15_17WK1__c==null  && week2Details.Fri_17_19WK1__c == null && week2Details.Fri_19_20WK1__c == null && 
                            
                            week2Details.Sat_AM_ApptWk1__c == null && week2Details.Sat_PM_ApptWk1__c==null && week2Details.Sat_EV_ApptWK1__c==null && week2Details.Sat_Any_ApptWK1__c==null && 
                            week2Details.Sat_07_09WK1__c==null && week2Details.Sat_09_11WK1__c==null &&  week2Details.Sat_11_13WK1__c==null &&
                            week2Details.Sat_13_15WK1__c==null && week2Details.Sat_15_17WK1__c==null  && week2Details.Sat_17_19WK1__c == null && week2Details.Sat_19_20WK1__c == null &&
                            
                             
                            week2Details.Sun_AM_ApptWk1__c == null && week2Details.Sun_PM_ApptWk1__c==null && week2Details.Sun_EV_ApptWK1__c==null && week2Details.Sun_Any_ApptWK1__c==null && 
                            week2Details.Sun_07_09WK1__c==null && week2Details.Sun_09_11WK1__c==null &&  week2Details.Sun_11_13WK1__c==null &&
                            week2Details.Sun_13_15WK1__c==null && week2Details.Sun_15_17WK1__c==null  && week2Details.Sun_17_19WK1__c == null && week2Details.Sun_19_20WK1__c == null )
                            {
                                //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 2 OR Do Not Check the Week 2 check box.' );
                                //finalResult =  false;
                                copy2 = true;
                            }
                            
                            
                            
                            if(deReq.Week_3__c  && 
                            week3Details.Mon_AM_ApptWk1__c == null && week3Details.Mon_PM_ApptWk1__c==null && week3Details.Mon_EV_ApptWK1__c==null && week3Details.Mon_Any_ApptWK1__c==null && 
                            week3Details.Mon_07_09WK1__c==null && week3Details.Mon_09_11WK1__c==null &&  week3Details.Mon_11_13WK1__c==null &&
                            week3Details.Mon_13_15WK1__c==null && week3Details.Mon_15_17WK1__c==null  && week3Details.Mon_17_19WK1__c == null && week3Details.Mon_19_20WK1__c == null &&
                            
                            week3Details.Tue_AM_ApptWk1__c == null && week3Details.Tue_PM_ApptWk1__c==null && week3Details.Tue_EV_ApptWK1__c==null && week3Details.Tue_Any_ApptWK1__c==null && 
                            week3Details.Tue_07_09WK1__c==null && week3Details.Tue_09_11WK1__c==null &&  week3Details.Tue_11_13WK1__c==null &&
                            week3Details.Tue_13_15WK1__c==null && week3Details.Tue_15_17WK1__c==null  && week3Details.Tue_17_19WK1__c == null && week3Details.Tue_19_20WK1__c == null && 
                            
                            week3Details.Wed_AM_ApptWk1__c == null && week3Details.Wed_PM_ApptWk1__c==null && week3Details.Wed_EV_ApptWK1__c==null && week3Details.Wed_Any_ApptWK1__c==null && 
                            week3Details.Wed_07_09WK1__c==null && week3Details.Wed_09_11WK1__c==null &&  week3Details.Wed_11_13WK1__c==null &&
                            week3Details.Wed_13_15WK1__c==null && week3Details.Wed_15_17WK1__c==null  && week3Details.Wed_17_19WK1__c == null && week3Details.Wed_19_20WK1__c == null &&
                            
                            week3Details.Thu_AM_ApptWk1__c == null && week3Details.Thu_PM_ApptWk1__c==null && week3Details.Thu_EV_ApptWK1__c==null && week3Details.Thu_Any_ApptWK1__c==null && 
                            week3Details.Thu_07_09WK1__c==null && week3Details.Thu_09_11WK1__c==null &&  week3Details.Thu_11_13WK1__c==null &&
                            week3Details.Thu_13_15WK1__c==null && week3Details.Thu_15_17WK1__c==null  && week3Details.Thu_17_19WK1__c == null && week3Details.Thu_19_20WK1__c == null
                            &&
                            
                            week3Details.Fri_AM_ApptWk1__c == null && week3Details.Fri_PM_ApptWk1__c==null && week3Details.Fri_EV_ApptWK1__c==null && week3Details.Fri_Any_ApptWK1__c==null && 
                            week3Details.Fri_07_09WK1__c==null && week3Details.Fri_09_11WK1__c==null &&  week3Details.Fri_11_13WK1__c==null &&
                            week3Details.Fri_13_15WK1__c==null && week3Details.Fri_15_17WK1__c==null  && week3Details.Fri_17_19WK1__c == null && week3Details.Fri_19_20WK1__c == null && 
                            
                            week3Details.Sat_AM_ApptWk1__c == null && week3Details.Sat_PM_ApptWk1__c==null && week3Details.Sat_EV_ApptWK1__c==null && week3Details.Sat_Any_ApptWK1__c==null && 
                            week3Details.Sat_07_09WK1__c==null && week3Details.Sat_09_11WK1__c==null &&  week3Details.Sat_11_13WK1__c==null &&
                            week3Details.Sat_13_15WK1__c==null && week3Details.Sat_15_17WK1__c==null  && week3Details.Sat_17_19WK1__c == null && week3Details.Sat_19_20WK1__c == null &&
                            
                             
                            week3Details.Sun_AM_ApptWk1__c == null && week3Details.Sun_PM_ApptWk1__c==null && week3Details.Sun_EV_ApptWK1__c==null && week3Details.Sun_Any_ApptWK1__c==null && 
                            week3Details.Sun_07_09WK1__c==null && week3Details.Sun_09_11WK1__c==null &&  week3Details.Sun_11_13WK1__c==null &&
                            week3Details.Sun_13_15WK1__c==null && week3Details.Sun_15_17WK1__c==null  && week3Details.Sun_17_19WK1__c == null && week3Details.Sun_19_20WK1__c == null )
                            {
                                //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 3 OR Do Not Check the Week 3 check box.' );
                                //finalResult =  false;
                                copy3=true;
                            }
                            
                            
                            if(deReq.Week_4__c  && 
                            week4Details.Mon_AM_ApptWk1__c == null && week4Details.Mon_PM_ApptWk1__c==null && week4Details.Mon_EV_ApptWK1__c==null && week4Details.Mon_Any_ApptWK1__c==null && 
                            week4Details.Mon_07_09WK1__c==null && week4Details.Mon_09_11WK1__c==null &&  week4Details.Mon_11_13WK1__c==null &&
                            week4Details.Mon_13_15WK1__c==null && week4Details.Mon_15_17WK1__c==null  && week4Details.Mon_17_19WK1__c == null && week4Details.Mon_19_20WK1__c == null &&
                            
                            week4Details.Tue_AM_ApptWk1__c == null && week4Details.Tue_PM_ApptWk1__c==null && week4Details.Tue_EV_ApptWK1__c==null && week4Details.Tue_Any_ApptWK1__c==null && 
                            week4Details.Tue_07_09WK1__c==null && week4Details.Tue_09_11WK1__c==null &&  week4Details.Tue_11_13WK1__c==null &&
                            week4Details.Tue_13_15WK1__c==null && week4Details.Tue_15_17WK1__c==null  && week4Details.Tue_17_19WK1__c == null && week4Details.Tue_19_20WK1__c == null && 
                            
                            week4Details.Wed_AM_ApptWk1__c == null && week4Details.Wed_PM_ApptWk1__c==null && week4Details.Wed_EV_ApptWK1__c==null && week4Details.Wed_Any_ApptWK1__c==null && 
                            week4Details.Wed_07_09WK1__c==null && week4Details.Wed_09_11WK1__c==null &&  week4Details.Wed_11_13WK1__c==null &&
                            week4Details.Wed_13_15WK1__c==null && week4Details.Wed_15_17WK1__c==null  && week4Details.Wed_17_19WK1__c == null && week4Details.Wed_19_20WK1__c == null &&
                            
                            week4Details.Thu_AM_ApptWk1__c == null && week4Details.Thu_PM_ApptWk1__c==null && week4Details.Thu_EV_ApptWK1__c==null && week4Details.Thu_Any_ApptWK1__c==null && 
                            week4Details.Thu_07_09WK1__c==null && week4Details.Thu_09_11WK1__c==null &&  week4Details.Thu_11_13WK1__c==null &&
                            week4Details.Thu_13_15WK1__c==null && week4Details.Thu_15_17WK1__c==null  && week4Details.Thu_17_19WK1__c == null && week4Details.Thu_19_20WK1__c == null
                            &&
                            
                            week4Details.Fri_AM_ApptWk1__c == null && week4Details.Fri_PM_ApptWk1__c==null && week4Details.Fri_EV_ApptWK1__c==null && week4Details.Fri_Any_ApptWK1__c==null && 
                            week4Details.Fri_07_09WK1__c==null && week4Details.Fri_09_11WK1__c==null &&  week4Details.Fri_11_13WK1__c==null &&
                            week4Details.Fri_13_15WK1__c==null && week4Details.Fri_15_17WK1__c==null  && week4Details.Fri_17_19WK1__c == null && week4Details.Fri_19_20WK1__c == null && 
                            
                            week4Details.Sat_AM_ApptWk1__c == null && week4Details.Sat_PM_ApptWk1__c==null && week4Details.Sat_EV_ApptWK1__c==null && week4Details.Sat_Any_ApptWK1__c==null && 
                            week4Details.Sat_07_09WK1__c==null && week4Details.Sat_09_11WK1__c==null &&  week4Details.Sat_11_13WK1__c==null &&
                            week4Details.Sat_13_15WK1__c==null && week4Details.Sat_15_17WK1__c==null  && week4Details.Sat_17_19WK1__c == null && week4Details.Sat_19_20WK1__c == null &&
                            
                             
                            week4Details.Sun_AM_ApptWk1__c == null && week4Details.Sun_PM_ApptWk1__c==null && week4Details.Sun_EV_ApptWK1__c==null && week4Details.Sun_Any_ApptWK1__c==null && 
                            week4Details.Sun_07_09WK1__c==null && week4Details.Sun_09_11WK1__c==null &&  week4Details.Sun_11_13WK1__c==null &&
                            week4Details.Sun_13_15WK1__c==null && week4Details.Sun_15_17WK1__c==null  && week4Details.Sun_17_19WK1__c == null && week4Details.Sun_19_20WK1__c == null )
                            {
                                //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 4 OR Do Not Check the Week 4 check box.' );
                                //finalResult =  false;
                                copy4=true;
                            }
            }else{
              if(deReq.Week_1__c && week1Details.Mon_09_00_09_40__c == null && week1Details.Mon_09_40_10_20__c == null && week1Details.Mon_10_20_11_00__c == null && week1Details.Mon_11_00_11_40__c == null && week1Details.Mon_11_40_12_20__c == null && week1Details.Mon_12_20_13_00__c == null && week1Details.Mon_13_00_13_40__c == null && 
                 week1Details.Mon_13_40_14_20__c == null && week1Details.Mon_14_20_15_00__c == null && week1Details.Mon_15_00_15_40__c == null && week1Details.Mon_15_40_16_20__c == null && week1Details.Mon_16_20_17_00__c == null && week1Details.Mon_17_00_17_40__c == null && week1Details.Mon_17_40_18_20__c == null && 
                 week1Details.Mon_18_20_19_00__c == null && week1Details.Mon_19_00_19_40__c == null && week1Details.Tue_09_00_09_40__c == null && week1Details.Tue_09_40_10_20__c == null && week1Details.Tue_10_20_11_00__c == null && week1Details.Tue_11_00_11_40__c == null && week1Details.Tue_11_40_12_20__c == null && 
                 week1Details.Tue_12_20_13_00__c == null && week1Details.Tue_13_00_13_40__c == null && week1Details.Tue_13_40_14_20__c == null && week1Details.Tue_14_20_15_00__c == null && week1Details.Tue_15_00_15_40__c == null && week1Details.Tue_15_40_16_20__c == null && week1Details.Tue_16_20_17_00__c == null && 
                 week1Details.Tue_17_00_17_40__c == null && week1Details.Tue_17_40_18_20__c == null && week1Details.Tue_18_20_19_00__c == null && week1Details.Tue_19_00_19_40__c == null && week1Details.Wed_09_00_09_40__c == null && week1Details.Wed_09_40_10_20__c == null && week1Details.Wed_10_20_11_00__c == null && 
                 week1Details.Wed_11_00_11_40__c == null && week1Details.Wed_11_40_12_20__c == null && week1Details.Wed_12_20_13_00__c == null && week1Details.Wed_13_00_13_40__c == null && week1Details.Wed_13_40_14_20__c == null && week1Details.Wed_14_20_15_00__c == null && week1Details.Wed_15_00_15_40__c == null && 
                 week1Details.Wed_15_40_16_20__c == null && week1Details.Wed_16_20_17_00__c == null && week1Details.Wed_17_00_17_40__c == null && week1Details.Wed_17_40_18_20__c == null && week1Details.Wed_18_20_19_00__c == null && week1Details.Wed_19_00_19_40__c == null && week1Details.Thu_09_00_09_40__c == null && 
                 week1Details.Thu_09_40_10_20__c == null && week1Details.Thu_10_20_11_00__c == null && week1Details.Thu_11_00_11_40__c == null && week1Details.Thu_11_40_12_20__c == null && week1Details.Thu_12_20_13_00__c == null && week1Details.Thu_13_00_13_40__c == null && week1Details.Thu_13_40_14_20__c == null && 
                 week1Details.Thu_14_20_15_00__c == null && week1Details.Thu_15_00_15_40__c == null && week1Details.Thu_15_40_16_20__c == null && week1Details.Thurs_16_20_17_00__c == null && week1Details.Thurs_17_00_17_40__c == null && week1Details.Thurs_17_40_18_20__c == null && week1Details.Thurs_18_20_19_00__c == null && 
                 week1Details.Thurs_19_00_19_40__c == null && week1Details.Fri_09_00_09_40__c == null && week1Details.Fri_09_40_10_20__c == null && week1Details.Fri_10_20_11_00__c == null && week1Details.Fri_11_00_11_40__c == null && week1Details.Fri_11_40_12_20__c == null && week1Details.Fri_12_20_13_00__c == null && week1Details.Fri_13_00_13_40__c == null && 
                 week1Details.Fri_13_40_14_20__c == null && week1Details.Fri_14_20_15_00__c == null && week1Details.Fri_15_00_15_40__c == null && week1Details.Fri_15_40_16_20__c == null && week1Details.Fri_16_20_17_00__c == null && week1Details.Fri_17_00_17_40__c == null && week1Details.Fri_17_40_18_20__c == null && week1Details.Fri_18_20_19_00__c == null && 
                 week1Details.Fri_19_00_19_40__c == null && week1Details.Sat_09_00_09_40__c == null && week1Details.Sat_09_40_10_20__c == null && week1Details.Sat_10_20_11_00__c == null && week1Details.Sat_11_00_11_40__c == null && week1Details.Sat_11_40_12_20__c == null && week1Details.Sat_12_20_13_00__c == null && week1Details.Sat_13_00_13_40__c == null && 
                 week1Details.Sat_13_40_14_20__c == null && week1Details.Sat_14_20_15_00__c == null && week1Details.Sat_15_00_15_40__c == null && week1Details.Sat_15_40_16_20__c == null && week1Details.Sat_16_20_17_00__c == null && week1Details.Sat_17_00_17_40__c == null && week1Details.Sat_17_40_18_20__c == null && week1Details.Sat_18_20_19_00__c == null && 
                 week1Details.Sat_19_00_19_40__c == null && week1Details.Sun_09_00_09_40__c == null && week1Details.Sun_09_40_10_20__c == null && week1Details.Sun_10_20_11_00__c == null && week1Details.Sun_11_00_11_40__c == null && week1Details.Sun_11_40_12_20__c == null && week1Details.Sun_12_20_13_00__c == null && week1Details.Sun_13_00_13_40__c == null && 
                 week1Details.Sun_13_40_14_20__c == null && week1Details.Sun_14_20_15_00__c == null && week1Details.Sun_15_00_15_40__c == null && week1Details.Sun_15_40_16_20__c == null && week1Details.Sun_16_20_17_00__c == null && week1Details.Sun_17_00_17_40__c == null && week1Details.Sun_17_40_18_20__c == null && week1Details.Sun_18_20_19_00__c == null && 
                 week1Details.Sun_19_00_19_40__c == null)     
                {
                    util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 1 OR Do Not Check the Week 1 check box.' );
                    finalResult =  false;
                } 
               
                
                system.debug('week2Details--->'+week2Details);
                if(deReq.Week_2__c  && 
                            week2Details.Mon_09_00_09_40__c == null && week2Details.Mon_09_40_10_20__c == null && week2Details.Mon_10_20_11_00__c == null && week2Details.Mon_11_00_11_40__c == null && week2Details.Mon_11_40_12_20__c == null && week2Details.Mon_12_20_13_00__c == null && week2Details.Mon_13_00_13_40__c == null && 
                            week2Details.Mon_13_40_14_20__c == null && week2Details.Mon_14_20_15_00__c == null && week2Details.Mon_15_00_15_40__c == null && week2Details.Mon_15_40_16_20__c == null && week2Details.Mon_16_20_17_00__c == null && week2Details.Mon_17_00_17_40__c == null && week2Details.Mon_17_40_18_20__c == null && 
                            week2Details.Mon_18_20_19_00__c == null && week2Details.Mon_19_00_19_40__c == null && week2Details.Tue_09_00_09_40__c == null && week2Details.Tue_09_40_10_20__c == null && week2Details.Tue_10_20_11_00__c == null && week2Details.Tue_11_00_11_40__c == null && week2Details.Tue_11_40_12_20__c == null && 
                            week2Details.Tue_12_20_13_00__c == null && week2Details.Tue_13_00_13_40__c == null && week2Details.Tue_13_40_14_20__c == null && week2Details.Tue_14_20_15_00__c == null && week2Details.Tue_15_00_15_40__c == null && week2Details.Tue_15_40_16_20__c == null && week2Details.Tue_16_20_17_00__c == null && 
                            week2Details.Tue_17_00_17_40__c == null && week2Details.Tue_17_40_18_20__c == null && week2Details.Tue_18_20_19_00__c == null && week2Details.Tue_19_00_19_40__c == null && week2Details.Wed_09_00_09_40__c == null && week2Details.Wed_09_40_10_20__c == null && week2Details.Wed_10_20_11_00__c == null && 
                            week2Details.Wed_11_00_11_40__c == null && week2Details.Wed_11_40_12_20__c == null && week2Details.Wed_12_20_13_00__c == null && week2Details.Wed_13_00_13_40__c == null && week2Details.Wed_13_40_14_20__c == null && week2Details.Wed_14_20_15_00__c == null && week2Details.Wed_15_00_15_40__c == null && 
                            week2Details.Wed_15_40_16_20__c == null && week2Details.Wed_16_20_17_00__c == null && week2Details.Wed_17_00_17_40__c == null && week2Details.Wed_17_40_18_20__c == null && week2Details.Wed_18_20_19_00__c == null && week2Details.Wed_19_00_19_40__c == null && week2Details.Thu_09_00_09_40__c == null && 
                            week2Details.Thu_09_40_10_20__c == null && week2Details.Thu_10_20_11_00__c == null && week2Details.Thu_11_00_11_40__c == null && week2Details.Thu_11_40_12_20__c == null && week2Details.Thu_12_20_13_00__c == null && week2Details.Thu_13_00_13_40__c == null && week2Details.Thu_13_40_14_20__c == null && 
                            week2Details.Thu_14_20_15_00__c == null && week2Details.Thu_15_00_15_40__c == null && week2Details.Thu_15_40_16_20__c == null && week2Details.Thurs_16_20_17_00__c == null && week2Details.Thurs_17_00_17_40__c == null && week2Details.Thurs_17_40_18_20__c == null && week2Details.Thurs_18_20_19_00__c == null && 
                            week2Details.Thurs_19_00_19_40__c == null && week2Details.Fri_09_00_09_40__c == null && week2Details.Fri_09_40_10_20__c == null && week2Details.Fri_10_20_11_00__c == null && week2Details.Fri_11_00_11_40__c == null && week2Details.Fri_11_40_12_20__c == null && week2Details.Fri_12_20_13_00__c == null && week2Details.Fri_13_00_13_40__c == null && 
                            week2Details.Fri_13_40_14_20__c == null && week2Details.Fri_14_20_15_00__c == null && week2Details.Fri_15_00_15_40__c == null && week2Details.Fri_15_40_16_20__c == null && week2Details.Fri_16_20_17_00__c == null && week2Details.Fri_17_00_17_40__c == null && week2Details.Fri_17_40_18_20__c == null && week2Details.Fri_18_20_19_00__c == null && 
                            week2Details.Fri_19_00_19_40__c == null && week2Details.Sat_09_00_09_40__c == null && week2Details.Sat_09_40_10_20__c == null && week2Details.Sat_10_20_11_00__c == null && week2Details.Sat_11_00_11_40__c == null && week2Details.Sat_11_40_12_20__c == null && week2Details.Sat_12_20_13_00__c == null && week2Details.Sat_13_00_13_40__c == null && 
                            week2Details.Sat_13_40_14_20__c == null && week2Details.Sat_14_20_15_00__c == null && week2Details.Sat_15_00_15_40__c == null && week2Details.Sat_15_40_16_20__c == null && week2Details.Sat_16_20_17_00__c == null && week2Details.Sat_17_00_17_40__c == null && week2Details.Sat_17_40_18_20__c == null && week2Details.Sat_18_20_19_00__c == null && 
                            week2Details.Sat_19_00_19_40__c == null && week2Details.Sun_09_00_09_40__c == null && week2Details.Sun_09_40_10_20__c == null && week2Details.Sun_10_20_11_00__c == null && week2Details.Sun_11_00_11_40__c == null && week2Details.Sun_11_40_12_20__c == null && week2Details.Sun_12_20_13_00__c == null && week2Details.Sun_13_00_13_40__c == null && 
                            week2Details.Sun_13_40_14_20__c == null && week2Details.Sun_14_20_15_00__c == null && week2Details.Sun_15_00_15_40__c == null && week2Details.Sun_15_40_16_20__c == null && week2Details.Sun_16_20_17_00__c == null && week2Details.Sun_17_00_17_40__c == null && week2Details.Sun_17_40_18_20__c == null && week2Details.Sun_18_20_19_00__c == null && 
                            week2Details.Sun_19_00_19_40__c == null) 
                {
                    //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 2 OR Do Not Check the Week 2 check box.' );
                    //finalResult =  false;
                    copy2 = true;
                }
                
                
                
                if(deReq.Week_3__c  && 
                            week3Details.Mon_09_00_09_40__c == null && week3Details.Mon_09_40_10_20__c == null && week3Details.Mon_10_20_11_00__c == null && week3Details.Mon_11_00_11_40__c == null && week3Details.Mon_11_40_12_20__c == null && week3Details.Mon_12_20_13_00__c == null && week3Details.Mon_13_00_13_40__c == null && 
                            week3Details.Mon_13_40_14_20__c == null && week3Details.Mon_14_20_15_00__c == null && week3Details.Mon_15_00_15_40__c == null && week3Details.Mon_15_40_16_20__c == null && week3Details.Mon_16_20_17_00__c == null && week3Details.Mon_17_00_17_40__c == null && week3Details.Mon_17_40_18_20__c == null && 
                            week3Details.Mon_18_20_19_00__c == null && week3Details.Mon_19_00_19_40__c == null && week3Details.Tue_09_00_09_40__c == null && week3Details.Tue_09_40_10_20__c == null && week3Details.Tue_10_20_11_00__c == null && week3Details.Tue_11_00_11_40__c == null && week3Details.Tue_11_40_12_20__c == null && 
                            week3Details.Tue_12_20_13_00__c == null && week3Details.Tue_13_00_13_40__c == null && week3Details.Tue_13_40_14_20__c == null && week3Details.Tue_14_20_15_00__c == null && week3Details.Tue_15_00_15_40__c == null && week3Details.Tue_15_40_16_20__c == null && week3Details.Tue_16_20_17_00__c == null && 
                            week3Details.Tue_17_00_17_40__c == null && week3Details.Tue_17_40_18_20__c == null && week3Details.Tue_18_20_19_00__c == null && week3Details.Tue_19_00_19_40__c == null && week3Details.Wed_09_00_09_40__c == null && week3Details.Wed_09_40_10_20__c == null && week3Details.Wed_10_20_11_00__c == null && 
                            week3Details.Wed_11_00_11_40__c == null && week3Details.Wed_11_40_12_20__c == null && week3Details.Wed_12_20_13_00__c == null && week3Details.Wed_13_00_13_40__c == null && week3Details.Wed_13_40_14_20__c == null && week3Details.Wed_14_20_15_00__c == null && week3Details.Wed_15_00_15_40__c == null && 
                            week3Details.Wed_15_40_16_20__c == null && week3Details.Wed_16_20_17_00__c == null && week3Details.Wed_17_00_17_40__c == null && week3Details.Wed_17_40_18_20__c == null && week3Details.Wed_18_20_19_00__c == null && week3Details.Wed_19_00_19_40__c == null && week3Details.Thu_09_00_09_40__c == null && 
                            week3Details.Thu_09_40_10_20__c == null && week3Details.Thu_10_20_11_00__c == null && week3Details.Thu_11_00_11_40__c == null && week3Details.Thu_11_40_12_20__c == null && week3Details.Thu_12_20_13_00__c == null && week3Details.Thu_13_00_13_40__c == null && week3Details.Thu_13_40_14_20__c == null && 
                            week3Details.Thu_14_20_15_00__c == null && week3Details.Thu_15_00_15_40__c == null && week3Details.Thu_15_40_16_20__c == null && week3Details.Thurs_16_20_17_00__c == null && week3Details.Thurs_17_00_17_40__c == null && week3Details.Thurs_17_40_18_20__c == null && week3Details.Thurs_18_20_19_00__c == null && 
                            week3Details.Thurs_19_00_19_40__c == null && week3Details.Fri_09_00_09_40__c == null && week3Details.Fri_09_40_10_20__c == null && week3Details.Fri_10_20_11_00__c == null && week3Details.Fri_11_00_11_40__c == null && week3Details.Fri_11_40_12_20__c == null && week3Details.Fri_12_20_13_00__c == null && week3Details.Fri_13_00_13_40__c == null && 
                            week3Details.Fri_13_40_14_20__c == null && week3Details.Fri_14_20_15_00__c == null && week3Details.Fri_15_00_15_40__c == null && week3Details.Fri_15_40_16_20__c == null && week3Details.Fri_16_20_17_00__c == null && week3Details.Fri_17_00_17_40__c == null && week3Details.Fri_17_40_18_20__c == null && week3Details.Fri_18_20_19_00__c == null && 
                            week3Details.Fri_19_00_19_40__c == null && week3Details.Sat_09_00_09_40__c == null && week3Details.Sat_09_40_10_20__c == null && week3Details.Sat_10_20_11_00__c == null && week3Details.Sat_11_00_11_40__c == null && week3Details.Sat_11_40_12_20__c == null && week3Details.Sat_12_20_13_00__c == null && week3Details.Sat_13_00_13_40__c == null && 
                            week3Details.Sat_13_40_14_20__c == null && week3Details.Sat_14_20_15_00__c == null && week3Details.Sat_15_00_15_40__c == null && week3Details.Sat_15_40_16_20__c == null && week3Details.Sat_16_20_17_00__c == null && week3Details.Sat_17_00_17_40__c == null && week3Details.Sat_17_40_18_20__c == null && week3Details.Sat_18_20_19_00__c == null && 
                            week3Details.Sat_19_00_19_40__c == null && week3Details.Sun_09_00_09_40__c == null && week3Details.Sun_09_40_10_20__c == null && week3Details.Sun_10_20_11_00__c == null && week3Details.Sun_11_00_11_40__c == null && week3Details.Sun_11_40_12_20__c == null && week3Details.Sun_12_20_13_00__c == null && week3Details.Sun_13_00_13_40__c == null && 
                            week3Details.Sun_13_40_14_20__c == null && week3Details.Sun_14_20_15_00__c == null && week3Details.Sun_15_00_15_40__c == null && week3Details.Sun_15_40_16_20__c == null && week3Details.Sun_16_20_17_00__c == null && week3Details.Sun_17_00_17_40__c == null && week3Details.Sun_17_40_18_20__c == null && week3Details.Sun_18_20_19_00__c == null && 
                            week3Details.Sun_19_00_19_40__c == null)
                {
                    //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 3 OR Do Not Check the Week 3 check box.' );
                    //finalResult =  false;
                    copy3=true;
                }
                
                
                if(deReq.Week_4__c  && 
                            week4Details.Mon_09_00_09_40__c == null && week4Details.Mon_09_40_10_20__c == null && week4Details.Mon_10_20_11_00__c == null && week4Details.Mon_11_00_11_40__c == null && week4Details.Mon_11_40_12_20__c == null && week4Details.Mon_12_20_13_00__c == null && week4Details.Mon_13_00_13_40__c == null && 
                            week4Details.Mon_13_40_14_20__c == null && week4Details.Mon_14_20_15_00__c == null && week4Details.Mon_15_00_15_40__c == null && week4Details.Mon_15_40_16_20__c == null && week4Details.Mon_16_20_17_00__c == null && week4Details.Mon_17_00_17_40__c == null && week4Details.Mon_17_40_18_20__c == null && 
                            week4Details.Mon_18_20_19_00__c == null && week4Details.Mon_19_00_19_40__c == null && week4Details.Tue_09_00_09_40__c == null && week4Details.Tue_09_40_10_20__c == null && week4Details.Tue_10_20_11_00__c == null && week4Details.Tue_11_00_11_40__c == null && week4Details.Tue_11_40_12_20__c == null && 
                            week4Details.Tue_12_20_13_00__c == null && week4Details.Tue_13_00_13_40__c == null && week4Details.Tue_13_40_14_20__c == null && week4Details.Tue_14_20_15_00__c == null && week4Details.Tue_15_00_15_40__c == null && week4Details.Tue_15_40_16_20__c == null && week4Details.Tue_16_20_17_00__c == null && 
                            week4Details.Tue_17_00_17_40__c == null && week4Details.Tue_17_40_18_20__c == null && week4Details.Tue_18_20_19_00__c == null && week4Details.Tue_19_00_19_40__c == null && week4Details.Wed_09_00_09_40__c == null && week4Details.Wed_09_40_10_20__c == null && week4Details.Wed_10_20_11_00__c == null && 
                            week4Details.Wed_11_00_11_40__c == null && week4Details.Wed_11_40_12_20__c == null && week4Details.Wed_12_20_13_00__c == null && week4Details.Wed_13_00_13_40__c == null && week4Details.Wed_13_40_14_20__c == null && week4Details.Wed_14_20_15_00__c == null && week4Details.Wed_15_00_15_40__c == null && 
                            week4Details.Wed_15_40_16_20__c == null && week4Details.Wed_16_20_17_00__c == null && week4Details.Wed_17_00_17_40__c == null && week4Details.Wed_17_40_18_20__c == null && week4Details.Wed_18_20_19_00__c == null && week4Details.Wed_19_00_19_40__c == null && week4Details.Thu_09_00_09_40__c == null && 
                            week4Details.Thu_09_40_10_20__c == null && week4Details.Thu_10_20_11_00__c == null && week4Details.Thu_11_00_11_40__c == null && week4Details.Thu_11_40_12_20__c == null && week4Details.Thu_12_20_13_00__c == null && week4Details.Thu_13_00_13_40__c == null && week4Details.Thu_13_40_14_20__c == null && 
                            week4Details.Thu_14_20_15_00__c == null && week4Details.Thu_15_00_15_40__c == null && week4Details.Thu_15_40_16_20__c == null && week4Details.Thurs_16_20_17_00__c == null && week4Details.Thurs_17_00_17_40__c == null && week4Details.Thurs_17_40_18_20__c == null && week4Details.Thurs_18_20_19_00__c == null && 
                            week4Details.Thurs_19_00_19_40__c == null && week4Details.Fri_09_00_09_40__c == null && week4Details.Fri_09_40_10_20__c == null && week4Details.Fri_10_20_11_00__c == null && week4Details.Fri_11_00_11_40__c == null && week4Details.Fri_11_40_12_20__c == null && week4Details.Fri_12_20_13_00__c == null && week4Details.Fri_13_00_13_40__c == null && 
                            week4Details.Fri_13_40_14_20__c == null && week4Details.Fri_14_20_15_00__c == null && week4Details.Fri_15_00_15_40__c == null && week4Details.Fri_15_40_16_20__c == null && week4Details.Fri_16_20_17_00__c == null && week4Details.Fri_17_00_17_40__c == null && week4Details.Fri_17_40_18_20__c == null && week4Details.Fri_18_20_19_00__c == null && 
                            week4Details.Fri_19_00_19_40__c == null && week4Details.Sat_09_00_09_40__c == null && week4Details.Sat_09_40_10_20__c == null && week4Details.Sat_10_20_11_00__c == null && week4Details.Sat_11_00_11_40__c == null && week4Details.Sat_11_40_12_20__c == null && week4Details.Sat_12_20_13_00__c == null && week4Details.Sat_13_00_13_40__c == null && 
                            week4Details.Sat_13_40_14_20__c == null && week4Details.Sat_14_20_15_00__c == null && week4Details.Sat_15_00_15_40__c == null && week4Details.Sat_15_40_16_20__c == null && week4Details.Sat_16_20_17_00__c == null && week4Details.Sat_17_00_17_40__c == null && week4Details.Sat_17_40_18_20__c == null && week4Details.Sat_18_20_19_00__c == null && 
                            week4Details.Sat_19_00_19_40__c == null && week4Details.Sun_09_00_09_40__c == null && week4Details.Sun_09_40_10_20__c == null && week4Details.Sun_10_20_11_00__c == null && week4Details.Sun_11_00_11_40__c == null && week4Details.Sun_11_40_12_20__c == null && week4Details.Sun_12_20_13_00__c == null && week4Details.Sun_13_00_13_40__c == null && 
                            week4Details.Sun_13_40_14_20__c == null && week4Details.Sun_14_20_15_00__c == null && week4Details.Sun_15_00_15_40__c == null && week4Details.Sun_15_40_16_20__c == null && week4Details.Sun_16_20_17_00__c == null && week4Details.Sun_17_00_17_40__c == null && week4Details.Sun_17_40_18_20__c == null && week4Details.Sun_18_20_19_00__c == null && 
                            week4Details.Sun_19_00_19_40__c == null)
                {
                    //util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 4 OR Do Not Check the Week 4 check box.' );
                    //finalResult =  false;
                    copy4=true;
                }
            }
                
                
          }
           
           return finalResult;
           
        }        
        
        //Takes data of 4 weeks and populates week data for given no of weeks
        private void populateWeekRecords()
        {
             system.debug('Show Copy Details--->'+copy2+ ' '+copy3+ ' '+ copy4);
            if(recGeo || recAvailGeo)
            {
              RoleVlaues1 = new List<list<Selectoption>>{monAMWeek1, tueAMWeek1,
                                                        wedAMWeek1,thuAMWeek1,
                                                        friAMWeek1,satAMWeek1,
                                                        sunAMWeek1};
                                                     
               RoleVlaues2 = new List<list<Selectoption>>{monAMWeek2, tueAMWeek2,
                                                          wedAMWeek2,thuAMWeek2,
                                                          friAMWeek2,satAMWeek2,
                                                          sunAMWeek2};
                                                  
               RoleVlaues3 = new List<list<Selectoption>>{monAMWeek3, tueAMWeek3,
                                                          wedAMWeek3,thuAMWeek3,
                                                          friAMWeek3,satAMWeek3,
                                                          sunAMWeek3};   
                                                              
               RoleVlaues4 =  new List<list<Selectoption>>{monAMWeek4, tueAMWeek4,
                                                          wedAMWeek4,thuAMWeek4,
                                                          friAMWeek4,satAMWeek4,
                                                          sunAMWeek4};            
                
                week1Details = populateRoleDetails(RoleVlaues1,week1Details);
                
               
                if(deReq.Week_2__c && deReq.Week_3__c && deReq.Week_4__c)
                {
                    if(!copy2 && !copy3 && !copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details);       
                    }else if(!copy2 && copy3 && copy4)  
                    {
                        week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues2,week4Details);
                    }
                    else if(copy2 && !copy3 && copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues3,week4Details);       
                    } 
                    else if(copy2 && copy3 && !copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details);       
                    }  
                    else if(!copy2 && !copy3 && copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues1,week4Details);
                        
                    } else if(copy2 && !copy3 && !copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details);
                    }else if(!copy2 && copy3 && !copy4)
                    {
                        week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details);
                    }else
                    {
                        week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        week4Details = populateRoleDetails(RoleVlaues1,week4Details);
                    }
                }
                 
              /* else if(!deReq.Week_2__c && !deReq.Week_3__c && !deReq.Week_4__c)
               {
                       //week2Details =week1Details ;
                       //week3Details =week1Details ;
                       //week4Details =week1Details ;
                       week2Details= populateRoleDetails(RoleVlaues1,week2Details); 
                       week3Details= populateRoleDetails(RoleVlaues1,week3Details); 
                       week4Details= populateRoleDetails(RoleVlaues1,week4Details);                      
               }  */
                
               else if(!deReq.Week_2__c && deReq.Week_3__c && deReq.Week_4__c)
               {
                        //week2Details=week1Details;
                        if(!copy3 && !copy4)
                        {
                        //week2Details= populateRoleDetails(RoleVlaues1,week2Details);
                            week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                            week4Details = populateRoleDetails(RoleVlaues4,week4Details);      
                        }
                        else if(!copy3 && copy4)
                        {
                        //week2Details= populateRoleDetails(RoleVlaues1,week2Details);
                            week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                            week4Details = populateRoleDetails(RoleVlaues1,week4Details);      
                        }  
                        else if(copy3 && !copy4)
                        {
                            week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                            week4Details = populateRoleDetails(RoleVlaues4,week4Details);          
                        } else
                        {
                            week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                            week4Details = populateRoleDetails(RoleVlaues1,week4Details); 
                        }               
               } 
                
               else if(deReq.Week_2__c && !deReq.Week_3__c && deReq.Week_4__c)
               {
                        //week3Details  = week2Details;
                        if(!copy2 && !copy4)
                        {
                        week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details); 
                        }
                        else if(!copy2 && copy4)
                        {
                            week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                            week4Details = populateRoleDetails(RoleVlaues1,week4Details); 
                        }
                        else if(copy2 && !copy4)
                        {
                        week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                        week4Details = populateRoleDetails(RoleVlaues4,week4Details); 
                        }else
                        {
                             week2Details = populateRoleDetails(RoleVlaues1,week2Details); 
                            //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                            week4Details = populateRoleDetails(RoleVlaues1,week4Details); 
                        }
                                              
               } 
               else if(deReq.Week_2__c && deReq.Week_3__c && !deReq.Week_4__c)
               {
                        //week4Details = week3Details;
                        if(!copy2 && !copy3)
                        {
                            week2Details = populateRoleDetails(RoleVlaues2,week2Details);  
                            week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        }else if(!copy2 && copy3)
                        {
                            week2Details = populateRoleDetails(RoleVlaues2,week2Details);  
                            week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        }else if(copy2 && !copy3)
                        {
                            week2Details = populateRoleDetails(RoleVlaues1,week2Details);  
                            week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        }else
                        {
                            week2Details = populateRoleDetails(RoleVlaues1,week2Details);  
                            week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        }
                        
                        
                        //week4Details= populateRoleDetails(RoleVlaues3,week4Details);                      
               }  
               else if(!deReq.Week_2__c && !deReq.Week_3__c && deReq.Week_4__c)
               {
                       //week2Details=week1Details;
                       //week3Details=week1Details;          
                       if(!copy4)
                       {             
                           
                           week4Details = populateRoleDetails(RoleVlaues4,week4Details);
                       }else
                       {
                           //week2Details= populateRoleDetails(RoleVlaues1,week2Details); 
                           //week3Details= populateRoleDetails(RoleVlaues1,week3Details); 
                           week4Details = populateRoleDetails(RoleVlaues1,week4Details);
                       }
               }
                else if(deReq.Week_2__c && !deReq.Week_3__c && !deReq.Week_4__c)
                {
                        //week3Details=week1Details;
                        //week4Details=week2Details;   
                        if(!copy2)
                        {
                            week2Details = populateRoleDetails(RoleVlaues2,week2Details);
                        }else
                        {
                            week2Details = populateRoleDetails(RoleVlaues1,week2Details);
                        }             
                }
                else if(!deReq.Week_2__c && deReq.Week_3__c && !deReq.Week_4__c)
                {
                        //week2Details=week1Details;
                        //week4Details=week1Details;
                        if(!copy3)
                        { 
                            week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        
                        } else
                        {
                            week3Details = populateRoleDetails(RoleVlaues1,week3Details);
                        }                    
                } 
            }
            
            if(recAvail || recAvailGeo)
            {
                
                
                
                 
                if(deReq.Week_2__c && deReq.Week_3__c && deReq.Week_4__c)
                {
                    if(!copy2 && copy3 && copy4)  
                    {
                        
                        week3Details = week1Details.clone(true);
                        week4Details = week2Details.clone(true);
                    }
                    else if(copy2 && !copy3 && copy4)
                    {
                        week2Details = week1Details.clone(true); //populateRoleDetails(RoleVlaues1,week2Details); 
                        week4Details = week3Details.clone(true);//populateRoleDetails(RoleVlaues3,week4Details);       
                    } 
                    else if(copy2 && copy3 && !copy4)
                    {
                        week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        //week4Details = populateRoleDetails(RoleVlaues4,week4Details);       
                    }  
                    else if(!copy2 && !copy3 && copy4)
                    {
                        //week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details);
                        
                    } else if(copy2 && !copy3 && !copy4)
                    {
                        week2Details = week1Details.clone(true);// populateRoleDetails(RoleVlaues1,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        //week4Details = populateRoleDetails(RoleVlaues4,week4Details);
                    }else if(!copy2 && copy3 && !copy4)
                    {
                        //week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                        week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        //week4Details = populateRoleDetails(RoleVlaues4,week4Details);
                    }else
                    {
                        week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details); 
                        week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details);
                    }
                }
              
                
               else if(!deReq.Week_2__c && deReq.Week_3__c && deReq.Week_4__c)
               {
                        //week2Details=week1Details;
                        if(!copy3 && copy4)
                        {
                            //week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                            week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details);      
                        }  
                        else if(copy3 && !copy4)
                        {
                            week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                            //week4Details = populateRoleDetails(RoleVlaues4,week4Details);          
                        } else if (copy3 && copy4)
                        {
                            week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                            week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details); 
                        }               
               } 
                
               else if(deReq.Week_2__c && !deReq.Week_3__c && deReq.Week_4__c)
               {
                        //week3Details  = week2Details;
                        if(!copy2 && copy4)
                        {
                            //week2Details = populateRoleDetails(RoleVlaues2,week2Details); 
                            //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                            week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details); 
                        }
                        else if(copy2 && !copy4)
                        {
                        week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details); 
                        //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                        //week4Details = populateRoleDetails(RoleVlaues4,week4Details); 
                        }else if(copy2 && copy4)
                        {
                             week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details); 
                            //week3Details = populateRoleDetails(RoleVlaues2,week3Details); 
                            week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details); 
                        }
                                              
               } 
               else if(deReq.Week_2__c && deReq.Week_3__c && !deReq.Week_4__c)
               {
                        //week4Details = week3Details;
                        if(!copy2 && copy3)
                        {
                            //week2Details = populateRoleDetails(RoleVlaues2,week2Details);  
                            week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        }else if(copy2 && !copy3)
                        {
                            week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details);  
                            //week3Details = populateRoleDetails(RoleVlaues3,week3Details);
                        }else if(copy2 && copy3)
                        {
                            week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details);  
                            week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        }
                        
                        
                        //week4Details= populateRoleDetails(RoleVlaues3,week4Details);                      
               }  
               else if(!deReq.Week_2__c && !deReq.Week_3__c && deReq.Week_4__c)
               {
                       //week2Details=week1Details;
                       //week3Details=week1Details;          
                       if(copy4)
                       {             
                           
                           week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details);
                       }
               }
                else if(deReq.Week_2__c && !deReq.Week_3__c && !deReq.Week_4__c)
                {
                        //week3Details=week1Details;
                        //week4Details=week2Details;   
                        if(copy2)
                        {
                            week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details);
                        }            
                }
                else if(!deReq.Week_2__c && deReq.Week_3__c && !deReq.Week_4__c)
                {
                        //week2Details=week1Details;
                        //week4Details=week1Details;
                        if(copy3)
                        { 
                            week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
                        
                        }                   
                } 
            }
                
            
                 
                 insertList.add(week1Details);
                 insertList.add(week2Details);
                 insertList.add(week3Details);
                 insertList.add(week4Details);            
        }  
        
        // assigns multiple subpatches binded in one string to the respective field of week detail object     
        private Diary_Change_Request__c populateRoleDetails(list<list<Selectoption>> RoleValues,Diary_Change_Request__c w)
        { 
                Diary_Change_Request__c temp = w;
                System.debug('====RoleValuesInMethod==='+RoleValues);
               if(RoleValues.size()>0){
                   System.debug('=======RoleValues[0]===='+RoleValues[0]);
                  temp.Mon_AM_RoleWK1__c = makedelimitedstring(RoleValues[0]);
                  System.debug('=======RoleValues[1]===='+RoleValues[1]);
                  //temp.Mon_PM_RoleWK1__c = makedelimitedstring(RoleValues[1]);
                  temp.Tue_AM_RoleWK1__c = makedelimitedstring(RoleValues[1]);
                  //temp.Tue_PM_RoleWK1__c = makedelimitedstring(RoleValues[3]);
                  temp.Wed_AM_RoleWK1__c = makedelimitedstring(RoleValues[2]);
                  //temp.Wed_PM_RoleWK1__c = makedelimitedstring(RoleValues[5]);
                  temp.Thu_AM_RoleWK1__c = makedelimitedstring(RoleValues[3]);
                  //temp.Thu_PM_RoleWK1__c = makedelimitedstring(RoleValues[7]);
                  temp.Fri_AM_RoleWK1__c = makedelimitedstring(RoleValues[4]);
                  //temp.Fri_PM_RoleWK1__c = makedelimitedstring(RoleValues[9]);
                  temp.Sat_AM_RoleWK1__c = makedelimitedstring(RoleValues[5]);
                  //temp.Sat_PM_RoleWK1__c = makedelimitedstring(RoleValues[11]);
                  temp.Sun_AM_RoleWK1__c = makedelimitedstring(RoleValues[6]);
                  //temp.Sun_PM_RoleWK1__c = makedelimitedstring(RoleValues[13]);
                  System.debug('=====debug====='+'===='+RoleValues[0]+'======'+makedelimitedstring(RoleValues[0])+'====='+temp.Mon_AM_RoleWK1__c);
                  
               }              
              System.debug('====temp==='+temp);
              return temp;           
        }               
        
        private void instantiateValues ()
        {
            districtList = new list<selectOption>();
            subpatchDetails = new list<selectOption>();
            week1Details = new Diary_Change_Request__c();
            week2Details = new Diary_Change_Request__c();
            week3Details = new Diary_Change_Request__c();
            week4Details = new Diary_Change_Request__c();
            week1 = false;
            week2 = false;
            week3=false;
            week4 = false;
            recAvail = false;
            recGeo = false;            
            recUnavail = false;
            recAvailGeo = false;
            isClone = null;
            
            masterPicklist2 = new list<selectoption>();
            masterPicklist3 = new list<selectoption>();
            masterPicklist4 = new list<selectoption>();
            masterPicklistSelected2='';
            masterPicklistSelected3='';
            masterPicklistSelected4='';
            
            if(System.currentPageReference().getParameters().get('var_isClone')!=null)
            strIsClone = System.currentPageReference().getParameters().get('var_isClone'); 
            if(System.currentPageReference().getParameters().get('var_DCId')!=null)
            diaryChangeIDString = System.currentPageReference().getParameters().get('var_DCId');
            if(strIsClone.equals('true'))
                isClone = true;
            else
                isClone = null;
                
            AnyTimeApptTypes = new list<selectOption>();
            twoHrApptTypes = new list<selectOption>();
            
            monAMWeek1 = new list<selectoption>();
           // monPMWeek1= new list<selectoption>();
            tueAMWeek1= new list<selectoption>();
          //  tuePMWeek1= new list<selectoption>();
            wedAMWeek1= new list<selectoption>();
          //  wedPMWeek1= new list<selectoption>();
            thuAMWeek1= new list<selectoption>();
          //  thuPMWeek1= new list<selectoption>();
            friAMWeek1= new list<selectoption>();
          //  friPMWeek1= new list<selectoption>();
            satAMWeek1= new list<selectoption>();
         //   satPMWeek1= new list<selectoption>();
            sunAMWeek1= new list<selectoption>();
         //   sunPMWeek1= new list<selectoption>();
            
            monAMWeek2 = new list<selectoption>();
         //   monPMWeek2= new list<selectoption>();
            tueAMWeek2= new list<selectoption>();
        //    tuePMWeek2= new list<selectoption>();
            wedAMWeek2= new list<selectoption>();
       //     wedPMWeek2= new list<selectoption>();
            thuAMWeek2= new list<selectoption>();
       //     thuPMWeek2= new list<selectoption>();
            friAMWeek2= new list<selectoption>();
       //     friPMWeek2= new list<selectoption>();
            satAMWeek2= new list<selectoption>();
      //      satPMWeek2= new list<selectoption>();
            sunAMWeek2= new list<selectoption>();
      //      sunPMWeek2= new list<selectoption>();
            
            monAMWeek3= new list<selectoption>();
       //     monPMWeek3= new list<selectoption>();
            tueAMWeek3= new list<selectoption>();
       //     tuePMWeek3= new list<selectoption>();
            wedAMWeek3= new list<selectoption>();
      //      wedPMWeek3= new list<selectoption>();
            thuAMWeek3= new list<selectoption>();
      //      thuPMWeek3= new list<selectoption>();
            friAMWeek3= new list<selectoption>();
      //      friPMWeek3= new list<selectoption>();
            satAMWeek3= new list<selectoption>();
       //     satPMWeek3= new list<selectoption>();
            sunAMWeek3= new list<selectoption>();
      //      sunPMWeek3= new list<selectoption>();
            
            monAMWeek4 = new list<selectoption>();
     //       monPMWeek4= new list<selectoption>();
            tueAMWeek4= new list<selectoption>();
      //      tuePMWeek4= new list<selectoption>();
            wedAMWeek4= new list<selectoption>();
     //       wedPMWeek4= new list<selectoption>();
            thuAMWeek4= new list<selectoption>();
    //        thuPMWeek4= new list<selectoption>();
            friAMWeek4= new list<selectoption>();
    //        friPMWeek4= new list<selectoption>();
            satAMWeek4= new list<selectoption>();
    //        satPMWeek4= new list<selectoption>();
            sunAMWeek4= new list<selectoption>();
     //       sunPMWeek4= new list<selectoption>();
            
            
        }
    
    public pagereference doNothing()
    {
        if(deReq.Team__c == 'Straight Swap')
        labelList = stringhtSwap;
        else
        labelList = normalSlot;
        displayWeek1();
        displayWeek2();
        displayWeek3();
        displayWeek4();
        return null;
    }
  }