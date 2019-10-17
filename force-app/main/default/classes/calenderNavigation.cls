global class calenderNavigation {
      
   Webservice static String getGroupCalendarURL(String postCode, String rlType) {
      String retVal = '/00U/c?cType=2&shWkends=true';
    
      calUtils hlp = new calUtils();  
      String listTeam = hlp.getTeamListArg(postCode, rlType);
      if(listTeam == 'Error'){
         retVal='Error';
      }
      else
      {
        retVal += hlp.getYearArg() + hlp.getWeekNoArg() + listTeam;
      }
 
      return retVal;
   }
   
   public class calUtils {
     public String getYearArg() {
          String retString = '';
      
          Date dt = Date.Today();
          retString='&md0=' + dt.year();
      
          return retString;
    }
   
    public String getWeekNoArg() {
     String retString = '';
         //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Starts 
     //Integer wkNo = (Date.Today().DayOfYear()+3)/7 ;
  
//date DateX = date.newInstance(2016, 1, 1);
 Long wkNo;
date DateX=Date.Today();
date DateC;
Integer x = DateX.DayOfYear()-1;

date DateB= DateX-x;


date DateA=DateB.toStartofWeek();
if(DateA<DateB)
{
DateC= DateA +7;
}
else
{
    DateC=DateA;
}
System.debug('DateX-->'+DateX);
System.debug('DateA-->'+DateA);
System.debug('DateB-->'+DateB);
System.debug('DateC-->'+DateC);

Long a = DateC.day();

System.debug('a-->'+a);
If(a== 7)
{
a= 0;
}
integer B = DateA.daysBetween(DateB);
if (DateX.toStartofWeek()<=DateB && B<=3)
wkNo=1;

else if (DateX>DateB && B<=3 && a>0)
wkNo = ((DateX.toStartofWeek().DayOfYear()+(7-a))/7) +1 ;
else 
wkNo = (DateX.toStartofWeek().DayOfYear()+(7-a))/7 ;

System.debug('wkNo-->'+wkNo);
     
     //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Ends   
     /*
     
     Date startOfWeek = Date.Today().toStartofWeek();
     
     Date yesterDay = Date.Today()-1;
     if(startOfWeek.day()== Date.Today().day()){
        wkNo  = 2+Date.Today().DayOfYear()/7;
       }
     if(startOfWeek.day()== yesterDay.day()){
        wkNo  = 2+Date.Today().DayOfYear()/7;
       }
     
     */
     
     retString='md2=' + wkNo;
     return retString;
    }
      
    public String getTeamListArg(String postCode, String rlType) {
     String retString = '';

     String postCode_sector = postCode.substring(0,postCode.length()-2);
     Postcode_Sector__c[] calList = [Select sub_patch__r.District__r.Region__r.Calender_List_Id__c  From postcode_sector__c
            where type__c = :rlType
            and name = :postCode_Sector limit 1];
     if (calList.size()==0) 
      retstring='Error';    
     else if(calList[0].sub_patch__r.District__r.Region__r.Calender_List_Id__c == null)
       retstring='Error';
     else       
       retString='&fcf=' + calList[0].sub_patch__r.District__r.Region__r.Calender_List_Id__c;
     
     return retString;
    }
     
   } 
   
    global class CalendarResult{
        WebService String calendarViewId = '';
        WebService String recordTypeId = '';
        WebService String primaryContact = '';
        WebService Integer year = 0;
        WebService Long week = 0;
        WebService String error = '';
    } 
    
    Webservice static CalendarResult getCalendarViewIdFromUserId(String userId, String rlType) {     
     CalendarResult result = new CalendarResult();                   
     try {
        result.year = Date.Today().year();
             //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Starts
       // result.week = (Date.Today().DayOfYear()+3)/7 ;
       Long wkNo;
date DateX=Date.Today();
date DateC;
Integer x = DateX.DayOfYear()-1;

date DateB= DateX-x;


date DateA=DateB.toStartofWeek();
if(DateA<DateB)
{
DateC= DateA +7;
}
else
{
    DateC=DateA;
}
System.debug('DateX-->'+DateX);
System.debug('DateA-->'+DateA);
System.debug('DateB-->'+DateB);
System.debug('DateC-->'+DateC);

Long a = DateC.day();

System.debug('a-->'+a);
If(a== 7)
{
a= 0;
}
integer B = DateA.daysBetween(DateB);
if (DateX.toStartofWeek()<=DateB && B<=3)
wkNo=1;

else if (DateX>DateB && B<=3 && a>0)
wkNo = ((DateX.toStartofWeek().DayOfYear()+(7-a))/7) +1 ;
else 
wkNo = (DateX.toStartofWeek().DayOfYear()+(7-a))/7 ;

System.debug('wkNo-->'+wkNo);
       result.week=wkNo;
         //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Ends
        
        /*
        
        Date startOfWeek = Date.Today().toStartofWeek();
        Date yesterDay = Date.Today()-1;
        if(startOfWeek.day()== Date.Today().day()){
        result.week = 2+Date.Today().DayOfYear()/7;
        }
        if(startOfWeek.day()== yesterDay.day()){
        result.week = 2+Date.Today().DayOfYear()/7;
        }
        
        */

           
        User user = [Select Sales_District__c, Survey_District__c From User where Id=:userId limit 1][0];
        String districtCode = '';
        if(rlType=='Sales')
            districtCode=user.Sales_District__c;
        if(rlType=='Survey')
            districtCode=user.Survey_District__c;   
        String cLookupId = [Select Calendar_View_ID__c From Calendar_Lookup__c where District_ID__c=:districtCode limit 1].Calendar_View_ID__c;
        
        result.calendarViewId=cLookupId;
        result.recordTypeId=Schema.SObjectType.Event.getRecordTypeInfosByName().get('Appointment').getRecordTypeId();            
     } catch (Exception err) {
        result.error=err.getMessage();
     }
     return result;
    }
    
   Webservice static CalendarResult getCalendarViewId(String postCode, String rlType) {      
     CalendarResult result = new CalendarResult();                   
     try {
        result.year = Date.Today().year();
             //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Starts
        //result.week = (Date.Today().DayOfYear()+3)/7 ;
        Long wkNo;
date DateX=Date.Today();
date DateC;
Integer x = DateX.DayOfYear()-1;

date DateB= DateX-x;


date DateA=DateB.toStartofWeek();
if(DateA<DateB)
{
DateC= DateA +7;
}
else
{
    DateC=DateA;
}
System.debug('DateX-->'+DateX);
System.debug('DateA-->'+DateA);
System.debug('DateB-->'+DateB);
System.debug('DateC-->'+DateC);

Long a = DateC.day();

System.debug('a-->'+a);
If(a== 7)
{
a= 0;
}
integer B = DateA.daysBetween(DateB);
if (DateX.toStartofWeek()<=DateB && B<=3)
wkNo=1;

else if (DateX>DateB && B<=3 && a>0)
wkNo = ((DateX.toStartofWeek().DayOfYear()+(7-a))/7) +1 ;
else 
wkNo = (DateX.toStartofWeek().DayOfYear()+(7-a))/7 ;

System.debug('wkNo-->'+wkNo);
       result.week = wkNo;
         //Code Fix done as a part of PRB00008389 by BGSAMS Support on 08/08/2012 - Starts
        /*
        
        Date startOfWeek = Date.Today().toStartofWeek();
        Date yesterDay = Date.Today()-1;
        if(startOfWeek.day()== Date.Today().day()){
        result.week = 2+Date.Today().DayOfYear()/7;
        }
        if(startOfWeek.day()== yesterDay.day()){
        result.week = 2+Date.Today().DayOfYear()/7;
        }
        
        */
     
        String postCode_sector = postCode.substring(0,postCode.length()-2);     
        String districtCode = [Select Sub_Patch__r.District__r.Code__c From Postcode_Sector__c 
                where Type__c=:rlType 
                and Sub_Patch__r.Type__c=:rlType 
                and Sub_Patch__r.District__r.Type__c=:rlType 
                and Name=:postCode_Sector limit 1].Sub_Patch__r.District__r.Code__c;

        String cLookupId = [Select Calendar_View_ID__c From Calendar_Lookup__c where District_ID__c=:districtCode limit 1].Calendar_View_ID__c;
        
        result.calendarViewId=cLookupId;
        result.recordTypeId=Schema.SObjectType.Event.getRecordTypeInfosByName().get('Appointment').getRecordTypeId();            
     } catch (Exception err) {
        result.error=err.getMessage();
     }
     return result;
    }
   
  ///
    //Test class to achieve coverage only. Cannot assert webservice calls in Apex.
    ///
    @isTest
    static void TestCalenderNavigation (){
        
        String postCode = 'TW18 3AX';
        String rlType = 'Sales';
        String retValue = '';
        CalendarResult result = new CalendarResult();     
        calenderNavigation.calUtils cal = new calenderNavigation.calUtils();
        
        retValue = getGroupCalendarURL(postCode,rlType);
        result = getCalendarViewIdFromUserId('00520000000mTzkAAE',rlType);
        result = getCalendarViewId(postCode,rlType);
        retValue = cal.getWeekNoArg();
        retValue = cal.getTeamListArg(postCode,rlType);
        
        rlType = 'Survey';
        retValue = getGroupCalendarURL(postCode,rlType);
        result = getCalendarViewIdFromUserId('00520000000mTzkAAE',rlType);
        result = getCalendarViewId(postCode,rlType);
        retValue = cal.getWeekNoArg();
        retValue = cal.getTeamListArg(postCode,rlType);
        
    }       
   
}