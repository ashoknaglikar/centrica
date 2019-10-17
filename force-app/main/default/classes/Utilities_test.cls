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
private class Utilities_test {

    static testMethod void myUnitTest() {
        
        set<id> temp = Utilities.profilesAllowedToDelete;
        string s = Utilities.appRTID;
        
        s = Utilities.avRTID;
        pagereference  pageRef = new pagereference('www.google.com');
        Utilities.buildParameterString(pageRef, 'test');
        Utilities.setup();
        
        id appid = Utilities.getRecordTypeId('Appointment', 'Appointment__c');
        Utilities.getRecordTypeName(appid);
        //Utilities.offersSetup();
        //Utilities.getOfferDescription(system.now());
        
        try{
           
        Utilities.findDistanceBetweenPostcodes('sk12lg','sk12ql',system.today());
        }
        catch (exception e)
        {
            
        }
        Utilities util = new Utilities();
        util.setErrorMsg(true,'This is error');
        util.setErrorMsg(false,'This is error');
        //Set<String> profileNames = new Set<String> {'CHI Installation Lead Engineer','CHI Installation - DHM' ,'System Administrator','CHI Customer Manager'};
        Utilities.fetchprofilenames('CHI Installation Lead Engineer,CHI Installation - DHM,System Administrator,CHI Customer Manager');
        
        user u = TestClassHelper.createUser();
        u.EmployeeNumber = '1234321';
        insert u;
                       
        /*Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        insert emp;
        
        Week__c week=TestClassHelper.createWeek(emp.id);
        insert week;
        week__c w=[select id,name,employee__c from week__c where id=:week.id ];
        //system.debug('--------------Employer name----------->'+employee__r.name);
       
        string recordtypeid='012200000009ipQ';  
        
        /*       
        Diary_Entry__c diary=TestClassHelper.createDe(week.id,recordtypeid);
        diary.
        insert diary;
        Diary_Entry__c D=[select id,Start__c,End__c,Job__c,Week__c,week__r.employee__c from Diary_Entry__c where id=:diary.id];
        
        
       // system.debug('--------------diary Employer name----------->'+d.week__r.employee__c);       
        //system.debug('--------------diary Employer name----------->'+d.recordtypeid);
        District__c  district=TestClassHelper.createDistrict();
        insert district;
        
        Account  acc=TestClassHelper.createAccout();
        insert acc;
        
        Opportunity  opp=TestClassHelper.createCHILead(Acc);       
        insert opp;
        
        Job__c  job=TestClassHelper.createJob('Planned','Awaiting Planned',opp.id,district.id);
        
        insert job;
        job__c a=[select id,name, Install_postcode__c, CHI_Lead__c from job__c where id=:job.id];
        system.debug('-------------->Install postcode--->'+a.Install_Postcode__c);
        system.debug('-------------->Install postcode--->'+a.CHI_Lead__c);
        string JobPostCode='SW19 6DZ'; 
               
        Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 8, 0, 0);
        
        Diary_Entry__c diary= new Diary_Entry__c(Start__c = startTime , End__c = endTime , Hours__c = 40, Week__c = week.id,Sub_Type__c='Mechanical',job__c=job.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        
        list<search_Result__c> searchlist=new list<search_result__c>();
                
        Search_Result__c newsearch=new Search_Result__c(
                                  Diary_Entry_ID__c = diary.ID,Start_Date_Time__c= startTime,Job_ID__c=a.id,skill__c='MECHANICAL', 
                                 End_Date_Time__c= endTime, name = 'NewTest');
        searchlist.add(newsearch);
        Search_Result__c newsearch1=new Search_Result__c(
                                  Diary_Entry_ID__c = diary.ID,Start_Date_Time__c= startTime,skill__c='MECHANICAL',Job_ID__c=a.id,
                                 End_Date_Time__c= endTime, name = 'NewTest1');
        searchlist.add(newsearch1);
        insert searchlist;    job.CHI_Lead__r.Install_Postcode__c
        */
        Job__c j = Phase3TestHelper.createJob1();
        j.Job_Reason__c = 'Green Deal';
        j.CRD_Code__c = 'Green Deal';
        j.Customer_Preferred_Date__c=system.today();
        update j;
        
        
        
        
        Job__c j1 = Phase3TestHelper.createJob5();
        j1.Job_Reason__c = 'Customer Requested';
        j1.CRD_Code__c = 'Direct labour only';
        j1.Customer_Preferred_Date__c=system.today();
        update j1;
        District__c district = Phase3TestHelper.createTestGeographyDistrict();
        Supplier__c supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Supplier_Num__c= :'2017' LIMIT 1];
                
         Employee__c e = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10,Salesforce_User__c = u.Id);
        Database.insert(e);
       
        //Employee__c e = Phase3TestHelper.createEmployee();
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Database.insert(sp);
        
         
        Week__c w = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
        Database.insert(w);
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
        DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
        Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='NWD - Working',job__c=j.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
       
        Database.insert(de);
        test.starttest();
        OFS_Quota_Data__c OFSData =new OFS_Quota_Data__c(Bucket_Name__c='Del Bucket', Date__c=system.today(), Slot_Type__c='AM', AM_All_day_unavailabilities_hours__c=0, AM_Internal_activities_hrs__c=0,  AM_Booked_activities__c=0, AM_Capacity_Available_Hrs__c=0, AM_Quota__c=0, AM_Category_Booked_Time_Hrs__c=0, AM_Total_Available_Hrs__c=0, AM_Total_Quota__c=0, AM_Total_Booked_Time_hrs__c=0);
        Database.insert(OFSData);
        Utilities.popluateExternalId(ofsData);
        Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='Mechanical',job__c=j.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        database.insert(de1);
        
        Diary_Entry__c de2 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='Mechanical',job__c=j1.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        database.insert(de2);
        list<search_Result__c> searchlist=new list<search_result__c>();
        
        Search_Result__c sr = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
       searchlist.add(sr);
        
        Search_Result__c sr1 = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j1.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        searchlist.add(sr1); 
        insert searchlist;  
        
        
        
        Utilities.calcluateIndayJobTime(SearchList,j.CHI_Lead__r.Install_Postcode__c,w.id);
        Utilities.calcluateIndayJobTime(SearchList,j1.CHI_Lead__r.Install_Postcode__c,w.id);
        date holidaydate=date.parse('25/12/2010');
        util .isTodayBankHoliday(holidaydate);
      // 
        
        map<double, string> temp2 = Utilities.categoryMap;
        set<string> temp1 = Utilities.defaultStatusReasonValues;
        s = Utilities.nonOpCategory;
        test.stoptest();
        // TO DO: implement unit test
    }
}