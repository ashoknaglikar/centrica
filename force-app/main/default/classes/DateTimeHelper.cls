/* DateTimeHelper
    A class full of helpeful methods for when it comes to handling DateTimes.
*/

public with sharing class DateTimeHelper {

    // Some static Maps useful for going from a DateTime to a number to indicate the day of the week
    // and vice versa...
    public static final Map<String, Integer> DAYS_OF_WEEK
                = new Map<String, Integer> {'Mon' => 0, 'Tue' => 1, 'Wed' => 2, 'Thu' => 3, 'Fri' => 4,
                                            'Sat' => 5, 'Sun' => 6};
    public static final Map<Integer, String> WEEK_DAY_INTEGERS 
                = new Map<Integer, String> {0 =>'Mon', 1 => 'Tue', 2 => 'Wed', 3 => 'Thu', 4 => 'Fri',
                                            5 => 'Sat', 6 => 'Sun'};
    
    /* calculateHours(Datetime startT, Datetime endT, Diary_Entry__c de)
        Calculates the number of working hours between two DateTimes taking into 
        account the shift pattern of a Diary Entry belonging to a week. The first
        DateTime should be the earlier of the two DateTimes, though no check is
        performed to enforce this.
        
        This method basically just passes information through to another method. */
    public static Double calculateHours(Datetime startT, Datetime endT, Diary_Entry__c de) {
        List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{de.Week__r.Monday_Start_Time__c, de.Week__r.Monday_End_Time__c},
                                        new List<String>{de.Week__r.Tuesday_Start_Time__c, de.Week__r.Tuesday_End_Time__c},
                                        new List<String>{de.Week__r.Wednesday_Start_Time__c, de.Week__r.Wednesday_End_Time__c},
                                        new List<String>{de.Week__r.Thursday_Start_Time__c, de.Week__r.Thursday_End_Time__c},
                                        new List<String>{de.Week__r.Friday_Start_Time__c, de.Week__r.Friday_End_Time__c},
                                        new List<String>{de.Week__r.Saturday_Start_Time__c, de.Week__r.Saturday_End_Time__c},
                                        new List<String>{de.Week__r.Sunday_Start_Time__c, de.Week__r.Sunday_End_Time__c}};
        return calculateHours(startT, endT, shifts);
    }
    
    /* calculateHours(Datetime startT, Datetime endT, Diary_Entry__c de)
        Calculates the number of working hours between two DateTimes taking into 
        account the shift pattern of a Week. The first DateTime should be the 
        earlier of the two DateTimes, though no check is performed to enforce this.
        
        This method basically just passes information through to another method. */
    public static Double calculateHours(Datetime startT, Datetime endT, Week__c week) {
        List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{week.Monday_Start_Time__c, week.Monday_End_Time__c},
                                        new List<String>{week.Tuesday_Start_Time__c, week.Tuesday_End_Time__c},
                                        new List<String>{week.Wednesday_Start_Time__c, week.Wednesday_End_Time__c},
                                        new List<String>{week.Thursday_Start_Time__c, week.Thursday_End_Time__c},
                                        new List<String>{week.Friday_Start_Time__c, week.Friday_End_Time__c},
                                        new List<String>{week.Saturday_Start_Time__c, week.Saturday_End_Time__c},
                                        new List<String>{week.Sunday_Start_Time__c, week.Sunday_End_Time__c}};
        return calculateHours(startT, endT, shifts);
    }
    
    /* calculateHours(Datetime startT, Datetime endT, Diary_Entry__c de)
        Calculates the number of working hours between two DateTimes taking into 
        account a shift pattern (represented by a List of List of Strings). The 
        first DateTime should be the earlier of the two DateTimes, though no check 
        is performed to enforce this. 
        
        Note that this method does not check that the shift pattern covers the time
        between the two DateTimes - if there are gaps in the shift information between
        the DateTimes passed in, it is likely an Exception will occur. */
    public static Double calculateHours(Datetime startT, Datetime endT, List<List<String>> shifts) {
        
        // If the two Datetime passed in to the method are equal, the hours between
        // them is 0, so return this result straight away.
        if(dateEquals(startT,endT))
            return 0.0;
        
        // "Normalise" the times - basically, check if they fall outside of the shift pattern
        // and adjust them if need be. See the normaliseDateTime method for more information   
        DateTime earlier = normaliseDateTime(startT, shifts);
        DateTime later = normaliseDateTime(endT, shifts);
        
        System.debug(LoggingLevel.INFO, 'earlier: ' + earlier + ' later: ' + later);
        
        // If, after the DateTimes are normalised, they are equal, the hours between them is
        // 0 - so return this result.
        if(earlier == later || earlier>later)
            return 0.0;
        
        // Get the days of the DateTimes as Integers
        Integer startDay = DAYS_OF_WEEK.get(earlier.format('E'));
        Integer endDay = DAYS_OF_WEEK.get(later.format('E'));
        
//      System.debug(LoggingLevel.INFO, 'startDay: ' + startDay + ' endDay: ' + endDay);
//      System.debug(LoggingLevel.INFO, 'stringToTime(shifts[startDay][1]): ' + stringToTime(shifts[startDay][1]) + ' earlier.time(): ' + earlier.time());
        
        // Get the shift end time for the earlier DateTime
        Time t = stringToTime(shifts[startDay][1]);
        
        // Total will hold the total number of hours between the two DateTimes. 
        Double total = null;
        
        // If the two days are equal and the later DateTime's time is earlier than the
        // shift end for the day, calculate the hours between the later and earlier times.
        // Otherwise, calculate the hours between the earlier time and the shift end.
        if(startDay == endDay && later.time() < t)
            total = subtractTime(later.time(), earlier.time());
        else
            total = subtractTime(t, earlier.time());
        System.debug(LoggingLevel.INFO, 'total: ' + total);
        
        // If the days are the same, we have our answer and we can return...
        if(startDay == endDay)
            return total;
        
        // ... otherwise, we need to do additional calculations.
//      System.debug(LoggingLevel.INFO, 'Shifts::::'+shifts);
        do {
            // Work out the shift start and end times for the next day. Note that if startDay and endDay are
            // equal, we need to use the time of the later DateTime; otherwise we use the shift end for the day
            startDay++;
            System.debug(LoggingLevel.INFO, 'startDay::::'+startDay);
            if(shifts[startDay][0] == null){
//              System.debug(LoggingLevel.INFO, 'Uh Oh!');
                //rjd - 17-12-2009 - try and see what heppens if we finish here it this doesn't exist...
                break;
            }
            Time shiftStart = stringToTime(shifts[startDay][0]);
            Time shiftEnd = (startDay == endDay) ? later.time() : stringToTime(shifts[startDay][1]);
            // Calculate the hours between the times and add it to total
            total += subtractTime(shiftEnd, shiftStart);
            
            System.debug(LoggingLevel.INFO, 'startDay: ' + startDay + ' shiftStart: ' + shiftStart + ' shiftEnd: ' + shiftEnd + ' total: ' + total);

        } while(startDay != endDay);
        
        System.debug(LoggingLevel.INFO, 'total: ' + total);
        
        return total;
    }
    
    /* addWorkingHoursToDateTime(DateTime dt, Double hoursToAdd, Diary_Entry__c de)
        This method adds a number of hours to a DateTime according to the shift pattern
        of a Diary Entry. 
        
        Note that this method assumes that the Diary Entry's shift pattern allows the 
        number of hours to be added - if the number of hours to add will take the 
        DateTime to a day without shift information, this will cause an Exception. */
    
    public static DateTime addWorkingHoursToDateTime(DateTime dt, Double hoursToAdd, Diary_Entry__c de) {
        
        // Put the shift information into a handy format...
        List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{de.Week__r.Monday_Start_Time__c, de.Week__r.Monday_End_Time__c},
                                        new List<String>{de.Week__r.Tuesday_Start_Time__c, de.Week__r.Tuesday_End_Time__c},
                                        new List<String>{de.Week__r.Wednesday_Start_Time__c, de.Week__r.Wednesday_End_Time__c},
                                        new List<String>{de.Week__r.Thursday_Start_Time__c, de.Week__r.Thursday_End_Time__c},
                                        new List<String>{de.Week__r.Friday_Start_Time__c, de.Week__r.Friday_End_Time__c},
                                        new List<String>{de.Week__r.Saturday_Start_Time__c, de.Week__r.Saturday_End_Time__c},
                                        new List<String>{de.Week__r.Sunday_Start_Time__c, de.Week__r.Sunday_End_Time__c}};
        
        
        return addWorkingHoursToDateTime1(dt,hoursToAdd,shifts);
    }
    
    /* normaliseDateTime(DateTime original, List<List<String>> shifts)
        Takes a DateTime and check that it occurs at a time when an employee actualy works, according
        to his shift pattern. If it does not, the time is rolled forward to the next valid date and time. 
        
        rjd - 2010-01-04 - need to think about the direction of the 'normalisation'. If the date is outside of the shift pattern ane on the 
        last day of the week then we are stuck.... Perhaps if should be normalised back to a valid datetime?
    */
    /*
    rjd - 22-12-2009 - Added an exception if the date is outside of the working shift pattern Otherwise null reference is thrown...
    */
    public static DateTime oldnormaliseDateTime(DateTime original, List<List<String>> shifts) {
        // Create a new instance of the DateTime, and get the shift start and end times for
        // the day as Time objects.
        DateTime normaliseMe = DateTime.newInstance(original.date(), original.time());
        Integer startDay = DateTimeHelper.DAYS_OF_WEEK.get(original.format('E'));
        if(shifts[startDay] == null || shifts[startDay][0] == null || shifts[startDay][1] == null){
            throw new ShiftException('A date outside of the shift pattern has been received. Please check and ammend data accordingly.');
        }
        Time shiftStart = DateTimeHelper.stringToTime(shifts[startDay][0]);
        Time shiftEnd = DateTimeHelper.stringToTime(shifts[startDay][1]);
        
        if(original.time() >= shiftEnd && shifts.size() <= startDay+1 && shifts[startDay+1][0] == null) {
            // if the time is past today's shift end time and there is not a shift in the next day,
            // set the time to the end of the current day. 
            normaliseMe = DateTime.newInstance(normaliseMe.date(), shiftEnd);
        } else if(original.time() >= shiftEnd) {
            // If past today's shift end time, roll forward to next day's start
            //rjd - 22-12-2009 - trying to stop problems with shifts[startDay+1][0] being null...
            //TODO: this needs fixing as if the date is null then it won't be moved correctly.
            if(shifts[startDay+1][0] != null)
                normaliseMe = DateTime.newInstance(normaliseMe.date().addDays(1), DateTimeHelper.stringToTime(shifts[startDay+1][0]));
        } else if (original.time() < shiftStart) {
            // If before today's shift start time, roll forward to today's start
            normaliseMe = DateTime.newInstance(normaliseMe.date(), DateTimeHelper.stringToTime(shifts[startDay][0]));
        }
        
        return normaliseMe;     
    }
    /*
    Shifts is of form <<"Monday Start Time", "Monday End Time">,<"Tuesday Start Time", "Tuesday End Time">...>
    so you get <<"09:00", "18:00">,<"08:00", "18:00">...>
    
    Functionality is to move the original dattetime to a time within the shift pattern if not already valid.
    If the datetime is outside of the shift pattern (e.g. sunday evening) then an exception is thrown.
    It is possible that the shift pattern has 'gaps' for non-working days. Only 1 start/end time entry per day
    */
    public static DateTime normaliseDateTime(DateTime original, List<List<String>> shifts) {
        // Create a new instance of the DateTime, and get the shift start and end times for
        // the day as Time objects.
        //use this for the date
        Date dTemp = original.date();
        Integer startDay = DateTimeHelper.DAYS_OF_WEEK.get(original.format('E'));
        
        if(startDay >= shifts.size())
            throw new ShiftException('A date outside of the shift pattern has been received.');
        
        DateTime dayStart = null;
        DateTime dayEnd = null;
        
        if(shifts[startDay][0] != null)
            dayStart = DateTime.newInstance(dTemp, DateTimeHelper.stringToTime(shifts[startDay][0]));
        if(shifts[startDay][1] != null)
            dayEnd = DateTime.newInstance(dTemp, DateTimeHelper.stringToTime(shifts[startDay][1]));
            
//      System.debug(original+','+dayStart+','+dayEnd);
        //if the date passed in is in the day range - return the original as its ok.
        if(original >= dayStart && original <= dayEnd  && dayStart != null && dayEnd != null) // nulls are here in case the day isn't in a shift pattern.
            return original;
        
        //if the date is before the start of todays shift then move to the day start time.
        if(original < dayStart && dayStart != null)
            return dayStart;
        
        //if the date is after the day end (or day end is null, or the day start is null) then move to the start of the next day (with a shift pattern).
        //NOTE: if no shift day is found after the 'current day' then an exception is thrown.
        if(original > dayEnd || dayEnd == null || dayStart == null){
            
            while(startDay < shifts.size()-1) {
                dTemp = dTemp.addDays(1);
                startDay += 1;
                if(shifts[startDay] != null && shifts[startDay][0] != null){
                    return dateTime.newInstance(dTemp, DateTimeHelper.stringToTime(shifts[startDay][0]));
                }
            }
            //can only be here if no start datte found => throw exception.
            throw new ShiftException('A date outside of the shift pattern has been received.');
        }
        
        return null;
    }
    
   
    
    /* hoursBetweenShifts(String firstDayEnd, String nextDayStart)
        Calculates the hours between the end of one day's shift and the start of the next day's
        shift. This information is passed in as string in the format HH:MM */
    public static Double hoursBetweenShifts(String firstDayEnd, String nextDayStart) {
//        System.debug(LoggingLevel.INFO, 'firstDayEnd is: ' + firstDayEnd);
//        System.debug(LoggingLevel.INFO, 'nextDayStart is: ' + nextDayStart);
        Time firstDayT = Time.newInstance(Integer.valueOf(firstDayEnd.subString(0, firstDayEnd.indexOf(':'))), 
                                            Integer.valueOf(firstDayEnd.subString(firstDayEnd.indexOf(':')+1, firstDayEnd.length())), 
                                            0, 0);
        Time secondDayT = Time.newInstance(Integer.valueOf(nextDayStart.subString(0, nextDayStart.indexOf(':'))), 
                                            Integer.valueOf(nextDayStart.subString(nextDayStart.indexOf(':')+1, nextDayStart.length())), 
                                            0, 0);
        
        return subtractDate(Datetime.newInstance(Date.today().addDays(1), secondDayT), 
                            Datetime.newInstance(Date.today(), firstDayT));
    }
 
    /* hoursBetweenStartEndHours (String startTime, String endTime)
        This method is used for returning difference (in hours) between start & end 
        times specified in HH:MM format. */
    
    public static Double hoursBetweenStartEndHours (String startTime, String endTime) {
        Time startOfDay = Time.newInstance(Integer.valueOf(startTime.subString(0, startTime.indexOf(':'))), 
                                            Integer.valueOf(startTime.subString(startTime.indexOf(':')+1, startTime.length())), 
                                            0, 0);
        Time endOfDay = Time.newInstance(Integer.valueOf(endTime.subString(0, endTime.indexOf(':'))), 
                                            Integer.valueOf(endTime.subString(endTime.indexOf(':')+1, endTime.length())), 
                                            0, 0);
        return subtractDate(Datetime.newInstance(Date.today(), endOfDay), 
                              Datetime.newInstance(Date.today(), startOfDay));
    }
   
    public static Double subtractTime(Time highTime, Time lowtime) {
        return subtractDate(Datetime.newInstance(Date.today(), highTime), Datetime.newInstance(Date.today(), lowTime));
    }
    
    public static Double subtractDate(DateTime highDate, DateTime lowDate) {
        highDate = removeSecs(highDate);
        lowDate = removeSecs(lowDate);
        Double timeDiff = highDate.getTime() - lowDate.getTime();
        //System.debug(LoggingLevel.INFO, 'time difference: ' + timeDiff/(1000 * 60 * 60));
        Double result = ((Double) timediff) /(1000 * 60 * 60); // 1000 milliseconds * 60 seconds * 60 Minutes
        
        //rjd 2010-01-24 returning the double without rounding to see what impact this will have
        //return result;
        
        // brm - 13-01-2010 - Convert to decimal type and limit to 2 decimal places
//        System.debug(LoggingLevel.INFO, '---------------- initial val: ' + result);
        Decimal dec = result;
        dec = dec.setScale(2);
//        System.debug(LoggingLevel.INFO, '---------------- rounded val: ' + dec);
        // brm - 13-01-2010 - return value as double
        return dec.doubleValue();
    }


    public static Datetime removeSecs(Datetime secsDate) {
        //rjd - 2010-01-27 - trying to reduce script count
        return DateTime.newInstance(secsDate.year(),secsDate.month(),secsDate.day(),secsDate.hour(),secsDate.minute(),0);
        //remove the milliseconds and seconds
//        Long millisecs = secsDate.millisecond();
//        Long unixDate = secsDate.getTime();
//        Long minusMillisecs = unixDate - millisecs;
//        secsDate = Datetime.newInstance(minusMillisecs);
        
//        Long secs = secsDate.second();
//        unixDate = secsDate.getTime();
//        Long minusSecs = unixDate - (secs * 1000);
//        return Datetime.newInstance(minusSecs);
    }
    
    //there seems to be a bug in force.com that when you save and retrieve a datetime
    //to the database the milliseconds are not preserved. So you cannot reliably
    //compare 2 datetimes. So this function will ignore milliseconds (and seconds)
    //for a comparison
    public static boolean dateEquals(Datetime d1, Datetime d2)
    {
        if(d1 == null || d2 == null)
            return false;
        //rjd - 2010-01-27 - trying to reduce script count
        return (d1.format('dd/MM/yyyy HH:mm') == d2.format('dd/MM/yyyy HH:mm'));
        //return (removeSecs(d1) == removeSecs(d2));
        
    }
    //check if d1 is greater than d2
    public static boolean dateGreaterThan(Datetime d1, Datetime d2)
    {
        //rjd - 2010-01-27 - trying to reduce script count
        return (d1.format('yyyyMMdd HH:mm') > d2.format('yyyyMMdd HH:mm'));
        //return (removeSecs(d1) > removeSecs(d2));
    }
    //check if d1 is less than d2
    public static boolean dateLessThan(Datetime d1, Datetime d2)
    {
        //rjd - 2010-01-27 - trying to reduce script count
        return (d1.format('yyyyMMdd HH:mm') < d2.format('yyyyMMdd HH:mm'));
        //return (removeSecs(d1) < removeSecs(d2));
    }
    //check if d1 is greater than or eqaul to d2
    public static boolean dateGreaterThanOrEqual(Datetime d1, Datetime d2)
    {
        return (dateGreaterThan(d1,d2) || dateEquals(d1,d2));
    }   
    //check if d1 is less than or eqaul to d2
    public static boolean dateLessThanOrEqual(Datetime d1, Datetime d2)
    {
        return (dateLessThan(d1,d2) || dateEquals(d1,d2));
    }

    /* sameWeek(Datetime d1, Datetime d2)
        Returns a boolean indicating whether the two DateTimes passed in occur in the same week. */
    public static boolean sameWeek(Datetime d1, Datetime d2) {
        
        //rjd - 2010-01-27 - trying to reduce script count
        return (d1.date().toStartOfWeek() == d2.date().toStartOfWeek());
        //Date d1Date = d1.date().toStartOfWeek();
        //Date d2Date = d2.date().toStartOfWeek();
        //return(d1Date == d2Date);
    } 
    /* stringToTime(String convertMe) {
        Converts a string in the format HH:MM to a Time object. */
    public static Time stringToTime(String convertMe) {
        //Integer hours = Integer.valueOf(convertMe.subString(0, convertMe.indexOf(':')));
        //Integer minutes = Integer.valueOf(convertMe.subString(convertMe.indexOf(':') + 1, convertMe.length()));
        //return Time.newInstance(hours, minutes, 0, 0);
        
        //rjd - trying to reduce script count
        if(convertMe!=null)
        return Time.newInstance(Integer.valueOf(convertMe.split(':')[0]),Integer.valueOf(convertMe.split(':')[1]),0,0);
        else 
        return null;
    }
    
    /* addHoursToDT(Datetime dt, Double hoursToAdd)
        Takes a DateTime and Double representing the number of hours to add, and adds
        the number of hours to the DateTime. */
    public static Datetime addHoursToDT(Datetime dt, Double hoursToAdd) {
        Integer hours = hoursToAdd.intValue();
        //rjd - 2009-11-19 - changing to round - 
        //problem: if hoursToAdd has minutes element of 39.99999 rounded down to 39; should be 40
        //Integer minutes = ((hoursToAdd - hoursToAdd.intValue()) * 60).intValue();
        Integer minutes = Integer.valueOf(''+((hoursToAdd - hours) * 60).round());
        return dt.addHours(hours).addMinutes(minutes);      
    }
    
    public static Datetime removeHoursFromDT(Datetime dt, Double hoursToRemove) {
        Integer hours = hoursToRemove.intValue();
        Integer minutes = Integer.valueOf(''+((hoursToRemove - hours) * 60).round());
        return dt.addHours(-hours).addMinutes(-minutes);        
    }
    
    public static DateTime getGMTDateTime(DateTime mydateTime)
    {
        Integer year = mydateTime.year();
        Integer month = mydateTime.month();
        Integer day = mydateTime.day();
        Integer hour = mydateTime.hour();
        Integer minute = mydateTime.minute();
        Integer second = mydateTime.second();
        string stringDate = year + '-' + month
        + '-' + day + ' ' + hour + ':' +
        minute + ':' + second;
        Datetime myDate =
        datetime.valueOf(stringDate);
        Datetime myDateGMT = datetime.valueOfGmt(stringDate);    
        return myDateGMT;            
    }
    
    public static boolean isGMTTimeZone(DateTime mydateTime)
    {
        Integer year = mydateTime.year();
        Integer month = mydateTime.month();
        Integer day = mydateTime.day();
        Integer hour = mydateTime.hour();
        Integer minute = mydateTime.minute();
        Integer second = mydateTime.second();
        string stringDate = year + '-' + month
        + '-' + day + ' ' + hour + ':' +
        minute + ':' + second;
        Datetime myDate =
        datetime.valueOf(stringDate);
        Datetime myDateGMT =
        datetime.valueOfGmt(stringDate);
        if(myDateGMT != myDate)
        {
        return true;
        }
        else
        {
        return false;
        }
    }
    
    public static map<string, list<time>> ShiftTimeMap(Shift_Pattern__c sf)
    {   
        Map <string, list<time>> shfitTimeMap = new  Map <string, list<time>> ();
        
        shfitTimeMap.put('0', new list<time>{DatetimeHelper.stringToTime(sf.Monday_Start_Time__c),DatetimeHelper.stringToTime(sf.Monday_End_Time__c)});
        shfitTimeMap.put('1', new list<time>{DatetimeHelper.stringToTime(sf.Tuesday_Start_Time__c),DatetimeHelper.stringToTime(sf.Tuesday_End_Time__c)});
        shfitTimeMap.put('2', new list<time>{DatetimeHelper.stringToTime(sf.Wednesday_Start_Time__c),DatetimeHelper.stringToTime(sf.Wednesday_End_Time__c)});
        shfitTimeMap.put('3', new list<time>{DatetimeHelper.stringToTime(sf.Thursday_Start_Time__c),DatetimeHelper.stringToTime(sf.Thursday_End_Time__c)});
        shfitTimeMap.put('4', new list<time>{DatetimeHelper.stringToTime(sf.Friday_Start_Time__c),DatetimeHelper.stringToTime(sf.Friday_End_Time__c)});
        shfitTimeMap.put('5', new list<time>{DatetimeHelper.stringToTime(sf.Saturday_Start_Time__c),DatetimeHelper.stringToTime(sf.Saturday_End_Time__c)});
        shfitTimeMap.put('6', new list<time>{DatetimeHelper.stringToTime(sf.Sunday_Start_Time__c),DatetimeHelper.stringToTime(sf.Sunday_End_Time__c)});
        
        return shfitTimeMap;
        
    }
    
    public static list<Date> calcualteDateTimesForTravel(Datetime start, Datetime EndDatetime, map<string, list<time>> ShiftTimeMap )
    {
        list<Date> newStartEnd = new list<Date>();
        integer startDay = DateTimeHelper.DAYS_OF_WEEK.get(start.format('E'));
        integer EndDay = DateTimeHelper.DAYS_OF_WEEK.get(EndDatetime.format('E'));
        Time startTime = start.time();
        time endtime = EndDatetime.time();
        if(startTime == ShiftTimeMap.get(string.valueof(startDay))[1])
        {
            newStartEnd.add(start.addDays(1).date());
        }
        else
        {
            newStartEnd.add(start.date());
        }
        if(endtime == ShiftTimeMap.get(string.valueof(EndDay))[0])
        {
            newStartEnd.add(EndDatetime.addDays(-1).date());
        }else
        {
            newStartEnd.add(EndDatetime.date());
        }
        return newStartEnd;
    }
    
    public Integer daysOff(Datetime sdate, Datetime edate)
    {   
        
        Integer iCount = 0;
        //Added By Ashok G
        if(sdate.format('E') == 'Sat' || sdate.format('E') == 'Sun')
        iCount = -1;
                
        while (sdate <= edate) 
        {
            if (sdate.format('E') == 'Sat' || sdate.format('E') == 'Sun')
            {
                iCount = iCount + 1;
            }
            sdate = sdate.addDays(1);
        }
        
        return iCount;
    }
    
     public Datetime addBussinessDays(Datetime startDate, Integer iDays)
    {
        system.debug('Sart Date-->'+startDate);
        Datetime endDate = startDate.addDays(iDays);
        Integer iOffDays = daysOff(startDate,endDate);
        endDate = endDate.addDays(iOffDays);
        if (endDate.format('E') == 'Sat'  )
        {
            endDate=endDate.addDays(2);
        }else if(endDate.format('E') == 'Sun' )
        {
            endDate=endDate.addDays(1);
        }
        
        system.debug('End Date-->'+endDate);
        return endDate;
    }
    
    public static DateTime subtractWorkingHoursToDateTime(DateTime dt, Double hoursToSub,List<List<String>> shifts) {
        if(hoursToSub == 0.0)
            return dt;
        
        DateTime newDt = normaliseDateTime(dt, shifts);
        Integer dayI = DAYS_OF_WEEK.get(newDt.format('E'));
        
        Time dtEndTime = Time.newInstance(newDt.hour(), newDt.minute(),0,0); 
        Time startTime = stringToTime(shifts[dayI][0]);
        Double leftToSub = hoursToSub;
       
        while(leftToSub > 0) {
            Double hoursToday = subtractTime(dtEndTime, startTime);
            if(hoursToday >= leftToSub) {
                newDt = removeHoursFromDT(newDt,leftToSub);
                break;
            }
            
            leftToSub -= hoursToday;
            
            dayI--;
            if(dayI>6)
            {
                break;
            }
            
            if(shifts[dayI][0] != null){
               startTime = stringToTime(shifts[dayI][0]); // previous day's shift start
               dtEndTime = stringToTime(shifts[dayI][1]); // previous day's shift end
            }
            else{
                dayI++;
                startTime= stringToTime(shifts[dayI][0]);
                dtEndTime = stringToTime(shifts[dayI][1]);
            }
           
            newDt = DateTime.newInstance(newDt.date().addDays(-1), dtEndTime);
        }
        
        return newDt;
    }
    
    
    public static DateTime addWorkingHoursToDateTime1(DateTime dt, Double hoursToAdd, List<List<String>> shifts) {
        
        // If there are no hours to add, don't need to do anything, return.
        if(hoursToAdd == 0.0)
            return dt;
        
        // Get some initial information 
        // - first, normalise the DateTime passed in (wind it forward to the start of the next shift if it occurs outside of a shift pattern)
        DateTime newDt = normaliseDateTime(dt, shifts);
        // - get the day of the DateTime as an Integer
        Integer dayI = DAYS_OF_WEEK.get(newDt.format('E'));
        // - get the shift start and end times as Time objects
        Time startTime = Time.newInstance(newDt.hour(), newDt.minute(),0,0); 
        Time endTime = stringToTime(shifts[dayI][1]);
        // - set a variable that holds the number of hours left to add
        Double leftToAdd = hoursToAdd;
        //BGSAMS Support PRB00014431 - code fix starts
        Time startTime1;
        Time endTime1;
        //BGSAMS Support PRB00014431- code fix ends
        // Whilst there are still hours to add, loop
        while(leftToAdd > 0) {
            // How many hours between start and end?
            Double hoursToday = subtractTime(endTime, startTime);
             system.debug('&&&&&&&&&&&&&&&  endTime'+endTime);
              system.debug('&&&&&&&&&&&&&&&  startTime'+startTime);
            system.debug('&&&&&&&&&&&&&&&  hoursToday (Subtract time)'+hoursToday);
            
            // Are there more hours in the current day than we have left to add?
            // If so, add the hours to the newDT DateTime and break.
            if(hoursToday >= leftToAdd) {
                system.debug('&&&&&&&&&&&&&&&  Inside if hoursToday >= leftToAdd ');
                newDt = addHoursToDT(newDt, leftToAdd);
                system.debug('&&&&&&&&&&&&&&&  Inside if hoursToday >= leftToAdd newDt '+newDt);
                break;
            }
            
            // Decrement leftToAdd by the number of hours in the current day. 
            leftToAdd -= hoursToday;
            system.debug('&&&&&&&&&&&&&&&  leftToAdd'+leftToAdd);
            // We need to loop to the next day - get the shift start and end times for the
            // next day, and set newDT to the start of the next day.
            
            dayI++;
            if(dayI>6)
            {
                //newDt = addHoursToDT(newDt, leftToAdd);
                break;
            }
            //BGSAMS Support PRB00014431 - code fix starts
            if(shifts[dayI][0] != null){
               
               startTime = stringToTime(shifts[dayI][0]); // next day's shift start
               endTime = stringToTime(shifts[dayI][1]); // next day's shift end
               
            }
            else{
                System.debug('Entering else loop - vincy');
                dayI--;
                startTime1= stringToTime(shifts[dayI][0]);
                endTime1 = stringToTime(shifts[dayI][1]);
                //dayI++;
                startTime = startTime1;
                endTime = endTime1;
            }
            
            //BGSAMS Support PRB00014431- code fix ends
            newDt = DateTime.newInstance(newDt.date().addDays(1), startTime);
        }
        
        return newDt;
    }
     
     public class ShiftException extends System.Exception{}
}