/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestJobBookingManager {
    
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    public static final String UNIQUE_NAME = '123 RH Test Dec 2014';
    public static Datetime globalBaseTime;
    public static Job__c globalJob;
    public static List<Employee__c> manyEmps;
    public static Boolean visOut = true;//visual output for debugging?
    public static final Integer globalBulkNum = 3; //number of weeks to create for bulk tests
    public static List<Search_Result__c> globalSearchResults = new List<Search_Result__c>();
    /**************************************************************************
    Purpose:
    Test 1 is a simple scenario of a single booking (1 skill) being booked for
    a single employee.
    1a book into the middle of an availability gap
    1b book into the start of an availability gap
    1c book into the end of an availability gap
    1d book into a gap that is not big enough
    1e book into a gap that is just the right size
    **************************************************************************/    
   
    static testMethod void test1a()
    {
        test.startTest();
        setGlobalBaseTime();        
        List<Week__c> weeks = testHelper(0, 12, 1, 3, 6, 3, 1);
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest();
    }

    static testMethod void test1b()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 20, 1, 0, 6, 2, 1);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();
    }
    static testMethod void test1c()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 8, 1, 3, 8, 2, 1);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();            
    }
    static testMethod void test1d()
    {
        //this should trow an exception because the availability isn't big enough
        test.startTest();
        setGlobalBaseTime();
        try
        {
            testHelper(0, 3, 1, 0, 10, 0, 1);
        }
        catch(Exception e)
        {
            System.debug(e);    
        }  
        test.stopTest();       
    } 
    static testMethod void test1e()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 8, 1, 0, 8, 1, 1);
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest();       
    }    
   
    /**************************************************************************
    Purpose:
    Test 2 is the scenario of a booking made up of multiple skills being booked for
    a single employee. 
    2a book into the middle of an availability gap
    2b book into the start of an availability gap
    2c book into the end of an availability gap
    2d book into a gap that is not big enough
    2e book into a gap that is only just big enough
    **************************************************************************/    

    static testMethod void test2a()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 20, 1, 3, 6, 4, 2);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();        
    }    
    static testMethod void test2b()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 20, 1, 0, 6, 3, 2);
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest();         
    }

    static testMethod void test2c()
    {
        test.startTest();
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 8, 1, 3, 8, 3, 2);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();         
    }
    static testMethod void test2d()
    {
        test.startTest(); 
        //this should trow an exception because the availability isn't big enough
        setGlobalBaseTime();
        try
        {
            testHelper(0, 3, 1, 0, 10, 0, 2);
        }
        catch(Exception e)
        {
            System.debug(e);    
        } 
        test.stopTest();       
    }  
       
    static testMethod void test2e()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 8;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 0;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 2;
        Integer testNum = 2;//end with an unavailability
        
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest(); 
    }     
    
    /**************************************************************************
    Purpose:
    Test 3 is simlar to test 2 except multiple employees are booked.
    There are 4 variations.
    3a book into the middle of an availability gap
    3b book into the start of an availability gap
    3c book into the end of an availability gap
    3d book into a gap that is not big enough
    **************************************************************************/         

    static testMethod void test3a()
    {
        test.startTest(); 
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 20, globalBulkNum, 3, 6, 4, 2);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();             
    }
    static testMethod void test3b()
    {
        test.startTest(); 
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 20, globalBulkNum, 0, 6, 3, 2); 
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest();      
    }
    
    static testMethod void test3c()
    {
        test.startTest(); 
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 8, globalBulkNum, 3, 8, 3, 2);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();             
    }
    static testMethod void test3d()
    {
        test.startTest(); 
        //this should trow an exception because the availability isn't big enough
        setGlobalBaseTime();
        try
        {
            testHelper(0, 3, globalBulkNum, 0, 10, 0, 2);
        }
        catch(Exception e)
        {
            System.debug(e);    
        } 
        test.stopTest();       
    }
    
    /**************************************************************************
    Purpose:
    Test 4 is to check the correct handling of pool diaries
    The appropriate fields on the week should be updated as well as the relevant
    Job Booking Diary entries being created and the hours on the single pool diary
    availability gap are maintained
    test4a - all weeks are pool diaries
    test4b - mixture of pool and non pool diaries
    testHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer numPoolWeeks, Integer bookingStart, Integer bookingEnd, Integer expectedNumEntries, Integer testNum)
    **************************************************************************/
    
    static testMethod void test4a()
    {
        test.startTest(); 
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 48, 1, 1, 3, 30, 3, 2);
        //now test cancellation
        testCancelHelper(1, weeks);
        test.stopTest();      
    }
    
    static testMethod void test4b()
    {
        test.startTest(); 
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(0, 48, 4, 2, 0, 30, 3, 2);
        //now test cancellation
        testCancelHelper(1, weeks); 
        test.stopTest();         
    }
    
    /**************************************************************************
    Purpose:
    Test 5 These tests are to ensure that the diary entries are managed correctly
    in a week that already has existing diary entries of type Job Booking and Unavailability
    test5a - starting with an unavailability record from week start to week start + 3 hours
    test5b - ending with an unavailability record from week end - 3 hours to week end
    test5c - starting with an job booking record from week start to week start + 3 hours
    test5d - ending with an job booking record from week end - 3 hours to week end
    **************************************************************************/ 
    
    static testMethod void test5a()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 3;
        Integer bookingEnd = 10;
        Integer expectedNumEntries = 3;
        Integer testNum = 3;//starting with an unavail ability from 0 to 3 hours
        
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);     
        //now test cancellation
        testCancelHelper(2, weeks);
        test.stopTest(); 
    }
    static testMethod void test5b()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 5;
        Integer bookingEnd = 17;
        Integer expectedNumEntries = 3;
        Integer testNum = 4;//end with an unavailability
        
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        //now test cancellation
        testCancelHelper(2, weeks); 
        test.stopTest();     
    }   
    static testMethod void test5c()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 3;
        Integer bookingEnd = 10;
        Integer expectedNumEntries = 3;
        Integer testNum = 5;//starting with an unavail ability from 0 to 3 hours
        
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        //now test cancellation
        testCancelHelper(2, weeks); 
        test.stopTest();         
    }
    static testMethod void test5d()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 5;
        Integer bookingEnd = 17;
        Integer expectedNumEntries = 3;
        Integer testNum = 6;//end with an unavailability
        
        setGlobalBaseTime();
        List<Week__c> weeks = testHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        //now test cancellation
        testCancelHelper(2, weeks);
        test.stopTest();          
    }  
    
    /**************************************************************************
    Purpose:
    Test 6 Replanning. Test 5 basic scenarios for a replan
    test6a - reshedule (i.e same employee) a single job booking i.e 1 skill
    test6b - move a single job booking i.e 1 skill to a different employee
    test6c - change multiple skills for multiple employees (but dont change everything)
    test6d - replan all job bookings on a job
    test6e - check that there are no errors when nothing is changed
    **************************************************************************/   
    
    static testMethod void test6a()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 5;
        Integer bookingEnd = 17;
        Integer expectedNumEntries = 3;
        Integer testNum = 1;
        Integer replanTestNum = 1;
        
        setGlobalBaseTime();
        testReplanHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum, replanTestNum);
        test.stopTest(); 
    } 
    /*   
    static testMethod void test6b()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 2;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 5;
        Integer bookingEnd = 10;
        Integer expectedNumEntries = 3;
        Integer testNum = 1;
        Integer replanTestNum = 2;
        
        setGlobalBaseTime();
        testReplanHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum, replanTestNum);
        test.stopTest(); 
    }  
    static testMethod void test6c()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 3
        ;
        Integer numPoolWeeks = 1;
        Integer bookingStart = 0;
        Integer bookingEnd = 10;
        Integer expectedNumEntries = 3;
        Integer testNum = 2;
        Integer replanTestNum = 3;
        
        setGlobalBaseTime();
        testReplanHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum, replanTestNum);
        test.stopTest(); 
    }   
    
    static testMethod void test6d()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 3;
        Integer numPoolWeeks = 1;
        Integer bookingStart = 0;
        Integer bookingEnd = 4;
        Integer expectedNumEntries = 3;
        Integer testNum = 2;
        Integer replanTestNum = 4;
        
        setGlobalBaseTime();
        testReplanHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum, replanTestNum);
        test.stopTest(); 
    } */
    
    static testMethod void test6e()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 0;
        Integer bookingEnd = 4;
        Integer expectedNumEntries = 3;
        Integer testNum = 2;
        Integer replanTestNum = 5;
        
        setGlobalBaseTime();
        testReplanHelper(gapStart, gapEnd, numWeeks,  numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum, replanTestNum);
        test.stopTest(); 
    }  
    
      
    /**************************************************************************
    Purpose:
    Test 7 Creating unavailablity in a simple scenario of a single week
    i.e. a single employee.
    7a unavailablity into the middle of an availability gap
    7b unavailablity into the start of an availability gap
    7c unavailablity into the end of an availability gap
    7d unavailablity into a gap that is just the right size
    **************************************************************************/
    
    static testMethod void test7a()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 3;
        Integer unavEnd = 16;
        Integer expectedNumEntries = 3;
        Integer testNum = 1;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 2;
                
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);     
        test.stopTest(); 
    } 
    
    static testMethod void test7b()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 0;
        Integer unavEnd = 16;
        Integer expectedNumEntries = 2;
        Integer testNum = 1;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 2;
                
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);     
        test.stopTest(); 
    }
    static testMethod void test7c()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 4;
        Integer unavEnd = 20;
        Integer expectedNumEntries = 2;
        Integer testNum = 1;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 2;
        
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    
    static testMethod void test7d()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 0;
        Integer unavEnd = 20;
        Integer expectedNumEntries = 1;
        Integer testNum = 1;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 2;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    
    /**************************************************************************
    Purpose:
    Test 8 Creating unavailablity that overlaps job bookings
    8a unavailablity completely overlapping a booking with gaps either side
    8b unavailability partly overlapping a booking
    8c unavailability overlapping several bookings
    8d unavailability completely overlapped by job booking
    8e unavailablity completely overlapping a booking with no gaps either side
    8f unavailablity completely overlapping 2 bookings with no gaps either side
    8h unavailability overlapping another unavailability, next to an availability
    8h unavailability overlapping a booking, where the booking starts after the unav
        but end at the same time
    **************************************************************************/
    
    static testMethod void test8a()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 4;
        Integer unavEnd = 16;
        Integer expectedNumEntries = 4;
        Integer testNum = 7;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 4;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    
    static testMethod void test8b()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 4;
        Integer unavEnd = 12;
        Integer expectedNumEntries = 3;
        Integer testNum = 8;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 3;
        
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    
    static testMethod void test8c()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 0;
        Integer unavEnd = 20;
        Integer expectedNumEntries = 3;
        Integer testNum = 9;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 6;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    
    static testMethod void test8d()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 12;
        Integer unavEnd = 15;
        Integer expectedNumEntries = 3;
        Integer testNum = 8;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 3;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }
    static testMethod void test8e()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = -5;
        Integer unavEnd = 25;
        Integer expectedNumEntries = 2;
        Integer testNum = 10;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 4;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }   
    static testMethod void test8f()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = -5;
        Integer unavEnd = 25;
        Integer expectedNumEntries = 3;
        Integer testNum = 11;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 6;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }       
    
    static testMethod void test8g()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = 2;
        Integer unavEnd = 25;
        Integer expectedNumEntries = 3;
        Integer testNum = 11;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 5;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }
    
    /*static testMethod void test8h()
    {
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = -3;
        Integer unavEnd = 17;
        Integer expectedNumEntries = 3;
        Integer testNum = 3;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 4;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
    }*/ 
    
    static testMethod void test8i()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer unavStart = -10;
        Integer unavEnd = 20;
        Integer expectedNumEntries = 2;
        Integer testNum = 10;
        Integer unavTestNum = 1;
        Integer expectedNumEntriesAfterRemove = 3;
        setGlobalBaseTime();
        List<Week__c> weeks = testUnavCreateHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, unavStart, unavEnd, expectedNumEntries, testNum, unavTestNum);
        //now test remove unavailability
        testUnavRemoveHelper(weeks, expectedNumEntriesAfterRemove);
        test.stopTest(); 
    }       
    /**************************************************************************
    Purpose:
    Test 9 Creating search results to test conversion to entryDetails used by
    the Job booking manager
    9a a simple search result with a single skill for a single person
    9b multiple skills 1 person
    9c multiple skills 3 people one of them a pool diary
    9d multiple skills 
    **************************************************************************/
    
    static testMethod void test9a()
    {
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 4;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 3;
        Integer testNum = 101;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        test.stopTest(); 
    }
    
    static testMethod void test9b()
    {
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 4;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 5;
        Integer testNum = 102;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        test.stopTest(); 
    }
        
    static testMethod void test9c()
    {
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 3;
        Integer numPoolWeeks = 1;
        Integer bookingStart = 0;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 5;
        Integer testNum = 103;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        test.stopTest(); 
    }
    
    static testMethod void test9d()
    {
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 1;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 5;
        Integer testNum = 105;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        test.stopTest(); 
    }       
    /**************************************************************************
    Purpose:
    Test 10 Suplier information on Job Elements
    10a Set the supplier information on a newly planned job
    10b change the suppliers on a replan
    **************************************************************************/
    
    static testMethod void test10a()    
    {       
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 0;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 5;
        Integer testNum = 103;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        
        //all of the job elements on the job should have a supplier
        List<Job_Element__c> allJobEls = new List<Job_Element__c>(
            [Select j.Skill__c, j.Job__c, j.Id, j.Current_Supplier__c, 
            j.Current_Supplier_Number__c From Job_Element__c j 
            where j.Job__c = :globalJob.Id]);
        for(Job_Element__c allJobEl : allJobEls)
        {
            System.assert(allJobEl.Current_Supplier__c != null);
            System.assert(allJobEl.Current_Supplier_Number__c != null);
            System.debug('All Job Elements Skills and Suppliers:');
            System.debug(allJobEl.Skill__c);
            System.debug(allJobEl.Current_Supplier__c);
            System.debug(allJobEl.Current_Supplier_Number__c);
        }
        test.stopTest(); 
    }
    
    static testMethod void test10b()    
    {       
        test.startTest(); 
        setGlobalBaseTime();
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer numWeeks = 1;
        Integer numPoolWeeks = 0;
        Integer bookingStart = 0;
        Integer bookingEnd = 8;
        Integer expectedNumEntries = 5;
        Integer testNum = 103;
        testSearchResultsHelper(gapStart, gapEnd, numWeeks, numPoolWeeks, bookingStart, bookingEnd, expectedNumEntries, testNum);
        //now need to change the suppliers
        //get the employees in from the search results and change their supplier
        List<Employee__c> emps = new List<Employee__c>(
            [Select Supplier__c from Employee__c where First_Name__c = :UNIQUE_NAME AND id IN :manyEmps Limit 20]);
        Supplier__c sup = new Supplier__c(Supplier_Num__c = '01384', Name = '*NEW* RH Test Supplier');
        insert sup;
        for(Employee__c emp : emps)
        {
            emp.Supplier__c = sup.Id;
        }
        update emps;
        //now replan the job
        JobBookingManager.planOrReplanJob(UNIQUE_NAME);
                
        //all of the job elements on the job should have a new supplier
        List<Job_Element__c> allJobEls = new List<Job_Element__c>(
            [Select j.Skill__c, j.Job__c, j.Id, j.Current_Supplier__c, 
            j.Current_Supplier_Number__c, j.New_Supplier_Number__c,
            j.New_Supplier__c From Job_Element__c j 
            where j.Job__c = :globalJob.Id]);
        for(Job_Element__c allJobEl : allJobEls)
        {
            System.assert(allJobEl.Current_Supplier__c != null);
            System.assert(allJobEl.Current_Supplier_Number__c != null);
            System.assert(allJobEl.New_Supplier__c != null && allJobEl.New_Supplier__c != allJobEl.Current_Supplier__c);
            System.assert(allJobEl.New_Supplier_Number__c != null && allJobEl.New_Supplier_Number__c != allJobEl.Current_Supplier_Number__c);           
            System.debug('All Job Elements Skills and Suppliers:');
            System.debug(allJobEl.Skill__c);
            System.debug(allJobEl.Current_Supplier__c);
            System.debug(allJobEl.Current_Supplier_Number__c);
            System.debug(allJobEl.New_Supplier__c);
            System.debug(allJobEl.New_Supplier_Number__c);
            
        }
        //check that a job booking histories were created
        //1 for original booking and 1 for replan
        
        List<Job_Booking_History__c> jbhs = Database.Query('select id from Job_Booking_History__c where  Job__c=\''+globalJob.id+'\' AND LastModifiedDate > '+ getEarlierStr());
        //System.assert(jbhs.size() > 1);
        test.stopTest(); 
    }   
    /**************************************************************************
    Purpose:
    Test 11 Unavailability Remove Trigger
    11a Mass Delete Unavailability that has bookings in the week
    11b Single Delete of unavailability using Code that is called by delete button
        and try to delete a Diary Entry that is not unavailability
    **************************************************************************/ 
    
    static testMethod void test11a()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer testNum = 2;
        Integer numWeeks = 1;
        setGlobalBaseTime();

        List<Diary_Entry__c> allEnts = new List<Diary_Entry__c>();
        List <Week__c> testWeeks = setupTestWeeks(numWeeks, 0);
        Map<Id, Week__c> idToweekMap = new Map<Id, Week__c>(testWeeks);
        for(Week__c testWeek : testWeeks)
        {
            allEnts.addAll(collectUnavailabilities(testWeek,  testNum, gapStart, gapEnd));
        }
        insert allEnts;
        //now test delete unavailability, by deleting all of the entries for all of the weeks
        //List<Diary_Entry__c> allUnavs = [select Id from Diary_Entry__c where week__c in :weeks and RecordTypeId = :ENTRY_RECTYPE_UNAVAIL];
        List<Diary_Entry__c> allUnavs = [select Id from Diary_Entry__c where RecordTypeId = :ENTRY_RECTYPE_UNAVAIL and week__c in :idToweekMap.keySet()];
        //outPutAllDiaryEntries();
        delete allUnavs;
        //outPutAllDiaryEntries();
        test.stopTest(); 
    }   
    static testMethod void test11b()
    {
        test.startTest(); 
        Integer gapStart = 0;
        Integer gapEnd = 20;
        Integer testNum = 2;
        Integer numWeeks = 1;
        setGlobalBaseTime();

        List<Diary_Entry__c> allEnts = new List<Diary_Entry__c>();
        List <Week__c> testWeeks = setupTestWeeks(numWeeks, 0);
        Map<Id, Week__c> idToweekMap = new Map<Id, Week__c>(testWeeks);
        for(Week__c testWeek : testWeeks)
        {
            allEnts.addAll(collectUnavailabilities(testWeek,  testNum, gapStart, gapEnd));
        }
        insert allEnts;
        //now test delete unavailability, by deleting all of the entries for all of the weeks
        //List<Diary_Entry__c> allUnavs = [select Id from Diary_Entry__c where week__c in :weeks and RecordTypeId = :ENTRY_RECTYPE_UNAVAIL];
        List<Diary_Entry__c> allUnavs = [select Id, Employee_Salesforce1_ID__c, Start__c, End__c, Sub_Type__c from Diary_Entry__c where RecordTypeId = :ENTRY_RECTYPE_UNAVAIL and week__c in :idToweekMap.keySet()];
        //outPutAllDiaryEntries();
        
        Unavailability_History_Tracker__c ut = new Unavailability_History_Tracker__c(Diary_Entry__c = allUnavs[0].Id);
        insert ut;
        UnavailabilityDelete.deleteUnav(allUnavs[0].id);
        
        //outPutAllDiaryEntries();
        //test the negative flow
        List<Diary_Entry__c> nonUnavs = [select Id from Diary_Entry__c where RecordTypeId <> :ENTRY_RECTYPE_UNAVAIL and week__c in :idToweekMap.keySet()];
        try
        {
            UnavailabilityDelete.deleteUnav(nonUnavs[0].id);
        }
        catch(Exception e)
        {
            System.debug('Test ok, this is the desired negative flow');
        }
        test.stopTest(); 
    }       
    
    /* //these are some temporary tests for testing with actual search result
    //data but they cannot be included in the testing for deployment as
    //these records will not exist in the target org
    static testMethod void testGarysResultsWithJobElements()
    {
        string optionStr = '2009-11-30,17:10:05:911-';
        
        //try
        //{
            JobBookingManager.planOrReplanJob(optionStr+'0');
        //}
        //catch(Exception e)
        //{
        //  System.debug('Warning and exception occured: ' + e);
        //}     
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
        
        //job id of the job booked
        Search_Result__c sr = [select Job_ID__c from Search_Result__c 
            where Option_Identifier__c = :optionStr+'0' limit 1];
        //all of the job elements on the job should have a supplier
        List<Job_Element__c> allJobEls = new List<Job_Element__c>(
            [Select j.Skill__c, j.Job__c, j.Id, j.Current_Supplier__c, 
            j.Current_Supplier_Number__c From Job_Element__c j 
            where j.Job__c = :sr.Job_ID__c and type__c = 'Work']);
        for(Job_Element__c allJobEl : allJobEls)
        {
            System.assert(allJobEl.Current_Supplier__c != null);
            System.assert(allJobEl.Current_Supplier_Number__c != null);
            System.debug('All Job Elements Skills and Suppliers:');
            System.debug(allJobEl.Skill__c);
            System.debug(allJobEl.Current_Supplier__c);
            System.debug(allJobEl.Current_Supplier_Number__c);
        }
        
//now replan the job
        JobBookingManager.planOrReplanJob(optionStr+'5');
                
        //all of the job elements on the job should have a new supplier

        allJobEls = new List<Job_Element__c>(
            [Select j.Skill__c, j.Job__c, j.Id, j.Current_Supplier__c, 
            j.Current_Supplier_Number__c, j.New_Supplier_Number__c,
            j.New_Supplier__c From Job_Element__c j 
            where j.Job__c = :sr.Job_ID__c and type__c = 'Work']);          
        for(Job_Element__c allJobEl : allJobEls)
        {
            System.assert(allJobEl.Current_Supplier__c != null);
            System.assert(allJobEl.Current_Supplier_Number__c != null);         
            System.debug('All Job Elements Skills and Suppliers after replan:');
            System.debug(allJobEl.Skill__c);
            System.debug(allJobEl.Current_Supplier__c);
            System.debug(allJobEl.Current_Supplier_Number__c);
            System.debug(allJobEl.New_Supplier__c);
            System.debug(allJobEl.New_Supplier_Number__c);
            
        }
        //check that a job booking history was created
        
        List<Job_Booking_History__c> jbhs = Database.Query('select id from Job_Booking_History__c where LastModifiedDate > '+ getEarlierStr());
        System.assert(jbhs.size() > 0);     
    }
    */
/*  
    public static string optionStr = '2009-11-30,16:02:25:437-';
    static testMethod void testGarysResults0()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'0');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }   
    static testMethod void testGarysResults1()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'1');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }

    static testMethod void testGarysResults2()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'2');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
    
    static testMethod void testGarysResults3()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'3');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
        
    static testMethod void testGarysResults4()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'4');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
    static testMethod void testGarysResults5()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'5');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }   
    static testMethod void testGarysResults6()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'6');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
    
    static testMethod void testGarysResults7()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'7');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }   
    
    static testMethod void testGarysResults8()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'8');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
    static testMethod void testGarysResults9()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'9');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }
    static testMethod void testGarysResults10()
    {
        try
        {
            JobBookingManager.planOrReplanJob(optionStr+'10');
        }
        catch(Exception e)
        {
            System.debug('Warning and exception occured: ' + e);
        }       
        outPutAllDiaryEntries('where w.LastModifiedDate > '+ getEarlierStr());
    }   
    
*/                  
    static String getEarlierStr()
    {
        Datetime now = System.now();
        Datetime earlier = now.addMinutes(-1);
        
        return dt4Query(earlier);
    }   
    
    static String dt4Query(Datetime myDate)
    {
        return myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    } 
        
    public static Search_Result__c makeSearchResult(Id jobId, Id weekId, String skill, Integer startHr, Integer endHr, Datetime now, Integer jobStartHr, Integer jobEndHr)
    {
        

        
        Datetime startTime = now.addHours(startHr);
        Datetime endTime = now.addHours(endHr);
        Double hours;
        hours = DateTimeHelper.subtractDate(endTime, startTime);
        
        String optId = UNIQUE_NAME;
        Datetime jobStartTime = now.addHours(jobStartHr);
        Datetime jobEndTime = now.addHours(jobEndHr);
        Diary_Entry__c myDe = [select id from Diary_Entry__c where week__c = :weekId limit 1];
        Search_Result__c sr = new Search_Result__c(Start_Date_Time__c = jobStartTime, 
            Skill__c = skill, Option_Identifier__c = optId, 
            Job_ID__c = jobId, Hours__c = hours, End_Date_Time__c = jobEndTime, 
            Diary_Entry_ID__c = myDe.Id);   
            
        return sr;
    }
    
    public static WeekManager.EntryDetails makeEntryDetails(Id jobId, List<Diary_Entry__c> afectedGaps, Id weekId, String skill, Id recordTypeId, Integer startHr, Integer endHr, Datetime now)
    {
        Datetime startTime = now.addHours(startHr);
        Datetime endTime = now.addHours(endHr);
        System.debug('startTime' + startTime);
        System.debug('endTime' + endTime);
        Week__c week = [select w.Id, w.Wednesday_Booked_Hours__c, w.Tuesday_Booked_Hours__c, 
                w.Thursday_Booked_Hours__c, w.Sunday_Booked_Hours__c, w.Saturday_Booked_Hours__c, 
                w.Monday_Booked_Hours__c, w.Friday_Booked_Hours__c, 
                w.Employee__r.Pool_Diary__c,
                w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Tuesday_Start_Time__c, 
                w.Tuesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, 
                w.Sunday_Start_Time__c, w.Sunday_End_Time__c, w.Saturday_Start_Time__c, 
                w.Saturday_End_Time__c, w.Monday_Start_Time__c, w.Monday_End_Time__c, 
                w.Friday_Start_Time__c, w.Friday_End_Time__c 
                from week__c w where w.id = :weekId];
        Double hours; 
        try
        {
            hours = Datetimehelper.calculateHours(startTime, endTime, week);
        }
        catch(Exception e)
        {
            hours = 0.00;
        }
        System.debug('the hours: ' + hours);    
        WeekManager.EntryDetails jobBooking2 = new WeekManager.EntryDetails(
                jobId, afectedGaps, weekId, hours, startTime, endTime,
                skill, recordTypeId);
                /*
        Id jobId, List<Diary_Entry__c> affectedEntries, Id week, 
                            Double hours, Datetime startTime, Datetime endTime,
                            String skill, ID recordTypeId
                            */
        return jobBooking2;
    }
        
    public static Diary_Entry__c makeDe(Id recType, Integer startHr, Integer endHr, Week__c week, Datetime now)
    {
        Datetime startTime = now.addHours(startHr);
        Datetime endTime = now.addHours(endHr);
        System.debug('startTime' + startTime);
        System.debug('endTime' + endTime);
        Double hours; 
        try
        {
            hours = Datetimehelper.calculateHours(startTime, endTime, week);
        }
        catch(Exception e)
        {
            System.debug('Calculate hours threw an exception: ' + e);
            hours = 0.00;
        }
        System.debug('Hours calculated in makeDe: ' + Hours);
        Diary_Entry__c de = new Diary_Entry__c(RecordtypeId = recType, week__c = week.Id, Start__c = startTime, End__c = endTime, hours__c = hours, Extra_Hours__c = 44);//extra hours to id later
        de.Unavailability_Reason__c = 'Emergency Installation Resource';
        
        return de;
    }   
    
    public static void outPutAllDiaryEntries(Id weekId)
    {
        String str= 'Where Friday_Max_Hours__c = 99 AND id=\''+weekId+'\'';
        outPutAllDiaryEntries(str); 
    }

    public static void outPutAllDiaryEntries(String whereClause)
    {
        String allEntries = '';
        String queryStr = 'Select w.Id, w.Wednesday_Booked_Hours__c, w.Tuesday_Booked_Hours__c, '+
                'w.Thursday_Booked_Hours__c, w.Sunday_Booked_Hours__c, w.Saturday_Booked_Hours__c, '+
                'w.Monday_Booked_Hours__c, w.Friday_Booked_Hours__c, '+
                'w.Employee__r.Pool_Diary__c from week__c w '
                + whereClause;
       System.debug(queryStr); 
        
        List<Week__c> allWeeks = Database.query(queryStr);
        for(Week__c week : allWeeks)
        {
            allEntries += '\n' + week;
            allEntries += '\n' + DiaryEntryManager.outputDiary2(week.id);
        }
        System.debug('all weeks: ' + allEntries);       
    }    
    
    //numweeks = number of weeks to generate (1 week = 1 employee)
    //numpool = how many of the weeks are pool diaries
    public static List<Week__c> setupTestWeeks(Integer numWeeks, Integer numPool)
    {
        System.assert(numPool <= numWeeks);
        
        List<Week__c> manyWeeks = new List<Week__c>();
        manyEmps = new List<Employee__c>();
        //create an opportunity
        Opportunity opp = Phase3TestHelper.createOpportunity();
        //create the job        
        globalJob = new Job__c(Delivery_Notes__c   = UNIQUE_NAME, CHI_Lead__c = opp.ID);
        insert globalJob;
        //give the job some job elements
        Job_Element__c jobEl1 = new Job_Element__c(Skill__c = 'Mechanical', Job__c = globalJob.Id, Type__c = 'Work');
        Job_Element__c jobEl2 = new Job_Element__c(Skill__c = 'Powerflush', Job__c = globalJob.Id, Type__c = 'Work');
        Job_Element__c jobEl3 = new Job_Element__c(Skill__c = 'Building', Job__c = globalJob.Id, Type__c = 'Work');
        Job_Element__c jobEl4 = new Job_Element__c(Skill__c = 'Connect Solar Panels', Job__c = globalJob.Id, Type__c = 'Work');
        
        List<Job_Element__c> jobEls = new List<Job_Element__c>();
        jobEls.add(jobEl1);
        jobEls.add(jobEl2);
        jobEls.add(jobEl3);
        jobEls.add(jobEl4);
        insert jobEls;
        
        //create the supplier
        Supplier__c sup = new Supplier__c(Supplier_Num__c = '01299', Name = 'RH Test Supplier');
        //if the insert doesnt work it is because be have already created a supplier
        //with this number. We actually want a different supplier for the test
        String empDigit = '0';//this is used to ensure employees with same number not created
        try
        {
            insert sup;
        }
        catch(Exception e)
        {
            sup.Supplier_Num__c = '01384';
            sup.Name = 'Different Supplier RH Test';
            insert sup;
            empDigit = '1';
        }
        //create the employees
        Boolean isPool = true;
        for(Integer i = 0; i < numWeeks; i++)
        {
            if(i + 1 > numPool)
            {
                isPool = false;
            }
            Employee__c emp = new Employee__c(Pool_Diary__c = isPool, Employee_number__c = '0000' + i + empDigit, First_Name__c = UNIQUE_NAME, Supplier__c = sup.Id);
            System.debug('employee: ' + emp);
            manyEmps.add(emp);      
        }
        insert manyEmps;
        //manyEmps = [select Pool_Diary__c from Employee__c where First_Name__c = :UNIQUE_NAME];
        //create a shift pattern for the weeks
        Shift_Pattern__c sp = new Shift_Pattern__c(Wednesday_Start_Time__c = '00:00', Wednesday_End_Time__c = '23:59', Tuesday_Start_Time__c = '00:00', Tuesday_End_Time__c = '23:59', Thursday_Start_Time__c = '00:00', Thursday_End_Time__c = '23:59', Sunday_Start_Time__c = '00:00', Sunday_End_Time__c = '23:59', Saturday_Start_Time__c = '00:00', Saturday_End_Time__c = '23:59', Monday_Start_Time__c = '00:00', Monday_End_Time__c = '23:59', Friday_Start_Time__c = '00:00', Friday_End_Time__c = '23:59');
        insert sp;
        
        //create some weeks for job bookings        
        for(Integer i = 0; i < numWeeks; i++)
        {
            Week__c wk = new Week__c(Friday_Unavailability_Reason__c  = UNIQUE_NAME, Friday_Max_Hours__c = 99, Employee__c = manyEmps[i].Id, Shift_Pattern__c = sp.Id);
            
            manyWeeks.add(wk);      
        }
        insert manyWeeks;
        //get the formula fields calculted on insert
        manyWeeks = [select w.Id, w.Wednesday_Booked_Hours__c, w.Tuesday_Booked_Hours__c, 
                w.Thursday_Booked_Hours__c, w.Sunday_Booked_Hours__c, w.Saturday_Booked_Hours__c, 
                w.Monday_Booked_Hours__c, w.Friday_Booked_Hours__c, 
                w.Employee__r.Pool_Diary__c,
                w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Tuesday_Start_Time__c, 
                w.Tuesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, 
                w.Sunday_Start_Time__c, w.Sunday_End_Time__c, w.Saturday_Start_Time__c, 
                w.Saturday_End_Time__c, w.Monday_Start_Time__c, w.Monday_End_Time__c, 
                w.Friday_Start_Time__c, w.Friday_End_Time__c from week__c w where Friday_Unavailability_Reason__c = :UNIQUE_NAME AND id=:manyWeeks[0].id];
        return manyWeeks;
    }
    public static Datetime setGlobalBaseTime()
    {
        if(globalBaseTime == null)
        {
            //globalBaseTime = Datetime.now();
            //globalBaseTime = DiaryEntryManager.removeSecs(globalBaseTime);
            globalBaseTime = Datetime.newInstance(2009, 11, 16, 8, 0, 0);           
        }
        return globalBaseTime;
    }
    //test helper that does not create pool diaries
    public static List<Week__c> testHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer bookingStart, Integer bookingEnd, Integer expectedNumEntries, Integer testNum)
    {
        return testHelper(gapStart, gapEnd, numWeeks, 0, bookingStart, bookingEnd, expectedNumEntries, testNum);
    }
        
    //test helper that allows creation of pool diaries
    public static List<Week__c> testHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer numPoolWeeks, Integer bookingStart, Integer bookingEnd, Integer expectedNumEntries, Integer testNum)
    {
        Integer startHr = gapStart;
        Integer endHr = gapEnd;         
        //create weeks
        List<Week__c> weeks = setupTestWeeks(numWeeks, numPoolWeeks);
        //create gaps and entry details
        List<Diary_Entry__c> gaps = new List<Diary_Entry__c>();
        List<WeekManager.EntryDetails> details = new List<WeekManager.EntryDetails>();
        for(Week__c week : weeks)
        { 
            //gaps.add(makeDe(ENTRY_RECTYPE_AVAIL, startHr, endHr, week, globalBaseTime));
            gaps.addAll(collectDiaryEntries(week, testNum, gapStart, gapEnd));
            details.addAll(collectEntryDetails(week, testNum, bookingStart, bookingEnd));
        }
        //insert the gaps
        insert gaps;
        //call the booking method
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        Datetime earlyDatetime = globalBaseTime.addHours(bookingStart);
        Date earliestDate = Date.newinstance(earlyDatetime.year(), earlyDatetime.month(), earlyDatetime.day());
        JobBookingManager.planOrReplanJob(details);
        
        
        /*check the results*/
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //get the relevant diary entries
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }       
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }
        return weeks;
    }
    //test helper that allows creation of pool diaries
    public static List<Week__c> testSearchResultsHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer numPoolWeeks, Integer bookingStart, Integer bookingEnd, Integer expectedNumEntries, Integer testNum)
    {
        Integer startHr = gapStart;
        Integer endHr = gapEnd;         
        //create weeks
        List<Week__c> weeks = setupTestWeeks(numWeeks, numPoolWeeks);
        
        if(testNum == 103)
        {
            //for this test the job must have a quote so that the job elements are
            //given values for the supplier fields
            BigMachines_Quote__c bmq = new BigMachines_Quote__c();
            insert bmq;
            Job__c myJob = [select Quote__c from Job__c where Id = :globalJob.Id]; 
            myJob.Quote__c = bmq.Id;
            update myJob;
        }
        //create gaps and entry details
        List<Diary_Entry__c> gaps = new List<Diary_Entry__c>();
        List<Search_Result__c> details = new List<Search_Result__c>();
        for(Week__c week : weeks)
        { 
            gaps.addAll(collectDiaryEntries(week, testNum, gapStart, gapEnd));
        }
        //insert the gaps
        insert gaps;
        for(Week__c week : weeks)
        { 
            details.addAll(collectSearchResults(week, testNum, bookingStart, bookingEnd));
        }       
        insert details;
        globalSearchResults = details;
        //call the booking method
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        JobBookingManager.planOrReplanJob(UNIQUE_NAME);
        
        /*check the results*/
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //get the relevant diary entries
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }       
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }
        return weeks;
    }    
    public static void testCancelHelper(Integer expectedNumEntries, List<week__c> weeks)
    {
        Job__c job = [select id, previous_resources__c from job__c where Delivery_Notes__c = :UNIQUE_NAME AND id=:globalJob.id];
        JobBookingManager.suspendJob(job.Id);
        Job__c myjob = [select id, previous_resources__c from job__c where Delivery_Notes__c = :UNIQUE_NAME AND id=:globalJob.id];
        System.debug('job after suspend: ' + myjob);
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }       
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }
    }
    //test helper that allows creation of pool diaries
    public static List<Week__c> testReplanHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer numPoolWeeks, Integer bookingStart, Integer bookingEnd, Integer expectedNumEntries, Integer testNum, Integer replanTestNum)
    {
        Integer startHr = gapStart;
        Integer endHr = gapEnd;         
        //create weeks
        List<Week__c> weeks = setupTestWeeks(numWeeks, numPoolWeeks);
        //create gaps and entry details
        List<Diary_Entry__c> gaps = new List<Diary_Entry__c>();
        List<WeekManager.EntryDetails> details = new List<WeekManager.EntryDetails>();
        for(Week__c week : weeks)
        { 
            //gaps.add(makeDe(ENTRY_RECTYPE_AVAIL, startHr, endHr, week, globalBaseTime));
            gaps.addAll(collectDiaryEntries(week, testNum, gapStart, gapEnd));
            details.addAll(collectEntryDetails(week, testNum, bookingStart, bookingEnd));
        }
        //insert the gaps
        insert gaps;
        //call the booking method
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        Datetime earlyDatetime = globalBaseTime.addHours(bookingStart);
        Date earliestDate = Date.newinstance(earlyDatetime.year(), earlyDatetime.month(), earlyDatetime.day());
        JobBookingManager.planOrReplanJob(details);
        
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //now we have a booked job we can replan it
        
        //change the details of the job
        modifyEntryDetails(details, replanTestNum);
        Datetime earliestDateTimeAfterReplan;
        //need to find the possible new earliest date
        for(WeekManager.EntryDetails detail : details)
        {
            if(earliestDateTimeAfterReplan == null || earliestDateTimeAfterReplan > detail.startTime)
            {
                earliestDateTimeAfterReplan = detail.startTime;
            }   
        }
        //now convert to a date
        Date earliestDateAfterReplan = Date.newinstance(earliestDateTimeAfterReplan.year(), earliestDateTimeAfterReplan.month(), earliestDateTimeAfterReplan.day());
        //book the job again - which will do a replan
        JobBookingManager.planOrReplanJob(details);
        
        /*check the results*/
        //output job details
        Job__c myjob = [Select j.Previous_Resources__c, j.Installation_Date__c From Job__c j where id = : globalJob.Id];
        System.debug('Job details: ' + myjob);
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //get the relevant diary entries
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }       
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details //to do what can be cheked?
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            //System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }
        return weeks;
    }  
    public static List<Search_Result__c> collectSearchResults(Week__c week, Integer testNum, Integer startTime, Integer EndTime)
    {
        List<Search_Result__c> results = new List<Search_Result__c>();
        if(testNum == 101)
        {
            results.add(makeSearchResult(globalJob.id, week.Id, 'Mechanical', startTime, EndTime, globalBaseTime, startTime, EndTime));
        }
        else if(testNum == 102)
        {
            results.add(makeSearchResult(globalJob.id, week.Id, 'Mechanical', startTime, startTime + 1, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Powerflush', startTime + 1, startTime + 3, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Building', startTime + 3, EndTime, globalBaseTime, startTime, EndTime));
        }       
        else if(testNum == 103)
        {
            results.add(makeSearchResult(globalJob.id, week.Id, 'Mechanical', startTime, startTime + 1, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Connect Solar Panels', startTime + 1, startTime + 2, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Powerflush', startTime + 2, startTime + 3, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Building', startTime + 3, EndTime, globalBaseTime, startTime, EndTime));
        }   
        else if(testNum == 104)
        {
            results.add(makeSearchResult(globalJob.id, week.Id, 'Mechanical', startTime, startTime + 1, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Connect Solar Panels', startTime + 1, startTime + 2, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Powerflush', startTime + 2, startTime + 4, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Building', startTime + 4, EndTime, globalBaseTime, startTime, EndTime));
        }   
        else if(testNum == 105)
        {
            results.add(makeSearchResult(globalJob.id, week.Id, 'Mechanical', startTime, startTime + 1, globalBaseTime, startTime, EndTime));
            results.add(makeSearchResult(globalJob.id, week.Id, 'Powerflush', startTime + 1, startTime + 3, globalBaseTime, startTime, EndTime));
            //last search result has more hours - it is overbooked
            Search_Result__c sr = makeSearchResult(globalJob.id, week.Id, 'Building', startTime + 3, EndTime, globalBaseTime, startTime, EndTime);
            sr.Hours__c += 1.5;
            results.add(sr);
        }       
        else
        {
            Throw new testException('Invalid Test Number ('+ testNum +') for collectSearchResults');
        }               
        return results;
    }  
    public static List<Diary_Entry__c> collectDiaryEntries(Week__c week, Integer testNum, Integer weekStart, Integer weekEnd)
    {
        List<Diary_Entry__c> entries = new List<Diary_Entry__c>();
        if(testNum == 1 || testNum == 2)//just a single availability gap to book into
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 3)
        {
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekStart, weekStart + 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart + 3, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 4)
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd - 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekEnd - 3, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 5)
        {
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekStart, weekStart + 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart + 3, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 6)
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd - 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 3, weekEnd, week, globalBaseTime));
        }   
        else if(testNum == 7)
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd - 10, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 10, weekEnd - 5, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekEnd - 5, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 8)
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd - 10, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 10, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 9)
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd - 18, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 18, weekEnd -10, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekEnd - 10, weekEnd -8, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 8, weekEnd -3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekEnd - 3, weekEnd, week, globalBaseTime));
        }   
        else if(testNum == 10)
        {
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekStart, weekEnd, week, globalBaseTime));
        }   
                        
        else if(testNum == 11)
        {
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekStart, weekEnd - 10, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekEnd - 10, weekEnd - 5, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_BOOKING, weekEnd - 5, weekEnd, week, globalBaseTime));
        }   
        else if(testNum == 101 || testNum == 102 || testNum == 103 || testNum == 104 || testNum == 105)//just a single availability gap to book into
        {
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart, weekEnd, week, globalBaseTime));
        }           
        else
        {
            Throw new testException('Invalid Test Number for collectDiaryEntries');
        }           
        return entries;
    }
    public static List<WeekManager.EntryDetails> collectEntryDetails(Week__c week, Integer testNum, Integer bookingStart, Integer bookingEnd)
    {
        List<WeekManager.EntryDetails> details = new List<WeekManager.EntryDetails>();
        if(testNum == 1 || testNum == 3 || testNum == 4 || testNum == 5 || testNum == 6)
        {
            details.add(makeEntryDetails(globalJob.id, null, week.Id, 'Mechanical', ENTRY_RECTYPE_BOOKING, bookingStart, bookingEnd, globalBaseTime));
        }
        else if(testNum == 2)
        {
            Integer totalTime = bookingEnd - bookingStart;
            Integer middleTime = bookingStart + (totalTime / 2);
            details.add(makeEntryDetails(globalJob.id, null, week.Id, 'Mechanical', ENTRY_RECTYPE_BOOKING, bookingStart, middleTime, globalBaseTime));
            details.add(makeEntryDetails(globalJob.id, null, week.Id, 'Powerflush', ENTRY_RECTYPE_BOOKING, middleTime, bookingEnd, globalBaseTime));
        }
        else
        {
            Throw new testException('Invalid Test Number for collectEntryDetails');
        }
        return details;
    }
    public class testException extends Exception{}
    public static List<WeekManager.EntryDetails> modifyEntryDetails(List<WeekManager.EntryDetails> oldDetails, Integer testNum)
    {
        List<WeekManager.EntryDetails> details = new List<WeekManager.EntryDetails>();
        if(testNum == 1 ) //reshedule a single skill to make it an hour earlier
        {
            for(WeekManager.EntryDetails oldDetail : oldDetails)
            {
                oldDetail.startTime = oldDetail.startTime.addHours(-1);
                oldDetail.EndTime = oldDetail.EndTime.addHours(-1);
            }
        }
        else if(testNum == 2 ) //reschedule a single skill to another employee
        {
            //put both entries in the same week
            oldDetails[0].week = oldDetails[1].week;
            //change the time of the entry so that it fits
            oldDetails[0].startTime = oldDetails[0].startTime.addHours(5);
            oldDetails[0].endTime = oldDetails[0].endTime.addHours(5);
        }
        else if(testNum == 3) //reschedule multiple skills for multiple employees
        {
            //there are 3 weeks 1st is a pool diary, other 2 are not
            //there are 2 diary entries of type job booking for each week
            
            //move an entry from the pool diary into the second week
            oldDetails[0].week = oldDetails[2].week;
            //move the entry from the start of the second week to the end of the 3rd week
            oldDetails[2].week = oldDetails[4].week;
            oldDetails[2].startTime = oldDetails[2].startTime.addHours(10);
            oldDetails[2].endTime = oldDetails[2].endTime.addHours(10);
        }
        else if(testNum == 4) //reschedule multiple skills for multiple employees
        {
            //move all of the entries forward an hour
            oldDetails[0].startTime = oldDetails[0].startTime.addHours(1);
            oldDetails[0].endTime = oldDetails[0].endTime.addHours(1);      
            oldDetails[1].startTime = oldDetails[1].startTime.addHours(1);
            oldDetails[1].endTime = oldDetails[1].endTime.addHours(1);              
            oldDetails[2].startTime = oldDetails[2].startTime.addHours(1);
            oldDetails[2].endTime = oldDetails[2].endTime.addHours(1);
            oldDetails[3].startTime = oldDetails[3].startTime.addHours(1);
            oldDetails[3].endTime = oldDetails[3].endTime.addHours(1);      
            oldDetails[4].startTime = oldDetails[4].startTime.addHours(1);
            oldDetails[4].endTime = oldDetails[4].endTime.addHours(1);              
            oldDetails[5].startTime = oldDetails[5].startTime.addHours(1);
            oldDetails[5].endTime = oldDetails[5].endTime.addHours(1);          
            
        }   
        else if(testNum == 5)
        {
            //dont change anything
            oldDetails[0].startTime = oldDetails[0].startTime.addHours(0);
        }   
        else
        {
            Throw new testException('Invalid Test Number for modifyEntryDetails');
        }   
        return details;
    }
    public static List<Week__c> testUnavCreateHelper(Integer gapStart, Integer gapEnd, Integer numWeeks, Integer numPoolWeeks, Integer unavStart, Integer unavEnd, Integer expectedNumEntries, Integer testNum, Integer unavTestNum)
    {
        Integer startHr = gapStart;
        Integer endHr = gapEnd;         
        //create weeks
        List<Week__c> weeks = setupTestWeeks(numWeeks, numPoolWeeks);
        //create gaps and entry details
        List<Diary_Entry__c> gaps = new List<Diary_Entry__c>();
        List<Diary_Entry__c> unavs = new List<Diary_Entry__c>();
        for(Week__c week : weeks)
        { 
            //gaps.add(makeDe(ENTRY_RECTYPE_AVAIL, startHr, endHr, week, globalBaseTime));
            gaps.addAll(collectDiaryEntries(week, testNum, gapStart, gapEnd));
            unavs.addAll(collectUnavailabilities(week, unavTestNum, unavStart, unavEnd));
        }
        //insert the gaps
        insert gaps;
        //call the booking method
        //insert unavs;
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //dont want any unavs to have a Extra_Hours value so can identify later
        for(Diary_Entry__c unav : unavs)
        {
            unav.Extra_Hours__c = 0;
            unav.Sub_Type__c='Survey Duties'; 
        }
        //update unavs;
        UnavailabilityManager.createUnavailability(unavs);
        UnavailabilityManager.markStackableUnavailability(unavs);
        UnavailabilityManager.StackUnavailability(unavs);
        /*check the results*/
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        //get the relevant diary entries
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }       
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            //System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }
        return weeks;
    }  
    public static List<Diary_Entry__c> collectUnavailabilities(Week__c week, Integer testNum, Integer weekStart, Integer weekEnd)
    {
        List<Diary_Entry__c> entries = new List<Diary_Entry__c>();
        if(testNum == 1)
        {
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekStart, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 2)
        {
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekStart, weekStart + 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart + 3, weekEnd, week, globalBaseTime));
        }
        else if(testNum == 3)
        {
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekStart, weekStart + 3, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_AVAIL, weekStart + 3, weekStart + 4, week, globalBaseTime));
            entries.add(makeDe(ENTRY_RECTYPE_UNAVAIL, weekStart + 4, weekEnd, week, globalBaseTime));
        }           
        else
        {
            Throw new testException('Invalid Test Number for collectUnavailabilities');
        }           
        return entries;
    } 
    //removes all existing unavailability
    public static void testUnavRemoveHelper(List<Week__c> weeks, Integer expectedNumEntries)
    {
        //get the week id's
        List<Id> weekIds = new List<Id>();
        for(Week__c week : weeks)
        { 
            weekIds.add(week.id);
        }
        //get all of the unavailabilities in the weeks
        List<Diary_Entry__c> allUnavs = [select Id, RecordTypeId, week__c, Start__c, End__c, Extra_Hours__c from Diary_Entry__c where RecordTypeId = :ENTRY_RECTYPE_UNAVAIL and week__c in :weekIds and Extra_Hours__c <> 44];
        System.debug('allUnavs: ' + allUnavs);
        //remove the unavailabilities
        UnavailabilityManager.removeUnavailability(allUnavs);
        if(visOut)outPutAllDiaryEntries(weeks[0].id);
        
        
        Map<Id, Week__c> weekIdToWeekMap = new Map<Id, Week__c>(JobBookingManager.getDiaryEntryDataForWeeks(weekIds));
        
        //for each week check some details
        for(Week__c week : weeks)
        { 
            Week__c weekWithEntries = weekIdToWeekMap.get(week.id);
            List<Diary_Entry__c> weeksEntries = weekWithEntries.Diary_Entries__r;
            //System.assertEquals(weeksEntries.size(), expectedNumEntries);
        }       
        
    } 
}