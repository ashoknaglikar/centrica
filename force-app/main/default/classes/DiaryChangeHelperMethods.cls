public with sharing class DiaryChangeHelperMethods {
    
    @future(callout =false)
    public static void massDeleteRole(set<Id> RoleId , Date StartDate, Date EndDate, list<boolean> weeks, Id diaryChagId)
    {
        GeographyChangeReqController  obj = new GeographyChangeReqController();
        obj.diaryChng = [Select id, Start__c , Week_1__c, Week_2__c,Week_3__c,Week_4__c,RecordType.name from Diary_Change__c where id = : diaryChagId];
        system.debug('======='+obj.diaryChng);
        list<Role_Sub_Patch__c> deleteList= new list<Role_Sub_Patch__c>();
        
        for( Role_Sub_Patch__c r: [select id,Start_Date__c from Role_Sub_Patch__c where Role__c IN :RoleId AND (Start_Date__c >= :StartDate AND End_Date__c <= :EndDate)])
        {
            if(obj.checkValid(r))
                deleteList.add(r);
        }
        if(deleteList.size()>0)
            delete deleteList;
    }
    
    @future(callout =false)
    public static void massDeleteAppts(set<Id> empIdSet , Date StartDate, Date EndDate, id RecordtypeId, Id diaryChagId)
    {
        AvailabilityChangeReqController objAv = new AvailabilityChangeReqController();
        objAv.diaryChng = [Select id, Start__c , Week_1__c, Week_2__c,Week_3__c,Week_4__c from Diary_Change__c where id = : diaryChagId];
        list<Appointment__c> deleteList= new list<Appointment__c>();
        
        for(Appointment__c a: [Select id, Start__c,RecordTypeId, RecordType.Name from Appointment__c where Assigned_To__c IN :empIdSet AND Start__c >= :startDate AND End__c <= :EndDate and RecordTypeId = : RecordtypeId])
        {
            if(objAv.checkIfNeeds(a))
                deleteList.add(a);
        }
        if(deleteList.SIZE()>0)
            delete deleteList;
    }
    
    @future(callout =false)
    public static Void insertUnavailabilties(Id DiaryRequest,set<Id> empIdSet , Datetime StartDate, Datetime EndDate, id RecordtypeId, string reason, string notes, string Subject )
    {
        list<Appointment__c> apptToInsert = new list<Appointment__c>();
        list<DateTime> startdateList = new list<DateTime>();
        List<DateTime> endDateList = new list<DateTime>();
        Integer Hour = StartDate.Hour();
        Integer Minutes = StartDate.Minute();
        Date startofWeek = StartDate.date().toStartOfWeek() ;
        Date EndoftheWeek =  startofWeek.addDays(7);
        System.debug('====debug====='+startofWeek  +'=='+EndoftheWeek );
        startdateList.add(StartDate);
        while(EndoftheWeek<EndDate.date()) //PRB00024155 fix
        {
            endDateList.add(EndoftheWeek);
            startdateList.add(EndoftheWeek.addDays(1));
            EndoftheWeek = EndoftheWeek.addDays(8);
            
        }
        endDateList.add(EndDate);
        system.debug('-- '+EndDate);
        system.debug('startdateList-->'+startdateList + '-- '+endDateList);
        
        list<DateTime> startdateListTemp = new list<DateTime>();
        List<DateTime> endDateListTemp = new list<DateTime>();
        for(integer i=0 ; i< startdateList.size() ; i++){
            System.debug('======In for==='+startdateList[i].date().daysBetween(endDateList[i].date()));
            if(startdateList[i].date().daysBetween(endDateList[i].date()) >= 5){
                system.debug('======In If===');
                startdateListTemp.add(startdateList[i]);
                endDateListTemp.add(startdateList[i].adddays(3));
                startdateListTemp.add(startdateList[i].adddays(4));
                endDateListTemp.add(endDateList[i]);
            }
            else{
                system.debug('======In else===');
                startdateListTemp.add(startdateList[i]);
                endDateListTemp.add(endDateList[i]);
            }
        }
        system.debug('startdateList-->'+startdateListTemp+ '-- '+endDateListTemp);
        for(Id  i: empIdSet)
        {
            for(integer j=0 ; j< startdateListTemp.size() ; j++)
            {
                Appointment__c app = new Appointment__c(Assigned_To__c=i,Start__c=startdateListTemp[j],End__c=endDateListTemp[j].addHours(24),
                                                        Type__c='Unavailabilty',RecordTypeId=RecordtypeId,
                                                        Subject__c=Subject, Unavailability_Reason__c = reason, Call_Notes__c = notes);
                
                apptToInsert.add(app);
            }
            apptToInsert[apptToInsert.size()-1].End__c = endDateListTemp[endDateListTemp.size()-1];
        }
        System.debug('====Appt==='+apptToInsert);
        
        try{
            insert apptToInsert;
            
            Diary_Change__c d  = new Diary_Change__c(id = DiaryRequest , Status__c = 'Completed');
            update d;
        }
        catch (exception e)
        {
            System.debug('======Error======'+e);
        }  
    }
    
    map<string, string> subCodeMap = new map<string, string> ();
    
    @future(callout = true)
    public static void insertRoleSubpatches(Id DiaryRequest, set<Id> roleIds)
    {
        Diary_Change__c diaryChng = [Select id,Start__c,End__c,No_Of_Weeks__c, Week_2__c, Week_3__c, Week_4__c,Cycle__c from Diary_Change__c where id = :DiaryRequest];
        Map<integer, boolean> weekMap= new map<integer, boolean>{1=>true, 2=> diaryChng.Week_2__c, 3=>diaryChng.Week_3__c, 0 => diaryChng.Week_4__c};
            
            List<Diary_Change_Request__c> weeks = [Select Mon_AM_RoleWK1__c,Mon_PM_RoleWk1__c,Tue_AM_RoleWK1__c,Tue_PM_RoleWK1__c,Wed_AM_RoleWK1__c,Wed_PM_RoleWK1__c,Thu_AM_RoleWK1__c,
                                                   Thu_PM_RoleWk1__c,Fri_AM_RoleWK1__c,Fri_PM_RoleWK1__c,Sat_AM_RoleWK1__c,Sat_PM_RoleWK1__c,Sun_AM_RoleWK1__c,Sun_PM_RoleWK1__c from Diary_Change_Request__c 
                                                   where Diary_Change_Master__c =: DiaryRequest order by Week_Number__c limit 4] ;
        
        DiaryChangeHelperMethods obj = new DiaryChangeHelperMethods(); 
        if(weeks.size()<=4)
        {                   
            Map<string , list<list<List<Date>>>> subPacthDetails1 = obj.populateStartEndDates(weeks[0], diaryChng.Start__c.toStartOfWeek(), diaryChng.Start__c.toStartOfWeek().adddays(7));
            Map<string , list<list<List<Date>>>> subPacthDetails2 = new     Map<string , list<list<List<Date>>>>();
            Map<string , list<list<List<Date>>>> subPacthDetails3 = new     Map<string , list<list<List<Date>>>>();
            Map<string , list<list<List<Date>>>> subPacthDetails4 = new     Map<string , list<list<List<Date>>>>();
            
            if(weekMap.get(2))
                subPacthDetails2 = obj.populateStartEndDates(weeks[1], diaryChng.Start__c.toStartOfWeek().adddays(7), diaryChng.Start__c.toStartOfWeek().adddays(14));
            if(weekMap.get(3))
                subPacthDetails3 = obj.populateStartEndDates(weeks[2], diaryChng.Start__c.toStartOfWeek().adddays(14), diaryChng.Start__c.toStartOfWeek().adddays(21));
            if(weekMap.get(0))
                subPacthDetails4 = obj.populateStartEndDates(weeks[3], diaryChng.Start__c.toStartOfWeek().adddays(21), diaryChng.Start__c.toStartOfWeek().adddays(28));   
            
            
            system.debug('====='+subPacthDetails1);
            system.debug('====='+subPacthDetails2);
            system.debug('====='+subPacthDetails3);
            system.debug('====='+subPacthDetails4);
            
            
            
            set <string> completeSet =  new set<string>();
            completeSet.addall(subPacthDetails1.keyset());
            completeSet.addall(subPacthDetails2.keyset());
            completeSet.addall(subPacthDetails3.keyset());
            completeSet.addall(subPacthDetails4.keyset());
            
            
            for(Sub_Patch__c sub : [select id , name, code__c from Sub_Patch__c where Code__c in : completeSet])
            {
                obj.subCodeMap.put(sub.Code__c, sub.Id);
            }
            
            list<Role_Sub_Patch__c> finalInserList = new list<Role_Sub_Patch__c>();
            
            
            for(id role: roleIds)
            {
                
                Integer i=0;
                integer j=0;
                Integer reminder =0;
                if(diaryChng.Cycle__c == '3 Week')
                {
                    for(i=0;i<integer.valueof(diaryChng.No_Of_Weeks__c/3);i++){
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails1, role,j));
                        system.debug('Size 1--->'+finalInserList.size());
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails2, role,j));
                        system.debug('Size 2--->'+finalInserList.size());
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails3, role,j));
                        system.debug('Size 3--->'+finalInserList.size());
                        j+=3;
                    }
                    
                    reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),3);
                    
                }else{
                    
                    
                    for(i=0;i<integer.valueof(diaryChng.No_Of_Weeks__c/4);i++){
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails1, role,j));
                        system.debug('Size 1--->'+finalInserList.size());
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails2, role,j));
                        system.debug('Size 2--->'+finalInserList.size());
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails3, role,j));
                        system.debug('Size 3--->'+finalInserList.size());
                        finalInserList.addall(obj.createRoleSubPacth(subPacthDetails4, role,j));
                        system.debug('Size 4--->'+finalInserList.size());    
                        j+=4;
                    }
                    reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),4);
                }
                system.debug('--->'+i);
                //i+=4;
                
                system.debug(reminder);
                if(reminder==1)
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails1, role,j));
                else if(reminder==2){
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails1, role,j));
                    //j+=4;
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails2, role,j));            
                }
                else if(reminder==3){
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails1, role,j));
                    //j+=4;
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails2, role,j));
                    //j+=4;
                    finalInserList.addall(obj.createRoleSubPacth(subPacthDetails3, role,j));       
                } 
                
            }
            system.debug(finalInserList.size());
            system.debug(finalInserList);
            if(finalInserList.size()>0)
            {
                try{
                    insert finalInserList;
                    
                    update (new Diary_Change__c (Id = DiaryRequest, Status__c = 'Completed' , Sub_Status__c = 'Geography'));
                }
                catch (Exception e)
                {
                    update (new Diary_Change__c (Id = DiaryRequest, Status__c = 'Submitted'));
                }
            }
            
            
        }                 
        
        
    }
    
    
    public list<Role_Sub_Patch__c> createRoleSubPacth(Map<string , list<list<List<Date>>>> subPacthDetails, id role, integer i )
    {
        list<Role_Sub_Patch__c> returnList = new list<Role_Sub_Patch__c>();
        String type = 'Availability';
        
        for(string s: subPacthDetails.keyset())
        {
            for(List<List<Date>> dateList : subPacthDetails.get(s))
            {
                
                list<date> startdates = dateList[0];
                list<date> endDates =  dateList[1];
                
                system.debug('----->'+startdates);
                system.debug('----->'+endDates);
                system.debug('----->'+startdates.size());
                system.debug('----->'+endDates.size());
                for(integer j=0; j<startdates.size();j++)
                {
                    system.debug('in Creation---->'+startdates[j]);
                    system.debug('in Creation---->'+endDates[j]);
                    Role_Sub_Patch__c newRolePatch = new Role_Sub_Patch__c(Role__c=role,Type__c=type,Start_Date__c=startdates[j].adddays(i*7),
                                                                           End_Date__c=endDates[j].adddays(i*7),Sub_Patch__c=subCodeMap.get(s));
                    
                    
                    returnList.add(newRolePatch);   
                }                                                     
            }
        }
        
        return returnList;
    }
    
    public Map<string , list<list<List<Date>>>>  populateStartEndDates( Diary_Change_Request__c week1, Date startDate , Date endDate)
    {
        system.debug('Dairy Change request--> '+week1);
        integer finalweekDateforWeek1 =0;
        Map<string, Date> sunMap = new Map<string, Date>();
        Map<string, Date> monMap = new Map<string, Date>();
        Map<string, Date> tueMap = new Map<string, Date>();
        Map<string, Date> wedMap = new Map<string, Date>();
        Map<string, Date> thuMap = new Map<string, Date>();
        Map<string, Date> friMap = new Map<string, Date>();
        Map<string, Date> satMap = new Map<string, Date>();
        
        set<String> allPatches = new set<String> ();
        if(week1.Sun_AM_RoleWK1__c !=null )//|| week1.Sun_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =0;
            if(week1.Sun_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.Sun_AM_RoleWK1__c.Split(';') )
                {
                    sunMap.put(s, startDate);
                }
            }else
            {
                sunMap.put(week1.Sun_AM_RoleWK1__c,startDate);
            }
            /*
if(week1.Sun_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.Sun_PM_RoleWK1__c.Split(';') )
{
sunMap.put(s, startDate);
}
}else
{
sunMap.put(week1.Sun_PM_RoleWK1__c, startDate);
}*/
            allPatches.addall(sunMap.keyset());
            
        }
        
        if(week1.Mon_AM_RoleWK1__c !=null)// || week1.Mon_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =1;
            if(week1.mon_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.mon_AM_RoleWK1__c.Split(';') )
                {
                    monMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }ELSE
            {
                monMap.put(week1.Mon_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            /*
IF(week1.mon_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.mon_PM_RoleWK1__c.Split(';') )
{
monMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
monMap.put(week1.mon_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(monMap.keyset());
        }
        
        if(week1.Tue_AM_RoleWK1__c !=null )//|| week1.Tue_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 = 2;
            
            if(week1.tue_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.tue_AM_RoleWK1__c.Split(';') )
                {
                    tueMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }else
            {
                tueMap.put(week1.tue_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            
            /*if(week1.tue_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.tue_PM_RoleWK1__c.Split(';') )
{
tueMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
tueMap.put(week1.tue_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(tueMap.keyset());
        }
        
        if(week1.Wed_AM_RoleWK1__c !=null)// || week1.Wed_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =4;
            
            if(week1.wed_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.wed_AM_RoleWK1__c.Split(';') )
                {
                    wedMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }else
            {
                wedMap.put(week1.wed_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            /*
if(week1.wed_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.wed_PM_RoleWK1__c.Split(';') )
{
wedMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
wedMap.put(week1.wed_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(wedMap.keyset());
            
        }
        
        if(week1.Thu_AM_RoleWK1__c !=null)// || week1.Thu_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =5;
            
            if(week1.Thu_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.thu_AM_RoleWK1__c.Split(';') )
                {
                    thuMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }else
            {
                thuMap.put(week1.Thu_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            
            /*if(week1.thu_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.thu_PM_RoleWK1__c.Split(';') )
{
thuMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
thuMap.put(week1.thu_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(thuMap.keyset());
        }
        
        if(week1.Fri_AM_RoleWK1__c !=null)// || week1.Fri_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =6;
            
            if(week1.fri_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.fri_AM_RoleWK1__c.Split(';') )
                {
                    friMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }else
            {
                friMap.put(week1.fri_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            /*
if(week1.fri_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.fri_PM_RoleWK1__c.Split(';') )
{
friMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
friMap.put(week1.fri_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(friMap.keyset());
        }
        
        if(week1.Sat_AM_RoleWK1__c !=null) //|| week1.Sat_PM_RoleWK1__c !=null)
        {
            finalweekDateforWeek1 =7;
            
            if(week1.sat_AM_RoleWK1__c.contains(';'))
            {
                for(string s:week1.sat_AM_RoleWK1__c.Split(';') )
                {
                    satMap.put(s, startDate.addDays(finalweekDateforWeek1));
                }
            }else
            {
                satMap.put(week1.sat_AM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
            }
            /*
if(week1.sat_PM_RoleWK1__c.contains(';'))
{
for(string s:week1.sat_PM_RoleWK1__c.Split(';') )
{
satMap.put(s, startDate.addDays(finalweekDateforWeek1));
}
}else
{
satMap.put(week1.sat_PM_RoleWK1__c, startDate.addDays(finalweekDateforWeek1));
}*/
            allPatches.addall(SatMap.keyset());
        }
        
        system.debug('All Patches===>'+allPatches);
        system.debug('--->'+sunMap);
        system.debug('--->'+tueMap);
        system.debug('--->'+wedMap);
        system.debug('--->'+thuMap);
        system.debug('--->'+friMap);
        system.debug('--->'+satMap);
        
        
        map <string , List<list<integer>>> startEndPacth = new map <string , list<list<integer>>>();
        
        for(string s : allPatches)
        {
            
            integer startDay ;
            integer endDay;
            
            if(monMap.ContainsKey(s))
            {
                if(startDay==null)
                {
                    startDay = 0;
                    endDay = 0;
                }   
                else
                {
                    endDay +=1;
                }   
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            if(tueMap.Containskey(s))
            {
                if(startDay ==null)
                {
                    startDay = 1;
                    endDay = 1;
                }else
                {
                    endDay +=1;
                    
                }
                
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            if(wedMap.Containskey(s))
            {
                if(startDay ==null)
                {
                    startDay = 2;
                    endDay = 2;
                }else
                {
                    endDay +=1;
                    
                }
                
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            
            if(thuMap.Containskey(s))
            {
                if(startDay ==null)
                {
                    startDay = 3;
                    endDay = 3;
                }else
                {
                    endDay +=1;
                    
                }
                
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            
            if(friMap.Containskey(s))
            {
                if(startDay ==null)
                {
                    startDay = 4;
                    endDay = 4;
                }else
                {
                    endDay +=1;
                    
                }
                
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            
            if(satMap.Containskey(s))
            {
                if(startDay ==null)
                {
                    startDay = 5;
                    endDay = 5;
                }else
                {
                    endDay +=1;
                    
                }
                
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            
            if(sunMap.ContainsKey(s))
            {
                if(startDay==null)
                {
                    startDay = 6;
                    endDay = 6;
                }   
                else
                {
                    endDay +=1;
                }   
            }else if(startDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
                startDay = NULL;
                endDay = NULL;
            }
            
            if(startDay!=null && endDay!=null)
            {
                list<List<integer>> temp = new list<LIST<INTEGER>>(); //{startDay,  endDay}; 
                if(startEndPacth.containskey(s))
                {
                    temp.addall(startEndPacth.get(s));
                }
                temp.add(new list<integer>{startDay,  endDay});
                startEndPacth.put(s,temp);
            }
            
        }
        system.debug('----->'+startEndPacth);
        
        Map<string , list<list<List<Date>>>> patchStartEndDateMap = new Map<string , list<list<List<Date>>>> ();
        
        for(string s: startEndPacth.keyset())
        {
            for(list<integer> i : startEndPacth.get(s))
            {
                list<Date> startdateListWeek1 = new list<Date>();
                List<Date> endDateListWeek1 = new list<Date>();
                list<List<Date>> finalList = new list<List<Date>> ();
                integer startday = i[0];
                integer endDay = i[1];
                
                startdateListWeek1.add(startDate.adddays(startday));
                
                Date startofWeek = startDate.toStartOfWeek() ;
                Date EndoftheWeek =  startofWeek.addDays(endDay);
                date actualEnd = startofWeek.addDays(6);
                //integer diffIndaysToStart = 7-endDay;
                system.debug('Start Date-->'+startDate);
                system.debug('EndDate -->'+endDate);
                
                system.debug('startofWeek -- >'+ startofWeek);
                system.debug('EndoftheWeek -- >'+ EndoftheWeek);
                system.debug('actualEnd -- >'+ actualEnd);
                boolean dontadd=false ;
                while(actualEnd<endDate)
                {
                    endDateListWeek1.add(EndoftheWeek);
                    if(actualEnd.addDays(startday+1)<endDate)
                    {
                        startdateListWeek1.add(actualEnd.addDays(startday+1));
                    }else
                    {
                        dontadd = true;
                    }
                    EndoftheWeek = actualEnd.addDays(endDay+1);
                    actualEnd = actualEnd.adddays(7);
                    system.debug('actualEnd -- >'+ actualEnd);
                    system.debug('startdateListWeek1 -->'+startdateListWeek1);
                    system.debug('endDateListWeek1--- >'+endDateListWeek1);
                }
                system.debug('EndoftheWeek2 -- >'+ EndoftheWeek);
                if(!dontadd) 
                    endDateListWeek1.add(EndoftheWeek);
                
                
                finalList.add(startdateListWeek1);
                finalList.add(endDateListWeek1);
                system.debug('Final List -- >'+finalList);
                list<list<List<Date>>> tempList = new list<list<List<Date>>>();
                if(patchStartEndDateMap.containskey(s))
                {
                    templist = patchStartEndDateMap.get(s);
                }
                
                templist.add(finalList);
                patchStartEndDateMap.put(s, templist);
                //return finalList;
            }
        }
        system.debug('patchStartEndDateMap--->'+patchStartEndDateMap);
        return patchStartEndDateMap;
    }
    
    @future(callout = false)
    public static void inserAppointments(set<Id> empIdset, id diaryChngId)
    {     

     List<Appointment__c> appointmentList = New List<Appointment__c>();
     Diary_Change__c diaryChng = [Select id,Shift_template__c,Shift_template__r.Week_1__c,Shift_template__r.Week_2__c,Shift_template__r.Week_3__c,Shift_template__r.Week_4__c,RecordTypeId,RecordType.Name,Employee__c,Employee_Group__c,Start__c,End__c,No_Of_Weeks__c,Week_1__c,Week_2__c,Week_3__c,Week_4__c,Employee__r.Name,Employee_Group__r.Name,Employee__r.Role__c,Unavailability_Reason__c, Unavailability_Notes__c,Subject__c , Cycle__c from Diary_Change__c where id = :diaryChngId];
     
     datetime stratTime = diaryChng.Start__c;
    
     //String assignedTo = diaryChng.Employee__c;
     //integer offset = diaryChangeHelperMethods.getTZOffset(startdate.Date());
     List<Week_template__c> weekRecordsList = new List<Week_template__c>();
     List<Week_template__c> week1RecordsList = new List<Week_template__c>();
     List<Week_template__c> week2RecordsList = new List<Week_template__c>();
     List<Week_template__c> week3RecordsList = new List<Week_template__c>();
     List<Week_template__c> week4RecordsList = new List<Week_template__c>();

     
     for(Week_template__c temp:[SELECT Id, Type__c, Shift_template__c, Day_name__c, Week_name__c, Number_of_Appointments__c, End_time__c, Start_time__c, Name FROM Week_template__c WHERE Shift_template__c =: diaryChng.Shift_template__c]){
         weekRecordsList.add(temp);
         System.debug('weekRecordsList--->'+temp);
     }
     integer j=1;
     for(Week_template__c temp : weekRecordsList )
     {
         if(temp.Week_name__c == 'Week 1')
         {
             week1RecordsList.add(temp); 
             System.debug('week1RecordsList--->'+week1RecordsList);

         }
         if(temp.Week_name__c == 'Week 2')
         {
             week2RecordsList.add(temp);
             System.debug('week2RecordsList--->'+week2RecordsList);
         }
         if(temp.Week_name__c == 'Week 3')
         {
             week3RecordsList.add(temp); 
             System.debug('week3RecordsList--->'+week3RecordsList);
         }
         if(temp.Week_name__c == 'Week 4')
         {
             week4RecordsList.add(temp);  
             System.debug('week4RecordsList--->'+week4RecordsList);
         }
     }
     list<list<Week_template__c>> newWeeklist = new list<list<Week_template__c>>();
     newWeeklist.add(week1RecordsList);
     newWeeklist.add(week2RecordsList);
     newWeeklist.add(week3RecordsList);
     newWeeklist.add(week4RecordsList);

    integer reminder = 0;
    integer l = 7;

    diaryChangeHelperMethods obj = new diaryChangeHelperMethods();

    if(diaryChng.Cycle__c == '3 Week')
    {
        if(diaryChng.No_Of_Weeks__c>=3){
            for(Integer i=1;i<=diaryChng.No_Of_Weeks__c/3;i++){
                //weekDetails.addall(weekList);
                
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[0], stratTime));
                  
                    stratTime = stratTime.adddays(l);
                if(diaryChng.Shift_template__r.Week_2__c)
                {
                    
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[1], stratTime));
                }
                stratTime = stratTime.adddays(l);
                if(diaryChng.Shift_template__r.Week_3__c)
                {
                    
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[2], stratTime));
                }
                stratTime = stratTime.adddays(l);
            }
        }
        
        reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),3);
        
    }
    else
    {
        if(diaryChng.No_Of_Weeks__c>=4){
            for(Integer i=1;i<=diaryChng.No_Of_Weeks__c/4;i++){
                //weekDetails.addall(weekList);
                
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[0], stratTime));
                  
                    stratTime = stratTime.adddays(l);
                if(diaryChng.Shift_template__r.Week_2__c)
                {
                    
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[1], stratTime));
                }
                stratTime = stratTime.adddays(l);
                if(diaryChng.Shift_template__r.Week_3__c)
                {
                    
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[2], stratTime));
                }
                stratTime = stratTime.adddays(l);
                if(diaryChng.Shift_template__r.Week_4__c)
                {
                    appointmentList.addall(obj.populateDynamicApp(newWeeklist[3], stratTime));
                }
                stratTime = stratTime.adddays(l);
            }
        }
        
        reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),3);

        if(reminder==3 || reminder==2  || reminder==1 )
        {
            appointmentList.addall(obj.populateDynamicApp(newWeeklist[0], stratTime));

        }
        stratTime = stratTime.adddays(l);
        if(reminder==3 || reminder==2   )
        {
            appointmentList.addall(obj.populateDynamicApp(newWeeklist[1], stratTime));

        }
        stratTime = stratTime.adddays(l);
        if(reminder==3)
        {
            appointmentList.addall(obj.populateDynamicApp(newWeeklist[2], stratTime));

        }
        stratTime = stratTime.adddays(l);

    /*
         if(week1RecordsList.size()>0)
         {
             for(Week_template__c temp: week1RecordsList)
             {
                 if(temp.Day_name__c == 'Monday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     System.debug('startTimeHour-->'+startTimeHour);
                     startTimeMinute = temp.Start_time__c.minute();
                     System.debug('startTimeMinute--->'+startTimeMinute);
                     endTimeHour = temp.End_time__c.hour() - 1;
                     System.debug('endTimeHour---->'+endTimeHour);
                     endTimeMinute = temp.End_time__c.minute();
                     System.debug('endTimeMinute---->'+endTimeMinute);
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                     System.debug('Start time ---->'+temp.Start_time__c);
                     System.debug('Start time date --->'+stratTime.addHours(startTimeHour).addMinutes(startTimeMinute));
                     System.debug('End date time---->'+stratTime.addHours(endTimeHour).addMinutes(endTimeMinute));
                 }
                 if(temp.Day_name__c == 'Tuesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(1).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(1).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Wednesday')
                 { 
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(2).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(2).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Thursday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(3).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(3).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Friday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(4).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(4).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Saturday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++) 
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(5).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(5).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Sunday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(6).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(6).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
             }
         }
         if(week2RecordsList.size()>0)
         {
             for(Week_template__c temp: week2RecordsList)
             {
                 if(temp.Day_name__c == 'Monday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(7).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(7).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Tuesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(8).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(8).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Wednesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(9).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(9).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Thursday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(10).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(10).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Friday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(11).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(11).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Saturday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(12).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(12).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Sunday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(13).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(13).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
             }
         }
         if(week3RecordsList.size()>0)
         {
             for(Week_template__c temp: week3RecordsList)
             {
                 if(temp.Day_name__c == 'Monday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(14).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(14).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Tuesday')
                 {  for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                     
                     
                  startTimeHour = temp.Start_time__c.hour() - 1;
                  startTimeMinute = temp.Start_time__c.minute();
                  endTimeHour = temp.End_time__c.hour() - 1;
                  endTimeMinute = temp.End_time__c.minute();
                  appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(15).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(15).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Wednesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(16).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(16).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Thursday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(17).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(17).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Friday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(18).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(18).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Saturday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(19).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(19).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Sunday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(20).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(20).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
             }
         }
         if(week4RecordsList.size()>0)
         {
             for(Week_template__c temp: week4RecordsList)
             {
                 if(temp.Day_name__c == 'Monday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(21).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(21).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Tuesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(22).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(22).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Wednesday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(23).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(23).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Thursday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(24).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(24).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Friday')
                 {
                     for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                         
                         
                     startTimeHour = temp.Start_time__c.hour() - 1;
                     startTimeMinute = temp.Start_time__c.minute();
                     endTimeHour = temp.End_time__c.hour() - 1;
                     endTimeMinute = temp.End_time__c.minute();
                     appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(25).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(25).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                            Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                            Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Saturday')
                 {  for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                     
                     
                  startTimeHour = temp.Start_time__c.hour() - 1;
                  startTimeMinute = temp.Start_time__c.minute();
                  endTimeHour = temp.End_time__c.hour() - 1;
                  endTimeMinute = temp.End_time__c.minute();
                  appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(26).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(26).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
                 if(temp.Day_name__c == 'Sunday')
                 {  for(Integer i =0; i < temp.Number_of_Appointments__c; i++)
                     
                     
                  startTimeHour = temp.Start_time__c.hour() - 1;
                  startTimeMinute = temp.Start_time__c.minute();
                  endTimeHour = temp.End_time__c.hour() - 1;
                  endTimeMinute = temp.End_time__c.minute();
                  appointmentList.add(new Appointment__c(Assigned_To__c=diaryChng.Employee__c,Time_Band__c=null,StartTime__c=temp.Start_time__c,EndTime__c=temp.End_time__c,Start__c = stratTime.addDays(27).addHours(startTimeHour).addMinutes(startTimeMinute),End__c=stratTime.addDays(27).addHours(endTimeHour).addMinutes(endTimeMinute),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,RecordTypeId=recType,Type__c='Sales',
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false)); 
                 }
             }
         }
         */
    }
     if(empIdset.size()>=1)
     {   System.debug('Inside the empgroup check 123');
         list<Appointment__c > finalList = new list<Appointment__c >();
         for(id i:  empIdset)
         {
             Appointment__c newAPP = new Appointment__c();
             for(Appointment__c a:appointmentList )
             {
                 newAPP = a.clone(true);
                 newAPP.Assigned_To__c = i;
                 finalList.add(newAPP);
             }
         }
         try{ 
             System.debug('Inside the try statement for inserting final list');
             insert finalList;
         }catch(Exception e){
             System.debug('Exception caught in inserting final list');
         }
      system.debug('f1'+finalList);
         
     }else
     {
         if(appointmentList.size() > 0) {
             //try{ 
             //for(Appointment__c app : appointmentList){
             System.debug('Inside the else statement for inserting the appointment list');
             Insert appointmentList;
             //}
             //}
             //catch(Exception e) {
             //}
         }
         system.debug(appointmentList);
         
     }
     
    }

    public final map<string, integer> daymap = new map<string, integer> {'Monday' => 0, 'Tuesday' => 1 , 'Wednesday' => 2 , 'Thursday' => 3, 'Friday' => 4 , 'Saturday' => 5 , 'Sunday' =>6}; 

    public list<Appointment__c> populateDynamicApp(list<Week_template__c> appList , DateTime StartTime)
    {
        String ShowTime = 'Out of Office';
        String Subject = 'Available';
        id recType = '012200000004iOLAAY';
        StartTime = StartTime.date().tostartofWeek();

        list<Appointment__c> returnList = new list<Appointment__c>();

        for(Week_template__c app:  appList)
        {
            integer dayOffset = daymap.get(app.Day_name__c);

            integer offset = diaryChangeHelperMethods.getTZOffset(StartTime.addDays(dayOffset).date());
            for(Integer i = 0 ; i< integer.valueof(app.Number_of_Appointments__c) ; i++)
            {
                Appointment__c appvar  = new Appointment__c(Start__c=StartTime.addDays(dayOffset).addHours(app.Start_time__c.hour() -1 + offset).addMinutes(app.Start_time__c.Minute()),
                                                        End__c=StartTime.addDays(dayOffset).addHours(app.End_time__c.hour() -1 + offset).addMinutes(app.End_time__c.Minute()),
                                                        Show_Time_As__c=ShowTime,Type__c=app.Type__c,RecordTypeId=recType,Subject__c=Subject);
                returnList.add(appvar);
            }

            
        }

        return returnList;

    }
    /*
    @future(callout = false)
    public static void inserAppointmentsTemp(set<Id> empIdset, id diaryChngId)
    {
        //boolean w2, w3, w4 = false;
        
        Diary_Change__c diaryChng = [Select id,RecordTypeId,RecordType.Name,Employee__c,Employee_Group__c,Start__c,End__c,No_Of_Weeks__c,Week_1__c,Week_2__c,Week_3__c,Week_4__c,Employee__r.Name,Employee_Group__r.Name,Employee__r.Role__c,Unavailability_Reason__c, Unavailability_Notes__c,Subject__c , Cycle__c from Diary_Change__c where id = :diaryChngId];
        
        Map<integer, boolean> weekMap= new map<integer, boolean>{1=>true, 2=> diaryChng.Week_2__c, 3=>diaryChng.Week_3__c, 0 => diaryChng.Week_4__c};
            
            List<Diary_Change_request__c> weekList;
        /* 
        [Select d.Wed_PM_RoleWK1__c, d.Wed_PM_ApptWk1__c, d.Wed_Non_Op_PM_ApptWK1__c, d.Wed_Non_Op_Any_ApptWK1__c, d.Wed_Non_Op_AM_ApptWK1__c, 
d.Wed_GD_PMWK1__c, d.Wed_GD_AMWK1__c, d.Wed_EV_ApptWK1__c, d.Wed_Any_ApptWk1__c, d.Wed_AM_ApptWk1__c, d.Wed_19_20WK1__c, 
d.Wed_17_19WK1__c, d.Wed_15_17WK1__c, d.Wed_13_15WK1__c, d.Wed_11_13WK1__c, d.Wed_09_11WK1__c, d.Wed_07_09WK1__c, 
d.Tue_PM_ApptWk1__c, d.Tue_Non_Op_PM_ApptWK1__c, d.Tue_Non_Op_Any_ApptWK1__c, d.Tue_Non_Op_AM_ApptWK1__c, d.Tue_GD_PMWK1__c,
d.Tue_GD_AMWK1__c, d.Tue_EV_ApptWK1__c, d.Tue_Any_ApptWK1__c, d.Tue_AM_ApptWk1__c, d.Tue_19_20WK1__c, d.Tue_17_19WK1__c, d.Tue_15_17WK1__c,
d.Tue_13_15WK1__c, d.Tue_11_13WK1__c, d.Tue_09_11WK1__c, d.Tue_07_09WK1__c, d.Thu_PM_ApptWk1__c, d.Thu_Non_Op_PM_ApptWK1__c, d.Thu_Non_Op_Any_ApptWK1__c, 
d.Thu_Non_Op_AM_ApptWK1__c, d.Thu_GD_PMWK1__c, d.Thu_GD_AMWK1__c, d.Thu_EV_ApptWK1__c, d.Thu_Any_ApptWk1__c, d.Thu_AM_RoleWK1__c, d.Thu_AM_ApptWk1__c,
d.Thu_19_20WK1__c, d.Thu_17_19WK1__c, d.Thu_15_17WK1__c, d.Thu_13_15WK1__c, d.Thu_11_13WK1__c, d.Thu_09_11WK1__c, d.Thu_07_09WK1__c, d.Sun_PM_ApptWk1__c,
d.Sun_Non_Op_PM_ApptWK1__c, d.Sun_Non_Op_Any_ApptWK1__c, d.Sun_Non_Op_AM_ApptWK1__c, d.Sun_GD_PMWK1__c, d.Sun_GD_AMWK1__c, d.Sun_EV_ApptWK1__c, d.Sun_Any_ApptWk1__c,
d.Sun_AM_RoleWK1__c, d.Sun_AM_ApptWk1__c, d.Sun_19_20WK1__c, d.Sun_17_19WK1__c, d.Sun_15_17WK1__c, d.Sun_13_15WK1__c, d.Sun_11_13WK1__c, d.Sun_09_11WK1__c, d.Sun_07_09WK1__c,
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
d.Sun_17_00_17_40_App_Type__c,d.Sun_17_40_18_20_App_Type__c,d.Sun_18_20_19_00_App_Type__c,d.Sun_19_00_19_40_App_Type__c,d.Shift_template__c                               
From Diary_Change_Request__c d where Diary_Change_Master__c =: diaryChng.id order by Week_Number__c limit 4]; */
        /*
        list<Appointment__c> apptDetailsTemp = new list<Appointment__c>();
        
        //list<Diary_Change_request__c> weekDetails = new list<Diary_Change_request__c> ();
        date StartDate = diaryChng.Start__c.tostartofweek();
        
        datetime stratTime = StartDate;
        integer l =7;
        DiaryChangeHelperMethods obj = new DiaryChangeHelperMethods();
        System.debug('============'+diaryChng.No_Of_Weeks__c/4);
        
        Integer reminder = 0;
        
        if(diaryChng.Cycle__c == '3 Week')
        {
            if(diaryChng.No_Of_Weeks__c!=1 && diaryChng.No_Of_Weeks__c!=2){
                for(Integer i=1;i<=diaryChng.No_Of_Weeks__c/3;i++){
                    //weekDetails.addall(weekList);
                    
                    apptDetailsTemp.addall(obj.populateApp(weekList[0],l, stratTime, diaryChng.Employee__c));
                    system.debug('Start Time-->'+stratTime+' '+l);
                    stratTime = stratTime.adddays(l);
                    if(diaryChng.Week_2__c)
                    {
                        system.debug('Start Time-->'+stratTime+' '+l);
                        apptDetailsTemp.addall(obj.populateApp(weekList[1],l, stratTime, diaryChng.Employee__c));
                    }
                    stratTime = stratTime.adddays(l);
                    if(diaryChng.Week_3__c)
                    {
                        system.debug('Start Time-->'+stratTime+' '+l);
                        apptDetailsTemp.addall(obj.populateApp(weekList[2],l, stratTime, diaryChng.Employee__c));
                    }
                    stratTime = stratTime.adddays(l);
                }
            }
            
            reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),3);
            
        }else
        {
            if(diaryChng.No_Of_Weeks__c!=1 && diaryChng.No_Of_Weeks__c!=2 && diaryChng.No_Of_Weeks__c!=3){
                for(Integer i=1;i<=diaryChng.No_Of_Weeks__c/4;i++){
                    //weekDetails.addall(weekList);
                    
                    apptDetailsTemp.addall(obj.populateApp(weekList[0],l, stratTime, diaryChng.Employee__c));
                    system.debug('Start Time-->'+stratTime+' '+l);
                    stratTime = stratTime.adddays(l);
                    if(diaryChng.Week_2__c)
                    {
                        system.debug('Start Time-->'+stratTime+' '+l);
                        apptDetailsTemp.addall(obj.populateApp(weekList[1],l, stratTime, diaryChng.Employee__c));
                    }
                    stratTime = stratTime.adddays(l);
                    if(diaryChng.Week_3__c)
                    {
                        system.debug('Start Time-->'+stratTime+' '+l);
                        apptDetailsTemp.addall(obj.populateApp(weekList[2],l, stratTime, diaryChng.Employee__c));
                    }
                    stratTime = stratTime.adddays(l);
                    
                    if(diaryChng.Week_4__c)
                    {
                        system.debug('Start Time-->'+stratTime+' '+l);
                        apptDetailsTemp.addall(obj.populateApp(weekList[3],l, stratTime, diaryChng.Employee__c));
                    }
                    stratTime = stratTime.adddays(l);
                    
                }
            }
            reminder =  math.mod((diaryChng.No_Of_Weeks__c).intValue(),4);
        }
        
        
        
        system.debug(LoggingLevel.INFO,'reminder-->'+reminder+' '+l);
        //l-=7;
        //stratTime = stratTime.adddays(l);
        if(reminder!=0){
            if(reminder==1)
            {
                //weekDetails.add(weekList[0]);
                system.debug('Start Time-->'+stratTime+' '+l);
                apptDetailsTemp.addall(obj.populateApp(weekList[0],l, stratTime, diaryChng.Employee__c));
            }
            else if(reminder==2){
                //weekDetails.add(weekList[0]);
                system.debug(LoggingLevel.INFO,'Start Time-->'+stratTime+' '+l);
                apptDetailsTemp.addall(obj.populateApp(weekList[0],l, stratTime, diaryChng.Employee__c));
                if(weekList.size()>=2 && diaryChng.Week_2__c)
                {
                    //weekDetails.add(weekList[1]); 
                    system.debug('Start Time-->'+stratTime+' '+l);
                    //l+=7;
                    stratTime = stratTime.adddays(l);            
                    apptDetailsTemp.addall(obj.populateApp(weekList[1],l, stratTime, diaryChng.Employee__c));
                }
            }
            else if(reminder==3){
                system.debug('Start Time-->'+stratTime+' '+l);
                apptDetailsTemp.addall(obj.populateApp(weekList[0],l, stratTime, diaryChng.Employee__c));
                if(weekList.size()>=2 && diaryChng.Week_2__c)
                {
                    //l+=7;
                    stratTime = stratTime.adddays(l); 
                    system.debug('Start Time-->'+stratTime+' '+l);
                    //weekDetails.add(weekList[1]);
                    apptDetailsTemp.addall(obj.populateApp(weekList[1],l, stratTime, diaryChng.Employee__c));
                }
                if(weekList.size()>=3 && diaryChng.Week_3__c)
                {
                    //weekDetails.add(weekList[2]);   
                    //l+=7;
                    stratTime = stratTime.adddays(l);    
                    system.debug('Start Time-->'+stratTime+' '+l);
                    apptDetailsTemp.addall(obj.populateApp(weekList[2],l,stratTime, diaryChng.Employee__c));    
                }  
            }  
        }
        
        
        
        
        system.debug('Emp -->'+empIdset.Size()+' '+apptDetailsTemp);
        if(empIdset.Size()>1)
        {
            list<Appointment__c > finalList = new list<Appointment__c >();
            for(id i:  empIdset)
            {
                Appointment__c newAPP = new Appointment__c();
                for(Appointment__c a:apptDetailsTemp )
                {
                    newAPP = a.clone(true);
                    newAPP.Assigned_To__c = i;
                    finalList.add(newAPP);
                }
                
                
            }
            try{ 
                insert finalList;
            }catch(Exception e){}
            
        }else
        {
            if(apptDetailsTemp.size()>0)
            {
                try{
                    insert apptDetailsTemp;
                }catch (Exception e){}
                
            }
        }
        
        
        
        
        
        
    }
    */
    
    /*
    public list <Appointment__c> populateApp(Diary_Change_request__c week, integer k, datetime startdate,id assignedTo)
    {
        list<Appointment__c > apptDetailsTemp = new list<Appointment__c>();
        //String ShowTime = 'Out of Office';
        //String Subject = 'Available';
        //string assignedTo =;
        //id recType = '012200000004iOLAAY';
        //dateTime d= datetime.valueOf(system.label.Daylightsaving);
        
        apptDetailsTemp.addAll(normalAppointments(week,k,startdate,assignedTo));
        apptDetailsTemp.addAll(straightSwapAppointments(week,k,startdate,assignedTo));
        
        
        return apptDetailsTemp;
    }
    */
    /*
    public list <Appointment__c> normalAppointments(Diary_Change_request__c week, integer k, datetime startdate,id assignedTo){
        
        String ShowTime = 'Out of Office';
        String Subject = 'Available';
        list<Appointment__c> apptDetailsTemp = new list<Appointment__c>();
        id recType = '012200000004iOLAAY';
        integer offset = diaryChangeHelperMethods.getTZOffset(startdate.Date());
        if(week.Mon_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Mon_AM_ApptWk1__c.intValue();i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addHours(6+offset),End__c=startdate.addHours(12+offset ),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Mon_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addHours(12 + offset),End__c=startdate.addHours(16  + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Mon_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addHours(16 + offset).addMinutes(30),End__c=startdate.addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Mon_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addHours(6 + offset),End__c=startdate.addHours(20 + offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Mon_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_07_09WK1__c!=null){
            for(Integer i=0;i<week.Mon_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(6 + offset),End__c=startdate.addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_09_11WK1__c!=null){
            for(Integer i=0;i<week.Mon_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours( 8  + offset),End__c=startdate.addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_11_13WK1__c!=null){
            for(Integer i=0;i<week.Mon_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(10  + offset),End__c=startdate.addHours(12  + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_13_15WK1__c!=null){
            for(Integer i=0;i<week.Mon_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(12  + offset),End__c=startdate.addhours( 14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_15_17WK1__c!=null){
            for(Integer i=0;i<week.Mon_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours( 14  + offset).addMinutes(30),End__c=startdate.addHours( 16  + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_17_19WK1__c!=null){
            for(Integer i=0;i<week.Mon_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(16 + offset).addMinutes(30),End__c=startdate.addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Mon_19_20WK1__c!=null){
            for(Integer i=0;i<week.Mon_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(18 + offset),End__c=startdate.addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        
        //==================================Tuesday==========================================
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(1).Date());
        
        if(week.Tue_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Tue_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(1).addHours(6 + offset),End__c=startdate.addDays(1).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Tue_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(1).addHours(12 + offset),End__c=startdate.addDays(1).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Tue_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(1).addHours(16 + offset).addMinutes(30) ,End__c=startdate.addDays(1).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Tue_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(1).addHours(6+ offset),End__c=startdate.addDays(1).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Tue_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_07_09WK1__c!=null){
            for(Integer i=0;i<week.Tue_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(6 + offset),End__c=startdate.addDays(1).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_09_11WK1__c!=null){
            for(Integer i=0;i<week.Tue_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(8 + offset),End__c=startdate.addDays(1).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_11_13WK1__c!=null){
            for(Integer i=0;i<week.Tue_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(10 + offset),End__c=startdate.addDays(1).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_13_15WK1__c!=null){
            for(Integer i=0;i<week.Tue_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(12 + offset),End__c=startdate.addDays(1).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_15_17WK1__c!=null){
            for(Integer i=0;i<week.Tue_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(1).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_17_19WK1__c!=null){
            for(Integer i=0;i<week.Tue_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(1).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Tue_19_20WK1__c!=null){
            for(Integer i=0;i<week.Tue_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(18 + offset),End__c=startdate.addDays(1).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //=============================================Wednesday============================================
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(2).Date());
        
        if(week.Wed_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Wed_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(2).addHours(6 + offset),End__c=startdate.addDays(2).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Wed_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(2).addHours(12 + offset),End__c=startdate.addDays(2).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Wed_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(2).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(2).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Wed_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(2).addHours(6+ offset),End__c=startdate.addDays(2).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Wed_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_07_09WK1__c!=null){
            for(Integer i=0;i<week.Wed_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(6 + offset),End__c=startdate.addDays(2).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_09_11WK1__c!=null){
            for(Integer i=0;i<week.Wed_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(8 + offset),End__c=startdate.addDays(2).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_11_13WK1__c!=null){
            for(Integer i=0;i<week.Wed_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(10 + offset),End__c=startdate.addDays(2).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_13_15WK1__c!=null){
            for(Integer i=0;i<week.Wed_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(12 + offset),End__c=startdate.addDays(2).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_15_17WK1__c!=null){
            for(Integer i=0;i<week.Wed_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(2).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_17_19WK1__c!=null){
            for(Integer i=0;i<week.Wed_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(2).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Wed_19_20WK1__c!=null){
            for(Integer i=0;i<week.Wed_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(18 + offset),End__c=startdate.addDays(2).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        
        //============================================Thursday==========================================================================================================
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(3).Date());
        
        if(week.Thu_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Thu_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(3).addHours(6 + offset),End__c=startdate.addDays(3).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Thu_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(3).addHours(12 + offset),End__c=startdate.addDays(3).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Thu_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(3).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(3).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Thu_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(3).addHours(6+ offset),End__c=startdate.addDays(3).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Thu_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_07_09WK1__c!=null){
            for(Integer i=0;i<week.Thu_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(6 + offset),End__c=startdate.addDays(3).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_09_11WK1__c!=null){
            for(Integer i=0;i<week.Thu_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(8 + offset),End__c=startdate.addDays(3).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_11_13WK1__c!=null){
            for(Integer i=0;i<week.Thu_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(10 + offset),End__c=startdate.addDays(3).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_13_15WK1__c!=null){
            for(Integer i=0;i<week.Thu_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(12 + offset),End__c=startdate.addDays(3).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_15_17WK1__c!=null){
            for(Integer i=0;i<week.Thu_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(3).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_17_19WK1__c!=null){
            for(Integer i=0;i<week.Thu_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(3).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Thu_19_20WK1__c!=null){
            for(Integer i=0;i<week.Thu_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(18 + offset),End__c=startdate.addDays(3).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        
        //=============================================Friday======================================================================================================================
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(4).Date());
        
        if(week.Fri_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Fri_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(4).addHours(6 + offset),End__c=startdate.addDays(4).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Fri_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(4).addHours(12 + offset),End__c=startdate.addDays(4).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Fri_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(4).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(4).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Fri_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(4).addHours(6+ offset),End__c=startdate.addDays(4).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Fri_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_07_09WK1__c!=null){
            for(Integer i=0;i<week.Fri_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(6 + offset),End__c=startdate.addDays(4).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_09_11WK1__c!=null){
            for(Integer i=0;i<week.Fri_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(8 + offset),End__c=startdate.addDays(4).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_11_13WK1__c!=null){
            for(Integer i=0;i<week.Fri_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(10 + offset),End__c=startdate.addDays(4).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_13_15WK1__c!=null){
            for(Integer i=0;i<week.Fri_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(12 + offset),End__c=startdate.addDays(4).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_15_17WK1__c!=null){
            for(Integer i=0;i<week.Fri_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(4).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_17_19WK1__c!=null){
            for(Integer i=0;i<week.Fri_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(4).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Fri_19_20WK1__c!=null){
            for(Integer i=0;i<week.Fri_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(18 + offset),End__c=startdate.addDays(4).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //======================================================Saturday==============================================================================================================
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(5).Date());
        
        if(week.Sat_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sat_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(5).addHours(6 + offset),End__c=startdate.addDays(5).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sat_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(5).addHours(12 + offset),End__c=startdate.addDays(5).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sat_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(5).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(5).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sat_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(5).addHours(6+ offset),End__c=startdate.addDays(5).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Sat_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_07_09WK1__c!=null){
            for(Integer i=0;i<week.Sat_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(6 + offset),End__c=startdate.addDays(5).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_09_11WK1__c!=null){
            for(Integer i=0;i<week.Sat_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(8 + offset),End__c=startdate.addDays(5).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_11_13WK1__c!=null){
            for(Integer i=0;i<week.Sat_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(10 + offset),End__c=startdate.addDays(5).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_13_15WK1__c!=null){
            for(Integer i=0;i<week.Sat_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(12 + offset),End__c=startdate.addDays(5).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_15_17WK1__c!=null){
            for(Integer i=0;i<week.Sat_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(5).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_17_19WK1__c!=null){
            for(Integer i=0;i<week.Sat_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(5).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sat_19_20WK1__c!=null){
            for(Integer i=0;i<week.Sat_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(18 + offset),End__c=startdate.addDays(5).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //=============================================Sunday=================================== ================================================================   
        
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(6).Date());
        
        if(week.Sun_AM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sun_AM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='AM',Start__c=startdate.addDays(6).addHours(6 + offset),End__c=startdate.addDays(6).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_AM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_PM_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sun_PM_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='PM',Start__c=startdate.addDays(6).addHours(12 + offset),End__c=startdate.addDays(6).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_PM_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_EV_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sun_EV_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='EV',Start__c=startdate.addDays(6).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(6).addHours(19 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_EV_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_Any_ApptWk1__c!=null){
            for(Integer i=0;i<week.Sun_Any_ApptWk1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c='Any',Start__c=startdate.addDays(6).addHours(6+ offset),End__c=startdate.addDays(6).addHours(20+ offset),
                                                         Any_Time__c=true,Show_Time_As__c=ShowTime,Type__c=week.Sun_Any_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_07_09WK1__c!=null){
            for(Integer i=0;i<week.Sun_07_09WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(6 + offset),End__c=startdate.addDays(6).addHours(8 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_7_00_to_9_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_09_11WK1__c!=null){
            for(Integer i=0;i<week.Sun_09_11WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(8 + offset),End__c=startdate.addDays(6).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_9_00_to_11_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_11_13WK1__c!=null){
            for(Integer i=0;i<week.Sun_11_13WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(10 + offset),End__c=startdate.addDays(6).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_11_00_to_13_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_13_15WK1__c!=null){
            for(Integer i=0;i<week.Sun_13_15WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(12 + offset),End__c=startdate.addDays(6).addHours(14 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_13_00_to_15_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_15_17WK1__c!=null){
            for(Integer i=0;i<week.Sun_15_17WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(14 + offset).addMinutes(30),End__c=startdate.addDays(6).addHours(16 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_15_30_to_17_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_17_19WK1__c!=null){
            for(Integer i=0;i<week.Sun_17_19WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(16 + offset).addMinutes(30),End__c=startdate.addDays(6).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_17_30_to_19_00_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        if(week.Sun_19_20WK1__c!=null){
            for(Integer i=0;i<week.Sun_19_20WK1__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(18 + offset),End__c=startdate.addDays(6).addHours(19 + offset).addMinutes(30),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_19_00_to_20_30_Appt_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
            
        } 
        return apptDetailsTemp;
    }
    
    public list <Appointment__c> straightSwapAppointments(Diary_Change_request__c week, integer k, datetime startdate,id assignedTo){
        
        list<Appointment__c> apptDetailsTemp = new list<Appointment__c>();
        String ShowTime = 'Out of Office';
        String Subject = 'Available';
        id recType = '012200000004iOLAAY';
        integer offset = diaryChangeHelperMethods.getTZOffset(startdate.Date());
        //================================Monday straight swap Appointments=================
        if(week.Mon_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Mon_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(8 + offset),End__c=startdate.addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Mon_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(8 + offset).addMinutes(40),End__c=startdate.addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Mon_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(9 + offset).addMinutes(20),End__c=startdate.addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Mon_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(10 + offset),End__c=startdate.addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Mon_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(10 + offset).addMinutes(40),End__c=startdate.addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Mon_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(11 + offset).addMinutes(20),End__c=startdate.addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Mon_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(12 + offset),End__c=startdate.addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Mon_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(12 + offset).addMinutes(40),End__c=startdate.addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Mon_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(13 + offset).addMinutes(20),End__c=startdate.addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Mon_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(14 + offset),End__c=startdate.addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Mon_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(14 + offset).addMinutes(40),End__c=startdate.addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Mon_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(15 + offset).addMinutes(20),End__c=startdate.addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Mon_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(16 + offset),End__c=startdate.addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_17_00_17_40_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Mon_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(16 + offset).addMinutes(40),End__c=startdate.addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Mon_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(17 + offset).addMinutes(20),End__c=startdate.addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Mon_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Mon_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addHours(18 + offset),End__c=startdate.addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Mon_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //================================Tuesday straight swap Appointments=================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(1).Date());
        if(week.Tue_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Tue_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(8 + offset),End__c=startdate.addDays(1).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Tue_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(1).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Tue_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(1).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Tue_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(10 + offset),End__c=startdate.addDays(1).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Tue_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(1).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Tue_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(1).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Tue_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(12 + offset),End__c=startdate.addDays(1).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Tue_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(1).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Tue_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(1).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Tue_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(14 + offset),End__c=startdate.addDays(1).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Tue_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(1).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Tue_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(1).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Tue_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(16 + offset),End__c=startdate.addDays(1).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Tue_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(1).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Tue_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(1).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Tue_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Tue_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(1).addHours(18 + offset),End__c=startdate.addDays(1).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Tue_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //================================Wednesday straight swap Appointments=================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(2).Date());
        if(week.Wed_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Wed_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(8 + offset),End__c=startdate.addDays(2).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Wed_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(2).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Wed_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(2).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Wed_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(10 + offset),End__c=startdate.addDays(2).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Wed_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(2).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Wed_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(2).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Wed_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(12 + offset),End__c=startdate.addDays(2).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Wed_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(2).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Wed_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(2).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Wed_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(14 + offset),End__c=startdate.addDays(2).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Wed_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(2).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Wed_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(2).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Wed_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(16 + offset),End__c=startdate.addDays(2).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Wed_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(2).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Wed_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(2).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Wed_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Wed_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(2).addHours(18 + offset),End__c=startdate.addDays(2).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Wed_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //================================Thursday straight swap Appointments=================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(3).Date());
        if(week.Thu_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Thu_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(8 + offset),End__c=startdate.addDays(3).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Thu_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(3).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Thu_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(3).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Thu_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(10 + offset),End__c=startdate.addDays(3).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Thu_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(3).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Thu_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(3).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Thu_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(12 + offset),End__c=startdate.addDays(3).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Thu_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(3).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Thu_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(3).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Thu_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(14 + offset),End__c=startdate.addDays(3).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thu_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Thu_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(3).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thu_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thurs_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Thurs_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(3).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thurs_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thurs_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Thurs_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(16 + offset),End__c=startdate.addDays(3).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thurs_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thurs_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Thurs_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(3).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thurs_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thurs_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Thurs_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(3).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thurs_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Thurs_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Thurs_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(3).addHours(18 + offset),End__c=startdate.addDays(3).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Thurs_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //================================Friday straight swap Appointments=================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(4).Date());
        if(week.Fri_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Fri_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(8 + offset),End__c=startdate.addDays(4).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Fri_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(4).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Fri_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(4).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Fri_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(10 + offset),End__c=startdate.addDays(4).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Fri_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(4).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Fri_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(4).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Fri_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(12 + offset),End__c=startdate.addDays(4).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Fri_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(4).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Fri_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(4).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Fri_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(14 + offset),End__c=startdate.addDays(4).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Fri_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(4).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Fri_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(4).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Fri_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(16 + offset),End__c=startdate.addDays(4).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Fri_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(4).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Fri_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(4).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Fri_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Fri_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(4).addHours(18 + offset),End__c=startdate.addDays(4).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Fri_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        //================================Saturday straight swap Appointments=================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(5).Date());
        if(week.Sat_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Sat_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(8 + offset),End__c=startdate.addDays(5).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Sat_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(5).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Sat_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(5).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Sat_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(10 + offset),End__c=startdate.addDays(5).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Sat_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(5).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Sat_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(5).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Sat_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(12 + offset),End__c=startdate.addDays(5).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Sat_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(5).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Sat_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(5).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Sat_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(14 + offset),End__c=startdate.addDays(5).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Sat_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(5).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Sat_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(5).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Sat_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(16 + offset),End__c=startdate.addDays(5).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Sat_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(5).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Sat_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(5).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sat_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Sat_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(5).addHours(18 + offset),End__c=startdate.addDays(5).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sat_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        //==================Sunday Straight swap Appointments ==============================
        offset = diaryChangeHelperMethods.getTZOffset(startdate.addDays(6).Date());
        if(week.Sun_09_00_09_40__c!=null){
            for(Integer i=0;i<week.Sun_09_00_09_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(8 + offset),End__c=startdate.addDays(6).addHours(8 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_09_00_09_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_09_40_10_20__c!=null){
            for(Integer i=0;i<week.Sun_09_40_10_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(8 + offset).addMinutes(40),End__c=startdate.addDays(6).addHours(9 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_09_40_10_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_10_20_11_00__c!=null){
            for(Integer i=0;i<week.Sun_10_20_11_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(9 + offset).addMinutes(20),End__c=startdate.addDays(6).addHours(10 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_10_20_11_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_11_00_11_40__c!=null){
            for(Integer i=0;i<week.Sun_11_00_11_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(10 + offset),End__c=startdate.addDays(6).addHours(10 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_11_00_11_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_11_40_12_20__c!=null){
            for(Integer i=0;i<week.Sun_11_40_12_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(10 + offset).addMinutes(40),End__c=startdate.addDays(6).addHours(11 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_11_40_12_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_12_20_13_00__c!=null){
            for(Integer i=0;i<week.Sun_12_20_13_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(11 + offset).addMinutes(20),End__c=startdate.addDays(6).addHours(12 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_12_20_13_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_13_00_13_40__c!=null){
            for(Integer i=0;i<week.Sun_13_00_13_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(12 + offset),End__c=startdate.addDays(6).addHours(12 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_13_00_13_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_13_40_14_20__c!=null){
            for(Integer i=0;i<week.Sun_13_40_14_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(12 + offset).addMinutes(40),End__c=startdate.addDays(6).addHours(13 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_13_40_14_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_14_20_15_00__c!=null){
            for(Integer i=0;i<week.Sun_14_20_15_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(13 + offset).addMinutes(20),End__c=startdate.addDays(6).addHours(14 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_14_20_15_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_15_00_15_40__c!=null){
            for(Integer i=0;i<week.Sun_15_00_15_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(14 + offset),End__c=startdate.addDays(6).addHours(14 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_15_00_15_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_15_40_16_20__c!=null){
            for(Integer i=0;i<week.Sun_15_40_16_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(14 + offset).addMinutes(40),End__c=startdate.addDays(6).addHours(15 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_15_40_16_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_16_20_17_00__c!=null){
            for(Integer i=0;i<week.Sun_16_20_17_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(15 + offset).addMinutes(20),End__c=startdate.addDays(6).addHours(16 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_16_20_17_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_17_00_17_40__c!=null){
            for(Integer i=0;i<week.Sun_17_00_17_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(16 + offset),End__c=startdate.addDays(6).addHours(16 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_17_00_17_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_17_40_18_20__c!=null){
            for(Integer i=0;i<week.Sun_17_40_18_20__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(16 + offset).addMinutes(40),End__c=startdate.addDays(6).addHours(17 + offset).addMinutes(20),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_17_40_18_20_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_18_20_19_00__c!=null){
            for(Integer i=0;i<week.Sun_18_20_19_00__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(17 + offset).addMinutes(20),End__c=startdate.addDays(6).addHours(18 + offset),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_18_20_19_00_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        if(week.Sun_19_00_19_40__c!=null){
            for(Integer i=0;i<week.Sun_19_00_19_40__c;i++){
                Appointment__c appt = new Appointment__c(Assigned_To__c=assignedTo,Time_Band__c=null,Start__c=startdate.addDays(6).addHours(18 + offset),End__c=startdate.addDays(6).addHours(18 + offset).addMinutes(40),
                                                         Any_Time__c=false,Show_Time_As__c=ShowTime,Type__c=week.Sun_19_00_19_40_App_Type__c,RecordTypeId=recType,
                                                         Subject__c=Subject,Do_Not_Send_To_Premier__c=false);
                apptDetailsTemp.add(appt);
            }
        }
        
        
        return apptDetailsTemp;
        
    }  
    */
    
    public static Integer getTZOffset(date compareDate) {
        
        //Map<String, Integer[]> tzSIDKeys = new map<string, integer[]>();
        //tzSIDKeys.put('Europe/London', new Integer[]{0, 1});     
        
        Date[] dstDatesNow = getDSTDates(compareDate.year());
        Integer UsersTZOffset = 0;
        
        if (compareDate >= dstDatesNow[0] && compareDate < dstDatesNow[1]) UsersTZOffset = 0;
        else UsersTZOffset = 1;
        
        return UsersTZOffset;
    }
    
    /* -------------------------------------------------------------------------------------
* Returns a date Collection of Start/End dates for UK Daylight Saving Time
* for the specified year.
*
* Based on code from: http://www.webexhibits.org/daylightsaving/b2.html
* ------------------------------------------------------------------------------------- */
    
    public static Date[] getDSTDates(Integer theYear) {
        
        Long thisYear;
        
        Long longSeven = 7;
        thisYear = Math.round(theYear);
        
        
        Long MarchDateEU =  (31-Math.mod(( Math.floor (thisYear * 5 / 4).LongValue() + 4) ,longSeven));
        Long OctoberDateEU =  (31-Math.mod(( Math.floor (thisYear * 5 / 4).LongValue() + 1),longSeven));
        
        
        string startDateEu = MarchDateEU+'/03/' + thisYear;
        string endDateEu = OctoberDateEU+ '/10/' + thisYear;
        
        system.debug('startDate---->'+startDateEu+' '+endDateEu);
        system.debug('March EU Date-->'+MarchDateEU);
        system.debug('october Date-->'+OctoberDateEU);  
        Date[] rtnDates = new List<Date>();
        rtnDates.add(Date.parse(startDateEu));
        rtnDates.add(Date.parse(endDateEu));
        
        system.debug('--->'+ rtnDates);
        return rtnDates;
    }
    
    
    
}